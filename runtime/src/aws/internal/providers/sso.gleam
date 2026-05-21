//// AWS SSO (IAM Identity Center) provider — the GetRoleCredentials portal
//// call given an already-cached SSO access token. We don't implement the
//// device-grant flow that produces the cached token in the first place; the
//// AWS CLI's `aws sso login` does that and writes the token to
//// `~/.aws/sso/cache/<hash>.json`. We just consume it.
////
//// Endpoint shape:
////   GET https://portal.sso.<region>.amazonaws.com/federation/credentials
////       ?account_id=<id>&role_name=<name>
////   Header: x-amz-sso_bearer_token: <access_token>
////
//// Response:
////   { "roleCredentials": { accessKeyId, secretAccessKey, sessionToken,
////                          expiration (millis since epoch) } }

import aws/internal/http_send.{type Send}
import aws/internal/uri
import gleam/bit_array
import gleam/dynamic/decode
import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/json
import gleam/result

pub type Options {
  Options(
    region: String,
    account_id: String,
    role_name: String,
    access_token: String,
    /// Endpoint override for tests. Production callers pass the canonical
    /// `https://portal.sso.<region>.amazonaws.com` URL.
    endpoint: String,
  )
}

pub fn default_endpoint(region: String) -> String {
  "https://portal.sso." <> region <> ".amazonaws.com"
}

pub type SsoCredentials {
  SsoCredentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: String,
    /// Unix seconds. The wire value is milliseconds; the caller converts.
    expires_at: Int,
  )
}

pub type Error {
  /// Portal answered but the body didn't carry credentials. Loud.
  Failed(reason: String)
  /// Transport failed; treat as not-on-this-machine.
  Unreachable(reason: String)
}

pub fn fetch(send: Send, options: Options) -> Result(SsoCredentials, Error) {
  let url =
    options.endpoint
    <> "/federation/credentials?account_id="
    <> uri.encode_component(options.account_id)
    <> "&role_name="
    <> uri.encode_component(options.role_name)
  use req <- result.try(
    build_request(url, options.access_token)
    |> result.map_error(fn(reason) { Failed(reason: reason) }),
  )
  use resp <- result.try(
    send(req)
    |> result.map_error(fn(e) {
      Unreachable(reason: "SSO portal transport: " <> describe_http(e))
    }),
  )
  case resp.status {
    code if code >= 200 && code < 300 -> decode_credentials(resp.body)
    code ->
      Error(Failed(reason: "SSO portal returned status " <> int.to_string(code)))
  }
}

fn build_request(
  url: String,
  access_token: String,
) -> Result(Request(BitArray), String) {
  use base <- result.try(
    request.to(url)
    |> result.replace_error("invalid SSO URL: " <> url),
  )
  Ok(
    base
    |> request.set_method(http.Get)
    |> request.set_body(bit_array.from_string(""))
    |> request.set_header("x-amz-sso_bearer_token", access_token),
  )
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

type RawRoleCreds {
  RawRoleCreds(
    access_key_id: String,
    secret_access_key: String,
    session_token: String,
    expiration_ms: Int,
  )
}

fn raw_decoder() -> decode.Decoder(RawRoleCreds) {
  use access_key_id <- decode.subfield(
    ["roleCredentials", "accessKeyId"],
    decode.string,
  )
  use secret_access_key <- decode.subfield(
    ["roleCredentials", "secretAccessKey"],
    decode.string,
  )
  use session_token <- decode.subfield(
    ["roleCredentials", "sessionToken"],
    decode.string,
  )
  use expiration_ms <- decode.subfield(
    ["roleCredentials", "expiration"],
    decode.int,
  )
  decode.success(RawRoleCreds(
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token,
    expiration_ms: expiration_ms,
  ))
}

fn decode_credentials(body: BitArray) -> Result(SsoCredentials, Error) {
  use text <- result.try(
    bit_array.to_string(body)
    |> result.replace_error(Failed(reason: "non-utf8 SSO response body")),
  )
  use raw <- result.try(
    json.parse(text, raw_decoder())
    |> result.map_error(fn(_) {
      Failed(reason: "SSO response is not the expected JSON shape")
    }),
  )
  // SSO ships expiration as milliseconds-since-epoch; convert.
  Ok(SsoCredentials(
    access_key_id: raw.access_key_id,
    secret_access_key: raw.secret_access_key,
    session_token: raw.session_token,
    expires_at: raw.expiration_ms / 1000,
  ))
}
