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
import gleam/json

@external(erlang, "aws_ffi", "parse_iso8601")
fn parse_iso8601_ffi(t: String) -> Result(Int, Nil)

@external(erlang, "aws_ffi", "parse_http_date")
fn parse_http_date_ffi(t: String) -> Result(Int, Nil)

/// `2024-01-02T03:04:05Z`. Inverse of `parse_iso8601_ffi`.
@external(erlang, "aws_ffi", "format_iso8601")
pub fn format_iso8601(seconds: Int) -> String

/// `Tue, 29 Apr 2014 18:30:38 GMT`. Used by
/// `@timestampFormat("http-date")` body fields and headers.
@external(erlang, "aws_ffi", "format_http_date")
pub fn format_http_date(seconds: Int) -> String

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

/// Higher-precision timestamp value with nanosecond resolution.
/// AWS services like CloudWatch, EventBridge, and metric APIs ship
/// `Float` epoch-seconds wire values that carry sub-second
/// precision; the existing `Int` decoder truncates them. Callers
/// who need the precision use `Timestamp` end-to-end:
///
/// ```gleam
/// import aws/internal/codec/json_timestamp.{type Timestamp, Timestamp}
///
/// let t = Timestamp(seconds: 1700000000, nanoseconds: 123_000_000)
/// // ⇒ 2023-11-14T22:13:20.123 UTC
/// ```
///
/// `nanoseconds` is bounded to `[0, 999_999_999]` by convention;
/// callers normalising from a Float wire value get this for free
/// (see `decoder_precise`).
pub type Timestamp {
  Timestamp(seconds: Int, nanoseconds: Int)
}

/// Decode an AWS timestamp wire value into a `Timestamp` that
/// preserves sub-second precision when present.
///
/// * `Int` → `Timestamp(seconds: n, nanoseconds: 0)`
/// * `Float` → fractional seconds extracted via floor + scaling
///   to nanoseconds. Negative timestamps (pre-1970) handled by
///   normalising the fractional remainder so `nanoseconds` is
///   always in `[0, 999_999_999]`.
/// * `String` → ISO 8601 / HTTP-date, parsed with second-level
///   precision today (fractional ISO timestamps would need an
///   FFI extension; tracked separately).
pub fn decoder_precise() -> decode.Decoder(Timestamp) {
  decode.one_of(
    decode.then(decode.int, fn(n) {
      decode.success(Timestamp(seconds: n, nanoseconds: 0))
    }),
    [
      decode.then(decode.float, fn(f) { decode.success(float_to_timestamp(f)) }),
      decode.then(decode.string, fn(s) {
        case parse_iso8601_ffi(s) {
          Ok(n) -> decode.success(Timestamp(seconds: n, nanoseconds: 0))
          Error(_) ->
            case parse_http_date_ffi(s) {
              Ok(n) -> decode.success(Timestamp(seconds: n, nanoseconds: 0))
              Error(_) ->
                decode.failure(
                  Timestamp(seconds: 0, nanoseconds: 0),
                  "timestamp: unrecognised wire form",
                )
            }
        }
      }),
    ],
  )
}

/// Convert `Timestamp` back to integer epoch seconds, dropping the
/// nanosecond component. Symmetric with `int_to_timestamp` and
/// useful when callers want to bridge to the existing `Int` API.
pub fn timestamp_to_int(t: Timestamp) -> Int {
  t.seconds
}

/// Promote an `Int` epoch seconds value to a `Timestamp` with
/// zero nanoseconds. Symmetric with `timestamp_to_int`.
pub fn int_to_timestamp(seconds: Int) -> Timestamp {
  Timestamp(seconds: seconds, nanoseconds: 0)
}

/// Encode a `Timestamp` as a JSON epoch-seconds number. When
/// `nanoseconds == 0` we emit a JSON Int (`1700000000`) so the
/// wire bytes match the existing `json.int` path the codegen
/// uses for the `Int` API — flipping a member to precise must
/// not perturb the wire form for callers who never set
/// nanoseconds. When `nanoseconds > 0` we emit a JSON Float
/// (`1700000000.5`) so the fractional component reaches the
/// server intact.
pub fn encode_epoch_seconds(t: Timestamp) -> json.Json {
  case t.nanoseconds {
    0 -> json.int(t.seconds)
    _ ->
      json.float(
        int_to_float(t.seconds)
        +. int_to_float(t.nanoseconds)
        /. 1_000_000_000.0,
      )
  }
}

fn float_to_timestamp(f: Float) -> Timestamp {
  // Floor-divide the float into integer seconds + fractional
  // remainder. `truncate` would round-toward-zero, breaking
  // negative timestamps where the fractional part should
  // negative-extend; we use floor instead so `nanoseconds` stays
  // in [0, 999_999_999] without sign games.
  let seconds = float_floor(f)
  let fractional = f -. int_to_float(seconds)
  let nanos = float_to_int(fractional *. 1_000_000_000.0)
  // Clamp to the valid range — floating-point error can push
  // 0.999999999 up to 1.0e9 + epsilon in pathological cases.
  case nanos < 0 {
    True -> Timestamp(seconds: seconds, nanoseconds: 0)
    False ->
      case nanos > 999_999_999 {
        True ->
          Timestamp(seconds: seconds + 1, nanoseconds: nanos - 1_000_000_000)
        False -> Timestamp(seconds: seconds, nanoseconds: nanos)
      }
  }
}

@external(erlang, "math", "floor")
fn float_floor_native(f: Float) -> Float

fn float_floor(f: Float) -> Int {
  float_to_int(float_floor_native(f))
}

@external(erlang, "erlang", "float")
fn int_to_float(n: Int) -> Float
