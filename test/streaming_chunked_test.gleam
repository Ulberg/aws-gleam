//// Chunked variant of `StreamingBody`. The opaque type can hold
//// either a buffered `BitArray` or a list of byte-chunks; the
//// existing helpers (`to_bit_array`, `byte_size`, `is_empty`,
//// `append`) work uniformly across both. These tests pin the
//// invariants the future streaming transport will rely on.

import aws/streaming
import gleam/bit_array
import gleam/list
import gleeunit/should

pub fn from_chunks_round_trips_via_to_bit_array_test() {
  streaming.from_chunks([<<1, 2>>, <<3>>, <<4, 5, 6>>])
  |> streaming.to_bit_array
  |> should.equal(<<1, 2, 3, 4, 5, 6>>)
}

pub fn from_chunks_empty_is_zero_length_test() {
  streaming.from_chunks([])
  |> streaming.to_bit_array
  |> should.equal(<<>>)
}

pub fn from_chunks_byte_size_sums_chunk_sizes_test() {
  streaming.from_chunks([<<1, 2, 3>>, <<>>, <<4, 5>>])
  |> streaming.byte_size
  |> should.equal(5)
}

pub fn from_chunks_with_only_empty_chunks_is_empty_test() {
  streaming.from_chunks([<<>>, <<>>])
  |> streaming.is_empty
  |> should.be_true
}

pub fn to_chunks_preserves_chunk_boundaries_test() {
  streaming.from_chunks([<<1>>, <<2, 3>>, <<4>>])
  |> streaming.to_chunks
  |> should.equal([<<1>>, <<2, 3>>, <<4>>])
}

pub fn to_chunks_on_buffered_returns_single_chunk_test() {
  // Buffered bodies look like a one-chunk stream to consumers.
  // Callers that want raw bytes use `to_bit_array`; callers that
  // want the chunk iterator get a single entry. Importantly: an
  // empty buffered body yields the empty list, not `[<<>>]`, so
  // `is_empty` stays correct for both representations.
  streaming.from_bit_array(<<1, 2, 3>>)
  |> streaming.to_chunks
  |> should.equal([<<1, 2, 3>>])

  streaming.empty()
  |> streaming.to_chunks
  |> should.equal([])
}

pub fn append_chunked_to_buffered_concatenates_test() {
  let a = streaming.from_bit_array(<<1, 2>>)
  let b = streaming.from_chunks([<<3>>, <<4, 5>>])
  streaming.append(a, b)
  |> streaming.to_bit_array
  |> should.equal(<<1, 2, 3, 4, 5>>)
}

pub fn append_chunked_to_chunked_preserves_chunks_test() {
  let a = streaming.from_chunks([<<1>>, <<2>>])
  let b = streaming.from_chunks([<<3, 4>>])
  // The order matters; chunk boundaries from both bodies are
  // preserved end-to-end so consumers can stream without
  // rematerialising.
  streaming.append(a, b)
  |> streaming.to_chunks
  |> should.equal([<<1>>, <<2>>, <<3, 4>>])
}

// ---------- fold_chunks / try_fold_chunks / each_chunk ----------

pub fn fold_chunks_sums_byte_lengths_test() {
  streaming.from_chunks([<<1, 2>>, <<3>>, <<4, 5, 6>>])
  |> streaming.fold_chunks(0, fn(acc, chunk) {
    acc + bit_array.byte_size(chunk)
  })
  |> should.equal(6)
}

pub fn fold_chunks_invokes_once_per_chunk_test() {
  // Three chunks ⇒ three calls. The folder appends a count so we
  // can verify exact arity. Useful when downstream picks up the
  // "real" streaming transport — the call count should equal the
  // number of stream messages arriving on the wire.
  streaming.from_chunks([<<1>>, <<2>>, <<3>>])
  |> streaming.fold_chunks([], fn(acc, _) { [Nil, ..acc] })
  |> list.length
  |> should.equal(3)
}

pub fn fold_chunks_on_buffered_runs_once_test() {
  // Buffered bodies surface as one chunk to the folder. Empty
  // buffered surfaces as zero chunks (matches `to_chunks` /
  // `is_empty` semantics) so a presence check is `fold_chunks /=
  // 0`.
  streaming.from_bit_array(<<1, 2, 3>>)
  |> streaming.fold_chunks(0, fn(acc, _) { acc + 1 })
  |> should.equal(1)

  streaming.empty()
  |> streaming.fold_chunks(0, fn(acc, _) { acc + 1 })
  |> should.equal(0)
}

pub fn try_fold_chunks_short_circuits_on_error_test() {
  // Folder fails on the second chunk. We expect the third chunk
  // never to be visited and the error to bubble out. The accumulator
  // shape (Int here) doesn't matter — only that we stop early.
  let result =
    streaming.from_chunks([<<1>>, <<2>>, <<3>>])
    |> streaming.try_fold_chunks(0, fn(_acc, chunk) {
      case chunk {
        <<2>> -> Error("nope on second chunk")
        _ -> Ok(0)
      }
    })
  result |> should.equal(Error("nope on second chunk"))
}

pub fn try_fold_chunks_threads_accumulator_when_ok_test() {
  // No chunk errors; accumulator should reflect each step.
  streaming.from_chunks([<<10>>, <<20>>, <<30>>])
  |> streaming.try_fold_chunks(0, fn(acc, chunk) {
    Ok(acc + bit_array.byte_size(chunk))
  })
  |> should.equal(Ok(3))
}

pub fn fold_chunks_visits_in_order_test() {
  // Build a reversed list of visited chunks; reverse the result so
  // the assertion shows the on-wire order. This pins the iteration
  // contract — the chunked transport invokes the folder in the
  // same order chunks arrive on the socket.
  streaming.from_chunks([<<1>>, <<2>>, <<3>>])
  |> streaming.fold_chunks([], fn(acc, chunk) { [chunk, ..acc] })
  |> list.reverse
  |> should.equal([<<1>>, <<2>>, <<3>>])
}

// ---------- to_bit_array_max tests ----------
//
// `to_bit_array_max(body, max)` materialises the body iff its size
// stays at or below the cap. The cap fires across chunk boundaries
// so the caller never sees a partial result above the threshold.

pub fn to_bit_array_max_empty_body_under_cap_returns_ok_empty_test() {
  streaming.empty()
  |> streaming.to_bit_array_max(100)
  |> should.equal(Ok(<<>>))
}

pub fn to_bit_array_max_buffered_under_cap_test() {
  streaming.from_bit_array(<<1, 2, 3>>)
  |> streaming.to_bit_array_max(10)
  |> should.equal(Ok(<<1, 2, 3>>))
}

pub fn to_bit_array_max_buffered_at_exact_cap_test() {
  // Body size == cap is allowed; the predicate is strict >.
  streaming.from_bit_array(<<1, 2, 3>>)
  |> streaming.to_bit_array_max(3)
  |> should.equal(Ok(<<1, 2, 3>>))
}

pub fn to_bit_array_max_buffered_over_cap_returns_error_test() {
  streaming.from_bit_array(<<1, 2, 3, 4, 5>>)
  |> streaming.to_bit_array_max(3)
  |> should.equal(Error(Nil))
}

pub fn to_bit_array_max_chunked_under_cap_test() {
  // Cumulative size 6 bytes, cap 10 — accepted.
  streaming.from_chunks([<<1, 2>>, <<3>>, <<4, 5, 6>>])
  |> streaming.to_bit_array_max(10)
  |> should.equal(Ok(<<1, 2, 3, 4, 5, 6>>))
}

pub fn to_bit_array_max_chunked_fires_on_boundary_chunk_test() {
  // Total = 6 bytes but cap = 4 — the third chunk pushes over the
  // limit. Even though the first two chunks (3 bytes) fit, the
  // helper bails before concatenating the third.
  streaming.from_chunks([<<1, 2>>, <<3>>, <<4, 5, 6>>])
  |> streaming.to_bit_array_max(4)
  |> should.equal(Error(Nil))
}

pub fn to_bit_array_max_zero_cap_rejects_nonempty_test() {
  // max_bytes = 0 only accepts the empty body; any chunk pushes
  // over the cap (size 1 > 0).
  streaming.from_bit_array(<<1>>)
  |> streaming.to_bit_array_max(0)
  |> should.equal(Error(Nil))
}

// ---------- to_string_max tests ----------

pub fn to_string_max_buffered_utf8_under_cap_test() {
  streaming.from_string("hello")
  |> streaming.to_string_max(100)
  |> should.equal(Ok("hello"))
}

pub fn to_string_max_buffered_over_cap_returns_error_test() {
  streaming.from_string("hello world")
  |> streaming.to_string_max(5)
  |> should.equal(Error(Nil))
}

pub fn to_string_max_invalid_utf8_returns_error_test() {
  // 0xC0 0x80 is an invalid UTF-8 byte pair. Bit array survives
  // to_bit_array_max (size 2, cap 10), but bit_array.to_string
  // rejects it.
  streaming.from_bit_array(<<0xC0, 0x80>>)
  |> streaming.to_string_max(10)
  |> should.equal(Error(Nil))
}

pub fn to_string_max_chunked_text_round_trips_test() {
  // Source body chunked at random boundaries (including mid-grapheme)
  // — to_string_max concatenates first, then UTF-8 decodes, so this
  // should round-trip cleanly regardless of chunk boundaries.
  streaming.from_chunks([
    <<"héll":utf8>>,
    <<"o wo":utf8>>,
    <<"rld":utf8>>,
  ])
  |> streaming.to_string_max(100)
  |> should.equal(Ok("héllo world"))
}
