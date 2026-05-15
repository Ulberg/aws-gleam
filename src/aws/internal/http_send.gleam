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

/// Production sender backed by Erlang's `httpc` via `gleam_httpc`.
pub fn default_send(
  req: Request(BitArray),
) -> Result(Response(BitArray), HttpError) {
  case httpc.send_bits(req) {
    Ok(response) -> Ok(response)
    Error(httpc.FailedToConnect(_, _)) ->
      Error(ConnectFailed(reason: "could not connect to host"))
    Error(httpc.ResponseTimeout) -> Error(Timeout)
    Error(httpc.InvalidUtf8Response) ->
      Error(InvalidBody(reason: "response body was not valid UTF-8"))
  }
}
