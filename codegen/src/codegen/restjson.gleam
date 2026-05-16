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

import codegen/client
import codegen/code
import codegen/dispatcher
import codegen/named_shapes
import codegen/struct_codec
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

      // Build the rename map for namespace collisions (e.g.
      // `aws.protocoltests.restjson#GreetingStruct` vs
      // `aws.protocoltests.restjson.nested#GreetingStruct`). All
      // Resolved references and members run through `apply_rename`
      // before emission so collided types get unique Gleam names.
      let rename = types.build_rename_map(model)
      let resolved_ops =
        list.map(resolved_ops, fn(t) {
          let #(op_id, http, in_r, out_r, err_ids) = t
          #(
            op_id,
            http,
            types.apply_rename(in_r, rename),
            types.apply_rename(out_r, rename),
            err_ids,
          )
        })
      let named_shapes = collect_named_shapes(model, resolved_ops)
      let named_shapes =
        list.map(named_shapes, fn(r) { types.apply_rename(r, rename) })
      let preamble = emit_named_shapes(model, named_shapes, rename)

      let op_specs =
        list.map(resolved_ops, fn(t) {
          let #(op_id, _, in_r, out_r, err_ids) = t
          let local = strip_namespace(op_id)
          let snake = stringutils.pascal_to_snake(local)
          let in_info = resolve_io_type(model, local <> "Input", in_r, rename)
          let out_info =
            resolve_io_type(model, local <> "Output", out_r, rename)
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
          emit_operation(model, op_id, http, in_r, out_r, rename)
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
      let dispatcher_specs =
        list.map(op_specs, fn(s) {
          dispatcher.DispatcherSpec(
            op_id: s.op_id,
            snake: s.snake,
            input_type: s.in_info.type_name,
            // restjson emits `decode_<op>_input` unconditionally
            // today; if a real-service restJson1 target ever
            // appears, plumb `is_dispatcher_target` through here
            // the same way the awsjson emitter does.
            has_typed_input: True,
          )
        })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        operations_emitted: list.map(resolved_ops, fn(t) {
          let #(op_id, _, _, _, _) = t
          op_id
        }),
        dispatcher_specs: dispatcher_specs,
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
  client.render(metadata.endpoint_prefix, metadata.signing_name)
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
  case runtime.invoke(client.config, build_"
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
      <> "        case runtime.error_type_matches(et, \""
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
  <> "_error(err: runtime.ClientError) -> "
  <> name
  <> " {\n  case err {\n    runtime.ServiceError(status: s, error_type: et, body: b) -> {\n"
  <> matches
  <> fallback
  <> chain_end
  <> "\n    }\n    runtime.TransportError(_) -> "
  <> name
  <> "Transport(reason: \"transport error\")\n    runtime.CredentialsError(_) -> "
  <> name
  <> "Transport(reason: \"credentials error\")\n    runtime.DecodeError(reason: r) -> "
  <> name
  <> "Transport(reason: \"decode: \" <> r)\n  }\n}\n\n"
}

type HttpTrait {
  /// `compression` carries the `@requestCompression` encodings list,
  /// e.g. `["gzip"]`. When non-empty the SDK appends each encoding to
  /// the request's `Content-Encoding` header (Smithy
  /// `SDKAppliedContentEncoding` protocol test).
  HttpTrait(method: String, uri: String, code: Int, compression: List(String))
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
  // Dedup keyed by `full_id` so two shapes with the same local name in
  // different namespaces both make it into the named-shape list. The
  // rename map (built in `emit_service`) ensures the resulting Gleam
  // type names are unique on emission.
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
    RStruct(full_id: id, ..) | RUnion(full_id: id, ..) ->
      case set.contains(acc.0, id) {
        True -> acc
        False -> {
          let acc = remember(acc, id, r)
          let members = types.resolve_members(model, id)
          list.fold(members, acc, fn(a, m) { walk(model, a, m.target) })
        }
      }
    RList(element: e, ..) -> walk(model, acc, e)
    RMap(key: k, value: v, ..) -> {
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

fn emit_named_shapes(
  model: Model,
  shapes: List(Resolved),
  rename: dict.Dict(String, String),
) -> String {
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
            let ms =
              types.resolve_members(model, id)
              |> list.map(fn(m) { types.apply_rename_member(m, rename) })
            acc <> emit_record_def(n, ms) <> emit_struct_codec(n, ms)
          }
        }
      RUnion(gleam_name: n, full_id: id, ..) -> {
        let ms =
          types.resolve_members(model, id)
          |> list.map(fn(m) { types.apply_rename_member(m, rename) })
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
  rename: dict.Dict(String, String),
) -> String {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let in_info = resolve_io_type(model, pascal <> "Input", in_r, rename)
  let out_info = resolve_io_type(model, pascal <> "Output", out_r, rename)

  let synth_in = case in_info.synthesise {
    True ->
      emit_record_def(in_info.type_name, [])
      <> code.render(struct_codec.encoder(
        "encode_" <> snake <> "_input_struct",
        in_info.type_name,
        [],
        False,
        False,
      ))
      <> "\n"
      <> code.render(struct_codec.decoder(
        "decode_" <> snake <> "_input_struct",
        in_info.type_name,
        [],
        False,
        False,
      ))
      <> "\n"
    False -> ""
  }
  let synth_out = case out_info.synthesise {
    True ->
      emit_record_def(out_info.type_name, [])
      <> code.render(struct_codec.encoder(
        "encode_" <> snake <> "_output_struct",
        out_info.type_name,
        [],
        False,
        False,
      ))
      <> "\n"
      <> code.render(struct_codec.decoder(
        "decode_" <> snake <> "_output_struct",
        out_info.type_name,
        [],
        False,
        False,
      ))
      <> "\n"
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
  rename: dict.Dict(String, String),
) -> IOTypeInfo {
  case r {
    RStruct(local_name: ln, gleam_name: gn, full_id: id) ->
      case ln {
        "Unit" ->
          IOTypeInfo(type_name: synth_name, members: [], synthesise: True)
        _ -> {
          let ms =
            types.resolve_members(model, id)
            |> list.map(fn(m) { types.apply_rename_member(m, rename) })
          IOTypeInfo(type_name: gn, members: ms, synthesise: False)
        }
      }
    _ -> IOTypeInfo(type_name: synth_name, members: [], synthesise: True)
  }
}

// ---------- type definitions ----------

fn emit_record_def(name: String, members: List(MemberDef)) -> String {
  code.render(named_shapes.record_def(name, members)) <> "\n"
}

fn emit_enum_def(name: String, variants: List(types.EnumVariant)) -> String {
  code.render(named_shapes.enum_def(name, variants)) <> "\n"
}

fn emit_int_enum_def(
  name: String,
  variants: List(types.IntEnumVariant),
) -> String {
  code.render(named_shapes.int_enum_def(name, variants)) <> "\n"
}

fn emit_union_def(name: String, members: List(MemberDef)) -> String {
  code.render(named_shapes.union_def(name, members)) <> "\n"
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
  // Plain-int extractor — used by query/header/URI-label emitters
  // that need the wire integer value, not a wrapped json.Json.
  let int_value =
    "pub fn "
    <> snake
    <> "_int_value(v: "
    <> name
    <> ") -> Int {\n  case v {\n"
    <> list.fold(variants, "", fn(acc, v) {
      acc
      <> "    "
      <> v.gleam_ctor
      <> " -> "
      <> int_to_string(v.wire_value)
      <> "\n"
    })
    <> "  }\n}\n\n"
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
  int_value <> enc <> dec
}

fn emit_struct_codec(name: String, members: List(MemberDef)) -> String {
  let snake = stringutils.pascal_to_snake(name)
  // restJson1 honours `@jsonName`, so the encoder + main decoder
  // use the wire key (`m.json_name`). The `_params` decoder is
  // member-keyed so the dispatcher's params blob can address the
  // Smithy member names regardless of `@jsonName`.
  [
    struct_codec.encoder(
      "encode_" <> snake <> "_struct",
      name,
      members,
      False,
      False,
    ),
    struct_codec.decoder(
      "decode_" <> snake <> "_struct",
      name,
      members,
      False,
      False,
    ),
    struct_codec.decoder(
      "decode_" <> snake <> "_struct_params",
      name,
      members,
      True,
      True,
    ),
  ]
  |> list.map(code.render)
  |> list.fold("", fn(acc, s) { acc <> s <> "\n" })
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
  // Wrap union decoder bodies in `decode.recursive` so self-
  // referential unions don't construct branches eagerly and infinite-
  // loop. Smithy's `XmlUnionShape.unionValue: XmlUnionShape` cycle is
  // the canonical example.
  let lazy_wrap = case members {
    [] -> ""
    _ -> "  use <- decode.recursive\n"
  }
  let dec =
    "pub fn decode_"
    <> snake
    <> "_union() -> decode.Decoder("
    <> name
    <> ") {\n"
    <> lazy_wrap
    <> dec_body
    <> "}\n\n"
  // Parallel decoder keyed by member names — used by the protocol-test
  // dispatchers. Unions in `params` have variant tags identified by
  // Smithy member names (lowercase `foo`), while the wire form uses
  // `@jsonName` overrides (uppercase `FOO`).
  let dec_params_body = case members {
    [] -> "  decode.failure(" <> name <> "Empty, \"empty union\")\n"
    [first, ..rest] ->
      "  decode.one_of(\n    "
      <> emit_union_branch_params(name, first)
      <> ",\n    ["
      <> list.fold(rest, "", fn(acc, m) {
        acc <> "\n      " <> emit_union_branch_params(name, m) <> ","
      })
      <> "\n    ],\n  )\n"
  }
  let dec_params =
    "pub fn decode_"
    <> snake
    <> "_union_params() -> decode.Decoder("
    <> name
    <> ") {\n"
    <> lazy_wrap
    <> dec_params_body
    <> "}\n\n"
  enc <> dec <> dec_params
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

fn emit_union_branch_params(union_name: String, m: MemberDef) -> String {
  "decode.field(\""
  <> m.member_name
  <> "\", "
  <> types.json_decoder_params(m.target)
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
  <> "  let headers = case content_type, dict.has_key(headers, \"Content-Type\") {\n    \"\", _ -> headers\n    _, True -> headers\n    _, False -> dict.insert(headers, \"Content-Type\", content_type)\n  }\n  let headers = case content_type {\n    \"\" -> headers\n    _ -> dict.insert(headers, \"Content-Length\", int.to_string(bit_array.byte_size(body)))\n  }\n"
  <> emit_content_encoding(http.compression)
  <> "  let path = rest.build_path(path, query)\n  #(\""
  <> http.method
  <> "\", path, headers, body)\n}\n\n"
}

/// Emit `Content-Encoding` mutation for `@requestCompression`
/// encodings. Each encoding is appended to any existing value.
/// Empty list ⇒ no-op.
fn emit_content_encoding(encodings: List(String)) -> String {
  case encodings {
    [] -> ""
    _ ->
      list.fold(encodings, "", fn(acc, enc) {
        acc
        <> "  let headers = rest.append_content_encoding(headers, \""
        <> enc
        <> "\")\n"
      })
  }
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
    <> value_to_string_with_format(m.target, m.timestamp_format)
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
      case m.target, m.idempotency_token {
        _, True ->
          // `@idempotencyToken` query members auto-fill via the
          // runtime FFI when the caller leaves them unset.
          acc
          <> "  let query = case input."
          <> m.snake_name
          <> " {\n    option.Some(v) -> rest.add_query(query, \""
          <> query_name
          <> "\", v)\n    option.None -> rest.add_query(query, \""
          <> query_name
          <> "\", rest.idempotency_token())\n  }\n"
        RList(element: e, ..), _ ->
          acc
          <> "  let query = case input."
          <> m.snake_name
          <> " {\n    option.Some(xs) -> list.fold(xs, query, fn(q, item) {\n      let v = item\n      rest.add_query(q, \""
          <> query_name
          <> "\", "
          <> value_to_string_with_format(e, m.timestamp_format)
          <> ")\n    })\n    option.None -> query\n  }\n"
        _, _ ->
          acc
          <> "  let query = case input."
          <> m.snake_name
          <> " {\n    option.Some(v) -> rest.add_query(query, \""
          <> query_name
          <> "\", "
          <> value_to_string_with_format(m.target, m.timestamp_format)
          <> ")\n    option.None -> query\n  }\n"
      }
    })
  list.fold(query_maps, with_queries, fn(acc, m) {
    // Dispatch on the map's value type: Map<String, String> uses
    // `add_query_params`, Map<String, List<String>> uses
    // `add_query_params_list`. Anything else: skip.
    let helper = case m.target {
      RMap(
        key: _,
        value: RList(element: RPrim(primitive: types.PString), ..),
        ..,
      ) -> Ok("rest.add_query_params_list")
      RMap(key: _, value: RPrim(primitive: types.PString), ..) ->
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
  // Apply prefix-headers FIRST so explicit `@httpHeader` members
  // override on key collision (`HttpEmptyPrefixHeaders` test:
  // `prefixHeaders.hello = "Hello"` then `specificHeader = "There"`
  // bound to `@httpHeader("hello")` → wire `hello: There`).
  let initial = "  let headers = dict.new()\n"
  let with_prefix =
    list.fold(prefix_headers, initial, fn(acc, m) {
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
  list.fold(headers, with_prefix, fn(acc, m) {
    let header_name = case m.binding {
      Header(header_name: n) -> n
      _ -> m.json_name
    }
    case m.target {
      RList(element: e, ..) -> {
        // String list-header entries get RFC 7230 list-quoting; other
        // types (numbers, http-date timestamps, enums) use the raw
        // wire form. Smithy's @httpHeader spec only quotes strings.
        let render = case e {
          RPrim(primitive: types.PString) -> "rest.quote_list_string_entry(v)"
          _ -> value_to_string_full(e, m.timestamp_format, "http-date")
        }
        acc
        <> "  let headers = case input."
        <> m.snake_name
        <> " {\n    option.Some(xs) -> rest.maybe_set_list_header(headers, \""
        <> header_name
        <> "\", list.map(xs, fn(item) { let v = item "
        <> render
        <> " }))\n    option.None -> headers\n  }\n"
      }
      _ -> {
        // `@mediaType` on a `@httpHeader` string member means the
        // value is opaque to HTTP — base64 the JSON form so commas /
        // quotes / linefeeds in the payload don't break header parsing.
        let render = case m.target, m.media_type {
          RPrim(primitive: types.PString), option.Some(_) ->
            "bit_array.base64_encode(bit_array.from_string(v), True)"
          _, _ ->
            value_to_string_full(m.target, m.timestamp_format, "http-date")
        }
        acc
        <> "  let headers = case input."
        <> m.snake_name
        <> " {\n    option.Some(v) -> rest.maybe_set_header(headers, \""
        <> header_name
        <> "\", "
        <> render
        <> ")\n    option.None -> headers\n  }\n"
      }
    }
  })
}

fn emit_payload_body(m: MemberDef) -> String {
  // @httpPayload — the member's value IS the body. For blob members
  // the body is the raw bytes; for struct/string members it's the
  // JSON-encoded value; for primitive strings, the raw string.
  // `@mediaType` (on the member or its target shape) overrides
  // Content-Type for opaque-payload members.
  case m.target {
    types.RBlob -> {
      let ct = case m.media_type {
        Some(s) -> s
        None -> "application/octet-stream"
      }
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> v\n    option.None -> <<>>\n  }\n  let content_type = \""
      <> ct
      <> "\"\n"
    }
    RPrim(primitive: types.PString) -> {
      let ct = case m.media_type {
        Some(s) -> s
        None -> "text/plain"
      }
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(v)\n    option.None -> <<>>\n  }\n  let content_type = \""
      <> ct
      <> "\"\n"
    }
    REnum(..) -> {
      let ct = case m.media_type {
        Some(s) -> s
        None -> "text/plain"
      }
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(rest.enum_wire_value("
      <> types.json_encoder(m.target)
      <> "(v)))\n    option.None -> <<>>\n  }\n  let content_type = \""
      <> ct
      <> "\"\n"
    }
    RStruct(..) ->
      // Absent struct `@httpPayload` ⇒ `{}` rather than empty bytes
      // — restJson1 servers expect to JSON-parse a structured body
      // even when every field is null.
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(json.to_string("
      <> types.json_encoder(m.target)
      <> "(v)))\n    option.None -> bit_array.from_string(\"{}\")\n  }\n  let content_type = \"application/json\"\n"
    _ ->
      // Unions / Documents / other payload types: empty when unset.
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(json.to_string("
      <> types.json_encoder(m.target)
      <> "(v)))\n    option.None -> <<>>\n  }\n  let content_type = \"application/json\"\n"
  }
}

/// Render a Resolved value as a Gleam expression that produces a
/// String — used in label / query / header position where everything
/// is stringified. Format-aware variant; the no-format wrapper has
/// been removed since every caller carries an explicit timestamp
/// format.
fn value_to_string_with_format(
  target: Resolved,
  timestamp_format: option.Option(String),
) -> String {
  value_to_string_full(target, timestamp_format, "date-time")
}

fn value_to_string_full(
  target: Resolved,
  timestamp_format: option.Option(String),
  default_ts_format: String,
) -> String {
  case target {
    RPrim(primitive: types.PString) -> "v"
    RPrim(primitive: types.PInt) -> "rest.int_to_query(v)"
    RPrim(primitive: types.PFloat) ->
      "case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }"
    RPrim(primitive: types.PBool) -> "rest.bool_to_query(v)"
    REnum(local_name: _, ..) ->
      "rest.enum_wire_value(" <> types.json_encoder(target) <> "(v))"
    RIntEnum(local_name: n, ..) ->
      "rest.int_to_query(" <> stringutils.pascal_to_snake(n) <> "_int_value(v))"
    RTimestamp -> {
      let fmt = case timestamp_format {
        option.Some(f) -> f
        option.None -> default_ts_format
      }
      case fmt {
        "epoch-seconds" -> "rest.int_to_query(v)"
        "http-date" -> "json_timestamp.format_http_date(v)"
        _ -> "json_timestamp.format_iso8601(v)"
      }
    }
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
        <> types.json_encoder_member(m.target, m.timestamp_format)
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
    types.RBlob -> "let payload = option.Some(body)"
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
    _ -> "let payload = option.None"
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
import aws/internal/client/runtime as runtime
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
      let compression = request_compression_encodings(traits)
      case method, uri {
        Some(m), Some(u) ->
          Some(HttpTrait(
            method: m,
            uri: u,
            code: code,
            compression: compression,
          ))
        _, _ -> None
      }
    }
    _ -> None
  }
}

fn request_compression_encodings(traits: shape.Traits) -> List(String) {
  case dict.get(traits, ShapeId("smithy.api#requestCompression")) {
    Ok(Some(trait.Dict(d))) ->
      case dict.get(d, ShapeId("encodings")) {
        Ok(trait.List(items)) ->
          list.filter_map(items, fn(t) {
            case t {
              trait.String(s) -> Ok(s)
              _ -> Error(Nil)
            }
          })
        _ -> []
      }
    _ -> []
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
