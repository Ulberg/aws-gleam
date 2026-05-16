//// Smithy shape → codegen type information.
////
//// `resolve` walks a Smithy target shape ID and returns enough info to
//// emit:
////   * the Gleam type name for a field of that target
////   * the JSON encoder expression (a Gleam expression that takes a
////     value of that type and produces `gleam/json.Json`)
////   * the JSON decoder expression (a `gleam/dynamic/decode.Decoder(t)`)
////
//// **Cycle-safety.** Smithy models routinely contain recursive shapes —
//// the canonical example is DynamoDB's `AttributeValue` (a union whose
//// `M` member targets `Map<String, AttributeValue>`, closing the cycle
//// on itself). To stop the resolver from looping forever we keep
//// `RStruct` and `RUnion` "thin": they carry the shape's local name +
//// fully qualified ID, but NOT its members. Member lists are resolved
//// on demand via `resolve_struct_members` / `resolve_union_members`.
//// Callers thread their own seen-set through to avoid traversing the
//// same shape twice; the BEAM-targeted generated code itself is happy
//// with recursive types (`Box<T>`-style indirection is not needed —
//// every Gleam record is heap-allocated already), so this only
//// matters for the walking phase of code generation.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/string
import internal/stringutils
import smithy/model.{type Model}
import smithy/shape
import smithy/shape_id.{type ShapeId, ShapeId}
import smithy/trait

/// What `resolve` returns. Generators consume these to build encoder /
/// decoder snippets and Gleam type expressions.
pub type Resolved {
  /// Plain primitive: string/int/float/bool. Snippets reference the
  /// stdlib's `gleam/json` + `gleam/dynamic/decode` directly.
  RPrim(primitive: Primitive)
  /// Smithy enum — fully resolved (enum members can't recurse).
  REnum(local_name: String, gleam_name: String, variants: List(EnumVariant))
  /// Smithy intEnum — same, with integer wire values.
  RIntEnum(
    local_name: String,
    gleam_name: String,
    variants: List(IntEnumVariant),
  )
  /// Smithy list/set of T. `xml_entry_name` is the per-entry element
  /// name used by restXml / awsQuery / ec2Query — defaults to "member"
  /// and is overridden by `@xmlName` on the list shape's member. For
  /// JSON-shaped protocols this field is irrelevant.
  RList(element: Resolved, xml_entry_name: String)
  /// Smithy map of K → V.
  RMap(key: Resolved, value: Resolved)
  /// Reference to a Smithy structure. The full ID lets the emitter look
  /// the members up on demand without inlining (which would loop on
  /// recursive shapes).
  RStruct(local_name: String, gleam_name: String, full_id: String)
  /// Reference to a Smithy union, same as RStruct.
  RUnion(local_name: String, gleam_name: String, full_id: String)
  /// Smithy `@timestamp`. Default representation: Int (epoch seconds).
  RTimestamp
  /// Smithy `@blob` → Gleam `BitArray`.
  RBlob
  /// Smithy `@document` → free-form JSON.
  RDocument
  /// `smithy.api#Unit` used as a target. In unions this becomes a
  /// no-payload tag (e.g. `PlayerActionQuit`); in struct members it is
  /// effectively `Nil`.
  RUnit
  /// Something we don't yet handle (bigInteger / bigDecimal / etc.).
  Unsupported(reason: String)
}

pub type Primitive {
  PString
  PInt
  PFloat
  PBool
}

pub type EnumVariant {
  EnumVariant(gleam_ctor: String, wire_value: String)
}

pub type IntEnumVariant {
  IntEnumVariant(gleam_ctor: String, wire_value: Int)
}

pub type MemberDef {
  MemberDef(
    json_name: String,
    snake_name: String,
    target: Resolved,
    required: Bool,
    /// HTTP binding the member carries. Used by rest-protocol emitters
    /// to route the field to the URI / query / headers instead of the
    /// body. Defaults to `Body` for members without an http-binding
    /// trait — they're serialised into the JSON / XML body alongside
    /// other body members.
    binding: HttpBinding,
  )
}

pub type HttpBinding {
  Body
  /// `@httpLabel` — substitutes into the operation's URI template
  /// `{name}` placeholders. The URI placeholder name comes from the
  /// member's JSON name; the trait itself has no payload.
  Label
  /// `@httpQuery(name)` — emitted as `?<query_name>=<value>` in the
  /// request URL.
  Query(query_name: String)
  /// `@httpHeader(name)` — emitted as an HTTP request header.
  Header(header_name: String)
  /// `@httpPayload` — the body of the request IS this member's
  /// serialised value (no surrounding JSON / XML wrapper).
  Payload
  /// `@httpPrefixHeaders(prefix)` — the member must be a Map shape;
  /// each entry becomes a header `<prefix><key>: <value>`.
  PrefixHeaders(prefix: String)
  /// `@httpQueryParams` — member is a Map shape; entries become query
  /// string pairs.
  QueryParams
  /// `@httpResponseCode` — output-only, indicates that the HTTP
  /// status code feeds this member.
  ResponseCode
}

/// Resolve a Smithy target shape ID to a `Resolved`. Recursive shape
/// nesting is safe because struct/union targets are returned as thin
/// `RStruct` / `RUnion` references — the caller looks up members
/// separately when (and only when) it wants to emit that shape's
/// definition.
pub fn resolve(model: Model, target_id: String) -> Resolved {
  case target_id {
    "smithy.api#String" -> RPrim(primitive: PString)
    "smithy.api#Integer"
    | "smithy.api#Long"
    | "smithy.api#Short"
    | "smithy.api#Byte" -> RPrim(primitive: PInt)
    "smithy.api#Float" | "smithy.api#Double" -> RPrim(primitive: PFloat)
    "smithy.api#Boolean" -> RPrim(primitive: PBool)
    "smithy.api#Timestamp" -> RTimestamp
    "smithy.api#Blob" -> RBlob
    "smithy.api#Document" -> RDocument
    "smithy.api#BigInteger" -> Unsupported(reason: "bigInteger")
    "smithy.api#BigDecimal" -> Unsupported(reason: "bigDecimal")
    "smithy.api#Unit" -> RUnit
    _ -> resolve_user_defined(model, target_id)
  }
}

fn resolve_user_defined(model: Model, target_id: String) -> Resolved {
  case model.lookup(model, target_id) {
    Error(_) -> Unsupported(reason: "shape not found: " <> target_id)
    Ok(s) -> resolve_shape(model, target_id, s)
  }
}

fn resolve_shape(model: Model, target_id: String, s: shape.Shape) -> Resolved {
  case s {
    shape.String(..) -> RPrim(primitive: PString)
    shape.Integer(..) | shape.Long(..) | shape.Short(..) | shape.Byte(..) ->
      RPrim(primitive: PInt)
    shape.Float(..) | shape.Double(..) -> RPrim(primitive: PFloat)
    shape.Bool(..) -> RPrim(primitive: PBool)
    shape.Timestamp(..) -> RTimestamp
    shape.Blob(..) -> RBlob
    shape.Document(..) -> RDocument

    shape.Enum(members: m, ..) -> resolve_enum(target_id, m)
    shape.IntEnum(members: m, ..) -> resolve_int_enum(target_id, m)

    shape.List(member: mem, ..) -> {
      let ShapeId(t) = mem.target
      let entry_name = case
        dict.get(mem.traits, ShapeId("smithy.api#xmlName"))
      {
        Ok(option.Some(trait.String(s))) -> s
        _ -> "member"
      }
      RList(element: resolve(model, t), xml_entry_name: entry_name)
    }
    shape.Map(key: k, value: v, ..) -> {
      let ShapeId(kt) = k.target
      let ShapeId(vt) = v.target
      RMap(key: resolve(model, kt), value: resolve(model, vt))
    }
    shape.Structure(..) ->
      RStruct(
        local_name: strip_namespace(target_id),
        gleam_name: strip_namespace(target_id),
        full_id: target_id,
      )
    shape.Union(..) ->
      RUnion(
        local_name: strip_namespace(target_id),
        gleam_name: strip_namespace(target_id),
        full_id: target_id,
      )

    shape.Service(..) | shape.Resource(..) | shape.Operation(..) ->
      Unsupported(reason: "service/resource/operation shape as field target")
    shape.BigInteger(..) -> Unsupported(reason: "bigInteger")
    shape.BigDecimal(..) -> Unsupported(reason: "bigDecimal")
  }
}

/// Look up the members of a struct or union shape, fully resolving each
/// member target into `Resolved`. Cheap recursive call into `resolve`
/// is safe because cycles bottom out at `RStruct` / `RUnion` (thin
/// references, no further resolution).
pub fn resolve_members(model: Model, full_id: String) -> List(MemberDef) {
  case model.lookup(model, full_id) {
    Ok(shape.Structure(members: m, ..)) | Ok(shape.Union(members: m, ..)) ->
      extract_members(model, m)
    _ -> []
  }
}

fn resolve_enum(
  target_id: String,
  members: Dict(String, shape.Member),
) -> Resolved {
  let local = strip_namespace(target_id)
  let variants =
    dict.to_list(members)
    |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
    |> list.map(fn(pair) {
      let #(member_name, mem) = pair
      let wire = case dict.get(mem.traits, ShapeId("smithy.api#enumValue")) {
        Ok(option.Some(trait.String(s))) -> s
        _ -> member_name
      }
      EnumVariant(
        gleam_ctor: variant_constructor(local, member_name),
        wire_value: wire,
      )
    })
  REnum(local_name: local, gleam_name: local, variants: variants)
}

fn resolve_int_enum(
  target_id: String,
  members: Dict(String, shape.Member),
) -> Resolved {
  let local = strip_namespace(target_id)
  let variants =
    dict.to_list(members)
    |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
    |> list.map(fn(pair) {
      let #(member_name, mem) = pair
      let wire = case dict.get(mem.traits, ShapeId("smithy.api#enumValue")) {
        Ok(option.Some(trait.Int(n))) -> n
        _ -> 0
      }
      IntEnumVariant(
        gleam_ctor: variant_constructor(local, member_name),
        wire_value: wire,
      )
    })
  RIntEnum(local_name: local, gleam_name: local, variants: variants)
}

fn extract_members(
  model: Model,
  members: Dict(String, shape.Member),
) -> List(MemberDef) {
  dict.to_list(members)
  |> list.sort(fn(a, b) { string.compare(a.0, b.0) })
  |> list.map(fn(pair) {
    let #(name, mem) = pair
    let ShapeId(target) = mem.target
    MemberDef(
      json_name: name,
      snake_name: stringutils.pascal_to_snake(name),
      target: resolve(model, target),
      required: dict.has_key(mem.traits, ShapeId("smithy.api#required")),
      binding: binding_of(mem.traits),
    )
  })
}

fn binding_of(
  traits: Dict(ShapeId, option.Option(trait.Trait)),
) -> HttpBinding {
  case dict.has_key(traits, ShapeId("smithy.api#httpLabel")) {
    True -> Label
    False ->
      case maybe_string_trait(traits, "smithy.api#httpQuery") {
        Ok(name) -> Query(query_name: name)
        Error(_) ->
          case maybe_string_trait(traits, "smithy.api#httpHeader") {
            Ok(name) -> Header(header_name: name)
            Error(_) ->
              case dict.has_key(traits, ShapeId("smithy.api#httpPayload")) {
                True -> Payload
                False ->
                  case
                    maybe_string_trait(traits, "smithy.api#httpPrefixHeaders")
                  {
                    Ok(prefix) -> PrefixHeaders(prefix: prefix)
                    Error(_) ->
                      case
                        dict.has_key(
                          traits,
                          ShapeId("smithy.api#httpQueryParams"),
                        )
                      {
                        True -> QueryParams
                        False ->
                          case
                            dict.has_key(
                              traits,
                              ShapeId("smithy.api#httpResponseCode"),
                            )
                          {
                            True -> ResponseCode
                            False -> Body
                          }
                      }
                  }
              }
          }
      }
  }
}

fn maybe_string_trait(
  traits: Dict(ShapeId, option.Option(trait.Trait)),
  trait_id: String,
) -> Result(String, Nil) {
  case dict.get(traits, ShapeId(trait_id)) {
    Ok(option.Some(trait.String(s))) -> Ok(s)
    _ -> Error(Nil)
  }
}

/// Whether a `Resolved` is supported by the emitter today. Struct /
/// union references are supported unconditionally — their members are
/// checked at the walk site.
pub fn is_supported(r: Resolved) -> Bool {
  case r {
    Unsupported(..) -> False
    RList(element: e, ..) -> is_supported(e)
    RMap(key: k, value: v) -> is_supported(k) && is_supported(v)
    _ -> True
  }
}

/// Gleam type expression for a `Resolved`. Used in record field
/// declarations and function signatures.
pub fn gleam_type(r: Resolved) -> String {
  case r {
    RPrim(primitive: PString) -> "String"
    RPrim(primitive: PInt) -> "Int"
    RPrim(primitive: PFloat) -> "json_float.SmithyFloat"
    RPrim(primitive: PBool) -> "Bool"
    REnum(gleam_name: n, ..) | RIntEnum(gleam_name: n, ..) -> n
    RList(element: e, ..) -> "List(" <> gleam_type(e) <> ")"
    RMap(key: _k, value: v) -> "dict.Dict(String, " <> gleam_type(v) <> ")"
    RStruct(gleam_name: n, ..) | RUnion(gleam_name: n, ..) -> n
    RTimestamp -> "Int"
    RBlob -> "BitArray"
    RDocument -> "json.Json"
    RUnit -> "Nil"
    Unsupported(reason: _) -> "Nil"
  }
}

/// JSON encoder expression — produces a Gleam expression that takes a
/// value of `gleam_type(r)` and returns `gleam/json.Json`.
pub fn json_encoder(r: Resolved) -> String {
  case r {
    RPrim(primitive: PString) -> "json.string"
    RPrim(primitive: PInt) -> "json.int"
    RPrim(primitive: PFloat) -> "json_float.encode"
    RPrim(primitive: PBool) -> "json.bool"
    REnum(local_name: n, ..) ->
      "encode_" <> stringutils.pascal_to_snake(n) <> "_enum"
    RIntEnum(local_name: n, ..) ->
      "encode_" <> stringutils.pascal_to_snake(n) <> "_int_enum"
    RList(element: e, ..) ->
      "fn(xs) { json.array(xs, " <> json_encoder(e) <> ") }"
    RMap(value: v, ..) ->
      "fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, "
      <> json_encoder(v)
      <> "(pair.1)) })) }"
    RStruct(local_name: n, ..) ->
      "encode_" <> stringutils.pascal_to_snake(n) <> "_struct"
    RUnion(local_name: n, ..) ->
      "encode_" <> stringutils.pascal_to_snake(n) <> "_union"
    RTimestamp -> "json.int"
    RBlob -> "fn(b) { json.string(bit_array.base64_encode(b, True)) }"
    RDocument -> "fn(j) { j }"
    RUnit -> "fn(_) { json.object([]) }"
    Unsupported(..) -> "fn(_) { json.null() }"
  }
}

/// JSON decoder expression — produces a Gleam `Decoder(t)` value.
pub fn json_decoder(r: Resolved) -> String {
  case r {
    RPrim(primitive: PString) -> "decode.string"
    RPrim(primitive: PInt) -> "decode.int"
    RPrim(primitive: PFloat) -> "json_float.decoder()"
    RPrim(primitive: PBool) -> "decode.bool"
    REnum(local_name: n, ..) ->
      "decode_" <> stringutils.pascal_to_snake(n) <> "_enum()"
    RIntEnum(local_name: n, ..) ->
      "decode_" <> stringutils.pascal_to_snake(n) <> "_int_enum()"
    RList(element: e, ..) -> "decode.list(" <> json_decoder(e) <> ")"
    RMap(value: v, ..) ->
      "decode.dict(decode.string, " <> json_decoder(v) <> ")"
    RStruct(local_name: n, ..) ->
      "decode_" <> stringutils.pascal_to_snake(n) <> "_struct()"
    RUnion(local_name: n, ..) ->
      "decode_" <> stringutils.pascal_to_snake(n) <> "_union()"
    RTimestamp -> "decode.int"
    RBlob ->
      // Smithy protocol-test params encode blobs as UTF-8 strings, not
      // base64. The on-the-wire response form IS base64 — a wire-side
      // decoder lands when real-response tests do.
      "decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })"
    RDocument -> "decode.dynamic |> decode.map(fn(_) { json.null() })"
    RUnit -> "decode.success(Nil)"
    Unsupported(..) -> "decode.success(Nil)"
  }
}

fn variant_constructor(enum_local: String, member_name: String) -> String {
  enum_local <> pascalize_screaming_snake(member_name)
}

fn pascalize_screaming_snake(s: String) -> String {
  string.split(s, "_")
  |> list.map(fn(word) {
    case word {
      "" -> ""
      _ ->
        case string.to_graphemes(word) {
          [first, ..rest] ->
            string.uppercase(first) <> string.lowercase(string.concat(rest))
          [] -> word
        }
    }
  })
  |> string.concat
}

fn strip_namespace(id: String) -> String {
  case string.split_once(id, "#") {
    Ok(#(_, local)) -> local
    Error(_) -> id
  }
}
