//// Generated from aws.protocoltests.restxml#RestXml (restXml).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/credentials
import aws/internal/client/awsjson as awsjson_client
import aws/internal/codec/json_document
import aws/internal/codec/json_float
import aws/internal/codec/json_timestamp
import aws/internal/codec/rest
import aws/internal/codec/xml
import aws/internal/codec/xml_decode
import aws/internal/http_send
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/result
import gleam/string

pub opaque type Client {
  Client(config: awsjson_client.ClientConfig)
}

/// Build a Client for an AWS region. Credentials resolve through
/// the default chain (env → web-identity → SSO → profile → process
/// → ECS → IMDS); use `with_credentials_provider` to override.
pub fn new(region region: String) -> Client {
  Client(awsjson_client.default_config(region, "restxml", "restxml"))
}

/// Override the credentials provider — use for non-default
/// profiles, in-process static credentials, or a custom chain.
pub fn with_credentials_provider(client: Client, provider: credentials.Provider) -> Client {
  Client(awsjson_client.with_credentials_provider(client.config, provider))
}

/// Override the endpoint URL (LocalStack, FIPS endpoints, custom DNS).
pub fn with_endpoint_url(client: Client, url: String) -> Client {
  Client(awsjson_client.with_endpoint_url(client.config, url))
}

/// Swap the HTTP transport — useful for canned-response test doubles.
pub fn with_http_send(client: Client, send: http_send.Send) -> Client {
  Client(awsjson_client.with_http_send(client.config, send))
}

pub type AllQueryStringTypesInput {
  AllQueryStringTypesInput(query_boolean: option.Option(Bool), query_boolean_list: option.Option(List(Bool)), query_byte: option.Option(Int), query_double: option.Option(json_float.SmithyFloat), query_double_list: option.Option(List(json_float.SmithyFloat)), query_enum: option.Option(FooEnum), query_enum_list: option.Option(List(FooEnum)), query_float: option.Option(json_float.SmithyFloat), query_integer: option.Option(Int), query_integer_enum: option.Option(IntegerEnum), query_integer_enum_list: option.Option(List(IntegerEnum)), query_integer_list: option.Option(List(Int)), query_integer_set: option.Option(List(Int)), query_long: option.Option(Int), query_params_map_of_strings: option.Option(dict.Dict(String, String)), query_short: option.Option(Int), query_string: option.Option(String), query_string_list: option.Option(List(String)), query_string_set: option.Option(List(String)), query_timestamp: option.Option(Int), query_timestamp_list: option.Option(List(Int)))
}

pub fn encode_all_query_string_types_input_struct(input: AllQueryStringTypesInput) -> json.Json {
  let pairs = []
  let pairs = case input.query_boolean {
    option.Some(v) -> [#("queryBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_boolean_list {
    option.Some(v) -> [#("queryBooleanList", fn(xs) { json.array(xs, json.bool) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_byte {
    option.Some(v) -> [#("queryByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_double {
    option.Some(v) -> [#("queryDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_double_list {
    option.Some(v) -> [#("queryDoubleList", fn(xs) { json.array(xs, json_float.encode) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_enum {
    option.Some(v) -> [#("queryEnum", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_enum_list {
    option.Some(v) -> [#("queryEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_float {
    option.Some(v) -> [#("queryFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_integer {
    option.Some(v) -> [#("queryInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_integer_enum {
    option.Some(v) -> [#("queryIntegerEnum", encode_integer_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_integer_enum_list {
    option.Some(v) -> [#("queryIntegerEnumList", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_integer_list {
    option.Some(v) -> [#("queryIntegerList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_integer_set {
    option.Some(v) -> [#("queryIntegerSet", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_long {
    option.Some(v) -> [#("queryLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_params_map_of_strings {
    option.Some(v) -> [#("queryParamsMapOfStrings", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_short {
    option.Some(v) -> [#("queryShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_string {
    option.Some(v) -> [#("queryString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_string_list {
    option.Some(v) -> [#("queryStringList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_string_set {
    option.Some(v) -> [#("queryStringSet", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_timestamp {
    option.Some(v) -> [#("queryTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_timestamp_list {
    option.Some(v) -> [#("queryTimestampList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_all_query_string_types_input_struct() -> decode.Decoder(AllQueryStringTypesInput) {
  use <- decode.recursive
  use query_boolean <- decode.optional_field("queryBoolean", option.None, decode.optional(decode.bool))
  use query_boolean_list <- decode.optional_field("queryBooleanList", option.None, decode.optional(decode.list(decode.bool)))
  use query_byte <- decode.optional_field("queryByte", option.None, decode.optional(decode.int))
  use query_double <- decode.optional_field("queryDouble", option.None, decode.optional(json_float.decoder()))
  use query_double_list <- decode.optional_field("queryDoubleList", option.None, decode.optional(decode.list(json_float.decoder())))
  use query_enum <- decode.optional_field("queryEnum", option.None, decode.optional(decode_foo_enum_enum()))
  use query_enum_list <- decode.optional_field("queryEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use query_float <- decode.optional_field("queryFloat", option.None, decode.optional(json_float.decoder()))
  use query_integer <- decode.optional_field("queryInteger", option.None, decode.optional(decode.int))
  use query_integer_enum <- decode.optional_field("queryIntegerEnum", option.None, decode.optional(decode_integer_enum_int_enum()))
  use query_integer_enum_list <- decode.optional_field("queryIntegerEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use query_integer_list <- decode.optional_field("queryIntegerList", option.None, decode.optional(decode.list(decode.int)))
  use query_integer_set <- decode.optional_field("queryIntegerSet", option.None, decode.optional(decode.list(decode.int)))
  use query_long <- decode.optional_field("queryLong", option.None, decode.optional(decode.int))
  use query_params_map_of_strings <- decode.optional_field("queryParamsMapOfStrings", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use query_short <- decode.optional_field("queryShort", option.None, decode.optional(decode.int))
  use query_string <- decode.optional_field("queryString", option.None, decode.optional(decode.string))
  use query_string_list <- decode.optional_field("queryStringList", option.None, decode.optional(decode.list(decode.string)))
  use query_string_set <- decode.optional_field("queryStringSet", option.None, decode.optional(decode.list(decode.string)))
  use query_timestamp <- decode.optional_field("queryTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  use query_timestamp_list <- decode.optional_field("queryTimestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(AllQueryStringTypesInput(
    query_boolean: query_boolean,
    query_boolean_list: query_boolean_list,
    query_byte: query_byte,
    query_double: query_double,
    query_double_list: query_double_list,
    query_enum: query_enum,
    query_enum_list: query_enum_list,
    query_float: query_float,
    query_integer: query_integer,
    query_integer_enum: query_integer_enum,
    query_integer_enum_list: query_integer_enum_list,
    query_integer_list: query_integer_list,
    query_integer_set: query_integer_set,
    query_long: query_long,
    query_params_map_of_strings: query_params_map_of_strings,
    query_short: query_short,
    query_string: query_string,
    query_string_list: query_string_list,
    query_string_set: query_string_set,
    query_timestamp: query_timestamp,
    query_timestamp_list: query_timestamp_list,
  ))
}

pub fn decode_all_query_string_types_input_struct_params() -> decode.Decoder(AllQueryStringTypesInput) {
  use <- decode.recursive
  use query_boolean <- decode.optional_field("queryBoolean", option.None, decode.optional(decode.bool))
  use query_boolean_list <- decode.optional_field("queryBooleanList", option.None, decode.optional(decode.list(decode.bool)))
  use query_byte <- decode.optional_field("queryByte", option.None, decode.optional(decode.int))
  use query_double <- decode.optional_field("queryDouble", option.None, decode.optional(json_float.decoder()))
  use query_double_list <- decode.optional_field("queryDoubleList", option.None, decode.optional(decode.list(json_float.decoder())))
  use query_enum <- decode.optional_field("queryEnum", option.None, decode.optional(decode_foo_enum_enum()))
  use query_enum_list <- decode.optional_field("queryEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use query_float <- decode.optional_field("queryFloat", option.None, decode.optional(json_float.decoder()))
  use query_integer <- decode.optional_field("queryInteger", option.None, decode.optional(decode.int))
  use query_integer_enum <- decode.optional_field("queryIntegerEnum", option.None, decode.optional(decode_integer_enum_int_enum()))
  use query_integer_enum_list <- decode.optional_field("queryIntegerEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use query_integer_list <- decode.optional_field("queryIntegerList", option.None, decode.optional(decode.list(decode.int)))
  use query_integer_set <- decode.optional_field("queryIntegerSet", option.None, decode.optional(decode.list(decode.int)))
  use query_long <- decode.optional_field("queryLong", option.None, decode.optional(decode.int))
  use query_params_map_of_strings <- decode.optional_field("queryParamsMapOfStrings", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use query_short <- decode.optional_field("queryShort", option.None, decode.optional(decode.int))
  use query_string <- decode.optional_field("queryString", option.None, decode.optional(decode.string))
  use query_string_list <- decode.optional_field("queryStringList", option.None, decode.optional(decode.list(decode.string)))
  use query_string_set <- decode.optional_field("queryStringSet", option.None, decode.optional(decode.list(decode.string)))
  use query_timestamp <- decode.optional_field("queryTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  use query_timestamp_list <- decode.optional_field("queryTimestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(AllQueryStringTypesInput(
    query_boolean: query_boolean,
    query_boolean_list: query_boolean_list,
    query_byte: query_byte,
    query_double: query_double,
    query_double_list: query_double_list,
    query_enum: query_enum,
    query_enum_list: query_enum_list,
    query_float: query_float,
    query_integer: query_integer,
    query_integer_enum: query_integer_enum,
    query_integer_enum_list: query_integer_enum_list,
    query_integer_list: query_integer_list,
    query_integer_set: query_integer_set,
    query_long: query_long,
    query_params_map_of_strings: query_params_map_of_strings,
    query_short: query_short,
    query_string: query_string,
    query_string_list: query_string_list,
    query_string_set: query_string_set,
    query_timestamp: query_timestamp,
    query_timestamp_list: query_timestamp_list,
  ))
}

pub fn encode_all_query_string_types_input_xml_inner(input: AllQueryStringTypesInput) -> String {
  let inner = ""
  inner
}

pub fn encode_all_query_string_types_input_xml(input: AllQueryStringTypesInput, root: String) -> String {
  xml.element(root, encode_all_query_string_types_input_xml_inner(input))
}

pub fn decode_all_query_string_types_input_xml(elem: xml_decode.Element) -> Result(AllQueryStringTypesInput, String) {
  let query_boolean = option.None
  let query_boolean_list = option.None
  let query_byte = option.None
  let query_double = option.None
  let query_double_list = option.None
  let query_enum = option.None
  let query_enum_list = option.None
  let query_float = option.None
  let query_integer = option.None
  let query_integer_enum = option.None
  let query_integer_enum_list = option.None
  let query_integer_list = option.None
  let query_integer_set = option.None
  let query_long = option.None
  let query_params_map_of_strings = option.None
  let query_short = option.None
  let query_string = option.None
  let query_string_list = option.None
  let query_string_set = option.None
  let query_timestamp = option.None
  let query_timestamp_list = option.None
  Ok(AllQueryStringTypesInput(
    query_boolean: query_boolean,
    query_boolean_list: query_boolean_list,
    query_byte: query_byte,
    query_double: query_double,
    query_double_list: query_double_list,
    query_enum: query_enum,
    query_enum_list: query_enum_list,
    query_float: query_float,
    query_integer: query_integer,
    query_integer_enum: query_integer_enum,
    query_integer_enum_list: query_integer_enum_list,
    query_integer_list: query_integer_list,
    query_integer_set: query_integer_set,
    query_long: query_long,
    query_params_map_of_strings: query_params_map_of_strings,
    query_short: query_short,
    query_string: query_string,
    query_string_list: query_string_list,
    query_string_set: query_string_set,
    query_timestamp: query_timestamp,
    query_timestamp_list: query_timestamp_list,
  ))
}

pub type FooEnum {
  FooEnumBar
  FooEnumBaz
  FooEnumFoo
  FooEnumOne
  FooEnumZero
}

pub fn encode_foo_enum_enum(v: FooEnum) -> json.Json {
  case v {
    FooEnumBar -> json.string("Bar")
    FooEnumBaz -> json.string("Baz")
    FooEnumFoo -> json.string("Foo")
    FooEnumOne -> json.string("1")
    FooEnumZero -> json.string("0")
  }
}

pub fn decode_foo_enum_enum() -> decode.Decoder(FooEnum) {
  decode.then(decode.string, fn(s) {
    case s {
      "Bar" -> decode.success(FooEnumBar)
      "Baz" -> decode.success(FooEnumBaz)
      "Foo" -> decode.success(FooEnumFoo)
      "1" -> decode.success(FooEnumOne)
      "0" -> decode.success(FooEnumZero)
      _ -> decode.failure(FooEnumBar, "unknown enum value")
    }
  })
}

pub type IntegerEnum {
  IntegerEnumA
  IntegerEnumB
  IntegerEnumC
}

pub fn integer_enum_int_value(v: IntegerEnum) -> Int {
  case v {
    IntegerEnumA -> 1
    IntegerEnumB -> 2
    IntegerEnumC -> 3
  }
}

pub fn encode_integer_enum_int_enum(v: IntegerEnum) -> json.Json {
  case v {
    IntegerEnumA -> json.int(1)
    IntegerEnumB -> json.int(2)
    IntegerEnumC -> json.int(3)
  }
}

pub fn decode_integer_enum_int_enum() -> decode.Decoder(IntegerEnum) {
  decode.then(decode.int, fn(n) {
    case n {
      1 -> decode.success(IntegerEnumA)
      2 -> decode.success(IntegerEnumB)
      3 -> decode.success(IntegerEnumC)
      _ -> decode.failure(IntegerEnumA, "unknown int enum value")
    }
  })
}

pub type BodyWithXmlNameInputOutput {
  BodyWithXmlNameInputOutput(nested: option.Option(PayloadWithXmlName))
}

pub fn encode_body_with_xml_name_input_output_struct(input: BodyWithXmlNameInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_payload_with_xml_name_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_body_with_xml_name_input_output_struct() -> decode.Decoder(BodyWithXmlNameInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_name_struct()))
  decode.success(BodyWithXmlNameInputOutput(
    nested: nested,
  ))
}

pub fn decode_body_with_xml_name_input_output_struct_params() -> decode.Decoder(BodyWithXmlNameInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_name_struct_params()))
  decode.success(BodyWithXmlNameInputOutput(
    nested: nested,
  ))
}

pub fn encode_body_with_xml_name_input_output_xml_inner(input: BodyWithXmlNameInputOutput) -> String {
  let inner = ""
  let inner = case input.nested {
    option.Some(v) -> inner <> encode_payload_with_xml_name_xml(v, "nested")
    option.None -> inner
  }
  inner
}

pub fn encode_body_with_xml_name_input_output_xml(input: BodyWithXmlNameInputOutput, root: String) -> String {
  xml.element(root, encode_body_with_xml_name_input_output_xml_inner(input))
}

pub fn decode_body_with_xml_name_input_output_xml(elem: xml_decode.Element) -> Result(BodyWithXmlNameInputOutput, String) {
  use nested <- result.try(xml_decode.optional_child(elem, "nested", decode_payload_with_xml_name_xml))
  Ok(BodyWithXmlNameInputOutput(
    nested: nested,
  ))
}

pub type PayloadWithXmlName {
  PayloadWithXmlName(name: option.Option(String))
}

pub fn encode_payload_with_xml_name_struct(input: PayloadWithXmlName) -> json.Json {
  let pairs = []
  let pairs = case input.name {
    option.Some(v) -> [#("name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_payload_with_xml_name_struct() -> decode.Decoder(PayloadWithXmlName) {
  use <- decode.recursive
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(PayloadWithXmlName(
    name: name,
  ))
}

pub fn decode_payload_with_xml_name_struct_params() -> decode.Decoder(PayloadWithXmlName) {
  use <- decode.recursive
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(PayloadWithXmlName(
    name: name,
  ))
}

pub fn encode_payload_with_xml_name_xml_inner(input: PayloadWithXmlName) -> String {
  let inner = ""
  let inner = case input.name {
    option.Some(v) -> inner <> xml.element("name", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_payload_with_xml_name_xml(input: PayloadWithXmlName, root: String) -> String {
  xml.element(root, encode_payload_with_xml_name_xml_inner(input))
}

pub fn decode_payload_with_xml_name_xml(elem: xml_decode.Element) -> Result(PayloadWithXmlName, String) {
  use name <- result.try(xml_decode.optional_child(elem, "name", xml_decode.string_text))
  Ok(PayloadWithXmlName(
    name: name,
  ))
}

pub type ConstantAndVariableQueryStringInput {
  ConstantAndVariableQueryStringInput(baz: option.Option(String), maybe_set: option.Option(String))
}

pub fn encode_constant_and_variable_query_string_input_struct(input: ConstantAndVariableQueryStringInput) -> json.Json {
  let pairs = []
  let pairs = case input.baz {
    option.Some(v) -> [#("baz", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.maybe_set {
    option.Some(v) -> [#("maybeSet", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_constant_and_variable_query_string_input_struct() -> decode.Decoder(ConstantAndVariableQueryStringInput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use maybe_set <- decode.optional_field("maybeSet", option.None, decode.optional(decode.string))
  decode.success(ConstantAndVariableQueryStringInput(
    baz: baz,
    maybe_set: maybe_set,
  ))
}

pub fn decode_constant_and_variable_query_string_input_struct_params() -> decode.Decoder(ConstantAndVariableQueryStringInput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use maybe_set <- decode.optional_field("maybeSet", option.None, decode.optional(decode.string))
  decode.success(ConstantAndVariableQueryStringInput(
    baz: baz,
    maybe_set: maybe_set,
  ))
}

pub fn encode_constant_and_variable_query_string_input_xml_inner(input: ConstantAndVariableQueryStringInput) -> String {
  let inner = ""
  inner
}

pub fn encode_constant_and_variable_query_string_input_xml(input: ConstantAndVariableQueryStringInput, root: String) -> String {
  xml.element(root, encode_constant_and_variable_query_string_input_xml_inner(input))
}

pub fn decode_constant_and_variable_query_string_input_xml(elem: xml_decode.Element) -> Result(ConstantAndVariableQueryStringInput, String) {
  let baz = option.None
  let maybe_set = option.None
  Ok(ConstantAndVariableQueryStringInput(
    baz: baz,
    maybe_set: maybe_set,
  ))
}

pub type ConstantQueryStringInput {
  ConstantQueryStringInput(hello: option.Option(String))
}

pub fn encode_constant_query_string_input_struct(input: ConstantQueryStringInput) -> json.Json {
  let pairs = []
  let pairs = case input.hello {
    option.Some(v) -> [#("hello", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_constant_query_string_input_struct() -> decode.Decoder(ConstantQueryStringInput) {
  use <- decode.recursive
  use hello <- decode.optional_field("hello", option.None, decode.optional(decode.string))
  decode.success(ConstantQueryStringInput(
    hello: hello,
  ))
}

pub fn decode_constant_query_string_input_struct_params() -> decode.Decoder(ConstantQueryStringInput) {
  use <- decode.recursive
  use hello <- decode.optional_field("hello", option.None, decode.optional(decode.string))
  decode.success(ConstantQueryStringInput(
    hello: hello,
  ))
}

pub fn encode_constant_query_string_input_xml_inner(input: ConstantQueryStringInput) -> String {
  let inner = ""
  inner
}

pub fn encode_constant_query_string_input_xml(input: ConstantQueryStringInput, root: String) -> String {
  xml.element(root, encode_constant_query_string_input_xml_inner(input))
}

pub fn decode_constant_query_string_input_xml(elem: xml_decode.Element) -> Result(ConstantQueryStringInput, String) {
  let hello = option.None
  Ok(ConstantQueryStringInput(
    hello: hello,
  ))
}

pub type ContentTypeParametersInput {
  ContentTypeParametersInput(value: option.Option(Int))
}

pub fn encode_content_type_parameters_input_struct(input: ContentTypeParametersInput) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("value", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_content_type_parameters_input_struct() -> decode.Decoder(ContentTypeParametersInput) {
  use <- decode.recursive
  use value <- decode.optional_field("value", option.None, decode.optional(decode.int))
  decode.success(ContentTypeParametersInput(
    value: value,
  ))
}

pub fn decode_content_type_parameters_input_struct_params() -> decode.Decoder(ContentTypeParametersInput) {
  use <- decode.recursive
  use value <- decode.optional_field("value", option.None, decode.optional(decode.int))
  decode.success(ContentTypeParametersInput(
    value: value,
  ))
}

pub fn encode_content_type_parameters_input_xml_inner(input: ContentTypeParametersInput) -> String {
  let inner = ""
  let inner = case input.value {
    option.Some(v) -> inner <> xml.element("value", xml.int_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_content_type_parameters_input_xml(input: ContentTypeParametersInput, root: String) -> String {
  xml.element(root, encode_content_type_parameters_input_xml_inner(input))
}

pub fn decode_content_type_parameters_input_xml(elem: xml_decode.Element) -> Result(ContentTypeParametersInput, String) {
  use value <- result.try(xml_decode.optional_child(elem, "value", xml_decode.int_text))
  Ok(ContentTypeParametersInput(
    value: value,
  ))
}

pub type ContentTypeParametersOutput {
  ContentTypeParametersOutput
}

pub fn encode_content_type_parameters_output_struct(_v: ContentTypeParametersOutput) -> json.Json {
  json.object([])
}

pub fn decode_content_type_parameters_output_struct() -> decode.Decoder(ContentTypeParametersOutput) {
  decode.success(ContentTypeParametersOutput)
}

pub fn decode_content_type_parameters_output_struct_params() -> decode.Decoder(ContentTypeParametersOutput) {
  decode.success(ContentTypeParametersOutput)
}

pub fn encode_content_type_parameters_output_xml_inner(_input: ContentTypeParametersOutput) -> String {
  ""
}

pub fn encode_content_type_parameters_output_xml(input: ContentTypeParametersOutput, root: String) -> String {
  xml.element(root, encode_content_type_parameters_output_xml_inner(input))
}

pub fn decode_content_type_parameters_output_xml(_elem: xml_decode.Element) -> Result(ContentTypeParametersOutput, String) {
  Ok(ContentTypeParametersOutput)
}

pub type DatetimeOffsetsOutput {
  DatetimeOffsetsOutput(datetime: option.Option(Int))
}

pub fn encode_datetime_offsets_output_struct(input: DatetimeOffsetsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.datetime {
    option.Some(v) -> [#("datetime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_datetime_offsets_output_struct() -> decode.Decoder(DatetimeOffsetsOutput) {
  use <- decode.recursive
  use datetime <- decode.optional_field("datetime", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(DatetimeOffsetsOutput(
    datetime: datetime,
  ))
}

pub fn decode_datetime_offsets_output_struct_params() -> decode.Decoder(DatetimeOffsetsOutput) {
  use <- decode.recursive
  use datetime <- decode.optional_field("datetime", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(DatetimeOffsetsOutput(
    datetime: datetime,
  ))
}

pub fn encode_datetime_offsets_output_xml_inner(input: DatetimeOffsetsOutput) -> String {
  let inner = ""
  let inner = case input.datetime {
    option.Some(v) -> inner <> xml.element("datetime", xml.int_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_datetime_offsets_output_xml(input: DatetimeOffsetsOutput, root: String) -> String {
  xml.element(root, encode_datetime_offsets_output_xml_inner(input))
}

pub fn decode_datetime_offsets_output_xml(elem: xml_decode.Element) -> Result(DatetimeOffsetsOutput, String) {
  use datetime <- result.try(xml_decode.optional_child(elem, "datetime", xml_decode.timestamp_text))
  Ok(DatetimeOffsetsOutput(
    datetime: datetime,
  ))
}

pub type EmptyInputAndEmptyOutputInput {
  EmptyInputAndEmptyOutputInput
}

pub fn encode_empty_input_and_empty_output_input_struct(_v: EmptyInputAndEmptyOutputInput) -> json.Json {
  json.object([])
}

pub fn decode_empty_input_and_empty_output_input_struct() -> decode.Decoder(EmptyInputAndEmptyOutputInput) {
  decode.success(EmptyInputAndEmptyOutputInput)
}

pub fn decode_empty_input_and_empty_output_input_struct_params() -> decode.Decoder(EmptyInputAndEmptyOutputInput) {
  decode.success(EmptyInputAndEmptyOutputInput)
}

pub fn encode_empty_input_and_empty_output_input_xml_inner(_input: EmptyInputAndEmptyOutputInput) -> String {
  ""
}

pub fn encode_empty_input_and_empty_output_input_xml(input: EmptyInputAndEmptyOutputInput, root: String) -> String {
  xml.element(root, encode_empty_input_and_empty_output_input_xml_inner(input))
}

pub fn decode_empty_input_and_empty_output_input_xml(_elem: xml_decode.Element) -> Result(EmptyInputAndEmptyOutputInput, String) {
  Ok(EmptyInputAndEmptyOutputInput)
}

pub type EmptyInputAndEmptyOutputOutput {
  EmptyInputAndEmptyOutputOutput
}

pub fn encode_empty_input_and_empty_output_output_struct(_v: EmptyInputAndEmptyOutputOutput) -> json.Json {
  json.object([])
}

pub fn decode_empty_input_and_empty_output_output_struct() -> decode.Decoder(EmptyInputAndEmptyOutputOutput) {
  decode.success(EmptyInputAndEmptyOutputOutput)
}

pub fn decode_empty_input_and_empty_output_output_struct_params() -> decode.Decoder(EmptyInputAndEmptyOutputOutput) {
  decode.success(EmptyInputAndEmptyOutputOutput)
}

pub fn encode_empty_input_and_empty_output_output_xml_inner(_input: EmptyInputAndEmptyOutputOutput) -> String {
  ""
}

pub fn encode_empty_input_and_empty_output_output_xml(input: EmptyInputAndEmptyOutputOutput, root: String) -> String {
  xml.element(root, encode_empty_input_and_empty_output_output_xml_inner(input))
}

pub fn decode_empty_input_and_empty_output_output_xml(_elem: xml_decode.Element) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  Ok(EmptyInputAndEmptyOutputOutput)
}

pub type HostLabelHeaderInput {
  HostLabelHeaderInput(account_id: option.Option(String))
}

pub fn encode_host_label_header_input_struct(input: HostLabelHeaderInput) -> json.Json {
  let pairs = []
  let pairs = case input.account_id {
    option.Some(v) -> [#("accountId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_host_label_header_input_struct() -> decode.Decoder(HostLabelHeaderInput) {
  use <- decode.recursive
  use account_id <- decode.optional_field("accountId", option.None, decode.optional(decode.string))
  decode.success(HostLabelHeaderInput(
    account_id: account_id,
  ))
}

pub fn decode_host_label_header_input_struct_params() -> decode.Decoder(HostLabelHeaderInput) {
  use <- decode.recursive
  use account_id <- decode.optional_field("accountId", option.None, decode.optional(decode.string))
  decode.success(HostLabelHeaderInput(
    account_id: account_id,
  ))
}

pub fn encode_host_label_header_input_xml_inner(input: HostLabelHeaderInput) -> String {
  let inner = ""
  inner
}

pub fn encode_host_label_header_input_xml(input: HostLabelHeaderInput, root: String) -> String {
  xml.element(root, encode_host_label_header_input_xml_inner(input))
}

pub fn decode_host_label_header_input_xml(elem: xml_decode.Element) -> Result(HostLabelHeaderInput, String) {
  let account_id = option.None
  Ok(HostLabelHeaderInput(
    account_id: account_id,
  ))
}

pub type EndpointWithHostLabelOperationRequest {
  EndpointWithHostLabelOperationRequest(label: option.Option(String))
}

pub fn encode_endpoint_with_host_label_operation_request_struct(input: EndpointWithHostLabelOperationRequest) -> json.Json {
  let pairs = []
  let pairs = case input.label {
    option.Some(v) -> [#("label", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_endpoint_with_host_label_operation_request_struct() -> decode.Decoder(EndpointWithHostLabelOperationRequest) {
  use <- decode.recursive
  use label <- decode.optional_field("label", option.None, decode.optional(decode.string))
  decode.success(EndpointWithHostLabelOperationRequest(
    label: label,
  ))
}

pub fn decode_endpoint_with_host_label_operation_request_struct_params() -> decode.Decoder(EndpointWithHostLabelOperationRequest) {
  use <- decode.recursive
  use label <- decode.optional_field("label", option.None, decode.optional(decode.string))
  decode.success(EndpointWithHostLabelOperationRequest(
    label: label,
  ))
}

pub fn encode_endpoint_with_host_label_operation_request_xml_inner(input: EndpointWithHostLabelOperationRequest) -> String {
  let inner = ""
  let inner = case input.label {
    option.Some(v) -> inner <> xml.element("label", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_endpoint_with_host_label_operation_request_xml(input: EndpointWithHostLabelOperationRequest, root: String) -> String {
  xml.element(root, encode_endpoint_with_host_label_operation_request_xml_inner(input))
}

pub fn decode_endpoint_with_host_label_operation_request_xml(elem: xml_decode.Element) -> Result(EndpointWithHostLabelOperationRequest, String) {
  use label <- result.try(xml_decode.optional_child(elem, "label", xml_decode.string_text))
  Ok(EndpointWithHostLabelOperationRequest(
    label: label,
  ))
}

pub type FlattenedXmlMapRequest {
  FlattenedXmlMapRequest(my_map: option.Option(dict.Dict(String, FooEnum)))
}

pub fn encode_flattened_xml_map_request_struct(input: FlattenedXmlMapRequest) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_flattened_xml_map_request_struct() -> decode.Decoder(FlattenedXmlMapRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  decode.success(FlattenedXmlMapRequest(
    my_map: my_map,
  ))
}

pub fn decode_flattened_xml_map_request_struct_params() -> decode.Decoder(FlattenedXmlMapRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  decode.success(FlattenedXmlMapRequest(
    my_map: my_map,
  ))
}

pub fn encode_flattened_xml_map_request_xml_inner(input: FlattenedXmlMapRequest) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_flattened_xml_map_request_xml(input: FlattenedXmlMapRequest, root: String) -> String {
  xml.element(root, encode_flattened_xml_map_request_xml_inner(input))
}

pub fn decode_flattened_xml_map_request_xml(elem: xml_decode.Element) -> Result(FlattenedXmlMapRequest, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, FooEnum)), String) = Ok(option.None)
    r })
  Ok(FlattenedXmlMapRequest(
    my_map: my_map,
  ))
}

pub type FlattenedXmlMapResponse {
  FlattenedXmlMapResponse(my_map: option.Option(dict.Dict(String, FooEnum)))
}

pub fn encode_flattened_xml_map_response_struct(input: FlattenedXmlMapResponse) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_flattened_xml_map_response_struct() -> decode.Decoder(FlattenedXmlMapResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  decode.success(FlattenedXmlMapResponse(
    my_map: my_map,
  ))
}

pub fn decode_flattened_xml_map_response_struct_params() -> decode.Decoder(FlattenedXmlMapResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  decode.success(FlattenedXmlMapResponse(
    my_map: my_map,
  ))
}

pub fn encode_flattened_xml_map_response_xml_inner(input: FlattenedXmlMapResponse) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_flattened_xml_map_response_xml(input: FlattenedXmlMapResponse, root: String) -> String {
  xml.element(root, encode_flattened_xml_map_response_xml_inner(input))
}

pub fn decode_flattened_xml_map_response_xml(elem: xml_decode.Element) -> Result(FlattenedXmlMapResponse, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, FooEnum)), String) = Ok(option.None)
    r })
  Ok(FlattenedXmlMapResponse(
    my_map: my_map,
  ))
}

pub type FlattenedXmlMapWithXmlNameRequest {
  FlattenedXmlMapWithXmlNameRequest(my_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_flattened_xml_map_with_xml_name_request_struct(input: FlattenedXmlMapWithXmlNameRequest) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_flattened_xml_map_with_xml_name_request_struct() -> decode.Decoder(FlattenedXmlMapWithXmlNameRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(FlattenedXmlMapWithXmlNameRequest(
    my_map: my_map,
  ))
}

pub fn decode_flattened_xml_map_with_xml_name_request_struct_params() -> decode.Decoder(FlattenedXmlMapWithXmlNameRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(FlattenedXmlMapWithXmlNameRequest(
    my_map: my_map,
  ))
}

pub fn encode_flattened_xml_map_with_xml_name_request_xml_inner(input: FlattenedXmlMapWithXmlNameRequest) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_flattened_xml_map_with_xml_name_request_xml(input: FlattenedXmlMapWithXmlNameRequest, root: String) -> String {
  xml.element(root, encode_flattened_xml_map_with_xml_name_request_xml_inner(input))
}

pub fn decode_flattened_xml_map_with_xml_name_request_xml(elem: xml_decode.Element) -> Result(FlattenedXmlMapWithXmlNameRequest, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, String)), String) = Ok(option.None)
    r })
  Ok(FlattenedXmlMapWithXmlNameRequest(
    my_map: my_map,
  ))
}

pub type FlattenedXmlMapWithXmlNameResponse {
  FlattenedXmlMapWithXmlNameResponse(my_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_flattened_xml_map_with_xml_name_response_struct(input: FlattenedXmlMapWithXmlNameResponse) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_flattened_xml_map_with_xml_name_response_struct() -> decode.Decoder(FlattenedXmlMapWithXmlNameResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(FlattenedXmlMapWithXmlNameResponse(
    my_map: my_map,
  ))
}

pub fn decode_flattened_xml_map_with_xml_name_response_struct_params() -> decode.Decoder(FlattenedXmlMapWithXmlNameResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(FlattenedXmlMapWithXmlNameResponse(
    my_map: my_map,
  ))
}

pub fn encode_flattened_xml_map_with_xml_name_response_xml_inner(input: FlattenedXmlMapWithXmlNameResponse) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_flattened_xml_map_with_xml_name_response_xml(input: FlattenedXmlMapWithXmlNameResponse, root: String) -> String {
  xml.element(root, encode_flattened_xml_map_with_xml_name_response_xml_inner(input))
}

pub fn decode_flattened_xml_map_with_xml_name_response_xml(elem: xml_decode.Element) -> Result(FlattenedXmlMapWithXmlNameResponse, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, String)), String) = Ok(option.None)
    r })
  Ok(FlattenedXmlMapWithXmlNameResponse(
    my_map: my_map,
  ))
}

pub type FlattenedXmlMapWithXmlNamespaceOutput {
  FlattenedXmlMapWithXmlNamespaceOutput(my_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_flattened_xml_map_with_xml_namespace_output_struct(input: FlattenedXmlMapWithXmlNamespaceOutput) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_flattened_xml_map_with_xml_namespace_output_struct() -> decode.Decoder(FlattenedXmlMapWithXmlNamespaceOutput) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(FlattenedXmlMapWithXmlNamespaceOutput(
    my_map: my_map,
  ))
}

pub fn decode_flattened_xml_map_with_xml_namespace_output_struct_params() -> decode.Decoder(FlattenedXmlMapWithXmlNamespaceOutput) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(FlattenedXmlMapWithXmlNamespaceOutput(
    my_map: my_map,
  ))
}

pub fn encode_flattened_xml_map_with_xml_namespace_output_xml_inner(input: FlattenedXmlMapWithXmlNamespaceOutput) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_flattened_xml_map_with_xml_namespace_output_xml(input: FlattenedXmlMapWithXmlNamespaceOutput, root: String) -> String {
  xml.element(root, encode_flattened_xml_map_with_xml_namespace_output_xml_inner(input))
}

pub fn decode_flattened_xml_map_with_xml_namespace_output_xml(elem: xml_decode.Element) -> Result(FlattenedXmlMapWithXmlNamespaceOutput, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, String)), String) = Ok(option.None)
    r })
  Ok(FlattenedXmlMapWithXmlNamespaceOutput(
    my_map: my_map,
  ))
}

pub type FractionalSecondsOutput {
  FractionalSecondsOutput(datetime: option.Option(Int))
}

pub fn encode_fractional_seconds_output_struct(input: FractionalSecondsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.datetime {
    option.Some(v) -> [#("datetime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_fractional_seconds_output_struct() -> decode.Decoder(FractionalSecondsOutput) {
  use <- decode.recursive
  use datetime <- decode.optional_field("datetime", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(FractionalSecondsOutput(
    datetime: datetime,
  ))
}

pub fn decode_fractional_seconds_output_struct_params() -> decode.Decoder(FractionalSecondsOutput) {
  use <- decode.recursive
  use datetime <- decode.optional_field("datetime", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(FractionalSecondsOutput(
    datetime: datetime,
  ))
}

pub fn encode_fractional_seconds_output_xml_inner(input: FractionalSecondsOutput) -> String {
  let inner = ""
  let inner = case input.datetime {
    option.Some(v) -> inner <> xml.element("datetime", xml.int_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_fractional_seconds_output_xml(input: FractionalSecondsOutput, root: String) -> String {
  xml.element(root, encode_fractional_seconds_output_xml_inner(input))
}

pub fn decode_fractional_seconds_output_xml(elem: xml_decode.Element) -> Result(FractionalSecondsOutput, String) {
  use datetime <- result.try(xml_decode.optional_child(elem, "datetime", xml_decode.timestamp_text))
  Ok(FractionalSecondsOutput(
    datetime: datetime,
  ))
}

pub type GreetingWithErrorsOutput {
  GreetingWithErrorsOutput(greeting: option.Option(String))
}

pub fn encode_greeting_with_errors_output_struct(input: GreetingWithErrorsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_greeting_with_errors_output_struct() -> decode.Decoder(GreetingWithErrorsOutput) {
  use <- decode.recursive
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  decode.success(GreetingWithErrorsOutput(
    greeting: greeting,
  ))
}

pub fn decode_greeting_with_errors_output_struct_params() -> decode.Decoder(GreetingWithErrorsOutput) {
  use <- decode.recursive
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  decode.success(GreetingWithErrorsOutput(
    greeting: greeting,
  ))
}

pub fn encode_greeting_with_errors_output_xml_inner(input: GreetingWithErrorsOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_greeting_with_errors_output_xml(input: GreetingWithErrorsOutput, root: String) -> String {
  xml.element(root, encode_greeting_with_errors_output_xml_inner(input))
}

pub fn decode_greeting_with_errors_output_xml(elem: xml_decode.Element) -> Result(GreetingWithErrorsOutput, String) {
  let greeting = option.None
  Ok(GreetingWithErrorsOutput(
    greeting: greeting,
  ))
}

pub type ComplexError {
  ComplexError(header: option.Option(String), nested: option.Option(ComplexNestedErrorData), top_level: option.Option(String))
}

pub fn encode_complex_error_struct(input: ComplexError) -> json.Json {
  let pairs = []
  let pairs = case input.header {
    option.Some(v) -> [#("Header", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested {
    option.Some(v) -> [#("Nested", encode_complex_nested_error_data_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.top_level {
    option.Some(v) -> [#("TopLevel", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_complex_error_struct() -> decode.Decoder(ComplexError) {
  use <- decode.recursive
  use header <- decode.optional_field("Header", option.None, decode.optional(decode.string))
  use nested <- decode.optional_field("Nested", option.None, decode.optional(decode_complex_nested_error_data_struct()))
  use top_level <- decode.optional_field("TopLevel", option.None, decode.optional(decode.string))
  decode.success(ComplexError(
    header: header,
    nested: nested,
    top_level: top_level,
  ))
}

pub fn decode_complex_error_struct_params() -> decode.Decoder(ComplexError) {
  use <- decode.recursive
  use header <- decode.optional_field("Header", option.None, decode.optional(decode.string))
  use nested <- decode.optional_field("Nested", option.None, decode.optional(decode_complex_nested_error_data_struct_params()))
  use top_level <- decode.optional_field("TopLevel", option.None, decode.optional(decode.string))
  decode.success(ComplexError(
    header: header,
    nested: nested,
    top_level: top_level,
  ))
}

pub fn encode_complex_error_xml_inner(input: ComplexError) -> String {
  let inner = ""
  let inner = case input.nested {
    option.Some(v) -> inner <> encode_complex_nested_error_data_xml(v, "Nested")
    option.None -> inner
  }
  let inner = case input.top_level {
    option.Some(v) -> inner <> xml.element("TopLevel", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_complex_error_xml(input: ComplexError, root: String) -> String {
  xml.element(root, encode_complex_error_xml_inner(input))
}

pub fn decode_complex_error_xml(elem: xml_decode.Element) -> Result(ComplexError, String) {
  let header = option.None
  use nested <- result.try(xml_decode.optional_child(elem, "Nested", decode_complex_nested_error_data_xml))
  use top_level <- result.try(xml_decode.optional_child(elem, "TopLevel", xml_decode.string_text))
  Ok(ComplexError(
    header: header,
    nested: nested,
    top_level: top_level,
  ))
}

pub type ComplexNestedErrorData {
  ComplexNestedErrorData(foo: option.Option(String))
}

pub fn encode_complex_nested_error_data_struct(input: ComplexNestedErrorData) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("Foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_complex_nested_error_data_struct() -> decode.Decoder(ComplexNestedErrorData) {
  use <- decode.recursive
  use foo <- decode.optional_field("Foo", option.None, decode.optional(decode.string))
  decode.success(ComplexNestedErrorData(
    foo: foo,
  ))
}

pub fn decode_complex_nested_error_data_struct_params() -> decode.Decoder(ComplexNestedErrorData) {
  use <- decode.recursive
  use foo <- decode.optional_field("Foo", option.None, decode.optional(decode.string))
  decode.success(ComplexNestedErrorData(
    foo: foo,
  ))
}

pub fn encode_complex_nested_error_data_xml_inner(input: ComplexNestedErrorData) -> String {
  let inner = ""
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("Foo", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_complex_nested_error_data_xml(input: ComplexNestedErrorData, root: String) -> String {
  xml.element(root, encode_complex_nested_error_data_xml_inner(input))
}

pub fn decode_complex_nested_error_data_xml(elem: xml_decode.Element) -> Result(ComplexNestedErrorData, String) {
  use foo <- result.try(xml_decode.optional_child(elem, "Foo", xml_decode.string_text))
  Ok(ComplexNestedErrorData(
    foo: foo,
  ))
}

pub type InvalidGreeting {
  InvalidGreeting(message: option.Option(String))
}

pub fn encode_invalid_greeting_struct(input: InvalidGreeting) -> json.Json {
  let pairs = []
  let pairs = case input.message {
    option.Some(v) -> [#("Message", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_invalid_greeting_struct() -> decode.Decoder(InvalidGreeting) {
  use <- decode.recursive
  use message <- decode.optional_field("Message", option.None, decode.optional(decode.string))
  decode.success(InvalidGreeting(
    message: message,
  ))
}

pub fn decode_invalid_greeting_struct_params() -> decode.Decoder(InvalidGreeting) {
  use <- decode.recursive
  use message <- decode.optional_field("Message", option.None, decode.optional(decode.string))
  decode.success(InvalidGreeting(
    message: message,
  ))
}

pub fn encode_invalid_greeting_xml_inner(input: InvalidGreeting) -> String {
  let inner = ""
  let inner = case input.message {
    option.Some(v) -> inner <> xml.element("Message", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_invalid_greeting_xml(input: InvalidGreeting, root: String) -> String {
  xml.element(root, encode_invalid_greeting_xml_inner(input))
}

pub fn decode_invalid_greeting_xml(elem: xml_decode.Element) -> Result(InvalidGreeting, String) {
  use message <- result.try(xml_decode.optional_child(elem, "Message", xml_decode.string_text))
  Ok(InvalidGreeting(
    message: message,
  ))
}

pub type HttpEmptyPrefixHeadersInput {
  HttpEmptyPrefixHeadersInput(prefix_headers: option.Option(dict.Dict(String, String)), specific_header: option.Option(String))
}

pub fn encode_http_empty_prefix_headers_input_struct(input: HttpEmptyPrefixHeadersInput) -> json.Json {
  let pairs = []
  let pairs = case input.prefix_headers {
    option.Some(v) -> [#("prefixHeaders", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.specific_header {
    option.Some(v) -> [#("specificHeader", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_empty_prefix_headers_input_struct() -> decode.Decoder(HttpEmptyPrefixHeadersInput) {
  use <- decode.recursive
  use prefix_headers <- decode.optional_field("prefixHeaders", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use specific_header <- decode.optional_field("specificHeader", option.None, decode.optional(decode.string))
  decode.success(HttpEmptyPrefixHeadersInput(
    prefix_headers: prefix_headers,
    specific_header: specific_header,
  ))
}

pub fn decode_http_empty_prefix_headers_input_struct_params() -> decode.Decoder(HttpEmptyPrefixHeadersInput) {
  use <- decode.recursive
  use prefix_headers <- decode.optional_field("prefixHeaders", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use specific_header <- decode.optional_field("specificHeader", option.None, decode.optional(decode.string))
  decode.success(HttpEmptyPrefixHeadersInput(
    prefix_headers: prefix_headers,
    specific_header: specific_header,
  ))
}

pub fn encode_http_empty_prefix_headers_input_xml_inner(input: HttpEmptyPrefixHeadersInput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_empty_prefix_headers_input_xml(input: HttpEmptyPrefixHeadersInput, root: String) -> String {
  xml.element(root, encode_http_empty_prefix_headers_input_xml_inner(input))
}

pub fn decode_http_empty_prefix_headers_input_xml(elem: xml_decode.Element) -> Result(HttpEmptyPrefixHeadersInput, String) {
  let prefix_headers = option.None
  let specific_header = option.None
  Ok(HttpEmptyPrefixHeadersInput(
    prefix_headers: prefix_headers,
    specific_header: specific_header,
  ))
}

pub type HttpEmptyPrefixHeadersOutput {
  HttpEmptyPrefixHeadersOutput(prefix_headers: option.Option(dict.Dict(String, String)), specific_header: option.Option(String))
}

pub fn encode_http_empty_prefix_headers_output_struct(input: HttpEmptyPrefixHeadersOutput) -> json.Json {
  let pairs = []
  let pairs = case input.prefix_headers {
    option.Some(v) -> [#("prefixHeaders", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.specific_header {
    option.Some(v) -> [#("specificHeader", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_empty_prefix_headers_output_struct() -> decode.Decoder(HttpEmptyPrefixHeadersOutput) {
  use <- decode.recursive
  use prefix_headers <- decode.optional_field("prefixHeaders", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use specific_header <- decode.optional_field("specificHeader", option.None, decode.optional(decode.string))
  decode.success(HttpEmptyPrefixHeadersOutput(
    prefix_headers: prefix_headers,
    specific_header: specific_header,
  ))
}

pub fn decode_http_empty_prefix_headers_output_struct_params() -> decode.Decoder(HttpEmptyPrefixHeadersOutput) {
  use <- decode.recursive
  use prefix_headers <- decode.optional_field("prefixHeaders", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use specific_header <- decode.optional_field("specificHeader", option.None, decode.optional(decode.string))
  decode.success(HttpEmptyPrefixHeadersOutput(
    prefix_headers: prefix_headers,
    specific_header: specific_header,
  ))
}

pub fn encode_http_empty_prefix_headers_output_xml_inner(input: HttpEmptyPrefixHeadersOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_empty_prefix_headers_output_xml(input: HttpEmptyPrefixHeadersOutput, root: String) -> String {
  xml.element(root, encode_http_empty_prefix_headers_output_xml_inner(input))
}

pub fn decode_http_empty_prefix_headers_output_xml(elem: xml_decode.Element) -> Result(HttpEmptyPrefixHeadersOutput, String) {
  let prefix_headers = option.None
  let specific_header = option.None
  Ok(HttpEmptyPrefixHeadersOutput(
    prefix_headers: prefix_headers,
    specific_header: specific_header,
  ))
}

pub type EnumPayloadInput {
  EnumPayloadInput(payload: option.Option(StringEnum))
}

pub fn encode_enum_payload_input_struct(input: EnumPayloadInput) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", encode_string_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_enum_payload_input_struct() -> decode.Decoder(EnumPayloadInput) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_string_enum_enum()))
  decode.success(EnumPayloadInput(
    payload: payload,
  ))
}

pub fn decode_enum_payload_input_struct_params() -> decode.Decoder(EnumPayloadInput) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_string_enum_enum()))
  decode.success(EnumPayloadInput(
    payload: payload,
  ))
}

pub fn encode_enum_payload_input_xml_inner(input: EnumPayloadInput) -> String {
  let inner = ""
  inner
}

pub fn encode_enum_payload_input_xml(input: EnumPayloadInput, root: String) -> String {
  xml.element(root, encode_enum_payload_input_xml_inner(input))
}

pub fn decode_enum_payload_input_xml(elem: xml_decode.Element) -> Result(EnumPayloadInput, String) {
  let payload = option.None
  Ok(EnumPayloadInput(
    payload: payload,
  ))
}

pub type StringEnum {
  StringEnumV
}

pub fn encode_string_enum_enum(v: StringEnum) -> json.Json {
  case v {
    StringEnumV -> json.string("enumvalue")
  }
}

pub fn decode_string_enum_enum() -> decode.Decoder(StringEnum) {
  decode.then(decode.string, fn(s) {
    case s {
      "enumvalue" -> decode.success(StringEnumV)
      _ -> decode.failure(StringEnumV, "unknown enum value")
    }
  })
}

pub type HttpPayloadTraitsInputOutput {
  HttpPayloadTraitsInputOutput(blob: option.Option(BitArray), foo: option.Option(String))
}

pub fn encode_http_payload_traits_input_output_struct(input: HttpPayloadTraitsInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [#("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_traits_input_output_struct() -> decode.Decoder(HttpPayloadTraitsInputOutput) {
  use <- decode.recursive
  use blob <- decode.optional_field("blob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(HttpPayloadTraitsInputOutput(
    blob: blob,
    foo: foo,
  ))
}

pub fn decode_http_payload_traits_input_output_struct_params() -> decode.Decoder(HttpPayloadTraitsInputOutput) {
  use <- decode.recursive
  use blob <- decode.optional_field("blob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(HttpPayloadTraitsInputOutput(
    blob: blob,
    foo: foo,
  ))
}

pub fn encode_http_payload_traits_input_output_xml_inner(input: HttpPayloadTraitsInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_traits_input_output_xml(input: HttpPayloadTraitsInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_traits_input_output_xml_inner(input))
}

pub fn decode_http_payload_traits_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadTraitsInputOutput, String) {
  let blob = option.None
  let foo = option.None
  Ok(HttpPayloadTraitsInputOutput(
    blob: blob,
    foo: foo,
  ))
}

pub type HttpPayloadTraitsWithMediaTypeInputOutput {
  HttpPayloadTraitsWithMediaTypeInputOutput(blob: option.Option(BitArray), foo: option.Option(String))
}

pub fn encode_http_payload_traits_with_media_type_input_output_struct(input: HttpPayloadTraitsWithMediaTypeInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [#("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_traits_with_media_type_input_output_struct() -> decode.Decoder(HttpPayloadTraitsWithMediaTypeInputOutput) {
  use <- decode.recursive
  use blob <- decode.optional_field("blob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(HttpPayloadTraitsWithMediaTypeInputOutput(
    blob: blob,
    foo: foo,
  ))
}

pub fn decode_http_payload_traits_with_media_type_input_output_struct_params() -> decode.Decoder(HttpPayloadTraitsWithMediaTypeInputOutput) {
  use <- decode.recursive
  use blob <- decode.optional_field("blob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(HttpPayloadTraitsWithMediaTypeInputOutput(
    blob: blob,
    foo: foo,
  ))
}

pub fn encode_http_payload_traits_with_media_type_input_output_xml_inner(input: HttpPayloadTraitsWithMediaTypeInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_traits_with_media_type_input_output_xml(input: HttpPayloadTraitsWithMediaTypeInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_traits_with_media_type_input_output_xml_inner(input))
}

pub fn decode_http_payload_traits_with_media_type_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, String) {
  let blob = option.None
  let foo = option.None
  Ok(HttpPayloadTraitsWithMediaTypeInputOutput(
    blob: blob,
    foo: foo,
  ))
}

pub type HttpPayloadWithMemberXmlNameInputOutput {
  HttpPayloadWithMemberXmlNameInputOutput(nested: option.Option(PayloadWithXmlName))
}

pub fn encode_http_payload_with_member_xml_name_input_output_struct(input: HttpPayloadWithMemberXmlNameInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_payload_with_xml_name_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_member_xml_name_input_output_struct() -> decode.Decoder(HttpPayloadWithMemberXmlNameInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_name_struct()))
  decode.success(HttpPayloadWithMemberXmlNameInputOutput(
    nested: nested,
  ))
}

pub fn decode_http_payload_with_member_xml_name_input_output_struct_params() -> decode.Decoder(HttpPayloadWithMemberXmlNameInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_name_struct_params()))
  decode.success(HttpPayloadWithMemberXmlNameInputOutput(
    nested: nested,
  ))
}

pub fn encode_http_payload_with_member_xml_name_input_output_xml_inner(input: HttpPayloadWithMemberXmlNameInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_with_member_xml_name_input_output_xml(input: HttpPayloadWithMemberXmlNameInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_with_member_xml_name_input_output_xml_inner(input))
}

pub fn decode_http_payload_with_member_xml_name_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadWithMemberXmlNameInputOutput, String) {
  let nested = option.None
  Ok(HttpPayloadWithMemberXmlNameInputOutput(
    nested: nested,
  ))
}

pub type HttpPayloadWithStructureInputOutput {
  HttpPayloadWithStructureInputOutput(nested: option.Option(NestedPayload))
}

pub fn encode_http_payload_with_structure_input_output_struct(input: HttpPayloadWithStructureInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_nested_payload_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_structure_input_output_struct() -> decode.Decoder(HttpPayloadWithStructureInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_nested_payload_struct()))
  decode.success(HttpPayloadWithStructureInputOutput(
    nested: nested,
  ))
}

pub fn decode_http_payload_with_structure_input_output_struct_params() -> decode.Decoder(HttpPayloadWithStructureInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_nested_payload_struct_params()))
  decode.success(HttpPayloadWithStructureInputOutput(
    nested: nested,
  ))
}

pub fn encode_http_payload_with_structure_input_output_xml_inner(input: HttpPayloadWithStructureInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_with_structure_input_output_xml(input: HttpPayloadWithStructureInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_with_structure_input_output_xml_inner(input))
}

pub fn decode_http_payload_with_structure_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadWithStructureInputOutput, String) {
  let nested = option.None
  Ok(HttpPayloadWithStructureInputOutput(
    nested: nested,
  ))
}

pub type NestedPayload {
  NestedPayload(greeting: option.Option(String), name: option.Option(String))
}

pub fn encode_nested_payload_struct(input: NestedPayload) -> json.Json {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.name {
    option.Some(v) -> [#("name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_nested_payload_struct() -> decode.Decoder(NestedPayload) {
  use <- decode.recursive
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(NestedPayload(
    greeting: greeting,
    name: name,
  ))
}

pub fn decode_nested_payload_struct_params() -> decode.Decoder(NestedPayload) {
  use <- decode.recursive
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(NestedPayload(
    greeting: greeting,
    name: name,
  ))
}

pub fn encode_nested_payload_xml_inner(input: NestedPayload) -> String {
  let inner = ""
  let inner = case input.greeting {
    option.Some(v) -> inner <> xml.element("greeting", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.name {
    option.Some(v) -> inner <> xml.element("name", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_nested_payload_xml(input: NestedPayload, root: String) -> String {
  xml.element(root, encode_nested_payload_xml_inner(input))
}

pub fn decode_nested_payload_xml(elem: xml_decode.Element) -> Result(NestedPayload, String) {
  use greeting <- result.try(xml_decode.optional_child(elem, "greeting", xml_decode.string_text))
  use name <- result.try(xml_decode.optional_child(elem, "name", xml_decode.string_text))
  Ok(NestedPayload(
    greeting: greeting,
    name: name,
  ))
}

pub type HttpPayloadWithUnionInputOutput {
  HttpPayloadWithUnionInputOutput(nested: option.Option(UnionPayload))
}

pub fn encode_http_payload_with_union_input_output_struct(input: HttpPayloadWithUnionInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_union_payload_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_union_input_output_struct() -> decode.Decoder(HttpPayloadWithUnionInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_union_payload_union()))
  decode.success(HttpPayloadWithUnionInputOutput(
    nested: nested,
  ))
}

pub fn decode_http_payload_with_union_input_output_struct_params() -> decode.Decoder(HttpPayloadWithUnionInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_union_payload_union_params()))
  decode.success(HttpPayloadWithUnionInputOutput(
    nested: nested,
  ))
}

pub fn encode_http_payload_with_union_input_output_xml_inner(input: HttpPayloadWithUnionInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_with_union_input_output_xml(input: HttpPayloadWithUnionInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_with_union_input_output_xml_inner(input))
}

pub fn decode_http_payload_with_union_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadWithUnionInputOutput, String) {
  let nested = option.None
  Ok(HttpPayloadWithUnionInputOutput(
    nested: nested,
  ))
}

pub type UnionPayload {
  UnionPayloadGreeting(String)
}

pub fn encode_union_payload_union(v: UnionPayload) -> json.Json {
  case v {
    UnionPayloadGreeting(x) -> json.object([#("greeting", json.string(x))])
  }
}

pub fn decode_union_payload_union() -> decode.Decoder(UnionPayload) {
  use <- decode.recursive
  decode.one_of(
    decode.field("greeting", decode.string, fn(x) { decode.success(UnionPayloadGreeting(x)) }),
    [
    ],
  )
}

pub fn decode_union_payload_union_params() -> decode.Decoder(UnionPayload) {
  use <- decode.recursive
  decode.one_of(
    decode.field("greeting", decode.string, fn(x) { decode.success(UnionPayloadGreeting(x)) }),
    [
    ],
  )
}

pub type HttpPayloadWithXmlNameInputOutput {
  HttpPayloadWithXmlNameInputOutput(nested: option.Option(PayloadWithXmlName))
}

pub fn encode_http_payload_with_xml_name_input_output_struct(input: HttpPayloadWithXmlNameInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_payload_with_xml_name_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_xml_name_input_output_struct() -> decode.Decoder(HttpPayloadWithXmlNameInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_name_struct()))
  decode.success(HttpPayloadWithXmlNameInputOutput(
    nested: nested,
  ))
}

pub fn decode_http_payload_with_xml_name_input_output_struct_params() -> decode.Decoder(HttpPayloadWithXmlNameInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_name_struct_params()))
  decode.success(HttpPayloadWithXmlNameInputOutput(
    nested: nested,
  ))
}

pub fn encode_http_payload_with_xml_name_input_output_xml_inner(input: HttpPayloadWithXmlNameInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_with_xml_name_input_output_xml(input: HttpPayloadWithXmlNameInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_with_xml_name_input_output_xml_inner(input))
}

pub fn decode_http_payload_with_xml_name_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadWithXmlNameInputOutput, String) {
  let nested = option.None
  Ok(HttpPayloadWithXmlNameInputOutput(
    nested: nested,
  ))
}

pub type HttpPayloadWithXmlNamespaceInputOutput {
  HttpPayloadWithXmlNamespaceInputOutput(nested: option.Option(PayloadWithXmlNamespace))
}

pub fn encode_http_payload_with_xml_namespace_input_output_struct(input: HttpPayloadWithXmlNamespaceInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_payload_with_xml_namespace_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_xml_namespace_input_output_struct() -> decode.Decoder(HttpPayloadWithXmlNamespaceInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_namespace_struct()))
  decode.success(HttpPayloadWithXmlNamespaceInputOutput(
    nested: nested,
  ))
}

pub fn decode_http_payload_with_xml_namespace_input_output_struct_params() -> decode.Decoder(HttpPayloadWithXmlNamespaceInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_namespace_struct_params()))
  decode.success(HttpPayloadWithXmlNamespaceInputOutput(
    nested: nested,
  ))
}

pub fn encode_http_payload_with_xml_namespace_input_output_xml_inner(input: HttpPayloadWithXmlNamespaceInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_with_xml_namespace_input_output_xml(input: HttpPayloadWithXmlNamespaceInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_with_xml_namespace_input_output_xml_inner(input))
}

pub fn decode_http_payload_with_xml_namespace_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadWithXmlNamespaceInputOutput, String) {
  let nested = option.None
  Ok(HttpPayloadWithXmlNamespaceInputOutput(
    nested: nested,
  ))
}

pub type PayloadWithXmlNamespace {
  PayloadWithXmlNamespace(name: option.Option(String))
}

pub fn encode_payload_with_xml_namespace_struct(input: PayloadWithXmlNamespace) -> json.Json {
  let pairs = []
  let pairs = case input.name {
    option.Some(v) -> [#("name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_payload_with_xml_namespace_struct() -> decode.Decoder(PayloadWithXmlNamespace) {
  use <- decode.recursive
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(PayloadWithXmlNamespace(
    name: name,
  ))
}

pub fn decode_payload_with_xml_namespace_struct_params() -> decode.Decoder(PayloadWithXmlNamespace) {
  use <- decode.recursive
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(PayloadWithXmlNamespace(
    name: name,
  ))
}

pub fn encode_payload_with_xml_namespace_xml_inner(input: PayloadWithXmlNamespace) -> String {
  let inner = ""
  let inner = case input.name {
    option.Some(v) -> inner <> xml.element("name", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_payload_with_xml_namespace_xml(input: PayloadWithXmlNamespace, root: String) -> String {
  xml.element(root, encode_payload_with_xml_namespace_xml_inner(input))
}

pub fn decode_payload_with_xml_namespace_xml(elem: xml_decode.Element) -> Result(PayloadWithXmlNamespace, String) {
  use name <- result.try(xml_decode.optional_child(elem, "name", xml_decode.string_text))
  Ok(PayloadWithXmlNamespace(
    name: name,
  ))
}

pub type HttpPayloadWithXmlNamespaceAndPrefixInputOutput {
  HttpPayloadWithXmlNamespaceAndPrefixInputOutput(nested: option.Option(PayloadWithXmlNamespaceAndPrefix))
}

pub fn encode_http_payload_with_xml_namespace_and_prefix_input_output_struct(input: HttpPayloadWithXmlNamespaceAndPrefixInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_payload_with_xml_namespace_and_prefix_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_xml_namespace_and_prefix_input_output_struct() -> decode.Decoder(HttpPayloadWithXmlNamespaceAndPrefixInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_namespace_and_prefix_struct()))
  decode.success(HttpPayloadWithXmlNamespaceAndPrefixInputOutput(
    nested: nested,
  ))
}

pub fn decode_http_payload_with_xml_namespace_and_prefix_input_output_struct_params() -> decode.Decoder(HttpPayloadWithXmlNamespaceAndPrefixInputOutput) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_payload_with_xml_namespace_and_prefix_struct_params()))
  decode.success(HttpPayloadWithXmlNamespaceAndPrefixInputOutput(
    nested: nested,
  ))
}

pub fn encode_http_payload_with_xml_namespace_and_prefix_input_output_xml_inner(input: HttpPayloadWithXmlNamespaceAndPrefixInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_payload_with_xml_namespace_and_prefix_input_output_xml(input: HttpPayloadWithXmlNamespaceAndPrefixInputOutput, root: String) -> String {
  xml.element(root, encode_http_payload_with_xml_namespace_and_prefix_input_output_xml_inner(input))
}

pub fn decode_http_payload_with_xml_namespace_and_prefix_input_output_xml(elem: xml_decode.Element) -> Result(HttpPayloadWithXmlNamespaceAndPrefixInputOutput, String) {
  let nested = option.None
  Ok(HttpPayloadWithXmlNamespaceAndPrefixInputOutput(
    nested: nested,
  ))
}

pub type PayloadWithXmlNamespaceAndPrefix {
  PayloadWithXmlNamespaceAndPrefix(name: option.Option(String))
}

pub fn encode_payload_with_xml_namespace_and_prefix_struct(input: PayloadWithXmlNamespaceAndPrefix) -> json.Json {
  let pairs = []
  let pairs = case input.name {
    option.Some(v) -> [#("name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_payload_with_xml_namespace_and_prefix_struct() -> decode.Decoder(PayloadWithXmlNamespaceAndPrefix) {
  use <- decode.recursive
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(PayloadWithXmlNamespaceAndPrefix(
    name: name,
  ))
}

pub fn decode_payload_with_xml_namespace_and_prefix_struct_params() -> decode.Decoder(PayloadWithXmlNamespaceAndPrefix) {
  use <- decode.recursive
  use name <- decode.optional_field("name", option.None, decode.optional(decode.string))
  decode.success(PayloadWithXmlNamespaceAndPrefix(
    name: name,
  ))
}

pub fn encode_payload_with_xml_namespace_and_prefix_xml_inner(input: PayloadWithXmlNamespaceAndPrefix) -> String {
  let inner = ""
  let inner = case input.name {
    option.Some(v) -> inner <> xml.element("name", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_payload_with_xml_namespace_and_prefix_xml(input: PayloadWithXmlNamespaceAndPrefix, root: String) -> String {
  xml.element(root, encode_payload_with_xml_namespace_and_prefix_xml_inner(input))
}

pub fn decode_payload_with_xml_namespace_and_prefix_xml(elem: xml_decode.Element) -> Result(PayloadWithXmlNamespaceAndPrefix, String) {
  use name <- result.try(xml_decode.optional_child(elem, "name", xml_decode.string_text))
  Ok(PayloadWithXmlNamespaceAndPrefix(
    name: name,
  ))
}

pub type HttpPrefixHeadersInputOutput {
  HttpPrefixHeadersInputOutput(foo: option.Option(String), foo_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_http_prefix_headers_input_output_struct(input: HttpPrefixHeadersInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_map {
    option.Some(v) -> [#("fooMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_prefix_headers_input_output_struct() -> decode.Decoder(HttpPrefixHeadersInputOutput) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use foo_map <- decode.optional_field("fooMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(HttpPrefixHeadersInputOutput(
    foo: foo,
    foo_map: foo_map,
  ))
}

pub fn decode_http_prefix_headers_input_output_struct_params() -> decode.Decoder(HttpPrefixHeadersInputOutput) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use foo_map <- decode.optional_field("fooMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(HttpPrefixHeadersInputOutput(
    foo: foo,
    foo_map: foo_map,
  ))
}

pub fn encode_http_prefix_headers_input_output_xml_inner(input: HttpPrefixHeadersInputOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_prefix_headers_input_output_xml(input: HttpPrefixHeadersInputOutput, root: String) -> String {
  xml.element(root, encode_http_prefix_headers_input_output_xml_inner(input))
}

pub fn decode_http_prefix_headers_input_output_xml(elem: xml_decode.Element) -> Result(HttpPrefixHeadersInputOutput, String) {
  let foo = option.None
  let foo_map = option.None
  Ok(HttpPrefixHeadersInputOutput(
    foo: foo,
    foo_map: foo_map,
  ))
}

pub type HttpRequestWithFloatLabelsInput {
  HttpRequestWithFloatLabelsInput(double: option.Option(json_float.SmithyFloat), float: option.Option(json_float.SmithyFloat))
}

pub fn encode_http_request_with_float_labels_input_struct(input: HttpRequestWithFloatLabelsInput) -> json.Json {
  let pairs = []
  let pairs = case input.double {
    option.Some(v) -> [#("double", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float {
    option.Some(v) -> [#("float", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_request_with_float_labels_input_struct() -> decode.Decoder(HttpRequestWithFloatLabelsInput) {
  use <- decode.recursive
  use double <- decode.optional_field("double", option.None, decode.optional(json_float.decoder()))
  use float <- decode.optional_field("float", option.None, decode.optional(json_float.decoder()))
  decode.success(HttpRequestWithFloatLabelsInput(
    double: double,
    float: float,
  ))
}

pub fn decode_http_request_with_float_labels_input_struct_params() -> decode.Decoder(HttpRequestWithFloatLabelsInput) {
  use <- decode.recursive
  use double <- decode.optional_field("double", option.None, decode.optional(json_float.decoder()))
  use float <- decode.optional_field("float", option.None, decode.optional(json_float.decoder()))
  decode.success(HttpRequestWithFloatLabelsInput(
    double: double,
    float: float,
  ))
}

pub fn encode_http_request_with_float_labels_input_xml_inner(input: HttpRequestWithFloatLabelsInput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_request_with_float_labels_input_xml(input: HttpRequestWithFloatLabelsInput, root: String) -> String {
  xml.element(root, encode_http_request_with_float_labels_input_xml_inner(input))
}

pub fn decode_http_request_with_float_labels_input_xml(elem: xml_decode.Element) -> Result(HttpRequestWithFloatLabelsInput, String) {
  let double = option.None
  let float = option.None
  Ok(HttpRequestWithFloatLabelsInput(
    double: double,
    float: float,
  ))
}

pub type HttpRequestWithGreedyLabelInPathInput {
  HttpRequestWithGreedyLabelInPathInput(baz: option.Option(String), foo: option.Option(String))
}

pub fn encode_http_request_with_greedy_label_in_path_input_struct(input: HttpRequestWithGreedyLabelInPathInput) -> json.Json {
  let pairs = []
  let pairs = case input.baz {
    option.Some(v) -> [#("baz", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_request_with_greedy_label_in_path_input_struct() -> decode.Decoder(HttpRequestWithGreedyLabelInPathInput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(HttpRequestWithGreedyLabelInPathInput(
    baz: baz,
    foo: foo,
  ))
}

pub fn decode_http_request_with_greedy_label_in_path_input_struct_params() -> decode.Decoder(HttpRequestWithGreedyLabelInPathInput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(HttpRequestWithGreedyLabelInPathInput(
    baz: baz,
    foo: foo,
  ))
}

pub fn encode_http_request_with_greedy_label_in_path_input_xml_inner(input: HttpRequestWithGreedyLabelInPathInput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_request_with_greedy_label_in_path_input_xml(input: HttpRequestWithGreedyLabelInPathInput, root: String) -> String {
  xml.element(root, encode_http_request_with_greedy_label_in_path_input_xml_inner(input))
}

pub fn decode_http_request_with_greedy_label_in_path_input_xml(elem: xml_decode.Element) -> Result(HttpRequestWithGreedyLabelInPathInput, String) {
  let baz = option.None
  let foo = option.None
  Ok(HttpRequestWithGreedyLabelInPathInput(
    baz: baz,
    foo: foo,
  ))
}

pub type HttpRequestWithLabelsInput {
  HttpRequestWithLabelsInput(boolean: option.Option(Bool), double: option.Option(json_float.SmithyFloat), float: option.Option(json_float.SmithyFloat), integer: option.Option(Int), long: option.Option(Int), short: option.Option(Int), string: option.Option(String), timestamp: option.Option(Int))
}

pub fn encode_http_request_with_labels_input_struct(input: HttpRequestWithLabelsInput) -> json.Json {
  let pairs = []
  let pairs = case input.boolean {
    option.Some(v) -> [#("boolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double {
    option.Some(v) -> [#("double", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float {
    option.Some(v) -> [#("float", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer {
    option.Some(v) -> [#("integer", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long {
    option.Some(v) -> [#("long", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short {
    option.Some(v) -> [#("short", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string {
    option.Some(v) -> [#("string", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_request_with_labels_input_struct() -> decode.Decoder(HttpRequestWithLabelsInput) {
  use <- decode.recursive
  use boolean <- decode.optional_field("boolean", option.None, decode.optional(decode.bool))
  use double <- decode.optional_field("double", option.None, decode.optional(json_float.decoder()))
  use float <- decode.optional_field("float", option.None, decode.optional(json_float.decoder()))
  use integer <- decode.optional_field("integer", option.None, decode.optional(decode.int))
  use long <- decode.optional_field("long", option.None, decode.optional(decode.int))
  use short <- decode.optional_field("short", option.None, decode.optional(decode.int))
  use string <- decode.optional_field("string", option.None, decode.optional(decode.string))
  use timestamp <- decode.optional_field("timestamp", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(HttpRequestWithLabelsInput(
    boolean: boolean,
    double: double,
    float: float,
    integer: integer,
    long: long,
    short: short,
    string: string,
    timestamp: timestamp,
  ))
}

pub fn decode_http_request_with_labels_input_struct_params() -> decode.Decoder(HttpRequestWithLabelsInput) {
  use <- decode.recursive
  use boolean <- decode.optional_field("boolean", option.None, decode.optional(decode.bool))
  use double <- decode.optional_field("double", option.None, decode.optional(json_float.decoder()))
  use float <- decode.optional_field("float", option.None, decode.optional(json_float.decoder()))
  use integer <- decode.optional_field("integer", option.None, decode.optional(decode.int))
  use long <- decode.optional_field("long", option.None, decode.optional(decode.int))
  use short <- decode.optional_field("short", option.None, decode.optional(decode.int))
  use string <- decode.optional_field("string", option.None, decode.optional(decode.string))
  use timestamp <- decode.optional_field("timestamp", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(HttpRequestWithLabelsInput(
    boolean: boolean,
    double: double,
    float: float,
    integer: integer,
    long: long,
    short: short,
    string: string,
    timestamp: timestamp,
  ))
}

pub fn encode_http_request_with_labels_input_xml_inner(input: HttpRequestWithLabelsInput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_request_with_labels_input_xml(input: HttpRequestWithLabelsInput, root: String) -> String {
  xml.element(root, encode_http_request_with_labels_input_xml_inner(input))
}

pub fn decode_http_request_with_labels_input_xml(elem: xml_decode.Element) -> Result(HttpRequestWithLabelsInput, String) {
  let boolean = option.None
  let double = option.None
  let float = option.None
  let integer = option.None
  let long = option.None
  let short = option.None
  let string = option.None
  let timestamp = option.None
  Ok(HttpRequestWithLabelsInput(
    boolean: boolean,
    double: double,
    float: float,
    integer: integer,
    long: long,
    short: short,
    string: string,
    timestamp: timestamp,
  ))
}

pub type HttpRequestWithLabelsAndTimestampFormatInput {
  HttpRequestWithLabelsAndTimestampFormatInput(default_format: option.Option(Int), member_date_time: option.Option(Int), member_epoch_seconds: option.Option(Int), member_http_date: option.Option(Int), target_date_time: option.Option(Int), target_epoch_seconds: option.Option(Int), target_http_date: option.Option(Int))
}

pub fn encode_http_request_with_labels_and_timestamp_format_input_struct(input: HttpRequestWithLabelsAndTimestampFormatInput) -> json.Json {
  let pairs = []
  let pairs = case input.default_format {
    option.Some(v) -> [#("defaultFormat", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_date_time {
    option.Some(v) -> [#("memberDateTime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_epoch_seconds {
    option.Some(v) -> [#("memberEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_http_date {
    option.Some(v) -> [#("memberHttpDate", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_date_time {
    option.Some(v) -> [#("targetDateTime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_epoch_seconds {
    option.Some(v) -> [#("targetEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_http_date {
    option.Some(v) -> [#("targetHttpDate", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_request_with_labels_and_timestamp_format_input_struct() -> decode.Decoder(HttpRequestWithLabelsAndTimestampFormatInput) {
  use <- decode.recursive
  use default_format <- decode.optional_field("defaultFormat", option.None, decode.optional(json_timestamp.decoder()))
  use member_date_time <- decode.optional_field("memberDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use member_epoch_seconds <- decode.optional_field("memberEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use member_http_date <- decode.optional_field("memberHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  use target_date_time <- decode.optional_field("targetDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use target_epoch_seconds <- decode.optional_field("targetEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use target_http_date <- decode.optional_field("targetHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(HttpRequestWithLabelsAndTimestampFormatInput(
    default_format: default_format,
    member_date_time: member_date_time,
    member_epoch_seconds: member_epoch_seconds,
    member_http_date: member_http_date,
    target_date_time: target_date_time,
    target_epoch_seconds: target_epoch_seconds,
    target_http_date: target_http_date,
  ))
}

pub fn decode_http_request_with_labels_and_timestamp_format_input_struct_params() -> decode.Decoder(HttpRequestWithLabelsAndTimestampFormatInput) {
  use <- decode.recursive
  use default_format <- decode.optional_field("defaultFormat", option.None, decode.optional(json_timestamp.decoder()))
  use member_date_time <- decode.optional_field("memberDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use member_epoch_seconds <- decode.optional_field("memberEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use member_http_date <- decode.optional_field("memberHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  use target_date_time <- decode.optional_field("targetDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use target_epoch_seconds <- decode.optional_field("targetEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use target_http_date <- decode.optional_field("targetHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(HttpRequestWithLabelsAndTimestampFormatInput(
    default_format: default_format,
    member_date_time: member_date_time,
    member_epoch_seconds: member_epoch_seconds,
    member_http_date: member_http_date,
    target_date_time: target_date_time,
    target_epoch_seconds: target_epoch_seconds,
    target_http_date: target_http_date,
  ))
}

pub fn encode_http_request_with_labels_and_timestamp_format_input_xml_inner(input: HttpRequestWithLabelsAndTimestampFormatInput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_request_with_labels_and_timestamp_format_input_xml(input: HttpRequestWithLabelsAndTimestampFormatInput, root: String) -> String {
  xml.element(root, encode_http_request_with_labels_and_timestamp_format_input_xml_inner(input))
}

pub fn decode_http_request_with_labels_and_timestamp_format_input_xml(elem: xml_decode.Element) -> Result(HttpRequestWithLabelsAndTimestampFormatInput, String) {
  let default_format = option.None
  let member_date_time = option.None
  let member_epoch_seconds = option.None
  let member_http_date = option.None
  let target_date_time = option.None
  let target_epoch_seconds = option.None
  let target_http_date = option.None
  Ok(HttpRequestWithLabelsAndTimestampFormatInput(
    default_format: default_format,
    member_date_time: member_date_time,
    member_epoch_seconds: member_epoch_seconds,
    member_http_date: member_http_date,
    target_date_time: target_date_time,
    target_epoch_seconds: target_epoch_seconds,
    target_http_date: target_http_date,
  ))
}

pub type HttpResponseCodeOutput {
  HttpResponseCodeOutput(status: option.Option(Int))
}

pub fn encode_http_response_code_output_struct(input: HttpResponseCodeOutput) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [#("Status", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_response_code_output_struct() -> decode.Decoder(HttpResponseCodeOutput) {
  use <- decode.recursive
  use status <- decode.optional_field("Status", option.None, decode.optional(decode.int))
  decode.success(HttpResponseCodeOutput(
    status: status,
  ))
}

pub fn decode_http_response_code_output_struct_params() -> decode.Decoder(HttpResponseCodeOutput) {
  use <- decode.recursive
  use status <- decode.optional_field("Status", option.None, decode.optional(decode.int))
  decode.success(HttpResponseCodeOutput(
    status: status,
  ))
}

pub fn encode_http_response_code_output_xml_inner(input: HttpResponseCodeOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_http_response_code_output_xml(input: HttpResponseCodeOutput, root: String) -> String {
  xml.element(root, encode_http_response_code_output_xml_inner(input))
}

pub fn decode_http_response_code_output_xml(elem: xml_decode.Element) -> Result(HttpResponseCodeOutput, String) {
  let status = option.None
  Ok(HttpResponseCodeOutput(
    status: status,
  ))
}

pub type StringPayloadInput {
  StringPayloadInput(payload: option.Option(String))
}

pub fn encode_string_payload_input_struct(input: StringPayloadInput) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_string_payload_input_struct() -> decode.Decoder(StringPayloadInput) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode.string))
  decode.success(StringPayloadInput(
    payload: payload,
  ))
}

pub fn decode_string_payload_input_struct_params() -> decode.Decoder(StringPayloadInput) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode.string))
  decode.success(StringPayloadInput(
    payload: payload,
  ))
}

pub fn encode_string_payload_input_xml_inner(input: StringPayloadInput) -> String {
  let inner = ""
  inner
}

pub fn encode_string_payload_input_xml(input: StringPayloadInput, root: String) -> String {
  xml.element(root, encode_string_payload_input_xml_inner(input))
}

pub fn decode_string_payload_input_xml(elem: xml_decode.Element) -> Result(StringPayloadInput, String) {
  let payload = option.None
  Ok(StringPayloadInput(
    payload: payload,
  ))
}

pub type IgnoreQueryParamsInResponseOutput {
  IgnoreQueryParamsInResponseOutput(baz: option.Option(String))
}

pub fn encode_ignore_query_params_in_response_output_struct(input: IgnoreQueryParamsInResponseOutput) -> json.Json {
  let pairs = []
  let pairs = case input.baz {
    option.Some(v) -> [#("baz", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_ignore_query_params_in_response_output_struct() -> decode.Decoder(IgnoreQueryParamsInResponseOutput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  decode.success(IgnoreQueryParamsInResponseOutput(
    baz: baz,
  ))
}

pub fn decode_ignore_query_params_in_response_output_struct_params() -> decode.Decoder(IgnoreQueryParamsInResponseOutput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  decode.success(IgnoreQueryParamsInResponseOutput(
    baz: baz,
  ))
}

pub fn encode_ignore_query_params_in_response_output_xml_inner(input: IgnoreQueryParamsInResponseOutput) -> String {
  let inner = ""
  inner
}

pub fn encode_ignore_query_params_in_response_output_xml(input: IgnoreQueryParamsInResponseOutput, root: String) -> String {
  xml.element(root, encode_ignore_query_params_in_response_output_xml_inner(input))
}

pub fn decode_ignore_query_params_in_response_output_xml(elem: xml_decode.Element) -> Result(IgnoreQueryParamsInResponseOutput, String) {
  let baz = option.None
  Ok(IgnoreQueryParamsInResponseOutput(
    baz: baz,
  ))
}

pub type InputAndOutputWithHeadersIO {
  InputAndOutputWithHeadersIO(header_boolean_list: option.Option(List(Bool)), header_byte: option.Option(Int), header_double: option.Option(json_float.SmithyFloat), header_enum: option.Option(FooEnum), header_enum_list: option.Option(List(FooEnum)), header_false_bool: option.Option(Bool), header_float: option.Option(json_float.SmithyFloat), header_integer: option.Option(Int), header_integer_list: option.Option(List(Int)), header_long: option.Option(Int), header_short: option.Option(Int), header_string: option.Option(String), header_string_list: option.Option(List(String)), header_string_set: option.Option(List(String)), header_timestamp_list: option.Option(List(Int)), header_true_bool: option.Option(Bool))
}

pub fn encode_input_and_output_with_headers_io_struct(input: InputAndOutputWithHeadersIO) -> json.Json {
  let pairs = []
  let pairs = case input.header_boolean_list {
    option.Some(v) -> [#("headerBooleanList", fn(xs) { json.array(xs, json.bool) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_byte {
    option.Some(v) -> [#("headerByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_double {
    option.Some(v) -> [#("headerDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_enum {
    option.Some(v) -> [#("headerEnum", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_enum_list {
    option.Some(v) -> [#("headerEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_false_bool {
    option.Some(v) -> [#("headerFalseBool", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_float {
    option.Some(v) -> [#("headerFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_integer {
    option.Some(v) -> [#("headerInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_integer_list {
    option.Some(v) -> [#("headerIntegerList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_long {
    option.Some(v) -> [#("headerLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_short {
    option.Some(v) -> [#("headerShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_string {
    option.Some(v) -> [#("headerString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_string_list {
    option.Some(v) -> [#("headerStringList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_string_set {
    option.Some(v) -> [#("headerStringSet", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_timestamp_list {
    option.Some(v) -> [#("headerTimestampList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_true_bool {
    option.Some(v) -> [#("headerTrueBool", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_input_and_output_with_headers_io_struct() -> decode.Decoder(InputAndOutputWithHeadersIO) {
  use <- decode.recursive
  use header_boolean_list <- decode.optional_field("headerBooleanList", option.None, decode.optional(decode.list(decode.bool)))
  use header_byte <- decode.optional_field("headerByte", option.None, decode.optional(decode.int))
  use header_double <- decode.optional_field("headerDouble", option.None, decode.optional(json_float.decoder()))
  use header_enum <- decode.optional_field("headerEnum", option.None, decode.optional(decode_foo_enum_enum()))
  use header_enum_list <- decode.optional_field("headerEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use header_false_bool <- decode.optional_field("headerFalseBool", option.None, decode.optional(decode.bool))
  use header_float <- decode.optional_field("headerFloat", option.None, decode.optional(json_float.decoder()))
  use header_integer <- decode.optional_field("headerInteger", option.None, decode.optional(decode.int))
  use header_integer_list <- decode.optional_field("headerIntegerList", option.None, decode.optional(decode.list(decode.int)))
  use header_long <- decode.optional_field("headerLong", option.None, decode.optional(decode.int))
  use header_short <- decode.optional_field("headerShort", option.None, decode.optional(decode.int))
  use header_string <- decode.optional_field("headerString", option.None, decode.optional(decode.string))
  use header_string_list <- decode.optional_field("headerStringList", option.None, decode.optional(decode.list(decode.string)))
  use header_string_set <- decode.optional_field("headerStringSet", option.None, decode.optional(decode.list(decode.string)))
  use header_timestamp_list <- decode.optional_field("headerTimestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  use header_true_bool <- decode.optional_field("headerTrueBool", option.None, decode.optional(decode.bool))
  decode.success(InputAndOutputWithHeadersIO(
    header_boolean_list: header_boolean_list,
    header_byte: header_byte,
    header_double: header_double,
    header_enum: header_enum,
    header_enum_list: header_enum_list,
    header_false_bool: header_false_bool,
    header_float: header_float,
    header_integer: header_integer,
    header_integer_list: header_integer_list,
    header_long: header_long,
    header_short: header_short,
    header_string: header_string,
    header_string_list: header_string_list,
    header_string_set: header_string_set,
    header_timestamp_list: header_timestamp_list,
    header_true_bool: header_true_bool,
  ))
}

pub fn decode_input_and_output_with_headers_io_struct_params() -> decode.Decoder(InputAndOutputWithHeadersIO) {
  use <- decode.recursive
  use header_boolean_list <- decode.optional_field("headerBooleanList", option.None, decode.optional(decode.list(decode.bool)))
  use header_byte <- decode.optional_field("headerByte", option.None, decode.optional(decode.int))
  use header_double <- decode.optional_field("headerDouble", option.None, decode.optional(json_float.decoder()))
  use header_enum <- decode.optional_field("headerEnum", option.None, decode.optional(decode_foo_enum_enum()))
  use header_enum_list <- decode.optional_field("headerEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use header_false_bool <- decode.optional_field("headerFalseBool", option.None, decode.optional(decode.bool))
  use header_float <- decode.optional_field("headerFloat", option.None, decode.optional(json_float.decoder()))
  use header_integer <- decode.optional_field("headerInteger", option.None, decode.optional(decode.int))
  use header_integer_list <- decode.optional_field("headerIntegerList", option.None, decode.optional(decode.list(decode.int)))
  use header_long <- decode.optional_field("headerLong", option.None, decode.optional(decode.int))
  use header_short <- decode.optional_field("headerShort", option.None, decode.optional(decode.int))
  use header_string <- decode.optional_field("headerString", option.None, decode.optional(decode.string))
  use header_string_list <- decode.optional_field("headerStringList", option.None, decode.optional(decode.list(decode.string)))
  use header_string_set <- decode.optional_field("headerStringSet", option.None, decode.optional(decode.list(decode.string)))
  use header_timestamp_list <- decode.optional_field("headerTimestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  use header_true_bool <- decode.optional_field("headerTrueBool", option.None, decode.optional(decode.bool))
  decode.success(InputAndOutputWithHeadersIO(
    header_boolean_list: header_boolean_list,
    header_byte: header_byte,
    header_double: header_double,
    header_enum: header_enum,
    header_enum_list: header_enum_list,
    header_false_bool: header_false_bool,
    header_float: header_float,
    header_integer: header_integer,
    header_integer_list: header_integer_list,
    header_long: header_long,
    header_short: header_short,
    header_string: header_string,
    header_string_list: header_string_list,
    header_string_set: header_string_set,
    header_timestamp_list: header_timestamp_list,
    header_true_bool: header_true_bool,
  ))
}

pub fn encode_input_and_output_with_headers_io_xml_inner(input: InputAndOutputWithHeadersIO) -> String {
  let inner = ""
  inner
}

pub fn encode_input_and_output_with_headers_io_xml(input: InputAndOutputWithHeadersIO, root: String) -> String {
  xml.element(root, encode_input_and_output_with_headers_io_xml_inner(input))
}

pub fn decode_input_and_output_with_headers_io_xml(elem: xml_decode.Element) -> Result(InputAndOutputWithHeadersIO, String) {
  let header_boolean_list = option.None
  let header_byte = option.None
  let header_double = option.None
  let header_enum = option.None
  let header_enum_list = option.None
  let header_false_bool = option.None
  let header_float = option.None
  let header_integer = option.None
  let header_integer_list = option.None
  let header_long = option.None
  let header_short = option.None
  let header_string = option.None
  let header_string_list = option.None
  let header_string_set = option.None
  let header_timestamp_list = option.None
  let header_true_bool = option.None
  Ok(InputAndOutputWithHeadersIO(
    header_boolean_list: header_boolean_list,
    header_byte: header_byte,
    header_double: header_double,
    header_enum: header_enum,
    header_enum_list: header_enum_list,
    header_false_bool: header_false_bool,
    header_float: header_float,
    header_integer: header_integer,
    header_integer_list: header_integer_list,
    header_long: header_long,
    header_short: header_short,
    header_string: header_string,
    header_string_list: header_string_list,
    header_string_set: header_string_set,
    header_timestamp_list: header_timestamp_list,
    header_true_bool: header_true_bool,
  ))
}

pub type NestedXmlMapsRequest {
  NestedXmlMapsRequest(flat_nested_map: option.Option(dict.Dict(String, dict.Dict(String, FooEnum))), nested_map: option.Option(dict.Dict(String, dict.Dict(String, FooEnum))))
}

pub fn encode_nested_xml_maps_request_struct(input: NestedXmlMapsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.flat_nested_map {
    option.Some(v) -> [#("flatNestedMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested_map {
    option.Some(v) -> [#("nestedMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_nested_xml_maps_request_struct() -> decode.Decoder(NestedXmlMapsRequest) {
  use <- decode.recursive
  use flat_nested_map <- decode.optional_field("flatNestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  use nested_map <- decode.optional_field("nestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  decode.success(NestedXmlMapsRequest(
    flat_nested_map: flat_nested_map,
    nested_map: nested_map,
  ))
}

pub fn decode_nested_xml_maps_request_struct_params() -> decode.Decoder(NestedXmlMapsRequest) {
  use <- decode.recursive
  use flat_nested_map <- decode.optional_field("flatNestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  use nested_map <- decode.optional_field("nestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  decode.success(NestedXmlMapsRequest(
    flat_nested_map: flat_nested_map,
    nested_map: nested_map,
  ))
}

pub fn encode_nested_xml_maps_request_xml_inner(input: NestedXmlMapsRequest) -> String {
  let inner = ""
  let inner = case input.flat_nested_map {
    option.Some(v) -> inner <> xml.empty_element("flatNestedMap")
    option.None -> inner
  }
  let inner = case input.nested_map {
    option.Some(v) -> inner <> xml.empty_element("nestedMap")
    option.None -> inner
  }
  inner
}

pub fn encode_nested_xml_maps_request_xml(input: NestedXmlMapsRequest, root: String) -> String {
  xml.element(root, encode_nested_xml_maps_request_xml_inner(input))
}

pub fn decode_nested_xml_maps_request_xml(elem: xml_decode.Element) -> Result(NestedXmlMapsRequest, String) {
  use flat_nested_map <- result.try({ let r: Result(option.Option(dict.Dict(String, dict.Dict(String, FooEnum))), String) = Ok(option.None)
    r })
  use nested_map <- result.try({ let r: Result(option.Option(dict.Dict(String, dict.Dict(String, FooEnum))), String) = Ok(option.None)
    r })
  Ok(NestedXmlMapsRequest(
    flat_nested_map: flat_nested_map,
    nested_map: nested_map,
  ))
}

pub type NestedXmlMapsResponse {
  NestedXmlMapsResponse(flat_nested_map: option.Option(dict.Dict(String, dict.Dict(String, FooEnum))), nested_map: option.Option(dict.Dict(String, dict.Dict(String, FooEnum))))
}

pub fn encode_nested_xml_maps_response_struct(input: NestedXmlMapsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.flat_nested_map {
    option.Some(v) -> [#("flatNestedMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested_map {
    option.Some(v) -> [#("nestedMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_nested_xml_maps_response_struct() -> decode.Decoder(NestedXmlMapsResponse) {
  use <- decode.recursive
  use flat_nested_map <- decode.optional_field("flatNestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  use nested_map <- decode.optional_field("nestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  decode.success(NestedXmlMapsResponse(
    flat_nested_map: flat_nested_map,
    nested_map: nested_map,
  ))
}

pub fn decode_nested_xml_maps_response_struct_params() -> decode.Decoder(NestedXmlMapsResponse) {
  use <- decode.recursive
  use flat_nested_map <- decode.optional_field("flatNestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  use nested_map <- decode.optional_field("nestedMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode_foo_enum_enum()))))
  decode.success(NestedXmlMapsResponse(
    flat_nested_map: flat_nested_map,
    nested_map: nested_map,
  ))
}

pub fn encode_nested_xml_maps_response_xml_inner(input: NestedXmlMapsResponse) -> String {
  let inner = ""
  let inner = case input.flat_nested_map {
    option.Some(v) -> inner <> xml.empty_element("flatNestedMap")
    option.None -> inner
  }
  let inner = case input.nested_map {
    option.Some(v) -> inner <> xml.empty_element("nestedMap")
    option.None -> inner
  }
  inner
}

pub fn encode_nested_xml_maps_response_xml(input: NestedXmlMapsResponse, root: String) -> String {
  xml.element(root, encode_nested_xml_maps_response_xml_inner(input))
}

pub fn decode_nested_xml_maps_response_xml(elem: xml_decode.Element) -> Result(NestedXmlMapsResponse, String) {
  use flat_nested_map <- result.try({ let r: Result(option.Option(dict.Dict(String, dict.Dict(String, FooEnum))), String) = Ok(option.None)
    r })
  use nested_map <- result.try({ let r: Result(option.Option(dict.Dict(String, dict.Dict(String, FooEnum))), String) = Ok(option.None)
    r })
  Ok(NestedXmlMapsResponse(
    flat_nested_map: flat_nested_map,
    nested_map: nested_map,
  ))
}

pub type NestedXmlMapWithXmlNameRequest {
  NestedXmlMapWithXmlNameRequest(nested_xml_map_with_xml_name_map: option.Option(dict.Dict(String, dict.Dict(String, String))))
}

pub fn encode_nested_xml_map_with_xml_name_request_struct(input: NestedXmlMapWithXmlNameRequest) -> json.Json {
  let pairs = []
  let pairs = case input.nested_xml_map_with_xml_name_map {
    option.Some(v) -> [#("nestedXmlMapWithXmlNameMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_nested_xml_map_with_xml_name_request_struct() -> decode.Decoder(NestedXmlMapWithXmlNameRequest) {
  use <- decode.recursive
  use nested_xml_map_with_xml_name_map <- decode.optional_field("nestedXmlMapWithXmlNameMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode.string))))
  decode.success(NestedXmlMapWithXmlNameRequest(
    nested_xml_map_with_xml_name_map: nested_xml_map_with_xml_name_map,
  ))
}

pub fn decode_nested_xml_map_with_xml_name_request_struct_params() -> decode.Decoder(NestedXmlMapWithXmlNameRequest) {
  use <- decode.recursive
  use nested_xml_map_with_xml_name_map <- decode.optional_field("nestedXmlMapWithXmlNameMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode.string))))
  decode.success(NestedXmlMapWithXmlNameRequest(
    nested_xml_map_with_xml_name_map: nested_xml_map_with_xml_name_map,
  ))
}

pub fn encode_nested_xml_map_with_xml_name_request_xml_inner(input: NestedXmlMapWithXmlNameRequest) -> String {
  let inner = ""
  let inner = case input.nested_xml_map_with_xml_name_map {
    option.Some(v) -> inner <> xml.empty_element("nestedXmlMapWithXmlNameMap")
    option.None -> inner
  }
  inner
}

pub fn encode_nested_xml_map_with_xml_name_request_xml(input: NestedXmlMapWithXmlNameRequest, root: String) -> String {
  xml.element(root, encode_nested_xml_map_with_xml_name_request_xml_inner(input))
}

pub fn decode_nested_xml_map_with_xml_name_request_xml(elem: xml_decode.Element) -> Result(NestedXmlMapWithXmlNameRequest, String) {
  use nested_xml_map_with_xml_name_map <- result.try({ let r: Result(option.Option(dict.Dict(String, dict.Dict(String, String))), String) = Ok(option.None)
    r })
  Ok(NestedXmlMapWithXmlNameRequest(
    nested_xml_map_with_xml_name_map: nested_xml_map_with_xml_name_map,
  ))
}

pub type NestedXmlMapWithXmlNameResponse {
  NestedXmlMapWithXmlNameResponse(nested_xml_map_with_xml_name_map: option.Option(dict.Dict(String, dict.Dict(String, String))))
}

pub fn encode_nested_xml_map_with_xml_name_response_struct(input: NestedXmlMapWithXmlNameResponse) -> json.Json {
  let pairs = []
  let pairs = case input.nested_xml_map_with_xml_name_map {
    option.Some(v) -> [#("nestedXmlMapWithXmlNameMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_nested_xml_map_with_xml_name_response_struct() -> decode.Decoder(NestedXmlMapWithXmlNameResponse) {
  use <- decode.recursive
  use nested_xml_map_with_xml_name_map <- decode.optional_field("nestedXmlMapWithXmlNameMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode.string))))
  decode.success(NestedXmlMapWithXmlNameResponse(
    nested_xml_map_with_xml_name_map: nested_xml_map_with_xml_name_map,
  ))
}

pub fn decode_nested_xml_map_with_xml_name_response_struct_params() -> decode.Decoder(NestedXmlMapWithXmlNameResponse) {
  use <- decode.recursive
  use nested_xml_map_with_xml_name_map <- decode.optional_field("nestedXmlMapWithXmlNameMap", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode.string))))
  decode.success(NestedXmlMapWithXmlNameResponse(
    nested_xml_map_with_xml_name_map: nested_xml_map_with_xml_name_map,
  ))
}

pub fn encode_nested_xml_map_with_xml_name_response_xml_inner(input: NestedXmlMapWithXmlNameResponse) -> String {
  let inner = ""
  let inner = case input.nested_xml_map_with_xml_name_map {
    option.Some(v) -> inner <> xml.empty_element("nestedXmlMapWithXmlNameMap")
    option.None -> inner
  }
  inner
}

pub fn encode_nested_xml_map_with_xml_name_response_xml(input: NestedXmlMapWithXmlNameResponse, root: String) -> String {
  xml.element(root, encode_nested_xml_map_with_xml_name_response_xml_inner(input))
}

pub fn decode_nested_xml_map_with_xml_name_response_xml(elem: xml_decode.Element) -> Result(NestedXmlMapWithXmlNameResponse, String) {
  use nested_xml_map_with_xml_name_map <- result.try({ let r: Result(option.Option(dict.Dict(String, dict.Dict(String, String))), String) = Ok(option.None)
    r })
  Ok(NestedXmlMapWithXmlNameResponse(
    nested_xml_map_with_xml_name_map: nested_xml_map_with_xml_name_map,
  ))
}

pub type NoInputAndOutputOutput {
  NoInputAndOutputOutput
}

pub fn encode_no_input_and_output_output_struct(_v: NoInputAndOutputOutput) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_output_output_struct() -> decode.Decoder(NoInputAndOutputOutput) {
  decode.success(NoInputAndOutputOutput)
}

pub fn decode_no_input_and_output_output_struct_params() -> decode.Decoder(NoInputAndOutputOutput) {
  decode.success(NoInputAndOutputOutput)
}

pub fn encode_no_input_and_output_output_xml_inner(_input: NoInputAndOutputOutput) -> String {
  ""
}

pub fn encode_no_input_and_output_output_xml(input: NoInputAndOutputOutput, root: String) -> String {
  xml.element(root, encode_no_input_and_output_output_xml_inner(input))
}

pub fn decode_no_input_and_output_output_xml(_elem: xml_decode.Element) -> Result(NoInputAndOutputOutput, String) {
  Ok(NoInputAndOutputOutput)
}

pub type NullAndEmptyHeadersIO {
  NullAndEmptyHeadersIO(a: option.Option(String), b: option.Option(String), c: option.Option(List(String)))
}

pub fn encode_null_and_empty_headers_io_struct(input: NullAndEmptyHeadersIO) -> json.Json {
  let pairs = []
  let pairs = case input.a {
    option.Some(v) -> [#("a", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.b {
    option.Some(v) -> [#("b", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.c {
    option.Some(v) -> [#("c", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_null_and_empty_headers_io_struct() -> decode.Decoder(NullAndEmptyHeadersIO) {
  use <- decode.recursive
  use a <- decode.optional_field("a", option.None, decode.optional(decode.string))
  use b <- decode.optional_field("b", option.None, decode.optional(decode.string))
  use c <- decode.optional_field("c", option.None, decode.optional(decode.list(decode.string)))
  decode.success(NullAndEmptyHeadersIO(
    a: a,
    b: b,
    c: c,
  ))
}

pub fn decode_null_and_empty_headers_io_struct_params() -> decode.Decoder(NullAndEmptyHeadersIO) {
  use <- decode.recursive
  use a <- decode.optional_field("a", option.None, decode.optional(decode.string))
  use b <- decode.optional_field("b", option.None, decode.optional(decode.string))
  use c <- decode.optional_field("c", option.None, decode.optional(decode.list(decode.string)))
  decode.success(NullAndEmptyHeadersIO(
    a: a,
    b: b,
    c: c,
  ))
}

pub fn encode_null_and_empty_headers_io_xml_inner(input: NullAndEmptyHeadersIO) -> String {
  let inner = ""
  inner
}

pub fn encode_null_and_empty_headers_io_xml(input: NullAndEmptyHeadersIO, root: String) -> String {
  xml.element(root, encode_null_and_empty_headers_io_xml_inner(input))
}

pub fn decode_null_and_empty_headers_io_xml(elem: xml_decode.Element) -> Result(NullAndEmptyHeadersIO, String) {
  let a = option.None
  let b = option.None
  let c = option.None
  Ok(NullAndEmptyHeadersIO(
    a: a,
    b: b,
    c: c,
  ))
}

pub type OmitsNullSerializesEmptyStringInput {
  OmitsNullSerializesEmptyStringInput(empty_string: option.Option(String), null_value: option.Option(String))
}

pub fn encode_omits_null_serializes_empty_string_input_struct(input: OmitsNullSerializesEmptyStringInput) -> json.Json {
  let pairs = []
  let pairs = case input.empty_string {
    option.Some(v) -> [#("emptyString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.null_value {
    option.Some(v) -> [#("nullValue", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_omits_null_serializes_empty_string_input_struct() -> decode.Decoder(OmitsNullSerializesEmptyStringInput) {
  use <- decode.recursive
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  use null_value <- decode.optional_field("nullValue", option.None, decode.optional(decode.string))
  decode.success(OmitsNullSerializesEmptyStringInput(
    empty_string: empty_string,
    null_value: null_value,
  ))
}

pub fn decode_omits_null_serializes_empty_string_input_struct_params() -> decode.Decoder(OmitsNullSerializesEmptyStringInput) {
  use <- decode.recursive
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  use null_value <- decode.optional_field("nullValue", option.None, decode.optional(decode.string))
  decode.success(OmitsNullSerializesEmptyStringInput(
    empty_string: empty_string,
    null_value: null_value,
  ))
}

pub fn encode_omits_null_serializes_empty_string_input_xml_inner(input: OmitsNullSerializesEmptyStringInput) -> String {
  let inner = ""
  inner
}

pub fn encode_omits_null_serializes_empty_string_input_xml(input: OmitsNullSerializesEmptyStringInput, root: String) -> String {
  xml.element(root, encode_omits_null_serializes_empty_string_input_xml_inner(input))
}

pub fn decode_omits_null_serializes_empty_string_input_xml(elem: xml_decode.Element) -> Result(OmitsNullSerializesEmptyStringInput, String) {
  let empty_string = option.None
  let null_value = option.None
  Ok(OmitsNullSerializesEmptyStringInput(
    empty_string: empty_string,
    null_value: null_value,
  ))
}

pub type PutWithContentEncodingInput {
  PutWithContentEncodingInput(data: option.Option(String), encoding: option.Option(String))
}

pub fn encode_put_with_content_encoding_input_struct(input: PutWithContentEncodingInput) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [#("data", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding {
    option.Some(v) -> [#("encoding", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_with_content_encoding_input_struct() -> decode.Decoder(PutWithContentEncodingInput) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.string))
  use encoding <- decode.optional_field("encoding", option.None, decode.optional(decode.string))
  decode.success(PutWithContentEncodingInput(
    data: data,
    encoding: encoding,
  ))
}

pub fn decode_put_with_content_encoding_input_struct_params() -> decode.Decoder(PutWithContentEncodingInput) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.string))
  use encoding <- decode.optional_field("encoding", option.None, decode.optional(decode.string))
  decode.success(PutWithContentEncodingInput(
    data: data,
    encoding: encoding,
  ))
}

pub fn encode_put_with_content_encoding_input_xml_inner(input: PutWithContentEncodingInput) -> String {
  let inner = ""
  let inner = case input.data {
    option.Some(v) -> inner <> xml.element("data", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_put_with_content_encoding_input_xml(input: PutWithContentEncodingInput, root: String) -> String {
  xml.element(root, encode_put_with_content_encoding_input_xml_inner(input))
}

pub fn decode_put_with_content_encoding_input_xml(elem: xml_decode.Element) -> Result(PutWithContentEncodingInput, String) {
  use data <- result.try(xml_decode.optional_child(elem, "data", xml_decode.string_text))
  let encoding = option.None
  Ok(PutWithContentEncodingInput(
    data: data,
    encoding: encoding,
  ))
}

pub type QueryIdempotencyTokenAutoFillInput {
  QueryIdempotencyTokenAutoFillInput(token: option.Option(String))
}

pub fn encode_query_idempotency_token_auto_fill_input_struct(input: QueryIdempotencyTokenAutoFillInput) -> json.Json {
  let pairs = []
  let pairs = case input.token {
    option.Some(v) -> [#("token", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_idempotency_token_auto_fill_input_struct() -> decode.Decoder(QueryIdempotencyTokenAutoFillInput) {
  use <- decode.recursive
  use token <- decode.optional_field("token", option.None, decode.optional(decode.string))
  decode.success(QueryIdempotencyTokenAutoFillInput(
    token: token,
  ))
}

pub fn decode_query_idempotency_token_auto_fill_input_struct_params() -> decode.Decoder(QueryIdempotencyTokenAutoFillInput) {
  use <- decode.recursive
  use token <- decode.optional_field("token", option.None, decode.optional(decode.string))
  decode.success(QueryIdempotencyTokenAutoFillInput(
    token: token,
  ))
}

pub fn encode_query_idempotency_token_auto_fill_input_xml_inner(input: QueryIdempotencyTokenAutoFillInput) -> String {
  let inner = ""
  inner
}

pub fn encode_query_idempotency_token_auto_fill_input_xml(input: QueryIdempotencyTokenAutoFillInput, root: String) -> String {
  xml.element(root, encode_query_idempotency_token_auto_fill_input_xml_inner(input))
}

pub fn decode_query_idempotency_token_auto_fill_input_xml(elem: xml_decode.Element) -> Result(QueryIdempotencyTokenAutoFillInput, String) {
  let token = option.None
  Ok(QueryIdempotencyTokenAutoFillInput(
    token: token,
  ))
}

pub type QueryParamsAsStringListMapInput {
  QueryParamsAsStringListMapInput(foo: option.Option(dict.Dict(String, List(String))), qux: option.Option(String))
}

pub fn encode_query_params_as_string_list_map_input_struct(input: QueryParamsAsStringListMapInput) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.qux {
    option.Some(v) -> [#("qux", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_params_as_string_list_map_input_struct() -> decode.Decoder(QueryParamsAsStringListMapInput) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.dict(decode.string, decode.list(decode.string))))
  use qux <- decode.optional_field("qux", option.None, decode.optional(decode.string))
  decode.success(QueryParamsAsStringListMapInput(
    foo: foo,
    qux: qux,
  ))
}

pub fn decode_query_params_as_string_list_map_input_struct_params() -> decode.Decoder(QueryParamsAsStringListMapInput) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.dict(decode.string, decode.list(decode.string))))
  use qux <- decode.optional_field("qux", option.None, decode.optional(decode.string))
  decode.success(QueryParamsAsStringListMapInput(
    foo: foo,
    qux: qux,
  ))
}

pub fn encode_query_params_as_string_list_map_input_xml_inner(input: QueryParamsAsStringListMapInput) -> String {
  let inner = ""
  inner
}

pub fn encode_query_params_as_string_list_map_input_xml(input: QueryParamsAsStringListMapInput, root: String) -> String {
  xml.element(root, encode_query_params_as_string_list_map_input_xml_inner(input))
}

pub fn decode_query_params_as_string_list_map_input_xml(elem: xml_decode.Element) -> Result(QueryParamsAsStringListMapInput, String) {
  let foo = option.None
  let qux = option.None
  Ok(QueryParamsAsStringListMapInput(
    foo: foo,
    qux: qux,
  ))
}

pub type QueryPrecedenceInput {
  QueryPrecedenceInput(baz: option.Option(dict.Dict(String, String)), foo: option.Option(String))
}

pub fn encode_query_precedence_input_struct(input: QueryPrecedenceInput) -> json.Json {
  let pairs = []
  let pairs = case input.baz {
    option.Some(v) -> [#("baz", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_precedence_input_struct() -> decode.Decoder(QueryPrecedenceInput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(QueryPrecedenceInput(
    baz: baz,
    foo: foo,
  ))
}

pub fn decode_query_precedence_input_struct_params() -> decode.Decoder(QueryPrecedenceInput) {
  use <- decode.recursive
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(QueryPrecedenceInput(
    baz: baz,
    foo: foo,
  ))
}

pub fn encode_query_precedence_input_xml_inner(input: QueryPrecedenceInput) -> String {
  let inner = ""
  inner
}

pub fn encode_query_precedence_input_xml(input: QueryPrecedenceInput, root: String) -> String {
  xml.element(root, encode_query_precedence_input_xml_inner(input))
}

pub fn decode_query_precedence_input_xml(elem: xml_decode.Element) -> Result(QueryPrecedenceInput, String) {
  let baz = option.None
  let foo = option.None
  Ok(QueryPrecedenceInput(
    baz: baz,
    foo: foo,
  ))
}

pub type RecursiveShapesRequest {
  RecursiveShapesRequest(nested: option.Option(RecursiveShapesInputOutputNested1))
}

pub fn encode_recursive_shapes_request_struct(input: RecursiveShapesRequest) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_recursive_shapes_input_output_nested1_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_recursive_shapes_request_struct() -> decode.Decoder(RecursiveShapesRequest) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_recursive_shapes_input_output_nested1_struct()))
  decode.success(RecursiveShapesRequest(
    nested: nested,
  ))
}

pub fn decode_recursive_shapes_request_struct_params() -> decode.Decoder(RecursiveShapesRequest) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_recursive_shapes_input_output_nested1_struct_params()))
  decode.success(RecursiveShapesRequest(
    nested: nested,
  ))
}

pub fn encode_recursive_shapes_request_xml_inner(input: RecursiveShapesRequest) -> String {
  let inner = ""
  let inner = case input.nested {
    option.Some(v) -> inner <> encode_recursive_shapes_input_output_nested1_xml(v, "nested")
    option.None -> inner
  }
  inner
}

pub fn encode_recursive_shapes_request_xml(input: RecursiveShapesRequest, root: String) -> String {
  xml.element(root, encode_recursive_shapes_request_xml_inner(input))
}

pub fn decode_recursive_shapes_request_xml(elem: xml_decode.Element) -> Result(RecursiveShapesRequest, String) {
  use nested <- result.try(xml_decode.optional_child(elem, "nested", decode_recursive_shapes_input_output_nested1_xml))
  Ok(RecursiveShapesRequest(
    nested: nested,
  ))
}

pub type RecursiveShapesInputOutputNested1 {
  RecursiveShapesInputOutputNested1(foo: option.Option(String), nested: option.Option(RecursiveShapesInputOutputNested2))
}

pub fn encode_recursive_shapes_input_output_nested1_struct(input: RecursiveShapesInputOutputNested1) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_recursive_shapes_input_output_nested2_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_recursive_shapes_input_output_nested1_struct() -> decode.Decoder(RecursiveShapesInputOutputNested1) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_recursive_shapes_input_output_nested2_struct()))
  decode.success(RecursiveShapesInputOutputNested1(
    foo: foo,
    nested: nested,
  ))
}

pub fn decode_recursive_shapes_input_output_nested1_struct_params() -> decode.Decoder(RecursiveShapesInputOutputNested1) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_recursive_shapes_input_output_nested2_struct_params()))
  decode.success(RecursiveShapesInputOutputNested1(
    foo: foo,
    nested: nested,
  ))
}

pub fn encode_recursive_shapes_input_output_nested1_xml_inner(input: RecursiveShapesInputOutputNested1) -> String {
  let inner = ""
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.nested {
    option.Some(v) -> inner <> encode_recursive_shapes_input_output_nested2_xml(v, "nested")
    option.None -> inner
  }
  inner
}

pub fn encode_recursive_shapes_input_output_nested1_xml(input: RecursiveShapesInputOutputNested1, root: String) -> String {
  xml.element(root, encode_recursive_shapes_input_output_nested1_xml_inner(input))
}

pub fn decode_recursive_shapes_input_output_nested1_xml(elem: xml_decode.Element) -> Result(RecursiveShapesInputOutputNested1, String) {
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  use nested <- result.try(xml_decode.optional_child(elem, "nested", decode_recursive_shapes_input_output_nested2_xml))
  Ok(RecursiveShapesInputOutputNested1(
    foo: foo,
    nested: nested,
  ))
}

pub type RecursiveShapesInputOutputNested2 {
  RecursiveShapesInputOutputNested2(bar: option.Option(String), recursive_member: option.Option(RecursiveShapesInputOutputNested1))
}

pub fn encode_recursive_shapes_input_output_nested2_struct(input: RecursiveShapesInputOutputNested2) -> json.Json {
  let pairs = []
  let pairs = case input.bar {
    option.Some(v) -> [#("bar", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.recursive_member {
    option.Some(v) -> [#("recursiveMember", encode_recursive_shapes_input_output_nested1_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_recursive_shapes_input_output_nested2_struct() -> decode.Decoder(RecursiveShapesInputOutputNested2) {
  use <- decode.recursive
  use bar <- decode.optional_field("bar", option.None, decode.optional(decode.string))
  use recursive_member <- decode.optional_field("recursiveMember", option.None, decode.optional(decode_recursive_shapes_input_output_nested1_struct()))
  decode.success(RecursiveShapesInputOutputNested2(
    bar: bar,
    recursive_member: recursive_member,
  ))
}

pub fn decode_recursive_shapes_input_output_nested2_struct_params() -> decode.Decoder(RecursiveShapesInputOutputNested2) {
  use <- decode.recursive
  use bar <- decode.optional_field("bar", option.None, decode.optional(decode.string))
  use recursive_member <- decode.optional_field("recursiveMember", option.None, decode.optional(decode_recursive_shapes_input_output_nested1_struct_params()))
  decode.success(RecursiveShapesInputOutputNested2(
    bar: bar,
    recursive_member: recursive_member,
  ))
}

pub fn encode_recursive_shapes_input_output_nested2_xml_inner(input: RecursiveShapesInputOutputNested2) -> String {
  let inner = ""
  let inner = case input.bar {
    option.Some(v) -> inner <> xml.element("bar", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.recursive_member {
    option.Some(v) -> inner <> encode_recursive_shapes_input_output_nested1_xml(v, "recursiveMember")
    option.None -> inner
  }
  inner
}

pub fn encode_recursive_shapes_input_output_nested2_xml(input: RecursiveShapesInputOutputNested2, root: String) -> String {
  xml.element(root, encode_recursive_shapes_input_output_nested2_xml_inner(input))
}

pub fn decode_recursive_shapes_input_output_nested2_xml(elem: xml_decode.Element) -> Result(RecursiveShapesInputOutputNested2, String) {
  use bar <- result.try(xml_decode.optional_child(elem, "bar", xml_decode.string_text))
  use recursive_member <- result.try(xml_decode.optional_child(elem, "recursiveMember", decode_recursive_shapes_input_output_nested1_xml))
  Ok(RecursiveShapesInputOutputNested2(
    bar: bar,
    recursive_member: recursive_member,
  ))
}

pub type RecursiveShapesResponse {
  RecursiveShapesResponse(nested: option.Option(RecursiveShapesInputOutputNested1))
}

pub fn encode_recursive_shapes_response_struct(input: RecursiveShapesResponse) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_recursive_shapes_input_output_nested1_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_recursive_shapes_response_struct() -> decode.Decoder(RecursiveShapesResponse) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_recursive_shapes_input_output_nested1_struct()))
  decode.success(RecursiveShapesResponse(
    nested: nested,
  ))
}

pub fn decode_recursive_shapes_response_struct_params() -> decode.Decoder(RecursiveShapesResponse) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_recursive_shapes_input_output_nested1_struct_params()))
  decode.success(RecursiveShapesResponse(
    nested: nested,
  ))
}

pub fn encode_recursive_shapes_response_xml_inner(input: RecursiveShapesResponse) -> String {
  let inner = ""
  let inner = case input.nested {
    option.Some(v) -> inner <> encode_recursive_shapes_input_output_nested1_xml(v, "nested")
    option.None -> inner
  }
  inner
}

pub fn encode_recursive_shapes_response_xml(input: RecursiveShapesResponse, root: String) -> String {
  xml.element(root, encode_recursive_shapes_response_xml_inner(input))
}

pub fn decode_recursive_shapes_response_xml(elem: xml_decode.Element) -> Result(RecursiveShapesResponse, String) {
  use nested <- result.try(xml_decode.optional_child(elem, "nested", decode_recursive_shapes_input_output_nested1_xml))
  Ok(RecursiveShapesResponse(
    nested: nested,
  ))
}

pub type SimpleScalarPropertiesRequest {
  SimpleScalarPropertiesRequest(byte_value: option.Option(Int), double_value: option.Option(json_float.SmithyFloat), false_boolean_value: option.Option(Bool), float_value: option.Option(json_float.SmithyFloat), foo: option.Option(String), integer_value: option.Option(Int), long_value: option.Option(Int), short_value: option.Option(Int), string_value: option.Option(String), true_boolean_value: option.Option(Bool))
}

pub fn encode_simple_scalar_properties_request_struct(input: SimpleScalarPropertiesRequest) -> json.Json {
  let pairs = []
  let pairs = case input.byte_value {
    option.Some(v) -> [#("byteValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.false_boolean_value {
    option.Some(v) -> [#("falseBooleanValue", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_value {
    option.Some(v) -> [#("integerValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long_value {
    option.Some(v) -> [#("longValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short_value {
    option.Some(v) -> [#("shortValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_value {
    option.Some(v) -> [#("stringValue", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.true_boolean_value {
    option.Some(v) -> [#("trueBooleanValue", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_simple_scalar_properties_request_struct() -> decode.Decoder(SimpleScalarPropertiesRequest) {
  use <- decode.recursive
  use byte_value <- decode.optional_field("byteValue", option.None, decode.optional(decode.int))
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use false_boolean_value <- decode.optional_field("falseBooleanValue", option.None, decode.optional(decode.bool))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use integer_value <- decode.optional_field("integerValue", option.None, decode.optional(decode.int))
  use long_value <- decode.optional_field("longValue", option.None, decode.optional(decode.int))
  use short_value <- decode.optional_field("shortValue", option.None, decode.optional(decode.int))
  use string_value <- decode.optional_field("stringValue", option.None, decode.optional(decode.string))
  use true_boolean_value <- decode.optional_field("trueBooleanValue", option.None, decode.optional(decode.bool))
  decode.success(SimpleScalarPropertiesRequest(
    byte_value: byte_value,
    double_value: double_value,
    false_boolean_value: false_boolean_value,
    float_value: float_value,
    foo: foo,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
    true_boolean_value: true_boolean_value,
  ))
}

pub fn decode_simple_scalar_properties_request_struct_params() -> decode.Decoder(SimpleScalarPropertiesRequest) {
  use <- decode.recursive
  use byte_value <- decode.optional_field("byteValue", option.None, decode.optional(decode.int))
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use false_boolean_value <- decode.optional_field("falseBooleanValue", option.None, decode.optional(decode.bool))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use integer_value <- decode.optional_field("integerValue", option.None, decode.optional(decode.int))
  use long_value <- decode.optional_field("longValue", option.None, decode.optional(decode.int))
  use short_value <- decode.optional_field("shortValue", option.None, decode.optional(decode.int))
  use string_value <- decode.optional_field("stringValue", option.None, decode.optional(decode.string))
  use true_boolean_value <- decode.optional_field("trueBooleanValue", option.None, decode.optional(decode.bool))
  decode.success(SimpleScalarPropertiesRequest(
    byte_value: byte_value,
    double_value: double_value,
    false_boolean_value: false_boolean_value,
    float_value: float_value,
    foo: foo,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
    true_boolean_value: true_boolean_value,
  ))
}

pub fn encode_simple_scalar_properties_request_xml_inner(input: SimpleScalarPropertiesRequest) -> String {
  let inner = ""
  let inner = case input.byte_value {
    option.Some(v) -> inner <> xml.element("byteValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.double_value {
    option.Some(v) -> inner <> xml.element("doubleValue", case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> inner
  }
  let inner = case input.false_boolean_value {
    option.Some(v) -> inner <> xml.element("falseBooleanValue", xml.bool_text(v))
    option.None -> inner
  }
  let inner = case input.float_value {
    option.Some(v) -> inner <> xml.element("floatValue", case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> inner
  }
  let inner = case input.integer_value {
    option.Some(v) -> inner <> xml.element("integerValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.long_value {
    option.Some(v) -> inner <> xml.element("longValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.short_value {
    option.Some(v) -> inner <> xml.element("shortValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.string_value {
    option.Some(v) -> inner <> xml.element("stringValue", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.true_boolean_value {
    option.Some(v) -> inner <> xml.element("trueBooleanValue", xml.bool_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_simple_scalar_properties_request_xml(input: SimpleScalarPropertiesRequest, root: String) -> String {
  xml.element(root, encode_simple_scalar_properties_request_xml_inner(input))
}

pub fn decode_simple_scalar_properties_request_xml(elem: xml_decode.Element) -> Result(SimpleScalarPropertiesRequest, String) {
  use byte_value <- result.try(xml_decode.optional_child(elem, "byteValue", xml_decode.int_text))
  use double_value <- result.try(xml_decode.optional_child(elem, "doubleValue", fn(e) { case xml_decode.float_text(e) { Ok(f) -> Ok(json_float.FloatValue(f)) Error(r) -> Error(r) } }))
  use false_boolean_value <- result.try(xml_decode.optional_child(elem, "falseBooleanValue", xml_decode.bool_text))
  use float_value <- result.try(xml_decode.optional_child(elem, "floatValue", fn(e) { case xml_decode.float_text(e) { Ok(f) -> Ok(json_float.FloatValue(f)) Error(r) -> Error(r) } }))
  let foo = option.None
  use integer_value <- result.try(xml_decode.optional_child(elem, "integerValue", xml_decode.int_text))
  use long_value <- result.try(xml_decode.optional_child(elem, "longValue", xml_decode.int_text))
  use short_value <- result.try(xml_decode.optional_child(elem, "shortValue", xml_decode.int_text))
  use string_value <- result.try(xml_decode.optional_child(elem, "stringValue", xml_decode.string_text))
  use true_boolean_value <- result.try(xml_decode.optional_child(elem, "trueBooleanValue", xml_decode.bool_text))
  Ok(SimpleScalarPropertiesRequest(
    byte_value: byte_value,
    double_value: double_value,
    false_boolean_value: false_boolean_value,
    float_value: float_value,
    foo: foo,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
    true_boolean_value: true_boolean_value,
  ))
}

pub type SimpleScalarPropertiesResponse {
  SimpleScalarPropertiesResponse(byte_value: option.Option(Int), double_value: option.Option(json_float.SmithyFloat), false_boolean_value: option.Option(Bool), float_value: option.Option(json_float.SmithyFloat), foo: option.Option(String), integer_value: option.Option(Int), long_value: option.Option(Int), short_value: option.Option(Int), string_value: option.Option(String), true_boolean_value: option.Option(Bool))
}

pub fn encode_simple_scalar_properties_response_struct(input: SimpleScalarPropertiesResponse) -> json.Json {
  let pairs = []
  let pairs = case input.byte_value {
    option.Some(v) -> [#("byteValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.false_boolean_value {
    option.Some(v) -> [#("falseBooleanValue", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_value {
    option.Some(v) -> [#("integerValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long_value {
    option.Some(v) -> [#("longValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short_value {
    option.Some(v) -> [#("shortValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_value {
    option.Some(v) -> [#("stringValue", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.true_boolean_value {
    option.Some(v) -> [#("trueBooleanValue", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_simple_scalar_properties_response_struct() -> decode.Decoder(SimpleScalarPropertiesResponse) {
  use <- decode.recursive
  use byte_value <- decode.optional_field("byteValue", option.None, decode.optional(decode.int))
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use false_boolean_value <- decode.optional_field("falseBooleanValue", option.None, decode.optional(decode.bool))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use integer_value <- decode.optional_field("integerValue", option.None, decode.optional(decode.int))
  use long_value <- decode.optional_field("longValue", option.None, decode.optional(decode.int))
  use short_value <- decode.optional_field("shortValue", option.None, decode.optional(decode.int))
  use string_value <- decode.optional_field("stringValue", option.None, decode.optional(decode.string))
  use true_boolean_value <- decode.optional_field("trueBooleanValue", option.None, decode.optional(decode.bool))
  decode.success(SimpleScalarPropertiesResponse(
    byte_value: byte_value,
    double_value: double_value,
    false_boolean_value: false_boolean_value,
    float_value: float_value,
    foo: foo,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
    true_boolean_value: true_boolean_value,
  ))
}

pub fn decode_simple_scalar_properties_response_struct_params() -> decode.Decoder(SimpleScalarPropertiesResponse) {
  use <- decode.recursive
  use byte_value <- decode.optional_field("byteValue", option.None, decode.optional(decode.int))
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use false_boolean_value <- decode.optional_field("falseBooleanValue", option.None, decode.optional(decode.bool))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use integer_value <- decode.optional_field("integerValue", option.None, decode.optional(decode.int))
  use long_value <- decode.optional_field("longValue", option.None, decode.optional(decode.int))
  use short_value <- decode.optional_field("shortValue", option.None, decode.optional(decode.int))
  use string_value <- decode.optional_field("stringValue", option.None, decode.optional(decode.string))
  use true_boolean_value <- decode.optional_field("trueBooleanValue", option.None, decode.optional(decode.bool))
  decode.success(SimpleScalarPropertiesResponse(
    byte_value: byte_value,
    double_value: double_value,
    false_boolean_value: false_boolean_value,
    float_value: float_value,
    foo: foo,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
    true_boolean_value: true_boolean_value,
  ))
}

pub fn encode_simple_scalar_properties_response_xml_inner(input: SimpleScalarPropertiesResponse) -> String {
  let inner = ""
  let inner = case input.byte_value {
    option.Some(v) -> inner <> xml.element("byteValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.double_value {
    option.Some(v) -> inner <> xml.element("doubleValue", case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> inner
  }
  let inner = case input.false_boolean_value {
    option.Some(v) -> inner <> xml.element("falseBooleanValue", xml.bool_text(v))
    option.None -> inner
  }
  let inner = case input.float_value {
    option.Some(v) -> inner <> xml.element("floatValue", case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> inner
  }
  let inner = case input.integer_value {
    option.Some(v) -> inner <> xml.element("integerValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.long_value {
    option.Some(v) -> inner <> xml.element("longValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.short_value {
    option.Some(v) -> inner <> xml.element("shortValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.string_value {
    option.Some(v) -> inner <> xml.element("stringValue", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.true_boolean_value {
    option.Some(v) -> inner <> xml.element("trueBooleanValue", xml.bool_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_simple_scalar_properties_response_xml(input: SimpleScalarPropertiesResponse, root: String) -> String {
  xml.element(root, encode_simple_scalar_properties_response_xml_inner(input))
}

pub fn decode_simple_scalar_properties_response_xml(elem: xml_decode.Element) -> Result(SimpleScalarPropertiesResponse, String) {
  use byte_value <- result.try(xml_decode.optional_child(elem, "byteValue", xml_decode.int_text))
  use double_value <- result.try(xml_decode.optional_child(elem, "doubleValue", fn(e) { case xml_decode.float_text(e) { Ok(f) -> Ok(json_float.FloatValue(f)) Error(r) -> Error(r) } }))
  use false_boolean_value <- result.try(xml_decode.optional_child(elem, "falseBooleanValue", xml_decode.bool_text))
  use float_value <- result.try(xml_decode.optional_child(elem, "floatValue", fn(e) { case xml_decode.float_text(e) { Ok(f) -> Ok(json_float.FloatValue(f)) Error(r) -> Error(r) } }))
  let foo = option.None
  use integer_value <- result.try(xml_decode.optional_child(elem, "integerValue", xml_decode.int_text))
  use long_value <- result.try(xml_decode.optional_child(elem, "longValue", xml_decode.int_text))
  use short_value <- result.try(xml_decode.optional_child(elem, "shortValue", xml_decode.int_text))
  use string_value <- result.try(xml_decode.optional_child(elem, "stringValue", xml_decode.string_text))
  use true_boolean_value <- result.try(xml_decode.optional_child(elem, "trueBooleanValue", xml_decode.bool_text))
  Ok(SimpleScalarPropertiesResponse(
    byte_value: byte_value,
    double_value: double_value,
    false_boolean_value: false_boolean_value,
    float_value: float_value,
    foo: foo,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
    true_boolean_value: true_boolean_value,
  ))
}

pub type TimestampFormatHeadersIO {
  TimestampFormatHeadersIO(default_format: option.Option(Int), member_date_time: option.Option(Int), member_epoch_seconds: option.Option(Int), member_http_date: option.Option(Int), target_date_time: option.Option(Int), target_epoch_seconds: option.Option(Int), target_http_date: option.Option(Int))
}

pub fn encode_timestamp_format_headers_io_struct(input: TimestampFormatHeadersIO) -> json.Json {
  let pairs = []
  let pairs = case input.default_format {
    option.Some(v) -> [#("defaultFormat", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_date_time {
    option.Some(v) -> [#("memberDateTime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_epoch_seconds {
    option.Some(v) -> [#("memberEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_http_date {
    option.Some(v) -> [#("memberHttpDate", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_date_time {
    option.Some(v) -> [#("targetDateTime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_epoch_seconds {
    option.Some(v) -> [#("targetEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_http_date {
    option.Some(v) -> [#("targetHttpDate", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_timestamp_format_headers_io_struct() -> decode.Decoder(TimestampFormatHeadersIO) {
  use <- decode.recursive
  use default_format <- decode.optional_field("defaultFormat", option.None, decode.optional(json_timestamp.decoder()))
  use member_date_time <- decode.optional_field("memberDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use member_epoch_seconds <- decode.optional_field("memberEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use member_http_date <- decode.optional_field("memberHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  use target_date_time <- decode.optional_field("targetDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use target_epoch_seconds <- decode.optional_field("targetEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use target_http_date <- decode.optional_field("targetHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(TimestampFormatHeadersIO(
    default_format: default_format,
    member_date_time: member_date_time,
    member_epoch_seconds: member_epoch_seconds,
    member_http_date: member_http_date,
    target_date_time: target_date_time,
    target_epoch_seconds: target_epoch_seconds,
    target_http_date: target_http_date,
  ))
}

pub fn decode_timestamp_format_headers_io_struct_params() -> decode.Decoder(TimestampFormatHeadersIO) {
  use <- decode.recursive
  use default_format <- decode.optional_field("defaultFormat", option.None, decode.optional(json_timestamp.decoder()))
  use member_date_time <- decode.optional_field("memberDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use member_epoch_seconds <- decode.optional_field("memberEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use member_http_date <- decode.optional_field("memberHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  use target_date_time <- decode.optional_field("targetDateTime", option.None, decode.optional(json_timestamp.decoder()))
  use target_epoch_seconds <- decode.optional_field("targetEpochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use target_http_date <- decode.optional_field("targetHttpDate", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(TimestampFormatHeadersIO(
    default_format: default_format,
    member_date_time: member_date_time,
    member_epoch_seconds: member_epoch_seconds,
    member_http_date: member_http_date,
    target_date_time: target_date_time,
    target_epoch_seconds: target_epoch_seconds,
    target_http_date: target_http_date,
  ))
}

pub fn encode_timestamp_format_headers_io_xml_inner(input: TimestampFormatHeadersIO) -> String {
  let inner = ""
  inner
}

pub fn encode_timestamp_format_headers_io_xml(input: TimestampFormatHeadersIO, root: String) -> String {
  xml.element(root, encode_timestamp_format_headers_io_xml_inner(input))
}

pub fn decode_timestamp_format_headers_io_xml(elem: xml_decode.Element) -> Result(TimestampFormatHeadersIO, String) {
  let default_format = option.None
  let member_date_time = option.None
  let member_epoch_seconds = option.None
  let member_http_date = option.None
  let target_date_time = option.None
  let target_epoch_seconds = option.None
  let target_http_date = option.None
  Ok(TimestampFormatHeadersIO(
    default_format: default_format,
    member_date_time: member_date_time,
    member_epoch_seconds: member_epoch_seconds,
    member_http_date: member_http_date,
    target_date_time: target_date_time,
    target_epoch_seconds: target_epoch_seconds,
    target_http_date: target_http_date,
  ))
}

pub type XmlAttributesRequest {
  XmlAttributesRequest(attr: option.Option(String), foo: option.Option(String))
}

pub fn encode_xml_attributes_request_struct(input: XmlAttributesRequest) -> json.Json {
  let pairs = []
  let pairs = case input.attr {
    option.Some(v) -> [#("attr", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_request_struct() -> decode.Decoder(XmlAttributesRequest) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesRequest(
    attr: attr,
    foo: foo,
  ))
}

pub fn decode_xml_attributes_request_struct_params() -> decode.Decoder(XmlAttributesRequest) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesRequest(
    attr: attr,
    foo: foo,
  ))
}

pub fn encode_xml_attributes_request_xml_inner(input: XmlAttributesRequest) -> String {
  let inner = ""
  let inner = case input.attr {
    option.Some(v) -> inner <> xml.element("attr", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_attributes_request_xml(input: XmlAttributesRequest, root: String) -> String {
  xml.element(root, encode_xml_attributes_request_xml_inner(input))
}

pub fn decode_xml_attributes_request_xml(elem: xml_decode.Element) -> Result(XmlAttributesRequest, String) {
  use attr <- result.try(xml_decode.optional_child(elem, "attr", xml_decode.string_text))
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  Ok(XmlAttributesRequest(
    attr: attr,
    foo: foo,
  ))
}

pub type XmlAttributesResponse {
  XmlAttributesResponse(attr: option.Option(String), foo: option.Option(String))
}

pub fn encode_xml_attributes_response_struct(input: XmlAttributesResponse) -> json.Json {
  let pairs = []
  let pairs = case input.attr {
    option.Some(v) -> [#("attr", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_response_struct() -> decode.Decoder(XmlAttributesResponse) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesResponse(
    attr: attr,
    foo: foo,
  ))
}

pub fn decode_xml_attributes_response_struct_params() -> decode.Decoder(XmlAttributesResponse) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesResponse(
    attr: attr,
    foo: foo,
  ))
}

pub fn encode_xml_attributes_response_xml_inner(input: XmlAttributesResponse) -> String {
  let inner = ""
  let inner = case input.attr {
    option.Some(v) -> inner <> xml.element("attr", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_attributes_response_xml(input: XmlAttributesResponse, root: String) -> String {
  xml.element(root, encode_xml_attributes_response_xml_inner(input))
}

pub fn decode_xml_attributes_response_xml(elem: xml_decode.Element) -> Result(XmlAttributesResponse, String) {
  use attr <- result.try(xml_decode.optional_child(elem, "attr", xml_decode.string_text))
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  Ok(XmlAttributesResponse(
    attr: attr,
    foo: foo,
  ))
}

pub type XmlAttributesInMiddleRequest {
  XmlAttributesInMiddleRequest(payload: option.Option(XmlAttributesInMiddlePayloadRequest))
}

pub fn encode_xml_attributes_in_middle_request_struct(input: XmlAttributesInMiddleRequest) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", encode_xml_attributes_in_middle_payload_request_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_in_middle_request_struct() -> decode.Decoder(XmlAttributesInMiddleRequest) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_in_middle_payload_request_struct()))
  decode.success(XmlAttributesInMiddleRequest(
    payload: payload,
  ))
}

pub fn decode_xml_attributes_in_middle_request_struct_params() -> decode.Decoder(XmlAttributesInMiddleRequest) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_in_middle_payload_request_struct_params()))
  decode.success(XmlAttributesInMiddleRequest(
    payload: payload,
  ))
}

pub fn encode_xml_attributes_in_middle_request_xml_inner(input: XmlAttributesInMiddleRequest) -> String {
  let inner = ""
  inner
}

pub fn encode_xml_attributes_in_middle_request_xml(input: XmlAttributesInMiddleRequest, root: String) -> String {
  xml.element(root, encode_xml_attributes_in_middle_request_xml_inner(input))
}

pub fn decode_xml_attributes_in_middle_request_xml(elem: xml_decode.Element) -> Result(XmlAttributesInMiddleRequest, String) {
  let payload = option.None
  Ok(XmlAttributesInMiddleRequest(
    payload: payload,
  ))
}

pub type XmlAttributesInMiddlePayloadRequest {
  XmlAttributesInMiddlePayloadRequest(attr: option.Option(String), baz: option.Option(String), foo: option.Option(String))
}

pub fn encode_xml_attributes_in_middle_payload_request_struct(input: XmlAttributesInMiddlePayloadRequest) -> json.Json {
  let pairs = []
  let pairs = case input.attr {
    option.Some(v) -> [#("attr", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.baz {
    option.Some(v) -> [#("baz", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_in_middle_payload_request_struct() -> decode.Decoder(XmlAttributesInMiddlePayloadRequest) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesInMiddlePayloadRequest(
    attr: attr,
    baz: baz,
    foo: foo,
  ))
}

pub fn decode_xml_attributes_in_middle_payload_request_struct_params() -> decode.Decoder(XmlAttributesInMiddlePayloadRequest) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesInMiddlePayloadRequest(
    attr: attr,
    baz: baz,
    foo: foo,
  ))
}

pub fn encode_xml_attributes_in_middle_payload_request_xml_inner(input: XmlAttributesInMiddlePayloadRequest) -> String {
  let inner = ""
  let inner = case input.attr {
    option.Some(v) -> inner <> xml.element("attr", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.baz {
    option.Some(v) -> inner <> xml.element("baz", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_attributes_in_middle_payload_request_xml(input: XmlAttributesInMiddlePayloadRequest, root: String) -> String {
  xml.element(root, encode_xml_attributes_in_middle_payload_request_xml_inner(input))
}

pub fn decode_xml_attributes_in_middle_payload_request_xml(elem: xml_decode.Element) -> Result(XmlAttributesInMiddlePayloadRequest, String) {
  use attr <- result.try(xml_decode.optional_child(elem, "attr", xml_decode.string_text))
  use baz <- result.try(xml_decode.optional_child(elem, "baz", xml_decode.string_text))
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  Ok(XmlAttributesInMiddlePayloadRequest(
    attr: attr,
    baz: baz,
    foo: foo,
  ))
}

pub type XmlAttributesInMiddleResponse {
  XmlAttributesInMiddleResponse(payload: option.Option(XmlAttributesInMiddlePayloadResponse))
}

pub fn encode_xml_attributes_in_middle_response_struct(input: XmlAttributesInMiddleResponse) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", encode_xml_attributes_in_middle_payload_response_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_in_middle_response_struct() -> decode.Decoder(XmlAttributesInMiddleResponse) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_in_middle_payload_response_struct()))
  decode.success(XmlAttributesInMiddleResponse(
    payload: payload,
  ))
}

pub fn decode_xml_attributes_in_middle_response_struct_params() -> decode.Decoder(XmlAttributesInMiddleResponse) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_in_middle_payload_response_struct_params()))
  decode.success(XmlAttributesInMiddleResponse(
    payload: payload,
  ))
}

pub fn encode_xml_attributes_in_middle_response_xml_inner(input: XmlAttributesInMiddleResponse) -> String {
  let inner = ""
  inner
}

pub fn encode_xml_attributes_in_middle_response_xml(input: XmlAttributesInMiddleResponse, root: String) -> String {
  xml.element(root, encode_xml_attributes_in_middle_response_xml_inner(input))
}

pub fn decode_xml_attributes_in_middle_response_xml(elem: xml_decode.Element) -> Result(XmlAttributesInMiddleResponse, String) {
  let payload = option.None
  Ok(XmlAttributesInMiddleResponse(
    payload: payload,
  ))
}

pub type XmlAttributesInMiddlePayloadResponse {
  XmlAttributesInMiddlePayloadResponse(attr: option.Option(String), baz: option.Option(String), foo: option.Option(String))
}

pub fn encode_xml_attributes_in_middle_payload_response_struct(input: XmlAttributesInMiddlePayloadResponse) -> json.Json {
  let pairs = []
  let pairs = case input.attr {
    option.Some(v) -> [#("attr", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.baz {
    option.Some(v) -> [#("baz", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_in_middle_payload_response_struct() -> decode.Decoder(XmlAttributesInMiddlePayloadResponse) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesInMiddlePayloadResponse(
    attr: attr,
    baz: baz,
    foo: foo,
  ))
}

pub fn decode_xml_attributes_in_middle_payload_response_struct_params() -> decode.Decoder(XmlAttributesInMiddlePayloadResponse) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use baz <- decode.optional_field("baz", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesInMiddlePayloadResponse(
    attr: attr,
    baz: baz,
    foo: foo,
  ))
}

pub fn encode_xml_attributes_in_middle_payload_response_xml_inner(input: XmlAttributesInMiddlePayloadResponse) -> String {
  let inner = ""
  let inner = case input.attr {
    option.Some(v) -> inner <> xml.element("attr", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.baz {
    option.Some(v) -> inner <> xml.element("baz", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_attributes_in_middle_payload_response_xml(input: XmlAttributesInMiddlePayloadResponse, root: String) -> String {
  xml.element(root, encode_xml_attributes_in_middle_payload_response_xml_inner(input))
}

pub fn decode_xml_attributes_in_middle_payload_response_xml(elem: xml_decode.Element) -> Result(XmlAttributesInMiddlePayloadResponse, String) {
  use attr <- result.try(xml_decode.optional_child(elem, "attr", xml_decode.string_text))
  use baz <- result.try(xml_decode.optional_child(elem, "baz", xml_decode.string_text))
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  Ok(XmlAttributesInMiddlePayloadResponse(
    attr: attr,
    baz: baz,
    foo: foo,
  ))
}

pub type XmlAttributesOnPayloadRequest {
  XmlAttributesOnPayloadRequest(payload: option.Option(XmlAttributesPayloadRequest))
}

pub fn encode_xml_attributes_on_payload_request_struct(input: XmlAttributesOnPayloadRequest) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", encode_xml_attributes_payload_request_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_on_payload_request_struct() -> decode.Decoder(XmlAttributesOnPayloadRequest) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_payload_request_struct()))
  decode.success(XmlAttributesOnPayloadRequest(
    payload: payload,
  ))
}

pub fn decode_xml_attributes_on_payload_request_struct_params() -> decode.Decoder(XmlAttributesOnPayloadRequest) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_payload_request_struct_params()))
  decode.success(XmlAttributesOnPayloadRequest(
    payload: payload,
  ))
}

pub fn encode_xml_attributes_on_payload_request_xml_inner(input: XmlAttributesOnPayloadRequest) -> String {
  let inner = ""
  inner
}

pub fn encode_xml_attributes_on_payload_request_xml(input: XmlAttributesOnPayloadRequest, root: String) -> String {
  xml.element(root, encode_xml_attributes_on_payload_request_xml_inner(input))
}

pub fn decode_xml_attributes_on_payload_request_xml(elem: xml_decode.Element) -> Result(XmlAttributesOnPayloadRequest, String) {
  let payload = option.None
  Ok(XmlAttributesOnPayloadRequest(
    payload: payload,
  ))
}

pub type XmlAttributesPayloadRequest {
  XmlAttributesPayloadRequest(attr: option.Option(String), foo: option.Option(String))
}

pub fn encode_xml_attributes_payload_request_struct(input: XmlAttributesPayloadRequest) -> json.Json {
  let pairs = []
  let pairs = case input.attr {
    option.Some(v) -> [#("attr", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_payload_request_struct() -> decode.Decoder(XmlAttributesPayloadRequest) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesPayloadRequest(
    attr: attr,
    foo: foo,
  ))
}

pub fn decode_xml_attributes_payload_request_struct_params() -> decode.Decoder(XmlAttributesPayloadRequest) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesPayloadRequest(
    attr: attr,
    foo: foo,
  ))
}

pub fn encode_xml_attributes_payload_request_xml_inner(input: XmlAttributesPayloadRequest) -> String {
  let inner = ""
  let inner = case input.attr {
    option.Some(v) -> inner <> xml.element("attr", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_attributes_payload_request_xml(input: XmlAttributesPayloadRequest, root: String) -> String {
  xml.element(root, encode_xml_attributes_payload_request_xml_inner(input))
}

pub fn decode_xml_attributes_payload_request_xml(elem: xml_decode.Element) -> Result(XmlAttributesPayloadRequest, String) {
  use attr <- result.try(xml_decode.optional_child(elem, "attr", xml_decode.string_text))
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  Ok(XmlAttributesPayloadRequest(
    attr: attr,
    foo: foo,
  ))
}

pub type XmlAttributesOnPayloadResponse {
  XmlAttributesOnPayloadResponse(payload: option.Option(XmlAttributesPayloadResponse))
}

pub fn encode_xml_attributes_on_payload_response_struct(input: XmlAttributesOnPayloadResponse) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", encode_xml_attributes_payload_response_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_on_payload_response_struct() -> decode.Decoder(XmlAttributesOnPayloadResponse) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_payload_response_struct()))
  decode.success(XmlAttributesOnPayloadResponse(
    payload: payload,
  ))
}

pub fn decode_xml_attributes_on_payload_response_struct_params() -> decode.Decoder(XmlAttributesOnPayloadResponse) {
  use <- decode.recursive
  use payload <- decode.optional_field("payload", option.None, decode.optional(decode_xml_attributes_payload_response_struct_params()))
  decode.success(XmlAttributesOnPayloadResponse(
    payload: payload,
  ))
}

pub fn encode_xml_attributes_on_payload_response_xml_inner(input: XmlAttributesOnPayloadResponse) -> String {
  let inner = ""
  inner
}

pub fn encode_xml_attributes_on_payload_response_xml(input: XmlAttributesOnPayloadResponse, root: String) -> String {
  xml.element(root, encode_xml_attributes_on_payload_response_xml_inner(input))
}

pub fn decode_xml_attributes_on_payload_response_xml(elem: xml_decode.Element) -> Result(XmlAttributesOnPayloadResponse, String) {
  let payload = option.None
  Ok(XmlAttributesOnPayloadResponse(
    payload: payload,
  ))
}

pub type XmlAttributesPayloadResponse {
  XmlAttributesPayloadResponse(attr: option.Option(String), foo: option.Option(String))
}

pub fn encode_xml_attributes_payload_response_struct(input: XmlAttributesPayloadResponse) -> json.Json {
  let pairs = []
  let pairs = case input.attr {
    option.Some(v) -> [#("attr", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_attributes_payload_response_struct() -> decode.Decoder(XmlAttributesPayloadResponse) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesPayloadResponse(
    attr: attr,
    foo: foo,
  ))
}

pub fn decode_xml_attributes_payload_response_struct_params() -> decode.Decoder(XmlAttributesPayloadResponse) {
  use <- decode.recursive
  use attr <- decode.optional_field("attr", option.None, decode.optional(decode.string))
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  decode.success(XmlAttributesPayloadResponse(
    attr: attr,
    foo: foo,
  ))
}

pub fn encode_xml_attributes_payload_response_xml_inner(input: XmlAttributesPayloadResponse) -> String {
  let inner = ""
  let inner = case input.attr {
    option.Some(v) -> inner <> xml.element("attr", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_attributes_payload_response_xml(input: XmlAttributesPayloadResponse, root: String) -> String {
  xml.element(root, encode_xml_attributes_payload_response_xml_inner(input))
}

pub fn decode_xml_attributes_payload_response_xml(elem: xml_decode.Element) -> Result(XmlAttributesPayloadResponse, String) {
  use attr <- result.try(xml_decode.optional_child(elem, "attr", xml_decode.string_text))
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  Ok(XmlAttributesPayloadResponse(
    attr: attr,
    foo: foo,
  ))
}

pub type XmlBlobsRequest {
  XmlBlobsRequest(data: option.Option(BitArray))
}

pub fn encode_xml_blobs_request_struct(input: XmlBlobsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [#("data", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_blobs_request_struct() -> decode.Decoder(XmlBlobsRequest) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlBlobsRequest(
    data: data,
  ))
}

pub fn decode_xml_blobs_request_struct_params() -> decode.Decoder(XmlBlobsRequest) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlBlobsRequest(
    data: data,
  ))
}

pub fn encode_xml_blobs_request_xml_inner(input: XmlBlobsRequest) -> String {
  let inner = ""
  let inner = case input.data {
    option.Some(v) -> inner <> xml.element("data", xml.blob_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_blobs_request_xml(input: XmlBlobsRequest, root: String) -> String {
  xml.element(root, encode_xml_blobs_request_xml_inner(input))
}

pub fn decode_xml_blobs_request_xml(elem: xml_decode.Element) -> Result(XmlBlobsRequest, String) {
  use data <- result.try(xml_decode.optional_child(elem, "data", fn(e) { case xml_decode.string_text(e) { Ok(s) -> case bit_array.base64_decode(s) { Ok(b) -> Ok(b) Error(_) -> Error("xml: bad base64") } Error(r) -> Error(r) } }))
  Ok(XmlBlobsRequest(
    data: data,
  ))
}

pub type XmlBlobsResponse {
  XmlBlobsResponse(data: option.Option(BitArray))
}

pub fn encode_xml_blobs_response_struct(input: XmlBlobsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [#("data", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_blobs_response_struct() -> decode.Decoder(XmlBlobsResponse) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlBlobsResponse(
    data: data,
  ))
}

pub fn decode_xml_blobs_response_struct_params() -> decode.Decoder(XmlBlobsResponse) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlBlobsResponse(
    data: data,
  ))
}

pub fn encode_xml_blobs_response_xml_inner(input: XmlBlobsResponse) -> String {
  let inner = ""
  let inner = case input.data {
    option.Some(v) -> inner <> xml.element("data", xml.blob_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_blobs_response_xml(input: XmlBlobsResponse, root: String) -> String {
  xml.element(root, encode_xml_blobs_response_xml_inner(input))
}

pub fn decode_xml_blobs_response_xml(elem: xml_decode.Element) -> Result(XmlBlobsResponse, String) {
  use data <- result.try(xml_decode.optional_child(elem, "data", fn(e) { case xml_decode.string_text(e) { Ok(s) -> case bit_array.base64_decode(s) { Ok(b) -> Ok(b) Error(_) -> Error("xml: bad base64") } Error(r) -> Error(r) } }))
  Ok(XmlBlobsResponse(
    data: data,
  ))
}

pub type XmlEmptyBlobsRequest {
  XmlEmptyBlobsRequest(data: option.Option(BitArray))
}

pub fn encode_xml_empty_blobs_request_struct(input: XmlEmptyBlobsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [#("data", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_blobs_request_struct() -> decode.Decoder(XmlEmptyBlobsRequest) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlEmptyBlobsRequest(
    data: data,
  ))
}

pub fn decode_xml_empty_blobs_request_struct_params() -> decode.Decoder(XmlEmptyBlobsRequest) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlEmptyBlobsRequest(
    data: data,
  ))
}

pub fn encode_xml_empty_blobs_request_xml_inner(input: XmlEmptyBlobsRequest) -> String {
  let inner = ""
  let inner = case input.data {
    option.Some(v) -> inner <> xml.element("data", xml.blob_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_blobs_request_xml(input: XmlEmptyBlobsRequest, root: String) -> String {
  xml.element(root, encode_xml_empty_blobs_request_xml_inner(input))
}

pub fn decode_xml_empty_blobs_request_xml(elem: xml_decode.Element) -> Result(XmlEmptyBlobsRequest, String) {
  use data <- result.try(xml_decode.optional_child(elem, "data", fn(e) { case xml_decode.string_text(e) { Ok(s) -> case bit_array.base64_decode(s) { Ok(b) -> Ok(b) Error(_) -> Error("xml: bad base64") } Error(r) -> Error(r) } }))
  Ok(XmlEmptyBlobsRequest(
    data: data,
  ))
}

pub type XmlEmptyBlobsResponse {
  XmlEmptyBlobsResponse(data: option.Option(BitArray))
}

pub fn encode_xml_empty_blobs_response_struct(input: XmlEmptyBlobsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [#("data", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_blobs_response_struct() -> decode.Decoder(XmlEmptyBlobsResponse) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlEmptyBlobsResponse(
    data: data,
  ))
}

pub fn decode_xml_empty_blobs_response_struct_params() -> decode.Decoder(XmlEmptyBlobsResponse) {
  use <- decode.recursive
  use data <- decode.optional_field("data", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  decode.success(XmlEmptyBlobsResponse(
    data: data,
  ))
}

pub fn encode_xml_empty_blobs_response_xml_inner(input: XmlEmptyBlobsResponse) -> String {
  let inner = ""
  let inner = case input.data {
    option.Some(v) -> inner <> xml.element("data", xml.blob_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_blobs_response_xml(input: XmlEmptyBlobsResponse, root: String) -> String {
  xml.element(root, encode_xml_empty_blobs_response_xml_inner(input))
}

pub fn decode_xml_empty_blobs_response_xml(elem: xml_decode.Element) -> Result(XmlEmptyBlobsResponse, String) {
  use data <- result.try(xml_decode.optional_child(elem, "data", fn(e) { case xml_decode.string_text(e) { Ok(s) -> case bit_array.base64_decode(s) { Ok(b) -> Ok(b) Error(_) -> Error("xml: bad base64") } Error(r) -> Error(r) } }))
  Ok(XmlEmptyBlobsResponse(
    data: data,
  ))
}

pub type XmlEmptyListsRequest {
  XmlEmptyListsRequest(boolean_list: option.Option(List(Bool)), enum_list: option.Option(List(FooEnum)), flattened_list: option.Option(List(String)), flattened_list2: option.Option(List(String)), flattened_list_with_member_namespace: option.Option(List(String)), flattened_list_with_namespace: option.Option(List(String)), flattened_structure_list: option.Option(List(StructureListMember)), int_enum_list: option.Option(List(IntegerEnum)), integer_list: option.Option(List(Int)), nested_string_list: option.Option(List(List(String))), renamed_list_members: option.Option(List(String)), string_list: option.Option(List(String)), string_set: option.Option(List(String)), structure_list: option.Option(List(StructureListMember)), timestamp_list: option.Option(List(Int)))
}

pub fn encode_xml_empty_lists_request_struct(input: XmlEmptyListsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_list {
    option.Some(v) -> [#("booleanList", fn(xs) { json.array(xs, json.bool) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.enum_list {
    option.Some(v) -> [#("enumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list {
    option.Some(v) -> [#("flattenedList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list2 {
    option.Some(v) -> [#("flattenedList2", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_member_namespace {
    option.Some(v) -> [#("flattenedListWithMemberNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_namespace {
    option.Some(v) -> [#("flattenedListWithNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_structure_list {
    option.Some(v) -> [#("flattenedStructureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [#("intEnumList", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_list {
    option.Some(v) -> [#("integerList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested_string_list {
    option.Some(v) -> [#("nestedStringList", fn(xs) { json.array(xs, fn(xs) { json.array(xs, json.string) }) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.renamed_list_members {
    option.Some(v) -> [#("renamedListMembers", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_list {
    option.Some(v) -> [#("stringList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_set {
    option.Some(v) -> [#("stringSet", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.structure_list {
    option.Some(v) -> [#("structureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.timestamp_list {
    option.Some(v) -> [#("timestampList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_lists_request_struct() -> decode.Decoder(XmlEmptyListsRequest) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlEmptyListsRequest(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn decode_xml_empty_lists_request_struct_params() -> decode.Decoder(XmlEmptyListsRequest) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlEmptyListsRequest(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn encode_xml_empty_lists_request_xml_inner(input: XmlEmptyListsRequest) -> String {
  let inner = ""
  let inner = case input.boolean_list {
    option.Some(v) -> inner <> xml.list_element("booleanList", "member", list.map(v, fn(item) { let v = item xml.bool_text(v) }))
    option.None -> inner
  }
  let inner = case input.enum_list {
    option.Some(v) -> inner <> xml.list_element("enumList", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  let inner = case input.flattened_list {
    option.Some(v) -> inner <> xml.list_element("flattenedList", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list2 {
    option.Some(v) -> inner <> xml.list_element("flattenedList2", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_member_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithMemberNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_structure_list {
    option.Some(v) -> inner <> xml.list_element("flattenedStructureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.int_enum_list {
    option.Some(v) -> inner <> xml.list_element("intEnumList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.integer_list {
    option.Some(v) -> inner <> xml.list_element("integerList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  let inner = case input.nested_string_list {
    option.Some(v) -> inner <> xml.list_element("nestedStringList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.renamed_list_members {
    option.Some(v) -> inner <> xml.list_element("renamedListMembers", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_list {
    option.Some(v) -> inner <> xml.list_element("stringList", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_set {
    option.Some(v) -> inner <> xml.list_element("stringSet", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.structure_list {
    option.Some(v) -> inner <> xml.list_element("structureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.timestamp_list {
    option.Some(v) -> inner <> xml.list_element("timestampList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_lists_request_xml(input: XmlEmptyListsRequest, root: String) -> String {
  xml.element(root, encode_xml_empty_lists_request_xml_inner(input))
}

pub fn decode_xml_empty_lists_request_xml(elem: xml_decode.Element) -> Result(XmlEmptyListsRequest, String) {
  use boolean_list <- result.try(xml_decode.optional_list(elem, "booleanList", "member", xml_decode.bool_text))
  use enum_list <- result.try(xml_decode.optional_list(elem, "enumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use flattened_list <- result.try(xml_decode.optional_list(elem, "flattenedList", "item", xml_decode.string_text))
  use flattened_list2 <- result.try(xml_decode.optional_list(elem, "flattenedList2", "item", xml_decode.string_text))
  use flattened_list_with_member_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithMemberNamespace", "member", xml_decode.string_text))
  use flattened_list_with_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithNamespace", "member", xml_decode.string_text))
  use flattened_structure_list <- result.try(xml_decode.optional_list(elem, "flattenedStructureList", "item", decode_structure_list_member_xml))
  use int_enum_list <- result.try(xml_decode.optional_list(elem, "intEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use integer_list <- result.try(xml_decode.optional_list(elem, "integerList", "member", xml_decode.int_text))
  use nested_string_list <- result.try(xml_decode.optional_list(elem, "nestedStringList", "member", fn(_) { Error("xml: unsupported list element") }))
  use renamed_list_members <- result.try(xml_decode.optional_list(elem, "renamedListMembers", "item", xml_decode.string_text))
  use string_list <- result.try(xml_decode.optional_list(elem, "stringList", "member", xml_decode.string_text))
  use string_set <- result.try(xml_decode.optional_list(elem, "stringSet", "member", xml_decode.string_text))
  use structure_list <- result.try(xml_decode.optional_list(elem, "structureList", "item", decode_structure_list_member_xml))
  use timestamp_list <- result.try(xml_decode.optional_list(elem, "timestampList", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlEmptyListsRequest(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub type StructureListMember {
  StructureListMember(a: option.Option(String), b: option.Option(String))
}

pub fn encode_structure_list_member_struct(input: StructureListMember) -> json.Json {
  let pairs = []
  let pairs = case input.a {
    option.Some(v) -> [#("a", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.b {
    option.Some(v) -> [#("b", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_structure_list_member_struct() -> decode.Decoder(StructureListMember) {
  use <- decode.recursive
  use a <- decode.optional_field("a", option.None, decode.optional(decode.string))
  use b <- decode.optional_field("b", option.None, decode.optional(decode.string))
  decode.success(StructureListMember(
    a: a,
    b: b,
  ))
}

pub fn decode_structure_list_member_struct_params() -> decode.Decoder(StructureListMember) {
  use <- decode.recursive
  use a <- decode.optional_field("a", option.None, decode.optional(decode.string))
  use b <- decode.optional_field("b", option.None, decode.optional(decode.string))
  decode.success(StructureListMember(
    a: a,
    b: b,
  ))
}

pub fn encode_structure_list_member_xml_inner(input: StructureListMember) -> String {
  let inner = ""
  let inner = case input.a {
    option.Some(v) -> inner <> xml.element("a", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.b {
    option.Some(v) -> inner <> xml.element("b", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_structure_list_member_xml(input: StructureListMember, root: String) -> String {
  xml.element(root, encode_structure_list_member_xml_inner(input))
}

pub fn decode_structure_list_member_xml(elem: xml_decode.Element) -> Result(StructureListMember, String) {
  use a <- result.try(xml_decode.optional_child(elem, "a", xml_decode.string_text))
  use b <- result.try(xml_decode.optional_child(elem, "b", xml_decode.string_text))
  Ok(StructureListMember(
    a: a,
    b: b,
  ))
}

pub type XmlEmptyListsResponse {
  XmlEmptyListsResponse(boolean_list: option.Option(List(Bool)), enum_list: option.Option(List(FooEnum)), flattened_list: option.Option(List(String)), flattened_list2: option.Option(List(String)), flattened_list_with_member_namespace: option.Option(List(String)), flattened_list_with_namespace: option.Option(List(String)), flattened_structure_list: option.Option(List(StructureListMember)), int_enum_list: option.Option(List(IntegerEnum)), integer_list: option.Option(List(Int)), nested_string_list: option.Option(List(List(String))), renamed_list_members: option.Option(List(String)), string_list: option.Option(List(String)), string_set: option.Option(List(String)), structure_list: option.Option(List(StructureListMember)), timestamp_list: option.Option(List(Int)))
}

pub fn encode_xml_empty_lists_response_struct(input: XmlEmptyListsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_list {
    option.Some(v) -> [#("booleanList", fn(xs) { json.array(xs, json.bool) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.enum_list {
    option.Some(v) -> [#("enumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list {
    option.Some(v) -> [#("flattenedList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list2 {
    option.Some(v) -> [#("flattenedList2", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_member_namespace {
    option.Some(v) -> [#("flattenedListWithMemberNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_namespace {
    option.Some(v) -> [#("flattenedListWithNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_structure_list {
    option.Some(v) -> [#("flattenedStructureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [#("intEnumList", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_list {
    option.Some(v) -> [#("integerList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested_string_list {
    option.Some(v) -> [#("nestedStringList", fn(xs) { json.array(xs, fn(xs) { json.array(xs, json.string) }) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.renamed_list_members {
    option.Some(v) -> [#("renamedListMembers", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_list {
    option.Some(v) -> [#("stringList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_set {
    option.Some(v) -> [#("stringSet", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.structure_list {
    option.Some(v) -> [#("structureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.timestamp_list {
    option.Some(v) -> [#("timestampList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_lists_response_struct() -> decode.Decoder(XmlEmptyListsResponse) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlEmptyListsResponse(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn decode_xml_empty_lists_response_struct_params() -> decode.Decoder(XmlEmptyListsResponse) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlEmptyListsResponse(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn encode_xml_empty_lists_response_xml_inner(input: XmlEmptyListsResponse) -> String {
  let inner = ""
  let inner = case input.boolean_list {
    option.Some(v) -> inner <> xml.list_element("booleanList", "member", list.map(v, fn(item) { let v = item xml.bool_text(v) }))
    option.None -> inner
  }
  let inner = case input.enum_list {
    option.Some(v) -> inner <> xml.list_element("enumList", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  let inner = case input.flattened_list {
    option.Some(v) -> inner <> xml.list_element("flattenedList", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list2 {
    option.Some(v) -> inner <> xml.list_element("flattenedList2", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_member_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithMemberNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_structure_list {
    option.Some(v) -> inner <> xml.list_element("flattenedStructureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.int_enum_list {
    option.Some(v) -> inner <> xml.list_element("intEnumList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.integer_list {
    option.Some(v) -> inner <> xml.list_element("integerList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  let inner = case input.nested_string_list {
    option.Some(v) -> inner <> xml.list_element("nestedStringList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.renamed_list_members {
    option.Some(v) -> inner <> xml.list_element("renamedListMembers", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_list {
    option.Some(v) -> inner <> xml.list_element("stringList", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_set {
    option.Some(v) -> inner <> xml.list_element("stringSet", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.structure_list {
    option.Some(v) -> inner <> xml.list_element("structureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.timestamp_list {
    option.Some(v) -> inner <> xml.list_element("timestampList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_lists_response_xml(input: XmlEmptyListsResponse, root: String) -> String {
  xml.element(root, encode_xml_empty_lists_response_xml_inner(input))
}

pub fn decode_xml_empty_lists_response_xml(elem: xml_decode.Element) -> Result(XmlEmptyListsResponse, String) {
  use boolean_list <- result.try(xml_decode.optional_list(elem, "booleanList", "member", xml_decode.bool_text))
  use enum_list <- result.try(xml_decode.optional_list(elem, "enumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use flattened_list <- result.try(xml_decode.optional_list(elem, "flattenedList", "item", xml_decode.string_text))
  use flattened_list2 <- result.try(xml_decode.optional_list(elem, "flattenedList2", "item", xml_decode.string_text))
  use flattened_list_with_member_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithMemberNamespace", "member", xml_decode.string_text))
  use flattened_list_with_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithNamespace", "member", xml_decode.string_text))
  use flattened_structure_list <- result.try(xml_decode.optional_list(elem, "flattenedStructureList", "item", decode_structure_list_member_xml))
  use int_enum_list <- result.try(xml_decode.optional_list(elem, "intEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use integer_list <- result.try(xml_decode.optional_list(elem, "integerList", "member", xml_decode.int_text))
  use nested_string_list <- result.try(xml_decode.optional_list(elem, "nestedStringList", "member", fn(_) { Error("xml: unsupported list element") }))
  use renamed_list_members <- result.try(xml_decode.optional_list(elem, "renamedListMembers", "item", xml_decode.string_text))
  use string_list <- result.try(xml_decode.optional_list(elem, "stringList", "member", xml_decode.string_text))
  use string_set <- result.try(xml_decode.optional_list(elem, "stringSet", "member", xml_decode.string_text))
  use structure_list <- result.try(xml_decode.optional_list(elem, "structureList", "item", decode_structure_list_member_xml))
  use timestamp_list <- result.try(xml_decode.optional_list(elem, "timestampList", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlEmptyListsResponse(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub type XmlEmptyMapsRequest {
  XmlEmptyMapsRequest(my_map: option.Option(dict.Dict(String, GreetingStruct)))
}

pub fn encode_xml_empty_maps_request_struct(input: XmlEmptyMapsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_greeting_struct_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_maps_request_struct() -> decode.Decoder(XmlEmptyMapsRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())))
  decode.success(XmlEmptyMapsRequest(
    my_map: my_map,
  ))
}

pub fn decode_xml_empty_maps_request_struct_params() -> decode.Decoder(XmlEmptyMapsRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct_params())))
  decode.success(XmlEmptyMapsRequest(
    my_map: my_map,
  ))
}

pub fn encode_xml_empty_maps_request_xml_inner(input: XmlEmptyMapsRequest) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_maps_request_xml(input: XmlEmptyMapsRequest, root: String) -> String {
  xml.element(root, encode_xml_empty_maps_request_xml_inner(input))
}

pub fn decode_xml_empty_maps_request_xml(elem: xml_decode.Element) -> Result(XmlEmptyMapsRequest, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, GreetingStruct)), String) = Ok(option.None)
    r })
  Ok(XmlEmptyMapsRequest(
    my_map: my_map,
  ))
}

pub type GreetingStruct {
  GreetingStruct(hi: option.Option(String))
}

pub fn encode_greeting_struct_struct(input: GreetingStruct) -> json.Json {
  let pairs = []
  let pairs = case input.hi {
    option.Some(v) -> [#("hi", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_greeting_struct_struct() -> decode.Decoder(GreetingStruct) {
  use <- decode.recursive
  use hi <- decode.optional_field("hi", option.None, decode.optional(decode.string))
  decode.success(GreetingStruct(
    hi: hi,
  ))
}

pub fn decode_greeting_struct_struct_params() -> decode.Decoder(GreetingStruct) {
  use <- decode.recursive
  use hi <- decode.optional_field("hi", option.None, decode.optional(decode.string))
  decode.success(GreetingStruct(
    hi: hi,
  ))
}

pub fn encode_greeting_struct_xml_inner(input: GreetingStruct) -> String {
  let inner = ""
  let inner = case input.hi {
    option.Some(v) -> inner <> xml.element("hi", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_greeting_struct_xml(input: GreetingStruct, root: String) -> String {
  xml.element(root, encode_greeting_struct_xml_inner(input))
}

pub fn decode_greeting_struct_xml(elem: xml_decode.Element) -> Result(GreetingStruct, String) {
  use hi <- result.try(xml_decode.optional_child(elem, "hi", xml_decode.string_text))
  Ok(GreetingStruct(
    hi: hi,
  ))
}

pub type XmlEmptyMapsResponse {
  XmlEmptyMapsResponse(my_map: option.Option(dict.Dict(String, GreetingStruct)))
}

pub fn encode_xml_empty_maps_response_struct(input: XmlEmptyMapsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_greeting_struct_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_maps_response_struct() -> decode.Decoder(XmlEmptyMapsResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())))
  decode.success(XmlEmptyMapsResponse(
    my_map: my_map,
  ))
}

pub fn decode_xml_empty_maps_response_struct_params() -> decode.Decoder(XmlEmptyMapsResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct_params())))
  decode.success(XmlEmptyMapsResponse(
    my_map: my_map,
  ))
}

pub fn encode_xml_empty_maps_response_xml_inner(input: XmlEmptyMapsResponse) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_maps_response_xml(input: XmlEmptyMapsResponse, root: String) -> String {
  xml.element(root, encode_xml_empty_maps_response_xml_inner(input))
}

pub fn decode_xml_empty_maps_response_xml(elem: xml_decode.Element) -> Result(XmlEmptyMapsResponse, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, GreetingStruct)), String) = Ok(option.None)
    r })
  Ok(XmlEmptyMapsResponse(
    my_map: my_map,
  ))
}

pub type XmlEmptyStringsRequest {
  XmlEmptyStringsRequest(empty_string: option.Option(String))
}

pub fn encode_xml_empty_strings_request_struct(input: XmlEmptyStringsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.empty_string {
    option.Some(v) -> [#("emptyString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_strings_request_struct() -> decode.Decoder(XmlEmptyStringsRequest) {
  use <- decode.recursive
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  decode.success(XmlEmptyStringsRequest(
    empty_string: empty_string,
  ))
}

pub fn decode_xml_empty_strings_request_struct_params() -> decode.Decoder(XmlEmptyStringsRequest) {
  use <- decode.recursive
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  decode.success(XmlEmptyStringsRequest(
    empty_string: empty_string,
  ))
}

pub fn encode_xml_empty_strings_request_xml_inner(input: XmlEmptyStringsRequest) -> String {
  let inner = ""
  let inner = case input.empty_string {
    option.Some(v) -> inner <> xml.element("emptyString", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_strings_request_xml(input: XmlEmptyStringsRequest, root: String) -> String {
  xml.element(root, encode_xml_empty_strings_request_xml_inner(input))
}

pub fn decode_xml_empty_strings_request_xml(elem: xml_decode.Element) -> Result(XmlEmptyStringsRequest, String) {
  use empty_string <- result.try(xml_decode.optional_child(elem, "emptyString", xml_decode.string_text))
  Ok(XmlEmptyStringsRequest(
    empty_string: empty_string,
  ))
}

pub type XmlEmptyStringsResponse {
  XmlEmptyStringsResponse(empty_string: option.Option(String))
}

pub fn encode_xml_empty_strings_response_struct(input: XmlEmptyStringsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.empty_string {
    option.Some(v) -> [#("emptyString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_empty_strings_response_struct() -> decode.Decoder(XmlEmptyStringsResponse) {
  use <- decode.recursive
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  decode.success(XmlEmptyStringsResponse(
    empty_string: empty_string,
  ))
}

pub fn decode_xml_empty_strings_response_struct_params() -> decode.Decoder(XmlEmptyStringsResponse) {
  use <- decode.recursive
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  decode.success(XmlEmptyStringsResponse(
    empty_string: empty_string,
  ))
}

pub fn encode_xml_empty_strings_response_xml_inner(input: XmlEmptyStringsResponse) -> String {
  let inner = ""
  let inner = case input.empty_string {
    option.Some(v) -> inner <> xml.element("emptyString", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_empty_strings_response_xml(input: XmlEmptyStringsResponse, root: String) -> String {
  xml.element(root, encode_xml_empty_strings_response_xml_inner(input))
}

pub fn decode_xml_empty_strings_response_xml(elem: xml_decode.Element) -> Result(XmlEmptyStringsResponse, String) {
  use empty_string <- result.try(xml_decode.optional_child(elem, "emptyString", xml_decode.string_text))
  Ok(XmlEmptyStringsResponse(
    empty_string: empty_string,
  ))
}

pub type XmlEnumsRequest {
  XmlEnumsRequest(foo_enum1: option.Option(FooEnum), foo_enum2: option.Option(FooEnum), foo_enum3: option.Option(FooEnum), foo_enum_list: option.Option(List(FooEnum)), foo_enum_map: option.Option(dict.Dict(String, FooEnum)), foo_enum_set: option.Option(List(FooEnum)))
}

pub fn encode_xml_enums_request_struct(input: XmlEnumsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.foo_enum1 {
    option.Some(v) -> [#("fooEnum1", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum2 {
    option.Some(v) -> [#("fooEnum2", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum3 {
    option.Some(v) -> [#("fooEnum3", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_list {
    option.Some(v) -> [#("fooEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_map {
    option.Some(v) -> [#("fooEnumMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_set {
    option.Some(v) -> [#("fooEnumSet", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_enums_request_struct() -> decode.Decoder(XmlEnumsRequest) {
  use <- decode.recursive
  use foo_enum1 <- decode.optional_field("fooEnum1", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum2 <- decode.optional_field("fooEnum2", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum3 <- decode.optional_field("fooEnum3", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum_list <- decode.optional_field("fooEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use foo_enum_map <- decode.optional_field("fooEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  use foo_enum_set <- decode.optional_field("fooEnumSet", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  decode.success(XmlEnumsRequest(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
  ))
}

pub fn decode_xml_enums_request_struct_params() -> decode.Decoder(XmlEnumsRequest) {
  use <- decode.recursive
  use foo_enum1 <- decode.optional_field("fooEnum1", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum2 <- decode.optional_field("fooEnum2", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum3 <- decode.optional_field("fooEnum3", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum_list <- decode.optional_field("fooEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use foo_enum_map <- decode.optional_field("fooEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  use foo_enum_set <- decode.optional_field("fooEnumSet", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  decode.success(XmlEnumsRequest(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
  ))
}

pub fn encode_xml_enums_request_xml_inner(input: XmlEnumsRequest) -> String {
  let inner = ""
  let inner = case input.foo_enum1 {
    option.Some(v) -> inner <> xml.element("fooEnum1", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> inner
  }
  let inner = case input.foo_enum2 {
    option.Some(v) -> inner <> xml.element("fooEnum2", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> inner
  }
  let inner = case input.foo_enum3 {
    option.Some(v) -> inner <> xml.element("fooEnum3", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> inner
  }
  let inner = case input.foo_enum_list {
    option.Some(v) -> inner <> xml.list_element("fooEnumList", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  let inner = case input.foo_enum_map {
    option.Some(v) -> inner <> xml.empty_element("fooEnumMap")
    option.None -> inner
  }
  let inner = case input.foo_enum_set {
    option.Some(v) -> inner <> xml.list_element("fooEnumSet", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_enums_request_xml(input: XmlEnumsRequest, root: String) -> String {
  xml.element(root, encode_xml_enums_request_xml_inner(input))
}

pub fn decode_xml_enums_request_xml(elem: xml_decode.Element) -> Result(XmlEnumsRequest, String) {
  use foo_enum1 <- result.try({ let r: Result(option.Option(FooEnum), String) = Ok(option.None)
    r })
  use foo_enum2 <- result.try({ let r: Result(option.Option(FooEnum), String) = Ok(option.None)
    r })
  use foo_enum3 <- result.try({ let r: Result(option.Option(FooEnum), String) = Ok(option.None)
    r })
  use foo_enum_list <- result.try(xml_decode.optional_list(elem, "fooEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use foo_enum_map <- result.try({ let r: Result(option.Option(dict.Dict(String, FooEnum)), String) = Ok(option.None)
    r })
  use foo_enum_set <- result.try(xml_decode.optional_list(elem, "fooEnumSet", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlEnumsRequest(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
  ))
}

pub type XmlEnumsResponse {
  XmlEnumsResponse(foo_enum1: option.Option(FooEnum), foo_enum2: option.Option(FooEnum), foo_enum3: option.Option(FooEnum), foo_enum_list: option.Option(List(FooEnum)), foo_enum_map: option.Option(dict.Dict(String, FooEnum)), foo_enum_set: option.Option(List(FooEnum)))
}

pub fn encode_xml_enums_response_struct(input: XmlEnumsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.foo_enum1 {
    option.Some(v) -> [#("fooEnum1", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum2 {
    option.Some(v) -> [#("fooEnum2", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum3 {
    option.Some(v) -> [#("fooEnum3", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_list {
    option.Some(v) -> [#("fooEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_map {
    option.Some(v) -> [#("fooEnumMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_set {
    option.Some(v) -> [#("fooEnumSet", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_enums_response_struct() -> decode.Decoder(XmlEnumsResponse) {
  use <- decode.recursive
  use foo_enum1 <- decode.optional_field("fooEnum1", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum2 <- decode.optional_field("fooEnum2", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum3 <- decode.optional_field("fooEnum3", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum_list <- decode.optional_field("fooEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use foo_enum_map <- decode.optional_field("fooEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  use foo_enum_set <- decode.optional_field("fooEnumSet", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  decode.success(XmlEnumsResponse(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
  ))
}

pub fn decode_xml_enums_response_struct_params() -> decode.Decoder(XmlEnumsResponse) {
  use <- decode.recursive
  use foo_enum1 <- decode.optional_field("fooEnum1", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum2 <- decode.optional_field("fooEnum2", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum3 <- decode.optional_field("fooEnum3", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum_list <- decode.optional_field("fooEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use foo_enum_map <- decode.optional_field("fooEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  use foo_enum_set <- decode.optional_field("fooEnumSet", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  decode.success(XmlEnumsResponse(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
  ))
}

pub fn encode_xml_enums_response_xml_inner(input: XmlEnumsResponse) -> String {
  let inner = ""
  let inner = case input.foo_enum1 {
    option.Some(v) -> inner <> xml.element("fooEnum1", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> inner
  }
  let inner = case input.foo_enum2 {
    option.Some(v) -> inner <> xml.element("fooEnum2", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> inner
  }
  let inner = case input.foo_enum3 {
    option.Some(v) -> inner <> xml.element("fooEnum3", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> inner
  }
  let inner = case input.foo_enum_list {
    option.Some(v) -> inner <> xml.list_element("fooEnumList", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  let inner = case input.foo_enum_map {
    option.Some(v) -> inner <> xml.empty_element("fooEnumMap")
    option.None -> inner
  }
  let inner = case input.foo_enum_set {
    option.Some(v) -> inner <> xml.list_element("fooEnumSet", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_enums_response_xml(input: XmlEnumsResponse, root: String) -> String {
  xml.element(root, encode_xml_enums_response_xml_inner(input))
}

pub fn decode_xml_enums_response_xml(elem: xml_decode.Element) -> Result(XmlEnumsResponse, String) {
  use foo_enum1 <- result.try({ let r: Result(option.Option(FooEnum), String) = Ok(option.None)
    r })
  use foo_enum2 <- result.try({ let r: Result(option.Option(FooEnum), String) = Ok(option.None)
    r })
  use foo_enum3 <- result.try({ let r: Result(option.Option(FooEnum), String) = Ok(option.None)
    r })
  use foo_enum_list <- result.try(xml_decode.optional_list(elem, "fooEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use foo_enum_map <- result.try({ let r: Result(option.Option(dict.Dict(String, FooEnum)), String) = Ok(option.None)
    r })
  use foo_enum_set <- result.try(xml_decode.optional_list(elem, "fooEnumSet", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlEnumsResponse(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
  ))
}

pub type XmlIntEnumsRequest {
  XmlIntEnumsRequest(int_enum1: option.Option(IntegerEnum), int_enum2: option.Option(IntegerEnum), int_enum3: option.Option(IntegerEnum), int_enum_list: option.Option(List(IntegerEnum)), int_enum_map: option.Option(dict.Dict(String, IntegerEnum)), int_enum_set: option.Option(List(IntegerEnum)))
}

pub fn encode_xml_int_enums_request_struct(input: XmlIntEnumsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.int_enum1 {
    option.Some(v) -> [#("intEnum1", encode_integer_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum2 {
    option.Some(v) -> [#("intEnum2", encode_integer_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum3 {
    option.Some(v) -> [#("intEnum3", encode_integer_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [#("intEnumList", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_map {
    option.Some(v) -> [#("intEnumMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_integer_enum_int_enum(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_set {
    option.Some(v) -> [#("intEnumSet", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_int_enums_request_struct() -> decode.Decoder(XmlIntEnumsRequest) {
  use <- decode.recursive
  use int_enum1 <- decode.optional_field("intEnum1", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum2 <- decode.optional_field("intEnum2", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum3 <- decode.optional_field("intEnum3", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use int_enum_map <- decode.optional_field("intEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_integer_enum_int_enum())))
  use int_enum_set <- decode.optional_field("intEnumSet", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  decode.success(XmlIntEnumsRequest(
    int_enum1: int_enum1,
    int_enum2: int_enum2,
    int_enum3: int_enum3,
    int_enum_list: int_enum_list,
    int_enum_map: int_enum_map,
    int_enum_set: int_enum_set,
  ))
}

pub fn decode_xml_int_enums_request_struct_params() -> decode.Decoder(XmlIntEnumsRequest) {
  use <- decode.recursive
  use int_enum1 <- decode.optional_field("intEnum1", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum2 <- decode.optional_field("intEnum2", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum3 <- decode.optional_field("intEnum3", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use int_enum_map <- decode.optional_field("intEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_integer_enum_int_enum())))
  use int_enum_set <- decode.optional_field("intEnumSet", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  decode.success(XmlIntEnumsRequest(
    int_enum1: int_enum1,
    int_enum2: int_enum2,
    int_enum3: int_enum3,
    int_enum_list: int_enum_list,
    int_enum_map: int_enum_map,
    int_enum_set: int_enum_set,
  ))
}

pub fn encode_xml_int_enums_request_xml_inner(input: XmlIntEnumsRequest) -> String {
  let inner = ""
  let inner = case input.int_enum1 {
    option.Some(v) -> inner <> xml.element("intEnum1", xml.int_text(case v { _ -> 0 }))
    option.None -> inner
  }
  let inner = case input.int_enum2 {
    option.Some(v) -> inner <> xml.element("intEnum2", xml.int_text(case v { _ -> 0 }))
    option.None -> inner
  }
  let inner = case input.int_enum3 {
    option.Some(v) -> inner <> xml.element("intEnum3", xml.int_text(case v { _ -> 0 }))
    option.None -> inner
  }
  let inner = case input.int_enum_list {
    option.Some(v) -> inner <> xml.list_element("intEnumList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.int_enum_map {
    option.Some(v) -> inner <> xml.empty_element("intEnumMap")
    option.None -> inner
  }
  let inner = case input.int_enum_set {
    option.Some(v) -> inner <> xml.list_element("intEnumSet", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_int_enums_request_xml(input: XmlIntEnumsRequest, root: String) -> String {
  xml.element(root, encode_xml_int_enums_request_xml_inner(input))
}

pub fn decode_xml_int_enums_request_xml(elem: xml_decode.Element) -> Result(XmlIntEnumsRequest, String) {
  use int_enum1 <- result.try({ let r: Result(option.Option(IntegerEnum), String) = Ok(option.None)
    r })
  use int_enum2 <- result.try({ let r: Result(option.Option(IntegerEnum), String) = Ok(option.None)
    r })
  use int_enum3 <- result.try({ let r: Result(option.Option(IntegerEnum), String) = Ok(option.None)
    r })
  use int_enum_list <- result.try(xml_decode.optional_list(elem, "intEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use int_enum_map <- result.try({ let r: Result(option.Option(dict.Dict(String, IntegerEnum)), String) = Ok(option.None)
    r })
  use int_enum_set <- result.try(xml_decode.optional_list(elem, "intEnumSet", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlIntEnumsRequest(
    int_enum1: int_enum1,
    int_enum2: int_enum2,
    int_enum3: int_enum3,
    int_enum_list: int_enum_list,
    int_enum_map: int_enum_map,
    int_enum_set: int_enum_set,
  ))
}

pub type XmlIntEnumsResponse {
  XmlIntEnumsResponse(int_enum1: option.Option(IntegerEnum), int_enum2: option.Option(IntegerEnum), int_enum3: option.Option(IntegerEnum), int_enum_list: option.Option(List(IntegerEnum)), int_enum_map: option.Option(dict.Dict(String, IntegerEnum)), int_enum_set: option.Option(List(IntegerEnum)))
}

pub fn encode_xml_int_enums_response_struct(input: XmlIntEnumsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.int_enum1 {
    option.Some(v) -> [#("intEnum1", encode_integer_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum2 {
    option.Some(v) -> [#("intEnum2", encode_integer_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum3 {
    option.Some(v) -> [#("intEnum3", encode_integer_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [#("intEnumList", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_map {
    option.Some(v) -> [#("intEnumMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_integer_enum_int_enum(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_set {
    option.Some(v) -> [#("intEnumSet", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_int_enums_response_struct() -> decode.Decoder(XmlIntEnumsResponse) {
  use <- decode.recursive
  use int_enum1 <- decode.optional_field("intEnum1", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum2 <- decode.optional_field("intEnum2", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum3 <- decode.optional_field("intEnum3", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use int_enum_map <- decode.optional_field("intEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_integer_enum_int_enum())))
  use int_enum_set <- decode.optional_field("intEnumSet", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  decode.success(XmlIntEnumsResponse(
    int_enum1: int_enum1,
    int_enum2: int_enum2,
    int_enum3: int_enum3,
    int_enum_list: int_enum_list,
    int_enum_map: int_enum_map,
    int_enum_set: int_enum_set,
  ))
}

pub fn decode_xml_int_enums_response_struct_params() -> decode.Decoder(XmlIntEnumsResponse) {
  use <- decode.recursive
  use int_enum1 <- decode.optional_field("intEnum1", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum2 <- decode.optional_field("intEnum2", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum3 <- decode.optional_field("intEnum3", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use int_enum_map <- decode.optional_field("intEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_integer_enum_int_enum())))
  use int_enum_set <- decode.optional_field("intEnumSet", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  decode.success(XmlIntEnumsResponse(
    int_enum1: int_enum1,
    int_enum2: int_enum2,
    int_enum3: int_enum3,
    int_enum_list: int_enum_list,
    int_enum_map: int_enum_map,
    int_enum_set: int_enum_set,
  ))
}

pub fn encode_xml_int_enums_response_xml_inner(input: XmlIntEnumsResponse) -> String {
  let inner = ""
  let inner = case input.int_enum1 {
    option.Some(v) -> inner <> xml.element("intEnum1", xml.int_text(case v { _ -> 0 }))
    option.None -> inner
  }
  let inner = case input.int_enum2 {
    option.Some(v) -> inner <> xml.element("intEnum2", xml.int_text(case v { _ -> 0 }))
    option.None -> inner
  }
  let inner = case input.int_enum3 {
    option.Some(v) -> inner <> xml.element("intEnum3", xml.int_text(case v { _ -> 0 }))
    option.None -> inner
  }
  let inner = case input.int_enum_list {
    option.Some(v) -> inner <> xml.list_element("intEnumList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.int_enum_map {
    option.Some(v) -> inner <> xml.empty_element("intEnumMap")
    option.None -> inner
  }
  let inner = case input.int_enum_set {
    option.Some(v) -> inner <> xml.list_element("intEnumSet", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_int_enums_response_xml(input: XmlIntEnumsResponse, root: String) -> String {
  xml.element(root, encode_xml_int_enums_response_xml_inner(input))
}

pub fn decode_xml_int_enums_response_xml(elem: xml_decode.Element) -> Result(XmlIntEnumsResponse, String) {
  use int_enum1 <- result.try({ let r: Result(option.Option(IntegerEnum), String) = Ok(option.None)
    r })
  use int_enum2 <- result.try({ let r: Result(option.Option(IntegerEnum), String) = Ok(option.None)
    r })
  use int_enum3 <- result.try({ let r: Result(option.Option(IntegerEnum), String) = Ok(option.None)
    r })
  use int_enum_list <- result.try(xml_decode.optional_list(elem, "intEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use int_enum_map <- result.try({ let r: Result(option.Option(dict.Dict(String, IntegerEnum)), String) = Ok(option.None)
    r })
  use int_enum_set <- result.try(xml_decode.optional_list(elem, "intEnumSet", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlIntEnumsResponse(
    int_enum1: int_enum1,
    int_enum2: int_enum2,
    int_enum3: int_enum3,
    int_enum_list: int_enum_list,
    int_enum_map: int_enum_map,
    int_enum_set: int_enum_set,
  ))
}

pub type XmlListsRequest {
  XmlListsRequest(boolean_list: option.Option(List(Bool)), enum_list: option.Option(List(FooEnum)), flattened_list: option.Option(List(String)), flattened_list2: option.Option(List(String)), flattened_list_with_member_namespace: option.Option(List(String)), flattened_list_with_namespace: option.Option(List(String)), flattened_structure_list: option.Option(List(StructureListMember)), int_enum_list: option.Option(List(IntegerEnum)), integer_list: option.Option(List(Int)), nested_string_list: option.Option(List(List(String))), renamed_list_members: option.Option(List(String)), string_list: option.Option(List(String)), string_set: option.Option(List(String)), structure_list: option.Option(List(StructureListMember)), timestamp_list: option.Option(List(Int)))
}

pub fn encode_xml_lists_request_struct(input: XmlListsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_list {
    option.Some(v) -> [#("booleanList", fn(xs) { json.array(xs, json.bool) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.enum_list {
    option.Some(v) -> [#("enumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list {
    option.Some(v) -> [#("flattenedList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list2 {
    option.Some(v) -> [#("flattenedList2", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_member_namespace {
    option.Some(v) -> [#("flattenedListWithMemberNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_namespace {
    option.Some(v) -> [#("flattenedListWithNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_structure_list {
    option.Some(v) -> [#("flattenedStructureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [#("intEnumList", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_list {
    option.Some(v) -> [#("integerList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested_string_list {
    option.Some(v) -> [#("nestedStringList", fn(xs) { json.array(xs, fn(xs) { json.array(xs, json.string) }) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.renamed_list_members {
    option.Some(v) -> [#("renamedListMembers", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_list {
    option.Some(v) -> [#("stringList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_set {
    option.Some(v) -> [#("stringSet", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.structure_list {
    option.Some(v) -> [#("structureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.timestamp_list {
    option.Some(v) -> [#("timestampList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_lists_request_struct() -> decode.Decoder(XmlListsRequest) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlListsRequest(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn decode_xml_lists_request_struct_params() -> decode.Decoder(XmlListsRequest) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlListsRequest(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn encode_xml_lists_request_xml_inner(input: XmlListsRequest) -> String {
  let inner = ""
  let inner = case input.boolean_list {
    option.Some(v) -> inner <> xml.list_element("booleanList", "member", list.map(v, fn(item) { let v = item xml.bool_text(v) }))
    option.None -> inner
  }
  let inner = case input.enum_list {
    option.Some(v) -> inner <> xml.list_element("enumList", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  let inner = case input.flattened_list {
    option.Some(v) -> inner <> xml.list_element("flattenedList", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list2 {
    option.Some(v) -> inner <> xml.list_element("flattenedList2", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_member_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithMemberNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_structure_list {
    option.Some(v) -> inner <> xml.list_element("flattenedStructureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.int_enum_list {
    option.Some(v) -> inner <> xml.list_element("intEnumList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.integer_list {
    option.Some(v) -> inner <> xml.list_element("integerList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  let inner = case input.nested_string_list {
    option.Some(v) -> inner <> xml.list_element("nestedStringList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.renamed_list_members {
    option.Some(v) -> inner <> xml.list_element("renamedListMembers", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_list {
    option.Some(v) -> inner <> xml.list_element("stringList", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_set {
    option.Some(v) -> inner <> xml.list_element("stringSet", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.structure_list {
    option.Some(v) -> inner <> xml.list_element("structureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.timestamp_list {
    option.Some(v) -> inner <> xml.list_element("timestampList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_lists_request_xml(input: XmlListsRequest, root: String) -> String {
  xml.element(root, encode_xml_lists_request_xml_inner(input))
}

pub fn decode_xml_lists_request_xml(elem: xml_decode.Element) -> Result(XmlListsRequest, String) {
  use boolean_list <- result.try(xml_decode.optional_list(elem, "booleanList", "member", xml_decode.bool_text))
  use enum_list <- result.try(xml_decode.optional_list(elem, "enumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use flattened_list <- result.try(xml_decode.optional_list(elem, "flattenedList", "item", xml_decode.string_text))
  use flattened_list2 <- result.try(xml_decode.optional_list(elem, "flattenedList2", "item", xml_decode.string_text))
  use flattened_list_with_member_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithMemberNamespace", "member", xml_decode.string_text))
  use flattened_list_with_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithNamespace", "member", xml_decode.string_text))
  use flattened_structure_list <- result.try(xml_decode.optional_list(elem, "flattenedStructureList", "item", decode_structure_list_member_xml))
  use int_enum_list <- result.try(xml_decode.optional_list(elem, "intEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use integer_list <- result.try(xml_decode.optional_list(elem, "integerList", "member", xml_decode.int_text))
  use nested_string_list <- result.try(xml_decode.optional_list(elem, "nestedStringList", "member", fn(_) { Error("xml: unsupported list element") }))
  use renamed_list_members <- result.try(xml_decode.optional_list(elem, "renamedListMembers", "item", xml_decode.string_text))
  use string_list <- result.try(xml_decode.optional_list(elem, "stringList", "member", xml_decode.string_text))
  use string_set <- result.try(xml_decode.optional_list(elem, "stringSet", "member", xml_decode.string_text))
  use structure_list <- result.try(xml_decode.optional_list(elem, "structureList", "item", decode_structure_list_member_xml))
  use timestamp_list <- result.try(xml_decode.optional_list(elem, "timestampList", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlListsRequest(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub type XmlListsResponse {
  XmlListsResponse(boolean_list: option.Option(List(Bool)), enum_list: option.Option(List(FooEnum)), flattened_list: option.Option(List(String)), flattened_list2: option.Option(List(String)), flattened_list_with_member_namespace: option.Option(List(String)), flattened_list_with_namespace: option.Option(List(String)), flattened_structure_list: option.Option(List(StructureListMember)), int_enum_list: option.Option(List(IntegerEnum)), integer_list: option.Option(List(Int)), nested_string_list: option.Option(List(List(String))), renamed_list_members: option.Option(List(String)), string_list: option.Option(List(String)), string_set: option.Option(List(String)), structure_list: option.Option(List(StructureListMember)), timestamp_list: option.Option(List(Int)))
}

pub fn encode_xml_lists_response_struct(input: XmlListsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_list {
    option.Some(v) -> [#("booleanList", fn(xs) { json.array(xs, json.bool) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.enum_list {
    option.Some(v) -> [#("enumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list {
    option.Some(v) -> [#("flattenedList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list2 {
    option.Some(v) -> [#("flattenedList2", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_member_namespace {
    option.Some(v) -> [#("flattenedListWithMemberNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_list_with_namespace {
    option.Some(v) -> [#("flattenedListWithNamespace", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.flattened_structure_list {
    option.Some(v) -> [#("flattenedStructureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [#("intEnumList", fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_list {
    option.Some(v) -> [#("integerList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested_string_list {
    option.Some(v) -> [#("nestedStringList", fn(xs) { json.array(xs, fn(xs) { json.array(xs, json.string) }) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.renamed_list_members {
    option.Some(v) -> [#("renamedListMembers", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_list {
    option.Some(v) -> [#("stringList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_set {
    option.Some(v) -> [#("stringSet", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.structure_list {
    option.Some(v) -> [#("structureList", fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.timestamp_list {
    option.Some(v) -> [#("timestampList", fn(xs) { json.array(xs, json.int) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_lists_response_struct() -> decode.Decoder(XmlListsResponse) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlListsResponse(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn decode_xml_lists_response_struct_params() -> decode.Decoder(XmlListsResponse) {
  use <- decode.recursive
  use boolean_list <- decode.optional_field("booleanList", option.None, decode.optional(decode.list(decode.bool)))
  use enum_list <- decode.optional_field("enumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use flattened_list <- decode.optional_field("flattenedList", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list2 <- decode.optional_field("flattenedList2", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_member_namespace <- decode.optional_field("flattenedListWithMemberNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_list_with_namespace <- decode.optional_field("flattenedListWithNamespace", option.None, decode.optional(decode.list(decode.string)))
  use flattened_structure_list <- decode.optional_field("flattenedStructureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use integer_list <- decode.optional_field("integerList", option.None, decode.optional(decode.list(decode.int)))
  use nested_string_list <- decode.optional_field("nestedStringList", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use renamed_list_members <- decode.optional_field("renamedListMembers", option.None, decode.optional(decode.list(decode.string)))
  use string_list <- decode.optional_field("stringList", option.None, decode.optional(decode.list(decode.string)))
  use string_set <- decode.optional_field("stringSet", option.None, decode.optional(decode.list(decode.string)))
  use structure_list <- decode.optional_field("structureList", option.None, decode.optional(decode.list(decode_structure_list_member_struct_params())))
  use timestamp_list <- decode.optional_field("timestampList", option.None, decode.optional(decode.list(json_timestamp.decoder())))
  decode.success(XmlListsResponse(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub fn encode_xml_lists_response_xml_inner(input: XmlListsResponse) -> String {
  let inner = ""
  let inner = case input.boolean_list {
    option.Some(v) -> inner <> xml.list_element("booleanList", "member", list.map(v, fn(item) { let v = item xml.bool_text(v) }))
    option.None -> inner
  }
  let inner = case input.enum_list {
    option.Some(v) -> inner <> xml.list_element("enumList", "member", list.map(v, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> inner
  }
  let inner = case input.flattened_list {
    option.Some(v) -> inner <> xml.list_element("flattenedList", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list2 {
    option.Some(v) -> inner <> xml.list_element("flattenedList2", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_member_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithMemberNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_list_with_namespace {
    option.Some(v) -> inner <> xml.list_element("flattenedListWithNamespace", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.flattened_structure_list {
    option.Some(v) -> inner <> xml.list_element("flattenedStructureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.int_enum_list {
    option.Some(v) -> inner <> xml.list_element("intEnumList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.integer_list {
    option.Some(v) -> inner <> xml.list_element("integerList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  let inner = case input.nested_string_list {
    option.Some(v) -> inner <> xml.list_element("nestedStringList", "member", list.map(v, fn(item) { let v = item "" }))
    option.None -> inner
  }
  let inner = case input.renamed_list_members {
    option.Some(v) -> inner <> xml.list_element("renamedListMembers", "item", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_list {
    option.Some(v) -> inner <> xml.list_element("stringList", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.string_set {
    option.Some(v) -> inner <> xml.list_element("stringSet", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  let inner = case input.structure_list {
    option.Some(v) -> inner <> xml.list_element("structureList", "item", list.map(v, fn(item) { let v = item encode_structure_list_member_xml_inner(v) }))
    option.None -> inner
  }
  let inner = case input.timestamp_list {
    option.Some(v) -> inner <> xml.list_element("timestampList", "member", list.map(v, fn(item) { let v = item xml.int_text(v) }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_lists_response_xml(input: XmlListsResponse, root: String) -> String {
  xml.element(root, encode_xml_lists_response_xml_inner(input))
}

pub fn decode_xml_lists_response_xml(elem: xml_decode.Element) -> Result(XmlListsResponse, String) {
  use boolean_list <- result.try(xml_decode.optional_list(elem, "booleanList", "member", xml_decode.bool_text))
  use enum_list <- result.try(xml_decode.optional_list(elem, "enumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use flattened_list <- result.try(xml_decode.optional_list(elem, "flattenedList", "item", xml_decode.string_text))
  use flattened_list2 <- result.try(xml_decode.optional_list(elem, "flattenedList2", "item", xml_decode.string_text))
  use flattened_list_with_member_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithMemberNamespace", "member", xml_decode.string_text))
  use flattened_list_with_namespace <- result.try(xml_decode.optional_list(elem, "flattenedListWithNamespace", "member", xml_decode.string_text))
  use flattened_structure_list <- result.try(xml_decode.optional_list(elem, "flattenedStructureList", "item", decode_structure_list_member_xml))
  use int_enum_list <- result.try(xml_decode.optional_list(elem, "intEnumList", "member", fn(_) { Error("xml: unsupported list element") }))
  use integer_list <- result.try(xml_decode.optional_list(elem, "integerList", "member", xml_decode.int_text))
  use nested_string_list <- result.try(xml_decode.optional_list(elem, "nestedStringList", "member", fn(_) { Error("xml: unsupported list element") }))
  use renamed_list_members <- result.try(xml_decode.optional_list(elem, "renamedListMembers", "item", xml_decode.string_text))
  use string_list <- result.try(xml_decode.optional_list(elem, "stringList", "member", xml_decode.string_text))
  use string_set <- result.try(xml_decode.optional_list(elem, "stringSet", "member", xml_decode.string_text))
  use structure_list <- result.try(xml_decode.optional_list(elem, "structureList", "item", decode_structure_list_member_xml))
  use timestamp_list <- result.try(xml_decode.optional_list(elem, "timestampList", "member", fn(_) { Error("xml: unsupported list element") }))
  Ok(XmlListsResponse(
    boolean_list: boolean_list,
    enum_list: enum_list,
    flattened_list: flattened_list,
    flattened_list2: flattened_list2,
    flattened_list_with_member_namespace: flattened_list_with_member_namespace,
    flattened_list_with_namespace: flattened_list_with_namespace,
    flattened_structure_list: flattened_structure_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    renamed_list_members: renamed_list_members,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub type XmlMapsRequest {
  XmlMapsRequest(my_map: option.Option(dict.Dict(String, GreetingStruct)))
}

pub fn encode_xml_maps_request_struct(input: XmlMapsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_greeting_struct_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_maps_request_struct() -> decode.Decoder(XmlMapsRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())))
  decode.success(XmlMapsRequest(
    my_map: my_map,
  ))
}

pub fn decode_xml_maps_request_struct_params() -> decode.Decoder(XmlMapsRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct_params())))
  decode.success(XmlMapsRequest(
    my_map: my_map,
  ))
}

pub fn encode_xml_maps_request_xml_inner(input: XmlMapsRequest) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_maps_request_xml(input: XmlMapsRequest, root: String) -> String {
  xml.element(root, encode_xml_maps_request_xml_inner(input))
}

pub fn decode_xml_maps_request_xml(elem: xml_decode.Element) -> Result(XmlMapsRequest, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, GreetingStruct)), String) = Ok(option.None)
    r })
  Ok(XmlMapsRequest(
    my_map: my_map,
  ))
}

pub type XmlMapsResponse {
  XmlMapsResponse(my_map: option.Option(dict.Dict(String, GreetingStruct)))
}

pub fn encode_xml_maps_response_struct(input: XmlMapsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_greeting_struct_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_maps_response_struct() -> decode.Decoder(XmlMapsResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())))
  decode.success(XmlMapsResponse(
    my_map: my_map,
  ))
}

pub fn decode_xml_maps_response_struct_params() -> decode.Decoder(XmlMapsResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct_params())))
  decode.success(XmlMapsResponse(
    my_map: my_map,
  ))
}

pub fn encode_xml_maps_response_xml_inner(input: XmlMapsResponse) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_maps_response_xml(input: XmlMapsResponse, root: String) -> String {
  xml.element(root, encode_xml_maps_response_xml_inner(input))
}

pub fn decode_xml_maps_response_xml(elem: xml_decode.Element) -> Result(XmlMapsResponse, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, GreetingStruct)), String) = Ok(option.None)
    r })
  Ok(XmlMapsResponse(
    my_map: my_map,
  ))
}

pub type XmlMapsXmlNameRequest {
  XmlMapsXmlNameRequest(my_map: option.Option(dict.Dict(String, GreetingStruct)))
}

pub fn encode_xml_maps_xml_name_request_struct(input: XmlMapsXmlNameRequest) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_greeting_struct_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_maps_xml_name_request_struct() -> decode.Decoder(XmlMapsXmlNameRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())))
  decode.success(XmlMapsXmlNameRequest(
    my_map: my_map,
  ))
}

pub fn decode_xml_maps_xml_name_request_struct_params() -> decode.Decoder(XmlMapsXmlNameRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct_params())))
  decode.success(XmlMapsXmlNameRequest(
    my_map: my_map,
  ))
}

pub fn encode_xml_maps_xml_name_request_xml_inner(input: XmlMapsXmlNameRequest) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_maps_xml_name_request_xml(input: XmlMapsXmlNameRequest, root: String) -> String {
  xml.element(root, encode_xml_maps_xml_name_request_xml_inner(input))
}

pub fn decode_xml_maps_xml_name_request_xml(elem: xml_decode.Element) -> Result(XmlMapsXmlNameRequest, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, GreetingStruct)), String) = Ok(option.None)
    r })
  Ok(XmlMapsXmlNameRequest(
    my_map: my_map,
  ))
}

pub type XmlMapsXmlNameResponse {
  XmlMapsXmlNameResponse(my_map: option.Option(dict.Dict(String, GreetingStruct)))
}

pub fn encode_xml_maps_xml_name_response_struct(input: XmlMapsXmlNameResponse) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_greeting_struct_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_maps_xml_name_response_struct() -> decode.Decoder(XmlMapsXmlNameResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())))
  decode.success(XmlMapsXmlNameResponse(
    my_map: my_map,
  ))
}

pub fn decode_xml_maps_xml_name_response_struct_params() -> decode.Decoder(XmlMapsXmlNameResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode_greeting_struct_struct_params())))
  decode.success(XmlMapsXmlNameResponse(
    my_map: my_map,
  ))
}

pub fn encode_xml_maps_xml_name_response_xml_inner(input: XmlMapsXmlNameResponse) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_maps_xml_name_response_xml(input: XmlMapsXmlNameResponse, root: String) -> String {
  xml.element(root, encode_xml_maps_xml_name_response_xml_inner(input))
}

pub fn decode_xml_maps_xml_name_response_xml(elem: xml_decode.Element) -> Result(XmlMapsXmlNameResponse, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, GreetingStruct)), String) = Ok(option.None)
    r })
  Ok(XmlMapsXmlNameResponse(
    my_map: my_map,
  ))
}

pub type XmlMapWithXmlNamespaceRequest {
  XmlMapWithXmlNamespaceRequest(my_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_xml_map_with_xml_namespace_request_struct(input: XmlMapWithXmlNamespaceRequest) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_map_with_xml_namespace_request_struct() -> decode.Decoder(XmlMapWithXmlNamespaceRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(XmlMapWithXmlNamespaceRequest(
    my_map: my_map,
  ))
}

pub fn decode_xml_map_with_xml_namespace_request_struct_params() -> decode.Decoder(XmlMapWithXmlNamespaceRequest) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(XmlMapWithXmlNamespaceRequest(
    my_map: my_map,
  ))
}

pub fn encode_xml_map_with_xml_namespace_request_xml_inner(input: XmlMapWithXmlNamespaceRequest) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_map_with_xml_namespace_request_xml(input: XmlMapWithXmlNamespaceRequest, root: String) -> String {
  xml.element(root, encode_xml_map_with_xml_namespace_request_xml_inner(input))
}

pub fn decode_xml_map_with_xml_namespace_request_xml(elem: xml_decode.Element) -> Result(XmlMapWithXmlNamespaceRequest, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, String)), String) = Ok(option.None)
    r })
  Ok(XmlMapWithXmlNamespaceRequest(
    my_map: my_map,
  ))
}

pub type XmlMapWithXmlNamespaceResponse {
  XmlMapWithXmlNamespaceResponse(my_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_xml_map_with_xml_namespace_response_struct(input: XmlMapWithXmlNamespaceResponse) -> json.Json {
  let pairs = []
  let pairs = case input.my_map {
    option.Some(v) -> [#("myMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_map_with_xml_namespace_response_struct() -> decode.Decoder(XmlMapWithXmlNamespaceResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(XmlMapWithXmlNamespaceResponse(
    my_map: my_map,
  ))
}

pub fn decode_xml_map_with_xml_namespace_response_struct_params() -> decode.Decoder(XmlMapWithXmlNamespaceResponse) {
  use <- decode.recursive
  use my_map <- decode.optional_field("myMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(XmlMapWithXmlNamespaceResponse(
    my_map: my_map,
  ))
}

pub fn encode_xml_map_with_xml_namespace_response_xml_inner(input: XmlMapWithXmlNamespaceResponse) -> String {
  let inner = ""
  let inner = case input.my_map {
    option.Some(v) -> inner <> xml.empty_element("myMap")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_map_with_xml_namespace_response_xml(input: XmlMapWithXmlNamespaceResponse, root: String) -> String {
  xml.element(root, encode_xml_map_with_xml_namespace_response_xml_inner(input))
}

pub fn decode_xml_map_with_xml_namespace_response_xml(elem: xml_decode.Element) -> Result(XmlMapWithXmlNamespaceResponse, String) {
  use my_map <- result.try({ let r: Result(option.Option(dict.Dict(String, String)), String) = Ok(option.None)
    r })
  Ok(XmlMapWithXmlNamespaceResponse(
    my_map: my_map,
  ))
}

pub type XmlNamespacesRequest {
  XmlNamespacesRequest(nested: option.Option(XmlNamespaceNested))
}

pub fn encode_xml_namespaces_request_struct(input: XmlNamespacesRequest) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_xml_namespace_nested_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_namespaces_request_struct() -> decode.Decoder(XmlNamespacesRequest) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_xml_namespace_nested_struct()))
  decode.success(XmlNamespacesRequest(
    nested: nested,
  ))
}

pub fn decode_xml_namespaces_request_struct_params() -> decode.Decoder(XmlNamespacesRequest) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_xml_namespace_nested_struct_params()))
  decode.success(XmlNamespacesRequest(
    nested: nested,
  ))
}

pub fn encode_xml_namespaces_request_xml_inner(input: XmlNamespacesRequest) -> String {
  let inner = ""
  let inner = case input.nested {
    option.Some(v) -> inner <> encode_xml_namespace_nested_xml(v, "nested")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_namespaces_request_xml(input: XmlNamespacesRequest, root: String) -> String {
  xml.element(root, encode_xml_namespaces_request_xml_inner(input))
}

pub fn decode_xml_namespaces_request_xml(elem: xml_decode.Element) -> Result(XmlNamespacesRequest, String) {
  use nested <- result.try(xml_decode.optional_child(elem, "nested", decode_xml_namespace_nested_xml))
  Ok(XmlNamespacesRequest(
    nested: nested,
  ))
}

pub type XmlNamespaceNested {
  XmlNamespaceNested(foo: option.Option(String), values: option.Option(List(String)))
}

pub fn encode_xml_namespace_nested_struct(input: XmlNamespaceNested) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.values {
    option.Some(v) -> [#("values", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_namespace_nested_struct() -> decode.Decoder(XmlNamespaceNested) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use values <- decode.optional_field("values", option.None, decode.optional(decode.list(decode.string)))
  decode.success(XmlNamespaceNested(
    foo: foo,
    values: values,
  ))
}

pub fn decode_xml_namespace_nested_struct_params() -> decode.Decoder(XmlNamespaceNested) {
  use <- decode.recursive
  use foo <- decode.optional_field("foo", option.None, decode.optional(decode.string))
  use values <- decode.optional_field("values", option.None, decode.optional(decode.list(decode.string)))
  decode.success(XmlNamespaceNested(
    foo: foo,
    values: values,
  ))
}

pub fn encode_xml_namespace_nested_xml_inner(input: XmlNamespaceNested) -> String {
  let inner = ""
  let inner = case input.foo {
    option.Some(v) -> inner <> xml.element("foo", xml.escape_text(v))
    option.None -> inner
  }
  let inner = case input.values {
    option.Some(v) -> inner <> xml.list_element("values", "member", list.map(v, fn(item) { let v = item xml.escape_text(v) }))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_namespace_nested_xml(input: XmlNamespaceNested, root: String) -> String {
  xml.element(root, encode_xml_namespace_nested_xml_inner(input))
}

pub fn decode_xml_namespace_nested_xml(elem: xml_decode.Element) -> Result(XmlNamespaceNested, String) {
  use foo <- result.try(xml_decode.optional_child(elem, "foo", xml_decode.string_text))
  use values <- result.try(xml_decode.optional_list(elem, "values", "member", xml_decode.string_text))
  Ok(XmlNamespaceNested(
    foo: foo,
    values: values,
  ))
}

pub type XmlNamespacesResponse {
  XmlNamespacesResponse(nested: option.Option(XmlNamespaceNested))
}

pub fn encode_xml_namespaces_response_struct(input: XmlNamespacesResponse) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_xml_namespace_nested_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_namespaces_response_struct() -> decode.Decoder(XmlNamespacesResponse) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_xml_namespace_nested_struct()))
  decode.success(XmlNamespacesResponse(
    nested: nested,
  ))
}

pub fn decode_xml_namespaces_response_struct_params() -> decode.Decoder(XmlNamespacesResponse) {
  use <- decode.recursive
  use nested <- decode.optional_field("nested", option.None, decode.optional(decode_xml_namespace_nested_struct_params()))
  decode.success(XmlNamespacesResponse(
    nested: nested,
  ))
}

pub fn encode_xml_namespaces_response_xml_inner(input: XmlNamespacesResponse) -> String {
  let inner = ""
  let inner = case input.nested {
    option.Some(v) -> inner <> encode_xml_namespace_nested_xml(v, "nested")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_namespaces_response_xml(input: XmlNamespacesResponse, root: String) -> String {
  xml.element(root, encode_xml_namespaces_response_xml_inner(input))
}

pub fn decode_xml_namespaces_response_xml(elem: xml_decode.Element) -> Result(XmlNamespacesResponse, String) {
  use nested <- result.try(xml_decode.optional_child(elem, "nested", decode_xml_namespace_nested_xml))
  Ok(XmlNamespacesResponse(
    nested: nested,
  ))
}

pub type XmlTimestampsRequest {
  XmlTimestampsRequest(date_time: option.Option(Int), date_time_on_target: option.Option(Int), epoch_seconds: option.Option(Int), epoch_seconds_on_target: option.Option(Int), http_date: option.Option(Int), http_date_on_target: option.Option(Int), normal: option.Option(Int))
}

pub fn encode_xml_timestamps_request_struct(input: XmlTimestampsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.date_time {
    option.Some(v) -> [#("dateTime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.date_time_on_target {
    option.Some(v) -> [#("dateTimeOnTarget", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.epoch_seconds {
    option.Some(v) -> [#("epochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.epoch_seconds_on_target {
    option.Some(v) -> [#("epochSecondsOnTarget", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.http_date {
    option.Some(v) -> [#("httpDate", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.http_date_on_target {
    option.Some(v) -> [#("httpDateOnTarget", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.normal {
    option.Some(v) -> [#("normal", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_timestamps_request_struct() -> decode.Decoder(XmlTimestampsRequest) {
  use <- decode.recursive
  use date_time <- decode.optional_field("dateTime", option.None, decode.optional(json_timestamp.decoder()))
  use date_time_on_target <- decode.optional_field("dateTimeOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds <- decode.optional_field("epochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds_on_target <- decode.optional_field("epochSecondsOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use http_date <- decode.optional_field("httpDate", option.None, decode.optional(json_timestamp.decoder()))
  use http_date_on_target <- decode.optional_field("httpDateOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use normal <- decode.optional_field("normal", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(XmlTimestampsRequest(
    date_time: date_time,
    date_time_on_target: date_time_on_target,
    epoch_seconds: epoch_seconds,
    epoch_seconds_on_target: epoch_seconds_on_target,
    http_date: http_date,
    http_date_on_target: http_date_on_target,
    normal: normal,
  ))
}

pub fn decode_xml_timestamps_request_struct_params() -> decode.Decoder(XmlTimestampsRequest) {
  use <- decode.recursive
  use date_time <- decode.optional_field("dateTime", option.None, decode.optional(json_timestamp.decoder()))
  use date_time_on_target <- decode.optional_field("dateTimeOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds <- decode.optional_field("epochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds_on_target <- decode.optional_field("epochSecondsOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use http_date <- decode.optional_field("httpDate", option.None, decode.optional(json_timestamp.decoder()))
  use http_date_on_target <- decode.optional_field("httpDateOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use normal <- decode.optional_field("normal", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(XmlTimestampsRequest(
    date_time: date_time,
    date_time_on_target: date_time_on_target,
    epoch_seconds: epoch_seconds,
    epoch_seconds_on_target: epoch_seconds_on_target,
    http_date: http_date,
    http_date_on_target: http_date_on_target,
    normal: normal,
  ))
}

pub fn encode_xml_timestamps_request_xml_inner(input: XmlTimestampsRequest) -> String {
  let inner = ""
  let inner = case input.date_time {
    option.Some(v) -> inner <> xml.element("dateTime", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.date_time_on_target {
    option.Some(v) -> inner <> xml.element("dateTimeOnTarget", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.epoch_seconds {
    option.Some(v) -> inner <> xml.element("epochSeconds", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.epoch_seconds_on_target {
    option.Some(v) -> inner <> xml.element("epochSecondsOnTarget", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.http_date {
    option.Some(v) -> inner <> xml.element("httpDate", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.http_date_on_target {
    option.Some(v) -> inner <> xml.element("httpDateOnTarget", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.normal {
    option.Some(v) -> inner <> xml.element("normal", xml.int_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_timestamps_request_xml(input: XmlTimestampsRequest, root: String) -> String {
  xml.element(root, encode_xml_timestamps_request_xml_inner(input))
}

pub fn decode_xml_timestamps_request_xml(elem: xml_decode.Element) -> Result(XmlTimestampsRequest, String) {
  use date_time <- result.try(xml_decode.optional_child(elem, "dateTime", xml_decode.timestamp_text))
  use date_time_on_target <- result.try(xml_decode.optional_child(elem, "dateTimeOnTarget", xml_decode.timestamp_text))
  use epoch_seconds <- result.try(xml_decode.optional_child(elem, "epochSeconds", xml_decode.timestamp_text))
  use epoch_seconds_on_target <- result.try(xml_decode.optional_child(elem, "epochSecondsOnTarget", xml_decode.timestamp_text))
  use http_date <- result.try(xml_decode.optional_child(elem, "httpDate", xml_decode.timestamp_text))
  use http_date_on_target <- result.try(xml_decode.optional_child(elem, "httpDateOnTarget", xml_decode.timestamp_text))
  use normal <- result.try(xml_decode.optional_child(elem, "normal", xml_decode.timestamp_text))
  Ok(XmlTimestampsRequest(
    date_time: date_time,
    date_time_on_target: date_time_on_target,
    epoch_seconds: epoch_seconds,
    epoch_seconds_on_target: epoch_seconds_on_target,
    http_date: http_date,
    http_date_on_target: http_date_on_target,
    normal: normal,
  ))
}

pub type XmlTimestampsResponse {
  XmlTimestampsResponse(date_time: option.Option(Int), date_time_on_target: option.Option(Int), epoch_seconds: option.Option(Int), epoch_seconds_on_target: option.Option(Int), http_date: option.Option(Int), http_date_on_target: option.Option(Int), normal: option.Option(Int))
}

pub fn encode_xml_timestamps_response_struct(input: XmlTimestampsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.date_time {
    option.Some(v) -> [#("dateTime", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.date_time_on_target {
    option.Some(v) -> [#("dateTimeOnTarget", fn(v) { json.string(json_timestamp.format_iso8601(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.epoch_seconds {
    option.Some(v) -> [#("epochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.epoch_seconds_on_target {
    option.Some(v) -> [#("epochSecondsOnTarget", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.http_date {
    option.Some(v) -> [#("httpDate", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.http_date_on_target {
    option.Some(v) -> [#("httpDateOnTarget", fn(v) { json.string(json_timestamp.format_http_date(v)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.normal {
    option.Some(v) -> [#("normal", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_timestamps_response_struct() -> decode.Decoder(XmlTimestampsResponse) {
  use <- decode.recursive
  use date_time <- decode.optional_field("dateTime", option.None, decode.optional(json_timestamp.decoder()))
  use date_time_on_target <- decode.optional_field("dateTimeOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds <- decode.optional_field("epochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds_on_target <- decode.optional_field("epochSecondsOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use http_date <- decode.optional_field("httpDate", option.None, decode.optional(json_timestamp.decoder()))
  use http_date_on_target <- decode.optional_field("httpDateOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use normal <- decode.optional_field("normal", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(XmlTimestampsResponse(
    date_time: date_time,
    date_time_on_target: date_time_on_target,
    epoch_seconds: epoch_seconds,
    epoch_seconds_on_target: epoch_seconds_on_target,
    http_date: http_date,
    http_date_on_target: http_date_on_target,
    normal: normal,
  ))
}

pub fn decode_xml_timestamps_response_struct_params() -> decode.Decoder(XmlTimestampsResponse) {
  use <- decode.recursive
  use date_time <- decode.optional_field("dateTime", option.None, decode.optional(json_timestamp.decoder()))
  use date_time_on_target <- decode.optional_field("dateTimeOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds <- decode.optional_field("epochSeconds", option.None, decode.optional(json_timestamp.decoder()))
  use epoch_seconds_on_target <- decode.optional_field("epochSecondsOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use http_date <- decode.optional_field("httpDate", option.None, decode.optional(json_timestamp.decoder()))
  use http_date_on_target <- decode.optional_field("httpDateOnTarget", option.None, decode.optional(json_timestamp.decoder()))
  use normal <- decode.optional_field("normal", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(XmlTimestampsResponse(
    date_time: date_time,
    date_time_on_target: date_time_on_target,
    epoch_seconds: epoch_seconds,
    epoch_seconds_on_target: epoch_seconds_on_target,
    http_date: http_date,
    http_date_on_target: http_date_on_target,
    normal: normal,
  ))
}

pub fn encode_xml_timestamps_response_xml_inner(input: XmlTimestampsResponse) -> String {
  let inner = ""
  let inner = case input.date_time {
    option.Some(v) -> inner <> xml.element("dateTime", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.date_time_on_target {
    option.Some(v) -> inner <> xml.element("dateTimeOnTarget", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.epoch_seconds {
    option.Some(v) -> inner <> xml.element("epochSeconds", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.epoch_seconds_on_target {
    option.Some(v) -> inner <> xml.element("epochSecondsOnTarget", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.http_date {
    option.Some(v) -> inner <> xml.element("httpDate", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.http_date_on_target {
    option.Some(v) -> inner <> xml.element("httpDateOnTarget", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.normal {
    option.Some(v) -> inner <> xml.element("normal", xml.int_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_timestamps_response_xml(input: XmlTimestampsResponse, root: String) -> String {
  xml.element(root, encode_xml_timestamps_response_xml_inner(input))
}

pub fn decode_xml_timestamps_response_xml(elem: xml_decode.Element) -> Result(XmlTimestampsResponse, String) {
  use date_time <- result.try(xml_decode.optional_child(elem, "dateTime", xml_decode.timestamp_text))
  use date_time_on_target <- result.try(xml_decode.optional_child(elem, "dateTimeOnTarget", xml_decode.timestamp_text))
  use epoch_seconds <- result.try(xml_decode.optional_child(elem, "epochSeconds", xml_decode.timestamp_text))
  use epoch_seconds_on_target <- result.try(xml_decode.optional_child(elem, "epochSecondsOnTarget", xml_decode.timestamp_text))
  use http_date <- result.try(xml_decode.optional_child(elem, "httpDate", xml_decode.timestamp_text))
  use http_date_on_target <- result.try(xml_decode.optional_child(elem, "httpDateOnTarget", xml_decode.timestamp_text))
  use normal <- result.try(xml_decode.optional_child(elem, "normal", xml_decode.timestamp_text))
  Ok(XmlTimestampsResponse(
    date_time: date_time,
    date_time_on_target: date_time_on_target,
    epoch_seconds: epoch_seconds,
    epoch_seconds_on_target: epoch_seconds_on_target,
    http_date: http_date,
    http_date_on_target: http_date_on_target,
    normal: normal,
  ))
}

pub type XmlUnionsRequest {
  XmlUnionsRequest(union_value: option.Option(XmlUnionShape))
}

pub fn encode_xml_unions_request_struct(input: XmlUnionsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.union_value {
    option.Some(v) -> [#("unionValue", encode_xml_union_shape_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_unions_request_struct() -> decode.Decoder(XmlUnionsRequest) {
  use <- decode.recursive
  use union_value <- decode.optional_field("unionValue", option.None, decode.optional(decode_xml_union_shape_union()))
  decode.success(XmlUnionsRequest(
    union_value: union_value,
  ))
}

pub fn decode_xml_unions_request_struct_params() -> decode.Decoder(XmlUnionsRequest) {
  use <- decode.recursive
  use union_value <- decode.optional_field("unionValue", option.None, decode.optional(decode_xml_union_shape_union_params()))
  decode.success(XmlUnionsRequest(
    union_value: union_value,
  ))
}

pub fn encode_xml_unions_request_xml_inner(input: XmlUnionsRequest) -> String {
  let inner = ""
  let inner = case input.union_value {
    option.Some(v) -> inner <> xml.empty_element("unionValue")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_unions_request_xml(input: XmlUnionsRequest, root: String) -> String {
  xml.element(root, encode_xml_unions_request_xml_inner(input))
}

pub fn decode_xml_unions_request_xml(elem: xml_decode.Element) -> Result(XmlUnionsRequest, String) {
  use union_value <- result.try({ let r: Result(option.Option(XmlUnionShape), String) = Ok(option.None)
    r })
  Ok(XmlUnionsRequest(
    union_value: union_value,
  ))
}

pub type XmlUnionShape {
  XmlUnionShapeBooleanValue(Bool)
  XmlUnionShapeByteValue(Int)
  XmlUnionShapeDoubleValue(json_float.SmithyFloat)
  XmlUnionShapeFloatValue(json_float.SmithyFloat)
  XmlUnionShapeIntegerValue(Int)
  XmlUnionShapeLongValue(Int)
  XmlUnionShapeShortValue(Int)
  XmlUnionShapeStringValue(String)
  XmlUnionShapeStructValue(XmlNestedUnionStruct)
  XmlUnionShapeUnionValue(XmlUnionShape)
}

pub fn encode_xml_union_shape_union(v: XmlUnionShape) -> json.Json {
  case v {
    XmlUnionShapeBooleanValue(x) -> json.object([#("booleanValue", json.bool(x))])
    XmlUnionShapeByteValue(x) -> json.object([#("byteValue", json.int(x))])
    XmlUnionShapeDoubleValue(x) -> json.object([#("doubleValue", json_float.encode(x))])
    XmlUnionShapeFloatValue(x) -> json.object([#("floatValue", json_float.encode(x))])
    XmlUnionShapeIntegerValue(x) -> json.object([#("integerValue", json.int(x))])
    XmlUnionShapeLongValue(x) -> json.object([#("longValue", json.int(x))])
    XmlUnionShapeShortValue(x) -> json.object([#("shortValue", json.int(x))])
    XmlUnionShapeStringValue(x) -> json.object([#("stringValue", json.string(x))])
    XmlUnionShapeStructValue(x) -> json.object([#("structValue", encode_xml_nested_union_struct_struct(x))])
    XmlUnionShapeUnionValue(x) -> json.object([#("unionValue", encode_xml_union_shape_union(x))])
  }
}

pub fn decode_xml_union_shape_union() -> decode.Decoder(XmlUnionShape) {
  use <- decode.recursive
  decode.one_of(
    decode.field("booleanValue", decode.bool, fn(x) { decode.success(XmlUnionShapeBooleanValue(x)) }),
    [
      decode.field("byteValue", decode.int, fn(x) { decode.success(XmlUnionShapeByteValue(x)) }),
      decode.field("doubleValue", json_float.decoder(), fn(x) { decode.success(XmlUnionShapeDoubleValue(x)) }),
      decode.field("floatValue", json_float.decoder(), fn(x) { decode.success(XmlUnionShapeFloatValue(x)) }),
      decode.field("integerValue", decode.int, fn(x) { decode.success(XmlUnionShapeIntegerValue(x)) }),
      decode.field("longValue", decode.int, fn(x) { decode.success(XmlUnionShapeLongValue(x)) }),
      decode.field("shortValue", decode.int, fn(x) { decode.success(XmlUnionShapeShortValue(x)) }),
      decode.field("stringValue", decode.string, fn(x) { decode.success(XmlUnionShapeStringValue(x)) }),
      decode.field("structValue", decode_xml_nested_union_struct_struct(), fn(x) { decode.success(XmlUnionShapeStructValue(x)) }),
      decode.field("unionValue", decode_xml_union_shape_union(), fn(x) { decode.success(XmlUnionShapeUnionValue(x)) }),
    ],
  )
}

pub fn decode_xml_union_shape_union_params() -> decode.Decoder(XmlUnionShape) {
  use <- decode.recursive
  decode.one_of(
    decode.field("booleanValue", decode.bool, fn(x) { decode.success(XmlUnionShapeBooleanValue(x)) }),
    [
      decode.field("byteValue", decode.int, fn(x) { decode.success(XmlUnionShapeByteValue(x)) }),
      decode.field("doubleValue", json_float.decoder(), fn(x) { decode.success(XmlUnionShapeDoubleValue(x)) }),
      decode.field("floatValue", json_float.decoder(), fn(x) { decode.success(XmlUnionShapeFloatValue(x)) }),
      decode.field("integerValue", decode.int, fn(x) { decode.success(XmlUnionShapeIntegerValue(x)) }),
      decode.field("longValue", decode.int, fn(x) { decode.success(XmlUnionShapeLongValue(x)) }),
      decode.field("shortValue", decode.int, fn(x) { decode.success(XmlUnionShapeShortValue(x)) }),
      decode.field("stringValue", decode.string, fn(x) { decode.success(XmlUnionShapeStringValue(x)) }),
      decode.field("structValue", decode_xml_nested_union_struct_struct_params(), fn(x) { decode.success(XmlUnionShapeStructValue(x)) }),
      decode.field("unionValue", decode_xml_union_shape_union_params(), fn(x) { decode.success(XmlUnionShapeUnionValue(x)) }),
    ],
  )
}

pub type XmlNestedUnionStruct {
  XmlNestedUnionStruct(boolean_value: option.Option(Bool), byte_value: option.Option(Int), double_value: option.Option(json_float.SmithyFloat), float_value: option.Option(json_float.SmithyFloat), integer_value: option.Option(Int), long_value: option.Option(Int), short_value: option.Option(Int), string_value: option.Option(String))
}

pub fn encode_xml_nested_union_struct_struct(input: XmlNestedUnionStruct) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_value {
    option.Some(v) -> [#("booleanValue", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.byte_value {
    option.Some(v) -> [#("byteValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_value {
    option.Some(v) -> [#("integerValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long_value {
    option.Some(v) -> [#("longValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short_value {
    option.Some(v) -> [#("shortValue", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_value {
    option.Some(v) -> [#("stringValue", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_nested_union_struct_struct() -> decode.Decoder(XmlNestedUnionStruct) {
  use <- decode.recursive
  use boolean_value <- decode.optional_field("booleanValue", option.None, decode.optional(decode.bool))
  use byte_value <- decode.optional_field("byteValue", option.None, decode.optional(decode.int))
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  use integer_value <- decode.optional_field("integerValue", option.None, decode.optional(decode.int))
  use long_value <- decode.optional_field("longValue", option.None, decode.optional(decode.int))
  use short_value <- decode.optional_field("shortValue", option.None, decode.optional(decode.int))
  use string_value <- decode.optional_field("stringValue", option.None, decode.optional(decode.string))
  decode.success(XmlNestedUnionStruct(
    boolean_value: boolean_value,
    byte_value: byte_value,
    double_value: double_value,
    float_value: float_value,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
  ))
}

pub fn decode_xml_nested_union_struct_struct_params() -> decode.Decoder(XmlNestedUnionStruct) {
  use <- decode.recursive
  use boolean_value <- decode.optional_field("booleanValue", option.None, decode.optional(decode.bool))
  use byte_value <- decode.optional_field("byteValue", option.None, decode.optional(decode.int))
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  use integer_value <- decode.optional_field("integerValue", option.None, decode.optional(decode.int))
  use long_value <- decode.optional_field("longValue", option.None, decode.optional(decode.int))
  use short_value <- decode.optional_field("shortValue", option.None, decode.optional(decode.int))
  use string_value <- decode.optional_field("stringValue", option.None, decode.optional(decode.string))
  decode.success(XmlNestedUnionStruct(
    boolean_value: boolean_value,
    byte_value: byte_value,
    double_value: double_value,
    float_value: float_value,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
  ))
}

pub fn encode_xml_nested_union_struct_xml_inner(input: XmlNestedUnionStruct) -> String {
  let inner = ""
  let inner = case input.boolean_value {
    option.Some(v) -> inner <> xml.element("booleanValue", xml.bool_text(v))
    option.None -> inner
  }
  let inner = case input.byte_value {
    option.Some(v) -> inner <> xml.element("byteValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.double_value {
    option.Some(v) -> inner <> xml.element("doubleValue", case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> inner
  }
  let inner = case input.float_value {
    option.Some(v) -> inner <> xml.element("floatValue", case v { json_float.FloatValue(f) -> xml.float_text(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> inner
  }
  let inner = case input.integer_value {
    option.Some(v) -> inner <> xml.element("integerValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.long_value {
    option.Some(v) -> inner <> xml.element("longValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.short_value {
    option.Some(v) -> inner <> xml.element("shortValue", xml.int_text(v))
    option.None -> inner
  }
  let inner = case input.string_value {
    option.Some(v) -> inner <> xml.element("stringValue", xml.escape_text(v))
    option.None -> inner
  }
  inner
}

pub fn encode_xml_nested_union_struct_xml(input: XmlNestedUnionStruct, root: String) -> String {
  xml.element(root, encode_xml_nested_union_struct_xml_inner(input))
}

pub fn decode_xml_nested_union_struct_xml(elem: xml_decode.Element) -> Result(XmlNestedUnionStruct, String) {
  use boolean_value <- result.try(xml_decode.optional_child(elem, "booleanValue", xml_decode.bool_text))
  use byte_value <- result.try(xml_decode.optional_child(elem, "byteValue", xml_decode.int_text))
  use double_value <- result.try(xml_decode.optional_child(elem, "doubleValue", fn(e) { case xml_decode.float_text(e) { Ok(f) -> Ok(json_float.FloatValue(f)) Error(r) -> Error(r) } }))
  use float_value <- result.try(xml_decode.optional_child(elem, "floatValue", fn(e) { case xml_decode.float_text(e) { Ok(f) -> Ok(json_float.FloatValue(f)) Error(r) -> Error(r) } }))
  use integer_value <- result.try(xml_decode.optional_child(elem, "integerValue", xml_decode.int_text))
  use long_value <- result.try(xml_decode.optional_child(elem, "longValue", xml_decode.int_text))
  use short_value <- result.try(xml_decode.optional_child(elem, "shortValue", xml_decode.int_text))
  use string_value <- result.try(xml_decode.optional_child(elem, "stringValue", xml_decode.string_text))
  Ok(XmlNestedUnionStruct(
    boolean_value: boolean_value,
    byte_value: byte_value,
    double_value: double_value,
    float_value: float_value,
    integer_value: integer_value,
    long_value: long_value,
    short_value: short_value,
    string_value: string_value,
  ))
}

pub type XmlUnionsResponse {
  XmlUnionsResponse(union_value: option.Option(XmlUnionShape))
}

pub fn encode_xml_unions_response_struct(input: XmlUnionsResponse) -> json.Json {
  let pairs = []
  let pairs = case input.union_value {
    option.Some(v) -> [#("unionValue", encode_xml_union_shape_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_xml_unions_response_struct() -> decode.Decoder(XmlUnionsResponse) {
  use <- decode.recursive
  use union_value <- decode.optional_field("unionValue", option.None, decode.optional(decode_xml_union_shape_union()))
  decode.success(XmlUnionsResponse(
    union_value: union_value,
  ))
}

pub fn decode_xml_unions_response_struct_params() -> decode.Decoder(XmlUnionsResponse) {
  use <- decode.recursive
  use union_value <- decode.optional_field("unionValue", option.None, decode.optional(decode_xml_union_shape_union_params()))
  decode.success(XmlUnionsResponse(
    union_value: union_value,
  ))
}

pub fn encode_xml_unions_response_xml_inner(input: XmlUnionsResponse) -> String {
  let inner = ""
  let inner = case input.union_value {
    option.Some(v) -> inner <> xml.empty_element("unionValue")
    option.None -> inner
  }
  inner
}

pub fn encode_xml_unions_response_xml(input: XmlUnionsResponse, root: String) -> String {
  xml.element(root, encode_xml_unions_response_xml_inner(input))
}

pub fn decode_xml_unions_response_xml(elem: xml_decode.Element) -> Result(XmlUnionsResponse, String) {
  use union_value <- result.try({ let r: Result(option.Option(XmlUnionShape), String) = Ok(option.None)
    r })
  Ok(XmlUnionsResponse(
    union_value: union_value,
  ))
}


pub type AllQueryStringTypesOutput {
  AllQueryStringTypesOutput
}

pub fn encode_all_query_string_types_output_struct(_v: AllQueryStringTypesOutput) -> json.Json {
  json.object([])
}

pub fn decode_all_query_string_types_output_struct() -> decode.Decoder(AllQueryStringTypesOutput) {
  decode.success(AllQueryStringTypesOutput)
}

pub fn encode_all_query_string_types_input(input: AllQueryStringTypesInput) -> String {
  json.to_string(encode_all_query_string_types_input_struct(input))
}

pub fn decode_all_query_string_types_input(body: String) -> Result(AllQueryStringTypesInput, String) {
  case json.parse(body, decode_all_query_string_types_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_all_query_string_types_output(body: String) -> Result(AllQueryStringTypesOutput, String) {
  case json.parse(body, decode_all_query_string_types_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_all_query_string_types_body_xml(input: AllQueryStringTypesInput) -> String {
  encode_all_query_string_types_input_xml(input, "AllQueryStringTypes")
}

pub fn build_all_query_string_types_request(
  input: AllQueryStringTypesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/AllQueryStringTypesInput"
  let query = ""
  let query = case input.query_boolean {
    option.Some(v) -> rest.add_query(query, "Boolean", rest.bool_to_query(v))
    option.None -> query
  }
  let query = case input.query_boolean_list {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "BooleanList", rest.bool_to_query(v))
    })
    option.None -> query
  }
  let query = case input.query_byte {
    option.Some(v) -> rest.add_query(query, "Byte", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.query_double {
    option.Some(v) -> rest.add_query(query, "Double", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> query
  }
  let query = case input.query_double_list {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "DoubleList", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    })
    option.None -> query
  }
  let query = case input.query_enum {
    option.Some(v) -> rest.add_query(query, "Enum", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> query
  }
  let query = case input.query_enum_list {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "EnumList", rest.enum_wire_value(encode_foo_enum_enum(v)))
    })
    option.None -> query
  }
  let query = case input.query_float {
    option.Some(v) -> rest.add_query(query, "Float", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> query
  }
  let query = case input.query_integer {
    option.Some(v) -> rest.add_query(query, "Integer", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.query_integer_enum {
    option.Some(v) -> rest.add_query(query, "IntegerEnum", rest.int_to_query(integer_enum_int_value(v)))
    option.None -> query
  }
  let query = case input.query_integer_enum_list {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "IntegerEnumList", rest.int_to_query(integer_enum_int_value(v)))
    })
    option.None -> query
  }
  let query = case input.query_integer_list {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "IntegerList", rest.int_to_query(v))
    })
    option.None -> query
  }
  let query = case input.query_integer_set {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "IntegerSet", rest.int_to_query(v))
    })
    option.None -> query
  }
  let query = case input.query_long {
    option.Some(v) -> rest.add_query(query, "Long", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.query_short {
    option.Some(v) -> rest.add_query(query, "Short", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.query_string {
    option.Some(v) -> rest.add_query(query, "String", v)
    option.None -> query
  }
  let query = case input.query_string_list {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "StringList", v)
    })
    option.None -> query
  }
  let query = case input.query_string_set {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "StringSet", v)
    })
    option.None -> query
  }
  let query = case input.query_timestamp {
    option.Some(v) -> rest.add_query(query, "Timestamp", json_timestamp.format_iso8601(v))
    option.None -> query
  }
  let query = case input.query_timestamp_list {
    option.Some(xs) -> list.fold(xs, query, fn(q, item) {
      let v = item
      rest.add_query(q, "TimestampList", json_timestamp.format_iso8601(v))
    })
    option.None -> query
  }
  let query = case input.query_params_map_of_strings {
    option.Some(m) -> rest.add_query_params(query, m)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_all_query_string_types_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(AllQueryStringTypesOutput, String) {
  Ok(AllQueryStringTypesOutput)
}


pub fn encode_body_with_xml_name_input(input: BodyWithXmlNameInputOutput) -> String {
  json.to_string(encode_body_with_xml_name_input_output_struct(input))
}

pub fn decode_body_with_xml_name_input(body: String) -> Result(BodyWithXmlNameInputOutput, String) {
  case json.parse(body, decode_body_with_xml_name_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_body_with_xml_name_output(body: String) -> Result(BodyWithXmlNameInputOutput, String) {
  case json.parse(body, decode_body_with_xml_name_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_body_with_xml_name_body_xml(input: BodyWithXmlNameInputOutput) -> String {
  encode_body_with_xml_name_input_output_xml(input, "BodyWithXmlName")
}

pub fn build_body_with_xml_name_request(
  input: BodyWithXmlNameInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/BodyWithXmlName"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_body_with_xml_name_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_body_with_xml_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(BodyWithXmlNameInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_body_with_xml_name_input_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_body_with_xml_name_input_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type ConstantAndVariableQueryStringOutput {
  ConstantAndVariableQueryStringOutput
}

pub fn encode_constant_and_variable_query_string_output_struct(_v: ConstantAndVariableQueryStringOutput) -> json.Json {
  json.object([])
}

pub fn decode_constant_and_variable_query_string_output_struct() -> decode.Decoder(ConstantAndVariableQueryStringOutput) {
  decode.success(ConstantAndVariableQueryStringOutput)
}

pub fn encode_constant_and_variable_query_string_input(input: ConstantAndVariableQueryStringInput) -> String {
  json.to_string(encode_constant_and_variable_query_string_input_struct(input))
}

pub fn decode_constant_and_variable_query_string_input(body: String) -> Result(ConstantAndVariableQueryStringInput, String) {
  case json.parse(body, decode_constant_and_variable_query_string_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_constant_and_variable_query_string_output(body: String) -> Result(ConstantAndVariableQueryStringOutput, String) {
  case json.parse(body, decode_constant_and_variable_query_string_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_constant_and_variable_query_string_body_xml(input: ConstantAndVariableQueryStringInput) -> String {
  encode_constant_and_variable_query_string_input_xml(input, "ConstantAndVariableQueryString")
}

pub fn build_constant_and_variable_query_string_request(
  input: ConstantAndVariableQueryStringInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/ConstantAndVariableQueryString?foo=bar"
  let query = ""
  let query = case input.baz {
    option.Some(v) -> rest.add_query(query, "baz", v)
    option.None -> query
  }
  let query = case input.maybe_set {
    option.Some(v) -> rest.add_query(query, "maybeSet", v)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_constant_and_variable_query_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(ConstantAndVariableQueryStringOutput, String) {
  Ok(ConstantAndVariableQueryStringOutput)
}


pub type ConstantQueryStringOutput {
  ConstantQueryStringOutput
}

pub fn encode_constant_query_string_output_struct(_v: ConstantQueryStringOutput) -> json.Json {
  json.object([])
}

pub fn decode_constant_query_string_output_struct() -> decode.Decoder(ConstantQueryStringOutput) {
  decode.success(ConstantQueryStringOutput)
}

pub fn encode_constant_query_string_input(input: ConstantQueryStringInput) -> String {
  json.to_string(encode_constant_query_string_input_struct(input))
}

pub fn decode_constant_query_string_input(body: String) -> Result(ConstantQueryStringInput, String) {
  case json.parse(body, decode_constant_query_string_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_constant_query_string_output(body: String) -> Result(ConstantQueryStringOutput, String) {
  case json.parse(body, decode_constant_query_string_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_constant_query_string_body_xml(input: ConstantQueryStringInput) -> String {
  encode_constant_query_string_input_xml(input, "ConstantQueryString")
}

pub fn build_constant_query_string_request(
  input: ConstantQueryStringInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/ConstantQueryString/{hello}?foo=bar&hello"
  let path = case input.hello {
    option.Some(v) -> rest.substitute_label(path, "hello", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_constant_query_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(ConstantQueryStringOutput, String) {
  Ok(ConstantQueryStringOutput)
}


pub fn encode_content_type_parameters_input(input: ContentTypeParametersInput) -> String {
  json.to_string(encode_content_type_parameters_input_struct(input))
}

pub fn decode_content_type_parameters_input(body: String) -> Result(ContentTypeParametersInput, String) {
  case json.parse(body, decode_content_type_parameters_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_content_type_parameters_output(body: String) -> Result(ContentTypeParametersOutput, String) {
  case json.parse(body, decode_content_type_parameters_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_content_type_parameters_body_xml(input: ContentTypeParametersInput) -> String {
  encode_content_type_parameters_input_xml(input, "ContentTypeParameters")
}

pub fn build_content_type_parameters_request(
  input: ContentTypeParametersInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/ContentTypeParameters"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_content_type_parameters_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_content_type_parameters_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ContentTypeParametersOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_content_type_parameters_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_content_type_parameters_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type DatetimeOffsetsInput {
  DatetimeOffsetsInput
}

pub fn encode_datetime_offsets_input_struct(_v: DatetimeOffsetsInput) -> json.Json {
  json.object([])
}

pub fn decode_datetime_offsets_input_struct() -> decode.Decoder(DatetimeOffsetsInput) {
  decode.success(DatetimeOffsetsInput)
}

pub fn encode_datetime_offsets_input(input: DatetimeOffsetsInput) -> String {
  json.to_string(encode_datetime_offsets_input_struct(input))
}

pub fn decode_datetime_offsets_input(body: String) -> Result(DatetimeOffsetsInput, String) {
  case json.parse(body, decode_datetime_offsets_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_datetime_offsets_output(body: String) -> Result(DatetimeOffsetsOutput, String) {
  case json.parse(body, decode_datetime_offsets_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_datetime_offsets_body_xml(_input: DatetimeOffsetsInput) -> String {
  xml.empty_element("DatetimeOffsets")
}

pub fn build_datetime_offsets_request(
  _input: DatetimeOffsetsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DatetimeOffsets"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_datetime_offsets_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DatetimeOffsetsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_datetime_offsets_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_datetime_offsets_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_empty_input_and_empty_output_input(input: EmptyInputAndEmptyOutputInput) -> String {
  json.to_string(encode_empty_input_and_empty_output_input_struct(input))
}

pub fn decode_empty_input_and_empty_output_input(body: String) -> Result(EmptyInputAndEmptyOutputInput, String) {
  case json.parse(body, decode_empty_input_and_empty_output_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_empty_input_and_empty_output_output(body: String) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  case json.parse(body, decode_empty_input_and_empty_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_empty_input_and_empty_output_body_xml(input: EmptyInputAndEmptyOutputInput) -> String {
  encode_empty_input_and_empty_output_input_xml(input, "EmptyInputAndEmptyOutput")
}

pub fn build_empty_input_and_empty_output_request(
  input: EmptyInputAndEmptyOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EmptyInputAndEmptyOutput"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_empty_input_and_empty_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_empty_input_and_empty_output_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_empty_input_and_empty_output_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type EndpointOperationInput {
  EndpointOperationInput
}

pub fn encode_endpoint_operation_input_struct(_v: EndpointOperationInput) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_operation_input_struct() -> decode.Decoder(EndpointOperationInput) {
  decode.success(EndpointOperationInput)
}

pub type EndpointOperationOutput {
  EndpointOperationOutput
}

pub fn encode_endpoint_operation_output_struct(_v: EndpointOperationOutput) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_operation_output_struct() -> decode.Decoder(EndpointOperationOutput) {
  decode.success(EndpointOperationOutput)
}

pub fn encode_endpoint_operation_input(input: EndpointOperationInput) -> String {
  json.to_string(encode_endpoint_operation_input_struct(input))
}

pub fn decode_endpoint_operation_input(body: String) -> Result(EndpointOperationInput, String) {
  case json.parse(body, decode_endpoint_operation_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_endpoint_operation_output(body: String) -> Result(EndpointOperationOutput, String) {
  case json.parse(body, decode_endpoint_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_endpoint_operation_body_xml(_input: EndpointOperationInput) -> String {
  xml.empty_element("EndpointOperation")
}

pub fn build_endpoint_operation_request(
  _input: EndpointOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EndpointOperation"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_endpoint_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointOperationOutput, String) {
  Ok(EndpointOperationOutput)
}


pub type EndpointWithHostLabelHeaderOperationOutput {
  EndpointWithHostLabelHeaderOperationOutput
}

pub fn encode_endpoint_with_host_label_header_operation_output_struct(_v: EndpointWithHostLabelHeaderOperationOutput) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_with_host_label_header_operation_output_struct() -> decode.Decoder(EndpointWithHostLabelHeaderOperationOutput) {
  decode.success(EndpointWithHostLabelHeaderOperationOutput)
}

pub fn encode_endpoint_with_host_label_header_operation_input(input: HostLabelHeaderInput) -> String {
  json.to_string(encode_host_label_header_input_struct(input))
}

pub fn decode_endpoint_with_host_label_header_operation_input(body: String) -> Result(HostLabelHeaderInput, String) {
  case json.parse(body, decode_host_label_header_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_endpoint_with_host_label_header_operation_output(body: String) -> Result(EndpointWithHostLabelHeaderOperationOutput, String) {
  case json.parse(body, decode_endpoint_with_host_label_header_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_endpoint_with_host_label_header_operation_body_xml(input: HostLabelHeaderInput) -> String {
  encode_host_label_header_input_xml(input, "EndpointWithHostLabelHeaderOperation")
}

pub fn build_endpoint_with_host_label_header_operation_request(
  input: HostLabelHeaderInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EndpointWithHostLabelHeaderOperation"
  let query = ""
  let headers = dict.new()
  let headers = case input.account_id {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Amz-Account-Id", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_endpoint_with_host_label_header_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointWithHostLabelHeaderOperationOutput, String) {
  Ok(EndpointWithHostLabelHeaderOperationOutput)
}


pub type EndpointWithHostLabelOperationOutput {
  EndpointWithHostLabelOperationOutput
}

pub fn encode_endpoint_with_host_label_operation_output_struct(_v: EndpointWithHostLabelOperationOutput) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_with_host_label_operation_output_struct() -> decode.Decoder(EndpointWithHostLabelOperationOutput) {
  decode.success(EndpointWithHostLabelOperationOutput)
}

pub fn encode_endpoint_with_host_label_operation_input(input: EndpointWithHostLabelOperationRequest) -> String {
  json.to_string(encode_endpoint_with_host_label_operation_request_struct(input))
}

pub fn decode_endpoint_with_host_label_operation_input(body: String) -> Result(EndpointWithHostLabelOperationRequest, String) {
  case json.parse(body, decode_endpoint_with_host_label_operation_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_endpoint_with_host_label_operation_output(body: String) -> Result(EndpointWithHostLabelOperationOutput, String) {
  case json.parse(body, decode_endpoint_with_host_label_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_endpoint_with_host_label_operation_body_xml(input: EndpointWithHostLabelOperationRequest) -> String {
  encode_endpoint_with_host_label_operation_request_xml(input, "EndpointWithHostLabelOperation")
}

pub fn build_endpoint_with_host_label_operation_request(
  input: EndpointWithHostLabelOperationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EndpointWithHostLabelOperation"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_endpoint_with_host_label_operation_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_endpoint_with_host_label_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointWithHostLabelOperationOutput, String) {
  Ok(EndpointWithHostLabelOperationOutput)
}


pub fn encode_flattened_xml_map_input(input: FlattenedXmlMapRequest) -> String {
  json.to_string(encode_flattened_xml_map_request_struct(input))
}

pub fn decode_flattened_xml_map_input(body: String) -> Result(FlattenedXmlMapRequest, String) {
  case json.parse(body, decode_flattened_xml_map_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_flattened_xml_map_output(body: String) -> Result(FlattenedXmlMapResponse, String) {
  case json.parse(body, decode_flattened_xml_map_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_flattened_xml_map_body_xml(input: FlattenedXmlMapRequest) -> String {
  encode_flattened_xml_map_request_xml(input, "FlattenedXmlMap")
}

pub fn build_flattened_xml_map_request(
  input: FlattenedXmlMapRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/FlattenedXmlMap"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_flattened_xml_map_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_flattened_xml_map_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(FlattenedXmlMapResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_flattened_xml_map_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_flattened_xml_map_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_flattened_xml_map_with_xml_name_input(input: FlattenedXmlMapWithXmlNameRequest) -> String {
  json.to_string(encode_flattened_xml_map_with_xml_name_request_struct(input))
}

pub fn decode_flattened_xml_map_with_xml_name_input(body: String) -> Result(FlattenedXmlMapWithXmlNameRequest, String) {
  case json.parse(body, decode_flattened_xml_map_with_xml_name_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_flattened_xml_map_with_xml_name_output(body: String) -> Result(FlattenedXmlMapWithXmlNameResponse, String) {
  case json.parse(body, decode_flattened_xml_map_with_xml_name_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_flattened_xml_map_with_xml_name_body_xml(input: FlattenedXmlMapWithXmlNameRequest) -> String {
  encode_flattened_xml_map_with_xml_name_request_xml(input, "FlattenedXmlMapWithXmlName")
}

pub fn build_flattened_xml_map_with_xml_name_request(
  input: FlattenedXmlMapWithXmlNameRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/FlattenedXmlMapWithXmlName"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_flattened_xml_map_with_xml_name_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_flattened_xml_map_with_xml_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(FlattenedXmlMapWithXmlNameResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_flattened_xml_map_with_xml_name_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_flattened_xml_map_with_xml_name_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type FlattenedXmlMapWithXmlNamespaceInput {
  FlattenedXmlMapWithXmlNamespaceInput
}

pub fn encode_flattened_xml_map_with_xml_namespace_input_struct(_v: FlattenedXmlMapWithXmlNamespaceInput) -> json.Json {
  json.object([])
}

pub fn decode_flattened_xml_map_with_xml_namespace_input_struct() -> decode.Decoder(FlattenedXmlMapWithXmlNamespaceInput) {
  decode.success(FlattenedXmlMapWithXmlNamespaceInput)
}

pub fn encode_flattened_xml_map_with_xml_namespace_input(input: FlattenedXmlMapWithXmlNamespaceInput) -> String {
  json.to_string(encode_flattened_xml_map_with_xml_namespace_input_struct(input))
}

pub fn decode_flattened_xml_map_with_xml_namespace_input(body: String) -> Result(FlattenedXmlMapWithXmlNamespaceInput, String) {
  case json.parse(body, decode_flattened_xml_map_with_xml_namespace_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_flattened_xml_map_with_xml_namespace_output(body: String) -> Result(FlattenedXmlMapWithXmlNamespaceOutput, String) {
  case json.parse(body, decode_flattened_xml_map_with_xml_namespace_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_flattened_xml_map_with_xml_namespace_body_xml(_input: FlattenedXmlMapWithXmlNamespaceInput) -> String {
  xml.empty_element("FlattenedXmlMapWithXmlNamespace")
}

pub fn build_flattened_xml_map_with_xml_namespace_request(
  _input: FlattenedXmlMapWithXmlNamespaceInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/FlattenedXmlMapWithXmlNamespace"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_flattened_xml_map_with_xml_namespace_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(FlattenedXmlMapWithXmlNamespaceOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_flattened_xml_map_with_xml_namespace_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_flattened_xml_map_with_xml_namespace_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type FractionalSecondsInput {
  FractionalSecondsInput
}

pub fn encode_fractional_seconds_input_struct(_v: FractionalSecondsInput) -> json.Json {
  json.object([])
}

pub fn decode_fractional_seconds_input_struct() -> decode.Decoder(FractionalSecondsInput) {
  decode.success(FractionalSecondsInput)
}

pub fn encode_fractional_seconds_input(input: FractionalSecondsInput) -> String {
  json.to_string(encode_fractional_seconds_input_struct(input))
}

pub fn decode_fractional_seconds_input(body: String) -> Result(FractionalSecondsInput, String) {
  case json.parse(body, decode_fractional_seconds_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_fractional_seconds_output(body: String) -> Result(FractionalSecondsOutput, String) {
  case json.parse(body, decode_fractional_seconds_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_fractional_seconds_body_xml(_input: FractionalSecondsInput) -> String {
  xml.empty_element("FractionalSeconds")
}

pub fn build_fractional_seconds_request(
  _input: FractionalSecondsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/FractionalSeconds"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_fractional_seconds_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(FractionalSecondsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_fractional_seconds_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_fractional_seconds_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type GreetingWithErrorsInput {
  GreetingWithErrorsInput
}

pub fn encode_greeting_with_errors_input_struct(_v: GreetingWithErrorsInput) -> json.Json {
  json.object([])
}

pub fn decode_greeting_with_errors_input_struct() -> decode.Decoder(GreetingWithErrorsInput) {
  decode.success(GreetingWithErrorsInput)
}

pub fn encode_greeting_with_errors_input(input: GreetingWithErrorsInput) -> String {
  json.to_string(encode_greeting_with_errors_input_struct(input))
}

pub fn decode_greeting_with_errors_input(body: String) -> Result(GreetingWithErrorsInput, String) {
  case json.parse(body, decode_greeting_with_errors_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_greeting_with_errors_output(body: String) -> Result(GreetingWithErrorsOutput, String) {
  case json.parse(body, decode_greeting_with_errors_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_greeting_with_errors_body_xml(_input: GreetingWithErrorsInput) -> String {
  xml.empty_element("GreetingWithErrors")
}

pub fn build_greeting_with_errors_request(
  _input: GreetingWithErrorsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/GreetingWithErrors"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_greeting_with_errors_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GreetingWithErrorsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_greeting_with_errors_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_greeting_with_errors_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_http_empty_prefix_headers_input(input: HttpEmptyPrefixHeadersInput) -> String {
  json.to_string(encode_http_empty_prefix_headers_input_struct(input))
}

pub fn decode_http_empty_prefix_headers_input(body: String) -> Result(HttpEmptyPrefixHeadersInput, String) {
  case json.parse(body, decode_http_empty_prefix_headers_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_empty_prefix_headers_output(body: String) -> Result(HttpEmptyPrefixHeadersOutput, String) {
  case json.parse(body, decode_http_empty_prefix_headers_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_empty_prefix_headers_body_xml(input: HttpEmptyPrefixHeadersInput) -> String {
  encode_http_empty_prefix_headers_input_xml(input, "HttpEmptyPrefixHeaders")
}

pub fn build_http_empty_prefix_headers_request(
  input: HttpEmptyPrefixHeadersInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpEmptyPrefixHeaders"
  let query = ""
  let headers = dict.new()
  let headers = case input.specific_header {
    option.Some(v) -> rest.maybe_set_header(headers, "hello", v)
    option.None -> headers
  }
  let headers = case input.prefix_headers {
    option.Some(m) -> rest.add_prefix_headers(headers, "", m)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_empty_prefix_headers_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpEmptyPrefixHeadersOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_http_empty_prefix_headers_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_http_empty_prefix_headers_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_http_enum_payload_input(input: EnumPayloadInput) -> String {
  json.to_string(encode_enum_payload_input_struct(input))
}

pub fn decode_http_enum_payload_input(body: String) -> Result(EnumPayloadInput, String) {
  case json.parse(body, decode_enum_payload_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_enum_payload_output(body: String) -> Result(EnumPayloadInput, String) {
  case json.parse(body, decode_enum_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_enum_payload_body_xml(input: EnumPayloadInput) -> String {
  encode_enum_payload_input_xml(input, "HttpEnumPayload")
}

pub fn build_http_enum_payload_request(
  input: EnumPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EnumPayload"
  let query = ""
  let headers = dict.new()
  let body = case input.payload {
    option.Some(v) -> bit_array.from_string(json.to_string(encode_string_enum_enum(v)))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_enum_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EnumPayloadInput, String) {
  {
    let payload = option.None
    Ok(EnumPayloadInput(
    payload: payload,
    ))
  }
}


pub fn encode_http_payload_traits_input(input: HttpPayloadTraitsInputOutput) -> String {
  json.to_string(encode_http_payload_traits_input_output_struct(input))
}

pub fn decode_http_payload_traits_input(body: String) -> Result(HttpPayloadTraitsInputOutput, String) {
  case json.parse(body, decode_http_payload_traits_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_traits_output(body: String) -> Result(HttpPayloadTraitsInputOutput, String) {
  case json.parse(body, decode_http_payload_traits_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_traits_body_xml(input: HttpPayloadTraitsInputOutput) -> String {
  encode_http_payload_traits_input_output_xml(input, "HttpPayloadTraits")
}

pub fn build_http_payload_traits_request(
  input: HttpPayloadTraitsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadTraits"
  let query = ""
  let headers = dict.new()
  let headers = case input.foo {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Foo", v)
    option.None -> headers
  }
  let body = case input.blob {
    option.Some(v) -> v
    option.None -> <<>>
  }
  let content_type = "application/octet-stream"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_payload_traits_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadTraitsInputOutput, String) {
  {
    let payload = option.Some(body)
    Ok(HttpPayloadTraitsInputOutput(
    blob: payload,
    foo: option.None,
    ))
  }
}


pub fn encode_http_payload_traits_with_media_type_input(input: HttpPayloadTraitsWithMediaTypeInputOutput) -> String {
  json.to_string(encode_http_payload_traits_with_media_type_input_output_struct(input))
}

pub fn decode_http_payload_traits_with_media_type_input(body: String) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, String) {
  case json.parse(body, decode_http_payload_traits_with_media_type_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_traits_with_media_type_output(body: String) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, String) {
  case json.parse(body, decode_http_payload_traits_with_media_type_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_traits_with_media_type_body_xml(input: HttpPayloadTraitsWithMediaTypeInputOutput) -> String {
  encode_http_payload_traits_with_media_type_input_output_xml(input, "HttpPayloadTraitsWithMediaType")
}

pub fn build_http_payload_traits_with_media_type_request(
  input: HttpPayloadTraitsWithMediaTypeInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadTraitsWithMediaType"
  let query = ""
  let headers = dict.new()
  let headers = case input.foo {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Foo", v)
    option.None -> headers
  }
  let body = case input.blob {
    option.Some(v) -> v
    option.None -> <<>>
  }
  let content_type = "application/octet-stream"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_payload_traits_with_media_type_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, String) {
  {
    let payload = option.Some(body)
    Ok(HttpPayloadTraitsWithMediaTypeInputOutput(
    blob: payload,
    foo: option.None,
    ))
  }
}


pub fn encode_http_payload_with_member_xml_name_input(input: HttpPayloadWithMemberXmlNameInputOutput) -> String {
  json.to_string(encode_http_payload_with_member_xml_name_input_output_struct(input))
}

pub fn decode_http_payload_with_member_xml_name_input(body: String) -> Result(HttpPayloadWithMemberXmlNameInputOutput, String) {
  case json.parse(body, decode_http_payload_with_member_xml_name_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_member_xml_name_output(body: String) -> Result(HttpPayloadWithMemberXmlNameInputOutput, String) {
  case json.parse(body, decode_http_payload_with_member_xml_name_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_member_xml_name_body_xml(input: HttpPayloadWithMemberXmlNameInputOutput) -> String {
  encode_http_payload_with_member_xml_name_input_output_xml(input, "HttpPayloadWithMemberXmlName")
}

pub fn build_http_payload_with_member_xml_name_request(
  input: HttpPayloadWithMemberXmlNameInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithMemberXmlName"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) -> bit_array.from_string(encode_payload_with_xml_name_xml(v, "nested"))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_member_xml_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithMemberXmlNameInputOutput, String) {
  {
    use text <- result.try(case bit_array.to_string(body) {
      Ok(t) -> Ok(t)
      Error(_) -> Error("non-utf8 payload")
    })
    use payload <- result.try(case text {
      "" -> Ok(option.None)
      _ -> case xml_decode.parse(text) {
        Ok(root) -> case decode_payload_with_xml_name_xml(root) {
          Ok(v) -> Ok(option.Some(v))
          Error(r) -> Error(r)
        }
        Error(r) -> Error(r)
      }
    })
    Ok(HttpPayloadWithMemberXmlNameInputOutput(
    nested: payload,
    ))
  }
}


pub fn encode_http_payload_with_structure_input(input: HttpPayloadWithStructureInputOutput) -> String {
  json.to_string(encode_http_payload_with_structure_input_output_struct(input))
}

pub fn decode_http_payload_with_structure_input(body: String) -> Result(HttpPayloadWithStructureInputOutput, String) {
  case json.parse(body, decode_http_payload_with_structure_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_structure_output(body: String) -> Result(HttpPayloadWithStructureInputOutput, String) {
  case json.parse(body, decode_http_payload_with_structure_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_structure_body_xml(input: HttpPayloadWithStructureInputOutput) -> String {
  encode_http_payload_with_structure_input_output_xml(input, "HttpPayloadWithStructure")
}

pub fn build_http_payload_with_structure_request(
  input: HttpPayloadWithStructureInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithStructure"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) -> bit_array.from_string(encode_nested_payload_xml(v, "nested"))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_structure_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithStructureInputOutput, String) {
  {
    use text <- result.try(case bit_array.to_string(body) {
      Ok(t) -> Ok(t)
      Error(_) -> Error("non-utf8 payload")
    })
    use payload <- result.try(case text {
      "" -> Ok(option.None)
      _ -> case xml_decode.parse(text) {
        Ok(root) -> case decode_nested_payload_xml(root) {
          Ok(v) -> Ok(option.Some(v))
          Error(r) -> Error(r)
        }
        Error(r) -> Error(r)
      }
    })
    Ok(HttpPayloadWithStructureInputOutput(
    nested: payload,
    ))
  }
}


pub fn encode_http_payload_with_union_input(input: HttpPayloadWithUnionInputOutput) -> String {
  json.to_string(encode_http_payload_with_union_input_output_struct(input))
}

pub fn decode_http_payload_with_union_input(body: String) -> Result(HttpPayloadWithUnionInputOutput, String) {
  case json.parse(body, decode_http_payload_with_union_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_union_output(body: String) -> Result(HttpPayloadWithUnionInputOutput, String) {
  case json.parse(body, decode_http_payload_with_union_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_union_body_xml(input: HttpPayloadWithUnionInputOutput) -> String {
  encode_http_payload_with_union_input_output_xml(input, "HttpPayloadWithUnion")
}

pub fn build_http_payload_with_union_request(
  input: HttpPayloadWithUnionInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithUnion"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) -> bit_array.from_string(json.to_string(encode_union_payload_union(v)))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_union_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithUnionInputOutput, String) {
  {
    let payload = option.None
    Ok(HttpPayloadWithUnionInputOutput(
    nested: payload,
    ))
  }
}


pub fn encode_http_payload_with_xml_name_input(input: HttpPayloadWithXmlNameInputOutput) -> String {
  json.to_string(encode_http_payload_with_xml_name_input_output_struct(input))
}

pub fn decode_http_payload_with_xml_name_input(body: String) -> Result(HttpPayloadWithXmlNameInputOutput, String) {
  case json.parse(body, decode_http_payload_with_xml_name_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_xml_name_output(body: String) -> Result(HttpPayloadWithXmlNameInputOutput, String) {
  case json.parse(body, decode_http_payload_with_xml_name_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_xml_name_body_xml(input: HttpPayloadWithXmlNameInputOutput) -> String {
  encode_http_payload_with_xml_name_input_output_xml(input, "HttpPayloadWithXmlName")
}

pub fn build_http_payload_with_xml_name_request(
  input: HttpPayloadWithXmlNameInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithXmlName"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) -> bit_array.from_string(encode_payload_with_xml_name_xml(v, "nested"))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_xml_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithXmlNameInputOutput, String) {
  {
    use text <- result.try(case bit_array.to_string(body) {
      Ok(t) -> Ok(t)
      Error(_) -> Error("non-utf8 payload")
    })
    use payload <- result.try(case text {
      "" -> Ok(option.None)
      _ -> case xml_decode.parse(text) {
        Ok(root) -> case decode_payload_with_xml_name_xml(root) {
          Ok(v) -> Ok(option.Some(v))
          Error(r) -> Error(r)
        }
        Error(r) -> Error(r)
      }
    })
    Ok(HttpPayloadWithXmlNameInputOutput(
    nested: payload,
    ))
  }
}


pub fn encode_http_payload_with_xml_namespace_input(input: HttpPayloadWithXmlNamespaceInputOutput) -> String {
  json.to_string(encode_http_payload_with_xml_namespace_input_output_struct(input))
}

pub fn decode_http_payload_with_xml_namespace_input(body: String) -> Result(HttpPayloadWithXmlNamespaceInputOutput, String) {
  case json.parse(body, decode_http_payload_with_xml_namespace_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_xml_namespace_output(body: String) -> Result(HttpPayloadWithXmlNamespaceInputOutput, String) {
  case json.parse(body, decode_http_payload_with_xml_namespace_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_xml_namespace_body_xml(input: HttpPayloadWithXmlNamespaceInputOutput) -> String {
  encode_http_payload_with_xml_namespace_input_output_xml(input, "HttpPayloadWithXmlNamespace")
}

pub fn build_http_payload_with_xml_namespace_request(
  input: HttpPayloadWithXmlNamespaceInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithXmlNamespace"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) -> bit_array.from_string(encode_payload_with_xml_namespace_xml(v, "nested"))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_xml_namespace_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithXmlNamespaceInputOutput, String) {
  {
    use text <- result.try(case bit_array.to_string(body) {
      Ok(t) -> Ok(t)
      Error(_) -> Error("non-utf8 payload")
    })
    use payload <- result.try(case text {
      "" -> Ok(option.None)
      _ -> case xml_decode.parse(text) {
        Ok(root) -> case decode_payload_with_xml_namespace_xml(root) {
          Ok(v) -> Ok(option.Some(v))
          Error(r) -> Error(r)
        }
        Error(r) -> Error(r)
      }
    })
    Ok(HttpPayloadWithXmlNamespaceInputOutput(
    nested: payload,
    ))
  }
}


pub fn encode_http_payload_with_xml_namespace_and_prefix_input(input: HttpPayloadWithXmlNamespaceAndPrefixInputOutput) -> String {
  json.to_string(encode_http_payload_with_xml_namespace_and_prefix_input_output_struct(input))
}

pub fn decode_http_payload_with_xml_namespace_and_prefix_input(body: String) -> Result(HttpPayloadWithXmlNamespaceAndPrefixInputOutput, String) {
  case json.parse(body, decode_http_payload_with_xml_namespace_and_prefix_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_xml_namespace_and_prefix_output(body: String) -> Result(HttpPayloadWithXmlNamespaceAndPrefixInputOutput, String) {
  case json.parse(body, decode_http_payload_with_xml_namespace_and_prefix_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_xml_namespace_and_prefix_body_xml(input: HttpPayloadWithXmlNamespaceAndPrefixInputOutput) -> String {
  encode_http_payload_with_xml_namespace_and_prefix_input_output_xml(input, "HttpPayloadWithXmlNamespaceAndPrefix")
}

pub fn build_http_payload_with_xml_namespace_and_prefix_request(
  input: HttpPayloadWithXmlNamespaceAndPrefixInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithXmlNamespaceAndPrefix"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) -> bit_array.from_string(encode_payload_with_xml_namespace_and_prefix_xml(v, "nested"))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_xml_namespace_and_prefix_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithXmlNamespaceAndPrefixInputOutput, String) {
  {
    use text <- result.try(case bit_array.to_string(body) {
      Ok(t) -> Ok(t)
      Error(_) -> Error("non-utf8 payload")
    })
    use payload <- result.try(case text {
      "" -> Ok(option.None)
      _ -> case xml_decode.parse(text) {
        Ok(root) -> case decode_payload_with_xml_namespace_and_prefix_xml(root) {
          Ok(v) -> Ok(option.Some(v))
          Error(r) -> Error(r)
        }
        Error(r) -> Error(r)
      }
    })
    Ok(HttpPayloadWithXmlNamespaceAndPrefixInputOutput(
    nested: payload,
    ))
  }
}


pub fn encode_http_prefix_headers_input(input: HttpPrefixHeadersInputOutput) -> String {
  json.to_string(encode_http_prefix_headers_input_output_struct(input))
}

pub fn decode_http_prefix_headers_input(body: String) -> Result(HttpPrefixHeadersInputOutput, String) {
  case json.parse(body, decode_http_prefix_headers_input_output_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_prefix_headers_output(body: String) -> Result(HttpPrefixHeadersInputOutput, String) {
  case json.parse(body, decode_http_prefix_headers_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_prefix_headers_body_xml(input: HttpPrefixHeadersInputOutput) -> String {
  encode_http_prefix_headers_input_output_xml(input, "HttpPrefixHeaders")
}

pub fn build_http_prefix_headers_request(
  input: HttpPrefixHeadersInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPrefixHeaders"
  let query = ""
  let headers = dict.new()
  let headers = case input.foo {
    option.Some(v) -> rest.maybe_set_header(headers, "x-foo", v)
    option.None -> headers
  }
  let headers = case input.foo_map {
    option.Some(m) -> rest.add_prefix_headers(headers, "x-foo-", m)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_prefix_headers_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPrefixHeadersInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_http_prefix_headers_input_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_http_prefix_headers_input_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type HttpRequestWithFloatLabelsOutput {
  HttpRequestWithFloatLabelsOutput
}

pub fn encode_http_request_with_float_labels_output_struct(_v: HttpRequestWithFloatLabelsOutput) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_float_labels_output_struct() -> decode.Decoder(HttpRequestWithFloatLabelsOutput) {
  decode.success(HttpRequestWithFloatLabelsOutput)
}

pub fn encode_http_request_with_float_labels_input(input: HttpRequestWithFloatLabelsInput) -> String {
  json.to_string(encode_http_request_with_float_labels_input_struct(input))
}

pub fn decode_http_request_with_float_labels_input(body: String) -> Result(HttpRequestWithFloatLabelsInput, String) {
  case json.parse(body, decode_http_request_with_float_labels_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_float_labels_output(body: String) -> Result(HttpRequestWithFloatLabelsOutput, String) {
  case json.parse(body, decode_http_request_with_float_labels_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_float_labels_body_xml(input: HttpRequestWithFloatLabelsInput) -> String {
  encode_http_request_with_float_labels_input_xml(input, "HttpRequestWithFloatLabels")
}

pub fn build_http_request_with_float_labels_request(
  input: HttpRequestWithFloatLabelsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/FloatHttpLabels/{float}/{double}"
  let path = case input.double {
    option.Some(v) -> rest.substitute_label(path, "double", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" }, False)
    option.None -> path
  }
  let path = case input.float {
    option.Some(v) -> rest.substitute_label(path, "float", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" }, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_float_labels_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HttpRequestWithFloatLabelsOutput, String) {
  Ok(HttpRequestWithFloatLabelsOutput)
}


pub type HttpRequestWithGreedyLabelInPathOutput {
  HttpRequestWithGreedyLabelInPathOutput
}

pub fn encode_http_request_with_greedy_label_in_path_output_struct(_v: HttpRequestWithGreedyLabelInPathOutput) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_greedy_label_in_path_output_struct() -> decode.Decoder(HttpRequestWithGreedyLabelInPathOutput) {
  decode.success(HttpRequestWithGreedyLabelInPathOutput)
}

pub fn encode_http_request_with_greedy_label_in_path_input(input: HttpRequestWithGreedyLabelInPathInput) -> String {
  json.to_string(encode_http_request_with_greedy_label_in_path_input_struct(input))
}

pub fn decode_http_request_with_greedy_label_in_path_input(body: String) -> Result(HttpRequestWithGreedyLabelInPathInput, String) {
  case json.parse(body, decode_http_request_with_greedy_label_in_path_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_greedy_label_in_path_output(body: String) -> Result(HttpRequestWithGreedyLabelInPathOutput, String) {
  case json.parse(body, decode_http_request_with_greedy_label_in_path_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_greedy_label_in_path_body_xml(input: HttpRequestWithGreedyLabelInPathInput) -> String {
  encode_http_request_with_greedy_label_in_path_input_xml(input, "HttpRequestWithGreedyLabelInPath")
}

pub fn build_http_request_with_greedy_label_in_path_request(
  input: HttpRequestWithGreedyLabelInPathInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpRequestWithGreedyLabelInPath/foo/{foo}/baz/{baz+}"
  let path = case input.baz {
    option.Some(v) -> rest.substitute_label(path, "baz", v, True)
    option.None -> path
  }
  let path = case input.foo {
    option.Some(v) -> rest.substitute_label(path, "foo", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_greedy_label_in_path_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HttpRequestWithGreedyLabelInPathOutput, String) {
  Ok(HttpRequestWithGreedyLabelInPathOutput)
}


pub type HttpRequestWithLabelsOutput {
  HttpRequestWithLabelsOutput
}

pub fn encode_http_request_with_labels_output_struct(_v: HttpRequestWithLabelsOutput) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_labels_output_struct() -> decode.Decoder(HttpRequestWithLabelsOutput) {
  decode.success(HttpRequestWithLabelsOutput)
}

pub fn encode_http_request_with_labels_input(input: HttpRequestWithLabelsInput) -> String {
  json.to_string(encode_http_request_with_labels_input_struct(input))
}

pub fn decode_http_request_with_labels_input(body: String) -> Result(HttpRequestWithLabelsInput, String) {
  case json.parse(body, decode_http_request_with_labels_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_labels_output(body: String) -> Result(HttpRequestWithLabelsOutput, String) {
  case json.parse(body, decode_http_request_with_labels_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_labels_body_xml(input: HttpRequestWithLabelsInput) -> String {
  encode_http_request_with_labels_input_xml(input, "HttpRequestWithLabels")
}

pub fn build_http_request_with_labels_request(
  input: HttpRequestWithLabelsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpRequestWithLabels/{string}/{short}/{integer}/{long}/{float}/{double}/{boolean}/{timestamp}"
  let path = case input.boolean {
    option.Some(v) -> rest.substitute_label(path, "boolean", rest.bool_to_query(v), False)
    option.None -> path
  }
  let path = case input.double {
    option.Some(v) -> rest.substitute_label(path, "double", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" }, False)
    option.None -> path
  }
  let path = case input.float {
    option.Some(v) -> rest.substitute_label(path, "float", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" }, False)
    option.None -> path
  }
  let path = case input.integer {
    option.Some(v) -> rest.substitute_label(path, "integer", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.long {
    option.Some(v) -> rest.substitute_label(path, "long", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.short {
    option.Some(v) -> rest.substitute_label(path, "short", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.string {
    option.Some(v) -> rest.substitute_label(path, "string", v, False)
    option.None -> path
  }
  let path = case input.timestamp {
    option.Some(v) -> rest.substitute_label(path, "timestamp", json_timestamp.format_iso8601(v), False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_labels_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HttpRequestWithLabelsOutput, String) {
  Ok(HttpRequestWithLabelsOutput)
}


pub type HttpRequestWithLabelsAndTimestampFormatOutput {
  HttpRequestWithLabelsAndTimestampFormatOutput
}

pub fn encode_http_request_with_labels_and_timestamp_format_output_struct(_v: HttpRequestWithLabelsAndTimestampFormatOutput) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_labels_and_timestamp_format_output_struct() -> decode.Decoder(HttpRequestWithLabelsAndTimestampFormatOutput) {
  decode.success(HttpRequestWithLabelsAndTimestampFormatOutput)
}

pub fn encode_http_request_with_labels_and_timestamp_format_input(input: HttpRequestWithLabelsAndTimestampFormatInput) -> String {
  json.to_string(encode_http_request_with_labels_and_timestamp_format_input_struct(input))
}

pub fn decode_http_request_with_labels_and_timestamp_format_input(body: String) -> Result(HttpRequestWithLabelsAndTimestampFormatInput, String) {
  case json.parse(body, decode_http_request_with_labels_and_timestamp_format_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_labels_and_timestamp_format_output(body: String) -> Result(HttpRequestWithLabelsAndTimestampFormatOutput, String) {
  case json.parse(body, decode_http_request_with_labels_and_timestamp_format_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_labels_and_timestamp_format_body_xml(input: HttpRequestWithLabelsAndTimestampFormatInput) -> String {
  encode_http_request_with_labels_and_timestamp_format_input_xml(input, "HttpRequestWithLabelsAndTimestampFormat")
}

pub fn build_http_request_with_labels_and_timestamp_format_request(
  input: HttpRequestWithLabelsAndTimestampFormatInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpRequestWithLabelsAndTimestampFormat/{memberEpochSeconds}/{memberHttpDate}/{memberDateTime}/{defaultFormat}/{targetEpochSeconds}/{targetHttpDate}/{targetDateTime}"
  let path = case input.default_format {
    option.Some(v) -> rest.substitute_label(path, "defaultFormat", json_timestamp.format_iso8601(v), False)
    option.None -> path
  }
  let path = case input.member_date_time {
    option.Some(v) -> rest.substitute_label(path, "memberDateTime", json_timestamp.format_iso8601(v), False)
    option.None -> path
  }
  let path = case input.member_epoch_seconds {
    option.Some(v) -> rest.substitute_label(path, "memberEpochSeconds", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.member_http_date {
    option.Some(v) -> rest.substitute_label(path, "memberHttpDate", json_timestamp.format_http_date(v), False)
    option.None -> path
  }
  let path = case input.target_date_time {
    option.Some(v) -> rest.substitute_label(path, "targetDateTime", json_timestamp.format_iso8601(v), False)
    option.None -> path
  }
  let path = case input.target_epoch_seconds {
    option.Some(v) -> rest.substitute_label(path, "targetEpochSeconds", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.target_http_date {
    option.Some(v) -> rest.substitute_label(path, "targetHttpDate", json_timestamp.format_http_date(v), False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_labels_and_timestamp_format_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HttpRequestWithLabelsAndTimestampFormatOutput, String) {
  Ok(HttpRequestWithLabelsAndTimestampFormatOutput)
}


pub type HttpResponseCodeInput {
  HttpResponseCodeInput
}

pub fn encode_http_response_code_input_struct(_v: HttpResponseCodeInput) -> json.Json {
  json.object([])
}

pub fn decode_http_response_code_input_struct() -> decode.Decoder(HttpResponseCodeInput) {
  decode.success(HttpResponseCodeInput)
}

pub fn encode_http_response_code_input(input: HttpResponseCodeInput) -> String {
  json.to_string(encode_http_response_code_input_struct(input))
}

pub fn decode_http_response_code_input(body: String) -> Result(HttpResponseCodeInput, String) {
  case json.parse(body, decode_http_response_code_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_response_code_output(body: String) -> Result(HttpResponseCodeOutput, String) {
  case json.parse(body, decode_http_response_code_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_response_code_body_xml(_input: HttpResponseCodeInput) -> String {
  xml.empty_element("HttpResponseCode")
}

pub fn build_http_response_code_request(
  _input: HttpResponseCodeInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpResponseCode"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_response_code_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpResponseCodeOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_http_response_code_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_http_response_code_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_http_string_payload_input(input: StringPayloadInput) -> String {
  json.to_string(encode_string_payload_input_struct(input))
}

pub fn decode_http_string_payload_input(body: String) -> Result(StringPayloadInput, String) {
  case json.parse(body, decode_string_payload_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_string_payload_output(body: String) -> Result(StringPayloadInput, String) {
  case json.parse(body, decode_string_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_string_payload_body_xml(input: StringPayloadInput) -> String {
  encode_string_payload_input_xml(input, "HttpStringPayload")
}

pub fn build_http_string_payload_request(
  input: StringPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/StringPayload"
  let query = ""
  let headers = dict.new()
  let body = case input.payload {
    option.Some(v) -> bit_array.from_string(v)
    option.None -> <<>>
  }
  let content_type = "text/plain"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_string_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(StringPayloadInput, String) {
  {
    use payload <- result.try(case bit_array.to_string(body) {
      Ok(s) -> Ok(option.Some(s))
      Error(_) -> Error("non-utf8 payload")
    })
    Ok(StringPayloadInput(
    payload: payload,
    ))
  }
}


pub type IgnoreQueryParamsInResponseInput {
  IgnoreQueryParamsInResponseInput
}

pub fn encode_ignore_query_params_in_response_input_struct(_v: IgnoreQueryParamsInResponseInput) -> json.Json {
  json.object([])
}

pub fn decode_ignore_query_params_in_response_input_struct() -> decode.Decoder(IgnoreQueryParamsInResponseInput) {
  decode.success(IgnoreQueryParamsInResponseInput)
}

pub fn encode_ignore_query_params_in_response_input(input: IgnoreQueryParamsInResponseInput) -> String {
  json.to_string(encode_ignore_query_params_in_response_input_struct(input))
}

pub fn decode_ignore_query_params_in_response_input(body: String) -> Result(IgnoreQueryParamsInResponseInput, String) {
  case json.parse(body, decode_ignore_query_params_in_response_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_ignore_query_params_in_response_output(body: String) -> Result(IgnoreQueryParamsInResponseOutput, String) {
  case json.parse(body, decode_ignore_query_params_in_response_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_ignore_query_params_in_response_body_xml(_input: IgnoreQueryParamsInResponseInput) -> String {
  xml.empty_element("IgnoreQueryParamsInResponse")
}

pub fn build_ignore_query_params_in_response_request(
  _input: IgnoreQueryParamsInResponseInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/IgnoreQueryParamsInResponse"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_ignore_query_params_in_response_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(IgnoreQueryParamsInResponseOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_ignore_query_params_in_response_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_ignore_query_params_in_response_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_input_and_output_with_headers_input(input: InputAndOutputWithHeadersIO) -> String {
  json.to_string(encode_input_and_output_with_headers_io_struct(input))
}

pub fn decode_input_and_output_with_headers_input(body: String) -> Result(InputAndOutputWithHeadersIO, String) {
  case json.parse(body, decode_input_and_output_with_headers_io_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_input_and_output_with_headers_output(body: String) -> Result(InputAndOutputWithHeadersIO, String) {
  case json.parse(body, decode_input_and_output_with_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_input_and_output_with_headers_body_xml(input: InputAndOutputWithHeadersIO) -> String {
  encode_input_and_output_with_headers_io_xml(input, "InputAndOutputWithHeaders")
}

pub fn build_input_and_output_with_headers_request(
  input: InputAndOutputWithHeadersIO,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/InputAndOutputWithHeaders"
  let query = ""
  let headers = dict.new()
  let headers = case input.header_boolean_list {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-BooleanList", list.map(xs, fn(item) { let v = item rest.bool_to_query(v) }))
    option.None -> headers
  }
  let headers = case input.header_byte {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Byte", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_double {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Double", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> headers
  }
  let headers = case input.header_enum {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Enum", rest.enum_wire_value(encode_foo_enum_enum(v)))
    option.None -> headers
  }
  let headers = case input.header_enum_list {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-EnumList", list.map(xs, fn(item) { let v = item rest.enum_wire_value(encode_foo_enum_enum(v)) }))
    option.None -> headers
  }
  let headers = case input.header_false_bool {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Boolean2", rest.bool_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_float {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Float", case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> "NaN" json_float.PosInfinity -> "Infinity" json_float.NegInfinity -> "-Infinity" })
    option.None -> headers
  }
  let headers = case input.header_integer {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Integer", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_integer_list {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-IntegerList", list.map(xs, fn(item) { let v = item rest.int_to_query(v) }))
    option.None -> headers
  }
  let headers = case input.header_long {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Long", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_short {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Short", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_string {
    option.Some(v) -> rest.maybe_set_header(headers, "X-String", v)
    option.None -> headers
  }
  let headers = case input.header_string_list {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-StringList", list.map(xs, fn(item) { let v = item v }))
    option.None -> headers
  }
  let headers = case input.header_string_set {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-StringSet", list.map(xs, fn(item) { let v = item v }))
    option.None -> headers
  }
  let headers = case input.header_timestamp_list {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-TimestampList", list.map(xs, fn(item) { let v = item json_timestamp.format_iso8601(v) }))
    option.None -> headers
  }
  let headers = case input.header_true_bool {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Boolean1", rest.bool_to_query(v))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_input_and_output_with_headers_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(InputAndOutputWithHeadersIO, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_input_and_output_with_headers_io_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_input_and_output_with_headers_io_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_nested_xml_maps_input(input: NestedXmlMapsRequest) -> String {
  json.to_string(encode_nested_xml_maps_request_struct(input))
}

pub fn decode_nested_xml_maps_input(body: String) -> Result(NestedXmlMapsRequest, String) {
  case json.parse(body, decode_nested_xml_maps_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_nested_xml_maps_output(body: String) -> Result(NestedXmlMapsResponse, String) {
  case json.parse(body, decode_nested_xml_maps_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_nested_xml_maps_body_xml(input: NestedXmlMapsRequest) -> String {
  encode_nested_xml_maps_request_xml(input, "NestedXmlMaps")
}

pub fn build_nested_xml_maps_request(
  input: NestedXmlMapsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NestedXmlMaps"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_nested_xml_maps_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_nested_xml_maps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NestedXmlMapsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_nested_xml_maps_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_nested_xml_maps_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_nested_xml_map_with_xml_name_input(input: NestedXmlMapWithXmlNameRequest) -> String {
  json.to_string(encode_nested_xml_map_with_xml_name_request_struct(input))
}

pub fn decode_nested_xml_map_with_xml_name_input(body: String) -> Result(NestedXmlMapWithXmlNameRequest, String) {
  case json.parse(body, decode_nested_xml_map_with_xml_name_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_nested_xml_map_with_xml_name_output(body: String) -> Result(NestedXmlMapWithXmlNameResponse, String) {
  case json.parse(body, decode_nested_xml_map_with_xml_name_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_nested_xml_map_with_xml_name_body_xml(input: NestedXmlMapWithXmlNameRequest) -> String {
  encode_nested_xml_map_with_xml_name_request_xml(input, "NestedXmlMapWithXmlName")
}

pub fn build_nested_xml_map_with_xml_name_request(
  input: NestedXmlMapWithXmlNameRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NestedXmlMapWithXmlName"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_nested_xml_map_with_xml_name_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_nested_xml_map_with_xml_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NestedXmlMapWithXmlNameResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_nested_xml_map_with_xml_name_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_nested_xml_map_with_xml_name_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type NoInputAndNoOutputInput {
  NoInputAndNoOutputInput
}

pub fn encode_no_input_and_no_output_input_struct(_v: NoInputAndNoOutputInput) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_no_output_input_struct() -> decode.Decoder(NoInputAndNoOutputInput) {
  decode.success(NoInputAndNoOutputInput)
}

pub type NoInputAndNoOutputOutput {
  NoInputAndNoOutputOutput
}

pub fn encode_no_input_and_no_output_output_struct(_v: NoInputAndNoOutputOutput) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_no_output_output_struct() -> decode.Decoder(NoInputAndNoOutputOutput) {
  decode.success(NoInputAndNoOutputOutput)
}

pub fn encode_no_input_and_no_output_input(input: NoInputAndNoOutputInput) -> String {
  json.to_string(encode_no_input_and_no_output_input_struct(input))
}

pub fn decode_no_input_and_no_output_input(body: String) -> Result(NoInputAndNoOutputInput, String) {
  case json.parse(body, decode_no_input_and_no_output_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_no_input_and_no_output_output(body: String) -> Result(NoInputAndNoOutputOutput, String) {
  case json.parse(body, decode_no_input_and_no_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_no_input_and_no_output_body_xml(_input: NoInputAndNoOutputInput) -> String {
  xml.empty_element("NoInputAndNoOutput")
}

pub fn build_no_input_and_no_output_request(
  _input: NoInputAndNoOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NoInputAndNoOutput"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
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

pub fn encode_no_input_and_output_input_struct(_v: NoInputAndOutputInput) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_output_input_struct() -> decode.Decoder(NoInputAndOutputInput) {
  decode.success(NoInputAndOutputInput)
}

pub fn encode_no_input_and_output_input(input: NoInputAndOutputInput) -> String {
  json.to_string(encode_no_input_and_output_input_struct(input))
}

pub fn decode_no_input_and_output_input(body: String) -> Result(NoInputAndOutputInput, String) {
  case json.parse(body, decode_no_input_and_output_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_no_input_and_output_output(body: String) -> Result(NoInputAndOutputOutput, String) {
  case json.parse(body, decode_no_input_and_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_no_input_and_output_body_xml(_input: NoInputAndOutputInput) -> String {
  xml.empty_element("NoInputAndOutput")
}

pub fn build_no_input_and_output_request(
  _input: NoInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NoInputAndOutputOutput"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_no_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NoInputAndOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_no_input_and_output_output_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_no_input_and_output_output_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_null_and_empty_headers_client_input(input: NullAndEmptyHeadersIO) -> String {
  json.to_string(encode_null_and_empty_headers_io_struct(input))
}

pub fn decode_null_and_empty_headers_client_input(body: String) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_null_and_empty_headers_client_output(body: String) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_null_and_empty_headers_client_body_xml(input: NullAndEmptyHeadersIO) -> String {
  encode_null_and_empty_headers_io_xml(input, "NullAndEmptyHeadersClient")
}

pub fn build_null_and_empty_headers_client_request(
  input: NullAndEmptyHeadersIO,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NullAndEmptyHeadersClient"
  let query = ""
  let headers = dict.new()
  let headers = case input.a {
    option.Some(v) -> rest.maybe_set_header(headers, "X-A", v)
    option.None -> headers
  }
  let headers = case input.b {
    option.Some(v) -> rest.maybe_set_header(headers, "X-B", v)
    option.None -> headers
  }
  let headers = case input.c {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-C", list.map(xs, fn(item) { let v = item v }))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_null_and_empty_headers_client_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NullAndEmptyHeadersIO, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_null_and_empty_headers_io_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_null_and_empty_headers_io_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_null_and_empty_headers_server_input(input: NullAndEmptyHeadersIO) -> String {
  json.to_string(encode_null_and_empty_headers_io_struct(input))
}

pub fn decode_null_and_empty_headers_server_input(body: String) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_null_and_empty_headers_server_output(body: String) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_null_and_empty_headers_server_body_xml(input: NullAndEmptyHeadersIO) -> String {
  encode_null_and_empty_headers_io_xml(input, "NullAndEmptyHeadersServer")
}

pub fn build_null_and_empty_headers_server_request(
  input: NullAndEmptyHeadersIO,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NullAndEmptyHeadersServer"
  let query = ""
  let headers = dict.new()
  let headers = case input.a {
    option.Some(v) -> rest.maybe_set_header(headers, "X-A", v)
    option.None -> headers
  }
  let headers = case input.b {
    option.Some(v) -> rest.maybe_set_header(headers, "X-B", v)
    option.None -> headers
  }
  let headers = case input.c {
    option.Some(xs) -> rest.maybe_set_list_header(headers, "X-C", list.map(xs, fn(item) { let v = item v }))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_null_and_empty_headers_server_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NullAndEmptyHeadersIO, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_null_and_empty_headers_io_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_null_and_empty_headers_io_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub type OmitsNullSerializesEmptyStringOutput {
  OmitsNullSerializesEmptyStringOutput
}

pub fn encode_omits_null_serializes_empty_string_output_struct(_v: OmitsNullSerializesEmptyStringOutput) -> json.Json {
  json.object([])
}

pub fn decode_omits_null_serializes_empty_string_output_struct() -> decode.Decoder(OmitsNullSerializesEmptyStringOutput) {
  decode.success(OmitsNullSerializesEmptyStringOutput)
}

pub fn encode_omits_null_serializes_empty_string_input(input: OmitsNullSerializesEmptyStringInput) -> String {
  json.to_string(encode_omits_null_serializes_empty_string_input_struct(input))
}

pub fn decode_omits_null_serializes_empty_string_input(body: String) -> Result(OmitsNullSerializesEmptyStringInput, String) {
  case json.parse(body, decode_omits_null_serializes_empty_string_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_omits_null_serializes_empty_string_output(body: String) -> Result(OmitsNullSerializesEmptyStringOutput, String) {
  case json.parse(body, decode_omits_null_serializes_empty_string_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_omits_null_serializes_empty_string_body_xml(input: OmitsNullSerializesEmptyStringInput) -> String {
  encode_omits_null_serializes_empty_string_input_xml(input, "OmitsNullSerializesEmptyString")
}

pub fn build_omits_null_serializes_empty_string_request(
  input: OmitsNullSerializesEmptyStringInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/OmitsNullSerializesEmptyString"
  let query = ""
  let query = case input.empty_string {
    option.Some(v) -> rest.add_query(query, "Empty", v)
    option.None -> query
  }
  let query = case input.null_value {
    option.Some(v) -> rest.add_query(query, "Null", v)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_omits_null_serializes_empty_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(OmitsNullSerializesEmptyStringOutput, String) {
  Ok(OmitsNullSerializesEmptyStringOutput)
}


pub type PutWithContentEncodingOutput {
  PutWithContentEncodingOutput
}

pub fn encode_put_with_content_encoding_output_struct(_v: PutWithContentEncodingOutput) -> json.Json {
  json.object([])
}

pub fn decode_put_with_content_encoding_output_struct() -> decode.Decoder(PutWithContentEncodingOutput) {
  decode.success(PutWithContentEncodingOutput)
}

pub fn encode_put_with_content_encoding_input(input: PutWithContentEncodingInput) -> String {
  json.to_string(encode_put_with_content_encoding_input_struct(input))
}

pub fn decode_put_with_content_encoding_input(body: String) -> Result(PutWithContentEncodingInput, String) {
  case json.parse(body, decode_put_with_content_encoding_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_with_content_encoding_output(body: String) -> Result(PutWithContentEncodingOutput, String) {
  case json.parse(body, decode_put_with_content_encoding_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_put_with_content_encoding_body_xml(input: PutWithContentEncodingInput) -> String {
  encode_put_with_content_encoding_input_xml(input, "PutWithContentEncoding")
}

pub fn build_put_with_content_encoding_request(
  input: PutWithContentEncodingInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/requestcompression/putcontentwithencoding"
  let query = ""
  let headers = dict.new()
  let headers = case input.encoding {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Encoding", v)
    option.None -> headers
  }
  let body_xml = encode_put_with_content_encoding_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_put_with_content_encoding_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(PutWithContentEncodingOutput, String) {
  Ok(PutWithContentEncodingOutput)
}


pub type QueryIdempotencyTokenAutoFillOutput {
  QueryIdempotencyTokenAutoFillOutput
}

pub fn encode_query_idempotency_token_auto_fill_output_struct(_v: QueryIdempotencyTokenAutoFillOutput) -> json.Json {
  json.object([])
}

pub fn decode_query_idempotency_token_auto_fill_output_struct() -> decode.Decoder(QueryIdempotencyTokenAutoFillOutput) {
  decode.success(QueryIdempotencyTokenAutoFillOutput)
}

pub fn encode_query_idempotency_token_auto_fill_input(input: QueryIdempotencyTokenAutoFillInput) -> String {
  json.to_string(encode_query_idempotency_token_auto_fill_input_struct(input))
}

pub fn decode_query_idempotency_token_auto_fill_input(body: String) -> Result(QueryIdempotencyTokenAutoFillInput, String) {
  case json.parse(body, decode_query_idempotency_token_auto_fill_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_idempotency_token_auto_fill_output(body: String) -> Result(QueryIdempotencyTokenAutoFillOutput, String) {
  case json.parse(body, decode_query_idempotency_token_auto_fill_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_query_idempotency_token_auto_fill_body_xml(input: QueryIdempotencyTokenAutoFillInput) -> String {
  encode_query_idempotency_token_auto_fill_input_xml(input, "QueryIdempotencyTokenAutoFill")
}

pub fn build_query_idempotency_token_auto_fill_request(
  input: QueryIdempotencyTokenAutoFillInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/QueryIdempotencyTokenAutoFill"
  let query = ""
  let query = case input.token {
    option.Some(v) -> rest.add_query(query, "token", v)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_query_idempotency_token_auto_fill_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(QueryIdempotencyTokenAutoFillOutput, String) {
  Ok(QueryIdempotencyTokenAutoFillOutput)
}


pub type QueryParamsAsStringListMapOutput {
  QueryParamsAsStringListMapOutput
}

pub fn encode_query_params_as_string_list_map_output_struct(_v: QueryParamsAsStringListMapOutput) -> json.Json {
  json.object([])
}

pub fn decode_query_params_as_string_list_map_output_struct() -> decode.Decoder(QueryParamsAsStringListMapOutput) {
  decode.success(QueryParamsAsStringListMapOutput)
}

pub fn encode_query_params_as_string_list_map_input(input: QueryParamsAsStringListMapInput) -> String {
  json.to_string(encode_query_params_as_string_list_map_input_struct(input))
}

pub fn decode_query_params_as_string_list_map_input(body: String) -> Result(QueryParamsAsStringListMapInput, String) {
  case json.parse(body, decode_query_params_as_string_list_map_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_params_as_string_list_map_output(body: String) -> Result(QueryParamsAsStringListMapOutput, String) {
  case json.parse(body, decode_query_params_as_string_list_map_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_query_params_as_string_list_map_body_xml(input: QueryParamsAsStringListMapInput) -> String {
  encode_query_params_as_string_list_map_input_xml(input, "QueryParamsAsStringListMap")
}

pub fn build_query_params_as_string_list_map_request(
  input: QueryParamsAsStringListMapInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/StringListMap"
  let query = ""
  let query = case input.qux {
    option.Some(v) -> rest.add_query(query, "corge", v)
    option.None -> query
  }
  let query = case input.foo {
    option.Some(m) -> rest.add_query_params_list(query, m)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_query_params_as_string_list_map_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(QueryParamsAsStringListMapOutput, String) {
  Ok(QueryParamsAsStringListMapOutput)
}


pub type QueryPrecedenceOutput {
  QueryPrecedenceOutput
}

pub fn encode_query_precedence_output_struct(_v: QueryPrecedenceOutput) -> json.Json {
  json.object([])
}

pub fn decode_query_precedence_output_struct() -> decode.Decoder(QueryPrecedenceOutput) {
  decode.success(QueryPrecedenceOutput)
}

pub fn encode_query_precedence_input(input: QueryPrecedenceInput) -> String {
  json.to_string(encode_query_precedence_input_struct(input))
}

pub fn decode_query_precedence_input(body: String) -> Result(QueryPrecedenceInput, String) {
  case json.parse(body, decode_query_precedence_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_precedence_output(body: String) -> Result(QueryPrecedenceOutput, String) {
  case json.parse(body, decode_query_precedence_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_query_precedence_body_xml(input: QueryPrecedenceInput) -> String {
  encode_query_precedence_input_xml(input, "QueryPrecedence")
}

pub fn build_query_precedence_request(
  input: QueryPrecedenceInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/Precedence"
  let query = ""
  let query = case input.foo {
    option.Some(v) -> rest.add_query(query, "bar", v)
    option.None -> query
  }
  let query = case input.baz {
    option.Some(m) -> rest.add_query_params(query, m)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_query_precedence_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(QueryPrecedenceOutput, String) {
  Ok(QueryPrecedenceOutput)
}


pub fn encode_recursive_shapes_input(input: RecursiveShapesRequest) -> String {
  json.to_string(encode_recursive_shapes_request_struct(input))
}

pub fn decode_recursive_shapes_input(body: String) -> Result(RecursiveShapesRequest, String) {
  case json.parse(body, decode_recursive_shapes_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_recursive_shapes_output(body: String) -> Result(RecursiveShapesResponse, String) {
  case json.parse(body, decode_recursive_shapes_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_recursive_shapes_body_xml(input: RecursiveShapesRequest) -> String {
  encode_recursive_shapes_request_xml(input, "RecursiveShapes")
}

pub fn build_recursive_shapes_request(
  input: RecursiveShapesRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/RecursiveShapes"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_recursive_shapes_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_recursive_shapes_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(RecursiveShapesResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_recursive_shapes_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_recursive_shapes_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_simple_scalar_properties_input(input: SimpleScalarPropertiesRequest) -> String {
  json.to_string(encode_simple_scalar_properties_request_struct(input))
}

pub fn decode_simple_scalar_properties_input(body: String) -> Result(SimpleScalarPropertiesRequest, String) {
  case json.parse(body, decode_simple_scalar_properties_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_simple_scalar_properties_output(body: String) -> Result(SimpleScalarPropertiesResponse, String) {
  case json.parse(body, decode_simple_scalar_properties_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_simple_scalar_properties_body_xml(input: SimpleScalarPropertiesRequest) -> String {
  encode_simple_scalar_properties_request_xml(input, "SimpleScalarProperties")
}

pub fn build_simple_scalar_properties_request(
  input: SimpleScalarPropertiesRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/SimpleScalarProperties"
  let query = ""
  let headers = dict.new()
  let headers = case input.foo {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Foo", v)
    option.None -> headers
  }
  let body_xml = encode_simple_scalar_properties_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_simple_scalar_properties_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SimpleScalarPropertiesResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_simple_scalar_properties_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_simple_scalar_properties_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_timestamp_format_headers_input(input: TimestampFormatHeadersIO) -> String {
  json.to_string(encode_timestamp_format_headers_io_struct(input))
}

pub fn decode_timestamp_format_headers_input(body: String) -> Result(TimestampFormatHeadersIO, String) {
  case json.parse(body, decode_timestamp_format_headers_io_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_timestamp_format_headers_output(body: String) -> Result(TimestampFormatHeadersIO, String) {
  case json.parse(body, decode_timestamp_format_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_timestamp_format_headers_body_xml(input: TimestampFormatHeadersIO) -> String {
  encode_timestamp_format_headers_io_xml(input, "TimestampFormatHeaders")
}

pub fn build_timestamp_format_headers_request(
  input: TimestampFormatHeadersIO,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/TimestampFormatHeaders"
  let query = ""
  let headers = dict.new()
  let headers = case input.default_format {
    option.Some(v) -> rest.maybe_set_header(headers, "X-defaultFormat", json_timestamp.format_iso8601(v))
    option.None -> headers
  }
  let headers = case input.member_date_time {
    option.Some(v) -> rest.maybe_set_header(headers, "X-memberDateTime", json_timestamp.format_iso8601(v))
    option.None -> headers
  }
  let headers = case input.member_epoch_seconds {
    option.Some(v) -> rest.maybe_set_header(headers, "X-memberEpochSeconds", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.member_http_date {
    option.Some(v) -> rest.maybe_set_header(headers, "X-memberHttpDate", json_timestamp.format_http_date(v))
    option.None -> headers
  }
  let headers = case input.target_date_time {
    option.Some(v) -> rest.maybe_set_header(headers, "X-targetDateTime", json_timestamp.format_iso8601(v))
    option.None -> headers
  }
  let headers = case input.target_epoch_seconds {
    option.Some(v) -> rest.maybe_set_header(headers, "X-targetEpochSeconds", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.target_http_date {
    option.Some(v) -> rest.maybe_set_header(headers, "X-targetHttpDate", json_timestamp.format_http_date(v))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_timestamp_format_headers_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TimestampFormatHeadersIO, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_timestamp_format_headers_io_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_timestamp_format_headers_io_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_attributes_input(input: XmlAttributesRequest) -> String {
  json.to_string(encode_xml_attributes_request_struct(input))
}

pub fn decode_xml_attributes_input(body: String) -> Result(XmlAttributesRequest, String) {
  case json.parse(body, decode_xml_attributes_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_attributes_output(body: String) -> Result(XmlAttributesResponse, String) {
  case json.parse(body, decode_xml_attributes_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_attributes_body_xml(input: XmlAttributesRequest) -> String {
  encode_xml_attributes_request_xml(input, "XmlAttributes")
}

pub fn build_xml_attributes_request(
  input: XmlAttributesRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlAttributes"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_attributes_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_attributes_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlAttributesResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_attributes_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_attributes_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_attributes_in_middle_input(input: XmlAttributesInMiddleRequest) -> String {
  json.to_string(encode_xml_attributes_in_middle_request_struct(input))
}

pub fn decode_xml_attributes_in_middle_input(body: String) -> Result(XmlAttributesInMiddleRequest, String) {
  case json.parse(body, decode_xml_attributes_in_middle_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_attributes_in_middle_output(body: String) -> Result(XmlAttributesInMiddleResponse, String) {
  case json.parse(body, decode_xml_attributes_in_middle_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_attributes_in_middle_body_xml(input: XmlAttributesInMiddleRequest) -> String {
  encode_xml_attributes_in_middle_request_xml(input, "XmlAttributesInMiddle")
}

pub fn build_xml_attributes_in_middle_request(
  input: XmlAttributesInMiddleRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlAttributesInMiddle"
  let query = ""
  let headers = dict.new()
  let body = case input.payload {
    option.Some(v) -> bit_array.from_string(encode_xml_attributes_in_middle_payload_request_xml(v, "payload"))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_attributes_in_middle_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlAttributesInMiddleResponse, String) {
  {
    use text <- result.try(case bit_array.to_string(body) {
      Ok(t) -> Ok(t)
      Error(_) -> Error("non-utf8 payload")
    })
    use payload <- result.try(case text {
      "" -> Ok(option.None)
      _ -> case xml_decode.parse(text) {
        Ok(root) -> case decode_xml_attributes_in_middle_payload_response_xml(root) {
          Ok(v) -> Ok(option.Some(v))
          Error(r) -> Error(r)
        }
        Error(r) -> Error(r)
      }
    })
    Ok(XmlAttributesInMiddleResponse(
    payload: payload,
    ))
  }
}


pub fn encode_xml_attributes_on_payload_input(input: XmlAttributesOnPayloadRequest) -> String {
  json.to_string(encode_xml_attributes_on_payload_request_struct(input))
}

pub fn decode_xml_attributes_on_payload_input(body: String) -> Result(XmlAttributesOnPayloadRequest, String) {
  case json.parse(body, decode_xml_attributes_on_payload_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_attributes_on_payload_output(body: String) -> Result(XmlAttributesOnPayloadResponse, String) {
  case json.parse(body, decode_xml_attributes_on_payload_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_attributes_on_payload_body_xml(input: XmlAttributesOnPayloadRequest) -> String {
  encode_xml_attributes_on_payload_request_xml(input, "XmlAttributesOnPayload")
}

pub fn build_xml_attributes_on_payload_request(
  input: XmlAttributesOnPayloadRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlAttributesOnPayload"
  let query = ""
  let headers = dict.new()
  let body = case input.payload {
    option.Some(v) -> bit_array.from_string(encode_xml_attributes_payload_request_xml(v, "payload"))
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_attributes_on_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlAttributesOnPayloadResponse, String) {
  {
    use text <- result.try(case bit_array.to_string(body) {
      Ok(t) -> Ok(t)
      Error(_) -> Error("non-utf8 payload")
    })
    use payload <- result.try(case text {
      "" -> Ok(option.None)
      _ -> case xml_decode.parse(text) {
        Ok(root) -> case decode_xml_attributes_payload_response_xml(root) {
          Ok(v) -> Ok(option.Some(v))
          Error(r) -> Error(r)
        }
        Error(r) -> Error(r)
      }
    })
    Ok(XmlAttributesOnPayloadResponse(
    payload: payload,
    ))
  }
}


pub fn encode_xml_blobs_input(input: XmlBlobsRequest) -> String {
  json.to_string(encode_xml_blobs_request_struct(input))
}

pub fn decode_xml_blobs_input(body: String) -> Result(XmlBlobsRequest, String) {
  case json.parse(body, decode_xml_blobs_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_blobs_output(body: String) -> Result(XmlBlobsResponse, String) {
  case json.parse(body, decode_xml_blobs_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_blobs_body_xml(input: XmlBlobsRequest) -> String {
  encode_xml_blobs_request_xml(input, "XmlBlobs")
}

pub fn build_xml_blobs_request(
  input: XmlBlobsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlBlobs"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_blobs_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_blobs_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlBlobsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_blobs_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_blobs_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_empty_blobs_input(input: XmlEmptyBlobsRequest) -> String {
  json.to_string(encode_xml_empty_blobs_request_struct(input))
}

pub fn decode_xml_empty_blobs_input(body: String) -> Result(XmlEmptyBlobsRequest, String) {
  case json.parse(body, decode_xml_empty_blobs_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_empty_blobs_output(body: String) -> Result(XmlEmptyBlobsResponse, String) {
  case json.parse(body, decode_xml_empty_blobs_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_empty_blobs_body_xml(input: XmlEmptyBlobsRequest) -> String {
  encode_xml_empty_blobs_request_xml(input, "XmlEmptyBlobs")
}

pub fn build_xml_empty_blobs_request(
  input: XmlEmptyBlobsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlEmptyBlobs"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_empty_blobs_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_empty_blobs_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlEmptyBlobsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_empty_blobs_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_empty_blobs_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_empty_lists_input(input: XmlEmptyListsRequest) -> String {
  json.to_string(encode_xml_empty_lists_request_struct(input))
}

pub fn decode_xml_empty_lists_input(body: String) -> Result(XmlEmptyListsRequest, String) {
  case json.parse(body, decode_xml_empty_lists_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_empty_lists_output(body: String) -> Result(XmlEmptyListsResponse, String) {
  case json.parse(body, decode_xml_empty_lists_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_empty_lists_body_xml(input: XmlEmptyListsRequest) -> String {
  encode_xml_empty_lists_request_xml(input, "XmlEmptyLists")
}

pub fn build_xml_empty_lists_request(
  input: XmlEmptyListsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlEmptyLists"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_empty_lists_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_empty_lists_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlEmptyListsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_empty_lists_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_empty_lists_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_empty_maps_input(input: XmlEmptyMapsRequest) -> String {
  json.to_string(encode_xml_empty_maps_request_struct(input))
}

pub fn decode_xml_empty_maps_input(body: String) -> Result(XmlEmptyMapsRequest, String) {
  case json.parse(body, decode_xml_empty_maps_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_empty_maps_output(body: String) -> Result(XmlEmptyMapsResponse, String) {
  case json.parse(body, decode_xml_empty_maps_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_empty_maps_body_xml(input: XmlEmptyMapsRequest) -> String {
  encode_xml_empty_maps_request_xml(input, "XmlEmptyMaps")
}

pub fn build_xml_empty_maps_request(
  input: XmlEmptyMapsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlEmptyMaps"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_empty_maps_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_empty_maps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlEmptyMapsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_empty_maps_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_empty_maps_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_empty_strings_input(input: XmlEmptyStringsRequest) -> String {
  json.to_string(encode_xml_empty_strings_request_struct(input))
}

pub fn decode_xml_empty_strings_input(body: String) -> Result(XmlEmptyStringsRequest, String) {
  case json.parse(body, decode_xml_empty_strings_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_empty_strings_output(body: String) -> Result(XmlEmptyStringsResponse, String) {
  case json.parse(body, decode_xml_empty_strings_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_empty_strings_body_xml(input: XmlEmptyStringsRequest) -> String {
  encode_xml_empty_strings_request_xml(input, "XmlEmptyStrings")
}

pub fn build_xml_empty_strings_request(
  input: XmlEmptyStringsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlEmptyStrings"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_empty_strings_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_empty_strings_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlEmptyStringsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_empty_strings_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_empty_strings_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_enums_input(input: XmlEnumsRequest) -> String {
  json.to_string(encode_xml_enums_request_struct(input))
}

pub fn decode_xml_enums_input(body: String) -> Result(XmlEnumsRequest, String) {
  case json.parse(body, decode_xml_enums_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_enums_output(body: String) -> Result(XmlEnumsResponse, String) {
  case json.parse(body, decode_xml_enums_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_enums_body_xml(input: XmlEnumsRequest) -> String {
  encode_xml_enums_request_xml(input, "XmlEnums")
}

pub fn build_xml_enums_request(
  input: XmlEnumsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlEnums"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_enums_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlEnumsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_enums_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_enums_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_int_enums_input(input: XmlIntEnumsRequest) -> String {
  json.to_string(encode_xml_int_enums_request_struct(input))
}

pub fn decode_xml_int_enums_input(body: String) -> Result(XmlIntEnumsRequest, String) {
  case json.parse(body, decode_xml_int_enums_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_int_enums_output(body: String) -> Result(XmlIntEnumsResponse, String) {
  case json.parse(body, decode_xml_int_enums_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_int_enums_body_xml(input: XmlIntEnumsRequest) -> String {
  encode_xml_int_enums_request_xml(input, "XmlIntEnums")
}

pub fn build_xml_int_enums_request(
  input: XmlIntEnumsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlIntEnums"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_int_enums_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_int_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlIntEnumsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_int_enums_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_int_enums_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_lists_input(input: XmlListsRequest) -> String {
  json.to_string(encode_xml_lists_request_struct(input))
}

pub fn decode_xml_lists_input(body: String) -> Result(XmlListsRequest, String) {
  case json.parse(body, decode_xml_lists_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_lists_output(body: String) -> Result(XmlListsResponse, String) {
  case json.parse(body, decode_xml_lists_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_lists_body_xml(input: XmlListsRequest) -> String {
  encode_xml_lists_request_xml(input, "XmlLists")
}

pub fn build_xml_lists_request(
  input: XmlListsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlLists"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_lists_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_lists_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlListsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_lists_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_lists_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_maps_input(input: XmlMapsRequest) -> String {
  json.to_string(encode_xml_maps_request_struct(input))
}

pub fn decode_xml_maps_input(body: String) -> Result(XmlMapsRequest, String) {
  case json.parse(body, decode_xml_maps_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_maps_output(body: String) -> Result(XmlMapsResponse, String) {
  case json.parse(body, decode_xml_maps_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_maps_body_xml(input: XmlMapsRequest) -> String {
  encode_xml_maps_request_xml(input, "XmlMaps")
}

pub fn build_xml_maps_request(
  input: XmlMapsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlMaps"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_maps_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_maps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlMapsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_maps_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_maps_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_maps_xml_name_input(input: XmlMapsXmlNameRequest) -> String {
  json.to_string(encode_xml_maps_xml_name_request_struct(input))
}

pub fn decode_xml_maps_xml_name_input(body: String) -> Result(XmlMapsXmlNameRequest, String) {
  case json.parse(body, decode_xml_maps_xml_name_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_maps_xml_name_output(body: String) -> Result(XmlMapsXmlNameResponse, String) {
  case json.parse(body, decode_xml_maps_xml_name_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_maps_xml_name_body_xml(input: XmlMapsXmlNameRequest) -> String {
  encode_xml_maps_xml_name_request_xml(input, "XmlMapsXmlName")
}

pub fn build_xml_maps_xml_name_request(
  input: XmlMapsXmlNameRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlMapsXmlName"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_maps_xml_name_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_maps_xml_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlMapsXmlNameResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_maps_xml_name_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_maps_xml_name_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_map_with_xml_namespace_input(input: XmlMapWithXmlNamespaceRequest) -> String {
  json.to_string(encode_xml_map_with_xml_namespace_request_struct(input))
}

pub fn decode_xml_map_with_xml_namespace_input(body: String) -> Result(XmlMapWithXmlNamespaceRequest, String) {
  case json.parse(body, decode_xml_map_with_xml_namespace_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_map_with_xml_namespace_output(body: String) -> Result(XmlMapWithXmlNamespaceResponse, String) {
  case json.parse(body, decode_xml_map_with_xml_namespace_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_map_with_xml_namespace_body_xml(input: XmlMapWithXmlNamespaceRequest) -> String {
  encode_xml_map_with_xml_namespace_request_xml(input, "XmlMapWithXmlNamespace")
}

pub fn build_xml_map_with_xml_namespace_request(
  input: XmlMapWithXmlNamespaceRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlMapWithXmlNamespace"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_map_with_xml_namespace_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_map_with_xml_namespace_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlMapWithXmlNamespaceResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_map_with_xml_namespace_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_map_with_xml_namespace_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_namespaces_input(input: XmlNamespacesRequest) -> String {
  json.to_string(encode_xml_namespaces_request_struct(input))
}

pub fn decode_xml_namespaces_input(body: String) -> Result(XmlNamespacesRequest, String) {
  case json.parse(body, decode_xml_namespaces_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_namespaces_output(body: String) -> Result(XmlNamespacesResponse, String) {
  case json.parse(body, decode_xml_namespaces_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_namespaces_body_xml(input: XmlNamespacesRequest) -> String {
  encode_xml_namespaces_request_xml(input, "XmlNamespaces")
}

pub fn build_xml_namespaces_request(
  input: XmlNamespacesRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlNamespaces"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_namespaces_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_namespaces_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlNamespacesResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_namespaces_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_namespaces_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_timestamps_input(input: XmlTimestampsRequest) -> String {
  json.to_string(encode_xml_timestamps_request_struct(input))
}

pub fn decode_xml_timestamps_input(body: String) -> Result(XmlTimestampsRequest, String) {
  case json.parse(body, decode_xml_timestamps_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_timestamps_output(body: String) -> Result(XmlTimestampsResponse, String) {
  case json.parse(body, decode_xml_timestamps_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_timestamps_body_xml(input: XmlTimestampsRequest) -> String {
  encode_xml_timestamps_request_xml(input, "XmlTimestamps")
}

pub fn build_xml_timestamps_request(
  input: XmlTimestampsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlTimestamps"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_timestamps_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_xml_timestamps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlTimestampsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_timestamps_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_timestamps_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}


pub fn encode_xml_unions_input(input: XmlUnionsRequest) -> String {
  json.to_string(encode_xml_unions_request_struct(input))
}

pub fn decode_xml_unions_input(body: String) -> Result(XmlUnionsRequest, String) {
  case json.parse(body, decode_xml_unions_request_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_xml_unions_output(body: String) -> Result(XmlUnionsResponse, String) {
  case json.parse(body, decode_xml_unions_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_xml_unions_body_xml(input: XmlUnionsRequest) -> String {
  encode_xml_unions_request_xml(input, "XmlUnions")
}

pub fn build_xml_unions_request(
  input: XmlUnionsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/XmlUnions"
  let query = ""
  let headers = dict.new()
  let body_xml = encode_xml_unions_body_xml(input)
  let body = bit_array.from_string(body_xml)
  let content_type = "application/xml"
  let headers = case content_type, dict.has_key(headers, "Content-Type") {
    "", _ -> headers
    _, True -> headers
    _, False -> dict.insert(headers, "Content-Type", content_type)
  }
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Length", int.to_string(bit_array.byte_size(body)))
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_xml_unions_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(XmlUnionsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_xml_unions_response_xml(xml_decode.Element(name: "empty", attrs: [], children: []))
      _ -> case xml_decode.parse(text) {
        Ok(root) -> decode_xml_unions_response_xml(root)
        Error(r) -> Error(r)
      }
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type AllQueryStringTypesError {
  AllQueryStringTypesErrorTransport(reason: String)
  AllQueryStringTypesErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_all_query_string_types_error(err: awsjson_client.ClientError) -> AllQueryStringTypesError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> AllQueryStringTypesErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> AllQueryStringTypesErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> AllQueryStringTypesErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> AllQueryStringTypesErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> AllQueryStringTypesErrorTransport(reason: "decode: " <> r)
  }
}

pub type BodyWithXmlNameError {
  BodyWithXmlNameErrorTransport(reason: String)
  BodyWithXmlNameErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_body_with_xml_name_error(err: awsjson_client.ClientError) -> BodyWithXmlNameError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> BodyWithXmlNameErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> BodyWithXmlNameErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> BodyWithXmlNameErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> BodyWithXmlNameErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> BodyWithXmlNameErrorTransport(reason: "decode: " <> r)
  }
}

pub type ConstantAndVariableQueryStringError {
  ConstantAndVariableQueryStringErrorTransport(reason: String)
  ConstantAndVariableQueryStringErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_constant_and_variable_query_string_error(err: awsjson_client.ClientError) -> ConstantAndVariableQueryStringError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> ConstantAndVariableQueryStringErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> ConstantAndVariableQueryStringErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> ConstantAndVariableQueryStringErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> ConstantAndVariableQueryStringErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> ConstantAndVariableQueryStringErrorTransport(reason: "decode: " <> r)
  }
}

pub type ConstantQueryStringError {
  ConstantQueryStringErrorTransport(reason: String)
  ConstantQueryStringErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_constant_query_string_error(err: awsjson_client.ClientError) -> ConstantQueryStringError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> ConstantQueryStringErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> ConstantQueryStringErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> ConstantQueryStringErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> ConstantQueryStringErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> ConstantQueryStringErrorTransport(reason: "decode: " <> r)
  }
}

pub type ContentTypeParametersError {
  ContentTypeParametersErrorTransport(reason: String)
  ContentTypeParametersErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_content_type_parameters_error(err: awsjson_client.ClientError) -> ContentTypeParametersError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> ContentTypeParametersErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> ContentTypeParametersErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> ContentTypeParametersErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> ContentTypeParametersErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> ContentTypeParametersErrorTransport(reason: "decode: " <> r)
  }
}

pub type DatetimeOffsetsError {
  DatetimeOffsetsErrorTransport(reason: String)
  DatetimeOffsetsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_datetime_offsets_error(err: awsjson_client.ClientError) -> DatetimeOffsetsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> DatetimeOffsetsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> DatetimeOffsetsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> DatetimeOffsetsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> DatetimeOffsetsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> DatetimeOffsetsErrorTransport(reason: "decode: " <> r)
  }
}

pub type EmptyInputAndEmptyOutputError {
  EmptyInputAndEmptyOutputErrorTransport(reason: String)
  EmptyInputAndEmptyOutputErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_empty_input_and_empty_output_error(err: awsjson_client.ClientError) -> EmptyInputAndEmptyOutputError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> EmptyInputAndEmptyOutputErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> EmptyInputAndEmptyOutputErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> EmptyInputAndEmptyOutputErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> EmptyInputAndEmptyOutputErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> EmptyInputAndEmptyOutputErrorTransport(reason: "decode: " <> r)
  }
}

pub type EndpointOperationError {
  EndpointOperationErrorTransport(reason: String)
  EndpointOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_endpoint_operation_error(err: awsjson_client.ClientError) -> EndpointOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> EndpointOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> EndpointOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> EndpointOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> EndpointOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> EndpointOperationErrorTransport(reason: "decode: " <> r)
  }
}

pub type EndpointWithHostLabelHeaderOperationError {
  EndpointWithHostLabelHeaderOperationErrorTransport(reason: String)
  EndpointWithHostLabelHeaderOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_endpoint_with_host_label_header_operation_error(err: awsjson_client.ClientError) -> EndpointWithHostLabelHeaderOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> EndpointWithHostLabelHeaderOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> EndpointWithHostLabelHeaderOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> EndpointWithHostLabelHeaderOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> EndpointWithHostLabelHeaderOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> EndpointWithHostLabelHeaderOperationErrorTransport(reason: "decode: " <> r)
  }
}

pub type EndpointWithHostLabelOperationError {
  EndpointWithHostLabelOperationErrorTransport(reason: String)
  EndpointWithHostLabelOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_endpoint_with_host_label_operation_error(err: awsjson_client.ClientError) -> EndpointWithHostLabelOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> EndpointWithHostLabelOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> EndpointWithHostLabelOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> EndpointWithHostLabelOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> EndpointWithHostLabelOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> EndpointWithHostLabelOperationErrorTransport(reason: "decode: " <> r)
  }
}

pub type FlattenedXmlMapError {
  FlattenedXmlMapErrorTransport(reason: String)
  FlattenedXmlMapErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_flattened_xml_map_error(err: awsjson_client.ClientError) -> FlattenedXmlMapError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> FlattenedXmlMapErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> FlattenedXmlMapErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> FlattenedXmlMapErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> FlattenedXmlMapErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> FlattenedXmlMapErrorTransport(reason: "decode: " <> r)
  }
}

pub type FlattenedXmlMapWithXmlNameError {
  FlattenedXmlMapWithXmlNameErrorTransport(reason: String)
  FlattenedXmlMapWithXmlNameErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_flattened_xml_map_with_xml_name_error(err: awsjson_client.ClientError) -> FlattenedXmlMapWithXmlNameError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> FlattenedXmlMapWithXmlNameErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> FlattenedXmlMapWithXmlNameErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> FlattenedXmlMapWithXmlNameErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> FlattenedXmlMapWithXmlNameErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> FlattenedXmlMapWithXmlNameErrorTransport(reason: "decode: " <> r)
  }
}

pub type FlattenedXmlMapWithXmlNamespaceError {
  FlattenedXmlMapWithXmlNamespaceErrorTransport(reason: String)
  FlattenedXmlMapWithXmlNamespaceErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_flattened_xml_map_with_xml_namespace_error(err: awsjson_client.ClientError) -> FlattenedXmlMapWithXmlNamespaceError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> FlattenedXmlMapWithXmlNamespaceErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> FlattenedXmlMapWithXmlNamespaceErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> FlattenedXmlMapWithXmlNamespaceErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> FlattenedXmlMapWithXmlNamespaceErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> FlattenedXmlMapWithXmlNamespaceErrorTransport(reason: "decode: " <> r)
  }
}

pub type FractionalSecondsError {
  FractionalSecondsErrorTransport(reason: String)
  FractionalSecondsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_fractional_seconds_error(err: awsjson_client.ClientError) -> FractionalSecondsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> FractionalSecondsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> FractionalSecondsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> FractionalSecondsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> FractionalSecondsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> FractionalSecondsErrorTransport(reason: "decode: " <> r)
  }
}

pub type GreetingWithErrorsError {
  GreetingWithErrorsErrorComplexError(value: ComplexError)
  GreetingWithErrorsErrorInvalidGreeting(value: InvalidGreeting)
  GreetingWithErrorsErrorTransport(reason: String)
  GreetingWithErrorsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_greeting_with_errors_error(err: awsjson_client.ClientError) -> GreetingWithErrorsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
        case awsjson_client.error_type_matches(et, "ComplexError") {
          True -> case bit_array.to_string(b) {
            Ok(text) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: text)
            Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: "")
          }
          False ->         case awsjson_client.error_type_matches(et, "InvalidGreeting") {
          True -> case bit_array.to_string(b) {
            Ok(text) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: text)
            Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: "")
          }
          False -> case bit_array.to_string(b) {
          Ok(text) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: "")
        }
        }
        }
    }
    awsjson_client.TransportError(_) -> GreetingWithErrorsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> GreetingWithErrorsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> GreetingWithErrorsErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpEmptyPrefixHeadersError {
  HttpEmptyPrefixHeadersErrorTransport(reason: String)
  HttpEmptyPrefixHeadersErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_empty_prefix_headers_error(err: awsjson_client.ClientError) -> HttpEmptyPrefixHeadersError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpEmptyPrefixHeadersErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpEmptyPrefixHeadersErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpEmptyPrefixHeadersErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpEmptyPrefixHeadersErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpEmptyPrefixHeadersErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpEnumPayloadError {
  HttpEnumPayloadErrorTransport(reason: String)
  HttpEnumPayloadErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_enum_payload_error(err: awsjson_client.ClientError) -> HttpEnumPayloadError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpEnumPayloadErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpEnumPayloadErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpEnumPayloadErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpEnumPayloadErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpEnumPayloadErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadTraitsError {
  HttpPayloadTraitsErrorTransport(reason: String)
  HttpPayloadTraitsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_traits_error(err: awsjson_client.ClientError) -> HttpPayloadTraitsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadTraitsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadTraitsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadTraitsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadTraitsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadTraitsErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadTraitsWithMediaTypeError {
  HttpPayloadTraitsWithMediaTypeErrorTransport(reason: String)
  HttpPayloadTraitsWithMediaTypeErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_traits_with_media_type_error(err: awsjson_client.ClientError) -> HttpPayloadTraitsWithMediaTypeError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadTraitsWithMediaTypeErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadTraitsWithMediaTypeErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadTraitsWithMediaTypeErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadTraitsWithMediaTypeErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadTraitsWithMediaTypeErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadWithMemberXmlNameError {
  HttpPayloadWithMemberXmlNameErrorTransport(reason: String)
  HttpPayloadWithMemberXmlNameErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_with_member_xml_name_error(err: awsjson_client.ClientError) -> HttpPayloadWithMemberXmlNameError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadWithMemberXmlNameErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadWithMemberXmlNameErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadWithMemberXmlNameErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadWithMemberXmlNameErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadWithMemberXmlNameErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadWithStructureError {
  HttpPayloadWithStructureErrorTransport(reason: String)
  HttpPayloadWithStructureErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_with_structure_error(err: awsjson_client.ClientError) -> HttpPayloadWithStructureError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadWithStructureErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadWithStructureErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadWithStructureErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadWithStructureErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadWithStructureErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadWithUnionError {
  HttpPayloadWithUnionErrorTransport(reason: String)
  HttpPayloadWithUnionErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_with_union_error(err: awsjson_client.ClientError) -> HttpPayloadWithUnionError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadWithUnionErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadWithUnionErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadWithUnionErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadWithUnionErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadWithUnionErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadWithXmlNameError {
  HttpPayloadWithXmlNameErrorTransport(reason: String)
  HttpPayloadWithXmlNameErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_with_xml_name_error(err: awsjson_client.ClientError) -> HttpPayloadWithXmlNameError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadWithXmlNameErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadWithXmlNameErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadWithXmlNameErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadWithXmlNameErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadWithXmlNameErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadWithXmlNamespaceError {
  HttpPayloadWithXmlNamespaceErrorTransport(reason: String)
  HttpPayloadWithXmlNamespaceErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_with_xml_namespace_error(err: awsjson_client.ClientError) -> HttpPayloadWithXmlNamespaceError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadWithXmlNamespaceErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadWithXmlNamespaceErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadWithXmlNamespaceErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadWithXmlNamespaceErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadWithXmlNamespaceErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPayloadWithXmlNamespaceAndPrefixError {
  HttpPayloadWithXmlNamespaceAndPrefixErrorTransport(reason: String)
  HttpPayloadWithXmlNamespaceAndPrefixErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_payload_with_xml_namespace_and_prefix_error(err: awsjson_client.ClientError) -> HttpPayloadWithXmlNamespaceAndPrefixError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPayloadWithXmlNamespaceAndPrefixErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPayloadWithXmlNamespaceAndPrefixErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPayloadWithXmlNamespaceAndPrefixErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPayloadWithXmlNamespaceAndPrefixErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPayloadWithXmlNamespaceAndPrefixErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpPrefixHeadersError {
  HttpPrefixHeadersErrorTransport(reason: String)
  HttpPrefixHeadersErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_prefix_headers_error(err: awsjson_client.ClientError) -> HttpPrefixHeadersError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpPrefixHeadersErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpPrefixHeadersErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpPrefixHeadersErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpPrefixHeadersErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpPrefixHeadersErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpRequestWithFloatLabelsError {
  HttpRequestWithFloatLabelsErrorTransport(reason: String)
  HttpRequestWithFloatLabelsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_request_with_float_labels_error(err: awsjson_client.ClientError) -> HttpRequestWithFloatLabelsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpRequestWithFloatLabelsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpRequestWithFloatLabelsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpRequestWithFloatLabelsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpRequestWithFloatLabelsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpRequestWithFloatLabelsErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpRequestWithGreedyLabelInPathError {
  HttpRequestWithGreedyLabelInPathErrorTransport(reason: String)
  HttpRequestWithGreedyLabelInPathErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_request_with_greedy_label_in_path_error(err: awsjson_client.ClientError) -> HttpRequestWithGreedyLabelInPathError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpRequestWithGreedyLabelInPathErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpRequestWithGreedyLabelInPathErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpRequestWithGreedyLabelInPathErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpRequestWithGreedyLabelInPathErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpRequestWithGreedyLabelInPathErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpRequestWithLabelsError {
  HttpRequestWithLabelsErrorTransport(reason: String)
  HttpRequestWithLabelsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_request_with_labels_error(err: awsjson_client.ClientError) -> HttpRequestWithLabelsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpRequestWithLabelsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpRequestWithLabelsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpRequestWithLabelsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpRequestWithLabelsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpRequestWithLabelsErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpRequestWithLabelsAndTimestampFormatError {
  HttpRequestWithLabelsAndTimestampFormatErrorTransport(reason: String)
  HttpRequestWithLabelsAndTimestampFormatErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_request_with_labels_and_timestamp_format_error(err: awsjson_client.ClientError) -> HttpRequestWithLabelsAndTimestampFormatError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpRequestWithLabelsAndTimestampFormatErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpRequestWithLabelsAndTimestampFormatErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpRequestWithLabelsAndTimestampFormatErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpRequestWithLabelsAndTimestampFormatErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpRequestWithLabelsAndTimestampFormatErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpResponseCodeError {
  HttpResponseCodeErrorTransport(reason: String)
  HttpResponseCodeErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_response_code_error(err: awsjson_client.ClientError) -> HttpResponseCodeError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpResponseCodeErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpResponseCodeErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpResponseCodeErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpResponseCodeErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpResponseCodeErrorTransport(reason: "decode: " <> r)
  }
}

pub type HttpStringPayloadError {
  HttpStringPayloadErrorTransport(reason: String)
  HttpStringPayloadErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_http_string_payload_error(err: awsjson_client.ClientError) -> HttpStringPayloadError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HttpStringPayloadErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HttpStringPayloadErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HttpStringPayloadErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HttpStringPayloadErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HttpStringPayloadErrorTransport(reason: "decode: " <> r)
  }
}

pub type IgnoreQueryParamsInResponseError {
  IgnoreQueryParamsInResponseErrorTransport(reason: String)
  IgnoreQueryParamsInResponseErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_ignore_query_params_in_response_error(err: awsjson_client.ClientError) -> IgnoreQueryParamsInResponseError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> IgnoreQueryParamsInResponseErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> IgnoreQueryParamsInResponseErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> IgnoreQueryParamsInResponseErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> IgnoreQueryParamsInResponseErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> IgnoreQueryParamsInResponseErrorTransport(reason: "decode: " <> r)
  }
}

pub type InputAndOutputWithHeadersError {
  InputAndOutputWithHeadersErrorTransport(reason: String)
  InputAndOutputWithHeadersErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_input_and_output_with_headers_error(err: awsjson_client.ClientError) -> InputAndOutputWithHeadersError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> InputAndOutputWithHeadersErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> InputAndOutputWithHeadersErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> InputAndOutputWithHeadersErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> InputAndOutputWithHeadersErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> InputAndOutputWithHeadersErrorTransport(reason: "decode: " <> r)
  }
}

pub type NestedXmlMapsError {
  NestedXmlMapsErrorTransport(reason: String)
  NestedXmlMapsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_nested_xml_maps_error(err: awsjson_client.ClientError) -> NestedXmlMapsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> NestedXmlMapsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> NestedXmlMapsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> NestedXmlMapsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> NestedXmlMapsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> NestedXmlMapsErrorTransport(reason: "decode: " <> r)
  }
}

pub type NestedXmlMapWithXmlNameError {
  NestedXmlMapWithXmlNameErrorTransport(reason: String)
  NestedXmlMapWithXmlNameErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_nested_xml_map_with_xml_name_error(err: awsjson_client.ClientError) -> NestedXmlMapWithXmlNameError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> NestedXmlMapWithXmlNameErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> NestedXmlMapWithXmlNameErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> NestedXmlMapWithXmlNameErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> NestedXmlMapWithXmlNameErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> NestedXmlMapWithXmlNameErrorTransport(reason: "decode: " <> r)
  }
}

pub type NoInputAndNoOutputError {
  NoInputAndNoOutputErrorTransport(reason: String)
  NoInputAndNoOutputErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_no_input_and_no_output_error(err: awsjson_client.ClientError) -> NoInputAndNoOutputError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> NoInputAndNoOutputErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> NoInputAndNoOutputErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> NoInputAndNoOutputErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> NoInputAndNoOutputErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> NoInputAndNoOutputErrorTransport(reason: "decode: " <> r)
  }
}

pub type NoInputAndOutputError {
  NoInputAndOutputErrorTransport(reason: String)
  NoInputAndOutputErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_no_input_and_output_error(err: awsjson_client.ClientError) -> NoInputAndOutputError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> NoInputAndOutputErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> NoInputAndOutputErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> NoInputAndOutputErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> NoInputAndOutputErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> NoInputAndOutputErrorTransport(reason: "decode: " <> r)
  }
}

pub type NullAndEmptyHeadersClientError {
  NullAndEmptyHeadersClientErrorTransport(reason: String)
  NullAndEmptyHeadersClientErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_null_and_empty_headers_client_error(err: awsjson_client.ClientError) -> NullAndEmptyHeadersClientError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> NullAndEmptyHeadersClientErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> NullAndEmptyHeadersClientErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> NullAndEmptyHeadersClientErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> NullAndEmptyHeadersClientErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> NullAndEmptyHeadersClientErrorTransport(reason: "decode: " <> r)
  }
}

pub type NullAndEmptyHeadersServerError {
  NullAndEmptyHeadersServerErrorTransport(reason: String)
  NullAndEmptyHeadersServerErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_null_and_empty_headers_server_error(err: awsjson_client.ClientError) -> NullAndEmptyHeadersServerError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> NullAndEmptyHeadersServerErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> NullAndEmptyHeadersServerErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> NullAndEmptyHeadersServerErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> NullAndEmptyHeadersServerErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> NullAndEmptyHeadersServerErrorTransport(reason: "decode: " <> r)
  }
}

pub type OmitsNullSerializesEmptyStringError {
  OmitsNullSerializesEmptyStringErrorTransport(reason: String)
  OmitsNullSerializesEmptyStringErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_omits_null_serializes_empty_string_error(err: awsjson_client.ClientError) -> OmitsNullSerializesEmptyStringError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> OmitsNullSerializesEmptyStringErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> OmitsNullSerializesEmptyStringErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> OmitsNullSerializesEmptyStringErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> OmitsNullSerializesEmptyStringErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> OmitsNullSerializesEmptyStringErrorTransport(reason: "decode: " <> r)
  }
}

pub type PutWithContentEncodingError {
  PutWithContentEncodingErrorTransport(reason: String)
  PutWithContentEncodingErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_put_with_content_encoding_error(err: awsjson_client.ClientError) -> PutWithContentEncodingError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> PutWithContentEncodingErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> PutWithContentEncodingErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> PutWithContentEncodingErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> PutWithContentEncodingErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> PutWithContentEncodingErrorTransport(reason: "decode: " <> r)
  }
}

pub type QueryIdempotencyTokenAutoFillError {
  QueryIdempotencyTokenAutoFillErrorTransport(reason: String)
  QueryIdempotencyTokenAutoFillErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_query_idempotency_token_auto_fill_error(err: awsjson_client.ClientError) -> QueryIdempotencyTokenAutoFillError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> QueryIdempotencyTokenAutoFillErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> QueryIdempotencyTokenAutoFillErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> QueryIdempotencyTokenAutoFillErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> QueryIdempotencyTokenAutoFillErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> QueryIdempotencyTokenAutoFillErrorTransport(reason: "decode: " <> r)
  }
}

pub type QueryParamsAsStringListMapError {
  QueryParamsAsStringListMapErrorTransport(reason: String)
  QueryParamsAsStringListMapErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_query_params_as_string_list_map_error(err: awsjson_client.ClientError) -> QueryParamsAsStringListMapError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> QueryParamsAsStringListMapErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> QueryParamsAsStringListMapErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> QueryParamsAsStringListMapErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> QueryParamsAsStringListMapErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> QueryParamsAsStringListMapErrorTransport(reason: "decode: " <> r)
  }
}

pub type QueryPrecedenceError {
  QueryPrecedenceErrorTransport(reason: String)
  QueryPrecedenceErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_query_precedence_error(err: awsjson_client.ClientError) -> QueryPrecedenceError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> QueryPrecedenceErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> QueryPrecedenceErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> QueryPrecedenceErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> QueryPrecedenceErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> QueryPrecedenceErrorTransport(reason: "decode: " <> r)
  }
}

pub type RecursiveShapesError {
  RecursiveShapesErrorTransport(reason: String)
  RecursiveShapesErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_recursive_shapes_error(err: awsjson_client.ClientError) -> RecursiveShapesError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> RecursiveShapesErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> RecursiveShapesErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> RecursiveShapesErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> RecursiveShapesErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> RecursiveShapesErrorTransport(reason: "decode: " <> r)
  }
}

pub type SimpleScalarPropertiesError {
  SimpleScalarPropertiesErrorTransport(reason: String)
  SimpleScalarPropertiesErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_simple_scalar_properties_error(err: awsjson_client.ClientError) -> SimpleScalarPropertiesError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> SimpleScalarPropertiesErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> SimpleScalarPropertiesErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> SimpleScalarPropertiesErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> SimpleScalarPropertiesErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> SimpleScalarPropertiesErrorTransport(reason: "decode: " <> r)
  }
}

pub type TimestampFormatHeadersError {
  TimestampFormatHeadersErrorTransport(reason: String)
  TimestampFormatHeadersErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_timestamp_format_headers_error(err: awsjson_client.ClientError) -> TimestampFormatHeadersError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> TimestampFormatHeadersErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> TimestampFormatHeadersErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> TimestampFormatHeadersErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> TimestampFormatHeadersErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> TimestampFormatHeadersErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlAttributesError {
  XmlAttributesErrorTransport(reason: String)
  XmlAttributesErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_attributes_error(err: awsjson_client.ClientError) -> XmlAttributesError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlAttributesErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlAttributesErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlAttributesErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlAttributesErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlAttributesErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlAttributesInMiddleError {
  XmlAttributesInMiddleErrorTransport(reason: String)
  XmlAttributesInMiddleErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_attributes_in_middle_error(err: awsjson_client.ClientError) -> XmlAttributesInMiddleError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlAttributesInMiddleErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlAttributesInMiddleErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlAttributesInMiddleErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlAttributesInMiddleErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlAttributesInMiddleErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlAttributesOnPayloadError {
  XmlAttributesOnPayloadErrorTransport(reason: String)
  XmlAttributesOnPayloadErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_attributes_on_payload_error(err: awsjson_client.ClientError) -> XmlAttributesOnPayloadError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlAttributesOnPayloadErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlAttributesOnPayloadErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlAttributesOnPayloadErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlAttributesOnPayloadErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlAttributesOnPayloadErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlBlobsError {
  XmlBlobsErrorTransport(reason: String)
  XmlBlobsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_blobs_error(err: awsjson_client.ClientError) -> XmlBlobsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlBlobsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlBlobsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlBlobsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlBlobsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlBlobsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlEmptyBlobsError {
  XmlEmptyBlobsErrorTransport(reason: String)
  XmlEmptyBlobsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_empty_blobs_error(err: awsjson_client.ClientError) -> XmlEmptyBlobsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlEmptyBlobsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlEmptyBlobsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlEmptyBlobsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlEmptyBlobsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlEmptyBlobsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlEmptyListsError {
  XmlEmptyListsErrorTransport(reason: String)
  XmlEmptyListsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_empty_lists_error(err: awsjson_client.ClientError) -> XmlEmptyListsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlEmptyListsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlEmptyListsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlEmptyListsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlEmptyListsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlEmptyListsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlEmptyMapsError {
  XmlEmptyMapsErrorTransport(reason: String)
  XmlEmptyMapsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_empty_maps_error(err: awsjson_client.ClientError) -> XmlEmptyMapsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlEmptyMapsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlEmptyMapsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlEmptyMapsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlEmptyMapsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlEmptyMapsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlEmptyStringsError {
  XmlEmptyStringsErrorTransport(reason: String)
  XmlEmptyStringsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_empty_strings_error(err: awsjson_client.ClientError) -> XmlEmptyStringsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlEmptyStringsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlEmptyStringsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlEmptyStringsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlEmptyStringsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlEmptyStringsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlEnumsError {
  XmlEnumsErrorTransport(reason: String)
  XmlEnumsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_enums_error(err: awsjson_client.ClientError) -> XmlEnumsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlEnumsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlEnumsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlEnumsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlEnumsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlEnumsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlIntEnumsError {
  XmlIntEnumsErrorTransport(reason: String)
  XmlIntEnumsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_int_enums_error(err: awsjson_client.ClientError) -> XmlIntEnumsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlIntEnumsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlIntEnumsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlIntEnumsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlIntEnumsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlIntEnumsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlListsError {
  XmlListsErrorTransport(reason: String)
  XmlListsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_lists_error(err: awsjson_client.ClientError) -> XmlListsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlListsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlListsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlListsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlListsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlListsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlMapsError {
  XmlMapsErrorTransport(reason: String)
  XmlMapsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_maps_error(err: awsjson_client.ClientError) -> XmlMapsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlMapsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlMapsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlMapsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlMapsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlMapsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlMapsXmlNameError {
  XmlMapsXmlNameErrorTransport(reason: String)
  XmlMapsXmlNameErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_maps_xml_name_error(err: awsjson_client.ClientError) -> XmlMapsXmlNameError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlMapsXmlNameErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlMapsXmlNameErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlMapsXmlNameErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlMapsXmlNameErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlMapsXmlNameErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlMapWithXmlNamespaceError {
  XmlMapWithXmlNamespaceErrorTransport(reason: String)
  XmlMapWithXmlNamespaceErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_map_with_xml_namespace_error(err: awsjson_client.ClientError) -> XmlMapWithXmlNamespaceError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlMapWithXmlNamespaceErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlMapWithXmlNamespaceErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlMapWithXmlNamespaceErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlMapWithXmlNamespaceErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlMapWithXmlNamespaceErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlNamespacesError {
  XmlNamespacesErrorTransport(reason: String)
  XmlNamespacesErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_namespaces_error(err: awsjson_client.ClientError) -> XmlNamespacesError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlNamespacesErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlNamespacesErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlNamespacesErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlNamespacesErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlNamespacesErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlTimestampsError {
  XmlTimestampsErrorTransport(reason: String)
  XmlTimestampsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_timestamps_error(err: awsjson_client.ClientError) -> XmlTimestampsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlTimestampsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlTimestampsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlTimestampsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlTimestampsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlTimestampsErrorTransport(reason: "decode: " <> r)
  }
}

pub type XmlUnionsError {
  XmlUnionsErrorTransport(reason: String)
  XmlUnionsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_xml_unions_error(err: awsjson_client.ClientError) -> XmlUnionsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> XmlUnionsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> XmlUnionsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> XmlUnionsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> XmlUnionsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> XmlUnionsErrorTransport(reason: "decode: " <> r)
  }
}

pub fn all_query_string_types(client: Client, input: AllQueryStringTypesInput) -> Result(AllQueryStringTypesOutput, AllQueryStringTypesError) {
  case awsjson_client.invoke(client.config, build_all_query_string_types_request(input), parse_all_query_string_types_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_all_query_string_types_error(err))
  }
}

pub fn body_with_xml_name(client: Client, input: BodyWithXmlNameInputOutput) -> Result(BodyWithXmlNameInputOutput, BodyWithXmlNameError) {
  case awsjson_client.invoke(client.config, build_body_with_xml_name_request(input), parse_body_with_xml_name_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_body_with_xml_name_error(err))
  }
}

pub fn constant_and_variable_query_string(client: Client, input: ConstantAndVariableQueryStringInput) -> Result(ConstantAndVariableQueryStringOutput, ConstantAndVariableQueryStringError) {
  case awsjson_client.invoke(client.config, build_constant_and_variable_query_string_request(input), parse_constant_and_variable_query_string_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_constant_and_variable_query_string_error(err))
  }
}

pub fn constant_query_string(client: Client, input: ConstantQueryStringInput) -> Result(ConstantQueryStringOutput, ConstantQueryStringError) {
  case awsjson_client.invoke(client.config, build_constant_query_string_request(input), parse_constant_query_string_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_constant_query_string_error(err))
  }
}

pub fn content_type_parameters(client: Client, input: ContentTypeParametersInput) -> Result(ContentTypeParametersOutput, ContentTypeParametersError) {
  case awsjson_client.invoke(client.config, build_content_type_parameters_request(input), parse_content_type_parameters_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_content_type_parameters_error(err))
  }
}

pub fn datetime_offsets(client: Client, input: DatetimeOffsetsInput) -> Result(DatetimeOffsetsOutput, DatetimeOffsetsError) {
  case awsjson_client.invoke(client.config, build_datetime_offsets_request(input), parse_datetime_offsets_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_datetime_offsets_error(err))
  }
}

pub fn empty_input_and_empty_output(client: Client, input: EmptyInputAndEmptyOutputInput) -> Result(EmptyInputAndEmptyOutputOutput, EmptyInputAndEmptyOutputError) {
  case awsjson_client.invoke(client.config, build_empty_input_and_empty_output_request(input), parse_empty_input_and_empty_output_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_empty_input_and_empty_output_error(err))
  }
}

pub fn endpoint_operation(client: Client, input: EndpointOperationInput) -> Result(EndpointOperationOutput, EndpointOperationError) {
  case awsjson_client.invoke(client.config, build_endpoint_operation_request(input), parse_endpoint_operation_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_endpoint_operation_error(err))
  }
}

pub fn endpoint_with_host_label_header_operation(client: Client, input: HostLabelHeaderInput) -> Result(EndpointWithHostLabelHeaderOperationOutput, EndpointWithHostLabelHeaderOperationError) {
  case awsjson_client.invoke(client.config, build_endpoint_with_host_label_header_operation_request(input), parse_endpoint_with_host_label_header_operation_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_endpoint_with_host_label_header_operation_error(err))
  }
}

pub fn endpoint_with_host_label_operation(client: Client, input: EndpointWithHostLabelOperationRequest) -> Result(EndpointWithHostLabelOperationOutput, EndpointWithHostLabelOperationError) {
  case awsjson_client.invoke(client.config, build_endpoint_with_host_label_operation_request(input), parse_endpoint_with_host_label_operation_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_endpoint_with_host_label_operation_error(err))
  }
}

pub fn flattened_xml_map(client: Client, input: FlattenedXmlMapRequest) -> Result(FlattenedXmlMapResponse, FlattenedXmlMapError) {
  case awsjson_client.invoke(client.config, build_flattened_xml_map_request(input), parse_flattened_xml_map_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_flattened_xml_map_error(err))
  }
}

pub fn flattened_xml_map_with_xml_name(client: Client, input: FlattenedXmlMapWithXmlNameRequest) -> Result(FlattenedXmlMapWithXmlNameResponse, FlattenedXmlMapWithXmlNameError) {
  case awsjson_client.invoke(client.config, build_flattened_xml_map_with_xml_name_request(input), parse_flattened_xml_map_with_xml_name_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_flattened_xml_map_with_xml_name_error(err))
  }
}

pub fn flattened_xml_map_with_xml_namespace(client: Client, input: FlattenedXmlMapWithXmlNamespaceInput) -> Result(FlattenedXmlMapWithXmlNamespaceOutput, FlattenedXmlMapWithXmlNamespaceError) {
  case awsjson_client.invoke(client.config, build_flattened_xml_map_with_xml_namespace_request(input), parse_flattened_xml_map_with_xml_namespace_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_flattened_xml_map_with_xml_namespace_error(err))
  }
}

pub fn fractional_seconds(client: Client, input: FractionalSecondsInput) -> Result(FractionalSecondsOutput, FractionalSecondsError) {
  case awsjson_client.invoke(client.config, build_fractional_seconds_request(input), parse_fractional_seconds_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_fractional_seconds_error(err))
  }
}

pub fn greeting_with_errors(client: Client, input: GreetingWithErrorsInput) -> Result(GreetingWithErrorsOutput, GreetingWithErrorsError) {
  case awsjson_client.invoke(client.config, build_greeting_with_errors_request(input), parse_greeting_with_errors_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_greeting_with_errors_error(err))
  }
}

pub fn http_empty_prefix_headers(client: Client, input: HttpEmptyPrefixHeadersInput) -> Result(HttpEmptyPrefixHeadersOutput, HttpEmptyPrefixHeadersError) {
  case awsjson_client.invoke(client.config, build_http_empty_prefix_headers_request(input), parse_http_empty_prefix_headers_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_empty_prefix_headers_error(err))
  }
}

pub fn http_enum_payload(client: Client, input: EnumPayloadInput) -> Result(EnumPayloadInput, HttpEnumPayloadError) {
  case awsjson_client.invoke(client.config, build_http_enum_payload_request(input), parse_http_enum_payload_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_enum_payload_error(err))
  }
}

pub fn http_payload_traits(client: Client, input: HttpPayloadTraitsInputOutput) -> Result(HttpPayloadTraitsInputOutput, HttpPayloadTraitsError) {
  case awsjson_client.invoke(client.config, build_http_payload_traits_request(input), parse_http_payload_traits_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_traits_error(err))
  }
}

pub fn http_payload_traits_with_media_type(client: Client, input: HttpPayloadTraitsWithMediaTypeInputOutput) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, HttpPayloadTraitsWithMediaTypeError) {
  case awsjson_client.invoke(client.config, build_http_payload_traits_with_media_type_request(input), parse_http_payload_traits_with_media_type_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_traits_with_media_type_error(err))
  }
}

pub fn http_payload_with_member_xml_name(client: Client, input: HttpPayloadWithMemberXmlNameInputOutput) -> Result(HttpPayloadWithMemberXmlNameInputOutput, HttpPayloadWithMemberXmlNameError) {
  case awsjson_client.invoke(client.config, build_http_payload_with_member_xml_name_request(input), parse_http_payload_with_member_xml_name_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_with_member_xml_name_error(err))
  }
}

pub fn http_payload_with_structure(client: Client, input: HttpPayloadWithStructureInputOutput) -> Result(HttpPayloadWithStructureInputOutput, HttpPayloadWithStructureError) {
  case awsjson_client.invoke(client.config, build_http_payload_with_structure_request(input), parse_http_payload_with_structure_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_with_structure_error(err))
  }
}

pub fn http_payload_with_union(client: Client, input: HttpPayloadWithUnionInputOutput) -> Result(HttpPayloadWithUnionInputOutput, HttpPayloadWithUnionError) {
  case awsjson_client.invoke(client.config, build_http_payload_with_union_request(input), parse_http_payload_with_union_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_with_union_error(err))
  }
}

pub fn http_payload_with_xml_name(client: Client, input: HttpPayloadWithXmlNameInputOutput) -> Result(HttpPayloadWithXmlNameInputOutput, HttpPayloadWithXmlNameError) {
  case awsjson_client.invoke(client.config, build_http_payload_with_xml_name_request(input), parse_http_payload_with_xml_name_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_with_xml_name_error(err))
  }
}

pub fn http_payload_with_xml_namespace(client: Client, input: HttpPayloadWithXmlNamespaceInputOutput) -> Result(HttpPayloadWithXmlNamespaceInputOutput, HttpPayloadWithXmlNamespaceError) {
  case awsjson_client.invoke(client.config, build_http_payload_with_xml_namespace_request(input), parse_http_payload_with_xml_namespace_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_with_xml_namespace_error(err))
  }
}

pub fn http_payload_with_xml_namespace_and_prefix(client: Client, input: HttpPayloadWithXmlNamespaceAndPrefixInputOutput) -> Result(HttpPayloadWithXmlNamespaceAndPrefixInputOutput, HttpPayloadWithXmlNamespaceAndPrefixError) {
  case awsjson_client.invoke(client.config, build_http_payload_with_xml_namespace_and_prefix_request(input), parse_http_payload_with_xml_namespace_and_prefix_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_payload_with_xml_namespace_and_prefix_error(err))
  }
}

pub fn http_prefix_headers(client: Client, input: HttpPrefixHeadersInputOutput) -> Result(HttpPrefixHeadersInputOutput, HttpPrefixHeadersError) {
  case awsjson_client.invoke(client.config, build_http_prefix_headers_request(input), parse_http_prefix_headers_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_prefix_headers_error(err))
  }
}

pub fn http_request_with_float_labels(client: Client, input: HttpRequestWithFloatLabelsInput) -> Result(HttpRequestWithFloatLabelsOutput, HttpRequestWithFloatLabelsError) {
  case awsjson_client.invoke(client.config, build_http_request_with_float_labels_request(input), parse_http_request_with_float_labels_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_request_with_float_labels_error(err))
  }
}

pub fn http_request_with_greedy_label_in_path(client: Client, input: HttpRequestWithGreedyLabelInPathInput) -> Result(HttpRequestWithGreedyLabelInPathOutput, HttpRequestWithGreedyLabelInPathError) {
  case awsjson_client.invoke(client.config, build_http_request_with_greedy_label_in_path_request(input), parse_http_request_with_greedy_label_in_path_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_request_with_greedy_label_in_path_error(err))
  }
}

pub fn http_request_with_labels(client: Client, input: HttpRequestWithLabelsInput) -> Result(HttpRequestWithLabelsOutput, HttpRequestWithLabelsError) {
  case awsjson_client.invoke(client.config, build_http_request_with_labels_request(input), parse_http_request_with_labels_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_request_with_labels_error(err))
  }
}

pub fn http_request_with_labels_and_timestamp_format(client: Client, input: HttpRequestWithLabelsAndTimestampFormatInput) -> Result(HttpRequestWithLabelsAndTimestampFormatOutput, HttpRequestWithLabelsAndTimestampFormatError) {
  case awsjson_client.invoke(client.config, build_http_request_with_labels_and_timestamp_format_request(input), parse_http_request_with_labels_and_timestamp_format_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_request_with_labels_and_timestamp_format_error(err))
  }
}

pub fn http_response_code(client: Client, input: HttpResponseCodeInput) -> Result(HttpResponseCodeOutput, HttpResponseCodeError) {
  case awsjson_client.invoke(client.config, build_http_response_code_request(input), parse_http_response_code_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_response_code_error(err))
  }
}

pub fn http_string_payload(client: Client, input: StringPayloadInput) -> Result(StringPayloadInput, HttpStringPayloadError) {
  case awsjson_client.invoke(client.config, build_http_string_payload_request(input), parse_http_string_payload_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_http_string_payload_error(err))
  }
}

pub fn ignore_query_params_in_response(client: Client, input: IgnoreQueryParamsInResponseInput) -> Result(IgnoreQueryParamsInResponseOutput, IgnoreQueryParamsInResponseError) {
  case awsjson_client.invoke(client.config, build_ignore_query_params_in_response_request(input), parse_ignore_query_params_in_response_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_ignore_query_params_in_response_error(err))
  }
}

pub fn input_and_output_with_headers(client: Client, input: InputAndOutputWithHeadersIO) -> Result(InputAndOutputWithHeadersIO, InputAndOutputWithHeadersError) {
  case awsjson_client.invoke(client.config, build_input_and_output_with_headers_request(input), parse_input_and_output_with_headers_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_input_and_output_with_headers_error(err))
  }
}

pub fn nested_xml_maps(client: Client, input: NestedXmlMapsRequest) -> Result(NestedXmlMapsResponse, NestedXmlMapsError) {
  case awsjson_client.invoke(client.config, build_nested_xml_maps_request(input), parse_nested_xml_maps_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_nested_xml_maps_error(err))
  }
}

pub fn nested_xml_map_with_xml_name(client: Client, input: NestedXmlMapWithXmlNameRequest) -> Result(NestedXmlMapWithXmlNameResponse, NestedXmlMapWithXmlNameError) {
  case awsjson_client.invoke(client.config, build_nested_xml_map_with_xml_name_request(input), parse_nested_xml_map_with_xml_name_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_nested_xml_map_with_xml_name_error(err))
  }
}

pub fn no_input_and_no_output(client: Client, input: NoInputAndNoOutputInput) -> Result(NoInputAndNoOutputOutput, NoInputAndNoOutputError) {
  case awsjson_client.invoke(client.config, build_no_input_and_no_output_request(input), parse_no_input_and_no_output_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_no_input_and_no_output_error(err))
  }
}

pub fn no_input_and_output(client: Client, input: NoInputAndOutputInput) -> Result(NoInputAndOutputOutput, NoInputAndOutputError) {
  case awsjson_client.invoke(client.config, build_no_input_and_output_request(input), parse_no_input_and_output_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_no_input_and_output_error(err))
  }
}

pub fn null_and_empty_headers_client(client: Client, input: NullAndEmptyHeadersIO) -> Result(NullAndEmptyHeadersIO, NullAndEmptyHeadersClientError) {
  case awsjson_client.invoke(client.config, build_null_and_empty_headers_client_request(input), parse_null_and_empty_headers_client_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_null_and_empty_headers_client_error(err))
  }
}

pub fn null_and_empty_headers_server(client: Client, input: NullAndEmptyHeadersIO) -> Result(NullAndEmptyHeadersIO, NullAndEmptyHeadersServerError) {
  case awsjson_client.invoke(client.config, build_null_and_empty_headers_server_request(input), parse_null_and_empty_headers_server_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_null_and_empty_headers_server_error(err))
  }
}

pub fn omits_null_serializes_empty_string(client: Client, input: OmitsNullSerializesEmptyStringInput) -> Result(OmitsNullSerializesEmptyStringOutput, OmitsNullSerializesEmptyStringError) {
  case awsjson_client.invoke(client.config, build_omits_null_serializes_empty_string_request(input), parse_omits_null_serializes_empty_string_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_omits_null_serializes_empty_string_error(err))
  }
}

pub fn put_with_content_encoding(client: Client, input: PutWithContentEncodingInput) -> Result(PutWithContentEncodingOutput, PutWithContentEncodingError) {
  case awsjson_client.invoke(client.config, build_put_with_content_encoding_request(input), parse_put_with_content_encoding_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_put_with_content_encoding_error(err))
  }
}

pub fn query_idempotency_token_auto_fill(client: Client, input: QueryIdempotencyTokenAutoFillInput) -> Result(QueryIdempotencyTokenAutoFillOutput, QueryIdempotencyTokenAutoFillError) {
  case awsjson_client.invoke(client.config, build_query_idempotency_token_auto_fill_request(input), parse_query_idempotency_token_auto_fill_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_query_idempotency_token_auto_fill_error(err))
  }
}

pub fn query_params_as_string_list_map(client: Client, input: QueryParamsAsStringListMapInput) -> Result(QueryParamsAsStringListMapOutput, QueryParamsAsStringListMapError) {
  case awsjson_client.invoke(client.config, build_query_params_as_string_list_map_request(input), parse_query_params_as_string_list_map_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_query_params_as_string_list_map_error(err))
  }
}

pub fn query_precedence(client: Client, input: QueryPrecedenceInput) -> Result(QueryPrecedenceOutput, QueryPrecedenceError) {
  case awsjson_client.invoke(client.config, build_query_precedence_request(input), parse_query_precedence_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_query_precedence_error(err))
  }
}

pub fn recursive_shapes(client: Client, input: RecursiveShapesRequest) -> Result(RecursiveShapesResponse, RecursiveShapesError) {
  case awsjson_client.invoke(client.config, build_recursive_shapes_request(input), parse_recursive_shapes_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_recursive_shapes_error(err))
  }
}

pub fn simple_scalar_properties(client: Client, input: SimpleScalarPropertiesRequest) -> Result(SimpleScalarPropertiesResponse, SimpleScalarPropertiesError) {
  case awsjson_client.invoke(client.config, build_simple_scalar_properties_request(input), parse_simple_scalar_properties_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_simple_scalar_properties_error(err))
  }
}

pub fn timestamp_format_headers(client: Client, input: TimestampFormatHeadersIO) -> Result(TimestampFormatHeadersIO, TimestampFormatHeadersError) {
  case awsjson_client.invoke(client.config, build_timestamp_format_headers_request(input), parse_timestamp_format_headers_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_timestamp_format_headers_error(err))
  }
}

pub fn xml_attributes(client: Client, input: XmlAttributesRequest) -> Result(XmlAttributesResponse, XmlAttributesError) {
  case awsjson_client.invoke(client.config, build_xml_attributes_request(input), parse_xml_attributes_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_attributes_error(err))
  }
}

pub fn xml_attributes_in_middle(client: Client, input: XmlAttributesInMiddleRequest) -> Result(XmlAttributesInMiddleResponse, XmlAttributesInMiddleError) {
  case awsjson_client.invoke(client.config, build_xml_attributes_in_middle_request(input), parse_xml_attributes_in_middle_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_attributes_in_middle_error(err))
  }
}

pub fn xml_attributes_on_payload(client: Client, input: XmlAttributesOnPayloadRequest) -> Result(XmlAttributesOnPayloadResponse, XmlAttributesOnPayloadError) {
  case awsjson_client.invoke(client.config, build_xml_attributes_on_payload_request(input), parse_xml_attributes_on_payload_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_attributes_on_payload_error(err))
  }
}

pub fn xml_blobs(client: Client, input: XmlBlobsRequest) -> Result(XmlBlobsResponse, XmlBlobsError) {
  case awsjson_client.invoke(client.config, build_xml_blobs_request(input), parse_xml_blobs_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_blobs_error(err))
  }
}

pub fn xml_empty_blobs(client: Client, input: XmlEmptyBlobsRequest) -> Result(XmlEmptyBlobsResponse, XmlEmptyBlobsError) {
  case awsjson_client.invoke(client.config, build_xml_empty_blobs_request(input), parse_xml_empty_blobs_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_empty_blobs_error(err))
  }
}

pub fn xml_empty_lists(client: Client, input: XmlEmptyListsRequest) -> Result(XmlEmptyListsResponse, XmlEmptyListsError) {
  case awsjson_client.invoke(client.config, build_xml_empty_lists_request(input), parse_xml_empty_lists_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_empty_lists_error(err))
  }
}

pub fn xml_empty_maps(client: Client, input: XmlEmptyMapsRequest) -> Result(XmlEmptyMapsResponse, XmlEmptyMapsError) {
  case awsjson_client.invoke(client.config, build_xml_empty_maps_request(input), parse_xml_empty_maps_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_empty_maps_error(err))
  }
}

pub fn xml_empty_strings(client: Client, input: XmlEmptyStringsRequest) -> Result(XmlEmptyStringsResponse, XmlEmptyStringsError) {
  case awsjson_client.invoke(client.config, build_xml_empty_strings_request(input), parse_xml_empty_strings_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_empty_strings_error(err))
  }
}

pub fn xml_enums(client: Client, input: XmlEnumsRequest) -> Result(XmlEnumsResponse, XmlEnumsError) {
  case awsjson_client.invoke(client.config, build_xml_enums_request(input), parse_xml_enums_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_enums_error(err))
  }
}

pub fn xml_int_enums(client: Client, input: XmlIntEnumsRequest) -> Result(XmlIntEnumsResponse, XmlIntEnumsError) {
  case awsjson_client.invoke(client.config, build_xml_int_enums_request(input), parse_xml_int_enums_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_int_enums_error(err))
  }
}

pub fn xml_lists(client: Client, input: XmlListsRequest) -> Result(XmlListsResponse, XmlListsError) {
  case awsjson_client.invoke(client.config, build_xml_lists_request(input), parse_xml_lists_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_lists_error(err))
  }
}

pub fn xml_maps(client: Client, input: XmlMapsRequest) -> Result(XmlMapsResponse, XmlMapsError) {
  case awsjson_client.invoke(client.config, build_xml_maps_request(input), parse_xml_maps_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_maps_error(err))
  }
}

pub fn xml_maps_xml_name(client: Client, input: XmlMapsXmlNameRequest) -> Result(XmlMapsXmlNameResponse, XmlMapsXmlNameError) {
  case awsjson_client.invoke(client.config, build_xml_maps_xml_name_request(input), parse_xml_maps_xml_name_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_maps_xml_name_error(err))
  }
}

pub fn xml_map_with_xml_namespace(client: Client, input: XmlMapWithXmlNamespaceRequest) -> Result(XmlMapWithXmlNamespaceResponse, XmlMapWithXmlNamespaceError) {
  case awsjson_client.invoke(client.config, build_xml_map_with_xml_namespace_request(input), parse_xml_map_with_xml_namespace_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_map_with_xml_namespace_error(err))
  }
}

pub fn xml_namespaces(client: Client, input: XmlNamespacesRequest) -> Result(XmlNamespacesResponse, XmlNamespacesError) {
  case awsjson_client.invoke(client.config, build_xml_namespaces_request(input), parse_xml_namespaces_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_namespaces_error(err))
  }
}

pub fn xml_timestamps(client: Client, input: XmlTimestampsRequest) -> Result(XmlTimestampsResponse, XmlTimestampsError) {
  case awsjson_client.invoke(client.config, build_xml_timestamps_request(input), parse_xml_timestamps_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_timestamps_error(err))
  }
}

pub fn xml_unions(client: Client, input: XmlUnionsRequest) -> Result(XmlUnionsResponse, XmlUnionsError) {
  case awsjson_client.invoke(client.config, build_xml_unions_request(input), parse_xml_unions_response) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_xml_unions_error(err))
  }
}

