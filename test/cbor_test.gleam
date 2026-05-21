//// Tests for the CBOR (RFC 8949) codec used by rpcv2Cbor.
////
//// Reference values come from RFC 8949 Appendix A — the canonical
//// CBOR test vectors. They cover a small subset of AWS rpcv2Cbor
//// wire shapes: text strings, byte strings, ints, floats, lists,
//// maps, booleans, null.

import aws/internal/codec/cbor.{
  type Value, CBool, CBytes, CFloat, CInt, CList, CMap, CNull, CString,
}
import gleam/list
import gleeunit/should

fn round_trip(v: Value) -> Result(Value, String) {
  cbor.decode_value(cbor.encode(v))
}

pub fn encode_small_unsigned_int_test() {
  cbor.encode(CInt(0)) |> should.equal(<<0x00>>)
  cbor.encode(CInt(10)) |> should.equal(<<0x0A>>)
  cbor.encode(CInt(23)) |> should.equal(<<0x17>>)
}

pub fn encode_one_byte_unsigned_int_test() {
  // RFC 8949 §A: 24 → 18 18
  cbor.encode(CInt(24)) |> should.equal(<<0x18, 0x18>>)
  cbor.encode(CInt(100)) |> should.equal(<<0x18, 0x64>>)
}

pub fn encode_two_byte_unsigned_int_test() {
  // 1000 → 19 03 e8
  cbor.encode(CInt(1000)) |> should.equal(<<0x19, 0x03, 0xE8>>)
}

pub fn encode_negative_int_test() {
  cbor.encode(CInt(-1)) |> should.equal(<<0x20>>)
  cbor.encode(CInt(-10)) |> should.equal(<<0x29>>)
  cbor.encode(CInt(-100)) |> should.equal(<<0x38, 0x63>>)
}

pub fn encode_text_string_test() {
  cbor.encode(CString("")) |> should.equal(<<0x60>>)
  cbor.encode(CString("a")) |> should.equal(<<0x61, 0x61>>)
  cbor.encode(CString("IETF")) |> should.equal(<<0x64, 0x49, 0x45, 0x54, 0x46>>)
}

pub fn encode_byte_string_test() {
  cbor.encode(CBytes(<<>>)) |> should.equal(<<0x40>>)
  cbor.encode(CBytes(<<0x01, 0x02, 0x03>>))
  |> should.equal(<<0x43, 0x01, 0x02, 0x03>>)
}

pub fn encode_booleans_and_null_test() {
  cbor.encode(CBool(False)) |> should.equal(<<0xF4>>)
  cbor.encode(CBool(True)) |> should.equal(<<0xF5>>)
  cbor.encode(CNull) |> should.equal(<<0xF6>>)
}

pub fn encode_empty_list_and_map_test() {
  cbor.encode(CList([])) |> should.equal(<<0x80>>)
  cbor.encode(CMap([])) |> should.equal(<<0xA0>>)
}

pub fn encode_simple_list_test() {
  cbor.encode(CList([CInt(1), CInt(2), CInt(3)]))
  |> should.equal(<<0x83, 0x01, 0x02, 0x03>>)
}

pub fn encode_map_sorts_keys_lexicographically_test() {
  // Canonical CBOR requires lexicographic key order on encode.
  // "a" (0x61) < "b" (0x62) so the {"b":2,"a":1} input encodes
  // with "a" first.
  let m = CMap([#(CString("b"), CInt(2)), #(CString("a"), CInt(1))])
  cbor.encode(m)
  |> should.equal(<<0xA2, 0x61, 0x61, 0x01, 0x61, 0x62, 0x02>>)
}

pub fn decode_roundtrips_through_encoder_test() {
  // Canonical-CBOR key order is bytewise on the encoded key
  // (head byte + UTF-8 bytes). Shorter encoded keys sort before
  // longer ones with the same first prefix — so "int" (3 chars,
  // head 0x63) sorts before "bool" (4 chars, head 0x64) even
  // though 'i' > 'b' lexically.
  let v =
    CMap([
      #(CString("int"), CInt(-42)),
      #(CString("bool"), CBool(True)),
      #(CString("list"), CList([CInt(1), CNull, CFloat(1.5)])),
      #(CString("text"), CString("hello")),
      #(CString("bytes"), CBytes(<<0xDE, 0xAD>>)),
    ])
  round_trip(v) |> should.equal(Ok(v))
}

pub fn decode_handles_two_byte_length_test() {
  cbor.decode_value(<<0x19, 0x01, 0x00>>) |> should.equal(Ok(CInt(256)))
}

pub fn decode_rejects_truncated_input_test() {
  case cbor.decode_value(<<0x18>>) {
    Error(_) -> Nil
    Ok(_) -> should.fail()
  }
}

pub fn decode_rejects_invalid_utf8_in_text_string_test() {
  // Text string of length 2 with bytes that aren't valid UTF-8
  // (0xC0 0x80 is the overlong NUL encoding, rejected by RFC
  // 3629). The decoder distinguishes byte strings (major 2)
  // from text strings (major 3) and only validates UTF-8 for
  // the latter.
  case cbor.decode_value(<<0x62, 0xC0, 0x80>>) {
    Error(_) -> Nil
    Ok(_) -> should.fail()
  }
}

pub fn round_trip_float64_special_values_test() {
  // Float round-trip preserves the bit pattern through encode +
  // decode. NaN / Inf are documented as float64 simple-value 27;
  // the encoder always emits 0xFB regardless of value.
  let pos = CFloat(123.456)
  cbor.decode_value(cbor.encode(pos)) |> should.equal(Ok(pos))
  let zero = CFloat(0.0)
  cbor.decode_value(cbor.encode(zero)) |> should.equal(Ok(zero))
  let neg = CFloat(-3.14159)
  cbor.decode_value(cbor.encode(neg)) |> should.equal(Ok(neg))
}

pub fn round_trip_int_boundaries_test() {
  // 2^16 - 1 (3-byte head), 2^16 (5-byte head), 2^32 - 1
  // (5-byte head), 2^32 (9-byte head). All round-trip cleanly.
  let cases = [65_535, 65_536, 4_294_967_295, 4_294_967_296]
  list.each(cases, fn(n) {
    cbor.decode_value(cbor.encode(CInt(n))) |> should.equal(Ok(CInt(n)))
  })
}
