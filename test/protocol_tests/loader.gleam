//// Load one protocol's JSON AST file (built by
//// `scripts/build-protocol-test-asts.sh`) into typed `ProtocolTests`.
////
//// The AST is plain Smithy 2.0 JSON. Operations carry their request /
//// response cases under `traits["smithy.test#httpRequestTests"]` /
//// `["smithy.test#httpResponseTests"]`. Error structures (marked with
//// `smithy.api#error`) carry response cases under the same trait key.
////
//// `params` and `vendorParams` get preserved as serialised JSON so the
//// runner can compare them structurally against whatever the generated
//// deserialiser produces without re-deciding their shape.

import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode.{type Decoder}
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import protocol_tests/cases.{
  type ErrorTests, type OperationTests, type ProtocolTests, type RequestCase,
  type ResponseCase, AppliesToBoth, AppliesToClient, AppliesToServer, ErrorTests,
  OperationTests, ProtocolTests, RequestCase, ResponseCase,
}
import simplifile

pub type LoadError {
  /// The fixture file could not be opened.
  CannotRead(path: String)
  /// JSON couldn't be parsed at all.
  InvalidJson(reason: String)
  /// Required top-level field missing.
  MalformedAst(reason: String)
}

pub fn load(path: String, protocol_name: String) -> Result(ProtocolTests, LoadError) {
  use text <- result.try(
    simplifile.read(path) |> result.replace_error(CannotRead(path: path)),
  )
  use raw <- result.try(
    json.parse(text, top_decoder())
    |> result.map_error(fn(_) { InvalidJson(reason: "could not parse " <> path) }),
  )
  Ok(walk(raw, protocol_name))
}

// ---------- minimal AST view ----------

/// We don't need the full Smithy shape graph here — just `shape_id` →
/// (type, traits-blob). That keeps the loader tolerant of new shape
/// types that the protocol-tests model might pick up in future submodule
/// bumps.
type RawShape {
  RawShape(type_: String, traits: Dict(String, Dynamic))
}

type RawModel {
  RawModel(shapes: Dict(String, RawShape))
}

fn top_decoder() -> Decoder(RawModel) {
  use shapes <- decode.field(
    "shapes",
    decode.dict(decode.string, raw_shape_decoder()),
  )
  decode.success(RawModel(shapes: shapes))
}

fn raw_shape_decoder() -> Decoder(RawShape) {
  use type_ <- decode.field("type", decode.string)
  use traits <- decode.optional_field(
    "traits",
    dict.new(),
    decode.dict(decode.string, decode.dynamic),
  )
  decode.success(RawShape(type_: type_, traits: traits))
}

// ---------- walk ----------

fn walk(raw: RawModel, protocol_name: String) -> ProtocolTests {
  let pairs = dict.to_list(raw.shapes)
  let operations =
    pairs
    |> list.filter_map(fn(pair) {
      let #(id, shape) = pair
      case shape.type_ {
        "operation" -> Ok(walk_operation(id, shape))
        _ -> Error(Nil)
      }
    })
    |> list.filter(fn(op) {
      // Keep only operations that have at least one case (saves noise
      // for ops that are referenced but have no test trait applied).
      list.length(op.request_cases) + list.length(op.response_cases) > 0
    })
  let errors =
    pairs
    |> list.filter_map(fn(pair) {
      let #(id, shape) = pair
      case shape.type_ {
        "structure" ->
          case dict.has_key(shape.traits, "smithy.api#error") {
            True -> walk_error(id, shape)
            False -> Error(Nil)
          }
        _ -> Error(Nil)
      }
    })
  ProtocolTests(
    protocol_name: protocol_name,
    operations: operations,
    errors: errors,
  )
}

fn walk_operation(id: String, shape: RawShape) -> OperationTests {
  let req_cases = case dict.get(shape.traits, "smithy.test#httpRequestTests") {
    Ok(d) -> decode_request_cases(d)
    Error(_) -> []
  }
  let resp_cases = case dict.get(shape.traits, "smithy.test#httpResponseTests")
  {
    Ok(d) -> decode_response_cases(d)
    Error(_) -> []
  }
  OperationTests(
    operation_id: id,
    request_cases: req_cases,
    response_cases: resp_cases,
  )
}

fn walk_error(id: String, shape: RawShape) -> Result(ErrorTests, Nil) {
  case dict.get(shape.traits, "smithy.test#httpResponseTests") {
    Ok(d) ->
      case decode_response_cases(d) {
        [] -> Error(Nil)
        cases -> Ok(ErrorTests(error_id: id, response_cases: cases))
      }
    Error(_) -> Error(Nil)
  }
}

// ---------- case decoding ----------

fn decode_request_cases(value: Dynamic) -> List(RequestCase) {
  case decode.run(value, decode.list(request_case_decoder())) {
    Ok(cs) -> cs
    Error(_) -> []
  }
}

fn decode_response_cases(value: Dynamic) -> List(ResponseCase) {
  case decode.run(value, decode.list(response_case_decoder())) {
    Ok(cs) -> cs
    Error(_) -> []
  }
}

fn request_case_decoder() -> Decoder(RequestCase) {
  use id <- decode.field("id", decode.string)
  use protocol <- decode.field("protocol", decode.string)
  use method <- decode.field("method", decode.string)
  use uri <- decode.field("uri", decode.string)
  use documentation <- decode.optional_field(
    "documentation",
    None,
    decode.optional(decode.string),
  )
  use host <- decode.optional_field(
    "host",
    None,
    decode.optional(decode.string),
  )
  use resolved_host <- decode.optional_field(
    "resolvedHost",
    None,
    decode.optional(decode.string),
  )
  use headers <- decode.optional_field(
    "headers",
    dict.new(),
    decode.dict(decode.string, decode.string),
  )
  use require_headers <- decode.optional_field(
    "requireHeaders",
    [],
    decode.list(decode.string),
  )
  use forbid_headers <- decode.optional_field(
    "forbidHeaders",
    [],
    decode.list(decode.string),
  )
  use query_params <- decode.optional_field(
    "queryParams",
    [],
    decode.list(decode.string),
  )
  use forbid_query_params <- decode.optional_field(
    "forbidQueryParams",
    [],
    decode.list(decode.string),
  )
  use require_query_params <- decode.optional_field(
    "requireQueryParams",
    [],
    decode.list(decode.string),
  )
  use body <- decode.optional_field(
    "body",
    None,
    decode.optional(decode.string),
  )
  use body_media_type <- decode.optional_field(
    "bodyMediaType",
    None,
    decode.optional(decode.string),
  )
  use params <- decode.optional_field(
    "params",
    None,
    json_blob_decoder(),
  )
  use applies_to <- applies_to_field()
  decode.success(RequestCase(
    id: id,
    documentation: documentation,
    protocol: protocol,
    method: method,
    uri: uri,
    host: host,
    resolved_host: resolved_host,
    headers: headers,
    require_headers: require_headers,
    forbid_headers: forbid_headers,
    query_params: query_params,
    forbid_query_params: forbid_query_params,
    require_query_params: require_query_params,
    body: body,
    body_media_type: body_media_type,
    params: params,
    applies_to: applies_to,
  ))
}

fn response_case_decoder() -> Decoder(ResponseCase) {
  use id <- decode.field("id", decode.string)
  use protocol <- decode.field("protocol", decode.string)
  use code <- decode.field("code", decode.int)
  use documentation <- decode.optional_field(
    "documentation",
    None,
    decode.optional(decode.string),
  )
  use headers <- decode.optional_field(
    "headers",
    dict.new(),
    decode.dict(decode.string, decode.string),
  )
  use require_headers <- decode.optional_field(
    "requireHeaders",
    [],
    decode.list(decode.string),
  )
  use forbid_headers <- decode.optional_field(
    "forbidHeaders",
    [],
    decode.list(decode.string),
  )
  use body <- decode.optional_field(
    "body",
    None,
    decode.optional(decode.string),
  )
  use body_media_type <- decode.optional_field(
    "bodyMediaType",
    None,
    decode.optional(decode.string),
  )
  use params <- decode.optional_field(
    "params",
    None,
    json_blob_decoder(),
  )
  use applies_to <- applies_to_field()
  decode.success(ResponseCase(
    id: id,
    documentation: documentation,
    protocol: protocol,
    code: code,
    headers: headers,
    require_headers: require_headers,
    forbid_headers: forbid_headers,
    body: body,
    body_media_type: body_media_type,
    params: params,
    applies_to: applies_to,
  ))
}

/// `appliesTo` is "client", "server", or absent. We map absent →
/// `AppliesToBoth` so the runner gets to decide.
fn applies_to_field(
  k: fn(cases.AppliesTo) -> Decoder(t),
) -> Decoder(t) {
  use a <- decode.optional_field(
    "appliesTo",
    AppliesToBoth,
    applies_to_decoder(),
  )
  k(a)
}

fn applies_to_decoder() -> Decoder(cases.AppliesTo) {
  decode.then(decode.string, fn(s) {
    case s {
      "client" -> decode.success(AppliesToClient)
      "server" -> decode.success(AppliesToServer)
      _ -> decode.success(AppliesToBoth)
    }
  })
}

/// `params` is an arbitrary JSON object. For the MVP runner we only need
/// to know whether it was provided; deep params comparison happens at the
/// generated-code dispatch site, where the emitter can decode them into
/// the typed input. Returning `Some("present")` keeps the field shape
/// stable; the runner is responsible for re-fetching the underlying JSON
/// if it needs structural comparison.
fn json_blob_decoder() -> Decoder(Option(String)) {
  decode.then(decode.optional(decode.dynamic), fn(opt) {
    case opt {
      None -> decode.success(None)
      Some(_) -> decode.success(Some("present"))
    }
  })
}
