//// Pins `aws/internal/codec/compression.maybe_compress` — the
//// `@smithy.api#requestCompression` body wrap. Threshold defaults
//// to the Rust SDK's 10 240 bytes; sub-threshold bodies pass
//// through untouched (matches `RequestCompressionInterceptor.
//// modify_before_retry_loop` which skips the wrap entirely).

import aws/internal/codec/compression
import gleam/bit_array
import gleeunit/should

@external(erlang, "zlib", "gunzip")
fn gunzip(b: BitArray) -> BitArray

fn make_body(byte_count: Int) -> BitArray {
  // Pseudo-random but deterministic: repeat a 32-byte ASCII pattern
  // to the requested length. zlib compresses repetitive input
  // hard, so the result is meaningfully smaller than the input.
  let unit = <<"abcdefghijklmnopqrstuvwxyz012345":utf8>>
  let unit_size = bit_array.byte_size(unit)
  let n = byte_count / unit_size + 1
  build(unit, n, <<>>) |> bit_array.slice(at: 0, take: byte_count)
  |> result.unwrap(<<>>)
}

fn build(unit: BitArray, n: Int, acc: BitArray) -> BitArray {
  case n {
    0 -> acc
    _ -> build(unit, n - 1, <<acc:bits, unit:bits>>)
  }
}

import gleam/result

pub fn sub_threshold_body_passes_through_test() {
  let body = make_body(9000)
  // 9 000 < default 10 240, so no compression and no header signal.
  let #(out, applied) =
    compression.maybe_compress(
      body,
      "gzip",
      compression.default_min_compression_size_bytes,
    )
  applied |> should.be_false
  bit_array.byte_size(out) |> should.equal(9000)
  out |> should.equal(body)
}

pub fn at_threshold_body_gets_compressed_test() {
  let body = make_body(10_240)
  let #(out, applied) =
    compression.maybe_compress(
      body,
      "gzip",
      compression.default_min_compression_size_bytes,
    )
  applied |> should.be_true
  // Repetitive ASCII compresses massively — output is well under
  // the 10 240-byte input.
  case bit_array.byte_size(out) < 10_240 {
    True -> Nil
    False -> should.fail()
  }
  // Round-trip via `zlib:gunzip/1` recovers the original bytes.
  gunzip(out) |> should.equal(body)
}

pub fn unsupported_encoding_passes_through_test() {
  let body = make_body(20_000)
  let #(out, applied) =
    compression.maybe_compress(
      body,
      "brotli",
      compression.default_min_compression_size_bytes,
    )
  applied |> should.be_false
  out |> should.equal(body)
}
