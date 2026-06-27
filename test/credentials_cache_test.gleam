//// Tests for the credentials cache actor. Inject a controlled clock so we
//// can fast-forward across expiries, and a stub provider that signals every
//// time `fetch` is invoked so we can assert the cache isn't over-fetching.

import aws/credentials.{
  type Credentials, type ProviderError, Credentials, FetchFailed, Provider,
}
import aws/internal/credentials_cache
import gleam/erlang/process.{type Subject}
import gleam/option.{None, Some}
import gleam/otp/actor
import gleeunit/should

// ----- controllable clock -----

type ClockMessage {
  ReadClock(reply: Subject(Int))
  SetClock(value: Int)
}

fn handle_clock(
  now: Int,
  message: ClockMessage,
) -> actor.Next(Int, ClockMessage) {
  case message {
    ReadClock(reply: reply) -> {
      process.send(reply, now)
      actor.continue(now)
    }
    SetClock(value: value) -> actor.continue(value)
  }
}

fn start_clock(at initial: Int) -> Subject(ClockMessage) {
  let assert Ok(started) =
    actor.new(initial)
    |> actor.on_message(handle_clock)
    |> actor.start
  started.data
}

fn read_clock(clock: Subject(ClockMessage)) -> Int {
  actor.call(clock, waiting: 1000, sending: ReadClock)
}

fn set_clock(clock: Subject(ClockMessage), to value: Int) -> Nil {
  process.send(clock, SetClock(value: value))
}

fn clock_fn(clock: Subject(ClockMessage)) -> fn() -> Int {
  fn() { read_clock(clock) }
}

// ----- stub provider that signals each fetch -----

fn stub_provider(
  signal: Subject(Nil),
  returning result: Result(Credentials, ProviderError),
) -> credentials.Provider {
  Provider(name: "Stub", fetch: fn() {
    process.send(signal, Nil)
    result
  })
}

/// Drain all currently-queued signals (non-blocking) and return the count.
fn count_signals(signal: Subject(Nil)) -> Int {
  do_count(signal, 0)
}

fn do_count(signal: Subject(Nil), acc: Int) -> Int {
  case process.receive(from: signal, within: 0) {
    Ok(Nil) -> do_count(signal, acc + 1)
    Error(_) -> acc
  }
}

// ----- helpers -----

fn creds_expiring_at(t: Int) -> Credentials {
  Credentials(
    access_key_id: "AKID",
    secret_access_key: "SECRET",
    session_token: None,
    expires_at: Some(t),
    source: "Stub",
  )
}

fn non_expiring_creds() -> Credentials {
  Credentials(
    access_key_id: "AKID",
    secret_access_key: "SECRET",
    session_token: None,
    expires_at: None,
    source: "Stub",
  )
}

// ----- tests -----

pub fn first_get_fetches_from_provider_test() {
  let signal = process.new_subject()
  let clock = start_clock(at: 100)
  let assert Ok(cache) =
    credentials_cache.start(
      provider: stub_provider(signal, returning: Ok(creds_expiring_at(1000))),
      clock: clock_fn(clock),
      buffer_seconds: 60,
    )
  let assert Ok(_) = credentials_cache.get(cache)
  count_signals(signal) |> should.equal(1)
}

pub fn subsequent_gets_within_validity_reuse_cache_test() {
  let signal = process.new_subject()
  let clock = start_clock(at: 100)
  let assert Ok(cache) =
    credentials_cache.start(
      provider: stub_provider(signal, returning: Ok(creds_expiring_at(1000))),
      clock: clock_fn(clock),
      buffer_seconds: 60,
    )
  let assert Ok(_) = credentials_cache.get(cache)
  let assert Ok(_) = credentials_cache.get(cache)
  let assert Ok(_) = credentials_cache.get(cache)
  count_signals(signal) |> should.equal(1)
}

pub fn get_within_refresh_buffer_triggers_refetch_test() {
  let signal = process.new_subject()
  let clock = start_clock(at: 100)
  // expires_at=200, buffer=60 → fresh while now < 140, stale at now=140+.
  let assert Ok(cache) =
    credentials_cache.start(
      provider: stub_provider(signal, returning: Ok(creds_expiring_at(200))),
      clock: clock_fn(clock),
      buffer_seconds: 60,
    )
  let assert Ok(_) = credentials_cache.get(cache)
  // Inside the buffer: should hit the provider again.
  set_clock(clock, to: 150)
  let assert Ok(_) = credentials_cache.get(cache)
  count_signals(signal) |> should.equal(2)
}

pub fn get_past_expiry_triggers_refetch_test() {
  let signal = process.new_subject()
  let clock = start_clock(at: 100)
  let assert Ok(cache) =
    credentials_cache.start(
      provider: stub_provider(signal, returning: Ok(creds_expiring_at(200))),
      clock: clock_fn(clock),
      buffer_seconds: 60,
    )
  let assert Ok(_) = credentials_cache.get(cache)
  set_clock(clock, to: 500)
  let assert Ok(_) = credentials_cache.get(cache)
  count_signals(signal) |> should.equal(2)
}

pub fn non_expiring_credentials_are_cached_forever_test() {
  let signal = process.new_subject()
  let clock = start_clock(at: 100)
  let assert Ok(cache) =
    credentials_cache.start(
      provider: stub_provider(signal, returning: Ok(non_expiring_creds())),
      clock: clock_fn(clock),
      buffer_seconds: 60,
    )
  let assert Ok(_) = credentials_cache.get(cache)
  set_clock(clock, to: 1_000_000)
  let assert Ok(_) = credentials_cache.get(cache)
  let assert Ok(_) = credentials_cache.get(cache)
  count_signals(signal) |> should.equal(1)
}

pub fn provider_error_is_propagated_test() {
  let signal = process.new_subject()
  let clock = start_clock(at: 100)
  let assert Ok(cache) =
    credentials_cache.start(
      provider: stub_provider(
        signal,
        returning: Error(FetchFailed(reason: "boom")),
      ),
      clock: clock_fn(clock),
      buffer_seconds: 60,
    )
  let assert Error(err) = credentials_cache.get(cache)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed"
  }
  // The signal was fired (we did attempt a fetch).
  count_signals(signal) |> should.equal(1)
}

pub fn returned_credentials_match_provider_output_test() {
  let signal = process.new_subject()
  let clock = start_clock(at: 100)
  let creds = creds_expiring_at(1000)
  let assert Ok(cache) =
    credentials_cache.start(
      provider: stub_provider(signal, returning: Ok(creds)),
      clock: clock_fn(clock),
      buffer_seconds: 60,
    )
  credentials_cache.get(cache)
  |> should.equal(Ok(creds))
}

/// Smoke test of the production wiring: real OS clock + the static provider.
/// Static creds are non-expiring so wall-clock advance doesn't matter here.
pub fn start_default_works_with_real_clock_test() {
  let inner =
    credentials.static_provider(Credentials(
      access_key_id: "AKID",
      secret_access_key: "SECRET",
      session_token: None,
      expires_at: None,
      source: "ignored",
    ))
  let assert Ok(cache) = credentials_cache.start_default(provider: inner)
  let assert Ok(out) = credentials_cache.get(cache)
  out.access_key_id |> should.equal("AKID")
  out.source |> should.equal("Static")
}

pub fn shutdown_sync_stops_the_actor_test() {
  // The cache spawns an OTP process; without a shutdown path that
  // process lives until the BEAM exits. `shutdown_sync` monitors the
  // owning Pid, sends `Stop`, and waits for `DOWN` — Ok means the
  // actor exited cleanly. The 200 ms timeout is generous; if the
  // scheduler is loaded enough to miss it, that's a real bug.
  let inner =
    credentials.static_provider(Credentials(
      access_key_id: "AKID",
      secret_access_key: "SECRET",
      session_token: None,
      expires_at: None,
      source: "ignored",
    ))
  let assert Ok(cache) = credentials_cache.start_default(provider: inner)
  credentials_cache.shutdown_sync(cache, 200) |> should.equal(Ok(Nil))
}

pub fn shutdown_sync_is_idempotent_test() {
  // Calling `shutdown_sync` twice should report Ok both times: the
  // second call sees `subject_owner` return `Error(Nil)` (the actor
  // is gone) and short-circuits to `Ok(Nil)` rather than waiting
  // for a monitor signal that will never arrive.
  let inner =
    credentials.static_provider(Credentials(
      access_key_id: "AKID",
      secret_access_key: "SECRET",
      session_token: None,
      expires_at: None,
      source: "ignored",
    ))
  let assert Ok(cache) = credentials_cache.start_default(provider: inner)
  credentials_cache.shutdown_sync(cache, 200) |> should.equal(Ok(Nil))
  credentials_cache.shutdown_sync(cache, 200) |> should.equal(Ok(Nil))
}

pub fn get_on_dead_cache_actor_returns_error_test() {
  // Regression for #30: a dead cache actor must surface a typed Error,
  // not panic the caller. We can't crash the actor without taking down
  // this linked test process, so we stop it cleanly (a normal exit does
  // not propagate) and then call `get` — `safe_call` sees the dead
  // owner and `get` maps it to `FetchFailed`.
  let inner =
    credentials.static_provider(Credentials(
      access_key_id: "AKID",
      secret_access_key: "SECRET",
      session_token: None,
      expires_at: None,
      source: "ignored",
    ))
  let assert Ok(cache) = credentials_cache.start_default(provider: inner)
  credentials_cache.shutdown_sync(cache, 200) |> should.equal(Ok(Nil))
  let assert Error(err) = credentials_cache.get(cache)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed from a dead cache actor"
  }
}

pub fn shutdown_fire_and_forget_does_not_block_test() {
  // Plain `shutdown` returns immediately without waiting for the
  // actor; subsequent `shutdown_sync` confirms it eventually exited.
  let inner =
    credentials.static_provider(Credentials(
      access_key_id: "AKID",
      secret_access_key: "SECRET",
      session_token: None,
      expires_at: None,
      source: "ignored",
    ))
  let assert Ok(cache) = credentials_cache.start_default(provider: inner)
  credentials_cache.shutdown(cache)
  // Sync follow-up should see Ok — actor already exiting or exited.
  credentials_cache.shutdown_sync(cache, 200) |> should.equal(Ok(Nil))
}
