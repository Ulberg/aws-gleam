//// Code emitter for awsQuery (form-urlencoded body) and ec2Query (same
//// wire shape, different list-encoding rules — handled by the same
//// generator at this level since the empty-input case is identical).
////
//// For empty-input operations the body is:
////   Action=<OperationName>&Version=<service.version>
//// method = POST, uri = "/", content-type = application/x-www-form-urlencoded.

import codegen/dispatcher
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{ShapeId}

pub type Variant {
  AwsQuery
  Ec2Query
}

pub type EmitResult {
  EmitResult(
    module_name: String,
    source: String,
    operations_emitted: List(String),
    /// One per emitted operation; the CLI uses it to render the
    /// matching `<protocol>_dispatchers.gleam` for protocol-test
    /// targets. Populated unconditionally — production-service
    /// emissions just drop it.
    dispatcher_specs: List(dispatcher.DispatcherSpec),
  )
}

pub fn emit_service(
  model: Model,
  service_id: String,
  variant: Variant,
) -> Result(EmitResult, String) {
  case model.lookup(model, service_id) {
    Error(_) -> Error("service not found: " <> service_id)
    Ok(shape.Service(operations: refs, version: ver, ..)) -> {
      let version = case ver {
        Some(v) -> v
        None -> "unknown"
      }
      let header = file_header(service_id, variant)
      let emitted_ops =
        list.filter_map(refs, fn(ref) {
          let ShapeId(target) = ref.target
          case model.lookup(model, target) {
            Ok(shape.Operation(input: in_ref, ..)) ->
              case is_unit_or_empty(model, in_ref) {
                True -> Ok(emit_empty_operation(target, version))
                False -> Error(Nil)
              }
            _ -> Error(Nil)
          }
        })
      let body =
        header
        <> "\n"
        <> list.fold(emitted_ops, "", fn(acc, e) { acc <> e.code })
      // The awsQuery / ec2Query emitter today only handles
      // empty-input operations and never emits a `decode_<op>_input`
      // helper, so dispatchers built from these specs go through
      // the singleton-input path.
      let dispatcher_specs =
        list.map(emitted_ops, fn(e) {
          let local = strip_namespace(e.operation_id)
          let snake = stringutils.pascal_to_snake(local)
          dispatcher.DispatcherSpec(
            op_id: e.operation_id,
            snake: snake,
            input_type: local <> "Input",
            has_typed_input: False,
          )
        })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        operations_emitted: list.map(emitted_ops, fn(e) { e.operation_id }),
        dispatcher_specs: dispatcher_specs,
      ))
    }
    Ok(_) -> Error("not a service: " <> service_id)
  }
}

type EmittedOp {
  EmittedOp(operation_id: String, code: String)
}

fn emit_empty_operation(op_id: String, version: String) -> EmittedOp {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let body_literal = "Action=" <> local <> "&Version=" <> version
  let template = "
pub type " <> pascal <> "Input {
  " <> pascal <> "Input
}

pub type " <> pascal <> "Output {
  " <> pascal <> "Output
}

pub fn build_" <> snake <> "_request(
  _input: " <> pascal <> "Input,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#(\"Content-Type\", \"application/x-www-form-urlencoded\")])
  #(\"POST\", \"/\", headers, <<\"" <> body_literal <> "\">>)
}

pub fn parse_" <> snake <> "_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(" <> pascal <> "Output, String) {
  Ok(" <> pascal <> "Output)
}
"
  EmittedOp(operation_id: op_id, code: template)
}

fn file_header(service_id: String, variant: Variant) -> String {
  let proto = case variant {
    AwsQuery -> "awsQuery"
    Ec2Query -> "ec2Query"
  }
  "//// Generated from " <> service_id <> " (" <> proto <> ").
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
