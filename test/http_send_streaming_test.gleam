//// Tests for `http_send.lift_to_streaming` — the v1 forward-
//// compatibility lift that turns a buffered `Send` into a
//// `StreamingSend`. Until the transport rewrite lands, every
//// streaming response is a single buffered chunk; these tests
//// pin that invariant so call sites that switch over today
//// don't break when the real chunked transport replaces the lift
//// under the hood.

import aws/internal/http_send
import aws/streaming
import gleam/bit_array
import gleam/http.{Get}
import gleam/http/request
import gleam/http/response
import gleeunit/should

fn stub_send_ok(
  body: BitArray,
) -> fn(request.Request(BitArray)) ->
  Result(response.Response(BitArray), http_send.HttpError) {
  fn(_req) {
    Ok(response.Response(
      status: 200,
      headers: [#("content-type", "application/octet-stream")],
      body: body,
    ))
  }
}

fn stub_send_err() -> fn(request.Request(BitArray)) ->
  Result(response.Response(BitArray), http_send.HttpError) {
  fn(_req) { Error(http_send.Timeout) }
}

fn fixture_request() -> request.Request(BitArray) {
  request.new()
  |> request.set_method(Get)
  |> request.set_host("example.com")
  |> request.set_path("/")
  |> request.set_body(<<>>)
}

pub fn lift_to_streaming_wraps_response_body_test() {
  let payload = <<"hello, streaming world":utf8>>
  let streaming_send = http_send.lift_to_streaming(stub_send_ok(payload))
  let assert Ok(resp) = streaming_send(fixture_request())
  resp.status |> should.equal(200)
  resp.headers
  |> should.equal([#("content-type", "application/octet-stream")])
  streaming.to_bit_array(resp.body) |> should.equal(payload)
  streaming.byte_size(resp.body) |> should.equal(bit_array.byte_size(payload))
}

pub fn lift_to_streaming_propagates_errors_test() {
  let streaming_send = http_send.lift_to_streaming(stub_send_err())
  let assert Error(err) = streaming_send(fixture_request())
  err |> should.equal(http_send.Timeout)
}

pub fn lift_to_streaming_empty_body_is_empty_streaming_body_test() {
  let streaming_send = http_send.lift_to_streaming(stub_send_ok(<<>>))
  let assert Ok(resp) = streaming_send(fixture_request())
  streaming.is_empty(resp.body) |> should.be_true
}
