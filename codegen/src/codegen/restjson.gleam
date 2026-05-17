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
import codegen/rest_request
import codegen/struct_codec
import codegen/trait_helpers
import codegen/types.{
  type HttpTrait, type MemberDef, type Resolved, HttpTrait, Payload, RDocument,
  REnum, RIntEnum, RList, RMap, RPrim, RStruct, RUnion,
}
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{ShapeId}
import smithy/trait

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
    Error(_) -> Error(string.concat(["service not found: ", service_id]))
    Ok(shape.Service(operations: refs, traits: svc_traits, ..)) -> {
      let service_local = strip_namespace(service_id)
      let metadata = trait_helpers.service_metadata(svc_traits, service_local)
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
                  let requires_md5 = trait_helpers.op_requires_md5(op_traits)
                  case
                    members_have_no_http_bindings(in_r),
                    types.is_supported(in_r),
                    types.is_supported(out_r)
                  {
                    True, True, True ->
                      Ok(#(target, http, in_r, out_r, err_ids, requires_md5))
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
          let #(op_id, http, in_r, out_r, err_ids, requires_md5) = t
          #(
            op_id,
            http,
            types.apply_rename(in_r, rename),
            types.apply_rename(out_r, rename),
            err_ids,
            requires_md5,
          )
        })
      let named_shapes = collect_named_shapes(model, resolved_ops)
      let named_shapes =
        list.map(named_shapes, fn(r) { types.apply_rename(r, rename) })
      let preamble = emit_named_shapes(model, named_shapes, rename)

      let op_specs =
        list.map(resolved_ops, fn(t) {
          let #(op_id, _, in_r, out_r, err_ids, _) = t
          let local = strip_namespace(op_id)
          let snake = stringutils.pascal_to_snake(local)
          let in_info =
            resolve_io_type(model, name_concat([local, "Input"]), in_r, rename)
          let out_info =
            resolve_io_type(
              model,
              name_concat([local, "Output"]),
              out_r,
              rename,
            )
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
          let #(op_id, http, in_r, out_r, _, requires_md5) = t
          emit_operation(model, op_id, http, in_r, out_r, rename, requires_md5)
        })
      let client_block = emit_client(metadata)
      let invoke_blocks = list.map(op_specs, emit_invoke)
      let error_blocks =
        list.map(op_specs, fn(spec) {
          string.concat([emit_error_type(spec), emit_error_translator(spec)])
        })
      let body_content =
        string.concat([
          client_block,
          preamble,
          string.concat(op_blocks),
          string.concat(error_blocks),
          string.concat(invoke_blocks),
        ])
      let body =
        string.concat([
          file_header(service_id, body_content),
          "\n",
          body_content,
        ])
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
          let #(op_id, _, _, _, _, _) = t
          op_id
        }),
        dispatcher_specs: dispatcher_specs,
      ))
    }
    Ok(_) -> Error(string.concat(["not a service: ", service_id]))
  }
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

// `Metadata`, `service_metadata`, `string_field_under` live in
// `codegen/trait_helpers.gleam` — see Pass 4 in plan.md.

fn emit_client(metadata: trait_helpers.Metadata) -> String {
  client.render(
    metadata.endpoint_prefix,
    metadata.signing_name,
    metadata.endpoint_rule_set_json,
  )
}

fn emit_invoke(spec: OpSpec) -> String {
  code.render(
    code.Module(items: [
      client.invoke_fn(
        spec.snake,
        spec.local,
        spec.in_info.type_name,
        spec.out_info.type_name,
      ),
      code.Blank,
    ]),
  )
}

/// Per-op typed-error enum. One variant per error shape on the
/// operation, plus `Transport` and `Unknown` fall-backs. Mirrors the
/// awsjson emitter — restJson1 errors are still JSON-shaped on the
/// wire, so the same decoder path works.
fn emit_error_type(spec: OpSpec) -> String {
  let name = name_concat([spec.local, "Error"])
  let typed_variants =
    list.map(spec.error_ids, fn(err_id) {
      let local = strip_namespace(err_id)
      code.Variant(name: name_concat([name, local]), fields: [
        code.Param(name: "value", type_: local),
      ])
    })
  let fallback_variants = [
    code.Variant(name: name_concat([name, "Transport"]), fields: [
      code.Param(name: "reason", type_: "String"),
    ]),
    code.Variant(name: name_concat([name, "Unknown"]), fields: [
      code.Param(name: "error_type", type_: "String"),
      code.Param(name: "status", type_: "Int"),
      code.Param(name: "body", type_: "String"),
    ]),
  ]
  code.render(
    code.Module(items: [
      code.TypeDef(
        public: True,
        is_opaque: False,
        name: name,
        variants: list.append(typed_variants, fallback_variants),
      ),
      code.Blank,
    ]),
  )
}

/// See `awsjson.emit_error_translator` for the table-style design.
fn emit_error_translator(spec: OpSpec) -> String {
  let name = name_concat([spec.local, "Error"])
  let snake = spec.snake
  let decoder_entries =
    list.map(spec.error_ids, fn(err_id) {
      let local = strip_namespace(err_id)
      let err_snake = stringutils.pascal_to_snake(local)
      code.Tuple(items: [
        code.StrLit(value: local),
        code.Raw(fragment: error_decoder_lambda(err_snake, name, local)),
      ])
    })
  let decoders_fn =
    code.Fn(
      public: False,
      name: name_concat([snake, "_error_decoders"]),
      params: [],
      return: code.CodeNone,
      body: code.ListLit(items: decoder_entries, tail: code.CodeNone),
    )
  let translate_fn =
    code.Fn(
      public: False,
      name: name_concat(["translate_", snake, "_error"]),
      params: [code.Param(name: "err", type_: "runtime.ClientError")],
      return: code.CodeSome(name),
      body: code.Call(
        head: code.Ident(name: "runtime.translate_service_error"),
        args: [
          code.Ident(name: "err"),
          code.Call(
            head: code.Ident(name: name_concat([snake, "_error_decoders"])),
            args: [],
          ),
          code.Raw(
            fragment: name_concat([
              "fn(reason) { ",
              name,
              "Transport(reason: reason) }",
            ]),
          ),
          code.Raw(
            fragment: name_concat([
              "fn(et, s, body) { ",
              name,
              "Unknown(error_type: et, status: s, body: body) }",
            ]),
          ),
        ],
      ),
    )
  code.render(
    code.Module(items: [decoders_fn, code.Blank, translate_fn, code.Blank]),
  )
}

/// Multi-line per-error decoder closure for the table emitted by
/// `<op>_error_decoders()`. Body decodes the JSON, then wraps in
/// the op's error sum-type variant.
fn error_decoder_lambda(
  err_snake: String,
  error_name: String,
  local: String,
) -> String {
  string.concat([
    "fn(body) {\n      case json.parse(body, decode_",
    err_snake,
    "_struct()) {\n        Ok(v) -> Ok(",
    error_name,
    local,
    "(value: v))\n        Error(_) -> Error(Nil)\n      }\n    }",
  ])
}

fn resolve_or_unit(model: Model, id: String) -> Resolved {
  case id {
    "smithy.api#Unit" ->
      RStruct(
        local_name: "Unit",
        gleam_name: "Unit",
        full_id: "smithy.api#Unit",
        xml_name: option.None,
        xml_namespace: option.None,
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
  ops: List(#(String, HttpTrait, Resolved, Resolved, List(String), Bool)),
) -> List(Resolved) {
  // Dedup keyed by `full_id` so two shapes with the same local name in
  // different namespaces both make it into the named-shape list. The
  // rename map (built in `emit_service`) ensures the resulting Gleam
  // type names are unique on emission.
  let init = #(set.new(), [])
  let #(_seen, found) =
    list.fold(ops, init, fn(acc, t) {
      let #(_, _, in_r, out_r, err_ids, _) = t
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
  shapes
  |> list.flat_map(fn(r) {
    case r {
      REnum(gleam_name: n, variants: vs, ..) -> [
        emit_enum_def(n, vs),
        emit_enum_codec(n, vs),
      ]
      RIntEnum(gleam_name: n, variants: vs, ..) -> [
        emit_int_enum_def(n, vs),
        emit_int_enum_codec(n, vs),
      ]
      RStruct(gleam_name: n, full_id: id, local_name: ln, ..) ->
        case ln == "Unit" {
          True -> []
          False -> {
            let ms =
              types.resolve_members(model, id)
              |> list.map(fn(m) { types.apply_rename_member(m, rename) })
            [emit_record_def(n, ms), emit_struct_codec(n, ms)]
          }
        }
      RUnion(gleam_name: n, full_id: id, ..) -> {
        let ms =
          types.resolve_members(model, id)
          |> list.map(fn(m) { types.apply_rename_member(m, rename) })
        [emit_union_def(n, ms), emit_union_codec(n, ms)]
      }
      _ -> []
    }
  })
  |> string.concat
}

// ---------- per-operation emission ----------

fn emit_operation(
  model: Model,
  op_id: String,
  http: HttpTrait,
  in_r: Resolved,
  out_r: Resolved,
  rename: dict.Dict(String, String),
  requires_md5: Bool,
) -> String {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let in_info =
    resolve_io_type(model, name_concat([pascal, "Input"]), in_r, rename)
  let out_info =
    resolve_io_type(model, name_concat([pascal, "Output"]), out_r, rename)

  let synth_in = synth_io_def(snake, in_info, "input")
  let synth_out = synth_io_def(snake, out_info, "output")
  let in_struct_encoder_name = io_codec_name("encode", snake, in_info, "input")
  let out_struct_decoder_name =
    io_codec_name("decode", snake, out_info, "output")
  let in_encoder =
    code.render(
      code.Module(items: [
        code.Fn(
          public: True,
          name: name_concat(["encode_", snake, "_input"]),
          params: [code.Param(name: "input", type_: in_info.type_name)],
          return: code.CodeSome("String"),
          body: code.Call(head: code.Ident(name: "json.to_string"), args: [
            code.Call(head: code.Ident(name: in_struct_encoder_name), args: [
              code.Ident(name: "input"),
            ]),
          ]),
        ),
        code.Blank,
      ]),
    )
  // `decode_<op>_input` is the entry point used by the Smithy
  // protocol-test dispatchers — Smithy's `params` is keyed by member
  // name, not wire name (`@jsonName`). Use the member-keyed parallel
  // decoder so dispatcher params round-trip into typed structs.
  let in_decoder =
    emit_parse_via_decoder(
      name_concat(["decode_", snake, "_input"]),
      in_info.type_name,
      case in_info.synthesise {
        True -> name_concat(["decode_", snake, "_input_struct"])
        False ->
          name_concat([
            "decode_",
            stringutils.pascal_to_snake(in_info.type_name),
            "_struct_params",
          ])
      },
    )
  let out_decoder =
    emit_parse_via_decoder(
      name_concat(["decode_", snake, "_output"]),
      out_info.type_name,
      out_struct_decoder_name,
    )
  let in_members = in_info.members
  let body_members = types.categorize_bindings(in_members).body
  let body_encoder = emit_body_encoder(snake, in_info.type_name, body_members)
  let build =
    emit_build(
      in_info.type_name,
      in_info.synthesise,
      snake,
      http,
      in_members,
      requires_md5,
    )
  let parse = emit_parse(out_info, snake)
  string.concat([
    "\n",
    synth_in,
    synth_out,
    in_encoder,
    in_decoder,
    out_decoder,
    body_encoder,
    build,
    parse,
  ])
}

fn emit_parse_via_decoder(
  fn_name: String,
  type_name: String,
  decoder_fn: String,
) -> String {
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: fn_name,
        params: [code.Param(name: "body", type_: "String")],
        return: code.CodeSome(name_concat(["Result(", type_name, ", String)"])),
        body: code.Case(
          scrutinee: code.Call(head: code.Ident(name: "json.parse"), args: [
            code.Ident(name: "body"),
            code.Call(head: code.Ident(name: decoder_fn), args: []),
          ]),
          branches: [
            code.Branch(
              pattern: "Ok(v)",
              body: code.Call(head: code.Ident(name: "Ok"), args: [
                code.Ident(name: "v"),
              ]),
            ),
            code.Branch(
              pattern: "Error(_)",
              body: code.Call(head: code.Ident(name: "Error"), args: [
                code.StrLit(value: "decode failed"),
              ]),
            ),
          ],
        ),
      ),
      code.Blank,
    ]),
  )
}

type IOTypeInfo {
  IOTypeInfo(type_name: String, members: List(MemberDef), synthesise: Bool)
}

/// Emit the synthetic record def + encoder + decoder for a unit-typed
/// I/O when `info.synthesise` is set. `direction` is `"input"` or
/// `"output"`; it parameterises the generated function names.
fn synth_io_def(snake: String, info: IOTypeInfo, direction: String) -> String {
  case info.synthesise {
    True ->
      string.concat([
        emit_record_def(info.type_name, []),
        code.render(struct_codec.encoder(
          name_concat(["encode_", snake, "_", direction, "_struct"]),
          info.type_name,
          [],
          False,
          False,
        )),
        "\n",
        code.render(struct_codec.decoder(
          name_concat(["decode_", snake, "_", direction, "_struct"]),
          info.type_name,
          [],
          False,
          False,
        )),
        "\n",
      ])
    False -> ""
  }
}

/// Resolve the codec function name for an operation I/O. For synthetic
/// (Unit) I/O the name is per-operation (`encode_<snake>_input_struct`);
/// for named structs it derives from the struct's type name
/// (`encode_<type_snake>_struct`). `action` is `"encode"` or `"decode"`.
fn io_codec_name(
  action: String,
  snake: String,
  info: IOTypeInfo,
  direction: String,
) -> String {
  case info.synthesise {
    True -> name_concat([action, "_", snake, "_", direction, "_struct"])
    False ->
      name_concat([
        action,
        "_",
        stringutils.pascal_to_snake(info.type_name),
        "_struct",
      ])
  }
}

fn resolve_io_type(
  model: Model,
  synth_name: String,
  r: Resolved,
  rename: dict.Dict(String, String),
) -> IOTypeInfo {
  case r {
    RStruct(local_name: ln, gleam_name: gn, full_id: id, ..) ->
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
  string.concat([code.render(named_shapes.record_def(name, members)), "\n"])
}

fn emit_enum_def(name: String, variants: List(types.EnumVariant)) -> String {
  string.concat([code.render(named_shapes.enum_def(name, variants)), "\n"])
}

fn emit_int_enum_def(
  name: String,
  variants: List(types.IntEnumVariant),
) -> String {
  string.concat([code.render(named_shapes.int_enum_def(name, variants)), "\n"])
}

fn emit_union_def(name: String, members: List(MemberDef)) -> String {
  string.concat([code.render(named_shapes.union_def(name, members)), "\n"])
}

// ---------- codec helpers ----------

fn emit_enum_codec(name: String, variants: List(types.EnumVariant)) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let first_ctor = case variants {
    [v, ..] -> v.gleam_ctor
    [] -> name_concat([name, "Unknown"])
  }
  let enc =
    code.Fn(
      public: True,
      name: name_concat(["encode_", snake, "_enum"]),
      params: [code.Param(name: "v", type_: name)],
      return: code.CodeSome("json.Json"),
      body: code.Case(
        scrutinee: code.Ident(name: "v"),
        branches: list.map(variants, fn(v) {
          code.Branch(
            pattern: v.gleam_ctor,
            body: code.Call(head: code.Ident(name: "json.string"), args: [
              code.StrLit(value: v.wire_value),
            ]),
          )
        }),
      ),
    )
  let dec =
    code.Fn(
      public: True,
      name: name_concat(["decode_", snake, "_enum"]),
      params: [],
      return: code.CodeSome(name_concat(["decode.Decoder(", name, ")"])),
      body: code.Call(head: code.Ident(name: "decode.then"), args: [
        code.Ident(name: "decode.string"),
        enum_decode_lambda(variants, first_ctor),
      ]),
    )
  code.render(code.Module(items: [enc, code.Blank, dec, code.Blank]))
}

/// `fn(s) { case s { ... } }` lambda body for the decoder. Stays
/// as `code.Raw` since the AST has no anonymous-function node.
fn enum_decode_lambda(
  variants: List(types.EnumVariant),
  first_ctor: String,
) -> code.Code {
  let arms =
    list.map(variants, fn(v) {
      string.concat([
        "      \"",
        v.wire_value,
        "\" -> decode.success(",
        v.gleam_ctor,
        ")\n",
      ])
    })
  let fallback =
    string.concat([
      "      _ -> decode.failure(",
      first_ctor,
      ", \"unknown enum value\")\n    }\n  }",
    ])
  code.Raw(
    fragment: string.concat([
      "fn(s) {\n    case s {\n",
      string.concat(arms),
      fallback,
    ]),
  )
}

fn emit_int_enum_codec(
  name: String,
  variants: List(types.IntEnumVariant),
) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let first_ctor = case variants {
    [v, ..] -> v.gleam_ctor
    [] -> name_concat([name, "Unknown"])
  }
  // Plain-int extractor — used by query/header/URI-label emitters
  // that need the wire integer value, not a wrapped json.Json.
  let int_value =
    code.Fn(
      public: True,
      name: name_concat([snake, "_int_value"]),
      params: [code.Param(name: "v", type_: name)],
      return: code.CodeSome("Int"),
      body: code.Case(
        scrutinee: code.Ident(name: "v"),
        branches: list.map(variants, fn(v) {
          code.Branch(
            pattern: v.gleam_ctor,
            body: code.IntLit(value: v.wire_value),
          )
        }),
      ),
    )
  let enc =
    code.Fn(
      public: True,
      name: name_concat(["encode_", snake, "_int_enum"]),
      params: [code.Param(name: "v", type_: name)],
      return: code.CodeSome("json.Json"),
      body: code.Case(
        scrutinee: code.Ident(name: "v"),
        branches: list.map(variants, fn(v) {
          code.Branch(
            pattern: v.gleam_ctor,
            body: code.Call(head: code.Ident(name: "json.int"), args: [
              code.IntLit(value: v.wire_value),
            ]),
          )
        }),
      ),
    )
  let dec =
    code.Fn(
      public: True,
      name: name_concat(["decode_", snake, "_int_enum"]),
      params: [],
      return: code.CodeSome(name_concat(["decode.Decoder(", name, ")"])),
      body: code.Call(head: code.Ident(name: "decode.then"), args: [
        code.Ident(name: "decode.int"),
        int_enum_decode_lambda(variants, first_ctor),
      ]),
    )
  code.render(
    code.Module(items: [
      int_value,
      code.Blank,
      enc,
      code.Blank,
      dec,
      code.Blank,
    ]),
  )
}

/// `fn(n) { case n { ... } }` lambda body for the int-enum
/// decoder. Same pattern as `enum_decode_lambda`.
fn int_enum_decode_lambda(
  variants: List(types.IntEnumVariant),
  first_ctor: String,
) -> code.Code {
  let arms =
    list.map(variants, fn(v) {
      string.concat([
        "      ",
        stringutils.int_to_string(v.wire_value),
        " -> decode.success(",
        v.gleam_ctor,
        ")\n",
      ])
    })
  let fallback =
    string.concat([
      "      _ -> decode.failure(",
      first_ctor,
      ", \"unknown int enum value\")\n    }\n  }",
    ])
  code.Raw(
    fragment: string.concat([
      "fn(n) {\n    case n {\n",
      string.concat(arms),
      fallback,
    ]),
  )
}

fn emit_struct_codec(name: String, members: List(MemberDef)) -> String {
  let snake = stringutils.pascal_to_snake(name)
  // restJson1 honours `@jsonName`, so the encoder + main decoder
  // use the wire key (`m.json_name`). The `_params` decoder is
  // member-keyed so the dispatcher's params blob can address the
  // Smithy member names regardless of `@jsonName`.
  [
    struct_codec.encoder(
      name_concat(["encode_", snake, "_struct"]),
      name,
      members,
      False,
      False,
    ),
    struct_codec.decoder(
      name_concat(["decode_", snake, "_struct"]),
      name,
      members,
      False,
      False,
    ),
    struct_codec.decoder(
      name_concat(["decode_", snake, "_struct_params"]),
      name,
      members,
      True,
      True,
    ),
  ]
  |> list.map(code.render)
  |> list.map(fn(s) { string.concat([s, "\n"]) })
  |> string.concat
}

fn emit_union_codec(name: String, members: List(MemberDef)) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let enc =
    code.Fn(
      public: True,
      name: name_concat(["encode_", snake, "_union"]),
      params: [code.Param(name: "v", type_: name)],
      return: code.CodeSome("json.Json"),
      body: code.Case(
        scrutinee: code.Ident(name: "v"),
        branches: list.map(members, fn(m) {
          let ctor =
            name_concat([name, stringutils.pascalize_member(m.member_name)])
          code.Branch(
            pattern: name_concat([ctor, "(x)"]),
            body: code.Call(head: code.Ident(name: "json.object"), args: [
              code.ListLit(
                items: [
                  code.Tuple(items: [
                    code.StrLit(value: m.json_name),
                    code.Call(
                      head: code.Ident(name: types.json_encoder(m.target)),
                      args: [code.Ident(name: "x")],
                    ),
                  ]),
                ],
                tail: code.CodeNone,
              ),
            ]),
          )
        }),
      ),
    )
  let dec =
    code.Fn(
      public: True,
      name: name_concat(["decode_", snake, "_union"]),
      params: [],
      return: code.CodeSome(name_concat(["decode.Decoder(", name, ")"])),
      body: union_decoder_body(name, members, emit_union_branch),
    )
  // Parallel decoder keyed by member names — used by the protocol-test
  // dispatchers. Unions in `params` have variant tags identified by
  // Smithy member names (lowercase `foo`), while the wire form uses
  // `@jsonName` overrides (uppercase `FOO`).
  let dec_params =
    code.Fn(
      public: True,
      name: name_concat(["decode_", snake, "_union_params"]),
      params: [],
      return: code.CodeSome(name_concat(["decode.Decoder(", name, ")"])),
      body: union_decoder_body(name, members, emit_union_branch_params),
    )
  code.render(
    code.Module(items: [
      enc,
      code.Blank,
      dec,
      code.Blank,
      dec_params,
      code.Blank,
    ]),
  )
}

/// Build the body of a `decode_<U>_union*` function — a
/// `decode.one_of` over the branch decoders, or an unconditional
/// failure when the union has no variants. Wrapped in
/// `decode.recursive` since unions can self-reference (Smithy's
/// `XmlUnionShape.unionValue: XmlUnionShape` cycle).
fn union_decoder_body(
  name: String,
  members: List(MemberDef),
  branch_fn: fn(String, MemberDef) -> code.Code,
) -> code.Code {
  case members {
    [] ->
      code.Call(head: code.Ident(name: "decode.failure"), args: [
        code.Ident(name: name_concat([name, "Empty"])),
        code.StrLit(value: "empty union"),
      ])
    [first, ..rest] ->
      code.Block(items: [
        code.Use(name: "", callee: code.Ident(name: "decode.recursive")),
        code.Call(head: code.Ident(name: "decode.one_of"), args: [
          branch_fn(name, first),
          code.ListLit(
            items: list.map(rest, fn(m) { branch_fn(name, m) }),
            tail: code.CodeNone,
          ),
        ]),
      ])
  }
}

fn emit_union_branch(union_name: String, m: MemberDef) -> code.Code {
  let ctor =
    name_concat([union_name, stringutils.pascalize_member(m.member_name)])
  code.Call(head: code.Ident(name: "decode.field"), args: [
    code.StrLit(value: m.json_name),
    code.Raw(fragment: types.json_decoder(m.target)),
    code.Raw(fragment: name_concat(["fn(x) { decode.success(", ctor, "(x)) }"])),
  ])
}

fn emit_union_branch_params(union_name: String, m: MemberDef) -> code.Code {
  let ctor =
    name_concat([union_name, stringutils.pascalize_member(m.member_name)])
  code.Call(head: code.Ident(name: "decode.field"), args: [
    code.StrLit(value: m.member_name),
    code.Raw(fragment: types.json_decoder_params(m.target)),
    code.Raw(fragment: name_concat(["fn(x) { decode.success(", ctor, "(x)) }"])),
  ])
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
  requires_md5: Bool,
) -> String {
  rest_request.build_request_module(
    input_type,
    is_unit,
    snake,
    http,
    members,
    requires_md5,
    fn(cats: types.BindingCategories) {
      case cats.payload {
        Ok(p) -> emit_payload_body(p)
        Error(_) -> json_body_setup(snake, cats.body)
      }
    },
  )
}

fn json_body_setup(snake: String, body: List(MemberDef)) -> List(code.Code) {
  case body {
    [] -> [
      code.Let(name: "body", value: code.Raw(fragment: "<<>>")),
      code.Let(name: "content_type", value: code.StrLit(value: "")),
    ]
    _ -> [
      code.Let(
        name: "body_json",
        value: code.Call(
          head: code.Ident(name: name_concat(["encode_", snake, "_body"])),
          args: [code.Ident(name: "input")],
        ),
      ),
      code.Let(
        name: "body",
        value: code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
          code.Call(head: code.Ident(name: "json.to_string"), args: [
            code.Ident(name: "body_json"),
          ]),
        ]),
      ),
      code.Let(
        name: "content_type",
        value: code.StrLit(value: "application/json"),
      ),
    ]
  }
}

/// Build a Gleam identifier name from a list of parts. Used in
/// place of the `<>` operator throughout codegen so the Gleam
/// source of the emitters doesn't itself use string concat to
/// shape the generated identifiers.
fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

fn emit_payload_body(m: MemberDef) -> List(code.Code) {
  // @httpPayload — the member's value IS the body. For blob members
  // the body is the raw bytes; for struct/string members it's the
  // JSON-encoded value; for primitive strings, the raw string.
  // `@mediaType` (on the member or its target shape) overrides
  // Content-Type for opaque-payload members.
  let blob_ct = case m.media_type {
    Some(s) -> s
    None -> "application/octet-stream"
  }
  let string_ct = case m.media_type {
    Some(s) -> s
    None -> "text/plain"
  }
  let #(some_expr, none_expr, content_type) = case m.target {
    types.RBlob -> #(code.Ident(name: "v"), code.Raw(fragment: "<<>>"), blob_ct)
    RPrim(primitive: types.PString) -> #(
      code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.Ident(name: "v"),
      ]),
      code.Raw(fragment: "<<>>"),
      string_ct,
    )
    REnum(..) -> #(
      code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.Call(head: code.Ident(name: "rest.enum_wire_value"), args: [
          code.Call(head: code.Ident(name: types.json_encoder(m.target)), args: [
            code.Ident(name: "v"),
          ]),
        ]),
      ]),
      code.Raw(fragment: "<<>>"),
      string_ct,
    )
    RStruct(..) -> #(
      json_payload_some_expr(m.target),
      code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.StrLit(value: "{}"),
      ]),
      "application/json",
    )
    _ -> #(
      json_payload_some_expr(m.target),
      code.Raw(fragment: "<<>>"),
      "application/json",
    )
  }
  let body_stmt =
    code.Let(
      name: "body",
      value: code.Case(
        scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
        branches: [
          code.Branch(pattern: "option.Some(v)", body: some_expr),
          code.Branch(pattern: "option.None", body: none_expr),
        ],
      ),
    )
  let ct_stmt =
    code.Let(name: "content_type", value: code.StrLit(value: content_type))
  [body_stmt, ct_stmt]
}

fn json_payload_some_expr(target: Resolved) -> code.Code {
  code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
    code.Call(head: code.Ident(name: "json.to_string"), args: [
      code.Call(head: code.Ident(name: types.json_encoder(target)), args: [
        code.Ident(name: "v"),
      ]),
    ]),
  ])
}

/// Emit a per-op body encoder that ONLY includes Body-bound members.
/// Generated as a separate function so the operation's URI/query/
/// header members don't double-encode into the JSON body.
fn emit_body_encoder(
  snake: String,
  input_type: String,
  body_members: List(MemberDef),
) -> String {
  let fn_name = name_concat(["encode_", snake, "_body"])
  let #(param_name, body) = case body_members {
    [] -> #(
      "_input",
      code.Call(head: code.Ident(name: "json.object"), args: [
        code.ListLit(items: [], tail: code.CodeNone),
      ]),
    )
    _ -> {
      let initial =
        code.Let(
          name: "pairs",
          value: code.ListLit(items: [], tail: code.CodeNone),
        )
      let updates =
        list.map(body_members, fn(m) {
          code.Let(
            name: "pairs",
            value: code.Case(
              scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
              branches: [
                code.Branch(
                  pattern: "option.Some(v)",
                  body: code.ListLit(
                    items: [
                      code.Tuple(items: [
                        code.StrLit(value: m.json_name),
                        code.Call(
                          head: code.Ident(name: types.json_encoder_member(
                            m.target,
                            m.timestamp_format,
                          )),
                          args: [code.Ident(name: "v")],
                        ),
                      ]),
                    ],
                    tail: code.CodeSome(code.Ident(name: "pairs")),
                  ),
                ),
                code.Branch(
                  pattern: "option.None",
                  body: code.Ident(name: "pairs"),
                ),
              ],
            ),
          )
        })
      let tail =
        code.Call(head: code.Ident(name: "json.object"), args: [
          code.Ident(name: "pairs"),
        ])
      #("input", code.Block(items: list.append([initial, ..updates], [tail])))
    }
  }
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: fn_name,
        params: [code.Param(name: param_name, type_: input_type)],
        return: code.CodeSome("json.Json"),
        body: body,
      ),
      code.Blank,
    ]),
  )
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
      code.render(
        code.Module(items: [
          code.Fn(
            public: True,
            name: name_concat(["parse_", snake, "_response"]),
            params: parse_response_params("_body"),
            return: code.CodeSome(
              name_concat(["Result(", output_type, ", String)"]),
            ),
            body: code.Call(head: code.Ident(name: "Ok"), args: [
              code.Ident(name: output_type),
            ]),
          ),
          code.Blank,
        ]),
      )
    Ok(p), False -> emit_parse_with_payload(out_info, snake, p)
    Error(_), False ->
      code.render(
        code.Module(items: [
          code.Fn(
            public: True,
            name: name_concat(["parse_", snake, "_response"]),
            params: parse_response_params("body"),
            return: code.CodeSome(
              name_concat(["Result(", output_type, ", String)"]),
            ),
            body: code.Case(
              scrutinee: code.Call(
                head: code.Ident(name: "bit_array.to_string"),
                args: [code.Ident(name: "body")],
              ),
              branches: [
                code.Branch(
                  pattern: "Ok(text)",
                  body: code.Case(
                    scrutinee: code.Ident(name: "text"),
                    branches: [
                      code.Branch(
                        pattern: "\"\"",
                        body: code.Call(
                          head: code.Ident(
                            name: name_concat(["decode_", snake, "_output"]),
                          ),
                          args: [code.StrLit(value: "{}")],
                        ),
                      ),
                      code.Branch(
                        pattern: "_",
                        body: code.Call(
                          head: code.Ident(
                            name: name_concat(["decode_", snake, "_output"]),
                          ),
                          args: [code.Ident(name: "text")],
                        ),
                      ),
                    ],
                  ),
                ),
                code.Branch(
                  pattern: "Error(_)",
                  body: code.Call(head: code.Ident(name: "Error"), args: [
                    code.StrLit(value: "non-utf8 body"),
                  ]),
                ),
              ],
            ),
          ),
          code.Blank,
        ]),
      )
  }
}

fn parse_response_params(body_param: String) -> List(code.Param) {
  [
    code.Param(name: "_code", type_: "Int"),
    code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
    code.Param(name: body_param, type_: "BitArray"),
  ]
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
  let ctor_args =
    list.map(out_info.members, fn(m) {
      let value = case m.snake_name == payload.snake_name {
        True -> code.Ident(name: "payload")
        False -> code.Ident(name: "option.None")
      }
      code.Labelled(label: m.snake_name, value: value)
    })
  let payload_decode = case payload.target {
    types.RBlob ->
      code.Let(
        name: "payload",
        value: code.Call(head: code.Ident(name: "option.Some"), args: [
          code.Ident(name: "body"),
        ]),
      )
    RPrim(primitive: types.PString) ->
      code.Use(
        name: "payload",
        callee: code.Raw(
          fragment: "result.try(case bit_array.to_string(body) {\n      Ok(s) -> Ok(option.Some(s))\n      Error(_) -> Error(\"non-utf8 payload\")\n    })",
        ),
      )
    RStruct(local_name: name, ..) -> {
      let decoder =
        name_concat(["decode_", stringutils.pascal_to_snake(name), "_struct"])
      code.Raw(
        fragment: string.concat([
          "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case json.parse(text, ",
          decoder,
          "()) {\n        Ok(v) -> Ok(option.Some(v))\n        Error(_) -> Error(\"decode failed\")\n      }\n    })",
        ]),
      )
    }
    RDocument ->
      code.Raw(
        fragment: "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case json.parse(text, decode.dynamic) {\n        Ok(d) -> Ok(option.Some(json_document.from_dynamic(d)))\n        Error(_) -> Error(\"decode failed\")\n      }\n    })",
      )
    REnum(local_name: name, ..) -> {
      let decoder =
        name_concat(["decode_", stringutils.pascal_to_snake(name), "_enum"])
      code.Raw(
        fragment: string.concat([
          "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case json.parse(string.concat([\"\\\"\", text, \"\\\"\"]), ",
          decoder,
          "()) {\n        Ok(v) -> Ok(option.Some(v))\n        Error(_) -> Error(\"decode failed\")\n      }\n    })",
        ]),
      )
    }
    _ -> code.Let(name: "payload", value: code.Ident(name: "option.None"))
  }
  // Payload bindings that fall through to `option.None` (e.g. Union
  // payloads, not yet implemented) leave `body` unused — bind as
  // `_body` to silence the warning.
  let payload_fragment = case payload_decode {
    code.Raw(fragment: f) -> f
    other -> code.render(other)
  }
  let body_param = case string.contains(payload_fragment, "body") {
    True -> "body"
    False -> "_body"
  }
  let inner =
    code.Block(items: [
      payload_decode,
      code.Call(head: code.Ident(name: "Ok"), args: [
        code.Call(head: code.Ident(name: output_type), args: ctor_args),
      ]),
    ])
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: name_concat(["parse_", snake, "_response"]),
        params: [
          code.Param(name: "_code", type_: "Int"),
          code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
          code.Param(name: body_param, type_: "BitArray"),
        ],
        return: code.CodeSome(
          name_concat(["Result(", output_type, ", String)"]),
        ),
        body: code.Block(items: [inner]),
      ),
      code.Blank,
    ]),
  )
}

/// See `awsjson.file_header` for the design — body-scan picks the
/// subset of candidate imports actually referenced.
fn file_header(service_id: String, body: String) -> String {
  let candidates = [
    #("aws/credentials", "credentials.", code.CodeNone),
    #("aws/endpoints", "endpoints.", code.CodeNone),
    #("aws/internal/credentials_cache", "credentials_cache.", code.CodeNone),
    #("aws/region", "region.", code.CodeNone),
    #("aws/internal/client/runtime", "runtime.", code.CodeSome("runtime")),
    #("aws/internal/codec/json_document", "json_document.", code.CodeNone),
    #("aws/internal/codec/json_float", "json_float.", code.CodeNone),
    #("aws/internal/codec/json_timestamp", "json_timestamp.", code.CodeNone),
    #("aws/internal/codec/rest", "rest.", code.CodeNone),
    #("aws/internal/http_send", "http_send.", code.CodeNone),
    #("gleam/bit_array", "bit_array.", code.CodeNone),
    #("gleam/dict", "dict.", code.CodeNone),
    #("gleam/dynamic/decode", "decode.", code.CodeNone),
    #("gleam/int", "int.", code.CodeNone),
    #("gleam/json", "json.", code.CodeNone),
    #("gleam/list", "list.", code.CodeNone),
    #("gleam/option", "option.", code.CodeNone),
    #("gleam/result", "result.", code.CodeNone),
    #("gleam/string", "string.", code.CodeNone),
  ]
  let used =
    candidates
    |> list.filter(fn(c) { code.references_module(body, c.1) })
    |> list.map(fn(c) { code.Import(path: c.0, alias: c.2, unqualified: []) })
  let items =
    [
      code.ModuleDocComment([
        name_concat(["Generated from ", service_id, " (restJson1)."]),
        "DO NOT EDIT. Re-generate via the codegen subproject.",
      ]),
      code.Blank,
    ]
    |> list.append(used)
  code.render(code.Module(items: items))
}

fn op_uses_unsupported_trait(traits: shape.Traits) -> Bool {
  // `smithy.api#httpChecksumRequired` is no longer in the skip list —
  // `rest_request.build_request_module` emits a
  // `rest.with_content_md5_header` call when the trait is present.
  // `aws.protocols#httpChecksum` still skips: it's the multi-algorithm
  // request/response validation trait used by S3 Get/PutObject, gated
  // on a broader checksum middleware that's v0.2.
  dict.has_key(traits, ShapeId("aws.protocols#httpChecksum"))
}


fn http_trait(traits: shape.Traits) -> Option(HttpTrait) {
  case dict.get(traits, ShapeId("smithy.api#http")) {
    Ok(Some(trait.Dict(d))) -> {
      let method = trait_helpers.string_field(d, "method")
      let uri = trait_helpers.string_field(d, "uri")
      let code = trait_helpers.int_field(d, "code", 200)
      let compression = trait_helpers.request_compression_encodings(traits)
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
// `pascalize_member`, `int_to_string` live in
// `codegen/src/internal/stringutils.gleam` — see Pass 4 in
// plan.md for the de-duplication.
