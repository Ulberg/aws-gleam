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

/// Convenience: stream a GetObject response and materialise its
/// body as a `BitArray`, refusing if cumulative size would exceed
/// `max_bytes`. Thin wrapper over `streaming.collect_to_bit_array_max`
/// pinning the input error type to `runtime.ClientError`.
///
/// Typical "download a smallish-bounded object" case: small JSON /
/// config blobs / log shards where the wire bytes fit in memory
/// but the caller wants a hard ceiling. For multi-GB objects skip
/// this helper and consume chunks via `streaming.fold_chunks`.
pub fn download_to_bit_array_max(
  client: s3.Client,
  input: s3.GetObjectRequest,
  max_bytes: Int,
) -> Result(BitArray, streaming.CollectError(runtime.ClientError)) {
  streaming.collect_to_bit_array_max(
    s3.get_object_streaming(client, input),
    max_bytes,
  )
}
