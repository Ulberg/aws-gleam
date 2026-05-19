//// `StreamingBody` — a forward-compatible wrapper for HTTP
//// request / response bodies that may be too large to hold in
//// memory.
////
//// The opaque type has two representations:
////
//// - **Buffered**: a single `BitArray` materialised up front. The
////   v1 transport always produces this.
//// - **Chunked**: an ordered list of byte chunks. Callers building
////   multipart bodies or feeding a future streaming transport
////   construct one of these via `from_chunks`. Today the helpers
////   collapse it back to bytes on demand; once the transport
////   rewrite lands, `to_chunks` becomes the streaming surface and
////   nothing else changes.
////
//// Smithy `@streaming` blob members on the request side are
//// already surfaced as `BitArray` by the codegen; callers
//// wanting a forward-compatible call site can wrap their byte
//// payload via `from_bit_array` and pass the `StreamingBody`
//// through.

import gleam/bit_array
import gleam/list

pub opaque type StreamingBody {
  Buffered(bytes: BitArray)
  Chunked(chunks: List(BitArray))
}

/// Build a `StreamingBody` from a `BitArray` already in memory.
/// The canonical constructor for v1 and the only one the
/// codegen emits today.
pub fn from_bit_array(bytes: BitArray) -> StreamingBody {
  Buffered(bytes: bytes)
}

/// Build a `StreamingBody` from an ordered list of byte chunks.
/// Chunk boundaries are preserved by `to_chunks` and by `append`
/// when both operands are chunked, so multipart builders and the
/// future streaming transport see exactly the chunking the caller
/// produced.
pub fn from_chunks(chunks: List(BitArray)) -> StreamingBody {
  Chunked(chunks: chunks)
}

/// Return the body as a `BitArray`. For the v1 buffered
/// implementation this is a constant-time operation. For chunked
/// bodies this concatenates the chunks. Once the transport rewrite
/// lands and chunked bodies travel as iterators, this will
/// materialise the underlying chunk iterator — code that calls
/// `to_bit_array` then keeps using the bytes works either way.
pub fn to_bit_array(body: StreamingBody) -> BitArray {
  case body {
    Buffered(bytes: b) -> b
    Chunked(chunks: cs) -> bit_array.concat(cs)
  }
}

/// Return the body as an ordered list of byte chunks. Buffered
/// bodies surface as a single-element list (or the empty list if
/// the buffer is empty), so consumers can write one chunk-oriented
/// loop and have it work uniformly. The future streaming transport
/// will produce chunked responses directly and pipe them through
/// this surface without materialising the full payload.
pub fn to_chunks(body: StreamingBody) -> List(BitArray) {
  case body {
    Buffered(bytes: b) ->
      case bit_array.byte_size(b) {
        0 -> []
        _ -> [b]
      }
    Chunked(chunks: cs) -> cs
  }
}

/// Byte size of the body. v1 is `bit_array.byte_size`; once
/// streaming lands the helper either reads the `Content-Length`
/// header or walks the chunk iterator to compute it lazily.
pub fn byte_size(body: StreamingBody) -> Int {
  case body {
    Buffered(bytes: b) -> bit_array.byte_size(b)
    Chunked(chunks: cs) ->
      list.fold(cs, 0, fn(acc, chunk) { acc + bit_array.byte_size(chunk) })
  }
}

/// `True` iff the body is empty. Carved out from `byte_size` so
/// callers checking emptiness don't materialise the full chunk
/// iterator once the transport rewrite lands.
pub fn is_empty(body: StreamingBody) -> Bool {
  byte_size(body) == 0
}

/// Buffered empty body. Used by request builders when no body
/// is present (the SDK threads a `StreamingBody` end-to-end even
/// for GET-style operations).
pub fn empty() -> StreamingBody {
  Buffered(bytes: <<>>)
}

/// Build a `StreamingBody` from a UTF-8 `String`. Common path
/// for caller-supplied text payloads (JSON bodies, XML bodies);
/// the eventual transport will treat this exactly like
/// `from_bit_array(bit_array.from_string(s))`.
pub fn from_string(s: String) -> StreamingBody {
  Buffered(bytes: bit_array.from_string(s))
}

/// Concatenate two streaming bodies. When both sides are chunked
/// the result preserves chunk boundaries from each operand —
/// useful for multipart builders that already chose their chunk
/// shape. Mixing buffered and chunked merges through `to_chunks`
/// so the result is still walkable chunk-by-chunk by downstream
/// consumers.
pub fn append(a: StreamingBody, b: StreamingBody) -> StreamingBody {
  case a, b {
    Buffered(bytes: ba), Buffered(bytes: bb) ->
      Buffered(bytes: bit_array.append(ba, bb))
    _, _ -> Chunked(chunks: list.append(to_chunks(a), to_chunks(b)))
  }
}
