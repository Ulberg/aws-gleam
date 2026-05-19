//// Tests for `aws_streaming_ffi:collect_stream/2`. Drives the
//// message-collection loop by sending synthetic stream messages to
//// the test process and asserting the loop assembles them in the
//// expected order. The real `request_streaming/4` is exercised via
//// integration tests against LocalStack / live AWS — those need an
//// actual HTTP server and live in a separate suite.

import gleam/bit_array
import gleam/erlang/atom.{type Atom}
import gleam/list
import gleeunit/should

pub fn collect_stream_assembles_three_chunks_in_order_test() {
  let req_id = make_request_id()
  send_stream_start(req_id, [])
  send_stream_chunk(req_id, <<"hello ":utf8>>)
  send_stream_chunk(req_id, <<"streaming ":utf8>>)
  send_stream_chunk(req_id, <<"world":utf8>>)
  send_stream_end(req_id, [])
  case collect_stream(req_id, 1000) {
    StreamOk(status: status, headers: _h, chunks: chunks) -> {
      status |> should.equal(200)
      chunks
      |> list.length
      |> should.equal(3)
      // Re-assembly via concat must yield the original bytes in the
      // original order; this pins the on-wire chunk ordering.
      chunks
      |> bit_array.concat
      |> bit_array.to_string
      |> should.equal(Ok("hello streaming world"))
    }
    StreamError(_) -> panic as "expected ok stream"
  }
}

pub fn collect_stream_pins_response_headers_from_start_test() {
  // stream_start delivers response headers; stream_end may carry
  // trailers. The collector concatenates them in the conceptual
  // header-list order (trailers tail-appended) so both reach the
  // caller. Test pins both presences.
  let req_id = make_request_id()
  send_stream_start(req_id, [
    #(<<"content-type":utf8>>, <<"application/octet-stream":utf8>>),
  ])
  send_stream_chunk(req_id, <<"x":utf8>>)
  send_stream_end(req_id, [
    #(<<"x-trailer":utf8>>, <<"present":utf8>>),
  ])
  case collect_stream(req_id, 1000) {
    StreamOk(headers: headers, ..) -> {
      list.length(headers) |> should.equal(2)
    }
    StreamError(_) -> panic as "expected ok stream"
  }
}

pub fn collect_stream_passes_through_non_streamed_error_response_test() {
  // OTP only streams 2xx; 4xx / 5xx arrive as a sync-mode `Result`
  // tuple. The collector surfaces that as a single-chunk response
  // so callers see the same `{status, headers, chunks}` shape
  // either way.
  let req_id = make_request_id()
  send_sync_response(
    req_id,
    404,
    [#(<<"content-type":utf8>>, <<"text/plain":utf8>>)],
    <<"not found":utf8>>,
  )
  case collect_stream(req_id, 1000) {
    StreamOk(status: status, chunks: chunks, headers: _h) -> {
      status |> should.equal(404)
      list.length(chunks) |> should.equal(1)
      chunks
      |> bit_array.concat
      |> bit_array.to_string
      |> should.equal(Ok("not found"))
    }
    StreamError(_) -> panic as "expected ok shape, got error"
  }
}

pub fn collect_stream_surfaces_transport_error_test() {
  let req_id = make_request_id()
  send_stream_error(req_id, atom.create("response_timeout"))
  case collect_stream(req_id, 1000) {
    StreamOk(..) -> panic as "expected error, got ok"
    StreamError(reason) -> {
      // `normalise_error` collapses `timeout` to `response_timeout`;
      // we expect the same atom back here.
      atom.to_string(reason) |> should.equal("response_timeout")
    }
  }
}

pub fn collect_stream_times_out_when_no_message_arrives_test() {
  // Pass a short timeout (50ms) and don't send any messages; the
  // loop must surface `timeout` so callers don't block forever
  // when the server vanishes mid-response.
  let req_id = make_request_id()
  case collect_stream(req_id, 50) {
    StreamOk(..) -> panic as "expected error, got ok"
    StreamError(reason) -> {
      atom.to_string(reason) |> should.equal("timeout")
    }
  }
}

// ---------- FFI bindings + test harness wiring ----------
//
// `collect_stream/2` returns `{ok, {Status, Headers, Chunks}}` or
// `{error, Reason}`. We model both arms as one Gleam tag-union with
// labelled fields so tests read straightforwardly.

pub type StreamResult {
  StreamOk(
    status: Int,
    headers: List(#(BitArray, BitArray)),
    chunks: List(BitArray),
  )
  StreamError(reason: Atom)
}

@external(erlang, "aws_streaming_ffi", "collect_stream")
fn ffi_collect_stream(
  request_id: Int,
  timeout: Int,
) -> Result(#(Int, List(#(BitArray, BitArray)), List(BitArray)), Atom)

fn collect_stream(request_id: Int, timeout: Int) -> StreamResult {
  case ffi_collect_stream(request_id, timeout) {
    Ok(#(status, headers, chunks)) ->
      StreamOk(status: status, headers: headers, chunks: chunks)
    Error(reason) -> StreamError(reason: reason)
  }
}

// Each test gets a fresh request id (a monotonically-increasing int)
// so messages from one test's `self() ! {http, {Id, ...}}` can't be
// picked up by a later test's `collect_stream` loop — even though
// gleeunit runs tests in fresh processes, defensive isolation is
// cheap and pins the loop's RequestId-matching contract.
@external(erlang, "erlang", "unique_integer")
fn unique_int() -> Int

fn make_request_id() -> Int {
  unique_int()
}

@external(erlang, "aws_test_support_ffi", "send_stream_start")
fn send_stream_start(
  request_id: Int,
  headers: List(#(BitArray, BitArray)),
) -> Nil

@external(erlang, "aws_test_support_ffi", "send_stream_chunk")
fn send_stream_chunk(request_id: Int, chunk: BitArray) -> Nil

@external(erlang, "aws_test_support_ffi", "send_stream_end")
fn send_stream_end(
  request_id: Int,
  trailers: List(#(BitArray, BitArray)),
) -> Nil

@external(erlang, "aws_test_support_ffi", "send_sync_response")
fn send_sync_response(
  request_id: Int,
  status: Int,
  headers: List(#(BitArray, BitArray)),
  body: BitArray,
) -> Nil

@external(erlang, "aws_test_support_ffi", "send_stream_error")
fn send_stream_error(request_id: Int, reason: Atom) -> Nil
