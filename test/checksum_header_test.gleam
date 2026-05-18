//// Tests for `rest.checksum_header` / `rest.with_checksum_header`.
////
//// These are the building blocks for the
//// `aws.protocols#httpChecksum` multi-algorithm checksum
//// middleware. Each algorithm's expected output is the base64 of
//// the corresponding raw digest, byte-for-byte what AWS's
//// reference implementations produce.

import aws/internal/codec/rest.{
  ChecksumCrc32, ChecksumCrc32C, ChecksumSha1, ChecksumSha256,
}
import gleam/bit_array
import gleam/dict
import gleeunit/should

pub fn sha256_checksum_header_empty_body_test() {
  // base64(sha256("")) = `47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=`.
  let #(name, value) = rest.checksum_header(ChecksumSha256, <<>>)
  name |> should.equal("x-amz-checksum-sha256")
  value |> should.equal("47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=")
}

pub fn sha1_checksum_header_abc_test() {
  // base64(sha1("abc")) = `qZk+NkcGgWq6PiVxeFDCbJzQ2J0=`.
  let #(name, value) =
    rest.checksum_header(ChecksumSha1, bit_array.from_string("abc"))
  name |> should.equal("x-amz-checksum-sha1")
  value |> should.equal("qZk+NkcGgWq6PiVxeFDCbJzQ2J0=")
}

pub fn crc32_checksum_header_hello_world_test() {
  // CRC-32("Hello world") = 0x8BD69E52, base64 of the BE 4 bytes
  // is `i9aeUg==`. Matches the AWS C++ SDK's `crc32` test vector.
  let #(name, value) =
    rest.checksum_header(ChecksumCrc32, bit_array.from_string("Hello world"))
  name |> should.equal("x-amz-checksum-crc32")
  value |> should.equal("i9aeUg==")
}

pub fn crc32c_checksum_header_hello_world_test() {
  // CRC-32C("Hello world") = 0x72B51F78; base64 = `crUfeA==`.
  let #(name, value) =
    rest.checksum_header(ChecksumCrc32C, bit_array.from_string("Hello world"))
  name |> should.equal("x-amz-checksum-crc32c")
  value |> should.equal("crUfeA==")
}

pub fn with_checksum_header_inserts_in_dict_test() {
  let headers = dict.from_list([#("Content-Type", "text/plain")])
  let out =
    rest.with_checksum_header(headers, ChecksumSha256, bit_array.from_string("hi"))
  // Preexisting Content-Type stays; checksum header added.
  out
  |> dict.get("Content-Type")
  |> should.equal(Ok("text/plain"))
  out
  |> dict.get("x-amz-checksum-sha256")
  |> should.equal(Ok("j0NDRmSPa5bfid2pAcUXaxCm2Dlh3TwayItZstwyeqQ="))
}
