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
  /// `sparse` reflects `@sparse` — sparse lists CAN contain nulls and
  /// surface as `List(Option(T))` so the codec can preserve them.
  RList(
    element: Resolved,
    xml_entry_name: String,
    sparse: Bool,
    /// `@xmlNamespace` on the list's **inner member**. When set,
    /// each per-entry wrapping element on the wire carries the
    /// corresponding `xmlns="..."` (or `xmlns:prefix="..."`)
    /// attribute. This is independent of any namespace on the
    /// list shape itself, which is dropped when the list is
    /// flattened.
    xml_element_namespace: option.Option(#(String, String)),
  )
  /// Smithy map of K → V. `sparse` reflects `@sparse` — sparse maps
  /// permit null values and surface as `Dict(K, Option(V))`.
  RMap(
    key: Resolved,
    value: Resolved,
    sparse: Bool,
    /// `@xmlNamespace` on the map's **key member**. When set, the
    /// `<key>` wrapper on the wire carries `xmlns="..."` / `xmlns:
    /// prefix="..."`. Distinct from the namespace on the map shape
    /// itself (carried by `MemberDef.xml_namespace` on whatever
    /// member references the map).
    xml_key_namespace: option.Option(#(String, String)),
    /// `@xmlNamespace` on the map's **value member**, same shape.
    xml_value_namespace: option.Option(#(String, String)),
    /// `@xmlName` on the map's key member, defaults to `"key"`.
    /// Used by restXml's body emitter for `<key>K</key>` /
    /// `<custom>K</custom>` variants.
    xml_key_name: String,
    /// `@xmlName` on the map's value member, defaults to `"value"`.
    xml_value_name: String,
  )
  /// Reference to a Smithy structure. The full ID lets the emitter look
  /// the members up on demand without inlining (which would loop on
  /// recursive shapes).
  RStruct(
    local_name: String,
    gleam_name: String,
    full_id: String,
    /// `@xmlName` trait on the struct shape itself (not on a member).
    /// `Some(s)` overrides the default wire wrapper for `@httpPayload`
    /// struct members — e.g. `<Hello>` instead of `<PayloadWithXml
    /// Name>`. `None` falls through to `local_name`.
    xml_name: option.Option(String),
    /// `@xmlNamespace` trait on the struct shape. `Some(#(prefix,
    /// uri))` adds `xmlns:<prefix>="<uri>"` (or `xmlns="<uri>"` when
    /// prefix is empty) to the wrapping element when the struct is
    /// used as an `@httpPayload` body root or as the request body.
    xml_namespace: option.Option(#(String, String)),
  )
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
    /// The wire key — what shows up in JSON bodies, query strings, or
    /// XML element names. Honours `@jsonName` / `@xmlName` overrides;
    /// otherwise the Smithy member name.
    json_name: String,
    /// Gleam record-field name, always derived from the original
    /// Smithy member name (Pascal → snake_case + reserved-keyword
    /// escape). Stable across `@jsonName` changes so the user-facing
    /// API doesn't churn when a service rebrands a wire field.
    snake_name: String,
    /// Original Smithy member name (PascalCase). Used to build union
    /// variant constructor names (which must be valid Gleam
    /// identifiers — the wire name may include leading underscores or
    /// other non-Gleam characters that Smithy permits in `@jsonName`).
    member_name: String,
    target: Resolved,
    required: Bool,
    /// HTTP binding the member carries. Used by rest-protocol emitters
    /// to route the field to the URI / query / headers instead of the
    /// body. Defaults to `Body` for members without an http-binding
    /// trait — they're serialised into the JSON / XML body alongside
    /// other body members.
    binding: HttpBinding,
    /// `@mediaType("...")` — sets Content-Type on the request for
    /// `@httpPayload` members whose wire form is intrinsically opaque
    /// (Blob, raw String). `None` falls back to the protocol default.
    media_type: option.Option(String),
    /// `@timestampFormat("date-time"|"http-date"|"epoch-seconds")` —
    /// member-level override for the wire form of `@timestamp` shapes.
    /// `None` means use the protocol default (`epoch-seconds` for the
    /// awsJson family, `date-time` for restJson1 / restXml).
    timestamp_format: option.Option(String),
    /// `@default(value)` — the SDK serialises this value when the user
    /// leaves the field unset (`Option.None`). Stored as a Gleam source
    /// expression that produces `gleam/json.Json` so the encoder can
    /// splice it directly into the body.
    default_json: option.Option(String),
    /// `@idempotencyToken` — when the member is `None`, the SDK
    /// auto-generates a UUID v4 and serialises that. Behaves like a
    /// dynamic `@default` whose value is a fresh UUID per request.
    idempotency_token: Bool,
    /// `@xmlFlattened` — list / map members with this trait skip the
    /// wrapper element on the wire. Lists become repeated
    /// `<member_name>value</member_name>` siblings; maps become
    /// repeated `<member_name><key>K</key><value>V</value></member
    /// _name>` siblings.
    xml_flattened: Bool,
    /// `@xmlAttribute` — the member becomes an XML attribute on the
    /// parent element rather than a child element. Smithy restricts
    /// this to scalar members; the wire form uses `@xmlName` (or
    /// the Smithy member name) as the attribute name.
    xml_attribute: Bool,
    /// `@xmlNamespace` on the *member* — adds `xmlns:<prefix>=<uri>`
    /// (or `xmlns=<uri>` when prefix is empty) to the wrapping
    /// element when the member is serialised in XML. Distinct from
    /// the shape-level `@xmlNamespace` on `RStruct`: this one
    /// applies at the member position, regardless of the target
    /// shape.
    xml_namespace: option.Option(#(String, String)),
  )
}

fn media_type_of_target(
  model: Model,
  target_id: String,
) -> option.Option(String) {
  case model.lookup(model, target_id) {
    Ok(sh) ->
      case shape_traits(sh) {
        traits ->
          case dict.get(traits, ShapeId("smithy.api#mediaType")) {
            Ok(option.Some(trait.String(s))) -> option.Some(s)
            _ -> option.None
          }
      }
    _ -> option.None
  }
}

fn timestamp_format_of_target(
  model: Model,
  target_id: String,
) -> option.Option(String) {
  case model.lookup(model, target_id) {
    Ok(sh) ->
      case dict.get(shape_traits(sh), ShapeId("smithy.api#timestampFormat")) {
        Ok(option.Some(trait.String(s))) -> option.Some(s)
        _ -> option.None
      }
    _ -> option.None
  }
}

/// Render an `@default(VALUE)` trait as a Gleam source expression
/// producing `gleam/json.Json`. Used by the per-struct encoder to
/// splice the default in place of an `option.None` field.
fn default_to_json_expr(t: trait.Trait) -> String {
  case t {
    trait.Null -> "json.null()"
    trait.String(s) ->
      name_concat(["json.string(\"", escape_default_string(s), "\")"])
    trait.Int(n) -> name_concat(["json.int(", int_to_dec(n), ")"])
    trait.Float(f) -> name_concat(["json.float(", float_to_dec(f), ")"])
    trait.Bool(True) -> "json.bool(True)"
    trait.Bool(False) -> "json.bool(False)"
    trait.List(_) -> "json.preprocessed_array([])"
    trait.Dict(_) -> "json.object([])"
  }
}

fn escape_default_string(s: String) -> String {
  s
  |> string.replace("\\", "\\\\")
  |> string.replace("\"", "\\\"")
}

fn int_to_dec(n: Int) -> String {
  case n {
    0 -> "0"
    _ -> int_str(n, "")
  }
}

fn int_str(n: Int, acc: String) -> String {
  case n {
    0 -> acc
    _ -> {
      let d = n - { n / 10 } * 10
      let c = case d {
        0 -> "0"
        1 -> "1"
        2 -> "2"
        3 -> "3"
        4 -> "4"
        5 -> "5"
        6 -> "6"
        7 -> "7"
        8 -> "8"
        9 -> "9"
        _ -> "?"
      }
      int_str(n / 10, name_concat([c, acc]))
    }
  }
}

// OTP 25+ short formatter — `1.1` not `1.10000…e+00`. Lives directly
// in `erlang` (no extra deps for the codegen subproject).
@external(erlang, "erlang", "float_to_binary")
fn float_to_binary(f: Float, opts: List(FloatFormatOpt)) -> String

type FloatFormatOpt {
  Short
}

fn float_to_dec(f: Float) -> String {
  float_to_binary(f, [Short])
}

fn shape_traits(sh: shape.Shape) -> Dict(ShapeId, option.Option(trait.Trait)) {
  case sh {
    shape.Blob(traits: t) -> t
    shape.Bool(traits: t) -> t
    shape.String(traits: t) -> t
    shape.Byte(traits: t) -> t
    shape.Short(traits: t) -> t
    shape.Integer(traits: t) -> t
    shape.Long(traits: t) -> t
    shape.Float(traits: t) -> t
    shape.Double(traits: t) -> t
    shape.BigInteger(traits: t) -> t
    shape.BigDecimal(traits: t) -> t
    shape.Timestamp(traits: t) -> t
    shape.Document(traits: t) -> t
    shape.List(traits: t, ..) -> t
    shape.Map(traits: t, ..) -> t
    shape.Structure(traits: t, ..) -> t
    shape.Union(traits: t, ..) -> t
    shape.IntEnum(traits: t, ..) -> t
    shape.Enum(traits: t, ..) -> t
    shape.Service(traits: t, ..) -> t
    shape.Resource(traits: t, ..) -> t
    shape.Operation(traits: t, ..) -> t
  }
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

/// The `@http(method, uri, code)` trait + `@requestCompression`. Used
/// by the rest-protocol `emit_build` emitters to build the request
/// path / status / encoding. `compression` is the `@requestCompression`
/// encodings list (e.g. `["gzip"]`); when non-empty the SDK appends
/// each encoding to the `Content-Encoding` header.
pub type HttpTrait {
  HttpTrait(method: String, uri: String, code: Int, compression: List(String))
}

/// A struct's members partitioned by their `HttpBinding`. Returned by
/// `categorize_bindings`; consumed by the rest-protocol `emit_build`
/// emitters to avoid seven near-identical `list.filter` ladders.
pub type BindingCategories {
  BindingCategories(
    payload: Result(MemberDef, Nil),
    labels: List(MemberDef),
    queries: List(MemberDef),
    query_maps: List(MemberDef),
    headers: List(MemberDef),
    prefix_headers: List(MemberDef),
    body: List(MemberDef),
  )
}

/// Walk `members` once and bucket each by its `binding`. `Payload` is
/// `Result(MemberDef, Nil)` because Smithy permits at most one
/// `@httpPayload` member per operation. Order within each bucket
/// matches input order (the per-bucket `list.filter` callers used).
pub fn categorize_bindings(members: List(MemberDef)) -> BindingCategories {
  let empty =
    BindingCategories(
      payload: Error(Nil),
      labels: [],
      queries: [],
      query_maps: [],
      headers: [],
      prefix_headers: [],
      body: [],
    )
  let acc =
    list.fold(members, empty, fn(acc, m) {
      case m.binding {
        Body -> BindingCategories(..acc, body: [m, ..acc.body])
        Label -> BindingCategories(..acc, labels: [m, ..acc.labels])
        Query(_) -> BindingCategories(..acc, queries: [m, ..acc.queries])
        QueryParams ->
          BindingCategories(..acc, query_maps: [m, ..acc.query_maps])
        Header(_) -> BindingCategories(..acc, headers: [m, ..acc.headers])
        PrefixHeaders(_) ->
          BindingCategories(..acc, prefix_headers: [m, ..acc.prefix_headers])
        Payload -> BindingCategories(..acc, payload: Ok(m))
        ResponseCode -> acc
      }
    })
  BindingCategories(
    payload: acc.payload,
    labels: list.reverse(acc.labels),
    queries: list.reverse(acc.queries),
    query_maps: list.reverse(acc.query_maps),
    headers: list.reverse(acc.headers),
    prefix_headers: list.reverse(acc.prefix_headers),
    body: list.reverse(acc.body),
  )
}

/// True if any of the body-shaped buckets has at least one member.
/// Mirrors the `input_consumed` check the rest-protocol emitters do
/// before deciding whether to bind `input` vs `_input`.
pub fn has_any_binding(c: BindingCategories) -> Bool {
  case c.payload {
    Ok(_) -> True
    Error(_) ->
      [c.labels, c.queries, c.query_maps, c.headers, c.prefix_headers, c.body]
      |> list.any(fn(xs) { xs != [] })
  }
}

/// Build a `full_id → unique gleam_name` map for the whole model.
/// Two Smithy shapes with the same local name but different
/// namespaces collapse to the same Gleam type name otherwise; we
/// disambiguate by prefixing the namespace's final segment in
/// PascalCase (`...restjson.nested#GreetingStruct` becomes
/// `NestedGreetingStruct`).
pub fn build_rename_map(model: Model) -> Dict(String, String) {
  // Group full_ids by local name.
  let by_local =
    dict.fold(model.shapes, dict.new(), fn(acc, sid, _shape) {
      let ShapeId(full_id) = sid
      // Skip the prelude — these are well-known and don't collide.
      case string.starts_with(full_id, "smithy.api#") {
        True -> acc
        False -> {
          let local = strip_namespace(full_id)
          let existing =
            dict.get(acc, local)
            |> option.from_result()
            |> option.unwrap([])
          dict.insert(acc, local, [full_id, ..existing])
        }
      }
    })
  // For each collision (>1 full_id for same local), apply namespace
  // disambiguation. Singletons keep the bare local name.
  dict.fold(by_local, dict.new(), fn(acc, local, full_ids) {
    case full_ids {
      [single] -> dict.insert(acc, single, local)
      multiple ->
        list.fold(multiple, acc, fn(acc2, full_id) {
          let unique = name_concat([local, namespace_suffix(full_id)])
          dict.insert(acc2, full_id, unique)
        })
    }
  })
}

/// Take the last `.`-separated segment of a Smithy namespace and turn
/// it into a PascalCase fragment suitable for splicing into a Gleam
/// type name. Used for namespace-disambiguating collisions.
fn namespace_suffix(full_id: String) -> String {
  case string.split_once(full_id, "#") {
    Ok(#(ns, _)) -> {
      let last = case string.split(ns, ".") {
        [] -> ns
        parts -> {
          let assert Ok(tail) = list.last(parts)
          tail
        }
      }
      pascalize(last)
    }
    Error(_) -> "X"
  }
}

/// Read `@xmlName` on a shape's traits. Used by `RStruct` to track
/// the per-shape override that `@httpPayload`-bound struct members
/// honour as the wire wrapper element name.
fn xml_name_of(traits: shape.Traits) -> option.Option(String) {
  case dict.get(traits, ShapeId("smithy.api#xmlName")) {
    Ok(option.Some(trait.String(s))) -> option.Some(s)
    _ -> option.None
  }
}

/// Read `@xmlNamespace` on a shape's traits. The trait body is a
/// dict `{uri: "...", prefix: "..."}`. Returns
/// `Some(#(prefix, uri))`; `prefix` is `""` for the default
/// (un-prefixed) namespace. Used by `RStruct` to emit the matching
/// `xmlns="..."` / `xmlns:prefix="..."` attribute when the shape
/// becomes a wire wrapper.
fn xml_namespace_of(traits: shape.Traits) -> option.Option(#(String, String)) {
  case dict.get(traits, ShapeId("smithy.api#xmlNamespace")) {
    Ok(option.Some(trait.Dict(d))) -> {
      let uri = case dict.get(d, ShapeId("uri")) {
        Ok(trait.String(s)) -> s
        _ -> ""
      }
      let prefix = case dict.get(d, ShapeId("prefix")) {
        Ok(trait.String(s)) -> s
        _ -> ""
      }
      case uri {
        "" -> option.None
        _ -> option.Some(#(prefix, uri))
      }
    }
    _ -> option.None
  }
}

fn pascalize(s: String) -> String {
  case string.to_graphemes(s) {
    [] -> s
    [first, ..rest] ->
      name_concat([string.uppercase(first), string.concat(rest)])
  }
}

/// Walk a `Resolved` tree and rewrite every `RStruct` / `RUnion` /
/// `REnum` / `RIntEnum` to use the disambiguated Gleam name from the
/// rename map. Identity for shapes not in the map. The walker bottoms
/// out at thin struct/union references — recursion is bounded by the
/// shape graph (lists, maps, primitives) — so this is safe to call
/// after `resolve`.
pub fn apply_rename(r: Resolved, rename: Dict(String, String)) -> Resolved {
  case r {
    RStruct(
      full_id: id,
      local_name: ln,
      gleam_name: gn,
      xml_name: xn,
      xml_namespace: xns,
    ) -> {
      let new = gleam_name_for(rename, id)
      case new == ln {
        True -> r
        False ->
          RStruct(
            local_name: new,
            gleam_name: new,
            full_id: id,
            xml_name: xn,
            xml_namespace: xns,
          )
      }
      |> fn(x) {
        let _ = gn
        x
      }
    }
    RUnion(full_id: id, local_name: ln, gleam_name: gn) -> {
      let new = gleam_name_for(rename, id)
      case new == ln {
        True -> r
        False -> RUnion(local_name: new, gleam_name: new, full_id: id)
      }
      |> fn(x) {
        let _ = gn
        x
      }
    }
    RList(
      element: e,
      xml_entry_name: xen,
      sparse: sp,
      xml_element_namespace: ens,
    ) ->
      RList(
        element: apply_rename(e, rename),
        xml_entry_name: xen,
        sparse: sp,
        xml_element_namespace: ens,
      )
    RMap(
      key: k,
      value: v,
      sparse: sp,
      xml_key_namespace: knp,
      xml_value_namespace: vnp,
      xml_key_name: kn,
      xml_value_name: vn,
    ) ->
      RMap(
        key: apply_rename(k, rename),
        value: apply_rename(v, rename),
        sparse: sp,
        xml_key_namespace: knp,
        xml_value_namespace: vnp,
        xml_key_name: kn,
        xml_value_name: vn,
      )
    _ -> r
  }
}

/// Apply `apply_rename` to a `MemberDef`'s target — used when
/// emitting members of a renamed struct.
pub fn apply_rename_member(
  m: MemberDef,
  rename: Dict(String, String),
) -> MemberDef {
  MemberDef(..m, target: apply_rename(m.target, rename))
}

/// Look up the disambiguated Gleam name for a shape. Falls back to
/// the bare local name when the shape isn't in the rename map (e.g.
/// during the rename-map's own construction).
pub fn gleam_name_for(rename: Dict(String, String), full_id: String) -> String {
  case dict.get(rename, full_id) {
    Ok(name) -> name
    Error(_) -> strip_namespace(full_id)
  }
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
    Error(_) ->
      Unsupported(reason: string.concat(["shape not found: ", target_id]))
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

    shape.List(member: mem, traits: lt) -> {
      let ShapeId(t) = mem.target
      let entry_name = case
        dict.get(mem.traits, ShapeId("smithy.api#xmlName"))
      {
        Ok(option.Some(trait.String(s))) -> s
        _ -> "member"
      }
      let sparse = dict.has_key(lt, ShapeId("smithy.api#sparse"))
      RList(
        element: resolve(model, t),
        xml_entry_name: entry_name,
        sparse: sparse,
        xml_element_namespace: xml_namespace_of(mem.traits),
      )
    }
    shape.Map(key: k, value: v, traits: mt) -> {
      let ShapeId(kt) = k.target
      let ShapeId(vt) = v.target
      let sparse = dict.has_key(mt, ShapeId("smithy.api#sparse"))
      // `@xmlName` lives on the **map members** (k.traits / v.traits),
      // not on the map shape itself. Default to Smithy's "key" /
      // "value" wire labels.
      let key_name = case dict.get(k.traits, ShapeId("smithy.api#xmlName")) {
        Ok(option.Some(trait.String(s))) -> s
        _ -> "key"
      }
      let value_name = case dict.get(v.traits, ShapeId("smithy.api#xmlName")) {
        Ok(option.Some(trait.String(s))) -> s
        _ -> "value"
      }
      RMap(
        key: resolve(model, kt),
        value: resolve(model, vt),
        sparse: sparse,
        xml_key_namespace: xml_namespace_of(k.traits),
        xml_value_namespace: xml_namespace_of(v.traits),
        xml_key_name: key_name,
        xml_value_name: value_name,
      )
    }
    shape.Structure(traits: t, ..) -> {
      let local = strip_namespace(target_id)
      RStruct(
        local_name: local,
        // Gleam type names MUST start with an uppercase letter. Smithy
        // shape names are PascalCase by convention but a handful (e.g.
        // `com.amazonaws.finspacedata#locationType`) sneak through
        // lower-cased; pascalize unconditionally so the generated
        // source compiles.
        gleam_name: stringutils.gleam_type_name(local),
        full_id: target_id,
        xml_name: xml_name_of(t),
        xml_namespace: xml_namespace_of(t),
      )
    }
    shape.Union(..) -> {
      let local = strip_namespace(target_id)
      RUnion(
        local_name: local,
        gleam_name: stringutils.gleam_type_name(local),
        full_id: target_id,
      )
    }

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
  let gleam_name = stringutils.gleam_type_name(local)
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
        gleam_ctor: variant_constructor(gleam_name, member_name),
        wire_value: wire,
      )
    })
  REnum(local_name: local, gleam_name: gleam_name, variants: variants)
}

fn resolve_int_enum(
  target_id: String,
  members: Dict(String, shape.Member),
) -> Resolved {
  let local = strip_namespace(target_id)
  let gleam_name = stringutils.gleam_type_name(local)
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
        gleam_ctor: variant_constructor(gleam_name, member_name),
        wire_value: wire,
      )
    })
  RIntEnum(local_name: local, gleam_name: gleam_name, variants: variants)
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
    // The wire-key resolution order is: `@xmlName` (XML-protocol
    // override), then `@jsonName` (JSON-protocol override), then
    // the Smithy member name. In practice a member only carries one
    // of the two traits so order rarely matters; when both are set
    // the XML override wins because restXml is the only consumer
    // that reads `@xmlName`. The Gleam-side record field always
    // derives from the Smithy member name so the user-facing API
    // doesn't change when the service rebrands a wire field.
    let wire_name = case
      dict.get(mem.traits, ShapeId("smithy.api#xmlName")),
      dict.get(mem.traits, ShapeId("smithy.api#jsonName"))
    {
      Ok(option.Some(trait.String(s))), _ -> s
      _, Ok(option.Some(trait.String(s))) -> s
      _, _ -> name
    }
    // `@mediaType` overrides Content-Type for `@httpPayload` members.
    // Falls back to the target shape's own `@mediaType` (S3 puts the
    // trait on the wrapping `StreamingBlob` shape rather than each op
    // member).
    let media_type = case
      dict.get(mem.traits, ShapeId("smithy.api#mediaType"))
    {
      Ok(option.Some(trait.String(s))) -> option.Some(s)
      _ -> media_type_of_target(model, target)
    }
    // `@timestampFormat` (member overrides target-shape trait if both
    // are set).
    let timestamp_format = case
      dict.get(mem.traits, ShapeId("smithy.api#timestampFormat"))
    {
      Ok(option.Some(trait.String(s))) -> option.Some(s)
      _ -> timestamp_format_of_target(model, target)
    }
    // `@clientOptional` opts a member out of automatic default
    // population. Per the Smithy spec, the wire form leaves the field
    // absent even if the shape declared a `@default`.
    let client_optional =
      dict.has_key(mem.traits, ShapeId("smithy.api#clientOptional"))
    let default_json = case
      dict.get(mem.traits, ShapeId("smithy.api#default")),
      client_optional
    {
      Ok(option.Some(t)), False -> option.Some(default_to_json_expr(t))
      _, _ -> option.None
    }
    let idempotency_token =
      dict.has_key(mem.traits, ShapeId("smithy.api#idempotencyToken"))
    let xml_flattened =
      dict.has_key(mem.traits, ShapeId("smithy.api#xmlFlattened"))
    let xml_attribute =
      dict.has_key(mem.traits, ShapeId("smithy.api#xmlAttribute"))
    let xml_namespace = xml_namespace_of(mem.traits)
    MemberDef(
      json_name: wire_name,
      snake_name: stringutils.pascal_to_snake(name),
      member_name: name,
      target: resolve(model, target),
      required: dict.has_key(mem.traits, ShapeId("smithy.api#required")),
      binding: binding_of(mem.traits),
      media_type: media_type,
      timestamp_format: timestamp_format,
      default_json: default_json,
      idempotency_token: idempotency_token,
      xml_flattened: xml_flattened,
      xml_attribute: xml_attribute,
      xml_namespace: xml_namespace,
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
    RMap(key: k, value: v, ..) -> is_supported(k) && is_supported(v)
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
    RList(element: e, sparse: True, ..) ->
      name_concat(["List(option.Option(", gleam_type(e), "))"])
    RList(element: e, sparse: False, ..) ->
      name_concat(["List(", gleam_type(e), ")"])
    RMap(key: _k, value: v, sparse: True, ..) ->
      name_concat(["dict.Dict(String, option.Option(", gleam_type(v), "))"])
    RMap(key: _k, value: v, sparse: False, ..) ->
      name_concat(["dict.Dict(String, ", gleam_type(v), ")"])
    RStruct(gleam_name: n, ..) | RUnion(gleam_name: n, ..) -> n
    RTimestamp -> "Int"
    RBlob -> "BitArray"
    RDocument -> "json.Json"
    RUnit -> "Nil"
    Unsupported(reason: _) -> "Nil"
  }
}

/// Per-member JSON encoder/decoder. Wraps `json_encoder` /
/// `json_decoder` with `@timestampFormat` handling — timestamps are
/// the one Smithy type whose wire form depends on the **member**, not
/// just the shape. `format` is the resolved member-level format
/// (member-trait first, then shape-trait, then `None` for protocol
/// default).
pub fn json_encoder_member(
  r: Resolved,
  format: option.Option(String),
) -> String {
  case r, format {
    RTimestamp, option.Some("date-time") ->
      "fn(v) { json.string(json_timestamp.format_iso8601(v)) }"
    RTimestamp, option.Some("http-date") ->
      "fn(v) { json.string(json_timestamp.format_http_date(v)) }"
    _, _ -> json_encoder(r)
  }
}

pub fn json_decoder_member(
  r: Resolved,
  format: option.Option(String),
) -> String {
  case r, format {
    RTimestamp, _ -> "json_timestamp.decoder()"
    _, _ -> json_decoder(r)
  }
}

pub fn json_decoder_member_params(
  r: Resolved,
  format: option.Option(String),
) -> String {
  case r, format {
    RTimestamp, _ -> "json_timestamp.decoder()"
    _, _ -> json_decoder_params(r)
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
    REnum(gleam_name: n, ..) ->
      name_concat(["encode_", stringutils.pascal_to_snake(n), "_enum"])
    RIntEnum(gleam_name: n, ..) ->
      name_concat(["encode_", stringutils.pascal_to_snake(n), "_int_enum"])
    RList(element: e, sparse: True, ..) ->
      name_concat([
        "fn(xs) { json.array(xs, fn(o) { case o { option.Some(x) -> ",
        json_encoder(e),
        "(x) option.None -> json.null() } }) }",
      ])
    RList(element: e, sparse: False, ..) ->
      name_concat(["fn(xs) { json.array(xs, ", json_encoder(e), ") }"])
    RMap(value: v, sparse: True, ..) ->
      name_concat([
        "fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, case pair.1 { option.Some(x) -> ",
        json_encoder(v),
        "(x) option.None -> json.null() }) })) }",
      ])
    RMap(value: v, sparse: False, ..) ->
      name_concat([
        "fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, ",
        json_encoder(v),
        "(pair.1)) })) }",
      ])
    RStruct(gleam_name: n, ..) ->
      name_concat(["encode_", stringutils.pascal_to_snake(n), "_struct"])
    RUnion(gleam_name: n, ..) ->
      name_concat(["encode_", stringutils.pascal_to_snake(n), "_union"])
    RTimestamp -> "json.int"
    RBlob -> "fn(b) { json.string(bit_array.base64_encode(b, True)) }"
    RDocument -> "fn(j) { j }"
    RUnit -> "fn(_) { json.object([]) }"
    Unsupported(..) -> "fn(_) { json.null() }"
  }
}

/// Build a Gleam identifier name from a list of parts. Same pattern
/// as the per-protocol emitter helpers — avoids the `<>` operator
/// throughout the codegen source.
fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

/// Same shape as `json_decoder`, but every nested struct/union
/// reference points at the `_struct_params` variant (member-name
/// keyed). Used by the protocol-test dispatchers, whose `params`
/// blobs are keyed by Smithy member names, not by `@jsonName`
/// overrides. List and map element decoders recurse via this same
/// function so the member-keyed convention reaches the leaves.
pub fn json_decoder_params(r: Resolved) -> String {
  case r {
    RStruct(gleam_name: n, ..) ->
      name_concat([
        "decode_",
        stringutils.pascal_to_snake(n),
        "_struct_params()",
      ])
    RUnion(gleam_name: n, ..) ->
      name_concat([
        "decode_",
        stringutils.pascal_to_snake(n),
        "_union_params()",
      ])
    RList(element: e, sparse: True, ..) ->
      name_concat(["decode.list(decode.optional(", json_decoder_params(e), "))"])
    RList(element: e, sparse: False, ..) ->
      name_concat(["decode.list(", json_decoder_params(e), ")"])
    RMap(value: v, sparse: True, ..) ->
      name_concat([
        "decode.dict(decode.string, decode.optional(",
        json_decoder_params(v),
        "))",
      ])
    RMap(value: v, sparse: False, ..) ->
      name_concat(["decode.dict(decode.string, ", json_decoder_params(v), ")"])
    _ -> json_decoder(r)
  }
}

/// JSON decoder expression — produces a Gleam `Decoder(t)` value.
pub fn json_decoder(r: Resolved) -> String {
  case r {
    RPrim(primitive: PString) -> "decode.string"
    RPrim(primitive: PInt) -> "decode.int"
    RPrim(primitive: PFloat) -> "json_float.decoder()"
    RPrim(primitive: PBool) -> "decode.bool"
    REnum(gleam_name: n, ..) ->
      name_concat(["decode_", stringutils.pascal_to_snake(n), "_enum()"])
    RIntEnum(gleam_name: n, ..) ->
      name_concat(["decode_", stringutils.pascal_to_snake(n), "_int_enum()"])
    RList(element: e, sparse: True, ..) ->
      name_concat(["decode.list(decode.optional(", json_decoder(e), "))"])
    RList(element: e, sparse: False, ..) ->
      name_concat(["decode.list(", json_decoder(e), ")"])
    RMap(value: v, sparse: True, ..) ->
      name_concat([
        "decode.dict(decode.string, decode.optional(",
        json_decoder(v),
        "))",
      ])
    RMap(value: v, sparse: False, ..) ->
      name_concat(["decode.dict(decode.string, ", json_decoder(v), ")"])
    RStruct(gleam_name: n, ..) ->
      name_concat(["decode_", stringutils.pascal_to_snake(n), "_struct()"])
    RUnion(gleam_name: n, ..) ->
      name_concat(["decode_", stringutils.pascal_to_snake(n), "_union()"])
    RTimestamp -> "json_timestamp.decoder()"
    RBlob ->
      // Smithy protocol-test params encode blobs as UTF-8 strings, not
      // base64. The on-the-wire response form IS base64 — a wire-side
      // decoder lands when real-response tests do.
      "decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })"
    RDocument -> "json_document.decoder()"
    RUnit -> "decode.success(Nil)"
    Unsupported(..) -> "decode.success(Nil)"
  }
}

fn variant_constructor(enum_local: String, member_name: String) -> String {
  name_concat([enum_local, pascalize_screaming_snake(member_name)])
}

fn pascalize_screaming_snake(s: String) -> String {
  string.split(s, "_")
  |> list.map(fn(word) {
    case word {
      "" -> ""
      _ ->
        case string.to_graphemes(word) {
          [first, ..rest] ->
            name_concat([
              string.uppercase(first),
              string.lowercase(string.concat(rest)),
            ])
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
