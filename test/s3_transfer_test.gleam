//// Tests for `aws/s3/transfer.upload`. Drives the multipart
//// coordination logic by stubbing `s3.Client`'s HTTP send with a
//// scripted responder keyed on the request method + URI shape:
////
////   POST  /key?uploads          → CreateMultipartUpload
////   PUT   /key?partNumber=N&... → UploadPart (N)
////   POST  /key?uploadId=...     → CompleteMultipartUpload
////   DELETE /key?uploadId=...    → AbortMultipartUpload
////
//// Each test verifies (a) the helper returns the expected typed
//// result and (b) the right sequence of HTTP calls was made by
//// reading back the captured request list. The S3 wire format
//// goes through the generated `s3` module unchanged — these tests
//// only assert the coordination layer.

import aws/credentials
import aws/internal/http_send as aws_http
import aws/s3/transfer
import aws/services/s3
import aws/streaming
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None}
import gleam/string
import gleeunit/should

// ---------- request capture + scripted responder ----------

type Captured {
  Captured(method: http.Method, uri: String)
}

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

/// Build a request-recording send that dispatches on method + the
/// presence/absence of multipart query-string markers. Each call is
/// pushed onto `captured` so tests can assert on the sequence; the
/// responder picks the right canned response for the op shape.
///
/// `responder` receives the parsed Captured and returns the
/// response — tests script per-call failure modes (e.g. fail the
/// second `upload_part`) by inspecting the captured method + uri.
fn scripted_send(
  captured: process.Subject(Captured),
  responder: fn(Captured) ->
    Result(response.Response(BitArray), aws_http.HttpError),
) -> aws_http.Send {
  fn(req: Request(BitArray)) {
    let uri =
      req.path
      <> case req.query {
        option.Some(q) -> "?" <> q
        option.None -> ""
      }
    let cap = Captured(method: req.method, uri: uri)
    process.send(captured, cap)
    responder(cap)
  }
}

fn drain(
  captured: process.Subject(Captured),
  acc: List(Captured),
) -> List(Captured) {
  case process.receive(captured, 0) {
    Ok(c) -> drain(captured, [c, ..acc])
    Error(_) -> list.reverse(acc)
  }
}

fn xml_response(status: Int, body: String) -> response.Response(BitArray) {
  response.Response(
    status: status,
    headers: [#("content-type", "application/xml")],
    body: <<body:utf8>>,
  )
}

fn upload_part_response(etag: String) -> response.Response(BitArray) {
  response.Response(status: 200, headers: [#("etag", etag)], body: <<>>)
}

fn create_resp_body() -> String {
  "<InitiateMultipartUploadResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">"
  <> "<Bucket>my-bucket</Bucket>"
  <> "<Key>my-key</Key>"
  <> "<UploadId>upid-42</UploadId>"
  <> "</InitiateMultipartUploadResult>"
}

fn complete_resp_body() -> String {
  "<CompleteMultipartUploadResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">"
  <> "<Location>https://my-bucket.s3.amazonaws.com/my-key</Location>"
  <> "<Bucket>my-bucket</Bucket>"
  <> "<Key>my-key</Key>"
  <> "<ETag>\"final-etag\"</ETag>"
  <> "</CompleteMultipartUploadResult>"
}

/// Standard happy-path responder: every operation succeeds.
fn happy_responder(
  cap: Captured,
) -> Result(response.Response(BitArray), aws_http.HttpError) {
  Ok(canned_for(cap))
}

fn canned_for(cap: Captured) -> response.Response(BitArray) {
  case
    cap.method,
    string.contains(cap.uri, "?uploads"),
    string.contains(cap.uri, "partNumber="),
    string.contains(cap.uri, "uploadId=")
  {
    http.Post, True, _, _ -> xml_response(200, create_resp_body())
    http.Put, _, True, _ -> upload_part_response("\"etag-part\"")
    http.Post, _, _, True -> xml_response(200, complete_resp_body())
    http.Delete, _, _, True ->
      response.Response(status: 204, headers: [], body: <<>>)
    _, _, _, _ -> response.Response(status: 500, headers: [], body: <<>>)
  }
}

fn fresh_client(send: aws_http.Send) -> s3.Client {
  s3.new(region: "us-east-1")
  |> s3.with_credentials_provider(static_credentials())
  |> s3.with_http_send(send)
}

// ---------- tests ----------

pub fn upload_empty_body_returns_empty_body_error_test() {
  // Empty bodies are rejected before any HTTP work — S3 itself
  // would reject them with EntityTooSmall on Complete; we
  // short-circuit so the bucket never sees the create.
  let captured = process.new_subject()
  let send = scripted_send(captured, happy_responder)
  let client = fresh_client(send)

  transfer.upload(
    client: client,
    bucket: "my-bucket",
    key: "my-key",
    body: <<>>,
    part_size_bytes: transfer.default_part_size_bytes,
  )
  |> should.equal(Error(transfer.EmptyBody))

  // No HTTP traffic should have happened.
  drain(captured, []) |> list.length |> should.equal(0)
}

pub fn upload_succeeds_single_part_test() {
  // Body fits in one part. Sequence: create → upload_part(1) → complete.
  let captured = process.new_subject()
  let send = scripted_send(captured, happy_responder)
  let client = fresh_client(send)

  let result =
    transfer.upload(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: <<"small payload":utf8>>,
      part_size_bytes: 5_242_880,
    )

  case result {
    Ok(out) -> {
      out.upload_id |> should.equal("upid-42")
      out.parts_uploaded |> should.equal(1)
    }
    Error(e) -> panic as { "expected Ok, got: " <> describe_error(e) }
  }

  let calls = drain(captured, [])
  list.length(calls) |> should.equal(3)
  // Verify the operation sequence: create, upload_part, complete.
  case calls {
    [c1, c2, c3] -> {
      string.contains(c1.uri, "?uploads") |> should.equal(True)
      string.contains(c2.uri, "partNumber=1") |> should.equal(True)
      string.contains(c3.uri, "uploadId=upid-42") |> should.equal(True)
    }
    _ -> panic as "expected exactly 3 captured calls"
  }
}

pub fn upload_succeeds_multi_part_test() {
  // 12 bytes / 5-byte parts = 3 parts (5 + 5 + 2). Sequence:
  // create → upload_part(1) → upload_part(2) → upload_part(3) → complete.
  let captured = process.new_subject()
  let send = scripted_send(captured, happy_responder)
  let client = fresh_client(send)

  let result =
    transfer.upload(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: <<"hello world!":utf8>>,
      part_size_bytes: 5,
    )

  case result {
    Ok(out) -> out.parts_uploaded |> should.equal(3)
    Error(e) -> panic as { "expected Ok, got: " <> describe_error(e) }
  }

  let calls = drain(captured, [])
  // create + 3 uploads + complete = 5 HTTP calls.
  list.length(calls) |> should.equal(5)
  // Part numbers must increment in order.
  case calls {
    [_create, p1, p2, p3, _complete] -> {
      string.contains(p1.uri, "partNumber=1") |> should.equal(True)
      string.contains(p2.uri, "partNumber=2") |> should.equal(True)
      string.contains(p3.uri, "partNumber=3") |> should.equal(True)
    }
    _ -> panic as "expected 5 calls (create + 3 parts + complete)"
  }
}

pub fn upload_aborts_on_part_failure_test() {
  // Fail the second UploadPart with a 403 (AccessDenied — a typical
  // non-retryable client error). The helper must surface
  // UploadPartFailed(2, _) AND issue an AbortMultipartUpload so the
  // bucket doesn't keep a dangling upload. We use 4xx (not 5xx)
  // because the runtime retries 5xx by default and this test wants
  // a clean one-attempt failure path — retry semantics live in
  // their own suite.
  let captured = process.new_subject()
  let responder = fn(cap: Captured) -> Result(
    response.Response(BitArray),
    aws_http.HttpError,
  ) {
    case string.contains(cap.uri, "partNumber=2") {
      True -> Ok(response.Response(status: 403, headers: [], body: <<>>))
      False -> Ok(canned_for(cap))
    }
  }
  let send = scripted_send(captured, responder)
  let client = fresh_client(send)

  let result =
    transfer.upload(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: <<"hello world!":utf8>>,
      part_size_bytes: 5,
    )

  case result {
    Error(transfer.UploadPartFailed(part_number: 2, ..)) -> Nil
    other ->
      panic as {
        "expected UploadPartFailed(2, _), got: " <> describe_result(other)
      }
  }

  // create + part1 + part2(fail) + abort = 4 calls; no complete.
  let calls = drain(captured, [])
  list.length(calls) |> should.equal(4)
  let last = case list.last(calls) {
    Ok(c) -> c
    Error(_) -> panic as "no calls captured"
  }
  case last.method {
    http.Delete -> Nil
    _ ->
      panic as "expected the cleanup call to be a DELETE (AbortMultipartUpload)"
  }
}

pub fn upload_aborts_on_complete_failure_test() {
  // The complete step fails with 403 — abort still runs. Same 4xx
  // rationale as above: this test is about cleanup behaviour, not
  // about retry policy.
  let captured = process.new_subject()
  let responder = fn(cap: Captured) -> Result(
    response.Response(BitArray),
    aws_http.HttpError,
  ) {
    case
      cap.method,
      string.contains(cap.uri, "uploadId="),
      string.contains(cap.uri, "partNumber=")
    {
      http.Post, True, False ->
        Ok(response.Response(status: 403, headers: [], body: <<>>))
      _, _, _ -> Ok(canned_for(cap))
    }
  }
  let send = scripted_send(captured, responder)
  let client = fresh_client(send)

  let result =
    transfer.upload(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: <<"small payload":utf8>>,
      part_size_bytes: 5_242_880,
    )

  case result {
    Error(transfer.CompleteFailed(_)) -> Nil
    other ->
      panic as { "expected CompleteFailed, got: " <> describe_result(other) }
  }

  // create + part + complete(fail) + abort = 4 calls.
  let calls = drain(captured, [])
  list.length(calls) |> should.equal(4)
  let last = case list.last(calls) {
    Ok(c) -> c
    Error(_) -> panic as "no calls captured"
  }
  case last.method {
    http.Delete -> Nil
    _ ->
      panic as "expected the cleanup call to be a DELETE (AbortMultipartUpload)"
  }
}

// ---------- part_size_for tests ----------
//
// Pure-function tests on the part-size scaler; no HTTP needed.
// 50 GB / 10000 = 5 MiB exactly, so anything <= 50 GB returns the
// default. Past 50 GB the helper scales to keep part count <= 10000.

pub fn part_size_for_zero_returns_default_test() {
  transfer.part_size_for(0) |> should.equal(transfer.default_part_size_bytes)
}

pub fn part_size_for_negative_returns_default_test() {
  transfer.part_size_for(-1)
  |> should.equal(transfer.default_part_size_bytes)
}

pub fn part_size_for_small_body_returns_default_test() {
  // 1 MB body → default (1 MB / 10000 = 100 bytes, far below 5 MiB).
  transfer.part_size_for(1_000_000)
  |> should.equal(transfer.default_part_size_bytes)
}

pub fn part_size_for_at_50gb_boundary_returns_default_test() {
  // 10_000 * 5_242_880 = 52_428_800_000 bytes — the largest total
  // that still needs exactly 5 MiB parts.
  transfer.part_size_for(52_428_800_000)
  |> should.equal(transfer.default_part_size_bytes)
}

pub fn part_size_for_above_50gb_scales_up_test() {
  // 60 GB total → ceil(60_000_000_000 / 10000) = 6_000_000 bytes.
  // Larger than the 5 MiB default, so the helper returns the
  // computed value verbatim.
  transfer.part_size_for(60_000_000_000)
  |> should.equal(6_000_000)
}

pub fn part_size_for_5tib_returns_under_5gib_test() {
  // 5 TiB / 10_000 ≈ 549 MiB. The helper must stay under the 5 GiB
  // per-part cap; pinning ~549 MB anchors that.
  let result = transfer.part_size_for(5_497_558_138_880)
  // Result should be ceil(5_497_558_138_880 / 10000) = 549_755_813_888 / 1000
  // = exact divide: 5_497_558_138_880 / 10000 = 549_755_813.888, so the
  // ceiling is 549_755_814.
  result |> should.equal(549_755_814)
}

// ---------- upload_from_stream tests ----------

pub fn upload_from_stream_empty_body_returns_empty_body_error_test() {
  // Streaming variant must also short-circuit before touching HTTP.
  let captured = process.new_subject()
  let send = scripted_send(captured, happy_responder)
  let client = fresh_client(send)

  transfer.upload_from_stream(
    client: client,
    bucket: "my-bucket",
    key: "my-key",
    body: streaming.empty(),
    part_size_bytes: transfer.default_part_size_bytes,
  )
  |> should.equal(Error(transfer.EmptyBody))

  drain(captured, []) |> list.length |> should.equal(0)
}

pub fn upload_from_stream_rechunks_to_part_size_test() {
  // Body arrives as tiny chunks but the wire-side parts must
  // follow part_size_bytes. 6 chunks of 2 bytes + part_size 5 →
  // parts of 5, 5, 2 (= 3 parts).
  let captured = process.new_subject()
  let send = scripted_send(captured, happy_responder)
  let client = fresh_client(send)

  let body =
    streaming.from_chunks([
      <<"he":utf8>>,
      <<"ll":utf8>>,
      <<"o ":utf8>>,
      <<"wo":utf8>>,
      <<"rl":utf8>>,
      <<"d!":utf8>>,
    ])

  let result =
    transfer.upload_from_stream(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: body,
      part_size_bytes: 5,
    )

  case result {
    Ok(out) -> out.parts_uploaded |> should.equal(3)
    Error(e) -> panic as { "expected Ok, got: " <> describe_error(e) }
  }

  let calls = drain(captured, [])
  // create + 3 parts + complete = 5 calls.
  list.length(calls) |> should.equal(5)
  case calls {
    [_create, p1, p2, p3, _complete] -> {
      string.contains(p1.uri, "partNumber=1") |> should.equal(True)
      string.contains(p2.uri, "partNumber=2") |> should.equal(True)
      string.contains(p3.uri, "partNumber=3") |> should.equal(True)
    }
    _ -> panic as "expected 5 calls (create + 3 parts + complete)"
  }
}

pub fn upload_from_stream_single_chunk_body_path_test() {
  // Buffered StreamingBody body (single chunk) goes through the
  // same rechunker — proves the Buffered branch of to_chunks
  // collapses cleanly. Body = 13 bytes, part_size = 5_242_880 →
  // exactly one part.
  let captured = process.new_subject()
  let send = scripted_send(captured, happy_responder)
  let client = fresh_client(send)

  let body = streaming.from_bit_array(<<"small payload":utf8>>)

  let result =
    transfer.upload_from_stream(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: body,
      part_size_bytes: 5_242_880,
    )

  case result {
    Ok(out) -> out.parts_uploaded |> should.equal(1)
    Error(e) -> panic as { "expected Ok, got: " <> describe_error(e) }
  }

  // create + 1 part + complete = 3 calls.
  drain(captured, []) |> list.length |> should.equal(3)
}

// ---------- helpers ----------

fn describe_result(r: Result(transfer.UploadResult, transfer.Error)) -> String {
  case r {
    Ok(u) -> "Ok(" <> u.upload_id <> ")"
    Error(e) -> describe_error(e)
  }
}

fn describe_error(e: transfer.Error) -> String {
  case e {
    transfer.CreateFailed(_) -> "CreateFailed(_)"
    transfer.UploadPartFailed(part_number: n, ..) ->
      "UploadPartFailed(" <> int_to_string(n) <> ", _)"
    transfer.CompleteFailed(_) -> "CompleteFailed(_)"
    transfer.MissingUploadId -> "MissingUploadId"
    transfer.EmptyBody -> "EmptyBody"
  }
}

@external(erlang, "erlang", "integer_to_binary")
fn int_to_string(n: Int) -> String
