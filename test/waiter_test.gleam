//// Unit tests for the `waiter.wait` polling helper.
////
//// The codegen-emitted `wait_until_<name>` functions are thin
//// wrappers over this helper — they pass in a `step` closure that
//// invokes the underlying operation, matches the result against
//// the Smithy `@waitable` acceptors, and returns
//// `Settled` / `Continue` / `FailedNow`. These tests exercise the
//// helper in isolation so a regression in the polling /
//// backoff / max-attempts logic surfaces without a real service.

import aws/waiter
import gleam/erlang/process
import gleeunit/should

pub fn wait_settles_on_first_attempt_test() {
  let result =
    waiter.wait(
      step: fn(_attempt) { waiter.Settled },
      max_attempts: 5,
      min_delay_ms: 0,
      max_delay_ms: 0,
    )
  result |> should.equal(Ok(Nil))
}

pub fn wait_settles_after_continuing_test() {
  let attempts = process.new_subject()
  process.send(attempts, 0)
  let result =
    waiter.wait(
      step: fn(_attempt) {
        let n = case process.receive(attempts, 0) {
          Ok(v) -> v
          Error(_) -> 0
        }
        process.send(attempts, n + 1)
        case n < 2 {
          True -> waiter.Continue
          False -> waiter.Settled
        }
      },
      max_attempts: 5,
      min_delay_ms: 0,
      max_delay_ms: 0,
    )
  result |> should.equal(Ok(Nil))
}

pub fn wait_exceeds_max_attempts_test() {
  let result =
    waiter.wait(
      step: fn(_attempt) { waiter.Continue },
      max_attempts: 3,
      min_delay_ms: 0,
      max_delay_ms: 0,
    )
  result |> should.equal(Error(waiter.MaxAttemptsExceeded(attempts: 3)))
}

pub fn wait_propagates_failed_now_test() {
  let result =
    waiter.wait(
      step: fn(_attempt) { waiter.FailedNow("permanent") },
      max_attempts: 5,
      min_delay_ms: 0,
      max_delay_ms: 0,
    )
  result |> should.equal(Error(waiter.Failed("permanent")))
}

pub fn wait_zero_max_attempts_returns_immediately_test() {
  // Calling with `max_attempts: 0` is a defensive guard — no
  // attempts at all. Returns `MaxAttemptsExceeded(attempts: 0)`
  // without invoking the step closure.
  let invoked = process.new_subject()
  let result =
    waiter.wait(
      step: fn(_attempt) {
        process.send(invoked, True)
        waiter.Settled
      },
      max_attempts: 0,
      min_delay_ms: 0,
      max_delay_ms: 0,
    )
  result |> should.equal(Error(waiter.MaxAttemptsExceeded(attempts: 0)))
  process.receive(invoked, 0) |> should.equal(Error(Nil))
}
