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
/// frame; v1 callers call `decode` again on the rest).
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
        True ->
          decode_after_prelude(total, headers_len, prelude_crc, rest, bytes)
      }
    }
    _ -> Error(MalformedFrame(reason: "shorter than prelude"))
  }
}

fn decode_after_prelude(
  total: Int,
  headers_len: Int,
  _prelude_crc: Int,
  rest_after_prelude: BitArray,
  original_bytes: BitArray,
) -> Result(#(Event, BitArray), DecodeError) {
  // Frame layout sizes: 12 byte prelude, headers_len, payload_len,
  // 4 byte message-crc. Solve for payload_len.
  let payload_len = total - 12 - headers_len - 4
  case payload_len < 0 {
    True -> Error(MalformedFrame(reason: "negative payload length"))
    False ->
      case bit_array.slice(rest_after_prelude, 0, headers_len) {
        Error(_) -> Error(MalformedFrame(reason: "headers slice failed"))
        Ok(headers_bytes) ->
          case bit_array.slice(rest_after_prelude, headers_len, payload_len) {
            Error(_) -> Error(MalformedFrame(reason: "payload slice failed"))
            Ok(payload) -> {
              let trailing_offset = headers_len + payload_len
              case bit_array.slice(rest_after_prelude, trailing_offset, 4) {
                Error(_) ->
                  Error(MalformedFrame(reason: "message crc slice failed"))
                Ok(msg_crc_bytes) -> {
                  let actual_msg_crc = bytes_to_int_be(msg_crc_bytes)
                  let body_len = total - 4
                  case bit_array.slice(original_bytes, 0, body_len) {
                    Error(_) ->
                      Error(MalformedFrame(reason: "body slice failed"))
                    Ok(body) ->
                      case crc32(body) == actual_msg_crc {
                        False -> Error(BadMessageCrc)
                        True ->
                          case decode_headers(headers_bytes, []) {
                            Error(e) -> Error(e)
                            Ok(headers) -> {
                              let rest_offset = trailing_offset + 4
                              let rest = case
                                bit_array.slice(
                                  rest_after_prelude,
                                  rest_offset,
                                  bit_array.byte_size(rest_after_prelude)
                                    - rest_offset,
                                )
                              {
                                Ok(b) -> b
                                Error(_) -> <<>>
                              }
                              Ok(#(
                                Event(headers: headers, payload: payload),
                                rest,
                              ))
                            }
                          }
                      }
                  }
                }
              }
            }
          }
      }
  }
}

fn decode_headers(
  bytes: BitArray,
  acc: List(Header),
) -> Result(List(Header), DecodeError) {
  case bit_array.byte_size(bytes) {
    0 -> Ok(list.reverse(acc))
    _ ->
      case bytes {
        <<name_len:8, rest:bits>> ->
          case bit_array.slice(rest, 0, name_len) {
            Error(_) -> Error(MalformedFrame(reason: "header name slice"))
            Ok(name_bytes) ->
              case bit_array.to_string(name_bytes) {
                Error(_) -> Error(MalformedFrame(reason: "header name utf8"))
                Ok(name) ->
                  case
                    bit_array.slice(
                      rest,
                      name_len,
                      bit_array.byte_size(rest) - name_len,
                    )
                  {
                    Error(_) ->
                      Error(MalformedFrame(reason: "header value rest"))
                    Ok(value_rest) -> {
                      case decode_header_value(value_rest) {
                        Error(e) -> Error(e)
                        Ok(#(value, after_value)) ->
                          decode_headers(after_value, [
                            Header(name: name, value: value),
                            ..acc
                          ])
                      }
                    }
                  }
              }
          }
        _ -> Error(MalformedFrame(reason: "header truncated"))
      }
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
    // Type 2 = byte. Read one byte, sign-extend from 8.
    2 ->
      case rest {
        <<n:big-8, after:bits>> -> {
          let signed = case n >= 128 {
            True -> n - 256
            False -> n
          }
          Ok(#(ByteValue(signed), after))
        }
        _ -> Error(MalformedFrame(reason: "byte header truncated"))
      }
    // Type 7 = string. Read 2-byte length, then UTF-8 bytes.
    7 -> decode_string_header(rest)
    other -> Error(UnknownHeaderType(type_code: other))
  }
}

fn decode_string_header(
  rest: BitArray,
) -> Result(#(HeaderValue, BitArray), DecodeError) {
  case rest {
    <<len:big-16, value_and_rest:bits>> ->
      case bit_array.slice(value_and_rest, 0, len) {
        Error(_) -> Error(MalformedFrame(reason: "string slice"))
        Ok(value_bytes) ->
          case bit_array.to_string(value_bytes) {
            Error(_) -> Error(MalformedFrame(reason: "string utf8"))
            Ok(s) -> {
              let after = case
                bit_array.slice(
                  value_and_rest,
                  len,
                  bit_array.byte_size(value_and_rest) - len,
                )
              {
                Ok(b) -> b
                Error(_) -> <<>>
              }
              Ok(#(StringValue(s), after))
            }
          }
      }
    _ -> Error(MalformedFrame(reason: "string header truncated"))
  }
}

fn bytes_to_int_be(bytes: BitArray) -> Int {
  case bytes {
    <<n:big-32>> -> n
    _ -> 0
  }
}
