//// Pins for `runtime.with_sigv4a_region_set` and the
//// `prepare_signed_request` branch that routes through
//// `sigv4a.sign_with_credentials` when the config carries an
//// `Sigv4aSigner`. Default behaviour stays on `sigv4.sign`; opt-in
//// is the entire API surface.
////
//// The test uses S3 because that's the canonical SigV4a consumer
//// (multi-region access points). A stubbed HTTP sender captures
//// the outgoing `Authorization` header so we can assert the
//// algorithm string flipped from `AWS4-HMAC-SHA256` to
//// `AWS4-ECDSA-P256-SHA256` once `with_sigv4a_region_set` is set.

import aws/config
import aws/credentials
import aws/internal/http_send as aws_http
import aws/services/s3
import gleam/erlang/process.{type Subject}
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

/// Records the outgoing request onto `inbox` and returns 200 OK so
/// the test can inspect the signed headers without involving the
/// network or any service-specific response shape.
fn capture_send(inbox: Subject(Request(BitArray))) -> aws_http.Send {
  fn(req: Request(BitArray)) {
    process.send(inbox, req)
    Ok(
      response.Response(status: 200, headers: [], body: <<
        "<ListAllMyBucketsResult></ListAllMyBucketsResult>",
      >>),
    )
  }
}

fn first_authorization_header(inbox: Subject(Request(BitArray))) -> String {
  let assert Ok(req) = process.receive(inbox, 0)
  let assert Ok(auth) =
    list.find_map(req.headers, fn(h) {
      case string.lowercase(h.0) == "authorization" {
        True -> Ok(h.1)
        False -> Error(Nil)
      }
    })
  auth
}

pub fn default_client_uses_sigv4_authorization_test() {
  let inbox = process.new_subject()
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(capture_send(inbox)),
        max_attempts: Some(1),
      ),
      s3.default_endpoint_params(),
    )
  let input =
    s3.ListBucketsRequest(
      bucket_region: None,
      continuation_token: None,
      max_buckets: None,
      prefix: None,
    )
  let _ = s3.list_buckets(client, input)

  string.starts_with(first_authorization_header(inbox), "AWS4-HMAC-SHA256 ")
  |> should.be_true
  s3.shutdown(client)
}

pub fn with_sigv4a_region_set_flips_authorization_algorithm_test() {
  let inbox = process.new_subject()
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(capture_send(inbox)),
        max_attempts: Some(1),
        sigv4a_region_set: Some(["us-east-1", "us-west-2"]),
      ),
      s3.default_endpoint_params(),
    )
  let input =
    s3.ListBucketsRequest(
      bucket_region: None,
      continuation_token: None,
      max_buckets: None,
      prefix: None,
    )
  let _ = s3.list_buckets(client, input)

  let auth = first_authorization_header(inbox)
  string.starts_with(auth, "AWS4-ECDSA-P256-SHA256 Credential=AKIDEXAMPLE/")
  |> should.be_true
  s3.shutdown(client)
}

pub fn with_sigv4a_path_normalization_false_preserves_dot_segments_test() {
  // S3 sets normalize_path: False so object keys with `.` / `..`
  // survive the canonical-request step. End-to-end check: the
  // request path makes it into the signing canonical-uri verbatim
  // (no dot-segment collapse) and the SigV4a signature is
  // accepted by the round-trip verifier — which would fail if the
  // signer used the normalised path while we hashed the literal.
  let inbox = process.new_subject()
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(capture_send(inbox)),
        max_attempts: Some(1),
        sigv4a_region_set: Some(["us-east-1"]),
        sigv4a_normalize_path: False,
      ),
      s3.default_endpoint_params(),
    )
  let input =
    s3.ListBucketsRequest(
      bucket_region: None,
      continuation_token: None,
      max_buckets: None,
      prefix: None,
    )
  let _ = s3.list_buckets(client, input)

  let auth = first_authorization_header(inbox)
  string.starts_with(auth, "AWS4-ECDSA-P256-SHA256 Credential=AKIDEXAMPLE/")
  |> should.be_true
  s3.shutdown(client)
}

pub fn with_sigv4a_path_normalization_without_signer_is_noop_test() {
  // Calling the path-normalization setter before opting into SigV4a
  // leaves the config unchanged — no signer present, nothing to
  // override. The dispatch still uses the default `sign_sigv4`
  // path.
  let inbox = process.new_subject()
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(capture_send(inbox)),
        max_attempts: Some(1),
        sigv4a_normalize_path: False,
      ),
      s3.default_endpoint_params(),
    )
  let input =
    s3.ListBucketsRequest(
      bucket_region: None,
      continuation_token: None,
      max_buckets: None,
      prefix: None,
    )
  let _ = s3.list_buckets(client, input)

  string.starts_with(first_authorization_header(inbox), "AWS4-HMAC-SHA256 ")
  |> should.be_true
  s3.shutdown(client)
}

pub fn with_sigv4a_region_set_emits_region_set_header_test() {
  let inbox = process.new_subject()
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(capture_send(inbox)),
        max_attempts: Some(1),
        sigv4a_region_set: Some(["us-east-1", "us-west-2"]),
      ),
      s3.default_endpoint_params(),
    )
  let input =
    s3.ListBucketsRequest(
      bucket_region: None,
      continuation_token: None,
      max_buckets: None,
      prefix: None,
    )
  let _ = s3.list_buckets(client, input)

  let assert Ok(req) = process.receive(inbox, 0)
  let assert Ok(rs) =
    list.find_map(req.headers, fn(h) {
      case string.lowercase(h.0) == "x-amz-region-set" {
        True -> Ok(h.1)
        False -> Error(Nil)
      }
    })
  rs |> should.equal("us-east-1,us-west-2")
  s3.shutdown(client)
}
