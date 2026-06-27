//// ECS container credentials provider.
////
//// One HTTP GET to a URL the container runtime advertises in environment
//// variables — typically `http://169.254.170.2<relative-uri>` inside an
//// ECS/EKS task. Response shape is the same as IMDS step 3 (a JSON
//// document with `AccessKeyId`, `SecretAccessKey`, `Token`, `Expiration`).
////
//// Auth token, when present, goes in the `Authorization` header — but only
//// when the destination is trusted (see `ecs_uri_allows_auth`). The token is
//// a bearer credential; attaching it to an arbitrary host advertised via
//// `AWS_CONTAINER_CREDENTIALS_FULL_URI` would exfiltrate it (issue #28). An
//// empty token value means "no auth header at all" (None) rather than "send
//// the empty string".

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
import gleam/string
import gleam/uri

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
    build_request(
      http.Get,
      options.url,
      auth_headers(options.url, options.auth_token),
    )
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

/// Build the auth headers for a request to `url`. The token is withheld —
/// the `Authorization` header is simply omitted — when `url` is not a trusted
/// destination, so an untrusted `FULL_URI` can never receive the bearer token
/// (issue #28). The request still goes out unauthenticated; the metadata
/// endpoint, if it really requires auth, then fails closed.
fn auth_headers(url: String, token: Option(String)) -> List(#(String, String)) {
  case token {
    Some(t) ->
      case ecs_uri_allows_auth(url) {
        True -> [#("authorization", t)]
        False -> []
      }
    None -> []
  }
}

/// Whether the metadata URL may receive the
/// `AWS_CONTAINER_AUTHORIZATION_TOKEN`. The token is a bearer credential, so
/// sending it to an arbitrary host over plain HTTP would leak it (SSRF /
/// credential exfiltration — issue #28). Mirroring aws-sdk-rust and
/// aws-sdk-go-v2, it is only attached when the destination is trusted:
///
/// - any `https` host (TLS protects the token in transit), or
/// - a loopback host: `127.0.0.0/8`, IPv6 `::1` / `[::1]`, or `localhost`, or
/// - the ECS (`169.254.170.2`) / EKS (`169.254.170.23`) link-local endpoints.
///
/// Any other host over plain HTTP returns `False` so the caller omits the
/// header entirely rather than leak the token. A URL that fails to parse is
/// treated as untrusted.
pub fn ecs_uri_allows_auth(url: String) -> Bool {
  case uri.parse(url) {
    Ok(parsed) ->
      case option.map(parsed.scheme, string.lowercase) {
        Some("https") -> True
        _ ->
          case parsed.host {
            Some(host) -> host_is_trusted(string.lowercase(host))
            None -> False
          }
      }
    Error(_) -> False
  }
}

/// Hosts allowed to receive the auth token over plain HTTP.
fn host_is_trusted(host: String) -> Bool {
  case host {
    "localhost" -> True
    "::1" | "[::1]" -> True
    // ECS / EKS container-credentials link-local endpoints.
    "169.254.170.2" -> True
    "169.254.170.23" -> True
    _ -> is_loopback_ipv4(host)
  }
}

/// True for any address in the `127.0.0.0/8` loopback block.
fn is_loopback_ipv4(host: String) -> Bool {
  case string.split(host, on: ".") {
    [first, b, c, d] ->
      first == "127" && is_octet(b) && is_octet(c) && is_octet(d)
    _ -> False
  }
}

/// True if `s` is a decimal byte (0–255), i.e. a valid dotted-quad octet.
fn is_octet(s: String) -> Bool {
  case int.parse(s) {
    Ok(n) -> n >= 0 && n <= 255
    Error(_) -> False
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
