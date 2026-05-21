//// Top-level decoder for a Smithy 2.0 JSON model document. A model
//// contains a flat map of `shape_id → shape`; the codegen pipeline picks
//// out service shapes and walks references from there.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import smithy/shape.{type Shape}
import smithy/shape_id.{type ShapeId}

pub type Model {
  Model(
    smithy_version: String,
    shapes: Dict(ShapeId, Shape),
    /// `shape_id → declared member-name order`. Populated for every
    /// aggregate shape (struct / union / enum / intEnum) via the
    /// `member_order.extract` FFI pre-pass that parses the same raw
    /// JSON with order-preserving callbacks. Empty list when the
    /// shape has no `members` block.
    member_orders: Dict(String, List(String)),
  )
}

pub fn decoder() -> Decoder(Model) {
  use smithy <- decode.field("smithy", decode.string)
  use shapes <- decode.field(
    "shapes",
    decode.dict(shape_id.decoder(), shape.decoder()),
  )
  decode.success(Model(
    smithy_version: smithy,
    shapes: shapes,
    member_orders: dict.new(),
  ))
}

pub fn lookup(model: Model, id: String) -> Result(Shape, Nil) {
  dict.get(model.shapes, shape_id.ShapeId(id))
}

/// Replace the model's `member_orders` map. Used by the codegen
/// driver to attach the pre-pass result after the standard JSON
/// decode (which has no access to the raw JSON bytes the FFI needs).
pub fn with_member_orders(
  model: Model,
  orders: Dict(String, List(String)),
) -> Model {
  Model(..model, member_orders: orders)
}

/// Look up the declared member-name order for a shape. Falls back to
/// an empty list when the shape isn't in the orderings map (simple
/// shapes, ops, services).
pub fn ordered_member_names(model: Model, id: String) -> List(String) {
  case dict.get(model.member_orders, id) {
    Ok(names) -> names
    Error(_) -> []
  }
}
