//// Generated from aws.protocoltests.json10#JsonRpc10 (awsJson1_0).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/internal/codec/json_float
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option

pub type EmptyInputAndEmptyOutputInput {
  EmptyInputAndEmptyOutputInput
}

pub type EmptyInputAndEmptyOutputOutput {
  EmptyInputAndEmptyOutputOutput
}

pub fn encode_empty_input_and_empty_output_input(
  _input: EmptyInputAndEmptyOutputInput,
) -> String {
  "{}"
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
  input: EmptyInputAndEmptyOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_empty_input_and_empty_output_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.EmptyInputAndEmptyOutput"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
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
  "{}"
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
  input: EndpointOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_endpoint_operation_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.EndpointOperation"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
}

pub fn parse_endpoint_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointOperationOutput, String) {
  Ok(EndpointOperationOutput)
}

pub type GreetingWithErrorsInput {
  GreetingWithErrorsInput(greeting: option.Option(String))
}

pub type GreetingWithErrorsOutput {
  GreetingWithErrorsOutput(greeting: option.Option(String))
}

pub fn encode_greeting_with_errors_input(
  input: GreetingWithErrorsInput,
) -> String {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_greeting_with_errors_input(
  body: String,
) -> Result(GreetingWithErrorsInput, String) {
  let dec = {
    use greeting <- decode.optional_field(
      "greeting",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(GreetingWithErrorsInput(greeting: greeting))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_greeting_with_errors_output(
  body: String,
) -> Result(GreetingWithErrorsOutput, String) {
  let dec = {
    use greeting <- decode.optional_field(
      "greeting",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(GreetingWithErrorsOutput(greeting: greeting))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_greeting_with_errors_request(
  input: GreetingWithErrorsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_greeting_with_errors_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.GreetingWithErrors"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
}

pub fn parse_greeting_with_errors_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GreetingWithErrorsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> decode_greeting_with_errors_output(text)
    Error(_) -> Error("non-utf8 body")
  }
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
  "{}"
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
  input: HostWithPathOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_host_with_path_operation_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.HostWithPathOperation"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
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

pub fn encode_no_input_and_no_output_input(
  _input: NoInputAndNoOutputInput,
) -> String {
  "{}"
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
  input: NoInputAndNoOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_no_input_and_no_output_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.NoInputAndNoOutput"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
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
  "{}"
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
  input: NoInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_no_input_and_output_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.NoInputAndOutput"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
}

pub fn parse_no_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(NoInputAndOutputOutput, String) {
  Ok(NoInputAndOutputOutput)
}

pub type QueryIncompatibleOperationInput {
  QueryIncompatibleOperationInput
}

pub type QueryIncompatibleOperationOutput {
  QueryIncompatibleOperationOutput
}

pub fn encode_query_incompatible_operation_input(
  _input: QueryIncompatibleOperationInput,
) -> String {
  "{}"
}

pub fn decode_query_incompatible_operation_input(
  _body: String,
) -> Result(QueryIncompatibleOperationInput, String) {
  Ok(QueryIncompatibleOperationInput)
}

pub fn decode_query_incompatible_operation_output(
  _body: String,
) -> Result(QueryIncompatibleOperationOutput, String) {
  Ok(QueryIncompatibleOperationOutput)
}

pub fn build_query_incompatible_operation_request(
  input: QueryIncompatibleOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_query_incompatible_operation_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.QueryIncompatibleOperation"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
}

pub fn parse_query_incompatible_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(QueryIncompatibleOperationOutput, String) {
  Ok(QueryIncompatibleOperationOutput)
}

pub type SimpleScalarPropertiesInput {
  SimpleScalarPropertiesInput(
    double_value: option.Option(json_float.SmithyFloat),
    float_value: option.Option(json_float.SmithyFloat),
  )
}

pub type SimpleScalarPropertiesOutput {
  SimpleScalarPropertiesOutput(
    double_value: option.Option(json_float.SmithyFloat),
    float_value: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_simple_scalar_properties_input(
  input: SimpleScalarPropertiesInput,
) -> String {
  let pairs = []
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_simple_scalar_properties_input(
  body: String,
) -> Result(SimpleScalarPropertiesInput, String) {
  let dec = {
    use double_value <- decode.optional_field(
      "doubleValue",
      option.None,
      decode.optional(json_float.decoder()),
    )
    use float_value <- decode.optional_field(
      "floatValue",
      option.None,
      decode.optional(json_float.decoder()),
    )
    decode.success(SimpleScalarPropertiesInput(
      double_value: double_value,
      float_value: float_value,
    ))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_simple_scalar_properties_output(
  body: String,
) -> Result(SimpleScalarPropertiesOutput, String) {
  let dec = {
    use double_value <- decode.optional_field(
      "doubleValue",
      option.None,
      decode.optional(json_float.decoder()),
    )
    use float_value <- decode.optional_field(
      "floatValue",
      option.None,
      decode.optional(json_float.decoder()),
    )
    decode.success(SimpleScalarPropertiesOutput(
      double_value: double_value,
      float_value: float_value,
    ))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_simple_scalar_properties_request(
  input: SimpleScalarPropertiesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_simple_scalar_properties_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("X-Amz-Target", "JsonRpc10.SimpleScalarProperties"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
}

pub fn parse_simple_scalar_properties_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SimpleScalarPropertiesOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> decode_simple_scalar_properties_output(text)
    Error(_) -> Error("non-utf8 body")
  }
}
