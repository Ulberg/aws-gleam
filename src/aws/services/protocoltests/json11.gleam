//// Generated from aws.protocoltests.json#JsonProtocol (awsJson1_1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/internal/codec/json_float
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/option

pub type EmptyOperationInput {
  EmptyOperationInput
}

pub type EmptyOperationOutput {
  EmptyOperationOutput
}

pub fn encode_empty_operation_input(_input: EmptyOperationInput) -> String {
  "{}"
}

pub fn decode_empty_operation_input(
  _body: String,
) -> Result(EmptyOperationInput, String) {
  Ok(EmptyOperationInput)
}

pub fn decode_empty_operation_output(
  _body: String,
) -> Result(EmptyOperationOutput, String) {
  Ok(EmptyOperationOutput)
}

pub fn build_empty_operation_request(
  input: EmptyOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_empty_operation_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.EmptyOperation"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
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
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.EndpointOperation"),
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
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.HostWithPathOperation"),
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

pub type NullOperationInput {
  NullOperationInput(string: option.Option(String))
}

pub type NullOperationOutput {
  NullOperationOutput(string: option.Option(String))
}

pub fn encode_null_operation_input(input: NullOperationInput) -> String {
  let pairs = []
  let pairs = case input.string {
    option.Some(v) -> [#("string", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_null_operation_input(
  body: String,
) -> Result(NullOperationInput, String) {
  let dec = {
    use string <- decode.optional_field(
      "string",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(NullOperationInput(string: string))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_null_operation_output(
  body: String,
) -> Result(NullOperationOutput, String) {
  let dec = {
    use string <- decode.optional_field(
      "string",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(NullOperationOutput(string: string))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_null_operation_request(
  input: NullOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_null_operation_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.NullOperation"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
}

pub fn parse_null_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NullOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> decode_null_operation_output(text)
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OperationWithOptionalInputOutputInput {
  OperationWithOptionalInputOutputInput(value: option.Option(String))
}

pub type OperationWithOptionalInputOutputOutput {
  OperationWithOptionalInputOutputOutput(value: option.Option(String))
}

pub fn encode_operation_with_optional_input_output_input(
  input: OperationWithOptionalInputOutputInput,
) -> String {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.to_string(json.object(pairs))
}

pub fn decode_operation_with_optional_input_output_input(
  body: String,
) -> Result(OperationWithOptionalInputOutputInput, String) {
  let dec = {
    use value <- decode.optional_field(
      "Value",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(OperationWithOptionalInputOutputInput(value: value))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_optional_input_output_output(
  body: String,
) -> Result(OperationWithOptionalInputOutputOutput, String) {
  let dec = {
    use value <- decode.optional_field(
      "Value",
      option.None,
      decode.optional(decode.string),
    )
    decode.success(OperationWithOptionalInputOutputOutput(value: value))
  }
  case json.parse(body, dec) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_operation_with_optional_input_output_request(
  input: OperationWithOptionalInputOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_operation_with_optional_input_output_input(input)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.OperationWithOptionalInputOutput"),
    ])
  #("POST", "/", headers, bit_array.from_string(body_str))
}

pub fn parse_operation_with_optional_input_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithOptionalInputOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> decode_operation_with_optional_input_output_output(text)
    Error(_) -> Error("non-utf8 body")
  }
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
      #("Content-Type", "application/x-amz-json-1.1"),
      #("X-Amz-Target", "JsonProtocol.SimpleScalarProperties"),
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
