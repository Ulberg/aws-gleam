//// Shared runtime for awsJson1_0 + awsJson1_1 generated clients.
////
//// Generated per-service modules carry the per-operation `build_*` /
//// `parse_*` codec pair plus the service-level metadata (endpoint
//// prefix, signing name, region). They call into `invoke` here for
//// everything else: credential resolution, endpoint URL construction,
//// SigV4 signing, HTTP dispatch, response parsing.
////
//// This keeps the generated code small: one `invoke` call per
//// operation rather than ~30 lines of glue per op duplicated 57×
//// across DynamoDB.

import aws/credentials.{type Provider}
import aws/internal/http_request as our_http
import aws/internal/http_send.{type HttpError, type Send}
import aws/internal/sigv4.{SigningOptions}
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/http
import gleam/http/request
import gleam/list
import gleam/result
import gleam/string

/// Configuration carried inside every generated `Client`. See module
/// docs for what's threaded through where.
pub type ClientConfig {
  ClientConfig(
    provider: Provider,
    region: String,
    endpoint_prefix: String,
    signing_name: String,
    endpoint_url: String,
    http_send: Send,
    timestamp: fn() -> String,
  )
}

/// Errors surfaced from a generated `<op>(client, input)` call.
pub type ClientError {
  CredentialsError(credentials.ProviderError)
  TransportError(HttpError)
  DecodeError(reason: String)
  ServiceError(status: Int, error_type: String, body: BitArray)
}

/// Sensible default config given a region. Credentials default to
/// the standard chain (env → web-identity → SSO → profile → process →
/// ECS → IMDS); callers swap in a custom provider via
/// `with_credentials_provider`, matching the convention every other
/// AWS SDK follows.
pub fn default_config(
  region: String,
  endpoint_prefix: String,
  signing_name: String,
) -> ClientConfig {
  ClientConfig(
    provider: credentials.default_chain(
      send: http_send.default_send,
      profile: "default",
    ),
    region: region,
    endpoint_prefix: endpoint_prefix,
    signing_name: signing_name,
    endpoint_url: default_endpoint(endpoint_prefix, region),
    http_send: http_send.default_send,
    timestamp: aws_timestamp,
  )
}

pub fn default_endpoint(endpoint_prefix: String, region: String) -> String {
  "https://" <> endpoint_prefix <> "." <> region <> ".amazonaws.com"
}

/// Override the credentials provider — use for non-default profiles,
/// in-process static creds, or any custom resolution chain.
pub fn with_credentials_provider(
  config: ClientConfig,
  provider: Provider,
) -> ClientConfig {
  ClientConfig(..config, provider: provider)
}

pub fn with_endpoint_url(config: ClientConfig, url: String) -> ClientConfig {
  ClientConfig(..config, endpoint_url: url)
}

pub fn with_http_send(config: ClientConfig, send: Send) -> ClientConfig {
  ClientConfig(..config, http_send: send)
}

/// Run one operation end-to-end. See module docs for the pipeline.
pub fn invoke(
  config: ClientConfig,
  built: #(String, String, Dict(String, String), BitArray),
  parse: fn(Int, Dict(String, String), BitArray) -> Result(output, String),
) -> Result(output, ClientError) {
  let #(method, uri, headers, body) = built

  use creds <- result.try(
    credentials.fetch(config.provider)
    |> result.map_error(CredentialsError),
  )

  let host = host_from_endpoint(config.endpoint_url)
  let header_pairs =
    [#("host", host), ..dict.to_list(headers)]
    |> list.map(fn(p) { our_http.Header(name: p.0, value: p.1) })

  // Split the path and query so SigV4 canonicalises them separately:
  // `/foo?x-id=Bar` must hash with CanonicalURI=`/foo` and
  // CanonicalQueryString=`x-id=Bar`, never with `?x-id=Bar` baked
  // into the URI. Builds that produce no query (`/foo`) come through
  // unchanged with `path_only`=path, `query_str`="".
  let #(path_only, query_str) = case string.split_once(uri, "?") {
    Ok(#(p, q)) -> #(p, q)
    Error(_) -> #(uri, "")
  }
  let unsigned =
    our_http.HttpRequest(
      method: method,
      path: path_only,
      query: query_str,
      headers: header_pairs,
      body: body,
    )
  let opts =
    SigningOptions(
      timestamp: config.timestamp(),
      region: config.region,
      service: config.signing_name,
      normalize_path: True,
      sign_body: True,
      omit_session_token: False,
    )
  let signed = sigv4.sign(unsigned, creds, opts)

  let full_url = config.endpoint_url <> uri
  let assert Ok(base) = request.to(full_url)
  let http_req =
    base
    |> request.set_method(parse_method(method))
    |> request.set_body(body)
  let http_req =
    list.fold(signed.headers, http_req, fn(r, h) {
      request.set_header(r, h.name, h.value)
    })

  use resp <- result.try(
    config.http_send(http_req)
    |> result.map_error(TransportError),
  )

  let resp_headers = headers_to_dict(resp.headers)
  case resp.status >= 200 && resp.status < 300 {
    True ->
      parse(resp.status, resp_headers, resp.body)
      |> result.map_error(fn(reason) { DecodeError(reason: reason) })
    False -> {
      let error_type = extract_error_type(resp_headers, resp.body)
      Error(ServiceError(
        status: resp.status,
        error_type: error_type,
        body: resp.body,
      ))
    }
  }
}

fn host_from_endpoint(url: String) -> String {
  // Strip the `https://` or `http://` scheme prefix to get the
  // host:port part. The Host header used in SigV4 canonicalisation must
  // not include the scheme.
  let after = case string.split_once(url, "://") {
    Ok(#(_, rest)) -> rest
    Error(_) -> url
  }
  case string.split_once(after, "/") {
    Ok(#(host, _)) -> host
    Error(_) -> after
  }
}

fn parse_method(method: String) -> http.Method {
  case string.uppercase(method) {
    "GET" -> http.Get
    "POST" -> http.Post
    "PUT" -> http.Put
    "DELETE" -> http.Delete
    "HEAD" -> http.Head
    "PATCH" -> http.Patch
    "OPTIONS" -> http.Options
    "TRACE" -> http.Trace
    "CONNECT" -> http.Connect
    _ -> http.Post
  }
}

fn headers_to_dict(headers: List(#(String, String))) -> Dict(String, String) {
  list.fold(headers, dict.new(), fn(acc, p) {
    dict.insert(acc, string.lowercase(p.0), p.1)
  })
}

/// Match an AWS `error_type` wire value against a local Smithy
/// shape name. Used by the generated per-op `translate_<op>_error`
/// dispatchers. `error_type` already passes through
/// `normalise_error_type` (namespace + suffix stripped) at the
/// invoke layer, so a plain equality check suffices; we keep this
/// behind a helper to give the codegen one stable call-site.
pub fn error_type_matches(error_type: String, local: String) -> Bool {
  error_type == local
}

fn extract_error_type(headers: Dict(String, String), body: BitArray) -> String {
  case dict.get(headers, "x-amzn-errortype") {
    Ok(v) -> normalise_error_type(v)
    Error(_) ->
      case bit_array.to_string(body) {
        Error(_) -> "Unknown"
        Ok(text) -> error_type_from_body(text)
      }
  }
}

fn normalise_error_type(raw: String) -> String {
  let s = case string.split_once(raw, ":") {
    Ok(#(prefix, _)) -> prefix
    Error(_) -> raw
  }
  let s = case string.split_once(s, ",") {
    Ok(#(prefix, _)) -> prefix
    Error(_) -> s
  }
  case string.split_once(s, "#") {
    Ok(#(_, local)) -> local
    Error(_) -> s
  }
}

fn error_type_from_body(body: String) -> String {
  case extract_quoted_field(body, "__type") {
    Ok(v) -> normalise_error_type(v)
    Error(_) ->
      case extract_quoted_field(body, "code") {
        Ok(v) -> normalise_error_type(v)
        Error(_) -> "Unknown"
      }
  }
}

fn extract_quoted_field(body: String, key: String) -> Result(String, Nil) {
  let needle = "\"" <> key <> "\""
  case string.split_once(body, needle) {
    Error(_) -> Error(Nil)
    Ok(#(_, rest)) ->
      case string.split_once(rest, "\"") {
        Error(_) -> Error(Nil)
        Ok(#(_, after_first_quote)) ->
          case string.split_once(after_first_quote, "\"") {
            Error(_) -> Error(Nil)
            Ok(#(value, _)) -> Ok(value)
          }
      }
  }
}

@external(erlang, "aws_ffi", "aws_timestamp")
fn aws_timestamp() -> String
