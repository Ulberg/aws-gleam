//// Tests for the response-side header extraction helpers in
//// `aws/internal/codec/rest`. These are what generated `parse_<op>_
//// response` functions call when binding `@httpHeader` output members.
////
//// The runtime hands the parse function a `dict.Dict(String, String)`
//// of lowercased header keys. Helpers must therefore lowercase the
//// caller-supplied name as well — generators emit the wire spelling
//// verbatim, so `"ETag"` and `"etag"` must both resolve.

import aws/internal/codec/rest
import gleam/dict
import gleam/option.{None, Some}
import gleeunit/should

fn headers() -> dict.Dict(String, String) {
  dict.from_list([
    #("etag", "\"abc\""),
    #("content-length", "1024"),
    #("x-amz-server-side-encryption-bucket-key-enabled", "true"),
    #("x-amz-some-float", "1.5"),
    #("x-amz-int-as-float", "2"),
    #("x-amz-bad-int", "not-a-number"),
  ])
}

pub fn string_header_returns_value_test() {
  rest.string_header(headers(), "ETag")
  |> should.equal(Some("\"abc\""))
}

pub fn string_header_is_case_insensitive_test() {
  rest.string_header(headers(), "Content-Length")
  |> should.equal(Some("1024"))
  rest.string_header(headers(), "content-length")
  |> should.equal(Some("1024"))
}

pub fn string_header_returns_none_when_absent_test() {
  rest.string_header(headers(), "Missing")
  |> should.equal(None)
}

pub fn int_header_parses_integers_test() {
  rest.int_header(headers(), "Content-Length")
  |> should.equal(Some(1024))
}

pub fn int_header_returns_none_for_bad_input_test() {
  rest.int_header(headers(), "X-Amz-Bad-Int")
  |> should.equal(None)
}

pub fn bool_header_parses_true_and_false_test() {
  let h =
    dict.from_list([
      #("flag", "true"),
      #("other", "False"),
    ])
  rest.bool_header(h, "flag") |> should.equal(Some(True))
  rest.bool_header(h, "Other") |> should.equal(Some(False))
}

pub fn bool_header_returns_none_for_non_boolean_test() {
  let h = dict.from_list([#("flag", "maybe")])
  rest.bool_header(h, "flag") |> should.equal(None)
}

pub fn float_header_parses_decimals_test() {
  rest.float_header(headers(), "X-Amz-Some-Float")
  |> should.equal(Some(1.5))
}

pub fn float_header_accepts_integer_literals_test() {
  // Smithy `Float` shapes wire-format as ints when the value is whole;
  // the helper must accept both forms so generated code doesn't lose
  // values when servers omit a trailing `.0`.
  rest.float_header(headers(), "X-Amz-Int-As-Float")
  |> should.equal(Some(2.0))
}
