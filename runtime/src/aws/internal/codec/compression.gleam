//// Request-body compression for `@smithy.api#requestCompression`.
////
//// Mirrors the Rust SDK's `RequestCompressionInterceptor`
//// (vendor/aws-sdk-rust/sdk/aws-smithy-compression/src/) — gzip the
//// body when it's at least `min_compression_size_bytes` long, drop
//// the wrap entirely when it's smaller (compressing tiny bodies
//// usually makes them larger). The default matches Rust:
//// 10 240 bytes (10 KiB).
////
//// Erlang's stdlib `zlib:gzip/1` does the work — no extra deps.
//// Only gzip is supported today; the trait technically allows other
//// algorithms (brotli, etc.) but no AWS service uses them.

import gleam/bit_array

/// Default `min_compression_size_bytes` matching the Rust SDK
/// (`vendor/aws-sdk-rust/sdk/aws-smithy-compression/src/lib.rs:61`).
/// Bodies smaller than this skip both the gzip wrap AND the
/// `Content-Encoding: gzip` header — compressing tiny bodies tends
/// to make them larger, so the SDK silently no-ops below the cap.
pub const default_min_compression_size_bytes: Int = 10_240

/// Gzip a body via Erlang's `zlib:gzip/1`. Pure function; no
/// streaming variant since `@requestCompression` only wraps
/// buffered bodies (streaming bodies use the chunked transport
/// which has its own per-chunk wrappers).
@external(erlang, "zlib", "gzip")
pub fn gzip(body: BitArray) -> BitArray

/// Apply a `@requestCompression` algorithm to `body` if the body is
/// at least `min_size` bytes long. Returns `#(compressed_body,
/// applied)` — `applied` is `True` iff the body was actually wrapped
/// (the caller uses it to decide whether to set the
/// `Content-Encoding` header). When `encoding` isn't `"gzip"` (the
/// only algorithm we support today), the body passes through
/// unchanged and `applied` is `False`.
pub fn maybe_compress(
  body: BitArray,
  encoding: String,
  min_size: Int,
) -> #(BitArray, Bool) {
  case encoding, bit_array.byte_size(body) >= min_size {
    "gzip", True -> #(gzip(body), True)
    _, _ -> #(body, False)
  }
}
