//// Code emitter for awsQuery (form-urlencoded body) and ec2Query (same
//// wire shape, different list-encoding rules — handled by the same
//// generator at this level since the empty-input case is identical).
////
//// For empty-input operations the body is:
////   Action=<OperationName>&Version=<service.version>
//// method = POST, uri = "/", content-type = application/x-www-form-urlencoded.

import codegen/code.{type Code, CodeSome}
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
    Error(_) -> Error(string.concat(["service not found: ", service_id]))
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
        string.concat([
          header,
          "\n",
          string.concat(list.map(emitted_ops, fn(e) { e.code })),
        ])
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
            input_type: name_concat([local, "Input"]),
            has_typed_input: False,
            is_error_shape: False,
          )
        })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        operations_emitted: list.map(emitted_ops, fn(e) { e.operation_id }),
        dispatcher_specs: dispatcher_specs,
      ))
    }
    Ok(_) -> Error(string.concat(["not a service: ", service_id]))
  }
}

type EmittedOp {
  EmittedOp(operation_id: String, code: String)
}

fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

fn emit_empty_operation(op_id: String, version: String) -> EmittedOp {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let input_type = name_concat([pascal, "Input"])
  let output_type = name_concat([pascal, "Output"])
  let body_literal = name_concat(["Action=", local, "&Version=", version])
  let module =
    code.Module(items: [
      code.Blank,
      code.TypeDef(public: True, is_opaque: False, name: input_type, variants: [
        code.UnitVariant(name: input_type),
      ]),
      code.Blank,
      code.TypeDef(public: True, is_opaque: False, name: output_type, variants: [
        code.UnitVariant(name: output_type),
      ]),
      code.Blank,
      build_request_fn(snake, input_type, body_literal),
      code.Blank,
      parse_response_fn(snake, output_type),
      code.Blank,
    ])
  EmittedOp(operation_id: op_id, code: code.render(module))
}

/// `pub fn build_<snake>_request(_input: <input_type>) -> #(...) { ... }`
/// — the awsQuery / ec2Query empty-input form is a fixed
/// `Action=Op&Version=v` body with `POST /` and a standard
/// form-urlencoded content-type header.
fn build_request_fn(
  snake: String,
  input_type: String,
  body_literal: String,
) -> Code {
  let headers_assign =
    code.Let(
      name: "headers",
      value: code.Raw(
        fragment: "dict.from_list([#(\"Content-Type\", \"application/x-www-form-urlencoded\")])",
      ),
    )
  let tuple_expr =
    code.Tuple(items: [
      code.StrLit(value: "POST"),
      code.StrLit(value: "/"),
      code.Ident(name: "headers"),
      code.Raw(fragment: name_concat(["<<\"", body_literal, "\">>"])),
    ])
  code.Fn(
    public: True,
    name: name_concat(["build_", snake, "_request"]),
    params: [code.Param(name: "_input", type_: input_type)],
    return: CodeSome("#(String, String, dict.Dict(String, String), BitArray)"),
    body: code.Block(items: [headers_assign, tuple_expr]),
  )
}

/// `pub fn parse_<snake>_response(_code, _headers, _body) -> Result(<output_type>, String) { Ok(<output_type>) }`.
fn parse_response_fn(snake: String, output_type: String) -> Code {
  code.Fn(
    public: True,
    name: name_concat(["parse_", snake, "_response"]),
    params: [
      code.Param(name: "_code", type_: "Int"),
      code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
      code.Param(name: "_body", type_: "BitArray"),
    ],
    return: CodeSome(name_concat(["Result(", output_type, ", String)"])),
    body: code.Call(head: code.Ident(name: "Ok"), args: [
      code.Ident(name: output_type),
    ]),
  )
}

fn file_header(service_id: String, variant: Variant) -> String {
  let proto = case variant {
    AwsQuery -> "awsQuery"
    Ec2Query -> "ec2Query"
  }
  code.render(
    code.Module(items: [
      code.ModuleDocComment(lines: [
        name_concat(["Generated from ", service_id, " (", proto, ")."]),
        "DO NOT EDIT. Re-generate via the codegen subproject.",
      ]),
      code.Blank,
      code.Import(path: "gleam/dict", alias: code.CodeNone, unqualified: []),
    ]),
  )
  |> fn(s) { string.concat([s, "\n"]) }
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
