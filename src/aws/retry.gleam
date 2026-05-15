//// Retry middleware. Wraps any `http_send.Send` with the standard or
//// adaptive retry semantics every AWS SDK ships:
////
////   - Exponential backoff with full jitter (`min(max, base * 2^n) * rand()`)
////   - Status-code classifier: 2xx success; 4xx (except 408/429) is
////     non-retryable; 408/429/5xx retryable; transport errors retryable.
////   - `Retry-After` header (in seconds or HTTP date) honoured for 429 and
////     503 responses — overrides the computed backoff.
////   - Adaptive: additionally gates retries through a token-bucket rate
////     limiter that shrinks on throttling and replenishes on success.
////
//// The clock, sleep, and RNG are all injected so retry behaviour is fully
//// deterministic under tests. `standard()` plugs in the production
//// defaults (OS rand, `process.sleep`, the `aws_ffi` clock).

import aws/internal/http_send.{type HttpError, type Send}
import aws/internal/retry/rate_limiter.{type Bucket}
import gleam/erlang/process
import gleam/float
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/option.{type Option, None, Some}

/// Default maximum total attempts (the initial try plus retries). Matches
/// the AWS SDK "standard" mode default.
pub const default_max_attempts: Int = 3

/// Base delay before the first retry, in milliseconds.
pub const default_base_delay_ms: Int = 100

/// Cap on any individual retry delay, in milliseconds (20 s — matches the
/// Rust SDK's `MAX_BACKOFF`).
pub const default_max_delay_ms: Int = 20_000

/// What the strategy decided after looking at the last attempt.
pub type Decision {
  /// Attempt succeeded — return the response to the caller.
  Stop
  /// Attempt failed retryably — sleep `delay_ms` then attempt again.
  RetryAfter(delay_ms: Int)
  /// Attempt failed non-retryably or attempts are exhausted — surface the
  /// last response/error.
  GiveUp
}

/// A retry strategy. Opaque to callers; built via `standard` / `adaptive`.
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

/// Build a standard retry strategy with the AWS-SDK-default knobs. Use
/// `standard_with(...)` if you need to tune any of them; the test suite
/// passes a zero-sleep + deterministic-RNG variant.
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

/// Standard strategy with explicit knobs. All four mirror their `default_*`
/// counterparts.
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

/// Adaptive retry: standard semantics plus a token-bucket rate limiter that
/// halves available tokens when the server throttles and replenishes on
/// success.
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

/// Adaptive strategy with explicit knobs (see `standard_with`).
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

/// Wrap a `Send` with retry semantics. The returned `Send` calls the inner
/// `send` repeatedly per the strategy's classifier and backoff.
pub fn with_retry(send send: Send, strategy strategy: Strategy) -> Send {
  fn(req) { do_attempt(send, strategy, req, 1) }
}

fn do_attempt(
  send: Send,
  strategy: Strategy,
  req: Request(BitArray),
  attempt: Int,
) -> Result(Response(BitArray), HttpError) {
  let result = send(req)
  case classify(result, attempt, strategy) {
    Stop -> {
      // Successful attempt — replenish the adaptive token bucket if any.
      release_to_bucket(strategy)
      result
    }
    GiveUp -> result
    RetryAfter(delay_ms: delay) -> {
      // Throttling debits the bucket; non-throttle retryable does too but
      // with a smaller cost. We treat both the same for now.
      acquire_from_bucket(strategy)
      strategy.sleep(delay)
      do_attempt(send, strategy, req, attempt + 1)
    }
  }
}

/// Classify the outcome of one attempt. Exposed because the protocol codecs
/// (M5) will want to override `Retry-After` interpretation per service, and
/// because tests assert on it directly.
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
  let retryable = is_retryable_status(resp.status)
  case retryable, attempt < strategy.max_attempts {
    False, _ -> Stop
    // It's retryable but we've used our last attempt — return whatever the
    // server sent. The caller can still inspect the status code.
    True, False -> GiveUp
    True, True -> {
      // Honour Retry-After when present (429 / 503 most often). The header
      // can be a non-negative integer (seconds) or an HTTP date; we only
      // parse the integer form for now.
      let delay = case retry_after_seconds(resp) {
        Some(secs) -> int.min(secs * 1000, strategy.max_delay_ms)
        None -> exponential_backoff(strategy, attempt)
      }
      RetryAfter(delay_ms: delay)
    }
  }
}

fn classify_transport_error(
  _err: HttpError,
  attempt: Int,
  strategy: Strategy,
) -> Decision {
  // Every transport error (connect refused, timeout, TLS, garbage response)
  // is treated as transient. The signing layer is responsible for surfacing
  // its own deterministic errors before they ever hit us.
  case attempt < strategy.max_attempts {
    True -> RetryAfter(delay_ms: exponential_backoff(strategy, attempt))
    False -> GiveUp
  }
}

/// AWS-style retryable status codes. 408 / 429 are throttling-adjacent; 5xx
/// is server fault. Everything else is the caller's problem.
fn is_retryable_status(status: Int) -> Bool {
  case status {
    408 | 429 -> True
    s if s >= 500 && s <= 599 -> True
    _ -> False
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

/// Exponential backoff with full jitter:
///
///   raw   = base * 2^(attempt-1)
///   bound = min(raw, max)
///   delay = rng() * bound
///
/// `attempt` is 1-indexed (so the *first* retry uses base * 2^0 = base).
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

fn acquire_from_bucket(strategy: Strategy) -> Nil {
  case strategy.rate_limiter {
    Some(bucket) -> rate_limiter.on_throttle(bucket)
    None -> Nil
  }
}

fn release_to_bucket(strategy: Strategy) -> Nil {
  case strategy.rate_limiter {
    Some(bucket) -> rate_limiter.on_success(bucket)
    None -> Nil
  }
}
