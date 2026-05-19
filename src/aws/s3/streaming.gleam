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
import aws/streaming
import gleam/result

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
) -> Result(streaming.Response, runtime.ClientError) {
  use resp <- result.try(runtime.invoke_streaming(
    s3.config(client),
    s3.build_get_object_request(input),
  ))
  Ok(streaming.Response(
    status: resp.status,
    headers: resp.headers,
    body: resp.body,
  ))
}

/// Errors `download_to_bit_array_max` can surface — splits the
/// streaming wrapper's transport / service / credentials failures
/// from the bounded-size cap so callers can react differently
/// (retry transient, page through ranges for the size cap, etc.).
pub type DownloadError {
  TransportFailed(cause: runtime.ClientError)
  BodyTooLarge(max_bytes: Int)
}

/// Convenience: stream a GetObject response and materialise its
/// body as a `BitArray`, refusing if cumulative size would exceed
/// `max_bytes`. The size check walks chunks lazily on the chunked
/// path so the cap fires before concatenation — safe to call with
/// untrusted object sizes.
///
/// Typical "download a smallish-bounded object" case: think small
/// JSON / config blobs / log shards where the wire bytes fit in
/// memory but you want a hard ceiling. For multi-GB objects skip
/// this helper and consume chunks via `streaming.fold_chunks`.
pub fn download_to_bit_array_max(
  client: s3.Client,
  input: s3.GetObjectRequest,
  max_bytes: Int,
) -> Result(BitArray, DownloadError) {
  use resp <- result.try(
    get_object_streaming(client, input)
    |> result.map_error(TransportFailed),
  )
  case streaming.to_bit_array_max(resp.body, max_bytes) {
    Ok(bytes) -> Ok(bytes)
    Error(_) -> Error(BodyTooLarge(max_bytes: max_bytes))
  }
}
