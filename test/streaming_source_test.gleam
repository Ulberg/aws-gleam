//// Pins for the `Source(...)` variant of `StreamingBody`. The
//// callback yields chunks one at a time and signals end-of-stream
//// with `Error(Nil)`; consumers stream chunk-by-chunk via
//// `fold_chunks` / `try_fold_chunks` without materialising the
//// full body, and fall back to materialising via `to_chunks` /
//// `to_bit_array` when needed.

import aws/streaming
import gleam/erlang/process
import gleam/list
import gleeunit/should

/// Build a `Source` body that yields the given chunks in order.
/// Backed by a process-subject queue so each test fixture is
/// self-contained — no module-level mutable state.
fn source_from_chunks(chunks: List(BitArray)) -> streaming.StreamingBody {
  let inbox = process.new_subject()
  list.each(chunks, fn(c) { process.send(inbox, Ok(c)) })
  process.send(inbox, Error(Nil))
  streaming.from_source(fn() {
    case process.receive(inbox, 0) {
      Ok(v) -> v
      Error(_) -> Error(Nil)
    }
  })
}

pub fn source_to_chunks_drains_callback_test() {
  source_from_chunks([<<1, 2>>, <<3, 4>>, <<5>>])
  |> streaming.to_chunks
  |> should.equal([<<1, 2>>, <<3, 4>>, <<5>>])
}

pub fn source_to_bit_array_concatenates_test() {
  source_from_chunks([<<1, 2>>, <<3>>, <<4, 5, 6>>])
  |> streaming.to_bit_array
  |> should.equal(<<1, 2, 3, 4, 5, 6>>)
}

pub fn source_byte_size_sums_chunks_test() {
  source_from_chunks([<<1, 2, 3>>, <<4, 5>>, <<>>, <<6>>])
  |> streaming.byte_size
  |> should.equal(6)
}

pub fn source_fold_chunks_streams_test() {
  // Streaming fold: we accumulate the chunk count + total bytes
  // without ever materialising the chunk list.
  let result =
    source_from_chunks([<<1, 2>>, <<3, 4, 5>>, <<6>>])
    |> streaming.fold_chunks(#(0, 0), fn(acc, chunk) {
      let #(count, total) = acc
      #(count + 1, total + chunk_size(chunk))
    })
  result |> should.equal(#(3, 6))
}

pub fn source_try_fold_chunks_short_circuits_test() {
  // Stop folding as soon as a chunk exceeds 4 bytes; verify we
  // surfaced the error rather than running to completion.
  let result =
    source_from_chunks([<<1, 2>>, <<3, 4, 5, 6, 7>>, <<8, 9>>])
    |> streaming.try_fold_chunks(0, fn(acc, chunk) {
      let size = chunk_size(chunk)
      case size > 4 {
        True -> Error("oversized chunk")
        False -> Ok(acc + size)
      }
    })
  result |> should.equal(Error("oversized chunk"))
}

pub fn source_to_bit_array_max_caps_test() {
  // Source streams chunks one at a time and the cap fires partway —
  // the partial accumulation isn't returned, just Error(Nil).
  source_from_chunks([<<1, 2, 3>>, <<4, 5, 6>>, <<7, 8>>])
  |> streaming.to_bit_array_max(5)
  |> should.equal(Error(Nil))

  // Cap matches exact total: succeeds.
  source_from_chunks([<<1, 2, 3>>, <<4, 5>>])
  |> streaming.to_bit_array_max(5)
  |> should.equal(Ok(<<1, 2, 3, 4, 5>>))
}

pub fn source_is_empty_returns_false_conservatively_test() {
  // `is_empty` doesn't consume the source; even an empty source
  // reports non-empty to avoid double-pass complexity. Documented
  // limitation — callers who need a definitive answer use byte_size.
  source_from_chunks([])
  |> streaming.is_empty
  |> should.be_false
}

@external(erlang, "erlang", "byte_size")
fn chunk_size(b: BitArray) -> Int
