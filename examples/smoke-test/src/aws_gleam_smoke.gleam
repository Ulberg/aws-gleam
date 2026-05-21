//// Smoke-test entry. Same OTP release services both Fargate task
//// shapes; `SMOKE_ROLE` env var picks which:
////
////   * `writer`  — one-shot task. Reads the payload from
////     `SMOKE_PAYLOAD` (or stdin if that's empty), writes it to S3
////     under `events/<utc-timestamp>-<rand>.bin`, sends the key as
////     an SQS message body, then exits. Triggered via
////     `aws ecs run-task` from the deploy script.
////
////   * `reader` — long-running service. Polls SQS in a loop
////     (long-poll wait_time_seconds=20), GETs each key it sees
////     from S3, logs the byte count, deletes the message. The
////     ECS service `desired_count = 1` keeps exactly one of these
////     alive at a time.
////
//// Both roles use the standard aws-gleam credentials chain — on
//// Fargate that picks up the task-role creds from
//// `AWS_CONTAINER_CREDENTIALS_RELATIVE_URI` via the ECS-metadata
//// endpoint, same path real production workloads use.

import gleam/io
import gleam/result
import reader_handler
import writer_handler

pub fn main() {
  case role() {
    "writer" -> exit_on_error(writer_handler.run())
    "reader" -> reader_handler.run_forever()
    other -> {
      io.println_error("unknown SMOKE_ROLE: " <> other)
      halt(2)
    }
  }
}

fn role() -> String {
  os_getenv("SMOKE_ROLE") |> result.unwrap("writer")
}

fn exit_on_error(res: Result(String, String)) -> Nil {
  case res {
    Ok(summary) -> {
      io.println(summary)
      halt(0)
    }
    Error(msg) -> {
      io.println_error("smoke-test failed: " <> msg)
      halt(1)
    }
  }
}

@external(erlang, "smoke_ffi", "get_env")
fn os_getenv(name: String) -> Result(String, Nil)

@external(erlang, "erlang", "halt")
fn halt(status: Int) -> a
