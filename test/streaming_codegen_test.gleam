//// Codegen-side opt-in to `streaming.StreamingBody` for Smithy
//// `@streaming` blob shapes.
////
//// The generated service modules previously surfaced any `@blob`
//// member — streaming or not — as `BitArray`. M13 part 2 flips
//// the codegen so a blob shape carrying `smithy.api#streaming`
//// is typed as `streaming.StreamingBody` in the public input /
//// output records, while the wire bytes round-trip exactly the
//// same as before (the runtime helpers materialise the buffered
//// payload in / out).
////
//// These tests pin the type-level flip end-to-end via the
//// `aws.protocoltests.restjson#StreamingTraits` operation —
//// the same shape the protocol-test corpus exercises. They run
//// against the generated `restjson1` protocol-test module
//// (regen produces `src/aws/services/protocoltests/restjson1.gleam`).

import aws/services/protocoltests/restjson1
import aws/streaming
import gleam/dict
import gleam/option.{None, Some}
import gleeunit/should

pub fn streaming_traits_input_accepts_streaming_body_test() {
  // The `blob` field on `StreamingTraitsInputOutput` is typed as
  // `Option(streaming.StreamingBody)`. A buffered body roundtrips
  // through the request builder byte-for-byte.
  let body = streaming.from_bit_array(<<"blobby blob blob":utf8>>)
  let input =
    restjson1.StreamingTraitsInputOutput(blob: Some(body), foo: Some("Foo"))

  let #(method, path, headers, wire) =
    restjson1.build_streaming_traits_request(input)

  method |> should.equal("POST")
  path |> should.equal("/StreamingTraits")
  // The X-Foo header carries the `foo` member per the @httpHeader
  // binding on this op; the streaming-blob flip mustn't disturb
  // the header path.
  headers
  |> dict.get("X-Foo")
  |> should.equal(Ok("Foo"))
  wire |> should.equal(<<"blobby blob blob":utf8>>)
}

pub fn streaming_traits_response_yields_streaming_body_test() {
  // The `parse_<op>_response` helper for an op with a
  // @streaming output blob now wraps the HTTP body in
  // `streaming.from_bit_array`, so callers always read the
  // member as `StreamingBody`.
  let body = <<"server-said-hi":utf8>>
  let assert Ok(out) =
    restjson1.parse_streaming_traits_response(200, dict.new(), body)
  let assert Some(payload) = out.blob
  payload |> streaming.to_bit_array |> should.equal(body)
}

pub fn empty_streaming_body_renders_zero_bytes_test() {
  // Building a request with an empty streaming body produces a
  // zero-length wire body — matches the corpus's
  // `RestJsonStreamingTraitsWithNoBlobBody` case.
  let input =
    restjson1.StreamingTraitsInputOutput(
      blob: Some(streaming.empty()),
      foo: None,
    )
  let #(_method, _path, _headers, wire) =
    restjson1.build_streaming_traits_request(input)
  wire |> should.equal(<<>>)
}
