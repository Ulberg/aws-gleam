@external(erlang, "aws_ffi", "sha256")
pub fn sha256(data: BitArray) -> BitArray

@external(erlang, "aws_ffi", "hmac_sha256")
pub fn hmac_sha256(key: BitArray, data: BitArray) -> BitArray

@external(erlang, "aws_ffi", "hex_encode")
pub fn hex_encode(data: BitArray) -> String
