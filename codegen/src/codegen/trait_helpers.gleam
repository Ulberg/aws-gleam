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
/// trait — see `http_checksum_trait`.
pub fn op_requires_md5(traits: shape.Traits) -> Bool {
  dict.has_key(traits, ShapeId("smithy.api#httpChecksumRequired"))
}

/// Multi-algorithm checksum trait extracted from
/// `aws.protocols#httpChecksum`. `request_required` mirrors the
/// trait's `requestChecksumRequired`; `request_algorithm_member`
/// (when present) names an input member whose enum value picks the
/// algorithm at runtime. v1 emits a SHA-256 checksum when
/// `request_required` is set; the algorithm-member dispatch is a
/// follow-up that needs the codegen to walk the input enum's
/// variants.
pub type HttpChecksumInfo {
  HttpChecksumInfo(
    request_required: Bool,
    request_algorithm_member: Option(String),
  )
}

pub fn http_checksum_trait(traits: shape.Traits) -> Option(HttpChecksumInfo) {
  case dict.get(traits, ShapeId("aws.protocols#httpChecksum")) {
    Ok(Some(trait.Dict(d))) -> {
      let required = case dict.get(d, ShapeId("requestChecksumRequired")) {
        Ok(trait.Bool(v)) -> v
        _ -> False
      }
      let alg_member = string_field(d, "requestAlgorithmMember")
      // Only surface the trait when there's something for the
      // emitter to do — without `request_required` or an
      // algorithm member, the v1 codegen has nothing to emit.
      case required, alg_member {
        False, None -> None
        _, _ ->
          Some(HttpChecksumInfo(
            request_required: required,
            request_algorithm_member: alg_member,
          ))
      }
    }
    _ -> None
  }
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

/// Raw Smithy member names lifted out of the operation's
/// `smithy.api#paginated` trait. `input_token` / `output_token`
/// are PascalCased Smithy member names on the op's input / output
/// shapes (e.g. `"NextToken"`); `items` likewise names the
/// output member that holds the page items list; `page_size`
/// (when present) names an input member the caller can use to
/// control per-page count. The emitter is responsible for
/// resolving these wire-form names to the corresponding Gleam
/// snake_case record field names before splicing them into the
/// generated `paginate_<op>` source.
pub type PaginatedTrait {
  PaginatedTrait(
    input_token: String,
    output_token: String,
    items: String,
    page_size: Option(String),
  )
}

/// Extract `smithy.api#paginated` from an operation's traits.
/// Returns `None` when the trait is absent or when any of the
/// required fields (`inputToken`, `outputToken`, `items`) is
/// missing — without all three the codegen has no cursor + items
/// to thread, so we treat it as non-paginated.
pub fn paginated_trait(traits: shape.Traits) -> Option(PaginatedTrait) {
  case dict.get(traits, ShapeId("smithy.api#paginated")) {
    Ok(Some(trait.Dict(d))) -> {
      let input_token = string_field(d, "inputToken")
      let output_token = string_field(d, "outputToken")
      let items = string_field(d, "items")
      let page_size = string_field(d, "pageSize")
      case input_token, output_token, items {
        Some(it), Some(ot), Some(i) ->
          Some(PaginatedTrait(
            input_token: it,
            output_token: ot,
            items: i,
            page_size: page_size,
          ))
        _, _, _ -> None
      }
    }
    _ -> None
  }
}

/// One waiter lifted out of `smithy.waiters#waitable`. `name` is
/// the waiter key (e.g. `"BucketExists"`); `acceptors` is the
/// ordered list of `state` + `matcher` rules the codegen must
/// translate to `Settled` / `Continue` / `FailedNow`. Waiters
/// containing any unsupported matcher (`output`, `inputOutput`,
/// `outputCount`, `errorContains`) are dropped here so the codegen
/// never has to worry about them.
pub type WaiterDef {
  WaiterDef(
    name: String,
    acceptors: List(WaiterAcceptor),
    min_delay_ms: Int,
    max_delay_ms: Int,
  )
}

pub type WaiterAcceptor {
  WaiterAcceptor(state: WaiterState, matcher: WaiterMatcher)
}

pub type WaiterState {
  WaiterSuccess
  WaiterFailure
  WaiterRetry
}

/// Subset of `smithy.waiters#Matcher` the v1 codegen supports.
/// `MatchSuccess(True)` ⇒ match when the typed operation returns
/// `Ok(_)`. `MatchSuccess(False)` ⇒ match on any `Error(_)`.
/// `MatchErrorType(local)` ⇒ match when the typed error variant
/// equals `<Op>Error<local>`. JMESPath matchers (`output`,
/// `inputOutput`) and `outputCount` / `errorContains` are tracked
/// in the audit and deferred.
pub type WaiterMatcher {
  MatchSuccess(value: Bool)
  MatchErrorType(local: String)
}

/// Extract every supported waiter from an op's traits. Drops any
/// waiter that uses a matcher the codegen doesn't yet support so
/// the generator emits clean code (or nothing) rather than a
/// partial wait function that ignores some acceptors.
pub fn waitable_traits(traits: shape.Traits) -> List(WaiterDef) {
  case dict.get(traits, ShapeId("smithy.waiters#waitable")) {
    Ok(Some(trait.Dict(d))) ->
      dict.to_list(d)
      |> list.filter_map(fn(pair) {
        let #(ShapeId(name), body) = pair
        case body {
          trait.Dict(waiter_body) ->
            case parse_waiter(name, waiter_body) {
              Some(w) -> Ok(w)
              None -> Error(Nil)
            }
          _ -> Error(Nil)
        }
      })
    _ -> []
  }
}

fn parse_waiter(name: String, body: Dict(ShapeId, Trait)) -> Option(WaiterDef) {
  // Smithy default cadence: min=2s, max=120s when the trait
  // doesn't override.
  let min_delay = int_field(body, "minDelay", 2) * 1000
  let max_delay = int_field(body, "maxDelay", 120) * 1000
  case dict.get(body, ShapeId("acceptors")) {
    Ok(trait.List(items)) -> {
      let acceptors =
        list.filter_map(items, fn(item) {
          case item {
            trait.Dict(a) ->
              case parse_acceptor(a) {
                Some(ac) -> Ok(ac)
                None -> Error(Nil)
              }
            _ -> Error(Nil)
          }
        })
      // If any acceptor in the waiter is unsupported we get fewer
      // items back than the input list. Drop the whole waiter in
      // that case — partial coverage would be misleading.
      case list.length(acceptors) == list.length(items) {
        True ->
          Some(WaiterDef(
            name: name,
            acceptors: acceptors,
            min_delay_ms: min_delay,
            max_delay_ms: max_delay,
          ))
        False -> None
      }
    }
    _ -> None
  }
}

fn parse_acceptor(body: Dict(ShapeId, Trait)) -> Option(WaiterAcceptor) {
  let state_opt = case string_field(body, "state") {
    Some("success") -> Some(WaiterSuccess)
    Some("failure") -> Some(WaiterFailure)
    Some("retry") -> Some(WaiterRetry)
    _ -> None
  }
  let matcher_opt = case dict.get(body, ShapeId("matcher")) {
    Ok(trait.Dict(m)) -> parse_matcher(m)
    _ -> None
  }
  case state_opt, matcher_opt {
    Some(s), Some(m) -> Some(WaiterAcceptor(state: s, matcher: m))
    _, _ -> None
  }
}

fn parse_matcher(body: Dict(ShapeId, Trait)) -> Option(WaiterMatcher) {
  case dict.to_list(body) {
    [#(ShapeId("success"), trait.Bool(v))] -> Some(MatchSuccess(value: v))
    [#(ShapeId("errorType"), trait.String(s))] -> Some(MatchErrorType(local: s))
    // Other matchers (`output`, `inputOutput`, `outputCount`,
    // `errorContains`) are deferred — return None so the caller
    // drops the entire waiter.
    _ -> None
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
