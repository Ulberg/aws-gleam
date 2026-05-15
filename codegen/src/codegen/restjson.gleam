//// Code emitter for restJson1.
////
//// Walks `@http` traits per operation, emits a builder. Supports
////   * empty input → empty body
////   * structure of primitive members with no @http-binding traits →
////     JSON body via the same encoder/decoder pattern as awsJson
////
//// Operations with @httpLabel / @httpQuery / @httpHeader /
//// @httpPayload / @httpPrefixHeaders bindings, or with non-primitive
//// member types (list/map/structure/union/enum/timestamp/blob/
//// document), are still skipped — the runner reports them as
//// `skip_no_dispatcher`. Those traits are the next-iteration target.

import codegen/types
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
              output: out_ref,
              traits: op_traits,
              ..,
            )) ->
              case
                http_trait(op_traits),
                op_uses_unsupported_trait(op_traits)
              {
                Some(http), False ->
                  emit_operation(model, target, http, in_ref, out_ref)
                _, _ -> Error(Nil)
              }
            _ -> Error(Nil)
          }
        })
      let body =
        header
        <> "\n"
        <> list.fold(emitted_ops, "", fn(acc, e) { acc <> e.code })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
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

type Classified {
  Empty
  PrimitiveBody(members: List(MemberSpec))
  Unsupported
}

type MemberSpec {
  MemberSpec(json_name: String, snake_name: String, primitive: types.Primitive)
}

fn emit_operation(
  model: Model,
  op_id: String,
  http: HttpTrait,
  in_ref: shape.Reference,
  out_ref: shape.Reference,
) -> Result(EmittedOp, Nil) {
  case classify(model, in_ref) {
    Unsupported -> Error(Nil)
    in_class -> {
      // Output gets best-effort treatment: typed when we recognise the
      // shape, an empty singleton fallback when we don't. The fallback
      // lets us still emit the operation so its httpRequestTests cases
      // can be exercised; httpResponseTests deep-equality of typed
      // output unlocks once the relevant shape kinds (list, map,
      // structure, union, enum, timestamp, blob) are supported.
      let out_class = case classify(model, out_ref) {
        Unsupported -> Empty
        c -> c
      }
      Ok(emit_op(op_id, http, members_of(in_class), members_of(out_class)))
    }
  }
}

fn members_of(c: Classified) -> List(MemberSpec) {
  case c {
    Empty -> []
    PrimitiveBody(m) -> m
    Unsupported -> []
  }
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
              case all_primitive_no_http_binding(model, m) {
                False -> Unsupported
                True -> PrimitiveBody(members: extract_members(model, m))
              }
          }
        _ -> Unsupported
      }
  }
}

fn all_primitive_no_http_binding(
  model: Model,
  members: Dict(String, shape.Member),
) -> Bool {
  dict.fold(members, True, fn(acc, _name, member) {
    case acc {
      False -> False
      True ->
        case member_is_body_primitive(model, member) {
          True -> True
          False -> False
        }
    }
  })
}

fn member_is_body_primitive(model: Model, member: shape.Member) -> Bool {
  // Reject members carrying any of the rest-binding traits — those need
  // dedicated handling.
  let traits = member.traits
  let bound =
    dict.has_key(traits, ShapeId("smithy.api#httpLabel"))
    || dict.has_key(traits, ShapeId("smithy.api#httpQuery"))
    || dict.has_key(traits, ShapeId("smithy.api#httpHeader"))
    || dict.has_key(traits, ShapeId("smithy.api#httpPayload"))
    || dict.has_key(traits, ShapeId("smithy.api#httpPrefixHeaders"))
    || dict.has_key(traits, ShapeId("smithy.api#httpQueryParams"))
    || dict.has_key(traits, ShapeId("smithy.api#httpResponseCode"))
  case bound {
    True -> False
    False -> {
      let ShapeId(target) = member.target
      case types.resolve(model, target) {
        types.Resolved(..) -> True
        types.Unsupported(..) -> False
      }
    }
  }
}

fn extract_members(
  model: Model,
  members: Dict(String, shape.Member),
) -> List(MemberSpec) {
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
  http: HttpTrait,
  in_members: List(MemberSpec),
  out_members: List(MemberSpec),
) -> EmittedOp {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
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
  let build = emit_build(pascal, snake, http, in_members)
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
    [] -> "pub type " <> name <> " {\n  " <> name <> "\n}\n\n"
    _ ->
      "pub type "
      <> name
      <> " {\n  "
      <> name
      <> "(\n"
      <> list.fold(members, "", fn(acc, m) {
        acc
        <> "    "
        <> m.snake_name
        <> ": option.Option("
        <> types.gleam_type(m.primitive)
        <> "),\n"
      })
      <> "  )\n}\n\n"
  }
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
      <> "Input) -> String {\n  \"\"\n}\n\n"
    _ ->
      "pub fn encode_"
      <> snake
      <> "_input(input: "
      <> pascal
      <> "Input) -> String {\n  let pairs = []\n"
      <> list.fold(members, "", fn(acc, m) {
        acc
        <> "  let pairs = case input."
        <> m.snake_name
        <> " {\n    option.Some(v) -> [#(\""
        <> m.json_name
        <> "\", "
        <> types.json_encoder(m.primitive)
        <> "(v)), ..pairs]\n    option.None -> pairs\n  }\n"
      })
      <> "  json.to_string(json.object(pairs))\n}\n\n"
  }
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
      <> ", String) {\n  Ok("
      <> type_name
      <> ")\n}\n\n"
    _ ->
      "pub fn "
      <> fn_name
      <> "(body: String) -> Result("
      <> type_name
      <> ", String) {\n  let dec = {\n"
      <> list.fold(members, "", fn(acc, m) {
        acc
        <> "    use "
        <> m.snake_name
        <> " <- decode.optional_field(\""
        <> m.json_name
        <> "\", option.None, decode.optional("
        <> types.json_decoder(m.primitive)
        <> "))\n"
      })
      <> "    decode.success("
      <> type_name
      <> "(\n"
      <> list.fold(members, "", fn(acc, m) {
        acc <> "      " <> m.snake_name <> ": " <> m.snake_name <> ",\n"
      })
      <> "    ))\n  }\n  case json.parse(body, dec) {\n    Ok(v) -> Ok(v)\n    Error(_) -> Error(\"decode failed\")\n  }\n}\n\n"
  }
}

fn emit_build(
  pascal: String,
  snake: String,
  http: HttpTrait,
  members: List(MemberSpec),
) -> String {
  case members {
    [] ->
      "pub fn build_"
      <> snake
      <> "_request(\n  _input: "
      <> pascal
      <> "Input,\n) -> #(String, String, dict.Dict(String, String), BitArray) {\n  #(\""
      <> http.method
      <> "\", \""
      <> http.uri
      <> "\", dict.new(), <<>>)\n}\n\n"
    _ ->
      "pub fn build_"
      <> snake
      <> "_request(\n  input: "
      <> pascal
      <> "Input,\n) -> #(String, String, dict.Dict(String, String), BitArray) {\n  let body_str = encode_"
      <> snake
      <> "_input(input)\n  let headers = dict.from_list([#(\"Content-Type\", \"application/json\")])\n  #(\""
      <> http.method
      <> "\", \""
      <> http.uri
      <> "\", headers, bit_array.from_string(body_str))\n}\n\n"
  }
}

fn emit_parse(pascal: String, snake: String, members: List(MemberSpec)) -> String {
  case members {
    [] ->
      "pub fn parse_"
      <> snake
      <> "_response(\n  _code: Int,\n  _headers: dict.Dict(String, String),\n  _body: BitArray,\n) -> Result("
      <> pascal
      <> "Output, String) {\n  Ok("
      <> pascal
      <> "Output)\n}\n\n"
    _ ->
      "pub fn parse_"
      <> snake
      <> "_response(\n  _code: Int,\n  _headers: dict.Dict(String, String),\n  body: BitArray,\n) -> Result("
      <> pascal
      <> "Output, String) {\n  case bit_array.to_string(body) {\n    Ok(text) -> decode_"
      <> snake
      <> "_output(text)\n    Error(_) -> Error(\"non-utf8 body\")\n  }\n}\n\n"
  }
}

fn file_header(service_id: String) -> String {
  "//// Generated from "
  <> service_id
  <> " (restJson1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/internal/codec/json_float
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option
"
}

/// Operation-level traits we don't yet honour. Emitting code for an op
/// that requires one of these would produce wrong-on-the-wire output.
/// When the corresponding feature lands, drop the entry.
fn op_uses_unsupported_trait(traits: shape.Traits) -> Bool {
  dict.has_key(traits, ShapeId("smithy.api#httpChecksumRequired"))
  || dict.has_key(traits, ShapeId("aws.protocols#httpChecksum"))
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

fn string_field(d: Dict(ShapeId, Trait), name: String) -> option.Option(String) {
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
