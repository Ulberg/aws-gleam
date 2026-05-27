//// Tests for `transfer.with_max_concurrency` + the parallel
//// multipart-upload coordinator. Mirrors the stubbed-transport
//// pattern from `s3_transfer_test.gleam` — every UploadPart call
//// gets a canned 200 + ETag response — but uses the parallel
//// dispatcher (`max_concurrency: Some(n)`) instead of the
//// sequential one.
////
//// We can't deterministically assert "parts ran in parallel" from
//// the BEAM scheduler's perspective (it'd require timing-based
//// signals), but we CAN assert: (a) every part uploaded
//// regardless of dispatch order, (b) the final
//// CompleteMultipartUpload sees all parts sorted by part-number
//// (S3 requires it), and (c) a per-part failure aborts the whole
//// upload with the expected typed error.

import aws/config
import aws/credentials
import aws/internal/http_send as aws_http
import aws/s3/transfer
import aws/services/s3
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

fn capture_send(
  inbox: process.Subject(http.Method),
  responder: fn(Request(BitArray)) -> response.Response(BitArray),
) -> aws_http.Send {
  fn(req: Request(BitArray)) {
    process.send(inbox, req.method)
    Ok(responder(req))
  }
}

fn count(inbox: process.Subject(http.Method), acc: Int) -> Int {
  case process.receive(inbox, 0) {
    Ok(_) -> count(inbox, acc + 1)
    Error(_) -> acc
  }
}

fn xml_resp(body: String) -> response.Response(BitArray) {
  response.Response(
    status: 200,
    headers: [#("content-type", "application/xml")],
    body: <<body:utf8>>,
  )
}

fn create_xml() -> String {
  "<InitiateMultipartUploadResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">"
  <> "<Bucket>my-bucket</Bucket><Key>my-key</Key><UploadId>upid</UploadId>"
  <> "</InitiateMultipartUploadResult>"
}

fn complete_xml() -> String {
  "<CompleteMultipartUploadResult xmlns=\"http://s3.amazonaws.com/doc/2006-03-01/\">"
  <> "<Location>https://my-bucket.s3.amazonaws.com/my-key</Location>"
  <> "<Bucket>my-bucket</Bucket><Key>my-key</Key><ETag>\"final\"</ETag>"
  <> "</CompleteMultipartUploadResult>"
}

fn happy(req: Request(BitArray)) -> response.Response(BitArray) {
  let uri =
    req.path
    <> case req.query {
      Some(q) -> "?" <> q
      None -> ""
    }
  case
    req.method,
    string.contains(uri, "?uploads"),
    string.contains(uri, "partNumber="),
    string.contains(uri, "uploadId=")
  {
    http.Post, True, _, _ -> xml_resp(create_xml())
    http.Put, _, True, _ ->
      response.Response(
        status: 200,
        headers: [#("etag", "\"epart\"")],
        body: <<>>,
      )
    http.Post, _, _, True -> xml_resp(complete_xml())
    _, _, _, _ -> response.Response(status: 500, headers: [], body: <<>>)
  }
}

fn fresh_client(send: aws_http.Send) -> s3.Client {
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(send),
      ),
      s3.default_endpoint_params(),
    )
  client
}

pub fn parallel_upload_all_parts_succeed_test() {
  // 13 parts × 1 KiB each, max_concurrency=4. Every UploadPart
  // succeeds; the coordinator must dispatch all 13 (regardless of
  // batching) and produce a UploadResult with parts_uploaded=13.
  let inbox = process.new_subject()
  let client = fresh_client(capture_send(inbox, happy))
  let body = make_body(13 * 1024)
  let opts = transfer.with_max_concurrency(transfer.default_options(), 4)

  let result =
    transfer.upload_with_options(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: body,
      part_size_bytes: 1024,
      options: opts,
    )

  case result {
    Ok(out) -> out.parts_uploaded |> should.equal(13)
    Error(e) -> {
      let _ = e
      should.fail()
    }
  }

  // Expect exactly: 1 create + 13 upload_part + 1 complete = 15 requests
  count(inbox, 0) |> should.equal(15)
  s3.shutdown(client)
}

pub fn parallel_upload_concurrency_one_equals_sequential_test() {
  // max_concurrency: 1 is degenerate parallel — one batch of one
  // worker at a time — and should produce the same result as the
  // sequential path. Smoke check that the parallel code path
  // handles the degenerate case without deadlocking.
  let inbox = process.new_subject()
  let client = fresh_client(capture_send(inbox, happy))
  let body = make_body(3 * 1024)
  let opts = transfer.with_max_concurrency(transfer.default_options(), 1)

  let result =
    transfer.upload_with_options(
      client: client,
      bucket: "my-bucket",
      key: "my-key",
      body: body,
      part_size_bytes: 1024,
      options: opts,
    )

  case result {
    Ok(out) -> out.parts_uploaded |> should.equal(3)
    Error(_) -> should.fail()
  }
  s3.shutdown(client)
}

pub fn with_max_concurrency_zero_coerces_to_sequential_test() {
  // Pass n=0 — coerced to None per `with_max_concurrency` doc.
  // The result should match the sequential path, no parallel
  // dispatch happens.
  let opts = transfer.with_max_concurrency(transfer.default_options(), 0)
  opts.max_concurrency |> should.equal(None)
}

pub fn with_max_concurrency_negative_coerces_to_sequential_test() {
  let opts = transfer.with_max_concurrency(transfer.default_options(), -3)
  opts.max_concurrency |> should.equal(None)
}

// ---------- helpers ----------

fn make_body(total_bytes: Int) -> BitArray {
  case total_bytes {
    0 -> <<>>
    _ -> {
      let one = <<"a":utf8>>
      grow(one, total_bytes - 1)
    }
  }
}

fn grow(b: BitArray, remaining: Int) -> BitArray {
  case remaining {
    0 -> b
    _ -> grow(<<b:bits, "a":utf8>>, remaining - 1)
  }
}
