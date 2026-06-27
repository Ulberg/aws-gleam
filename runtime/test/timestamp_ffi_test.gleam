//// Regression tests for the timestamp-parsing FFI boundary (issue #26).
//// Server-controlled response timestamps and credential `Expiration`
//// fields are untrusted input; a malformed or out-of-range value must
//// return a typed failure rather than crash the consumer's process.

import aws/internal/codec/json_timestamp
import aws/internal/datetime
import gleeunit/should

/// An out-of-range ISO 8601 timestamp (month 13, day 39, 25:61:61)
/// passes the regex shape check but would crash
/// `calendar:datetime_to_gregorian_seconds/1`. It must surface as
/// `Error(Nil)` instead.
pub fn datetime_parse_iso8601_out_of_range_test() {
  datetime.parse_iso8601("2024-13-39T25:61:61Z")
  |> should.equal(Error(Nil))
}

/// A structurally bogus string never matches the regex and must also
/// be a clean `Error(Nil)`.
pub fn datetime_parse_iso8601_bogus_test() {
  datetime.parse_iso8601("not a timestamp")
  |> should.equal(Error(Nil))
}

/// The json_timestamp ISO 8601 wrapper must not crash on out-of-range
/// digits either.
pub fn json_timestamp_parse_iso8601_out_of_range_test() {
  json_timestamp.parse_iso8601("2024-13-39T25:61:61Z")
  |> should.equal(Error(Nil))
}

pub fn json_timestamp_parse_iso8601_bogus_test() {
  json_timestamp.parse_iso8601("nope")
  |> should.equal(Error(Nil))
}

/// HTTP-date with a valid month name but out-of-range day/time passes
/// the shape + month-name checks, then would crash the gregorian-seconds
/// conversion. Must return `Error(Nil)`.
pub fn json_timestamp_parse_http_date_out_of_range_test() {
  json_timestamp.parse_http_date("Mon, 39 Jan 2024 25:61:61 GMT")
  |> should.equal(Error(Nil))
}

pub fn json_timestamp_parse_http_date_bogus_test() {
  json_timestamp.parse_http_date("definitely not a date")
  |> should.equal(Error(Nil))
}
