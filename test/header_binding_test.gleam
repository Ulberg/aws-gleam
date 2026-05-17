//// Tests for the response header binding the restXml codegen emits.
//// Drives `parse_head_object_response` directly with a synthetic
//// (headers, body) pair and asserts the resulting `HeadObjectOutput`
//// carries the values from the headers in the right typed fields.

import aws/services/s3
import gleam/dict
import gleam/option.{None, Some}
import gleeunit/should

pub fn parse_head_object_response_binds_headers_test() {
  let headers =
    dict.from_list([
      #("etag", "\"abc-123\""),
      #("content-length", "5120"),
      #("content-type", "image/png"),
      #("x-amz-server-side-encryption-bucket-key-enabled", "true"),
      #("accept-ranges", "bytes"),
    ])
  let body = <<>>
  let assert Ok(out) = s3.parse_head_object_response(200, headers, body)

  out.e_tag |> should.equal(Some("\"abc-123\""))
  out.content_length |> should.equal(Some(5120))
  out.content_type |> should.equal(Some("image/png"))
  out.bucket_key_enabled |> should.equal(Some(True))
  out.accept_ranges |> should.equal(Some("bytes"))
}

pub fn parse_head_object_response_returns_none_for_missing_headers_test() {
  // When the server omits a header, the corresponding output field must
  // be `None` rather than panicking or returning `Some("")`.
  let assert Ok(out) = s3.parse_head_object_response(200, dict.new(), <<>>)
  out.e_tag |> should.equal(None)
  out.content_length |> should.equal(None)
}

pub fn parse_head_object_response_is_case_insensitive_test() {
  // Headers arrive lowercased from the runtime; the binding lookup
  // must therefore match regardless of the wire spelling we emit
  // (e.g. "ETag" vs "etag").
  let headers = dict.from_list([#("etag", "\"V1\"")])
  let assert Ok(out) = s3.parse_head_object_response(200, headers, <<>>)
  out.e_tag |> should.equal(Some("\"V1\""))
}
