//// Polling helper for Smithy `@waitable` operations.
////
//// The codegen-emitted `wait_until_<name>` functions are thin
//// wrappers over `wait`. Each wrapper:
////
////   1. Invokes the underlying typed operation in a `step` closure.
////   2. Matches the result against the waiter's acceptors (a list
////      of `state` + `matcher` rules lifted from the Smithy trait).
////      Returns `Settled` when an acceptor with `state: success`
////      matches, `FailedNow(err)` when `state: failure` matches,
////      `Continue` otherwise.
////   3. Calls `wait(step, max_attempts, min_delay, max_delay)` to
////      drive the loop with exponential backoff between attempts.
////
//// Backoff doubles the previous delay (starting at `min_delay_ms`)
//// up to `max_delay_ms` — Smithy's standard waiter cadence. The
//// helper sleeps between attempts via `process.sleep`; tests pass
//// zero delays so they don't block.
////
//// `step` carries the 1-indexed attempt number. The codegen
//// generally ignores it but specialised callers can use it for
//// dynamic adjustments (e.g. emit a log line per attempt).

import gleam/erlang/process

/// What a single waiter step produced. The codegen-emitted
/// `wait_until_<name>` wrapper turns the typed operation's
/// `Result(Output, Error)` plus the configured acceptors into one
/// of these three states.
pub type Step(error) {
  /// At least one `state: success` acceptor matched — the wait
  /// returns `Ok(Nil)` immediately.
  Settled
  /// No acceptor matched yet — sleep for the current backoff and
  /// re-invoke `step` (unless we've hit `max_attempts`).
  Continue
  /// A `state: failure` acceptor matched — the wait returns
  /// `Error(Failed(_))` immediately, no further attempts.
  FailedNow(error)
}

/// What can go wrong driving a waiter to completion.
pub type WaiterError(error) {
  /// A `state: failure` acceptor matched on attempt `attempts`.
  Failed(error: error)
  /// Reached the configured `max_attempts` without ever settling
  /// or failing. `attempts` is the actual number of attempts made.
  MaxAttemptsExceeded(attempts: Int)
}

/// Drive a waiter step closure to completion, sleeping between
/// attempts with exponential backoff capped at `max_delay_ms`.
/// Returns `Ok(Nil)` on settle, `Error(Failed(_))` on a
/// `state: failure` acceptor match, `Error(MaxAttemptsExceeded(_))`
/// when the attempt budget is exhausted. `max_attempts == 0` is a
/// defensive guard that returns immediately without invoking
/// `step`.
pub fn wait(
  step step: fn(Int) -> Step(error),
  max_attempts max_attempts: Int,
  min_delay_ms min_delay_ms: Int,
  max_delay_ms max_delay_ms: Int,
) -> Result(Nil, WaiterError(error)) {
  case max_attempts > 0 {
    False -> Error(MaxAttemptsExceeded(attempts: 0))
    True -> loop(step, 1, max_attempts, min_delay_ms, max_delay_ms)
  }
}

fn loop(
  step: fn(Int) -> Step(error),
  attempt: Int,
  max_attempts: Int,
  current_delay_ms: Int,
  max_delay_ms: Int,
) -> Result(Nil, WaiterError(error)) {
  case step(attempt) {
    Settled -> Ok(Nil)
    FailedNow(e) -> Error(Failed(error: e))
    Continue ->
      case attempt >= max_attempts {
        True -> Error(MaxAttemptsExceeded(attempts: max_attempts))
        False -> {
          // The Gleam OTP scheduler treats `process.sleep(0)` as a
          // no-op; the loop drives attempts back-to-back in that
          // case (used by tests).
          sleep(current_delay_ms)
          loop(
            step,
            attempt + 1,
            max_attempts,
            next_delay(current_delay_ms, max_delay_ms),
            max_delay_ms,
          )
        }
      }
  }
}

/// Smithy's waiter backoff: double the previous delay, capped at
/// `max_delay_ms`. Starts at `min_delay_ms` (the first sleep) and
/// climbs from there.
fn next_delay(current_ms: Int, max_delay_ms: Int) -> Int {
  let doubled = current_ms * 2
  case doubled > max_delay_ms {
    True -> max_delay_ms
    False -> doubled
  }
}

fn sleep(ms: Int) -> Nil {
  case ms <= 0 {
    True -> Nil
    False -> process.sleep(ms)
  }
}
