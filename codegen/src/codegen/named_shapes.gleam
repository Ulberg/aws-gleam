//// Shared AST emitters for the `pub type Name { ... }` definitions
//// the codegen produces — records (struct shapes), enums, intEnums,
//// and unions.
////
//// The previous codebase had three near-identical copies (one per
//// per-protocol emitter); they're consolidated here behind the
//// `codegen/code` AST. Each function returns a `Code` node, ready
//// to splice into the emitter's `Module(items)` list.

import codegen/code.{
  type Code, Param, PositionalVariant, TypeDef, UnitVariant, Variant,
}
import codegen/types.{
  type EnumVariant, type IntEnumVariant, type MemberDef, type Resolved, REnum,
  RIntEnum, RStruct, RUnion,
}
import gleam/list
import gleam/set.{type Set}
import gleam/string
import internal/stringutils

fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

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

/// `pub type Name { Name(field: option.Option(T), ...) }`. Body-less
/// variant for member-less structs falls back to `pub type Name { Name }`.
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
            Param(
              name: m.snake_name,
              type_: name_concat([
                "option.Option(",
                types.gleam_type(m.target),
                ")",
              ]),
            )
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
        UnitVariant(name: name_concat([name, "Unknown"])),
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
        UnitVariant(name: name_concat([name, "Unknown"])),
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
        UnitVariant(name: name_concat([name, "Empty"])),
      ])
    _ ->
      TypeDef(
        public: True,
        is_opaque: False,
        name: name,
        variants: list.map(members, fn(m) {
          PositionalVariant(
            name: stringutils.union_variant_ctor(
              name,
              m.member_name,
              emitted,
            ),
            types: [types.gleam_type(m.target)],
          )
        }),
      )
  }
}
