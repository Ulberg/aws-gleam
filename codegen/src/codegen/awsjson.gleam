//// Code emitter for awsJson1_0 and awsJson1_1.
////
//// Walks a parsed `smithy.Model` and emits one Gleam module per
//// service. Per operation:
////
////   * If input and output are both unit (or empty structure), emit
////     singleton input/output records and a body of `{}`.
////   * If input or output is a structure of supported primitives
////     (`String`/`Int`/`Float`/`Bool`), emit typed records with
////     `Option(T)` fields and JSON encoder + decoder helpers.
////   * Otherwise skip the operation. The protocol-test runner will
////     report it as `skip_no_dispatcher` until further shape kinds
////     (list, map, enum, union, structure, timestamp, blob, document)
////     land.

import codegen/types
import gleam/dict.{type Dict}
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

pub fn emit_service(
  model: Model,
  service_id: String,
  protocol: Protocol,
) -> Result(EmitResult, String) {
  case model.lookup(model, service_id) {
    Error(_) -> Error("service not found: " <> service_id)
    Ok(shape.Service(operations: refs, ..)) -> {
      let service_target = strip_namespace(service_id)
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
          emit_operation(
            model,
            op_id,
            in_ref,
            out_ref,
            service_target,
            protocol,
          )
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

/// Pick the right per-op codegen path based on input/output shapes.
fn emit_operation(
  model: Model,
  op_id: String,
  in_ref: shape.Reference,
  out_ref: shape.Reference,
  service_target: String,
  protocol: Protocol,
) -> Result(EmittedOp, Nil) {
  case classify(model, in_ref), classify(model, out_ref) {
    Empty, Empty -> Ok(emit_op(op_id, service_target, protocol, [], []))
    EmptyOrPrimitive(in_members), EmptyOrPrimitive(out_members) ->
      Ok(emit_op(op_id, service_target, protocol, in_members, out_members))
    _, _ -> Error(Nil)
  }
}

type Classified {
  Empty
  EmptyOrPrimitive(members: List(MemberSpec))
  Unsupported
}

type MemberSpec {
  MemberSpec(json_name: String, snake_name: String, primitive: types.Primitive)
}

fn classify(model: Model, ref: shape.Reference) -> Classified {
  let ShapeId(id) = ref.target
  case id {
    "smithy.api#Unit" -> Empty
    _ ->
      case model.lookup(model, id) {
        Ok(shape.Structure(members: m, ..)) ->
          case dict.size(m) {
            0 -> Empty
            _ ->
              case types.all_members_primitive(model, m) {
                False -> Unsupported
                True -> EmptyOrPrimitive(members: extract_members(model, m))
              }
          }
        _ -> Unsupported
      }
  }
}

fn extract_members(
  model: Model,
  members: Dict(String, shape.Member),
) -> List(MemberSpec) {
  // Sort by JSON name so emission is stable across runs.
  dict.to_list(members)
  |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
  |> list.filter_map(fn(pair) {
    let #(name, mem) = pair
    let ShapeId(target) = mem.target
    case types.resolve(model, target) {
      types.Resolved(primitive: p) ->
        Ok(MemberSpec(
          json_name: name,
          snake_name: stringutils.pascal_to_snake(name),
          primitive: p,
        ))
      types.Unsupported(..) -> Error(Nil)
    }
  })
}

fn emit_op(
  op_id: String,
  service_target: String,
  protocol: Protocol,
  in_members: List(MemberSpec),
  out_members: List(MemberSpec),
) -> EmittedOp {
  let local_name = strip_namespace(op_id)
  let pascal = local_name
  let snake = stringutils.pascal_to_snake(local_name)
  let target_value = service_target <> "." <> local_name
  let ct = content_type(protocol)
  let input_record = emit_record(pascal <> "Input", in_members)
  let output_record = emit_record(pascal <> "Output", out_members)
  let in_encoder = emit_encoder(pascal, snake, in_members)
  let in_decoder =
    emit_struct_decoder(
      "decode_" <> snake <> "_input",
      pascal <> "Input",
      in_members,
    )
  let out_decoder =
    emit_struct_decoder(
      "decode_" <> snake <> "_output",
      pascal <> "Output",
      out_members,
    )
  let build = emit_build(pascal, snake, target_value, ct, in_members)
  let parse = emit_parse(pascal, snake, out_members)
  let code =
    "\n"
    <> input_record
    <> output_record
    <> in_encoder
    <> in_decoder
    <> out_decoder
    <> build
    <> parse
  EmittedOp(operation_id: op_id, code: code)
}

fn emit_record(name: String, members: List(MemberSpec)) -> String {
  case members {
    [] -> "pub type " <> name <> " {
  " <> name <> "
}

"
    _ -> "pub type " <> name <> " {
  " <> name <> "(
" <> emit_record_fields(members) <> "  )
}

"
  }
}

fn emit_record_fields(members: List(MemberSpec)) -> String {
  list.fold(members, "", fn(acc, m) {
    acc
    <> "    "
    <> m.snake_name
    <> ": option.Option("
    <> types.gleam_type(m.primitive)
    <> "),
"
  })
}

fn emit_encoder(
  pascal: String,
  snake: String,
  members: List(MemberSpec),
) -> String {
  case members {
    [] ->
      "pub fn encode_"
      <> snake
      <> "_input(_input: "
      <> pascal
      <> "Input) -> String {
  \"{}\"
}

"
    _ ->
      "pub fn encode_"
      <> snake
      <> "_input(input: "
      <> pascal
      <> "Input) -> String {
  let pairs = []
"
      <> emit_encoder_field_lines(members)
      <> "  json.to_string(json.object(pairs))
}

"
  }
}

fn emit_encoder_field_lines(members: List(MemberSpec)) -> String {
  list.fold(members, "", fn(acc, m) {
    acc <> "  let pairs = case input." <> m.snake_name <> " {
    option.Some(v) -> [#(\"" <> m.json_name <> "\", " <> types.json_encoder(
      m.primitive,
    ) <> "(v)), ..pairs]
    option.None -> pairs
  }
"
  })
}

fn emit_struct_decoder(
  fn_name: String,
  type_name: String,
  members: List(MemberSpec),
) -> String {
  case members {
    [] ->
      "pub fn "
      <> fn_name
      <> "(_body: String) -> Result("
      <> type_name
      <> ", String) {
  Ok("
      <> type_name
      <> ")
}

"
    _ ->
      "pub fn "
      <> fn_name
      <> "(body: String) -> Result("
      <> type_name
      <> ", String) {
  let dec = {
"
      <> emit_decoder_field_lines(members)
      <> "    decode.success("
      <> type_name
      <> "(
"
      <> emit_decoder_constructor_args(members)
      <> "    ))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error(\"decode failed\")
  }
}

"
  }
}

fn emit_decoder_field_lines(members: List(MemberSpec)) -> String {
  list.fold(members, "", fn(acc, m) {
    acc
    <> "    use "
    <> m.snake_name
    <> " <- decode.optional_field(\""
    <> m.json_name
    <> "\", option.None, decode.optional("
    <> types.json_decoder(m.primitive)
    <> "))
"
  })
}

fn emit_decoder_constructor_args(members: List(MemberSpec)) -> String {
  list.fold(members, "", fn(acc, m) {
    acc <> "      " <> m.snake_name <> ": " <> m.snake_name <> ",
"
  })
}

fn emit_build(
  pascal: String,
  snake: String,
  target_value: String,
  ct: String,
  members: List(MemberSpec),
) -> String {
  let _ = members
  "pub fn build_" <> snake <> "_request(
  input: " <> pascal <> "Input,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_" <> snake <> "_input(input)
  let headers =
    dict.from_list([
      #(\"Content-Type\", \"" <> ct <> "\"),
      #(\"X-Amz-Target\", \"" <> target_value <> "\"),
    ])
  #(\"POST\", \"/\", headers, bit_array.from_string(body_str))
}

"
}

fn emit_parse(
  pascal: String,
  snake: String,
  members: List(MemberSpec),
) -> String {
  case members {
    [] -> "pub fn parse_" <> snake <> "_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(" <> pascal <> "Output, String) {
  Ok(" <> pascal <> "Output)
}

"
    _ -> "pub fn parse_" <> snake <> "_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(" <> pascal <> "Output, String) {
  case bit_array.to_string(body) {
    Ok(text) -> decode_" <> snake <> "_output(text)
    Error(_) -> Error(\"non-utf8 body\")
  }
}

"
  }
}

fn file_header(service_id: String, protocol: Protocol) -> String {
  let proto_str = case protocol {
    AwsJson10 -> "awsJson1_0"
    AwsJson11 -> "awsJson1_1"
  }
  "//// Generated from " <> service_id <> " (" <> proto_str <> ").
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/internal/codec/json_float
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
"
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
