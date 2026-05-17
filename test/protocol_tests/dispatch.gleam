//// Dispatcher registry.
////
//// Each generated client registers itself with the runner: a name
//// (operation Smithy ID) plus two callbacks:
////
////   - `build_request`: given the case's `params` JSON, produce the
////     concrete HTTP request the client would send.
////   - `parse_response`: given the case's canned response bytes, parse
////     them into either the operation's typed output or one of its
////     error variants.
////
//// Until M5.3 emits any code, the registry is empty and every case
//// reports `NoDispatcher` — i.e., the runner counts the test toward
//// "pending" coverage rather than failing the suite. That's the
//// failing-baseline-to-grow-from for the upcoming codegen work.

import gleam/dict.{type Dict}

/// The runner asks each dispatcher to perform one of two operations.
/// We model them as separate callbacks because not every operation will
/// support both directions at first; a partial registration is fine.
pub type Dispatcher {
  Dispatcher(
    operation_id: String,
    build_request: BuildRequest,
    parse_response: ParseResponse,
  )
}

/// `params_json` is the raw JSON string for the case's `params`. The
/// dispatcher must decode it into the typed input shape and produce the
/// outgoing HTTP request.
pub type BuildRequest =
  fn(String) -> Result(BuiltRequest, String)

pub type ParseResponse =
  fn(ParsedResponseInput) -> Result(ParsedResponse, String)

pub type BuiltRequest {
  BuiltRequest(
    method: String,
    uri: String,
    headers: Dict(String, String),
    body: BitArray,
  )
}

pub type ParsedResponseInput {
  ParsedResponseInput(code: Int, headers: Dict(String, String), body: BitArray)
}

/// Parsed-output shape: either the operation's typed output (serialised
/// back to JSON for the runner's structural comparison) or a typed error
/// variant identified by its Smithy shape ID.
pub type ParsedResponse {
  ParsedOutput(json: String)
  ParsedError(error_id: String, json: String)
}

pub opaque type Registry {
  Registry(by_operation: Dict(String, Dispatcher))
}

pub fn new() -> Registry {
  Registry(by_operation: dict.new())
}

pub fn register(registry: Registry, dispatcher: Dispatcher) -> Registry {
  Registry(by_operation: dict.insert(
    registry.by_operation,
    dispatcher.operation_id,
    dispatcher,
  ))
}

pub fn lookup(
  registry: Registry,
  operation_id: String,
) -> Result(Dispatcher, Nil) {
  dict.get(registry.by_operation, operation_id)
}
