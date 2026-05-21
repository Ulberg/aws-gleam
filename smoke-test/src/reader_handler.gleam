//// Reader-role long-running service. Polls SQS with a 20s
//// long-poll, fetches each S3 object whose key arrives as a
//// message body, logs the byte count, deletes the message.
//// Re-enters the poll on success and on transient failure;
//// only a `panic` (config missing) ends the process — ECS then
//// restarts the task per the service's `desired_count = 1`.
////
//// Logs land in CloudWatch via the task definition's awslogs
//// driver — `aws logs tail /ecs/aws-gleam-smoke --follow` is
//// the live-view command.

import aws/services/s3
import aws/services/sqs
import aws/streaming
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub fn run_forever() -> Nil {
  let bucket = env_or_die("SMOKE_BUCKET")
  let queue_url = env_or_die("SMOKE_QUEUE_URL")
  let s3_client = case s3.new_with_auto_region() {
    Ok(c) -> c
    Error(e) -> panic as { "s3_client_init: " <> string.inspect(e) }
  }
  let sqs_client = case sqs.new_with_auto_region() {
    Ok(c) -> c
    Error(e) -> panic as { "sqs_client_init: " <> string.inspect(e) }
  }
  io.println("reader: started, polling " <> queue_url)
  loop(s3_client, sqs_client, bucket, queue_url)
}

fn loop(
  s3_client: s3.Client,
  sqs_client: sqs.Client,
  bucket: String,
  queue_url: String,
) -> Nil {
  let messages = receive_batch(sqs_client, queue_url)
  list.each(messages, fn(m) {
    case process(s3_client, sqs_client, bucket, queue_url, m) {
      Ok(_) -> Nil
      Error(reason) ->
        // Don't delete on failure — SQS will re-deliver after
        // visibility-timeout. Log so CloudWatch shows the cause.
        io.println_error("reader: skip " <> short_id(m) <> ": " <> reason)
    }
  })
  loop(s3_client, sqs_client, bucket, queue_url)
}

fn receive_batch(client: sqs.Client, queue_url: String) -> List(sqs.Message) {
  let req =
    sqs.ReceiveMessageRequest(
      attribute_names: None,
      max_number_of_messages: Some(10),
      message_attribute_names: None,
      message_system_attribute_names: None,
      queue_url: Some(queue_url),
      receive_request_attempt_id: None,
      visibility_timeout: None,
      // Long-poll: cuts empty-queue API spend by ~25x at idle, also
      // lower latency than a sleep-poll loop.
      wait_time_seconds: Some(20),
    )
  case sqs.receive_message(client, req) {
    Ok(result) ->
      case result.messages {
        Some(msgs) -> msgs
        None -> []
      }
    Error(e) -> {
      io.println_error("reader: receive_message: " <> string.inspect(e))
      []
    }
  }
}

fn process(
  s3_client: s3.Client,
  sqs_client: sqs.Client,
  bucket: String,
  queue_url: String,
  message: sqs.Message,
) -> Result(Nil, String) {
  let key = case message.body {
    Some(k) -> k
    None -> ""
  }
  case key {
    "" -> Error("empty message body")
    _ -> {
      case fetch(s3_client, bucket, key) {
        Ok(size) -> {
          io.println(
            "reader: fetched s3://"
            <> bucket
            <> "/"
            <> key
            <> " ("
            <> int.to_string(size)
            <> " bytes)",
          )
          delete(sqs_client, queue_url, message)
        }
        Error(reason) -> Error(reason)
      }
    }
  }
}

fn fetch(client: s3.Client, bucket: String, key: String) -> Result(Int, String) {
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
    Ok(out) ->
      Ok(case out.body {
        Some(body) -> streaming.byte_size(body)
        None -> 0
      })
    Error(e) -> Error("s3.get_object: " <> string.inspect(e))
  }
}

fn delete(
  client: sqs.Client,
  queue_url: String,
  message: sqs.Message,
) -> Result(Nil, String) {
  case message.receipt_handle {
    None -> Error("missing receipt_handle on message")
    Some(handle) -> {
      let req =
        sqs.DeleteMessageRequest(
          queue_url: Some(queue_url),
          receipt_handle: Some(handle),
        )
      case sqs.delete_message(client, req) {
        Ok(_) -> Ok(Nil)
        Error(e) -> Error("sqs.delete_message: " <> string.inspect(e))
      }
    }
  }
}

fn short_id(m: sqs.Message) -> String {
  case m.message_id {
    Some(id) -> id
    None -> "<no-id>"
  }
}

fn env_or_die(name: String) -> String {
  case os_getenv(name) {
    Ok(v) if v != "" -> v
    _ -> panic as { "missing required env var: " <> name }
  }
}

@external(erlang, "smoke_ffi", "get_env")
fn os_getenv(name: String) -> Result(String, Nil)
