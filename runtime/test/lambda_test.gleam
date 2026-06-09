//// Tests for the AWS Lambda custom runtime (`aws/lambda`).
////
//// The runtime talks to the Lambda Runtime API over an injected `Send`
//// (`aws/internal/http_send.Send`), so every test drives the loop through a
//// mock sender: a closure that records each outgoing `Request` to a
//// `process.Subject` and replies with a canned `Response`. That lets us
//// assert the exact HTTP contract — URLs, methods, bodies, the
//// `Lambda-Runtime-*` headers — without a live endpoint, and exercise the
//// full poll → handle → respond/error lifecycle plus the crash-trapping and
//// multi-invocation loop.
////
//// The header casing and JSON shapes match the Runtime API spec:
//// https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html

import aws/internal/http_send.{type HttpError, type Send}
import aws/lambda
import gleam/bit_array
import gleam/dynamic/decode
import gleam/erlang/process.{type Subject}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/json
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

const endpoint: String = "127.0.0.1:9001"

// --- mock transport -------------------------------------------------------

/// A `Send` that records every request to `recorder`, then replies with
/// whatever `responder` returns for that request.
fn recording_send(
  recorder: Subject(Request(BitArray)),
  responder: fn(Request(BitArray)) -> Result(Response(BitArray), HttpError),
) -> Send {
  fn(req) {
    process.send(recorder, req)
    responder(req)
  }
}

/// Responder that answers `GET /next` with `event` + `headers` and accepts
/// any `POST` with `202 Accepted`. Models one full invocation turn.
fn next_or_accept(
  event: BitArray,
  headers: List(#(String, String)),
) -> fn(Request(BitArray)) -> Result(Response(BitArray), HttpError) {
  fn(req: Request(BitArray)) {
    case req.method {
      http.Get -> ok(200, headers, event)
      _ -> ok(202, [], <<>>)
    }
  }
}

fn ok(
  status: Int,
  headers: List(#(String, String)),
  body: BitArray,
) -> Result(Response(BitArray), HttpError) {
  Ok(response.Response(status: status, headers: headers, body: body))
}

/// The `Lambda-Runtime-*` headers httpc delivers (lowercased) on a populated
/// `/next` response.
fn next_headers() -> List(#(String, String)) {
  [
    #("lambda-runtime-aws-request-id", "req-id-1"),
    #("lambda-runtime-deadline-ms", "1700000000123"),
    #(
      "lambda-runtime-invoked-function-arn",
      "arn:aws:lambda:us-east-1:123456789012:function:my-fn",
    ),
    #("lambda-runtime-trace-id", "Root=1-5e1b4151-trace"),
  ]
}

fn expect_request(recorder: Subject(Request(BitArray))) -> Request(BitArray) {
  case process.receive(recorder, 500) {
    Ok(req) -> req
    Error(_) -> panic as "expected a recorded request but none arrived"
  }
}

fn test_context() -> lambda.Context {
  lambda.Context(
    request_id: "rid",
    deadline_ms: 0,
    invoked_function_arn: "",
    trace_id: None,
    client_context: None,
    cognito_identity: None,
  )
}

// --- next() ---------------------------------------------------------------

pub fn next_parses_full_context_test() {
  let recorder = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(recorder, fn(_) {
        ok(200, next_headers(), <<"the-payload":utf8>>)
      }),
      endpoint: endpoint,
    )

  let assert Ok(invocation) = lambda.next(api)

  invocation.payload |> should.equal(<<"the-payload":utf8>>)
  let ctx = invocation.context
  ctx.request_id |> should.equal("req-id-1")
  ctx.deadline_ms |> should.equal(1_700_000_000_123)
  ctx.invoked_function_arn
  |> should.equal("arn:aws:lambda:us-east-1:123456789012:function:my-fn")
  ctx.trace_id |> should.equal(Some("Root=1-5e1b4151-trace"))
  ctx.client_context |> should.equal(None)
  ctx.cognito_identity |> should.equal(None)

  // The poll is a GET rooted at the versioned Runtime API path.
  let req = expect_request(recorder)
  req.method |> should.equal(http.Get)
  req.host |> should.equal("127.0.0.1")
  req.port |> should.equal(Some(9001))
  req.path |> should.equal("/2018-06-01/runtime/invocation/next")
}

pub fn next_tolerates_absent_optional_headers_test() {
  // Only the required request-id present: deadline defaults to 0, arn to "",
  // trace/client/cognito to None; mobile-SDK headers surface when present.
  let headers = [
    #("lambda-runtime-aws-request-id", "r2"),
    #("lambda-runtime-client-context", "client-ctx-b64"),
    #("lambda-runtime-cognito-identity", "cognito-id"),
  ]
  let api =
    lambda.Api(send: fn(_) { ok(200, headers, <<>>) }, endpoint: endpoint)

  let assert Ok(inv) = lambda.next(api)
  inv.context.request_id |> should.equal("r2")
  inv.context.deadline_ms |> should.equal(0)
  inv.context.invoked_function_arn |> should.equal("")
  inv.context.trace_id |> should.equal(None)
  inv.context.client_context |> should.equal(Some("client-ctx-b64"))
  inv.context.cognito_identity |> should.equal(Some("cognito-id"))
}

pub fn next_without_request_id_is_missing_request_id_test() {
  let api = lambda.Api(send: fn(_) { ok(200, [], <<>>) }, endpoint: endpoint)
  lambda.next(api) |> should.equal(Error(lambda.MissingRequestId))
}

pub fn next_non_200_is_unexpected_status_test() {
  let api = lambda.Api(send: fn(_) { ok(403, [], <<>>) }, endpoint: endpoint)
  lambda.next(api)
  |> should.equal(Error(lambda.UnexpectedStatus(endpoint: "next", status: 403)))
}

pub fn next_transport_failure_is_transport_error_test() {
  let api =
    lambda.Api(
      send: fn(_) { Error(http_send.Timeout) },
      endpoint: endpoint,
    )
  lambda.next(api)
  |> should.equal(Error(lambda.Transport(http_send.Timeout)))
}

// --- send_response() ------------------------------------------------------

pub fn send_response_posts_body_to_response_url_test() {
  let recorder = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(recorder, fn(_) { ok(202, [], <<>>) }),
      endpoint: endpoint,
    )

  lambda.send_response(api, "abc-123", <<"the-result":utf8>>)
  |> should.equal(Ok(Nil))

  let req = expect_request(recorder)
  req.method |> should.equal(http.Post)
  req.path
  |> should.equal("/2018-06-01/runtime/invocation/abc-123/response")
  req.body |> should.equal(<<"the-result":utf8>>)
}

pub fn send_response_non_2xx_is_unexpected_status_test() {
  let api = lambda.Api(send: fn(_) { ok(500, [], <<>>) }, endpoint: endpoint)
  lambda.send_response(api, "abc", <<>>)
  |> should.equal(Error(lambda.UnexpectedStatus(
    endpoint: "response",
    status: 500,
  )))
}

// --- send_error() / send_init_error() -------------------------------------

type ErrorBody {
  ErrorBody(error_type: String, error_message: String, stack_trace: List(String))
}

fn error_body_decoder() -> decode.Decoder(ErrorBody) {
  use error_type <- decode.field("errorType", decode.string)
  use error_message <- decode.field("errorMessage", decode.string)
  use stack_trace <- decode.field("stackTrace", decode.list(decode.string))
  decode.success(ErrorBody(error_type:, error_message:, stack_trace:))
}

fn parse_error_body(req: Request(BitArray)) -> ErrorBody {
  let assert Ok(text) = bit_array.to_string(req.body)
  let assert Ok(body) = json.parse(text, error_body_decoder())
  body
}

pub fn send_error_posts_json_body_and_error_type_header_test() {
  let recorder = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(recorder, fn(_) { ok(202, [], <<>>) }),
      endpoint: endpoint,
    )
  let err =
    lambda.InvocationError(
      error_type: "My.CustomError",
      error_message: "it broke",
      stack_trace: ["frame-1", "frame-2"],
    )

  lambda.send_error(api, "req-9", err) |> should.equal(Ok(Nil))

  let req = expect_request(recorder)
  req.method |> should.equal(http.Post)
  req.path |> should.equal("/2018-06-01/runtime/invocation/req-9/error")
  request.get_header(req, "lambda-runtime-function-error-type")
  |> should.equal(Ok("My.CustomError"))
  request.get_header(req, "content-type")
  |> should.equal(Ok("application/json"))
  parse_error_body(req)
  |> should.equal(ErrorBody("My.CustomError", "it broke", [
    "frame-1", "frame-2",
  ]))
}

pub fn send_init_error_posts_to_init_error_url_test() {
  let recorder = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(recorder, fn(_) { ok(202, [], <<>>) }),
      endpoint: endpoint,
    )

  lambda.send_init_error(api, lambda.invocation_error("Init.Fail", "no boot"))
  |> should.equal(Ok(Nil))

  let req = expect_request(recorder)
  req.method |> should.equal(http.Post)
  req.path |> should.equal("/2018-06-01/runtime/init/error")
  request.get_header(req, "lambda-runtime-function-error-type")
  |> should.equal(Ok("Init.Fail"))
}

// --- process_invocation() -------------------------------------------------

pub fn process_invocation_posts_handler_output_test() {
  let recorder = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(
        recorder,
        next_or_accept(<<"{\"n\":1}":utf8>>, next_headers()),
      ),
      endpoint: endpoint,
    )

  // Handler echoes the event bytes straight back as the response body.
  let handler = fn(payload: BitArray, _ctx) { Ok(payload) }
  lambda.process_invocation(api, fn(_) { Nil }, handler)
  |> should.equal(Ok(Nil))

  let get = expect_request(recorder)
  get.method |> should.equal(http.Get)
  get.path |> should.equal("/2018-06-01/runtime/invocation/next")

  let post = expect_request(recorder)
  post.method |> should.equal(http.Post)
  post.path
  |> should.equal("/2018-06-01/runtime/invocation/req-id-1/response")
  post.body |> should.equal(<<"{\"n\":1}":utf8>>)
}

pub fn process_invocation_reports_handler_error_test() {
  let recorder = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(
        recorder,
        next_or_accept(<<"{}":utf8>>, next_headers()),
      ),
      endpoint: endpoint,
    )

  let handler = fn(_payload, _ctx) {
    Error(lambda.invocation_error("Biz.Rejected", "no"))
  }
  lambda.process_invocation(api, fn(_) { Nil }, handler)
  |> should.equal(Ok(Nil))

  let _get = expect_request(recorder)
  let post = expect_request(recorder)
  post.path |> should.equal("/2018-06-01/runtime/invocation/req-id-1/error")
  request.get_header(post, "lambda-runtime-function-error-type")
  |> should.equal(Ok("Biz.Rejected"))
  parse_error_body(post)
  |> should.equal(ErrorBody("Biz.Rejected", "no", []))
}

pub fn process_invocation_traps_handler_crash_test() {
  let recorder = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(
        recorder,
        next_or_accept(<<"{}":utf8>>, next_headers()),
      ),
      endpoint: endpoint,
    )

  // A panicking handler must not take the loop down: the runtime traps it,
  // reports it as an "Unhandled" error, and process_invocation still returns
  // Ok(Nil) (the /error POST succeeded).
  let handler = fn(_payload, _ctx) { panic as "kaboom" }
  lambda.process_invocation(api, fn(_) { Nil }, handler)
  |> should.equal(Ok(Nil))

  let _get = expect_request(recorder)
  let post = expect_request(recorder)
  post.path |> should.equal("/2018-06-01/runtime/invocation/req-id-1/error")
  request.get_header(post, "lambda-runtime-function-error-type")
  |> should.equal(Ok("Unhandled"))
  let body = parse_error_body(post)
  body.error_type |> should.equal("Unhandled")
  string.contains(body.error_message, "kaboom") |> should.be_true
}

pub fn process_invocation_propagates_trace_id_test() {
  let recorder = process.new_subject()
  let traces = process.new_subject()
  let api =
    lambda.Api(
      send: recording_send(
        recorder,
        next_or_accept(<<"{}":utf8>>, next_headers()),
      ),
      endpoint: endpoint,
    )

  lambda.process_invocation(
    api,
    fn(trace_id) { process.send(traces, trace_id) },
    fn(payload, _ctx) { Ok(payload) },
  )
  |> should.equal(Ok(Nil))

  process.receive(traces, 500)
  |> should.equal(Ok("Root=1-5e1b4151-trace"))
}

pub fn process_invocation_propagates_fatal_next_error_test() {
  // A Runtime API failure on /next aborts the turn with the RuntimeError;
  // the handler never runs.
  let api = lambda.Api(send: fn(_) { ok(500, [], <<>>) }, endpoint: endpoint)
  lambda.process_invocation(api, fn(_) { Nil }, fn(p, _) { Ok(p) })
  |> should.equal(Error(lambda.UnexpectedStatus(endpoint: "next", status: 500)))
}

// --- serve() loop ---------------------------------------------------------

pub fn serve_returns_first_fatal_runtime_error_test() {
  let api = lambda.Api(send: fn(_) { ok(502, [], <<>>) }, endpoint: endpoint)
  lambda.serve(api, fn(_) { Nil }, fn(p, _) { Ok(p) })
  |> should.equal(lambda.UnexpectedStatus(endpoint: "next", status: 502))
}

pub fn serve_processes_invocations_until_fatal_test() {
  let recorder = process.new_subject()
  let script = process.new_subject()
  let calls = process.new_subject()

  // Script two full turns: next(200) → response(202), next(200) →
  // response(202). The third /next poll finds the script exhausted and
  // returns 500, which stops the loop.
  process.send(script, ok(200, next_headers(), <<"{}":utf8>>))
  process.send(script, ok(202, [], <<>>))
  process.send(script, ok(200, next_headers(), <<"{}":utf8>>))
  process.send(script, ok(202, [], <<>>))

  let send = fn(req) {
    process.send(recorder, req)
    case process.receive(script, 0) {
      Ok(resp) -> resp
      Error(_) -> ok(500, [], <<>>)
    }
  }
  let api = lambda.Api(send: send, endpoint: endpoint)
  let handler = fn(payload, _ctx) {
    process.send(calls, Nil)
    Ok(payload)
  }

  lambda.serve(api, fn(_) { Nil }, handler)
  |> should.equal(lambda.UnexpectedStatus(endpoint: "next", status: 500))

  // Handler ran exactly twice (once per scripted invocation).
  drain_count(calls, 0) |> should.equal(2)
}

fn drain_count(subject: Subject(Nil), n: Int) -> Int {
  case process.receive(subject, 0) {
    Ok(_) -> drain_count(subject, n + 1)
    Error(_) -> n
  }
}

// --- json_handler() -------------------------------------------------------

fn int_field_decoder() -> decode.Decoder(Int) {
  use n <- decode.field("n", decode.int)
  decode.success(n)
}

pub fn json_handler_decodes_event_and_encodes_response_test() {
  let handler =
    lambda.json_handler(
      int_field_decoder(),
      fn(n, _ctx) { Ok(n * 2) },
      fn(out) { json.int(out) },
    )
  let assert Ok(body) = handler(<<"{\"n\":21}":utf8>>, test_context())
  body |> should.equal(<<"42":utf8>>)
}

pub fn json_handler_invalid_json_is_invalid_event_test() {
  let handler =
    lambda.json_handler(int_field_decoder(), fn(n, _) { Ok(n) }, json.int)
  case handler(<<"this is not json":utf8>>, test_context()) {
    Error(e) -> e.error_type |> should.equal("Runtime.InvalidEvent")
    Ok(_) -> should.fail()
  }
}

pub fn json_handler_schema_mismatch_is_invalid_event_test() {
  // Valid JSON but the "n" field is a string, not an int.
  let handler =
    lambda.json_handler(int_field_decoder(), fn(n, _) { Ok(n) }, json.int)
  case handler(<<"{\"n\":\"oops\"}":utf8>>, test_context()) {
    Error(e) -> e.error_type |> should.equal("Runtime.InvalidEvent")
    Ok(_) -> should.fail()
  }
}

pub fn json_handler_non_utf8_payload_is_invalid_event_test() {
  let handler =
    lambda.json_handler(decode.success(Nil), fn(_, _) { Ok(Nil) }, fn(_) {
      json.null()
    })
  case handler(<<0xff, 0xfe, 0xfd>>, test_context()) {
    Error(e) -> e.error_type |> should.equal("Runtime.InvalidEvent")
    Ok(_) -> should.fail()
  }
}

pub fn json_handler_propagates_handler_error_string_test() {
  let handler =
    lambda.json_handler(decode.success(Nil), fn(_, _) { Error("denied") }, fn(_) {
      json.null()
    })
  case handler(<<"{}":utf8>>, test_context()) {
    Error(e) -> {
      e.error_type |> should.equal("Handler.Error")
      e.error_message |> should.equal("denied")
    }
    Ok(_) -> should.fail()
  }
}

// --- api_from_env() -------------------------------------------------------

pub fn api_from_env_without_runtime_api_var_is_not_running_in_lambda_test() {
  // AWS_LAMBDA_RUNTIME_API is unset in the test environment, so the runtime
  // reports it is not executing inside a Lambda sandbox.
  lambda.api_from_env() |> should.equal(Error(lambda.NotRunningInLambda))
}
