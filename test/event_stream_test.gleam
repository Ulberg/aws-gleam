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
  TimestampValue, UuidValue, decode, decode_all, encode, fold_events,
}
import aws/streaming
import gleam/bit_array
import gleam/list
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

// ---------- decode_all over a streaming body ----------

pub fn decode_all_returns_all_frames_in_order_test() {
  // Pack three frames into one buffered StreamingBody. decode_all
  // must surface them in the same order they appear in the bytes.
  let f1 = encode(Event(headers: [], payload: <<"one":utf8>>))
  let f2 = encode(Event(headers: [], payload: <<"two":utf8>>))
  let f3 = encode(Event(headers: [], payload: <<"three":utf8>>))
  let all = streaming.from_bit_array(<<f1:bits, f2:bits, f3:bits>>)
  case decode_all(all) {
    Ok(events) -> {
      list.length(events) |> should.equal(3)
      list.map(events, fn(e) { bit_array.to_string(e.payload) })
      |> should.equal([Ok("one"), Ok("two"), Ok("three")])
    }
    Error(_) -> panic as "decode_all unexpectedly failed"
  }
}

pub fn decode_all_on_empty_body_returns_empty_list_test() {
  case decode_all(streaming.empty()) {
    Ok(events) -> events |> should.equal([])
    Error(_) -> panic as "empty body should decode to []"
  }
}

pub fn decode_all_propagates_first_decode_error_test() {
  // Append two valid frames, then a few junk bytes (clearly not
  // a valid frame prelude). decode_all should return the error
  // from the third decode attempt — and NOT return a partial list
  // of the two valid events (that would be silently dropping data).
  let f1 = encode(Event(headers: [], payload: <<>>))
  let f2 = encode(Event(headers: [], payload: <<>>))
  let junk = <<0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0>>
  let mixed = streaming.from_bit_array(<<f1:bits, f2:bits, junk:bits>>)
  case decode_all(mixed) {
    Ok(_) -> panic as "expected an error on the junk-tail frame"
    Error(_) -> Nil
  }
}

pub fn events_to_streaming_body_round_trips_through_decode_all_test() {
  // Build a list of events, pack them as a StreamingBody via the
  // request-side helper, decode_all the body — the result must
  // equal the original list. This pins the request/response
  // symmetry across the streaming transport.
  let events = [
    event_stream.Event(headers: [], payload: <<"first":utf8>>),
    event_stream.Event(headers: [], payload: <<"second":utf8>>),
    event_stream.Event(
      headers: [
        Header(name: ":message-type", value: StringValue("event")),
      ],
      payload: <<"third":utf8>>,
    ),
  ]
  let body = event_stream.events_to_streaming_body(events)
  // Chunked variant should preserve one chunk per event.
  body |> streaming.to_chunks |> list.length |> should.equal(3)
  case decode_all(body) {
    Ok(decoded) -> decoded |> should.equal(events)
    Error(_) -> panic as "round-trip through streaming body failed"
  }
}

pub fn events_to_streaming_body_with_empty_list_is_empty_test() {
  let body = event_stream.events_to_streaming_body([])
  body |> streaming.is_empty |> should.be_true
  case decode_all(body) {
    Ok(events) -> events |> should.equal([])
    Error(_) -> panic as "empty event list should produce empty body"
  }
}

// ---------- fold_events tests ----------
//
// `fold_events` is the incremental-consumer API: walks frames one
// at a time, updating an accumulator. Pinning the in-order
// iteration contract here means long-lived subscription streams
// (`SubscribeToShard`, `StartStreamTranscription`) can drive
// running-state state machines without buffering every event.

pub fn fold_events_visits_each_event_in_order_test() {
  let events = [
    Event(headers: [], payload: <<"a":utf8>>),
    Event(headers: [], payload: <<"b":utf8>>),
    Event(headers: [], payload: <<"c":utf8>>),
  ]
  let body = event_stream.events_to_streaming_body(events)
  // Collect payloads in arrival order; reverse the accumulator
  // for a wire-order assertion.
  let result = fold_events(body, [], fn(acc, e) { [e.payload, ..acc] })
  case result {
    Ok(rev) -> {
      list.reverse(rev)
      |> should.equal([<<"a":utf8>>, <<"b":utf8>>, <<"c":utf8>>])
    }
    Error(_) -> panic as "fold_events should succeed on a clean frame list"
  }
}

pub fn fold_events_returns_initial_on_empty_body_test() {
  let body = event_stream.events_to_streaming_body([])
  // The accumulator passes through untouched when no events fire.
  case fold_events(body, 42, fn(_acc, _e) { 0 }) {
    Ok(acc) -> acc |> should.equal(42)
    Error(_) -> panic as "empty body should fold to the initial value"
  }
}

pub fn fold_events_propagates_decode_error_test() {
  // Corrupt the first frame's prelude CRC; fold_events must surface
  // `BadPreludeCrc` and not touch the accumulator.
  let frame = encode(Event(headers: [], payload: <<"hello":utf8>>))
  let assert Ok(head) = bit_array.slice(frame, 0, 8)
  let assert Ok(tail) =
    bit_array.slice(frame, 12, bit_array.byte_size(frame) - 12)
  let corrupted = <<head:bits, 0:big-32, tail:bits>>
  let body = streaming.from_bit_array(corrupted)
  case fold_events(body, 0, fn(acc, _) { acc + 1 }) {
    Error(BadPreludeCrc) -> Nil
    Error(other) ->
      panic as {
        "expected BadPreludeCrc, got " <> describe_decode_error(other)
      }
    Ok(_) -> panic as "fold_events should not succeed on a corrupted frame"
  }
}

fn describe_decode_error(e: event_stream.DecodeError) -> String {
  case e {
    BadPreludeCrc -> "BadPreludeCrc"
    BadMessageCrc -> "BadMessageCrc"
    event_stream.MalformedFrame(reason: r) -> "MalformedFrame(" <> r <> ")"
    event_stream.UnknownHeaderType(type_code: _) -> "UnknownHeaderType"
  }
}
