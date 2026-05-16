//// Code emitter for awsJson1_0 and awsJson1_1.
////
//// Walks a parsed `smithy.Model`, collects the transitive closure of
//// shapes referenced from each operation's input + output, then emits:
////
////   * One named-type definition (record / variant) per unique
////     structure / enum / union it encounters.
////   * Per-type JSON encoder + decoder helpers.
////   * Per-operation `<Op>Input` / `<Op>Output` records, an encoder
////     (input → JSON String), a decoder (JSON String → typed output),
////     and the `build_<op>_request` / `parse_<op>_response` pair.
////
//// Operations whose input or output transitively references an
//// `Unsupported` shape are skipped at the emitter level — they land in
//// the protocol-test runner's `skip_no_dispatcher` bucket rather than
//// producing broken Gleam.

import codegen/types.{
  type MemberDef, type Resolved, REnum, RIntEnum, RList, RMap, RStruct, RUnion,
}
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/set.{type Set}
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{ShapeId}
import smithy/trait

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
    Ok(shape.Service(operations: refs, traits: svc_traits, ..)) -> {
      let service_target = strip_namespace(service_id)
      let metadata = service_metadata(svc_traits, service_target)
      // Walk each operation's input / output; keep only ops whose
      // shapes resolve cleanly (no Unsupported anywhere). Each entry
      // also carries the operation's `errors` list (Smithy error
      // shape IDs) so the per-op typed-error enum can be emitted.
      let resolved_ops =
        list.filter_map(refs, fn(ref) {
          let ShapeId(target) = ref.target
          case model.lookup(model, target) {
            Ok(shape.Operation(
              input: in_ref,
              output: out_ref,
              errors: errs,
              traits: ts,
            )) ->
              case op_uses_unsupported_trait(ts) {
                True -> Error(Nil)
                False -> {
                  let ShapeId(in_id) = in_ref.target
                  let ShapeId(out_id) = out_ref.target
                  let in_r = resolve_or_unit(model, in_id)
                  let out_r = resolve_or_unit(model, out_id)
                  let err_ids =
                    list.map(errs, fn(r) {
                      let ShapeId(t) = r.target
                      t
                    })
                  case types.is_supported(in_r), types.is_supported(out_r) {
                    True, True -> Ok(#(target, in_r, out_r, err_ids))
                    _, _ -> Error(Nil)
                  }
                }
              }
            _ -> Error(Nil)
          }
        })

      let named_shapes = collect_named_shapes(model, resolved_ops)
      let preamble = emit_named_shapes(model, named_shapes)

      let op_specs =
        list.map(resolved_ops, fn(t) {
          let #(op_id, in_r, out_r, err_ids) = t
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
        list.map(op_specs, fn(spec) {
          emit_operation_with(spec, service_target, protocol)
        })
      let client_block = emit_client(metadata)
      let invoke_blocks = list.map(op_specs, emit_invoke)
      let body =
        file_header(service_id, protocol)
        <> "\n"
        <> client_block
        <> preamble
        <> list.fold(op_blocks, "", fn(acc, code) { acc <> code })
        <> list.fold(invoke_blocks, "", fn(acc, code) { acc <> code })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        operations_emitted: list.map(resolved_ops, fn(t) {
          let #(op_id, _, _, _) = t
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
    /// Full IDs of error shapes the operation can return. Used by the
    /// typed-error emitter to build `<Op>Error` variants and the
    /// `translate_<op>_error` dispatcher.
    error_ids: List(String),
  )
}

/// Extract per-service metadata from the service shape's traits.
/// `aws.api#service.endpointPrefix` and `aws.auth#sigv4.name` are
/// what the runtime needs to build endpoint URLs and sign requests.
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
    Ok(option.Some(trait.Dict(d))) ->
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

/// Build a Client given a credentials provider and an AWS region. The
/// generated module hard-codes the service's endpoint prefix and SigV4
/// signing name; everything else is configurable via the `with_*`
/// helpers below.
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

/// Override the endpoint URL (LocalStack, FIPS endpoints, custom DNS).
pub fn with_endpoint_url(client: Client, url: String) -> Client {
  Client(config: awsjson_client.with_endpoint_url(client.config, url))
}

/// Swap the HTTP transport — useful for canned-response test doubles.
pub fn with_http_send(
  client: Client,
  send: http_send.Send,
) -> Client {
  Client(config: awsjson_client.with_http_send(client.config, send))
}

"
}

fn emit_invoke(spec: OpSpec) -> String {
  "/// Invoke "
  <> spec.local
  <> ". Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `"
  <> spec.local
  <> "Error`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `"
  <> spec.local
  <> "ErrorTransport` variant.
pub fn "
  <> spec.snake
  <> "(
  client: Client,
  input: "
  <> spec.in_info.type_name
  <> ",
) -> Result("
  <> spec.out_info.type_name
  <> ", "
  <> spec.local
  <> "Error) {
  case awsjson_client.invoke(
    client.config,
    build_"
  <> spec.snake
  <> "_request(input),
    parse_"
  <> spec.snake
  <> "_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_"
  <> spec.snake
  <> "_error(err))
  }
}

"
}

fn resolve_or_unit(model: Model, id: String) -> Resolved {
  // `smithy.api#Unit` at the operation input/output position means "no
  // members"; we tag it as a synthetic struct with the sentinel
  // `local_name: "Unit"` so the op emitter knows to synthesise a per-op
  // empty record instead of referencing a non-existent shape.
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

// ---------- named-shape collection ----------

/// Walk the shape graph starting from each operation's input + output,
/// returning the list of unique named (struct / union / enum) shapes
/// that need their own type + codec emitted in the preamble. Cycle
/// detection via a seen-set keyed on the local Gleam name.
fn collect_named_shapes(
  model: Model,
  ops: List(#(String, Resolved, Resolved, List(String))),
) -> List(Resolved) {
  let init = #(set.new(), [])
  let #(_seen, found) =
    list.fold(ops, init, fn(acc, t) {
      let #(_op_id, in_r, out_r, err_ids) = t
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
      case is_seen(acc, name) {
        True -> acc
        False -> {
          // Mark BEFORE recursing — otherwise a cycle through the same
          // shape loops forever.
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

fn is_seen(acc: #(Set(String), List(Resolved)), name: String) -> Bool {
  set.contains(acc.0, name)
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
          // The synthetic Unit struct is per-operation, not a top-level
          // named type — skip in the preamble.
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

fn emit_operation_with(
  spec: OpSpec,
  service_target: String,
  protocol: Protocol,
) -> String {
  let snake = spec.snake
  let local_name = spec.local
  let target_value = service_target <> "." <> local_name
  let ct = content_type(protocol)
  let in_info = spec.in_info
  let out_info = spec.out_info
  emit_operation_body(snake, target_value, ct, in_info, out_info)
  <> emit_error_type(spec)
  <> emit_error_translator(spec)
}

/// Emit the per-operation typed-error sum type. One variant per error
/// shape on the operation, plus `Transport(reason: String)` for
/// non-service failures (network, decode, credentials) and
/// `Unknown(error_type, status, body)` for service errors we don't
/// have a typed variant for.
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

/// Emit `translate_<op>_error` — maps `awsjson_client.ClientError`
/// to the typed `<Op>Error` enum. Transport / decode / credentials
/// failures become the generic `Transport` variant. Service errors
/// dispatch on `error_type` (matched as a suffix to ignore namespace
/// prefixes the wire format may include) against the operation's
/// declared error shapes, falling through to `Unknown`.
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

fn emit_operation_body(
  snake: String,
  target_value: String,
  ct: String,
  in_info: IOTypeInfo,
  out_info: IOTypeInfo,
) -> String {
  // For Unit input/output we synthesise a singleton type + codec at the
  // op level. For named-struct sides we reuse the preamble's codec.
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

  // Encoder/Decoder helper names — point at either the named-shape
  // codec from the preamble, or the synthetic per-op codec above.
  let in_struct_encoder_name = case in_info.synthesise {
    True -> "encode_" <> snake <> "_input_struct"
    False ->
      "encode_"
      <> stringutils.pascal_to_snake(in_info.type_name)
      <> "_struct_top"
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

  // Use the member-keyed parallel decoder for `decode_<op>_input` —
  // protocol-test dispatchers pass `params` keyed by Smithy member
  // names. Synth-Unit inputs have no members, so their `_struct`
  // decoder works identically and gets re-used.
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

  let build = emit_build(in_info.type_name, snake, target_value, ct)
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

// ---------- encoder helpers ----------

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
  // Top-level operation-input encoder: same as `_struct` but skips
  // `@default` population. Per the AWS-Smithy protocols spec, clients
  // do NOT serialise top-level defaults on operation inputs — only
  // defaults on nested struct members.
  <> emit_struct_encoder_top(name, "encode_" <> snake <> "_struct_top", members)
  <> emit_struct_decoder(name, "decode_" <> snake <> "_struct", members)
  <> emit_struct_decoder_params(
    name,
    "decode_" <> snake <> "_struct_params",
    members,
  )
}

fn emit_struct_encoder_top(
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
        <> m.member_name
        <> "\", "
        <> types.json_encoder_member(m.target, m.timestamp_format)
        <> "(v)), ..pairs]\n    option.None -> pairs\n  }\n"
      })
      <> "  json.object(pairs)\n}\n\n"
  }
}

/// Parallel decoder keyed by Smithy member names rather than wire
/// names. Used by the protocol-test dispatchers, whose `params` field
/// is keyed by member identifiers and not by `@jsonName` overrides.
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
        <> types.json_decoder_member_params(m.target, m.timestamp_format)
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

/// Emit an encoder that takes a typed value and returns `json.Json`
/// (used as a building block inside parent encoders).
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
        let none_branch = case m.default_json {
          option.Some(expr) ->
            "[#(\"" <> m.member_name <> "\", " <> expr <> "), ..pairs]"
          option.None -> "pairs"
        }
        acc
        <> "  let pairs = case input."
        <> m.snake_name
        <> " {\n    option.Some(v) -> [#(\""
        <> m.member_name
        <> "\", "
        <> types.json_encoder_member(m.target, m.timestamp_format)
        <> "(v)), ..pairs]\n    option.None -> "
        <> none_branch
        <> "\n  }\n"
      })
      <> "  json.object(pairs)\n}\n\n"
  }
}

/// Emit a `Decoder(T)` function — used as a building block inside
/// parent decoders (for nested structs, list elements, map values).
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
        <> m.member_name
        <> "\", option.None, decode.optional("
        <> types.json_decoder_member(m.target, m.timestamp_format)
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
      <> m.member_name
      <> "\", "
      <> types.json_encoder(m.target)
      <> "(x))])\n"
    })
    <> "  }\n}\n\n"
  // Decoder: try each tagged-object branch in sequence.
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
    <> dec_params_body
    <> "}\n\n"
  enc <> dec <> dec_params
}

fn emit_union_branch(union_name: String, m: MemberDef) -> String {
  "decode.field(\""
  <> m.member_name
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

fn emit_build(
  input_type: String,
  snake: String,
  target_value: String,
  ct: String,
) -> String {
  "pub fn build_"
  <> snake
  <> "_request(\n  input: "
  <> input_type
  <> ",\n) -> #(String, String, dict.Dict(String, String), BitArray) {\n  let body_str = encode_"
  <> snake
  <> "_input(input)\n  let body = bit_array.from_string(body_str)\n  let headers =\n    dict.from_list([\n      #(\"Content-Type\", \""
  <> ct
  <> "\"),\n      #(\"Content-Length\", int.to_string(bit_array.byte_size(body))),\n      #(\"X-Amz-Target\", \""
  <> target_value
  <> "\"),\n    ])\n  #(\"POST\", \"/\", headers, body)\n}\n\n"
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

/// Operation-level traits the emitter doesn't yet honour. Emitting code
/// for these would produce wrong-on-the-wire requests.
fn op_uses_unsupported_trait(traits: shape.Traits) -> Bool {
  dict.has_key(traits, ShapeId("smithy.api#httpChecksumRequired"))
  || dict.has_key(traits, ShapeId("smithy.api#requestCompression"))
}

fn file_header(service_id: String, protocol: Protocol) -> String {
  let proto_str = case protocol {
    AwsJson10 -> "awsJson1_0"
    AwsJson11 -> "awsJson1_1"
  }
  "//// Generated from " <> service_id <> " (" <> proto_str <> ").
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/credentials
import aws/internal/client/awsjson as awsjson_client
import aws/internal/codec/json_document
import aws/internal/codec/json_float
import aws/internal/codec/json_timestamp
import aws/internal/http_send
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
"
}

// ---------- helpers ----------

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
