//// Smithy `@httpRequestTests` and `@httpResponseTests` case types.
////
//// One-to-one with the [Smithy protocol-test
//// specification](https://smithy.io/2.0/additional-specs/http-protocol-compliance-tests.html#httprequesttests-trait).
//// All fields except the required ones are `Option(t)`. The runner reads
//// only the fields it knows how to assert; unknown vendor fields are
//// preserved on the original JSON for debugging.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option}

/// `appliesTo` controls whether the case is for client SDKs, server
/// implementations, or both. We're building a client; server-only cases
/// are skipped with a documented reason.
pub type AppliesTo {
  AppliesToClient
  AppliesToServer
  AppliesToBoth
}

/// One `@httpRequestTests` case. Drives the request-side codepath: given
/// `params`, the generated client must produce `method` + `uri` +
/// `headers` + `query` + `body` matching the expected values.
pub type RequestCase {
  RequestCase(
    id: String,
    documentation: Option(String),
    protocol: String,
    method: String,
    uri: String,
    host: Option(String),
    resolved_host: Option(String),
    headers: Dict(String, String),
    require_headers: List(String),
    forbid_headers: List(String),
    query_params: List(String),
    forbid_query_params: List(String),
    require_query_params: List(String),
    body: Option(String),
    body_media_type: Option(String),
    params: Option(String),
    applies_to: AppliesTo,
  )
}

/// One `@httpResponseTests` case. Drives the response-side codepath:
/// given the raw response bytes / status / headers, the generated
/// client must deserialize them to a struct equivalent to `params`.
pub type ResponseCase {
  ResponseCase(
    id: String,
    documentation: Option(String),
    protocol: String,
    code: Int,
    headers: Dict(String, String),
    require_headers: List(String),
    forbid_headers: List(String),
    body: Option(String),
    body_media_type: Option(String),
    params: Option(String),
    applies_to: AppliesTo,
  )
}

/// All test cases for a single operation in a Smithy model.
pub type OperationTests {
  OperationTests(
    operation_id: String,
    request_cases: List(RequestCase),
    response_cases: List(ResponseCase),
  )
}

/// All test cases for a single error structure. Each error case asserts
/// that the generated client maps the canned response bytes to the right
/// typed error variant (with `params` describing the expected field
/// values).
pub type ErrorTests {
  ErrorTests(error_id: String, response_cases: List(ResponseCase))
}

/// All tests extracted from one protocol's JSON AST file.
pub type ProtocolTests {
  ProtocolTests(
    protocol_name: String,
    operations: List(OperationTests),
    errors: List(ErrorTests),
  )
}

/// Quick counts used by the runner's summary line.
pub type CaseCounts {
  CaseCounts(request: Int, response: Int, error_response: Int)
}

pub fn counts(tests: ProtocolTests) -> CaseCounts {
  let req =
    list.fold(tests.operations, 0, fn(acc, op) {
      acc + list.length(op.request_cases)
    })
  let resp =
    list.fold(tests.operations, 0, fn(acc, op) {
      acc + list.length(op.response_cases)
    })
  let err_resp =
    list.fold(tests.errors, 0, fn(acc, e) {
      acc + list.length(e.response_cases)
    })
  CaseCounts(request: req, response: resp, error_response: err_resp)
}
