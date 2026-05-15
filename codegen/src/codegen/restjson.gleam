//// Code emitter for restJson1.
////
//// Walks a parsed `smithy.Model` and for each operation reads the
//// `@http` trait (method + uri) and emits a Gleam builder. This first
//// pass handles operations whose input shape is `smithy.api#Unit` or an
//// empty structure — body is empty, headers default to none.
////
//// Typed body / path / query / header bindings land in subsequent
//// iterations. The protocol-test runner is the green-bar that drives
//// that growth.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{type ShapeId, ShapeId}
import smithy/trait.{type Trait}

pub type EmitResult {
  EmitResult(
    module_name: String,
    source: String,
    operations_emitted: List(String),
  )
}

pub fn emit_service(
  model: Model,
  service_id: String,
) -> Result(EmitResult, String) {
  case model.lookup(model, service_id) {
    Error(_) -> Error("service not found: " <> service_id)
    Ok(shape.Service(operations: refs, ..)) -> {
      let header = file_header(service_id)
      let emitted_ops =
        list.filter_map(refs, fn(ref) {
          let ShapeId(target) = ref.target
          case model.lookup(model, target) {
            Ok(shape.Operation(
              input: in_ref,
              output: _out_ref,
              traits: op_traits,
              ..,
            )) ->
              case http_trait(op_traits) {
                Some(http) ->
                  case is_unit_or_empty(model, in_ref) {
                    True -> Ok(emit_empty_operation(target, http))
                    False -> Error(Nil)
                  }
                None -> Error(Nil)
              }
            _ -> Error(Nil)
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

type HttpTrait {
  HttpTrait(method: String, uri: String, code: Int)
}

fn emit_empty_operation(op_id: String, http: HttpTrait) -> EmittedOp {
  let local_name = strip_namespace(op_id)
  let pascal = local_name
  let snake = stringutils.pascal_to_snake(local_name)
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
  #(\"" <> http.method <> "\", \"" <> http.uri <> "\", dict.new(), <<>>)
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

fn file_header(service_id: String) -> String {
  "//// Generated from " <> service_id <> " (restJson1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import gleam/dict
"
}

fn http_trait(traits: shape.Traits) -> option.Option(HttpTrait) {
  case dict.get(traits, ShapeId("smithy.api#http")) {
    Ok(Some(trait.Dict(d))) -> {
      let method = string_field(d, "method")
      let uri = string_field(d, "uri")
      let code = int_field(d, "code", 200)
      case method, uri {
        Some(m), Some(u) -> Some(HttpTrait(method: m, uri: u, code: code))
        _, _ -> None
      }
    }
    _ -> None
  }
}

fn string_field(
  d: Dict(ShapeId, Trait),
  name: String,
) -> option.Option(String) {
  case dict.get(d, ShapeId(name)) {
    Ok(trait.String(s)) -> Some(s)
    _ -> None
  }
}

fn int_field(d: Dict(ShapeId, Trait), name: String, default: Int) -> Int {
  case dict.get(d, ShapeId(name)) {
    Ok(trait.Int(n)) -> n
    _ -> default
  }
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
