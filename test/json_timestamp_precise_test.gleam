//// Tests for `json_timestamp.decoder_precise` and the conversion
//// helpers around the `Timestamp` type. Verifies the
//// nanosecond-precision wire decoding for the AWS service APIs
//// that ship fractional epoch-seconds Float values
//// (CloudWatch, EventBridge, metric APIs).

import aws/internal/codec/json_timestamp.{
  type Timestamp, Timestamp, decoder_precise, encode_epoch_seconds,
  int_to_timestamp, timestamp_to_int,
}
import gleam/dynamic
import gleam/dynamic/decode
import gleam/json
import gleeunit/should

fn decode_value(
  d: dynamic.Dynamic,
) -> Result(Timestamp, List(decode.DecodeError)) {
  decode.run(d, decoder_precise())
}

pub fn decoder_precise_int_wire_form_test() {
  decode_value(dynamic.int(1_700_000_000))
  |> should.equal(Ok(Timestamp(seconds: 1_700_000_000, nanoseconds: 0)))
}

pub fn decoder_precise_preserves_fractional_seconds_test() {
  // 1700000000.5 ⇒ 1700000000 seconds + 500ms = 500_000_000 ns.
  decode_value(dynamic.float(1_700_000_000.5))
  |> should.equal(
    Ok(Timestamp(seconds: 1_700_000_000, nanoseconds: 500_000_000)),
  )
}

pub fn decoder_precise_handles_quarter_second_test() {
  // 1700000000.25 ⇒ 250_000_000 ns.
  decode_value(dynamic.float(1_700_000_000.25))
  |> should.equal(
    Ok(Timestamp(seconds: 1_700_000_000, nanoseconds: 250_000_000)),
  )
}

pub fn decoder_precise_zero_fractional_keeps_zero_nanos_test() {
  decode_value(dynamic.float(1_700_000_000.0))
  |> should.equal(Ok(Timestamp(seconds: 1_700_000_000, nanoseconds: 0)))
}

pub fn int_to_timestamp_roundtrip_test() {
  let t = int_to_timestamp(1_700_000_000)
  t |> should.equal(Timestamp(seconds: 1_700_000_000, nanoseconds: 0))
  timestamp_to_int(t) |> should.equal(1_700_000_000)
}

pub fn timestamp_to_int_drops_nanoseconds_test() {
  Timestamp(seconds: 1_700_000_000, nanoseconds: 999_999_999)
  |> timestamp_to_int
  |> should.equal(1_700_000_000)
}

pub fn encode_epoch_seconds_zero_nanos_emits_int_test() {
  // When the Timestamp has no sub-second precision we keep the wire
  // form Int so the encoder is byte-for-byte compatible with the
  // existing `json.int` path the codegen emits today — opt-in to
  // precision must never change the wire bytes of values that
  // didn't have sub-second info to begin with.
  Timestamp(seconds: 1_700_000_000, nanoseconds: 0)
  |> encode_epoch_seconds
  |> json.to_string
  |> should.equal("1700000000")
}

pub fn encode_epoch_seconds_with_nanos_emits_float_test() {
  // Half-second nano carries `1700000000.5` on the wire — the
  // canonical Smithy epoch-seconds form for fractional values.
  Timestamp(seconds: 1_700_000_000, nanoseconds: 500_000_000)
  |> encode_epoch_seconds
  |> json.to_string
  |> should.equal("1700000000.5")
}

pub fn encode_epoch_seconds_milli_nanos_test() {
  // 123ms → `.123`. Spot-checks that the encoder doesn't lose
  // precision on the common millisecond range CloudWatch ships.
  Timestamp(seconds: 1_700_000_000, nanoseconds: 123_000_000)
  |> encode_epoch_seconds
  |> json.to_string
  |> should.equal("1700000000.123")
}

pub fn encode_epoch_seconds_roundtrips_through_decoder_test() {
  // Encode then decode preserves the original value exactly for the
  // common millisecond-precision case — the round-trip is what the
  // codegen flip relies on.
  let original = Timestamp(seconds: 1_700_000_000, nanoseconds: 250_000_000)
  let wire = original |> encode_epoch_seconds |> json.to_string
  let assert Ok(decoded) = json.parse(wire, decoder_precise())
  decoded |> should.equal(original)
}
