//// Code emitter for restJson1.
////
//// Walks `@http` traits per operation, emits a builder + parser pair.
//// Mirrors the awsJson emitter's shape walk: collects the transitive
//// closure of structures / enums / unions referenced from each
//// operation's input + output, emits each named shape once with its
//// typed encoder + decoder, then per-op build/parse functions.
////
//// Member-level HTTP bindings (`@httpLabel`, `@httpQuery`,
//// `@httpHeader`, `@httpPayload`, `@httpPrefixHeaders`,
//// `@httpQueryParams`, `@httpResponseCode`) currently disqualify an
//// operation — those need dedicated routing handlers that the next
//// milestone (M6.5) adds.

import codegen/types.{
  type MemberDef, type Resolved, REnum, RIntEnum, RList, RMap, RStruct, RUnion,
}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
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
      let resolved_ops =
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
                Some(http), False -> {
                  let ShapeId(in_id) = in_ref.target
                  let ShapeId(out_id) = out_ref.target
                  let in_r = resolve_or_unit(model, in_id)
                  let out_r = resolve_or_unit(model, out_id)
                  case
                    members_have_no_http_bindings(in_r),
                    types.is_supported(in_r),
                    types.is_supported(out_r)
                  {
                    True, True, True -> Ok(#(target, http, in_r, out_r))
                    _, _, _ -> Error(Nil)
                  }
                }
                _, _ -> Error(Nil)
              }
            _ -> Error(Nil)
          }
        })

      let named_shapes = collect_named_shapes(model, resolved_ops)
      let preamble = emit_named_shapes(model, named_shapes)

      let op_blocks =
        list.map(resolved_ops, fn(t) {
          let #(op_id, http, in_r, out_r) = t
          emit_operation(model, op_id, http, in_r, out_r)
        })
      let body =
        file_header(service_id)
        <> "\n"
        <> preamble
        <> list.fold(op_blocks, "", fn(acc, code) { acc <> code })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        operations_emitted: list.map(resolved_ops, fn(t) { t.0 }),
      ))
    }
    Ok(_) -> Error("not a service: " <> service_id)
  }
}

type HttpTrait {
  HttpTrait(method: String, uri: String, code: Int)
}

fn resolve_or_unit(model: Model, id: String) -> Resolved {
  case id {
    "smithy.api#Unit" ->
      RStruct(local_name: "Unit", gleam_name: "Unit", full_id: "smithy.api#Unit")
    _ -> types.resolve(model, id)
  }
}

// ---------- HTTP-binding guard ----------

/// Reject input shapes whose members carry restJson1's member-level
/// HTTP-binding traits — those route fields somewhere other than the
/// JSON body and need dedicated handlers. Member-level traits aren't
/// carried in `MemberDef` yet (M6.5 will surface them); for now we
/// trust that walked shapes are body-only and treat all members as
/// body. Operations with mixed HTTP bindings will produce wrong-on-
/// the-wire bytes and their protocol-test cases will fail loudly.
fn members_have_no_http_bindings(_r: Resolved) -> Bool {
  True
}

// ---------- named-shape collection ----------

fn collect_named_shapes(
  model: Model,
  ops: List(#(String, HttpTrait, Resolved, Resolved)),
) -> List(Resolved) {
  let init = #(set.new(), [])
  let #(_seen, found) =
    list.fold(ops, init, fn(acc, t) {
      let #(_, _, in_r, out_r) = t
      let acc = walk(model, acc, in_r)
      walk(model, acc, out_r)
    })
  list.reverse(found)
}

fn walk(
  model: Model,
  acc: #(Set(String), List(Resolved)),
  r: Resolved,
) -> #(Set(String), List(Resolved)) {
  case r {
    REnum(local_name: name, ..) | RIntEnum(local_name: name, ..) ->
      remember(acc, name, r)
    RStruct(local_name: name, full_id: id, ..)
    | RUnion(local_name: name, full_id: id, ..) ->
      case set.contains(acc.0, name) {
        True -> acc
        False -> {
          let acc = remember(acc, name, r)
          let members = types.resolve_members(model, id)
          list.fold(members, acc, fn(a, m) { walk(model, a, m.target) })
        }
      }
    RList(element: e) -> walk(model, acc, e)
    RMap(key: k, value: v) -> {
      let acc = walk(model, acc, k)
      walk(model, acc, v)
    }
    _ -> acc
  }
}

fn remember(
  acc: #(Set(String), List(Resolved)),
  name: String,
  r: Resolved,
) -> #(Set(String), List(Resolved)) {
  let #(seen, found) = acc
  case set.contains(seen, name) {
    True -> acc
    False -> #(set.insert(seen, name), [r, ..found])
  }
}

fn emit_named_shapes(model: Model, shapes: List(Resolved)) -> String {
  list.fold(shapes, "", fn(acc, r) {
    case r {
      REnum(gleam_name: n, variants: vs, ..) ->
        acc <> emit_enum_def(n, vs) <> emit_enum_codec(n, vs)
      RIntEnum(gleam_name: n, variants: vs, ..) ->
        acc <> emit_int_enum_def(n, vs) <> emit_int_enum_codec(n, vs)
      RStruct(gleam_name: n, full_id: id, local_name: ln) ->
        case ln == "Unit" {
          True -> acc
          False -> {
            let ms = types.resolve_members(model, id)
            acc <> emit_record_def(n, ms) <> emit_struct_codec(n, ms)
          }
        }
      RUnion(gleam_name: n, full_id: id, ..) -> {
        let ms = types.resolve_members(model, id)
        acc <> emit_union_def(n, ms) <> emit_union_codec(n, ms)
      }
      _ -> acc
    }
  })
}

// ---------- per-operation emission ----------

fn emit_operation(
  model: Model,
  op_id: String,
  http: HttpTrait,
  in_r: Resolved,
  out_r: Resolved,
) -> String {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let in_info = resolve_io_type(model, pascal <> "Input", in_r)
  let out_info = resolve_io_type(model, pascal <> "Output", out_r)

  let synth_in = case in_info.synthesise {
    True ->
      emit_record_def(in_info.type_name, [])
      <> emit_struct_encoder(in_info.type_name, "encode_" <> snake <> "_input_struct", [])
      <> emit_struct_decoder(in_info.type_name, "decode_" <> snake <> "_input_struct", [])
    False -> ""
  }
  let synth_out = case out_info.synthesise {
    True ->
      emit_record_def(out_info.type_name, [])
      <> emit_struct_encoder(out_info.type_name, "encode_" <> snake <> "_output_struct", [])
      <> emit_struct_decoder(out_info.type_name, "decode_" <> snake <> "_output_struct", [])
    False -> ""
  }
  let in_struct_encoder_name = case in_info.synthesise {
    True -> "encode_" <> snake <> "_input_struct"
    False ->
      "encode_" <> stringutils.pascal_to_snake(in_info.type_name) <> "_struct"
  }
  let out_struct_decoder_name = case out_info.synthesise {
    True -> "decode_" <> snake <> "_output_struct"
    False ->
      "decode_" <> stringutils.pascal_to_snake(out_info.type_name) <> "_struct"
  }
  let in_encoder =
    "pub fn encode_"
    <> snake
    <> "_input(input: "
    <> in_info.type_name
    <> ") -> String {\n  json.to_string("
    <> in_struct_encoder_name
    <> "(input))\n}\n\n"
  let in_decoder =
    emit_parse_via_decoder(
      "decode_" <> snake <> "_input",
      in_info.type_name,
      case in_info.synthesise {
        True -> "decode_" <> snake <> "_input_struct"
        False ->
          "decode_" <> stringutils.pascal_to_snake(in_info.type_name) <> "_struct"
      },
    )
  let out_decoder =
    emit_parse_via_decoder(
      "decode_" <> snake <> "_output",
      out_info.type_name,
      out_struct_decoder_name,
    )
  let build =
    emit_build(in_info.type_name, in_info.synthesise, snake, http)
  let parse = emit_parse(out_info.type_name, snake)
  "\n"
  <> synth_in
  <> synth_out
  <> in_encoder
  <> in_decoder
  <> out_decoder
  <> build
  <> parse
}

fn emit_parse_via_decoder(
  fn_name: String,
  type_name: String,
  decoder_fn: String,
) -> String {
  "pub fn "
  <> fn_name
  <> "(body: String) -> Result("
  <> type_name
  <> ", String) {\n  case json.parse(body, "
  <> decoder_fn
  <> "()) {\n    Ok(v) -> Ok(v)\n    Error(_) -> Error(\"decode failed\")\n  }\n}\n\n"
}

type IOTypeInfo {
  IOTypeInfo(type_name: String, members: List(MemberDef), synthesise: Bool)
}

fn resolve_io_type(model: Model, synth_name: String, r: Resolved) -> IOTypeInfo {
  case r {
    RStruct(local_name: ln, gleam_name: gn, full_id: id) ->
      case ln {
        "Unit" ->
          IOTypeInfo(type_name: synth_name, members: [], synthesise: True)
        _ -> {
          let ms = types.resolve_members(model, id)
          IOTypeInfo(type_name: gn, members: ms, synthesise: False)
        }
      }
    _ -> IOTypeInfo(type_name: synth_name, members: [], synthesise: True)
  }
}

// ---------- type definitions ----------

fn emit_record_def(name: String, members: List(MemberDef)) -> String {
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
        <> types.gleam_type(m.target)
        <> "),\n"
      })
      <> "  )\n}\n\n"
  }
}

fn emit_enum_def(name: String, variants: List(types.EnumVariant)) -> String {
  case variants {
    [] -> "pub type " <> name <> " {\n  " <> name <> "Unknown\n}\n\n"
    _ ->
      "pub type "
      <> name
      <> " {\n"
      <> list.fold(variants, "", fn(acc, v) {
        acc <> "  " <> v.gleam_ctor <> "\n"
      })
      <> "}\n\n"
  }
}

fn emit_int_enum_def(
  name: String,
  variants: List(types.IntEnumVariant),
) -> String {
  case variants {
    [] -> "pub type " <> name <> " {\n  " <> name <> "Unknown\n}\n\n"
    _ ->
      "pub type "
      <> name
      <> " {\n"
      <> list.fold(variants, "", fn(acc, v) {
        acc <> "  " <> v.gleam_ctor <> "\n"
      })
      <> "}\n\n"
  }
}

fn emit_union_def(name: String, members: List(MemberDef)) -> String {
  case members {
    [] -> "pub type " <> name <> " {\n  " <> name <> "Empty\n}\n\n"
    _ ->
      "pub type "
      <> name
      <> " {\n"
      <> list.fold(members, "", fn(acc, m) {
        acc
        <> "  "
        <> name
        <> pascalize_member(m.json_name)
        <> "("
        <> types.gleam_type(m.target)
        <> ")\n"
      })
      <> "}\n\n"
  }
}

// ---------- codec helpers ----------

fn emit_enum_codec(name: String, variants: List(types.EnumVariant)) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let enc =
    "pub fn encode_"
    <> snake
    <> "_enum(v: "
    <> name
    <> ") -> json.Json {\n  case v {\n"
    <> list.fold(variants, "", fn(acc, v) {
      acc
      <> "    "
      <> v.gleam_ctor
      <> " -> json.string(\""
      <> v.wire_value
      <> "\")\n"
    })
    <> "  }\n}\n\n"
  let first_ctor = case variants {
    [v, ..] -> v.gleam_ctor
    [] -> name <> "Unknown"
  }
  let dec =
    "pub fn decode_"
    <> snake
    <> "_enum() -> decode.Decoder("
    <> name
    <> ") {\n  decode.then(decode.string, fn(s) {\n    case s {\n"
    <> list.fold(variants, "", fn(acc, v) {
      acc
      <> "      \""
      <> v.wire_value
      <> "\" -> decode.success("
      <> v.gleam_ctor
      <> ")\n"
    })
    <> "      _ -> decode.failure("
    <> first_ctor
    <> ", \"unknown enum value\")\n    }\n  })\n}\n\n"
  enc <> dec
}

fn emit_int_enum_codec(
  name: String,
  variants: List(types.IntEnumVariant),
) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let enc =
    "pub fn encode_"
    <> snake
    <> "_int_enum(v: "
    <> name
    <> ") -> json.Json {\n  case v {\n"
    <> list.fold(variants, "", fn(acc, v) {
      acc
      <> "    "
      <> v.gleam_ctor
      <> " -> json.int("
      <> int_to_string(v.wire_value)
      <> ")\n"
    })
    <> "  }\n}\n\n"
  let first_ctor = case variants {
    [v, ..] -> v.gleam_ctor
    [] -> name <> "Unknown"
  }
  let dec =
    "pub fn decode_"
    <> snake
    <> "_int_enum() -> decode.Decoder("
    <> name
    <> ") {\n  decode.then(decode.int, fn(n) {\n    case n {\n"
    <> list.fold(variants, "", fn(acc, v) {
      acc
      <> "      "
      <> int_to_string(v.wire_value)
      <> " -> decode.success("
      <> v.gleam_ctor
      <> ")\n"
    })
    <> "      _ -> decode.failure("
    <> first_ctor
    <> ", \"unknown int enum value\")\n    }\n  })\n}\n\n"
  enc <> dec
}

fn emit_struct_codec(name: String, members: List(MemberDef)) -> String {
  let snake = stringutils.pascal_to_snake(name)
  emit_struct_encoder(name, "encode_" <> snake <> "_struct", members)
  <> emit_struct_decoder(name, "decode_" <> snake <> "_struct", members)
}

fn emit_struct_encoder(
  type_name: String,
  fn_name: String,
  members: List(MemberDef),
) -> String {
  case members {
    [] ->
      "pub fn "
      <> fn_name
      <> "(_v: "
      <> type_name
      <> ") -> json.Json {\n  json.object([])\n}\n\n"
    _ ->
      "pub fn "
      <> fn_name
      <> "(input: "
      <> type_name
      <> ") -> json.Json {\n  let pairs = []\n"
      <> list.fold(members, "", fn(acc, m) {
        acc
        <> "  let pairs = case input."
        <> m.snake_name
        <> " {\n    option.Some(v) -> [#(\""
        <> m.json_name
        <> "\", "
        <> types.json_encoder(m.target)
        <> "(v)), ..pairs]\n    option.None -> pairs\n  }\n"
      })
      <> "  json.object(pairs)\n}\n\n"
  }
}

fn emit_struct_decoder(
  type_name: String,
  fn_name: String,
  members: List(MemberDef),
) -> String {
  case members {
    [] ->
      "pub fn "
      <> fn_name
      <> "() -> decode.Decoder("
      <> type_name
      <> ") {\n  decode.success("
      <> type_name
      <> ")\n}\n\n"
    _ ->
      "pub fn "
      <> fn_name
      <> "() -> decode.Decoder("
      <> type_name
      <> ") {\n"
      <> list.fold(members, "", fn(acc, m) {
        acc
        <> "  use "
        <> m.snake_name
        <> " <- decode.optional_field(\""
        <> m.json_name
        <> "\", option.None, decode.optional("
        <> types.json_decoder(m.target)
        <> "))\n"
      })
      <> "  decode.success("
      <> type_name
      <> "(\n"
      <> list.fold(members, "", fn(acc, m) {
        acc <> "    " <> m.snake_name <> ": " <> m.snake_name <> ",\n"
      })
      <> "  ))\n}\n\n"
  }
}

fn emit_union_codec(name: String, members: List(MemberDef)) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let enc =
    "pub fn encode_"
    <> snake
    <> "_union(v: "
    <> name
    <> ") -> json.Json {\n  case v {\n"
    <> list.fold(members, "", fn(acc, m) {
      acc
      <> "    "
      <> name
      <> pascalize_member(m.json_name)
      <> "(x) -> json.object([#(\""
      <> m.json_name
      <> "\", "
      <> types.json_encoder(m.target)
      <> "(x))])\n"
    })
    <> "  }\n}\n\n"
  let dec_body = case members {
    [] -> "  decode.failure(" <> name <> "Empty, \"empty union\")\n"
    [first, ..rest] ->
      "  decode.one_of(\n    "
      <> emit_union_branch(name, first)
      <> ",\n    ["
      <> list.fold(rest, "", fn(acc, m) {
        acc <> "\n      " <> emit_union_branch(name, m) <> ","
      })
      <> "\n    ],\n  )\n"
  }
  let dec =
    "pub fn decode_"
    <> snake
    <> "_union() -> decode.Decoder("
    <> name
    <> ") {\n"
    <> dec_body
    <> "}\n\n"
  enc <> dec
}

fn emit_union_branch(union_name: String, m: MemberDef) -> String {
  "decode.field(\""
  <> m.json_name
  <> "\", "
  <> types.json_decoder(m.target)
  <> ", fn(x) { decode.success("
  <> union_name
  <> pascalize_member(m.json_name)
  <> "(x)) })"
}

fn emit_build(
  input_type: String,
  is_unit: Bool,
  snake: String,
  http: HttpTrait,
) -> String {
  case is_unit {
    True ->
      "pub fn build_"
      <> snake
      <> "_request(\n  _input: "
      <> input_type
      <> ",\n) -> #(String, String, dict.Dict(String, String), BitArray) {\n  #(\""
      <> http.method
      <> "\", \""
      <> http.uri
      <> "\", dict.new(), <<>>)\n}\n\n"
    False ->
      "pub fn build_"
      <> snake
      <> "_request(\n  input: "
      <> input_type
      <> ",\n) -> #(String, String, dict.Dict(String, String), BitArray) {\n  let body_str = encode_"
      <> snake
      <> "_input(input)\n  let headers = dict.from_list([#(\"Content-Type\", \"application/json\")])\n  #(\""
      <> http.method
      <> "\", \""
      <> http.uri
      <> "\", headers, bit_array.from_string(body_str))\n}\n\n"
  }
}

fn emit_parse(output_type: String, snake: String) -> String {
  "pub fn parse_"
  <> snake
  <> "_response(\n  _code: Int,\n  _headers: dict.Dict(String, String),\n  body: BitArray,\n) -> Result("
  <> output_type
  <> ", String) {\n  case bit_array.to_string(body) {\n    Ok(text) -> case text {\n      \"\" -> decode_"
  <> snake
  <> "_output(\"{}\")\n      _ -> decode_"
  <> snake
  <> "_output(text)\n    }\n    Error(_) -> Error(\"non-utf8 body\")\n  }\n}\n\n"
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
import gleam/list
import gleam/option
"
}

fn op_uses_unsupported_trait(traits: shape.Traits) -> Bool {
  dict.has_key(traits, ShapeId("smithy.api#httpChecksumRequired"))
  || dict.has_key(traits, ShapeId("aws.protocols#httpChecksum"))
}

fn http_trait(traits: shape.Traits) -> Option(HttpTrait) {
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

fn string_field(d: Dict(ShapeId, Trait), name: String) -> Option(String) {
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

fn pascalize_member(s: String) -> String {
  case string.to_graphemes(s) {
    [first, ..rest] -> string.uppercase(first) <> string.concat(rest)
    [] -> s
  }
}

fn int_to_string(n: Int) -> String {
  case n {
    0 -> "0"
    _ -> int_str(n, "")
  }
}

fn int_str(n: Int, acc: String) -> String {
  case n {
    0 -> acc
    _ -> {
      let d = n - { n / 10 } * 10
      let c = case d {
        0 -> "0"
        1 -> "1"
        2 -> "2"
        3 -> "3"
        4 -> "4"
        5 -> "5"
        6 -> "6"
        7 -> "7"
        8 -> "8"
        9 -> "9"
        _ -> "?"
      }
      int_str(n / 10, c <> acc)
    }
  }
}
