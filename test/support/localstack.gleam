//// LocalStack container harness for end-to-end tests.
////
//// Per CLAUDE.md the v0.1 gate requires LocalStack-backed tests for
//// DynamoDB `GetItem` and S3 `GetObject`. This module provides:
////
////   - `localstack_enabled` — checks `INCLUDE_LOCALSTACK=1` so a
////     plain `gleam test` skips the E2E tests silently.
////   - `when_enabled(fun)` — combines the env gate with container
////     boot + teardown so each test body is "the work that runs when
////     LocalStack is available".
////   - `fake_credentials` — `test:test` keys LocalStack accepts.
////
//// Boot / teardown shells out to `docker compose` via the Erlang FFI
//// in `aws_test_support_ffi`, which uses `open_port` for an honest
//// exit-code signal rather than scraping `os:cmd` stdout, and runs
//// teardown inside `try / after` so the container dies cleanly even
//// when the callback panics.

import aws/credentials
import gleam/option.{None}

pub type Container {
  Container(endpoint: String)
}

/// Is `INCLUDE_LOCALSTACK=1` set?
pub fn localstack_enabled() -> Bool {
  case get_env("INCLUDE_LOCALSTACK") {
    Ok("1") -> True
    _ -> False
  }
}

/// Run `fun` if `INCLUDE_LOCALSTACK=1` is set; otherwise return Nil.
/// When enabled, boots the LocalStack container, hands the callback
/// a `Container` describing the local endpoint, then tears it down.
/// Folds the gate + container lifecycle so each E2E test body is
/// "what runs once LocalStack is available."
pub fn when_enabled(fun: fn(Container) -> Nil) -> Nil {
  case localstack_enabled() {
    False -> Nil
    True -> {
      let container = Container(endpoint: "http://localhost:4566")
      with_teardown(fn() { fun(container) })
    }
  }
}

/// `test:test` keys LocalStack accepts. The actual values don't
/// matter — LocalStack ignores the signature — but the credential
/// chain expects non-empty access key + secret.
pub fn fake_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "test",
    secret_access_key: "test",
    session_token: None,
    expires_at: None,
    source: "LocalStack",
  ))
}

@external(erlang, "aws_test_support_ffi", "with_teardown")
fn with_teardown(fun: fn() -> a) -> a

@external(erlang, "aws_ffi", "get_env")
fn get_env(name: String) -> Result(String, Nil)
