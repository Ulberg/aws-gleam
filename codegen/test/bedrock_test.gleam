//// Regression coverage using AWS's resource-bound Bedrock models.

import codegen/restjson
import gleam/dict
import gleam/json
import gleam/list
import gleam/string
import gleeunit/should
import simplifile
import smithy/model
import smithy/shape
import smithy/shape_id

/// Runtime operations live on resources, not directly on the service.
pub fn bedrock_runtime_emits_resource_operations_test() {
  let m = load("bedrock-runtime")
  let assert Ok(emitted) =
    restjson.emit_service(
      m,
      "com.amazonaws.bedrockruntime#AmazonBedrockFrontendService",
    )
    as "Bedrock Runtime must generate"
  should.equal(emitted.operations_emitted, all_operation_ids(m))
  should.equal(list.length(emitted.operations_emitted), 10)
  should.be_true(string.contains(emitted.source, "pub fn converse("))
  should.be_true(string.contains(emitted.source, "pub fn invoke_model("))
}

/// The control-plane model also uses lifecycle bindings and nested resources.
pub fn bedrock_emits_all_control_plane_operations_test() {
  let m = load("bedrock")
  let service_id = find_service_id(m)
  let assert Ok(emitted) = restjson.emit_service(m, service_id)
    as "Bedrock must generate"
  should.equal(emitted.operations_emitted, all_operation_ids(m))
  should.be_true(string.contains(
    emitted.source,
    "pub fn list_foundation_models(",
  ))
  should.be_true(string.contains(emitted.source, "pub fn create_guardrail("))
}

/// A shared operation or resource must not produce duplicate declarations.
pub fn resource_operations_are_deduplicated_test() {
  let m = load("bedrock-runtime")
  let service_id = find_service_id(m)
  let expected = model.operation_refs(m, service_id)
  let assert Ok(shape.Service(version, _, resources, errors, traits)) =
    model.lookup(m, service_id)
    as "Bedrock Runtime service must exist"
  let service =
    shape.Service(
      version,
      expected,
      list.append(resources, resources),
      errors,
      traits,
    )
  let m =
    model.Model(
      ..m,
      shapes: dict.insert(m.shapes, shape_id.ShapeId(service_id), service),
    )
  should.equal(model.operation_refs(m, service_id), expected)
}

fn find_service_id(m: model.Model) -> String {
  let services =
    m.shapes
    |> dict.to_list
    |> list.filter_map(fn(entry) {
      case entry {
        #(id, shape.Service(..)) -> Ok(shape_id.to_string(id))
        _ -> Error(Nil)
      }
    })
  let assert [id] = services as "AWS model must contain one service"
  id
}

fn all_operation_ids(m: model.Model) -> List(String) {
  m.shapes
  |> dict.to_list
  |> list.filter_map(fn(entry) {
    case entry {
      #(id, shape.Operation(..)) -> Ok(shape_id.to_string(id))
      _ -> Error(Nil)
    }
  })
  |> list.sort(string.compare)
}

fn load(service: String) -> model.Model {
  let assert Ok(text) =
    simplifile.read("../vendor/aws-sdk-rust/aws-models/" <> service <> ".json")
    as "vendored AWS model must exist"
  let assert Ok(m) = json.parse(text, model.decoder())
    as "vendored AWS model must decode"
  m
}
