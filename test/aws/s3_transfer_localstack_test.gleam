//// LocalStack-backed end-to-end test for `aws/s3/transfer`.
////
//// Proves the multipart-upload coordinator works against a real
//// S3-compatible server, not just a scripted stub: create bucket →
//// `transfer.upload` (small body split into 2 parts via a tiny
//// `part_size_bytes`) → `get_object` to verify the bytes round-trip
//// intact → clean up. LocalStack doesn't enforce S3's 5 MiB
//// minimum part size, so we use a 100-byte body + 50-byte parts to
//// keep the test fast.
////
//// A second test exercises `upload_with_options` by setting
//// `content_type` and verifying it round-trips on the GetObject
//// response — proves options reach the wire on the
//// `CreateMultipartUpload` request and survive the `Complete` step.
////
//// Both tests are gated on `INCLUDE_LOCALSTACK=1` so a plain
//// `gleam test` skips them silently.

import aws/config
import aws/s3/transfer
import aws/services/s3
import aws/streaming
import gleam/option.{None, Some}
import gleeunit/should
import support/localstack

const region: String = "us-east-1"

const bucket_name: String = "aws-sdk-gleam-transfer-e2e"

const object_key: String = "multipart-roundtrip.bin"

fn build_client(endpoint: String) -> s3.Client {
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some(region),
        credentials: Some(localstack.fake_credentials()),
        endpoint_url: Some(endpoint),
      ),
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

fn body_100_bytes() -> BitArray {
  // Hundred-byte body — small enough to keep the LocalStack round
  // trip fast, big enough to split into two parts with the 50-byte
  // part size we pass to `transfer.upload`.
  <<
    "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()_+-=[]{};:":utf8,
  >>
}

pub fn transfer_upload_multipart_round_trip_test() {
  use container <- localstack.when_enabled
  let client = build_client(container.endpoint)
  let assert Ok(_) = s3.create_bucket(client, create_bucket_input())

  let payload = body_100_bytes()
  let assert Ok(result) =
    transfer.upload(
      client:,
      bucket: bucket_name,
      key: object_key,
      body: payload,
      part_size_bytes: 50,
    )
  result.parts_uploaded |> should.equal(2)

  let assert Ok(out) = s3.get_object(client, get_object_input(object_key))
  let assert Some(body) = out.body
  streaming.to_bit_array(body) |> should.equal(payload)

  let assert Ok(_) = s3.delete_object(client, delete_object_input(object_key))
  let assert Ok(_) = s3.delete_bucket(client, delete_bucket_input())
  s3.shutdown(client)
}

pub fn transfer_upload_with_options_round_trips_content_type_test() {
  use container <- localstack.when_enabled
  let client = build_client(container.endpoint)
  let assert Ok(_) = s3.create_bucket(client, create_bucket_input())

  let opts =
    transfer.UploadOptions(
      ..transfer.default_options(),
      content_type: Some("application/json"),
    )
  let key = "options-content-type.json"
  let payload = <<"{\"hello\":\"world\"}":utf8>>

  let assert Ok(_) =
    transfer.upload_with_options(
      client:,
      bucket: bucket_name,
      key:,
      body: payload,
      part_size_bytes: transfer.default_part_size_bytes,
      options: opts,
    )

  let assert Ok(out) = s3.get_object(client, get_object_input(key))
  // GetObject echoes back the content-type stored at create time —
  // proves the option threaded through both CreateMultipartUpload
  // and CompleteMultipartUpload intact.
  out.content_type |> should.equal(Some("application/json"))

  let assert Ok(_) = s3.delete_object(client, delete_object_input(key))
  let assert Ok(_) = s3.delete_bucket(client, delete_bucket_input())
  s3.shutdown(client)
}
