//// Streaming HTTP send for the SDK runtime. Sits between the
//// generated service code and the Erlang FFI in `aws_streaming_ffi`:
//// translates a Gleam `Request(BitArray)` into the parameters
//// `httpc:request/4` expects, dispatches via the streaming FFI,
//// then wraps the response back into a `Response(StreamingBody)`
//// so call sites read identically to the buffered transport.
////
//// This is the foundational piece for `S3.GetObject` on multi-GB
//// objects, event-stream operations (Transcribe, Kinesis), and any
//// future S3 transfer manager — none of those can pre-buffer the
//// full response into memory.

import aws/internal/http_send.{
  type HttpError, type StreamingSend, ConnectFailed, InvalidBody, Other, Timeout,
  default_timeout_seconds,
}
import aws/streaming.{type StreamingBody}
import gleam/bit_array
import gleam/erlang/atom.{type Atom}
import gleam/http.{type Method}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/uri

/// Default streaming sender. Same TLS / timeout defaults as
/// `http_send.default_send`; the response body is a `StreamingBody`
/// carrying chunks as they arrived on the wire. Pass this as
/// `ClientConfig.streaming_http_send` for the SDK runtime, or call
/// it directly when wiring custom callers.
pub fn default_send(
  req: Request(BitArray),
) -> Result(Response(StreamingBody), HttpError) {
  send_with(
    req,
    timeout_ms: default_timeout_seconds * 1000,
    verify_tls: True,
    http2: False,
  )
}

/// HTTP/2 variant of `default_send`. Adds `{http_version, "HTTP/2"}`
/// to the httpc option list; servers that don't speak HTTP/2 negotiate
/// down to HTTP/1.1 via ALPN. Use this for endpoints known to benefit:
/// S3 multipart uploads, Bedrock streaming responses, Transcribe.
/// Caller-facing knob lives at `runtime.with_http2`.
pub fn default_send_http2(
  req: Request(BitArray),
) -> Result(Response(StreamingBody), HttpError) {
  send_with(
    req,
    timeout_ms: default_timeout_seconds * 1000,
    verify_tls: True,
    http2: True,
  )
}

/// Send a `StreamingSend` configurable on timeout and TLS verification.
/// Use this for live-tested object-streaming GETs that need either
/// fast-fail (IMDS-style 2s timeouts) or extra patience (multi-GB
/// downloads).
pub fn with_timeout_and_tls(
  timeout_ms timeout_ms: Int,
  verify_tls verify_tls: Bool,
) -> StreamingSend {
  fn(req) { send_with(req, timeout_ms, verify_tls, False) }
}

/// HTTP/2 + custom timeout / TLS builder. Same as `with_timeout_and_tls`
/// but adds the HTTP/2 option to the httpc call.
pub fn with_timeout_tls_http2(
  timeout_ms timeout_ms: Int,
  verify_tls verify_tls: Bool,
) -> StreamingSend {
  fn(req) { send_with(req, timeout_ms, verify_tls, True) }
}

fn send_with(
  req: Request(BitArray),
  timeout_ms timeout_ms: Int,
  verify_tls verify_tls: Bool,
  http2 http2: Bool,
) -> Result(Response(StreamingBody), HttpError) {
  let url = req |> request.to_uri |> uri.to_string
  case
    streaming_send(
      req.method,
      url,
      req.headers,
      req.body,
      timeout_ms,
      verify_tls,
      http2,
    )
  {
    Ok(#(status, headers, chunks)) ->
      Ok(response.Response(
        status: status,
        headers: list_decode_headers(headers),
        body: streaming.from_chunks(chunks),
      ))
    Error(reason) -> Error(translate_error(reason))
  }
}

// httpc returns response headers as binaries (or iolists on some OTP
// minors). `bit_array.to_string` normalises both to a Gleam String;
// non-UTF8 values fall through as empty (AWS response headers are
// always ASCII so this never bites in practice).
fn list_decode_headers(
  raw: List(#(BitArray, BitArray)),
) -> List(#(String, String)) {
  list.map(raw, fn(pair) {
    #(to_string_or_empty(pair.0), to_string_or_empty(pair.1))
  })
}

fn to_string_or_empty(b: BitArray) -> String {
  case bit_array.to_string(b) {
    Ok(s) -> s
    Error(_) -> ""
  }
}

fn translate_error(reason: Atom) -> HttpError {
  case atom.to_string(reason) {
    "failed_to_connect" -> ConnectFailed(reason: "could not connect to host")
    "response_timeout" -> Timeout
    "timeout" -> Timeout
    "invalid_utf8_response" ->
      InvalidBody(reason: "response body was not valid UTF-8")
    other -> Other(reason: other)
  }
}

@external(erlang, "aws_streaming_ffi", "streaming_send")
fn streaming_send(
  method: Method,
  url: String,
  headers: List(#(String, String)),
  body: BitArray,
  timeout_ms: Int,
  verify_tls: Bool,
  http2: Bool,
) -> Result(#(Int, List(#(BitArray, BitArray)), List(BitArray)), Atom)
