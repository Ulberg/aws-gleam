//// Writer-role handler. For each invocation event, writes the raw
//// payload bytes to S3 under `events/<request_id>.bin`, then sends
//// the S3 key as an SQS message body to `SMOKE_QUEUE_URL`. The
//// reader-role Lambda picks the message up via the standard
//// Lambda → SQS event source mapping and fetches the object.
////
//// Together with `reader_handler.gleam` this exercises both
//// restXml (S3 PutObject) and awsJson1_0 (SQS SendMessage) from
//// the same OTP release, so a single smoke deploy validates the
//// SigV4 / endpoint resolver / HTTP transport across two protocol
//// codecs.
////
//// Environment variables:
////   - SMOKE_BUCKET    — destination bucket (set by Terraform)
////   - SMOKE_QUEUE_URL — destination queue URL (set by Terraform)
////   - AWS_REGION      — Lambda's runtime sets this automatically

import aws/services/s3
import aws/services/sqs
import aws/streaming
import gleam/bit_array
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import runtime_api.{type Invocation, Invocation}

pub fn handle(inv: Invocation) -> Result(BitArray, String) {
  use bucket <- env_required("SMOKE_BUCKET")
  use queue_url <- env_required("SMOKE_QUEUE_URL")

  use s3_client <- try_step("s3_client_init", s3.new_with_auto_region())
  use sqs_client <- try_step("sqs_client_init", sqs.new_with_auto_region())

  let Invocation(request_id: request_id, payload: payload, ..) = inv
  // Deterministic per-invocation key so a Lambda retry of the same
  // invocation re-uses the same object; the reader is idempotent on
  // GetObject either way.
  let key = "events/" <> request_id <> ".bin"

  let put_result = put_payload(s3_client, bucket, key, payload)
  s3.shutdown(s3_client)
  use _ <- result.try(put_result)

  let send_result = send_key(sqs_client, queue_url, key)
  sqs.shutdown(sqs_client)
  use _ <- result.try(send_result)

  Ok(bit_array.from_string(
    "{\"status\":\"ok\",\"s3_key\":\"" <> key <> "\"}",
  ))
}

fn put_payload(
  client: s3.Client,
  bucket: String,
  key: String,
  body: BitArray,
) -> Result(Nil, String) {
  let input =
    s3.PutObjectRequest(
      acl: None,
      body: Some(streaming.from_bit_array(body)),
      bucket: Some(bucket),
      bucket_key_enabled: None,
      cache_control: None,
      checksum_algorithm: None,
      checksum_crc32: None,
      checksum_crc32_c: None,
      checksum_crc64_nvme: None,
      checksum_md5: None,
      checksum_sha1: None,
      checksum_sha256: None,
      checksum_sha512: None,
      checksum_xxhash128: None,
      checksum_xxhash3: None,
      checksum_xxhash64: None,
      content_disposition: None,
      content_encoding: None,
      content_language: None,
      content_length: Some(bit_array.byte_size(body)),
      content_md5: None,
      content_type: Some("application/octet-stream"),
      expected_bucket_owner: None,
      expires: None,
      grant_full_control: None,
      grant_read: None,
      grant_read_acp: None,
      grant_write_acp: None,
      if_match: None,
      if_none_match: None,
      key: Some(key),
      metadata: None,
      object_lock_legal_hold_status: None,
      object_lock_mode: None,
      object_lock_retain_until_date: None,
      request_payer: None,
      sse_customer_algorithm: None,
      sse_customer_key: None,
      sse_customer_key_md5: None,
      ssekms_encryption_context: None,
      ssekms_key_id: None,
      server_side_encryption: None,
      storage_class: None,
      tagging: None,
      website_redirect_location: None,
      write_offset_bytes: None,
    )
  case s3.put_object(client, input) {
    Ok(_) -> Ok(Nil)
    Error(e) -> Error("put_object: " <> string.inspect(e))
  }
}

fn send_key(
  client: sqs.Client,
  queue_url: String,
  key: String,
) -> Result(Nil, String) {
  let input =
    sqs.SendMessageRequest(
      delay_seconds: None,
      message_attributes: None,
      message_body: Some(key),
      message_deduplication_id: None,
      message_group_id: None,
      message_system_attributes: None,
      queue_url: Some(queue_url),
    )
  case sqs.send_message(client, input) {
    Ok(_) -> Ok(Nil)
    Error(e) -> Error("send_message: " <> string.inspect(e))
  }
}

fn env_required(
  name: String,
  k: fn(String) -> Result(a, String),
) -> Result(a, String) {
  case os_getenv(name) {
    Ok(v) -> k(v)
    Error(_) -> Error("missing required env var: " <> name)
  }
}

fn try_step(
  step: String,
  res: Result(a, e),
  k: fn(a) -> Result(b, String),
) -> Result(b, String) {
  case res {
    Ok(v) -> k(v)
    Error(e) -> Error(step <> ": " <> string.inspect(e))
  }
}

@external(erlang, "os", "getenv")
fn os_getenv(name: String) -> Result(String, Nil)
