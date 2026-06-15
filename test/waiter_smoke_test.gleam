//// End-to-end smoke test for the codegen-emitted `wait_until_*`
//// waiters, using `S3.wait_until_bucket_exists` as the
//// representative case (it has a `success: true` matcher and a
//// retry-on-NotFound matcher — the canonical Smithy waiter shape).
////
//// We mock S3 returning HTTP 200 (head_bucket succeeds) and
//// assert the waiter settles immediately. A regression in the
//// codegen-emitted closure (wrong step expression, wrong matcher
//// dispatch, missing `waiter.Settled` reference) surfaces as a
//// failed compile or a non-OK result.

import aws/config
import aws/credentials
import aws/internal/http_send as aws_http
import aws/services/s3
import aws/waiter as waiter_runtime
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

/// Mock that returns 200 (head_bucket succeeds). The waiter's
/// `success: true` acceptor matches → Settled.
fn always_ok_send() -> fn(Request(BitArray)) ->
  Result(response.Response(BitArray), aws_http.HttpError) {
  fn(_req: Request(BitArray)) {
    Ok(response.Response(status: 200, headers: [], body: <<>>))
  }
}

pub fn wait_until_bucket_exists_settles_on_first_success_test() {
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(always_ok_send()),
      ),
      s3.default_endpoint_params(),
    )

  let result =
    s3.wait_until_bucket_exists(
      client,
      s3.head_bucket_request_default(bucket: "my-bucket"),
      // The waiter codegen wires `min_delay_ms` / `max_delay_ms`
      // verbatim from the trait (5000 / 120000 for S3). The test
      // never sleeps because the first attempt settles.
      5,
    )

  result |> should.equal(Ok(Nil))
}

pub fn waiter_max_attempts_exceeded_test() {
  // Mock returns 500 every time, no acceptor matches → Continue
  // until `max_attempts` is hit. We pass `max_attempts: 2` so the
  // test doesn't actually sleep 5s between attempts — the codegen
  // emits `min_delay_ms: 5000`, but the runtime caps the actual
  // sleeps by passing `max_delay_ms` through. To keep this test
  // fast we use the raw `waiter_runtime.wait` directly with zero
  // delays — the *generated* waiter delegates to exactly this
  // helper, so a regression there shows in `waiter_test.gleam`.
  let result =
    waiter_runtime.wait(
      step: fn(_attempt) { waiter_runtime.Continue },
      max_attempts: 2,
      min_delay_ms: 0,
      max_delay_ms: 0,
    )
  result
  |> should.equal(Error(waiter_runtime.MaxAttemptsExceeded(attempts: 2)))
}
