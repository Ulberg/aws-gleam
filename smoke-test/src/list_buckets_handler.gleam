//// Original single-scenario handler: `s3.list_buckets` and return
//// the count. Default role for `aws-gleam-smoke` (used by direct
//// `aws lambda invoke` for proof-of-life smoke testing).
////
//// Lifted out of `aws_gleam_smoke.gleam` when the writer / reader
//// roles landed; behaviour unchanged.

import aws/services/s3
import gleam/bit_array
import gleam/option.{None}
import gleam/string
import runtime_api.{type Invocation}

pub fn handle(_inv: Invocation) -> Result(BitArray, String) {
  // Auto-region resolves from `AWS_REGION` which Lambda sets
  // automatically. Credentials chain picks up `AWS_ACCESS_KEY_ID` /
  // `AWS_SECRET_ACCESS_KEY` / `AWS_SESSION_TOKEN` from the env, set
  // by Lambda from the execution role.
  use client <- try_with_summary("client_init", s3.new_with_auto_region())

  let input =
    s3.ListBucketsRequest(
      bucket_region: None,
      continuation_token: None,
      max_buckets: None,
      prefix: None,
    )
  case s3.list_buckets(client, input) {
    Ok(out) -> {
      s3.shutdown(client)
      Ok(bit_array.from_string(summarise_buckets(out)))
    }
    Error(err) -> {
      s3.shutdown(client)
      Error("list_buckets failed: " <> string.inspect(err))
    }
  }
}

/// Bind a `Result` with a step label so the eventual error message
/// pinpoints which stage of the handler tripped. Cheaper than
/// wrapping each branch in `result.map_error(fn(_) { "label: ..." })`.
fn try_with_summary(
  step: String,
  result: Result(a, e),
  k: fn(a) -> Result(b, String),
) -> Result(b, String) {
  case result {
    Ok(v) -> k(v)
    Error(e) -> Error(step <> ": " <> string.inspect(e))
  }
}

fn summarise_buckets(out: s3.ListBucketsOutput) -> String {
  case out.buckets {
    None -> "{\"buckets\":0}"
    option.Some(bs) ->
      "{\"buckets\":" <> int_to_string(list_length(bs)) <> "}"
  }
}

@external(erlang, "erlang", "integer_to_binary")
fn int_to_string(n: Int) -> String

@external(erlang, "erlang", "length")
fn list_length(xs: List(a)) -> Int
