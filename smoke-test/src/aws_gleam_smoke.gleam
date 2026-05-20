//// Lambda handler entry point. The same OTP release services three
//// roles, distinguished by the `SMOKE_ROLE` env var the Terraform
//// module sets per Lambda function:
////
////   - `list_buckets` (default) — proof-of-life: invoke `s3.list_buckets`
////     and return the count. Validates credentials chain + endpoint
////     resolution + HTTP transport without depending on any side
////     effects in the AWS account.
////
////   - `writer` — for each invocation event, write the raw payload to
////     S3 under `events/<request_id>.bin`, then send the key as an
////     SQS message body to `SMOKE_QUEUE_URL`. Together with `reader`
////     this exercises the S3 + SQS clients end-to-end and verifies
////     the credentials chain works for both restXml and awsJson1_0
////     services from the same Client config.
////
////   - `reader` — SQS-triggered. The Lambda Runtime API delivers the
////     standard `{ "Records": [{ "body": "<key>", ... }, ...] }`
////     envelope; we fetch each S3 object whose key is in `body` and
////     log its byte count. The integration deletes the SQS message
////     on a successful return.
////
//// Each role's handler lives in its own module so they stay easy to
//// read in isolation; the dispatch here is one `case` on the env var.

import gleam/result
import list_buckets_handler
import reader_handler
import runtime_api.{type Invocation}
import writer_handler

pub fn main() {
  // Lambda's runtime starts our process and immediately expects us
  // to start polling. Failure to enter the loop = Init error.
  case runtime_api.run_loop(pick_handler()) {
    Ok(_) -> Nil
    Error(_) -> Nil
  }
}

/// Choose the handler for the running Lambda based on `SMOKE_ROLE`.
/// Unset / unrecognised values fall through to the safe `list_buckets`
/// proof-of-life — that's what the existing single-Lambda deployment
/// has always done.
fn pick_handler() -> fn(Invocation) -> Result(BitArray, String) {
  case role() {
    "writer" -> writer_handler.handle
    "reader" -> reader_handler.handle
    _ -> list_buckets_handler.handle
  }
}

fn role() -> String {
  os_getenv("SMOKE_ROLE") |> result.unwrap("list_buckets")
}

@external(erlang, "os", "getenv")
fn os_getenv(name: String) -> Result(String, Nil)
