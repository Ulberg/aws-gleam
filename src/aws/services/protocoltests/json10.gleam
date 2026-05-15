//// Generated from aws.protocoltests.json10#JsonRpc10 (awsJson1_0).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import gleam/dict

pub type EmptyInputAndEmptyOutputInput {
  EmptyInputAndEmptyOutputInput
}

pub type EmptyInputAndEmptyOutputOutput {
  EmptyInputAndEmptyOutputOutput
}

pub fn build_empty_input_and_empty_output_request(
  _input: EmptyInputAndEmptyOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.EmptyInputAndEmptyOutput"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_empty_input_and_empty_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  Ok(EmptyInputAndEmptyOutputOutput)
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
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.EndpointOperation"),
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
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.HostWithPathOperation"),
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

pub type NoInputAndNoOutputInput {
  NoInputAndNoOutputInput
}

pub type NoInputAndNoOutputOutput {
  NoInputAndNoOutputOutput
}

pub fn build_no_input_and_no_output_request(
  _input: NoInputAndNoOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.NoInputAndNoOutput"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_no_input_and_no_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(NoInputAndNoOutputOutput, String) {
  Ok(NoInputAndNoOutputOutput)
}

pub type NoInputAndOutputInput {
  NoInputAndOutputInput
}

pub type NoInputAndOutputOutput {
  NoInputAndOutputOutput
}

pub fn build_no_input_and_output_request(
  _input: NoInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.NoInputAndOutput"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_no_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(NoInputAndOutputOutput, String) {
  Ok(NoInputAndOutputOutput)
}

pub type OperationWithRequiredMembersInput {
  OperationWithRequiredMembersInput
}

pub type OperationWithRequiredMembersOutput {
  OperationWithRequiredMembersOutput
}

pub fn build_operation_with_required_members_request(
  _input: OperationWithRequiredMembersInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.OperationWithRequiredMembers"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_operation_with_required_members_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(OperationWithRequiredMembersOutput, String) {
  Ok(OperationWithRequiredMembersOutput)
}

pub type OperationWithRequiredMembersWithDefaultsInput {
  OperationWithRequiredMembersWithDefaultsInput
}

pub type OperationWithRequiredMembersWithDefaultsOutput {
  OperationWithRequiredMembersWithDefaultsOutput
}

pub fn build_operation_with_required_members_with_defaults_request(
  _input: OperationWithRequiredMembersWithDefaultsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.OperationWithRequiredMembersWithDefaults"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_operation_with_required_members_with_defaults_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(OperationWithRequiredMembersWithDefaultsOutput, String) {
  Ok(OperationWithRequiredMembersWithDefaultsOutput)
}

pub type QueryIncompatibleOperationInput {
  QueryIncompatibleOperationInput
}

pub type QueryIncompatibleOperationOutput {
  QueryIncompatibleOperationOutput
}

pub fn build_query_incompatible_operation_request(
  _input: QueryIncompatibleOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.QueryIncompatibleOperation"),
    ])
  #("POST", "/", headers, <<"{}">>)
}

pub fn parse_query_incompatible_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(QueryIncompatibleOperationOutput, String) {
  Ok(QueryIncompatibleOperationOutput)
}
