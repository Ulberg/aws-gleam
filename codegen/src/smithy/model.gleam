//// Top-level decoder for a Smithy 2.0 JSON model document. A model
//// contains a flat map of `shape_id → shape`; the codegen pipeline picks
//// out service shapes and walks references from there.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/list
import gleam/option
import gleam/set.{type Set}
import gleam/string
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

/// All operations bound to a service or resource, including nested resources
/// and lifecycle bindings. Like Smithy's TopDownIndex, return unique operations
/// sorted by shape ID; do not follow input/output or identifier references.
pub fn operation_refs(
  model: Model,
  container_id: String,
) -> List(shape.Reference) {
  walk_operations(model, [shape_id.ShapeId(container_id)], set.new(), [])
  |> list.sort(fn(a, b) {
    string.compare(shape_id.to_string(a.target), shape_id.to_string(b.target))
  })
}

fn walk_operations(
  model: Model,
  pending: List(ShapeId),
  visited: Set(ShapeId),
  operations: List(shape.Reference),
) -> List(shape.Reference) {
  case pending {
    [] -> operations
    [id, ..rest] -> {
      case set.contains(visited, id) {
        True -> walk_operations(model, rest, visited, operations)
        False -> {
          let visited = set.insert(visited, id)
          case dict.get(model.shapes, id) {
            Ok(shape.Operation(..)) ->
              walk_operations(model, rest, visited, [
                shape.Reference(id),
                ..operations
              ])
            Ok(container) -> {
              let targets =
                list.map(container_refs(container), fn(ref) { ref.target })
              walk_operations(
                model,
                list.append(targets, rest),
                visited,
                operations,
              )
            }
            Error(_) -> walk_operations(model, rest, visited, operations)
          }
        }
      }
    }
  }
}

fn container_refs(container: Shape) -> List(shape.Reference) {
  case container {
    shape.Service(operations: operations, resources: resources, ..) ->
      list.append(operations, resources)
    shape.Resource(
      create: create,
      put: put,
      read: read,
      update: update,
      delete: delete,
      list: list_op,
      operations: operations,
      collection_operations: collection_operations,
      resources: resources,
      ..,
    ) -> {
      let lifecycle =
        list.filter_map([create, put, read, update, delete, list_op], fn(ref) {
          option.to_result(ref, Nil)
        })
      list.flatten([lifecycle, operations, collection_operations, resources])
    }
    _ -> []
  }
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
