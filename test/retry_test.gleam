//// Tests for the retry middleware. Every test drives a stub `Send` with a
//// scripted sequence of (status, body) responses, runs the wrapped
//// `with_retry` strategy, then asserts on the final outcome and the count
//// of attempts the stub saw.

import aws/internal/http_send.{type HttpError, type Send}
import aws/internal/retry/rate_limiter
import aws/retry
import gleam/bit_array
import gleam/erlang/process.{type Subject}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/otp/actor
import gleeunit/should

// ---------- stub Send that scripts a sequence of responses ----------

type ScriptedResponse {
  RespOk(status: Int, headers: List(#(String, String)))
  /// Like `RespOk` but with a JSON body, so tests can exercise the
  /// modeled-error-code classifier (e.g. a 400 carrying a DynamoDB
  /// `__type` throttling code).
  RespBody(status: Int, headers: List(#(String, String)), body: String)
  RespError(error: HttpError)
}

type ScriptMessage {
  Next(reply: Subject(ScriptedResponse))
  Count(reply: Subject(Int))
}

fn start_script(responses: List(ScriptedResponse)) -> Subject(ScriptMessage) {
  let assert Ok(started) =
    actor.new(#(responses, 0))
    |> actor.on_message(fn(state, message) {
      let #(remaining, count) = state
      case message {
        Next(reply: reply) ->
          case remaining {
            [head, ..rest] -> {
              process.send(reply, head)
              actor.continue(#(rest, count + 1))
            }
            [] -> {
              // Script ran out — return an error so the test fails loudly.
              process.send(
                reply,
                RespError(http_send.Other(reason: "script exhausted")),
              )
              actor.continue(#([], count + 1))
            }
          }
        Count(reply: reply) -> {
          process.send(reply, count)
          actor.continue(state)
        }
      }
    })
    |> actor.start
  started.data
}

fn pop_next(script: Subject(ScriptMessage)) -> ScriptedResponse {
  actor.call(script, waiting: 1000, sending: Next)
}

fn attempt_count(script: Subject(ScriptMessage)) -> Int {
  actor.call(script, waiting: 1000, sending: Count)
}

fn stub_send(script: Subject(ScriptMessage)) -> Send {
  fn(_req: Request(BitArray)) {
    case pop_next(script) {
      RespOk(status: status, headers: headers) ->
        Ok(response.Response(
          status: status,
          headers: headers,
          body: bit_array.from_string(""),
        ))
      RespBody(status: status, headers: headers, body: body) ->
        Ok(response.Response(
          status: status,
          headers: headers,
          body: bit_array.from_string(body),
        ))
      RespError(error: e) -> Error(e)
    }
  }
}

// ---------- helpers ----------

fn empty_req() -> Request(BitArray) {
  let assert Ok(r) = request.to("https://example.test/x")
  r
  |> request.set_method(http.Get)
  |> request.set_body(bit_array.from_string(""))
}

fn no_sleep(_ms: Int) -> Nil {
  Nil
}

fn fixed_rng() -> Float {
  // Deterministic 0.5 — picks the midpoint of the jitter range so backoff
  // calculations are predictable.
  0.5
}

fn test_strategy() -> retry.Strategy {
  retry.standard_with(
    max_attempts: 3,
    base_delay_ms: 100,
    max_delay_ms: 1000,
    sleep: no_sleep,
    rng: fixed_rng,
  )
}

// ---------- success on first try ----------

pub fn success_on_first_try_is_one_attempt_test() {
  let script = start_script([RespOk(status: 200, headers: [])])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(1)
}

// ---------- 5xx then success ----------

pub fn one_503_then_200_retries_once_test() {
  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn two_503s_then_200_retries_twice_test() {
  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(3)
}

pub fn exhausting_max_attempts_surfaces_last_status_test() {
  // 3 × 503 with max_attempts=3 → fail, return the last 503 to the caller.
  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(503)
  attempt_count(script) |> should.equal(3)
}

// ---------- 429 throttling ----------

pub fn throttle_429_is_retried_test() {
  let script =
    start_script([
      RespOk(status: 429, headers: []),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn retry_after_header_drives_delay_test() {
  let captured = process.new_subject()
  let capturing_sleep = fn(ms: Int) -> Nil {
    process.send(captured, ms)
    Nil
  }
  let script =
    start_script([
      RespOk(status: 429, headers: [#("retry-after", "2")]),
      RespOk(status: 200, headers: []),
    ])
  let strategy =
    retry.standard_with(
      max_attempts: 3,
      base_delay_ms: 100,
      max_delay_ms: 10_000,
      sleep: capturing_sleep,
      rng: fixed_rng,
    )
  let send = retry.with_retry(send: stub_send(script), strategy: strategy)
  let assert Ok(_) = send(empty_req())
  // Retry-After: 2 (seconds) → 2000 ms — overrides the computed backoff.
  let assert Ok(delay_ms) = process.receive(from: captured, within: 100)
  delay_ms |> should.equal(2000)
}

// ---------- non-retryable client errors ----------

pub fn client_403_is_not_retried_test() {
  // 4xx (other than 408/429) is the caller's misconfiguration — never retry.
  let script = start_script([RespOk(status: 403, headers: [])])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(403)
  attempt_count(script) |> should.equal(1)
}

pub fn client_404_is_not_retried_test() {
  let script = start_script([RespOk(status: 404, headers: [])])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(_) = send(empty_req())
  attempt_count(script) |> should.equal(1)
}

// ---------- transport errors ----------

pub fn transport_error_is_retried_test() {
  let script =
    start_script([
      RespError(error: http_send.ConnectFailed(reason: "no route")),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn timeout_then_success_test() {
  let script =
    start_script([
      RespError(error: http_send.Timeout),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(_) = send(empty_req())
  attempt_count(script) |> should.equal(2)
}

// ---------- exponential backoff math ----------

pub fn backoff_grows_exponentially_with_attempt_test() {
  // Use a fixed RNG of 1.0 so every result equals the upper bound directly.
  let strategy =
    retry.standard_with(
      max_attempts: 5,
      base_delay_ms: 100,
      max_delay_ms: 10_000,
      sleep: no_sleep,
      rng: fn() { 1.0 },
    )
  retry.exponential_backoff(strategy, 1) |> should.equal(100)
  retry.exponential_backoff(strategy, 2) |> should.equal(200)
  retry.exponential_backoff(strategy, 3) |> should.equal(400)
  retry.exponential_backoff(strategy, 4) |> should.equal(800)
}

pub fn backoff_clamps_to_max_delay_test() {
  let strategy =
    retry.standard_with(
      max_attempts: 99,
      base_delay_ms: 100,
      max_delay_ms: 500,
      sleep: no_sleep,
      rng: fn() { 1.0 },
    )
  retry.exponential_backoff(strategy, 10) |> should.equal(500)
}

// ---------- adaptive: token bucket gating ----------

pub fn successful_retry_returns_permit_tokens_test() {
  // Matches Rust SDK behaviour: a retry that ultimately succeeds leaves the
  // bucket essentially unchanged (the held permit is released, success_reward
  // adds 0 by default). 1× 503 → 200 should net to original capacity.
  let assert Ok(bucket) = rate_limiter.start(capacity: 100, success_reward: 0)
  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 200, headers: []),
    ])
  let strategy =
    retry.adaptive_with(
      bucket: bucket,
      max_attempts: 5,
      base_delay_ms: 1,
      max_delay_ms: 10,
      sleep: no_sleep,
      rng: fixed_rng,
    )
  let send = retry.with_retry(send: stub_send(script), strategy: strategy)
  let assert Ok(_) = send(empty_req())
  // -retry_cost +retry_cost +0 = 0 net change.
  rate_limiter.current(bucket).available |> should.equal(100)
}

pub fn transport_error_uses_timeout_retry_cost_test() {
  // Transport errors are classified as TransientError → timeout_retry_cost
  // (10), while a 503 would use retry_cost (5). One transport error + final
  // give-up keeps the larger cost debited longer.
  let assert Ok(bucket) = rate_limiter.start(capacity: 100, success_reward: 0)
  let script =
    start_script([
      RespError(error: http_send.Timeout),
      RespError(error: http_send.Timeout),
      RespOk(status: 200, headers: []),
    ])
  let strategy =
    retry.adaptive_with(
      bucket: bucket,
      max_attempts: 5,
      base_delay_ms: 1,
      max_delay_ms: 10,
      sleep: no_sleep,
      rng: fixed_rng,
    )
  let send = retry.with_retry(send: stub_send(script), strategy: strategy)
  let assert Ok(_) = send(empty_req())
  // Across the retry loop the cost is acquired then released between
  // attempts and after success — the bucket should end where it started.
  rate_limiter.current(bucket).available |> should.equal(100)
}

pub fn exhausted_retries_leak_no_permit_test() {
  // 3× 503 with max=3 exhausts retries. The held permit should still be
  // released so subsequent operations aren't starved. (Rust SDK: final
  // permit dropped via RAII on terminal non-retryable / exhausted.)
  let assert Ok(bucket) = rate_limiter.start(capacity: 100, success_reward: 0)
  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
    ])
  let strategy =
    retry.adaptive_with(
      bucket: bucket,
      max_attempts: 3,
      base_delay_ms: 1,
      max_delay_ms: 10,
      sleep: no_sleep,
      rng: fixed_rng,
    )
  let send = retry.with_retry(send: stub_send(script), strategy: strategy)
  let assert Ok(_) = send(empty_req())
  rate_limiter.current(bucket).available |> should.equal(100)
}

pub fn success_reward_adds_above_returned_tokens_test() {
  // Setting success_reward > 0 makes the bucket actually grow on a
  // successful run (beyond just refunding the permit). This is the
  // configurable knob — matches Rust SDK's `success_reward()` builder.
  let assert Ok(bucket) = rate_limiter.start(capacity: 100, success_reward: 3)
  // Pre-debit by 20.
  let assert rate_limiter.Acquired(_) =
    rate_limiter.try_acquire(bucket, cost: 20)
  rate_limiter.current(bucket).available |> should.equal(80)

  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 200, headers: []),
    ])
  let strategy =
    retry.adaptive_with(
      bucket: bucket,
      max_attempts: 3,
      base_delay_ms: 1,
      max_delay_ms: 10,
      sleep: no_sleep,
      rng: fixed_rng,
    )
  let send = retry.with_retry(send: stub_send(script), strategy: strategy)
  let assert Ok(_) = send(empty_req())
  // -5 (acquire) +5 (release) +3 (reward) = 83.
  rate_limiter.current(bucket).available |> should.equal(83)
}

pub fn adaptive_empty_bucket_stops_retries_test() {
  let assert Ok(bucket) = rate_limiter.start(capacity: 5, success_reward: 0)
  let assert rate_limiter.Acquired(_) =
    rate_limiter.try_acquire(bucket, cost: 5)
  rate_limiter.current(bucket).available |> should.equal(0)

  let script = start_script([RespOk(status: 503, headers: [])])
  let strategy =
    retry.adaptive_with(
      bucket: bucket,
      max_attempts: 5,
      base_delay_ms: 1,
      max_delay_ms: 10,
      sleep: no_sleep,
      rng: fixed_rng,
    )
  let send = retry.with_retry(send: stub_send(script), strategy: strategy)
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(503)
  attempt_count(script) |> should.equal(1)
}

pub fn bucket_reward_caps_at_capacity_test() {
  let assert Ok(bucket) = rate_limiter.start(capacity: 5, success_reward: 100)
  rate_limiter.reward_success(bucket)
  rate_limiter.reward_success(bucket)
  rate_limiter.current(bucket).available |> should.equal(5)
}

pub fn bucket_release_caps_at_capacity_test() {
  // A wild release that would exceed capacity (e.g. reward + release racing)
  // is clamped, matching Rust SDK's `add_permits` clamping behaviour.
  let assert Ok(bucket) = rate_limiter.start(capacity: 10, success_reward: 0)
  let assert rate_limiter.Acquired(p) =
    rate_limiter.try_acquire(bucket, cost: 5)
  rate_limiter.release(bucket, permit: p)
  // Releasing the same permit twice (or any extra release) must not push
  // available above capacity.
  rate_limiter.release(bucket, permit: p)
  rate_limiter.current(bucket).available |> should.equal(10)
}

pub fn bucket_try_acquire_returns_empty_when_short_test() {
  let assert Ok(bucket) = rate_limiter.start(capacity: 5, success_reward: 0)
  let assert rate_limiter.Acquired(_) =
    rate_limiter.try_acquire(bucket, cost: 5)
  let assert rate_limiter.Empty = rate_limiter.try_acquire(bucket, cost: 1)
  rate_limiter.current(bucket).available |> should.equal(0)
}

// ---------- edge cases caught by the M4 audit ----------

pub fn status_408_is_retried_like_429_test() {
  let script =
    start_script([
      RespOk(status: 408, headers: []),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn max_attempts_1_means_no_retries_test() {
  // With max_attempts=1, even a retryable error should NOT retry.
  let script = start_script([RespOk(status: 503, headers: [])])
  let strategy =
    retry.standard_with(
      max_attempts: 1,
      base_delay_ms: 100,
      max_delay_ms: 1000,
      sleep: no_sleep,
      rng: fixed_rng,
    )
  let send = retry.with_retry(send: stub_send(script), strategy: strategy)
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(503)
  attempt_count(script) |> should.equal(1)
}

// Mirrors aws-sdk-rust `calculate_exponential_backoff_where_initial_backoff_is_one`.
pub fn backoff_with_initial_one_ms_test() {
  let strategy =
    retry.standard_with(
      max_attempts: 5,
      base_delay_ms: 1,
      max_delay_ms: 10_000,
      sleep: no_sleep,
      rng: fn() { 1.0 },
    )
  retry.exponential_backoff(strategy, 1) |> should.equal(1)
  retry.exponential_backoff(strategy, 2) |> should.equal(2)
  retry.exponential_backoff(strategy, 3) |> should.equal(4)
  retry.exponential_backoff(strategy, 4) |> should.equal(8)
}

// Mirrors aws-sdk-rust
// `should_not_panic_when_exponential_backoff_duration_could_not_be_created`.
// We use Erlang bignums so `2^N` never overflows, but the `min(_, max_delay)`
// clamp must still keep the output sane for very large attempt counts.
pub fn large_attempt_count_clamps_safely_test() {
  let strategy =
    retry.standard_with(
      max_attempts: 1000,
      base_delay_ms: 100,
      max_delay_ms: 20_000,
      sleep: no_sleep,
      rng: fn() { 1.0 },
    )
  retry.exponential_backoff(strategy, 64) |> should.equal(20_000)
  retry.exponential_backoff(strategy, 256) |> should.equal(20_000)
}

pub fn exponential_backoff_zero_when_rng_is_zero_test() {
  // rng = 0.0 means no jitter — delay collapses to 0.
  let strategy =
    retry.standard_with(
      max_attempts: 5,
      base_delay_ms: 1000,
      max_delay_ms: 30_000,
      sleep: no_sleep,
      rng: fn() { 0.0 },
    )
  retry.exponential_backoff(strategy, 1) |> should.equal(0)
  retry.exponential_backoff(strategy, 5) |> should.equal(0)
}

// ---------- bucket lifecycle ----------

pub fn bucket_shutdown_sync_stops_the_actor_test() {
  // The bucket spawns an OTP process; long-running apps that build
  // many adaptive strategies (or rebuild on config change) need to
  // release the actor or the BEAM accumulates one process per
  // strategy. `shutdown_sync` is the deterministic monitor-based
  // teardown — mirrors `credentials_cache.shutdown_sync`.
  let assert Ok(bucket) = rate_limiter.start_default()
  rate_limiter.shutdown_sync(bucket, 200) |> should.equal(Ok(Nil))
}

pub fn bucket_shutdown_sync_is_idempotent_test() {
  // Second call sees the subject's owner gone and short-circuits to
  // `Ok(Nil)` rather than hanging on a monitor signal that will
  // never arrive.
  let assert Ok(bucket) = rate_limiter.start_default()
  rate_limiter.shutdown_sync(bucket, 200) |> should.equal(Ok(Nil))
  rate_limiter.shutdown_sync(bucket, 200) |> should.equal(Ok(Nil))
}

pub fn bucket_shutdown_fire_and_forget_is_observable_via_sync_test() {
  // Plain `shutdown` returns immediately; the actor exits on its
  // next dispatch. A follow-up `shutdown_sync` observes the exit.
  let assert Ok(bucket) = rate_limiter.start_default()
  rate_limiter.shutdown(bucket)
  rate_limiter.shutdown_sync(bucket, 200) |> should.equal(Ok(Nil))
}

// ---------- with_max_attempts / with_base_delay_ms / with_max_delay_ms ----------
//
// These setters tweak a single Strategy field without forcing the
// caller to re-supply the other knobs. Tests pin the behavioural
// override (attempts taking effect) and the field-preservation
// invariant (other knobs survive).

pub fn with_max_attempts_overrides_attempt_budget_test() {
  // standard_with(3 attempts) capped down to 1 — a single 503 must
  // surface immediately as the result. No retries.
  let strategy =
    retry.standard_with(
      max_attempts: 3,
      base_delay_ms: 0,
      max_delay_ms: 0,
      sleep: no_sleep,
      rng: fixed_rng,
    )
    |> retry.with_max_attempts(1)
  let script = start_script([RespOk(status: 503, headers: [])])
  let send = retry.with_retry(send: stub_send(script), strategy:)
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(503)
  attempt_count(script) |> should.equal(1)
}

pub fn with_max_attempts_preserves_other_knobs_test() {
  // Bumping max_attempts on a no-sleep strategy keeps the
  // sleep / rng / delay knobs intact — exhaustion at 4 means
  // 4 attempts and zero wall-clock wait.
  let strategy =
    retry.standard_with(
      max_attempts: 2,
      base_delay_ms: 0,
      max_delay_ms: 0,
      sleep: no_sleep,
      rng: fixed_rng,
    )
    |> retry.with_max_attempts(4)
  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
      RespOk(status: 503, headers: []),
    ])
  let send = retry.with_retry(send: stub_send(script), strategy:)
  let assert Ok(_) = send(empty_req())
  attempt_count(script) |> should.equal(4)
}

pub fn with_base_delay_and_max_delay_ms_compose_with_max_attempts_test() {
  // Chaining the three setters off `retry.standard()` must produce a
  // working strategy that retries once on 503, then succeeds on 200.
  // standard() uses process.sleep which would block 1+ second per
  // retry; the zero-delay overrides + max_attempts=2 cap make the
  // test instant.
  let strategy =
    retry.standard()
    |> retry.with_max_attempts(2)
    |> retry.with_base_delay_ms(0)
    |> retry.with_max_delay_ms(0)
  let script =
    start_script([
      RespOk(status: 503, headers: []),
      RespOk(status: 200, headers: []),
    ])
  let send = retry.with_retry(send: stub_send(script), strategy:)
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

// ---------- modeled-error-code classification (issue #29) ----------
//
// Many AWS throttling / transient errors arrive as HTTP 400 with the
// retryable signal in the response body's modeled error code
// (`__type`), not the status line. The classifier must honour the
// modeled code in addition to the status-based rules.

fn json_type(code: String) -> String {
  "{\"__type\":\"" <> code <> "\",\"message\":\"throttled\"}"
}

pub fn provisioned_throughput_exceeded_400_is_retried_test() {
  let script =
    start_script([
      RespBody(
        status: 400,
        headers: [],
        body: json_type("ProvisionedThroughputExceededException"),
      ),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn throttling_exception_400_is_retried_test() {
  let script =
    start_script([
      RespBody(status: 400, headers: [], body: json_type("ThrottlingException")),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn namespaced_throttling_exception_400_is_retried_test() {
  // AWS often namespaces `__type`: `com.amazonaws...#ThrottlingException`.
  // The classifier matches on the local suffix after `#` (and after the
  // last `.`).
  let script =
    start_script([
      RespBody(
        status: 400,
        headers: [],
        body: json_type("com.amazonaws.dynamodb.v20120810#ThrottlingException"),
      ),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn validation_exception_400_is_not_retried_test() {
  // A non-throttling 400 (the caller's bad input) must NOT be retried.
  let script =
    start_script([
      RespBody(status: 400, headers: [], body: json_type("ValidationException")),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(400)
  attempt_count(script) |> should.equal(1)
}

pub fn throttling_via_error_type_header_is_retried_test() {
  // awsJson / restJson1 surface the modeled code in the
  // `x-amzn-errortype` header; the classifier honours it too.
  let script =
    start_script([
      RespOk(status: 400, headers: [
        #("x-amzn-errortype", "TooManyRequestsException"),
      ]),
      RespOk(status: 200, headers: []),
    ])
  let send =
    retry.with_retry(send: stub_send(script), strategy: test_strategy())
  let assert Ok(resp) = send(empty_req())
  resp.status |> should.equal(200)
  attempt_count(script) |> should.equal(2)
}

pub fn is_retryable_error_code_predicate_test() {
  retry.is_retryable_error_code("ThrottlingException") |> should.equal(True)
  retry.is_retryable_error_code("ProvisionedThroughputExceededException")
  |> should.equal(True)
  retry.is_retryable_error_code(
    "com.amazonaws.dynamodb.v20120810#ThrottlingException",
  )
  |> should.equal(True)
  retry.is_retryable_error_code("TransactionInProgressException")
  |> should.equal(True)
  retry.is_retryable_error_code("ValidationException") |> should.equal(False)
  retry.is_retryable_error_code("ResourceNotFoundException")
  |> should.equal(False)
}
