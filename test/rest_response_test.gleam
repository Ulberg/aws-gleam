//// Tests for the response-side header extraction helpers in
//// `aws/internal/codec/rest`. These are what generated `parse_<op>_
//// response` functions call when binding `@httpHeader` output members.
////
//// The runtime hands the parse function a `dict.Dict(String, String)`
//// of lowercased header keys. Helpers must therefore lowercase the
//// caller-supplied name as well — generators emit the wire spelling
//// verbatim, so `"ETag"` and `"etag"` must both resolve.

import aws/internal/codec/json_timestamp
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

// ---------- @httpChecksumRequired ----------

pub fn with_content_md5_header_sets_base64_md5_of_body_test() {
  // The Smithy `@httpChecksumRequired` trait directs the SDK to add
  // `Content-MD5: base64(md5(body))` to the outgoing request. The
  // expected pair below mirrors the upstream restJson1
  // protocol-test corpus (`RestJsonHttpChecksumRequired`) — the
  // fixture's `body` field is pretty-printed for readability but the
  // wire-level body our codegen emits is compact, so we hash the
  // compact form here. The SDK runtime does the same: the JSON body
  // assembled by `build_<op>_request` has no extraneous whitespace.
  let body = <<"{\"foo\":\"base64 encoded md5 checksum\"}":utf8>>
  let starting = dict.from_list([#("Content-Type", "application/json")])

  let with_md5 = rest.with_content_md5_header(starting, body)
  dict.get(with_md5, "Content-MD5")
  |> should.equal(Ok("iB0/3YSo7maijL0IGOgA9g=="))
  // Existing headers are preserved.
  dict.get(with_md5, "Content-Type")
  |> should.equal(Ok("application/json"))
}

pub fn with_content_md5_header_handles_empty_body_test() {
  // RFC 1321: md5("") = d41d8cd98f00b204e9800998ecf8427e —
  // base64 = "1B2M2Y8AsgTpgAmY7PhCfg==". The helper must produce
  // a deterministic header for the empty-body case too.
  let with_md5 = rest.with_content_md5_header(dict.new(), <<>>)
  dict.get(with_md5, "Content-MD5")
  |> should.equal(Ok("1B2M2Y8AsgTpgAmY7PhCfg=="))
}

pub fn with_content_md5_header_overwrites_existing_value_test() {
  // If a previous step set Content-MD5 (e.g. caller-supplied), the
  // checksum helper MUST win — the wire contract says the SDK is
  // responsible for the value and stale ones lead to 400s.
  let starting =
    dict.from_list([#("Content-MD5", "stale=="), #("X-Other", "keep")])
  let with_md5 = rest.with_content_md5_header(starting, <<>>)
  dict.get(with_md5, "Content-MD5")
  |> should.equal(Ok("1B2M2Y8AsgTpgAmY7PhCfg=="))
  dict.get(with_md5, "X-Other") |> should.equal(Ok("keep"))
}

// ---------- enum_header ----------

type FakeEnum {
  Alpha
  Beta
}

fn fake_enum_from_wire(s: String) -> Result(FakeEnum, String) {
  case s {
    "alpha" -> Ok(Alpha)
    "beta" -> Ok(Beta)
    other -> Error("unknown enum value: " <> other)
  }
}

pub fn enum_header_decodes_known_wire_value_test() {
  let h = dict.from_list([#("x-enum", "alpha")])
  rest.enum_header(h, "X-Enum", fake_enum_from_wire)
  |> should.equal(Some(Alpha))
}

pub fn enum_header_returns_none_for_missing_header_test() {
  rest.enum_header(headers(), "X-Missing", fake_enum_from_wire)
  |> should.equal(None)
}

pub fn enum_header_returns_none_for_unknown_wire_value_test() {
  // Forgiving contract: unknown enum wire values land as `None`,
  // not as a crash. Matches int/bool header semantics — the parse
  // never blows up because a server added a new variant.
  let h = dict.from_list([#("x-enum", "gamma")])
  rest.enum_header(h, "X-Enum", fake_enum_from_wire)
  |> should.equal(None)
}

// ---------- timestamp headers ----------

pub fn http_date_header_decodes_rfc7231_timestamp_test() {
  // S3 GetObject's Last-Modified header ships in HTTP-date form
  // per the Smithy core default for @httpHeader bindings.
  let h = dict.from_list([#("last-modified", "Thu, 01 Jan 1970 00:00:42 GMT")])
  rest.http_date_header(h, "Last-Modified")
  |> should.equal(Some(json_timestamp.Timestamp(seconds: 42, nanoseconds: 0)))
}

pub fn http_date_header_returns_none_for_missing_test() {
  rest.http_date_header(headers(), "Last-Modified")
  |> should.equal(None)
}

pub fn http_date_header_returns_none_for_unparseable_test() {
  // Forgiving contract: garbage strings land as None, not a crash.
  let h = dict.from_list([#("last-modified", "not-a-date")])
  rest.http_date_header(h, "Last-Modified")
  |> should.equal(None)
}

pub fn iso8601_header_decodes_date_time_format_test() {
  let h = dict.from_list([#("x-amz-when", "1970-01-01T00:00:42Z")])
  rest.iso8601_header(h, "X-Amz-When")
  |> should.equal(Some(json_timestamp.Timestamp(seconds: 42, nanoseconds: 0)))
}

pub fn epoch_seconds_header_decodes_integer_test() {
  let h = dict.from_list([#("x-amz-when", "1234567890")])
  rest.epoch_seconds_header(h, "X-Amz-When")
  |> should.equal(
    Some(json_timestamp.Timestamp(seconds: 1_234_567_890, nanoseconds: 0)),
  )
}

pub fn epoch_seconds_header_returns_none_for_non_integer_test() {
  let h = dict.from_list([#("x-amz-when", "1234.5")])
  rest.epoch_seconds_header(h, "X-Amz-When")
  |> should.equal(None)
}
