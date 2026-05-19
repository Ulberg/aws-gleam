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
import aws/internal/http_send.{type HttpError, type Send, type StreamingSend}
import aws/internal/http_streaming
import aws/internal/sigv4.{SigningOptions}
import aws/internal/text_scan
import aws/retry.{type Strategy}
import aws/streaming.{type StreamingBody}
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
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
    /// Streaming HTTP sender used by `@streaming` operations. Buffered
    /// callers (the majority of AWS APIs) keep using `http_send`; the
    /// codegen for streaming operations threads this one instead so
    /// large object GETs (S3) or long-lived subscription streams
    /// (Kinesis, Bedrock) can consume chunks incrementally without
    /// the runtime buffering the full response.
    streaming_http_send: StreamingSend,
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
    streaming_http_send: http_streaming.default_send,
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

/// Override the request endpoint URL. Used for LocalStack, FIPS
/// endpoints, custom DNS, and pre-signed-URL replay flows.
///
/// When a Smithy endpoint rule set is attached (the codegen wires
/// one on every generated service that declares one), the override
/// is threaded into the rule set as the standard `Endpoint`
/// parameter rather than replacing `endpoint_url` outright. AWS
/// rule sets honour this parameter via an early-branch rule like
/// `case isSet(Endpoint) -> endpoint { url: "{Endpoint}" }`, so the
/// override wins consistently across all services that declare an
/// `Endpoint` rule-set parameter.
///
/// The static `endpoint_url` is also updated so services without a
/// rule set continue to honour the override via the fallback path.
pub fn with_endpoint_url(config: ClientConfig, url: String) -> ClientConfig {
  ClientConfig(..config, endpoint_url: url)
  |> with_endpoint_param("Endpoint", endpoints.StringVal(url))
}

pub fn with_http_send(config: ClientConfig, send: Send) -> ClientConfig {
  ClientConfig(..config, http_send: send)
}

/// Override the streaming HTTP sender. Use for tests (stub the
/// transport), for forcing the buffered-then-streamed path via
/// `http_send.lift_to_streaming(custom_buffered)`, or to inject a
/// future custom transport (proxy, gRPC tunnel, etc.).
pub fn with_streaming_http_send(
  config: ClientConfig,
  send: StreamingSend,
) -> ClientConfig {
  ClientConfig(..config, streaming_http_send: send)
}

/// Switch the streaming sender to the HTTP/2 variant. httpc adds
/// `{http_version, "HTTP/2"}` to its option list; servers that don't
/// speak HTTP/2 negotiate down to HTTP/1.1 via ALPN, so calls keep
/// working even when the peer doesn't support it. Buffered requests
/// (`http_send`) are unaffected — HTTP/2 is for high-throughput
/// streaming endpoints (S3 multipart, Bedrock streaming, Transcribe).
///
/// Pair with `with_streaming_http_send` for finer control (e.g. a
/// stubbed sender in tests that needs HTTP/2 wiring elsewhere).
pub fn with_http2(config: ClientConfig) -> ClientConfig {
  ClientConfig(..config, streaming_http_send: http_streaming.default_send_http2)
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
  use http_req <- result.try(prepare_signed_request(config, op_params, built))

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

/// Streaming-response variant of `invoke`. Builds + signs the
/// request exactly like `invoke`, but dispatches through
/// `streaming_http_send` (chunked transport) and returns the raw
/// `Response(StreamingBody)` so callers can consume the body
/// incrementally — fold chunk-by-chunk via `streaming.fold_chunks`,
/// decode event-stream frames via `event_stream.fold_events`, or
/// stream-to-disk without buffering.
///
/// Used by generated codegen for operations whose output carries
/// `@streaming` — `S3.GetObject` for multi-GB downloads,
/// `Transcribe.StartStreamTranscription` and `Kinesis.SubscribeToShard`
/// for event-stream responses, etc.
///
/// Error responses (non-2xx) are materialised via
/// `streaming.to_bit_array_max(body, 1 MiB)` so `error_type`
/// extraction works on the JSON/XML error body the same way as
/// `invoke`. A response body that exceeds the 1 MiB cap on the
/// error path surfaces as `DecodeError` since we can't safely
/// extract a typed error from an oversized error body.
///
/// Retry is intentionally NOT wrapped around `streaming_http_send`
/// at this layer — replaying a streaming request after a transient
/// failure is op-specific (idempotent vs. mutating). Callers that
/// want retry on a streaming op should layer it themselves or
/// drop down to the buffered `invoke`.
pub fn invoke_streaming(
  config: ClientConfig,
  built: #(String, String, Dict(String, String), BitArray),
) -> Result(Response(StreamingBody), ClientError) {
  invoke_streaming_with_endpoint_params(config, dict.new(), built)
}

/// `invoke_streaming` with per-op endpoint-rule-set parameters (the
/// streaming-side counterpart to `invoke_with_endpoint_params`).
pub fn invoke_streaming_with_endpoint_params(
  config: ClientConfig,
  op_params: Params,
  built: #(String, String, Dict(String, String), BitArray),
) -> Result(Response(StreamingBody), ClientError) {
  use http_req <- result.try(prepare_signed_request(config, op_params, built))

  use resp <- result.try(
    config.streaming_http_send(http_req)
    |> result.map_error(TransportError),
  )

  case resp.status >= 200 && resp.status < 300 {
    True -> Ok(resp)
    False -> Error(streaming_error(resp))
  }
}

// Cap error-response bodies at 1 MiB on the streaming path. Real
// AWS error bodies are always small (a few KB XML / JSON); anything
// larger is server misbehaviour and we surface DecodeError rather
// than risk an OOM on a hot retry path.
const streaming_error_body_cap_bytes: Int = 1_048_576

fn streaming_error(resp: Response(StreamingBody)) -> ClientError {
  let resp_headers = headers_to_dict(resp.headers)
  case streaming.to_bit_array_max(resp.body, streaming_error_body_cap_bytes) {
    Ok(body) ->
      ServiceError(
        status: resp.status,
        error_type: extract_error_type(resp_headers, body),
        body: body,
      )
    Error(_) ->
      DecodeError(
        reason: "streaming error body exceeded "
        <> int_to_decimal(streaming_error_body_cap_bytes)
        <> " bytes — refusing to materialise for typed-error extraction",
      )
  }
}

@external(erlang, "erlang", "integer_to_binary")
fn int_to_decimal(n: Int) -> String

// Build, sign, and assemble the gleam_http `Request(BitArray)` for
// the operation. Shared by `invoke` (buffered) and `invoke_streaming`
// (chunked) — the only divergence is which `Send` dispatches it.
fn prepare_signed_request(
  config: ClientConfig,
  op_params: Params,
  built: #(String, String, Dict(String, String), BitArray),
) -> Result(Request(BitArray), ClientError) {
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
  Ok(http_req)
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

/// Pull the wire-error-type local name out of a response. Looks at the
/// `X-Amzn-Errortype` header first (restJson1, awsJson*); falls back to
/// the body for `__type` / `code` / `<Code>` (covers JSON and XML
/// error shapes). The returned string is the *local* shape name —
/// namespace prefix, URI suffix, and Smithy `[Charlie,foo,bar]` suffix
/// are all stripped. Exposed for codegen-emitted error-shape protocol
/// test dispatchers; the in-process retry path uses it via the
/// `ServiceError` discriminator.
pub fn extract_error_type(
  headers: Dict(String, String),
  body: BitArray,
) -> String {
  case dict.get(headers, "x-amzn-errortype") {
    Ok(v) -> normalise_error_type(v)
    Error(_) ->
      case bit_array.to_string(body) {
        Error(_) -> "Unknown"
        Ok(text) -> error_type_from_body(text)
      }
  }
}

/// Discriminator check for protocol-test error-shape dispatchers. Used
/// by the generated `parse_<err>_response` function: if the wire-side
/// discriminator (header or body) resolves to `expected_local`, the
/// response was routed to the right error shape and the dispatcher
/// reports `Ok(Nil)`. The runner's response-side assertion is binary
/// — `Ok` vs `Error` — so returning `Nil` is enough.
///
/// The runner hands fixture headers through with their literal-case
/// keys (`X-Amzn-Errortype`), but `extract_error_type` expects the
/// lowercased form that the real-request path produces via
/// `headers_to_dict`. We lowercase here so the helper matches HTTP's
/// case-insensitive header semantics regardless of which call-site
/// invokes it.
pub fn check_error_type_matches(
  headers: Dict(String, String),
  body: BitArray,
  expected_local: String,
) -> Result(Nil, String) {
  let lower =
    dict.fold(headers, dict.new(), fn(acc, k, v) {
      dict.insert(acc, string.lowercase(k), v)
    })
  let extracted = extract_error_type(lower, body)
  case extracted == expected_local {
    True -> Ok(Nil)
    False ->
      Error(
        "error type mismatch: expected "
        <> expected_local
        <> ", got "
        <> extracted,
      )
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
  let found =
    text_scan.json_string_after_key(body, "__type")
    |> result.lazy_or(fn() { text_scan.json_string_after_key(body, "code") })
    |> result.lazy_or(fn() { extract_xml_error_code(body) })
  case found {
    Ok(v) -> normalise_error_type(v)
    Error(_) -> "Unknown"
  }
}

/// Pull the error code out of a restXml error body. Two shapes appear
/// in the wild — S3-style `<Error><Code>NoSuchBucket</Code>...</Error>`
/// and SQS/SNS-style `<ErrorResponse><Error><Code>X</Code>...</Error>...`.
/// In both cases the first `<Code>` element holds the error type, so a
/// single text search keyed on `<Code>` covers both shapes without
/// dragging in the full XML decoder for an error-only path. The trim
/// + empty-check rejects `<Code/>` and `<Code>   </Code>` so the
/// fallback to "Unknown" still fires for malformed bodies.
fn extract_xml_error_code(body: String) -> Result(String, Nil) {
  use raw <- result.try(text_scan.xml_tag_text(body, "Code"))
  case string.trim(raw) {
    "" -> Error(Nil)
    non_empty -> Ok(non_empty)
  }
}

@external(erlang, "aws_ffi", "aws_timestamp")
fn aws_timestamp() -> String
