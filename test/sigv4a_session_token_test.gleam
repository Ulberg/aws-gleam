//// Pins for `Sigv4aCredentials` + the session-token codepath. The
//// canonical request adds an `X-Amz-Security-Token` header when the
//// credentials carry a `Some(token)`, and that header is included
//// in `SignedHeaders`. Round-trip verification (sign → public-key
//// verify) closes the loop: if the canonical request is constructed
//// wrong, the signer + verifier disagree and `ecdsa_p256_verify`
//// returns `False`.

import aws/internal/http_request.{
  type Header, type HttpRequest, Header, HttpRequest,
}
import aws/internal/sigv4a
import gleam/bit_array
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

const access_key_id: String = "AKIDEXAMPLE"

const secret_access_key: String = "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY"

const session_token: String = "6e86291e8372ff2a2260956d9b8aae1d763fbf315fa00fa31553b73ebf194267"

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

fn credentials_with_token() -> sigv4a.Sigv4aCredentials {
  let key = sigv4a.derive_signing_key(access_key_id, secret_access_key)
  sigv4a.Sigv4aCredentials(
    access_key_id: access_key_id,
    private_key: key,
    session_token: Some(session_token),
  )
}

fn credentials_without_token() -> sigv4a.Sigv4aCredentials {
  let key = sigv4a.derive_signing_key(access_key_id, secret_access_key)
  sigv4a.Sigv4aCredentials(
    access_key_id: access_key_id,
    private_key: key,
    session_token: None,
  )
}

pub fn sign_with_credentials_adds_security_token_header_test() {
  let signed =
    sigv4a.sign_with_credentials(
      example_request(),
      credentials_with_token(),
      example_opts(),
    )
  case find_header(signed.headers, "X-Amz-Security-Token") {
    Ok(v) -> v |> should.equal(session_token)
    Error(_) ->
      panic as "X-Amz-Security-Token header missing when session_token is Some"
  }
}

pub fn sign_with_credentials_no_token_omits_security_token_header_test() {
  let signed =
    sigv4a.sign_with_credentials(
      example_request(),
      credentials_without_token(),
      example_opts(),
    )
  case find_header(signed.headers, "X-Amz-Security-Token") {
    Ok(_) ->
      panic as "X-Amz-Security-Token header present when session_token is None"
    Error(_) -> Nil
  }
}

pub fn sign_with_credentials_token_is_in_signed_headers_test() {
  // The canonical-request `SignedHeaders` line must include
  // `x-amz-security-token` when the token is present; otherwise
  // the server-side recomputation hashes a different canonical
  // request and the signature fails. The Authorization header
  // includes the SignedHeaders=... list literally, so we can
  // assert against it directly.
  let signed =
    sigv4a.sign_with_credentials(
      example_request(),
      credentials_with_token(),
      example_opts(),
    )
  let assert Ok(auth) = find_header(signed.headers, "Authorization")
  string.contains(auth, "SignedHeaders=")
  |> should.be_true
  string.contains(auth, "x-amz-security-token")
  |> should.be_true
}

pub fn sign_with_credentials_round_trip_verifies_with_token_test() {
  // End-to-end: signing with a token must produce a signature that
  // verifies against the derived public key. Catches regressions in
  // either the new code path or its interaction with the existing
  // canonical-request construction.
  let creds = credentials_with_token()
  let signed =
    sigv4a.sign_with_credentials(example_request(), creds, example_opts())
  let assert Ok(auth) = find_header(signed.headers, "Authorization")
  let assert Ok(sig_hex) = extract_signature(auth)
  let sig_bytes = decode_hex(sig_hex)
  let creq = canonical_for_round_trip(signed)
  let creq_hash = crypto_hex_encode(crypto_sha256(bit_array.from_string(creq)))
  let sts =
    "AWS4-ECDSA-P256-SHA256\n20150830T123600Z\n20150830/service/aws4_request\n"
    <> creq_hash

  let sigv4a.Sigv4aCredentials(private_key:, ..) = creds
  let sigv4a.EcdsaPrivateKey(scalar:) = private_key
  let pubkey = sigv4a.ecdsa_p256_public_key(scalar)
  sigv4a.ecdsa_p256_verify(pubkey, bit_array.from_string(sts), sig_bytes)
  |> should.be_true
}

// ---------- helpers ----------

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

/// Rebuild the canonical request from a signed request. All
/// non-Authorization headers participate — including
/// `x-amz-security-token` when present — so the reconstruction
/// matches what the signer hashed regardless of which headers
/// were injected by `prepare_headers`.
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
