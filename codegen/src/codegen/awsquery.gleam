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
      let body_inner =
        string.concat([
          string.concat(enum_blocks),
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
  let blockers = ["aws.protocols#requestCompression", "smithy.api#endpoint"]
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
              case
                all_supported(members)
                && all_body_bound(members)
                && no_member_traits(model, id)
              {
                True -> ScalarTypedInput(input_id: id)
                False -> UnsupportedInput
              }
            }
          }
        _ -> UnsupportedInput
      }
  }
}

fn all_supported(members: List(MemberDef)) -> Bool {
  list.all(members, fn(m) { is_supported_member(m.target) })
}

fn is_supported_member(r: types.Resolved) -> Bool {
  case r {
    types.RPrim(_) -> True
    types.RBlob -> True
    types.REnum(..) -> True
    types.RIntEnum(..) -> True
    _ -> False
  }
}

fn all_body_bound(members: List(MemberDef)) -> Bool {
  list.all(members, fn(m) {
    case m.binding {
      types.Body -> True
      _ -> False
    }
  })
}

fn no_member_traits(model: Model, struct_id: String) -> Bool {
  case model.lookup(model, struct_id) {
    Ok(shape.Structure(members: m, ..)) ->
      dict.values(m)
      |> list.all(fn(member) {
        let blockers = [
          "smithy.api#idempotencyToken",
          "smithy.api#hostLabel",
          "smithy.api#httpHeader",
          "smithy.api#httpQuery",
          "smithy.api#httpLabel",
          "smithy.api#httpPayload",
        ]
        list.all(blockers, fn(t) { !dict.has_key(member.traits, ShapeId(t)) })
      })
    _ -> True
  }
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
  )
}

/// Emit a typed-scalar-input operation: Input record with Option(T)
/// fields, `decode_<snake>_input` for the test-fixture JSON, and
/// `build_<snake>_request` that form-urlencodes Some-valued fields
/// onto the standard `Action=Op&Version=v` body prefix.
fn emit_scalar_typed_operation(
  model: Model,
  op_id: String,
  version: String,
  input_id: String,
  variant: Variant,
) -> EmittedOp {
  let local = strip_namespace(op_id)
  let snake = stringutils.pascal_to_snake(local)
  let input_type = name_concat([local, "Input"])
  let output_type = name_concat([local, "Output"])
  let members = types.resolve_members(model, input_id)
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
        snake,
        input_type,
        local,
        version,
        list.zip(members, wire_names),
      ),
      code.Blank,
      parse_response_fn(snake, output_type),
      code.Blank,
    ])
  EmittedOp(
    operation_id: op_id,
    code: code.render(module),
    has_typed_input: True,
    referenced_enums: referenced_enums,
  )
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
  snake: String,
  input_type: String,
  op_name: String,
  version: String,
  members: List(#(MemberDef, String)),
) -> Code {
  let prefix = name_concat(["Action=", op_name, "&Version=", version])
  let body_init = code.Let(name: "body", value: code.StrLit(value: prefix))
  let field_steps =
    list.map(members, fn(pair) {
      let #(m, wire) = pair
      code.Let(
        name: "body",
        value: code.Raw(fragment: scalar_field_append(m, wire)),
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
        [body_bytes, headers_assign, tuple_expr],
      ]),
    ),
  )
}

fn scalar_field_append(m: MemberDef, wire_name: String) -> String {
  let encode = case m.target {
    types.RPrim(types.PString) -> "uri.encode_component(v)"
    types.RPrim(types.PInt) -> "int.to_string(v)"
    types.RPrim(types.PFloat) -> "format_smithy_float(v)"
    types.RPrim(types.PBool) ->
      "case v { True -> \"true\" False -> \"false\" }"
    types.RBlob ->
      "uri.encode_component(bit_array.base64_encode(v, True))"
    types.REnum(gleam_name: en, ..) ->
      name_concat([
        "uri.encode_component(",
        stringutils.pascal_to_snake(en),
        "_to_wire(v))",
      ])
    types.RIntEnum(gleam_name: en, ..) ->
      name_concat(["int.to_string(", stringutils.pascal_to_snake(en), "_to_int(v))"])
    _ -> "uri.encode_component(string.inspect(v))"
  }
  name_concat([
    "case input.",
    m.snake_name,
    " { option.None -> body option.Some(v) -> body <> \"&",
    wire_name,
    "=\" <> ",
    encode,
    " }",
  ])
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
fn file_header(
  service_id: String,
  variant: Variant,
  body: String,
) -> String {
  let proto = case variant {
    AwsQuery -> "awsQuery"
    Ec2Query -> "ec2Query"
  }
  let candidates = [
    #("aws/internal/client/runtime", "runtime."),
    #("aws/internal/codec/json_float", "json_float."),
    #("aws/internal/uri", "uri."),
    #("gleam/bit_array", "bit_array."),
    #("gleam/dict", "dict."),
    #("gleam/dynamic/decode", "decode."),
    #("gleam/int", "int."),
    #("gleam/json", "json."),
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
