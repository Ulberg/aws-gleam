//// Generated from aws.protocoltests.restxml#RestXml (restXml).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import gleam/dict

pub type DatetimeOffsetsInput {
  DatetimeOffsetsInput
}

pub type DatetimeOffsetsOutput {
  DatetimeOffsetsOutput
}

pub fn build_datetime_offsets_request(
  _input: DatetimeOffsetsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/DatetimeOffsets", dict.new(), <<>>)
}

pub fn parse_datetime_offsets_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(DatetimeOffsetsOutput, String) {
  Ok(DatetimeOffsetsOutput)
}

pub type EmptyInputAndEmptyOutputInput {
  EmptyInputAndEmptyOutputInput
}

pub type EmptyInputAndEmptyOutputOutput {
  EmptyInputAndEmptyOutputOutput
}

pub fn build_empty_input_and_empty_output_request(
  _input: EmptyInputAndEmptyOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/EmptyInputAndEmptyOutput", dict.new(), <<>>)
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
  #("POST", "/EndpointOperation", dict.new(), <<>>)
}

pub fn parse_endpoint_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointOperationOutput, String) {
  Ok(EndpointOperationOutput)
}

pub type FlattenedXmlMapWithXmlNamespaceInput {
  FlattenedXmlMapWithXmlNamespaceInput
}

pub type FlattenedXmlMapWithXmlNamespaceOutput {
  FlattenedXmlMapWithXmlNamespaceOutput
}

pub fn build_flattened_xml_map_with_xml_namespace_request(
  _input: FlattenedXmlMapWithXmlNamespaceInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/FlattenedXmlMapWithXmlNamespace", dict.new(), <<>>)
}

pub fn parse_flattened_xml_map_with_xml_namespace_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(FlattenedXmlMapWithXmlNamespaceOutput, String) {
  Ok(FlattenedXmlMapWithXmlNamespaceOutput)
}

pub type FractionalSecondsInput {
  FractionalSecondsInput
}

pub type FractionalSecondsOutput {
  FractionalSecondsOutput
}

pub fn build_fractional_seconds_request(
  _input: FractionalSecondsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/FractionalSeconds", dict.new(), <<>>)
}

pub fn parse_fractional_seconds_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(FractionalSecondsOutput, String) {
  Ok(FractionalSecondsOutput)
}

pub type GreetingWithErrorsInput {
  GreetingWithErrorsInput
}

pub type GreetingWithErrorsOutput {
  GreetingWithErrorsOutput
}

pub fn build_greeting_with_errors_request(
  _input: GreetingWithErrorsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("PUT", "/GreetingWithErrors", dict.new(), <<>>)
}

pub fn parse_greeting_with_errors_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(GreetingWithErrorsOutput, String) {
  Ok(GreetingWithErrorsOutput)
}

pub type HttpResponseCodeInput {
  HttpResponseCodeInput
}

pub type HttpResponseCodeOutput {
  HttpResponseCodeOutput
}

pub fn build_http_response_code_request(
  _input: HttpResponseCodeInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("PUT", "/HttpResponseCode", dict.new(), <<>>)
}

pub fn parse_http_response_code_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HttpResponseCodeOutput, String) {
  Ok(HttpResponseCodeOutput)
}

pub type IgnoreQueryParamsInResponseInput {
  IgnoreQueryParamsInResponseInput
}

pub type IgnoreQueryParamsInResponseOutput {
  IgnoreQueryParamsInResponseOutput
}

pub fn build_ignore_query_params_in_response_request(
  _input: IgnoreQueryParamsInResponseInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("GET", "/IgnoreQueryParamsInResponse", dict.new(), <<>>)
}

pub fn parse_ignore_query_params_in_response_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(IgnoreQueryParamsInResponseOutput, String) {
  Ok(IgnoreQueryParamsInResponseOutput)
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
  #("POST", "/NoInputAndNoOutput", dict.new(), <<>>)
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
  #("POST", "/NoInputAndOutputOutput", dict.new(), <<>>)
}

pub fn parse_no_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(NoInputAndOutputOutput, String) {
  Ok(NoInputAndOutputOutput)
}
