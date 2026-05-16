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
  type MemberDef, type Resolved, Body, Header, Label, Payload, PrefixHeaders,
  Query, QueryParams, RDocument, REnum, RIntEnum, RList, RMap, RPrim, RStruct,
  RTimestamp, RUnion,
}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
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
    Ok(shape.Service(operations: refs, traits: svc_traits, ..)) -> {
      let service_local = strip_namespace(service_id)
      let metadata = service_metadata(svc_traits, service_local)
      let resolved_ops =
        list.filter_map(refs, fn(ref) {
          let ShapeId(target) = ref.target
          case model.lookup(model, target) {
            Ok(shape.Operation(
              input: in_ref,
              output: out_ref,
              errors: errs,
              traits: op_traits,
            )) ->
              case http_trait(op_traits), op_uses_unsupported_trait(op_traits) {
                Some(http), False -> {
                  let ShapeId(in_id) = in_ref.target
                  let ShapeId(out_id) = out_ref.target
                  let in_r = resolve_or_unit(model, in_id)
                  let out_r = resolve_or_unit(model, out_id)
                  let err_ids =
                    list.map(errs, fn(r) {
                      let ShapeId(t) = r.target
                      t
                    })
                  case
                    members_have_no_http_bindings(in_r),
                    types.is_supported(in_r),
                    types.is_supported(out_r)
                  {
                    True, True, True ->
                      Ok(#(target, http, in_r, out_r, err_ids))
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

      let op_specs =
        list.map(resolved_ops, fn(t) {
          let #(op_id, _, in_r, out_r, err_ids) = t
          let local = strip_namespace(op_id)
          let snake = stringutils.pascal_to_snake(local)
          let in_info = resolve_io_type(model, local <> "Input", in_r)
          let out_info = resolve_io_type(model, local <> "Output", out_r)
          OpSpec(
            op_id: op_id,
            local: local,
            snake: snake,
            in_info: in_info,
            out_info: out_info,
            error_ids: err_ids,
          )
        })

      let op_blocks =
        list.map(resolved_ops, fn(t) {
          let #(op_id, http, in_r, out_r, _) = t
          emit_operation(model, op_id, http, in_r, out_r)
        })
      let client_block = emit_client(metadata)
      let invoke_blocks = list.map(op_specs, emit_invoke)
      let error_blocks =
        list.map(op_specs, fn(spec) {
          emit_error_type(spec) <> emit_error_translator(spec)
        })
      let body =
        file_header(service_id)
        <> "\n"
        <> client_block
        <> preamble
        <> list.fold(op_blocks, "", fn(acc, code) { acc <> code })
        <> list.fold(error_blocks, "", fn(acc, code) { acc <> code })
        <> list.fold(invoke_blocks, "", fn(acc, code) { acc <> code })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        operations_emitted: list.map(resolved_ops, fn(t) {
          let #(op_id, _, _, _, _) = t
          op_id
        }),
      ))
    }
    Ok(_) -> Error("not a service: " <> service_id)
  }
}

type Metadata {
  Metadata(service_local: String, endpoint_prefix: String, signing_name: String)
}

type OpSpec {
  OpSpec(
    op_id: String,
    local: String,
    snake: String,
    in_info: IOTypeInfo,
    out_info: IOTypeInfo,
    error_ids: List(String),
  )
}

fn service_metadata(traits: shape.Traits, service_local: String) -> Metadata {
  let endpoint_prefix =
    string_field_under(traits, "aws.api#service", "endpointPrefix")
    |> result.unwrap(string.lowercase(service_local))
  let signing_name =
    string_field_under(traits, "aws.auth#sigv4", "name")
    |> result.unwrap(endpoint_prefix)
  Metadata(
    service_local: service_local,
    endpoint_prefix: endpoint_prefix,
    signing_name: signing_name,
  )
}

fn string_field_under(
  traits: shape.Traits,
  trait_id: String,
  field: String,
) -> Result(String, Nil) {
  case dict.get(traits, ShapeId(trait_id)) {
    Ok(Some(trait.Dict(d))) ->
      case dict.get(d, ShapeId(field)) {
        Ok(trait.String(s)) -> Ok(s)
        _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

fn emit_client(metadata: Metadata) -> String {
  "pub opaque type Client {
  Client(config: awsjson_client.ClientConfig)
}

pub fn new(
  provider provider: credentials.Provider,
  region region: String,
) -> Client {
  Client(config: awsjson_client.default_config(
    provider,
    region,
    \"" <> metadata.endpoint_prefix <> "\",
    \"" <> metadata.signing_name <> "\",
  ))
}

pub fn with_endpoint_url(client: Client, url: String) -> Client {
  Client(config: awsjson_client.with_endpoint_url(client.config, url))
}

pub fn with_http_send(client: Client, send: http_send.Send) -> Client {
  Client(config: awsjson_client.with_http_send(client.config, send))
}

"
}

fn emit_invoke(spec: OpSpec) -> String {
  "pub fn "
  <> spec.snake
  <> "(client: Client, input: "
  <> spec.in_info.type_name
  <> ") -> Result("
  <> spec.out_info.type_name
  <> ", "
  <> spec.local
  <> "Error) {
  case awsjson_client.invoke(client.config, build_"
  <> spec.snake
  <> "_request(input), parse_"
  <> spec.snake
  <> "_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_"
  <> spec.snake
  <> "_error(err))
  }
}

"
}

/// Per-op typed-error enum. One variant per error shape on the
/// operation, plus `Transport` and `Unknown` fall-backs. Mirrors the
/// awsjson emitter — restJson1 errors are still JSON-shaped on the
/// wire, so the same decoder path works.
fn emit_error_type(spec: OpSpec) -> String {
  let name = spec.local <> "Error"
  let variants =
    list.fold(spec.error_ids, "", fn(acc, err_id) {
      let local = strip_namespace(err_id)
      acc <> "  " <> name <> local <> "(value: " <> local <> ")\n"
    })
  "pub type "
  <> name
  <> " {\n"
  <> variants
  <> "  "
  <> name
  <> "Transport(reason: String)\n  "
  <> name
  <> "Unknown(error_type: String, status: Int, body: String)\n}\n\n"
}

fn emit_error_translator(spec: OpSpec) -> String {
  let name = spec.local <> "Error"
  let snake = spec.snake
  let matches =
    list.fold(spec.error_ids, "", fn(acc, err_id) {
      let local = strip_namespace(err_id)
      let err_snake = stringutils.pascal_to_snake(local)
      acc
      <> "        case awsjson_client.error_type_matches(et, \""
      <> local
      <> "\") {\n          True -> case bit_array.to_string(b) {\n            Ok(text) -> case json.parse(text, decode_"
      <> err_snake
      <> "_struct()) {\n              Ok(v) -> "
      <> name
      <> local
      <> "(value: v)\n              Error(_) -> "
      <> name
      <> "Unknown(error_type: et, status: s, body: text)\n            }\n            Error(_) -> "
      <> name
      <> "Unknown(error_type: et, status: s, body: \"\")\n          }\n          False -> "
    })
  let fallback =
    "case bit_array.to_string(b) {\n          Ok(text) -> "
    <> name
    <> "Unknown(error_type: et, status: s, body: text)\n          Error(_) -> "
    <> name
    <> "Unknown(error_type: et, status: s, body: \"\")\n        }"
  let chain_end =
    list.fold(spec.error_ids, "", fn(acc, _) { acc <> "\n        }" })
  "fn translate_"
  <> snake
  <> "_error(err: awsjson_client.ClientError) -> "
  <> name
  <> " {\n  case err {\n    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {\n"
  <> matches
  <> fallback
  <> chain_end
  <> "\n    }\n    awsjson_client.TransportError(_) -> "
  <> name
  <> "Transport(reason: \"transport error\")\n    awsjson_client.CredentialsError(_) -> "
  <> name
  <> "Transport(reason: \"credentials error\")\n    awsjson_client.DecodeError(reason: r) -> "
  <> name
  <> "Transport(reason: \"decode: \" <> r)\n  }\n}\n\n"
}

type HttpTrait {
  HttpTrait(method: String, uri: String, code: Int)
}

fn resolve_or_unit(model: Model, id: String) -> Resolved {
  case id {
    "smithy.api#Unit" ->
      RStruct(
        local_name: "Unit",
        gleam_name: "Unit",
        full_id: "smithy.api#Unit",
      )
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
  ops: List(#(String, HttpTrait, Resolved, Resolved, List(String))),
) -> List(Resolved) {
  let init = #(set.new(), [])
  let #(_seen, found) =
    list.fold(ops, init, fn(acc, t) {
      let #(_, _, in_r, out_r, err_ids) = t
      let acc = walk(model, acc, in_r)
      let acc = walk(model, acc, out_r)
      list.fold(err_ids, acc, fn(a, err_id) {
        walk(model, a, types.resolve(model, err_id))
      })
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
    RList(element: e, ..) -> walk(model, acc, e)
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
      <> emit_struct_encoder(
        in_info.type_name,
        "encode_" <> snake <> "_input_struct",
        [],
      )
      <> emit_struct_decoder(
        in_info.type_name,
        "decode_" <> snake <> "_input_struct",
        [],
      )
    False -> ""
  }
  let synth_out = case out_info.synthesise {
    True ->
      emit_record_def(out_info.type_name, [])
      <> emit_struct_encoder(
        out_info.type_name,
        "encode_" <> snake <> "_output_struct",
        [],
      )
      <> emit_struct_decoder(
        out_info.type_name,
        "decode_" <> snake <> "_output_struct",
        [],
      )
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
  // `decode_<op>_input` is the entry point used by the Smithy
  // protocol-test dispatchers — Smithy's `params` is keyed by member
  // name, not wire name (`@jsonName`). Use the member-keyed parallel
  // decoder so dispatcher params round-trip into typed structs.
  let in_decoder =
    emit_parse_via_decoder(
      "decode_" <> snake <> "_input",
      in_info.type_name,
      case in_info.synthesise {
        True -> "decode_" <> snake <> "_input_struct"
        False ->
          "decode_"
          <> stringutils.pascal_to_snake(in_info.type_name)
          <> "_struct_params"
      },
    )
  let out_decoder =
    emit_parse_via_decoder(
      "decode_" <> snake <> "_output",
      out_info.type_name,
      out_struct_decoder_name,
    )
  let in_members = in_info.members
  let body_members =
    list.filter(in_members, fn(m) {
      case m.binding {
        Body -> True
        _ -> False
      }
    })
  let body_encoder = emit_body_encoder(snake, in_info.type_name, body_members)
  let build =
    emit_build(in_info.type_name, in_info.synthesise, snake, http, in_members)
  let parse = emit_parse(out_info, snake)
  "\n"
  <> synth_in
  <> synth_out
  <> in_encoder
  <> in_decoder
  <> out_decoder
  <> body_encoder
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

fn resolve_io_type(
  model: Model,
  synth_name: String,
  r: Resolved,
) -> IOTypeInfo {
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
        <> pascalize_member(m.member_name)
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
  <> emit_struct_decoder_params(
    name,
    "decode_" <> snake <> "_struct_params",
    members,
  )
}

/// Member-name-keyed decoder used by the protocol-test dispatchers
/// (Smithy's `params` field is keyed by Smithy member name, not wire
/// name). Identical to `decode_<snake>_struct` apart from the JSON key
/// lookup. We always emit both; production code never calls the
/// `_params` variant on the response side.
fn emit_struct_decoder_params(
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
        <> m.member_name
        <> "\", option.None, decode.optional("
        <> types.json_decoder_params(m.target)
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
      <> pascalize_member(m.member_name)
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
  <> pascalize_member(m.member_name)
  <> "(x)) })"
}

/// Emit the per-op `build_<op>_request`. Partitions members by HTTP
/// binding and emits routing for each:
///
///   * `@httpLabel` members are substituted into the URI template.
///   * `@httpQuery` / `@httpQueryParams` build the query string.
///   * `@httpHeader` / `@httpPrefixHeaders` populate headers.
///   * `@httpPayload`, if present, IS the body (no JSON wrapper).
///   * Otherwise, remaining `Body`-bound members go into a JSON object
///     body via the per-op `encode_<op>_body` helper.
fn emit_build(
  input_type: String,
  is_unit: Bool,
  snake: String,
  http: HttpTrait,
  members: List(MemberDef),
) -> String {
  let payload =
    list.find(members, fn(m) {
      case m.binding {
        Payload -> True
        _ -> False
      }
    })
  let labels =
    list.filter(members, fn(m) {
      case m.binding {
        Label -> True
        _ -> False
      }
    })
  let queries =
    list.filter(members, fn(m) {
      case m.binding {
        Query(_) -> True
        _ -> False
      }
    })
  let query_maps =
    list.filter(members, fn(m) {
      case m.binding {
        QueryParams -> True
        _ -> False
      }
    })
  let headers =
    list.filter(members, fn(m) {
      case m.binding {
        Header(_) -> True
        _ -> False
      }
    })
  let prefix_headers =
    list.filter(members, fn(m) {
      case m.binding {
        PrefixHeaders(_) -> True
        _ -> False
      }
    })
  let body_members =
    list.filter(members, fn(m) {
      case m.binding {
        Body -> True
        _ -> False
      }
    })

  let header_or_input = case is_unit {
    True -> "_input"
    False -> "input"
  }

  let path_setup = emit_path_setup(http.uri, labels)
  let query_setup = emit_query_setup(queries, query_maps)
  let header_setup = emit_header_setup(headers, prefix_headers)
  let body_setup = case payload {
    Ok(p) -> emit_payload_body(p)
    Error(_) ->
      case body_members {
        [] -> "  let body = <<>>\n  let content_type = \"\"\n"
        _ ->
          "  let body_json = encode_"
          <> snake
          <> "_body(input)\n  let body = bit_array.from_string(json.to_string(body_json))\n  let content_type = \"application/json\"\n"
      }
  }

  "pub fn build_"
  <> snake
  <> "_request(\n  "
  <> header_or_input
  <> ": "
  <> input_type
  <> ",\n) -> #(String, String, dict.Dict(String, String), BitArray) {\n"
  <> path_setup
  <> query_setup
  <> header_setup
  <> body_setup
  <> "  let headers = case content_type {\n    \"\" -> headers\n    _ -> dict.insert(headers, \"Content-Type\", content_type)\n  }\n  let headers = case content_type {\n    \"\" -> headers\n    _ -> dict.insert(headers, \"Content-Length\", int.to_string(bit_array.byte_size(body)))\n  }\n  let path = rest.build_path(path, query)\n  #(\""
  <> http.method
  <> "\", path, headers, body)\n}\n\n"
}

fn emit_path_setup(uri_template: String, labels: List(MemberDef)) -> String {
  let initial = "  let path = \"" <> uri_template <> "\"\n"
  list.fold(labels, initial, fn(acc, m) {
    let greedy = string.contains(uri_template, "{" <> m.json_name <> "+}")
    let greedy_str = case greedy {
      True -> "True"
      False -> "False"
    }
    acc
    <> "  let path = case input."
    <> m.snake_name
    <> " {\n    option.Some(v) -> rest.substitute_label(path, \""
    <> m.json_name
    <> "\", "
    <> value_to_string(m.target)
    <> ", "
    <> greedy_str
    <> ")\n    option.None -> path\n  }\n"
  })
}

fn emit_query_setup(
  queries: List(MemberDef),
  query_maps: List(MemberDef),
) -> String {
  let initial = "  let query = \"\"\n"
  let with_queries =
    list.fold(queries, initial, fn(acc, m) {
      let query_name = case m.binding {
        Query(query_name: n) -> n
        _ -> m.json_name
      }
      case m.target {
        RList(element: e, ..) ->
          // `@httpQuery` on a list emits `Name=v1&Name=v2&...`. The
          // element-to-string conversion is the same as the scalar
          // case — reuse `value_to_string` by rebinding `v` to each
          // entry inside the fold.
          acc
          <> "  let query = case input."
          <> m.snake_name
          <> " {\n    option.Some(xs) -> list.fold(xs, query, fn(q, item) {\n      let v = item\n      rest.add_query(q, \""
          <> query_name
          <> "\", "
          <> value_to_string(e)
          <> ")\n    })\n    option.None -> query\n  }\n"
        _ ->
          acc
          <> "  let query = case input."
          <> m.snake_name
          <> " {\n    option.Some(v) -> rest.add_query(query, \""
          <> query_name
          <> "\", "
          <> value_to_string(m.target)
          <> ")\n    option.None -> query\n  }\n"
      }
    })
  list.fold(query_maps, with_queries, fn(acc, m) {
    // Dispatch on the map's value type: Map<String, String> uses
    // `add_query_params`, Map<String, List<String>> uses
    // `add_query_params_list`. Anything else: skip.
    let helper = case m.target {
      RMap(key: _, value: RList(element: RPrim(primitive: types.PString), ..)) ->
        Ok("rest.add_query_params_list")
      RMap(key: _, value: RPrim(primitive: types.PString)) ->
        Ok("rest.add_query_params")
      _ -> Error(Nil)
    }
    case helper {
      Ok(fn_name) ->
        acc
        <> "  let query = case input."
        <> m.snake_name
        <> " {\n    option.Some(m) -> "
        <> fn_name
        <> "(query, m)\n    option.None -> query\n  }\n"
      Error(_) -> acc
    }
  })
}

fn emit_header_setup(
  headers: List(MemberDef),
  prefix_headers: List(MemberDef),
) -> String {
  let initial = "  let headers = dict.new()\n"
  let with_headers =
    list.fold(headers, initial, fn(acc, m) {
      let header_name = case m.binding {
        Header(header_name: n) -> n
        _ -> m.json_name
      }
      case m.target {
        RList(element: e, ..) ->
          // `@httpHeader` on a list emits `Name: v1, v2, v3` per the
          // HTTP/1.1 header-folding rule. Each entry is rendered by
          // the same scalar `value_to_string`; we collect them with
          // `list.map` and hand to `maybe_set_list_header`.
          acc
          <> "  let headers = case input."
          <> m.snake_name
          <> " {\n    option.Some(xs) -> rest.maybe_set_list_header(headers, \""
          <> header_name
          <> "\", list.map(xs, fn(item) { let v = item "
          <> value_to_string(e)
          <> " }))\n    option.None -> headers\n  }\n"
        _ ->
          acc
          <> "  let headers = case input."
          <> m.snake_name
          <> " {\n    option.Some(v) -> rest.maybe_set_header(headers, \""
          <> header_name
          <> "\", "
          <> value_to_string(m.target)
          <> ")\n    option.None -> headers\n  }\n"
      }
    })
  list.fold(prefix_headers, with_headers, fn(acc, m) {
    let prefix = case m.binding {
      PrefixHeaders(prefix: p) -> p
      _ -> ""
    }
    acc
    <> "  let headers = case input."
    <> m.snake_name
    <> " {\n    option.Some(m) -> rest.add_prefix_headers(headers, \""
    <> prefix
    <> "\", m)\n    option.None -> headers\n  }\n"
  })
}

fn emit_payload_body(m: MemberDef) -> String {
  // @httpPayload — the member's value IS the body. For blob members
  // the body is the raw bytes; for struct/string members it's the
  // JSON-encoded value; for primitive strings, the raw string.
  case m.target {
    types.RBlob ->
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> v\n    option.None -> <<>>\n  }\n  let content_type = \"application/octet-stream\"\n"
    RPrim(primitive: types.PString) ->
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(v)\n    option.None -> <<>>\n  }\n  let content_type = \"text/plain\"\n"
    _ ->
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(json.to_string("
      <> types.json_encoder(m.target)
      <> "(v)))\n    option.None -> <<>>\n  }\n  let content_type = \"application/json\"\n"
  }
}

/// Render a Resolved value as a Gleam expression that produces a
/// String — used in label / query / header position where everything
/// is stringified.
fn value_to_string(target: Resolved) -> String {
  case target {
    RPrim(primitive: types.PString) -> "v"
    RPrim(primitive: types.PInt) -> "rest.int_to_query(v)"
    RPrim(primitive: types.PFloat) ->
      "case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }"
    RPrim(primitive: types.PBool) -> "rest.bool_to_query(v)"
    // Enum: encode to json.string, then strip the surrounding quotes
    // off. Cheaper than emitting a per-variant case (which would need
    // the variant list at this site).
    REnum(local_name: _, ..) ->
      "rest.enum_wire_value(" <> types.json_encoder(target) <> "(v))"
    RIntEnum(local_name: _, ..) ->
      "rest.int_to_query(case "
      <> types.json_encoder(target)
      <> "(v) { _ -> 0 })"
    RTimestamp -> "rest.timestamp_to_header(v)"
    _ -> "\"\""
  }
}

/// Emit a per-op body encoder that ONLY includes Body-bound members.
/// Generated as a separate function so the operation's URI/query/
/// header members don't double-encode into the JSON body.
fn emit_body_encoder(
  snake: String,
  input_type: String,
  body_members: List(MemberDef),
) -> String {
  case body_members {
    [] ->
      "pub fn encode_"
      <> snake
      <> "_body(_input: "
      <> input_type
      <> ") -> json.Json {\n  json.object([])\n}\n\n"
    _ ->
      "pub fn encode_"
      <> snake
      <> "_body(input: "
      <> input_type
      <> ") -> json.Json {\n  let pairs = []\n"
      <> list.fold(body_members, "", fn(acc, m) {
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

/// Emit the per-op `parse_<op>_response`. For outputs whose Smithy
/// members are body-bound (default), parse the body as JSON and run
/// the struct decoder. If the output declares an `@httpPayload` member,
/// the body IS that member's value:
///   - `blob`   → raw bytes go straight into the field;
///   - `string` → body UTF-8-decoded straight into the field;
///   - `struct` → JSON-parse the body and wrap it in the output struct;
///   - `document` → wrap the parsed JSON as a `json.Json`.
fn emit_parse(out_info: IOTypeInfo, snake: String) -> String {
  let output_type = out_info.type_name
  let payload =
    list.find(out_info.members, fn(m) {
      case m.binding {
        Payload -> True
        _ -> False
      }
    })
  case payload, out_info.synthesise {
    _, True ->
      "pub fn parse_"
      <> snake
      <> "_response(\n  _code: Int,\n  _headers: dict.Dict(String, String),\n  _body: BitArray,\n) -> Result("
      <> output_type
      <> ", String) {\n  Ok("
      <> output_type
      <> ")\n}\n\n"
    Ok(p), False -> emit_parse_with_payload(out_info, snake, p)
    Error(_), False ->
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
}

/// Emit a parse function that routes the body bytes into a single
/// `@httpPayload`-bound member of the output struct. Non-payload
/// members are set to `option.None` for now — header-bound output
/// members are tracked as a follow-up gap.
fn emit_parse_with_payload(
  out_info: IOTypeInfo,
  snake: String,
  payload: MemberDef,
) -> String {
  let output_type = out_info.type_name
  let constructor_fields =
    list.fold(out_info.members, "", fn(acc, m) {
      let value = case m.snake_name == payload.snake_name {
        True -> "payload"
        False -> "option.None"
      }
      acc <> "    " <> m.snake_name <> ": " <> value <> ",\n"
    })
  let payload_decode = case payload.target {
    types.RBlob ->
      "let payload = option.Some(body)"
    RPrim(primitive: types.PString) ->
      "use payload <- result.try(case bit_array.to_string(body) {\n      Ok(s) -> Ok(option.Some(s))\n      Error(_) -> Error(\"non-utf8 payload\")\n    })"
    RStruct(local_name: name, ..) -> {
      let decoder = "decode_" <> stringutils.pascal_to_snake(name) <> "_struct"
      "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case json.parse(text, "
      <> decoder
      <> "()) {\n        Ok(v) -> Ok(option.Some(v))\n        Error(_) -> Error(\"decode failed\")\n      }\n    })"
    }
    RDocument ->
      "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case json.parse(text, decode.dynamic) {\n        Ok(d) -> Ok(option.Some(json_document.from_dynamic(d)))\n        Error(_) -> Error(\"decode failed\")\n      }\n    })"
    REnum(local_name: name, ..) -> {
      let decoder = "decode_" <> stringutils.pascal_to_snake(name) <> "_enum"
      "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case json.parse(\"\\\"\" <> text <> \"\\\"\", "
      <> decoder
      <> "()) {\n        Ok(v) -> Ok(option.Some(v))\n        Error(_) -> Error(\"decode failed\")\n      }\n    })"
    }
    _ ->
      "let payload = option.None"
  }
  "pub fn parse_"
  <> snake
  <> "_response(\n  _code: Int,\n  _headers: dict.Dict(String, String),\n  body: BitArray,\n) -> Result("
  <> output_type
  <> ", String) {\n  {\n    "
  <> payload_decode
  <> "\n    Ok("
  <> output_type
  <> "(\n"
  <> constructor_fields
  <> "    ))\n  }\n}\n\n"
}

fn file_header(service_id: String) -> String {
  "//// Generated from " <> service_id <> " (restJson1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/credentials
import aws/internal/client/awsjson as awsjson_client
import aws/internal/codec/json_document
import aws/internal/codec/json_float
import aws/internal/codec/json_timestamp
import aws/internal/codec/rest
import aws/internal/http_send
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/string
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
