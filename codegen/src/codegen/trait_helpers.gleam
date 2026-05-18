//// Shared Smithy-trait extraction helpers used by the three
//// protocol emitters (awsjson, restjson, restxml). Each protocol
//// emitter previously carried its own copy of `string_field` /
//// `int_field` / `service_metadata` / `request_compression_
//// encodings` / `string_field_under`; the contents were byte-
//// identical across all three. Pass 4 of plan.md.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set.{type Set}
import gleam/string
import smithy/shape
import smithy/shape_id.{type ShapeId, ShapeId}
import smithy/trait.{type Trait}

/// Per-service metadata pulled out of the service shape's traits.
/// `endpoint_prefix` and `signing_name` feed the runtime's URL +
/// SigV4 setup; `service_local` is the Smithy short name (the part
/// after `#`) and feeds the file-header comment.
///
/// `endpoint_rule_set_json` carries the raw
/// `smithy.rules#endpointRuleSet` trait re-serialised back to JSON.
/// When present the generated `Client.new` parses it and attaches it
/// via `runtime.with_endpoint_rule_set`, so per-request URL resolution
/// runs the official Smithy rule set rather than the static
/// `<prefix>.<region>.amazonaws.com` fallback.
pub type Metadata {
  Metadata(
    service_local: String,
    endpoint_prefix: String,
    signing_name: String,
    endpoint_rule_set_json: Option(String),
  )
}

/// Extract a `Metadata` record from a service shape's `Traits`.
/// Falls back to lowercased `service_local` for `endpoint_prefix`
/// and to `endpoint_prefix` for `signing_name` when the traits
/// don't carry overrides.
pub fn service_metadata(
  traits: shape.Traits,
  service_local: String,
) -> Metadata {
  let endpoint_prefix =
    string_field_under(traits, "aws.api#service", "endpointPrefix")
    |> result.unwrap(string.lowercase(service_local))
  let signing_name =
    string_field_under(traits, "aws.auth#sigv4", "name")
    |> result.unwrap(endpoint_prefix)
  Metadata(
    service_local: service_local,
    endpoint_prefix: endpoint_prefix,
    signing_name: signing_name,
    endpoint_rule_set_json: endpoint_rule_set_json(traits),
  )
}

/// Re-serialise the `smithy.rules#endpointRuleSet` trait body back to
/// JSON. Returns `None` when the service shape doesn't declare the
/// trait — the legacy `<prefix>.<region>.amazonaws.com` URL is then
/// the only thing the runtime can fall back to.
pub fn endpoint_rule_set_json(traits: shape.Traits) -> Option(String) {
  case dict.get(traits, ShapeId("smithy.rules#endpointRuleSet")) {
    Ok(Some(t)) -> Some(trait.to_json_string(t))
    _ -> None
  }
}

/// Look up a `String` field nested under another trait. E.g. the
/// `endpointPrefix` field on the `aws.api#service` trait.
pub fn string_field_under(
  traits: shape.Traits,
  trait_id: String,
  field: String,
) -> Result(String, Nil) {
  case dict.get(traits, ShapeId(trait_id)) {
    Ok(Some(trait.Dict(d))) ->
      case dict.get(d, ShapeId(field)) {
        Ok(trait.String(s)) -> Ok(s)
        _ -> Error(Nil)
      }
    _ -> Error(Nil)
  }
}

/// Look up a `String` field on a trait-dict body.
pub fn string_field(d: Dict(ShapeId, Trait), name: String) -> Option(String) {
  case dict.get(d, ShapeId(name)) {
    Ok(trait.String(s)) -> Some(s)
    _ -> None
  }
}

/// Look up an `Int` field on a trait-dict body, with a default.
pub fn int_field(d: Dict(ShapeId, Trait), name: String, default: Int) -> Int {
  case dict.get(d, ShapeId(name)) {
    Ok(trait.Int(n)) -> n
    _ -> default
  }
}

/// True iff the operation carries `smithy.api#httpChecksumRequired`.
/// The rest/awsjson emitters use this to append a `Content-MD5:
/// base64(md5(body))` step to the generated `build_<op>_request`.
/// Distinct from the multi-algorithm `aws.protocols#httpChecksum`
/// trait, which is still emitter-skipped pending a richer checksum
/// middleware.
pub fn op_requires_md5(traits: shape.Traits) -> Bool {
  dict.has_key(traits, ShapeId("smithy.api#httpChecksumRequired"))
}

/// Pick the Gleam type name for an operation's typed error sum.
/// Normally `<OpLocal>Error`, but if a Smithy structure with that
/// exact name already exists in the service (e.g. Application
/// Discovery's `BatchDeleteImportDataError` record carrier
/// collides with the synthetic `BatchDeleteImportData` operation
/// error sum), we suffix with `Operation` instead so the two types
/// don't share a name. The wire form is unaffected — operation
/// error sums are local to the SDK, never serialised.
pub fn op_error_type(op_local: String, emitted: Set(String)) -> String {
  let candidate = string.concat([op_local, "Error"])
  case set.contains(emitted, candidate) {
    True -> string.concat([op_local, "OperationError"])
    False -> candidate
  }
}

/// Extract the `encodings` list from `@requestCompression`. Returns
/// an empty list when the trait is absent or malformed.
pub fn request_compression_encodings(traits: shape.Traits) -> List(String) {
  case dict.get(traits, ShapeId("smithy.api#requestCompression")) {
    Ok(Some(trait.Dict(d))) ->
      case dict.get(d, ShapeId("encodings")) {
        Ok(trait.List(items)) ->
          list.filter_map(items, fn(t) {
            case t {
              trait.String(s) -> Ok(s)
              _ -> Error(Nil)
            }
          })
        _ -> []
      }
    _ -> []
  }
}
