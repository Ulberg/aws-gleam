//// Reader-role handler. SQS-triggered: the Lambda → SQS event
//// source mapping delivers the standard JSON envelope
////
////   { "Records": [ { "body": "<s3-key>", ... }, ... ] }
////
//// where each `body` is the S3 key the writer-role Lambda wrote
//// in `writer_handler.gleam`. For each record we fetch the object
//// from `SMOKE_BUCKET` and log its byte count. Success deletes the
//// SQS message via the integration's auto-ack; a returned `Error(_)`
//// reports back to the runtime and Lambda re-drives the message.
////
//// Exercises S3 restXml `get_object` end-to-end through the SDK's
//// endpoint resolver (the new `@contextParam` Bucket / Key bindings
//// flow into the rule set, so the resolved URL places the bucket
//// in the virtual-host subdomain).

import aws/services/s3
import aws/streaming
import gleam/bit_array
import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import runtime_api.{type Invocation, Invocation}

pub fn handle(inv: Invocation) -> Result(BitArray, String) {
  use bucket <- env_required("SMOKE_BUCKET")
  use client <- try_step("s3_client_init", s3.new_with_auto_region())

  let Invocation(payload: payload, ..) = inv
  let payload_result = bit_array.to_string(payload)
  let process_result = case payload_result {
    Error(_) -> Error("payload was not UTF-8 — SQS event JSON expected")
    Ok(envelope) -> process_envelope(client, bucket, envelope)
  }
  s3.shutdown(client)
  process_result
}

fn process_envelope(
  client: s3.Client,
  bucket: String,
  envelope: String,
) -> Result(BitArray, String) {
  use keys <- result.try(decode_keys(envelope))
  use _ <- result.try(
    list.try_each(keys, fn(key) { fetch_and_log(client, bucket, key) }),
  )
  Ok(bit_array.from_string(
    "{\"status\":\"ok\",\"processed\":"
    <> int.to_string(list.length(keys))
    <> "}",
  ))
}

fn fetch_and_log(
  client: s3.Client,
  bucket: String,
  key: String,
) -> Result(Nil, String) {
  let input =
    s3.GetObjectRequest(
      bucket: Some(bucket),
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
  case s3.get_object(client, input) {
    Ok(out) -> {
      let size = case out.body {
        None -> 0
        Some(body) -> streaming.byte_size(body)
      }
      io.println(
        "fetched s3://" <> bucket <> "/" <> key <> " (" <> int.to_string(size)
        <> " bytes)",
      )
      Ok(Nil)
    }
    Error(e) -> Error("get_object(" <> key <> "): " <> string.inspect(e))
  }
}

fn decode_keys(envelope: String) -> Result(List(String), String) {
  let decoder = {
    use records <- decode.field(
      "Records",
      decode.list({
        use body <- decode.field("body", decode.string)
        decode.success(body)
      }),
    )
    decode.success(records)
  }
  json.parse(envelope, decoder)
  |> result.map_error(fn(e) {
    "SQS event JSON decode failed: " <> string.inspect(e)
  })
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
