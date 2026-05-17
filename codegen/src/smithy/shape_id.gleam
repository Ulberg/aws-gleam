//// Smithy `ShapeId` — a namespaced identifier of the form
//// `namespace#name[$member]`. Used throughout the AST as the key for
//// looking up shapes and as the value of `target` references.

import gleam/dynamic/decode.{type Decoder}

pub type ShapeId {
  ShapeId(String)
}

pub fn to_string(shape_id: ShapeId) -> String {
  let ShapeId(id) = shape_id
  id
}

pub fn decoder() -> Decoder(ShapeId) {
  decode.map(decode.string, ShapeId)
}
