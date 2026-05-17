//// LocalStack container harness for end-to-end tests.
////
//// Per CLAUDE.md the v0.1 gate requires LocalStack-backed tests for
//// DynamoDB `GetItem` and S3 `GetObject`. This module provides the
//// `with_container` helper that:
////
////   1. Boots `test/support/docker-compose.yml` via `docker compose
////      up --wait` (healthcheck blocks until LocalStack is ready).
////   2. Runs the supplied callback with a `Container` carrying the
////      endpoint URL.
////   3. Tears the container down with `docker compose down -v` on
////      every exit path — Ok or panic.
////
//// The boot/teardown shells out to `os:cmd/1` rather than via the
//// `gleam_otp` HTTP layer; that keeps the harness independent of the
//// runtime under test.
////
//// Tests that use this helper are gated on `INCLUDE_LOCALSTACK=1` in
//// the environment so a plain `gleam test` stays fast. See
//// `localstack_enabled()`.

import gleam/erlang/process

pub type Container {
  Container(endpoint: String)
}

/// Is `INCLUDE_LOCALSTACK=1` set? LocalStack-backed tests should
/// guard their body with `case localstack_enabled() { False -> Nil
/// True -> ... }` so a default `gleam test` skips them without
/// failing on an unavailable container.
pub fn localstack_enabled() -> Bool {
  case get_env("INCLUDE_LOCALSTACK") {
    Ok("1") -> True
    _ -> False
  }
}

/// Boot LocalStack, run `fun`, tear down. The teardown runs
/// unconditionally — even if `fun` panics — via Erlang try/after.
/// Returns whatever `fun` returned.
pub fn with_container(fun: fn(Container) -> a) -> a {
  start_localstack()
  // Give the healthcheck a moment to mark the container ready even
  // after `docker compose up --wait` returns. LocalStack reports
  // "running" briefly before its API listener accepts traffic.
  process.sleep(500)
  let container = Container(endpoint: "http://localhost:4566")
  run_with_teardown(fn() { fun(container) })
}

@external(erlang, "aws_test_support_ffi", "start_localstack")
fn start_localstack() -> Nil

@external(erlang, "aws_test_support_ffi", "run_with_teardown")
fn run_with_teardown(fun: fn() -> a) -> a

@external(erlang, "aws_ffi", "get_env")
fn get_env(name: String) -> Result(String, Nil)
