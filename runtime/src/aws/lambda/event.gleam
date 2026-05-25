//// Typed envelopes for the events Lambda delivers, with decoders for the
//// common trigger sources. Lambda hands every trigger to the handler as a
//// JSON document; these turn that document into a Gleam record.
////
//// Pair them with `aws/lambda.start_json`:
////
//// ```gleam
//// import aws/lambda
//// import aws/lambda/event
////
//// pub fn main() {
////   lambda.start_json(
////     event.sqs_decoder(),
////     fn(sqs, _ctx) {
////       list.each(sqs.records, fn(msg) { process(msg.body) })
////       Ok(Nil)
////     },
////     fn(_) { json.null() },
////   )
//// }
//// ```
////
//// Each decoder models the fields handlers actually reach for and tolerates
//// missing/null members so a slightly different payload shape never crashes
//// decoding. Open-ended members are left for the caller to decode: an SQS
//// `body` and an SNS `message` are raw `String`s (often JSON you parse with
//// your own decoder), and an EventBridge `detail` is decoded by a decoder
//// you supply. Field shapes follow the AWS sample events documented under
//// "Using AWS Lambda with <service>".

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option, None}

// --- SQS ------------------------------------------------------------------

/// An `aws:sqs` event: a batch of one or more messages.
pub type SqsEvent {
  SqsEvent(records: List(SqsMessage))
}

/// A single SQS message. `body` is the raw message body — parse it with your
/// own decoder if it carries JSON.
pub type SqsMessage {
  SqsMessage(
    message_id: String,
    receipt_handle: String,
    body: String,
    attributes: Dict(String, String),
    message_attributes: Dict(String, SqsMessageAttribute),
    md5_of_body: String,
    event_source: String,
    event_source_arn: String,
    aws_region: String,
  )
}

/// A user-supplied SQS message attribute. Binary attributes carry `data_type`
/// `"Binary"` and no `string_value`.
pub type SqsMessageAttribute {
  SqsMessageAttribute(data_type: String, string_value: Option(String))
}

/// Decoder for the SQS event envelope.
pub fn sqs_decoder() -> Decoder(SqsEvent) {
  use records <- decode.optional_field(
    "Records",
    [],
    decode.list(sqs_message_decoder()),
  )
  decode.success(SqsEvent(records: records))
}

fn sqs_message_decoder() -> Decoder(SqsMessage) {
  use message_id <- decode.field("messageId", decode.string)
  use receipt_handle <- decode.field("receiptHandle", decode.string)
  use body <- decode.field("body", decode.string)
  use attributes <- decode.optional_field(
    "attributes",
    dict.new(),
    string_dict(),
  )
  use message_attributes <- decode.optional_field(
    "messageAttributes",
    dict.new(),
    optional_dict(sqs_message_attribute_decoder()),
  )
  use md5_of_body <- decode.optional_field("md5OfBody", "", decode.string)
  use event_source <- decode.optional_field("eventSource", "", decode.string)
  use event_source_arn <- decode.optional_field(
    "eventSourceARN",
    "",
    decode.string,
  )
  use aws_region <- decode.optional_field("awsRegion", "", decode.string)
  decode.success(SqsMessage(
    message_id: message_id,
    receipt_handle: receipt_handle,
    body: body,
    attributes: attributes,
    message_attributes: message_attributes,
    md5_of_body: md5_of_body,
    event_source: event_source,
    event_source_arn: event_source_arn,
    aws_region: aws_region,
  ))
}

fn sqs_message_attribute_decoder() -> Decoder(SqsMessageAttribute) {
  use data_type <- decode.optional_field("dataType", "", decode.string)
  use string_value <- decode.optional_field(
    "stringValue",
    None,
    decode.optional(decode.string),
  )
  decode.success(SqsMessageAttribute(
    data_type: data_type,
    string_value: string_value,
  ))
}

// --- API Gateway REST (proxy integration, payload format 1.0) -------------

/// An API Gateway REST API proxy-integration request (payload format 1.0).
/// `request_context` is omitted; the fields here cover routing, headers,
/// query, and body.
pub type ApiGatewayProxyRequest {
  ApiGatewayProxyRequest(
    resource: String,
    path: String,
    http_method: String,
    headers: Dict(String, String),
    query_string_parameters: Dict(String, String),
    path_parameters: Dict(String, String),
    stage_variables: Dict(String, String),
    body: Option(String),
    is_base64_encoded: Bool,
  )
}

/// Decoder for the API Gateway REST proxy request (payload format 1.0).
pub fn api_gateway_decoder() -> Decoder(ApiGatewayProxyRequest) {
  use resource <- decode.optional_field("resource", "", decode.string)
  use path <- decode.optional_field("path", "", decode.string)
  use http_method <- decode.optional_field("httpMethod", "", decode.string)
  use headers <- decode.optional_field("headers", dict.new(), string_dict())
  use query_string_parameters <- decode.optional_field(
    "queryStringParameters",
    dict.new(),
    string_dict(),
  )
  use path_parameters <- decode.optional_field(
    "pathParameters",
    dict.new(),
    string_dict(),
  )
  use stage_variables <- decode.optional_field(
    "stageVariables",
    dict.new(),
    string_dict(),
  )
  use body <- decode.optional_field(
    "body",
    None,
    decode.optional(decode.string),
  )
  use is_base64_encoded <- decode.optional_field(
    "isBase64Encoded",
    False,
    optional_bool(),
  )
  decode.success(ApiGatewayProxyRequest(
    resource: resource,
    path: path,
    http_method: http_method,
    headers: headers,
    query_string_parameters: query_string_parameters,
    path_parameters: path_parameters,
    stage_variables: stage_variables,
    body: body,
    is_base64_encoded: is_base64_encoded,
  ))
}

// --- API Gateway HTTP API (payload format 2.0) ----------------------------

/// An API Gateway HTTP API request (payload format 2.0). `method`, `path`,
/// and `source_ip` are flattened out of `requestContext.http` for
/// convenience.
pub type ApiGatewayV2Request {
  ApiGatewayV2Request(
    version: String,
    route_key: String,
    raw_path: String,
    raw_query_string: String,
    cookies: List(String),
    headers: Dict(String, String),
    query_string_parameters: Dict(String, String),
    path_parameters: Dict(String, String),
    stage_variables: Dict(String, String),
    method: String,
    path: String,
    source_ip: String,
    body: Option(String),
    is_base64_encoded: Bool,
  )
}

/// Decoder for the API Gateway HTTP API request (payload format 2.0).
pub fn api_gateway_v2_decoder() -> Decoder(ApiGatewayV2Request) {
  use version <- decode.optional_field("version", "", decode.string)
  use route_key <- decode.optional_field("routeKey", "", decode.string)
  use raw_path <- decode.optional_field("rawPath", "", decode.string)
  use raw_query_string <- decode.optional_field(
    "rawQueryString",
    "",
    decode.string,
  )
  use cookies <- decode.optional_field(
    "cookies",
    [],
    decode.list(decode.string),
  )
  use headers <- decode.optional_field("headers", dict.new(), string_dict())
  use query_string_parameters <- decode.optional_field(
    "queryStringParameters",
    dict.new(),
    string_dict(),
  )
  use path_parameters <- decode.optional_field(
    "pathParameters",
    dict.new(),
    string_dict(),
  )
  use stage_variables <- decode.optional_field(
    "stageVariables",
    dict.new(),
    string_dict(),
  )
  use method <- decode.then(decode.optionally_at(
    ["requestContext", "http", "method"],
    "",
    decode.string,
  ))
  use path <- decode.then(decode.optionally_at(
    ["requestContext", "http", "path"],
    "",
    decode.string,
  ))
  use source_ip <- decode.then(decode.optionally_at(
    ["requestContext", "http", "sourceIp"],
    "",
    decode.string,
  ))
  use body <- decode.optional_field(
    "body",
    None,
    decode.optional(decode.string),
  )
  use is_base64_encoded <- decode.optional_field(
    "isBase64Encoded",
    False,
    optional_bool(),
  )
  decode.success(ApiGatewayV2Request(
    version: version,
    route_key: route_key,
    raw_path: raw_path,
    raw_query_string: raw_query_string,
    cookies: cookies,
    headers: headers,
    query_string_parameters: query_string_parameters,
    path_parameters: path_parameters,
    stage_variables: stage_variables,
    method: method,
    path: path,
    source_ip: source_ip,
    body: body,
    is_base64_encoded: is_base64_encoded,
  ))
}

// --- EventBridge ----------------------------------------------------------

/// An EventBridge (CloudWatch Events) event. The `detail` payload is
/// service-specific, so this type is generic over it: supply a decoder to
/// [`eventbridge_decoder`](#eventbridge_decoder). Use `decode.dynamic` (or
/// `gleam/json`'s document handling) if you want to keep it untyped.
pub type EventBridgeEvent(detail) {
  EventBridgeEvent(
    id: String,
    version: String,
    detail_type: String,
    source: String,
    account: String,
    time: String,
    region: String,
    resources: List(String),
    detail: detail,
  )
}

/// Decoder for an EventBridge event, decoding `detail` with `detail_decoder`.
pub fn eventbridge_decoder(
  detail_decoder: Decoder(detail),
) -> Decoder(EventBridgeEvent(detail)) {
  use id <- decode.optional_field("id", "", decode.string)
  use version <- decode.optional_field("version", "", decode.string)
  use detail_type <- decode.optional_field("detail-type", "", decode.string)
  use source <- decode.optional_field("source", "", decode.string)
  use account <- decode.optional_field("account", "", decode.string)
  use time <- decode.optional_field("time", "", decode.string)
  use region <- decode.optional_field("region", "", decode.string)
  use resources <- decode.optional_field(
    "resources",
    [],
    decode.list(decode.string),
  )
  use detail <- decode.field("detail", detail_decoder)
  decode.success(EventBridgeEvent(
    id: id,
    version: version,
    detail_type: detail_type,
    source: source,
    account: account,
    time: time,
    region: region,
    resources: resources,
    detail: detail,
  ))
}

// --- S3 -------------------------------------------------------------------

/// An `aws:s3` event notification: a batch of object-level records.
pub type S3Event {
  S3Event(records: List(S3Record))
}

/// A single S3 notification record. The bucket and object fields are
/// flattened out of the nested `s3` member. `object_key` is URL-encoded
/// exactly as S3 delivers it (spaces become `+`).
pub type S3Record {
  S3Record(
    aws_region: String,
    event_name: String,
    event_time: String,
    event_source: String,
    bucket_name: String,
    bucket_arn: String,
    object_key: String,
    object_size: Option(Int),
    object_etag: Option(String),
    object_sequencer: Option(String),
  )
}

/// Decoder for the S3 event-notification envelope.
pub fn s3_decoder() -> Decoder(S3Event) {
  use records <- decode.optional_field(
    "Records",
    [],
    decode.list(s3_record_decoder()),
  )
  decode.success(S3Event(records: records))
}

fn s3_record_decoder() -> Decoder(S3Record) {
  use aws_region <- decode.optional_field("awsRegion", "", decode.string)
  use event_name <- decode.optional_field("eventName", "", decode.string)
  use event_time <- decode.optional_field("eventTime", "", decode.string)
  use event_source <- decode.optional_field("eventSource", "", decode.string)
  use bucket_name <- decode.then(decode.optionally_at(
    ["s3", "bucket", "name"],
    "",
    decode.string,
  ))
  use bucket_arn <- decode.then(decode.optionally_at(
    ["s3", "bucket", "arn"],
    "",
    decode.string,
  ))
  use object_key <- decode.then(decode.optionally_at(
    ["s3", "object", "key"],
    "",
    decode.string,
  ))
  use object_size <- decode.then(decode.optionally_at(
    ["s3", "object", "size"],
    None,
    decode.optional(decode.int),
  ))
  use object_etag <- decode.then(decode.optionally_at(
    ["s3", "object", "eTag"],
    None,
    decode.optional(decode.string),
  ))
  use object_sequencer <- decode.then(decode.optionally_at(
    ["s3", "object", "sequencer"],
    None,
    decode.optional(decode.string),
  ))
  decode.success(S3Record(
    aws_region: aws_region,
    event_name: event_name,
    event_time: event_time,
    event_source: event_source,
    bucket_name: bucket_name,
    bucket_arn: bucket_arn,
    object_key: object_key,
    object_size: object_size,
    object_etag: object_etag,
    object_sequencer: object_sequencer,
  ))
}

// --- SNS ------------------------------------------------------------------

/// An `aws:sns` event: a batch of one or more notifications.
pub type SnsEvent {
  SnsEvent(records: List(SnsRecord))
}

/// A single SNS record wrapping the published message.
pub type SnsRecord {
  SnsRecord(
    event_source: String,
    event_subscription_arn: String,
    sns: SnsMessage,
  )
}

/// A published SNS message. `message` is the raw payload — parse it with your
/// own decoder if it carries JSON.
pub type SnsMessage {
  SnsMessage(
    message_id: String,
    topic_arn: String,
    subject: Option(String),
    message: String,
    timestamp: String,
    message_type: String,
  )
}

/// Decoder for the SNS event envelope.
pub fn sns_decoder() -> Decoder(SnsEvent) {
  use records <- decode.optional_field(
    "Records",
    [],
    decode.list(sns_record_decoder()),
  )
  decode.success(SnsEvent(records: records))
}

fn sns_record_decoder() -> Decoder(SnsRecord) {
  use event_source <- decode.optional_field("EventSource", "", decode.string)
  use event_subscription_arn <- decode.optional_field(
    "EventSubscriptionArn",
    "",
    decode.string,
  )
  use sns <- decode.field("Sns", sns_message_decoder())
  decode.success(SnsRecord(
    event_source: event_source,
    event_subscription_arn: event_subscription_arn,
    sns: sns,
  ))
}

fn sns_message_decoder() -> Decoder(SnsMessage) {
  use message_id <- decode.field("MessageId", decode.string)
  use topic_arn <- decode.optional_field("TopicArn", "", decode.string)
  use subject <- decode.optional_field(
    "Subject",
    None,
    decode.optional(decode.string),
  )
  use message <- decode.field("Message", decode.string)
  use timestamp <- decode.optional_field("Timestamp", "", decode.string)
  use message_type <- decode.optional_field("Type", "", decode.string)
  decode.success(SnsMessage(
    message_id: message_id,
    topic_arn: topic_arn,
    subject: subject,
    message: message,
    timestamp: timestamp,
    message_type: message_type,
  ))
}

// --- Shared null-tolerant combinators -------------------------------------
//
// These tolerate a JSON `null` (API Gateway sends `null`, not `{}`, for an
// empty `queryStringParameters` / `pathParameters` / `stageVariables`) by
// mapping it to the empty value. They must NOT swallow a genuine decode
// error in a present value — that would silently drop malformed data — so
// they key off `decode.optional`, which only short-circuits on `null`, and
// let any other failure propagate. An absent key is handled separately by
// the `optional_field` default at the call site.

fn string_dict() -> Decoder(Dict(String, String)) {
  optional_dict(decode.string)
}

fn optional_dict(value: Decoder(value)) -> Decoder(Dict(String, value)) {
  decode.dict(decode.string, value)
  |> decode.optional
  |> decode.map(fn(maybe) { option.unwrap(maybe, dict.new()) })
}

fn optional_bool() -> Decoder(Bool) {
  decode.bool
  |> decode.optional
  |> decode.map(fn(maybe) { option.unwrap(maybe, False) })
}
