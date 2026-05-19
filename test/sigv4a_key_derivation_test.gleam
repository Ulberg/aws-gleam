//// Pins for `sigv4a.derive_signing_key/2` — the deterministic IAM-secret-to-
//// EC-scalar derivation that AWS uses for SigV4a. Without this, the
//// `sigv4a.sign` entry point is unreachable for real users (they'd need a
//// pre-derived 32-byte P-256 scalar from somewhere). The aws-c-auth test
//// suite under `v4a/*` ships one shared `public-key.json` per fixture —
//// every fixture uses the canonical `AKIDEXAMPLE` / `wJalrXUtnFEMI...`
//// credential pair, so the expected uncompressed public key (`04 || X || Y`)
//// is the same across the suite. We pin against the X / Y from
//// `get-vanilla-utf8-query/public-key.json`.

import aws/internal/crypto
import aws/internal/sigv4a
import gleam/bit_array
import gleam/string
import gleeunit/should

const access_key_id: String = "AKIDEXAMPLE"

const secret_access_key: String = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"

/// X coordinate from
/// `test/fixtures/aws-c-auth/tests/aws-signing-test-suite/v4a/get-vanilla-utf8-query/public-key.json`.
const expected_x: String = "b6618f6a65740a99e650b33b6b4b5bd0d43b176d721a3edfea7e7d2d56d936b1"

/// Y coordinate from the same fixture.
const expected_y: String = "865ed22a7eadc9c5cb9d2cbaca1b3699139fedc5043dc6661864218330c8e518"

pub fn derive_signing_key_matches_aws_c_auth_public_key_test() {
  let key = sigv4a.derive_signing_key(access_key_id, secret_access_key)
  let sigv4a.EcdsaPrivateKey(scalar:) = key
  bit_array.byte_size(scalar) |> should.equal(32)

  // Derive the uncompressed SEC1 public key (`04 || X || Y`) via Erlang's
  // `crypto:generate_key(ecdh, secp256r1, _)` — same curve as ECDSA P-256.
  let pubkey = sigv4a.ecdsa_p256_public_key(scalar)
  bit_array.byte_size(pubkey) |> should.equal(65)

  let assert <<4, x:bytes-size(32), y:bytes-size(32)>> = pubkey
  crypto.hex_encode(x) |> string.lowercase |> should.equal(expected_x)
  crypto.hex_encode(y) |> string.lowercase |> should.equal(expected_y)
}

pub fn derive_signing_key_is_deterministic_test() {
  // Two calls with the same IAM pair must yield the same scalar — the
  // derivation is a pure function of (access_key_id, secret_access_key),
  // not a random keygen.
  let a = sigv4a.derive_signing_key(access_key_id, secret_access_key)
  let b = sigv4a.derive_signing_key(access_key_id, secret_access_key)
  let sigv4a.EcdsaPrivateKey(scalar: sa) = a
  let sigv4a.EcdsaPrivateKey(scalar: sb) = b
  sa |> should.equal(sb)
}

pub fn derive_signing_key_differs_by_access_key_id_test() {
  // Same secret + different access key id ⇒ different EC scalar.
  let a = sigv4a.derive_signing_key("AKIDEXAMPLE", secret_access_key)
  let b = sigv4a.derive_signing_key("OTHERAKID", secret_access_key)
  let sigv4a.EcdsaPrivateKey(scalar: sa) = a
  let sigv4a.EcdsaPrivateKey(scalar: sb) = b
  case sa == sb {
    True ->
      panic as "derive_signing_key should differ when access_key_id differs"
    False -> Nil
  }
}
