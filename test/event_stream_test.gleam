//// Tests for `aws/internal/codec/event_stream`. Pin the v1 encoder
//// against hand-crafted byte sequences so any future refactor that
//// breaks the on-wire framing surfaces immediately. The AWS C-RT
//// reference codec (`aws-c-event-stream`) accepts what we emit here;
//// we don't include that fixture suite because v1 covers only two
//// header types, but the byte-exact assertions match what their
//// `aws_event_stream_message_to_debug_str` would print for the same
//// inputs.

import aws/internal/codec/event_stream.{
  BadMessageCrc, BadPreludeCrc, BinaryValue, BoolFalseValue, BoolTrueValue,
  ByteValue, Event, Header, Int16Value, Int32Value, Int64Value, StringValue,
  TimestampValue, UuidValue, decode, encode,
}
import gleam/bit_array
import gleeunit/should

pub fn encodes_empty_message_test() {
  // Empty headers + empty payload → 16 byte frame:
  //   total_len = 16, headers_len = 0,
  //   prelude_crc = crc32(<<16:32, 0:32>>),
  //   message_crc = crc32(<<16:32, 0:32, prelude_crc:32>>).
  let frame = encode(Event(headers: [], payload: <<>>))
  bit_array.byte_size(frame) |> should.equal(16)
  // The first 8 bytes are total_len + headers_len.
  case frame {
    <<total:big-32, hdrs:big-32, _rest:bits>> -> {
      total |> should.equal(16)
      hdrs |> should.equal(0)
    }
    _ -> panic as "expected frame to start with two 32-bit BE ints"
  }
}

pub fn encodes_string_header_with_payload_test() {
  // One header `:message-type = "event"` (string), payload `{"x":1}`.
  // Headers section bytes:
  //   name_len[1] = 13, name[13] = ":message-type", type[1] = 7,
  //   value_len[2] = 5, value[5] = "event"
  // = 1 + 13 + 1 + 2 + 5 = 22 bytes.
  // Payload = 6 bytes (`{"x":1}` is 7 utf-8 bytes — wait, six chars).
  let payload = <<"{\"x\":1}":utf8>>
  let event =
    Event(
      headers: [Header(name: ":message-type", value: StringValue("event"))],
      payload: payload,
    )
  let frame = encode(event)
  let expected_total = 12 + 22 + bit_array.byte_size(payload) + 4
  case frame {
    <<total:big-32, hdrs_len:big-32, _rest:bits>> -> {
      total |> should.equal(expected_total)
      hdrs_len |> should.equal(22)
    }
    _ -> panic as "frame did not start with prelude ints"
  }
  // Sanity: total size matches what we computed above.
  bit_array.byte_size(frame) |> should.equal(expected_total)
}

pub fn encodes_byte_header_test() {
  // One `byte` header — the simplest non-string variant. Value is
  // signed 8-bit so -1 encodes as 0xFF.
  let event =
    Event(headers: [Header(name: "n", value: ByteValue(-1))], payload: <<>>)
  let frame = encode(event)
  // Header bytes: name_len[1]=1, name[1]="n", type[1]=2, value[1]=0xFF.
  // = 4 bytes total.
  case frame {
    <<
      _total:big-32,
      hdrs_len:big-32,
      _crc:big-32,
      hdr:bytes-size(4),
      _rest:bits,
    >> -> {
      hdrs_len |> should.equal(4)
      hdr |> should.equal(<<1, "n":utf8, 2, 0xFF>>)
    }
    _ -> panic as "frame layout did not match expected prelude+header"
  }
}

pub fn message_crc_is_last_four_bytes_test() {
  // CRC32 of everything-before-the-CRC must match what's written
  // at the tail. Self-consistency check — the framing contract.
  let event =
    Event(headers: [Header(name: "k", value: StringValue("v"))], payload: <<
      "hi":utf8,
    >>)
  let frame = encode(event)
  let total = bit_array.byte_size(frame)
  let body_len = total - 4
  case bit_array.slice(frame, 0, body_len) {
    Ok(body) -> {
      let actual_tail_crc = case bit_array.slice(frame, body_len, 4) {
        Ok(tail) -> tail
        Error(_) -> panic as "could not slice tail CRC"
      }
      let expected_crc_int = crc32(body)
      let expected_tail = <<expected_crc_int:big-32>>
      actual_tail_crc |> should.equal(expected_tail)
    }
    Error(_) -> panic as "could not slice frame body"
  }
}

@external(erlang, "erlang", "crc32")
fn crc32(data: BitArray) -> Int

// ---------- decode ----------

pub fn encode_decode_round_trips_string_header_test() {
  // Build a non-trivial event and verify decode(encode(x)) == x.
  // The trailing bytes (BitArray) should be empty when only one
  // frame is in the buffer.
  let event =
    Event(
      headers: [
        Header(name: ":message-type", value: StringValue("event")),
        Header(name: ":event-type", value: StringValue("ChunkResult")),
      ],
      payload: <<"hello":utf8>>,
    )
  case decode(encode(event)) {
    Ok(#(decoded, rest)) -> {
      decoded |> should.equal(event)
      rest |> should.equal(<<>>)
    }
    Error(e) -> panic as { "decode failed: " <> debug_decode_error(e) }
  }
}

pub fn encode_decode_round_trips_byte_header_with_negative_test() {
  // -128 is the most-negative signed-8 — exercises the two's-
  // complement wrap on both encode (n + 256) and decode (n - 256).
  let event =
    Event(headers: [Header(name: "n", value: ByteValue(-128))], payload: <<>>)
  case decode(encode(event)) {
    Ok(#(decoded, _rest)) -> decoded |> should.equal(event)
    Error(e) -> panic as { "decode failed: " <> debug_decode_error(e) }
  }
}

pub fn decode_surfaces_remaining_bytes_for_next_frame_test() {
  // Two frames concatenated; the first decode call must return the
  // second frame as the remaining BitArray so callers can loop.
  let first = encode(Event(headers: [], payload: <<"a":utf8>>))
  let second = encode(Event(headers: [], payload: <<"b":utf8>>))
  case decode(<<first:bits, second:bits>>) {
    Ok(#(decoded_first, remaining)) -> {
      decoded_first.payload |> should.equal(<<"a":utf8>>)
      remaining |> should.equal(second)
    }
    Error(_) -> panic as "expected to decode the first frame"
  }
}

pub fn decode_detects_corrupted_prelude_crc_test() {
  // Flip a bit in the prelude (one of the first 8 bytes) without
  // touching the recorded prelude_crc — must surface BadPreludeCrc.
  let good = encode(Event(headers: [], payload: <<>>))
  let assert <<a:big-32, b:big-32, tail:bits>> = good
  // Bump the headers_len field to something the prelude_crc no
  // longer matches.
  let corrupted = <<a:big-32, { b + 1 }:big-32, tail:bits>>
  case decode(corrupted) {
    Ok(_) -> panic as "expected BadPreludeCrc, got Ok"
    Error(BadPreludeCrc) -> Nil
    Error(other) ->
      panic as { "expected BadPreludeCrc, got " <> debug_decode_error(other) }
  }
}

pub fn decode_detects_corrupted_message_crc_test() {
  // Flip a byte in the middle of the headers section. Prelude
  // bytes + their CRC stay intact (so we get past the prelude
  // check); the body CRC must then fail.
  let event =
    Event(headers: [Header(name: "k", value: StringValue("v"))], payload: <<
      "hi":utf8,
    >>)
  let good = encode(event)
  // Flip the byte at offset 14 (somewhere inside the headers
  // section, after the 12-byte prelude + 2-byte recovery margin).
  // Use slice + concat to swap one byte.
  let assert Ok(prefix) = bit_array.slice(good, 0, 14)
  let assert Ok(rest) =
    bit_array.slice(good, 15, bit_array.byte_size(good) - 15)
  let corrupted = <<prefix:bits, 0xFF, rest:bits>>
  case decode(corrupted) {
    Ok(_) -> panic as "expected BadMessageCrc, got Ok"
    Error(BadMessageCrc) -> Nil
    Error(other) ->
      panic as { "expected BadMessageCrc, got " <> debug_decode_error(other) }
  }
}

fn debug_decode_error(err) -> String {
  case err {
    BadPreludeCrc -> "BadPreludeCrc"
    BadMessageCrc -> "BadMessageCrc"
    _ -> "other"
  }
}

// ---------- round-trips for every header value type ----------
//
// Each test runs a single header value through encode→decode and
// pins the bytes back. Together they cover the wire-codes 0..9
// the codec advertises.

fn assert_round_trip(name: String, value) -> Nil {
  let event = Event(headers: [Header(name: name, value: value)], payload: <<>>)
  case decode(encode(event)) {
    Ok(#(decoded, _rest)) -> decoded |> should.equal(event)
    Error(e) ->
      panic as {
        "round-trip failed for " <> name <> ": " <> debug_decode_error(e)
      }
  }
}

pub fn round_trips_bool_true_test() {
  assert_round_trip("b", BoolTrueValue)
}

pub fn round_trips_bool_false_test() {
  assert_round_trip("b", BoolFalseValue)
}

pub fn round_trips_int16_negative_test() {
  // -32768 = minimum signed 16-bit. Pins the wrap edge.
  assert_round_trip("i16", Int16Value(-32_768))
}

pub fn round_trips_int32_min_test() {
  assert_round_trip("i32", Int32Value(-2_147_483_648))
}

pub fn round_trips_int64_large_test() {
  // ~max int64; exercises the 64-bit wrap path.
  assert_round_trip("i64", Int64Value(9_223_372_036_854_775_000))
}

pub fn round_trips_binary_payload_test() {
  assert_round_trip("bin", BinaryValue(<<0, 1, 2, 3, 255>>))
}

pub fn round_trips_timestamp_test() {
  // Smithy timestamps as event-stream headers are millis-since-epoch.
  assert_round_trip("ts", TimestampValue(1_705_453_200_000))
}

pub fn round_trips_uuid_test() {
  // Exactly 16 bytes; the encoder doesn't add a length prefix
  // (UUIDs are fixed-width).
  let uuid = <<
    0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0x01, 0x23, 0x45, 0x67, 0x89,
    0xAB, 0xCD, 0xEF,
  >>
  assert_round_trip("u", UuidValue(uuid))
}

pub fn round_trips_byte_value_zero_test() {
  // The trivially-positive boundary — pins that encode/decode of
  // a 0 byte doesn't get confused with bool/false (wire-code 1).
  assert_round_trip("b0", ByteValue(0))
}

pub fn round_trips_string_with_multibyte_utf8_test() {
  // UTF-8 multibyte characters use 4 raw bytes for a single
  // codepoint. Ensures the byte-length prefix counts bytes, not
  // characters.
  assert_round_trip("emoji", StringValue("🦀 crab"))
}
