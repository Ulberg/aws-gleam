//// Tests for `aws/s3/streaming.get_object_streaming`. The wrapper
//// routes through the runtime via `s3.get_object_streaming` +
//// `runtime.invoke_streaming`; these tests swap the streaming sender
//// on a real `s3.Client` via the `streaming_http_send` setting, so the
//// assertion is on the wrapper's externally observable behaviour
//// rather than the runtime layer underneath.
////
//// LocalStack-backed end-to-end coverage belongs in a future
//// `test/aws/s3_streaming_localstack_test.gleam` once the
//// streaming endpoint actually serves chunked bodies.

import aws/config
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
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        streaming_http_send: Some(streaming_send),
      ),
      s3.default_endpoint_params(),
    )

  let input = build_get_object_input("bucket", "key")
  case s3.get_object_streaming(client, input) {
    Ok(resp) -> {
      resp.status |> should.equal(200)
      streaming.to_bit_array(resp.body) |> should.equal(body_bytes)
    }
    Error(_) -> panic as "expected streaming response, got error"
  }
  s3.shutdown(client)
}

pub fn download_to_bit_array_max_under_cap_returns_bytes_test() {
  // Convenience that wraps `get_object_streaming` + `to_bit_array_max`.
  // Under cap: surfaces the raw bytes.
  let body_bytes = <<"small payload":utf8>>
  let streaming_send =
    fixed_streaming_send(
      Ok(response.Response(
        status: 200,
        headers: [],
        body: streaming.from_bit_array(body_bytes),
      )),
    )
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        streaming_http_send: Some(streaming_send),
      ),
      s3.default_endpoint_params(),
    )

  let input = build_get_object_input("bucket", "key")
  s3_streaming.download_to_bit_array_max(client, input, 1024)
  |> should.equal(Ok(body_bytes))
  s3.shutdown(client)
}

pub fn download_to_bit_array_max_over_cap_returns_body_too_large_test() {
  // Body exceeds the cap → `streaming.TooLarge(cap)` surfaces, not
  // a panic. The error type is the generic `streaming.CollectError`
  // shape; the S3 wrapper just pins the inner err type.
  let body_bytes = <<"this body is more than ten bytes":utf8>>
  let streaming_send =
    fixed_streaming_send(
      Ok(response.Response(
        status: 200,
        headers: [],
        body: streaming.from_bit_array(body_bytes),
      )),
    )
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        streaming_http_send: Some(streaming_send),
      ),
      s3.default_endpoint_params(),
    )

  case
    s3_streaming.download_to_bit_array_max(
      client,
      build_get_object_input("bucket", "key"),
      10,
    )
  {
    Error(streaming.TooLarge(max_bytes: 10)) -> Nil
    other -> panic as { "expected TooLarge(10), got: " <> describe_dl(other) }
  }
  s3.shutdown(client)
}

pub fn download_to_bit_array_max_surfaces_transport_failure_test() {
  // Service errors from the streaming layer route through
  // `streaming.Transport(cause)` so callers can pattern-match on
  // the underlying runtime.ClientError shape (retry vs. give up).
  let streaming_send =
    fixed_streaming_send(
      Ok(response.Response(
        status: 500,
        headers: [],
        body: streaming.from_bit_array(<<"":utf8>>),
      )),
    )
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        streaming_http_send: Some(streaming_send),
      ),
      s3.default_endpoint_params(),
    )

  case
    s3_streaming.download_to_bit_array_max(
      client,
      build_get_object_input("bucket", "key"),
      1024,
    )
  {
    Error(streaming.Transport(_)) -> Nil
    other -> panic as { "expected Transport(_), got: " <> describe_dl(other) }
  }
  s3.shutdown(client)
}

fn describe_dl(
  r: Result(BitArray, streaming.CollectError(runtime.ClientError)),
) -> String {
  case r {
    Ok(_) -> "Ok(_)"
    Error(streaming.Transport(_)) -> "Transport(_)"
    Error(streaming.TooLarge(max_bytes: n)) ->
      "TooLarge(" <> int_to_string(n) <> ")"
    Error(streaming.InvalidUtf8) -> "InvalidUtf8"
  }
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
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        streaming_http_send: Some(streaming_send),
      ),
      s3.default_endpoint_params(),
    )

  let input = build_get_object_input("bucket", "missing-key")
  case s3.get_object_streaming(client, input) {
    Error(runtime.ServiceError(status: 404, error_type: et, ..)) ->
      et |> should.equal("NoSuchKey")
    other -> panic as { "expected ServiceError(404), got: " <> describe(other) }
  }
  s3.shutdown(client)
}

fn describe(r: Result(streaming.Response, runtime.ClientError)) -> String {
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
