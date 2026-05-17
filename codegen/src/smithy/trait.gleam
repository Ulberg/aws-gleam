//// Decoded representation of a Smithy trait value. Traits attach
//// metadata to shapes (e.g. `@httpRequestTests`, `aws.api#service`,
//// `aws.protocols#awsJson1_0`). A trait value can be any JSON type, so
//// this is a small sum that preserves shape.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import smithy/shape_id.{type ShapeId}

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
