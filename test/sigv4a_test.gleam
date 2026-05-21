//// Tests for `sigv4a.sign` — the asymmetric ECDSA P-256 variant
//// of AWS Signature Version 4 used by S3 Multi-Region Access
//// Points.
////
//// Erlang's `crypto:sign/4` uses random ECDSA nonces, so we
//// can't compare against fixed reference signatures byte-for-
//// byte. Instead the tests round-trip: sign with the private
//// key, parse the signature out of the `Authorization` header,
//// then verify it with the matching public key. A regression in
//// canonical-request construction surfaces as a verification
//// failure (the server-side check signs the same canonical
//// request hash, so any mismatch breaks the round-trip).

import aws/internal/http_request.{type HttpRequest, Header, HttpRequest}
import aws/internal/sigv4a
import gleam/bit_array
import gleam/string
import gleeunit/should
import support/sigv4a_test_helpers.{
  canonical_for_round_trip, crypto_hex_encode, crypto_sha256, decode_hex,
  extract_signature, find_header,
}

// A known P-256 test key pair from NIST FIPS 186-4 §D.1.1 (used
// by RFC 6979 example vectors).
const test_private_hex = "C9AFA9D845BA75166B5C215767B1D6934E50C3DB36E89B127B8A622B120F6721"

// SEC1 uncompressed public key (`04 || X || Y`) corresponding to
// the private key above.
const test_public_hex = "0460FED4BA255A9D31C961EB74C6356D68C049B8923B61FA6CE669622E60F29FB67903FE1008B8BC99A41AE9E95628BC64F2F1B20C2D7E9F5177A3C294D4462299"

fn private_key() -> sigv4a.EcdsaPrivateKey {
  let bytes = decode_hex(test_private_hex)
  let assert Ok(key) = sigv4a.ecdsa_private_key_from_bytes(bytes)
  key
}

fn public_key() -> BitArray {
  decode_hex(test_public_hex)
}

fn example_request() -> HttpRequest {
  HttpRequest(
    method: "GET",
    path: "/",
    query: "",
    headers: [Header(name: "Host", value: "example.amazonaws.com")],
    body: <<>>,
  )
}

fn example_opts() -> sigv4a.Sigv4aOptions {
  sigv4a.Sigv4aOptions(
    timestamp: "20150830T123600Z",
    region_set: ["us-east-1"],
    service: "service",
    sign_body: False,
    normalize_path: True,
    omit_session_token: False,
  )
}

pub fn sign_adds_authorization_header_test() {
  let signed =
    sigv4a.sign(example_request(), private_key(), "AKIDEXAMPLE", example_opts())
  case find_header(signed.headers, "Authorization") {
    Ok(v) ->
      string.starts_with(v, "AWS4-ECDSA-P256-SHA256 Credential=AKIDEXAMPLE/")
      |> should.be_true
    Error(_) -> should.fail()
  }
}

pub fn sign_adds_region_set_header_test() {
  let signed =
    sigv4a.sign(
      example_request(),
      private_key(),
      "AKIDEXAMPLE",
      sigv4a.Sigv4aOptions(
        timestamp: "20150830T123600Z",
        region_set: ["us-east-1", "us-west-2"],
        service: "service",
        sign_body: False,
        normalize_path: True,
        omit_session_token: False,
      ),
    )
  find_header(signed.headers, "X-Amz-Region-Set")
  |> should.equal(Ok("us-east-1,us-west-2"))
}

pub fn sign_signature_verifies_with_public_key_test() {
  // Round-trip: sign, parse the Authorization header, then verify
  // the signature with the matching public key. A regression in
  // canonical-request or string-to-sign construction shows up
  // here as a verification failure (the verifier is fed the same
  // canonical request the signer produced).
  let signed =
    sigv4a.sign(example_request(), private_key(), "AKIDEXAMPLE", example_opts())
  let assert Ok(auth) = find_header(signed.headers, "Authorization")
  let assert Ok(sig_hex) = extract_signature(auth)
  let sig_bytes = decode_hex(sig_hex)
  let creq = canonical_for_round_trip(signed, signed.path)
  let creq_hash = crypto_hex_encode(crypto_sha256(bit_array.from_string(creq)))
  let sts =
    "AWS4-ECDSA-P256-SHA256\n20150830T123600Z\n20150830/service/aws4_request\n"
    <> creq_hash
  sigv4a.ecdsa_p256_verify(public_key(), bit_array.from_string(sts), sig_bytes)
  |> should.be_true
}
