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
import aws/endpoints.{type Params, type RuleSet}
import aws/internal/http_request as our_http
import aws/internal/http_send.{type HttpError, type Send}
import aws/internal/sigv4.{SigningOptions}
import aws/retry.{type Strategy}
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/http
import gleam/http/request
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// Configuration carried inside every generated `Client`. See module
/// docs for what's threaded through where.
///
/// `endpoint_rule_set` and `endpoint_params` are the Smithy endpoint
/// resolution inputs. When `endpoint_rule_set` is `Some`, every `invoke`
/// call computes the request URL by walking the rule set against
/// `endpoint_params` merged with `{Region: region}` and any operation-
/// specific parameters threaded through `invoke_with_endpoint_params`.
/// When it's `None`, `endpoint_url` is used verbatim — that's the
/// pre-M3 behaviour the runtime keeps as a fallback.
pub type ClientConfig {
  ClientConfig(
    provider: Provider,
    region: String,
    endpoint_prefix: String,
    signing_name: String,
    endpoint_url: String,
    http_send: Send,
    timestamp: fn() -> String,
    retry_strategy: Strategy,
    endpoint_rule_set: Option(RuleSet),
    endpoint_params: Params,
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
    retry_strategy: retry.standard(),
    endpoint_rule_set: None,
    endpoint_params: dict.new(),
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

/// Override the retry strategy used to wrap `http_send`. Pass
/// `retry.standard()` for the AWS-standard 3-attempt backoff (the
/// default), or `retry.adaptive(bucket)` to add the token-bucket gate.
pub fn with_retry_strategy(
  config: ClientConfig,
  strategy: Strategy,
) -> ClientConfig {
  ClientConfig(..config, retry_strategy: strategy)
}

/// Attach a Smithy endpoint rule set. When set, the runtime walks the rule
/// set per request to compute the endpoint URL — the value passed in via
/// `with_endpoint_url` (or `default_endpoint`) is then ignored except as a
/// fallback when the rule set is cleared. Use this from generated service
/// constructors that embed their service's rule set.
pub fn with_endpoint_rule_set(
  config: ClientConfig,
  rule_set: RuleSet,
) -> ClientConfig {
  ClientConfig(..config, endpoint_rule_set: Some(rule_set))
}

/// Set a single client-level endpoint-rule-set parameter (e.g.
/// `"UseFIPS"` -> `BoolVal(True)`). Operation-specific params (S3
/// `Bucket`, `Key`) are threaded per-call via
/// `invoke_with_endpoint_params`.
pub fn with_endpoint_param(
  config: ClientConfig,
  name: String,
  value: endpoints.Value,
) -> ClientConfig {
  ClientConfig(
    ..config,
    endpoint_params: dict.insert(config.endpoint_params, name, value),
  )
}

/// Run one operation end-to-end. See module docs for the pipeline.
///
/// Operations that need to thread rule-set parameters known only to the
/// op itself (e.g. S3's `Bucket`) should use `invoke_with_endpoint_params`
/// instead and pass those parameters through `op_params`.
pub fn invoke(
  config: ClientConfig,
  built: #(String, String, Dict(String, String), BitArray),
  parse: fn(Int, Dict(String, String), BitArray) -> Result(output, String),
) -> Result(output, ClientError) {
  invoke_with_endpoint_params(config, dict.new(), built, parse)
}

/// Same as `invoke` but with extra rule-set parameters merged in for this
/// operation only — used by generated S3 ops to supply `Bucket`/`Key` etc.
/// without leaking them onto the client config. If the client has no
/// `endpoint_rule_set`, `op_params` is ignored (the static `endpoint_url`
/// is used).
pub fn invoke_with_endpoint_params(
  config: ClientConfig,
  op_params: Params,
  built: #(String, String, Dict(String, String), BitArray),
  parse: fn(Int, Dict(String, String), BitArray) -> Result(output, String),
) -> Result(output, ClientError) {
  let #(method, uri, headers, body) = built

  use creds <- result.try(
    credentials.fetch(config.provider)
    |> result.map_error(CredentialsError),
  )

  use endpoint_url <- result.try(resolve_endpoint_url(config, op_params))

  let host = host_from_endpoint(endpoint_url)
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
  let signing_creds =
    sigv4.SigningCredentials(
      access_key_id: creds.access_key_id,
      secret_access_key: creds.secret_access_key,
      session_token: creds.session_token,
    )
  let signed = sigv4.sign(unsigned, signing_creds, opts)

  let full_url = endpoint_url <> uri
  let assert Ok(base) = request.to(full_url)
  let http_req =
    base
    |> request.set_method(parse_method(method))
    |> request.set_body(body)
  let http_req =
    list.fold(signed.headers, http_req, fn(r, h) {
      request.set_header(r, h.name, h.value)
    })

  let send =
    retry.with_retry(send: config.http_send, strategy: config.retry_strategy)
  use resp <- result.try(
    send(http_req)
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

/// Compute the request URL using the rule set if attached, otherwise fall
/// back to the static `endpoint_url`. Returns a runtime error if the rule
/// set can't be resolved — bubbles up as `DecodeError` for now so existing
/// callers don't need a new variant.
fn resolve_endpoint_url(
  config: ClientConfig,
  op_params: Params,
) -> Result(String, ClientError) {
  case config.endpoint_rule_set {
    None -> Ok(config.endpoint_url)
    Some(rs) -> {
      let params =
        dict.insert(
          merge_params(config.endpoint_params, op_params),
          "Region",
          endpoints.StringVal(config.region),
        )
      case endpoints.resolve(rs, params) {
        Ok(endpoint) -> Ok(endpoint.url)
        Error(err) -> Error(DecodeError(reason: describe_endpoint_error(err)))
      }
    }
  }
}

fn merge_params(base: Params, overlay: Params) -> Params {
  dict.fold(overlay, base, fn(acc, k, v) { dict.insert(acc, k, v) })
}

fn describe_endpoint_error(err: endpoints.ResolveError) -> String {
  case err {
    endpoints.RuleError(message: m) -> "endpoint rule error: " <> m
    endpoints.NoMatch -> "endpoint rule set: no match"
    endpoints.InvalidRuleSet(reason: r) -> "invalid endpoint rule set: " <> r
    endpoints.Unsupported(reason: r) -> "endpoint unsupported: " <> r
    endpoints.MissingParameter(name: n) -> "endpoint parameter missing: " <> n
    endpoints.RequiredParameterMissing(name: n) ->
      "endpoint required parameter missing: " <> n
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

/// Generic translator from the runtime's `ClientError` to a per-op
/// typed-error enum. Each generated `translate_<op>_error` is a
/// one-liner that supplies its operation's decoder table plus
/// constructors for the always-present `*Transport` and `*Unknown`
/// variants. Saves ~15–25 LOC/op vs the previous open-coded nested
/// match — see Pass 3c in plan.md.
///
/// `decoders` is a list of `(wire_error_type_local_name, decoder)`
/// pairs. The first pair whose error_type matches gets to attempt the
/// decode; if its decoder returns `Error(Nil)`, we fall back to
/// `on_unknown` with the textified body so the caller still sees
/// something useful instead of a panic.
pub fn translate_service_error(
  err: ClientError,
  decoders: List(#(String, fn(String) -> Result(t, Nil))),
  on_transport: fn(String) -> t,
  on_unknown: fn(String, Int, String) -> t,
) -> t {
  case err {
    ServiceError(status: s, error_type: et, body: b) -> {
      let text = case bit_array.to_string(b) {
        Ok(t) -> t
        Error(_) -> ""
      }
      case list.find(decoders, fn(d) { error_type_matches(et, d.0) }) {
        Ok(#(_, decoder)) ->
          case decoder(text) {
            Ok(v) -> v
            Error(_) -> on_unknown(et, s, text)
          }
        Error(_) -> on_unknown(et, s, text)
      }
    }
    TransportError(_) -> on_transport("transport error")
    CredentialsError(_) -> on_transport("credentials error")
    DecodeError(reason: r) -> on_transport("decode: " <> r)
  }
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
        Error(_) ->
          case extract_xml_error_code(body) {
            Ok(v) -> normalise_error_type(v)
            Error(_) -> "Unknown"
          }
      }
  }
}

/// Pull the error code out of a restXml error body. Two shapes appear
/// in the wild — S3-style `<Error><Code>NoSuchBucket</Code>...</Error>`
/// and SQS/SNS-style `<ErrorResponse><Error><Code>X</Code>...</Error>...`.
/// In both cases the first `<Code>` element holds the error type, so a
/// single text search keyed on `<Code>` covers both shapes without
/// dragging in the full XML decoder for an error-only path.
fn extract_xml_error_code(body: String) -> Result(String, Nil) {
  case string.split_once(body, "<Code>") {
    Error(_) -> Error(Nil)
    Ok(#(_, rest)) ->
      case string.split_once(rest, "</Code>") {
        Error(_) -> Error(Nil)
        Ok(#(code, _)) ->
          case string.trim(code) {
            "" -> Error(Nil)
            non_empty -> Ok(non_empty)
          }
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
