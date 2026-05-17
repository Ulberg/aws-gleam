//// Smithy 2.0 AST shape decoder. Mirrors the discriminator `type` field
//// of each shape node and produces a typed AST suitable for downstream
//// codegen. Covers every shape kind documented at
//// <https://smithy.io/2.0/spec/simple-types.html>.

import gleam/dict.{type Dict}
import gleam/dynamic/decode.{type Decoder}
import gleam/option.{type Option}
import smithy/shape_id.{type ShapeId}
import smithy/trait.{type Trait}

pub type Reference {
  Reference(target: ShapeId)
}

pub type Member {
  Member(target: ShapeId, traits: Traits)
}

pub type Traits =
  Dict(ShapeId, Option(Trait))

pub type Shape {
  // Simple shapes
  Blob(traits: Traits)
  Bool(traits: Traits)
  String(traits: Traits)
  Byte(traits: Traits)
  Short(traits: Traits)
  Integer(traits: Traits)
  Long(traits: Traits)
  Float(traits: Traits)
  Double(traits: Traits)
  BigInteger(traits: Traits)
  BigDecimal(traits: Traits)
  Timestamp(traits: Traits)
  Document(traits: Traits)

  // Aggregate shapes
  List(traits: Traits, member: Member)
  Map(traits: Traits, key: Member, value: Member)
  Structure(traits: Traits, members: Dict(String, Member))
  Union(traits: Traits, members: Dict(String, Member))
  IntEnum(traits: Traits, members: Dict(String, Member))
  Enum(traits: Traits, members: Dict(String, Member))

  // Service shapes
  Service(
    version: Option(String),
    operations: List(Reference),
    resources: List(Reference),
    errors: List(Reference),
    traits: Traits,
  )
  Resource(
    identifiers: Dict(String, Reference),
    properties: Dict(String, Reference),
    create: Option(Reference),
    put: Option(Reference),
    read: Option(Reference),
    update: Option(Reference),
    delete: Option(Reference),
    list: Option(Reference),
    operations: List(Reference),
    collection_operations: List(Reference),
    resources: List(Reference),
    traits: Traits,
  )
  Operation(
    input: Reference,
    output: Reference,
    errors: List(Reference),
    traits: Traits,
  )
}

fn reference_decoder() -> Decoder(Reference) {
  use target <- decode.field("target", shape_id.decoder())
  decode.success(Reference(target: target))
}

fn member_decoder() -> Decoder(Member) {
  use target <- decode.field("target", shape_id.decoder())
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  decode.success(Member(target: target, traits: traits))
}

fn members_map() -> Decoder(Dict(String, Member)) {
  decode.dict(decode.string, member_decoder())
}

fn traits_decoder() -> Decoder(Traits) {
  decode.dict(shape_id.decoder(), decode.optional(trait.decoder()))
}

pub fn decoder() -> Decoder(Shape) {
  use tpe <- decode.field("type", decode.string)
  case tpe {
    "blob" -> simple(Blob)
    "boolean" -> simple(Bool)
    "string" -> simple(String)
    "byte" -> simple(Byte)
    "short" -> simple(Short)
    "integer" -> simple(Integer)
    "long" -> simple(Long)
    "float" -> simple(Float)
    "double" -> simple(Double)
    "bigInteger" -> simple(BigInteger)
    "bigDecimal" -> simple(BigDecimal)
    "timestamp" -> simple(Timestamp)
    "document" -> simple(Document)

    "list" -> list_decoder()
    "map" -> map_decoder()
    "structure" -> aggregate_decoder(Structure)
    "union" -> aggregate_decoder(Union)
    "enum" -> aggregate_decoder(Enum)
    "intEnum" -> aggregate_decoder(IntEnum)

    "service" -> service_decoder()
    "resource" -> resource_decoder()
    "operation" -> operation_decoder()

    other ->
      decode.failure(
        Blob(traits: dict.new()),
        "unknown smithy shape type: " <> other,
      )
  }
}

fn simple(constructor: fn(Traits) -> Shape) -> Decoder(Shape) {
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  decode.success(constructor(traits))
}

fn list_decoder() -> Decoder(Shape) {
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  use member <- decode.field("member", member_decoder())
  decode.success(List(traits: traits, member: member))
}

fn map_decoder() -> Decoder(Shape) {
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  use key <- decode.field("key", member_decoder())
  use value <- decode.field("value", member_decoder())
  decode.success(Map(traits: traits, key: key, value: value))
}

fn aggregate_decoder(
  constructor: fn(Traits, Dict(String, Member)) -> Shape,
) -> Decoder(Shape) {
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  use members <- decode.optional_field("members", dict.new(), members_map())
  decode.success(constructor(traits, members))
}

fn service_decoder() -> Decoder(Shape) {
  use version <- decode.optional_field(
    "version",
    option.None,
    decode.optional(decode.string),
  )
  use operations <- decode.optional_field(
    "operations",
    [],
    decode.list(reference_decoder()),
  )
  use resources <- decode.optional_field(
    "resources",
    [],
    decode.list(reference_decoder()),
  )
  use errors <- decode.optional_field(
    "errors",
    [],
    decode.list(reference_decoder()),
  )
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  decode.success(Service(
    version: version,
    operations: operations,
    resources: resources,
    errors: errors,
    traits: traits,
  ))
}

fn resource_decoder() -> Decoder(Shape) {
  use identifiers <- decode.optional_field(
    "identifiers",
    dict.new(),
    decode.dict(decode.string, reference_decoder()),
  )
  use properties <- decode.optional_field(
    "properties",
    dict.new(),
    decode.dict(decode.string, reference_decoder()),
  )
  use create <- decode.optional_field(
    "create",
    option.None,
    decode.optional(reference_decoder()),
  )
  use put <- decode.optional_field(
    "put",
    option.None,
    decode.optional(reference_decoder()),
  )
  use read <- decode.optional_field(
    "read",
    option.None,
    decode.optional(reference_decoder()),
  )
  use update <- decode.optional_field(
    "update",
    option.None,
    decode.optional(reference_decoder()),
  )
  use delete <- decode.optional_field(
    "delete",
    option.None,
    decode.optional(reference_decoder()),
  )
  use list_ref <- decode.optional_field(
    "list",
    option.None,
    decode.optional(reference_decoder()),
  )
  use operations <- decode.optional_field(
    "operations",
    [],
    decode.list(reference_decoder()),
  )
  use coll_ops <- decode.optional_field(
    "collectionOperations",
    [],
    decode.list(reference_decoder()),
  )
  use resources <- decode.optional_field(
    "resources",
    [],
    decode.list(reference_decoder()),
  )
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  decode.success(Resource(
    identifiers: identifiers,
    properties: properties,
    create: create,
    put: put,
    read: read,
    update: update,
    delete: delete,
    list: list_ref,
    operations: operations,
    collection_operations: coll_ops,
    resources: resources,
    traits: traits,
  ))
}

fn operation_decoder() -> Decoder(Shape) {
  use input <- decode.field("input", reference_decoder())
  use output <- decode.field("output", reference_decoder())
  use errors <- decode.optional_field(
    "errors",
    [],
    decode.list(reference_decoder()),
  )
  use traits <- decode.optional_field("traits", dict.new(), traits_decoder())
  decode.success(Operation(
    input: input,
    output: output,
    errors: errors,
    traits: traits,
  ))
}
