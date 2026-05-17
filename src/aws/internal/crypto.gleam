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
