//// Type-walking helpers shared across protocol emitters.
////
//// Given a Smithy shape, produce:
////   - the Gleam type expression (`"Int"`, `"Float"`, …)
////   - a JSON encoder snippet (`"json.float"`, `"json.int"`, …)
////   - a JSON decoder snippet (`"decode.float"`, …)
////
//// First-pass scope: primitive shapes only (string, int family, float
//// family, bool). Anything else returns `Unsupported`, signalling to
//// the caller that the operation can't yet be emitted with full typed
//// I/O. As we cover more shape kinds (list, map, enum, structure,
//// union, timestamp, blob, document), this module grows correspondingly.

import gleam/dict
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{ShapeId}

pub type Primitive {
  PString
  PInt
  PFloat
  PBool
}

pub type Resolved {
  Resolved(primitive: Primitive)
  Unsupported(reason: String)
}

/// Resolve a member's target shape ID to a primitive (or report
/// unsupported). For now we only walk one level deep: the target must
/// be a Smithy simple type. Aggregates, structures, unions, enums,
/// timestamps, blobs and documents all return `Unsupported` until the
/// corresponding emitter machinery lands.
pub fn resolve(model: Model, target_id: String) -> Resolved {
  case target_id {
    "smithy.api#String" -> Resolved(primitive: PString)
    "smithy.api#Integer"
    | "smithy.api#Long"
    | "smithy.api#Short"
    | "smithy.api#Byte" -> Resolved(primitive: PInt)
    "smithy.api#Float" | "smithy.api#Double" -> Resolved(primitive: PFloat)
    "smithy.api#Boolean" -> Resolved(primitive: PBool)
    _ -> resolve_user_defined(model, target_id)
  }
}

/// User-defined shape targets — if the shape is a thin alias around
/// another simple type, recurse. Otherwise mark unsupported.
fn resolve_user_defined(model: Model, target_id: String) -> Resolved {
  case model.lookup(model, target_id) {
    Ok(shape.String(..)) -> Resolved(primitive: PString)
    Ok(shape.Integer(..))
    | Ok(shape.Long(..))
    | Ok(shape.Short(..))
    | Ok(shape.Byte(..)) -> Resolved(primitive: PInt)
    Ok(shape.Float(..)) | Ok(shape.Double(..)) -> Resolved(primitive: PFloat)
    Ok(shape.Bool(..)) -> Resolved(primitive: PBool)
    _ -> Unsupported(reason: "non-primitive target: " <> target_id)
  }
}

/// Whether every member of a structure resolves to a supported
/// primitive (the precondition for emitting it with typed I/O).
pub fn all_members_primitive(
  model: Model,
  members: dict.Dict(String, shape.Member),
) -> Bool {
  dict.fold(members, True, fn(acc, _name, member) {
    case acc {
      False -> False
      True -> {
        let ShapeId(target) = member.target
        case resolve(model, target) {
          Resolved(..) -> True
          Unsupported(..) -> False
        }
      }
    }
  })
}

pub fn gleam_type(p: Primitive) -> String {
  case p {
    PString -> "String"
    PInt -> "Int"
    // Float fields use the SmithyFloat sum type from the runtime
    // helper. Plain Erlang `float()` cannot hold IEEE 754 NaN /
    // Infinity, so a tagged representation is required for faithful
    // round-tripping under awsJson's special-float convention.
    PFloat -> "json_float.SmithyFloat"
    PBool -> "Bool"
  }
}

pub fn json_encoder(p: Primitive) -> String {
  case p {
    PString -> "json.string"
    PInt -> "json.int"
    PFloat -> "json_float.encode"
    PBool -> "json.bool"
  }
}

pub fn json_decoder(p: Primitive) -> String {
  case p {
    PString -> "decode.string"
    PInt -> "decode.int"
    PFloat -> "json_float.decoder()"
    PBool -> "decode.bool"
  }
}
