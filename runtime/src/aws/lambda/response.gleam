//// Typed responses for Lambda integrations that expect a structured reply,
//// with encoders that produce the JSON Lambda marshals back to the caller.
////
//// Use these as the `encode` argument to `aws/lambda.start_json`.

import gleam/dict.{type Dict}
import gleam/json.{type Json}
import gleam/list

// --- API Gateway / proxy integration response -----------------------------

/// A proxy-integration response. The same shape serves API Gateway REST
/// (payload format 1.0) and HTTP API (payload format 2.0) proxy
/// integrations, as well as Lambda function URLs. `cookies` is encoded only
/// when non-empty (it is an HTTP API 2.0 field).
pub type ProxyResponse {
  ProxyResponse(
    status_code: Int,
    headers: Dict(String, String),
    cookies: List(String),
    body: String,
    is_base64_encoded: Bool,
  )
}

/// A `200 OK` proxy response with a body and no extra headers. Set further
/// fields with record-update syntax:
///
/// ```gleam
/// response.proxy_response(201, "{}")
/// |> fn(r) { response.ProxyResponse(..r, headers: my_headers) }
/// ```
pub fn proxy_response(status_code: Int, body: String) -> ProxyResponse {
  ProxyResponse(
    status_code: status_code,
    headers: dict.new(),
    cookies: [],
    body: body,
    is_base64_encoded: False,
  )
}

/// Encode a [`ProxyResponse`](#ProxyResponse) to its Lambda JSON form.
pub fn proxy_to_json(response: ProxyResponse) -> Json {
  let base = [
    #("statusCode", json.int(response.status_code)),
    #("headers", string_dict_to_json(response.headers)),
    #("body", json.string(response.body)),
    #("isBase64Encoded", json.bool(response.is_base64_encoded)),
  ]
  let fields = case response.cookies {
    [] -> base
    cookies -> [#("cookies", json.array(cookies, json.string)), ..base]
  }
  json.object(fields)
}

// --- SQS partial batch response -------------------------------------------

/// Reports which messages in an SQS batch failed so Lambda redelivers only
/// those. Requires `ReportBatchItemFailures` on the event source mapping. An
/// empty list tells Lambda the whole batch succeeded.
pub type SqsBatchResponse {
  SqsBatchResponse(batch_item_failures: List(String))
}

/// Encode an [`SqsBatchResponse`](#SqsBatchResponse) to its Lambda JSON form.
pub fn sqs_batch_to_json(response: SqsBatchResponse) -> Json {
  json.object([
    #(
      "batchItemFailures",
      json.array(response.batch_item_failures, fn(id) {
        json.object([#("itemIdentifier", json.string(id))])
      }),
    ),
  ])
}

fn string_dict_to_json(values: Dict(String, String)) -> Json {
  values
  |> dict.to_list
  |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })
  |> json.object
}
