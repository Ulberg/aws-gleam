//// Tests for the typed Lambda response encoders (`aws/lambda/response`).
////
//// Each encoder produces the JSON shape Lambda marshals back to the caller;
//// the tests render to a string, parse it back, and assert the structure.
//// The cookie-omission rule (only emit `cookies` when non-empty, an HTTP API
//// 2.0 field) is pinned by inspecting the rendered text directly.

import aws/lambda/response
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/string
import gleeunit/should

fn render(j: json.Json) -> String {
  json.to_string(j)
}

// --- proxy response -------------------------------------------------------

type DecodedProxy {
  DecodedProxy(
    status_code: Int,
    body: String,
    is_base64_encoded: Bool,
    headers: dict.Dict(String, String),
  )
}

fn proxy_back_decoder() -> decode.Decoder(DecodedProxy) {
  use status_code <- decode.field("statusCode", decode.int)
  use body <- decode.field("body", decode.string)
  use is_base64_encoded <- decode.field("isBase64Encoded", decode.bool)
  use headers <- decode.field(
    "headers",
    decode.dict(decode.string, decode.string),
  )
  decode.success(DecodedProxy(
    status_code:,
    body:,
    is_base64_encoded:,
    headers:,
  ))
}

pub fn proxy_response_defaults_test() {
  let r = response.proxy_response(200, "hello")
  r.status_code |> should.equal(200)
  r.body |> should.equal("hello")
  r.headers |> should.equal(dict.new())
  r.cookies |> should.equal([])
  r.is_base64_encoded |> should.equal(False)
}

pub fn proxy_to_json_basic_shape_test() {
  let rendered = render(response.proxy_to_json(response.proxy_response(201, "{}")))
  let assert Ok(decoded) = json.parse(rendered, proxy_back_decoder())
  decoded.status_code |> should.equal(201)
  decoded.body |> should.equal("{}")
  decoded.is_base64_encoded |> should.equal(False)
  decoded.headers |> should.equal(dict.new())
}

pub fn proxy_to_json_includes_headers_test() {
  let r =
    response.ProxyResponse(
      ..response.proxy_response(200, "body"),
      headers: dict.from_list([#("content-type", "application/json")]),
    )
  let assert Ok(decoded) = json.parse(render(response.proxy_to_json(r)), proxy_back_decoder())
  dict.get(decoded.headers, "content-type")
  |> should.equal(Ok("application/json"))
}

pub fn proxy_to_json_omits_cookies_when_empty_test() {
  let rendered = render(response.proxy_to_json(response.proxy_response(200, "x")))
  // No cookies key when the list is empty (REST / function-URL responses).
  string.contains(rendered, "cookies") |> should.be_false
}

pub fn proxy_to_json_includes_cookies_when_present_test() {
  let r =
    response.ProxyResponse(
      ..response.proxy_response(200, "x"),
      cookies: ["session=abc", "theme=dark"],
    )
  let rendered = render(response.proxy_to_json(r))
  string.contains(rendered, "cookies") |> should.be_true

  let assert Ok(cookies) =
    json.parse(rendered, {
      use cookies <- decode.field("cookies", decode.list(decode.string))
      decode.success(cookies)
    })
  cookies |> should.equal(["session=abc", "theme=dark"])
}

pub fn proxy_to_json_base64_flag_roundtrips_test() {
  let r =
    response.ProxyResponse(
      ..response.proxy_response(200, "AAEC"),
      is_base64_encoded: True,
    )
  let assert Ok(decoded) = json.parse(render(response.proxy_to_json(r)), proxy_back_decoder())
  decoded.is_base64_encoded |> should.equal(True)
}

// --- SQS partial-batch response -------------------------------------------

fn batch_failures_decoder() -> decode.Decoder(List(String)) {
  decode.field(
    "batchItemFailures",
    decode.list({
      use id <- decode.field("itemIdentifier", decode.string)
      decode.success(id)
    }),
    decode.success,
  )
}

pub fn sqs_batch_reports_failed_ids_test() {
  let rendered =
    render(response.sqs_batch_to_json(response.SqsBatchResponse(
      batch_item_failures: ["msg-1", "msg-2"],
    )))
  let assert Ok(ids) = json.parse(rendered, batch_failures_decoder())
  ids |> should.equal(["msg-1", "msg-2"])
}

pub fn sqs_batch_empty_is_full_success_test() {
  // An empty batchItemFailures array tells Lambda the whole batch succeeded.
  let rendered =
    render(response.sqs_batch_to_json(response.SqsBatchResponse(
      batch_item_failures: [],
    )))
  let assert Ok(ids) = json.parse(rendered, batch_failures_decoder())
  ids |> should.equal([])
}
