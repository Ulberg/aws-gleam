import aws/internal/crypto
import aws/internal/http_request.{
  type Header, type HttpRequest, Header, HttpRequest,
}
import aws/internal/sigv4_canonical
import aws/internal/uri
import gleam/bit_array
import gleam/list
import gleam/option.{type Option, Some}
import gleam/string

pub type SigningOptions {
  SigningOptions(
    timestamp: String,
    region: String,
    service: String,
    normalize_path: Bool,
    sign_body: Bool,
    omit_session_token: Bool,
  )
}

/// Minimal credentials shape the signer needs. Lives here rather than
/// `aws/credentials` so callers in providers/* (e.g. the STS
/// AssumeRole provider that signs its own request) can construct one
/// without dragging the full `Credentials` type — which would form a
/// dependency cycle with the provider chain that *consumes* signed
/// requests.
pub type SigningCredentials {
  SigningCredentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
  )
}

/// Convenience constructor mirroring the most common case: static keys
/// with no session token.
pub fn make_credentials(
  access_key_id access_key_id: String,
  secret_access_key secret_access_key: String,
  session_token session_token: Option(String),
) -> SigningCredentials {
  SigningCredentials(
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token,
  )
}

pub type CanonicalParts {
  CanonicalParts(
    canonical_request: String,
    signed_headers: String,
    payload_hash: String,
    prepared_headers: List(Header),
  )
}

pub fn canonical_request(
  req: HttpRequest,
  creds: SigningCredentials,
  opts: SigningOptions,
) -> CanonicalParts {
  let payload_hash = case opts.sign_body {
    True -> crypto.hex_encode(crypto.sha256(req.body))
    False -> crypto.hex_encode(crypto.sha256(bit_array.from_string("")))
  }

  let prepared = prepare_headers(req, creds, opts, payload_hash)
  let signing_headers = headers_for_signing(prepared, creds, opts)
  let canonical_headers_block =
    sigv4_canonical.canonical_headers(signing_headers)
  let signed_headers_list = sigv4_canonical.signed_headers(signing_headers)
  let canonical_uri =
    sigv4_canonical.build_canonical_uri(req.path, opts.normalize_path)
  let canonical_query = sigv4_canonical.canonical_query_string(req.query)

  let creq =
    build_creq(
      req.method,
      canonical_uri,
      canonical_query,
      canonical_headers_block,
      signed_headers_list,
      payload_hash,
    )

  CanonicalParts(
    canonical_request: creq,
    signed_headers: signed_headers_list,
    payload_hash: payload_hash,
    prepared_headers: prepared,
  )
}

pub fn string_to_sign(
  canonical: String,
  timestamp: String,
  region: String,
  service: String,
) -> String {
  let date = string.slice(timestamp, 0, 8)
  let scope = date <> "/" <> region <> "/" <> service <> "/aws4_request"
  let hash = crypto.hex_encode(crypto.sha256(bit_array.from_string(canonical)))
  "AWS4-HMAC-SHA256\n" <> timestamp <> "\n" <> scope <> "\n" <> hash
}

pub fn signing_key(
  secret: String,
  date: String,
  region: String,
  service: String,
) -> BitArray {
  let k_secret = bit_array.from_string("AWS4" <> secret)
  let k_date = crypto.hmac_sha256(k_secret, bit_array.from_string(date))
  let k_region = crypto.hmac_sha256(k_date, bit_array.from_string(region))
  let k_service = crypto.hmac_sha256(k_region, bit_array.from_string(service))
  crypto.hmac_sha256(k_service, bit_array.from_string("aws4_request"))
}

pub fn signature(key: BitArray, sts: String) -> String {
  crypto.hex_encode(crypto.hmac_sha256(key, bit_array.from_string(sts)))
}

pub fn authorization_header(
  creds: SigningCredentials,
  timestamp: String,
  region: String,
  service: String,
  signed_headers: String,
  signature: String,
) -> String {
  let date = string.slice(timestamp, 0, 8)
  "AWS4-HMAC-SHA256 Credential="
  <> creds.access_key_id
  <> "/"
  <> date
  <> "/"
  <> region
  <> "/"
  <> service
  <> "/aws4_request, SignedHeaders="
  <> signed_headers
  <> ", Signature="
  <> signature
}

pub fn sign(
  req: HttpRequest,
  creds: SigningCredentials,
  opts: SigningOptions,
) -> HttpRequest {
  let parts = canonical_request(req, creds, opts)
  let sts =
    string_to_sign(
      parts.canonical_request,
      opts.timestamp,
      opts.region,
      opts.service,
    )
  let date = string.slice(opts.timestamp, 0, 8)
  let key =
    signing_key(creds.secret_access_key, date, opts.region, opts.service)
  let sig = signature(key, sts)
  let auth =
    authorization_header(
      creds,
      opts.timestamp,
      opts.region,
      opts.service,
      parts.signed_headers,
      sig,
    )
  let with_session = case creds.session_token, opts.omit_session_token {
    Some(token), True ->
      list.append(parts.prepared_headers, [
        Header(name: "X-Amz-Security-Token", value: token),
      ])
    _, _ -> parts.prepared_headers
  }
  let final_headers =
    list.append(with_session, [Header(name: "Authorization", value: auth)])
  HttpRequest(..req, headers: final_headers)
}

/// Build a SigV4 presigned URL — the "query-string auth" variant
/// callers reach for to share short-lived links to S3 objects, etc.
/// The auth components (`X-Amz-Algorithm`, `X-Amz-Credential`,
/// `X-Amz-Date`, `X-Amz-Expires`, `X-Amz-SignedHeaders`,
/// `X-Amz-Security-Token` when present, and `X-Amz-Signature`) land
/// in the URL query string rather than headers. Only the `Host`
/// header is signed.
///
/// `payload_hash` controls the canonical-request payload line:
///   * `Some("UNSIGNED-PAYLOAD")` — the S3 convention for shared
///     download URLs (the caller doesn't get to choose the body).
///   * `Some(hex)` — caller-provided body hash; matches a known
///     request body that will be sent against the signed URL.
///   * `None` — the standard SigV4 path, honouring `opts.sign_body`:
///     `True` ⇒ `sha256(req.body)`, `False` ⇒ `sha256("")` (the
///     hash of the empty body). The v4 test suite uses this path.
///
/// `expires_seconds` is bounded by SigV4 to `[1, 604800]` (1 second
/// to 7 days). The function doesn't enforce the bound; AWS rejects
/// out-of-range values at the server side.
///
/// Returns the full URL (`https://<host><path>?<signed-query>`)
/// ready to hand to a caller. Existing `req.query` entries are
/// preserved and merged with the auth params.
pub fn presigned_url(
  req: HttpRequest,
  creds: SigningCredentials,
  opts: SigningOptions,
  expires_seconds: Int,
  payload_hash payload_hash: Option(String),
) -> String {
  let host = host_from_headers(req.headers)
  let date = string.slice(opts.timestamp, 0, 8)
  let credential_scope =
    creds.access_key_id
    <> "/"
    <> date
    <> "/"
    <> opts.region
    <> "/"
    <> opts.service
    <> "/aws4_request"
  // Sign every header the request carries (lowercased, sorted).
  // For URL-only flows the caller typically passes only `Host`,
  // but the v4 conformance suite covers cases where additional
  // headers (custom `My-Header*`, `Content-Type`, etc.) ride
  // along — they must all appear in `SignedHeaders` and the
  // canonical-headers block.
  let signed_headers_list = sigv4_canonical.signed_headers(req.headers)
  let canonical_headers_block = sigv4_canonical.canonical_headers(req.headers)
  // Auth params other than X-Amz-Signature. Credential scope goes
  // in unencoded; `canonical_query_string` (idempotent over
  // pre-encoded values via `uri.encode_component`'s decode-then-
  // encode) handles encoding when we merge.
  let auth_params = [
    #("X-Amz-Algorithm", "AWS4-HMAC-SHA256"),
    #("X-Amz-Credential", credential_scope),
    #("X-Amz-Date", opts.timestamp),
    #("X-Amz-Expires", int_to_string(expires_seconds)),
    #("X-Amz-SignedHeaders", signed_headers_list),
  ]
  // When `omit_session_token` is true, the token rides in the
  // final URL but is NOT part of what's signed — same semantics as
  // the header path's omit_session_token. When false, the token
  // is included in `auth_params` and signed along with everything
  // else.
  let auth_params_for_signing = case
    creds.session_token,
    opts.omit_session_token
  {
    Some(token), False ->
      list.append(auth_params, [#("X-Amz-Security-Token", token)])
    _, _ -> auth_params
  }
  let merged_query = merge_query(req.query, auth_params_for_signing)
  let canonical_uri =
    sigv4_canonical.build_canonical_uri(req.path, opts.normalize_path)
  let canonical_query = sigv4_canonical.canonical_query_string(merged_query)
  let payload_hash = case payload_hash {
    Some(h) -> h
    _ ->
      case opts.sign_body {
        True -> crypto.hex_encode(crypto.sha256(req.body))
        False -> crypto.hex_encode(crypto.sha256(bit_array.from_string("")))
      }
  }
  let creq =
    build_creq(
      req.method,
      canonical_uri,
      canonical_query,
      canonical_headers_block,
      signed_headers_list,
      payload_hash,
    )
  let sts = string_to_sign(creq, opts.timestamp, opts.region, opts.service)
  let key =
    signing_key(creds.secret_access_key, date, opts.region, opts.service)
  let sig = signature(key, sts)
  // Final URL: canonical query stays sorted; the signature is
  // appended after, since signing the request with the signature
  // already inside the query would be circular. When the caller
  // asked to omit the session token from the signed inputs, it
  // still rides in the URL after signing — same shape as the v4
  // suite's `post-sts-header-after` query-signed-request fixture.
  let url_with_signature =
    "https://"
    <> host
    <> canonical_uri
    <> "?"
    <> canonical_query
    <> "&X-Amz-Signature="
    <> sig
  case creds.session_token, opts.omit_session_token {
    Some(token), True ->
      url_with_signature
      <> "&X-Amz-Security-Token="
      <> uri.encode_component(token)
    _, _ -> url_with_signature
  }
}

/// Assemble the canonical-request line block both header-auth and
/// query-auth need. The five `\n`-joined parts are identical
/// between the two flows; only the inputs differ (header-auth
/// signs in-headers, query-auth signs an auth-augmented query
/// string).
fn build_creq(
  method: String,
  canonical_uri: String,
  canonical_query: String,
  canonical_headers_block: String,
  signed_headers_list: String,
  payload_hash: String,
) -> String {
  method
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
}

fn host_from_headers(headers: List(Header)) -> String {
  case list.find(headers, fn(h) { string.lowercase(h.name) == "host" }) {
    Ok(h) -> h.value
    Error(_) -> ""
  }
}

fn merge_query(
  existing: String,
  auth_params: List(#(String, String)),
) -> String {
  let auth_pairs =
    auth_params
    |> list.map(fn(p) { p.0 <> "=" <> uri.encode_component(p.1) })
    |> string.join("&")
  case existing {
    "" -> auth_pairs
    _ -> existing <> "&" <> auth_pairs
  }
}

@external(erlang, "erlang", "integer_to_binary")
fn int_to_string(n: Int) -> String

fn prepare_headers(
  req: HttpRequest,
  creds: SigningCredentials,
  opts: SigningOptions,
  payload_hash: String,
) -> List(Header) {
  let with_date =
    upsert_header(req.headers, "X-Amz-Date", opts.timestamp, replace: True)
  let with_body = case opts.sign_body {
    True ->
      upsert_header(
        with_date,
        "X-Amz-Content-Sha256",
        payload_hash,
        replace: True,
      )
    False -> with_date
  }
  case creds.session_token, opts.omit_session_token {
    Some(token), False ->
      upsert_header(with_body, "X-Amz-Security-Token", token, replace: True)
    _, _ -> with_body
  }
}

fn headers_for_signing(
  prepared: List(Header),
  creds: SigningCredentials,
  opts: SigningOptions,
) -> List(Header) {
  case creds.session_token, opts.omit_session_token {
    Some(_), True ->
      list.filter(prepared, fn(h) {
        string.lowercase(h.name) != "x-amz-security-token"
      })
    _, _ -> prepared
  }
}

fn upsert_header(
  headers: List(Header),
  name: String,
  value: String,
  replace replace: Bool,
) -> List(Header) {
  let lower = string.lowercase(name)
  let already_present =
    list.any(headers, fn(h) { string.lowercase(h.name) == lower })
  case already_present, replace {
    True, True ->
      list.map(headers, fn(h) {
        case string.lowercase(h.name) == lower {
          True -> Header(name: h.name, value: value)
          False -> h
        }
      })
    True, False -> headers
    False, _ -> list.append(headers, [Header(name: name, value: value)])
  }
}
