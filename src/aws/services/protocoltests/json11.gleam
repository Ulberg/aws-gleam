//// Generated from aws.protocoltests.json#JsonProtocol (awsJson1_1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import gleam/dict

pub type EmptyOperationInput {
  EmptyOperationInput
}

pub type EmptyOperationOutput {
  EmptyOperationOutput
}

pub fn build_empty_operation_request(
  _input: EmptyOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.EmptyOperation"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_empty_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EmptyOperationOutput, String) {
  Ok(EmptyOperationOutput)
}

pub type EndpointOperationInput {
  EndpointOperationInput
}

pub type EndpointOperationOutput {
  EndpointOperationOutput
}

pub fn build_endpoint_operation_request(
  _input: EndpointOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.EndpointOperation"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_endpoint_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointOperationOutput, String) {
  Ok(EndpointOperationOutput)
}

pub type HostWithPathOperationInput {
  HostWithPathOperationInput
}

pub type HostWithPathOperationOutput {
  HostWithPathOperationOutput
}

pub fn build_host_with_path_operation_request(
  _input: HostWithPathOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.HostWithPathOperation"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_host_with_path_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HostWithPathOperationOutput, String) {
  Ok(HostWithPathOperationOutput)
}
