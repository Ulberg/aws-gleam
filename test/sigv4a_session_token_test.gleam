//// Pins for `Sigv4aCredentials` + the session-token codepath. The
//// canonical request adds an `X-Amz-Security-Token` header when the
//// credentials carry a `Some(token)`, and that header is included
//// in `SignedHeaders`. Round-trip verification (sign → public-key
//// verify) closes the loop: if the canonical request is constructed
//// wrong, the signer + verifier disagree and `ecdsa_p256_verify`
//// returns `False`.

import aws/internal/http_request.{type HttpRequest, Header, HttpRequest}
import aws/internal/sigv4a
import gleam/bit_array
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should
import support/sigv4a_test_helpers.{
  canonical_for_round_trip, crypto_hex_encode, crypto_sha256, decode_hex,
  extract_signature, find_header,
}

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
    normalize_path: True,
    omit_session_token: False,
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
  let creq = canonical_for_round_trip(signed, signed.path)
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
