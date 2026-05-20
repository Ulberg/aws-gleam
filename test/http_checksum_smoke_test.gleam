//// End-to-end smoke test for the `aws.protocols#httpChecksum`
//// middleware (M10 + M18). Drives a real generated S3 request
//// builder for `PutBucketAccelerateConfiguration` — an op that
//// carries `aws.protocols#httpChecksum` with
//// `requestChecksumRequired: true` and a `ChecksumAlgorithm`
//// algorithm member — and asserts the right `x-amz-checksum-<alg>`
//// header lands on the wire.

import aws/services/s3
import gleam/dict
import gleam/option.{None, Some}
import gleeunit/should

pub fn default_to_sha256_when_algorithm_unset_test() {
  // No `checksum_algorithm` supplied — M10's fallback fires and
  // we get a SHA-256 header. The body is empty so the digest is
  // the well-known sha256("") base64.
  let #(_method, _path, headers, _body) =
    s3.build_put_bucket_accelerate_configuration_request(
      s3.PutBucketAccelerateConfigurationRequest(
        accelerate_configuration: None,
        bucket: Some("my-bucket"),
        checksum_algorithm: None,
        expected_bucket_owner: None,
      ),
    )
  headers
  |> dict.get("x-amz-checksum-sha256")
  |> should.equal(Ok("47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="))
}

pub fn dispatch_to_sha1_when_algorithm_set_test() {
  // Caller picks SHA-1; M18's algorithm-member dispatch reads
  // the typed enum, projects its wire value ("SHA1"), and
  // routes to the SHA-1 header.
  let #(_method, _path, headers, _body) =
    s3.build_put_bucket_accelerate_configuration_request(
      s3.PutBucketAccelerateConfigurationRequest(
        accelerate_configuration: None,
        bucket: Some("my-bucket"),
        checksum_algorithm: Some(s3.ChecksumAlgorithmSha1),
        expected_bucket_owner: None,
      ),
    )
  headers
  |> dict.get("x-amz-checksum-sha1")
  |> should.equal(Ok("2jmj7l5rSw0yVb/vlWAYkK/YBwk="))
  // The SHA-256 header is NOT also set — only the dispatched
  // algorithm fires.
  headers
  |> dict.get("x-amz-checksum-sha256")
  |> should.equal(Error(Nil))
}

pub fn dispatch_to_crc32c_test() {
  let #(_method, _path, headers, _body) =
    s3.build_put_bucket_accelerate_configuration_request(
      s3.PutBucketAccelerateConfigurationRequest(
        accelerate_configuration: None,
        bucket: Some("my-bucket"),
        checksum_algorithm: Some(s3.ChecksumAlgorithmCrc32c),
        expected_bucket_owner: None,
      ),
    )
  // CRC-32C("") = 0; base64 of 4 zero bytes = "AAAAAA==".
  headers
  |> dict.get("x-amz-checksum-crc32c")
  |> should.equal(Ok("AAAAAA=="))
}

pub fn unsupported_algorithm_falls_back_to_sha256_test() {
  // SHA-512 isn't in our runtime's `ChecksumAlgorithm` set —
  // `checksum_algorithm_from_wire` falls back to SHA-256 rather
  // than crashing, and the SHA-256 header lands.
  let #(_method, _path, headers, _body) =
    s3.build_put_bucket_accelerate_configuration_request(
      s3.PutBucketAccelerateConfigurationRequest(
        accelerate_configuration: None,
        bucket: Some("my-bucket"),
        checksum_algorithm: Some(s3.ChecksumAlgorithmSha512),
        expected_bucket_owner: None,
      ),
    )
  headers
  |> dict.get("x-amz-checksum-sha256")
  |> should.equal(Ok("47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU="))
}
