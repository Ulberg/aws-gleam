//// `application/vnd.amazon.eventstream` framing codec.
////
//// AWS event-stream operations (Transcribe, Kinesis SubscribeToShard,
//// Bedrock streaming responses, S3 SelectObjectContent, etc.) deliver
//// their bodies as a sequence of self-describing frames rather than a
//// single payload. Each frame carries a small header set and an
//// opaque payload; the protocol handler unpacks one frame at a time
//// off the streaming transport.
////
//// On-wire layout (big-endian throughout):
////
//// ```
//// +-----------------------+
//// | Total length      [4] |   <-- includes all four boxes below
//// | Headers length    [4] |   <-- bytes of Headers section
//// | Prelude CRC32     [4] |   <-- of the two ints above
//// | Headers       [N1]    |
//// | Payload       [N2]    |
//// | Message CRC32     [4] |   <-- of every byte before this one
//// +-----------------------+
//// ```
////
//// Each Header is `name_len[1] | name[name_len] | type[1] | value[...]`
//// where `type` selects the header-value shape. All ten header-value
//// shapes the protocol defines (bool true/false, byte, short, int,
//// long, binary, string, timestamp, uuid) are implemented — see
//// `HeaderValue` for the wire-code mapping.

import aws/streaming.{type StreamingBody}
import gleam/bit_array
import gleam/list
import gleam/result

/// One framed message: zero or more typed headers plus an opaque
/// payload. The payload is uninterpreted at this level — protocol
/// implementations (event-stream JSON, CBOR, etc.) layer on top.
pub type Event {
  Event(headers: List(Header), payload: BitArray)
}

pub type Header {
  Header(name: String, value: HeaderValue)
}

/// Look up the first `StringValue` header on `event` matching `name`.
/// Used by codegen-emitted `parse_<op>_event` functions to dispatch
/// on `:event-type` / `:message-type` (both are string-valued per the
/// event-stream spec).
pub fn string_header(event: Event, name: String) -> Result(String, Nil) {
  case list.find(event.headers, fn(h) { h.name == name }) {
    Ok(Header(value: StringValue(v), ..)) -> Ok(v)
    _ -> Error(Nil)
  }
}

/// Header-value shapes. The on-wire type discriminator is owned by
/// the encoder; callers construct these by variant name.
///
/// Coverage (wire-code in parens):
///   - `BoolTrueValue` (0), `BoolFalseValue` (1) — no payload
///   - `ByteValue` (2) — signed 8-bit
///   - `Int16Value` (3) — signed 16-bit
///   - `Int32Value` (4) — signed 32-bit
///   - `Int64Value` (5) — signed 64-bit
///   - `BinaryValue` (6) — 2-byte length prefix + bytes
///   - `StringValue` (7) — 2-byte length prefix + UTF-8
///   - `TimestampValue` (8) — millis since epoch (signed 64-bit)
///   - `UuidValue` (9) — exactly 16 bytes
pub type HeaderValue {
  BoolTrueValue
  BoolFalseValue
  ByteValue(Int)
  Int16Value(Int)
  Int32Value(Int)
  Int64Value(Int)
  BinaryValue(BitArray)
  StringValue(String)
  TimestampValue(Int)
  UuidValue(BitArray)
}

/// Frame an `Event` for transmission. Computes both CRC32s (prelude
/// over the first two ints, message over every preceding byte) and
/// returns the assembled BitArray ready to hand to the streaming
/// transport.
pub fn encode(event: Event) -> BitArray {
  let headers_bytes = encode_headers(event.headers)
  let headers_len = bit_array.byte_size(headers_bytes)
  let payload_len = bit_array.byte_size(event.payload)
  // Total = prelude(12) + headers + payload + message-crc(4).
  let total_len = 12 + headers_len + payload_len + 4
  let prelude = <<total_len:big-32, headers_len:big-32>>
  let prelude_crc = crc32(prelude)
  let body = <<
    prelude:bits,
    prelude_crc:big-32,
    headers_bytes:bits,
    event.payload:bits,
  >>
  let message_crc = crc32(body)
  <<body:bits, message_crc:big-32>>
}

fn encode_headers(headers: List(Header)) -> BitArray {
  list.fold(headers, <<>>, fn(acc, header) {
    <<acc:bits, encode_header(header):bits>>
  })
}

fn encode_header(header: Header) -> BitArray {
  let name_bytes = bit_array.from_string(header.name)
  let name_len = bit_array.byte_size(name_bytes)
  let value_bytes = encode_header_value(header.value)
  <<name_len:8, name_bytes:bits, value_bytes:bits>>
}

fn encode_header_value(value: HeaderValue) -> BitArray {
  // Gleam BitArray value segments don't have a `signed` option, so
  // negative values map into the unsigned range via two's
  // complement (`wrap(n, bits)`) before writing.
  case value {
    BoolTrueValue -> <<0:8>>
    BoolFalseValue -> <<1:8>>
    ByteValue(n) -> <<2:8, { wrap(n, 8) }:big-8>>
    Int16Value(n) -> <<3:8, { wrap(n, 16) }:big-16>>
    Int32Value(n) -> <<4:8, { wrap(n, 32) }:big-32>>
    Int64Value(n) -> <<5:8, { wrap(n, 64) }:big-64>>
    BinaryValue(bytes) -> {
      let len = bit_array.byte_size(bytes)
      <<6:8, len:big-16, bytes:bits>>
    }
    StringValue(s) -> {
      let bytes = bit_array.from_string(s)
      let len = bit_array.byte_size(bytes)
      <<7:8, len:big-16, bytes:bits>>
    }
    TimestampValue(millis) -> <<8:8, { wrap(millis, 64) }:big-64>>
    UuidValue(bytes) -> <<9:8, bytes:bits>>
  }
}

fn wrap(n: Int, bits: Int) -> Int {
  case n < 0 {
    True -> n + pow2(bits)
    False -> n
  }
}

fn pow2(bits: Int) -> Int {
  case bits {
    8 -> 256
    16 -> 65_536
    32 -> 4_294_967_296
    64 -> 18_446_744_073_709_551_616
    _ -> 0
  }
}

@external(erlang, "erlang", "crc32")
fn crc32(data: BitArray) -> Int

/// Why decoding can fail. `MalformedFrame` covers any structural
/// issue (truncated bytes, length fields disagreeing with each
/// other); `BadPreludeCrc` / `BadMessageCrc` flag exactly which
/// CRC check failed so callers can distinguish "stream got
/// corrupted" from "we mis-parsed the framing".
pub type DecodeError {
  MalformedFrame(reason: String)
  BadPreludeCrc
  BadMessageCrc
  UnknownHeaderType(type_code: Int)
}

/// Decode one framed message off the front of `bytes`. Returns the
/// decoded `Event` plus the trailing bytes (which may hold the next
/// frame; callers call `decode` again on the rest).
///
/// Validates both CRCs end-to-end — partial / corrupted streams
/// surface as `BadPreludeCrc` / `BadMessageCrc` rather than silently
/// returning garbage.
pub fn decode(bytes: BitArray) -> Result(#(Event, BitArray), DecodeError) {
  case bytes {
    <<total:big-32, headers_len:big-32, prelude_crc:big-32, rest:bits>> -> {
      let prelude = <<total:big-32, headers_len:big-32>>
      case crc32(prelude) == prelude_crc {
        False -> Error(BadPreludeCrc)
        True -> decode_after_prelude(total, headers_len, rest, bytes)
      }
    }
    _ -> Error(MalformedFrame(reason: "shorter than prelude"))
  }
}

fn decode_after_prelude(
  total: Int,
  headers_len: Int,
  rest_after_prelude: BitArray,
  original_bytes: BitArray,
) -> Result(#(Event, BitArray), DecodeError) {
  // Frame layout sizes: 12 byte prelude, headers_len, payload_len,
  // 4 byte message-crc. Solve for payload_len.
  let payload_len = total - 12 - headers_len - 4
  case payload_len < 0 {
    True -> Error(MalformedFrame(reason: "negative payload length"))
    False -> {
      use headers_bytes <- result.try(
        bit_array.slice(rest_after_prelude, 0, headers_len)
        |> result.replace_error(MalformedFrame("headers slice failed")),
      )
      use payload <- result.try(
        bit_array.slice(rest_after_prelude, headers_len, payload_len)
        |> result.replace_error(MalformedFrame("payload slice failed")),
      )
      let trailing_offset = headers_len + payload_len
      use msg_crc_bytes <- result.try(
        bit_array.slice(rest_after_prelude, trailing_offset, 4)
        |> result.replace_error(MalformedFrame("message crc slice failed")),
      )
      let body_len = total - 4
      use body <- result.try(
        bit_array.slice(original_bytes, 0, body_len)
        |> result.replace_error(MalformedFrame("body slice failed")),
      )
      case crc32(body) == bytes_to_int_be(msg_crc_bytes) {
        False -> Error(BadMessageCrc)
        True -> {
          use headers <- result.try(decode_headers(headers_bytes, []))
          let rest = slice_after(rest_after_prelude, trailing_offset + 4)
          Ok(#(Event(headers: headers, payload: payload), rest))
        }
      }
    }
  }
}

fn decode_headers(
  bytes: BitArray,
  acc: List(Header),
) -> Result(List(Header), DecodeError) {
  case bytes {
    <<>> -> Ok(list.reverse(acc))
    <<name_len:8, rest:bits>> -> {
      use name_bytes <- result.try(
        bit_array.slice(rest, 0, name_len)
        |> result.replace_error(MalformedFrame("header name slice")),
      )
      use name <- result.try(
        bit_array.to_string(name_bytes)
        |> result.replace_error(MalformedFrame("header name utf8")),
      )
      let value_rest = slice_after(rest, name_len)
      use #(value, after_value) <- result.try(decode_header_value(value_rest))
      decode_headers(after_value, [Header(name: name, value: value), ..acc])
    }
    _ -> Error(MalformedFrame(reason: "header truncated"))
  }
}

fn decode_header_value(
  bytes: BitArray,
) -> Result(#(HeaderValue, BitArray), DecodeError) {
  case bytes {
    <<type_code:8, rest:bits>> -> decode_header_value_body(type_code, rest)
    _ -> Error(MalformedFrame(reason: "header value missing type byte"))
  }
}

fn decode_header_value_body(
  type_code: Int,
  rest: BitArray,
) -> Result(#(HeaderValue, BitArray), DecodeError) {
  case type_code {
    0 -> Ok(#(BoolTrueValue, rest))
    1 -> Ok(#(BoolFalseValue, rest))
    2 -> decode_int_header(rest, 8, fn(n) { ByteValue(n) })
    3 -> decode_int_header(rest, 16, fn(n) { Int16Value(n) })
    4 -> decode_int_header(rest, 32, fn(n) { Int32Value(n) })
    5 -> decode_int_header(rest, 64, fn(n) { Int64Value(n) })
    6 -> decode_binary_header(rest)
    7 -> decode_string_header(rest)
    8 -> decode_int_header(rest, 64, fn(n) { TimestampValue(n) })
    9 -> decode_uuid_header(rest)
    other -> Error(UnknownHeaderType(type_code: other))
  }
}

fn decode_int_header(
  rest: BitArray,
  bits: Int,
  wrap_in: fn(Int) -> HeaderValue,
) -> Result(#(HeaderValue, BitArray), DecodeError) {
  case bits, rest {
    8, <<n:big-8, after:bits>> -> Ok(#(wrap_in(unsign(n, 8)), after))
    16, <<n:big-16, after:bits>> -> Ok(#(wrap_in(unsign(n, 16)), after))
    32, <<n:big-32, after:bits>> -> Ok(#(wrap_in(unsign(n, 32)), after))
    64, <<n:big-64, after:bits>> -> Ok(#(wrap_in(unsign(n, 64)), after))
    _, _ -> Error(MalformedFrame(reason: "int header truncated"))
  }
}

// Two's-complement decode: if the high bit is set, value is
// negative when read as signed. `wrap` is the encoder counterpart.
fn unsign(n: Int, bits: Int) -> Int {
  let half = pow2(bits) / 2
  case n >= half {
    True -> n - pow2(bits)
    False -> n
  }
}

fn decode_binary_header(
  rest: BitArray,
) -> Result(#(HeaderValue, BitArray), DecodeError) {
  case rest {
    <<len:big-16, value_and_rest:bits>> -> {
      use value_bytes <- result.try(
        bit_array.slice(value_and_rest, 0, len)
        |> result.replace_error(MalformedFrame("binary slice")),
      )
      Ok(#(BinaryValue(value_bytes), slice_after(value_and_rest, len)))
    }
    _ -> Error(MalformedFrame(reason: "binary header truncated"))
  }
}

fn decode_uuid_header(
  rest: BitArray,
) -> Result(#(HeaderValue, BitArray), DecodeError) {
  use uuid_bytes <- result.try(
    bit_array.slice(rest, 0, 16)
    |> result.replace_error(MalformedFrame("uuid header truncated")),
  )
  Ok(#(UuidValue(uuid_bytes), slice_after(rest, 16)))
}

fn decode_string_header(
  rest: BitArray,
) -> Result(#(HeaderValue, BitArray), DecodeError) {
  case rest {
    <<len:big-16, value_and_rest:bits>> -> {
      use value_bytes <- result.try(
        bit_array.slice(value_and_rest, 0, len)
        |> result.replace_error(MalformedFrame("string slice")),
      )
      use s <- result.try(
        bit_array.to_string(value_bytes)
        |> result.replace_error(MalformedFrame("string utf8")),
      )
      Ok(#(StringValue(s), slice_after(value_and_rest, len)))
    }
    _ -> Error(MalformedFrame(reason: "string header truncated"))
  }
}

// Return the tail of `bytes` starting at `offset`; falls back to an
// empty BitArray when the slice is out of range. The three header
// decoders all need the same "everything past this many bytes"
// computation; centralising it keeps each call site readable.
fn slice_after(bytes: BitArray, offset: Int) -> BitArray {
  case bit_array.slice(bytes, offset, bit_array.byte_size(bytes) - offset) {
    Ok(b) -> b
    Error(_) -> <<>>
  }
}

fn bytes_to_int_be(bytes: BitArray) -> Int {
  case bytes {
    <<n:big-32>> -> n
    _ -> 0
  }
}

/// Frame a list of events as a single `StreamingBody`. Each event
/// is `encode`d in turn; the result is the concatenated frames in
/// list order. Use this on the request side of `@eventStream`
/// operations to hand the framed bytes to the streaming transport.
///
/// The body is a `Chunked` `StreamingBody` carrying one chunk per
/// event, so the streaming transport can write them on the wire
/// one frame at a time (`fold_chunks` preserves order). Buffered-
/// then-streamed callers see the same wire bytes — `to_bit_array`
/// concatenates in order.
pub fn events_to_streaming_body(events: List(Event)) -> StreamingBody {
  events
  |> list.map(encode)
  |> streaming.from_chunks
}

/// Decode every frame from a streaming body. Materialises the full
/// list of events — appropriate when the response is short (control
/// messages, handshakes) or the call site wants to handle every
/// event after the stream terminates. Long-lived subscription
/// streams (`SubscribeToShard`, `StartStreamTranscription`) want
/// `fold_events` instead so each event surfaces incrementally.
///
/// The streaming body's chunks are concatenated first; the framing
/// protocol's length fields make incremental parsing safe across
/// chunk boundaries, but materialising-then-parsing is simpler and
/// equally correct for buffer-bounded responses.
pub fn decode_all(body: StreamingBody) -> Result(List(Event), DecodeError) {
  decode_all_bytes(streaming.to_bit_array(body), [])
}

fn decode_all_bytes(
  bytes: BitArray,
  acc: List(Event),
) -> Result(List(Event), DecodeError) {
  case bytes {
    <<>> -> Ok(list.reverse(acc))
    _ -> {
      use #(event, rest) <- result.try(decode(bytes))
      decode_all_bytes(rest, [event, ..acc])
    }
  }
}

/// Reduce a streaming body's event frames left-to-right by
/// accumulating one decoded event at a time. The natural consumer
/// API for long-lived subscription streams — the folder can update
/// running state (counts, partial outputs, signals) without holding
/// the whole event list in memory.
///
/// Returns `Error(DecodeError)` the moment a frame fails CRC or
/// length checks, preserving the accumulator up to (but not
/// including) the bad frame. Callers that want to keep going past
/// a bad frame must do their own resync.
///
/// Reads the full body up front via `streaming.to_bit_array` so the
/// fold runs on a single contiguous buffer; a future chunk-by-chunk
/// consumer that decodes events as bytes arrive can keep this same
/// surface — only the implementation changes.
pub fn fold_events(
  body: StreamingBody,
  initial: acc,
  f: fn(acc, Event) -> acc,
) -> Result(acc, DecodeError) {
  fold_events_bytes(streaming.to_bit_array(body), initial, f)
}

fn fold_events_bytes(
  bytes: BitArray,
  acc: acc,
  f: fn(acc, Event) -> acc,
) -> Result(acc, DecodeError) {
  case bytes {
    <<>> -> Ok(acc)
    _ -> {
      use #(event, rest) <- result.try(decode(bytes))
      fold_events_bytes(rest, f(acc, event), f)
    }
  }
}

/// One pull-based step of an event-stream iterator. `Yield` carries
/// the next decoded event plus the iterator's remaining state for
/// the subsequent call; `Done` marks normal end-of-stream; `Failed`
/// surfaces the decode error encountered partway through (the
/// stream is dead at that point — no further events recoverable).
pub type IterStep {
  Yield(event: Event, next: fn() -> IterStep)
  Done
  Failed(error: DecodeError)
}

/// Wrap a streaming body as a pull-based event iterator. Each call
/// to `next` returns either `Yield(event, next)` — the next decoded
/// event plus a continuation for the rest of the stream — or `Done`
/// at clean end-of-stream, or `Failed(err)` if the wire bytes don't
/// parse.
///
/// Useful for callers that want to drive consumption explicitly
/// rather than handing the whole stream to `fold_events`. The
/// codegen-emitted `<op>_event_stream(client, input)` wrappers
/// return a `streaming.Response`; pipe `resp.body` through this
/// helper to get a typed iterator without buffering the full event
/// list in memory.
///
/// Today materialises the body up front (same as `fold_events` —
/// `streaming.to_bit_array`); a follow-up that streams chunk-by-
/// chunk lands when the wire transport surfaces partial frames.
pub fn iter_events(body: StreamingBody) -> IterStep {
  iter_step(streaming.to_bit_array(body))
}

fn iter_step(remaining: BitArray) -> IterStep {
  case remaining {
    <<>> -> Done
    _ ->
      case decode(remaining) {
        Ok(#(event, rest)) -> Yield(event:, next: fn() { iter_step(rest) })
        Error(err) -> Failed(error: err)
      }
  }
}
