//// RFC 6979 deterministic ECDSA over NIST P-256 with SHA-256.
////
//// The standard ECDSA algorithm picks a fresh random nonce `k` per
//// signature; the signature varies between two signings of the
//// same `(key, message)`. Erlang's `crypto:sign/4` follows that
//// model — signatures are valid (server-side verify works) but
//// not byte-reproducible. RFC 6979 derives `k` deterministically
//// from `(d, h1)` via HMAC-DRBG, making signatures byte-for-byte
//// reproducible against the reference vectors in §A.2.5 and
//// against the aws-c-auth v4a corpus.
////
//// **Architecture.** The HMAC-DRBG nonce derivation, modular
//// arithmetic, and DER encoding are pure Gleam. The one expensive
//// step — the elliptic-curve point multiplication `k·G` — is
//// outsourced to Erlang's `crypto:generate_key(ecdh, secp256r1, k)`
//// via the existing `aws_ffi:ecdsa_p256_public_key/1` FFI. That
//// gives us the X coordinate of `k·G` from which the `r` half of
//// the signature is `X mod q`. Computing `s` and DER-encoding the
//// `(r, s)` pair is then pure integer arithmetic, which BEAM
//// bignums handle natively.

import aws/internal/crypto
import gleam/bit_array

/// NIST P-256 (secp256r1) curve order. Defined in NIST SP 800-186
/// §3.2.1.3. Every ECDSA-over-P256 scalar is reduced mod this.
const p256_order: Int = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551

/// Sign a 32-byte SHA-256 hash with a 32-byte P-256 private scalar.
/// Returns the DER-encoded `(r, s)` blob — the same shape Erlang's
/// `crypto:sign/4` returns for `ecdsa`, so callers can swap the two
/// without touching downstream code.
pub fn sign_p256(private_key: BitArray, message_hash: BitArray) -> BitArray {
  let #(r, s) = sign_p256_rs(private_key, message_hash)
  der_encode_sig(r, s)
}

/// Same signature as `sign_p256` but returns `(r_hex, s_hex)` as
/// 64-character lowercase strings. Test-side helper for matching
/// against the RFC 6979 reference vectors which list `r` / `s` as
/// hex.
pub fn sign_p256_rs_hex(
  private_key: BitArray,
  message_hash: BitArray,
) -> #(String, String) {
  let #(r, s) = sign_p256_rs(private_key, message_hash)
  #(int_to_hex_256(r), int_to_hex_256(s))
}

fn sign_p256_rs(private_key: BitArray, message_hash: BitArray) -> #(Int, Int) {
  let assert <<d:size(256)-big-unsigned>> = private_key
  let assert <<e:size(256)-big-unsigned>> = message_hash
  let e_mod_q = e % p256_order
  sign_retry_loop(private_key, message_hash, d, e_mod_q, 0)
}

/// RFC 6979's outer retry loop: if `r == 0` or `s == 0` (both
/// statistically impossible — ~2^-256 each — but the spec mandates
/// the retry), pull a fresh `k` from the HMAC-DRBG and try again.
/// The `attempt` arg threads into the nonce derivation so successive
/// tries don't keep producing the same `k`.
fn sign_retry_loop(
  private_key: BitArray,
  message_hash: BitArray,
  d: Int,
  e: Int,
  attempt: Int,
) -> #(Int, Int) {
  case attempt > 100 {
    True ->
      // Unreachable in practice; guard against pathological inputs.
      panic as "RFC 6979 sign: exceeded 100 nonce-retry attempts"
    False -> {
      let #(_, k) = derive_nonce(private_key, message_hash, attempt)
      // k·G via the existing scalar-multiplication FFI. The returned
      // uncompressed SEC1 form is `04 || X(32) || Y(32)`; we want
      // the X coordinate.
      let k_padded = pad_to_32(<<k:size(256)-big>>)
      let pubkey = ecdsa_p256_public_key(k_padded)
      let assert <<_:8, x_r:size(256)-big-unsigned, _:256>> = pubkey
      let r = x_r % p256_order
      case r == 0 {
        True -> sign_retry_loop(private_key, message_hash, d, e, attempt + 1)
        False -> {
          let k_inv = mod_inverse(k, p256_order)
          let s =
            mod_mul(
              k_inv,
              mod_add(e, mod_mul(r, d, p256_order), p256_order),
              p256_order,
            )
          case s == 0 {
            True ->
              sign_retry_loop(private_key, message_hash, d, e, attempt + 1)
            False -> #(r, s)
          }
        }
      }
    }
  }
}

/// HMAC-DRBG nonce derivation per RFC 6979 §3.2. Returns the
/// nonce both as a 32-byte big-endian bit array (for the
/// EC point-multiplication FFI) and as an integer (for the
/// `(r, s)` computation). `attempt` only matters when the outer
/// retry loop fires; for the typical `attempt = 0` path it returns
/// the canonical nonce.
fn derive_nonce(
  d_bytes: BitArray,
  h1: BitArray,
  attempt: Int,
) -> #(BitArray, Int) {
  let assert <<h1_int:size(256)-big-unsigned>> = h1
  let h1_mod_q = h1_int % p256_order
  let bits2octets_h1 = <<h1_mod_q:size(256)-big>>

  let v0 = repeat_byte(0x01, 32)
  let k0 = repeat_byte(0x00, 32)

  // Steps d-g of RFC 6979 §3.2.
  let k1 =
    crypto.hmac_sha256(k0, <<
      v0:bits, 0:size(8), d_bytes:bits, bits2octets_h1:bits,
    >>)
  let v1 = crypto.hmac_sha256(k1, v0)
  let k2 =
    crypto.hmac_sha256(k1, <<
      v1:bits, 1:size(8), d_bytes:bits, bits2octets_h1:bits,
    >>)
  let v2 = crypto.hmac_sha256(k2, v1)

  // Step h-k: each HMAC of V produces exactly 32 bytes = qlen
  // bits, so T = V after one round. Inner concatenation loop is
  // not needed for P-256 / SHA-256.
  nonce_loop(k2, v2, attempt)
}

fn nonce_loop(k: BitArray, v: BitArray, skip: Int) -> #(BitArray, Int) {
  let v_new = crypto.hmac_sha256(k, v)
  let assert <<candidate:size(256)-big-unsigned>> = v_new
  case candidate >= 1 && candidate < p256_order && skip == 0 {
    True -> #(v_new, candidate)
    False -> {
      // Either the candidate is out of range, OR we're being asked
      // to skip `skip` valid candidates (the outer retry path).
      let k_next = crypto.hmac_sha256(k, <<v_new:bits, 0:size(8)>>)
      let v_next = crypto.hmac_sha256(k_next, v_new)
      let next_skip = case candidate >= 1 && candidate < p256_order {
        True -> skip - 1
        False -> skip
      }
      nonce_loop(k_next, v_next, next_skip)
    }
  }
}

// ---------- modular arithmetic ----------

fn mod_add(a: Int, b: Int, m: Int) -> Int {
  { a + b } % m
}

fn mod_mul(a: Int, b: Int, m: Int) -> Int {
  a * b % m
}

/// Modular inverse via the extended Euclidean algorithm. Caller
/// guarantees `gcd(a, m) == 1` — P-256's order is prime so any
/// `a ∈ [1, q-1]` is coprime to `q`.
fn mod_inverse(a: Int, m: Int) -> Int {
  let #(_g, x, _y) = ext_gcd(a, m)
  let result = x % m
  case result < 0 {
    True -> result + m
    False -> result
  }
}

fn ext_gcd(a: Int, b: Int) -> #(Int, Int, Int) {
  case b {
    0 -> #(a, 1, 0)
    _ -> {
      let #(g, x1, y1) = ext_gcd(b, a % b)
      #(g, y1, x1 - { a / b } * y1)
    }
  }
}

// ---------- DER encoding ----------

fn der_encode_sig(r: Int, s: Int) -> BitArray {
  let r_int = der_int_bytes(r)
  let s_int = der_int_bytes(s)
  let inner_len = bit_array.byte_size(r_int) + bit_array.byte_size(s_int)
  <<0x30, inner_len:size(8), r_int:bits, s_int:bits>>
}

/// DER `INTEGER`: `0x02 LL <bytes>`. Bytes are the minimum-length
/// big-endian magnitude of `n` with a 0x00 prefix when the high bit
/// of the magnitude is set (so it reads as unsigned).
fn der_int_bytes(n: Int) -> BitArray {
  let raw = strip_leading_zeros(<<n:size(256)-big>>)
  let prefixed = case high_bit_set(raw) {
    True -> <<0:size(8), raw:bits>>
    False -> raw
  }
  <<0x02, { bit_array.byte_size(prefixed) }:size(8), prefixed:bits>>
}

fn strip_leading_zeros(b: BitArray) -> BitArray {
  case b {
    <<0:size(8), rest:bits>> ->
      case bit_array.byte_size(rest) > 0 {
        True -> strip_leading_zeros(rest)
        False -> b
      }
    _ -> b
  }
}

fn high_bit_set(b: BitArray) -> Bool {
  case b {
    <<first:size(8), _:bits>> -> first >= 0x80
    _ -> False
  }
}

// ---------- bit / hex helpers ----------

fn repeat_byte(byte: Int, count: Int) -> BitArray {
  do_repeat(byte, count, <<>>)
}

fn do_repeat(byte: Int, remaining: Int, acc: BitArray) -> BitArray {
  case remaining {
    0 -> acc
    _ -> do_repeat(byte, remaining - 1, <<acc:bits, byte:size(8)>>)
  }
}

/// Bit-pattern `<<k:size(256)-big-unsigned>>` always produces 32
/// bytes regardless of `k`'s magnitude. Provided as a function for
/// signature clarity / future-proofing if we need to accept
/// shorter inputs.
fn pad_to_32(b: BitArray) -> BitArray {
  b
}

fn int_to_hex_256(n: Int) -> String {
  crypto.hex_encode(<<n:size(256)-big>>)
}

@external(erlang, "aws_ffi", "ecdsa_p256_public_key")
fn ecdsa_p256_public_key(scalar: BitArray) -> BitArray
