//// Tests for `rest.glacier_tree_hash` and the
//// `rest.with_glacier_tree_hash_headers` middleware.
////
//// The algorithm (1 MiB chunked SHA-256, recursive pair-hashing) is
//// documented at https://docs.aws.amazon.com/amazonglacier/latest/dev/
//// checksum-calculations.html. The single-chunk fixture lifts the
//// pre-existing protocol-test corpus value (`b94d27b9…` for
//// "hello world"); the multi-chunk fixture is the AWS reference
//// vector copied byte-for-byte from the Rust SDK's
//// `glacier_interceptors::treehash_checksum_tests::hash_value_test`
//// — 11-byte sequence `01245678912` repeated to fill 101 MiB + 500
//// bytes, expected tree-hash
//// `3d417484359fc9f5a3bafd576dc47b8b2de2bf2d4fdac5aa2aff768f2210d386`.
//// AWS CLI was used to mint that value upstream, so a match here means
//// our pure-Gleam implementation agrees with the canonical algorithm.

import aws/internal/codec/rest
import aws/internal/crypto
import gleam/bit_array
import gleam/dict
import gleeunit/should

pub fn glacier_tree_hash_empty_body_test() {
  // Glacier's spec says an empty body still yields a digest:
  // `SHA-256("")`.
  let digest = rest.glacier_tree_hash(<<>>)
  digest
  |> crypto.hex_encode
  |> should.equal(
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  )
}

pub fn glacier_tree_hash_single_chunk_test() {
  // Bodies ≤ 1 MiB degenerate to plain SHA-256.
  let body = bit_array.from_string("hello world")
  rest.glacier_tree_hash(body)
  |> crypto.hex_encode
  |> should.equal(
    "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9",
  )
}

pub fn glacier_tree_hash_multi_chunk_aws_vector_test() {
  // 11-byte repeating sequence `01245678912`, replicated until the
  // total length reaches **at least** 1 MiB * 101 + 500 = 105,907,716
  // bytes — same overshoot the Rust SDK test does (it loops
  // `while test_data.len() < total_size { extend(11) }`, so the
  // final length is `ceil(target/11) * 11 = 105,907,725` bytes,
  // 9 bytes past the threshold). Trimming to the exact target
  // changes the chunk boundary alignment and the resulting tree.
  // Expected tree-hash verified upstream against AWS CLI.
  let base_seq = bit_array.from_string("01245678912")
  let total_size = 1_048_576 * 101 + 500
  let body = repeat_until_at_least(base_seq, total_size)

  rest.glacier_tree_hash(body)
  |> crypto.hex_encode
  |> should.equal(
    "3d417484359fc9f5a3bafd576dc47b8b2de2bf2d4fdac5aa2aff768f2210d386",
  )
}

pub fn glacier_tree_hash_headers_emits_both_test() {
  // Smoke check: both headers populate, tree-hash != content-sha256 on
  // a > 1 MiB body. The 11-byte sequence × 100_000 reaches ~1.1 MiB.
  let base_seq = bit_array.from_string("01245678912")
  let body = repeat_n(base_seq, 100_000)

  let h = rest.with_glacier_tree_hash_headers(dict.new(), body)
  let assert Ok(tree) = dict.get(h, "X-Amz-Sha256-Tree-Hash")
  let assert Ok(content) = dict.get(h, "X-Amz-Content-Sha256")
  // Two distinct digests on a > 1 MiB body.
  should.be_true(tree != content)
  // Content header is just sha256 of the body.
  content
  |> should.equal(crypto.hex_encode(crypto.sha256(body)))
}

pub fn glacier_tree_hash_headers_skip_when_present_test() {
  // Caller-supplied values win on collision (mirrors Rust SDK's
  // `if !contains_key(...) { insert(...) }`).
  let h =
    dict.from_list([
      #("X-Amz-Sha256-Tree-Hash", "caller-tree"),
      #("X-Amz-Content-Sha256", "caller-content"),
    ])
  let out = rest.with_glacier_tree_hash_headers(h, <<"data":utf8>>)
  let assert Ok(tree) = dict.get(out, "X-Amz-Sha256-Tree-Hash")
  let assert Ok(content) = dict.get(out, "X-Amz-Content-Sha256")
  tree |> should.equal("caller-tree")
  content |> should.equal("caller-content")
}

fn repeat_n(seq: BitArray, n: Int) -> BitArray {
  repeat_acc(seq, n, [])
  |> bit_array.concat
}

fn repeat_acc(seq: BitArray, n: Int, acc: List(BitArray)) -> List(BitArray) {
  case n {
    0 -> acc
    _ -> repeat_acc(seq, n - 1, [seq, ..acc])
  }
}

fn repeat_until_at_least(seq: BitArray, target_bytes: Int) -> BitArray {
  let seq_size = bit_array.byte_size(seq)
  let copies = target_bytes / seq_size + 1
  repeat_n(seq, copies)
}
