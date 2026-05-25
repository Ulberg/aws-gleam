//// Tests for the typed Lambda response encoders. Field order in the
//// expected JSON matches what the encoders emit (gleam_json preserves
//// insertion order), and mirrors the proxy-integration / partial-batch
//// shapes Lambda expects back.

import aws/lambda/response
import gleam/dict
import gleam/json
import gleeunit/should

pub fn proxy_response_default_encodes_test() {
  response.proxy_response(200, "hello")
  |> response.proxy_to_json
  |> json.to_string
  |> should.equal(
    "{\"statusCode\":200,\"headers\":{},\"body\":\"hello\",\"isBase64Encoded\":false}",
  )
}

pub fn proxy_response_with_headers_and_cookies_encodes_test() {
  response.ProxyResponse(
    status_code: 201,
    headers: dict.from_list([#("content-type", "application/json")]),
    cookies: ["session=abc"],
    body: "{}",
    is_base64_encoded: True,
  )
  |> response.proxy_to_json
  |> json.to_string
  |> should.equal(
    "{\"cookies\":[\"session=abc\"],\"statusCode\":201,\"headers\":{\"content-type\":\"application/json\"},\"body\":\"{}\",\"isBase64Encoded\":true}",
  )
}

pub fn sqs_batch_response_encodes_failures_test() {
  response.SqsBatchResponse(batch_item_failures: ["msg-1", "msg-2"])
  |> response.sqs_batch_to_json
  |> json.to_string
  |> should.equal(
    "{\"batchItemFailures\":[{\"itemIdentifier\":\"msg-1\"},{\"itemIdentifier\":\"msg-2\"}]}",
  )
}

pub fn sqs_batch_response_empty_reports_full_success_test() {
  response.SqsBatchResponse(batch_item_failures: [])
  |> response.sqs_batch_to_json
  |> json.to_string
  |> should.equal("{\"batchItemFailures\":[]}")
}
