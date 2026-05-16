//// Code emitter for restXml.
////
//// Same skeleton as restJson1 (shared shape walker, HTTP-binding
//// routing, Client wiring), but emits XML body encoders and XML
//// response decoders backed by `aws/internal/codec/xml` (encoder) and
//// `aws/internal/codec/xml_decode` (decoder + xmerl FFI).
////
//// Each generated struct gets four codec functions:
////
////   * `encode_<snake>_xml_inner(input)` — inner XML (no wrapper)
////   * `encode_<snake>_xml(input, root)` — wraps in `<root>...</root>`
////   * `decode_<snake>_xml(elem)` — element → Result(Struct, String)
////   * `encode_<snake>_struct` / `decode_<snake>_struct` — JSON codecs
////     retained for the internal awsJson runtime helpers; unused on the
////     wire side for restXml services.
////
//// Wire fidelity notes:
////   * `@xmlName` overrides on list members are honoured via
////     `Resolved.xml_entry_name`, so S3's `Buckets/Bucket` shape comes
////     out correctly. `@xmlName` on struct members and `@xmlFlattened`
////     are not yet honoured.
////   * Output members bound to `@httpHeader` / `@httpResponseCode`
////     are currently decoded as `option.None` — the response parser
////     does not yet read response headers into the typed output.
////   * Unions and maps in XML bodies are not yet implemented.

import codegen/client
import codegen/code
import codegen/dispatcher
import codegen/named_shapes
import codegen/struct_codec
import codegen/types.{
  type MemberDef, type Resolved, Body, Header, Label, Payload, PrefixHeaders,
  Query, QueryParams, RBlob, RDocument, REnum, RIntEnum, RList, RMap, RPrim,
  RStruct, RTimestamp, RUnion, RUnit, Unsupported,
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

      let named_shapes = collect_named_shapes(model, resolved_ops)
      let is_dispatcher = is_dispatcher_target(service_id)
      let union_reachable = compute_union_reachable_structs(model, named_shapes)
      let preamble =
        emit_named_shapes(model, named_shapes, is_dispatcher, union_reachable)

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
          emit_operation(model, op_id, http, in_r, out_r, is_dispatcher)
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
            has_typed_input: is_dispatcher,
          )
        })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        dispatcher_specs: dispatcher_specs,
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

/// restXml typed-error enum + translator. restXml errors come back
/// as an XML body shaped like `<Error><Code>...</Code>...</Error>`.
/// The shared `runtime` module still extracts an error_type from
/// the X-Amzn-Errortype header (when present) or — for S3 — from a
/// JSON `code` field that's not actually there. Until the runtime's
/// error_type extractor learns to read the XML `<Code>` element,
/// every restXml service error will land in the `Unknown` variant,
/// which still carries the raw body so callers aren't stuck.
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

/// See `awsjson.emit_error_translator` for the table-style design.
/// restXml's decoder table is intentionally empty today: the runtime
/// can't yet pull an `error_type` out of an XML `<Code>` element, so
/// every service error lands in the `*Unknown` variant. Pass 6 of
/// plan.md teaches the runtime to read XML error bodies; the table
/// will populate once that lands.
fn emit_error_translator(spec: OpSpec) -> String {
  let name = spec.local <> "Error"
  let snake = spec.snake
  "fn "
  <> snake
  <> "_error_decoders() {
  []
}

fn translate_"
  <> snake
  <> "_error(err: runtime.ClientError) -> "
  <> name
  <> " {
  runtime.translate_service_error(
    err,
    "
  <> snake
  <> "_error_decoders(),
    fn(reason) { "
  <> name
  <> "Transport(reason: reason) },
    fn(et, s, body) { "
  <> name
  <> "Unknown(error_type: et, status: s, body: body) },
  )
}

"
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
  is_dispatcher: Bool,
  union_reachable: Set(String),
) -> String {
  list.fold(shapes, "", fn(acc, r) {
    case r {
      REnum(gleam_name: n, variants: vs, ..) ->
        acc <> emit_enum_def(n, vs) <> emit_enum_codec(n, vs, is_dispatcher)
      RIntEnum(gleam_name: n, variants: vs, ..) ->
        acc <> emit_int_enum_def(n, vs) <> emit_int_enum_codec(n, vs)
      RStruct(gleam_name: n, full_id: id, local_name: ln) ->
        case ln == "Unit" {
          True -> acc
          False -> {
            let ms = types.resolve_members(model, id)
            let emit_json_encoder = set.contains(union_reachable, ln)
            acc
            <> emit_record_def(n, ms)
            <> emit_struct_codec(n, ms, is_dispatcher, emit_json_encoder)
          }
        }
      RUnion(gleam_name: n, full_id: id, ..) -> {
        let ms = types.resolve_members(model, id)
        acc <> emit_union_def(n, ms) <> emit_union_codec(n, ms, is_dispatcher)
      }
      _ -> acc
    }
  })
}

/// Walk every union shape and collect the set of struct local names
/// reachable from any union variant's `target`. The JSON `encode_<X>_
/// struct` function is only ever called from these unions (the wire
/// path for restXml is XML), so structs outside this set never need
/// their JSON encoder emitted. Reachability is transitive: if struct
/// `A` is referenced by a union and `A` has a field of type `B`,
/// then `B`'s encoder is also reachable.
fn compute_union_reachable_structs(
  model: Model,
  shapes: List(Resolved),
) -> Set(String) {
  let struct_index =
    list.fold(shapes, dict.new(), fn(acc, r) {
      case r {
        RStruct(local_name: n, full_id: id, ..) -> dict.insert(acc, n, id)
        _ -> acc
      }
    })
  let seeds =
    list.fold(shapes, set.new(), fn(acc, r) {
      case r {
        RUnion(full_id: id, ..) -> {
          let ms = types.resolve_members(model, id)
          list.fold(ms, acc, fn(inner, m) {
            collect_struct_refs(m.target, inner)
          })
        }
        _ -> acc
      }
    })
  fixpoint_struct_refs(model, struct_index, seeds)
}

fn collect_struct_refs(r: Resolved, acc: Set(String)) -> Set(String) {
  case r {
    RStruct(local_name: n, ..) -> set.insert(acc, n)
    RList(element: e, ..) -> collect_struct_refs(e, acc)
    RMap(value: v, ..) -> collect_struct_refs(v, acc)
    _ -> acc
  }
}

fn fixpoint_struct_refs(
  model: Model,
  struct_index: Dict(String, String),
  seeds: Set(String),
) -> Set(String) {
  let next =
    set.fold(seeds, seeds, fn(acc, struct_name) {
      case dict.get(struct_index, struct_name) {
        Ok(id) -> {
          let ms = types.resolve_members(model, id)
          list.fold(ms, acc, fn(inner, m) {
            collect_struct_refs(m.target, inner)
          })
        }
        Error(_) -> acc
      }
    })
  case set.size(next) == set.size(seeds) {
    True -> seeds
    False -> fixpoint_struct_refs(model, struct_index, next)
  }
}

// ---------- per-operation emission ----------

fn emit_operation(
  model: Model,
  op_id: String,
  http: HttpTrait,
  in_r: Resolved,
  out_r: Resolved,
  is_dispatcher: Bool,
) -> String {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let in_info = resolve_io_type(model, pascal <> "Input", in_r)
  let out_info = resolve_io_type(model, pascal <> "Output", out_r)

  // `synth_in` and `in_decoder` together form the dispatcher's
  // params-blob entry point — `decode_<op>_input(raw)` parses the
  // test-case params into a typed input via the member-keyed
  // `_struct_params` decoder. Real services bypass this entirely,
  // so both are gated on `is_dispatcher`.
  let synth_in_record = case in_info.synthesise {
    True -> emit_record_def(in_info.type_name, [])
    False -> ""
  }
  let synth_in_decoder = case in_info.synthesise, is_dispatcher {
    True, True ->
      code.render(struct_codec.decoder(
        "decode_" <> snake <> "_input_struct",
        in_info.type_name,
        [],
        True,
        True,
      ))
      <> "\n"
    _, _ -> ""
  }
  let synth_out = case out_info.synthesise {
    True -> emit_record_def(out_info.type_name, [])
    False -> ""
  }
  let in_decoder = case is_dispatcher {
    True ->
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
    False -> ""
  }
  let in_members = in_info.members
  let body_encoder =
    emit_body_encoder_xml(snake, in_info.type_name, local, in_info.synthesise)
  let build =
    emit_build(in_info.type_name, in_info.synthesise, snake, http, in_members)
  let parse = emit_parse(out_info, snake)
  "\n"
  <> synth_in_record
  <> synth_in_decoder
  <> synth_out
  <> in_decoder
  <> body_encoder
  <> build
  <> parse
}

/// Restxml body encoder: wraps the operation's input struct as XML.
/// Element name = the operation's local Pascal name (e.g. `PutBucketAcl`
/// produces `<PutBucketAcl>...</PutBucketAcl>`). For named-struct
/// inputs this delegates to the struct's `_xml` encoder; for synthetic
/// Unit inputs we emit an empty element.
fn emit_body_encoder_xml(
  snake: String,
  input_type: String,
  op_local: String,
  synthesised: Bool,
) -> String {
  // For synthetic Unit inputs (operation declares no input shape), the
  // named-shape walker never sees an `<Input>` struct, so we emit an
  // empty-element body directly. Otherwise delegate to the struct's
  // `_xml` encoder emitted into the named-shapes preamble.
  case synthesised {
    True ->
      "pub fn encode_"
      <> snake
      <> "_body_xml(_input: "
      <> input_type
      <> ") -> String {\n  xml.empty_element(\""
      <> op_local
      <> "\")\n}\n\n"
    False -> {
      let input_snake = stringutils.pascal_to_snake(input_type)
      "pub fn encode_"
      <> snake
      <> "_body_xml(input: "
      <> input_type
      <> ") -> String {\n  encode_"
      <> input_snake
      <> "_xml(input, \""
      <> op_local
      <> "\")\n}\n\n"
    }
  }
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

fn emit_enum_codec(
  name: String,
  variants: List(types.EnumVariant),
  is_dispatcher: Bool,
) -> String {
  let snake = stringutils.pascal_to_snake(name)
  // JSON enum encoder stays — it's reached from `encode_<X>_xml*`
  // (wire path) for enum-typed members. The JSON decoder is only
  // ever called from `decode_<X>_struct_params`, which is itself
  // dispatcher-only, so its emission is gated on the same flag.
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
  let dec = case is_dispatcher {
    True -> {
      let first_ctor = case variants {
        [v, ..] -> v.gleam_ctor
        [] -> name <> "Unknown"
      }
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
    }
    False -> ""
  }
  enc <> dec
}

fn emit_int_enum_codec(
  name: String,
  variants: List(types.IntEnumVariant),
) -> String {
  let snake = stringutils.pascal_to_snake(name)
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

fn emit_struct_codec(
  name: String,
  members: List(MemberDef),
  is_dispatcher: Bool,
  emit_json_encoder: Bool,
) -> String {
  let snake = stringutils.pascal_to_snake(name)
  // restXml wire is XML — the JSON encoder is only emitted when
  // this struct is transitively reachable from a union encoder
  // (`@httpPayload` Union fallback emits JSON). Other structs
  // never need a JSON encoder. The member-keyed `_struct_params`
  // decoder supports the protocol-test dispatcher's params blob;
  // real services never reach it.
  let encoder = case emit_json_encoder {
    True ->
      code.render(struct_codec.encoder(
        "encode_" <> snake <> "_struct",
        name,
        members,
        False,
        False,
      ))
      <> "\n"
    False -> ""
  }
  let params_decoder = case is_dispatcher {
    True ->
      code.render(struct_codec.decoder(
        "decode_" <> snake <> "_struct_params",
        name,
        members,
        True,
        True,
      ))
      <> "\n"
    False -> ""
  }
  encoder
  <> params_decoder
  <> emit_struct_xml_inner_encoder(
    name,
    "encode_" <> snake <> "_xml_inner",
    members,
  )
  <> emit_struct_xml_encoder(name, "encode_" <> snake <> "_xml", snake)
  <> emit_struct_xml_decoder(name, "decode_" <> snake <> "_xml", members)
}

/// Emit `decode_<snake>_xml(elem) -> Result(<Type>, String)`. Reads
/// each Body-bound member from the XML element; HTTP-bound members
/// (header, status, payload) are set to None for now — proper
/// out-of-body decoding requires threading `_code` / `_headers` into
/// the call site, which the per-op `parse_<op>_response` does not yet
/// do.
fn emit_struct_xml_decoder(
  type_name: String,
  fn_name: String,
  members: List(MemberDef),
) -> String {
  case members {
    [] ->
      "pub fn "
      <> fn_name
      <> "(_elem: xml_decode.Element) -> Result("
      <> type_name
      <> ", String) {\n  Ok("
      <> type_name
      <> ")\n}\n\n"
    _ ->
      "pub fn "
      <> fn_name
      <> "(elem: xml_decode.Element) -> Result("
      <> type_name
      <> ", String) {\n"
      <> list.fold(members, "", fn(acc, m) {
        case m.binding {
          Body ->
            acc
            <> "  use "
            <> m.snake_name
            <> " <- result.try("
            <> xml_value_decoder_expr(m.target, m.json_name)
            <> ")\n"
          _ -> acc <> "  let " <> m.snake_name <> " = option.None\n"
        }
      })
      <> "  Ok("
      <> type_name
      <> "(\n"
      <> list.fold(members, "", fn(acc, m) {
        acc <> "    " <> m.snake_name <> ": " <> m.snake_name <> ",\n"
      })
      <> "  ))\n}\n\n"
  }
}

/// Build the `Result(Option(a), String)` decoder expression that reads
/// a single member from the parent XML element. Mirrors
/// `xml_value_expr` on the encoder side: primitives use `int_text` /
/// `string_text` / etc., nested structs recurse, lists become wrapped
/// `optional_list` reads.
fn xml_value_decoder_expr(target: Resolved, member_name: String) -> String {
  case target {
    RPrim(primitive: types.PString) ->
      "xml_decode.optional_child(elem, \""
      <> member_name
      <> "\", xml_decode.string_text)"
    RPrim(primitive: types.PInt) ->
      "xml_decode.optional_child(elem, \""
      <> member_name
      <> "\", xml_decode.int_text)"
    RPrim(primitive: types.PBool) ->
      "xml_decode.optional_child(elem, \""
      <> member_name
      <> "\", xml_decode.bool_text)"
    RPrim(primitive: types.PFloat) ->
      // Wrap raw float in FloatValue. Special-float wire forms (NaN /
      // Infinity / -Infinity) aren't part of the restXml spec; if they
      // ever appear we'd dispatch on text content here.
      "xml_decode.optional_child(elem, \""
      <> member_name
      <> "\", fn(e) { case xml_decode.float_text(e) { Ok(f) -> Ok(json_float.FloatValue(f)) Error(r) -> Error(r) } })"
    RBlob ->
      // S3 wraps blob bodies in base64; decode the text content then
      // base64-decode. Failure on either side produces a String error.
      "xml_decode.optional_child(elem, \""
      <> member_name
      <> "\", fn(e) { case xml_decode.string_text(e) { Ok(s) -> case bit_array.base64_decode(s) { Ok(b) -> Ok(b) Error(_) -> Error(\"xml: bad base64\") } Error(r) -> Error(r) } })"
    RTimestamp ->
      // Wire timestamps in restXml are ISO 8601 (e.g.
      // `2024-01-02T03:04:05.000Z`); the type walker surfaces them
      // as `Int` (epoch seconds), so `xml_decode.timestamp_text`
      // does the ISO 8601 → epoch conversion and falls through to
      // integer parsing for the (rare) integer-on-wire case.
      "xml_decode.optional_child(elem, \""
      <> member_name
      <> "\", xml_decode.timestamp_text)"
    REnum(gleam_name: gn, ..) -> emit_unsupported_decoder(gn)
    RIntEnum(gleam_name: gn, ..) -> emit_unsupported_decoder(gn)
    RStruct(local_name: name, ..) ->
      "xml_decode.optional_child(elem, \""
      <> member_name
      <> "\", decode_"
      <> stringutils.pascal_to_snake(name)
      <> "_xml)"
    RUnion(gleam_name: gn, ..) -> emit_unsupported_decoder(gn)
    RList(element: e, xml_entry_name: entry, ..) -> {
      let inner_decoder = case e {
        RPrim(primitive: types.PString) -> "xml_decode.string_text"
        RPrim(primitive: types.PInt) -> "xml_decode.int_text"
        RPrim(primitive: types.PBool) -> "xml_decode.bool_text"
        RStruct(local_name: n, ..) ->
          "decode_" <> stringutils.pascal_to_snake(n) <> "_xml"
        _ -> "fn(_) { Error(\"xml: unsupported list element\") }"
      }
      "xml_decode.optional_list(elem, \""
      <> member_name
      <> "\", \""
      <> entry
      <> "\", "
      <> inner_decoder
      <> ")"
    }
    RMap(key: _, value: _, ..) ->
      emit_unsupported_decoder(types.gleam_type(target))
    RDocument -> emit_unsupported_decoder(types.gleam_type(target))
    RUnit -> emit_unsupported_decoder(types.gleam_type(target))
    Unsupported(..) -> emit_unsupported_decoder(types.gleam_type(target))
  }
}

/// Placeholder result used for member kinds we don't yet decode from
/// XML (enums, unions, maps, ...). Yields `option.None` so the
/// enclosing struct still constructs successfully.
fn emit_unsupported_decoder(gleam_type: String) -> String {
  // Cast the literal `Ok(option.None)` to the right Result type so
  // the use-bound variable infers as `option.Option(<gleam_type>)`.
  "{ let r: Result(option.Option("
  <> gleam_type
  <> "), String) = Ok(option.None)\n    r }"
}

/// Emit `encode_<snake>_xml(input, root)` — wraps the struct's inner
/// content in `<root>...</root>`. Delegates to `_xml_inner` for the
/// inner body to avoid duplicating the per-member emission.
fn emit_struct_xml_encoder(
  type_name: String,
  fn_name: String,
  snake: String,
) -> String {
  "pub fn "
  <> fn_name
  <> "(input: "
  <> type_name
  <> ", root: String) -> String {\n  xml.element(root, encode_"
  <> snake
  <> "_xml_inner(input))\n}\n\n"
}

/// Emit `encode_<snake>_xml_inner(input) -> String` — produces just
/// the inner XML for a struct (no outer wrapping element). Used by
/// `_xml` (which adds the wrapper) and by list emission (where the
/// caller's `<member>...</member>` provides the wrapper).
fn emit_struct_xml_inner_encoder(
  type_name: String,
  fn_name: String,
  members: List(MemberDef),
) -> String {
  case members {
    [] ->
      "pub fn "
      <> fn_name
      <> "(_input: "
      <> type_name
      <> ") -> String {\n  \"\"\n}\n\n"
    _ ->
      "pub fn "
      <> fn_name
      <> "(input: "
      <> type_name
      <> ") -> String {\n  let inner = \"\"\n"
      <> list.fold(members, "", fn(acc, m) {
        case m.binding {
          // Only Body-bound members go into the XML element. URI /
          // query / header members are routed elsewhere by the build
          // function.
          Body ->
            acc
            <> "  let inner = case input."
            <> m.snake_name
            <> " {\n    option.Some(v) -> inner <> "
            <> xml_value_expr(m.target, m.json_name)
            <> "\n    option.None -> inner\n  }\n"
          _ -> acc
        }
      })
      <> "  inner\n}\n\n"
  }
}

/// Render `v` (a Gleam value of `target`'s type) as an XML element
/// `<member_name>...</member_name>`. Recursive for nested structs and
/// lists.
fn xml_value_expr(target: Resolved, member_name: String) -> String {
  case target {
    RPrim(primitive: types.PString) ->
      "xml.element(\"" <> member_name <> "\", xml.escape_text(v))"
    RPrim(primitive: types.PInt) ->
      "xml.element(\"" <> member_name <> "\", xml.int_text(v))"
    RPrim(primitive: types.PBool) ->
      "xml.element(\"" <> member_name <> "\", xml.bool_text(v))"
    RPrim(primitive: types.PFloat) ->
      "xml.element(\""
      <> member_name
      <> "\", case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" })"
    RBlob -> "xml.element(\"" <> member_name <> "\", xml.blob_text(v))"
    RTimestamp -> "xml.element(\"" <> member_name <> "\", xml.int_text(v))"
    REnum(local_name: _, ..) ->
      "xml.element(\""
      <> member_name
      <> "\", rest.enum_wire_value("
      <> types.json_encoder(target)
      <> "(v)))"
    RIntEnum(local_name: _, ..) ->
      "xml.element(\"" <> member_name <> "\", xml.int_text(case v { _ -> 0 }))"
    RStruct(local_name: name, ..) ->
      "encode_"
      <> stringutils.pascal_to_snake(name)
      <> "_xml(v, \""
      <> member_name
      <> "\")"
    RUnion(local_name: _, ..) ->
      // Unions in XML body need per-variant element emission; not
      // implemented yet — emit an empty element as a placeholder.
      "xml.empty_element(\"" <> member_name <> "\")"
    RList(element: _e, xml_entry_name: entry, ..) ->
      // Smithy default list wrapping: `<MemberName><member>...</member>...</MemberName>`.
      // The list shape's member `@xmlName` overrides the per-entry tag —
      // S3's Buckets list, for example, uses `<Bucket>` not `<member>`.
      "xml.list_element(\""
      <> member_name
      <> "\", \""
      <> entry
      <> "\", list.map(v, fn(item) { let v = item "
      <> xml_inner_expr_for_list_element(target)
      <> " }))"
    RMap(value: _v, key: _k, ..) ->
      "xml.empty_element(\"" <> member_name <> "\")"
    RDocument -> "xml.element(\"" <> member_name <> "\", \"\")"
    RUnit -> "xml.empty_element(\"" <> member_name <> "\")"
    Unsupported(..) -> "\"\""
  }
}

/// For list elements, produce the INNER content (no wrapping element).
/// Used inside `xml.list_element` to render each item as just its
/// text-content / inner XML.
fn xml_inner_expr_for_list_element(target: Resolved) -> String {
  case target {
    RList(element: e, ..) ->
      case e {
        RPrim(primitive: types.PString) -> "xml.escape_text(v)"
        RPrim(primitive: types.PInt) -> "xml.int_text(v)"
        RPrim(primitive: types.PBool) -> "xml.bool_text(v)"
        RPrim(primitive: types.PFloat) ->
          "case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }"
        RBlob -> "xml.blob_text(v)"
        RTimestamp -> "xml.int_text(v)"
        REnum(..) -> "rest.enum_wire_value(" <> types.json_encoder(e) <> "(v))"
        RStruct(local_name: n, ..) ->
          // Lists of structs: each entry is an inline struct without
          // an outer wrapper (caller's `<member>...</member>` wraps).
          "encode_" <> stringutils.pascal_to_snake(n) <> "_xml_inner(v)"
        _ -> "\"\""
      }
    _ -> "\"\""
  }
}

/// restXml union codec. The wire-keyed JSON decoder is dropped
/// (build/parse use XML). The JSON encoder survives because
/// `@httpPayload` Union members fall back to a JSON body — proper
/// XML union emission is not yet implemented (see the file header).
/// The `_union_params` decoder is dispatcher-only.
fn emit_union_codec(
  name: String,
  members: List(MemberDef),
  is_dispatcher: Bool,
) -> String {
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
  let dec_params = case is_dispatcher {
    True -> {
      let lazy_wrap = case members {
        [] -> ""
        _ -> "  use <- decode.recursive\n"
      }
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
      "pub fn decode_"
      <> snake
      <> "_union_params() -> decode.Decoder("
      <> name
      <> ") {\n"
      <> lazy_wrap
      <> dec_params_body
      <> "}\n\n"
    }
    False -> ""
  }
  enc <> dec_params
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
          "  let body_xml = encode_"
          <> snake
          <> "_body_xml(input)\n  let body = bit_array.from_string(body_xml)\n  let content_type = \"application/xml\"\n"
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
  <> "  let headers = case content_type, dict.has_key(headers, \"Content-Type\") {\n    \"\", _ -> headers\n    _, True -> headers\n    _, False -> dict.insert(headers, \"Content-Type\", content_type)\n  }\n  let headers = case content_type {\n    \"\" -> headers\n    _ -> dict.insert(headers, \"Content-Length\", int.to_string(bit_array.byte_size(body)))\n  }\n  let path = rest.build_path(path, query)\n  #(\""
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
      case m.target {
        RList(element: e, ..) ->
          acc
          <> "  let query = case input."
          <> m.snake_name
          <> " {\n    option.Some(xs) -> list.fold(xs, query, fn(q, item) {\n      let v = item\n      rest.add_query(q, \""
          <> query_name
          <> "\", "
          <> value_to_string_with_format(e, m.timestamp_format)
          <> ")\n    })\n    option.None -> query\n  }\n"
        _ ->
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
  let initial = "  let headers = dict.new()\n"
  let with_headers =
    list.fold(headers, initial, fn(acc, m) {
      let header_name = case m.binding {
        Header(header_name: n) -> n
        _ -> m.json_name
      }
      case m.target {
        RList(element: e, ..) ->
          acc
          <> "  let headers = case input."
          <> m.snake_name
          <> " {\n    option.Some(xs) -> rest.maybe_set_list_header(headers, \""
          <> header_name
          <> "\", list.map(xs, fn(item) { let v = item "
          <> value_to_string_with_format(e, m.timestamp_format)
          <> " }))\n    option.None -> headers\n  }\n"
        _ ->
          acc
          <> "  let headers = case input."
          <> m.snake_name
          <> " {\n    option.Some(v) -> rest.maybe_set_header(headers, \""
          <> header_name
          <> "\", "
          <> value_to_string_with_format(m.target, m.timestamp_format)
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
  // @httpPayload — the member's value IS the body.
  //   * blob: raw bytes
  //   * string: raw string (no JSON quoting)
  //   * struct: XML element, root = member's wire name (or @xmlName)
  //   * other: fall back to JSON; restXml services don't put bare
  //     primitives or unions in @httpPayload position in practice.
  case m.target {
    types.RBlob ->
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> v\n    option.None -> <<>>\n  }\n  let content_type = \"application/octet-stream\"\n"
    RPrim(primitive: types.PString) ->
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(v)\n    option.None -> <<>>\n  }\n  let content_type = \"text/plain\"\n"
    RStruct(local_name: name, ..) ->
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(encode_"
      <> stringutils.pascal_to_snake(name)
      <> "_xml(v, \""
      <> m.json_name
      <> "\"))\n    option.None -> <<>>\n  }\n  let content_type = \"application/xml\"\n"
    _ ->
      "  let body = case input."
      <> m.snake_name
      <> " {\n    option.Some(v) -> bit_array.from_string(json.to_string("
      <> types.json_encoder(m.target)
      <> "(v)))\n    option.None -> <<>>\n  }\n  let content_type = \"application/xml\"\n"
  }
}

/// Render a Resolved value as a Gleam expression that produces a
/// String — used in label / query / header position where everything
/// is stringified. Format-aware variant; the no-format wrapper has
/// been removed since every caller carries an explicit timestamp
/// format.
fn value_to_string_with_format(
  target: Resolved,
  timestamp_format: Option(String),
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
    RTimestamp ->
      case timestamp_format {
        Some("epoch-seconds") -> "rest.int_to_query(v)"
        Some("http-date") -> "json_timestamp.format_http_date(v)"
        _ -> "json_timestamp.format_iso8601(v)"
      }
    _ -> "\"\""
  }
}

/// `parse_<op>_response`: parse the wire body as XML, then run the
/// output struct's XML decoder. The synthesised-Unit output case is
/// handled separately — there is no struct to decode into, so the
/// constructor is invoked directly.
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
    Error(_), False -> {
      let decoder =
        "decode_" <> stringutils.pascal_to_snake(output_type) <> "_xml"
      "pub fn parse_"
      <> snake
      <> "_response(\n  _code: Int,\n  _headers: dict.Dict(String, String),\n  body: BitArray,\n) -> Result("
      <> output_type
      <> ", String) {\n  case bit_array.to_string(body) {\n    Ok(text) -> case text {\n      \"\" -> "
      <> decoder
      <> "(xml_decode.Element(name: \"empty\", attrs: [], children: []))\n      _ -> case xml_decode.parse(text) {\n        Ok(root) -> "
      <> decoder
      <> "(root)\n        Error(r) -> Error(r)\n      }\n    }\n    Error(_) -> Error(\"non-utf8 body\")\n  }\n}\n\n"
    }
  }
}

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
    RBlob -> "let payload = option.Some(body)"
    RPrim(primitive: types.PString) ->
      "use payload <- result.try(case bit_array.to_string(body) {\n      Ok(s) -> Ok(option.Some(s))\n      Error(_) -> Error(\"non-utf8 payload\")\n    })"
    RStruct(local_name: name, ..) -> {
      let decoder = "decode_" <> stringutils.pascal_to_snake(name) <> "_xml"
      "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case xml_decode.parse(text) {\n        Ok(root) -> case "
      <> decoder
      <> "(root) {\n          Ok(v) -> Ok(option.Some(v))\n          Error(r) -> Error(r)\n        }\n        Error(r) -> Error(r)\n      }\n    })"
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
  "//// Generated from " <> service_id <> " (restXml).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/credentials
import aws/internal/client/runtime as runtime
import aws/internal/codec/json_document
import aws/internal/codec/json_float
import aws/internal/codec/json_timestamp
import aws/internal/codec/rest
import aws/internal/codec/xml
import aws/internal/codec/xml_decode
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

/// Smithy protocol-test models live under `aws.protocoltests.*` —
/// the runner round-trips dispatcher params blobs through the
/// SDK's JSON `_struct_params` / `_union_params` / `_input`
/// decoders, so these have to be emitted. Real services
/// (`com.amazonaws.*`, etc.) only ever exercise the XML wire path,
/// so the JSON-side dispatcher codecs are dead weight there and
/// account for >30% of the prior LOC.
fn is_dispatcher_target(service_id: String) -> Bool {
  string.starts_with(service_id, "aws.protocoltests.")
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
