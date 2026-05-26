//// Lambda Runtime API contract tests.
////
//// The runtime speaks an HTTP contract to the endpoint Lambda advertises in
//// `AWS_LAMBDA_RUNTIME_API`. There is no published conformance suite for it
//// (unlike SigV4), so these drive the runtime with a stubbed `Send` that
//// asserts the exact method/URL/body/headers of every call and scripts the
//// responses — exercising next/response/error/init-error, the per-invocation
//// context parse, trace-id propagation, handler-error and handler-panic
//// reporting, and the full serve loop. Endpoint shapes follow
//// <https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html>.

import aws/internal/http_send
import aws/lambda
import gleam/bit_array
import gleam/dict
import gleam/erlang/process
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

fn api_with(
  send: fn(Request(BitArray)) -> Result(Response(BitArray), http_send.HttpError),
) -> lambda.Api {
  lambda.Api(send: send, endpoint: "127.0.0.1:9001")
}

fn ok(
  status: Int,
  headers: List(#(String, String)),
  body: String,
) -> Result(Response(BitArray), http_send.HttpError) {
  Ok(response.Response(
    status: status,
    headers: headers,
    body: bit_array.from_string(body),
  ))
}

const next_path = "/2018-06-01/runtime/invocation/next"

// --- next -----------------------------------------------------------------

pub fn next_parses_full_context_test() {
  let send = fn(req: Request(BitArray)) {
    req.method |> should.equal(http.Get)
    req.host |> should.equal("127.0.0.1")
    req.port |> should.equal(Some(9001))
    req.path |> should.equal(next_path)
    ok(
      200,
      [
        #("lambda-runtime-aws-request-id", "8476a536-e9f4-11e8"),
        #("lambda-runtime-deadline-ms", "1700000000000"),
        #(
          "lambda-runtime-invoked-function-arn",
          "arn:aws:lambda:us-east-2:123456789012:function:custom-runtime",
        ),
        #("lambda-runtime-trace-id", "Root=1-5bef4de7-ad49b0e87f6ef6c87fc2e700"),
      ],
      "{\"hello\":\"world\"}",
    )
  }

  let assert Ok(invocation) = lambda.next(api_with(send))
  let context = invocation.context
  context.request_id |> should.equal("8476a536-e9f4-11e8")
  context.deadline_ms |> should.equal(1_700_000_000_000)
  context.invoked_function_arn
  |> should.equal(
    "arn:aws:lambda:us-east-2:123456789012:function:custom-runtime",
  )
  context.trace_id
  |> should.equal(Some("Root=1-5bef4de7-ad49b0e87f6ef6c87fc2e700"))
  context.client_context |> should.equal(None)
  context.cognito_identity |> should.equal(None)
  invocation.payload
  |> should.equal(bit_array.from_string("{\"hello\":\"world\"}"))
}

pub fn next_defaults_optional_context_fields_test() {
  // Only the required request-id header present.
  let send = fn(_req) {
    ok(200, [#("lambda-runtime-aws-request-id", "rid")], "{}")
  }
  let assert Ok(invocation) = lambda.next(api_with(send))
  invocation.context.deadline_ms |> should.equal(0)
  invocation.context.invoked_function_arn |> should.equal("")
  invocation.context.trace_id |> should.equal(None)
}

pub fn next_without_request_id_is_error_test() {
  let send = fn(_req) { ok(200, [], "{}") }
  lambda.next(api_with(send)) |> should.equal(Error(lambda.MissingRequestId))
}

pub fn next_transport_error_is_surfaced_test() {
  let send = fn(_req) { Error(http_send.ConnectFailed("no route")) }
  lambda.next(api_with(send))
  |> should.equal(Error(lambda.Transport(http_send.ConnectFailed("no route"))))
}

pub fn next_unexpected_status_is_error_test() {
  let send = fn(_req) { ok(403, [], "") }
  lambda.next(api_with(send))
  |> should.equal(Error(lambda.UnexpectedStatus(endpoint: "next", status: 403)))
}

// --- response / error / init-error ---------------------------------------

pub fn send_response_posts_to_response_url_test() {
  let send = fn(req: Request(BitArray)) {
    req.method |> should.equal(http.Post)
    req.path
    |> should.equal("/2018-06-01/runtime/invocation/req-42/response")
    req.body |> should.equal(bit_array.from_string("RESULT-BYTES"))
    ok(202, [], "")
  }
  lambda.send_response(
    api_with(send),
    "req-42",
    bit_array.from_string("RESULT-BYTES"),
  )
  |> should.equal(Ok(Nil))
}

pub fn send_error_posts_json_body_and_error_type_header_test() {
  let send = fn(req: Request(BitArray)) {
    req.method |> should.equal(http.Post)
    req.path |> should.equal("/2018-06-01/runtime/invocation/req-42/error")
    request.get_header(req, "lambda-runtime-function-error-type")
    |> should.equal(Ok("MyError"))
    let assert Ok(body) = bit_array.to_string(req.body)
    body
    |> should.equal(
      "{\"errorType\":\"MyError\",\"errorMessage\":\"it broke\",\"stackTrace\":[]}",
    )
    ok(202, [], "")
  }
  lambda.send_error(
    api_with(send),
    "req-42",
    lambda.invocation_error("MyError", "it broke"),
  )
  |> should.equal(Ok(Nil))
}

pub fn send_init_error_posts_to_init_error_url_test() {
  let send = fn(req: Request(BitArray)) {
    req.path |> should.equal("/2018-06-01/runtime/init/error")
    request.get_header(req, "lambda-runtime-function-error-type")
    |> should.equal(Ok("Runtime.BootError"))
    ok(202, [], "")
  }
  lambda.send_init_error(
    api_with(send),
    lambda.invocation_error("Runtime.BootError", "bad config"),
  )
  |> should.equal(Ok(Nil))
}

pub fn post_unexpected_status_is_error_test() {
  let send = fn(_req) { ok(500, [], "") }
  lambda.send_response(api_with(send), "x", <<>>)
  |> should.equal(
    Error(lambda.UnexpectedStatus(endpoint: "response", status: 500)),
  )
}

// --- process_invocation ---------------------------------------------------

fn route(
  next_headers: List(#(String, String)),
  next_body: String,
  on_post: fn(Request(BitArray)) ->
    Result(Response(BitArray), http_send.HttpError),
) -> fn(Request(BitArray)) -> Result(Response(BitArray), http_send.HttpError) {
  fn(req: Request(BitArray)) {
    case req.path {
      "/2018-06-01/runtime/invocation/next" -> ok(200, next_headers, next_body)
      _ -> on_post(req)
    }
  }
}

pub fn process_invocation_happy_path_posts_handler_result_test() {
  let send =
    route([#("lambda-runtime-aws-request-id", "rid")], "PING", fn(req) {
      req.path
      |> should.equal("/2018-06-01/runtime/invocation/rid/response")
      req.body |> should.equal(bit_array.from_string("PONG"))
      ok(202, [], "")
    })
  let handler = fn(payload, _ctx) {
    payload |> should.equal(bit_array.from_string("PING"))
    Ok(bit_array.from_string("PONG"))
  }
  lambda.process_invocation(api_with(send), fn(_) { Nil }, handler)
  |> should.equal(Ok(Nil))
}

pub fn process_invocation_propagates_trace_id_test() {
  let send =
    route(
      [
        #("lambda-runtime-aws-request-id", "rid"),
        #("lambda-runtime-trace-id", "Root=1-trace"),
      ],
      "{}",
      fn(_req) { ok(202, [], "") },
    )
  let captured = process.new_subject()
  let set_trace = fn(trace_id) {
    process.send(captured, trace_id)
    Nil
  }
  lambda.process_invocation(api_with(send), set_trace, fn(_p, _c) { Ok(<<>>) })
  |> should.equal(Ok(Nil))
  process.receive(captured, 0) |> should.equal(Ok("Root=1-trace"))
}

pub fn process_invocation_handler_error_is_reported_test() {
  let send =
    route([#("lambda-runtime-aws-request-id", "rid")], "{}", fn(req) {
      req.path |> should.equal("/2018-06-01/runtime/invocation/rid/error")
      request.get_header(req, "lambda-runtime-function-error-type")
      |> should.equal(Ok("BadInput"))
      ok(202, [], "")
    })
  let handler = fn(_p, _c) {
    Error(lambda.invocation_error("BadInput", "missing field"))
  }
  lambda.process_invocation(api_with(send), fn(_) { Nil }, handler)
  |> should.equal(Ok(Nil))
}

pub fn process_invocation_handler_panic_is_reported_as_unhandled_test() {
  let send =
    route([#("lambda-runtime-aws-request-id", "rid")], "{}", fn(req) {
      req.path |> should.equal("/2018-06-01/runtime/invocation/rid/error")
      request.get_header(req, "lambda-runtime-function-error-type")
      |> should.equal(Ok("Unhandled"))
      let assert Ok(body) = bit_array.to_string(req.body)
      string.contains(body, "kaboom") |> should.be_true
      ok(202, [], "")
    })
  let handler = fn(_p, _c) { panic as "kaboom" }
  lambda.process_invocation(api_with(send), fn(_) { Nil }, handler)
  |> should.equal(Ok(Nil))
}

pub fn process_invocation_runtime_error_on_next_propagates_test() {
  let send = fn(_req) { Error(http_send.Timeout) }
  lambda.process_invocation(api_with(send), fn(_) { Nil }, fn(_p, _c) {
    Ok(<<>>)
  })
  |> should.equal(Error(lambda.Transport(http_send.Timeout)))
}

// --- serve loop -----------------------------------------------------------

pub fn serve_loops_then_stops_on_runtime_error_test() {
  // Script two good invocations on /next, then drain (which the stub turns
  // into a transport error to break the otherwise-infinite loop).
  let next_queue = process.new_subject()
  process.send(
    next_queue,
    ok(200, [#("lambda-runtime-aws-request-id", "r1")], "A"),
  )
  process.send(
    next_queue,
    ok(200, [#("lambda-runtime-aws-request-id", "r2")], "B"),
  )
  let posted = process.new_subject()

  let send = fn(req: Request(BitArray)) {
    case req.path {
      "/2018-06-01/runtime/invocation/next" ->
        case process.receive(next_queue, 0) {
          Ok(scripted) -> scripted
          Error(_) -> Error(http_send.ConnectFailed("drained"))
        }
      path -> {
        process.send(posted, #(path, req.body))
        ok(202, [], "")
      }
    }
  }

  // Echo handler: response body == event payload.
  let stop =
    lambda.serve(api_with(send), fn(_) { Nil }, fn(payload, _ctx) {
      Ok(payload)
    })

  stop
  |> should.equal(lambda.Transport(http_send.ConnectFailed("drained")))

  // Both invocations were processed, in order, each posting its echoed body.
  process.receive(posted, 0)
  |> should.equal(
    Ok(#(
      "/2018-06-01/runtime/invocation/r1/response",
      bit_array.from_string("A"),
    )),
  )
  process.receive(posted, 0)
  |> should.equal(
    Ok(#(
      "/2018-06-01/runtime/invocation/r2/response",
      bit_array.from_string("B"),
    )),
  )
  process.receive(posted, 0) |> should.equal(Error(Nil))
}

// --- api_from_env ---------------------------------------------------------

pub fn api_from_env_without_runtime_api_var_test() {
  // AWS_LAMBDA_RUNTIME_API is unset outside a Lambda execution environment.
  lambda.api_from_env() |> should.equal(Error(lambda.NotRunningInLambda))
}

// --- local run (invoke_once / event resolution) ---------------------------

pub fn invoke_once_returns_handler_ok_test() {
  let handler = fn(payload, _ctx) { Ok(payload) }
  lambda.invoke_once(handler, bit_array.from_string("hi"))
  |> should.equal(Ok(bit_array.from_string("hi")))
}

pub fn invoke_once_returns_handler_error_test() {
  let handler = fn(_p, _c) { Error(lambda.invocation_error("Bad", "nope")) }
  lambda.invoke_once(handler, <<>>)
  |> should.equal(Error(lambda.invocation_error("Bad", "nope")))
}

pub fn invoke_once_traps_panic_as_unhandled_test() {
  let handler = fn(_p, _c) { panic as "boom" }
  let assert Error(failure) = lambda.invoke_once(handler, <<>>)
  failure.error_type |> should.equal("Unhandled")
  string.contains(failure.error_message, "boom") |> should.be_true
}

pub fn context_default_is_local_test() {
  lambda.context_default().request_id |> should.equal("local")
}

fn env_of(pairs: List(#(String, String))) -> fn(String) -> Result(String, Nil) {
  let table = dict.from_list(pairs)
  fn(name) { dict.get(table, name) }
}

pub fn local_event_prefers_event_arg_test() {
  lambda.local_event_from(["--event", "{\"a\":1}"], env_of([]))
  |> should.equal("{\"a\":1}")
}

pub fn local_event_accepts_short_flag_test() {
  lambda.local_event_from(["-e", "X", "ignored"], env_of([]))
  |> should.equal("X")
}

pub fn local_event_arg_beats_env_test() {
  lambda.local_event_from(
    ["--event", "FROM_ARG"],
    env_of([#("LAMBDA_EVENT", "FROM_ENV")]),
  )
  |> should.equal("FROM_ARG")
}

pub fn local_event_falls_back_to_env_test() {
  lambda.local_event_from(["prog"], env_of([#("LAMBDA_EVENT", "FROM_ENV")]))
  |> should.equal("FROM_ENV")
}

pub fn local_event_defaults_to_empty_object_test() {
  lambda.local_event_from([], env_of([])) |> should.equal("{}")
}
