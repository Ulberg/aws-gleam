//// Regression test: S3 `GetObject` responses carry their object
//// metadata in HTTP headers (Content-Type, ETag, Last-Modified,
//// x-amz-version-id, etc.), and the response body IS the object
//// payload (`@httpPayload` on a `@streaming` blob). The codegen's
//// payload-bearing parse emitter must extract header members the
//// same way the no-payload path does — otherwise every caller of
//// `get_object` sees `option.None` for every metadata field and
//// has to drop down to raw `httpc`.

import aws/services/s3
import aws/streaming
import gleam/dict
import gleam/option
import gleeunit/should

fn fake_headers() -> dict.Dict(String, String) {
  dict.from_list([
    #("content-type", "image/jpeg"),
    #("content-length", "12345"),
    #("etag", "\"abc123\""),
    #("accept-ranges", "bytes"),
    #("x-amz-version-id", "v-99"),
    #("x-amz-server-side-encryption", "AES256"),
  ])
}

pub fn parse_get_object_response_extracts_headers_test() {
  let body = <<"fake-jpeg-bytes":utf8>>
  let assert Ok(out) = s3.parse_get_object_response(200, fake_headers(), body)

  out.content_type |> should.equal(option.Some("image/jpeg"))
  out.content_length |> should.equal(option.Some(12_345))
  out.e_tag |> should.equal(option.Some("\"abc123\""))
  out.accept_ranges |> should.equal(option.Some("bytes"))
  out.version_id |> should.equal(option.Some("v-99"))
  out.server_side_encryption
  |> should.equal(option.Some(s3.ServerSideEncryptionAes256))
}

pub fn parse_get_object_response_payload_still_works_test() {
  // Don't regress the payload-binding behaviour while wiring headers.
  let body = <<"object-payload":utf8>>
  let assert Ok(out) = s3.parse_get_object_response(200, fake_headers(), body)
  let assert option.Some(payload) = out.body
  streaming.to_bit_array(payload) |> should.equal(body)
}
