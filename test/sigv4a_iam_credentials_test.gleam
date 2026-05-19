//// Pin for `sigv4a.sign_with_iam_credentials` — the convenience
//// wrapper that takes the IAM (access-key-id, secret-access-key)
//// pair directly instead of a pre-derived `EcdsaPrivateKey`.
//// Equivalent to `sign(req, derive_signing_key(akid, secret), akid, opts)`
//// but spares callers the two-step boilerplate.
////
//// Verification uses the round-trip pattern from `sigv4a_test`:
//// sign, parse the signature out of the `Authorization` header,
//// then verify it against the EC public key derived from the
//// same IAM pair. A regression in either the key derivation or
//// the signing pipeline shows up here as a verification failure.

import aws/internal/http_request.{
  type Header, type HttpRequest, Header, HttpRequest,
}
import aws/internal/sigv4a
import gleam/bit_array
import gleam/list
import gleam/string
import gleeunit/should

const access_key_id: String = "AKIDEXAMPLE"

const secret_access_key: String = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"

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
  )
}

pub fn sign_with_iam_credentials_emits_sigv4a_authorization_test() {
  let signed =
    sigv4a.sign_with_iam_credentials(
      example_request(),
      access_key_id,
      secret_access_key,
      example_opts(),
    )
  case find_header(signed.headers, "Authorization") {
    Ok(v) ->
      string.starts_with(v, "AWS4-ECDSA-P256-SHA256 Credential=AKIDEXAMPLE/")
      |> should.be_true
    Error(_) -> should.fail()
  }
}

pub fn sign_with_iam_credentials_round_trip_verifies_test() {
  // End-to-end: the wrapper signs with a derived key; the verifier
  // recomputes the same key derivation, projects to the public key,
  // and checks the signature. A regression anywhere in
  // (derive_signing_key, ecdsa_p256_public_key, sign) surfaces here.
  let signed =
    sigv4a.sign_with_iam_credentials(
      example_request(),
      access_key_id,
      secret_access_key,
      example_opts(),
    )
  let assert Ok(auth) = find_header(signed.headers, "Authorization")
  let assert Ok(sig_hex) = extract_signature(auth)
  let sig_bytes = decode_hex(sig_hex)
  let creq = canonical_for_round_trip(signed)
  let creq_hash = crypto_hex_encode(crypto_sha256(bit_array.from_string(creq)))
  let sts =
    "AWS4-ECDSA-P256-SHA256\n20150830T123600Z\n20150830/service/aws4_request\n"
    <> creq_hash

  let sigv4a.EcdsaPrivateKey(scalar:) =
    sigv4a.derive_signing_key(access_key_id, secret_access_key)
  let pubkey = sigv4a.ecdsa_p256_public_key(scalar)
  sigv4a.ecdsa_p256_verify(pubkey, bit_array.from_string(sts), sig_bytes)
  |> should.be_true
}

// ---------- helpers (mirror sigv4a_test.gleam) ----------

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
fn decode_hex(s: String) -> BitArray
