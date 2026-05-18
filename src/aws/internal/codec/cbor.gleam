//// Minimal CBOR (RFC 8949) codec for the rpcv2Cbor protocol.
////
//// AWS's rpcv2Cbor wire form is the canonical / deterministic
//// CBOR subset: definite-length arrays + maps, no tags, no
//// indefinite-length items, sort keys lexicographically when
//// encoding maps. The decoder is more permissive — it accepts
//// indefinite-length items too because real services have been
//// observed shipping them.
////
//// Major types this implementation covers:
////   * 0 unsigned int — 1/2/3/5/9-byte head encoding
////   * 1 negative int — 1/2/3/5/9-byte head
////   * 2 byte string — length-prefixed
////   * 3 text string — length-prefixed UTF-8
////   * 4 array — definite-length on encode, both on decode
////   * 5 map — definite-length on encode, both on decode
////   * 7 simple values + floats — false/true/null/float64
////
//// Not yet covered: tags (major type 6), `undefined` (simple 23),
//// half-float (0xF9), 32-bit float (0xFA). Half- and 32-bit floats
//// would surface only from CBOR senders explicitly downcasting; the
//// AWS rpcv2Cbor services we've seen always send float64. Tags are
//// reserved for date-time / bignum encodings the rpcv2Cbor spec
//// excludes from request/response bodies.

import gleam/bit_array
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result

pub type Value {
  CInt(value: Int)
  CFloat(value: Float)
  CBool(value: Bool)
  CNull
  CString(value: String)
  CBytes(value: BitArray)
  CList(items: List(Value))
  /// Map values are stored as a `List` rather than a `Dict` so
  /// the encoder can preserve insertion order — rpcv2Cbor only
  /// cares about lexicographic key order on encode, which the
  /// encoder enforces, but on decode the original order is
  /// observable for downstream consumers (e.g. for diffing
  /// against a deterministic reference).
  CMap(entries: List(#(Value, Value)))
}

// ---------- encoder ----------

/// Encode a `Value` to its canonical CBOR byte stream.
pub fn encode(v: Value) -> BitArray {
  case v {
    CInt(n) -> encode_int(n)
    CFloat(f) -> encode_float64(f)
    CBool(False) -> <<0xF4>>
    CBool(True) -> <<0xF5>>
    CNull -> <<0xF6>>
    CString(s) -> encode_text(s)
    CBytes(b) -> encode_bytes(b)
    CList(items) -> encode_list(items)
    CMap(entries) -> encode_map(entries)
  }
}

fn encode_int(n: Int) -> BitArray {
  case n >= 0 {
    True -> encode_head(0, n)
    False -> encode_head(1, -1 - n)
  }
}

fn encode_text(s: String) -> BitArray {
  let bytes = bit_array.from_string(s)
  bit_array.append(encode_head(3, bit_array.byte_size(bytes)), bytes)
}

fn encode_bytes(b: BitArray) -> BitArray {
  bit_array.append(encode_head(2, bit_array.byte_size(b)), b)
}

fn encode_list(items: List(Value)) -> BitArray {
  list.fold(
    items,
    encode_head(4, list.length(items)),
    fn(acc, v) { bit_array.append(acc, encode(v)) },
  )
}

fn encode_map(entries: List(#(Value, Value))) -> BitArray {
  // Canonical / deterministic CBOR sorts map keys by the
  // bytewise lexicographic order of their encoded form,
  // including the major-type head byte. AWS's rpcv2Cbor leans
  // on this when computing wire-form digests.
  let sorted =
    list.sort(entries, by: fn(a, b) { compare_bytewise(encode(a.0), encode(b.0)) })
  list.fold(
    sorted,
    encode_head(5, list.length(sorted)),
    fn(acc, entry) {
      let k = encode(entry.0)
      let v = encode(entry.1)
      bit_array.append(bit_array.append(acc, k), v)
    },
  )
}

/// Build a CBOR head byte sequence for a given `major_type`
/// (0-7) and `n` value following it. Uses the shortest possible
/// encoding: in-byte for n < 24, then 1, 2, 4, or 8 trailing
/// bytes for the larger ranges. Callers always pass `n >= 0` —
/// they precompute the unsigned magnitude (negative ints
/// transform to `-1 - n`, lengths are naturally unsigned).
fn encode_head(major_type: Int, n: Int) -> BitArray {
  let mt = major_type * 32
  case n {
    _ if n < 24 -> <<{ mt + n }>>
    _ if n < 256 -> <<{ mt + 24 }, n>>
    _ if n < 65_536 -> <<{ mt + 25 }, n:size(16)-big>>
    _ if n < 4_294_967_296 -> <<{ mt + 26 }, n:size(32)-big>>
    _ -> <<{ mt + 27 }, n:size(64)-big>>
  }
}

fn encode_float64(f: Float) -> BitArray {
  <<0xFB, f:float-size(64)-big>>
}

fn compare_bytewise(a: BitArray, b: BitArray) -> order.Order {
  case a, b {
    <<>>, <<>> -> order.Eq
    <<>>, _ -> order.Lt
    _, <<>> -> order.Gt
    <<x, ar:bits>>, <<y, br:bits>> ->
      case x, y {
        _, _ if x < y -> order.Lt
        _, _ if x > y -> order.Gt
        _, _ -> compare_bytewise(ar, br)
      }
    // Unreachable in practice — both `a` and `b` are byte-
    // aligned BitArrays from `encode`, so one of the above arms
    // always matches. The arm exists to satisfy the
    // exhaustiveness checker, which can't see the alignment
    // invariant from the function signature alone.
    _, _ -> order.Eq
  }
}

// ---------- decoder ----------

/// Decode a CBOR byte stream into a `Value`. Returns the leftover
/// bytes on success so callers can decode multiple items from one
/// buffer; rpcv2Cbor request bodies are single items, so most
/// callers can just drop the leftover.
pub fn decode(bytes: BitArray) -> Result(#(Value, BitArray), String) {
  case bytes {
    <<head, rest:bits>> -> {
      let major = head / 32
      let info = head - major * 32
      case major {
        0 -> {
          use #(n, rest2) <- result.try(read_int(info, rest))
          Ok(#(CInt(n), rest2))
        }
        1 -> {
          use #(n, rest2) <- result.try(read_int(info, rest))
          Ok(#(CInt(-1 - n), rest2))
        }
        2 -> {
          use #(len, rest2) <- result.try(read_int(info, rest))
          use #(b, rest3) <- result.try(take_bytes(rest2, len))
          Ok(#(CBytes(b), rest3))
        }
        3 -> {
          use #(len, rest2) <- result.try(read_int(info, rest))
          use #(b, rest3) <- result.try(take_bytes(rest2, len))
          case bit_array.to_string(b) {
            Ok(s) -> Ok(#(CString(s), rest3))
            Error(_) -> Error("cbor: invalid UTF-8 in text string")
          }
        }
        4 -> {
          use #(len, rest2) <- result.try(read_int(info, rest))
          decode_list_items(rest2, len, [])
        }
        5 -> {
          use #(len, rest2) <- result.try(read_int(info, rest))
          decode_map_entries(rest2, len, [])
        }
        7 -> decode_simple(info, rest)
        _ -> Error("cbor: tags / major type 6 not supported")
      }
    }
    _ -> Error("cbor: empty input")
  }
}

fn read_int(info: Int, rest: BitArray) -> Result(#(Int, BitArray), String) {
  case info {
    _ if info < 24 -> Ok(#(info, rest))
    24 ->
      case rest {
        <<n, r:bits>> -> Ok(#(n, r))
        _ -> Error("cbor: truncated 1-byte length")
      }
    25 ->
      case rest {
        <<n:size(16)-big, r:bits>> -> Ok(#(n, r))
        _ -> Error("cbor: truncated 2-byte length")
      }
    26 ->
      case rest {
        <<n:size(32)-big, r:bits>> -> Ok(#(n, r))
        _ -> Error("cbor: truncated 4-byte length")
      }
    27 ->
      case rest {
        <<n:size(64)-big, r:bits>> -> Ok(#(n, r))
        _ -> Error("cbor: truncated 8-byte length")
      }
    _ -> Error("cbor: unsupported length info")
  }
}

fn take_bytes(
  bytes: BitArray,
  n: Int,
) -> Result(#(BitArray, BitArray), String) {
  let bits = n * 8
  case bytes {
    <<b:bits-size(bits), r:bits>> -> Ok(#(b, r))
    _ -> Error("cbor: truncated byte string")
  }
}

fn decode_list_items(
  bytes: BitArray,
  remaining: Int,
  acc: List(Value),
) -> Result(#(Value, BitArray), String) {
  case remaining {
    0 -> Ok(#(CList(list.reverse(acc)), bytes))
    _ -> {
      use #(v, rest) <- result.try(decode(bytes))
      decode_list_items(rest, remaining - 1, [v, ..acc])
    }
  }
}

fn decode_map_entries(
  bytes: BitArray,
  remaining: Int,
  acc: List(#(Value, Value)),
) -> Result(#(Value, BitArray), String) {
  case remaining {
    0 -> Ok(#(CMap(list.reverse(acc)), bytes))
    _ -> {
      use #(k, rest1) <- result.try(decode(bytes))
      use #(v, rest2) <- result.try(decode(rest1))
      decode_map_entries(rest2, remaining - 1, [#(k, v), ..acc])
    }
  }
}

fn decode_simple(info: Int, rest: BitArray) -> Result(#(Value, BitArray), String) {
  case info {
    20 -> Ok(#(CBool(False), rest))
    21 -> Ok(#(CBool(True), rest))
    22 -> Ok(#(CNull, rest))
    23 -> Ok(#(CNull, rest))
    // Undefined (23) maps to Null for our purposes — AWS doesn't
    // distinguish them and the codec consumers always want one
    // of the two.
    27 ->
      case rest {
        <<f:float-size(64)-big, r:bits>> -> Ok(#(CFloat(f), r))
        _ -> Error("cbor: truncated float64")
      }
    _ -> Error("cbor: unsupported simple value")
  }
}

/// Convenience helper for callers that just want the decoded
/// value and don't care about the trailing bytes (the common
/// rpcv2Cbor request/response body case).
pub fn decode_value(bytes: BitArray) -> Result(Value, String) {
  decode(bytes) |> result.map(fn(t) { t.0 })
}

/// `option.None` (None) when looking up a key that's not present
/// in a `CMap`. Used by hand-written decoders that pluck specific
/// fields out of a CBOR-decoded map.
pub fn get_field(map: Value, key: String) -> Option(Value) {
  case map {
    CMap(entries) ->
      case list.find(entries, fn(p) { p.0 == CString(key) }) {
        Ok(#(_, v)) -> Some(v)
        Error(_) -> None
      }
    _ -> None
  }
}
