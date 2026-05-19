//// Hand-written streaming wrappers around generated S3 operations
//// whose output carries `@streaming` (currently just `GetObject`).
//// Routes the response through `runtime.invoke_streaming` so the
//// body bytes arrive as a `StreamingBody` (chunked) instead of
//// the buffered `BitArray` the generated `s3.get_object` returns.
////
//// This is a stepping-stone until the per-op codegen learns to
//// emit a `<op>_streaming` variant directly — the prototype is
//// here so users can stream multi-GB GetObject responses today
//// instead of OOMing the process buffering them.
////
//// Per-op typed-error translation lives inside the generated `s3`
//// module (private `translate_<op>_error`), so this prototype
//// surfaces the runtime's untyped `runtime.ClientError` instead.
//// Callers needing typed errors can still drop down to
//// `s3.get_object` (buffered) for those code paths; the typed-
//// error variant of streaming arrives with the codegen pass.

import aws/internal/client/runtime
import aws/services/s3
import aws/streaming.{type StreamingBody}
import gleam/result

/// What `get_object_streaming` returns on success — the wire-side
/// status, the raw headers list (preserves case-as-delivered), and
/// the response body as a `StreamingBody`. Headers as a list of
/// pairs (rather than a `Dict`) mirrors `gleam/http`'s shape and
/// keeps duplicate-header semantics observable.
pub type StreamingResponse {
  StreamingResponse(
    status: Int,
    headers: List(#(String, String)),
    body: StreamingBody,
  )
}

/// Stream the response body of an S3 `GetObject` request. The body
/// arrives as a `StreamingBody` whose chunks are consumed via
/// `streaming.fold_chunks` / `streaming.to_chunks` /
/// `streaming.to_bit_array_max(_, max)` without buffering the
/// whole payload up front.
///
/// Errors surface as `runtime.ClientError` (transport / credentials /
/// service / decode) — the typed `s3.GetObjectError` translation
/// lives inside the generated `s3` module and isn't reachable from
/// here. Use `s3.get_object` (buffered) when typed errors are
/// required and the body fits in memory.
pub fn get_object_streaming(
  client: s3.Client,
  input: s3.GetObjectRequest,
) -> Result(StreamingResponse, runtime.ClientError) {
  use resp <- result.try(runtime.invoke_streaming(
    s3.config(client),
    s3.build_get_object_request(input),
  ))
  Ok(StreamingResponse(
    status: resp.status,
    headers: resp.headers,
    body: resp.body,
  ))
}
