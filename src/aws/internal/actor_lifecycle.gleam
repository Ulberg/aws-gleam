//// Generic teardown helpers for actors that follow the SDK's
//// "polite stop message" convention. Used by `credentials_cache` and
//// `retry/rate_limiter` — both opaque types wrap a `Subject` whose
//// message variant set includes a `Stop` constructor that triggers
//// `actor.stop()` next dispatch.
////
//// Lives in a separate module so the same fire-and-forget + monitor-
//// based synchronous teardown lands in exactly one place. Adding a
//// third long-lived actor later (a request-rate limiter, an event-
//// stream demuxer) reuses these directly.

import gleam/erlang/process.{type Subject}

/// Fire-and-forget teardown: send the supplied `Stop` message and
/// return immediately. The actor exits on its next dispatch. Safe to
/// call against a dead actor — Erlang silently drops sends to a
/// terminated Pid.
pub fn shutdown_via_stop(subject: Subject(msg), stop_message: msg) -> Nil {
  process.send(subject, stop_message)
}

/// Synchronous teardown: monitor the owning Pid, send `Stop`, then
/// wait for the `DOWN` signal up to `timeout_ms`. Returns `Ok(Nil)`
/// on clean exit (already-dead actor short-circuits here too — the
/// `subject_owner` lookup fails fast). Returns `Error(Nil)` only on
/// real timeout — i.e. the actor is alive but didn't exit within the
/// window. The monitor is demonitored on the timeout path so the
/// caller's mailbox doesn't accumulate stray `DOWN` messages.
pub fn shutdown_via_stop_sync(
  subject: Subject(msg),
  stop_message: msg,
  timeout_ms: Int,
) -> Result(Nil, Nil) {
  case process.subject_owner(subject) {
    Error(_) -> Ok(Nil)
    Ok(pid) -> {
      let monitor = process.monitor(pid)
      process.send(subject, stop_message)
      let selector =
        process.new_selector()
        |> process.select_specific_monitor(monitor, fn(_down) { Nil })
      case process.selector_receive(selector, timeout_ms) {
        Ok(Nil) -> Ok(Nil)
        Error(Nil) -> {
          process.demonitor_process(monitor)
          Error(Nil)
        }
      }
    }
  }
}
