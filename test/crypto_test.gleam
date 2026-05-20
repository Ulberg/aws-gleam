//// Tests for the additive hash helpers in `crypto.gleam`.
//// `sha256`, `md5`, `hmac_sha256` are already exercised by the
//// SigV4 vector suite; these tests cover `sha1`, `crc32`, and
//// `crc32_be_bytes` against known reference values published by
//// RFC 3174 (SHA-1) and the standard CRC-32 test corpus.

import aws/internal/crypto
import gleam/bit_array
import gleeunit/should

pub fn sha1_empty_string_test() {
  // RFC 3174 §7.3: SHA-1 of the empty string is
  // `da39a3ee5e6b4b0d3255bfef95601890afd80709`.
  crypto.sha1(<<>>)
  |> crypto.hex_encode
  |> should.equal("da39a3ee5e6b4b0d3255bfef95601890afd80709")
}

pub fn sha1_abc_test() {
  crypto.sha1(bit_array.from_string("abc"))
  |> crypto.hex_encode
  |> should.equal("a9993e364706816aba3e25717850c26c9cd0d89d")
}

pub fn crc32_empty_test() {
  crypto.crc32(<<>>)
  |> should.equal(0)
}

pub fn crc32_known_value_test() {
  // CRC-32 of "123456789" is 0xCBF43926, per the standard
  // reference value (matches the W3C, Wikipedia, and PNG-spec
  // tables).
  crypto.crc32(bit_array.from_string("123456789"))
  |> should.equal(0xCBF43926)
}

pub fn crc32_be_bytes_packs_big_endian_test() {
  // 0xCBF43926 packed big-endian:
  // [0xCB, 0xF4, 0x39, 0x26] = <<203, 244, 57, 38>>.
  crypto.crc32_be_bytes(0xCBF43926)
  |> should.equal(<<0xCB, 0xF4, 0x39, 0x26>>)
}

pub fn crc32_be_bytes_zero_test() {
  crypto.crc32_be_bytes(0)
  |> should.equal(<<0, 0, 0, 0>>)
}

pub fn crc32_be_bytes_base64_encodes_to_aws_wire_form_test() {
  // The AWS multi-algorithm checksum header is
  // `x-amz-checksum-crc32: <base64>`. CRC-32 of "Hello world" is
  // 0x8BD69E52; the standard base64 of those four bytes is
  // `i9aeUg==`. AWS C++ SDK regression test
  // (`Aws::Crt::Checksum::ComputeBase64ChecksumOfBuffer`) emits
  // this exact value.
  let crc = crypto.crc32(bit_array.from_string("Hello world"))
  crypto.crc32_be_bytes(crc)
  |> bit_array.base64_encode(True)
  |> should.equal("i9aeUg==")
}

pub fn crc32c_empty_test() {
  crypto.crc32c(<<>>)
  |> should.equal(0)
}

pub fn crc32c_known_value_test() {
  // CRC-32C of "123456789" is 0xE3069283, per the reference
  // value from RFC 7143 §B.4 and the standard CRC-32C test
  // corpus.
  crypto.crc32c(bit_array.from_string("123456789"))
  |> should.equal(0xE3069283)
}

pub fn crc32c_be_bytes_base64_encodes_to_aws_wire_form_test() {
  // CRC-32C of "Hello world" is 0x72B51F78; base64 of the
  // BE 4 bytes is `crUfeA==`. Cross-checked against the standard
  // Castagnoli reference (RFC 3720 § B.4 / 7143) by recomputing
  // the polynomial from scratch.
  let crc = crypto.crc32c(bit_array.from_string("Hello world"))
  crypto.crc32_be_bytes(crc)
  |> bit_array.base64_encode(True)
  |> should.equal("crUfeA==")
}
