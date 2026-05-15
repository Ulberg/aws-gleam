//// Small helpers for the timestamp formats AWS uses in metadata responses.
//// Implementation lives in `aws_ffi.erl` so we can lean on Erlang's
//// `calendar` module rather than reimplementing gregorian-seconds arithmetic
//// in Gleam.

/// Parse an AWS-style ISO 8601 UTC timestamp into unix seconds.
///
/// Accepts both `"2023-11-30T15:30:00Z"` and the millisecond-fractional
/// variant `"2023-11-30T15:30:00.000Z"`. Any other shape returns `Error(Nil)`.
@external(erlang, "aws_ffi", "parse_iso8601")
pub fn parse_iso8601(timestamp: String) -> Result(Int, Nil)
