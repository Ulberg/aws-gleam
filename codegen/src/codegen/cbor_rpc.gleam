//// Code emitter for the `smithy.protocols#rpcv2Cbor` protocol.
////
//// rpcv2Cbor is an RPC-style protocol: each operation POSTs to
////   /service/<ServiceShapeName>/operation/<OperationName>
//// with `smithy-protocol: rpc-v2-cbor` and `Accept: application/cbor`.
//// The body is CBOR (RFC 8949). Empty-input operations send an empty
//// body and MUST NOT set `Content-Type` (so intermediaries don't
//// re-interpret the request).
////
//// This v1 emitter handles only `Unit`-input operations — enough to
//// drive the protocol-test corpus's request-side fixtures and the
//// `x-amzn-query-mode` header dispatch for `awsQueryCompatible`
//// services. CBOR body encoding for non-empty inputs is deferred
//// until a non-test service requires it.
////
//// Unlike the other protocol emitters, rpcv2Cbor scans the model for
//// every service carrying the trait and emits operations from each
//// into one combined module. The protocol-test fixture defines two
//// services (query-compat + non-query-compat); a real-world model
//// has exactly one, so the merged-module shape is a no-op for those.

import codegen/code.{type Code, CodeSome}
import codegen/dispatcher
import gleam/dict
import gleam/list
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{ShapeId}

pub type EmitResult {
  EmitResult(
    module_name: String,
    source: String,
    operations_emitted: List(String),
    dispatcher_specs: List(dispatcher.DispatcherSpec),
  )
}

const protocol_trait = "smithy.protocols#rpcv2Cbor"

const query_compatible_trait = "aws.protocols#awsQueryCompatible"

/// Emit one combined module covering every operation under every
/// service that carries the rpcv2Cbor trait. The CLI's
/// `find_service` is bypassed for this protocol — see
/// `aws_codegen.run` for the dispatch.
pub fn emit_services(m: Model) -> Result(EmitResult, String) {
  let services = find_services(m)
  case services {
    [] -> Error("no service has trait " <> protocol_trait)
    _ -> {
      let header = file_header()
      let op_emissions =
        list.flat_map(services, fn(svc) { emit_service_ops(m, svc) })
      let error_emissions = emit_error_shapes(m, services)
      let body =
        string.concat([
          header,
          "\n",
          string.concat(list.map(op_emissions, fn(e) { e.code })),
          string.concat(list.map(error_emissions, fn(e) { e.code })),
        ])
      let op_specs = list.map(op_emissions, to_op_dispatcher_spec)
      let err_specs = list.map(error_emissions, to_error_dispatcher_spec)
      Ok(EmitResult(
        module_name: "rpcv2cbor",
        source: body,
        operations_emitted: list.map(op_emissions, fn(e) { e.operation_id }),
        dispatcher_specs: list.append(op_specs, err_specs),
      ))
    }
  }
}

type ServiceCtx {
  ServiceCtx(service_id: String, service_name: String, query_compat: Bool)
}

type EmittedOp {
  EmittedOp(operation_id: String, code: String)
}

fn find_services(m: Model) -> List(ServiceCtx) {
  dict.to_list(m.shapes)
  |> list.filter_map(fn(pair) {
    let #(sid, sh) = pair
    case sh {
      shape.Service(traits: t, ..) ->
        case dict.has_key(t, ShapeId(protocol_trait)) {
          True -> {
            let id = shape_id.to_string(sid)
            let query = dict.has_key(t, ShapeId(query_compatible_trait))
            Ok(ServiceCtx(
              service_id: id,
              service_name: strip_namespace(id),
              query_compat: query,
            ))
          }
          False -> Error(Nil)
        }
      _ -> Error(Nil)
    }
  })
}

fn emit_service_ops(m: Model, svc: ServiceCtx) -> List(EmittedOp) {
  case model.lookup(m, svc.service_id) {
    Ok(shape.Service(operations: refs, ..)) ->
      list.filter_map(refs, fn(ref) {
        let ShapeId(target) = ref.target
        case model.lookup(m, target) {
          Ok(shape.Operation(input: in_ref, ..)) ->
            case is_unit_or_empty(m, in_ref) {
              True -> Ok(emit_empty_operation(target, svc))
              False -> Error(Nil)
            }
          _ -> Error(Nil)
        }
      })
    _ -> []
  }
}

fn emit_empty_operation(op_id: String, svc: ServiceCtx) -> EmittedOp {
  let local = strip_namespace(op_id)
  let snake = stringutils.pascal_to_snake(local)
  let input_type = string.concat([local, "Input"])
  let output_type = string.concat([local, "Output"])
  let uri =
    string.concat([
      "/service/",
      svc.service_name,
      "/operation/",
      local,
    ])
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
      build_request_fn(snake, input_type, uri, svc.query_compat),
      code.Blank,
      parse_response_fn(snake, output_type),
      code.Blank,
    ])
  EmittedOp(operation_id: op_id, code: code.render(module))
}

/// Emit the `build_<snake>_request` function for an empty-input
/// rpcv2Cbor operation. Headers carry the protocol selector and a
/// CBOR accept; query-compat services add `x-amzn-query-mode: true`.
/// Body is an empty bit array — and we deliberately do NOT set
/// `Content-Type` because the protocol-test forbids it (an empty body
/// has no media type).
fn build_request_fn(
  snake: String,
  input_type: String,
  uri: String,
  query_compat: Bool,
) -> Code {
  let base_pairs = [
    code.Tuple(items: [
      code.StrLit(value: "smithy-protocol"),
      code.StrLit(value: "rpc-v2-cbor"),
    ]),
    code.Tuple(items: [
      code.StrLit(value: "Accept"),
      code.StrLit(value: "application/cbor"),
    ]),
  ]
  let pairs = case query_compat {
    True ->
      list.append(base_pairs, [
        code.Tuple(items: [
          code.StrLit(value: "x-amzn-query-mode"),
          code.StrLit(value: "true"),
        ]),
      ])
    False -> base_pairs
  }
  let headers_assign =
    code.Let(
      name: "headers",
      value: code.Call(head: code.Ident(name: "dict.from_list"), args: [
        code.ListLit(items: pairs, tail: code.CodeNone),
      ]),
    )
  let tuple_expr =
    code.Tuple(items: [
      code.StrLit(value: "POST"),
      code.StrLit(value: uri),
      code.Ident(name: "headers"),
      code.Raw(fragment: "<<>>"),
    ])
  code.Fn(
    public: True,
    name: string.concat(["build_", snake, "_request"]),
    params: [code.Param(name: "_input", type_: input_type)],
    return: CodeSome("#(String, String, dict.Dict(String, String), BitArray)"),
    body: code.Block(items: [headers_assign, tuple_expr]),
  )
}

fn parse_response_fn(snake: String, output_type: String) -> Code {
  code.Fn(
    public: True,
    name: string.concat(["parse_", snake, "_response"]),
    params: [
      code.Param(name: "_code", type_: "Int"),
      code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
      code.Param(name: "_body", type_: "BitArray"),
    ],
    return: CodeSome(string.concat(["Result(", output_type, ", String)"])),
    body: code.Call(head: code.Ident(name: "Ok"), args: [
      code.Ident(name: output_type),
    ]),
  )
}

fn to_op_dispatcher_spec(op: EmittedOp) -> dispatcher.DispatcherSpec {
  let local = strip_namespace(op.operation_id)
  let snake = stringutils.pascal_to_snake(local)
  dispatcher.DispatcherSpec(
    op_id: op.operation_id,
    snake: snake,
    input_type: string.concat([local, "Input"]),
    has_typed_input: False,
    is_error_shape: False,
  )
}

fn to_error_dispatcher_spec(err: EmittedOp) -> dispatcher.DispatcherSpec {
  let local = strip_namespace(err.operation_id)
  let snake = stringutils.pascal_to_snake(local)
  dispatcher.DispatcherSpec(
    op_id: err.operation_id,
    snake: snake,
    input_type: local,
    has_typed_input: False,
    is_error_shape: True,
  )
}

/// Walk the rpcv2Cbor services' operations' `errors:` lists and emit a
/// struct + `parse_<snake>_response` for each unique error shape. The
/// parser decodes the CBOR body via `aws/internal/codec/cbor` and
/// returns the typed error — for the protocol-test corpus that's
/// enough; richer field extraction lands when a real-service rpcv2Cbor
/// target appears.
fn emit_error_shapes(m: Model, services: List(ServiceCtx)) -> List(EmittedOp) {
  let error_ids =
    services
    |> list.flat_map(fn(svc) { collect_error_ids(m, svc.service_id) })
    |> dedupe
  list.filter_map(error_ids, fn(id) {
    case model.lookup(m, id) {
      Ok(shape.Structure(members: members, ..)) ->
        Ok(emit_error_shape(id, has_member(members, "message")))
      _ -> Error(Nil)
    }
  })
}

fn collect_error_ids(m: Model, service_id: String) -> List(String) {
  case model.lookup(m, service_id) {
    Ok(shape.Service(operations: refs, ..)) ->
      list.flat_map(refs, fn(ref) {
        let ShapeId(target) = ref.target
        case model.lookup(m, target) {
          Ok(shape.Operation(errors: errs, ..)) ->
            list.map(errs, fn(e) {
              let ShapeId(eid) = e.target
              eid
            })
          _ -> []
        }
      })
    _ -> []
  }
}

fn dedupe(xs: List(String)) -> List(String) {
  list.fold(xs, [], fn(acc, x) {
    case list.contains(acc, x) {
      True -> acc
      False -> [x, ..acc]
    }
  })
  |> list.reverse
}

fn has_member(members: dict.Dict(String, shape.Member), name: String) -> Bool {
  dict.has_key(members, name)
}

fn emit_error_shape(error_id: String, with_message: Bool) -> EmittedOp {
  let local = strip_namespace(error_id)
  let snake = stringutils.pascal_to_snake(local)
  let variant = case with_message {
    True ->
      code.Variant(name: local, fields: [
        code.LabelledParam(
          label: "message",
          name: "message",
          type_: "option.Option(String)",
        ),
      ])
    False -> code.UnitVariant(name: local)
  }
  let module =
    code.Module(items: [
      code.Blank,
      code.TypeDef(public: True, is_opaque: False, name: local, variants: [
        variant,
      ]),
      code.Blank,
      parse_error_response_fn(snake, local, with_message),
      code.Blank,
    ])
  EmittedOp(operation_id: error_id, code: code.render(module))
}

/// Emit the parse function for an error shape. The CBOR body of an
/// rpcv2Cbor error is a top-level `map` with a `__type` discriminator
/// plus the shape's members. We decode it and project the `message`
/// field if the shape carries one — anything else is dropped today.
fn parse_error_response_fn(
  snake: String,
  ctor: String,
  with_message: Bool,
) -> Code {
  let body = case with_message {
    True -> "case cbor.decode_value(body) {
    Error(reason) -> Error(\"cbor decode failed: \" <> reason)
    Ok(value) -> {
      let message = case cbor.get_field(value, \"message\") {
        option.Some(cbor.CString(s)) -> option.Some(s)
        _ -> option.None
      }
      Ok(" <> ctor <> "(message: message))
    }
  }"
    False -> "case cbor.decode_value(body) {
    Error(reason) -> Error(\"cbor decode failed: \" <> reason)
    Ok(_) -> Ok(" <> ctor <> ")
  }"
  }
  code.Fn(
    public: True,
    name: string.concat(["parse_", snake, "_response"]),
    params: [
      code.Param(name: "_code", type_: "Int"),
      code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
      code.Param(name: "body", type_: "BitArray"),
    ],
    return: CodeSome(string.concat(["Result(", ctor, ", String)"])),
    body: code.Raw(fragment: body),
  )
}

fn file_header() -> String {
  code.render(
    code.Module(items: [
      code.ModuleDocComment(lines: [
        "Generated rpcv2Cbor protocol-test client.",
        "DO NOT EDIT. Re-generate via the codegen subproject.",
      ]),
      code.Blank,
      code.Import(
        path: "aws/internal/codec/cbor",
        alias: code.CodeNone,
        unqualified: [],
      ),
      code.Import(path: "gleam/dict", alias: code.CodeNone, unqualified: []),
      code.Import(path: "gleam/option", alias: code.CodeNone, unqualified: []),
    ]),
  )
  |> fn(s) { string.concat([s, "\n"]) }
}

fn is_unit_or_empty(m: Model, ref: shape.Reference) -> Bool {
  let ShapeId(id) = ref.target
  case id {
    "smithy.api#Unit" -> True
    _ ->
      case model.lookup(m, id) {
        Ok(shape.Structure(members: members, ..)) -> dict.size(members) == 0
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
