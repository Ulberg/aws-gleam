//// Token-bucket retry rate limiter, port of the AWS Smithy runtime's
//// `TokenBucket` (aws-sdk-rust/.../client/retries/token_bucket.rs).
////
//// Semantics:
////
////   - Each retry attempt `acquire`s tokens. The cost depends on the error
////     class (see retry.gleam: `retry_cost` 5 for normal retryable,
////     `timeout_retry_cost` 10 for timeouts / transient).
////   - The acquired tokens are HELD as a `Permit` while the retry is in
////     flight. On success or final non-retryable outcome the caller
////     `release`s the permit, returning the tokens. On retry-failure-then-
////     -retry, the caller releases the prior permit before acquiring the
////     next (Rust does this via permit drop on `set_retry_permit`).
////   - `reward_success` additionally tops up the bucket by `success_reward`
////     tokens. Rust's default is **0** — the bucket is a concurrent-retry
////     semaphore, not an AIMD-style limiter; the time-based `refill_rate`
////     handles long-term recovery in Rust. We follow Rust's default.
////
//// Concurrency: messages are processed sequentially per `gleam_otp`
//// actor semantics.

import gleam/erlang/process.{type Subject}
import gleam/otp/actor

/// Opaque bucket handle.
pub opaque type Bucket {
  Bucket(subject: Subject(Message))
}

/// An acquired set of tokens. Hold this until success or final outcome,
/// then `release` it to return the tokens to the bucket.
pub opaque type Permit {
  Permit(cost: Int)
}

pub fn permit_cost(p: Permit) -> Int {
  p.cost
}

pub type AcquireResult {
  Acquired(permit: Permit)
  Empty
}

type Message {
  TryAcquire(cost: Int, reply: Subject(AcquireResult))
  Release(cost: Int)
  RewardSuccess
  Read(reply: Subject(BucketState))
}

pub type BucketState {
  BucketState(available: Int, capacity: Int)
}

type State {
  State(available: Int, capacity: Int, success_reward: Int)
}

pub type StartError {
  StartFailed(actor.StartError)
}

/// Rust SDK default capacity. See DEFAULT_CAPACITY in token_bucket.rs.
pub const default_capacity: Int = 500

/// Rust SDK default success reward. See DEFAULT_SUCCESS_REWARD.
///
/// The bucket relies on permit RAII for normal recovery; success_reward is
/// the *additional* top-up on success and defaults to 0.
pub const default_success_reward: Int = 0

/// Start a bucket with explicit capacity + reward.
pub fn start(
  capacity capacity: Int,
  success_reward success_reward: Int,
) -> Result(Bucket, StartError) {
  let initial =
    State(
      available: capacity,
      capacity: capacity,
      success_reward: success_reward,
    )
  case actor.new(initial) |> actor.on_message(handle) |> actor.start {
    Ok(started) -> Ok(Bucket(subject: started.data))
    Error(reason) -> Error(StartFailed(reason))
  }
}

/// Start a bucket with Rust SDK defaults (500 / 0).
pub fn start_default() -> Result(Bucket, StartError) {
  start(capacity: default_capacity, success_reward: default_success_reward)
}

/// Try to acquire `cost` tokens. Returns `Acquired(permit)` if the bucket
/// can pay; `Empty` if not (caller must NOT retry).
pub fn try_acquire(bucket: Bucket, cost cost: Int) -> AcquireResult {
  actor.call(bucket.subject, waiting: 1000, sending: fn(reply) {
    TryAcquire(cost: cost, reply: reply)
  })
}

/// Return the permit's tokens to the bucket. Called on success, on a final
/// non-retryable response, and before replacing one held permit with a new
/// one mid-retry-loop.
pub fn release(bucket: Bucket, permit permit: Permit) -> Nil {
  process.send(bucket.subject, Release(cost: permit.cost))
}

/// Top up the bucket by `success_reward` tokens, capped at `capacity`.
/// Called once per successful operation.
pub fn reward_success(bucket: Bucket) -> Nil {
  process.send(bucket.subject, RewardSuccess)
}

/// Read the current bucket state. Tests only.
pub fn current(bucket: Bucket) -> BucketState {
  actor.call(bucket.subject, waiting: 1000, sending: Read)
}

fn handle(state: State, message: Message) -> actor.Next(State, Message) {
  case message {
    TryAcquire(cost: cost, reply: reply) ->
      case state.available >= cost {
        True -> {
          process.send(reply, Acquired(permit: Permit(cost: cost)))
          actor.continue(State(..state, available: state.available - cost))
        }
        False -> {
          process.send(reply, Empty)
          actor.continue(state)
        }
      }
    Release(cost: cost) -> {
      let new_avail = cap_at(state.available + cost, state.capacity)
      actor.continue(State(..state, available: new_avail))
    }
    RewardSuccess -> {
      let new_avail =
        cap_at(state.available + state.success_reward, state.capacity)
      actor.continue(State(..state, available: new_avail))
    }
    Read(reply: reply) -> {
      process.send(
        reply,
        BucketState(available: state.available, capacity: state.capacity),
      )
      actor.continue(state)
    }
  }
}

fn cap_at(value: Int, max: Int) -> Int {
  case value > max {
    True -> max
    False -> value
  }
}
