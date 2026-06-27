//// Regression coverage for the request-build path in
//// `aws/internal/client/runtime`: a consumer-supplied `endpoint_url`
//// without a scheme (the canonical LocalStack mistake,
//// `Some("localhost:4566")`) must surface as a typed `Error` from the
//// public `invoke` call — never panic the calling process. See issue
//// #27: `request.to` rejects a schemeless URL, and the old
//// `let assert Ok(...)` turned that recoverable input error into a
//// process crash.

import aws/credentials
import aws/internal/client/runtime
import aws/internal/http_send
import gleam/dict
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{None}
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

// A transport that should never be reached: the request must fail to
// build before any send happens.
fn unreachable_send() -> http_send.Send {
  fn(_req: Request(BitArray)) {
    Ok(response.Response(status: 200, headers: [], body: <<>>))
  }
}

pub fn schemeless_endpoint_url_returns_error_not_panic_test() {
  let config =
    runtime.default_config("us-east-1", "s3", "s3")
    |> runtime.with_credentials_provider(static_credentials())
    |> runtime.with_http_send(unreachable_send())
    |> runtime.with_endpoint_url("localhost:4566")
  let built = #("GET", "/", dict.new(), <<>>)

  case runtime.invoke(config, built, fn(_code, _headers, _body) { Ok(Nil) }) {
    Error(runtime.DecodeError(reason)) ->
      string.contains(reason, "localhost:4566") |> should.be_true
    _ -> should.fail()
  }
}
