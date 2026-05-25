//// Tests for the typed Lambda event decoders.
////
//// Each payload is the canonical AWS sample event for that trigger (as
//// documented under "Using AWS Lambda with <service>"), trimmed to the
//// members the decoder reads plus a few it should ignore. The API Gateway
//// REST case keeps `pathParameters`/`stageVariables` as JSON `null` — the
//// real shape — to pin the null-tolerant decoding.

import aws/lambda/event
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option.{None, Some}
import gleeunit/should

// --- SQS -------------------------------------------------------------------

const sqs_event_json = "{\"Records\":[{\"messageId\":\"059f36b4-87a3-44ab-83d2-661975830a7d\",\"receiptHandle\":\"AQEBwJnKyrHigUMZ\",\"body\":\"Test message.\",\"attributes\":{\"ApproximateReceiveCount\":\"1\",\"SentTimestamp\":\"1545082649183\",\"SenderId\":\"AIDAIENQZJOLO23YVJ4VO\",\"ApproximateFirstReceiveTimestamp\":\"1545082649185\"},\"messageAttributes\":{},\"md5OfBody\":\"e4e68fb7bd0e697a0ae8f1bb342846b3\",\"eventSource\":\"aws:sqs\",\"eventSourceARN\":\"arn:aws:sqs:us-east-2:123456789012:my-queue\",\"awsRegion\":\"us-east-2\"}]}"

pub fn sqs_decodes_canonical_event_test() {
  let assert Ok(sqs) = json.parse(sqs_event_json, event.sqs_decoder())
  let assert [message] = sqs.records
  message.message_id |> should.equal("059f36b4-87a3-44ab-83d2-661975830a7d")
  message.body |> should.equal("Test message.")
  message.event_source |> should.equal("aws:sqs")
  message.event_source_arn
  |> should.equal("arn:aws:sqs:us-east-2:123456789012:my-queue")
  message.aws_region |> should.equal("us-east-2")
  message.md5_of_body |> should.equal("e4e68fb7bd0e697a0ae8f1bb342846b3")
  dict.get(message.attributes, "ApproximateReceiveCount")
  |> should.equal(Ok("1"))
}

const sqs_attrs_json = "{\"Records\":[{\"messageId\":\"id\",\"receiptHandle\":\"rh\",\"body\":\"hi\",\"messageAttributes\":{\"Author\":{\"stringValue\":\"Alice\",\"dataType\":\"String\"},\"Blob\":{\"dataType\":\"Binary\"}},\"eventSource\":\"aws:sqs\",\"eventSourceARN\":\"arn\",\"awsRegion\":\"us-east-1\"}]}"

pub fn sqs_decodes_message_attributes_test() {
  let assert Ok(sqs) = json.parse(sqs_attrs_json, event.sqs_decoder())
  let assert [message] = sqs.records
  dict.get(message.message_attributes, "Author")
  |> should.equal(
    Ok(event.SqsMessageAttribute(
      data_type: "String",
      string_value: Some("Alice"),
    )),
  )
  dict.get(message.message_attributes, "Blob")
  |> should.equal(
    Ok(event.SqsMessageAttribute(data_type: "Binary", string_value: None)),
  )
}

// --- API Gateway HTTP API (payload format 2.0) -----------------------------

const apigw_v2_json = "{\"version\":\"2.0\",\"routeKey\":\"$default\",\"rawPath\":\"/my/path\",\"rawQueryString\":\"parameter1=value1&parameter2=value\",\"cookies\":[\"cookie1\",\"cookie2\"],\"headers\":{\"header1\":\"value1\",\"header2\":\"value1,value2\"},\"queryStringParameters\":{\"parameter1\":\"value1\",\"parameter2\":\"value\"},\"requestContext\":{\"accountId\":\"123456789012\",\"apiId\":\"api-id\",\"http\":{\"method\":\"POST\",\"path\":\"/my/path\",\"protocol\":\"HTTP/1.1\",\"sourceIp\":\"192.0.2.1\",\"userAgent\":\"agent\"},\"requestId\":\"id\",\"stage\":\"$default\"},\"body\":\"Hello from Lambda\",\"pathParameters\":{\"parameter1\":\"value1\"},\"isBase64Encoded\":false,\"stageVariables\":{\"stageVariable1\":\"value1\"}}"

pub fn api_gateway_v2_decodes_canonical_event_test() {
  let assert Ok(req) = json.parse(apigw_v2_json, event.api_gateway_v2_decoder())
  req.version |> should.equal("2.0")
  req.route_key |> should.equal("$default")
  req.raw_path |> should.equal("/my/path")
  req.raw_query_string |> should.equal("parameter1=value1&parameter2=value")
  req.method |> should.equal("POST")
  req.path |> should.equal("/my/path")
  req.source_ip |> should.equal("192.0.2.1")
  req.cookies |> should.equal(["cookie1", "cookie2"])
  req.body |> should.equal(Some("Hello from Lambda"))
  req.is_base64_encoded |> should.equal(False)
  dict.get(req.headers, "header1") |> should.equal(Ok("value1"))
  dict.get(req.query_string_parameters, "parameter2")
  |> should.equal(Ok("value"))
  dict.get(req.path_parameters, "parameter1") |> should.equal(Ok("value1"))
}

// --- API Gateway REST (payload format 1.0) ---------------------------------

const apigw_v1_json = "{\"resource\":\"/my/path\",\"path\":\"/my/path\",\"httpMethod\":\"GET\",\"headers\":{\"header1\":\"value1\",\"header2\":\"value2\"},\"queryStringParameters\":{\"parameter1\":\"value1\",\"parameter2\":\"value\"},\"pathParameters\":null,\"stageVariables\":null,\"body\":\"Hello from Lambda!\",\"isBase64Encoded\":false}"

pub fn api_gateway_v1_decodes_and_tolerates_null_maps_test() {
  let assert Ok(req) = json.parse(apigw_v1_json, event.api_gateway_decoder())
  req.http_method |> should.equal("GET")
  req.path |> should.equal("/my/path")
  req.resource |> should.equal("/my/path")
  req.body |> should.equal(Some("Hello from Lambda!"))
  req.is_base64_encoded |> should.equal(False)
  dict.get(req.query_string_parameters, "parameter1")
  |> should.equal(Ok("value1"))
  // pathParameters and stageVariables arrive as JSON null -> empty dicts.
  req.path_parameters |> should.equal(dict.new())
  req.stage_variables |> should.equal(dict.new())
}

// --- EventBridge -----------------------------------------------------------

pub type Ec2Detail {
  Ec2Detail(instance_id: String, state: String)
}

fn ec2_detail_decoder() -> decode.Decoder(Ec2Detail) {
  use instance_id <- decode.field("instance-id", decode.string)
  use state <- decode.field("state", decode.string)
  decode.success(Ec2Detail(instance_id: instance_id, state: state))
}

const eventbridge_json = "{\"version\":\"0\",\"id\":\"7bf73129-1428-4cd3-a780-95db273d1602\",\"detail-type\":\"EC2 Instance State-change Notification\",\"source\":\"aws.ec2\",\"account\":\"123456789012\",\"time\":\"2015-11-11T21:29:54Z\",\"region\":\"us-east-1\",\"resources\":[\"arn:aws:ec2:us-east-1:123456789012:instance/i-abcd1111\"],\"detail\":{\"instance-id\":\"i-abcd1111\",\"state\":\"pending\"}}"

pub fn eventbridge_decodes_with_typed_detail_test() {
  let assert Ok(eb) =
    json.parse(
      eventbridge_json,
      event.eventbridge_decoder(ec2_detail_decoder()),
    )
  eb.detail_type
  |> should.equal("EC2 Instance State-change Notification")
  eb.source |> should.equal("aws.ec2")
  eb.account |> should.equal("123456789012")
  eb.region |> should.equal("us-east-1")
  eb.resources
  |> should.equal(["arn:aws:ec2:us-east-1:123456789012:instance/i-abcd1111"])
  eb.detail
  |> should.equal(Ec2Detail(instance_id: "i-abcd1111", state: "pending"))
}

// --- S3 --------------------------------------------------------------------

const s3_json = "{\"Records\":[{\"eventVersion\":\"2.1\",\"eventSource\":\"aws:s3\",\"awsRegion\":\"us-east-2\",\"eventTime\":\"2019-09-03T19:37:27.192Z\",\"eventName\":\"ObjectCreated:Put\",\"s3\":{\"s3SchemaVersion\":\"1.0\",\"configurationId\":\"x\",\"bucket\":{\"name\":\"lambda-artifacts-deafc19498e3f2df\",\"ownerIdentity\":{\"principalId\":\"A3I5XTEXAMAI3E\"},\"arn\":\"arn:aws:s3:::lambda-artifacts-deafc19498e3f2df\"},\"object\":{\"key\":\"b21b84d653bb07b05b1e6b33684dc11b\",\"size\":1305107,\"eTag\":\"b21b84d653bb07b05b1e6b33684dc11b\",\"sequencer\":\"0C0F6F405D6ED209E1\"}}}]}"

pub fn s3_decodes_canonical_event_test() {
  let assert Ok(s3) = json.parse(s3_json, event.s3_decoder())
  let assert [record] = s3.records
  record.event_name |> should.equal("ObjectCreated:Put")
  record.event_source |> should.equal("aws:s3")
  record.aws_region |> should.equal("us-east-2")
  record.bucket_name |> should.equal("lambda-artifacts-deafc19498e3f2df")
  record.bucket_arn
  |> should.equal("arn:aws:s3:::lambda-artifacts-deafc19498e3f2df")
  record.object_key |> should.equal("b21b84d653bb07b05b1e6b33684dc11b")
  record.object_size |> should.equal(Some(1_305_107))
  record.object_etag |> should.equal(Some("b21b84d653bb07b05b1e6b33684dc11b"))
  record.object_sequencer |> should.equal(Some("0C0F6F405D6ED209E1"))
}

// --- SNS -------------------------------------------------------------------

const sns_json = "{\"Records\":[{\"EventSource\":\"aws:sns\",\"EventVersion\":\"1.0\",\"EventSubscriptionArn\":\"arn:aws:sns:us-east-1:123456789012:sns-topic:guid\",\"Sns\":{\"Type\":\"Notification\",\"MessageId\":\"95df01b4-ee98-5cb9-9903-4c221d41eb5e\",\"TopicArn\":\"arn:aws:sns:us-east-1:123456789012:sns-topic\",\"Subject\":\"TestInvoke\",\"Message\":\"Hello from SNS!\",\"Timestamp\":\"1970-01-01T00:00:00.000Z\"}}]}"

pub fn sns_decodes_canonical_event_test() {
  let assert Ok(sns) = json.parse(sns_json, event.sns_decoder())
  let assert [record] = sns.records
  record.event_source |> should.equal("aws:sns")
  record.event_subscription_arn
  |> should.equal("arn:aws:sns:us-east-1:123456789012:sns-topic:guid")
  record.sns.message_type |> should.equal("Notification")
  record.sns.message_id
  |> should.equal("95df01b4-ee98-5cb9-9903-4c221d41eb5e")
  record.sns.topic_arn
  |> should.equal("arn:aws:sns:us-east-1:123456789012:sns-topic")
  record.sns.subject |> should.equal(Some("TestInvoke"))
  record.sns.message |> should.equal("Hello from SNS!")
}

// --- robustness ------------------------------------------------------------

pub fn sns_decoder_requires_message_fields_test() {
  // `Sns` present but missing the required MessageId / Message -> error.
  json.parse("{\"Records\":[{\"Sns\":{}}]}", event.sns_decoder())
  |> should.be_error
}
