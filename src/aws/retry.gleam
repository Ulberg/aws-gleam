//// Retry middleware. Wraps any `http_send.Send` with the retry semantics
//// the AWS Smithy runtime ships
//// (aws-sdk-rust/.../client/retries/strategy/standard.rs).
////
//// Behaviour mirrored from upstream:
////
////   - Exponential backoff with full jitter:
////     `min(initial * 2^attempt, max) * rand()`.
////     Matches `calculate_exponential_backoff` in Rust.
////   - Status-code classifier: 2xx success; 4xx (except 408/429) is
////     non-retryable; 408/429/5xx retryable; transport errors classified
////     as `TransientError` (timeout-class) and charged at the higher
////     `timeout_retry_cost`. Per AWS-Smithy `ErrorKind` mapping.
////   - `Retry-After` header (integer seconds) overrides the computed
////     backoff and is clamped to `max_delay`.
////   - Token bucket gates retries (`try_acquire(cost)`); each retry holds
////     a permit across attempts that is released on success / final
////     non-retryable outcome, or replaced before the next retry. Matches
////     Rust's `set_retry_permit` / `release_retry_permit`.
////
//// **Deliberately out of scope** (explicit deltas vs Rust SDK, documented
//// for the M4 audit):
////
////   - Time-based bucket refill (`refill_rate` in Rust SDK). Our bucket
////     only changes on acquire/release/reward.
////   - Pre-request rate limiter gating
////     (`should_attempt_initial_request`). Only retries are gated.
////   - The CUBIC `ClientRateLimiter` — Rust ships this as a separate
////     component for "true" adaptive mode. Our `adaptive` builder
////     installs the token bucket only; CUBIC is a follow-up milestone.

import aws/internal/http_send.{type HttpError, type Send}
import aws/internal/retry/rate_limiter.{
  type Bucket, type Permit, Acquired, Empty,
}
import gleam/erlang/process
import gleam/float
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/option.{type Option, None, Some}

/// Default maximum total attempts. Matches AWS SDK "standard" mode.
pub const default_max_attempts: Int = 3

/// Base delay before the first retry, in milliseconds.
pub const default_base_delay_ms: Int = 100

/// Cap on any individual retry delay, in milliseconds. Matches Rust SDK's
/// `MAX_BACKOFF` (20 s).
pub const default_max_delay_ms: Int = 20_000

/// Token cost for a normal retryable error (throttling, server fault,
/// retryable client). Matches Rust SDK `DEFAULT_RETRY_COST = 5`.
pub const retry_cost: Int = 5

/// Token cost for a transient / timeout retry. Matches Rust SDK
/// `DEFAULT_RETRY_TIMEOUT_COST = DEFAULT_RETRY_COST * 2 = 10`.
pub const timeout_retry_cost: Int = 10

/// What the strategy decided after looking at the last attempt.
pub type Decision {
  /// Attempt succeeded — return the response to the caller.
  Stop
  /// Attempt failed retryably — sleep `delay_ms` then attempt again. `cost`
  /// is the number of tokens the bucket should debit before the retry.
  RetryAfter(delay_ms: Int, cost: Int)
  /// Attempt failed non-retryably or attempts are exhausted.
  GiveUp
}

/// A retry strategy. Opaque to callers; build via `standard` / `adaptive`.
pub opaque type Strategy {
  Strategy(
    max_attempts: Int,
    base_delay_ms: Int,
    max_delay_ms: Int,
    sleep: fn(Int) -> Nil,
    rng: fn() -> Float,
    rate_limiter: Option(Bucket),
  )
}

pub fn standard() -> Strategy {
  Strategy(
    max_attempts: default_max_attempts,
    base_delay_ms: default_base_delay_ms,
    max_delay_ms: default_max_delay_ms,
    sleep: process.sleep,
    rng: random_float,
    rate_limiter: None,
  )
}

pub fn standard_with(
  max_attempts max_attempts: Int,
  base_delay_ms base_delay_ms: Int,
  max_delay_ms max_delay_ms: Int,
  sleep sleep: fn(Int) -> Nil,
  rng rng: fn() -> Float,
) -> Strategy {
  Strategy(
    max_attempts: max_attempts,
    base_delay_ms: base_delay_ms,
    max_delay_ms: max_delay_ms,
    sleep: sleep,
    rng: rng,
    rate_limiter: None,
  )
}

/// Standard retry with a token-bucket gate. Equivalent to Rust SDK
/// "adaptive" minus the CUBIC client rate limiter (see module docs).
pub fn adaptive(bucket bucket: Bucket) -> Strategy {
  Strategy(
    max_attempts: default_max_attempts,
    base_delay_ms: default_base_delay_ms,
    max_delay_ms: default_max_delay_ms,
    sleep: process.sleep,
    rng: random_float,
    rate_limiter: Some(bucket),
  )
}

pub fn adaptive_with(
  bucket bucket: Bucket,
  max_attempts max_attempts: Int,
  base_delay_ms base_delay_ms: Int,
  max_delay_ms max_delay_ms: Int,
  sleep sleep: fn(Int) -> Nil,
  rng rng: fn() -> Float,
) -> Strategy {
  Strategy(
    max_attempts: max_attempts,
    base_delay_ms: base_delay_ms,
    max_delay_ms: max_delay_ms,
    sleep: sleep,
    rng: rng,
    rate_limiter: Some(bucket),
  )
}

/// Override the per-request max attempt count on an existing
/// `Strategy`, preserving the other knobs (delays, sleep / rng /
/// rate-limiter). The common case for tuning retry behaviour —
/// callers usually want the AWS-recommended backoff curve but a
/// different attempt budget (1 for fail-fast tests, 5 for
/// long-running batch workloads, etc.).
///
/// Strategy is opaque so this setter lives here; the runtime
/// re-exports a `with_max_attempts(config, n)` convenience that
/// threads through to this setter.
pub fn with_max_attempts(strategy: Strategy, max_attempts: Int) -> Strategy {
  Strategy(..strategy, max_attempts: max_attempts)
}

/// Override the initial-retry-backoff base on an existing
/// `Strategy`. The first retry sleeps roughly `base_delay_ms` with
/// full jitter; each subsequent attempt doubles the cap up to
/// `max_delay_ms`. Set to 0 (paired with `with_max_delay_ms(0)`)
/// for tests that want zero-delay retries.
pub fn with_base_delay_ms(strategy: Strategy, base_delay_ms: Int) -> Strategy {
  Strategy(..strategy, base_delay_ms: base_delay_ms)
}

/// Override the maximum-backoff cap on an existing `Strategy`.
/// Pairs with `with_base_delay_ms` for tests that need zero or
/// very short delays; production callers usually keep the AWS-
/// recommended default.
pub fn with_max_delay_ms(strategy: Strategy, max_delay_ms: Int) -> Strategy {
  Strategy(..strategy, max_delay_ms: max_delay_ms)
}

/// Wrap a `Send` with retry semantics.
pub fn with_retry(send send: Send, strategy strategy: Strategy) -> Send {
  fn(req) { do_attempt(send, strategy, req, 1, None) }
}

fn do_attempt(
  send: Send,
  strategy: Strategy,
  req: Request(BitArray),
  attempt: Int,
  held_permit: Option(Permit),
) -> Result(Response(BitArray), HttpError) {
  let result = send(req)
  case classify(result, attempt, strategy) {
    Stop -> {
      // Success: return any held permit's tokens, then add the reward.
      release_if_held(strategy, held_permit)
      reward_if_present(strategy)
      result
    }
    GiveUp -> {
      // Non-retryable or out of attempts. Release the held permit so the
      // bucket has budget for subsequent operations. (Matches Rust's
      // `release_retry_permit` on terminal non-retryable.)
      release_if_held(strategy, held_permit)
      result
    }
    RetryAfter(delay_ms: delay, cost: cost) ->
      case gate(strategy, cost) {
        NoBucket -> {
          strategy.sleep(delay)
          do_attempt(send, strategy, req, attempt + 1, None)
        }
        GotPermit(new_permit) -> {
          release_if_held(strategy, held_permit)
          strategy.sleep(delay)
          do_attempt(send, strategy, req, attempt + 1, Some(new_permit))
        }
        BucketEmpty -> {
          // Bucket refused. Surface what we have AND release any prior
          // permit so other operations get the budget back.
          release_if_held(strategy, held_permit)
          result
        }
      }
  }
}

/// Three-way result of consulting the rate limiter for a retry attempt.
type GateOutcome {
  NoBucket
  GotPermit(permit: Permit)
  BucketEmpty
}

/// Classify one attempt's outcome. Exposed for test asserting and so the
/// protocol-codec layer (M5) can override per-service error semantics.
pub fn classify(
  result: Result(Response(BitArray), HttpError),
  attempt: Int,
  strategy: Strategy,
) -> Decision {
  case result {
    Ok(resp) -> classify_response(resp, attempt, strategy)
    Error(err) -> classify_transport_error(err, attempt, strategy)
  }
}

fn classify_response(
  resp: Response(BitArray),
  attempt: Int,
  strategy: Strategy,
) -> Decision {
  case classify_status(resp.status), attempt < strategy.max_attempts {
    NotRetryable, _ -> Stop
    _, False -> GiveUp
    _, True -> {
      let delay = case retry_after_seconds(resp) {
        Some(secs) -> int.min(secs * 1000, strategy.max_delay_ms)
        None -> exponential_backoff(strategy, attempt)
      }
      // Per Rust SDK: throttling + server fault both use the normal
      // `retry_cost`. Only TransientError (timeouts) uses
      // `timeout_retry_cost`. Status-code-classified retries always fall
      // into the "normal" bucket.
      RetryAfter(delay_ms: delay, cost: retry_cost)
    }
  }
}

fn classify_transport_error(
  _err: HttpError,
  attempt: Int,
  strategy: Strategy,
) -> Decision {
  // Every transport-layer failure is classified as `TransientError`.
  case attempt < strategy.max_attempts {
    True ->
      RetryAfter(
        delay_ms: exponential_backoff(strategy, attempt),
        cost: timeout_retry_cost,
      )
    False -> GiveUp
  }
}

type StatusKind {
  NotRetryable
  Retryable
}

/// 408 and 429 are throttling-adjacent (request timeout / too many
/// requests); 5xx is server fault. All map to the same retry cost class —
/// matches the Rust SDK's `acquire(ErrorKind)` switch.
fn classify_status(status: Int) -> StatusKind {
  case status {
    408 | 429 -> Retryable
    s if s >= 500 && s <= 599 -> Retryable
    _ -> NotRetryable
  }
}

fn retry_after_seconds(resp: Response(BitArray)) -> Option(Int) {
  case response.get_header(resp, "retry-after") {
    Ok(value) ->
      case int.parse(value) {
        Ok(secs) ->
          case secs >= 0 {
            True -> Some(secs)
            False -> None
          }
        Error(_) -> None
      }
    Error(_) -> None
  }
}

/// Exponential backoff with full jitter, mirrored from Rust SDK
/// `calculate_exponential_backoff`:
///
///   raw   = base * 2^(attempt-1)
///   bound = min(raw, max)
///   delay = rng() * bound
///
/// `attempt` is 1-indexed (the first retry uses base * 2^0 = base).
pub fn exponential_backoff(strategy: Strategy, attempt: Int) -> Int {
  let raw = strategy.base_delay_ms * pow2(attempt - 1)
  let bound = int.min(raw, strategy.max_delay_ms)
  let jittered = strategy.rng() *. int.to_float(bound)
  case float.round(jittered) {
    n if n < 0 -> 0
    n -> n
  }
}

fn pow2(n: Int) -> Int {
  do_pow2(n, 1)
}

fn do_pow2(n: Int, acc: Int) -> Int {
  case n <= 0 {
    True -> acc
    False -> do_pow2(n - 1, acc * 2)
  }
}

@external(erlang, "aws_ffi", "random_float")
fn random_float() -> Float

fn gate(strategy: Strategy, cost: Int) -> GateOutcome {
  case strategy.rate_limiter {
    None -> NoBucket
    Some(bucket) ->
      case rate_limiter.try_acquire(bucket, cost: cost) {
        Acquired(permit: p) -> GotPermit(permit: p)
        Empty -> BucketEmpty
      }
  }
}

fn release_if_held(strategy: Strategy, permit: Option(Permit)) -> Nil {
  case strategy.rate_limiter, permit {
    Some(bucket), Some(p) -> rate_limiter.release(bucket, permit: p)
    _, _ -> Nil
  }
}

fn reward_if_present(strategy: Strategy) -> Nil {
  case strategy.rate_limiter {
    Some(bucket) -> rate_limiter.reward_success(bucket)
    None -> Nil
  }
}
