//// Token-bucket rate limiter backing the adaptive retry strategy.
////
//// State:
////
////   - `available`: tokens currently in the bucket. Each retry attempt
////     "borrows" one token via `on_throttle`. Each successful attempt
////     replenishes via `on_success`.
////   - `max_capacity`: the upper bound on `available`. A successful
////     run-of-1 (first try succeeds) replenishes faster than a
////     long-retry success because the slope is `(max - available)`
////     scaled by `replenish_factor`.
////
//// Concurrency: messages are processed sequentially, so two adaptive
//// strategies sharing a bucket coordinate correctly. The bucket is
//// `Send`-safe; passing it across processes is fine.

import gleam/erlang/process.{type Subject}
import gleam/otp/actor

/// Opaque handle. Build via `start`.
pub opaque type Bucket {
  Bucket(subject: Subject(Message))
}

type Message {
  /// A retry attempt is asking for permission. Returns the cost-debited
  /// state along with whether the bucket had enough tokens to allow it.
  Acquire(cost: Int, reply: Subject(AcquireResult))
  /// Success path: return tokens to the bucket (capped at max_capacity).
  OnSuccess
  /// Synchronous reply for tests.
  Read(reply: Subject(BucketState))
}

pub type BucketState {
  BucketState(available: Int, max_capacity: Int)
}

pub type AcquireResult {
  /// Bucket had tokens; the requested cost was debited.
  Acquired
  /// Bucket couldn't satisfy the request — caller should give up retrying.
  Empty
}

type State {
  State(available: Int, max_capacity: Int, replenish_per_success: Int)
}

pub type StartError {
  StartFailed(actor.StartError)
}

/// Start a bucket with `max_capacity` tokens initially available. The
/// strategy halves `available` on each throttle and adds
/// `replenish_per_success` (capped at `max_capacity`) on each success.
pub fn start(
  max_capacity max_capacity: Int,
  replenish_per_success replenish_per_success: Int,
) -> Result(Bucket, StartError) {
  let initial =
    State(
      available: max_capacity,
      max_capacity: max_capacity,
      replenish_per_success: replenish_per_success,
    )
  case
    actor.new(initial)
    |> actor.on_message(handle)
    |> actor.start
  {
    Ok(started) -> Ok(Bucket(subject: started.data))
    Error(reason) -> Error(StartFailed(reason))
  }
}

/// Production defaults: 500 tokens, replenish 5 per success.
pub fn start_default() -> Result(Bucket, StartError) {
  start(max_capacity: 500, replenish_per_success: 5)
}

/// Try to acquire `cost` tokens from the bucket. Returns `Acquired` (cost
/// debited from the bucket) or `Empty` (bucket couldn't satisfy the request
/// — caller should NOT retry).
pub fn try_acquire(bucket: Bucket, cost cost: Int) -> AcquireResult {
  actor.call(bucket.subject, waiting: 1000, sending: fn(reply) {
    Acquire(cost: cost, reply: reply)
  })
}

/// Called after a successful attempt. Returns up to `replenish_per_success`
/// tokens to the bucket, capped at `max_capacity`.
pub fn on_success(bucket: Bucket) -> Nil {
  process.send(bucket.subject, OnSuccess)
}

/// Synchronously read the current bucket state. Used by tests.
pub fn current(bucket: Bucket) -> BucketState {
  actor.call(bucket.subject, waiting: 1000, sending: Read)
}

fn handle(state: State, message: Message) -> actor.Next(State, Message) {
  case message {
    Acquire(cost: cost, reply: reply) -> {
      case state.available >= cost {
        True -> {
          process.send(reply, Acquired)
          actor.continue(State(..state, available: state.available - cost))
        }
        False -> {
          process.send(reply, Empty)
          actor.continue(state)
        }
      }
    }
    OnSuccess -> {
      let topped = state.available + state.replenish_per_success
      let new = case topped > state.max_capacity {
        True -> state.max_capacity
        False -> topped
      }
      actor.continue(State(..state, available: new))
    }
    Read(reply: reply) -> {
      process.send(
        reply,
        BucketState(
          available: state.available,
          max_capacity: state.max_capacity,
        ),
      )
      actor.continue(state)
    }
  }
}
