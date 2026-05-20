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
import codegen/error_dispatch
import codegen/named_shapes
import codegen/paginator
import codegen/rest_request
import codegen/struct_codec
import codegen/trait_helpers
import codegen/types.{
  type HttpTrait, type MemberDef, type Resolved, Header, HttpTrait, PBool, PInt,
  PString, Payload, RDocument, REnum, RIntEnum, RList, RMap, RPrim,
  RStreamingBlob, RStruct, RTimestamp, RUnion, ResponseCode,
}
import codegen/waiter
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
      // Protocol-test corpora declare multiple service shapes per
      // file (RestJsonValidation, BackplaneControlService, Glacier
      // alongside the dominant RestJson). Union their ops in so the
      // dispatcher table covers every `httpRequestTests` case —
      // no-op for real-world models (one service per file).
      let refs =
        list.append(
          refs,
          trait_helpers.secondary_service_op_refs(
            model,
            service_id,
            "aws.protocols#restJson1",
          ),
        )
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
                  let paginated = trait_helpers.paginated_trait(op_traits)
                  let waiters = trait_helpers.waitable_traits(op_traits)
                  let http_checksum =
                    trait_helpers.http_checksum_trait(op_traits)
                  let host_prefix_info =
                    extract_host_prefix_info(model, op_traits, in_id)
                  case
                    members_have_no_http_bindings(in_r),
                    types.is_supported(in_r),
                    types.is_supported(out_r)
                  {
                    True, True, True ->
                      Ok(#(
                        target,
                        http,
                        in_r,
                        out_r,
                        err_ids,
                        requires_md5,
                        paginated,
                        waiters,
                        http_checksum,
                        host_prefix_info,
                      ))
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
          let #(
            op_id,
            http,
            in_r,
            out_r,
            err_ids,
            requires_md5,
            paginated,
            waiters,
            http_checksum,
            host_prefix_info,
          ) = t
          #(
            op_id,
            http,
            types.apply_rename(in_r, rename),
            types.apply_rename(out_r, rename),
            err_ids,
            requires_md5,
            paginated,
            waiters,
            http_checksum,
            host_prefix_info,
          )
        })
      let named_shapes = collect_named_shapes(model, resolved_ops)
      let named_shapes =
        list.map(named_shapes, fn(r) { types.apply_rename(r, rename) })
      let preamble = emit_named_shapes(model, named_shapes, rename)

      let emitted_type_names = named_shapes.emitted_type_names(named_shapes)
      let op_specs =
        list.map(resolved_ops, fn(t) {
          let #(
            op_id,
            _,
            in_r,
            out_r,
            err_ids,
            _,
            paginated,
            waiters,
            _,
            host_prefix_info,
          ) = t
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
          let pagination_info =
            paginator.info_for(
              members_in: in_info.members,
              members_out: out_info.members,
              trait: paginated,
            )
          OpSpec(
            op_id: op_id,
            local: local,
            snake: snake,
            in_info: in_info,
            out_info: out_info,
            error_ids: err_ids,
            error_type: trait_helpers.op_error_type(local, emitted_type_names),
            pagination_info: pagination_info,
            waiters: waiters,
            host_prefix_info: host_prefix_info,
          )
        })

      let op_blocks =
        list.map(resolved_ops, fn(t) {
          let #(
            op_id,
            http,
            in_r,
            out_r,
            _,
            requires_md5,
            _,
            _,
            http_checksum,
            _,
          ) = t
          emit_operation(
            model,
            op_id,
            http,
            in_r,
            out_r,
            rename,
            requires_md5,
            http_checksum,
          )
        })
      let client_block = emit_client(metadata)
      let invoke_blocks =
        list.map(op_specs, fn(s) { emit_invoke(model, s, emitted_type_names) })
      let paginate_blocks = list.map(op_specs, emit_paginator)
      let waiter_blocks = list.map(op_specs, emit_waiter)
      let error_blocks =
        list.map(op_specs, fn(spec) {
          string.concat([emit_error_type(spec), emit_error_translator(spec)])
        })
      let unique_err_ids =
        op_specs
        |> list.flat_map(fn(s) { s.error_ids })
        |> error_dispatch.dedupe_strings
      let error_shape_blocks =
        list.map(unique_err_ids, fn(id) {
          let local = strip_namespace(id)
          error_dispatch.emit_parse_fn(local, local)
        })
      let body_content =
        string.concat([
          client_block,
          preamble,
          string.concat(op_blocks),
          string.concat(error_blocks),
          string.concat(error_shape_blocks),
          string.concat(invoke_blocks),
          string.concat(paginate_blocks),
          string.concat(waiter_blocks),
        ])
      let body =
        string.concat([
          file_header(service_id, body_content),
          "\n",
          body_content,
        ])
      let op_dispatcher_specs =
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
            is_error_shape: False,
          )
        })
      let err_dispatcher_specs =
        error_dispatch.dispatcher_specs(unique_err_ids, strip_namespace)
      let dispatcher_specs =
        list.append(op_dispatcher_specs, err_dispatcher_specs)
      Ok(EmitResult(
        module_name: derive_module_name(service_id),
        source: body,
        operations_emitted: list.map(resolved_ops, fn(t) {
          let #(op_id, _, _, _, _, _, _, _, _, _) = t
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
    /// Gleam type name for this op's typed error sum. Normally
    /// `<OpLocal>Error`; suffixed to `<OpLocal>OperationError` when
    /// a Smithy struct of the same name exists in the service.
    error_type: String,
    /// Pagination plumbing extracted from `smithy.api#paginated`.
    /// `Some(_)` ⇒ emit a `paginate_<op>` wrapper; `None` ⇒ skip.
    pagination_info: option.Option(paginator.PaginationInfo),
    /// Waiters extracted from `smithy.waiters#waitable`.
    waiters: List(trait_helpers.WaiterDef),
    /// `@smithy.api#endpoint.hostPrefix` template + the input's
    /// `@hostLabel` members.
    host_prefix_info: option.Option(client.HostPrefixInfo),
  )
}

/// Read `@smithy.api#endpoint.hostPrefix` + the input's `@hostLabel`
/// members. Same shape as the helpers in awsjson + restxml.
fn extract_host_prefix_info(
  model: Model,
  op_traits: shape.Traits,
  in_id: String,
) -> option.Option(client.HostPrefixInfo) {
  case trait_helpers.endpoint_host_prefix(op_traits) {
    option.None -> option.None
    option.Some(template) -> {
      let labels = case model.lookup(model, in_id) {
        Ok(shape.Structure(members: m, ..)) ->
          trait_helpers.host_label_member_names(m)
          |> list.map(fn(name) {
            client.HostLabelBinding(
              member_pascal: name,
              member_snake: stringutils.pascal_to_snake(name),
            )
          })
        _ -> []
      }
      option.Some(client.HostPrefixInfo(template: template, labels: labels))
    }
  }
}

// `Metadata`, `service_metadata`, `string_field_under` live in
// `codegen/trait_helpers.gleam` — see Pass 4 in plan.md.

fn emit_client(metadata: trait_helpers.Metadata) -> String {
  client.render(
    metadata.endpoint_prefix,
    metadata.signing_name,
    metadata.endpoint_rule_set_json,
    metadata.endpoint_param_setters,
  )
}

fn emit_paginator(spec: OpSpec) -> String {
  paginator.emit(
    snake: spec.snake,
    input_type: spec.in_info.type_name,
    error_type: spec.error_type,
    info: spec.pagination_info,
  )
}

fn emit_waiter(spec: OpSpec) -> String {
  waiter.emit(
    op_snake: spec.snake,
    input_type: spec.in_info.type_name,
    error_type: spec.error_type,
    waiters: spec.waiters,
    known_error_locals: list.fold(spec.error_ids, set.new(), fn(acc, id) {
      set.insert(acc, strip_namespace(id))
    }),
  )
}

fn emit_invoke(
  model: Model,
  spec: OpSpec,
  emitted_type_names: Set(String),
) -> String {
  let base =
    client.invoke_fn(
      spec.snake,
      spec.in_info.type_name,
      spec.out_info.type_name,
      spec.error_type,
      spec.host_prefix_info,
    )
  let host_prefix_validator = case spec.host_prefix_info {
    option.None -> []
    option.Some(info) -> [
      code.Blank,
      client.host_prefix_validator_fn(spec.snake, spec.in_info.type_name, info),
    ]
  }
  // Operations whose output carries a `@streaming` blob member get an
  // extra `<op>_streaming(client, input)` variant routing through
  // `runtime.invoke_streaming` — body arrives chunked rather than
  // buffered. Examples: Bedrock InvokeModelWithResponseStream
  // returns a streaming-blob `body`, MediaLive log streams, etc.
  let streaming_blob_items = case
    list.any(spec.out_info.members, fn(m) { m.target == RStreamingBlob })
  {
    True -> [
      code.Blank,
      client.invoke_streaming_fn(spec.snake, spec.in_info.type_name),
    ]
    False -> []
  }
  // Operations whose output carries a `@streaming` union (event
  // streams — Transcribe StartStreamTranscription, Lex Runtime
  // V2 StartConversation, etc.) get a `<op>_event_stream` variant
  // plus a typed `parse_<op>_event(event)` decoder. The framing
  // wrapper hands callers the raw `event_stream.Response`; the
  // parser dispatches on `:event-type` into the matching union
  // variant. Mirrors the Rust SDK's `UnmarshallMessage` impl in
  // vendor/aws-sdk-rust/sdk/transcribestreaming/src/event_stream_serde.rs
  let event_stream_items = case
    types.streaming_union_in_members(model, spec.out_info.members)
  {
    option.Some(#(union_local, _union_id, union_members)) -> {
      let variants =
        list.map(union_members, fn(m) {
          let target_local = case m.target {
            RStruct(local_name: ln, ..) -> ln
            _ -> ""
          }
          client.EventParserVariant(
            wire_name: m.member_name,
            variant_ctor: stringutils.union_variant_ctor(
              union_local,
              m.member_name,
              emitted_type_names,
            ),
            decoder_fn: "decode_"
              <> stringutils.pascal_to_snake(target_local)
              <> "_struct",
          )
        })
      [
        code.Blank,
        client.invoke_event_stream_fn(spec.snake, spec.in_info.type_name),
        code.Blank,
        client.event_parser_fn(spec.snake, union_local, variants),
      ]
    }
    option.None -> []
  }
  code.render(
    code.Module(
      items: list.flatten([
        [base, code.Blank],
        host_prefix_validator,
        streaming_blob_items,
        event_stream_items,
      ]),
    ),
  )
}

/// Per-op typed-error enum. One variant per error shape on the
/// operation, plus `Transport` and `Unknown` fall-backs. Mirrors the
/// awsjson emitter — restJson1 errors are still JSON-shaped on the
/// wire, so the same decoder path works.
fn emit_error_type(spec: OpSpec) -> String {
  let name = spec.error_type
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
  let name = spec.error_type
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
  ops: List(
    #(
      String,
      HttpTrait,
      Resolved,
      Resolved,
      List(String),
      Bool,
      option.Option(trait_helpers.PaginatedTrait),
      List(trait_helpers.WaiterDef),
      option.Option(trait_helpers.HttpChecksumInfo),
      option.Option(client.HostPrefixInfo),
    ),
  ),
) -> List(Resolved) {
  // Dedup keyed by `full_id` so two shapes with the same local name in
  // different namespaces both make it into the named-shape list. The
  // rename map (built in `emit_service`) ensures the resulting Gleam
  // type names are unique on emission.
  let init = #(set.new(), [])
  let #(_seen, found) =
    list.fold(ops, init, fn(acc, t) {
      let #(_, _, in_r, out_r, err_ids, _, _, _, _, _) = t
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
  let emitted_type_names = named_shapes.emitted_type_names(shapes)
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
        case id == "smithy.api#Unit" {
          True -> {
            let _ = ln
            []
          }
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
        [
          emit_union_def(n, ms, emitted_type_names),
          emit_union_codec(n, ms, emitted_type_names),
        ]
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
  http_checksum: Option(trait_helpers.HttpChecksumInfo),
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
      http_checksum,
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

fn emit_union_def(
  name: String,
  members: List(MemberDef),
  emitted: Set(String),
) -> String {
  string.concat([
    code.render(named_shapes.union_def(name, members, emitted)),
    "\n",
  ])
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
  // Wire→Gleam helper for @httpHeader-bound enum members. The
  // response-parse emitter calls `<snake>_from_wire(s)` so unknown
  // values can land as `None` rather than crashing the response
  // decode. Mirrors the restxml emitter's helper of the same name.
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
  code.render(
    code.Module(items: [enc, code.Blank, dec, code.Blank, from_wire, code.Blank]),
  )
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

fn emit_union_codec(
  name: String,
  members: List(MemberDef),
  emitted: Set(String),
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
            stringutils.union_variant_ctor(name, m.member_name, emitted)
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
      body: union_decoder_body(name, members, fn(union_name, m) {
        emit_union_branch(union_name, m, emitted)
      }),
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
      body: union_decoder_body(name, members, fn(union_name, m) {
        emit_union_branch_params(union_name, m, emitted)
      }),
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

fn emit_union_branch(
  union_name: String,
  m: MemberDef,
  emitted: Set(String),
) -> code.Code {
  let ctor = stringutils.union_variant_ctor(union_name, m.member_name, emitted)
  code.Call(head: code.Ident(name: "decode.field"), args: [
    code.StrLit(value: m.json_name),
    code.Raw(fragment: types.json_decoder(m.target)),
    code.Raw(fragment: name_concat(["fn(x) { decode.success(", ctor, "(x)) }"])),
  ])
}

fn emit_union_branch_params(
  union_name: String,
  m: MemberDef,
  emitted: Set(String),
) -> code.Code {
  let ctor = stringutils.union_variant_ctor(union_name, m.member_name, emitted)
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
  http_checksum: Option(trait_helpers.HttpChecksumInfo),
) -> String {
  rest_request.build_request_module(
    input_type,
    is_unit,
    snake,
    http,
    members,
    requires_md5,
    http_checksum,
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
    types.RStreamingBlob -> #(
      // Buffered materialisation. Drops when a chunked-send
      // transport replaces `to_bit_array` with a lazy reader.
      code.Call(head: code.Ident(name: "streaming.to_bit_array"), args: [
        code.Ident(name: "v"),
      ]),
      code.Raw(fragment: "<<>>"),
      blob_ct,
    )
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
    Error(_), False -> {
      let overrides = response_overrides(out_info)
      let full_override =
        list.length(overrides) == list.length(out_info.members)
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
      let empty_decode_call =
        code.Call(
          head: code.Ident(name: name_concat(["decode_", snake, "_output"])),
          args: [
            code.StrLit(value: "{}"),
          ],
        )
      let text_decode_call =
        code.Call(
          head: code.Ident(name: name_concat(["decode_", snake, "_output"])),
          args: [
            code.Ident(name: "text"),
          ],
        )
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
                code.Branch(
                  pattern: "Ok(text)",
                  body: code.Case(
                    scrutinee: code.Ident(name: "text"),
                    branches: [
                      code.Branch(
                        pattern: "\"\"",
                        body: with_overrides(empty_decode_call),
                      ),
                      code.Branch(
                        pattern: "_",
                        body: with_overrides(text_decode_call),
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
}

/// A single `Output(..decoded, field: header_value)` override produced by
/// a `@httpHeader` or `@httpResponseCode` member. Mirrors the restxml
/// version — kept in-protocol because the call-site differs (here the
/// decoder takes a JSON `String`, in restxml an `xml_decode.Element`).
type ResponseOverride {
  ResponseOverride(field: String, value_expr: String)
}

fn response_overrides(out_info: IOTypeInfo) -> List(ResponseOverride) {
  list.filter_map(out_info.members, fn(m) {
    case m.binding {
      Header(header_name: name) ->
        case header_extractor(m, name) {
          Some(expr) ->
            Ok(ResponseOverride(field: m.snake_name, value_expr: expr))
          None -> Error(Nil)
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

fn header_extractor(m: MemberDef, header_name: String) -> Option(String) {
  case m.target {
    RPrim(primitive: PString) ->
      Some(call_extractor("string_header", header_name))
    RPrim(primitive: PInt) -> Some(call_extractor("int_header", header_name))
    RPrim(primitive: PBool) -> Some(call_extractor("bool_header", header_name))
    REnum(gleam_name: gn, ..) -> Some(call_enum_extractor(header_name, gn))
    RTimestamp ->
      Some(call_timestamp_extractor(
        header_name,
        timestamp_header_helper(m.timestamp_format),
      ))
    _ -> None
  }
}

/// Pick the `rest.<helper>` matching the member's `@timestampFormat`.
/// Defaults to `http_date_header` per Smithy core's
/// "headers default to HTTP-date" rule.
fn timestamp_header_helper(format: Option(String)) -> String {
  case format {
    Some("date-time") -> "iso8601_header"
    Some("epoch-seconds") -> "epoch_seconds_header"
    _ -> "http_date_header"
  }
}

fn call_extractor(fn_name: String, header_name: String) -> String {
  name_concat(["rest.", fn_name, "(headers, \"", header_name, "\")"])
}

fn call_enum_extractor(header_name: String, enum_gleam_name: String) -> String {
  name_concat([
    "rest.enum_header(headers, \"",
    header_name,
    "\", ",
    stringutils.pascal_to_snake(enum_gleam_name),
    "_from_wire)",
  ])
}

fn call_timestamp_extractor(header_name: String, helper: String) -> String {
  name_concat(["rest.", helper, "(headers, \"", header_name, "\")"])
}

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
        fragment: name_concat([output_type, "(", prefix, overrides_text, ")"]),
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

fn response_params(
  body_param body_param: String,
  overrides_used overrides: List(ResponseOverride),
) -> List(code.Param) {
  // Look for the literal `code` / `headers` *identifiers* the
  // override expressions use — not just substring matches, which
  // would false-positive on e.g. an `x-amzn-code-interpreter-…`
  // header name that contains "code" or a `headers` field accessor.
  // `code` only appears inside `option.Some(code)` (response-code
  // override); `headers` only appears as the first argument to a
  // `rest.<*>_header(headers, ...)` extractor call.
  let uses_code =
    list.any(overrides, fn(o) { string.contains(o.value_expr, "Some(code)") })
  let uses_headers =
    list.any(overrides, fn(o) { string.contains(o.value_expr, "(headers,") })
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
  // Members bound via `@httpHeader` / `@httpResponseCode` get their
  // value populated from the response headers / status code; the rest
  // (other than the payload itself) stay `option.None` — they'd live
  // in the body, but the payload member owns the body here.
  let overrides = response_overrides(out_info)
  let ctor_args =
    list.map(out_info.members, fn(m) {
      let value = case m.snake_name == payload.snake_name {
        True -> code.Ident(name: "payload")
        False ->
          case list.find(overrides, fn(o) { o.field == m.snake_name }) {
            Ok(o) -> code.Raw(fragment: o.value_expr)
            Error(_) -> code.Ident(name: "option.None")
          }
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
    types.RStreamingBlob ->
      // Lazy iterator slot for a future chunked-recv transport;
      // today the v1 buffered transport hands `body` over whole.
      code.Let(
        name: "payload",
        value: code.Call(head: code.Ident(name: "option.Some"), args: [
          code.Call(head: code.Ident(name: "streaming.from_bit_array"), args: [
            code.Ident(name: "body"),
          ]),
        ]),
      )
    RPrim(primitive: types.PString) ->
      code.Use(
        name: "payload",
        callee: code.Raw(
          fragment: "result.try(case bit_array.to_string(body) {\n      Ok(s) -> Ok(option.Some(s))\n      Error(_) -> Error(\"non-utf8 payload\")\n    })",
        ),
      )
    RStruct(gleam_name: name, ..) -> {
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
    REnum(gleam_name: name, ..) -> {
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
        params: response_params(
          body_param: body_param,
          overrides_used: overrides,
        ),
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
    #("aws/pagination", "pagination.", code.CodeNone),
    #("aws/waiter", "waiter.", code.CodeNone),
    #("aws/region", "region.", code.CodeNone),
    #("aws/internal/client/runtime", "runtime.", code.CodeSome("runtime")),
    #("aws/internal/codec/event_stream", "event_stream.", code.CodeNone),
    #("aws/internal/codec/json_document", "json_document.", code.CodeNone),
    #("aws/internal/codec/json_float", "json_float.", code.CodeNone),
    #("aws/internal/codec/json_timestamp", "json_timestamp.", code.CodeNone),
    #("aws/internal/codec/rest", "rest.", code.CodeNone),
    #("aws/internal/http_send", "http_send.", code.CodeNone),
    #("aws/streaming", "streaming.", code.CodeNone),
    #("gleam/bit_array", "bit_array.", code.CodeNone),
    #("gleam/dict", "dict.", code.CodeNone),
    #("gleam/dynamic/decode", "decode.", code.CodeNone),
    #("gleam/int", "int.", code.CodeNone),
    #("gleam/json", "json.", code.CodeNone),
    #("gleam/list", "list.", code.CodeNone),
    #("gleam/option", "option.", code.CodeNone),
    #("gleam/result", "result.", code.CodeNone),
    #("gleam/string", "string.", code.CodeNone),
    #("aws/internal/codec/compression", "compression.", code.CodeNone),
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

fn op_uses_unsupported_trait(_traits: shape.Traits) -> Bool {
  // Both `smithy.api#httpChecksumRequired` (Content-MD5) and
  // `aws.protocols#httpChecksum` (multi-algorithm) are now emitted
  // by `rest_request.build_request_module`. The v1 multi-algorithm
  // path always picks SHA-256 — the algorithm-member dispatch that
  // honours the input's `ChecksumAlgorithm` field is a follow-up.
  False
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
