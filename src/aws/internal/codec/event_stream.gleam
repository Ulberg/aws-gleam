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
//// where `type` selects the header-value shape. v1 here implements
//// the two shapes that cover all framing-only use cases (handshake
//// + control messages): `byte` (7) and `string` (7). Richer header
//// types — bool, short, int, long, byte array, timestamp, uuid —
//// land when a service we generate against actually needs them.

import gleam/bit_array
import gleam/list

/// One framed message: zero or more typed headers plus an opaque
/// payload. The payload is uninterpreted at this level — protocol
/// implementations (event-stream JSON, CBOR, etc.) layer on top.
pub type Event {
  Event(headers: List(Header), payload: BitArray)
}

pub type Header {
  Header(name: String, value: HeaderValue)
}

/// Header-value shapes the v1 codec handles. The on-wire type
/// discriminator (`Byte = 2`, `String = 7`, etc.) is owned by the
/// encoder; callers construct these by variant name.
pub type HeaderValue {
  ByteValue(Int)
  StringValue(String)
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
  case value {
    // Type 2 = byte (signed 8-bit int). Gleam BitArray value
    // segments don't have a `signed` option, so we map negative
    // values into the unsigned 8-bit range via two's complement
    // (-1 → 255, -128 → 128) before writing.
    ByteValue(n) -> {
      let wrapped = case n < 0 {
        True -> n + 256
        False -> n
      }
      <<2:8, wrapped:big-8>>
    }
    // Type 7 = string. Two-byte BE length prefix, then UTF-8 bytes.
    StringValue(s) -> {
      let bytes = bit_array.from_string(s)
      let len = bit_array.byte_size(bytes)
      <<7:8, len:big-16, bytes:bits>>
    }
  }
}

@external(erlang, "erlang", "crc32")
fn crc32(data: BitArray) -> Int
