//// AWS Lambda Runtime API client — the polling loop a "custom
//// runtime" implements so AWS Lambda can dispatch invocations to
//// it. The contract:
////
////   1. GET `http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next`
////      blocks until Lambda has work for us, then returns the event
////      payload as the response body plus the request-id /
////      deadline / invoked-function-arn in response headers.
////   2. The handler runs.
////   3. POST `.../runtime/invocation/${requestId}/response` with the
////      handler's output, OR POST `.../runtime/invocation/${requestId}/error`
////      with `{errorType, errorMessage}` if the handler failed.
////   4. Loop.
////
//// We don't ship this in the main SDK — Lambda is just one of many
//// deployment targets, and pulling httpc + JSON helpers into the
//// runtime path would bloat callers who never use it. Living in
//// the smoke-test repo keeps the SDK focused; if the function
//// pays off we lift it into its own `gleam_aws_lambda_runtime`
//// package later.

import gleam/bit_array
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/httpc
import gleam/list
import gleam/result
import gleam/string

const api_version: String = "2018-06-01"

pub type Invocation {
  Invocation(
    request_id: String,
    function_arn: String,
    deadline_ms: String,
    trace_id: String,
    payload: BitArray,
  )
}

pub type RuntimeError {
  /// HTTP transport failure talking to the Runtime API. Bubble up
  /// — there's nothing the handler can do; either the API is down
  /// (which means Lambda is shutting us down anyway) or the env
  /// is misconfigured (no `AWS_LAMBDA_RUNTIME_API`).
  Transport(reason: String)
  /// `AWS_LAMBDA_RUNTIME_API` env var was missing — we're not
  /// running inside a Lambda container. Surface clearly so callers
  /// debugging locally don't chase the wrong tail.
  MissingEnv
  /// Response from /next lacked one of the required Lambda-Runtime-*
  /// headers; should never happen against a real Lambda runtime
  /// but the contract is HTTP so we defend in depth.
  MalformedNext(missing_header: String)
}

/// Block on `/invocation/next` until Lambda gives us an event, then
/// parse the response into an `Invocation`.
pub fn next() -> Result(Invocation, RuntimeError) {
  use api_host <- result.try(runtime_api_host())
  let url =
    "http://"
    <> api_host
    <> "/"
    <> api_version
    <> "/runtime/invocation/next"
  use req <- result.try(
    request.to(url) |> result.replace_error(Transport(reason: "bad url: " <> url)),
  )
  use resp <- result.try(send(
    req |> request.set_method(http.Get) |> request.set_body(<<>>),
  ))
  use req_id <- result.try(required_header(resp, "lambda-runtime-aws-request-id"))
  use arn <- result.try(required_header(
    resp,
    "lambda-runtime-invoked-function-arn",
  ))
  use deadline <- result.try(required_header(
    resp,
    "lambda-runtime-deadline-ms",
  ))
  // X-Ray trace id is informational; default to "" rather than
  // failing the whole loop on its absence.
  let trace = case header_value(resp, "lambda-runtime-trace-id") {
    Ok(v) -> v
    Error(_) -> ""
  }
  Ok(Invocation(
    request_id: req_id,
    function_arn: arn,
    deadline_ms: deadline,
    trace_id: trace,
    payload: resp.body,
  ))
}

/// Submit the handler's successful result for `request_id`.
pub fn respond(
  request_id: String,
  body: BitArray,
) -> Result(Nil, RuntimeError) {
  use api_host <- result.try(runtime_api_host())
  let url =
    "http://"
    <> api_host
    <> "/"
    <> api_version
    <> "/runtime/invocation/"
    <> request_id
    <> "/response"
  use req <- result.try(
    request.to(url) |> result.replace_error(Transport(reason: "bad url: " <> url)),
  )
  use _ <- result.try(
    send(req |> request.set_method(http.Post) |> request.set_body(body)),
  )
  Ok(Nil)
}

/// Report a handler error to Lambda. Lambda surfaces this as the
/// invocation result in CloudWatch with the supplied `error_type`
/// and `message`.
pub fn report_error(
  request_id: String,
  error_type: String,
  message: String,
) -> Result(Nil, RuntimeError) {
  use api_host <- result.try(runtime_api_host())
  let url =
    "http://"
    <> api_host
    <> "/"
    <> api_version
    <> "/runtime/invocation/"
    <> request_id
    <> "/error"
  use req <- result.try(
    request.to(url) |> result.replace_error(Transport(reason: "bad url: " <> url)),
  )
  let body = bit_array.from_string(error_json(error_type, message))
  let req =
    req
    |> request.set_method(http.Post)
    |> request.set_header("lambda-runtime-function-error-type", error_type)
    |> request.set_body(body)
  use _ <- result.try(send(req))
  Ok(Nil)
}

/// Run the dispatcher loop forever. Each iteration: `next` → handler
/// → either `respond` or `report_error`. Loop exits only on
/// transport failure (Lambda will restart the container).
pub fn run_loop(
  handler: fn(Invocation) -> Result(BitArray, String),
) -> Result(Nil, RuntimeError) {
  case next() {
    Error(e) -> Error(e)
    Ok(inv) -> {
      case handler(inv) {
        Ok(body) -> {
          let _ = respond(inv.request_id, body)
          Nil
        }
        Error(msg) -> {
          let _ = report_error(inv.request_id, "HandlerError", msg)
          Nil
        }
      }
      run_loop(handler)
    }
  }
}

// ---------- helpers ----------

@external(erlang, "os", "getenv")
fn os_getenv(name: String) -> Result(String, Nil)

fn runtime_api_host() -> Result(String, RuntimeError) {
  case os_getenv("AWS_LAMBDA_RUNTIME_API") {
    Ok(host) if host != "" -> Ok(host)
    _ -> Error(MissingEnv)
  }
}

fn send(
  req: request.Request(BitArray),
) -> Result(response.Response(BitArray), RuntimeError) {
  httpc.send_bits(req)
  |> result.map_error(fn(e) { Transport(reason: string.inspect(e)) })
}

fn required_header(
  resp: response.Response(BitArray),
  name: String,
) -> Result(String, RuntimeError) {
  case header_value(resp, name) {
    Ok(v) -> Ok(v)
    Error(_) -> Error(MalformedNext(missing_header: name))
  }
}

fn header_value(
  resp: response.Response(BitArray),
  name: String,
) -> Result(String, Nil) {
  list.find_map(resp.headers, fn(h) {
    case string.lowercase(h.0) == name {
      True -> Ok(h.1)
      False -> Error(Nil)
    }
  })
}

fn error_json(error_type: String, message: String) -> String {
  // Hand-rolled JSON — no need to pull in gleam_json for two fields
  // that contain JSON-special chars in degenerate cases only. The
  // handler should pre-sanitise.
  "{\"errorType\":\""
  <> json_escape(error_type)
  <> "\",\"errorMessage\":\""
  <> json_escape(message)
  <> "\"}"
}

fn json_escape(s: String) -> String {
  s
  |> string.replace("\\", "\\\\")
  |> string.replace("\"", "\\\"")
  |> string.replace("\n", "\\n")
  |> string.replace("\r", "\\r")
  |> string.replace("\t", "\\t")
}
