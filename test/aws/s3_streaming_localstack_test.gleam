//// LocalStack-backed end-to-end test for `aws/s3/streaming`.
////
//// Proves the streaming-side GetObject path actually streams bytes
//// from a real S3-compatible server. Sequence:
////
////   1. Create the bucket.
////   2. Upload a 100-byte payload via `transfer.upload` (multipart
////      with 50-byte parts, exercises the upload path too).
////   3. Fetch it back via `s3_streaming.get_object_streaming` —
////      the response body arrives as a `StreamingBody`.
////   4. Materialise the body via `streaming.to_bit_array` and
////      assert the bytes round-trip the upload exactly.
////   5. Clean up: delete object + bucket.
////
//// Gated on `INCLUDE_LOCALSTACK=1` so the default `gleam test`
//// skips this silently. Pattern mirrors `s3_transfer_localstack_test`.

import aws/config
import aws/s3/transfer
import aws/services/s3
import aws/streaming
import gleam/option.{None, Some}
import gleeunit/should
import support/localstack

const region: String = "us-east-1"

const bucket_name: String = "aws-sdk-gleam-streaming-e2e"

const object_key: String = "streaming-get-object.bin"

fn build_client(endpoint: String) -> s3.Client {
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some(region),
        credentials: Some(localstack.fake_credentials()),
        endpoint_url: Some(endpoint),
      ),
      s3.default_endpoint_params(),
    )
  client
}

fn create_bucket_input() -> s3.CreateBucketRequest {
  s3.CreateBucketRequest(
    acl: None,
    bucket: Some(bucket_name),
    bucket_namespace: None,
    create_bucket_configuration: None,
    grant_full_control: None,
    grant_read: None,
    grant_read_acp: None,
    grant_write: None,
    grant_write_acp: None,
    object_lock_enabled_for_bucket: None,
    object_ownership: None,
  )
}

fn delete_bucket_input() -> s3.DeleteBucketRequest {
  s3.DeleteBucketRequest(bucket: Some(bucket_name), expected_bucket_owner: None)
}

fn delete_object_input(key: String) -> s3.DeleteObjectRequest {
  s3.DeleteObjectRequest(
    bucket: Some(bucket_name),
    bypass_governance_retention: None,
    expected_bucket_owner: None,
    if_match: None,
    if_match_last_modified_time: None,
    if_match_size: None,
    key: Some(key),
    mfa: None,
    request_payer: None,
    version_id: None,
  )
}

fn get_object_input(key: String) -> s3.GetObjectRequest {
  s3.GetObjectRequest(
    bucket: Some(bucket_name),
    checksum_mode: None,
    expected_bucket_owner: None,
    if_match: None,
    if_modified_since: None,
    if_none_match: None,
    if_unmodified_since: None,
    key: Some(key),
    part_number: None,
    range: None,
    request_payer: None,
    response_cache_control: None,
    response_content_disposition: None,
    response_content_encoding: None,
    response_content_language: None,
    response_content_type: None,
    response_expires: None,
    sse_customer_algorithm: None,
    sse_customer_key: None,
    sse_customer_key_md5: None,
    version_id: None,
  )
}

fn payload() -> BitArray {
  <<
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{};:":utf8,
  >>
}

pub fn s3_streaming_get_object_round_trips_via_chunked_transport_test() {
  use container <- localstack.when_enabled
  let client = build_client(container.endpoint)
  let assert Ok(_) = s3.create_bucket(client, create_bucket_input())

  // Upload via the multipart helper — exercises the upload path
  // and lands real bytes in the bucket.
  let assert Ok(_) =
    transfer.upload(
      client:,
      bucket: bucket_name,
      key: object_key,
      body: payload(),
      part_size_bytes: 50,
    )

  // Fetch back via the streaming wrapper — proves the chunked
  // transport (`runtime.invoke_streaming` → `streaming_http_send`)
  // works against a real S3 implementation, not just the stub.
  let assert Ok(resp) =
    s3.get_object_streaming(client, get_object_input(object_key))
  resp.status |> should.equal(200)
  streaming.to_bit_array(resp.body) |> should.equal(payload())

  let assert Ok(_) = s3.delete_object(client, delete_object_input(object_key))
  let assert Ok(_) = s3.delete_bucket(client, delete_bucket_input())
  s3.shutdown(client)
}
