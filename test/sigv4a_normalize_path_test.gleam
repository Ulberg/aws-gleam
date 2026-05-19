//// Pin for `Sigv4aOptions.normalize_path`. When `True`, the
//// canonical URI applies RFC 3986 dot-segment removal (`/foo/./bar`
//// → `/foo/bar`, `/foo/../baz` → `/baz`) before percent-encoding.
//// Matches the behaviour of `sigv4.normalize_path` and is required
//// to pin against the `get-*-normalized` aws-c-auth v4a fixtures.
////
//// When `False`, the path passes through unchanged (only
//// percent-encoded). aws-c-auth's `*-unnormalized` fixtures rely
//// on this.

import aws/internal/http_request.{
  type Header, type HttpRequest, Header, HttpRequest,
}
import aws/internal/sigv4a
import gleam/bit_array
import gleam/list
import gleam/option.{None}
import gleam/string
import gleeunit/should

fn dotty_request() -> HttpRequest {
  HttpRequest(
    method: "GET",
    path: "/foo/./bar/../baz",
    query: "",
    headers: [Header(name: "Host", value: "example.amazonaws.com")],
    body: <<>>,
  )
}

fn example_opts(normalize: Bool) -> sigv4a.Sigv4aOptions {
  sigv4a.Sigv4aOptions(
    timestamp: "20150830T123600Z",
    region_set: ["us-east-1"],
    service: "service",
    sign_body: False,
    normalize_path: normalize,
  )
}

fn credentials() -> sigv4a.Sigv4aCredentials {
  let key =
    sigv4a.derive_signing_key(
      "AKIDEXAMPLE",
      "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    )
  sigv4a.Sigv4aCredentials(
    access_key_id: "AKIDEXAMPLE",
    private_key: key,
    session_token: None,
  )
}

pub fn normalize_true_collapses_dot_segments_test() {
  // Round-trip: sign with normalize_path: True, reconstruct what
  // the signer hashed, then verify with the public key.
  // `/foo/./bar/../baz` reduces to `/foo/baz`: the `.` is dropped,
  // and `..` pops the prior segment (`bar`) only — `foo` survives.
  // If the canonical URI line is the unnormalized form, the
  // reconstruction below won't match and verification fails.
  let signed =
    sigv4a.sign_with_credentials(
      dotty_request(),
      credentials(),
      example_opts(True),
    )
  let assert Ok(auth) = find_header(signed.headers, "Authorization")
  let assert Ok(sig_hex) = extract_signature(auth)
  let sig_bytes = decode_hex(sig_hex)
  let creq = canonical_for_round_trip(signed, "/foo/baz")
  let creq_hash = crypto_hex_encode(crypto_sha256(bit_array.from_string(creq)))
  let sts =
    "AWS4-ECDSA-P256-SHA256\n20150830T123600Z\n20150830/service/aws4_request\n"
    <> creq_hash

  let sigv4a.Sigv4aCredentials(private_key:, ..) = credentials()
  let sigv4a.EcdsaPrivateKey(scalar:) = private_key
  let pubkey = sigv4a.ecdsa_p256_public_key(scalar)
  sigv4a.ecdsa_p256_verify(pubkey, bit_array.from_string(sts), sig_bytes)
  |> should.be_true
}

pub fn normalize_false_preserves_dot_segments_test() {
  // Mirror of the above but with normalize_path: False — the
  // canonical URI should keep `/foo/./bar/../baz` literal, so the
  // reconstruction targets the unnormalized form (percent-encoded
  // since `encode_path` URI-encodes each segment, but `.` and
  // `..` are unreserved and pass through).
  let signed =
    sigv4a.sign_with_credentials(
      dotty_request(),
      credentials(),
      example_opts(False),
    )
  let assert Ok(auth) = find_header(signed.headers, "Authorization")
  let assert Ok(sig_hex) = extract_signature(auth)
  let sig_bytes = decode_hex(sig_hex)
  let creq = canonical_for_round_trip(signed, "/foo/./bar/../baz")
  let creq_hash = crypto_hex_encode(crypto_sha256(bit_array.from_string(creq)))
  let sts =
    "AWS4-ECDSA-P256-SHA256\n20150830T123600Z\n20150830/service/aws4_request\n"
    <> creq_hash

  let sigv4a.Sigv4aCredentials(private_key:, ..) = credentials()
  let sigv4a.EcdsaPrivateKey(scalar:) = private_key
  let pubkey = sigv4a.ecdsa_p256_public_key(scalar)
  sigv4a.ecdsa_p256_verify(pubkey, bit_array.from_string(sts), sig_bytes)
  |> should.be_true
}

pub fn normalize_true_root_path_stays_slash_test() {
  // `/` is the identity for normalisation — neither `.` nor `..`
  // present. Both modes should sign identically; we just check
  // that sign_with_credentials doesn't blow up on the edge case.
  let req =
    HttpRequest(
      method: "GET",
      path: "/",
      query: "",
      headers: [Header(name: "Host", value: "example.amazonaws.com")],
      body: <<>>,
    )
  let signed =
    sigv4a.sign_with_credentials(req, credentials(), example_opts(True))
  find_header(signed.headers, "Authorization")
  |> should.be_ok
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

fn canonical_for_round_trip(
  signed: HttpRequest,
  canonical_uri: String,
) -> String {
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
  <> canonical_uri
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
