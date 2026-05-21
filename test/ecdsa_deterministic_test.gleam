//// RFC 6979 deterministic ECDSA — pin against the reference test
//// vectors in §A.2.5 (P-256 / SHA-256). Each vector ships
//// `(d, message, k, r, s)` — the deterministic signing function
//// takes `(d_bytes, sha256(message))` and must produce the exact
//// `(r, s)` from the spec.
////
//// Unlike Erlang's `crypto:sign/4` which uses a random nonce per
//// call, deterministic ECDSA is byte-exact reproducible. That's
//// what unblocks fixture-driven signature pinning across the
//// aws-c-auth v4a corpus.

import aws/internal/crypto
import aws/internal/ecdsa_deterministic
import gleam/bit_array
import gleam/string
import gleeunit/should

/// Private key from RFC 6979 §A.2.5 (P-256 / SHA-256).
const test_private_hex: String = "C9AFA9D845BA75166B5C215767B1D6934E50C3DB36E89B127B8A622B120F6721"

pub fn rfc6979_p256_sample_message_test() {
  // Vector for message = "sample".
  // Expected:
  //   r = EFD48B2AACB6A8FD1140DD9CD45E81D69D2C877B56AAF991C34D0EA84EAF3716
  //   s = F7CB1C942D657C41D436C7A1B6E29F65F3E900DBB9AFF4064DC4AB2F843ACDA8
  let d = decode_hex(test_private_hex)
  let h = crypto.sha256(bit_array.from_string("sample"))
  let #(r_hex, s_hex) = ecdsa_deterministic.sign_p256_rs_hex(d, h)
  string.lowercase(r_hex)
  |> should.equal(
    "efd48b2aacb6a8fd1140dd9cd45e81d69d2c877b56aaf991c34d0ea84eaf3716",
  )
  string.lowercase(s_hex)
  |> should.equal(
    "f7cb1c942d657c41d436c7a1b6e29f65f3e900dbb9aff4064dc4ab2f843acda8",
  )
}

pub fn rfc6979_p256_test_message_test() {
  // Vector for message = "test".
  //   r = F1ABB023518351CD71D881567B1EA663ED3EFCF6C5132B354F28D3B0B7D38367
  //   s = 019F4113742A2B14BD25926B49C649155F267E60D3814B4C0CC84250E46F0083
  let d = decode_hex(test_private_hex)
  let h = crypto.sha256(bit_array.from_string("test"))
  let #(r_hex, s_hex) = ecdsa_deterministic.sign_p256_rs_hex(d, h)
  string.lowercase(r_hex)
  |> should.equal(
    "f1abb023518351cd71d881567b1ea663ed3efcf6c5132b354f28d3b0b7d38367",
  )
  string.lowercase(s_hex)
  |> should.equal(
    "019f4113742a2b14bd25926b49c649155f267e60d3814b4c0cc84250e46f0083",
  )
}

pub fn deterministic_p256_is_deterministic_test() {
  // Two calls with the same (key, message-hash) must produce
  // identical DER signatures — that's the entire point of RFC 6979.
  let d = decode_hex(test_private_hex)
  let h = crypto.sha256(bit_array.from_string("sample"))
  let a = ecdsa_deterministic.sign_p256(d, h)
  let b = ecdsa_deterministic.sign_p256(d, h)
  a |> should.equal(b)
}

pub fn deterministic_p256_der_round_trip_verify_test() {
  // The DER-encoded signature from sign_p256 must verify against
  // the corresponding public key — sanity-check that we're emitting
  // a structurally valid signature, not just numerically correct
  // (r, s) hidden behind a broken DER wrapper.
  let d = decode_hex(test_private_hex)
  let msg = bit_array.from_string("sample")
  let h = crypto.sha256(msg)
  let sig_der = ecdsa_deterministic.sign_p256(d, h)
  let pubkey = ecdsa_p256_public_key(d)
  // The existing FFI hashes `msg` internally; that hash equals `h`
  // so a signature over `h` verifies as a signature over `msg`.
  ecdsa_p256_verify(pubkey, msg, sig_der)
  |> should.be_true
}

@external(erlang, "binary", "decode_hex")
fn decode_hex(s: String) -> BitArray

@external(erlang, "aws_ffi", "ecdsa_p256_public_key")
fn ecdsa_p256_public_key(scalar: BitArray) -> BitArray

@external(erlang, "aws_ffi", "ecdsa_p256_verify")
fn ecdsa_p256_verify(
  public_key: BitArray,
  message: BitArray,
  signature: BitArray,
) -> Bool
