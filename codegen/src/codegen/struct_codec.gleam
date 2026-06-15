//// AST emitters for the JSON struct encoder + decoder pair the
//// codegen produces for every named structure shape. Previously the
//// three per-protocol emitters carried three near-identical copies
//// of these functions, all built from `string.concat(["...", snake, "..."])`
//// string templates with inline `\"` escapes — this consolidates
//// them behind `codegen/code` AST nodes so the brittle parts move
//// from "stringly-typed" to "type-checked structure".

import codegen/code.{
  type Code, Block, Call, Case, CodeNone, CodeSome, Fn, Ident, Let, ListLit,
  Param, StrLit, Tuple, Use,
}
import codegen/types.{type MemberDef}
import gleam/list
import gleam/option
import gleam/string

fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

/// `pub fn <fn_name>(input: <type_name>) -> json.Json { ... }`. Each
/// member appends to a `pairs` accumulator depending on whether the
/// caller set the field; `Option.None` either skips the entry or
/// inserts the `@default` value when the member declares one.
pub fn encoder(
  fn_name: String,
  type_name: String,
  members: List(MemberDef),
  top_level: Bool,
  member_keyed: Bool,
) -> Code {
  case members {
    [] ->
      Fn(
        public: True,
        name: fn_name,
        params: [Param(name: "_v", type_: type_name)],
        return: CodeSome("json.Json"),
        body: Call(Ident("json.object"), [ListLit(items: [], tail: CodeNone)]),
      )
    _ ->
      Fn(
        public: True,
        name: fn_name,
        params: [Param(name: "input", type_: type_name)],
        return: CodeSome("json.Json"),
        body: Block(items: encoder_body(members, top_level, member_keyed)),
      )
  }
}

/// `True` ⇒ skip `@default` population (operation-input encoder
/// per the AWS-Smithy protocols spec). Nested struct encoders use
/// `False` so defaults populate as expected.
/// `True` ⇒ wire keys are Smithy member names (`m.member_name`),
/// used by the awsJson1_0 / awsJson1_1 protocols which do NOT
/// honour `@jsonName`. `False` ⇒ wire keys are `m.json_name`
/// (`@jsonName` override, or member name when absent), used by
/// restJson1 and the JSON triple in the restXml emitter.
fn encoder_body(
  members: List(MemberDef),
  top_level: Bool,
  member_keyed: Bool,
) -> List(Code) {
  let init = Let(name: "pairs", value: ListLit(items: [], tail: CodeNone))
  let folds =
    list.map(members, fn(m) {
      let wire_key = case member_keyed {
        True -> m.member_name
        False -> m.json_name
      }
      let wire = StrLit(wire_key)
      let encoded_value = Call(Ident(member_encoder_expr(m)), [Ident("v")])
      let some_branch =
        ListLit(
          items: [
            Tuple(items: [
              wire,
              encoded_value,
            ]),
          ],
          tail: CodeSome(Ident("pairs")),
        )
      let none_branch = case top_level, m.default_json {
        False, option.Some(default_expr) ->
          ListLit(
            items: [
              Tuple(items: [wire, code.Raw(fragment: default_expr)]),
            ],
            tail: CodeSome(Ident("pairs")),
          )
        _, _ -> Ident("pairs")
      }
      let value = case m.required {
        True ->
          Block(items: [
            Let(name: "v", value: Ident(name_concat(["input.", m.snake_name]))),
            ListLit(
              items: [Tuple(items: [wire, encoded_value])],
              tail: CodeSome(Ident("pairs")),
            ),
          ])
        False ->
          Case(
            scrutinee: Ident(name_concat(["input.", m.snake_name])),
            branches: [
              code.Branch(pattern: "option.Some(v)", body: some_branch),
              code.Branch(pattern: "option.None", body: none_branch),
            ],
          )
      }
      Let(name: "pairs", value: value)
    })
  let tail = Call(Ident("json.object"), [Ident("pairs")])
  list.append([init, ..folds], [tail])
}

/// `pub fn <fn_name>() -> decode.Decoder(<type_name>) { ... }`. Wraps
/// in `decode.recursive` so self-referential Smithy shapes don't
/// infinite-loop at decoder construction (eager `decode.one_of`
/// evaluation). The two orthogonal flags are necessary because the
/// awsJson wire decoder is *member-keyed* (awsJson ignores
/// `@jsonName`) yet still refers to nested **wire** decoders, not
/// the dispatcher's `_struct_params` parallel set.
pub fn decoder(
  fn_name: String,
  type_name: String,
  members: List(MemberDef),
  member_keyed: Bool,
  params_nested: Bool,
) -> Code {
  case members {
    [] ->
      Fn(
        public: True,
        name: fn_name,
        params: [],
        return: CodeSome(name_concat(["decode.Decoder(", type_name, ")"])),
        body: Call(Ident("decode.success"), [Ident(type_name)]),
      )
    _ ->
      Fn(
        public: True,
        name: fn_name,
        params: [],
        return: CodeSome(name_concat(["decode.Decoder(", type_name, ")"])),
        body: Block(items: decoder_body(
          type_name,
          members,
          member_keyed,
          params_nested,
        )),
      )
  }
}

/// `True` ⇒ keys come from Smithy member names (`m.member_name`).
/// `False` ⇒ keys come from `m.json_name` (`@jsonName` override
/// or member name when absent).
/// `True` ⇒ nested struct/union refs call the dispatcher's
/// `_struct_params` / `_union_params` decoders. `False` ⇒ nested
/// refs call the wire decoders `_struct` / `_union`.
fn decoder_body(
  type_name: String,
  members: List(MemberDef),
  member_keyed: Bool,
  params_nested: Bool,
) -> List(Code) {
  let recursive_guard = Use(name: "", callee: Ident("decode.recursive"))
  let field_lets =
    list.map(members, fn(m) {
      let key = case member_keyed {
        True -> m.member_name
        False -> m.json_name
      }
      let inner = case params_nested {
        True -> member_decoder_params_expr(m)
        False -> member_decoder_expr(m)
      }
      case m.required {
        True ->
          Use(
            name: m.snake_name,
            callee: Call(Ident("decode.field"), [
              StrLit(key),
              code.Raw(fragment: inner),
            ]),
          )
        False ->
          Use(
            name: m.snake_name,
            callee: Call(Ident("decode.optional_field"), [
              StrLit(key),
              Ident("option.None"),
              Call(Ident("decode.optional"), [code.Raw(fragment: inner)]),
            ]),
          )
      }
    })
  let constructor =
    Call(
      Ident(type_name),
      list.map(members, fn(m) {
        code.Labelled(label: m.snake_name, value: Ident(m.snake_name))
      }),
    )
  let tail = Call(Ident("decode.success"), [constructor])
  list.append([recursive_guard, ..field_lets], [tail])
}

fn member_encoder_expr(m: MemberDef) -> String {
  types.json_encoder_member(m.target, m.timestamp_format)
}

fn member_decoder_expr(m: MemberDef) -> String {
  types.json_decoder_member(m.target, m.timestamp_format)
}

fn member_decoder_params_expr(m: MemberDef) -> String {
  types.json_decoder_member_params(m.target, m.timestamp_format)
}
