//// Chunked variant of `StreamingBody`. The opaque type can hold
//// either a buffered `BitArray` or a list of byte-chunks; the
//// existing helpers (`to_bit_array`, `byte_size`, `is_empty`,
//// `append`) work uniformly across both. These tests pin the
//// invariants the future streaming transport will rely on.

import aws/streaming
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
