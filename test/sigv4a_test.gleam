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

import aws/internal/http_request.{
  type Header, type HttpRequest, Header, HttpRequest,
}
import aws/internal/sigv4a
import gleam/bit_array
import gleam/list
import gleam/string
import gleeunit/should

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
  let creq = canonical_for_round_trip(signed)
  let creq_hash = crypto_hex_encode(crypto_sha256(bit_array.from_string(creq)))
  let sts =
    "AWS4-ECDSA-P256-SHA256\n20150830T123600Z\n20150830/service/aws4_request\n"
    <> creq_hash
  sigv4a.ecdsa_p256_verify(public_key(), bit_array.from_string(sts), sig_bytes)
  |> should.be_true
}

// ---------- test helpers ----------

fn find_header(headers: List(Header), name: String) -> Result(String, Nil) {
  case
    list.find(headers, fn(h) {
      string.lowercase(h.name) == string.lowercase(name)
    })
  {
    Ok(h) -> Ok(h.value)
    Error(_) -> Error(Nil)
  }
}

fn extract_signature(auth: String) -> Result(String, Nil) {
  case string.split_once(auth, "Signature=") {
    Ok(#(_, sig)) -> Ok(sig)
    Error(_) -> Error(Nil)
  }
}

/// Rebuild the canonical request that `sign` would have produced
/// from the final signed request. The `Authorization` header is
/// NOT part of the canonical request, so we strip it before
/// rebuilding.
fn canonical_for_round_trip(signed: HttpRequest) -> String {
  let signing_headers =
    list.filter(signed.headers, fn(h) {
      string.lowercase(h.name) != "authorization"
    })
  let sorted =
    signing_headers
    |> list.map(fn(h) { #(string.lowercase(h.name), string.trim(h.value)) })
    |> list.sort(by: fn(a, b) { string.compare(a.0, b.0) })
  let headers_block =
    sorted
    |> list.map(fn(p) { p.0 <> ":" <> p.1 <> "\n" })
    |> string.concat
  let signed_names =
    sorted
    |> list.map(fn(p) { p.0 })
    |> list.unique
    |> string.join(";")
  let payload_hash = crypto_hex_encode(crypto_sha256(bit_array.from_string("")))
  signed.method
  <> "\n"
  <> signed.path
  <> "\n"
  <> ""
  <> "\n"
  <> headers_block
  <> "\n"
  <> signed_names
  <> "\n"
  <> payload_hash
}

@external(erlang, "aws_ffi", "sha256")
fn crypto_sha256(data: BitArray) -> BitArray

@external(erlang, "aws_ffi", "hex_encode")
fn crypto_hex_encode(data: BitArray) -> String

@external(erlang, "binary", "decode_hex")
fn decode_hex_ffi(s: String) -> BitArray

fn decode_hex(s: String) -> BitArray {
  decode_hex_ffi(s)
}
