//// JSON-side timestamp decoder. AWS protocol families disagree on
//// the wire shape of `@timestamp` fields:
////
////   * awsJson1_0 / awsJson1_1 default: epoch-seconds number
////     (Int OR Float — services like KitchenSinkOperation send doubles)
////   * restJson1 / restXml default: ISO 8601 string
////   * Any protocol with `@timestampFormat("http-date")`: HTTP-date string
////
//// We never know which the server will send for a given field —
//// fractional-second tests in particular surface Floats where the
//// schema declares an Int member. Returning `option.None` on decode
//// failure would mask data; instead we accept all three forms and
//// coerce to `Int` (epoch seconds).

import gleam/dynamic/decode

@external(erlang, "aws_ffi", "parse_iso8601")
fn parse_iso8601_ffi(t: String) -> Result(Int, Nil)

@external(erlang, "aws_ffi", "parse_http_date")
fn parse_http_date_ffi(t: String) -> Result(Int, Nil)

@external(erlang, "erlang", "trunc")
fn float_to_int(f: Float) -> Int

/// Decode `Int | Float | String` into epoch seconds. Falls back to 0
/// when none of the forms match, which matches `gleam/dynamic`'s
/// default `decode.failure` payload style and lets the caller surface
/// the decode failure via the standard `Decoder` machinery rather than
/// crashing on bad data.
pub fn decoder() -> decode.Decoder(Int) {
  decode.one_of(decode.int, [
    decode.then(decode.float, fn(f) { decode.success(float_to_int(f)) }),
    decode.then(decode.string, fn(s) {
      case parse_iso8601_ffi(s) {
        Ok(n) -> decode.success(n)
        Error(_) ->
          case parse_http_date_ffi(s) {
            Ok(n) -> decode.success(n)
            Error(_) -> decode.failure(0, "timestamp: unrecognised wire form")
          }
      }
    }),
  ])
}
