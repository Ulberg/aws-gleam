//// Wire generated awsJson1_0 operations into the protocol-test
//// dispatcher registry. One entry per operation: the dispatcher's
//// `build_request` calls the codegen-emitted `build_*_request` with the
//// unit input; `parse_response` calls the emitted `parse_*_response`
//// and reports back the typed Result.
////
//// As the emitter grows new operation shapes, this file is the single
//// place where the dispatch table widens. Once the emitter learns to
//// register operations itself (e.g. via a generated registry list), we
//// fold this file into the generated module.

import aws/services/protocoltests/json10
import protocol_tests/dispatch.{
  type Dispatcher, type ParsedResponseInput, type Registry, BuiltRequest,
  Dispatcher, ParsedOutput,
}

pub fn register_all(registry: Registry) -> Registry {
  registry
  |> dispatch.register(empty_input_and_empty_output())
  |> dispatch.register(endpoint_operation())
  |> dispatch.register(host_with_path_operation())
  |> dispatch.register(no_input_and_no_output())
  |> dispatch.register(no_input_and_output())
  |> dispatch.register(operation_with_required_members())
  |> dispatch.register(operation_with_required_members_with_defaults())
  |> dispatch.register(query_incompatible_operation())
}

fn empty_input_and_empty_output() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#EmptyInputAndEmptyOutput",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_empty_input_and_empty_output_request(
          json10.EmptyInputAndEmptyOutputInput,
        )
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_empty_input_and_empty_output_response,
    ),
  )
}

fn endpoint_operation() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#EndpointOperation",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_endpoint_operation_request(json10.EndpointOperationInput)
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_endpoint_operation_response,
    ),
  )
}

fn host_with_path_operation() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#HostWithPathOperation",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_host_with_path_operation_request(
          json10.HostWithPathOperationInput,
        )
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_host_with_path_operation_response,
    ),
  )
}

fn no_input_and_no_output() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#NoInputAndNoOutput",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_no_input_and_no_output_request(
          json10.NoInputAndNoOutputInput,
        )
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_no_input_and_no_output_response,
    ),
  )
}

fn no_input_and_output() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#NoInputAndOutput",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_no_input_and_output_request(json10.NoInputAndOutputInput)
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_no_input_and_output_response,
    ),
  )
}

fn operation_with_required_members() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#OperationWithRequiredMembers",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_operation_with_required_members_request(
          json10.OperationWithRequiredMembersInput,
        )
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_operation_with_required_members_response,
    ),
  )
}

fn operation_with_required_members_with_defaults() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#OperationWithRequiredMembersWithDefaults",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_operation_with_required_members_with_defaults_request(
          json10.OperationWithRequiredMembersWithDefaultsInput,
        )
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_operation_with_required_members_with_defaults_response,
    ),
  )
}

fn query_incompatible_operation() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json10#QueryIncompatibleOperation",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json10.build_query_incompatible_operation_request(
          json10.QueryIncompatibleOperationInput,
        )
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json10.parse_query_incompatible_operation_response,
    ),
  )
}

/// Shared parse-response adapter for empty-output operations. The
/// generated `parse_*_response` returns Result(<typed output>, String);
/// the runner doesn't compare params yet so we just report success or
/// error.
fn empty_response_parser(
  parser: fn(Int, _, BitArray) -> Result(_, String),
) -> fn(ParsedResponseInput) -> Result(dispatch.ParsedResponse, String) {
  fn(input: ParsedResponseInput) {
    case parser(input.code, input.headers, input.body) {
      Ok(_) -> Ok(ParsedOutput(json: "{}"))
      Error(e) -> Error(e)
    }
  }
}
