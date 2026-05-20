@external(erlang, "aws_ffi", "sha256")
pub fn sha256(data: BitArray) -> BitArray

/// Raw MD5 digest. Used by the `@httpChecksumRequired` body-checksum
/// helper in `aws/internal/codec/rest` — not by SigV4. MD5 is not a
/// security primitive; the wire spec requires it here so the SDK can
/// emit `Content-MD5: base64(md5(body))` for traits that demand it.
@external(erlang, "aws_ffi", "md5")
pub fn md5(data: BitArray) -> BitArray

@external(erlang, "aws_ffi", "hmac_sha256")
pub fn hmac_sha256(key: BitArray, data: BitArray) -> BitArray

@external(erlang, "aws_ffi", "hex_encode")
pub fn hex_encode(data: BitArray) -> String

/// Raw SHA-1 digest. Used by the AWS multi-algorithm checksum
/// feature (`aws.protocols#httpChecksum`) when the caller picks
/// `sha1` — the SDK sets `x-amz-checksum-sha1: base64(sha1(body))`
/// on the request. SHA-1 isn't a security primitive on AWS's side
/// either; it's a payload-integrity check, and we expose it
/// without warnings because the wire spec mandates it.
@external(erlang, "aws_ffi", "sha1")
pub fn sha1(data: BitArray) -> BitArray

/// Raw CRC-32 (IEEE 802.3, the same polynomial as zlib / gzip).
/// Returned as an `Int` because that's the natural Erlang form
/// (`erlang:crc32/1` returns an unsigned 32-bit integer). Callers
/// wanting the AWS wire form should base64-encode the big-endian
/// 4-byte representation; see `crc32_be_bytes` for the helper
/// that produces the bytes ready for `bit_array.base64_encode`.
@external(erlang, "erlang", "crc32")
pub fn crc32(data: BitArray) -> Int

/// Raw CRC-32C (Castagnoli polynomial 0x1EDC6F41, the iSCSI / SCTP
/// variant). Returned as an unsigned 32-bit `Int`. Implemented in
/// pure Erlang (`aws_ffi.crc32c`) because OTP's stdlib doesn't
/// expose this polynomial. Used by AWS multi-algorithm checksum
/// (`crc32c` variant) — base64 of the BE 4-byte form goes into
/// `x-amz-checksum-crc32c`.
@external(erlang, "aws_ffi", "crc32c")
pub fn crc32c(data: BitArray) -> Int

/// Big-endian 4-byte encoding of a CRC-32 value, ready to feed
/// into `bit_array.base64_encode`. AWS's
/// `x-amz-checksum-crc32: <base64>` header expects exactly four
/// bytes (not the hex form most other CRC libraries print). Pure
/// Gleam — no FFI hop — because Gleam's `BitArray` literal
/// syntax handles the bit packing inline.
pub fn crc32_be_bytes(value: Int) -> BitArray {
  <<value:size(32)-big>>
}
