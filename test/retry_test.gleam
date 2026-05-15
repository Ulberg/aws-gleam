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
import gleam/list
import gleam/otp/actor
import gleeunit/should

// ---------- stub Send that scripts a sequence of responses ----------

type ScriptedResponse {
  RespOk(status: Int, headers: List(#(String, String)))
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

// ---------- adaptive: token bucket interplay ----------

pub fn adaptive_throttle_halves_token_bucket_test() {
  let assert Ok(bucket) =
    rate_limiter.start(max_capacity: 100, replenish_per_success: 5)
  let initial = rate_limiter.current(bucket)
  initial.available |> should.equal(100)

  let script =
    start_script([
      RespOk(status: 429, headers: []),
      RespOk(status: 429, headers: []),
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

  // Two throttles halve the bucket twice (100 → 50 → 25), then one success
  // tops up by 5 → 30.
  let final = rate_limiter.current(bucket)
  final.available |> should.equal(30)
}

pub fn adaptive_success_replenishes_bucket_test() {
  let assert Ok(bucket) =
    rate_limiter.start(max_capacity: 100, replenish_per_success: 10)
  // Knock the bucket down first.
  rate_limiter.on_throttle(bucket)
  rate_limiter.on_throttle(bucket)
  // 100 → 50 → 25
  rate_limiter.current(bucket).available |> should.equal(25)

  let script = start_script([RespOk(status: 200, headers: [])])
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

  // One success tops up by 10: 25 → 35.
  rate_limiter.current(bucket).available |> should.equal(35)
}

pub fn rate_limiter_floor_at_one_token_test() {
  // Beat the bucket all the way down: it must not go to zero, so the next
  // retry still has *some* shot at succeeding.
  let assert Ok(bucket) =
    rate_limiter.start(max_capacity: 4, replenish_per_success: 1)
  list.repeat(Nil, times: 11)
  |> list.each(fn(_) { rate_limiter.on_throttle(bucket) })
  rate_limiter.current(bucket).available |> should.equal(1)
}
