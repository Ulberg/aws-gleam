//// Wire generated awsJson1_1 operations into the dispatcher registry.
//// See `awsjson10_dispatchers.gleam` for the pattern; this file is
//// near-identical, modulo the content-type header and target prefix.

import aws/services/protocoltests/json11
import protocol_tests/dispatch.{
  type Dispatcher, type ParsedResponseInput, type Registry, BuiltRequest,
  Dispatcher, ParsedOutput,
}

pub fn register_all(registry: Registry) -> Registry {
  registry
  |> dispatch.register(empty_operation())
  |> dispatch.register(endpoint_operation())
  |> dispatch.register(host_with_path_operation())
}

fn empty_operation() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json#EmptyOperation",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json11.build_empty_operation_request(json11.EmptyOperationInput)
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(json11.parse_empty_operation_response),
  )
}

fn endpoint_operation() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json#EndpointOperation",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json11.build_endpoint_operation_request(json11.EndpointOperationInput)
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json11.parse_endpoint_operation_response,
    ),
  )
}

fn host_with_path_operation() -> Dispatcher {
  Dispatcher(
    operation_id: "aws.protocoltests.json#HostWithPathOperation",
    build_request: fn(_params) {
      let #(method, uri, headers, body) =
        json11.build_host_with_path_operation_request(
          json11.HostWithPathOperationInput,
        )
      Ok(BuiltRequest(method: method, uri: uri, headers: headers, body: body))
    },
    parse_response: empty_response_parser(
      json11.parse_host_with_path_operation_response,
    ),
  )
}

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
