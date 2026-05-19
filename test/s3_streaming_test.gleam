//// Tests for `aws/s3/streaming.get_object_streaming`. The wrapper
//// routes through the runtime via `s3.config(client)` +
//// `runtime.invoke_streaming` — these tests verify that wiring on
//// the prototype level without LocalStack:
////
////   - the runtime-side streaming path round-trips a stubbed
////     StreamingBody response (asserted on the underlying
////     `invoke_streaming` call to bypass the opaque `s3.Client`
////     and reach the same config + build pipeline the wrapper
////     uses);
////   - the wrapper itself reaches the network for a real call
////     against an unreachable endpoint, proving it isn't a
////     no-op and that `s3.config(client)` returns a usable
////     ClientConfig.
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

pub fn invoke_streaming_via_s3_config_round_trips_test() {
  // Verify the runtime layer the wrapper sits on top of: a real
  // `s3.config(client)` plumbed into `runtime.with_streaming_http_send`,
  // then `runtime.invoke_streaming` over `s3.build_get_object_request`.
  // This is exactly what `s3_streaming.get_object_streaming` does
  // internally minus the result wrapping.
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
  let config =
    runtime.with_streaming_http_send(s3.config(client), streaming_send)

  let input = build_get_object_input("bucket", "key")
  case runtime.invoke_streaming(config, s3.build_get_object_request(input)) {
    Ok(resp) -> {
      resp.status |> should.equal(200)
      streaming.to_bit_array(resp.body) |> should.equal(body_bytes)
    }
    Error(_) -> panic as "expected streaming response, got error"
  }
  s3.shutdown(client)
}

pub fn get_object_streaming_wrapper_reaches_network_test() {
  // The s3.Client type is opaque; we can't reach in and swap its
  // streaming sender post-construction. Instead pin the wrapper's
  // observable behaviour by pointing it at an unreachable endpoint
  // — a real network attempt fires (proving the wrapper actually
  // routes through s3.config + runtime.invoke_streaming + the
  // configured streaming transport) and surfaces an error result.
  let client =
    s3.new(region: "us-east-1")
    |> s3.with_credentials_provider(static_credentials())
    |> s3.with_endpoint_url("http://127.0.0.1:1")
  let input = build_get_object_input("bucket", "key")
  case s3_streaming.get_object_streaming(client, input) {
    Error(runtime.TransportError(_)) -> Nil
    Error(runtime.ServiceError(..)) -> Nil
    Error(runtime.DecodeError(_)) -> Nil
    Error(runtime.CredentialsError(_)) ->
      panic as "static creds should not surface CredentialsError"
    Ok(_) -> panic as "no server on 127.0.0.1:1, expected error"
  }
  s3.shutdown(client)
}

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
