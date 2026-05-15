//// Generated from aws.protocoltests.restjson#RestJson (restJson1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/internal/codec/json_float
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option

pub type ContentTypeParametersInput {
  ContentTypeParametersInput(value: option.Option(Int))
}

pub type ContentTypeParametersOutput {
  ContentTypeParametersOutput
}

pub fn encode_content_type_parameters_input(
  input: ContentTypeParametersInput,
) -> String {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("value", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_content_type_parameters_input(
  body: String,
) -> Result(ContentTypeParametersInput, String) {
  let dec = {
    use value <- decode.optional_field(
      "value",
      option.None,
      decode.optional(decode.int),
    )
    decode.success(ContentTypeParametersInput(value: value))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_content_type_parameters_output(
  _body: String,
) -> Result(ContentTypeParametersOutput, String) {
  Ok(ContentTypeParametersOutput)
}

pub fn build_content_type_parameters_request(
  input: ContentTypeParametersInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_content_type_parameters_input(input)
  let headers = dict.from_list([#("Content-Type", "application/json")])
  #("POST", "/ContentTypeParameters", headers, bit_array.from_string(body_str))
}

pub fn parse_content_type_parameters_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(ContentTypeParametersOutput, String) {
  Ok(ContentTypeParametersOutput)
}

pub type DatetimeOffsetsInput {
  DatetimeOffsetsInput
}

pub type DatetimeOffsetsOutput {
  DatetimeOffsetsOutput
}

pub fn encode_datetime_offsets_input(_input: DatetimeOffsetsInput) -> String {
  ""
}

pub fn decode_datetime_offsets_input(
  _body: String,
) -> Result(DatetimeOffsetsInput, String) {
  Ok(DatetimeOffsetsInput)
}

pub fn decode_datetime_offsets_output(
  _body: String,
) -> Result(DatetimeOffsetsOutput, String) {
  Ok(DatetimeOffsetsOutput)
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

pub fn encode_empty_input_and_empty_output_input(
  _input: EmptyInputAndEmptyOutputInput,
) -> String {
  ""
}

pub fn decode_empty_input_and_empty_output_input(
  _body: String,
) -> Result(EmptyInputAndEmptyOutputInput, String) {
  Ok(EmptyInputAndEmptyOutputInput)
}

pub fn decode_empty_input_and_empty_output_output(
  _body: String,
) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  Ok(EmptyInputAndEmptyOutputOutput)
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

pub fn encode_endpoint_operation_input(
  _input: EndpointOperationInput,
) -> String {
  ""
}

pub fn decode_endpoint_operation_input(
  _body: String,
) -> Result(EndpointOperationInput, String) {
  Ok(EndpointOperationInput)
}

pub fn decode_endpoint_operation_output(
  _body: String,
) -> Result(EndpointOperationOutput, String) {
  Ok(EndpointOperationOutput)
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

pub type EndpointWithHostLabelOperationInput {
  EndpointWithHostLabelOperationInput(label: option.Option(String))
}

pub type EndpointWithHostLabelOperationOutput {
  EndpointWithHostLabelOperationOutput
}

pub fn encode_endpoint_with_host_label_operation_input(
  input: EndpointWithHostLabelOperationInput,
) -> String {
  let pairs = []
  let pairs = case input.label {
    option.Some(v) -> [#("label", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_endpoint_with_host_label_operation_input(
  body: String,
) -> Result(EndpointWithHostLabelOperationInput, String) {
  let dec = {
    use label <- decode.optional_field(
      "label",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(EndpointWithHostLabelOperationInput(label: label))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_endpoint_with_host_label_operation_output(
  _body: String,
) -> Result(EndpointWithHostLabelOperationOutput, String) {
  Ok(EndpointWithHostLabelOperationOutput)
}

pub fn build_endpoint_with_host_label_operation_request(
  input: EndpointWithHostLabelOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_endpoint_with_host_label_operation_input(input)
  let headers = dict.from_list([#("Content-Type", "application/json")])
  #(
    "POST",
    "/EndpointWithHostLabelOperation",
    headers,
    bit_array.from_string(body_str),
  )
}

pub fn parse_endpoint_with_host_label_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointWithHostLabelOperationOutput, String) {
  Ok(EndpointWithHostLabelOperationOutput)
}

pub type FractionalSecondsInput {
  FractionalSecondsInput
}

pub type FractionalSecondsOutput {
  FractionalSecondsOutput
}

pub fn encode_fractional_seconds_input(
  _input: FractionalSecondsInput,
) -> String {
  ""
}

pub fn decode_fractional_seconds_input(
  _body: String,
) -> Result(FractionalSecondsInput, String) {
  Ok(FractionalSecondsInput)
}

pub fn decode_fractional_seconds_output(
  _body: String,
) -> Result(FractionalSecondsOutput, String) {
  Ok(FractionalSecondsOutput)
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

pub fn encode_greeting_with_errors_input(
  _input: GreetingWithErrorsInput,
) -> String {
  ""
}

pub fn decode_greeting_with_errors_input(
  _body: String,
) -> Result(GreetingWithErrorsInput, String) {
  Ok(GreetingWithErrorsInput)
}

pub fn decode_greeting_with_errors_output(
  _body: String,
) -> Result(GreetingWithErrorsOutput, String) {
  Ok(GreetingWithErrorsOutput)
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

pub fn encode_host_with_path_operation_input(
  _input: HostWithPathOperationInput,
) -> String {
  ""
}

pub fn decode_host_with_path_operation_input(
  _body: String,
) -> Result(HostWithPathOperationInput, String) {
  Ok(HostWithPathOperationInput)
}

pub fn decode_host_with_path_operation_output(
  _body: String,
) -> Result(HostWithPathOperationOutput, String) {
  Ok(HostWithPathOperationOutput)
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

pub fn encode_http_prefix_headers_in_response_input(
  _input: HttpPrefixHeadersInResponseInput,
) -> String {
  ""
}

pub fn decode_http_prefix_headers_in_response_input(
  _body: String,
) -> Result(HttpPrefixHeadersInResponseInput, String) {
  Ok(HttpPrefixHeadersInResponseInput)
}

pub fn decode_http_prefix_headers_in_response_output(
  _body: String,
) -> Result(HttpPrefixHeadersInResponseOutput, String) {
  Ok(HttpPrefixHeadersInResponseOutput)
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

pub fn encode_http_response_code_input(
  _input: HttpResponseCodeInput,
) -> String {
  ""
}

pub fn decode_http_response_code_input(
  _body: String,
) -> Result(HttpResponseCodeInput, String) {
  Ok(HttpResponseCodeInput)
}

pub fn decode_http_response_code_output(
  _body: String,
) -> Result(HttpResponseCodeOutput, String) {
  Ok(HttpResponseCodeOutput)
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

pub fn encode_ignore_query_params_in_response_input(
  _input: IgnoreQueryParamsInResponseInput,
) -> String {
  ""
}

pub fn decode_ignore_query_params_in_response_input(
  _body: String,
) -> Result(IgnoreQueryParamsInResponseInput, String) {
  Ok(IgnoreQueryParamsInResponseInput)
}

pub fn decode_ignore_query_params_in_response_output(
  _body: String,
) -> Result(IgnoreQueryParamsInResponseOutput, String) {
  Ok(IgnoreQueryParamsInResponseOutput)
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
  MalformedAcceptWithBodyOutput(hi: option.Option(String))
}

pub fn encode_malformed_accept_with_body_input(
  _input: MalformedAcceptWithBodyInput,
) -> String {
  ""
}

pub fn decode_malformed_accept_with_body_input(
  _body: String,
) -> Result(MalformedAcceptWithBodyInput, String) {
  Ok(MalformedAcceptWithBodyInput)
}

pub fn decode_malformed_accept_with_body_output(
  body: String,
) -> Result(MalformedAcceptWithBodyOutput, String) {
  let dec = {
    use hi <- decode.optional_field(
      "hi",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(MalformedAcceptWithBodyOutput(hi: hi))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_malformed_accept_with_body_request(
  _input: MalformedAcceptWithBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  #("POST", "/MalformedAcceptWithBody", dict.new(), <<>>)
}

pub fn parse_malformed_accept_with_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedAcceptWithBodyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> decode_malformed_accept_with_body_output(text)
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedAcceptWithGenericStringInput {
  MalformedAcceptWithGenericStringInput
}

pub type MalformedAcceptWithGenericStringOutput {
  MalformedAcceptWithGenericStringOutput
}

pub fn encode_malformed_accept_with_generic_string_input(
  _input: MalformedAcceptWithGenericStringInput,
) -> String {
  ""
}

pub fn decode_malformed_accept_with_generic_string_input(
  _body: String,
) -> Result(MalformedAcceptWithGenericStringInput, String) {
  Ok(MalformedAcceptWithGenericStringInput)
}

pub fn decode_malformed_accept_with_generic_string_output(
  _body: String,
) -> Result(MalformedAcceptWithGenericStringOutput, String) {
  Ok(MalformedAcceptWithGenericStringOutput)
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

pub fn encode_malformed_accept_with_payload_input(
  _input: MalformedAcceptWithPayloadInput,
) -> String {
  ""
}

pub fn decode_malformed_accept_with_payload_input(
  _body: String,
) -> Result(MalformedAcceptWithPayloadInput, String) {
  Ok(MalformedAcceptWithPayloadInput)
}

pub fn decode_malformed_accept_with_payload_output(
  _body: String,
) -> Result(MalformedAcceptWithPayloadOutput, String) {
  Ok(MalformedAcceptWithPayloadOutput)
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

pub type MalformedContentTypeWithBodyInput {
  MalformedContentTypeWithBodyInput(hi: option.Option(String))
}

pub type MalformedContentTypeWithBodyOutput {
  MalformedContentTypeWithBodyOutput
}

pub fn encode_malformed_content_type_with_body_input(
  input: MalformedContentTypeWithBodyInput,
) -> String {
  let pairs = []
  let pairs = case input.hi {
    option.Some(v) -> [#("hi", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_malformed_content_type_with_body_input(
  body: String,
) -> Result(MalformedContentTypeWithBodyInput, String) {
  let dec = {
    use hi <- decode.optional_field(
      "hi",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(MalformedContentTypeWithBodyInput(hi: hi))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_content_type_with_body_output(
  _body: String,
) -> Result(MalformedContentTypeWithBodyOutput, String) {
  Ok(MalformedContentTypeWithBodyOutput)
}

pub fn build_malformed_content_type_with_body_request(
  input: MalformedContentTypeWithBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_malformed_content_type_with_body_input(input)
  let headers = dict.from_list([#("Content-Type", "application/json")])
  #(
    "POST",
    "/MalformedContentTypeWithBody",
    headers,
    bit_array.from_string(body_str),
  )
}

pub fn parse_malformed_content_type_with_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(MalformedContentTypeWithBodyOutput, String) {
  Ok(MalformedContentTypeWithBodyOutput)
}

pub type MalformedContentTypeWithoutBodyInput {
  MalformedContentTypeWithoutBodyInput
}

pub type MalformedContentTypeWithoutBodyOutput {
  MalformedContentTypeWithoutBodyOutput
}

pub fn encode_malformed_content_type_without_body_input(
  _input: MalformedContentTypeWithoutBodyInput,
) -> String {
  ""
}

pub fn decode_malformed_content_type_without_body_input(
  _body: String,
) -> Result(MalformedContentTypeWithoutBodyInput, String) {
  Ok(MalformedContentTypeWithoutBodyInput)
}

pub fn decode_malformed_content_type_without_body_output(
  _body: String,
) -> Result(MalformedContentTypeWithoutBodyOutput, String) {
  Ok(MalformedContentTypeWithoutBodyOutput)
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

pub type MalformedRequestBodyInput {
  MalformedRequestBodyInput(
    float: option.Option(json_float.SmithyFloat),
    int: option.Option(Int),
  )
}

pub type MalformedRequestBodyOutput {
  MalformedRequestBodyOutput
}

pub fn encode_malformed_request_body_input(
  input: MalformedRequestBodyInput,
) -> String {
  let pairs = []
  let pairs = case input.float {
    option.Some(v) -> [#("float", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int {
    option.Some(v) -> [#("int", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_malformed_request_body_input(
  body: String,
) -> Result(MalformedRequestBodyInput, String) {
  let dec = {
    use float <- decode.optional_field(
      "float",
      option.None,
      decode.optional(json_float.decoder()),
    )
    use int <- decode.optional_field(
      "int",
      option.None,
      decode.optional(decode.int),
    )
    decode.success(MalformedRequestBodyInput(float: float, int: int))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_request_body_output(
  _body: String,
) -> Result(MalformedRequestBodyOutput, String) {
  Ok(MalformedRequestBodyOutput)
}

pub fn build_malformed_request_body_request(
  input: MalformedRequestBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_malformed_request_body_input(input)
  let headers = dict.from_list([#("Content-Type", "application/json")])
  #("POST", "/MalformedRequestBody", headers, bit_array.from_string(body_str))
}

pub fn parse_malformed_request_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(MalformedRequestBodyOutput, String) {
  Ok(MalformedRequestBodyOutput)
}

pub type NoInputAndNoOutputInput {
  NoInputAndNoOutputInput
}

pub type NoInputAndNoOutputOutput {
  NoInputAndNoOutputOutput
}

pub fn encode_no_input_and_no_output_input(
  _input: NoInputAndNoOutputInput,
) -> String {
  ""
}

pub fn decode_no_input_and_no_output_input(
  _body: String,
) -> Result(NoInputAndNoOutputInput, String) {
  Ok(NoInputAndNoOutputInput)
}

pub fn decode_no_input_and_no_output_output(
  _body: String,
) -> Result(NoInputAndNoOutputOutput, String) {
  Ok(NoInputAndNoOutputOutput)
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

pub fn encode_no_input_and_output_input(
  _input: NoInputAndOutputInput,
) -> String {
  ""
}

pub fn decode_no_input_and_output_input(
  _body: String,
) -> Result(NoInputAndOutputInput, String) {
  Ok(NoInputAndOutputInput)
}

pub fn decode_no_input_and_output_output(
  _body: String,
) -> Result(NoInputAndOutputOutput, String) {
  Ok(NoInputAndOutputOutput)
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

pub fn encode_output_stream_input(_input: OutputStreamInput) -> String {
  ""
}

pub fn decode_output_stream_input(
  _body: String,
) -> Result(OutputStreamInput, String) {
  Ok(OutputStreamInput)
}

pub fn decode_output_stream_output(
  _body: String,
) -> Result(OutputStreamOutput, String) {
  Ok(OutputStreamOutput)
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

pub fn encode_output_stream_with_initial_response_input(
  _input: OutputStreamWithInitialResponseInput,
) -> String {
  ""
}

pub fn decode_output_stream_with_initial_response_input(
  _body: String,
) -> Result(OutputStreamWithInitialResponseInput, String) {
  Ok(OutputStreamWithInitialResponseInput)
}

pub fn decode_output_stream_with_initial_response_output(
  _body: String,
) -> Result(OutputStreamWithInitialResponseOutput, String) {
  Ok(OutputStreamWithInitialResponseOutput)
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

pub fn encode_response_code_http_fallback_input(
  _input: ResponseCodeHttpFallbackInput,
) -> String {
  ""
}

pub fn decode_response_code_http_fallback_input(
  _body: String,
) -> Result(ResponseCodeHttpFallbackInput, String) {
  Ok(ResponseCodeHttpFallbackInput)
}

pub fn decode_response_code_http_fallback_output(
  _body: String,
) -> Result(ResponseCodeHttpFallbackOutput, String) {
  Ok(ResponseCodeHttpFallbackOutput)
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

pub fn encode_response_code_required_input(
  _input: ResponseCodeRequiredInput,
) -> String {
  ""
}

pub fn decode_response_code_required_input(
  _body: String,
) -> Result(ResponseCodeRequiredInput, String) {
  Ok(ResponseCodeRequiredInput)
}

pub fn decode_response_code_required_output(
  _body: String,
) -> Result(ResponseCodeRequiredOutput, String) {
  Ok(ResponseCodeRequiredOutput)
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

pub fn encode_test_get_no_input_no_payload_input(
  _input: TestGetNoInputNoPayloadInput,
) -> String {
  ""
}

pub fn decode_test_get_no_input_no_payload_input(
  _body: String,
) -> Result(TestGetNoInputNoPayloadInput, String) {
  Ok(TestGetNoInputNoPayloadInput)
}

pub fn decode_test_get_no_input_no_payload_output(
  _body: String,
) -> Result(TestGetNoInputNoPayloadOutput, String) {
  Ok(TestGetNoInputNoPayloadOutput)
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

pub fn encode_test_post_no_input_no_payload_input(
  _input: TestPostNoInputNoPayloadInput,
) -> String {
  ""
}

pub fn decode_test_post_no_input_no_payload_input(
  _body: String,
) -> Result(TestPostNoInputNoPayloadInput, String) {
  Ok(TestPostNoInputNoPayloadInput)
}

pub fn decode_test_post_no_input_no_payload_output(
  _body: String,
) -> Result(TestPostNoInputNoPayloadOutput, String) {
  Ok(TestPostNoInputNoPayloadOutput)
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

pub fn encode_unit_input_and_output_input(
  _input: UnitInputAndOutputInput,
) -> String {
  ""
}

pub fn decode_unit_input_and_output_input(
  _body: String,
) -> Result(UnitInputAndOutputInput, String) {
  Ok(UnitInputAndOutputInput)
}

pub fn decode_unit_input_and_output_output(
  _body: String,
) -> Result(UnitInputAndOutputOutput, String) {
  Ok(UnitInputAndOutputOutput)
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
