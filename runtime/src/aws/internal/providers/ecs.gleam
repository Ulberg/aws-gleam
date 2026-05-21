//// ECS container credentials provider.
////
//// One HTTP GET to a URL the container runtime advertises in environment
//// variables — typically `http://169.254.170.2<relative-uri>` inside an
//// ECS/EKS task. Response shape is the same as IMDS step 3 (a JSON
//// document with `AccessKeyId`, `SecretAccessKey`, `Token`, `Expiration`).
////
//// Auth token, when present, goes in the `Authorization` header verbatim.
//// AWS Fargate gates the metadata endpoint with this token, so an empty
//// value means "no auth header at all" (None) rather than "send the empty
//// string".

import aws/internal/datetime
import aws/internal/http_send.{type Send}
import gleam/bit_array
import gleam/dynamic/decode
import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result

pub type Options {
  Options(url: String, auth_token: Option(String))
}

pub type EcsCredentials {
  EcsCredentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
    expires_at: Option(Int),
  )
}

pub type Error {
  /// The metadata URL isn't reachable. The chain falls through.
  Unreachable(reason: String)
  /// URL responded but the body was malformed or signalled failure.
  Failed(reason: String)
}

pub fn fetch(send: Send, options: Options) -> Result(EcsCredentials, Error) {
  use req <- result.try(
    build_request(http.Get, options.url, auth_headers(options.auth_token))
    |> result.map_error(fn(reason) { Failed(reason: reason) }),
  )
  use resp <- result.try(
    send(req)
    |> result.map_error(fn(e) {
      Unreachable(reason: "ECS metadata transport: " <> describe_http(e))
    }),
  )
  case resp.status {
    200 -> decode_credentials(resp.body)
    other ->
      Error(Failed(
        reason: "ECS metadata returned status " <> int.to_string(other),
      ))
  }
}

fn auth_headers(token: Option(String)) -> List(#(String, String)) {
  case token {
    Some(t) -> [#("authorization", t)]
    None -> []
  }
}

fn build_request(
  method: http.Method,
  url: String,
  headers: List(#(String, String)),
) -> Result(Request(BitArray), String) {
  use base <- result.try(
    request.to(url)
    |> result.replace_error("invalid URL: " <> url),
  )
  let req =
    base
    |> request.set_method(method)
    |> request.set_body(bit_array.from_string(""))
  Ok(apply_headers(req, headers))
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

// ---- response decoding ----

type RawCredentials {
  RawCredentials(
    access_key_id: String,
    secret_access_key: String,
    token: Option(String),
    expiration: Option(String),
  )
}

fn raw_decoder() -> decode.Decoder(RawCredentials) {
  use access_key_id <- decode.field("AccessKeyId", decode.string)
  use secret_access_key <- decode.field("SecretAccessKey", decode.string)
  use token <- decode.then(decode.optionally_at(
    ["Token"],
    None,
    decode.map(decode.string, Some),
  ))
  use expiration <- decode.then(decode.optionally_at(
    ["Expiration"],
    None,
    decode.map(decode.string, Some),
  ))
  decode.success(RawCredentials(
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    token: token,
    expiration: expiration,
  ))
}

fn decode_credentials(body: BitArray) -> Result(EcsCredentials, Error) {
  use text <- result.try(
    bit_array.to_string(body)
    |> result.replace_error(Failed(reason: "non-utf8 credentials body")),
  )
  use raw <- result.try(
    json.parse(text, raw_decoder())
    |> result.map_error(fn(_) {
      Failed(reason: "ECS response is not the expected JSON shape")
    }),
  )
  // Expiration is technically optional in the wire format, but in practice
  // ECS always returns it. We tolerate it being absent (treat creds as
  // non-expiring) so we don't blow up on a one-off edge case.
  let expires_at = case raw.expiration {
    Some(ts) ->
      case datetime.parse_iso8601(ts) {
        Ok(t) -> Some(t)
        Error(_) -> None
      }
    None -> None
  }
  Ok(EcsCredentials(
    access_key_id: raw.access_key_id,
    secret_access_key: raw.secret_access_key,
    session_token: raw.token,
    expires_at: expires_at,
  ))
}
