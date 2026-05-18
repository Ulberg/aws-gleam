//// `StreamingBody` — a forward-compatible wrapper for HTTP
//// request / response bodies that may be too large to hold in
//// memory.
////
//// v1 is **buffered-only**: a `StreamingBody` always carries a
//// concrete `BitArray` payload internally, and the helpers that
//// drive it are equivalent to operating on a `BitArray` directly.
//// The wrapper exists so callers can write code today against
//// the eventual streaming surface — and the HTTP transport
//// rewrite that turns this into a real chunked iterator (gated
//// on a streaming HTTP send + receive path) ships later without
//// breaking any caller.
////
//// Smithy `@streaming` blob members on the request side are
//// already surfaced as `BitArray` by the codegen; callers
//// wanting a forward-compatible call site can wrap their byte
//// payload via `from_bit_array` and pass the `StreamingBody`
//// through.

import gleam/bit_array

pub opaque type StreamingBody {
  Buffered(bytes: BitArray)
}

/// Build a `StreamingBody` from a `BitArray` already in memory.
/// The canonical constructor for v1 and the only one the
/// codegen emits today.
pub fn from_bit_array(bytes: BitArray) -> StreamingBody {
  Buffered(bytes: bytes)
}

/// Return the body as a `BitArray`. For the v1 buffered
/// implementation this is a constant-time operation. Once the
/// transport rewrite lands, this will materialise the underlying
/// chunk iterator — code that calls `to_bit_array` then keeps
/// using the bytes works either way.
pub fn to_bit_array(body: StreamingBody) -> BitArray {
  case body {
    Buffered(bytes: b) -> b
  }
}

/// Byte size of the body. v1 is `bit_array.byte_size`; once
/// streaming lands the helper either reads the `Content-Length`
/// header or walks the chunk iterator to compute it lazily.
pub fn byte_size(body: StreamingBody) -> Int {
  case body {
    Buffered(bytes: b) -> bit_array.byte_size(b)
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

/// Concatenate two streaming bodies. v1 materialises both into
/// memory and joins; once the transport rewrite lands, this
/// returns a chunk iterator that yields `a`'s chunks then `b`'s
/// chunks without buffering either fully. Useful for callers
/// composing multipart bodies.
pub fn append(a: StreamingBody, b: StreamingBody) -> StreamingBody {
  Buffered(bytes: bit_array.append(to_bit_array(a), to_bit_array(b)))
}
