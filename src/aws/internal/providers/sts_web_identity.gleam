//// STS AssumeRoleWithWebIdentity provider — the IRSA (IAM Roles for
//// Service Accounts) flow used inside EKS pods and any other environment
//// that hands you a signed identity token plus an IAM role to assume.
////
//// Flow:
////   1. Read the web identity token from `AWS_WEB_IDENTITY_TOKEN_FILE`
////      at fetch time (IRSA rotates the token periodically; we must not
////      pin it at provider construction).
////   2. POST form-encoded `Action=AssumeRoleWithWebIdentity` to STS with
////      `RoleArn`, `RoleSessionName`, `WebIdentityToken`, and a duration.
////   3. Pull the credentials out of the XML response.
////
//// XML is parsed with simple `<Tag>value</Tag>` string scans — the STS
//// response shape is fixed and well-known, so a real XML parser would be
//// over-investment.

import aws/internal/datetime
import aws/internal/http_send.{type Send}
import aws/internal/text_scan
import aws/internal/uri
import gleam/bit_array
import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/result
import gleam/string

pub type Options {
  Options(
    endpoint: String,
    role_arn: String,
    role_session_name: String,
    token: String,
    duration_seconds: Int,
  )
}

pub type StsCredentials {
  StsCredentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: String,
    expires_at: Int,
  )
}

pub type Error {
  /// Required configuration absent. Chain falls through.
  Misconfigured(reason: String)
  /// STS responded with non-2xx or a malformed body.
  Failed(reason: String)
}

pub fn fetch(send: Send, options: Options) -> Result(StsCredentials, Error) {
  let body =
    [
      #("Action", "AssumeRoleWithWebIdentity"),
      #("Version", "2011-06-15"),
      #("RoleArn", options.role_arn),
      #("RoleSessionName", options.role_session_name),
      #("WebIdentityToken", options.token),
      #("DurationSeconds", int.to_string(options.duration_seconds)),
    ]
    |> form_encode
  use req <- result.try(
    build_request(options.endpoint, bit_array.from_string(body))
    |> result.map_error(fn(reason) { Failed(reason: reason) }),
  )
  use resp <- result.try(
    send(req)
    |> result.map_error(fn(e) {
      Failed(reason: "STS transport: " <> describe_http(e))
    }),
  )
  case resp.status {
    code if code >= 200 && code < 300 -> decode_xml(resp.body)
    code -> Error(Failed(reason: "STS returned status " <> int.to_string(code)))
  }
}

fn form_encode(pairs: List(#(String, String))) -> String {
  pairs
  |> do_encode_pairs([])
  |> string.join("&")
}

fn do_encode_pairs(
  pairs: List(#(String, String)),
  acc: List(String),
) -> List(String) {
  case pairs {
    [] -> list_reverse(acc)
    [#(k, v), ..rest] ->
      do_encode_pairs(rest, [
        uri.encode_component(k) <> "=" <> uri.encode_component(v),
        ..acc
      ])
  }
}

// Local list reverse so this module doesn't have to pull in gleam/list just
// for one use site.
fn list_reverse(xs: List(a)) -> List(a) {
  do_reverse(xs, [])
}

fn do_reverse(xs: List(a), acc: List(a)) -> List(a) {
  case xs {
    [] -> acc
    [h, ..t] -> do_reverse(t, [h, ..acc])
  }
}

fn build_request(
  endpoint: String,
  body: BitArray,
) -> Result(Request(BitArray), String) {
  use base <- result.try(
    request.to(endpoint)
    |> result.replace_error("invalid STS endpoint: " <> endpoint),
  )
  Ok(
    base
    |> request.set_method(http.Post)
    |> request.set_body(body)
    |> request.set_header("content-type", "application/x-www-form-urlencoded"),
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

// ---- XML response decoding ----

fn decode_xml(body: BitArray) -> Result(StsCredentials, Error) {
  use text <- result.try(
    bit_array.to_string(body)
    |> result.replace_error(Failed(reason: "non-utf8 STS response body")),
  )
  use access_key_id <- result.try(extract_required(text, "AccessKeyId"))
  use secret_access_key <- result.try(extract_required(text, "SecretAccessKey"))
  use session_token <- result.try(extract_required(text, "SessionToken"))
  use expiration <- result.try(extract_required(text, "Expiration"))
  use expires_at <- result.try(
    datetime.parse_iso8601(expiration)
    |> result.replace_error(Failed(
      reason: "could not parse STS Expiration '" <> expiration <> "'",
    )),
  )
  Ok(StsCredentials(
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token,
    expires_at: expires_at,
  ))
}

fn extract_required(xml: String, tag: String) -> Result(String, Error) {
  text_scan.xml_tag_text(xml, tag)
  |> result.replace_error(Failed(
    reason: "STS response missing <" <> tag <> "> element",
  ))
}

