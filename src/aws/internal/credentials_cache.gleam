//// Credentials cache: a `gleam_otp` actor that owns a `Provider` and caches
//// the last successful `Credentials`. Re-fetches when the cached value is
//// within `buffer_seconds` of its `expires_at`, or when the cache is empty
//// (first call) or the previous fetch failed.
////
//// Non-expiring credentials (`expires_at = None`) are cached forever — env
//// vars don't rotate without a process restart, so re-reading them on every
//// signed request would be wasteful.
////
//// Concurrency: actor messages are handled sequentially, so two parallel
//// `get` calls during the first fetch coalesce into a single provider
//// invocation. No thundering-herd shielding beyond that — adequate for the
//// rates AWS SDKs see in practice.

import aws/credentials.{type Credentials, type Provider, type ProviderError}
import gleam/erlang/process.{type Subject}
import gleam/option.{type Option, None, Some}
import gleam/otp/actor

/// Opaque handle for the cache. Hold one per `Client` you build.
pub opaque type Cache {
  Cache(subject: Subject(Message))
}

type Message {
  Get(reply: Subject(Result(Credentials, ProviderError)))
}

type State {
  State(
    provider: Provider,
    clock: fn() -> Int,
    buffer_seconds: Int,
    cached: Option(Credentials),
  )
}

pub type StartError {
  StartFailed(actor.StartError)
}

/// Default refresh buffer: trigger a refresh five minutes before expiry.
/// Tracks the conservative value most AWS SDKs use.
pub const default_buffer_seconds: Int = 300

@external(erlang, "aws_ffi", "unix_seconds")
fn unix_seconds() -> Int

/// Start the cache actor.
///
/// - `provider`: the upstream provider this cache wraps. Can itself be a
///   `credentials.chain([...])` — the cache doesn't care.
/// - `clock`: returns unix seconds. The default production wiring uses
///   `erlang:system_time(second)`; tests pass a closure over a controlled
///   counter so they can fast-forward across expiries.
/// - `buffer_seconds`: trigger a refresh this many seconds before
///   `expires_at`. See `default_buffer_seconds`.
pub fn start(
  provider provider: Provider,
  clock clock: fn() -> Int,
  buffer_seconds buffer_seconds: Int,
) -> Result(Cache, StartError) {
  let initial_state =
    State(
      provider: provider,
      clock: clock,
      buffer_seconds: buffer_seconds,
      cached: None,
    )
  case
    actor.new(initial_state)
    |> actor.on_message(handle_message)
    |> actor.start
  {
    Ok(started) -> Ok(Cache(subject: started.data))
    Error(reason) -> Error(StartFailed(reason))
  }
}

/// Start a cache using the OS clock and `default_buffer_seconds`. For
/// production wiring this is almost always what you want.
pub fn start_default(provider provider: Provider) -> Result(Cache, StartError) {
  start(
    provider: provider,
    clock: unix_seconds,
    buffer_seconds: default_buffer_seconds,
  )
}

/// Fetch the current credentials, refreshing from the wrapped provider if
/// the cache is empty or the credentials are within the refresh buffer of
/// expiry. Returns whatever the provider produced — the cache itself never
/// fabricates errors.
pub fn get(cache: Cache) -> Result(Credentials, ProviderError) {
  actor.call(cache.subject, waiting: 5000, sending: Get)
}

fn handle_message(
  state: State,
  message: Message,
) -> actor.Next(State, Message) {
  case message {
    Get(reply: reply) ->
      case fresh_enough(state) {
        True -> {
          let assert Some(creds) = state.cached
          process.send(reply, Ok(creds))
          actor.continue(state)
        }
        False ->
          case state.provider.fetch() {
            Ok(creds) -> {
              process.send(reply, Ok(creds))
              actor.continue(State(..state, cached: Some(creds)))
            }
            Error(error) -> {
              // Failed fetch: reply with the error AND leave any previously
              // cached value in place. If we held valid creds from a prior
              // call we'd rather keep serving them than blank the cache on
              // a transient IMDS hiccup — but right now we refresh as soon
              // as we re-enter the buffer window, so the next `get` will
              // retry. Future improvement: serve-stale-on-error.
              process.send(reply, Error(error))
              actor.continue(state)
            }
          }
      }
  }
}

fn fresh_enough(state: State) -> Bool {
  case state.cached {
    None -> False
    Some(creds) ->
      case creds.expires_at {
        None -> True
        Some(expires_at) -> expires_at - state.clock() > state.buffer_seconds
      }
  }
}
