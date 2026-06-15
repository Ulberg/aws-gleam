//// Shared AST emitters for the `pub type Name { ... }` definitions
//// the codegen produces — records (struct shapes), enums, intEnums,
//// and unions.
////
//// The previous codebase had three near-identical copies (one per
//// per-protocol emitter); they're consolidated here behind the
//// `codegen/code` AST. Each function returns a `Code` node, ready
//// to splice into the emitter's `Module(items)` list.

import codegen/code.{
  type Code, type Param, CodeSome, Fn, Ident, Labelled, LabelledParam, Param,
  PositionalVariant, RecordConstruct, TypeDef, UnitVariant, Variant,
}
import codegen/types.{
  type EnumVariant, type IntEnumVariant, type MemberDef, type Resolved, REnum,
  RIntEnum, RStruct, RUnion,
}
import gleam/list
import gleam/set.{type Set}
import internal/stringutils

/// Set of `gleam_name`s for every top-level shape that an emitter
/// will materialise as a `pub type` in the generated module —
/// structs, unions, enums, int-enums. Used by collision-detection
/// helpers (`trait_helpers.op_error_type`,
/// `stringutils.union_variant_ctor`) to know which Gleam identifiers
/// are already taken before they synthesise a new one. The set is
/// per-service: each emitter call passes its own resolved-shape
/// list in.
pub fn emitted_type_names(shapes: List(Resolved)) -> Set(String) {
  list.fold(shapes, set.new(), fn(acc, r) {
    case r {
      REnum(gleam_name: n, ..)
      | RIntEnum(gleam_name: n, ..)
      | RStruct(gleam_name: n, ..)
      | RUnion(gleam_name: n, ..) -> set.insert(acc, n)
      _ -> acc
    }
  })
}

/// `pub type Name { Name(field: T, optional: option.Option(U), ...) }`.
/// Body-less variant for member-less structs falls back to
/// `pub type Name { Name }`.
pub fn record_def(name: String, members: List(MemberDef)) -> Code {
  case members {
    [] ->
      TypeDef(public: True, is_opaque: False, name: name, variants: [
        UnitVariant(name: name),
      ])
    _ ->
      TypeDef(public: True, is_opaque: False, name: name, variants: [
        Variant(
          name: name,
          fields: list.map(members, fn(m) {
            Param(name: m.snake_name, type_: types.member_field_type(m))
          }),
        ),
      ])
  }
}

/// `pub type Name { Foo Bar ... }` for string enums. The Smithy
/// emitter always materialises a variant per enum value; empty enums
/// collapse to a sentinel `NameUnknown` so generated code that
/// pattern-matches on the type still compiles.
pub fn enum_def(name: String, variants: List(EnumVariant)) -> Code {
  case variants {
    [] ->
      TypeDef(public: True, is_opaque: False, name: name, variants: [
        UnitVariant(name: name <> "Unknown"),
      ])
    _ ->
      TypeDef(
        public: True,
        is_opaque: False,
        name: name,
        variants: list.map(variants, fn(v) { UnitVariant(name: v.gleam_ctor) }),
      )
  }
}

/// Same shape as `enum_def` but for `intEnum` shapes — the only
/// difference is the source variant list type.
pub fn int_enum_def(name: String, variants: List(IntEnumVariant)) -> Code {
  case variants {
    [] ->
      TypeDef(public: True, is_opaque: False, name: name, variants: [
        UnitVariant(name: name <> "Unknown"),
      ])
    _ ->
      TypeDef(
        public: True,
        is_opaque: False,
        name: name,
        variants: list.map(variants, fn(v) { UnitVariant(name: v.gleam_ctor) }),
      )
  }
}

/// `pub type Name { NameFoo(T) NameBar(U) ... }`. Empty unions get a
/// `NameEmpty` sentinel for the same reason as enums. Variant fields
/// stay positional (`Ctor(T)` not `Ctor(value: T)`) so callers can
/// pattern-match as `Ctor(x)` — the form smithy-rs and aws-sdk-go-v2
/// match.
pub fn union_def(
  name: String,
  members: List(MemberDef),
  emitted: Set(String),
) -> Code {
  case members {
    [] ->
      TypeDef(public: True, is_opaque: False, name: name, variants: [
        UnitVariant(name: name <> "Empty"),
      ])
    _ ->
      TypeDef(
        public: True,
        is_opaque: False,
        name: name,
        variants: list.map(members, fn(m) {
          PositionalVariant(
            name: stringutils.union_variant_ctor(name, m.member_name, emitted),
            types: [types.gleam_type(m.target)],
          )
        }),
      )
  }
}

/// `pub fn <snake>_default(required required: T) -> Name { ... }`.
/// Companion to `record_def` — emit alongside every Request /
/// Result struct so callers can write
///
///     SomeRequest(..s3.some_request_default(bucket: "b"), prefix: Some("p"))
///
/// instead of spelling out `None` for every optional field. Gleam
/// records require all fields at construction; the generated helper
/// takes required members as labelled arguments and defaults the rest.
///
/// `snake` is the Gleam-snake of the type name; `record_name` is
/// the PascalCase constructor.
pub fn record_default_fn(
  snake: String,
  record_name: String,
  members: List(MemberDef),
) -> Code {
  Fn(
    public: True,
    name: snake <> "_default",
    params: required_params(members),
    return: CodeSome(record_name),
    body: default_body(record_name, members),
  )
}

fn required_params(members: List(MemberDef)) -> List(Param) {
  members
  |> list.filter(fn(m) { m.required })
  |> list.map(fn(m) {
    LabelledParam(
      label: m.snake_name,
      name: m.snake_name,
      type_: types.gleam_type(m.target),
    )
  })
}

fn default_body(record_name: String, members: List(MemberDef)) -> Code {
  case members {
    [] -> Ident(name: record_name)
    _ ->
      RecordConstruct(
        type_: record_name,
        fields: list.map(members, fn(m) {
          let value = case m.required {
            True -> Ident(name: m.snake_name)
            False -> Ident(name: "option.None")
          }
          Labelled(label: m.snake_name, value: value)
        }),
      )
  }
}
