//// awsJson special-float helpers.
////
//// The AWS JSON protocols (`awsJson1_0`, `awsJson1_1`, plus other
//// JSON-family wire formats) encode IEEE 754 specials as JSON strings:
//// `"NaN"`, `"Infinity"`, `"-Infinity"`. Plain JSON numbers cover
//// every finite float.
////
//// **Why a wrapper type instead of raw `Float`:** Erlang's `float()`
//// type cannot hold NaN or Infinity. `0.0/0.0` raises `badarith`;
//// `binary_to_term` rejects the IEEE 754 NaN bit pattern with
//// `badarg`; `<<F/float>>` bit-syntax matching refuses to bind such
//// values. So a faithful representation of an awsJson Float field on
//// the BEAM target requires an explicit sum type — there's no way to
//// pack `NaN` into an Erlang float. Rust's `f64` happens to support
//// these natively, which is why aws-sdk-rust gets away with `Option<f64>`.
////
//// Matches `aws-sdk-rust`'s `aws-smithy-types::Number::SpecialFloat`
//// — same three string spellings, same case-sensitivity.

import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}

/// Tagged float that can faithfully round-trip every IEEE 754 value
/// reachable from JSON in the awsJson protocols.
///
/// Generated code uses this for any field whose Smithy shape is
/// `smithy.api#Float` or `smithy.api#Double`. User construction:
///
///   FloatValue(1.5)
///   NaN
///   PosInfinity
///   NegInfinity
pub type SmithyFloat {
  FloatValue(Float)
  NaN
  PosInfinity
  NegInfinity
}

/// Encode a `SmithyFloat` as a JSON value. Finite values become JSON
/// numbers; the three IEEE 754 specials become JSON strings, matching
/// the awsJson wire spec.
pub fn encode(v: SmithyFloat) -> Json {
  case v {
    FloatValue(f) -> json.float(f)
    NaN -> json.string("NaN")
    PosInfinity -> json.string("Infinity")
    NegInfinity -> json.string("-Infinity")
  }
}

/// Decoder for a `SmithyFloat`. Accepts plain JSON numbers and the
/// three special-float strings.
pub fn decoder() -> Decoder(SmithyFloat) {
  decode.one_of(decode.map(decode.float, FloatValue), [from_string()])
}

fn from_string() -> Decoder(SmithyFloat) {
  decode.then(decode.string, fn(s) {
    case s {
      "NaN" -> decode.success(NaN)
      "Infinity" -> decode.success(PosInfinity)
      "-Infinity" -> decode.success(NegInfinity)
      _ -> decode.failure(NaN, "expected NaN / Infinity / -Infinity")
    }
  })
}
