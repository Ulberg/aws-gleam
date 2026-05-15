//// IMDSv2 (Instance Metadata Service version 2) flow.
////
//// 1. PUT `<endpoint>/latest/api/token` with an `X-aws-ec2-metadata-token-
////    ttl-seconds` header → session token in body.
//// 2. GET `<endpoint>/latest/meta-data/iam/security-credentials/` with the
////    token in `X-aws-ec2-metadata-token` → role name in body.
//// 3. GET `<endpoint>/latest/meta-data/iam/security-credentials/<role>` with
////    the same token → JSON body with `AccessKeyId`, `SecretAccessKey`,
////    `Token`, `Expiration`.
////
//// The PUT in step 1 is what makes this "v2": it requires a session token
//// that an SSRF attacker bouncing requests off the instance can't easily
//// obtain. v1 is intentionally not implemented.
////
//// Errors are classified so the chain can do the right thing:
////   - Step 1 fails (DNS, connect, non-200) → `NotOnInstance` so the chain
////     falls through to the next provider quietly.
////   - Anything after step 1 succeeds-then-fails → `Failed` so the user sees
////     a loud "you're on EC2 but IMDS is misbehaving" signal.

import aws/internal/datetime
import aws/internal/http_send.{type Send}
import gleam/bit_array
import gleam/dynamic/decode
import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/json
import gleam/result

pub type Options {
  Options(endpoint: String, token_ttl_seconds: Int)
}

pub fn default_options() -> Options {
  Options(endpoint: "http://169.254.169.254", token_ttl_seconds: 21_600)
}

/// Decoded credentials, kept as a flat record so this module doesn't depend
/// on `aws/credentials`. The caller wraps these into the canonical
/// `credentials.Credentials` value.
pub type ImdsCredentials {
  ImdsCredentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: String,
    expires_at: Int,
  )
}

pub type Error {
  /// Step 1 failed (connect refused, 401, 404, timeout). The standard signal
  /// that we're not running on EC2 / Lambda. Chain should keep going.
  NotOnInstance(reason: String)
  /// Anything past step 1 — the instance answered the token PUT but the
  /// downstream calls failed. Worth surfacing to the user.
  Failed(reason: String)
}

/// Run the full IMDSv2 flow. Returns decoded credentials or a categorised
/// error. The `send` callback is the only side-effect surface — tests pass
/// a stub here.
pub fn fetch(send: Send, options: Options) -> Result(ImdsCredentials, Error) {
  use token <- result.try(get_token(send, options))
  use role <- result.try(get_role(send, options, token))
  get_credentials(send, options, token, role)
}

fn get_token(send: Send, options: Options) -> Result(String, Error) {
  let url = options.endpoint <> "/latest/api/token"
  use req <- result.try(
    build_request(
      http.Put,
      url,
      [
        #(
          "x-aws-ec2-metadata-token-ttl-seconds",
          int.to_string(options.token_ttl_seconds),
        ),
      ],
      bit_array.from_string(""),
    )
    |> result.map_error(fn(reason) { NotOnInstance(reason: reason) }),
  )
  use resp <- result.try(
    send(req)
    |> result.map_error(fn(e) {
      NotOnInstance(reason: "token request transport: " <> describe_http(e))
    }),
  )
  case resp.status {
    200 ->
      bit_array.to_string(resp.body)
      |> result.replace_error(NotOnInstance(
        reason: "non-utf8 token response body",
      ))
    other ->
      Error(NotOnInstance(
        reason: "token request returned status " <> int.to_string(other),
      ))
  }
}

fn get_role(
  send: Send,
  options: Options,
  token: String,
) -> Result(String, Error) {
  let url = options.endpoint <> "/latest/meta-data/iam/security-credentials/"
  use req <- result.try(
    build_request(http.Get, url, token_header(token), bit_array.from_string(""))
    |> result.map_error(fn(reason) { Failed(reason: reason) }),
  )
  use resp <- result.try(
    send(req)
    |> result.map_error(fn(e) {
      Failed(reason: "role listing transport: " <> describe_http(e))
    }),
  )
  case resp.status {
    200 ->
      bit_array.to_string(resp.body)
      |> result.replace_error(Failed(reason: "non-utf8 role listing body"))
    other ->
      Error(Failed(
        reason: "role listing returned status " <> int.to_string(other),
      ))
  }
}

fn get_credentials(
  send: Send,
  options: Options,
  token: String,
  role: String,
) -> Result(ImdsCredentials, Error) {
  let url =
    options.endpoint <> "/latest/meta-data/iam/security-credentials/" <> role
  use req <- result.try(
    build_request(http.Get, url, token_header(token), bit_array.from_string(""))
    |> result.map_error(fn(reason) { Failed(reason: reason) }),
  )
  use resp <- result.try(
    send(req)
    |> result.map_error(fn(e) {
      Failed(reason: "credentials fetch transport: " <> describe_http(e))
    }),
  )
  case resp.status {
    200 -> decode_credentials(resp.body)
    other ->
      Error(Failed(
        reason: "credentials endpoint returned status " <> int.to_string(other),
      ))
  }
}

fn token_header(token: String) -> List(#(String, String)) {
  [#("x-aws-ec2-metadata-token", token)]
}

fn build_request(
  method: http.Method,
  url: String,
  headers: List(#(String, String)),
  body: BitArray,
) -> Result(Request(BitArray), String) {
  use base <- result.try(
    request.to(url)
    |> result.replace_error("invalid URL: " <> url),
  )
  let withed =
    base
    |> request.set_method(method)
    |> request.set_body(body)
  Ok(apply_headers(withed, headers))
}

fn apply_headers(
  req: Request(BitArray),
  headers: List(#(String, String)),
) -> Request(BitArray) {
  case headers {
    [] -> req
    [#(k, v), ..rest] -> apply_headers(request.set_header(req, k, v), rest)
  }
}

fn describe_http(error: http_send.HttpError) -> String {
  case error {
    http_send.ConnectFailed(reason: reason) -> "connect failed: " <> reason
    http_send.Timeout -> "timeout"
    http_send.InvalidBody(reason: reason) -> "invalid body: " <> reason
    http_send.Other(reason: reason) -> reason
  }
}

// ---- credentials response decoding ----

type RawCredentials {
  RawCredentials(
    code: String,
    access_key_id: String,
    secret_access_key: String,
    token: String,
    expiration: String,
  )
}

fn raw_decoder() -> decode.Decoder(RawCredentials) {
  use code <- decode.field("Code", decode.string)
  use access_key_id <- decode.field("AccessKeyId", decode.string)
  use secret_access_key <- decode.field("SecretAccessKey", decode.string)
  use token <- decode.field("Token", decode.string)
  use expiration <- decode.field("Expiration", decode.string)
  decode.success(RawCredentials(
    code: code,
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    token: token,
    expiration: expiration,
  ))
}

fn decode_credentials(body: BitArray) -> Result(ImdsCredentials, Error) {
  use text <- result.try(
    bit_array.to_string(body)
    |> result.replace_error(Failed(reason: "non-utf8 credentials body")),
  )
  use raw <- result.try(
    json.parse(text, raw_decoder())
    |> result.map_error(fn(_) {
      Failed(reason: "credentials body is not the expected JSON shape")
    }),
  )
  // AWS sometimes returns Code != "Success" with an explanatory message; treat
  // that as a hard failure rather than silently using empty credentials.
  case raw.code {
    "Success" -> {
      use expires_at <- result.try(
        datetime.parse_iso8601(raw.expiration)
        |> result.replace_error(Failed(
          reason: "could not parse Expiration timestamp '"
          <> raw.expiration
          <> "'",
        )),
      )
      Ok(ImdsCredentials(
        access_key_id: raw.access_key_id,
        secret_access_key: raw.secret_access_key,
        session_token: raw.token,
        expires_at: expires_at,
      ))
    }
    other -> Error(Failed(reason: "IMDS returned Code=" <> other))
  }
}
