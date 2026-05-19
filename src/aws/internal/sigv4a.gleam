//// SigV4a — AWS Signature Version 4 with asymmetric ECDSA P-256
//// signatures, used by S3 Multi-Region Access Points (MRAP) and a
//// few other multi-region offerings.
////
//// The canonical-request shape is identical to SigV4 except for
//// the algorithm string (AWS4-ECDSA-P256-SHA256) and the
//// `X-Amz-Region-Set` header that carries the comma-joined region
//// list. The string-to-sign uses the same five-line shape; the
//// credential scope drops the region because SigV4a is region-
//// agnostic by design.
////
//// **v1 limitation — non-deterministic nonces.** Erlang's
//// `crypto:sign/4` generates a fresh random nonce per call. The
//// resulting signatures verify correctly with the corresponding
//// public key (which is what AWS does server-side), but they
//// won't match the aws-c-auth v4a fixture's literal bytes. The
//// RFC 6979 deterministic-nonce variant that matches the
//// reference vectors is a follow-up — it needs a pure-Erlang
//// HMAC-DRBG implementation.
////
//// **AWS-deterministic key derivation** is now wired via
//// `derive_signing_key/2` — feeds an IAM (access-key-id,
//// secret-access-key) pair through AWS's HMAC-SHA256 + P-256
//// modular-reduction KDF and returns the 32-byte EC private
//// scalar the SigV4a spec requires. Pinned by
//// `test/sigv4a_key_derivation_test.gleam` against the aws-c-auth
//// v4a fixture's `public-key.json` (X / Y derived from the
//// canonical `AKIDEXAMPLE` / `wJalrXUtnFEMI...` pair).

import aws/internal/crypto
import aws/internal/http_request.{
  type Header, type HttpRequest, Header, HttpRequest,
}
import aws/internal/uri
import gleam/bit_array
import gleam/list
import gleam/order
import gleam/string

pub type EcdsaPrivateKey {
  /// 32-byte P-256 (secp256r1) scalar. SEC1 form. Build via
  /// `ecdsa_private_key_from_bytes`; the wrapper validates the
  /// byte width so a malformed input fails at construction
  /// rather than at signing time.
  EcdsaPrivateKey(scalar: BitArray)
}

/// Build an `EcdsaPrivateKey` from a 32-byte scalar. Returns
/// `Error(_)` when the input is the wrong length — SigV4a is
/// strictly P-256, so any other key size is a bug.
pub fn ecdsa_private_key_from_bytes(
  bytes: BitArray,
) -> Result(EcdsaPrivateKey, String) {
  case bit_array.byte_size(bytes) {
    32 -> Ok(EcdsaPrivateKey(scalar: bytes))
    _ -> Error("SigV4a private key must be a 32-byte P-256 scalar")
  }
}

pub type Sigv4aOptions {
  Sigv4aOptions(
    /// AWS-form compact timestamp: `YYYYMMDDTHHMMSSZ`.
    timestamp: String,
    /// The region set the signature binds to. Single-region calls
    /// pass `["us-east-1"]`; multi-region calls pass the list.
    /// Order is preserved into the `X-Amz-Region-Set` header.
    region_set: List(String),
    /// Service name as it appears in the credential scope.
    service: String,
    /// `True` ⇒ canonical-request payload-hash line carries
    /// `sha256(req.body)`; `False` ⇒ `sha256("")`.
    sign_body: Bool,
  )
}

/// Sign `req` with `private_key` and `access_key_id`, returning
/// the request with `Authorization`, `X-Amz-Date`,
/// `X-Amz-Region-Set`, and (when `sign_body`) `X-Amz-Content-Sha256`
/// headers added.
pub fn sign(
  req: HttpRequest,
  private_key: EcdsaPrivateKey,
  access_key_id: String,
  opts: Sigv4aOptions,
) -> HttpRequest {
  let date = string.slice(opts.timestamp, 0, 8)
  let region_set_value = string.join(opts.region_set, ",")
  let payload_hash = case opts.sign_body {
    True -> crypto.hex_encode(crypto.sha256(req.body))
    False -> crypto.hex_encode(crypto.sha256(bit_array.from_string("")))
  }
  let prepared = case opts.sign_body {
    True ->
      req.headers
      |> upsert("X-Amz-Date", opts.timestamp)
      |> upsert("X-Amz-Region-Set", region_set_value)
      |> upsert("X-Amz-Content-Sha256", payload_hash)
    False ->
      req.headers
      |> upsert("X-Amz-Date", opts.timestamp)
      |> upsert("X-Amz-Region-Set", region_set_value)
  }
  let canonical_uri = encode_path(req.path)
  let canonical_query = canonical_query_string(req.query)
  let canonical_headers_block = canonical_headers(prepared)
  let signed_headers_list = signed_headers(prepared)
  let creq =
    req.method
    <> "\n"
    <> canonical_uri
    <> "\n"
    <> canonical_query
    <> "\n"
    <> canonical_headers_block
    <> "\n"
    <> signed_headers_list
    <> "\n"
    <> payload_hash
  // Credential scope drops the region — `X-Amz-Region-Set`
  // carries it instead.
  let scope = date <> "/" <> opts.service <> "/aws4_request"
  let creq_hash = crypto.hex_encode(crypto.sha256(bit_array.from_string(creq)))
  let sts =
    "AWS4-ECDSA-P256-SHA256\n"
    <> opts.timestamp
    <> "\n"
    <> scope
    <> "\n"
    <> creq_hash
  let sig_der = ecdsa_p256_sign(private_key.scalar, bit_array.from_string(sts))
  let sig_hex = crypto.hex_encode(sig_der)
  let auth =
    "AWS4-ECDSA-P256-SHA256 Credential="
    <> access_key_id
    <> "/"
    <> scope
    <> ", SignedHeaders="
    <> signed_headers_list
    <> ", Signature="
    <> sig_hex
  let final_headers =
    list.append(prepared, [Header(name: "Authorization", value: auth)])
  HttpRequest(..req, headers: final_headers)
}

/// ECDSA P-256 signature over `data`, returning the DER-encoded
/// blob. Erlang's `crypto:sign/4` uses a random nonce per call;
/// signatures verify correctly server-side but won't match
/// RFC-6979 deterministic-nonce reference vectors.
@external(erlang, "aws_ffi", "ecdsa_p256_sign")
pub fn ecdsa_p256_sign(private_key: BitArray, data: BitArray) -> BitArray

/// ECDSA P-256 verification. `public_key` is the uncompressed
/// SEC1 form (`04 || X || Y`, 65 bytes).
@external(erlang, "aws_ffi", "ecdsa_p256_verify")
pub fn ecdsa_p256_verify(
  public_key: BitArray,
  data: BitArray,
  signature: BitArray,
) -> Bool

/// Uncompressed SEC1 public key (`04 || X || Y`, 65 bytes) for a
/// given 32-byte P-256 private scalar. Surfaced so callers can pin
/// derived keys against AWS test fixtures (which ship the public
/// counterpart) without re-implementing curve arithmetic.
@external(erlang, "aws_ffi", "ecdsa_p256_public_key")
pub fn ecdsa_p256_public_key(private_key: BitArray) -> BitArray

/// AWS SigV4a deterministic key derivation: turn an IAM
/// (access-key-id, secret-access-key) pair into the 32-byte
/// P-256 private scalar that `sign/4` accepts. Matches the
/// algorithm in `aws-sigv4::sign::v4a::generate_signing_key`:
///   1. `input_key = "AWS4A" || secret_access_key` (UTF-8)
///   2. Loop counter `c = 1, 2, …`:
///        `kdf_context = access_key_id || c`
///        `fis = "AWS4-ECDSA-P256-SHA256" || 0x00 || kdf_context || 256:i32-be`
///        `buf = 1:i32-be || fis`
///        `tag = HMAC-SHA256(input_key, buf)` (32 bytes)
///        `k0 = U256(tag)` — big-endian
///        if `k0 ≤ N-2` (with `N` = P-256 order): return `k0 + 1`.
///   3. Otherwise `c += 1` and retry. The counter loop almost
///      always terminates on `c = 1`; the probability of rejection
///      per iteration is `(2^256 - (N-2)) / 2^256 ≈ 2^-128`.
pub fn derive_signing_key(
  access_key_id: String,
  secret_access_key: String,
) -> EcdsaPrivateKey {
  let input_key = bit_array.from_string("AWS4A" <> secret_access_key)
  let access_key_bytes = bit_array.from_string(access_key_id)
  derive_loop(input_key, access_key_bytes, 1)
}

fn derive_loop(
  input_key: BitArray,
  access_key_bytes: BitArray,
  counter: Int,
) -> EcdsaPrivateKey {
  case counter > 254 {
    True ->
      // Per RFC + AWS spec, the rejection branch has probability ~2^-128
      // per iteration. 254 tries means a probability of ~2^-120 of
      // reaching here for a single key — astronomically below any
      // realistic credential. If this ever fires, the input is
      // corrupted, the implementation is wrong, or the IAM secret is
      // adversarial; in any case, panicking beats silently looping.
      panic as "SigV4a key derivation: counter exceeded 254 — IAM secret may be malformed"
    False -> {
      let kdf_context = <<access_key_bytes:bits, counter:size(8)>>
      let fis = <<
        "AWS4-ECDSA-P256-SHA256":utf8, 0:size(8), kdf_context:bits,
        256:size(32)-big,
      >>
      let buf = <<1:size(32)-big, fis:bits>>
      let tag = crypto.hmac_sha256(input_key, buf)
      let assert <<k0:size(256)-big>> = tag
      case k0 <= p256_order_minus_two {
        True -> EcdsaPrivateKey(scalar: <<{ k0 + 1 }:size(256)-big>>)
        False -> derive_loop(input_key, access_key_bytes, counter + 1)
      }
    }
  }
}

/// `N − 2` where `N` is the P-256 curve order
/// (`ffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc632551`).
/// The KDF rejects candidates strictly greater than this; the `+1`
/// step on the survivor keeps the result in `[1, N-1]`, which is
/// the valid private-scalar range for ECDSA over P-256.
const p256_order_minus_two: Int = 0xffffffff00000000ffffffffffffffffbce6faada7179e84f3b9cac2fc63254f

// ---------- canonical-request helpers ----------
//
// These mirror the private helpers in `aws/internal/sigv4`. The
// duplication is intentional while SigV4a stabilises; once the
// shape is solid both can call into a neutral
// `aws/internal/sigv4_canonical` module.

fn upsert(headers: List(Header), name: String, value: String) -> List(Header) {
  let lower = string.lowercase(name)
  let already = list.any(headers, fn(h) { string.lowercase(h.name) == lower })
  case already {
    True ->
      list.map(headers, fn(h) {
        case string.lowercase(h.name) == lower {
          True -> Header(name: h.name, value: value)
          False -> h
        }
      })
    False -> list.append(headers, [Header(name: name, value: value)])
  }
}

fn canonical_headers(headers: List(Header)) -> String {
  headers
  |> list.map(fn(h) { #(string.lowercase(h.name), string.trim(h.value)) })
  |> list.sort(by: fn(a, b) { string.compare(a.0, b.0) })
  |> list.map(fn(p) { p.0 <> ":" <> p.1 <> "\n" })
  |> string.concat
}

fn signed_headers(headers: List(Header)) -> String {
  headers
  |> list.map(fn(h) { string.lowercase(h.name) })
  |> list.unique
  |> list.sort(by: string.compare)
  |> string.join(";")
}

fn canonical_query_string(query: String) -> String {
  case query {
    "" -> ""
    _ ->
      string.split(query, "&")
      |> list.map(fn(pair) {
        case string.split_once(pair, "=") {
          Ok(#(name, value)) -> #(
            uri.encode_component(name),
            uri.encode_component(value),
          )
          Error(_) -> #(uri.encode_component(pair), "")
        }
      })
      |> list.sort(by: fn(a, b) {
        case string.compare(a.0, b.0) {
          order.Eq -> string.compare(a.1, b.1)
          other -> other
        }
      })
      |> list.map(fn(p) { p.0 <> "=" <> p.1 })
      |> string.join("&")
  }
}

fn encode_path(path: String) -> String {
  string.split(path, "/")
  |> list.map(uri.encode_segment)
  |> string.join("/")
}
