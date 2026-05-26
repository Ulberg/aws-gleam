//// AWS Lambda custom-runtime support.
////
//// BEAM has no AWS-managed Lambda runtime, so a Gleam function deployed to
//// Lambda has to implement the [Lambda Runtime API][api] itself: a small
//// HTTP contract spoken over the loopback endpoint Lambda advertises in
//// `AWS_LAMBDA_RUNTIME_API`. This module is that implementation.
////
//// The lifecycle is a loop:
////
////   1. `GET  /runtime/invocation/next` — long-poll for the next event.
////      The response body is the raw event payload and the response
////      headers carry the per-invocation [`Context`](#Context).
////   2. Run the handler against the payload + context.
////   3. `POST /runtime/invocation/{id}/response` on success, or
////      `POST /runtime/invocation/{id}/error` on failure.
////   4. Repeat.
////
//// Write `main` as:
////
//// ```gleam
//// import aws/lambda
//// import gleam/bit_array
////
//// pub fn main() {
////   lambda.start(fn(payload, _context) {
////     let assert Ok(text) = bit_array.to_string(payload)
////     Ok(bit_array.from_string("hello, " <> text))
////   })
//// }
//// ```
////
//// For typed events and JSON responses use [`start_json`](#start_json)
//// together with the envelopes in `aws/lambda/event` and the responses in
//// `aws/lambda/response`.
////
//// `start` blocks forever, so it only returns when the runtime cannot
//// continue — either because the process is not running under a Lambda
//// runtime (`NotRunningInLambda`) or because the Runtime API became
//// unreachable. The returned [`RuntimeError`](#RuntimeError) says which.
////
//// A handler that raises (a `panic`, a failed `let assert`, or any Erlang
//// exception) does not take the process down: the runtime traps it, reports
//// it to `/error` as an `"Unhandled"` failure, and serves the next event.
////
//// ## Deploying
////
//// Lambda ships no managed BEAM runtime, so deploy as an OS-only custom
//// runtime (`provided.al2023`). The package needs an executable `bootstrap`
//// at its root that boots the VM and runs your `main`; for an Erlang release
//// built against Amazon Linux 2023 that is roughly:
////
//// ```sh
//// #!/bin/sh
//// set -eu
//// exec "${LAMBDA_TASK_ROOT}/bin/my_app" foreground
//// ```
////
//// In that process Lambda sets `AWS_LAMBDA_RUNTIME_API` (the endpoint this
//// module talks to), plus `_HANDLER` and `LAMBDA_TASK_ROOT`. The handler is
//// whatever your `main` passes to `start`, so `_HANDLER` is unused.
////
//// [api]: https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html

import aws/env
import aws/internal/http_send.{type HttpError, type Send}
import gleam/bit_array
import gleam/dynamic/decode.{type Decoder}
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/int
import gleam/io
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}
import gleam/result

/// The Runtime API version segment. Every endpoint is rooted at
/// `http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/...`.
const api_version: String = "2018-06-01"

/// Per-invocation context, populated from the `Lambda-Runtime-*` response
/// headers of the next-invocation call.
pub type Context {
  Context(
    /// `Lambda-Runtime-Aws-Request-Id`: identifies this invocation. Echoed
    /// back in the `/response` and `/error` URLs.
    request_id: String,
    /// `Lambda-Runtime-Deadline-Ms`: the wall-clock time the invocation
    /// times out, in Unix epoch milliseconds. `0` if the header was absent.
    deadline_ms: Int,
    /// `Lambda-Runtime-Invoked-Function-Arn`: the ARN of the function,
    /// version, or alias the caller invoked.
    invoked_function_arn: String,
    /// `Lambda-Runtime-Trace-Id`: the X-Ray tracing header. The runtime
    /// copies this into the `_X_AMZ_TRACE_ID` environment variable before
    /// calling the handler so AWS SDK calls join the active trace.
    trace_id: Option(String),
    /// `Lambda-Runtime-Client-Context`: base64 client context, set only for
    /// invocations from the AWS Mobile SDK.
    client_context: Option(String),
    /// `Lambda-Runtime-Cognito-Identity`: Cognito identity, set only for
    /// invocations from the AWS Mobile SDK.
    cognito_identity: Option(String),
  )
}

/// The result of polling `/runtime/invocation/next`: the raw event payload
/// plus its context. The payload is bytes — Lambda delivers every trigger
/// (SQS, API Gateway, EventBridge, S3, ...) as a JSON document, but the
/// runtime does not assume UTF-8 so binary custom payloads pass through.
pub type Invocation {
  Invocation(context: Context, payload: BitArray)
}

/// A failure to report back to Lambda for a single invocation. Serialised to
/// the `{ "errorType", "errorMessage", "stackTrace" }` body the Runtime API
/// expects, and `error_type` is also sent in the
/// `Lambda-Runtime-Function-Error-Type` header.
pub type InvocationError {
  InvocationError(
    error_type: String,
    error_message: String,
    stack_trace: List(String),
  )
}

/// A fatal error in the runtime loop itself — distinct from an
/// `InvocationError`, which concerns one event. These stop `serve`/`start`.
pub type RuntimeError {
  /// `AWS_LAMBDA_RUNTIME_API` was not set: the process is not running under
  /// a Lambda execution environment.
  NotRunningInLambda
  /// `AWS_LAMBDA_RUNTIME_API` did not form a valid URL.
  InvalidEndpoint(endpoint: String)
  /// The HTTP transport failed talking to the Runtime API.
  Transport(HttpError)
  /// A next-invocation response arrived without the required
  /// `Lambda-Runtime-Aws-Request-Id` header.
  MissingRequestId
  /// The Runtime API answered with an unexpected status code. `endpoint`
  /// names the call ("next", "response", "error", "init/error").
  UnexpectedStatus(endpoint: String, status: Int)
}

/// What `rescue_call` reports when a handler raises rather than returning.
pub type HandlerCrash {
  HandlerCrash(class: String, message: String, stack_trace: List(String))
}

/// Low-level Runtime API client: the HTTP sender plus the
/// `AWS_LAMBDA_RUNTIME_API` endpoint (a bare `host:port`, no scheme). Build
/// one with [`api_from_env`](#api_from_env), or by hand for testing.
pub type Api {
  Api(send: Send, endpoint: String)
}

/// A raw handler: raw event bytes and context in, response bytes or an
/// `InvocationError` out.
pub type Handler =
  fn(BitArray, Context) -> Result(BitArray, InvocationError)

// --- Entry points ---------------------------------------------------------

/// Run the Lambda runtime loop with a raw bytes handler. Reads
/// `AWS_LAMBDA_RUNTIME_API`, then polls/handles/responds forever. Returns
/// only on a fatal `RuntimeError`.
pub fn start(handler: Handler) -> RuntimeError {
  case api_from_env() {
    Ok(api) -> serve(api, set_xray_trace_id, handler)
    Error(error) -> error
  }
}

/// Run the handler from the same `main`, locally or in the cloud. Under
/// Lambda (`AWS_LAMBDA_RUNTIME_API` set) this is [`start`](#start) — the
/// poll-forever loop. Run any other way (e.g. `gleam run`) it invokes the
/// handler exactly once, prints the response to stdout, and exits the VM —
/// so you can smoke-test before deploying. The local event is read from
/// `--event <json>` (or `-e`), then `$LAMBDA_EVENT`, then `{}`.
///
/// Because it can exit the VM, `run` is meant to be your `main`; for the
/// cloud-only loop with no local/exit behaviour, call [`start`](#start).
pub fn run(handler: Handler) -> RuntimeError {
  case api_from_env() {
    Ok(api) -> serve(api, set_xray_trace_id, handler)
    Error(_) ->
      case invoke_once(handler, bit_array.from_string(local_event())) {
        Ok(body) -> {
          io.println(result.unwrap(bit_array.to_string(body), ""))
          halt(0)
        }
        Error(failure) -> {
          io.println_error(
            failure.error_type <> ": " <> failure.error_message,
          )
          halt(1)
        }
      }
  }
}

/// Invoke the handler once against a raw payload, trapping a panic exactly as
/// the cloud loop does. The testable core of local execution — no I/O and no
/// process exit. Uses [`context_default`](#context_default) for the context.
pub fn invoke_once(
  handler: Handler,
  payload: BitArray,
) -> Result(BitArray, InvocationError) {
  run_handler(handler, payload, context_default())
}

/// A `Context` with local-friendly placeholder values, for `run`'s local
/// path and for tests.
pub fn context_default() -> Context {
  Context(
    request_id: "local",
    deadline_ms: 0,
    invoked_function_arn: "arn:aws:lambda:local:000000000000:function:local",
    trace_id: None,
    client_context: None,
    cognito_identity: None,
  )
}

/// Resolve the local event payload: an `--event`/`-e` argument, else
/// `$LAMBDA_EVENT`, else `{}`. Inputs are injected so it stays testable;
/// `run` calls it with the real argv and environment.
pub fn local_event_from(
  args: List(String),
  read_env: fn(String) -> Result(String, Nil),
) -> String {
  case event_arg(args) {
    Ok(json) -> json
    Error(_) -> result.unwrap(read_env("LAMBDA_EVENT"), "{}")
  }
}

fn local_event() -> String {
  local_event_from(plain_args(), env.get_env)
}

fn event_arg(args: List(String)) -> Result(String, Nil) {
  case args {
    ["--event", value, ..] | ["-e", value, ..] -> Ok(value)
    [_, ..rest] -> event_arg(rest)
    [] -> Error(Nil)
  }
}

/// Run the loop with a typed JSON handler. The event payload is decoded with
/// `decoder`; the handler's `Ok` value is encoded with `encode` and posted
/// as the response; the handler's `Error` string is reported to Lambda. A
/// payload that fails to decode is reported as a `Runtime.InvalidEvent`
/// error without invoking the handler.
///
/// ```gleam
/// import aws/lambda
/// import aws/lambda/event
/// import aws/lambda/response
///
/// pub fn main() {
///   lambda.start_json(
///     event.api_gateway_v2_decoder(),
///     fn(req, _ctx) { Ok(response.proxy_response(200, "hi " <> req.raw_path)) },
///     response.proxy_to_json,
///   )
/// }
/// ```
pub fn start_json(
  decoder: Decoder(event),
  handler: fn(event, Context) -> Result(response, String),
  encode: fn(response) -> Json,
) -> RuntimeError {
  start(json_handler(decoder, handler, encode))
}

/// Adapt a typed JSON handler into a raw [`Handler`](#Handler). Useful when
/// you want to drive the loop yourself via [`serve`](#serve) but still want
/// the decode/encode plumbing.
pub fn json_handler(
  decoder: Decoder(event),
  handler: fn(event, Context) -> Result(response, String),
  encode: fn(response) -> Json,
) -> Handler {
  fn(payload: BitArray, context: Context) {
    use event <- result.try(decode_payload(payload, decoder))
    case handler(event, context) {
      Ok(response) ->
        Ok(bit_array.from_string(json.to_string(encode(response))))
      Error(message) -> Error(invocation_error("Handler.Error", message))
    }
  }
}

/// Build an [`InvocationError`](#InvocationError) with an empty stack trace.
pub fn invocation_error(
  error_type: String,
  message: String,
) -> InvocationError {
  InvocationError(
    error_type: error_type,
    error_message: message,
    stack_trace: [],
  )
}

/// Build an [`Api`](#Api) from `AWS_LAMBDA_RUNTIME_API`. The sender is tuned
/// for the long-poll on `/next`: Lambda may freeze the process between
/// events and hold the connection open up to the 15-minute function ceiling.
pub fn api_from_env() -> Result(Api, RuntimeError) {
  case env.get_env("AWS_LAMBDA_RUNTIME_API") {
    Ok(endpoint) ->
      Ok(Api(send: http_send.with_timeout(seconds: 900), endpoint: endpoint))
    Error(_) -> Error(NotRunningInLambda)
  }
}

// --- The loop -------------------------------------------------------------

/// Process invocations forever. Returns the first `RuntimeError` that stops
/// the loop (Runtime API unreachable, protocol violation, ...). A handler
/// that errors or raises does *not* stop the loop — that failure is reported
/// to `/error` and the loop continues.
///
/// `set_trace_id` is called with the X-Ray trace id before each handler
/// invocation; [`start`](#start) wires it to set `_X_AMZ_TRACE_ID`.
pub fn serve(
  api: Api,
  set_trace_id: fn(String) -> Nil,
  handler: Handler,
) -> RuntimeError {
  case process_invocation(api, set_trace_id, handler) {
    Ok(Nil) -> serve(api, set_trace_id, handler)
    Error(error) -> error
  }
}

/// One turn of the loop: poll `/next`, propagate the trace id, run the
/// handler (trapping exceptions), then post the response or the error.
/// `Ok(Nil)` means the invocation was fully handled — including the case
/// where the handler failed but the `/error` post succeeded. `Error` is
/// reserved for Runtime API failures.
pub fn process_invocation(
  api: Api,
  set_trace_id: fn(String) -> Nil,
  handler: Handler,
) -> Result(Nil, RuntimeError) {
  use invocation <- result.try(next(api))
  let context = invocation.context
  case context.trace_id {
    Some(trace_id) -> set_trace_id(trace_id)
    None -> Nil
  }
  case run_handler(handler, invocation.payload, context) {
    Ok(body) -> send_response(api, context.request_id, body)
    Error(error) -> send_error(api, context.request_id, error)
  }
}

/// Invoke the handler with exception trapping. A raised exception becomes an
/// `"Unhandled"` `InvocationError` carrying the class, message, and stack.
fn run_handler(
  handler: Handler,
  payload: BitArray,
  context: Context,
) -> Result(BitArray, InvocationError) {
  case rescue_call(fn() { handler(payload, context) }) {
    Ok(result) -> result
    Error(crash) -> Error(crash_to_error(crash))
  }
}

fn crash_to_error(crash: HandlerCrash) -> InvocationError {
  InvocationError(
    error_type: "Unhandled",
    error_message: crash.class <> ": " <> crash.message,
    stack_trace: crash.stack_trace,
  )
}

// --- Runtime API calls ----------------------------------------------------

/// Poll `GET /runtime/invocation/next` for the next event. Blocks until
/// Lambda has an invocation to deliver.
pub fn next(api: Api) -> Result(Invocation, RuntimeError) {
  use request <- result.try(
    build_request(http.Get, api, "/runtime/invocation/next", <<>>, []),
  )
  use response <- result.try(send(api, request))
  case response.status {
    200 -> parse_invocation(response)
    status -> Error(UnexpectedStatus(endpoint: "next", status: status))
  }
}

/// `POST /runtime/invocation/{request_id}/response` with the result bytes.
pub fn send_response(
  api: Api,
  request_id: String,
  body: BitArray,
) -> Result(Nil, RuntimeError) {
  use request <- result.try(
    build_request(
      http.Post,
      api,
      "/runtime/invocation/" <> request_id <> "/response",
      body,
      [],
    ),
  )
  expect_accepted(api, "response", request)
}

/// `POST /runtime/invocation/{request_id}/error` with the JSON error body and
/// the `Lambda-Runtime-Function-Error-Type` header.
pub fn send_error(
  api: Api,
  request_id: String,
  error: InvocationError,
) -> Result(Nil, RuntimeError) {
  use request <- result.try(build_request(
    http.Post,
    api,
    "/runtime/invocation/" <> request_id <> "/error",
    error_body(error),
    error_headers(error),
  ))
  expect_accepted(api, "error", request)
}

/// `POST /runtime/init/error` to report a fatal initialization failure
/// before the first invocation is polled.
pub fn send_init_error(
  api: Api,
  error: InvocationError,
) -> Result(Nil, RuntimeError) {
  use request <- result.try(build_request(
    http.Post,
    api,
    "/runtime/init/error",
    error_body(error),
    error_headers(error),
  ))
  expect_accepted(api, "init/error", request)
}

// --- Wire helpers ---------------------------------------------------------

fn parse_invocation(
  response: Response(BitArray),
) -> Result(Invocation, RuntimeError) {
  case response.get_header(response, "lambda-runtime-aws-request-id") {
    Error(_) -> Error(MissingRequestId)
    Ok(request_id) -> {
      let context =
        Context(
          request_id: request_id,
          deadline_ms: header_int(response, "lambda-runtime-deadline-ms"),
          invoked_function_arn: header_or_empty(
            response,
            "lambda-runtime-invoked-function-arn",
          ),
          trace_id: optional_header(response, "lambda-runtime-trace-id"),
          client_context: optional_header(
            response,
            "lambda-runtime-client-context",
          ),
          cognito_identity: optional_header(
            response,
            "lambda-runtime-cognito-identity",
          ),
        )
      Ok(Invocation(context: context, payload: response.body))
    }
  }
}

fn optional_header(
  response: Response(BitArray),
  name: String,
) -> Option(String) {
  option.from_result(response.get_header(response, name))
}

fn header_or_empty(response: Response(BitArray), name: String) -> String {
  response.get_header(response, name) |> result.unwrap("")
}

fn header_int(response: Response(BitArray), name: String) -> Int {
  response.get_header(response, name)
  |> result.try(int.parse)
  |> result.unwrap(0)
}

fn error_headers(error: InvocationError) -> List(#(String, String)) {
  [
    #("lambda-runtime-function-error-type", error.error_type),
    #("content-type", "application/json"),
  ]
}

fn error_body(error: InvocationError) -> BitArray {
  json.object([
    #("errorType", json.string(error.error_type)),
    #("errorMessage", json.string(error.error_message)),
    #("stackTrace", json.array(error.stack_trace, json.string)),
  ])
  |> json.to_string
  |> bit_array.from_string
}

fn decode_payload(
  payload: BitArray,
  decoder: Decoder(event),
) -> Result(event, InvocationError) {
  use text <- result.try(
    bit_array.to_string(payload)
    |> result.replace_error(invocation_error(
      "Runtime.InvalidEvent",
      "event payload was not valid UTF-8",
    )),
  )
  json.parse(text, decoder)
  |> result.replace_error(invocation_error(
    "Runtime.InvalidEvent",
    "event payload did not match the expected schema",
  ))
}

fn send(
  api: Api,
  request: Request(BitArray),
) -> Result(Response(BitArray), RuntimeError) {
  api.send(request) |> result.map_error(Transport)
}

fn expect_accepted(
  api: Api,
  endpoint: String,
  request: Request(BitArray),
) -> Result(Nil, RuntimeError) {
  use response <- result.try(send(api, request))
  case response.status >= 200 && response.status < 300 {
    True -> Ok(Nil)
    False ->
      Error(UnexpectedStatus(endpoint: endpoint, status: response.status))
  }
}

fn build_request(
  method: http.Method,
  api: Api,
  path: String,
  body: BitArray,
  headers: List(#(String, String)),
) -> Result(Request(BitArray), RuntimeError) {
  let url = "http://" <> api.endpoint <> "/" <> api_version <> path
  use base <- result.try(
    request.to(url) |> result.replace_error(InvalidEndpoint(api.endpoint)),
  )
  base
  |> request.set_method(method)
  |> request.set_body(body)
  |> apply_headers(headers)
  |> Ok
}

fn apply_headers(
  request: Request(BitArray),
  headers: List(#(String, String)),
) -> Request(BitArray) {
  case headers {
    [] -> request
    [#(key, value), ..rest] ->
      apply_headers(request.set_header(request, key, value), rest)
  }
}

fn set_xray_trace_id(trace_id: String) -> Nil {
  set_env("_X_AMZ_TRACE_ID", trace_id)
}

/// Deprecated alias for [`aws/env.get_env`](../env.html#get_env). Env access
/// is not Lambda-specific, so it now lives in `aws/env`.
@deprecated("Use aws/env.get_env instead")
pub fn get_env(name: String) -> Result(String, Nil) {
  env.get_env(name)
}

// --- FFI ------------------------------------------------------------------

@external(erlang, "aws_ffi", "set_env")
fn set_env(name: String, value: String) -> Nil

@external(erlang, "aws_ffi", "rescue_call")
fn rescue_call(run: fn() -> a) -> Result(a, HandlerCrash)

@external(erlang, "aws_ffi", "plain_args")
fn plain_args() -> List(String)

@external(erlang, "erlang", "halt")
fn halt(code: Int) -> a
