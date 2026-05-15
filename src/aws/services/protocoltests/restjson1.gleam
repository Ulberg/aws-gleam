//// Generated from aws.protocoltests.restjson#RestJson (restJson1).
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

pub type HostWithPathOperationInput {
  HostWithPathOperationInput
}

pub type HostWithPathOperationOutput {
  HostWithPathOperationOutput
}

pub fn build_host_with_path_operation_request(
  _input: HostWithPathOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("GET", "/HostWithPathOperation", dict.new(), <<>>)
}

pub fn parse_host_with_path_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HostWithPathOperationOutput, String) {
  Ok(HostWithPathOperationOutput)
}

pub type HttpPrefixHeadersInResponseInput {
  HttpPrefixHeadersInResponseInput
}

pub type HttpPrefixHeadersInResponseOutput {
  HttpPrefixHeadersInResponseOutput
}

pub fn build_http_prefix_headers_in_response_request(
  _input: HttpPrefixHeadersInResponseInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("GET", "/HttpPrefixHeadersResponse", dict.new(), <<>>)
}

pub fn parse_http_prefix_headers_in_response_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HttpPrefixHeadersInResponseOutput, String) {
  Ok(HttpPrefixHeadersInResponseOutput)
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

pub type MalformedAcceptWithBodyInput {
  MalformedAcceptWithBodyInput
}

pub type MalformedAcceptWithBodyOutput {
  MalformedAcceptWithBodyOutput
}

pub fn build_malformed_accept_with_body_request(
  _input: MalformedAcceptWithBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/MalformedAcceptWithBody", dict.new(), <<>>)
}

pub fn parse_malformed_accept_with_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(MalformedAcceptWithBodyOutput, String) {
  Ok(MalformedAcceptWithBodyOutput)
}

pub type MalformedAcceptWithGenericStringInput {
  MalformedAcceptWithGenericStringInput
}

pub type MalformedAcceptWithGenericStringOutput {
  MalformedAcceptWithGenericStringOutput
}

pub fn build_malformed_accept_with_generic_string_request(
  _input: MalformedAcceptWithGenericStringInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/MalformedAcceptWithGenericString", dict.new(), <<>>)
}

pub fn parse_malformed_accept_with_generic_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(MalformedAcceptWithGenericStringOutput, String) {
  Ok(MalformedAcceptWithGenericStringOutput)
}

pub type MalformedAcceptWithPayloadInput {
  MalformedAcceptWithPayloadInput
}

pub type MalformedAcceptWithPayloadOutput {
  MalformedAcceptWithPayloadOutput
}

pub fn build_malformed_accept_with_payload_request(
  _input: MalformedAcceptWithPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/MalformedAcceptWithPayload", dict.new(), <<>>)
}

pub fn parse_malformed_accept_with_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(MalformedAcceptWithPayloadOutput, String) {
  Ok(MalformedAcceptWithPayloadOutput)
}

pub type MalformedContentTypeWithoutBodyInput {
  MalformedContentTypeWithoutBodyInput
}

pub type MalformedContentTypeWithoutBodyOutput {
  MalformedContentTypeWithoutBodyOutput
}

pub fn build_malformed_content_type_without_body_request(
  _input: MalformedContentTypeWithoutBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/MalformedContentTypeWithoutBody", dict.new(), <<>>)
}

pub fn parse_malformed_content_type_without_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(MalformedContentTypeWithoutBodyOutput, String) {
  Ok(MalformedContentTypeWithoutBodyOutput)
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

pub type OutputStreamInput {
  OutputStreamInput
}

pub type OutputStreamOutput {
  OutputStreamOutput
}

pub fn build_output_stream_request(
  _input: OutputStreamInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/OutputStream", dict.new(), <<>>)
}

pub fn parse_output_stream_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(OutputStreamOutput, String) {
  Ok(OutputStreamOutput)
}

pub type OutputStreamWithInitialResponseInput {
  OutputStreamWithInitialResponseInput
}

pub type OutputStreamWithInitialResponseOutput {
  OutputStreamWithInitialResponseOutput
}

pub fn build_output_stream_with_initial_response_request(
  _input: OutputStreamWithInitialResponseInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/OutputStreamWithInitialResponse", dict.new(), <<>>)
}

pub fn parse_output_stream_with_initial_response_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(OutputStreamWithInitialResponseOutput, String) {
  Ok(OutputStreamWithInitialResponseOutput)
}

pub type ResponseCodeHttpFallbackInput {
  ResponseCodeHttpFallbackInput
}

pub type ResponseCodeHttpFallbackOutput {
  ResponseCodeHttpFallbackOutput
}

pub fn build_response_code_http_fallback_request(
  _input: ResponseCodeHttpFallbackInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("GET", "/responseCodeHttpFallback", dict.new(), <<>>)
}

pub fn parse_response_code_http_fallback_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(ResponseCodeHttpFallbackOutput, String) {
  Ok(ResponseCodeHttpFallbackOutput)
}

pub type ResponseCodeRequiredInput {
  ResponseCodeRequiredInput
}

pub type ResponseCodeRequiredOutput {
  ResponseCodeRequiredOutput
}

pub fn build_response_code_required_request(
  _input: ResponseCodeRequiredInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("GET", "/responseCodeRequired", dict.new(), <<>>)
}

pub fn parse_response_code_required_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(ResponseCodeRequiredOutput, String) {
  Ok(ResponseCodeRequiredOutput)
}

pub type TestGetNoInputNoPayloadInput {
  TestGetNoInputNoPayloadInput
}

pub type TestGetNoInputNoPayloadOutput {
  TestGetNoInputNoPayloadOutput
}

pub fn build_test_get_no_input_no_payload_request(
  _input: TestGetNoInputNoPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("GET", "/no_input_no_payload", dict.new(), <<>>)
}

pub fn parse_test_get_no_input_no_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(TestGetNoInputNoPayloadOutput, String) {
  Ok(TestGetNoInputNoPayloadOutput)
}

pub type TestPostNoInputNoPayloadInput {
  TestPostNoInputNoPayloadInput
}

pub type TestPostNoInputNoPayloadOutput {
  TestPostNoInputNoPayloadOutput
}

pub fn build_test_post_no_input_no_payload_request(
  _input: TestPostNoInputNoPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/no_input_no_payload", dict.new(), <<>>)
}

pub fn parse_test_post_no_input_no_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(TestPostNoInputNoPayloadOutput, String) {
  Ok(TestPostNoInputNoPayloadOutput)
}

pub type UnitInputAndOutputInput {
  UnitInputAndOutputInput
}

pub type UnitInputAndOutputOutput {
  UnitInputAndOutputOutput
}

pub fn build_unit_input_and_output_request(
  _input: UnitInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/UnitInputAndOutput", dict.new(), <<>>)
}

pub fn parse_unit_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(UnitInputAndOutputOutput, String) {
  Ok(UnitInputAndOutputOutput)
}
