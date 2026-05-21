//// Decoded representation of a Smithy trait value. Traits attach
//// metadata to shapes (e.g. `@httpRequestTests`, `aws.api#service`,
//// `aws.protocols#awsJson1_0`). A trait value can be any JSON type, so
//// this is a small sum that preserves shape.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import smithy/shape_id.{type ShapeId, ShapeId}

pub type Trait {
  Null
  String(String)
  Int(Int)
  Float(Float)
  Bool(Bool)
  List(List(Trait))
  Dict(Dict(ShapeId, Trait))
}

pub fn decoder() -> Decoder(Trait) {
  let int = decode.map(decode.int, Int)
  let float = decode.map(decode.float, Float)
  let string = decode.map(decode.string, String)
  let bool = decode.map(decode.bool, Bool)
  let list = decode.map(decode.list(lazy()), List)
  let dict = decode.map(decode.dict(shape_id.decoder(), lazy()), Dict)
  let null = decode.map(decode.optional(decode.string), fn(_) { Null })
  // Order matters in one_of — Dict last so `{}` doesn't shadow stricter
  // decoders. Null uses optional-string to catch the explicit JSON null
  // when no other decoder succeeds.
  decode.one_of(string, [int, float, bool, list, dict, null])
}

/// Defer evaluation so the recursive decoder graph terminates. Same
/// trick as the original `decode` package's `lazy` helper.
fn lazy() -> Decoder(Trait) {
  decode.then(decode.dynamic, fn(_) { decoder() })
}

/// Serialize a `Trait` value back to a JSON string. Used by the codegen to
/// re-emit object-valued traits (e.g. `smithy.rules#endpointRuleSet`) as
/// embedded constants in generated modules — when we need the full JSON
/// payload rather than walking the typed AST.
///
/// `Trait.Dict` keys are Smithy `ShapeId`s; for trait-as-object cases
/// they're already simple `name` strings, which `shape_id.to_string`
/// renders verbatim.
pub fn to_json_string(t: Trait) -> String {
  case t {
    Null -> "null"
    Bool(True) -> "true"
    Bool(False) -> "false"
    Int(n) -> int.to_string(n)
    Float(f) -> float.to_string(f)
    String(s) -> json_string(s)
    List(items) ->
      string.concat([
        "[",
        items
          |> list.map(to_json_string)
          |> string.join(","),
        "]",
      ])
    Dict(d) ->
      string.concat([
        "{",
        dict.to_list(d)
          |> list.map(fn(pair) {
            let ShapeId(k) = pair.0
            string.concat([json_string(k), ":", to_json_string(pair.1)])
          })
          |> string.join(","),
        "}",
      ])
  }
}

fn json_string(s: String) -> String {
  string.concat(["\"", escape_string(s), "\""])
}

fn escape_string(s: String) -> String {
  s
  |> string.to_graphemes
  |> list.map(escape_grapheme)
  |> string.concat
}

fn escape_grapheme(g: String) -> String {
  case g {
    "\\" -> "\\\\"
    "\"" -> "\\\""
    "\n" -> "\\n"
    "\r" -> "\\r"
    "\t" -> "\\t"
    "\u{0008}" -> "\\b"
    "\u{000C}" -> "\\f"
    other -> other
  }
}
