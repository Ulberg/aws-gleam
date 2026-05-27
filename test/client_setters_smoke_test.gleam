//// Functional pins for the `config.Settings` knobs that change runtime
//// behavior on a real generated Client (built via `new_with`). The
//// emitter test in `codegen/test/emitter_test.gleam` asserts the
//// constructors are present; these tests assert the knobs actually take
//// effect.
////
//// Covered:
////   - `max_attempts: Some(1)` — invoke loop respects the cap, not the
////     standard 3-attempt budget.
////   - `use_http2: True` — installs `http_streaming.default_send_http2`
////     on the underlying ClientConfig's streaming sender field.
////
//// `http_send` / `streaming_http_send` are exercised indirectly by
//// every other test that stubs the transport; no dedicated smoke here.

import aws/config
import aws/credentials
import aws/internal/http_send as aws_http
import aws/internal/http_streaming
import aws/services/s3
import gleam/erlang/process.{type Subject}
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

/// Records every invocation onto `counter` and returns 503 so
/// `runtime.invoke` treats it as transient + retries (if the
/// strategy allows).
fn always_503_recording_send(counter: Subject(Int)) -> aws_http.Send {
  fn(_req: Request(BitArray)) {
    process.send(counter, 1)
    Ok(response.Response(status: 503, headers: [], body: <<>>))
  }
}

fn count_messages(subject: Subject(Int), acc: Int) -> Int {
  case process.receive(subject, 0) {
    Ok(_) -> count_messages(subject, acc + 1)
    Error(_) -> acc
  }
}

pub fn with_max_attempts_one_disables_retry_test() {
  let counter = process.new_subject()
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(always_503_recording_send(counter)),
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
  // Don't care about the outcome — only how many HTTP attempts
  // the runtime issued. Default retry would issue three on a 503.
  let _ = s3.list_buckets(client, input)

  count_messages(counter, 0) |> should.equal(1)
  s3.shutdown(client)
}

pub fn with_http2_installs_default_http2_streaming_sender_test() {
  // `use_http2: True` routes through `runtime.with_http2`, which swaps
  // `streaming_http_send` to `http_streaming.default_send_http2`.
  // Module-function reference equality on the BEAM lets us check this
  // exactly: two refs to the same MFA compare `=:=`. A regression in
  // the config wiring (wrong runtime call, missing swap) flips this.
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        use_http2: True,
      ),
      s3.default_endpoint_params(),
    )

  case
    s3.client_config(client).streaming_http_send
    == http_streaming.default_send_http2
  {
    True -> Nil
    False ->
      panic as "use_http2: True did not install http_streaming.default_send_http2"
  }
  s3.shutdown(client)
}

pub fn default_client_does_not_use_http2_streaming_sender_test() {
  // Anchor: a fresh Client (without `with_http2`) defaults to the
  // HTTP/1.1 streaming sender. Pins the with_http2 test as
  // meaningfully different from a no-op.
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
      ),
      s3.default_endpoint_params(),
    )

  case
    s3.client_config(client).streaming_http_send
    == http_streaming.default_send_http2
  {
    True -> panic as "default Client should not use the HTTP/2 streaming sender"
    False -> Nil
  }
  s3.shutdown(client)
}
