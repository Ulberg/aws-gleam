//// Tests for the ISO 8601 → unix-seconds parser. Coverage is narrow
//// because the production callers (IMDS / STS / SSO responses) only
//// emit a couple of canonical shapes.

import aws/internal/datetime
import gleeunit/should

pub fn parses_canonical_z_form_test() {
  // Equivalent unix seconds checked against Python's
  // `int(datetime(2023,11,30,15,30,0,tzinfo=UTC).timestamp())`.
  datetime.parse_iso8601("2023-11-30T15:30:00Z")
  |> should.equal(Ok(1_701_358_200))
}

pub fn parses_fractional_seconds_test() {
  // Fractional seconds are truncated (we round down to the second).
  datetime.parse_iso8601("2023-11-30T15:30:00.123Z")
  |> should.equal(Ok(1_701_358_200))
}

pub fn parses_epoch_test() {
  datetime.parse_iso8601("1970-01-01T00:00:00Z")
  |> should.equal(Ok(0))
}

pub fn rejects_offset_form_test() {
  // We don't accept +00:00 offsets — every AWS response uses Z.
  datetime.parse_iso8601("2023-11-30T15:30:00+00:00")
  |> should.be_error
}

pub fn rejects_garbage_test() {
  datetime.parse_iso8601("not a timestamp")
  |> should.be_error
}
