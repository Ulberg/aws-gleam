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
import codegen/rest_request
import codegen/struct_codec
import codegen/trait_helpers
import codegen/types.{
  type HttpTrait, type MemberDef, type Resolved, Body, Header, HttpTrait, PBool,
  PInt, PString, Payload, RBlob, RDocument, REnum, RIntEnum, RList, RMap, RPrim,
  RStruct, RTimestamp, RUnion, RUnit, ResponseCode, Unsupported,
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

      let named_shapes = collect_named_shapes(model, resolved_ops)
      let is_dispatcher = is_dispatcher_target(service_id)
      let union_reachable = compute_union_reachable_structs(model, named_shapes)
      let preamble =
        emit_named_shapes(model, named_shapes, is_dispatcher, union_reachable)

      let op_specs =
        list.map(resolved_ops, fn(t) {
          let #(op_id, _, in_r, out_r, err_ids, _) = t
          let local = strip_namespace(op_id)
          let snake = stringutils.pascal_to_snake(local)
          let in_info =
            resolve_io_type(model, name_concat([local, "Input"]), in_r)
          let out_info =
            resolve_io_type(model, name_concat([local, "Output"]), out_r)
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
          emit_operation(
            model,
            op_id,
            http,
            in_r,
            out_r,
            is_dispatcher,
            requires_md5,
          )
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
            has_typed_input: is_dispatcher,
          )
        })
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        dispatcher_specs: dispatcher_specs,
        operations_emitted: list.map(resolved_ops, fn(t) {
          let #(op_id, _, _, _, _, _) = t
          op_id
        }),
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

/// restXml typed-error enum + translator. restXml errors come back
/// as an XML body shaped like `<Error><Code>...</Code>...</Error>`.
/// The shared `runtime` module still extracts an error_type from
/// the X-Amzn-Errortype header (when present) or — for S3 — from a
/// JSON `code` field that's not actually there. Until the runtime's
/// error_type extractor learns to read the XML `<Code>` element,
/// every restXml service error will land in the `Unknown` variant,
/// which still carries the raw body so callers aren't stuck.
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
/// restXml's decoder table is intentionally empty today: the runtime
/// can't yet pull an `error_type` out of an XML `<Code>` element, so
/// every service error lands in the `*Unknown` variant. Pass 6 of
/// plan.md teaches the runtime to read XML error bodies; the table
/// will populate once that lands.
fn emit_error_translator(spec: OpSpec) -> String {
  let name = name_concat([spec.local, "Error"])
  let snake = spec.snake
  let decoders_fn =
    code.Fn(
      public: False,
      name: name_concat([snake, "_error_decoders"]),
      params: [],
      return: code.CodeNone,
      body: code.ListLit(items: [], tail: code.CodeNone),
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
  shapes
  |> list.flat_map(fn(r) {
    case r {
      REnum(gleam_name: n, variants: vs, ..) -> [
        emit_enum_def(n, vs),
        emit_enum_codec(n, vs, is_dispatcher),
      ]
      RIntEnum(gleam_name: n, variants: vs, ..) -> [
        emit_int_enum_def(n, vs),
        emit_int_enum_codec(n, vs),
      ]
      RStruct(
        gleam_name: n,
        full_id: id,
        local_name: ln,
        xml_namespace: xns,
        ..,
      ) ->
        case ln == "Unit" {
          True -> []
          False -> {
            let ms = types.resolve_members(model, id)
            let emit_json_encoder = set.contains(union_reachable, ln)
            [
              emit_record_def(n, ms),
              emit_struct_codec(n, ms, is_dispatcher, emit_json_encoder, xns),
            ]
          }
        }
      RUnion(gleam_name: n, full_id: id, ..) -> {
        let ms = types.resolve_members(model, id)
        [emit_union_def(n, ms), emit_union_codec(n, ms, is_dispatcher)]
      }
      _ -> []
    }
  })
  |> string.concat
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
  struct_index: dict.Dict(String, String),
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
  requires_md5: Bool,
) -> String {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let in_info = resolve_io_type(model, name_concat([pascal, "Input"]), in_r)
  let out_info = resolve_io_type(model, name_concat([pascal, "Output"]), out_r)

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
      string.concat([
        code.render(struct_codec.decoder(
          name_concat(["decode_", snake, "_input_struct"]),
          in_info.type_name,
          [],
          True,
          True,
        )),
        "\n",
      ])
    _, _ -> ""
  }
  let synth_out = case out_info.synthesise {
    True -> emit_record_def(out_info.type_name, [])
    False -> ""
  }
  let in_decoder = case is_dispatcher {
    True ->
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
    False -> ""
  }
  let in_members = in_info.members
  let body_encoder =
    emit_body_encoder_xml(
      snake,
      in_info.type_name,
      local,
      in_info.synthesise,
      in_info.xml_name,
    )
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
    synth_in_record,
    synth_in_decoder,
    synth_out,
    in_decoder,
    body_encoder,
    build,
    parse,
  ])
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
  input_xml_name: option.Option(String),
) -> String {
  // The Smithy spec wraps the request body in an element named after
  // the **input shape's local name** (e.g. `XmlTimestampsRequest`),
  // not the operation's local name (`XmlTimestamps`). `@xmlName` on
  // the input shape overrides that — `BodyWithXmlName` becomes
  // `<Ahoy>`. For synthetic Unit inputs there's no input shape, so
  // we fall back to the op name.
  let root = case synthesised, input_xml_name {
    True, _ -> op_local
    False, Some(s) -> s
    False, None -> input_type
  }
  let fn_name = name_concat(["encode_", snake, "_body_xml"])
  let #(param_name, body) = case synthesised {
    True -> #(
      "_input",
      code.Call(head: code.Ident(name: "xml.empty_element"), args: [
        code.StrLit(value: root),
      ]),
    )
    False -> {
      let input_snake = stringutils.pascal_to_snake(input_type)
      #(
        "input",
        code.Call(
          head: code.Ident(name: name_concat(["encode_", input_snake, "_xml"])),
          args: [code.Ident(name: "input"), code.StrLit(value: root)],
        ),
      )
    }
  }
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: fn_name,
        params: [code.Param(name: param_name, type_: input_type)],
        return: code.CodeSome("String"),
        body: body,
      ),
      code.Blank,
    ]),
  )
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
  IOTypeInfo(
    type_name: String,
    members: List(MemberDef),
    synthesise: Bool,
    /// `@xmlName` on the input/output struct shape, propagated from
    /// `RStruct.xml_name`. `Some(s)` overrides the wire wrapper for
    /// the body XML (e.g. `<Ahoy>` instead of `<BodyWithXmlNameInput
    /// Output>`).
    xml_name: option.Option(String),
    /// `@xmlNamespace` on the input/output struct shape. `Some(#(
    /// prefix, uri))` adds an `xmlns` attribute to the body root.
    xml_namespace: option.Option(#(String, String)),
  )
}

fn resolve_io_type(
  model: Model,
  synth_name: String,
  r: Resolved,
) -> IOTypeInfo {
  case r {
    RStruct(
      local_name: ln,
      gleam_name: gn,
      full_id: id,
      xml_name: xn,
      xml_namespace: xns,
    ) ->
      case ln {
        "Unit" ->
          IOTypeInfo(
            type_name: synth_name,
            members: [],
            synthesise: True,
            xml_name: option.None,
            xml_namespace: option.None,
          )
        _ -> {
          let ms = types.resolve_members(model, id)
          IOTypeInfo(
            type_name: gn,
            members: ms,
            synthesise: False,
            xml_name: xn,
            xml_namespace: xns,
          )
        }
      }
    _ ->
      IOTypeInfo(
        type_name: synth_name,
        members: [],
        synthesise: True,
        xml_name: option.None,
        xml_namespace: option.None,
      )
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

fn emit_enum_codec(
  name: String,
  variants: List(types.EnumVariant),
  is_dispatcher: Bool,
) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let first_ctor = case variants {
    [v, ..] -> v.gleam_ctor
    [] -> name_concat([name, "Unknown"])
  }
  // JSON enum encoder stays — it's reached from `encode_<X>_xml*`
  // (wire path) for enum-typed members. The JSON decoder is only
  // ever called from `decode_<X>_struct_params`, which is itself
  // dispatcher-only, so its emission is gated on the same flag.
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
  // Inverse wire→Gleam helper for XML response decoders. Sentinel-
  // first variant gets returned on unknown wire values so callers
  // can still pattern-match exhaustively.
  let from_wire =
    code.Fn(
      public: True,
      name: name_concat([snake, "_from_wire"]),
      params: [code.Param(name: "s", type_: "String")],
      return: code.CodeSome(name_concat(["Result(", name, ", String)"])),
      body: code.Case(
        scrutinee: code.Ident(name: "s"),
        branches: list.append(
          list.map(variants, fn(v) {
            code.Branch(
              pattern: name_concat(["\"", v.wire_value, "\""]),
              body: code.Call(head: code.Ident(name: "Ok"), args: [
                code.Ident(name: v.gleam_ctor),
              ]),
            )
          }),
          [
            code.Branch(
              pattern: "_",
              body: code.Call(head: code.Ident(name: "Ok"), args: [
                code.Ident(name: first_ctor),
              ]),
            ),
          ],
        ),
      ),
    )
  let dec_items = case is_dispatcher {
    True -> {
      let dec_fn =
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
      [code.Blank, dec_fn, code.Blank]
    }
    False -> []
  }
  code.render(
    code.Module(items: list.append(
      [enc, code.Blank, from_wire, code.Blank],
      dec_items,
    )),
  )
}

/// `fn(s) { case s { ... } }` lambda body for the dispatcher-side
/// decoder. Stays as `code.Raw` since the AST has no anonymous-
/// function node.
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

/// `fn(n) { case n { ... } }` lambda body for the int-enum
/// dispatcher decoder. Same pattern as `enum_decode_lambda`.
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

fn emit_int_enum_codec(
  name: String,
  variants: List(types.IntEnumVariant),
) -> String {
  let snake = stringutils.pascal_to_snake(name)
  let first_ctor = case variants {
    [v, ..] -> v.gleam_ctor
    [] -> name_concat([name, "Unknown"])
  }
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
  // Inverse Int → Gleam helper for XML response decoders.
  let from_int =
    code.Fn(
      public: True,
      name: name_concat([snake, "_from_int"]),
      params: [code.Param(name: "n", type_: "Int")],
      return: code.CodeSome(name_concat(["Result(", name, ", String)"])),
      body: code.Case(
        scrutinee: code.Ident(name: "n"),
        branches: list.append(
          list.map(variants, fn(v) {
            code.Branch(
              pattern: stringutils.int_to_string(v.wire_value),
              body: code.Call(head: code.Ident(name: "Ok"), args: [
                code.Ident(name: v.gleam_ctor),
              ]),
            )
          }),
          [
            code.Branch(
              pattern: "_",
              body: code.Call(head: code.Ident(name: "Ok"), args: [
                code.Ident(name: first_ctor),
              ]),
            ),
          ],
        ),
      ),
    )
  code.render(
    code.Module(items: [
      int_value,
      code.Blank,
      enc,
      code.Blank,
      from_int,
      code.Blank,
      dec,
      code.Blank,
    ]),
  )
}

fn emit_struct_codec(
  name: String,
  members: List(MemberDef),
  is_dispatcher: Bool,
  emit_json_encoder: Bool,
  xml_namespace: option.Option(#(String, String)),
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
      string.concat([
        code.render(struct_codec.encoder(
          name_concat(["encode_", snake, "_struct"]),
          name,
          members,
          False,
          False,
        )),
        "\n",
      ])
    False -> ""
  }
  let params_decoder = case is_dispatcher {
    True ->
      string.concat([
        code.render(struct_codec.decoder(
          name_concat(["decode_", snake, "_struct_params"]),
          name,
          members,
          True,
          True,
        )),
        "\n",
      ])
    False -> ""
  }
  string.concat([
    encoder,
    params_decoder,
    emit_struct_xml_inner_encoder(
      name,
      name_concat(["encode_", snake, "_xml_inner"]),
      members,
    ),
    emit_struct_xml_encoder(
      name,
      name_concat(["encode_", snake, "_xml"]),
      snake,
      members,
      xml_namespace,
    ),
    emit_struct_xml_decoder(
      name,
      name_concat(["decode_", snake, "_xml"]),
      members,
    ),
  ])
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
  // A struct's `elem` is only read if it has at least one
  // Body-bound member with a decoder that reaches into the XML
  // tree. Enum / int-enum / union / map / document / unit / unsupported
  // members route through the unsupported-decoder placeholder
  // (which emits a constant `Ok(option.None)` and never touches
  // `elem`), so a struct whose only body members are these types
  // still ends up with `elem` unused. Bind as `_elem` in that case.
  // Mirrors the dispatch table in `xml_value_decoder_expr`.
  let has_real_body_read =
    list.any(members, fn(m) {
      case m.binding {
        Body ->
          case m.target {
            REnum(..) -> False
            RIntEnum(..) -> False
            RUnion(..) -> False
            RMap(..) -> False
            RDocument -> False
            RUnit -> False
            Unsupported(..) -> False
            _ -> True
          }
        _ -> False
      }
    })
  let return = code.CodeSome(name_concat(["Result(", type_name, ", String)"]))
  let #(param_name, body) = case members {
    [] -> #(
      "_elem",
      code.Call(head: code.Ident(name: "Ok"), args: [
        code.Ident(name: type_name),
      ]),
    )
    _ -> {
      let param = case has_real_body_read {
        True -> "elem"
        False -> "_elem"
      }
      let stmts =
        list.map(members, fn(m) {
          case m.binding {
            Body ->
              code.Use(
                name: m.snake_name,
                callee: code.Call(head: code.Ident(name: "result.try"), args: [
                  xml_value_decoder_expr_for_member(m),
                ]),
              )
            _ ->
              code.Let(
                name: m.snake_name,
                value: code.Ident(name: "option.None"),
              )
          }
        })
      let ctor_args =
        list.map(members, fn(m) {
          code.Labelled(
            label: m.snake_name,
            value: code.Ident(name: m.snake_name),
          )
        })
      let tail =
        code.Call(head: code.Ident(name: "Ok"), args: [
          code.Call(head: code.Ident(name: type_name), args: ctor_args),
        ])
      #(param, code.Block(items: list.append(stmts, [tail])))
    }
  }
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: fn_name,
        params: [code.Param(name: param_name, type_: "xml_decode.Element")],
        return: return,
        body: body,
      ),
      code.Blank,
    ]),
  )
}

/// Build the `Result(Option(a), String)` decoder expression that reads
/// a single member from the parent XML element. Mirrors
/// `xml_value_expr` on the encoder side: primitives use `int_text` /
/// Member-aware wrapper around `xml_value_decoder_expr`. Honours
/// `@xmlFlattened` on list members — flattened lists land as a list
/// of `<member_name>` siblings rather than a wrapped `<member><entry>`
/// shape, so they need `optional_flat_list` instead of `optional_list`.
fn xml_value_decoder_expr_for_member(m: MemberDef) -> code.Code {
  case m.target, m.xml_flattened {
    RList(element: e, ..), True -> {
      let inner_decoder = list_element_decoder(e)
      code.Call(head: code.Ident(name: "xml_decode.optional_flat_list"), args: [
        code.Ident(name: "elem"),
        code.StrLit(value: m.json_name),
        code.Raw(fragment: inner_decoder),
      ])
    }
    _, _ -> xml_value_decoder_expr(m.target, m.json_name)
  }
}

/// `string_text` / etc., nested structs recurse, lists become wrapped
/// `optional_list` reads.
fn xml_value_decoder_expr(target: Resolved, member_name: String) -> code.Code {
  let optional_child_via = fn(decoder_ident: String) {
    code.Call(head: code.Ident(name: "xml_decode.optional_child"), args: [
      code.Ident(name: "elem"),
      code.StrLit(value: member_name),
      code.Ident(name: decoder_ident),
    ])
  }
  case target {
    RPrim(primitive: types.PString) ->
      optional_child_via("xml_decode.string_text")
    RPrim(primitive: types.PInt) -> optional_child_via("xml_decode.int_text")
    RPrim(primitive: types.PBool) -> optional_child_via("xml_decode.bool_text")
    // `smithy_float_text` recognises the Smithy IEEE-754 special
    // tokens (`NaN` / `Infinity` / `-Infinity`) and returns the
    // matching `json_float.SmithyFloat` variant directly, so
    // `<floatValue>NaN</floatValue>` round-trips correctly.
    RPrim(primitive: types.PFloat) ->
      optional_child_via("xml_decode.smithy_float_text")
    RBlob ->
      // S3 wraps blob bodies in base64; decode the text content then
      // base64-decode. Failure on either side produces a String error.
      code.Call(head: code.Ident(name: "xml_decode.optional_child"), args: [
        code.Ident(name: "elem"),
        code.StrLit(value: member_name),
        code.Raw(
          fragment: "fn(e) { case xml_decode.string_text(e) { Ok(s) -> case bit_array.base64_decode(s) { Ok(b) -> Ok(b) Error(_) -> Error(\"xml: bad base64\") } Error(r) -> Error(r) } }",
        ),
      ])
    // Wire timestamps in restXml are ISO 8601 (e.g.
    // `2024-01-02T03:04:05.000Z`); the type walker surfaces them
    // as `Int` (epoch seconds), so `xml_decode.timestamp_text`
    // does the ISO 8601 → epoch conversion and falls through to
    // integer parsing for the (rare) integer-on-wire case.
    RTimestamp -> optional_child_via("xml_decode.timestamp_text")
    REnum(gleam_name: gn, ..) -> emit_unsupported_decoder(gn)
    RIntEnum(gleam_name: gn, ..) -> emit_unsupported_decoder(gn)
    RStruct(local_name: name, ..) ->
      optional_child_via(
        name_concat(["decode_", stringutils.pascal_to_snake(name), "_xml"]),
      )
    RUnion(gleam_name: gn, ..) -> emit_unsupported_decoder(gn)
    RList(element: e, xml_entry_name: entry, ..) -> {
      let inner_decoder = list_element_decoder(e)
      code.Call(head: code.Ident(name: "xml_decode.optional_list"), args: [
        code.Ident(name: "elem"),
        code.StrLit(value: member_name),
        code.StrLit(value: entry),
        code.Raw(fragment: inner_decoder),
      ])
    }
    RMap(key: _, value: _, ..) ->
      emit_unsupported_decoder(types.gleam_type(target))
    RDocument -> emit_unsupported_decoder(types.gleam_type(target))
    RUnit -> emit_unsupported_decoder(types.gleam_type(target))
    Unsupported(..) -> emit_unsupported_decoder(types.gleam_type(target))
  }
}

/// Decoder expression for one *list element* — i.e. the per-entry
/// callback passed to `optional_list` / `optional_flat_list`.
/// Mirrors `xml_inner_expr_for_list_element` on the encoder side.
fn list_element_decoder(e: Resolved) -> String {
  case e {
    RPrim(primitive: types.PString) -> "xml_decode.string_text"
    RPrim(primitive: types.PInt) -> "xml_decode.int_text"
    RPrim(primitive: types.PBool) -> "xml_decode.bool_text"
    RPrim(primitive: types.PFloat) -> "xml_decode.float_text"
    RTimestamp -> "xml_decode.timestamp_text"
    RStruct(local_name: n, ..) ->
      name_concat(["decode_", stringutils.pascal_to_snake(n), "_xml"])
    REnum(local_name: n, ..) ->
      name_concat([
        "fn(e) { case xml_decode.string_text(e) { Ok(s) -> ",
        stringutils.pascal_to_snake(n),
        "_from_wire(s) Error(r) -> Error(r) } }",
      ])
    RIntEnum(local_name: n, ..) ->
      name_concat([
        "fn(e) { case xml_decode.int_text(e) { Ok(i) -> ",
        stringutils.pascal_to_snake(n),
        "_from_int(i) Error(r) -> Error(r) } }",
      ])
    // Nested list: each outer entry wraps an inner list whose
    // children share the same per-entry name. `inner_list`
    // extracts those children and recursively decodes.
    RList(element: inner_e, xml_entry_name: inner_entry, ..) ->
      name_concat([
        "fn(e) { xml_decode.inner_list(e, \"",
        inner_entry,
        "\", ",
        list_element_decoder(inner_e),
        ") }",
      ])
    _ -> "fn(_) { Error(\"xml: unsupported list element\") }"
  }
}

/// Placeholder result used for member kinds we don't yet decode from
/// XML (enums, unions, maps, ...). Yields `option.None` so the
/// enclosing struct still constructs successfully.
fn emit_unsupported_decoder(gleam_type: String) -> code.Code {
  // Cast the literal `Ok(option.None)` to the right Result type so
  // the use-bound variable infers as `option.Option(<gleam_type>)`.
  code.Raw(
    fragment: name_concat([
      "{ let r: Result(option.Option(",
      gleam_type,
      "), String) = Ok(option.None)\n    r }",
    ]),
  )
}

/// Emit `encode_<snake>_xml(input, root)` — wraps the struct's inner
/// content in `<root>...</root>`. Delegates to `_xml_inner` for the
/// inner body to avoid duplicating the per-member emission.
fn emit_struct_xml_encoder(
  type_name: String,
  fn_name: String,
  snake: String,
  members: List(MemberDef),
  xml_namespace: option.Option(#(String, String)),
) -> String {
  // `@xmlAttribute` members land on the outer wrapper's open tag
  // (`<Root attr="value">`), not in the inner content. They're
  // collected by `_xml_attrs`; the inner encoder skips them. The
  // shape-level `@xmlNamespace` trait contributes a fixed
  // `xmlns="..."` / `xmlns:prefix="..."` attribute to the same
  // open tag.
  let attr_members =
    list.filter(members, fn(m) {
      case m.binding, m.xml_attribute {
        Body, True -> True
        _, _ -> False
      }
    })
  let inner_call =
    code.Call(
      head: code.Ident(name: name_concat(["encode_", snake, "_xml_inner"])),
      args: [code.Ident(name: "input")],
    )
  let #(body, attrs_emitter) = case attr_members, xml_namespace {
    [], option.None -> #(
      code.Call(head: code.Ident(name: "xml.element"), args: [
        code.Ident(name: "root"),
        inner_call,
      ]),
      "",
    )
    _, _ -> {
      let attrs_arg = struct_xml_attrs_expr(attr_members, xml_namespace, snake)
      let extra = case attr_members {
        [] -> ""
        _ -> emit_struct_xml_attrs(snake, type_name, attr_members)
      }
      #(
        code.Call(head: code.Ident(name: "xml.element_with_attrs"), args: [
          code.Ident(name: "root"),
          attrs_arg,
          inner_call,
        ]),
        extra,
      )
    }
  }
  let main_fn =
    code.Fn(
      public: True,
      name: fn_name,
      params: [
        code.Param(name: "input", type_: type_name),
        code.Param(name: "root", type_: "String"),
      ],
      return: code.CodeSome("String"),
      body: body,
    )
  string.concat([
    code.render(code.Module(items: [main_fn, code.Blank])),
    attrs_emitter,
  ])
}

/// Build the `attrs` argument expression for `xml.element_with_attrs`:
/// either the namespace-only list `[#("xmlns", "...")]`, the user-
/// attrs accumulator `encode_<snake>_xml_attrs(input)`, or both
/// concatenated `[#("xmlns", "..."), ..encode_<snake>_xml_attrs(input)]`.
fn struct_xml_attrs_expr(
  attr_members: List(MemberDef),
  xml_namespace: option.Option(#(String, String)),
  snake: String,
) -> code.Code {
  let xmlns_attr = xmlns_attr_expr(xml_namespace)
  let attrs_call =
    code.Call(
      head: code.Ident(name: name_concat(["encode_", snake, "_xml_attrs"])),
      args: [code.Ident(name: "input")],
    )
  case attr_members, xml_namespace {
    [], option.Some(_) ->
      code.ListLit(items: [code.Raw(fragment: xmlns_attr)], tail: code.CodeNone)
    _, option.None -> attrs_call
    _, option.Some(_) ->
      code.ListLit(
        items: [code.Raw(fragment: xmlns_attr)],
        tail: code.CodeSome(attrs_call),
      )
  }
}

/// Render the `xmlns` / `xmlns:prefix` attribute tuple expression
/// for an `@xmlNamespace` trait. Returns the empty string when
/// there's no namespace — the caller still emits the list literal,
/// which collapses to `[]` if no other attrs are present.
fn xmlns_attr_expr(ns: option.Option(#(String, String))) -> String {
  case ns {
    option.None -> ""
    option.Some(#("", uri)) -> name_concat(["#(\"xmlns\", \"", uri, "\")"])
    option.Some(#(prefix, uri)) ->
      name_concat(["#(\"xmlns:", prefix, "\", \"", uri, "\")"])
  }
}

fn emit_struct_xml_attrs(
  snake: String,
  type_name: String,
  attr_members: List(MemberDef),
) -> String {
  let initial =
    code.Let(name: "attrs", value: code.ListLit(items: [], tail: code.CodeNone))
  let updates =
    list.map(attr_members, fn(m) {
      code.Let(
        name: "attrs",
        value: code.Case(
          scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
          branches: [
            code.Branch(
              pattern: "option.Some(v)",
              body: code.ListLit(
                items: [
                  code.Tuple(items: [
                    code.StrLit(value: m.json_name),
                    code.Raw(fragment: attr_value_expr(m.target)),
                  ]),
                ],
                tail: code.CodeSome(code.Ident(name: "attrs")),
              ),
            ),
            code.Branch(pattern: "option.None", body: code.Ident(name: "attrs")),
          ],
        ),
      )
    })
  let tail = code.Ident(name: "attrs")
  let body_items = list.append([initial, ..updates], [tail])
  code.render(
    code.Module(items: [
      code.Fn(
        public: False,
        name: name_concat(["encode_", snake, "_xml_attrs"]),
        params: [code.Param(name: "input", type_: type_name)],
        return: code.CodeSome("List(#(String, String))"),
        body: code.Block(items: body_items),
      ),
      code.Blank,
    ]),
  )
}

fn attr_value_expr(target: Resolved) -> String {
  case target {
    RPrim(primitive: types.PString) -> "v"
    RPrim(primitive: types.PInt) -> "xml.int_text(v)"
    RPrim(primitive: types.PBool) -> "xml.bool_text(v)"
    RPrim(primitive: types.PFloat) ->
      "case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }"
    RTimestamp -> "json_timestamp.format_iso8601(v)"
    REnum(..) ->
      name_concat(["rest.enum_wire_value(", types.json_encoder(target), "(v))"])
    _ -> "\"\""
  }
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
  // A struct may have members yet still produce empty XML — e.g.
  // every member is URI / query / header bound. `input` is then
  // unused; the previous emitter still wrote `input:` and got
  // an "unused argument" warning per op. Filter to the Body
  // subset (minus `@xmlAttribute` members, which land on the
  // wrapper's open tag) before deciding whether to bind the param.
  let body_members =
    list.filter(members, fn(m) {
      case m.binding, m.xml_attribute {
        Body, False -> True
        _, _ -> False
      }
    })
  let #(param_name, body_items) = case body_members {
    [] -> #("_input", [code.StrLit(value: "")])
    _ -> {
      let initial = code.Let(name: "inner", value: code.StrLit(value: ""))
      let updates =
        list.map(body_members, fn(m) {
          code.Let(
            name: "inner",
            value: code.Case(
              scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
              branches: [
                code.Branch(
                  pattern: "option.Some(v)",
                  body: code.Concat(parts: [
                    code.Ident(name: "inner"),
                    xml_value_expr(m),
                  ]),
                ),
                code.Branch(
                  pattern: "option.None",
                  body: code.Ident(name: "inner"),
                ),
              ],
            ),
          )
        })
      let tail = code.Ident(name: "inner")
      #("input", list.append([initial, ..updates], [tail]))
    }
  }
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: fn_name,
        params: [code.Param(name: param_name, type_: type_name)],
        return: code.CodeSome("String"),
        body: code.Block(items: body_items),
      ),
      code.Blank,
    ]),
  )
}

/// Render `v` (a Gleam value of `target`'s type) as an XML element
/// `<member_name>...</member_name>`. Recursive for nested structs and
/// lists.
fn xml_value_expr(m: MemberDef) -> code.Code {
  let member_name = m.json_name
  let mem_ns = m.xml_namespace
  case m.target {
    RPrim(primitive: types.PString) ->
      wrap_text_call(member_name, mem_ns, "xml.escape_text")
    RPrim(primitive: types.PInt) ->
      wrap_text_call(member_name, mem_ns, "xml.int_text")
    RPrim(primitive: types.PBool) ->
      wrap_text_call(member_name, mem_ns, "xml.bool_text")
    RPrim(primitive: types.PFloat) ->
      wrap_with_attrs(
        member_name,
        mem_ns,
        code.Raw(
          fragment: "case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }",
        ),
      )
    RBlob -> wrap_text_call(member_name, mem_ns, "xml.blob_text")
    RTimestamp ->
      // restXml's protocol default is `date-time` (ISO 8601). The
      // `@timestampFormat` member trait overrides it; the member
      // walker collapses both the member-level and target-shape
      // trait into `m.timestamp_format`.
      wrap_text_call(
        member_name,
        mem_ns,
        xml_timestamp_format_expr(m.timestamp_format),
      )
    REnum(local_name: _, ..) ->
      wrap_with_attrs(
        member_name,
        mem_ns,
        code.Call(head: code.Ident(name: "rest.enum_wire_value"), args: [
          code.Call(head: code.Ident(name: types.json_encoder(m.target)), args: [
            code.Ident(name: "v"),
          ]),
        ]),
      )
    RIntEnum(local_name: n, ..) ->
      wrap_with_attrs(
        member_name,
        mem_ns,
        code.Call(head: code.Ident(name: "xml.int_text"), args: [
          code.Call(
            head: code.Ident(
              name: name_concat([
                stringutils.pascal_to_snake(n),
                "_int_value",
              ]),
            ),
            args: [code.Ident(name: "v")],
          ),
        ]),
      )
    RStruct(local_name: name, ..) ->
      // Smithy: shape-level `@xmlNamespace` only applies when the
      // struct is the document root, not when it's nested as a
      // member. So always splice the inner body and add the
      // wrapping element ourselves — member-level `@xmlNamespace`
      // (if any) lands on the wrapper via `wrap_with_attrs`.
      wrap_text_call(
        member_name,
        mem_ns,
        name_concat(["encode_", stringutils.pascal_to_snake(name), "_xml_inner"]),
      )
    RUnion(local_name: n, ..) ->
      // Wrap the union variant's emission in the outer member's
      // element. `encode_<U>_union_xml_inner` handles dispatching
      // on the variant and emitting `<variant_tag>...</variant_tag>`.
      wrap_text_call(
        member_name,
        mem_ns,
        name_concat([
          "encode_",
          stringutils.pascal_to_snake(n),
          "_union_xml_inner",
        ]),
      )
    RList(element: _e, xml_entry_name: entry, xml_element_namespace: ens, ..) -> {
      // Smithy default list: `<MemberName><member>...</member>...
      // </MemberName>`. The list shape's member `@xmlName` overrides
      // the per-entry tag — S3's Buckets list uses `<Bucket>`.
      // `@xmlFlattened` on the member drops the wrapper: entries
      // become repeated `<member_name>value</member_name>` siblings.
      let inner = xml_inner_expr_for_list_element(m.target)
      let mapped_v =
        code.Raw(
          fragment: name_concat([
            "list.map(v, fn(item) { let v = item ",
            inner,
            " })",
          ]),
        )
      // For flat lists the member-level namespace is the outer
      // (repeated) element's namespace; if the outer member has
      // none, fall back to the list-inner's namespace. For non-
      // flat lists the outer wrapper carries the member's
      // namespace, the per-entry tag carries the list-inner's.
      let flat_member_ns = case mem_ns {
        option.Some(_) -> mem_ns
        option.None -> ens
      }
      case m.xml_flattened, mem_ns, ens {
        True, option.None, option.None ->
          code.Call(head: code.Ident(name: "xml.flat_list"), args: [
            code.StrLit(value: member_name),
            mapped_v,
          ])
        True, _, _ ->
          code.Call(head: code.Ident(name: "xml.flat_list_ns"), args: [
            code.StrLit(value: member_name),
            xmlns_attrs_list_code(flat_member_ns),
            mapped_v,
          ])
        False, option.None, option.None ->
          code.Call(head: code.Ident(name: "xml.list_element"), args: [
            code.StrLit(value: member_name),
            code.StrLit(value: entry),
            mapped_v,
          ])
        False, _, _ ->
          code.Call(head: code.Ident(name: "xml.list_element_ns"), args: [
            code.StrLit(value: member_name),
            xmlns_attrs_list_code(mem_ns),
            code.StrLit(value: entry),
            xmlns_attrs_list_code(ens),
            mapped_v,
          ])
      }
    }
    RMap(
      value: v,
      xml_key_name: kn,
      xml_value_name: vn,
      xml_key_namespace: knp,
      xml_value_namespace: vnp,
      ..,
    ) -> {
      // Smithy default XML map: `<wrapper><entry><key>K</key>
      // <value>V</value></entry>...</wrapper>`. `@xmlFlattened` on
      // the member drops the outer wrapper AND `<entry>`:
      // `<member_name><key>K</key><value>V</value></member_name>`
      // siblings. `@xmlName` on the map's key / value members
      // replaces the default `key` / `value` labels.
      let val_expr = xml_map_value_expr(v)
      let mapped_v =
        code.Raw(
          fragment: name_concat([
            "dict.map_values(v, fn(_, v) { ",
            val_expr,
            " })",
          ]),
        )
      let any_ns = case mem_ns, knp, vnp {
        option.None, option.None, option.None -> False
        _, _, _ -> True
      }
      case m.xml_flattened, any_ns {
        True, False ->
          code.Call(head: code.Ident(name: "xml.flat_map"), args: [
            code.StrLit(value: member_name),
            code.StrLit(value: kn),
            code.StrLit(value: vn),
            mapped_v,
          ])
        True, True ->
          code.Call(head: code.Ident(name: "xml.flat_map_ns"), args: [
            code.StrLit(value: member_name),
            xmlns_attrs_list_code(mem_ns),
            code.StrLit(value: kn),
            xmlns_attrs_list_code(knp),
            code.StrLit(value: vn),
            xmlns_attrs_list_code(vnp),
            mapped_v,
          ])
        False, False ->
          code.Call(head: code.Ident(name: "xml.map_element"), args: [
            code.StrLit(value: member_name),
            code.StrLit(value: kn),
            code.StrLit(value: vn),
            mapped_v,
          ])
        False, True ->
          code.Call(head: code.Ident(name: "xml.map_element_ns"), args: [
            code.StrLit(value: member_name),
            xmlns_attrs_list_code(mem_ns),
            code.StrLit(value: kn),
            xmlns_attrs_list_code(knp),
            code.StrLit(value: vn),
            xmlns_attrs_list_code(vnp),
            mapped_v,
          ])
      }
    }
    RDocument ->
      code.Call(head: code.Ident(name: "xml.element"), args: [
        code.StrLit(value: member_name),
        code.StrLit(value: ""),
      ])
    RUnit ->
      code.Call(head: code.Ident(name: "xml.empty_element"), args: [
        code.StrLit(value: member_name),
      ])
    Unsupported(..) -> code.StrLit(value: "")
  }
}

/// Common shape: `<wrap><xml_fn(v)></wrap>`. The leaf branches of
/// `xml_value_expr` all share this — only the inner function name
/// differs. Pulled out to keep that case expression scannable.
fn wrap_text_call(
  name: String,
  ns: option.Option(#(String, String)),
  xml_fn: String,
) -> code.Code {
  wrap_with_attrs(
    name,
    ns,
    code.Call(head: code.Ident(name: xml_fn), args: [code.Ident(name: "v")]),
  )
}

/// Render `<name>inner</name>` or `<name xmlns=...>inner</name>`
/// depending on whether the member carries an `@xmlNamespace`.
fn wrap_with_attrs(
  name: String,
  ns: option.Option(#(String, String)),
  inner: code.Code,
) -> code.Code {
  case ns {
    option.None ->
      code.Call(head: code.Ident(name: "xml.element"), args: [
        code.StrLit(value: name),
        inner,
      ])
    option.Some(_) ->
      code.Call(head: code.Ident(name: "xml.element_with_attrs"), args: [
        code.StrLit(value: name),
        code.ListLit(
          items: [code.Raw(fragment: xmlns_attr_expr(ns))],
          tail: code.CodeNone,
        ),
        inner,
      ])
  }
}

/// `code.Code` version of `xmlns_attrs_list_expr` — returns the
/// attribute-list literal node directly so callers can splice it
/// into an AST argument list without going through `code.Raw`.
fn xmlns_attrs_list_code(ns: option.Option(#(String, String))) -> code.Code {
  case ns {
    option.None -> code.ListLit(items: [], tail: code.CodeNone)
    option.Some(_) ->
      code.ListLit(
        items: [code.Raw(fragment: xmlns_attr_expr(ns))],
        tail: code.CodeNone,
      )
  }
}

/// Render an XML map's *value* — what goes inside the `<value>...
/// </value>` wrapper. Structs become inline-no-wrapper XML; the
/// `<value>` element wraps. Primitives become their text form.
fn xml_map_value_expr(target: Resolved) -> String {
  case target {
    RPrim(primitive: types.PString) -> "xml.escape_text(v)"
    RPrim(primitive: types.PInt) -> "xml.int_text(v)"
    RPrim(primitive: types.PBool) -> "xml.bool_text(v)"
    RPrim(primitive: types.PFloat) ->
      "case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }"
    RBlob -> "xml.blob_text(v)"
    RTimestamp -> "json_timestamp.format_iso8601(v)"
    REnum(..) ->
      name_concat(["rest.enum_wire_value(", types.json_encoder(target), "(v))"])
    RIntEnum(local_name: n, ..) ->
      name_concat([
        "xml.int_text(",
        stringutils.pascal_to_snake(n),
        "_int_value(v))",
      ])
    RStruct(local_name: name, ..) ->
      name_concat([
        "encode_",
        stringutils.pascal_to_snake(name),
        "_xml_inner(v)",
      ])
    RMap(value: vv, xml_key_name: kn, xml_value_name: vn, ..) ->
      // Nested map value: produce just the inner entries; the
      // surrounding `<value>` wrapper sits on the outer map's
      // entry. Recursive — supports Map<String, Map<String, ...>>.
      name_concat([
        "xml.map_entries(\"",
        kn,
        "\", \"",
        vn,
        "\", dict.map_values(v, fn(_, v) { ",
        xml_map_value_expr(vv),
        " }))",
      ])
    _ -> "\"\""
  }
}

/// Map a member-level `@timestampFormat` to the wire-format helper
/// the runtime exposes. restXml's protocol default is `date-time`
/// (ISO 8601); the trait overrides it. The returned expression
/// names a `fn(Int) -> String` ready to splice into `xml.element`.
fn xml_timestamp_format_expr(format: Option(String)) -> String {
  case format {
    Some("epoch-seconds") -> "xml.int_text"
    Some("http-date") -> "json_timestamp.format_http_date"
    _ -> "json_timestamp.format_iso8601"
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
        // restXml's protocol default is `date-time` (ISO 8601). The
        // per-member `@timestampFormat` override doesn't apply at
        // the list-element position (Smithy puts that trait on the
        // *list member*, not its target shape, and we currently
        // don't plumb it through `RList`).
        RTimestamp -> "json_timestamp.format_iso8601(v)"
        REnum(..) ->
          name_concat(["rest.enum_wire_value(", types.json_encoder(e), "(v))"])
        RIntEnum(local_name: n, ..) ->
          name_concat([
            "xml.int_text(",
            stringutils.pascal_to_snake(n),
            "_int_value(v))",
          ])
        RStruct(local_name: n, ..) ->
          // Lists of structs: each entry is an inline struct without
          // an outer wrapper (caller's `<member>...</member>` wraps).
          name_concat([
            "encode_",
            stringutils.pascal_to_snake(n),
            "_xml_inner(v)",
          ])
        RList(element: inner_e, xml_entry_name: inner_entry, ..) ->
          // Nested list — outer entry's `<member>` wraps an inline
          // list. Recurse via a synthetic single-step call to
          // `xml.flat_list` (no outer wrapper; the surrounding
          // `<member>` provides it).
          name_concat([
            "xml.flat_list(\"",
            inner_entry,
            "\", list.map(v, fn(inner_item) { let v = inner_item ",
            xml_inner_expr_for_list_element(RList(
              element: inner_e,
              xml_entry_name: inner_entry,
              sparse: False,
              xml_element_namespace: option.None,
            )),
            " }))",
          ])
        RUnion(local_name: n, ..) ->
          name_concat([
            "encode_",
            stringutils.pascal_to_snake(n),
            "_union_xml_inner(v)",
          ])
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
  // XML union encoder: pattern-match on the variant and emit the
  // matching `<variant_tag>...</variant_tag>` block. Smithy's wire
  // form for a union is exactly one tag — the variant's @xmlName /
  // member name. The outer wrapping element (e.g. `<myUnion>`) is
  // added by the caller via `xml_value_expr`.
  let xml_inner =
    code.Fn(
      public: True,
      name: name_concat(["encode_", snake, "_union_xml_inner"]),
      params: [code.Param(name: "v", type_: name)],
      return: code.CodeSome("String"),
      body: code.Case(
        scrutinee: code.Ident(name: "v"),
        branches: list.map(members, fn(m) {
          let ctor =
            name_concat([name, stringutils.pascalize_member(m.member_name)])
          code.Branch(
            pattern: name_concat([ctor, "(x)"]),
            body: code.Call(head: code.Ident(name: "xml.element"), args: [
              code.StrLit(value: m.json_name),
              union_variant_xml_inner_expr(m.target),
            ]),
          )
        }),
      ),
    )
  let dec_params_items = case is_dispatcher {
    True -> [
      code.Blank,
      code.Fn(
        public: True,
        name: name_concat(["decode_", snake, "_union_params"]),
        params: [],
        return: code.CodeSome(name_concat(["decode.Decoder(", name, ")"])),
        body: union_params_decoder_body(name, members),
      ),
      code.Blank,
    ]
    False -> []
  }
  code.render(
    code.Module(items: list.append(
      [enc, code.Blank, xml_inner, code.Blank],
      dec_params_items,
    )),
  )
}

/// Per-variant inner-content expression for `encode_<U>_union_xml_inner`.
/// `x` is the unwrapped variant payload (after pattern matching).
fn union_variant_xml_inner_expr(target: Resolved) -> code.Code {
  case target {
    RPrim(primitive: types.PString) ->
      code.Call(head: code.Ident(name: "xml.escape_text"), args: [
        code.Ident(name: "x"),
      ])
    RPrim(primitive: types.PInt) ->
      code.Call(head: code.Ident(name: "xml.int_text"), args: [
        code.Ident(name: "x"),
      ])
    RPrim(primitive: types.PBool) ->
      code.Call(head: code.Ident(name: "xml.bool_text"), args: [
        code.Ident(name: "x"),
      ])
    RPrim(primitive: types.PFloat) ->
      code.Raw(
        fragment: "case x { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }",
      )
    RBlob ->
      code.Call(head: code.Ident(name: "xml.blob_text"), args: [
        code.Ident(name: "x"),
      ])
    RTimestamp ->
      code.Call(head: code.Ident(name: "json_timestamp.format_iso8601"), args: [
        code.Ident(name: "x"),
      ])
    REnum(..) ->
      code.Call(head: code.Ident(name: "rest.enum_wire_value"), args: [
        code.Call(head: code.Ident(name: types.json_encoder(target)), args: [
          code.Ident(name: "x"),
        ]),
      ])
    RIntEnum(local_name: n, ..) ->
      code.Call(head: code.Ident(name: "xml.int_text"), args: [
        code.Call(
          head: code.Ident(
            name: name_concat([
              stringutils.pascal_to_snake(n),
              "_int_value",
            ]),
          ),
          args: [code.Ident(name: "x")],
        ),
      ])
    RStruct(local_name: n, ..) ->
      code.Call(
        head: code.Ident(
          name: name_concat([
            "encode_",
            stringutils.pascal_to_snake(n),
            "_xml_inner",
          ]),
        ),
        args: [code.Ident(name: "x")],
      )
    RUnion(local_name: n, ..) ->
      code.Call(
        head: code.Ident(
          name: name_concat([
            "encode_",
            stringutils.pascal_to_snake(n),
            "_union_xml_inner",
          ]),
        ),
        args: [code.Ident(name: "x")],
      )
    _ -> code.StrLit(value: "")
  }
}

/// Body for `decode_<U>_union_params` — a `decode.one_of` over each
/// variant's `decode.field` branch, or an unconditional failure when
/// the union has no variants. Wrapped in `decode.recursive` since
/// unions can be (and often are) self-referential.
fn union_params_decoder_body(
  name: String,
  members: List(MemberDef),
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
          emit_union_branch_params(name, first),
          code.ListLit(
            items: list.map(rest, fn(m) { emit_union_branch_params(name, m) }),
            tail: code.CodeNone,
          ),
        ]),
      ])
  }
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
        Error(_) -> xml_body_setup(snake, cats.body)
      }
    },
  )
}

fn xml_body_setup(snake: String, body: List(MemberDef)) -> List(code.Code) {
  case body {
    [] -> [
      code.Let(name: "body", value: code.Raw(fragment: "<<>>")),
      code.Let(name: "content_type", value: code.StrLit(value: "")),
    ]
    _ -> [
      code.Let(
        name: "body_xml",
        value: code.Call(
          head: code.Ident(name: name_concat(["encode_", snake, "_body_xml"])),
          args: [code.Ident(name: "input")],
        ),
      ),
      code.Let(
        name: "body",
        value: code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
          code.Ident(name: "body_xml"),
        ]),
      ),
      code.Let(
        name: "content_type",
        value: code.StrLit(value: "application/xml"),
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
  // @httpPayload — the member's value IS the body.
  //   * blob: raw bytes; Content-Type defaults to
  //     `application/octet-stream`, overridden by `@mediaType`.
  //   * string: raw string (no JSON quoting); Content-Type defaults
  //     to `text/plain`, overridden by `@mediaType`.
  //   * struct: XML element, root = member's wire name (or @xmlName)
  //   * other: fall back to JSON; restXml services don't put bare
  //     primitives or unions in @httpPayload position in practice.
  let blob_ct = case m.media_type {
    option.Some(mt) -> mt
    option.None -> "application/octet-stream"
  }
  let string_ct = case m.media_type {
    option.Some(mt) -> mt
    option.None -> "text/plain"
  }
  let #(some_expr, content_type) = case m.target {
    types.RBlob -> #(code.Ident(name: "v"), blob_ct)
    RPrim(primitive: types.PString) -> #(
      code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.Ident(name: "v"),
      ]),
      string_ct,
    )
    REnum(local_name: _, ..) -> #(
      code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.Call(head: code.Ident(name: "rest.enum_wire_value"), args: [
          code.Call(head: code.Ident(name: types.json_encoder(m.target)), args: [
            code.Ident(name: "v"),
          ]),
        ]),
      ]),
      string_ct,
    )
    RUnion(local_name: name, ..) -> #(
      code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.Call(head: code.Ident(name: "xml.element"), args: [
          code.StrLit(value: name),
          code.Call(
            head: code.Ident(
              name: name_concat([
                "encode_",
                stringutils.pascal_to_snake(name),
                "_union_xml_inner",
              ]),
            ),
            args: [code.Ident(name: "v")],
          ),
        ]),
      ]),
      "application/xml",
    )
    RStruct(local_name: name, xml_name: xn, ..) -> {
      let wrapper = case m.json_name == m.member_name, xn {
        False, _ -> m.json_name
        True, Some(s) -> s
        True, None -> name
      }
      #(
        code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
          code.Call(
            head: code.Ident(
              name: name_concat([
                "encode_",
                stringutils.pascal_to_snake(name),
                "_xml",
              ]),
            ),
            args: [code.Ident(name: "v"), code.StrLit(value: wrapper)],
          ),
        ]),
        "application/xml",
      )
    }
    _ -> #(
      code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.Call(head: code.Ident(name: "json.to_string"), args: [
          code.Call(head: code.Ident(name: types.json_encoder(m.target)), args: [
            code.Ident(name: "v"),
          ]),
        ]),
      ]),
      "application/xml",
    )
  }
  let body_stmt =
    code.Let(
      name: "body",
      value: code.Case(
        scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
        branches: [
          code.Branch(pattern: "option.Some(v)", body: some_expr),
          code.Branch(pattern: "option.None", body: code.Raw(fragment: "<<>>")),
        ],
      ),
    )
  let ct_stmt =
    code.Let(name: "content_type", value: code.StrLit(value: content_type))
  [body_stmt, ct_stmt]
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
    Error(_), False -> {
      let decoder =
        name_concat([
          "decode_",
          stringutils.pascal_to_snake(output_type),
          "_xml",
        ])
      let overrides = response_overrides(out_info)
      // The decoder produces `Result(Output, String)` already; if the
      // output binds any `@httpHeader` / `@httpResponseCode` members we
      // wrap the Ok branch in a record-update expression that overlays
      // those values from `headers` / `code`. When every output member
      // is bound to a header (no body members) we sidestep the
      // `..decoded` base to silence the "redundant record update"
      // warning — the decoder's value is discarded.
      let full_override =
        list.length(overrides) == list.length(out_info.members)
      let bare_decode_call =
        code.Call(head: code.Ident(name: decoder), args: [
          code.Raw(
            fragment: "xml_decode.Element(name: \"empty\", attrs: [], children: [])",
          ),
        ])
      let bare_decode_call_with_root =
        code.Call(head: code.Ident(name: decoder), args: [
          code.Ident(name: "root"),
        ])
      let with_overrides = fn(call: code.Code) -> code.Code {
        case overrides {
          [] -> call
          _ ->
            wrap_decode_with_overrides_at(
              call,
              output_type,
              overrides,
              full_override: full_override,
            )
        }
      }
      let inner_text_case =
        code.Case(scrutinee: code.Ident(name: "text"), branches: [
          code.Branch(pattern: "\"\"", body: with_overrides(bare_decode_call)),
          code.Branch(
            pattern: "_",
            body: code.Case(
              scrutinee: code.Call(
                head: code.Ident(name: "xml_decode.parse"),
                args: [code.Ident(name: "text")],
              ),
              branches: [
                code.Branch(
                  pattern: "Ok(root)",
                  body: with_overrides(bare_decode_call_with_root),
                ),
                code.Branch(
                  pattern: "Error(r)",
                  body: code.Call(head: code.Ident(name: "Error"), args: [
                    code.Ident(name: "r"),
                  ]),
                ),
              ],
            ),
          ),
        ])
      code.render(
        code.Module(items: [
          code.Fn(
            public: True,
            name: name_concat(["parse_", snake, "_response"]),
            params: response_params(
              body_param: "body",
              overrides_used: overrides,
            ),
            return: code.CodeSome(
              name_concat(["Result(", output_type, ", String)"]),
            ),
            body: code.Case(
              scrutinee: code.Call(
                head: code.Ident(name: "bit_array.to_string"),
                args: [code.Ident(name: "body")],
              ),
              branches: [
                code.Branch(pattern: "Ok(text)", body: inner_text_case),
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
}

/// A single `Output(..decoded, field: header_value)` override produced by
/// a `@httpHeader` or `@httpResponseCode` member.
type ResponseOverride {
  ResponseOverride(field: String, value_expr: String)
}

fn response_overrides(out_info: IOTypeInfo) -> List(ResponseOverride) {
  list.filter_map(out_info.members, fn(m) {
    case m.binding {
      Header(header_name: name) ->
        case header_extractor(m.target, name) {
          option.Some(expr) ->
            Ok(ResponseOverride(field: m.snake_name, value_expr: expr))
          option.None -> Error(Nil)
        }
      ResponseCode ->
        Ok(ResponseOverride(
          field: m.snake_name,
          value_expr: "option.Some(code)",
        ))
      _ -> Error(Nil)
    }
  })
}

/// Map a Smithy `@httpHeader` target type to the matching extractor
/// call. Types we don't yet bind (enums, timestamps, lists) fall
/// through with `None` so the field continues to land as `option.None`
/// — same behaviour the codegen had before this pass; new binding
/// support drops into this match without touching anything else.
fn header_extractor(target: Resolved, header_name: String) -> Option(String) {
  case target {
    RPrim(primitive: PString) ->
      option.Some(call_extractor("string_header", header_name))
    RPrim(primitive: PInt) ->
      option.Some(call_extractor("int_header", header_name))
    RPrim(primitive: PBool) ->
      option.Some(call_extractor("bool_header", header_name))
    // `RPrim(PFloat)` would map to `json_float.SmithyFloat` in the
    // generated record — we don't yet emit the wrap/unwrap glue, so
    // float-bound headers stay `None` for now. Add the helper plus
    // a generator case here to close that gap.
    _ -> option.None
  }
}

fn call_extractor(fn_name: String, header_name: String) -> String {
  name_concat(["rest.", fn_name, "(headers, \"", header_name, "\")"])
}

/// `full_override = True` produces `Output(field: ..., ...)` without
/// the `..decoded` base — used when every member of the output type is
/// bound to a header or the response code, which sidesteps Gleam's
/// "redundant record update" warning.
fn wrap_decode_with_overrides_at(
  decoder_call: code.Code,
  output_type: String,
  overrides: List(ResponseOverride),
  full_override full_override: Bool,
) -> code.Code {
  let overrides_text =
    overrides
    |> list.map(fn(o) { name_concat([o.field, ": ", o.value_expr]) })
    |> string.join(", ")
  let prefix = case full_override {
    True -> ""
    False -> "..decoded, "
  }
  let ok_body =
    code.Call(head: code.Ident(name: "Ok"), args: [
      code.Raw(
        fragment: name_concat([
          output_type,
          "(",
          prefix,
          overrides_text,
          ")",
        ]),
      ),
    ])
  let pattern = case full_override {
    True -> "Ok(_)"
    False -> "Ok(decoded)"
  }
  code.Case(scrutinee: decoder_call, branches: [
    code.Branch(pattern: pattern, body: ok_body),
    code.Branch(
      pattern: "Error(r)",
      body: code.Call(head: code.Ident(name: "Error"), args: [
        code.Ident(name: "r"),
      ]),
    ),
  ])
}

/// Build the `parse_<op>_response` parameter list, deciding whether to
/// underscore each unused arg. When overrides exist we bind both
/// `code` and `headers`; without any, we keep the original `_code` /
/// `_headers` form so no `unused` warnings fire on the generated
/// module.
fn response_params(
  body_param body_param: String,
  overrides_used overrides: List(ResponseOverride),
) -> List(code.Param) {
  let uses_code =
    list.any(overrides, fn(o) { string.contains(o.value_expr, "code") })
  let uses_headers =
    list.any(overrides, fn(o) { string.contains(o.value_expr, "headers") })
  let code_name = case uses_code {
    True -> "code"
    False -> "_code"
  }
  let headers_name = case uses_headers {
    True -> "headers"
    False -> "_headers"
  }
  [
    code.Param(name: code_name, type_: "Int"),
    code.Param(name: headers_name, type_: "dict.Dict(String, String)"),
    code.Param(name: body_param, type_: "BitArray"),
  ]
}

fn parse_response_params(body_param: String) -> List(code.Param) {
  [
    code.Param(name: "_code", type_: "Int"),
    code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
    code.Param(name: body_param, type_: "BitArray"),
  ]
}

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
    RBlob ->
      code.Let(
        name: "payload",
        value: code.Call(head: code.Ident(name: "option.Some"), args: [
          code.Ident(name: "body"),
        ]),
      )
    RPrim(primitive: types.PString) ->
      code.Raw(
        fragment: "use payload <- result.try(case bit_array.to_string(body) {\n      Ok(s) -> Ok(option.Some(s))\n      Error(_) -> Error(\"non-utf8 payload\")\n    })",
      )
    RStruct(local_name: name, ..) -> {
      let decoder =
        name_concat(["decode_", stringutils.pascal_to_snake(name), "_xml"])
      code.Raw(
        fragment: name_concat([
          "use text <- result.try(case bit_array.to_string(body) {\n      Ok(t) -> Ok(t)\n      Error(_) -> Error(\"non-utf8 payload\")\n    })\n    use payload <- result.try(case text {\n      \"\" -> Ok(option.None)\n      _ -> case xml_decode.parse(text) {\n        Ok(root) -> case ",
          decoder,
          "(root) {\n          Ok(v) -> Ok(option.Some(v))\n          Error(r) -> Error(r)\n        }\n        Error(r) -> Error(r)\n      }\n    })",
        ]),
      )
    }
    _ -> code.Let(name: "payload", value: code.Ident(name: "option.None"))
  }
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
        params: parse_response_params(body_param),
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
    #("aws/internal/codec/xml", "xml.", code.CodeNone),
    #("aws/internal/codec/xml_decode", "xml_decode.", code.CodeNone),
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
        name_concat(["Generated from ", service_id, " (restXml)."]),
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
// `pascalize_member`, `int_to_string` live in
// `codegen/src/internal/stringutils.gleam` — see Pass 4 in
// plan.md for the de-duplication.
