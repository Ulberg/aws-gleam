//// Tests for the generic actor-teardown helpers in
//// `aws/internal/actor_lifecycle`. Both `credentials_cache` and
//// `retry/rate_limiter` route through these — covering them
//// independently here means the two consumer modules' lifecycle
//// tests can stay focused on consumer-specific assertions rather
//// than the underlying primitive.

import aws/internal/actor_lifecycle
import gleam/erlang/process
import gleam/otp/actor
import gleeunit/should

/// Trivial actor that holds no state, recognises a single `Stop`
/// message, and exits on receipt. Used to exercise the lifecycle
/// helpers without dragging a real cache / bucket into the test.
type TestMsg {
  Stop
}

fn start_test_actor() -> process.Subject(TestMsg) {
  let assert Ok(started) =
    actor.new(Nil)
    |> actor.on_message(fn(_state, msg) {
      case msg {
        Stop -> actor.stop()
      }
    })
    |> actor.start
  started.data
}

pub fn shutdown_via_stop_is_fire_and_forget_test() {
  // `shutdown_via_stop` returns Nil immediately and only sends the
  // Stop message; observation of the actor exit is the caller's job.
  let subject = start_test_actor()
  actor_lifecycle.shutdown_via_stop(subject, Stop)
  // Use shutdown_via_stop_sync as the observation primitive — it
  // reports Ok(Nil) once the actor has actually exited.
  actor_lifecycle.shutdown_via_stop_sync(subject, Stop, 200)
  |> should.equal(Ok(Nil))
}

pub fn shutdown_via_stop_sync_blocks_until_dead_test() {
  // Monitor-based teardown: sends Stop, receives DOWN, returns Ok.
  let subject = start_test_actor()
  actor_lifecycle.shutdown_via_stop_sync(subject, Stop, 200)
  |> should.equal(Ok(Nil))
}

pub fn shutdown_via_stop_sync_is_idempotent_for_dead_actors_test() {
  // The subject_owner short-circuit means a second sync call after
  // the actor has died returns Ok(Nil) immediately — no monitor,
  // no DOWN wait, no timeout.
  let subject = start_test_actor()
  actor_lifecycle.shutdown_via_stop_sync(subject, Stop, 200)
  |> should.equal(Ok(Nil))
  actor_lifecycle.shutdown_via_stop_sync(subject, Stop, 200)
  |> should.equal(Ok(Nil))
}

/// Actor that ignores Stop forever — used to trigger the timeout
/// path so we can assert `Error(Nil)` rather than rely on the
/// happy-path Ok.
type StubbornMsg {
  Ignore
}

fn start_stubborn_actor() -> process.Subject(StubbornMsg) {
  let assert Ok(started) =
    actor.new(Nil)
    |> actor.on_message(fn(state, _msg) { actor.continue(state) })
    |> actor.start
  started.data
}

pub fn shutdown_via_stop_sync_returns_error_on_timeout_test() {
  // The stubborn actor never exits — `shutdown_via_stop_sync` must
  // return `Error(Nil)` once the timeout fires, having demonitored
  // the actor so a future DOWN message doesn't pollute the caller's
  // mailbox.
  let subject = start_stubborn_actor()
  actor_lifecycle.shutdown_via_stop_sync(subject, Ignore, 50)
  |> should.equal(Error(Nil))
}

// ----- safe_call (#30) -----

/// Actor that echoes an Int back over the supplied reply subject, and
/// stops on `EchoStop`. Lets us drive `safe_call`'s happy path and,
/// after a clean stop, its dead-actor path.
type EchoMsg {
  Echo(reply: process.Subject(Int), value: Int)
  EchoStop
}

fn start_echo_actor() -> process.Subject(EchoMsg) {
  let assert Ok(started) =
    actor.new(Nil)
    |> actor.on_message(fn(state, msg) {
      case msg {
        Echo(reply:, value:) -> {
          process.send(reply, value)
          actor.continue(state)
        }
        EchoStop -> actor.stop()
      }
    })
    |> actor.start
  started.data
}

pub fn safe_call_returns_ok_with_reply_test() {
  // Happy path: a live actor replies, so safe_call returns Ok(reply).
  let subject = start_echo_actor()
  actor_lifecycle.safe_call(subject, waiting: 200, sending: Echo(_, 42))
  |> should.equal(Ok(42))
}

pub fn safe_call_returns_error_when_actor_dead_test() {
  // Regression for #30: calling a dead actor must return Error(Nil),
  // NOT panic the caller as `actor.call` does. We stop the actor
  // cleanly first (a normal exit doesn't crash this linked test
  // process), then call it.
  let subject = start_echo_actor()
  actor_lifecycle.shutdown_via_stop_sync(subject, EchoStop, 200)
  |> should.equal(Ok(Nil))
  actor_lifecycle.safe_call(subject, waiting: 200, sending: Echo(_, 1))
  |> should.equal(Error(Nil))
}

pub fn safe_call_returns_error_on_timeout_test() {
  // The stubborn actor receives the request but never replies, so
  // safe_call must time out into Error(Nil) rather than panic.
  let subject = start_stubborn_actor()
  actor_lifecycle.safe_call(
    subject,
    waiting: 50,
    sending: fn(_reply: process.Subject(Int)) { Ignore },
  )
  |> should.equal(Error(Nil))
}
