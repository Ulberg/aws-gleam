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

import codegen/client
import codegen/code
import codegen/dispatcher
import codegen/named_shapes
import codegen/paginator
import codegen/struct_codec
import codegen/trait_helpers
import codegen/waiter
import codegen/types.{
  type MemberDef, type Resolved, REnum, RIntEnum, RList, RMap, RStruct, RUnion,
}
import gleam/dict
import gleam/list
import gleam/option
import gleam/set.{type Set}
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
  protocol: Protocol,
) -> Result(EmitResult, String) {
  case model.lookup(model, service_id) {
    Error(_) -> Error(string.concat(["service not found: ", service_id]))
    Ok(shape.Service(operations: refs, traits: svc_traits, ..)) -> {
      let service_target = strip_namespace(service_id)
      let metadata = trait_helpers.service_metadata(svc_traits, service_target)
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
                  let requires_md5 = trait_helpers.op_requires_md5(ts)
                  let paginated = trait_helpers.paginated_trait(ts)
                  let waiters = trait_helpers.waitable_traits(ts)
                  case types.is_supported(in_r), types.is_supported(out_r) {
                    True, True ->
                      Ok(#(
                        target,
                        in_r,
                        out_r,
                        err_ids,
                        requires_md5,
                        paginated,
                        waiters,
                      ))
                    _, _ -> Error(Nil)
                  }
                }
              }
            _ -> Error(Nil)
          }
        })

      let named_shapes = collect_named_shapes(model, resolved_ops)
      let is_dispatcher = is_dispatcher_target(service_id)
      let encoder_reachable = case is_dispatcher {
        // Dispatcher targets emit every encoder (they get
        // round-tripped). Production services emit encoders only
        // for input-reachable shapes — see Pass 3a in plan.md.
        True -> set.new()
        False -> input_reachable_structs(model, resolved_ops)
      }
      let preamble =
        emit_named_shapes(model, named_shapes, is_dispatcher, encoder_reachable)

      let emitted_type_names = named_shapes.emitted_type_names(named_shapes)
      let op_specs =
        list.map(resolved_ops, fn(t) {
          let #(
            op_id,
            in_r,
            out_r,
            err_ids,
            requires_md5,
            paginated,
            waiters,
          ) = t
          let local = strip_namespace(op_id)
          let snake = stringutils.pascal_to_snake(local)
          let in_info =
            resolve_io_type(model, name_concat([local, "Input"]), in_r)
          let out_info =
            resolve_io_type(model, name_concat([local, "Output"]), out_r)
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
            requires_md5: requires_md5,
            error_type: trait_helpers.op_error_type(
              local,
              emitted_type_names,
            ),
            pagination_info: pagination_info,
            waiters: waiters,
          )
        })
      let op_blocks =
        list.map(op_specs, fn(spec) {
          emit_operation_with(spec, service_target, protocol, is_dispatcher)
        })
      let client_block = emit_client(metadata)
      let invoke_blocks = list.map(op_specs, emit_invoke)
      let paginate_blocks = list.map(op_specs, emit_paginator)
      let waiter_blocks = list.map(op_specs, emit_waiter)
      let body_content =
        string.concat([
          client_block,
          preamble,
          string.concat(op_blocks),
          string.concat(invoke_blocks),
          string.concat(paginate_blocks),
          string.concat(waiter_blocks),
        ])
      let body =
        string.concat([
          file_header(service_id, protocol, body_content),
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
        operations_emitted: list.map(resolved_ops, fn(t) {
          let #(op_id, _, _, _, _, _, _) = t
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
    /// Full IDs of error shapes the operation can return. Used by the
    /// typed-error emitter to build `<Op>Error` variants and the
    /// `translate_<op>_error` dispatcher.
    error_ids: List(String),
    /// `True` iff the op carries `smithy.api#httpChecksumRequired`.
    /// The emitter appends a `Content-MD5: base64(md5(body))` step
    /// at the end of the generated `build_<op>_request`.
    requires_md5: Bool,
    /// The Gleam type name to use for this operation's typed error
    /// sum. Normally `<OpLocal>Error`, but if a Smithy structure with
    /// that exact name already exists in the service, falls back to
    /// `<OpLocal>OperationError` to avoid duplicate type definitions.
    error_type: String,
    /// Pagination plumbing extracted from `smithy.api#paginated`.
    /// `Some(_)` ⇒ emit a `paginate_<op>` wrapper; `None` ⇒ skip.
    pagination_info: option.Option(paginator.PaginationInfo),
    /// Waiters extracted from `smithy.waiters#waitable`. Empty when
    /// the op carries no waiter or every declared waiter used a
    /// matcher the v1 codegen doesn't support (dropped at trait-
    /// parse time).
    waiters: List(trait_helpers.WaiterDef),
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
    known_error_locals: known_error_locals(spec.error_ids),
  )
}

/// Set of stripped-namespace locals for every error shape the op
/// declared. Used by the waiter emitter to decide whether an
/// `errorType` acceptor maps to a typed variant or the
/// `<Op>ErrorUnknown` fall-through.
fn known_error_locals(error_ids: List(String)) -> Set(String) {
  list.fold(error_ids, set.new(), fn(acc, id) {
    set.insert(acc, strip_namespace(id))
  })
}

fn emit_invoke(spec: OpSpec) -> String {
  let err_type = spec.error_type
  code.render(
    code.Module(items: [
      code.DocComment([
        name_concat([
          "Invoke ",
          spec.local,
          ". Signs the request with SigV4 and dispatches via the configured",
        ]),
        name_concat([
          "HTTP transport. Service errors come back as typed `",
          err_type,
          "`",
        ]),
        "variants; transport, decode, and credentials failures all collapse",
        name_concat([
          "into the generic `",
          err_type,
          "Transport` variant.",
        ]),
      ]),
      client.invoke_fn(
        spec.snake,
        spec.in_info.type_name,
        spec.out_info.type_name,
        spec.error_type,
      ),
      code.Blank,
    ]),
  )
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
        xml_name: option.None,
        xml_namespace: option.None,
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
  ops: List(
    #(
      String,
      Resolved,
      Resolved,
      List(String),
      Bool,
      option.Option(trait_helpers.PaginatedTrait),
      List(trait_helpers.WaiterDef),
    ),
  ),
) -> List(Resolved) {
  let init = #(set.new(), [])
  let #(_seen, found) =
    list.fold(ops, init, fn(acc, t) {
      let #(_op_id, in_r, out_r, err_ids, _, _, _) = t
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

/// Set of struct local-names whose JSON encoder is wire-reachable.
/// awsJson encodes every input on the wire, so we walk transitively
/// from each operation's input shape. Outputs are decode-only — a
/// shape used solely as an output (or its transitive members) has
/// no encoder caller in production. Always-on for dispatcher
/// targets, since the dispatcher round-trips through encoders too.
fn input_reachable_structs(
  model: Model,
  resolved_ops: List(
    #(
      String,
      Resolved,
      Resolved,
      List(String),
      Bool,
      option.Option(trait_helpers.PaginatedTrait),
      List(trait_helpers.WaiterDef),
    ),
  ),
) -> Set(String) {
  list.fold(resolved_ops, set.new(), fn(acc, t) {
    let #(_, in_r, _, _, _, _, _) = t
    walk_for_structs(model, acc, in_r)
  })
}

fn walk_for_structs(
  model: Model,
  acc: Set(String),
  r: Resolved,
) -> Set(String) {
  // Track both structs and unions in `acc` so a self-referential
  // union (DynamoDB's `AttributeValue` references
  // `List<AttributeValue>`) terminates the recursion. Set is
  // checked by local name; we prefix unions with `u:` to keep
  // the namespaces separate from struct names.
  case r {
    RStruct(local_name: name, full_id: id, ..) ->
      case set.contains(acc, name) {
        True -> acc
        False -> {
          let acc = set.insert(acc, name)
          let members = types.resolve_members(model, id)
          list.fold(members, acc, fn(a, m) {
            walk_for_structs(model, a, m.target)
          })
        }
      }
    RUnion(local_name: name, full_id: id, ..) -> {
      let key = name_concat(["u:", name])
      case set.contains(acc, key) {
        True -> acc
        False -> {
          let acc = set.insert(acc, key)
          let members = types.resolve_members(model, id)
          list.fold(members, acc, fn(a, m) {
            walk_for_structs(model, a, m.target)
          })
        }
      }
    }
    RList(element: e, ..) -> walk_for_structs(model, acc, e)
    RMap(value: v, ..) -> walk_for_structs(model, acc, v)
    _ -> acc
  }
}

fn emit_named_shapes(
  model: Model,
  shapes: List(Resolved),
  is_dispatcher: Bool,
  encoder_reachable: Set(String),
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
          // The synthetic Unit struct stands in for `smithy.api#Unit`
          // at operation input/output position and is materialised
          // per-op (as `<OpName>Input` / `<OpName>Output`), not as a
          // top-level type. User-defined shapes that happen to be
          // named `Unit` (e.g. `com.amazonaws.datazone#Unit`) must
          // still emit normally — that's why we key the sentinel on
          // the full Smithy ID, not just `local_name`.
          True -> {
            let _ = #(n, ln)
            []
          }
          False -> {
            let ms = types.resolve_members(model, id)
            // Always emit the encoder when the struct appears as a
            // top-level named shape. Output-only structs that don't
            // appear in any union variant still get one — the cost is
            // a handful of dead encoders, but the previous
            // input-reachable gating produced dangling
            // `encode_<X>_struct` references whenever a union variant
            // wrapped an output-only struct (e.g. SSM's
            // `ExecutionPreview` union over
            // `AutomationExecutionPreview`).
            let _ = encoder_reachable
            [
              emit_record_def(n, ms),
              emit_struct_codec(n, ms, is_dispatcher, True),
            ]
          }
        }
      RUnion(gleam_name: n, full_id: id, ..) -> {
        let ms = types.resolve_members(model, id)
        [
          emit_union_def(n, ms, emitted_type_names),
          emit_union_codec(n, ms, is_dispatcher, emitted_type_names),
        ]
      }
      _ -> []
    }
  })
  |> string.concat
}

// ---------- per-operation emission ----------

fn emit_operation_with(
  spec: OpSpec,
  service_target: String,
  protocol: Protocol,
  is_dispatcher: Bool,
) -> String {
  let snake = spec.snake
  let local_name = spec.local
  let target_value = name_concat([service_target, ".", local_name])
  let ct = content_type(protocol)
  let in_info = spec.in_info
  let out_info = spec.out_info
  string.concat([
    emit_operation_body(
      snake,
      target_value,
      ct,
      in_info,
      out_info,
      is_dispatcher,
      spec.requires_md5,
    ),
    emit_error_type(spec),
    emit_error_translator(spec),
  ])
}

/// Emit the per-operation typed-error sum type. One variant per error
/// shape on the operation, plus `Transport(reason: String)` for
/// non-service failures (network, decode, credentials) and
/// `Unknown(error_type, status, body)` for service errors we don't
/// have a typed variant for.
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

/// Emit `translate_<op>_error` — maps `runtime.ClientError`
/// to the typed `<Op>Error` enum. Transport / decode / credentials
/// failures become the generic `Transport` variant. Service errors
/// dispatch on `error_type` (matched as a suffix to ignore namespace
/// prefixes the wire format may include) against the operation's
/// declared error shapes, falling through to `Unknown`.
/// Table-style translator emitter. Replaces the previous open-coded
/// nested-case ladder (~30 LOC/op) with a per-op decoder table + a
/// one-liner delegating to `runtime.translate_service_error`. Saves
/// ~20 LOC/op and keeps the per-error decode logic structurally
/// identical across protocols, since the translator helper lives in
/// the shared runtime.
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

/// Multi-line `fn(body) { case json.parse(...) { ... } }` closure
/// that decodes one error-shape's JSON body and wraps it in the
/// op-level error sum-type variant. Stays as `code.Raw` since the
/// AST lacks a multi-line lambda node.
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

fn emit_operation_body(
  snake: String,
  target_value: String,
  ct: String,
  in_info: IOTypeInfo,
  out_info: IOTypeInfo,
  is_dispatcher: Bool,
  requires_md5: Bool,
) -> String {
  // For Unit input/output we synthesise a singleton type + codec at
  // the op level. The synth input encoder is wire-live (called via
  // `encode_<op>_input` from `build_<op>_request`); the synth input
  // decoder is dispatcher-only. The synth output decoder is wire-
  // live (called via `decode_<op>_output` from `parse_<op>_response`);
  // the matching output encoder is unused — awsJson never serialises
  // outputs — so it's omitted.
  let synth_in_record = case in_info.synthesise {
    True -> emit_record_def(in_info.type_name, [])
    False -> ""
  }
  let synth_in_encoder = case in_info.synthesise {
    True ->
      string.concat([
        code.render(struct_codec.encoder(
          name_concat(["encode_", snake, "_input_struct"]),
          in_info.type_name,
          [],
          False,
          True,
        )),
        "\n",
      ])
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
  let synth_out_record = case out_info.synthesise {
    True -> emit_record_def(out_info.type_name, [])
    False -> ""
  }
  let synth_out_decoder = case out_info.synthesise {
    True ->
      string.concat([
        code.render(struct_codec.decoder(
          name_concat(["decode_", snake, "_output_struct"]),
          out_info.type_name,
          [],
          True,
          False,
        )),
        "\n",
      ])
    False -> ""
  }

  // Encoder/Decoder helper names — point at either the named-shape
  // codec from the preamble, or the synthetic per-op codec above.
  let in_struct_encoder_name = case in_info.synthesise {
    True -> name_concat(["encode_", snake, "_input_struct"])
    False ->
      name_concat([
        "encode_",
        stringutils.pascal_to_snake(in_info.type_name),
        "_struct_top",
      ])
  }
  let out_struct_decoder_name = case out_info.synthesise {
    True -> name_concat(["decode_", snake, "_output_struct"])
    False ->
      name_concat([
        "decode_",
        stringutils.pascal_to_snake(out_info.type_name),
        "_struct",
      ])
  }

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

  // Dispatcher-only: parses the test-case `params` blob (keyed by
  // Smithy member names) into a typed input.
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

  let out_decoder =
    emit_parse_via_decoder(
      name_concat(["decode_", snake, "_output"]),
      out_info.type_name,
      out_struct_decoder_name,
    )

  let build =
    emit_build(in_info.type_name, snake, target_value, ct, requires_md5)
  let parse = emit_parse(out_info.type_name, snake)
  string.concat([
    "\n",
    synth_in_record,
    synth_in_encoder,
    synth_in_decoder,
    synth_out_record,
    synth_out_decoder,
    in_encoder,
    in_decoder,
    out_decoder,
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

fn resolve_io_type(
  model: Model,
  synth_name: String,
  r: Resolved,
) -> IOTypeInfo {
  case r {
    RStruct(local_name: ln, gleam_name: gn, full_id: id, ..) ->
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

// ---------- encoder helpers ----------

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

/// The anonymous `fn(s) { case s { ... } }` lambda body of a
/// `decode_<E>_enum`. Same Raw-fragment pattern as
/// `int_enum_decode_lambda`.
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
  code.render(code.Module(items: [enc, code.Blank, dec, code.Blank]))
}

/// The anonymous `fn(n) { case n { ... } }` lambda body of a
/// `decode_<E>_int_enum`. Wrapped in `code.Raw` because the AST
/// has no Lambda node; the inner `case` over wire integers is
/// rendered via the same Gleam-source helpers (`int_to_string`
/// for the patterns, `string.join` for the fold) so the
/// emitter source itself stays free of `<>` chains.
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

fn emit_struct_codec(
  name: String,
  members: List(MemberDef),
  is_dispatcher: Bool,
  emit_encoder: Bool,
) -> String {
  let snake = stringutils.pascal_to_snake(name)
  // awsJson1_x ignores `@jsonName` per the Smithy protocol spec, so
  // every codec keys by the Smithy member name. The decoder is
  // always wire-live (response parsing). The encoder pair is gated
  // on `emit_encoder` — production services skip encoders for
  // shapes that aren't reachable from any operation INPUT, since
  // those shapes only ever appear as outputs.
  let encoders = case emit_encoder {
    True -> [
      struct_codec.encoder(
        name_concat(["encode_", snake, "_struct"]),
        name,
        members,
        False,
        True,
      ),
      struct_codec.encoder(
        name_concat(["encode_", snake, "_struct_top"]),
        name,
        members,
        True,
        True,
      ),
    ]
    False -> []
  }
  let always = [
    struct_codec.decoder(
      name_concat(["decode_", snake, "_struct"]),
      name,
      members,
      True,
      False,
    ),
  ]
  let conditional = case is_dispatcher {
    True -> [
      struct_codec.decoder(
        name_concat(["decode_", snake, "_struct_params"]),
        name,
        members,
        True,
        True,
      ),
    ]
    False -> []
  }
  encoders
  |> list.append(always)
  |> list.append(conditional)
  |> list.map(code.render)
  |> list.map(fn(s) { string.concat([s, "\n"]) })
  |> string.concat
}

fn emit_union_codec(
  name: String,
  members: List(MemberDef),
  is_dispatcher: Bool,
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
                    code.StrLit(value: m.member_name),
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
  // Wrap union decoder bodies in `decode.recursive` so self-
  // referential unions (e.g. Smithy's `XmlUnionShape` with a
  // `unionValue: XmlUnionShape` member) don't eagerly construct
  // their `decode.one_of` branches and infinite-loop.
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
  let dec_params_items = case is_dispatcher {
    True -> [
      code.Blank,
      code.Fn(
        public: True,
        name: name_concat(["decode_", snake, "_union_params"]),
        params: [],
        return: code.CodeSome(name_concat(["decode.Decoder(", name, ")"])),
        body: union_decoder_body(name, members, fn(union_name, m) {
          emit_union_branch_params(union_name, m, emitted)
        }),
      ),
      code.Blank,
    ]
    False -> []
  }
  code.render(
    code.Module(items: list.append(
      [enc, code.Blank, dec, code.Blank],
      dec_params_items,
    )),
  )
}

/// Build the body of a `decode_<U>_union*` function — a
/// `decode.one_of` over the branch decoders, or an unconditional
/// failure when the union has no variants. Wrapped in
/// `decode.recursive` so self-referential unions don't eagerly
/// construct their branches.
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
    code.StrLit(value: m.member_name),
    code.Raw(fragment: types.json_decoder(m.target)),
    code.Raw(
      fragment: name_concat([
        "fn(x) { decode.success(",
        ctor,
        "(x)) }",
      ]),
    ),
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
    code.Raw(
      fragment: name_concat([
        "fn(x) { decode.success(",
        ctor,
        "(x)) }",
      ]),
    ),
  ])
}

fn emit_build(
  input_type: String,
  snake: String,
  target_value: String,
  ct: String,
  requires_md5: Bool,
) -> String {
  let body_str_let =
    code.Let(
      name: "body_str",
      value: code.Call(
        head: code.Ident(name: name_concat(["encode_", snake, "_input"])),
        args: [code.Ident(name: "input")],
      ),
    )
  let body_let =
    code.Let(
      name: "body",
      value: code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
        code.Ident(name: "body_str"),
      ]),
    )
  let headers_let =
    code.Let(
      name: "headers",
      value: code.Call(head: code.Ident(name: "dict.from_list"), args: [
        code.ListLit(
          items: [
            code.Tuple(items: [
              code.StrLit(value: "Content-Type"),
              code.StrLit(value: ct),
            ]),
            code.Tuple(items: [
              code.StrLit(value: "Content-Length"),
              code.Raw(fragment: "int.to_string(bit_array.byte_size(body))"),
            ]),
            code.Tuple(items: [
              code.StrLit(value: "X-Amz-Target"),
              code.StrLit(value: target_value),
            ]),
          ],
          tail: code.CodeNone,
        ),
      ]),
    )
  // `@httpChecksumRequired` operations land a final `let headers =
  // rest.with_content_md5_header(headers, body)` step after the
  // base headers are built. Body is already a BitArray at this
  // point, so the hash sees the exact bytes about to go on the
  // wire.
  let md5_step = case requires_md5 {
    True -> [
      code.Let(
        name: "headers",
        value: code.Call(
          head: code.Ident(name: "rest.with_content_md5_header"),
          args: [
            code.Ident(name: "headers"),
            code.Ident(name: "body"),
          ],
        ),
      ),
    ]
    False -> []
  }
  let return_tuple =
    code.Tuple(items: [
      code.StrLit(value: "POST"),
      code.StrLit(value: "/"),
      code.Ident(name: "headers"),
      code.Ident(name: "body"),
    ])
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: name_concat(["build_", snake, "_request"]),
        params: [code.Param(name: "input", type_: input_type)],
        return: code.CodeSome(
          "#(String, String, dict.Dict(String, String), BitArray)",
        ),
        body: code.Block(
          items: list.flatten([
            [body_str_let, body_let, headers_let],
            md5_step,
            [return_tuple],
          ]),
        ),
      ),
      code.Blank,
    ]),
  )
}

fn emit_parse(output_type: String, snake: String) -> String {
  let decoder = name_concat(["decode_", snake, "_output"])
  let inner_text_case =
    code.Case(scrutinee: code.Ident(name: "text"), branches: [
      code.Branch(
        pattern: "\"\"",
        body: code.Call(head: code.Ident(name: decoder), args: [
          code.StrLit(value: "{}"),
        ]),
      ),
      code.Branch(
        pattern: "_",
        body: code.Call(head: code.Ident(name: decoder), args: [
          code.Ident(name: "text"),
        ]),
      ),
    ])
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: name_concat(["parse_", snake, "_response"]),
        params: [
          code.Param(name: "_code", type_: "Int"),
          code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
          code.Param(name: "body", type_: "BitArray"),
        ],
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

/// Build a Gleam identifier name from a list of parts. Used in
/// place of the `<>` operator throughout codegen so the Gleam
/// source of the emitters doesn't itself use string concat to
/// shape the generated identifiers.
fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

/// Operation-level traits the emitter doesn't yet honour. Emitting code
/// for these would produce wrong-on-the-wire requests.
fn op_uses_unsupported_trait(traits: shape.Traits) -> Bool {
  // `smithy.api#httpChecksumRequired` is no longer in the skip list —
  // `emit_build` appends a `rest.with_content_md5_header` step when
  // the trait is present. `smithy.api#requestCompression` is
  // genuinely unsupported (no gzip middleware yet).
  dict.has_key(traits, ShapeId("smithy.api#requestCompression"))
}


/// Build the module-doc + import block as a `code.Module` AST. The
/// body itself is still raw string concatenation (each
/// emit_operation, emit_record_def etc. is independent), so we
/// scan it for `<module>.` references to decide which imports
/// survive — this drops e.g. `gleam/string` from `dynamodb.gleam`
/// where the body never reaches into the `string` module.
fn file_header(service_id: String, protocol: Protocol, body: String) -> String {
  let proto_str = case protocol {
    AwsJson10 -> "awsJson1_0"
    AwsJson11 -> "awsJson1_1"
  }
  let candidates = [
    #("aws/credentials", "credentials.", code.CodeNone),
    #("aws/endpoints", "endpoints.", code.CodeNone),
    #("aws/internal/credentials_cache", "credentials_cache.", code.CodeNone),
    #("aws/pagination", "pagination.", code.CodeNone),
    #("aws/waiter", "waiter.", code.CodeNone),
    #("aws/region", "region.", code.CodeNone),
    #("aws/internal/client/runtime", "runtime.", code.CodeSome("runtime")),
    #("aws/internal/codec/json_document", "json_document.", code.CodeNone),
    #("aws/internal/codec/json_float", "json_float.", code.CodeNone),
    #("aws/internal/codec/json_timestamp", "json_timestamp.", code.CodeNone),
    #("aws/internal/http_send", "http_send.", code.CodeNone),
    #("gleam/bit_array", "bit_array.", code.CodeNone),
    #("gleam/dict", "dict.", code.CodeNone),
    #("gleam/dynamic/decode", "decode.", code.CodeNone),
    #("gleam/int", "int.", code.CodeNone),
    #("gleam/json", "json.", code.CodeNone),
    #("gleam/list", "list.", code.CodeNone),
    #("gleam/option", "option.", code.CodeNone),
    #("gleam/result", "result.", code.CodeNone),
  ]
  let used =
    candidates
    |> list.filter(fn(c) { code.references_module(body, c.1) })
    |> list.map(fn(c) { code.Import(path: c.0, alias: c.2, unqualified: []) })
  let items =
    [
      code.ModuleDocComment([
        name_concat(["Generated from ", service_id, " (", proto_str, ")."]),
        "DO NOT EDIT. Re-generate via the codegen subproject.",
      ]),
      code.Blank,
    ]
    |> list.append(used)
  code.render(code.Module(items: items))
}

// ---------- helpers ----------

/// Smithy protocol-test models live under `aws.protocoltests.*` —
/// the runner round-trips dispatcher params blobs through the
/// SDK's JSON `_struct_params` / `_union_params` / `_input`
/// decoders, so these have to be emitted. Real services are wire-
/// only and don't reach those codecs.
fn is_dispatcher_target(service_id: String) -> Bool {
  string.starts_with(service_id, "aws.protocoltests.")
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
// `stringutils.pascalize_member`, `stringutils.int_to_string` live in
// `codegen/src/internal/stringutils.gleam` — see Pass 4 in
// plan.md for the de-duplication.
