//// HTTP send abstraction used by all HTTP-based credential providers (and
//// later by the request pipeline itself).
////
//// Every provider that talks to AWS endpoints takes a `Send` value so tests
//// can drive it with a stub. Production code calls `default_send`, which
//// dispatches via `gleam_httpc` (Erlang's `httpc`).
////
//// Errors are normalised to a single `HttpError` sum type so the providers
//// can pattern-match on category without depending on `httpc`'s shape
//// directly.

import aws/streaming.{type StreamingBody}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/httpc

pub type HttpError {
  /// Could not reach the host (DNS, TCP, TLS).
  ConnectFailed(reason: String)
  /// Connection succeeded but no response came back in time.
  Timeout
  /// Response body was not the expected encoding.
  InvalidBody(reason: String)
  /// Anything else the transport surfaced.
  Other(reason: String)
}

/// A function that sends a request and returns a response (or an HTTP error).
/// The body is `BitArray` so providers can deal in raw bytes without forcing
/// UTF-8 decoding decisions on the transport.
pub type Send =
  fn(Request(BitArray)) -> Result(Response(BitArray), HttpError)

/// Streaming variant of `Send`. The response body is a `StreamingBody`,
/// which v1 carries as a single buffered chunk and the eventual chunked
/// transport delivers as a true byte stream. Object-streaming GETs
/// (S3 `GetObject`, MediaLive, etc.) take this shape so call sites can
/// migrate today and pick up the real streaming path later without an
/// API change.
pub type StreamingSend =
  fn(Request(BitArray)) -> Result(Response(StreamingBody), HttpError)

/// Lift a buffered `Send` into a `StreamingSend`. For v1 this simply
/// wraps the response body bytes in a `Buffered` `StreamingBody`; once
/// the transport rewrite lands a real chunked sender replaces this
/// helper at the call sites that already pass a `StreamingSend`.
pub fn lift_to_streaming(send: Send) -> StreamingSend {
  fn(req) {
    case send(req) {
      Ok(resp) ->
        Ok(response.Response(
          status: resp.status,
          headers: resp.headers,
          body: streaming.from_bit_array(resp.body),
        ))
      Error(e) -> Error(e)
    }
  }
}

/// Streaming-aware default sender — same transport defaults as
/// `default_send`, response body wrapped as a `StreamingBody`.
pub fn default_streaming_send(
  req: Request(BitArray),
) -> Result(Response(StreamingBody), HttpError) {
  lift_to_streaming(default_send)(req)
}

/// Default total-request timeout for `default_send`. 30 seconds is the
/// gleam_httpc default and a reasonable upper bound for control-plane and
/// list operations. Object-streaming GETs that may take longer want a
/// dedicated, more generous Send.
pub const default_timeout_seconds: Int = 30

/// IMDS gets a much shorter total timeout because its first call goes to a
/// link-local address that doesn't resolve at all on a non-EC2 host.
/// Without this, the TCP retransmit window can stall the whole credential
/// chain for tens of seconds — enough to trip the credentials cache actor's
/// 5-second call timeout.
pub const imds_timeout_seconds: Int = 2

/// Production sender — 30 second total timeout, TLS verification on.
pub fn default_send(
  req: Request(BitArray),
) -> Result(Response(BitArray), HttpError) {
  do_send(default_config(), req)
}

/// Build a `Send` with a custom total timeout. Use this for endpoints that
/// need either fast-fail behaviour (IMDS) or extra patience (large object
/// downloads). TLS verification and redirect-following match
/// `default_send`'s defaults; if you need to tweak those, drop down to
/// `gleam_httpc` directly.
pub fn with_timeout(seconds seconds: Int) -> Send {
  let config = httpc.configure() |> httpc.timeout(seconds * 1000)
  fn(req) { do_send(config, req) }
}

/// IMDS-tuned sender. Equivalent to `with_timeout(seconds: imds_timeout_seconds)`,
/// exported as a constant so call sites read meaningfully.
pub fn imds_send(
  req: Request(BitArray),
) -> Result(Response(BitArray), HttpError) {
  with_timeout(seconds: imds_timeout_seconds)(req)
}

fn default_config() -> httpc.Configuration {
  httpc.configure() |> httpc.timeout(default_timeout_seconds * 1000)
}

fn do_send(
  config: httpc.Configuration,
  req: Request(BitArray),
) -> Result(Response(BitArray), HttpError) {
  case httpc.dispatch_bits(config, req) {
    Ok(response) -> Ok(response)
    Error(httpc.FailedToConnect(_, _)) ->
      Error(ConnectFailed(reason: "could not connect to host"))
    Error(httpc.ResponseTimeout) -> Error(Timeout)
    Error(httpc.InvalidUtf8Response) ->
      Error(InvalidBody(reason: "response body was not valid UTF-8"))
  }
}
