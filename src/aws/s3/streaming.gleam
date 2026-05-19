//// Hand-written convenience wrappers around streaming S3 operations.
////
//// The base `get_object_streaming(client, input) -> Result(streaming.Response,
//// runtime.ClientError)` is emitted by the codegen directly on the
//// `s3` module (see `s3.get_object_streaming`). This module adds
//// pure convenience helpers on top — patterns that come up often
//// enough that surfacing them with their own typed error is
//// worthwhile.

import aws/internal/client/runtime
import aws/services/s3
import aws/streaming
import gleam/result

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
    s3.get_object_streaming(client, input)
    |> result.map_error(TransportFailed),
  )
  case streaming.to_bit_array_max(resp.body, max_bytes) {
    Ok(bytes) -> Ok(bytes)
    Error(_) -> Error(BodyTooLarge(max_bytes: max_bytes))
  }
}
