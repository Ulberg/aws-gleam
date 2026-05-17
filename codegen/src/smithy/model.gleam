//// Top-level decoder for a Smithy 2.0 JSON model document. A model
//// contains a flat map of `shape_id → shape`; the codegen pipeline picks
//// out service shapes and walks references from there.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import smithy/shape.{type Shape}
import smithy/shape_id.{type ShapeId}

pub type Model {
  Model(smithy_version: String, shapes: Dict(ShapeId, Shape))
}

pub fn decoder() -> Decoder(Model) {
  use smithy <- decode.field("smithy", decode.string)
  use shapes <- decode.field(
    "shapes",
    decode.dict(shape_id.decoder(), shape.decoder()),
  )
  decode.success(Model(smithy_version: smithy, shapes: shapes))
}

pub fn lookup(model: Model, id: String) -> Result(Shape, Nil) {
  dict.get(model.shapes, shape_id.ShapeId(id))
}
