//// Shared helpers for the SigV4a test files. The
//// `sigv4a_iam_credentials_test`, `sigv4a_session_token_test`, and
//// `sigv4a_normalize_path_test` files used to carry their own
//// copies of `find_header` / `extract_signature` / the round-trip
//// canonical-request reconstruction + three crypto FFI shims —
//// every change in one place had to be mirrored in the others.
////
//// The round-trip helper rebuilds the canonical request from a
//// signed request so round-trip tests can hash it the same way
//// the signer did and verify the resulting signature against the
//// public key. It deliberately accepts `canonical_uri` as an
//// argument so callers can drive both the "no normalisation"
//// (`signed.path`) and "explicit URI" (test the path-normalisation
//// branch) shapes through one function.

import aws/internal/http_request.{type Header, type HttpRequest}
import gleam/bit_array
import gleam/list
import gleam/string

pub fn find_header(headers: List(Header), name: String) -> Result(String, Nil) {
  case
    list.find(headers, fn(h) {
      string.lowercase(h.name) == string.lowercase(name)
    })
  {
    Ok(h) -> Ok(h.value)
    Error(_) -> Error(Nil)
  }
}

pub fn extract_signature(auth: String) -> Result(String, Nil) {
  case string.split_once(auth, "Signature=") {
    Ok(#(_, sig)) -> Ok(sig)
    Error(_) -> Error(Nil)
  }
}

/// Rebuild the canonical request the signer would have produced
/// from the final signed request. `canonical_uri` is supplied
/// explicitly so callers can pass either `signed.path` (no
/// normalisation) or a known-normalised URI (for the
/// normalize_path round-trip).
pub fn canonical_for_round_trip(
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
pub fn crypto_sha256(data: BitArray) -> BitArray

@external(erlang, "aws_ffi", "hex_encode")
pub fn crypto_hex_encode(data: BitArray) -> String

@external(erlang, "binary", "decode_hex")
pub fn decode_hex(s: String) -> BitArray
