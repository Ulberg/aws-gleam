//// Tests for `aws/s3/streaming.get_object_streaming`. The wrapper
//// routes through the runtime via `s3.config(client)` +
//// `runtime.invoke_streaming`; these tests swap the streaming
//// sender on a real `s3.Client` via `s3.with_streaming_http_send`,
//// so the assertion is on the wrapper's externally observable
//// behaviour rather than the runtime layer underneath.
////
//// LocalStack-backed end-to-end coverage belongs in a future
//// `test/aws/s3_streaming_localstack_test.gleam` once the
//// streaming endpoint actually serves chunked bodies.

import aws/credentials
import aws/internal/client/runtime
import aws/internal/http_send as aws_http
import aws/s3/streaming as s3_streaming
import aws/services/s3
import aws/streaming
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{None, Some}
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

/// Stub streaming sender that always returns the canned response.
fn fixed_streaming_send(
  resp: Result(response.Response(streaming.StreamingBody), aws_http.HttpError),
) -> aws_http.StreamingSend {
  fn(_req: Request(BitArray)) { resp }
}

pub fn get_object_streaming_returns_streaming_body_test() {
  // Swap the streaming sender on a real Client via the codegen-
  // emitted `s3.with_streaming_http_send` setter, then call the
  // wrapper. The body bytes round-trip through `StreamingBody` —
  // proves the full pipeline (s3.config → runtime.invoke_streaming
  // → the swapped sender) wires up.
  let body_bytes = <<"hello chunked object":utf8>>
  let streaming_send =
    fixed_streaming_send(
      Ok(response.Response(
        status: 200,
        headers: [#("content-type", "application/octet-stream")],
        body: streaming.from_bit_array(body_bytes),
      )),
    )
  let client =
    s3.new(region: "us-east-1")
    |> s3.with_credentials_provider(static_credentials())
    |> s3.with_streaming_http_send(streaming_send)

  let input = build_get_object_input("bucket", "key")
  case s3_streaming.get_object_streaming(client, input) {
    Ok(resp) -> {
      resp.status |> should.equal(200)
      streaming.to_bit_array(resp.body) |> should.equal(body_bytes)
    }
    Error(_) -> panic as "expected streaming response, got error"
  }
  s3.shutdown(client)
}

pub fn get_object_streaming_surfaces_typed_error_on_404_test() {
  // The runtime materialises error bodies via `to_bit_array_max`
  // (1 MiB cap) and runs typed-error extraction over them on the
  // streaming path. A 404 with an `x-amzn-errortype` header must
  // surface as `runtime.ServiceError` with the matching
  // error_type, identical to the buffered `invoke` semantics.
  let streaming_send =
    fixed_streaming_send(
      Ok(response.Response(
        status: 404,
        headers: [#("x-amzn-errortype", "NoSuchKey")],
        body: streaming.from_bit_array(<<>>),
      )),
    )
  let client =
    s3.new(region: "us-east-1")
    |> s3.with_credentials_provider(static_credentials())
    |> s3.with_streaming_http_send(streaming_send)

  let input = build_get_object_input("bucket", "missing-key")
  case s3_streaming.get_object_streaming(client, input) {
    Error(runtime.ServiceError(status: 404, error_type: et, ..)) ->
      et |> should.equal("NoSuchKey")
    other -> panic as { "expected ServiceError(404), got: " <> describe(other) }
  }
  s3.shutdown(client)
}

fn describe(
  r: Result(s3_streaming.StreamingResponse, runtime.ClientError),
) -> String {
  case r {
    Ok(_) -> "Ok(_)"
    Error(runtime.ServiceError(status: s, ..)) ->
      "ServiceError(" <> int_to_string(s) <> ")"
    Error(runtime.TransportError(_)) -> "TransportError(_)"
    Error(runtime.CredentialsError(_)) -> "CredentialsError(_)"
    Error(runtime.DecodeError(reason: r)) -> "DecodeError(" <> r <> ")"
  }
}

@external(erlang, "erlang", "integer_to_binary")
fn int_to_string(n: Int) -> String

fn build_get_object_input(bucket: String, key: String) -> s3.GetObjectRequest {
  s3.GetObjectRequest(
    bucket: Some(bucket),
    checksum_mode: None,
    expected_bucket_owner: None,
    if_match: None,
    if_modified_since: None,
    if_none_match: None,
    if_unmodified_since: None,
    key: Some(key),
    part_number: None,
    range: None,
    request_payer: None,
    response_cache_control: None,
    response_content_disposition: None,
    response_content_encoding: None,
    response_content_language: None,
    response_content_type: None,
    response_expires: None,
    sse_customer_algorithm: None,
    sse_customer_key: None,
    sse_customer_key_md5: None,
    version_id: None,
  )
}
