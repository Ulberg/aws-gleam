//// `StreamingBody` — wrapper for HTTP request / response bodies
//// that may be too large to hold in memory.
////
//// The opaque type has two representations:
////
//// - **Buffered**: a single `BitArray` materialised up front.
////   Produced by `from_bit_array` and by buffered callers that
////   only ever hold the full payload.
//// - **Chunked**: an ordered list of byte chunks. The chunked
////   transport (`http_streaming.default_send`) produces these
////   directly off the wire; multipart builders construct them
////   via `from_chunks`. `to_chunks` exposes the chunk list to
////   consumers without materialising the full payload.
////
//// A future `Source(...)` variant — file handles, generators —
//// will let callers stream from on-disk or external producers
//// without holding the full payload in memory.

import gleam/bit_array
import gleam/list
import gleam/result

pub opaque type StreamingBody {
  Buffered(bytes: BitArray)
  Chunked(chunks: List(BitArray))
}

/// Build a `StreamingBody` from a `BitArray` already in memory.
/// Use this when the body bytes are buffered up front (a UTF-8
/// payload, the result of a buffered read, a generated XML/JSON
/// body) and you want to pass a `StreamingBody`-typed value through.
pub fn from_bit_array(bytes: BitArray) -> StreamingBody {
  Buffered(bytes: bytes)
}

/// Build a `StreamingBody` from an ordered list of byte chunks.
/// Chunk boundaries are preserved by `to_chunks` and by `append`
/// when both operands are chunked, so multipart builders and the
/// chunked transport see exactly the chunking the caller produced.
pub fn from_chunks(chunks: List(BitArray)) -> StreamingBody {
  Chunked(chunks: chunks)
}

/// Return the body as a `BitArray`. For `Buffered` this is a
/// constant-time accessor; for `Chunked` it concatenates the chunks.
/// Use this only when the caller actually needs the bytes contiguous;
/// chunk-by-chunk consumers should prefer `to_chunks` / `fold_chunks`.
pub fn to_bit_array(body: StreamingBody) -> BitArray {
  case body {
    Buffered(bytes: b) -> b
    Chunked(chunks: cs) -> bit_array.concat(cs)
  }
}

/// Return the body as an ordered list of byte chunks. Buffered
/// bodies surface as a single-element list (or the empty list if
/// the buffer is empty), so consumers can write one chunk-oriented
/// loop and have it work uniformly across both representations.
/// The chunked transport produces chunked responses directly off
/// the wire and pipes them through this surface.
pub fn to_chunks(body: StreamingBody) -> List(BitArray) {
  case body {
    Buffered(bytes: <<>>) -> []
    Buffered(bytes: b) -> [b]
    Chunked(chunks: cs) -> cs
  }
}

/// Byte size of the body. Constant-time for `Buffered`; walks the
/// chunk list (summing `bit_array.byte_size`) for `Chunked`.
pub fn byte_size(body: StreamingBody) -> Int {
  case body {
    Buffered(bytes: b) -> bit_array.byte_size(b)
    Chunked(chunks: cs) ->
      list.fold(cs, 0, fn(acc, chunk) { acc + bit_array.byte_size(chunk) })
  }
}

/// `True` iff the body is empty. Distinct from `byte_size == 0`
/// so a future lazy `Source(...)` variant can short-circuit
/// without walking the source.
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
/// equivalent to `from_bit_array(bit_array.from_string(s))`.
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

/// Reduce a streaming body left-to-right by accumulating one chunk
/// at a time. Buffered bodies surface as a single chunk per
/// `to_chunks`, so the fold runs once; chunked bodies fold across
/// every chunk the transport delivered. Use this for running-hash /
/// running-length / stream-to-disk pipelines without materialising
/// the full body.
pub fn fold_chunks(
  body: StreamingBody,
  initial: acc,
  f: fn(acc, BitArray) -> acc,
) -> acc {
  list.fold(to_chunks(body), initial, f)
}

/// `fold_chunks` variant that short-circuits on `Error`. Returns the
/// first error the folder produces (or `Ok(acc)` if every chunk
/// accepted). Useful for streaming decoders that can fail partway
/// (e.g. UTF-8 validation rejecting a torn multi-byte sequence at a
/// chunk boundary, or a JSON parser hitting a malformed token).
pub fn try_fold_chunks(
  body: StreamingBody,
  initial: acc,
  f: fn(acc, BitArray) -> Result(acc, err),
) -> Result(acc, err) {
  list.try_fold(to_chunks(body), initial, f)
}

/// Materialise the body as a `BitArray`, refusing to do so if the
/// cumulative size would exceed `max_bytes`. Walks chunks lazily
/// on the chunked path so the cap fires before concatenation. Use
/// this when a caller wants buffered access but must guard against
/// OOM on pathologically-large responses (event-stream control-
/// message buffers, downloads of unknown size, server bugs).
///
/// `Error(Nil)` means the body exceeded the cap; the caller can
/// fall back to chunk-by-chunk processing or surface a typed
/// error to its own callers. A `max_bytes` of 0 still accepts the
/// empty body (`Ok(<<>>)`).
pub fn to_bit_array_max(
  body: StreamingBody,
  max_bytes: Int,
) -> Result(BitArray, Nil) {
  try_fold_chunks(body, <<>>, fn(acc, chunk) {
    let combined = bit_array.append(acc, chunk)
    case bit_array.byte_size(combined) > max_bytes {
      True -> Error(Nil)
      False -> Ok(combined)
    }
  })
}

/// Materialise the body as a UTF-8 `String`. Returns `Error(Nil)`
/// if the body exceeds `max_bytes` (via `to_bit_array_max`) OR if
/// the bytes aren't valid UTF-8. The two-failure-modes-one-error
/// shape mirrors `bit_array.to_string` so callers can keep their
/// existing `result.try` chains.
///
/// Common path for text response bodies — JSON-as-text, XML-as-
/// text, log files — where the caller wants both size-safety and
/// a `String` result. Equivalent to `to_bit_array_max` followed by
/// `bit_array.to_string`, kept here as a single entry point so
/// call sites read as one operation.
pub fn to_string_max(
  body: StreamingBody,
  max_bytes: Int,
) -> Result(String, Nil) {
  use bytes <- result.try(to_bit_array_max(body, max_bytes))
  bit_array.to_string(bytes)
}
