//// STS AssumeRole provider.
////
//// The plain `AssumeRole` flow — distinct from
//// `AssumeRoleWithWebIdentity` in `sts_web_identity.gleam` — needs the
//// caller to *already hold* credentials that have permission to assume
//// the target role. The caller's credentials sign the STS request via
//// SigV4; STS hands back temporary credentials for the assumed role.
////
//// This is what the shared-config `role_arn` / `source_profile` chain
//// uses under the hood: resolve credentials for the source profile,
//// then call `AssumeRole` from those into the role declared on the
//// outer profile.
////
//// Wire format is the same form-encoded `Action=AssumeRole&Version=
//// 2011-06-15&...` shape used by every Query-protocol STS API. We hand-
//// roll it here rather than going through the typed STS client because
//// the credential-chain bootstrap path has to be free of any
//// dependency on a signed Client (chicken-and-egg).

import aws/internal/datetime
import aws/internal/http_request as our_http
import aws/internal/http_send.{type Send}
import aws/internal/sigv4.{type SigningCredentials, SigningOptions}
import aws/internal/text_scan
import aws/internal/uri
import gleam/bit_array
import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// AssumeRole inputs.
///
/// - `endpoint` is the STS endpoint URL — defaults to the global
///   `https://sts.amazonaws.com/`; pass a regional URL when assuming
///   into a partition / region that requires it.
/// - `role_arn` is the role to assume.
/// - `role_session_name` shows up in CloudTrail.
/// - `duration_seconds` caps the assumed-role session lifetime
///   (STS clamps to the role's `MaxSessionDuration`).
/// - `external_id` is the optional third-party trust-policy token; set
///   it when the role's trust policy requires `sts:ExternalId`.
pub type Options {
  Options(
    endpoint: String,
    region: String,
    role_arn: String,
    role_session_name: String,
    duration_seconds: Int,
    external_id: Option(String),
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

/// Default STS endpoint for the AssumeRole call. Regional endpoints are
/// available; this matches the global default the AWS CLI uses.
pub const default_endpoint: String = "https://sts.amazonaws.com/"

/// Default `DurationSeconds` STS clamps to whatever the role's
/// `MaxSessionDuration` allows. One hour is the conservative default
/// every other AWS SDK uses.
pub const default_duration_seconds: Int = 3600

/// Build options for a default AssumeRole call: global endpoint,
/// one-hour duration, no external id. Add overrides through
/// `Options(..opts, ...)`.
pub fn default_options(
  role_arn role_arn: String,
  role_session_name role_session_name: String,
) -> Options {
  Options(
    endpoint: default_endpoint,
    region: "us-east-1",
    role_arn: role_arn,
    role_session_name: role_session_name,
    duration_seconds: default_duration_seconds,
    external_id: None,
  )
}

pub fn fetch(
  send send: Send,
  source source: SigningCredentials,
  options options: Options,
  timestamp timestamp: fn() -> String,
) -> Result(StsCredentials, Error) {
  let body_string =
    build_form_body(
      options.role_arn,
      options.role_session_name,
      options.duration_seconds,
      options.external_id,
    )
  let body = bit_array.from_string(body_string)
  use req <- result.try(
    build_signed_request(send, source, options, body, timestamp)
    |> result.map_error(Failed),
  )
  use resp <- result.try(
    send(req)
    |> result.map_error(fn(e) {
      Failed(reason: "STS transport: " <> describe_http(e))
    }),
  )
  case resp.status {
    code if code >= 200 && code < 300 -> decode_xml(resp.body)
    code ->
      Error(Failed(
        reason: "STS AssumeRole returned status " <> int.to_string(code),
      ))
  }
}

fn build_form_body(
  role_arn: String,
  role_session_name: String,
  duration_seconds: Int,
  external_id: Option(String),
) -> String {
  let base = [
    #("Action", "AssumeRole"),
    #("Version", "2011-06-15"),
    #("RoleArn", role_arn),
    #("RoleSessionName", role_session_name),
    #("DurationSeconds", int.to_string(duration_seconds)),
  ]
  let pairs = case external_id {
    Some(eid) -> list.append(base, [#("ExternalId", eid)])
    None -> base
  }
  pairs
  |> list.map(fn(p) {
    uri.encode_component(p.0) <> "=" <> uri.encode_component(p.1)
  })
  |> string.join("&")
}

fn build_signed_request(
  _send: Send,
  source: SigningCredentials,
  options: Options,
  body: BitArray,
  timestamp: fn() -> String,
) -> Result(Request(BitArray), String) {
  use base <- result.try(
    request.to(options.endpoint)
    |> result.replace_error("invalid STS endpoint: " <> options.endpoint),
  )
  let host = host_from_endpoint(options.endpoint)
  let unsigned =
    our_http.HttpRequest(
      method: "POST",
      path: "/",
      query: "",
      headers: [
        our_http.Header(name: "host", value: host),
        our_http.Header(
          name: "content-type",
          value: "application/x-www-form-urlencoded",
        ),
      ],
      body: body,
    )
  let signed =
    sigv4.sign(
      unsigned,
      source,
      SigningOptions(
        timestamp: timestamp(),
        region: options.region,
        service: "sts",
        normalize_path: True,
        sign_body: True,
        omit_session_token: False,
      ),
    )
  let req =
    base
    |> request.set_method(http.Post)
    |> request.set_body(body)
  let req_with_headers =
    list.fold(signed.headers, req, fn(r, h) {
      request.set_header(r, h.name, h.value)
    })
  Ok(req_with_headers)
}

fn host_from_endpoint(url: String) -> String {
  let after = case string.split_once(url, "://") {
    Ok(#(_, rest)) -> rest
    Error(_) -> url
  }
  case string.split_once(after, "/") {
    Ok(#(host, _)) -> host
    Error(_) -> after
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

// ---- XML response decoding ----
//
// Same shape as `sts_web_identity`, but inside `<AssumeRoleResponse>`
// instead of `<AssumeRoleWithWebIdentityResponse>`. The string scan
// only needs the inner `<Credentials>` block's children, which both
// envelopes carry identically.

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
