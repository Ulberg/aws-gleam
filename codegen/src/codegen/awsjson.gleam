//// Code emitter for awsJson1_0 and awsJson1_1.
////
//// Walks a parsed `smithy.Model` and, for each operation whose input
//// and output are the unit shape `smithy.api#Unit` (or an empty
//// structure), emits a Gleam module exposing:
////
////   - typed `*Input` and `*Output` records (singleton variants today)
////   - a `build_<op>_request` function producing
////     `#(method, uri, headers, body)`
////   - a `parse_<op>_response` function producing the typed output
////
//// More shape patterns (scalar fields, lists, maps, unions) land in
//// subsequent iterations. The protocol-test runner provides the green
//// bar that drives that growth.

import gleam/dict
import gleam/list
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{ShapeId}

pub type Protocol {
  AwsJson10
  AwsJson11
}

pub fn content_type(p: Protocol) -> String {
  case p {
    AwsJson10 -> "application/x-amz-json-1.0"
    AwsJson11 -> "application/x-amz-json-1.1"
  }
}

pub type EmitResult {
  EmitResult(
    module_name: String,
    source: String,
    operations_emitted: List(String),
  )
}

/// Emit one Gleam module per service. `service_id` is the full Smithy
/// shape ID; the emitter derives the module name from it.
pub fn emit_service(
  model: Model,
  service_id: String,
  protocol: Protocol,
) -> Result(EmitResult, String) {
  case model.lookup(model, service_id) {
    Error(_) -> Error("service not found: " <> service_id)
    Ok(shape.Service(operations: refs, traits: traits, ..)) -> {
      let service_target = service_target_name(traits, service_id)
      let header = file_header(service_id, protocol)
      let ops_with_shapes =
        list.filter_map(refs, fn(ref) {
          let ShapeId(target) = ref.target
          case model.lookup(model, target) {
            Ok(shape.Operation(input: in_ref, output: out_ref, ..)) ->
              Ok(#(target, in_ref, out_ref))
            _ -> Error(Nil)
          }
        })
      let emitted_ops =
        list.filter_map(ops_with_shapes, fn(t) {
          let #(op_id, in_ref, out_ref) = t
          case
            is_unit_or_empty(model, in_ref),
            is_unit_or_empty(model, out_ref)
          {
            True, True ->
              Ok(emit_empty_operation(op_id, service_target, protocol))
            _, _ -> Error(Nil)
          }
        })
      let module_name = derive_module_name(service_id)
      let body =
        header
        <> "\n"
        <> list.fold(emitted_ops, "", fn(acc, e) { acc <> e.code })
      Ok(EmitResult(
        module_name: module_name,
        source: body,
        operations_emitted: list.map(emitted_ops, fn(e) { e.operation_id }),
      ))
    }
    Ok(_) -> Error("not a service: " <> service_id)
  }
}

type EmittedOp {
  EmittedOp(operation_id: String, code: String)
}

fn emit_empty_operation(
  op_id: String,
  service_target: String,
  protocol: Protocol,
) -> EmittedOp {
  let local_name = strip_namespace(op_id)
  let pascal = local_name
  let snake = stringutils.pascal_to_snake(local_name)
  let target_value = service_target <> "." <> local_name
  let ct = content_type(protocol)
  let template = "
pub type " <> pascal <> "Input {
  " <> pascal <> "Input
}

pub type " <> pascal <> "Output {
  " <> pascal <> "Output
}

pub fn build_" <> snake <> "_request(
  _input: " <> pascal <> "Input,
) -> #(String, String, gleam@dict.Dict(String, String), BitArray) {
  let headers =
    gleam@dict.from_list([
      #(\"Content-Type\", \"" <> ct <> "\"),
      #(\"X-Amz-Target\", \"" <> target_value <> "\"),
    ])
  #(\"POST\", \"/\", headers, <<\"{}\">>)
}

pub fn parse_" <> snake <> "_response(
  _code: Int,
  _headers: gleam@dict.Dict(String, String),
  _body: BitArray,
) -> Result(" <> pascal <> "Output, String) {
  Ok(" <> pascal <> "Output)
}
"
  // Gleam doesn't allow `gleam@dict` token in source; the alias is for
  // template parsing. Replace with proper module reference.
  let normalised = string.replace(template, "gleam@dict", "dict")
  EmittedOp(operation_id: op_id, code: normalised)
}

fn file_header(service_id: String, protocol: Protocol) -> String {
  let proto_str = case protocol {
    AwsJson10 -> "awsJson1_0"
    AwsJson11 -> "awsJson1_1"
  }
  "//// Generated from " <> service_id <> " (" <> proto_str <> ").
//// DO NOT EDIT. Re-generate via the codegen subproject.

import gleam/dict
"
}

fn is_unit_or_empty(model: Model, ref: shape.Reference) -> Bool {
  let ShapeId(id) = ref.target
  case id {
    "smithy.api#Unit" -> True
    _ ->
      case model.lookup(model, id) {
        Ok(shape.Structure(members: m, ..)) -> dict.size(m) == 0
        _ -> False
      }
  }
}

fn service_target_name(traits: shape.Traits, service_id: String) -> String {
  // For awsJson protocols the target prefix is the value of the
  // @sigv4 / @aws.api#service "sdkId" — actually it's the SHAPE NAME
  // of the service (without namespace), per Smithy spec. Test cases
  // confirm: `JsonRpc10.NoInputAndNoOutput` for service named
  // `JsonRpc10`. We use the bare local name.
  let _ = traits
  strip_namespace(service_id)
}

fn strip_namespace(id: String) -> String {
  case string.split_once(id, "#") {
    Ok(#(_, local)) -> local
    Error(_) -> id
  }
}

fn derive_module_name(service_id: String) -> String {
  let local = strip_namespace(service_id)
  stringutils.pascal_to_snake(local)
}
