//// Code emitter for awsQuery (form-urlencoded body) and ec2Query
//// (same wire shape, different list-encoding rules — handled by the
//// same generator at this level since the empty-input case is
//// identical).
////
//// For empty-input operations the body is:
////   Action=<OperationName>&Version=<service.version>
//// method = POST, uri = "/", content-type = application/x-www-form-urlencoded.
////
//// For typed-input operations (members of String / Bool / Int / Float
//// / Blob / Enum / IntegerEnum), the body becomes
////   Action=Op&Version=v&Field1=val1&Field2=val2…
//// with `&FieldN=value` appended for each `Some(value)` member.
//// Trade-offs for the first typed-input slice:
////   * Float NaN / Infinity / -Infinity get AWS's string names.
////   * Blob members are base64-encoded then URL-encoded.
////   * Enum members serialise as their wire string value, URL-encoded.
////   * IntegerEnum members serialise as the integer wire value.
////   * Members carrying HTTP bindings (header / query / label /
////     payload), `@idempotencyToken`, or `@hostLabel` traits, and
////     ops with `@requestCompression` / `@endpoint` are still
////     skipped — those need per-feature emit which lands in later
////     slices alongside lists / maps / nested / timestamps.

import codegen/code.{type Code, CodeSome}
import codegen/dispatcher
import codegen/error_dispatch
import codegen/named_shapes
import codegen/struct_codec
import codegen/trait_helpers
import codegen/types.{type MemberDef}
import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{type ShapeId, ShapeId}
import smithy/trait

pub type Variant {
  AwsQuery
  Ec2Query
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
  variant: Variant,
) -> Result(EmitResult, String) {
  case model.lookup(model, service_id) {
    Error(_) -> Error(string.concat(["service not found: ", service_id]))
    Ok(shape.Service(operations: refs, version: ver, ..)) -> {
      let version = case ver {
        Some(v) -> v
        None -> "unknown"
      }
      let emitted_ops =
        list.filter_map(refs, fn(ref) {
          let ShapeId(target) = ref.target
          case model.lookup(model, target) {
            Ok(shape.Operation(input: in_ref, traits: op_traits, ..)) ->
              case classify_input(model, in_ref) {
                EmptyInput -> Ok(emit_empty_operation(target, version))
                ScalarTypedInput(input_id) ->
                  case has_op_level_blocker(op_traits) {
                    True -> Error(Nil)
                    False ->
                      Ok(emit_scalar_typed_operation(
                        model,
                        target,
                        version,
                        input_id,
                        variant,
                        op_traits,
                      ))
                  }
                UnsupportedInput -> Error(Nil)
              }
            _ -> Error(Nil)
          }
        })

      // Gather enum + int-enum types referenced by any typed input.
      // De-duplicated so each enum lands once even if referenced from
      // multiple operations.
      let referenced_enums = collect_referenced_enums(model, emitted_ops)
      let enum_blocks = list.map(referenced_enums, emit_enum_block)

      // Walk every operation (even ones whose inputs we don't emit
      // yet) to gather error refs. `@httpResponseTests` on the error
      // structures themselves get dispatched independent of whether
      // the parent operation has a typed request side.
      let unique_err_ids =
        list.flat_map(refs, fn(ref) {
          let ShapeId(target) = ref.target
          case model.lookup(model, target) {
            Ok(shape.Operation(errors: errs, ..)) ->
              list.map(errs, fn(e) {
                let ShapeId(eid) = e.target
                eid
              })
            _ -> []
          }
        })
        |> error_dispatch.dedupe_strings
      let err_shape_blocks =
        list.map(unique_err_ids, fn(err_id) {
          let local = strip_namespace(err_id)
          let wire_code = aws_query_error_code(model, err_id, local)
          error_dispatch.emit_parse_fn(local, wire_code)
        })
      // Dedupe nested structs by `full_id` across all ops so each
      // shape gets one type def + one `encode_<snake>_at` helper.
      let referenced_structs =
        list.flat_map(emitted_ops, fn(e) { e.referenced_structs })
        |> dedupe_structs_by_id
      let nested_struct_blocks =
        list.map(referenced_structs, fn(rs) {
          emit_nested_struct_block(model, rs, variant)
        })
      let body_inner =
        string.concat([
          string.concat(enum_blocks),
          string.concat(nested_struct_blocks),
          string.concat(list.map(emitted_ops, fn(e) { e.code })),
          string.concat(err_shape_blocks),
        ])
      let header = file_header(service_id, variant, body_inner)
      let body = string.concat([header, "\n", body_inner])
      let op_dispatcher_specs =
        list.map(emitted_ops, fn(e) {
          let local = strip_namespace(e.operation_id)
          let snake = stringutils.pascal_to_snake(local)
          dispatcher.DispatcherSpec(
            op_id: e.operation_id,
            snake: snake,
            input_type: name_concat([local, "Input"]),
            has_typed_input: e.has_typed_input,
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
        operations_emitted: list.map(emitted_ops, fn(e) { e.operation_id }),
        dispatcher_specs: dispatcher_specs,
      ))
    }
    Ok(_) -> Error(string.concat(["not a service: ", service_id]))
  }
}

type EmittedOp {
  EmittedOp(
    operation_id: String,
    code: String,
    has_typed_input: Bool,
    referenced_enums: List(types.Resolved),
    /// Every nested struct/list shape transitively referenced from
    /// this op's input. The driver dedupes across ops and emits one
    /// `encode_<struct>_at(prefix, value)` helper per unique struct
    /// at the file level.
    referenced_structs: List(types.Resolved),
  )
}

type InputClass {
  EmptyInput
  ScalarTypedInput(input_id: String)
  UnsupportedInput
}

fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

fn has_op_level_blocker(traits: dict.Dict(ShapeId, a)) -> Bool {
  // `smithy.api#endpoint` (hostPrefix substitution) is *not* a blocker
  // here — it only affects the request's Host header, which the
  // runtime/transport sets, not the body bytes the awsquery emitter
  // produces. `@hostLabel` members participate in the body too (the
  // EndpointWithHostLabelOperation fixture's expected body includes
  // `&label=bar`), so they fall out of `no_member_traits` likewise.
  let blockers = ["aws.protocols#requestCompression"]
  list.any(blockers, fn(t) { dict.has_key(traits, ShapeId(t)) })
}

fn classify_input(model: Model, ref: shape.Reference) -> InputClass {
  let ShapeId(id) = ref.target
  case id {
    "smithy.api#Unit" -> EmptyInput
    _ ->
      case model.lookup(model, id) {
        Ok(shape.Structure(members: raw, ..)) ->
          case dict.size(raw) {
            0 -> EmptyInput
            _ -> {
              let members = types.resolve_members(model, id)
              case all_supported(model, members) {
                // awsQuery / ec2Query body builders skip non-Body
                // members at emission time (per the Smithy spec —
                // HTTP bindings are ignored for these protocols),
                // so the supportedness check no longer needs the
                // legacy `all_body_bound` / `no_member_traits`
                // guards.
                True -> ScalarTypedInput(input_id: id)
                False -> UnsupportedInput
              }
            }
          }
        _ -> UnsupportedInput
      }
  }
}

fn all_supported(model: Model, members: List(MemberDef)) -> Bool {
  list.all(members, fn(m) { is_supported_deep(model, m.target, set.new()) })
}

/// Recursive supportedness check used by both `classify_input` and
/// the per-field encoder dispatch. Allows scalars + Blob + Enum +
/// IntegerEnum + lists (of supported elements) + structs (with
/// all-supported members; tracked via a visited-set to bottom out
/// on self-referential shapes). Maps / unions / timestamps /
/// documents stay unsupported — they land in later slices.
fn is_supported_deep(
  model: Model,
  r: types.Resolved,
  visited: set.Set(String),
) -> Bool {
  case r {
    types.RPrim(_) -> True
    types.RBlob -> True
    types.REnum(..) -> True
    types.RIntEnum(..) -> True
    types.RTimestamp -> True
    types.RList(element: e, ..) -> is_supported_deep(model, e, visited)
    // Maps: slice 3 assumes String keys (every map in the corpus
    // uses `smithy.api#String`); value type is checked recursively.
    // Sparse maps surface as `Dict(K, Option(V))` from the existing
    // type pipeline — handled in encode_value_expr's RMap branch.
    types.RMap(key: k, value: v, ..) ->
      is_supported_map_key(k) && is_supported_deep(model, v, visited)
    types.RStruct(full_id: sid, ..) ->
      case set.contains(visited, sid) {
        True -> True
        False -> {
          let nested = types.resolve_members(model, sid)
          let visited2 = set.insert(visited, sid)
          list.all(nested, fn(m) {
            is_supported_deep(model, m.target, visited2)
          })
          && no_member_traits(model, sid)
        }
      }
    _ -> False
  }
}

fn is_supported_map_key(k: types.Resolved) -> Bool {
  case k {
    types.RPrim(types.PString) -> True
    types.REnum(..) -> True
    _ -> False
  }
}

fn no_member_traits(_model: Model, _struct_id: String) -> Bool {
  // awsQuery / ec2Query ignore every HTTP binding trait
  // (`@httpHeader`, `@httpQuery`, `@httpLabel`, `@httpPayload`),
  // per the Smithy spec — the wire is form-urlencoded body only.
  // `@idempotencyToken` (auto-fill via `rest.idempotency_token()`)
  // and `@hostLabel` (member also lands in the body verbatim)
  // both run through the same encoder paths.
  // → No struct-level blockers; per-member filtering happens at
  // body-emission time via `is_body_bound_member`.
  True
}

/// Members carrying HTTP binding traits don't contribute to the
/// awsQuery / ec2Query wire body — the protocol spec says HTTP
/// bindings are ignored. The field still exists in the Gleam input
/// record (so the API matches the model), but the body builder
/// skips it.
fn is_body_bound_member(model: Model, struct_id: String, name: String) -> Bool {
  let traits = member_traits(model, struct_id, name)
  let http_traits = [
    "smithy.api#httpHeader",
    "smithy.api#httpQuery",
    "smithy.api#httpLabel",
    "smithy.api#httpPayload",
  ]
  list.all(http_traits, fn(t) { !dict.has_key(traits, ShapeId(t)) })
}

fn emit_empty_operation(op_id: String, version: String) -> EmittedOp {
  let local = strip_namespace(op_id)
  let pascal = local
  let snake = stringutils.pascal_to_snake(local)
  let input_type = name_concat([pascal, "Input"])
  let output_type = name_concat([pascal, "Output"])
  let body_literal = name_concat(["Action=", local, "&Version=", version])
  let module =
    code.Module(items: [
      code.Blank,
      code.TypeDef(public: True, is_opaque: False, name: input_type, variants: [
        code.UnitVariant(name: input_type),
      ]),
      code.Blank,
      code.TypeDef(public: True, is_opaque: False, name: output_type, variants: [
        code.UnitVariant(name: output_type),
      ]),
      code.Blank,
      build_empty_request_fn(snake, input_type, body_literal),
      code.Blank,
      parse_response_fn(snake, output_type),
      code.Blank,
    ])
  EmittedOp(
    operation_id: op_id,
    code: code.render(module),
    has_typed_input: False,
    referenced_enums: [],
    referenced_structs: [],
  )
}

/// Emit a typed-scalar-input operation: Input record with required
/// members as plain fields and optional members as Option(T),
/// `decode_<snake>_input` for the test-fixture JSON, and
/// `build_<snake>_request` that form-urlencodes present fields onto
/// the standard `Action=Op&Version=v` body prefix.
fn emit_scalar_typed_operation(
  model: Model,
  op_id: String,
  version: String,
  input_id: String,
  variant: Variant,
  op_traits: shape.Traits,
) -> EmittedOp {
  let local = strip_namespace(op_id)
  let snake = stringutils.pascal_to_snake(local)
  let input_type = name_concat([local, "Input"])
  let output_type = name_concat([local, "Output"])
  // Wire-form must follow declared member order (per the Smithy
  // awsQuery spec); the rest of the codegen reads members in
  // alphabetical order from `resolve_members` so its existing
  // codec output stays stable across all eight protocols.
  let members = types.resolve_members_in_order(model, input_id)
  let wire_names =
    list.map(members, fn(m) { wire_name_for(model, input_id, m, variant) })
  let referenced_enums =
    list.filter(list.map(members, fn(m) { m.target }), fn(r) {
      case r {
        types.REnum(..) -> True
        types.RIntEnum(..) -> True
        _ -> False
      }
    })
  let module =
    code.Module(items: [
      code.Blank,
      named_shapes.record_def(input_type, members),
      code.Blank,
      named_shapes.record_default_fn(
        stringutils.pascal_to_snake(input_type),
        input_type,
        members,
      ),
      code.Blank,
      code.TypeDef(public: True, is_opaque: False, name: output_type, variants: [
        code.UnitVariant(name: output_type),
      ]),
      code.Blank,
      struct_codec.decoder(
        name_concat(["decode_", snake, "_input_struct"]),
        input_type,
        members,
        True,
        True,
      ),
      code.Blank,
      code.Fn(
        public: True,
        name: name_concat(["decode_", snake, "_input"]),
        params: [code.Param(name: "json_string", type_: "String")],
        return: CodeSome(name_concat(["Result(", input_type, ", String)"])),
        body: code.Raw(
          fragment: name_concat([
            "json.parse(json_string, decode_",
            snake,
            "_input_struct())\n  |> result.map_error(fn(_) { \"input JSON decode failed\" })",
          ]),
        ),
      ),
      code.Blank,
      build_scalar_request_fn(
        model,
        input_id,
        variant,
        snake,
        input_type,
        local,
        version,
        op_traits,
        list.zip(members, wire_names),
      ),
      code.Blank,
      parse_response_fn(snake, output_type),
      code.Blank,
    ])
  let referenced_structs = collect_referenced_structs(model, members, set.new())
  // The structs we surface here include any nested struct's own
  // referenced enums — pull them out so the file header sees them too.
  let nested_enums =
    list.flat_map(referenced_structs, fn(rs) {
      case rs {
        types.RStruct(full_id: sid, ..) -> {
          let inner = types.resolve_members(model, sid)
          list.filter(list.map(inner, fn(m) { m.target }), fn(r) {
            case r {
              types.REnum(..) -> True
              types.RIntEnum(..) -> True
              _ -> False
            }
          })
        }
        _ -> []
      }
    })
  EmittedOp(
    operation_id: op_id,
    code: code.render(module),
    has_typed_input: True,
    referenced_enums: list.append(referenced_enums, nested_enums),
    referenced_structs: referenced_structs,
  )
}

/// Walk the input struct's member targets and gather every nested
/// `RStruct` reachable. Visited-set tracks shape IDs already
/// queued so recursive structs (e.g. `StructArg.RecursiveArg →
/// StructArg`) don't loop. Lists are not added themselves — their
/// helper is inlined as a `list.index_fold` at the call site —
/// but we DO descend into their element type to catch any nested
/// struct inside.
fn collect_referenced_structs(
  model: Model,
  members: List(MemberDef),
  visited: set.Set(String),
) -> List(types.Resolved) {
  list.flat_map(members, fn(m) { collect_from_target(model, m.target, visited) })
}

fn collect_from_target(
  model: Model,
  target: types.Resolved,
  visited: set.Set(String),
) -> List(types.Resolved) {
  case target {
    types.RList(element: e, ..) -> collect_from_target(model, e, visited)
    types.RMap(value: v, ..) -> collect_from_target(model, v, visited)
    types.RStruct(full_id: sid, ..) ->
      case set.contains(visited, sid) {
        True -> []
        False -> {
          let v2 = set.insert(visited, sid)
          let nested = types.resolve_members(model, sid)
          let nested_structs =
            list.flat_map(nested, fn(m) {
              collect_from_target(model, m.target, v2)
            })
          [target, ..nested_structs]
        }
      }
    _ -> []
  }
}

/// Resolve a member's wire-form name per the awsQuery / ec2Query
/// spec. awsQuery honours `@xmlName`, falling back to the Smithy
/// member name. ec2Query gives `@aws.protocols#ec2QueryName` top
/// priority, then `@xmlName` with first-letter upper-cased, then
/// the Smithy member name (already PascalCase). Pinned by
/// `Ec2QueryNameDistinctFromXmlNameAndMemberName` in the corpus.
fn wire_name_for(
  model: Model,
  struct_id: String,
  m: MemberDef,
  variant: Variant,
) -> String {
  let traits = member_traits(model, struct_id, m.member_name)
  case variant {
    AwsQuery -> {
      case trait_string(traits, "smithy.api#xmlName") {
        Some(s) -> s
        None -> m.member_name
      }
    }
    Ec2Query -> {
      case trait_string(traits, "aws.protocols#ec2QueryName") {
        Some(s) -> s
        None ->
          case trait_string(traits, "smithy.api#xmlName") {
            Some(s) -> uppercase_first(s)
            None -> uppercase_first(m.member_name)
          }
      }
    }
  }
}

fn trait_string(
  traits: shape.Traits,
  trait_id: String,
) -> option.Option(String) {
  case dict.get(traits, ShapeId(trait_id)) {
    Ok(Some(trait.String(s))) -> Some(s)
    _ -> None
  }
}

fn member_traits(
  model: Model,
  struct_id: String,
  member_name: String,
) -> shape.Traits {
  case model.lookup(model, struct_id) {
    Ok(shape.Structure(members: ms, ..)) ->
      case dict.get(ms, member_name) {
        Ok(mem) -> mem.traits
        _ -> dict.new()
      }
    _ -> dict.new()
  }
}

fn uppercase_first(s: String) -> String {
  case string.to_graphemes(s) {
    [] -> s
    [h, ..rest] -> string.uppercase(h) <> string.concat(rest)
  }
}

fn collect_referenced_enums(
  _model: Model,
  emitted: List(EmittedOp),
) -> List(types.Resolved) {
  list.flat_map(emitted, fn(e) { e.referenced_enums })
  |> dedupe_by_name
}

fn dedupe_structs_by_id(rs: List(types.Resolved)) -> List(types.Resolved) {
  list.fold(rs, #([], set.new()), fn(acc, r) {
    let #(out, seen) = acc
    case r {
      types.RStruct(full_id: id, ..) ->
        case set.contains(seen, id) {
          True -> #(out, seen)
          False -> #([r, ..out], set.insert(seen, id))
        }
      _ -> #(out, seen)
    }
  }).0
  |> list.reverse
}

/// Emit the record type def + `encode_<snake>_at(prefix, value)`
/// helper for a single nested struct. The encoder takes the wire
/// prefix string (e.g. `"Nested"` or `"ComplexListArg.member.1"`)
/// and an instance of the struct, returns a `&k=v` body fragment
/// for every `Some(_)` member.
fn emit_nested_struct_block(
  model: Model,
  rs: types.Resolved,
  variant: Variant,
) -> String {
  case rs {
    types.RStruct(gleam_name: gn, full_id: sid, ..) -> {
      let snake = stringutils.pascal_to_snake(gn)
      // Nested struct wire form, like the top-level input, follows
      // declared member order — the per-member `encode_<S>_at`
      // helper appends `&prefix.<field>=<value>` in this sequence.
      let members = types.resolve_members_in_order(model, sid)
      let type_def = named_shapes.record_def(gn, members)
      let field_clauses =
        list.map(members, fn(m) {
          let wire = wire_name_for(model, sid, m, variant)
          let inner =
            encode_value_expr(
              m.target,
              "v",
              name_concat(["prefix <> \".", wire, "\""]),
              member_traits(model, sid, m.member_name),
              variant,
              m.timestamp_format,
            )
          case m.required {
            True ->
              name_concat([
                "  let v = s.",
                m.snake_name,
                "\n",
                "  let acc = acc <> ",
                inner,
                "\n",
              ])
            False ->
              name_concat([
                "  let acc = case s.",
                m.snake_name,
                " { option.None -> acc option.Some(v) -> acc <> ",
                inner,
                " }\n",
              ])
          }
        })
        |> string.concat
      let encoder =
        name_concat([
          "pub fn encode_",
          snake,
          "_at(prefix: String, s: ",
          gn,
          ") -> String {\n",
          "  let acc = \"\"\n",
          field_clauses,
          "  acc\n",
          "}\n",
        ])
      // Decoder for the protocol-test JSON fixture (params side).
      // Member-keyed, params_nested so nested struct refs call
      // sibling `decode_<S>_struct_params()` rather than wire-form
      // `_struct` decoders we don't emit on the awsQuery path.
      let decoder =
        struct_codec.decoder(
          name_concat(["decode_", snake, "_struct_params"]),
          gn,
          members,
          True,
          True,
        )
      let default_fn = named_shapes.record_default_fn(snake, gn, members)
      string.concat([
        "\n",
        code.render(type_def),
        "\n\n",
        code.render(default_fn),
        "\n",
        encoder,
        "\n",
        code.render(decoder),
        "\n",
      ])
    }
    _ -> ""
  }
}

fn dedupe_by_name(rs: List(types.Resolved)) -> List(types.Resolved) {
  list.fold(rs, #([], set.new()), fn(acc, r) {
    let #(out, seen) = acc
    let key = case r {
      types.REnum(gleam_name: n, ..) -> n
      types.RIntEnum(gleam_name: n, ..) -> n
      _ -> ""
    }
    case set.contains(seen, key) {
      True -> #(out, seen)
      False -> #([r, ..out], set.insert(seen, key))
    }
  }).0
  |> list.reverse
}

fn emit_enum_block(r: types.Resolved) -> String {
  case r {
    types.REnum(gleam_name: name, variants: vs, ..) -> {
      let snake = stringutils.pascal_to_snake(name)
      let first_ctor = case vs {
        [v, ..] -> v.gleam_ctor
        [] -> name_concat([name, "Unknown"])
      }
      let type_def = named_shapes.enum_def(name, vs)
      let to_wire =
        code.Fn(
          public: True,
          name: name_concat([snake, "_to_wire"]),
          params: [code.Param(name: "v", type_: name)],
          return: CodeSome("String"),
          body: code.Case(
            scrutinee: code.Ident(name: "v"),
            branches: list.map(vs, fn(v) {
              code.Branch(
                pattern: v.gleam_ctor,
                body: code.StrLit(value: v.wire_value),
              )
            }),
          ),
        )
      let decoder =
        code.Fn(
          public: True,
          name: name_concat(["decode_", snake, "_enum"]),
          params: [],
          return: CodeSome(name_concat(["decode.Decoder(", name, ")"])),
          body: code.Call(head: code.Ident(name: "decode.then"), args: [
            code.Ident(name: "decode.string"),
            enum_decode_lambda(vs, first_ctor),
          ]),
        )
      string.concat([
        "\n",
        code.render(type_def),
        "\n\n",
        code.render(to_wire),
        "\n\n",
        code.render(decoder),
        "\n",
      ])
    }
    types.RIntEnum(gleam_name: name, variants: vs, ..) -> {
      let snake = stringutils.pascal_to_snake(name)
      let first_ctor = case vs {
        [v, ..] -> v.gleam_ctor
        [] -> name_concat([name, "Unknown"])
      }
      let type_def = named_shapes.int_enum_def(name, vs)
      let to_int =
        code.Fn(
          public: True,
          name: name_concat([snake, "_to_int"]),
          params: [code.Param(name: "v", type_: name)],
          return: CodeSome("Int"),
          body: code.Case(
            scrutinee: code.Ident(name: "v"),
            branches: list.map(vs, fn(v) {
              code.Branch(
                pattern: v.gleam_ctor,
                body: code.Raw(fragment: int_to_str(v.wire_value)),
              )
            }),
          ),
        )
      let decoder =
        code.Fn(
          public: True,
          name: name_concat(["decode_", snake, "_int_enum"]),
          params: [],
          return: CodeSome(name_concat(["decode.Decoder(", name, ")"])),
          body: code.Call(head: code.Ident(name: "decode.then"), args: [
            code.Ident(name: "decode.int"),
            int_enum_decode_lambda(vs, first_ctor),
          ]),
        )
      string.concat([
        "\n",
        code.render(type_def),
        "\n\n",
        code.render(to_int),
        "\n\n",
        code.render(decoder),
        "\n",
      ])
    }
    _ -> ""
  }
}

/// `fn(s) { case s { "wire" -> decode.success(Ctor) ... } }` —
/// the inner lambda body of an enum's `decode_<E>_enum` helper.
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

fn int_enum_decode_lambda(
  variants: List(types.IntEnumVariant),
  first_ctor: String,
) -> code.Code {
  let arms =
    list.map(variants, fn(v) {
      string.concat([
        "      ",
        int_to_str(v.wire_value),
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

@external(erlang, "erlang", "integer_to_binary")
fn int_to_str(n: Int) -> String

/// `pub fn build_<snake>_request(_input: <input_type>) -> #(...) { ... }`
/// — the empty-input form.
fn build_empty_request_fn(
  snake: String,
  input_type: String,
  body_literal: String,
) -> Code {
  let headers_assign =
    code.Let(
      name: "headers",
      value: code.Raw(
        fragment: "dict.from_list([#(\"Content-Type\", \"application/x-www-form-urlencoded\")])",
      ),
    )
  let tuple_expr =
    code.Tuple(items: [
      code.StrLit(value: "POST"),
      code.StrLit(value: "/"),
      code.Ident(name: "headers"),
      code.Raw(fragment: name_concat(["<<\"", body_literal, "\">>"])),
    ])
  code.Fn(
    public: True,
    name: name_concat(["build_", snake, "_request"]),
    params: [code.Param(name: "_input", type_: input_type)],
    return: CodeSome("#(String, String, dict.Dict(String, String), BitArray)"),
    body: code.Block(items: [headers_assign, tuple_expr]),
  )
}

fn build_scalar_request_fn(
  model: Model,
  struct_id: String,
  variant: Variant,
  snake: String,
  input_type: String,
  op_name: String,
  version: String,
  op_traits: shape.Traits,
  members: List(#(MemberDef, String)),
) -> Code {
  let prefix = name_concat(["Action=", op_name, "&Version=", version])
  let body_init = code.Let(name: "body", value: code.StrLit(value: prefix))
  // Skip non-body-bound members (HTTP header / query / label /
  // payload). awsQuery / ec2Query ignore those traits per the
  // Smithy spec — the field stays on the input record so the API
  // matches the model, but the wire body doesn't carry it.
  let body_members =
    list.filter(members, fn(pair) {
      let #(m, _) = pair
      is_body_bound_member(model, struct_id, m.member_name)
    })
  let field_steps =
    list.map(body_members, fn(pair) {
      let #(m, wire) = pair
      code.Let(
        name: "body",
        value: code.Raw(fragment: scalar_field_append(
          model,
          struct_id,
          m,
          wire,
          variant,
        )),
      )
    })
  let body_bytes =
    code.Let(
      name: "body_bytes",
      value: code.Raw(fragment: "bit_array.from_string(body)"),
    )
  let headers_assign =
    code.Let(
      name: "headers",
      value: code.Raw(
        fragment: "dict.from_list([#(\"Content-Type\", \"application/x-www-form-urlencoded\"), #(\"Content-Length\", int.to_string(bit_array.byte_size(body_bytes)))])",
      ),
    )
  // `@smithy.api#requestCompression` — actually gzip the body via
  // `compression.maybe_compress` and append `Content-Encoding: gzip`
  // when the wrap was applied. Mirrors the Rust SDK's
  // `RequestCompressionInterceptor.modify_before_retry_loop`
  // (vendor/aws-sdk-rust/sdk/cloudwatch/src/client_request_compression.rs):
  // bodies smaller than `default_min_compression_size_bytes` skip
  // BOTH the gzip wrap AND the header (compressing tiny payloads
  // tends to bloat them; AWS rejects `Content-Encoding` headers
  // that don't match the body bytes).
  let encodings = trait_helpers.request_compression_encodings(op_traits)
  let encoding_steps =
    list.flat_map(encodings, fn(enc) {
      [
        code.Let(
          name: "#(body_bytes, applied)",
          value: code.Raw(
            fragment: name_concat([
              "compression.maybe_compress(body_bytes, \"",
              enc,
              "\", compression.default_min_compression_size_bytes)",
            ]),
          ),
        ),
        code.Let(
          name: "headers",
          value: code.Raw(
            fragment: name_concat([
              "case applied { True -> dict.insert(rest.append_content_encoding(headers, \"",
              enc,
              "\"), \"Content-Length\", int.to_string(bit_array.byte_size(body_bytes))) False -> headers }",
            ]),
          ),
        ),
      ]
    })
  let tuple_expr =
    code.Tuple(items: [
      code.StrLit(value: "POST"),
      code.StrLit(value: "/"),
      code.Ident(name: "headers"),
      code.Ident(name: "body_bytes"),
    ])
  code.Fn(
    public: True,
    name: name_concat(["build_", snake, "_request"]),
    params: [code.Param(name: "input", type_: input_type)],
    return: CodeSome("#(String, String, dict.Dict(String, String), BitArray)"),
    body: code.Block(
      items: list.flatten([
        [body_init],
        field_steps,
        [body_bytes, headers_assign],
        encoding_steps,
        [tuple_expr],
      ]),
    ),
  )
}

fn scalar_field_append(
  model: Model,
  struct_id: String,
  m: MemberDef,
  wire_name: String,
  variant: Variant,
) -> String {
  let body_extension =
    encode_value_expr(
      m.target,
      "v",
      quote_string(wire_name),
      member_traits(model, struct_id, m.member_name),
      variant,
      m.timestamp_format,
    )
  // `@idempotencyToken`: when `None`, substitute the SDK-generated
  // UUID and append the field. Otherwise omit the field entirely.
  // The substitution is the same `rest.idempotency_token/0` FFI
  // the rest-protocol emitters use — tests pin it to all-zeros
  // via `application:set_env`.
  let none_branch = case m.idempotency_token {
    True ->
      name_concat([
        "body <> \"&",
        wire_name,
        "=\" <> uri.encode_component(rest.idempotency_token())",
      ])
    False -> "body"
  }
  case m.required {
    True ->
      name_concat([
        "{\n  let v = input.",
        m.snake_name,
        "\n  body <> ",
        body_extension,
        "\n}",
      ])
    False ->
      name_concat([
        "case input.",
        m.snake_name,
        " { option.None -> ",
        none_branch,
        " option.Some(v) -> body <> ",
        body_extension,
        " }",
      ])
  }
}

/// Emit a Gleam expression that produces the wire-body fragment
/// (`&prefix=value` / `&prefix.member.N=...`) for `value_expr`
/// (of type `target`), placed under `prefix_expr` (a Gleam
/// expression that evaluates to the running prefix string,
/// without leading `&`). `member_traits` carries the struct-
/// member-level traits (`@xmlFlattened`, `@xmlName` overriding
/// the wire prefix). `variant` controls awsQuery / ec2Query
/// wire-name conventions inside nested structs. The model is
/// not consulted here because struct branches dispatch to
/// `encode_<snake>_at` helpers emitted at the file level —
/// recursion into nested struct shape lookup happens there.
fn encode_value_expr(
  target: types.Resolved,
  value_expr: String,
  prefix_expr: String,
  m_traits: shape.Traits,
  variant: Variant,
  timestamp_format: option.Option(String),
) -> String {
  case target {
    types.RPrim(_) | types.RBlob | types.REnum(..) | types.RIntEnum(..) ->
      scalar_kv(target, value_expr, prefix_expr)
    types.RTimestamp -> {
      // awsQuery / ec2Query default timestamp format is `date-time`
      // (ISO 8601). `@timestampFormat` on the member or the target
      // shape (e.g. `aws.protocoltests.shared#EpochSeconds`) flips
      // the wire form.
      let fmt = case timestamp_format {
        option.Some(s) -> s
        option.None -> "date-time"
      }
      let formatter = case fmt {
        "epoch-seconds" -> "json_timestamp.epoch_seconds_text"
        "http-date" -> "json_timestamp.format_http_date_precise"
        _ -> "json_timestamp.format_iso8601_precise"
      }
      name_concat([
        "\"&\" <> ",
        prefix_expr,
        " <> \"=\" <> uri.encode_component(",
        formatter,
        "(",
        value_expr,
        "))",
      ])
    }
    types.RList(element: et, xml_entry_name: xen, ..) -> {
      // ec2Query flattens every list per the protocol's "all lists are
      // flattened" rule (see Ec2Lists in the corpus); awsQuery only
      // flattens when the struct member carries `@xmlFlattened`.
      let flat = case variant {
        Ec2Query -> True
        AwsQuery ->
          case dict.get(m_traits, ShapeId("smithy.api#xmlFlattened")) {
            Ok(_) -> True
            Error(_) -> False
          }
      }
      let entry_prefix = case flat, xen {
        True, _ -> prefix_expr <> " <> \".\" <> int.to_string(idx + 1)"
        False, name ->
          prefix_expr <> " <> \"." <> name <> ".\" <> int.to_string(idx + 1)"
      }
      let elem_encode =
        encode_value_expr(
          et,
          "item",
          entry_prefix,
          dict.new(),
          variant,
          option.None,
        )
      // Empty-list semantics differ between protocols:
      //   awsQuery → serialize the bare parameter name `<prefix>=`
      //     (matches QueryListWriter.finish() in aws_smithy_query).
      //   ec2Query → do NOT serialize at all (Ec2EmptyQueryLists
      //     fixture: "Does not serialize empty query lists.").
      let empty_branch = case variant {
        AwsQuery -> name_concat(["[] -> \"&\" <> ", prefix_expr, " <> \"=\""])
        Ec2Query -> "[] -> \"\""
      }
      name_concat([
        "case ",
        value_expr,
        " { ",
        empty_branch,
        " _ -> list.index_fold(",
        value_expr,
        ", \"\", fn(acc, item, idx) { acc <> ",
        elem_encode,
        " }) }",
      ])
    }
    types.RMap(key: kt, value: vt, xml_key_name: kn, xml_value_name: vn, ..) -> {
      // awsQuery: flat when the struct member has `@xmlFlattened`;
      // ec2Query: maps follow the same flat-by-default rule as lists.
      let flat = case variant {
        Ec2Query -> True
        AwsQuery ->
          case dict.get(m_traits, ShapeId("smithy.api#xmlFlattened")) {
            Ok(_) -> True
            Error(_) -> False
          }
      }
      // Bind the entry's wire prefix to a unique local name before
      // recursing so the inner list/struct/map closures don't pick
      // up our outer `idx` via shadowing. `entry_prefix_<n>` is a
      // plain `String` Gleam expression at runtime.
      let entry_var = "entry_prefix"
      let entry_init = case flat {
        True -> prefix_expr <> " <> \".\" <> int.to_string(idx + 1)"
        False -> prefix_expr <> " <> \".entry.\" <> int.to_string(idx + 1)"
      }
      let key_prefix = entry_var <> " <> \"." <> kn <> "\""
      let value_prefix = entry_var <> " <> \"." <> vn <> "\""
      let key_enc = scalar_kv(kt, "k", key_prefix)
      let value_enc =
        encode_value_expr(
          vt,
          "v",
          value_prefix,
          dict.new(),
          variant,
          option.None,
        )
      // Empty maps not serialized (matches QueryEmptyQueryMaps and
      // Ec2EmptyQueryMaps in the corpus). Keys sorted ascending so
      // wire byte-match against fixture is deterministic (matches
      // the Rust SDK convention — its callers explicitly sort).
      name_concat([
        "case dict.size(",
        value_expr,
        ") { 0 -> \"\" _ -> { let entries = dict.to_list(",
        value_expr,
        ") |> list.sort(fn(a, b) { string.compare(a.0, b.0) }) list.index_fold(entries, \"\", fn(acc, pair, idx) { let #(k, v) = pair let ",
        entry_var,
        " = ",
        entry_init,
        " acc <> ",
        key_enc,
        " <> ",
        value_enc,
        " }) } }",
      ])
    }
    types.RStruct(gleam_name: gn, ..) ->
      name_concat([
        "encode_",
        stringutils.pascal_to_snake(gn),
        "_at(",
        prefix_expr,
        ", ",
        value_expr,
        ")",
      ])
    _ ->
      // Unsupported (union/timestamp/document) — emit a literal
      // empty string so the build still compiles if the classifier
      // missed a case. The classifier should prevent this in
      // practice.
      "\"\""
  }
}

fn scalar_kv(
  target: types.Resolved,
  value_expr: String,
  prefix_expr: String,
) -> String {
  let encoded = case target {
    types.RPrim(types.PString) ->
      name_concat(["uri.encode_component(", value_expr, ")"])
    types.RPrim(types.PInt) -> name_concat(["int.to_string(", value_expr, ")"])
    types.RPrim(types.PFloat) ->
      name_concat(["format_smithy_float(", value_expr, ")"])
    types.RPrim(types.PBool) ->
      name_concat([
        "case ",
        value_expr,
        " { True -> \"true\" False -> \"false\" }",
      ])
    types.RBlob ->
      name_concat([
        "uri.encode_component(bit_array.base64_encode(",
        value_expr,
        ", True))",
      ])
    types.REnum(gleam_name: en, ..) ->
      name_concat([
        "uri.encode_component(",
        stringutils.pascal_to_snake(en),
        "_to_wire(",
        value_expr,
        "))",
      ])
    types.RIntEnum(gleam_name: en, ..) ->
      name_concat([
        "int.to_string(",
        stringutils.pascal_to_snake(en),
        "_to_int(",
        value_expr,
        "))",
      ])
    _ ->
      name_concat([
        "uri.encode_component(string.inspect(",
        value_expr,
        "))",
      ])
  }
  name_concat(["\"&\" <> ", prefix_expr, " <> \"=\" <> ", encoded])
}

fn quote_string(s: String) -> String {
  name_concat(["\"", s, "\""])
}

fn parse_response_fn(snake: String, output_type: String) -> Code {
  code.Fn(
    public: True,
    name: name_concat(["parse_", snake, "_response"]),
    params: [
      code.Param(name: "_code", type_: "Int"),
      code.Param(name: "_headers", type_: "dict.Dict(String, String)"),
      code.Param(name: "_body", type_: "BitArray"),
    ],
    return: CodeSome(name_concat(["Result(", output_type, ", String)"])),
    body: code.Call(head: code.Ident(name: "Ok"), args: [
      code.Ident(name: output_type),
    ]),
  )
}

/// Body-driven import filter, same pattern as the awsjson emitter:
/// generate the module body first, then keep only the imports whose
/// `<module>.` prefix actually appears in it. Plus an inline
/// `format_float` helper + supporting FFI for the AWS-spec float
/// short-form / NaN / Infinity wire shape, included only when the
/// body actually references it.
fn file_header(service_id: String, variant: Variant, body: String) -> String {
  let proto = case variant {
    AwsQuery -> "awsQuery"
    Ec2Query -> "ec2Query"
  }
  let candidates = [
    #("aws/internal/client/runtime", "runtime."),
    #("aws/internal/codec/compression", "compression."),
    #("aws/internal/codec/json_float", "json_float."),
    #("aws/internal/codec/json_timestamp", "json_timestamp."),
    #("aws/internal/codec/rest", "rest."),
    #("aws/internal/uri", "uri."),
    #("gleam/bit_array", "bit_array."),
    #("gleam/dict", "dict."),
    #("gleam/dynamic/decode", "decode."),
    #("gleam/int", "int."),
    #("gleam/json", "json."),
    #("gleam/list", "list."),
    #("gleam/option", "option."),
    #("gleam/result", "result."),
    #("gleam/string", "string."),
  ]
  let used =
    candidates
    |> list.filter(fn(c) { code.references_module(body, c.1) })
    |> list.map(fn(c) {
      code.Import(path: c.0, alias: code.CodeNone, unqualified: [])
    })
  let module =
    code.Module(items: [
      code.ModuleDocComment(lines: [
        name_concat(["Generated from ", service_id, " (", proto, ")."]),
        "DO NOT EDIT. Re-generate via the codegen subproject.",
      ]),
      code.Blank,
      ..used
    ])
  let preamble = code.render(module)
  let helper = case string.contains(body, "format_smithy_float(") {
    False -> ""
    True ->
      "\n// AWS form-urlencoded float formatting:\n"
      <> "//   NaN -> \"NaN\", +Infinity -> \"Infinity\", -Infinity -> \"-Infinity\",\n"
      <> "//   finite -> short-form decimal via aws_ffi:float_short/1.\n"
      <> "// SmithyFloat already discriminates the three IEEE-754 specials,\n"
      <> "// so the helper just dispatches on the sum.\n"
      <> "fn format_smithy_float(v: json_float.SmithyFloat) -> String {\n"
      <> "  case v {\n"
      <> "    json_float.FloatValue(f) -> float_short(f)\n"
      <> "    json_float.NaN -> \"NaN\"\n"
      <> "    json_float.PosInfinity -> \"Infinity\"\n"
      <> "    json_float.NegInfinity -> \"-Infinity\"\n"
      <> "  }\n"
      <> "}\n\n"
      <> "@external(erlang, \"aws_ffi\", \"float_short\")\n"
      <> "fn float_short(v: Float) -> String\n"
  }
  string.concat([preamble, "\n", helper])
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

fn aws_query_error_code(
  model: Model,
  err_id: String,
  default: String,
) -> String {
  case model.lookup(model, err_id) {
    Ok(shape.Structure(traits: t, ..)) ->
      case
        trait_helpers.string_field_under(
          t,
          "aws.protocols#awsQueryError",
          "code",
        )
      {
        Ok(code) -> code
        Error(_) -> default
      }
    _ -> default
  }
}
