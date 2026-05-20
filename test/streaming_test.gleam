//// Tests for the `StreamingBody` buffered branch (`Buffered(bytes)`).
//// Pinned here so any future addition to the opaque type — the
//// planned lazy `Source(...)` variant for file-backed inputs — can
//// only extend behaviour, not change what existing buffered call
//// sites observe. Chunked-branch tests live in
//// `streaming_chunked_test.gleam`.

import aws/streaming
import gleeunit/should

pub fn from_bit_array_roundtrip_test() {
  let body = streaming.from_bit_array(<<1, 2, 3, 4>>)
  streaming.to_bit_array(body) |> should.equal(<<1, 2, 3, 4>>)
}

pub fn byte_size_returns_buffered_size_test() {
  streaming.from_bit_array(<<>>)
  |> streaming.byte_size
  |> should.equal(0)

  streaming.from_bit_array(<<1, 2, 3>>)
  |> streaming.byte_size
  |> should.equal(3)
}

pub fn is_empty_test() {
  streaming.empty()
  |> streaming.is_empty
  |> should.be_true

  streaming.from_bit_array(<<0xFF>>)
  |> streaming.is_empty
  |> should.be_false
}

pub fn empty_is_zero_length_test() {
  streaming.empty()
  |> streaming.to_bit_array
  |> should.equal(<<>>)
}

pub fn from_string_roundtrips_via_to_bit_array_test() {
  // UTF-8 byte values for "hello" — same payload either way.
  streaming.from_string("hello")
  |> streaming.to_bit_array
  |> should.equal(<<"hello":utf8>>)
}

pub fn append_concatenates_two_bodies_test() {
  let a = streaming.from_bit_array(<<1, 2, 3>>)
  let b = streaming.from_bit_array(<<4, 5>>)
  streaming.append(a, b)
  |> streaming.to_bit_array
  |> should.equal(<<1, 2, 3, 4, 5>>)
}

pub fn append_empty_is_identity_test() {
  let body = streaming.from_bit_array(<<0xAB, 0xCD>>)
  streaming.append(streaming.empty(), body)
  |> streaming.to_bit_array
  |> should.equal(<<0xAB, 0xCD>>)
  streaming.append(body, streaming.empty())
  |> streaming.to_bit_array
  |> should.equal(<<0xAB, 0xCD>>)
}
