//// Tests for the typed Lambda event envelopes (`aws/lambda/event`).
////
//// Each test decodes an actual AWS sample event — the payloads documented
//// under "Using AWS Lambda with <service>" — and asserts the fields handlers
//// reach for. The null-tolerance tests pin the behaviour AWS specifies but
//// that bites everyone once: API Gateway sends JSON `null` (not `{}`) for an
//// empty `queryStringParameters` / `pathParameters` / `stageVariables`, and
//// the decoders must map that to an empty map rather than failing.

import aws/lambda/event
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option.{None, Some}
import gleeunit/should

fn decode(json_text: String, decoder: decode.Decoder(a)) -> a {
  let assert Ok(value) = json.parse(json_text, decoder)
  value
}

// --- SQS ------------------------------------------------------------------

const sqs_event: String = "{
  \"Records\": [
    {
      \"messageId\": \"059f36b4-87a3-44ab-83d2-661975830a7d\",
      \"receiptHandle\": \"AQEBwJnKyrHigUMZj6rYigCgxlaS3SLy0a\",
      \"body\": \"Test message.\",
      \"attributes\": {
        \"ApproximateReceiveCount\": \"1\",
        \"SentTimestamp\": \"1545082649183\",
        \"SenderId\": \"AIDAIENQZJOLO23YVJ4VO\",
        \"ApproximateFirstReceiveTimestamp\": \"1545082649185\"
      },
      \"messageAttributes\": {
        \"colour\": { \"stringValue\": \"red\", \"dataType\": \"String\" },
        \"thumbnail\": { \"dataType\": \"Binary\" }
      },
      \"md5OfBody\": \"e4e68fb7bd0e697a0ae8f1bb342846b3\",
      \"eventSource\": \"aws:sqs\",
      \"eventSourceARN\": \"arn:aws:sqs:us-east-2:123456789012:my-queue\",
      \"awsRegion\": \"us-east-2\"
    }
  ]
}"

pub fn sqs_decodes_message_and_attributes_test() {
  let parsed = decode(sqs_event, event.sqs_decoder())

  let assert [message] = parsed.records
  message.message_id |> should.equal("059f36b4-87a3-44ab-83d2-661975830a7d")
  message.body |> should.equal("Test message.")
  message.md5_of_body |> should.equal("e4e68fb7bd0e697a0ae8f1bb342846b3")
  message.event_source |> should.equal("aws:sqs")
  message.event_source_arn
  |> should.equal("arn:aws:sqs:us-east-2:123456789012:my-queue")
  message.aws_region |> should.equal("us-east-2")

  dict.get(message.attributes, "ApproximateReceiveCount")
  |> should.equal(Ok("1"))

  // A String attribute carries its value; a Binary attribute carries the
  // data type but no string value.
  let assert Ok(colour) = dict.get(message.message_attributes, "colour")
  colour.data_type |> should.equal("String")
  colour.string_value |> should.equal(Some("red"))

  let assert Ok(thumbnail) = dict.get(message.message_attributes, "thumbnail")
  thumbnail.data_type |> should.equal("Binary")
  thumbnail.string_value |> should.equal(None)
}

pub fn sqs_empty_records_test() {
  decode("{\"Records\":[]}", event.sqs_decoder()).records
  |> should.equal([])
}

// --- API Gateway REST (payload format 1.0) --------------------------------

// A real proxy event delivers JSON `null` for the empty query/path/stage
// maps and for an empty body — the combinators must absorb that.
const api_gw_rest_event: String = "{
  \"resource\": \"/{proxy+}\",
  \"path\": \"/hello/world\",
  \"httpMethod\": \"GET\",
  \"headers\": { \"Host\": \"example.execute-api.us-east-1.amazonaws.com\" },
  \"queryStringParameters\": null,
  \"pathParameters\": { \"proxy\": \"hello/world\" },
  \"stageVariables\": null,
  \"body\": null,
  \"isBase64Encoded\": false
}"

pub fn api_gateway_rest_decodes_and_tolerates_null_maps_test() {
  let parsed = decode(api_gw_rest_event, event.api_gateway_decoder())

  parsed.resource |> should.equal("/{proxy+}")
  parsed.path |> should.equal("/hello/world")
  parsed.http_method |> should.equal("GET")
  dict.get(parsed.headers, "Host")
  |> should.equal(Ok("example.execute-api.us-east-1.amazonaws.com"))
  // null maps become empty maps, not decode failures.
  parsed.query_string_parameters |> should.equal(dict.new())
  parsed.stage_variables |> should.equal(dict.new())
  dict.get(parsed.path_parameters, "proxy") |> should.equal(Ok("hello/world"))
  parsed.body |> should.equal(None)
  parsed.is_base64_encoded |> should.equal(False)
}

// --- API Gateway HTTP API (payload format 2.0) ----------------------------

const api_gw_http_event: String = "{
  \"version\": \"2.0\",
  \"routeKey\": \"$default\",
  \"rawPath\": \"/my/path\",
  \"rawQueryString\": \"parameter1=value1&parameter2=value\",
  \"cookies\": [\"cookie1\", \"cookie2\"],
  \"headers\": { \"header1\": \"value1\", \"header2\": \"value1,value2\" },
  \"queryStringParameters\": { \"parameter1\": \"value1\", \"parameter2\": \"value\" },
  \"requestContext\": {
    \"http\": {
      \"method\": \"POST\",
      \"path\": \"/my/path\",
      \"protocol\": \"HTTP/1.1\",
      \"sourceIp\": \"192.0.2.1\",
      \"userAgent\": \"agent\"
    }
  },
  \"body\": \"Hello from Lambda\",
  \"isBase64Encoded\": false
}"

pub fn api_gateway_v2_flattens_request_context_http_test() {
  let parsed = decode(api_gw_http_event, event.api_gateway_v2_decoder())

  parsed.version |> should.equal("2.0")
  parsed.route_key |> should.equal("$default")
  parsed.raw_path |> should.equal("/my/path")
  parsed.raw_query_string |> should.equal("parameter1=value1&parameter2=value")
  parsed.cookies |> should.equal(["cookie1", "cookie2"])
  dict.get(parsed.headers, "header2") |> should.equal(Ok("value1,value2"))
  dict.get(parsed.query_string_parameters, "parameter1")
  |> should.equal(Ok("value1"))
  // method / path / source_ip are lifted out of requestContext.http.
  parsed.method |> should.equal("POST")
  parsed.path |> should.equal("/my/path")
  parsed.source_ip |> should.equal("192.0.2.1")
  parsed.body |> should.equal(Some("Hello from Lambda"))
  parsed.is_base64_encoded |> should.equal(False)
}

pub fn api_gateway_v2_missing_request_context_defaults_blank_test() {
  // A minimal v2 payload with no requestContext: the flattened fields fall
  // back to "" rather than failing the decode.
  let parsed =
    decode(
      "{\"version\":\"2.0\",\"rawPath\":\"/\"}",
      event.api_gateway_v2_decoder(),
    )
  parsed.method |> should.equal("")
  parsed.path |> should.equal("")
  parsed.source_ip |> should.equal("")
  parsed.raw_path |> should.equal("/")
}

// --- S3 -------------------------------------------------------------------

const s3_event: String = "{
  \"Records\": [
    {
      \"eventVersion\": \"2.1\",
      \"eventSource\": \"aws:s3\",
      \"awsRegion\": \"us-east-2\",
      \"eventTime\": \"2019-09-03T19:37:27.192Z\",
      \"eventName\": \"ObjectCreated:Put\",
      \"s3\": {
        \"bucket\": {
          \"name\": \"lambda-artifacts-deafc19498e3f2df\",
          \"arn\": \"arn:aws:s3:::lambda-artifacts-deafc19498e3f2df\"
        },
        \"object\": {
          \"key\": \"b21b84d653bb07b05b1e6b33684dc11b\",
          \"size\": 1305107,
          \"eTag\": \"b21b84d653bb07b05b1e6b33684dc11b\",
          \"sequencer\": \"0C0F6F405D6ED209E1\"
        }
      }
    }
  ]
}"

pub fn s3_flattens_bucket_and_object_test() {
  let parsed = decode(s3_event, event.s3_decoder())

  let assert [record] = parsed.records
  record.aws_region |> should.equal("us-east-2")
  record.event_name |> should.equal("ObjectCreated:Put")
  record.event_time |> should.equal("2019-09-03T19:37:27.192Z")
  record.event_source |> should.equal("aws:s3")
  record.bucket_name |> should.equal("lambda-artifacts-deafc19498e3f2df")
  record.bucket_arn
  |> should.equal("arn:aws:s3:::lambda-artifacts-deafc19498e3f2df")
  record.object_key |> should.equal("b21b84d653bb07b05b1e6b33684dc11b")
  record.object_size |> should.equal(Some(1_305_107))
  record.object_etag |> should.equal(Some("b21b84d653bb07b05b1e6b33684dc11b"))
  record.object_sequencer |> should.equal(Some("0C0F6F405D6ED209E1"))
}

// --- SNS ------------------------------------------------------------------

const sns_event: String = "{
  \"Records\": [
    {
      \"EventVersion\": \"1.0\",
      \"EventSubscriptionArn\": \"arn:aws:sns:us-east-2:123456789012:sns-lambda:abc\",
      \"EventSource\": \"aws:sns\",
      \"Sns\": {
        \"Type\": \"Notification\",
        \"MessageId\": \"95df01b4-ee98-5cb9-9903-4c221d41eb5e\",
        \"TopicArn\": \"arn:aws:sns:us-east-2:123456789012:sns-lambda\",
        \"Subject\": \"example subject\",
        \"Message\": \"example message\",
        \"Timestamp\": \"2019-01-02T12:45:07.000Z\"
      }
    }
  ]
}"

pub fn sns_decodes_record_and_message_test() {
  let parsed = decode(sns_event, event.sns_decoder())

  let assert [record] = parsed.records
  record.event_source |> should.equal("aws:sns")
  record.event_subscription_arn
  |> should.equal("arn:aws:sns:us-east-2:123456789012:sns-lambda:abc")
  record.sns.message_id |> should.equal("95df01b4-ee98-5cb9-9903-4c221d41eb5e")
  record.sns.topic_arn
  |> should.equal("arn:aws:sns:us-east-2:123456789012:sns-lambda")
  record.sns.subject |> should.equal(Some("example subject"))
  record.sns.message |> should.equal("example message")
  record.sns.timestamp |> should.equal("2019-01-02T12:45:07.000Z")
  record.sns.message_type |> should.equal("Notification")
}

// --- EventBridge ----------------------------------------------------------

const eventbridge_event: String = "{
  \"version\": \"0\",
  \"id\": \"53dc4d37-cffa-4f76-80c9-8b7d4a4d2eaa\",
  \"detail-type\": \"EC2 Instance State-change Notification\",
  \"source\": \"aws.ec2\",
  \"account\": \"123456789012\",
  \"time\": \"2019-10-12T07:23:14Z\",
  \"region\": \"us-east-1\",
  \"resources\": [\"arn:aws:ec2:us-east-1:123456789012:instance/i-0123\"],
  \"detail\": { \"instance-id\": \"i-0123\", \"state\": \"running\" }
}"

type Ec2StateChange {
  Ec2StateChange(instance_id: String, state: String)
}

fn ec2_state_change_decoder() -> decode.Decoder(Ec2StateChange) {
  use instance_id <- decode.field("instance-id", decode.string)
  use state <- decode.field("state", decode.string)
  decode.success(Ec2StateChange(instance_id:, state:))
}

pub fn eventbridge_decodes_envelope_and_typed_detail_test() {
  let parsed =
    decode(
      eventbridge_event,
      event.eventbridge_decoder(ec2_state_change_decoder()),
    )

  parsed.id |> should.equal("53dc4d37-cffa-4f76-80c9-8b7d4a4d2eaa")
  parsed.version |> should.equal("0")
  parsed.detail_type
  |> should.equal("EC2 Instance State-change Notification")
  parsed.source |> should.equal("aws.ec2")
  parsed.account |> should.equal("123456789012")
  parsed.time |> should.equal("2019-10-12T07:23:14Z")
  parsed.region |> should.equal("us-east-1")
  parsed.resources
  |> should.equal(["arn:aws:ec2:us-east-1:123456789012:instance/i-0123"])
  parsed.detail |> should.equal(Ec2StateChange("i-0123", "running"))
}
