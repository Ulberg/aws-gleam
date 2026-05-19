//// Functional pin for the codegen-emitted `with_max_attempts(client, n)`
//// setter. The emitter test in `codegen/test/emitter_test.gleam`
//// asserts the signature is present; this test asserts the setter
//// actually changes runtime behavior on a real generated Client.
////
//// Setup: stub `http_send` on an `s3.Client` to record + return
//// 503 for every call, set `with_max_attempts(client, 1)`, invoke
//// `s3.list_buckets`, and verify the stub saw exactly one call
//// (not three, which is `retry.standard()`'s default budget). A
//// regression in the codegen-emitted wrapper (wrong runtime call,
//// missing client.cache passthrough, etc.) flips this to three
//// recorded calls or a compile error.

import aws/credentials
import aws/internal/http_send as aws_http
import aws/services/s3
import gleam/erlang/process.{type Subject}
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{None}
import gleeunit/should

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

/// Records every invocation onto `counter` and returns 503 so
/// `runtime.invoke` treats it as transient + retries (if the
/// strategy allows).
fn always_503_recording_send(counter: Subject(Int)) -> aws_http.Send {
  fn(_req: Request(BitArray)) {
    process.send(counter, 1)
    Ok(response.Response(status: 503, headers: [], body: <<>>))
  }
}

fn count_messages(subject: Subject(Int), acc: Int) -> Int {
  case process.receive(subject, 0) {
    Ok(_) -> count_messages(subject, acc + 1)
    Error(_) -> acc
  }
}

pub fn with_max_attempts_one_disables_retry_test() {
  let counter = process.new_subject()
  let client =
    s3.new(region: "us-east-1")
    |> s3.with_credentials_provider(static_credentials())
    |> s3.with_http_send(always_503_recording_send(counter))
    |> s3.with_max_attempts(1)

  let input =
    s3.ListBucketsRequest(
      bucket_region: None,
      continuation_token: None,
      max_buckets: None,
      prefix: None,
    )
  // Don't care about the outcome — only how many HTTP attempts
  // the runtime issued. Default retry would issue three on a 503.
  let _ = s3.list_buckets(client, input)

  count_messages(counter, 0) |> should.equal(1)
  s3.shutdown(client)
}
