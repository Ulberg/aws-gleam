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
import codegen/types.{type EnumVariant, type IntEnumVariant, type MemberDef}
import gleam/list
import gleam/string
import internal/stringutils

fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
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
pub fn union_def(name: String, members: List(MemberDef)) -> Code {
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
            name: name_concat([
              name,
              stringutils.pascalize_member(m.member_name),
            ]),
            types: [types.gleam_type(m.target)],
          )
        }),
      )
  }
}
