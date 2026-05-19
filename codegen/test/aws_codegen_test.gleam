import codegen/types
import gleam/dict
import gleam/json
import gleam/list
import gleam/result
import gleeunit
import gleeunit/should
import simplifile
import smithy/model
import smithy/shape
import smithy/shape_id.{ShapeId}

pub fn main() {
  gleeunit.main()
}

const dynamodb_model_path = "../vendor/aws-sdk-rust/aws-models/dynamodb.json"

const s3_model_path = "../vendor/aws-sdk-rust/aws-models/s3.json"

pub fn parses_dynamodb_model_test() {
  let m = load(dynamodb_model_path)
  m.smithy_version |> should.equal("2.0")
  // The DynamoDB service shape exists.
  let assert Ok(svc) =
    model.lookup(m, "com.amazonaws.dynamodb#DynamoDB_20120810")
  case svc {
    shape.Service(operations: ops, ..) -> should.be_true(list.length(ops) > 30)
    _ -> should.fail()
  }
}

pub fn parses_s3_model_test() {
  let m = load(s3_model_path)
  m.smithy_version |> should.equal("2.0")
  // S3 service shape exists; restXml protocol trait is present.
  let assert Ok(svc) = model.lookup(m, "com.amazonaws.s3#AmazonS3")
  case svc {
    shape.Service(traits: traits, operations: ops, ..) -> {
      should.be_true(list.length(ops) > 50)
      // restXml protocol trait must be on the service.
      should.be_true(dict.has_key(traits, ShapeId("aws.protocols#restXml")))
    }
    _ -> should.fail()
  }
}

/// `types.has_streaming_blob_member` is the detection hook the
/// codegen will eventually use to emit a `<op>_streaming(client,
/// input)` variant for operations whose output struct carries a
/// `@streaming` blob. Pin its return on two reference S3 shapes:
///   - GetObjectOutput has a `body: StreamingBody` member → True
///   - ListBucketsOutput is header-only → False
/// Other shape kinds (the GetObjectRequest struct, a non-existent
/// shape) also return False so emitters can call this directly
/// without first narrowing to Structure shapes.
pub fn detects_streaming_blob_member_on_s3_outputs_test() {
  let m = load(s3_model_path)
  types.has_streaming_blob_member(m, "com.amazonaws.s3#GetObjectOutput")
  |> should.equal(True)
  types.has_streaming_blob_member(m, "com.amazonaws.s3#ListBucketsOutput")
  |> should.equal(False)
  types.has_streaming_blob_member(m, "com.amazonaws.s3#GetObjectRequest")
  |> should.equal(False)
  types.has_streaming_blob_member(m, "com.amazonaws.s3#NotARealShape")
  |> should.equal(False)
}

pub fn parses_every_shape_kind_test() {
  // dynamodb.json exercises every aggregate kind (Structure, List, Map,
  // Enum, Union) and many simple kinds. If decoding succeeds we have
  // coverage of all decoder branches we care about.
  let _ = load(dynamodb_model_path)
  Nil
}

fn load(path: String) -> model.Model {
  let text =
    simplifile.read(path)
    |> result.lazy_unwrap(fn() { panic as { "could not read " <> path } })
  json.parse(text, model.decoder())
  |> result.lazy_unwrap(fn() { panic as { "could not decode " <> path } })
}
