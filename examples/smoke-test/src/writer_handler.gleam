//// Writer-role one-shot task. Reads a payload, writes it to S3
//// under a per-run key, sends the key on to SQS, then exits.
////
//// `SMOKE_PAYLOAD` is the canonical input — Fargate's RunTask
//// passes it via the task's `environment` overrides. When unset
//// the writer falls back to a default string so a bare
//// `run-task` invocation still produces a verifiable round-trip.

import aws/services/s3
import aws/services/sqs
import aws/streaming
import gleam/bit_array
import gleam/int
import gleam/option.{None, Some}
import gleam/result
import gleam/string

const default_payload: String = "hello from aws-gleam fargate smoke test"

pub fn run() -> Result(String, String) {
  use bucket <- env_required("SMOKE_BUCKET")
  use queue_url <- env_required("SMOKE_QUEUE_URL")

  use s3_client <- try_step("s3_client_init", s3.new_with_auto_region())
  use sqs_client <- try_step("sqs_client_init", sqs.new_with_auto_region())

  let payload = case os_getenv("SMOKE_PAYLOAD") {
    Ok(p) if p != "" -> p
    _ -> default_payload
  }
  let key = "events/" <> mint_key_suffix() <> ".bin"
  let body = bit_array.from_string(payload)

  let put_outcome = put_payload(s3_client, bucket, key, body)
  s3.shutdown(s3_client)
  use _ <- result.try(put_outcome)

  let send_outcome = send_key(sqs_client, queue_url, key)
  sqs.shutdown(sqs_client)
  use _ <- result.try(send_outcome)

  Ok(
    "writer ok: wrote s3://"
    <> bucket
    <> "/"
    <> key
    <> " ("
    <> int.to_string(bit_array.byte_size(body))
    <> " bytes), enqueued to "
    <> queue_url,
  )
}

fn mint_key_suffix() -> String {
  // `erlang:unique_integer/0` is guaranteed unique within this BEAM
  // node's lifetime. Negative values are possible in some OTP
  // versions; abs them out so the key looks tidy.
  int.to_string(int_abs(unique_integer()))
}

fn int_abs(n: Int) -> Int {
  case n < 0 {
    True -> -n
    False -> n
  }
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
    Error(e) -> Error("s3.put_object: " <> string.inspect(e))
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
    Error(e) -> Error("sqs.send_message: " <> string.inspect(e))
  }
}

fn env_required(
  name: String,
  k: fn(String) -> Result(a, String),
) -> Result(a, String) {
  case os_getenv(name) {
    Ok(v) if v != "" -> k(v)
    _ -> Error("missing required env var: " <> name)
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

@external(erlang, "smoke_ffi", "get_env")
fn os_getenv(name: String) -> Result(String, Nil)

@external(erlang, "erlang", "unique_integer")
fn unique_integer() -> Int
