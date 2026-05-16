//// Generated from aws.protocoltests.json10#JsonRpc10 (awsJson1_0).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/credentials
import aws/internal/client/awsjson as awsjson_client
import aws/internal/codec/json_document
import aws/internal/codec/json_float
import aws/internal/codec/json_timestamp
import aws/internal/http_send
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option

pub opaque type Client {
  Client(config: awsjson_client.ClientConfig)
}

/// Build a Client for an AWS region. Credentials resolve through
/// the default chain (env → web-identity → SSO → profile → process
/// → ECS → IMDS); use `with_credentials_provider` to override.
pub fn new(region region: String) -> Client {
  Client(awsjson_client.default_config(region, "jsonrpc10", "jsonrpc10"))
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

pub type ContentTypeParametersInput {
  ContentTypeParametersInput(
    value: option.Option(Int),
  )
}

pub fn encode_content_type_parameters_input_struct(input: ContentTypeParametersInput) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("value", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_content_type_parameters_input_struct_top(input: ContentTypeParametersInput) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("value", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_content_type_parameters_input_struct() -> decode.Decoder(ContentTypeParametersInput) {
  use value <- decode.optional_field("value", option.None, decode.optional(decode.int))
  decode.success(ContentTypeParametersInput(
    value: value,
  ))
}

pub fn decode_content_type_parameters_input_struct_params() -> decode.Decoder(ContentTypeParametersInput) {
  use value <- decode.optional_field("value", option.None, decode.optional(decode.int))
  decode.success(ContentTypeParametersInput(
    value: value,
  ))
}

pub type ContentTypeParametersOutput {
  ContentTypeParametersOutput
}

pub fn encode_content_type_parameters_output_struct(_v: ContentTypeParametersOutput) -> json.Json {
  json.object([])
}

pub fn encode_content_type_parameters_output_struct_top(_v: ContentTypeParametersOutput) -> json.Json {
  json.object([])
}

pub fn decode_content_type_parameters_output_struct() -> decode.Decoder(ContentTypeParametersOutput) {
  decode.success(ContentTypeParametersOutput)
}

pub fn decode_content_type_parameters_output_struct_params() -> decode.Decoder(ContentTypeParametersOutput) {
  decode.success(ContentTypeParametersOutput)
}

pub type EmptyInputAndEmptyOutputInput {
  EmptyInputAndEmptyOutputInput
}

pub fn encode_empty_input_and_empty_output_input_struct(_v: EmptyInputAndEmptyOutputInput) -> json.Json {
  json.object([])
}

pub fn encode_empty_input_and_empty_output_input_struct_top(_v: EmptyInputAndEmptyOutputInput) -> json.Json {
  json.object([])
}

pub fn decode_empty_input_and_empty_output_input_struct() -> decode.Decoder(EmptyInputAndEmptyOutputInput) {
  decode.success(EmptyInputAndEmptyOutputInput)
}

pub fn decode_empty_input_and_empty_output_input_struct_params() -> decode.Decoder(EmptyInputAndEmptyOutputInput) {
  decode.success(EmptyInputAndEmptyOutputInput)
}

pub type EmptyInputAndEmptyOutputOutput {
  EmptyInputAndEmptyOutputOutput
}

pub fn encode_empty_input_and_empty_output_output_struct(_v: EmptyInputAndEmptyOutputOutput) -> json.Json {
  json.object([])
}

pub fn encode_empty_input_and_empty_output_output_struct_top(_v: EmptyInputAndEmptyOutputOutput) -> json.Json {
  json.object([])
}

pub fn decode_empty_input_and_empty_output_output_struct() -> decode.Decoder(EmptyInputAndEmptyOutputOutput) {
  decode.success(EmptyInputAndEmptyOutputOutput)
}

pub fn decode_empty_input_and_empty_output_output_struct_params() -> decode.Decoder(EmptyInputAndEmptyOutputOutput) {
  decode.success(EmptyInputAndEmptyOutputOutput)
}

pub type EndpointWithHostLabelOperationInput {
  EndpointWithHostLabelOperationInput(
    label: option.Option(String),
  )
}

pub fn encode_endpoint_with_host_label_operation_input_struct(input: EndpointWithHostLabelOperationInput) -> json.Json {
  let pairs = []
  let pairs = case input.label {
    option.Some(v) -> [#("label", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_endpoint_with_host_label_operation_input_struct_top(input: EndpointWithHostLabelOperationInput) -> json.Json {
  let pairs = []
  let pairs = case input.label {
    option.Some(v) -> [#("label", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_endpoint_with_host_label_operation_input_struct() -> decode.Decoder(EndpointWithHostLabelOperationInput) {
  use label <- decode.optional_field("label", option.None, decode.optional(decode.string))
  decode.success(EndpointWithHostLabelOperationInput(
    label: label,
  ))
}

pub fn decode_endpoint_with_host_label_operation_input_struct_params() -> decode.Decoder(EndpointWithHostLabelOperationInput) {
  use label <- decode.optional_field("label", option.None, decode.optional(decode.string))
  decode.success(EndpointWithHostLabelOperationInput(
    label: label,
  ))
}

pub type GreetingWithErrorsInput {
  GreetingWithErrorsInput(
    greeting: option.Option(String),
  )
}

pub fn encode_greeting_with_errors_input_struct(input: GreetingWithErrorsInput) -> json.Json {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_greeting_with_errors_input_struct_top(input: GreetingWithErrorsInput) -> json.Json {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_greeting_with_errors_input_struct() -> decode.Decoder(GreetingWithErrorsInput) {
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  decode.success(GreetingWithErrorsInput(
    greeting: greeting,
  ))
}

pub fn decode_greeting_with_errors_input_struct_params() -> decode.Decoder(GreetingWithErrorsInput) {
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  decode.success(GreetingWithErrorsInput(
    greeting: greeting,
  ))
}

pub type GreetingWithErrorsOutput {
  GreetingWithErrorsOutput(
    greeting: option.Option(String),
  )
}

pub fn encode_greeting_with_errors_output_struct(input: GreetingWithErrorsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_greeting_with_errors_output_struct_top(input: GreetingWithErrorsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_greeting_with_errors_output_struct() -> decode.Decoder(GreetingWithErrorsOutput) {
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  decode.success(GreetingWithErrorsOutput(
    greeting: greeting,
  ))
}

pub fn decode_greeting_with_errors_output_struct_params() -> decode.Decoder(GreetingWithErrorsOutput) {
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  decode.success(GreetingWithErrorsOutput(
    greeting: greeting,
  ))
}

pub type ComplexError {
  ComplexError(
    nested: option.Option(ComplexNestedErrorData),
    top_level: option.Option(String),
  )
}

pub fn encode_complex_error_struct(input: ComplexError) -> json.Json {
  let pairs = []
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

pub fn encode_complex_error_struct_top(input: ComplexError) -> json.Json {
  let pairs = []
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
  use nested <- decode.optional_field("Nested", option.None, decode.optional(decode_complex_nested_error_data_struct()))
  use top_level <- decode.optional_field("TopLevel", option.None, decode.optional(decode.string))
  decode.success(ComplexError(
    nested: nested,
    top_level: top_level,
  ))
}

pub fn decode_complex_error_struct_params() -> decode.Decoder(ComplexError) {
  use nested <- decode.optional_field("Nested", option.None, decode.optional(decode_complex_nested_error_data_struct_params()))
  use top_level <- decode.optional_field("TopLevel", option.None, decode.optional(decode.string))
  decode.success(ComplexError(
    nested: nested,
    top_level: top_level,
  ))
}

pub type ComplexNestedErrorData {
  ComplexNestedErrorData(
    foo: option.Option(String),
  )
}

pub fn encode_complex_nested_error_data_struct(input: ComplexNestedErrorData) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("Foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_complex_nested_error_data_struct_top(input: ComplexNestedErrorData) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("Foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_complex_nested_error_data_struct() -> decode.Decoder(ComplexNestedErrorData) {
  use foo <- decode.optional_field("Foo", option.None, decode.optional(decode.string))
  decode.success(ComplexNestedErrorData(
    foo: foo,
  ))
}

pub fn decode_complex_nested_error_data_struct_params() -> decode.Decoder(ComplexNestedErrorData) {
  use foo <- decode.optional_field("Foo", option.None, decode.optional(decode.string))
  decode.success(ComplexNestedErrorData(
    foo: foo,
  ))
}

pub type FooError {
  FooError
}

pub fn encode_foo_error_struct(_v: FooError) -> json.Json {
  json.object([])
}

pub fn encode_foo_error_struct_top(_v: FooError) -> json.Json {
  json.object([])
}

pub fn decode_foo_error_struct() -> decode.Decoder(FooError) {
  decode.success(FooError)
}

pub fn decode_foo_error_struct_params() -> decode.Decoder(FooError) {
  decode.success(FooError)
}

pub type InvalidGreeting {
  InvalidGreeting(
    message: option.Option(String),
  )
}

pub fn encode_invalid_greeting_struct(input: InvalidGreeting) -> json.Json {
  let pairs = []
  let pairs = case input.message {
    option.Some(v) -> [#("Message", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_invalid_greeting_struct_top(input: InvalidGreeting) -> json.Json {
  let pairs = []
  let pairs = case input.message {
    option.Some(v) -> [#("Message", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_invalid_greeting_struct() -> decode.Decoder(InvalidGreeting) {
  use message <- decode.optional_field("Message", option.None, decode.optional(decode.string))
  decode.success(InvalidGreeting(
    message: message,
  ))
}

pub fn decode_invalid_greeting_struct_params() -> decode.Decoder(InvalidGreeting) {
  use message <- decode.optional_field("Message", option.None, decode.optional(decode.string))
  decode.success(InvalidGreeting(
    message: message,
  ))
}

pub type JsonUnionsInput {
  JsonUnionsInput(
    contents: option.Option(MyUnion),
  )
}

pub fn encode_json_unions_input_struct(input: JsonUnionsInput) -> json.Json {
  let pairs = []
  let pairs = case input.contents {
    option.Some(v) -> [#("contents", encode_my_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_json_unions_input_struct_top(input: JsonUnionsInput) -> json.Json {
  let pairs = []
  let pairs = case input.contents {
    option.Some(v) -> [#("contents", encode_my_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_unions_input_struct() -> decode.Decoder(JsonUnionsInput) {
  use contents <- decode.optional_field("contents", option.None, decode.optional(decode_my_union_union()))
  decode.success(JsonUnionsInput(
    contents: contents,
  ))
}

pub fn decode_json_unions_input_struct_params() -> decode.Decoder(JsonUnionsInput) {
  use contents <- decode.optional_field("contents", option.None, decode.optional(decode_my_union_union_params()))
  decode.success(JsonUnionsInput(
    contents: contents,
  ))
}

pub type MyUnion {
  MyUnionBlobValue(BitArray)
  MyUnionBooleanValue(Bool)
  MyUnionEnumValue(FooEnum)
  MyUnionIntEnumValue(IntegerEnum)
  MyUnionListValue(List(String))
  MyUnionMapValue(dict.Dict(String, String))
  MyUnionNumberValue(Int)
  MyUnionStringValue(String)
  MyUnionStructureValue(GreetingStruct)
  MyUnionTimestampValue(Int)
}

pub fn encode_my_union_union(v: MyUnion) -> json.Json {
  case v {
    MyUnionBlobValue(x) -> json.object([#("blobValue", fn(b) { json.string(bit_array.base64_encode(b, True)) }(x))])
    MyUnionBooleanValue(x) -> json.object([#("booleanValue", json.bool(x))])
    MyUnionEnumValue(x) -> json.object([#("enumValue", encode_foo_enum_enum(x))])
    MyUnionIntEnumValue(x) -> json.object([#("intEnumValue", encode_integer_enum_int_enum(x))])
    MyUnionListValue(x) -> json.object([#("listValue", fn(xs) { json.array(xs, json.string) }(x))])
    MyUnionMapValue(x) -> json.object([#("mapValue", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(x))])
    MyUnionNumberValue(x) -> json.object([#("numberValue", json.int(x))])
    MyUnionStringValue(x) -> json.object([#("stringValue", json.string(x))])
    MyUnionStructureValue(x) -> json.object([#("structureValue", encode_greeting_struct_struct(x))])
    MyUnionTimestampValue(x) -> json.object([#("timestampValue", json.int(x))])
  }
}

pub fn decode_my_union_union() -> decode.Decoder(MyUnion) {
  decode.one_of(
    decode.field("blobValue", decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) }), fn(x) { decode.success(MyUnionBlobValue(x)) }),
    [
      decode.field("booleanValue", decode.bool, fn(x) { decode.success(MyUnionBooleanValue(x)) }),
      decode.field("enumValue", decode_foo_enum_enum(), fn(x) { decode.success(MyUnionEnumValue(x)) }),
      decode.field("intEnumValue", decode_integer_enum_int_enum(), fn(x) { decode.success(MyUnionIntEnumValue(x)) }),
      decode.field("listValue", decode.list(decode.string), fn(x) { decode.success(MyUnionListValue(x)) }),
      decode.field("mapValue", decode.dict(decode.string, decode.string), fn(x) { decode.success(MyUnionMapValue(x)) }),
      decode.field("numberValue", decode.int, fn(x) { decode.success(MyUnionNumberValue(x)) }),
      decode.field("stringValue", decode.string, fn(x) { decode.success(MyUnionStringValue(x)) }),
      decode.field("structureValue", decode_greeting_struct_struct(), fn(x) { decode.success(MyUnionStructureValue(x)) }),
      decode.field("timestampValue", json_timestamp.decoder(), fn(x) { decode.success(MyUnionTimestampValue(x)) }),
    ],
  )
}

pub fn decode_my_union_union_params() -> decode.Decoder(MyUnion) {
  decode.one_of(
    decode.field("blobValue", decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) }), fn(x) { decode.success(MyUnionBlobValue(x)) }),
    [
      decode.field("booleanValue", decode.bool, fn(x) { decode.success(MyUnionBooleanValue(x)) }),
      decode.field("enumValue", decode_foo_enum_enum(), fn(x) { decode.success(MyUnionEnumValue(x)) }),
      decode.field("intEnumValue", decode_integer_enum_int_enum(), fn(x) { decode.success(MyUnionIntEnumValue(x)) }),
      decode.field("listValue", decode.list(decode.string), fn(x) { decode.success(MyUnionListValue(x)) }),
      decode.field("mapValue", decode.dict(decode.string, decode.string), fn(x) { decode.success(MyUnionMapValue(x)) }),
      decode.field("numberValue", decode.int, fn(x) { decode.success(MyUnionNumberValue(x)) }),
      decode.field("stringValue", decode.string, fn(x) { decode.success(MyUnionStringValue(x)) }),
      decode.field("structureValue", decode_greeting_struct_struct_params(), fn(x) { decode.success(MyUnionStructureValue(x)) }),
      decode.field("timestampValue", json_timestamp.decoder(), fn(x) { decode.success(MyUnionTimestampValue(x)) }),
    ],
  )
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

pub type GreetingStruct {
  GreetingStruct(
    hi: option.Option(String),
  )
}

pub fn encode_greeting_struct_struct(input: GreetingStruct) -> json.Json {
  let pairs = []
  let pairs = case input.hi {
    option.Some(v) -> [#("hi", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_greeting_struct_struct_top(input: GreetingStruct) -> json.Json {
  let pairs = []
  let pairs = case input.hi {
    option.Some(v) -> [#("hi", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_greeting_struct_struct() -> decode.Decoder(GreetingStruct) {
  use hi <- decode.optional_field("hi", option.None, decode.optional(decode.string))
  decode.success(GreetingStruct(
    hi: hi,
  ))
}

pub fn decode_greeting_struct_struct_params() -> decode.Decoder(GreetingStruct) {
  use hi <- decode.optional_field("hi", option.None, decode.optional(decode.string))
  decode.success(GreetingStruct(
    hi: hi,
  ))
}

pub type JsonUnionsOutput {
  JsonUnionsOutput(
    contents: option.Option(MyUnion),
  )
}

pub fn encode_json_unions_output_struct(input: JsonUnionsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.contents {
    option.Some(v) -> [#("contents", encode_my_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_json_unions_output_struct_top(input: JsonUnionsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.contents {
    option.Some(v) -> [#("contents", encode_my_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_unions_output_struct() -> decode.Decoder(JsonUnionsOutput) {
  use contents <- decode.optional_field("contents", option.None, decode.optional(decode_my_union_union()))
  decode.success(JsonUnionsOutput(
    contents: contents,
  ))
}

pub fn decode_json_unions_output_struct_params() -> decode.Decoder(JsonUnionsOutput) {
  use contents <- decode.optional_field("contents", option.None, decode.optional(decode_my_union_union_params()))
  decode.success(JsonUnionsOutput(
    contents: contents,
  ))
}

pub type NoInputAndOutputOutput {
  NoInputAndOutputOutput
}

pub fn encode_no_input_and_output_output_struct(_v: NoInputAndOutputOutput) -> json.Json {
  json.object([])
}

pub fn encode_no_input_and_output_output_struct_top(_v: NoInputAndOutputOutput) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_output_output_struct() -> decode.Decoder(NoInputAndOutputOutput) {
  decode.success(NoInputAndOutputOutput)
}

pub fn decode_no_input_and_output_output_struct_params() -> decode.Decoder(NoInputAndOutputOutput) {
  decode.success(NoInputAndOutputOutput)
}

pub type OperationWithDefaultsInput {
  OperationWithDefaultsInput(
    client_optional_defaults: option.Option(ClientOptionalDefaults),
    defaults: option.Option(Defaults),
    other_top_level_default: option.Option(Int),
    top_level_default: option.Option(String),
  )
}

pub fn encode_operation_with_defaults_input_struct(input: OperationWithDefaultsInput) -> json.Json {
  let pairs = []
  let pairs = case input.client_optional_defaults {
    option.Some(v) -> [#("clientOptionalDefaults", encode_client_optional_defaults_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.defaults {
    option.Some(v) -> [#("defaults", encode_defaults_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.other_top_level_default {
    option.Some(v) -> [#("otherTopLevelDefault", json.int(v)), ..pairs]
    option.None -> [#("otherTopLevelDefault", json.int(0)), ..pairs]
  }
  let pairs = case input.top_level_default {
    option.Some(v) -> [#("topLevelDefault", json.string(v)), ..pairs]
    option.None -> [#("topLevelDefault", json.string("hi")), ..pairs]
  }
  json.object(pairs)
}

pub fn encode_operation_with_defaults_input_struct_top(input: OperationWithDefaultsInput) -> json.Json {
  let pairs = []
  let pairs = case input.client_optional_defaults {
    option.Some(v) -> [#("clientOptionalDefaults", encode_client_optional_defaults_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.defaults {
    option.Some(v) -> [#("defaults", encode_defaults_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.other_top_level_default {
    option.Some(v) -> [#("otherTopLevelDefault", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.top_level_default {
    option.Some(v) -> [#("topLevelDefault", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_defaults_input_struct() -> decode.Decoder(OperationWithDefaultsInput) {
  use client_optional_defaults <- decode.optional_field("clientOptionalDefaults", option.None, decode.optional(decode_client_optional_defaults_struct()))
  use defaults <- decode.optional_field("defaults", option.None, decode.optional(decode_defaults_struct()))
  use other_top_level_default <- decode.optional_field("otherTopLevelDefault", option.None, decode.optional(decode.int))
  use top_level_default <- decode.optional_field("topLevelDefault", option.None, decode.optional(decode.string))
  decode.success(OperationWithDefaultsInput(
    client_optional_defaults: client_optional_defaults,
    defaults: defaults,
    other_top_level_default: other_top_level_default,
    top_level_default: top_level_default,
  ))
}

pub fn decode_operation_with_defaults_input_struct_params() -> decode.Decoder(OperationWithDefaultsInput) {
  use client_optional_defaults <- decode.optional_field("clientOptionalDefaults", option.None, decode.optional(decode_client_optional_defaults_struct_params()))
  use defaults <- decode.optional_field("defaults", option.None, decode.optional(decode_defaults_struct_params()))
  use other_top_level_default <- decode.optional_field("otherTopLevelDefault", option.None, decode.optional(decode.int))
  use top_level_default <- decode.optional_field("topLevelDefault", option.None, decode.optional(decode.string))
  decode.success(OperationWithDefaultsInput(
    client_optional_defaults: client_optional_defaults,
    defaults: defaults,
    other_top_level_default: other_top_level_default,
    top_level_default: top_level_default,
  ))
}

pub type ClientOptionalDefaults {
  ClientOptionalDefaults(
    member: option.Option(Int),
  )
}

pub fn encode_client_optional_defaults_struct(input: ClientOptionalDefaults) -> json.Json {
  let pairs = []
  let pairs = case input.member {
    option.Some(v) -> [#("member", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_client_optional_defaults_struct_top(input: ClientOptionalDefaults) -> json.Json {
  let pairs = []
  let pairs = case input.member {
    option.Some(v) -> [#("member", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_client_optional_defaults_struct() -> decode.Decoder(ClientOptionalDefaults) {
  use member <- decode.optional_field("member", option.None, decode.optional(decode.int))
  decode.success(ClientOptionalDefaults(
    member: member,
  ))
}

pub fn decode_client_optional_defaults_struct_params() -> decode.Decoder(ClientOptionalDefaults) {
  use member <- decode.optional_field("member", option.None, decode.optional(decode.int))
  decode.success(ClientOptionalDefaults(
    member: member,
  ))
}

pub type Defaults {
  Defaults(
    default_blob: option.Option(BitArray),
    default_boolean: option.Option(Bool),
    default_byte: option.Option(Int),
    default_document_boolean: option.Option(json.Json),
    default_document_list: option.Option(json.Json),
    default_document_map: option.Option(json.Json),
    default_document_string: option.Option(json.Json),
    default_double: option.Option(json_float.SmithyFloat),
    default_enum: option.Option(TestEnum),
    default_float: option.Option(json_float.SmithyFloat),
    default_int_enum: option.Option(TestIntEnum),
    default_integer: option.Option(Int),
    default_list: option.Option(List(String)),
    default_long: option.Option(Int),
    default_map: option.Option(dict.Dict(String, String)),
    default_null_document: option.Option(json.Json),
    default_short: option.Option(Int),
    default_string: option.Option(String),
    default_timestamp: option.Option(Int),
    empty_blob: option.Option(BitArray),
    empty_string: option.Option(String),
    false_boolean: option.Option(Bool),
    zero_byte: option.Option(Int),
    zero_double: option.Option(json_float.SmithyFloat),
    zero_float: option.Option(json_float.SmithyFloat),
    zero_integer: option.Option(Int),
    zero_long: option.Option(Int),
    zero_short: option.Option(Int),
  )
}

pub fn encode_defaults_struct(input: Defaults) -> json.Json {
  let pairs = []
  let pairs = case input.default_blob {
    option.Some(v) -> [#("defaultBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> [#("defaultBlob", json.string("YWJj")), ..pairs]
  }
  let pairs = case input.default_boolean {
    option.Some(v) -> [#("defaultBoolean", json.bool(v)), ..pairs]
    option.None -> [#("defaultBoolean", json.bool(True)), ..pairs]
  }
  let pairs = case input.default_byte {
    option.Some(v) -> [#("defaultByte", json.int(v)), ..pairs]
    option.None -> [#("defaultByte", json.int(1)), ..pairs]
  }
  let pairs = case input.default_document_boolean {
    option.Some(v) -> [#("defaultDocumentBoolean", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentBoolean", json.bool(True)), ..pairs]
  }
  let pairs = case input.default_document_list {
    option.Some(v) -> [#("defaultDocumentList", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentList", json.preprocessed_array([])), ..pairs]
  }
  let pairs = case input.default_document_map {
    option.Some(v) -> [#("defaultDocumentMap", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentMap", json.object([])), ..pairs]
  }
  let pairs = case input.default_document_string {
    option.Some(v) -> [#("defaultDocumentString", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentString", json.string("hi")), ..pairs]
  }
  let pairs = case input.default_double {
    option.Some(v) -> [#("defaultDouble", json_float.encode(v)), ..pairs]
    option.None -> [#("defaultDouble", json.float(1.0)), ..pairs]
  }
  let pairs = case input.default_enum {
    option.Some(v) -> [#("defaultEnum", encode_test_enum_enum(v)), ..pairs]
    option.None -> [#("defaultEnum", json.string("FOO")), ..pairs]
  }
  let pairs = case input.default_float {
    option.Some(v) -> [#("defaultFloat", json_float.encode(v)), ..pairs]
    option.None -> [#("defaultFloat", json.float(1.0)), ..pairs]
  }
  let pairs = case input.default_int_enum {
    option.Some(v) -> [#("defaultIntEnum", encode_test_int_enum_int_enum(v)), ..pairs]
    option.None -> [#("defaultIntEnum", json.int(1)), ..pairs]
  }
  let pairs = case input.default_integer {
    option.Some(v) -> [#("defaultInteger", json.int(v)), ..pairs]
    option.None -> [#("defaultInteger", json.int(10)), ..pairs]
  }
  let pairs = case input.default_list {
    option.Some(v) -> [#("defaultList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> [#("defaultList", json.preprocessed_array([])), ..pairs]
  }
  let pairs = case input.default_long {
    option.Some(v) -> [#("defaultLong", json.int(v)), ..pairs]
    option.None -> [#("defaultLong", json.int(100)), ..pairs]
  }
  let pairs = case input.default_map {
    option.Some(v) -> [#("defaultMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> [#("defaultMap", json.object([])), ..pairs]
  }
  let pairs = case input.default_null_document {
    option.Some(v) -> [#("defaultNullDocument", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_short {
    option.Some(v) -> [#("defaultShort", json.int(v)), ..pairs]
    option.None -> [#("defaultShort", json.int(1)), ..pairs]
  }
  let pairs = case input.default_string {
    option.Some(v) -> [#("defaultString", json.string(v)), ..pairs]
    option.None -> [#("defaultString", json.string("hi")), ..pairs]
  }
  let pairs = case input.default_timestamp {
    option.Some(v) -> [#("defaultTimestamp", json.int(v)), ..pairs]
    option.None -> [#("defaultTimestamp", json.int(0)), ..pairs]
  }
  let pairs = case input.empty_blob {
    option.Some(v) -> [#("emptyBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> [#("emptyBlob", json.string("")), ..pairs]
  }
  let pairs = case input.empty_string {
    option.Some(v) -> [#("emptyString", json.string(v)), ..pairs]
    option.None -> [#("emptyString", json.string("")), ..pairs]
  }
  let pairs = case input.false_boolean {
    option.Some(v) -> [#("falseBoolean", json.bool(v)), ..pairs]
    option.None -> [#("falseBoolean", json.bool(False)), ..pairs]
  }
  let pairs = case input.zero_byte {
    option.Some(v) -> [#("zeroByte", json.int(v)), ..pairs]
    option.None -> [#("zeroByte", json.int(0)), ..pairs]
  }
  let pairs = case input.zero_double {
    option.Some(v) -> [#("zeroDouble", json_float.encode(v)), ..pairs]
    option.None -> [#("zeroDouble", json.float(0.0)), ..pairs]
  }
  let pairs = case input.zero_float {
    option.Some(v) -> [#("zeroFloat", json_float.encode(v)), ..pairs]
    option.None -> [#("zeroFloat", json.float(0.0)), ..pairs]
  }
  let pairs = case input.zero_integer {
    option.Some(v) -> [#("zeroInteger", json.int(v)), ..pairs]
    option.None -> [#("zeroInteger", json.int(0)), ..pairs]
  }
  let pairs = case input.zero_long {
    option.Some(v) -> [#("zeroLong", json.int(v)), ..pairs]
    option.None -> [#("zeroLong", json.int(0)), ..pairs]
  }
  let pairs = case input.zero_short {
    option.Some(v) -> [#("zeroShort", json.int(v)), ..pairs]
    option.None -> [#("zeroShort", json.int(0)), ..pairs]
  }
  json.object(pairs)
}

pub fn encode_defaults_struct_top(input: Defaults) -> json.Json {
  let pairs = []
  let pairs = case input.default_blob {
    option.Some(v) -> [#("defaultBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_boolean {
    option.Some(v) -> [#("defaultBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_byte {
    option.Some(v) -> [#("defaultByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_boolean {
    option.Some(v) -> [#("defaultDocumentBoolean", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_list {
    option.Some(v) -> [#("defaultDocumentList", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_map {
    option.Some(v) -> [#("defaultDocumentMap", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_string {
    option.Some(v) -> [#("defaultDocumentString", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_double {
    option.Some(v) -> [#("defaultDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_enum {
    option.Some(v) -> [#("defaultEnum", encode_test_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_float {
    option.Some(v) -> [#("defaultFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_int_enum {
    option.Some(v) -> [#("defaultIntEnum", encode_test_int_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_integer {
    option.Some(v) -> [#("defaultInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_list {
    option.Some(v) -> [#("defaultList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_long {
    option.Some(v) -> [#("defaultLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_map {
    option.Some(v) -> [#("defaultMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_null_document {
    option.Some(v) -> [#("defaultNullDocument", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_short {
    option.Some(v) -> [#("defaultShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_string {
    option.Some(v) -> [#("defaultString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_timestamp {
    option.Some(v) -> [#("defaultTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.empty_blob {
    option.Some(v) -> [#("emptyBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.empty_string {
    option.Some(v) -> [#("emptyString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.false_boolean {
    option.Some(v) -> [#("falseBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_byte {
    option.Some(v) -> [#("zeroByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_double {
    option.Some(v) -> [#("zeroDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_float {
    option.Some(v) -> [#("zeroFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_integer {
    option.Some(v) -> [#("zeroInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_long {
    option.Some(v) -> [#("zeroLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_short {
    option.Some(v) -> [#("zeroShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_defaults_struct() -> decode.Decoder(Defaults) {
  use default_blob <- decode.optional_field("defaultBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use default_boolean <- decode.optional_field("defaultBoolean", option.None, decode.optional(decode.bool))
  use default_byte <- decode.optional_field("defaultByte", option.None, decode.optional(decode.int))
  use default_document_boolean <- decode.optional_field("defaultDocumentBoolean", option.None, decode.optional(json_document.decoder()))
  use default_document_list <- decode.optional_field("defaultDocumentList", option.None, decode.optional(json_document.decoder()))
  use default_document_map <- decode.optional_field("defaultDocumentMap", option.None, decode.optional(json_document.decoder()))
  use default_document_string <- decode.optional_field("defaultDocumentString", option.None, decode.optional(json_document.decoder()))
  use default_double <- decode.optional_field("defaultDouble", option.None, decode.optional(json_float.decoder()))
  use default_enum <- decode.optional_field("defaultEnum", option.None, decode.optional(decode_test_enum_enum()))
  use default_float <- decode.optional_field("defaultFloat", option.None, decode.optional(json_float.decoder()))
  use default_int_enum <- decode.optional_field("defaultIntEnum", option.None, decode.optional(decode_test_int_enum_int_enum()))
  use default_integer <- decode.optional_field("defaultInteger", option.None, decode.optional(decode.int))
  use default_list <- decode.optional_field("defaultList", option.None, decode.optional(decode.list(decode.string)))
  use default_long <- decode.optional_field("defaultLong", option.None, decode.optional(decode.int))
  use default_map <- decode.optional_field("defaultMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use default_null_document <- decode.optional_field("defaultNullDocument", option.None, decode.optional(json_document.decoder()))
  use default_short <- decode.optional_field("defaultShort", option.None, decode.optional(decode.int))
  use default_string <- decode.optional_field("defaultString", option.None, decode.optional(decode.string))
  use default_timestamp <- decode.optional_field("defaultTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  use empty_blob <- decode.optional_field("emptyBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  use false_boolean <- decode.optional_field("falseBoolean", option.None, decode.optional(decode.bool))
  use zero_byte <- decode.optional_field("zeroByte", option.None, decode.optional(decode.int))
  use zero_double <- decode.optional_field("zeroDouble", option.None, decode.optional(json_float.decoder()))
  use zero_float <- decode.optional_field("zeroFloat", option.None, decode.optional(json_float.decoder()))
  use zero_integer <- decode.optional_field("zeroInteger", option.None, decode.optional(decode.int))
  use zero_long <- decode.optional_field("zeroLong", option.None, decode.optional(decode.int))
  use zero_short <- decode.optional_field("zeroShort", option.None, decode.optional(decode.int))
  decode.success(Defaults(
    default_blob: default_blob,
    default_boolean: default_boolean,
    default_byte: default_byte,
    default_document_boolean: default_document_boolean,
    default_document_list: default_document_list,
    default_document_map: default_document_map,
    default_document_string: default_document_string,
    default_double: default_double,
    default_enum: default_enum,
    default_float: default_float,
    default_int_enum: default_int_enum,
    default_integer: default_integer,
    default_list: default_list,
    default_long: default_long,
    default_map: default_map,
    default_null_document: default_null_document,
    default_short: default_short,
    default_string: default_string,
    default_timestamp: default_timestamp,
    empty_blob: empty_blob,
    empty_string: empty_string,
    false_boolean: false_boolean,
    zero_byte: zero_byte,
    zero_double: zero_double,
    zero_float: zero_float,
    zero_integer: zero_integer,
    zero_long: zero_long,
    zero_short: zero_short,
  ))
}

pub fn decode_defaults_struct_params() -> decode.Decoder(Defaults) {
  use default_blob <- decode.optional_field("defaultBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use default_boolean <- decode.optional_field("defaultBoolean", option.None, decode.optional(decode.bool))
  use default_byte <- decode.optional_field("defaultByte", option.None, decode.optional(decode.int))
  use default_document_boolean <- decode.optional_field("defaultDocumentBoolean", option.None, decode.optional(json_document.decoder()))
  use default_document_list <- decode.optional_field("defaultDocumentList", option.None, decode.optional(json_document.decoder()))
  use default_document_map <- decode.optional_field("defaultDocumentMap", option.None, decode.optional(json_document.decoder()))
  use default_document_string <- decode.optional_field("defaultDocumentString", option.None, decode.optional(json_document.decoder()))
  use default_double <- decode.optional_field("defaultDouble", option.None, decode.optional(json_float.decoder()))
  use default_enum <- decode.optional_field("defaultEnum", option.None, decode.optional(decode_test_enum_enum()))
  use default_float <- decode.optional_field("defaultFloat", option.None, decode.optional(json_float.decoder()))
  use default_int_enum <- decode.optional_field("defaultIntEnum", option.None, decode.optional(decode_test_int_enum_int_enum()))
  use default_integer <- decode.optional_field("defaultInteger", option.None, decode.optional(decode.int))
  use default_list <- decode.optional_field("defaultList", option.None, decode.optional(decode.list(decode.string)))
  use default_long <- decode.optional_field("defaultLong", option.None, decode.optional(decode.int))
  use default_map <- decode.optional_field("defaultMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use default_null_document <- decode.optional_field("defaultNullDocument", option.None, decode.optional(json_document.decoder()))
  use default_short <- decode.optional_field("defaultShort", option.None, decode.optional(decode.int))
  use default_string <- decode.optional_field("defaultString", option.None, decode.optional(decode.string))
  use default_timestamp <- decode.optional_field("defaultTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  use empty_blob <- decode.optional_field("emptyBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  use false_boolean <- decode.optional_field("falseBoolean", option.None, decode.optional(decode.bool))
  use zero_byte <- decode.optional_field("zeroByte", option.None, decode.optional(decode.int))
  use zero_double <- decode.optional_field("zeroDouble", option.None, decode.optional(json_float.decoder()))
  use zero_float <- decode.optional_field("zeroFloat", option.None, decode.optional(json_float.decoder()))
  use zero_integer <- decode.optional_field("zeroInteger", option.None, decode.optional(decode.int))
  use zero_long <- decode.optional_field("zeroLong", option.None, decode.optional(decode.int))
  use zero_short <- decode.optional_field("zeroShort", option.None, decode.optional(decode.int))
  decode.success(Defaults(
    default_blob: default_blob,
    default_boolean: default_boolean,
    default_byte: default_byte,
    default_document_boolean: default_document_boolean,
    default_document_list: default_document_list,
    default_document_map: default_document_map,
    default_document_string: default_document_string,
    default_double: default_double,
    default_enum: default_enum,
    default_float: default_float,
    default_int_enum: default_int_enum,
    default_integer: default_integer,
    default_list: default_list,
    default_long: default_long,
    default_map: default_map,
    default_null_document: default_null_document,
    default_short: default_short,
    default_string: default_string,
    default_timestamp: default_timestamp,
    empty_blob: empty_blob,
    empty_string: empty_string,
    false_boolean: false_boolean,
    zero_byte: zero_byte,
    zero_double: zero_double,
    zero_float: zero_float,
    zero_integer: zero_integer,
    zero_long: zero_long,
    zero_short: zero_short,
  ))
}

pub type TestEnum {
  TestEnumBar
  TestEnumBaz
  TestEnumFoo
}

pub fn encode_test_enum_enum(v: TestEnum) -> json.Json {
  case v {
    TestEnumBar -> json.string("BAR")
    TestEnumBaz -> json.string("BAZ")
    TestEnumFoo -> json.string("FOO")
  }
}

pub fn decode_test_enum_enum() -> decode.Decoder(TestEnum) {
  decode.then(decode.string, fn(s) {
    case s {
      "BAR" -> decode.success(TestEnumBar)
      "BAZ" -> decode.success(TestEnumBaz)
      "FOO" -> decode.success(TestEnumFoo)
      _ -> decode.failure(TestEnumBar, "unknown enum value")
    }
  })
}

pub type TestIntEnum {
  TestIntEnumOne
  TestIntEnumTwo
}

pub fn encode_test_int_enum_int_enum(v: TestIntEnum) -> json.Json {
  case v {
    TestIntEnumOne -> json.int(1)
    TestIntEnumTwo -> json.int(2)
  }
}

pub fn decode_test_int_enum_int_enum() -> decode.Decoder(TestIntEnum) {
  decode.then(decode.int, fn(n) {
    case n {
      1 -> decode.success(TestIntEnumOne)
      2 -> decode.success(TestIntEnumTwo)
      _ -> decode.failure(TestIntEnumOne, "unknown int enum value")
    }
  })
}

pub type OperationWithDefaultsOutput {
  OperationWithDefaultsOutput(
    default_blob: option.Option(BitArray),
    default_boolean: option.Option(Bool),
    default_byte: option.Option(Int),
    default_document_boolean: option.Option(json.Json),
    default_document_list: option.Option(json.Json),
    default_document_map: option.Option(json.Json),
    default_document_string: option.Option(json.Json),
    default_double: option.Option(json_float.SmithyFloat),
    default_enum: option.Option(TestEnum),
    default_float: option.Option(json_float.SmithyFloat),
    default_int_enum: option.Option(TestIntEnum),
    default_integer: option.Option(Int),
    default_list: option.Option(List(String)),
    default_long: option.Option(Int),
    default_map: option.Option(dict.Dict(String, String)),
    default_null_document: option.Option(json.Json),
    default_short: option.Option(Int),
    default_string: option.Option(String),
    default_timestamp: option.Option(Int),
    empty_blob: option.Option(BitArray),
    empty_string: option.Option(String),
    false_boolean: option.Option(Bool),
    zero_byte: option.Option(Int),
    zero_double: option.Option(json_float.SmithyFloat),
    zero_float: option.Option(json_float.SmithyFloat),
    zero_integer: option.Option(Int),
    zero_long: option.Option(Int),
    zero_short: option.Option(Int),
  )
}

pub fn encode_operation_with_defaults_output_struct(input: OperationWithDefaultsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.default_blob {
    option.Some(v) -> [#("defaultBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> [#("defaultBlob", json.string("YWJj")), ..pairs]
  }
  let pairs = case input.default_boolean {
    option.Some(v) -> [#("defaultBoolean", json.bool(v)), ..pairs]
    option.None -> [#("defaultBoolean", json.bool(True)), ..pairs]
  }
  let pairs = case input.default_byte {
    option.Some(v) -> [#("defaultByte", json.int(v)), ..pairs]
    option.None -> [#("defaultByte", json.int(1)), ..pairs]
  }
  let pairs = case input.default_document_boolean {
    option.Some(v) -> [#("defaultDocumentBoolean", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentBoolean", json.bool(True)), ..pairs]
  }
  let pairs = case input.default_document_list {
    option.Some(v) -> [#("defaultDocumentList", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentList", json.preprocessed_array([])), ..pairs]
  }
  let pairs = case input.default_document_map {
    option.Some(v) -> [#("defaultDocumentMap", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentMap", json.object([])), ..pairs]
  }
  let pairs = case input.default_document_string {
    option.Some(v) -> [#("defaultDocumentString", fn(j) { j }(v)), ..pairs]
    option.None -> [#("defaultDocumentString", json.string("hi")), ..pairs]
  }
  let pairs = case input.default_double {
    option.Some(v) -> [#("defaultDouble", json_float.encode(v)), ..pairs]
    option.None -> [#("defaultDouble", json.float(1.0)), ..pairs]
  }
  let pairs = case input.default_enum {
    option.Some(v) -> [#("defaultEnum", encode_test_enum_enum(v)), ..pairs]
    option.None -> [#("defaultEnum", json.string("FOO")), ..pairs]
  }
  let pairs = case input.default_float {
    option.Some(v) -> [#("defaultFloat", json_float.encode(v)), ..pairs]
    option.None -> [#("defaultFloat", json.float(1.0)), ..pairs]
  }
  let pairs = case input.default_int_enum {
    option.Some(v) -> [#("defaultIntEnum", encode_test_int_enum_int_enum(v)), ..pairs]
    option.None -> [#("defaultIntEnum", json.int(1)), ..pairs]
  }
  let pairs = case input.default_integer {
    option.Some(v) -> [#("defaultInteger", json.int(v)), ..pairs]
    option.None -> [#("defaultInteger", json.int(10)), ..pairs]
  }
  let pairs = case input.default_list {
    option.Some(v) -> [#("defaultList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> [#("defaultList", json.preprocessed_array([])), ..pairs]
  }
  let pairs = case input.default_long {
    option.Some(v) -> [#("defaultLong", json.int(v)), ..pairs]
    option.None -> [#("defaultLong", json.int(100)), ..pairs]
  }
  let pairs = case input.default_map {
    option.Some(v) -> [#("defaultMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> [#("defaultMap", json.object([])), ..pairs]
  }
  let pairs = case input.default_null_document {
    option.Some(v) -> [#("defaultNullDocument", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_short {
    option.Some(v) -> [#("defaultShort", json.int(v)), ..pairs]
    option.None -> [#("defaultShort", json.int(1)), ..pairs]
  }
  let pairs = case input.default_string {
    option.Some(v) -> [#("defaultString", json.string(v)), ..pairs]
    option.None -> [#("defaultString", json.string("hi")), ..pairs]
  }
  let pairs = case input.default_timestamp {
    option.Some(v) -> [#("defaultTimestamp", json.int(v)), ..pairs]
    option.None -> [#("defaultTimestamp", json.int(0)), ..pairs]
  }
  let pairs = case input.empty_blob {
    option.Some(v) -> [#("emptyBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> [#("emptyBlob", json.string("")), ..pairs]
  }
  let pairs = case input.empty_string {
    option.Some(v) -> [#("emptyString", json.string(v)), ..pairs]
    option.None -> [#("emptyString", json.string("")), ..pairs]
  }
  let pairs = case input.false_boolean {
    option.Some(v) -> [#("falseBoolean", json.bool(v)), ..pairs]
    option.None -> [#("falseBoolean", json.bool(False)), ..pairs]
  }
  let pairs = case input.zero_byte {
    option.Some(v) -> [#("zeroByte", json.int(v)), ..pairs]
    option.None -> [#("zeroByte", json.int(0)), ..pairs]
  }
  let pairs = case input.zero_double {
    option.Some(v) -> [#("zeroDouble", json_float.encode(v)), ..pairs]
    option.None -> [#("zeroDouble", json.float(0.0)), ..pairs]
  }
  let pairs = case input.zero_float {
    option.Some(v) -> [#("zeroFloat", json_float.encode(v)), ..pairs]
    option.None -> [#("zeroFloat", json.float(0.0)), ..pairs]
  }
  let pairs = case input.zero_integer {
    option.Some(v) -> [#("zeroInteger", json.int(v)), ..pairs]
    option.None -> [#("zeroInteger", json.int(0)), ..pairs]
  }
  let pairs = case input.zero_long {
    option.Some(v) -> [#("zeroLong", json.int(v)), ..pairs]
    option.None -> [#("zeroLong", json.int(0)), ..pairs]
  }
  let pairs = case input.zero_short {
    option.Some(v) -> [#("zeroShort", json.int(v)), ..pairs]
    option.None -> [#("zeroShort", json.int(0)), ..pairs]
  }
  json.object(pairs)
}

pub fn encode_operation_with_defaults_output_struct_top(input: OperationWithDefaultsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.default_blob {
    option.Some(v) -> [#("defaultBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_boolean {
    option.Some(v) -> [#("defaultBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_byte {
    option.Some(v) -> [#("defaultByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_boolean {
    option.Some(v) -> [#("defaultDocumentBoolean", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_list {
    option.Some(v) -> [#("defaultDocumentList", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_map {
    option.Some(v) -> [#("defaultDocumentMap", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_document_string {
    option.Some(v) -> [#("defaultDocumentString", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_double {
    option.Some(v) -> [#("defaultDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_enum {
    option.Some(v) -> [#("defaultEnum", encode_test_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_float {
    option.Some(v) -> [#("defaultFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_int_enum {
    option.Some(v) -> [#("defaultIntEnum", encode_test_int_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_integer {
    option.Some(v) -> [#("defaultInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_list {
    option.Some(v) -> [#("defaultList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_long {
    option.Some(v) -> [#("defaultLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_map {
    option.Some(v) -> [#("defaultMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_null_document {
    option.Some(v) -> [#("defaultNullDocument", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_short {
    option.Some(v) -> [#("defaultShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_string {
    option.Some(v) -> [#("defaultString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_timestamp {
    option.Some(v) -> [#("defaultTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.empty_blob {
    option.Some(v) -> [#("emptyBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.empty_string {
    option.Some(v) -> [#("emptyString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.false_boolean {
    option.Some(v) -> [#("falseBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_byte {
    option.Some(v) -> [#("zeroByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_double {
    option.Some(v) -> [#("zeroDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_float {
    option.Some(v) -> [#("zeroFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_integer {
    option.Some(v) -> [#("zeroInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_long {
    option.Some(v) -> [#("zeroLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.zero_short {
    option.Some(v) -> [#("zeroShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_defaults_output_struct() -> decode.Decoder(OperationWithDefaultsOutput) {
  use default_blob <- decode.optional_field("defaultBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use default_boolean <- decode.optional_field("defaultBoolean", option.None, decode.optional(decode.bool))
  use default_byte <- decode.optional_field("defaultByte", option.None, decode.optional(decode.int))
  use default_document_boolean <- decode.optional_field("defaultDocumentBoolean", option.None, decode.optional(json_document.decoder()))
  use default_document_list <- decode.optional_field("defaultDocumentList", option.None, decode.optional(json_document.decoder()))
  use default_document_map <- decode.optional_field("defaultDocumentMap", option.None, decode.optional(json_document.decoder()))
  use default_document_string <- decode.optional_field("defaultDocumentString", option.None, decode.optional(json_document.decoder()))
  use default_double <- decode.optional_field("defaultDouble", option.None, decode.optional(json_float.decoder()))
  use default_enum <- decode.optional_field("defaultEnum", option.None, decode.optional(decode_test_enum_enum()))
  use default_float <- decode.optional_field("defaultFloat", option.None, decode.optional(json_float.decoder()))
  use default_int_enum <- decode.optional_field("defaultIntEnum", option.None, decode.optional(decode_test_int_enum_int_enum()))
  use default_integer <- decode.optional_field("defaultInteger", option.None, decode.optional(decode.int))
  use default_list <- decode.optional_field("defaultList", option.None, decode.optional(decode.list(decode.string)))
  use default_long <- decode.optional_field("defaultLong", option.None, decode.optional(decode.int))
  use default_map <- decode.optional_field("defaultMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use default_null_document <- decode.optional_field("defaultNullDocument", option.None, decode.optional(json_document.decoder()))
  use default_short <- decode.optional_field("defaultShort", option.None, decode.optional(decode.int))
  use default_string <- decode.optional_field("defaultString", option.None, decode.optional(decode.string))
  use default_timestamp <- decode.optional_field("defaultTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  use empty_blob <- decode.optional_field("emptyBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  use false_boolean <- decode.optional_field("falseBoolean", option.None, decode.optional(decode.bool))
  use zero_byte <- decode.optional_field("zeroByte", option.None, decode.optional(decode.int))
  use zero_double <- decode.optional_field("zeroDouble", option.None, decode.optional(json_float.decoder()))
  use zero_float <- decode.optional_field("zeroFloat", option.None, decode.optional(json_float.decoder()))
  use zero_integer <- decode.optional_field("zeroInteger", option.None, decode.optional(decode.int))
  use zero_long <- decode.optional_field("zeroLong", option.None, decode.optional(decode.int))
  use zero_short <- decode.optional_field("zeroShort", option.None, decode.optional(decode.int))
  decode.success(OperationWithDefaultsOutput(
    default_blob: default_blob,
    default_boolean: default_boolean,
    default_byte: default_byte,
    default_document_boolean: default_document_boolean,
    default_document_list: default_document_list,
    default_document_map: default_document_map,
    default_document_string: default_document_string,
    default_double: default_double,
    default_enum: default_enum,
    default_float: default_float,
    default_int_enum: default_int_enum,
    default_integer: default_integer,
    default_list: default_list,
    default_long: default_long,
    default_map: default_map,
    default_null_document: default_null_document,
    default_short: default_short,
    default_string: default_string,
    default_timestamp: default_timestamp,
    empty_blob: empty_blob,
    empty_string: empty_string,
    false_boolean: false_boolean,
    zero_byte: zero_byte,
    zero_double: zero_double,
    zero_float: zero_float,
    zero_integer: zero_integer,
    zero_long: zero_long,
    zero_short: zero_short,
  ))
}

pub fn decode_operation_with_defaults_output_struct_params() -> decode.Decoder(OperationWithDefaultsOutput) {
  use default_blob <- decode.optional_field("defaultBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use default_boolean <- decode.optional_field("defaultBoolean", option.None, decode.optional(decode.bool))
  use default_byte <- decode.optional_field("defaultByte", option.None, decode.optional(decode.int))
  use default_document_boolean <- decode.optional_field("defaultDocumentBoolean", option.None, decode.optional(json_document.decoder()))
  use default_document_list <- decode.optional_field("defaultDocumentList", option.None, decode.optional(json_document.decoder()))
  use default_document_map <- decode.optional_field("defaultDocumentMap", option.None, decode.optional(json_document.decoder()))
  use default_document_string <- decode.optional_field("defaultDocumentString", option.None, decode.optional(json_document.decoder()))
  use default_double <- decode.optional_field("defaultDouble", option.None, decode.optional(json_float.decoder()))
  use default_enum <- decode.optional_field("defaultEnum", option.None, decode.optional(decode_test_enum_enum()))
  use default_float <- decode.optional_field("defaultFloat", option.None, decode.optional(json_float.decoder()))
  use default_int_enum <- decode.optional_field("defaultIntEnum", option.None, decode.optional(decode_test_int_enum_int_enum()))
  use default_integer <- decode.optional_field("defaultInteger", option.None, decode.optional(decode.int))
  use default_list <- decode.optional_field("defaultList", option.None, decode.optional(decode.list(decode.string)))
  use default_long <- decode.optional_field("defaultLong", option.None, decode.optional(decode.int))
  use default_map <- decode.optional_field("defaultMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use default_null_document <- decode.optional_field("defaultNullDocument", option.None, decode.optional(json_document.decoder()))
  use default_short <- decode.optional_field("defaultShort", option.None, decode.optional(decode.int))
  use default_string <- decode.optional_field("defaultString", option.None, decode.optional(decode.string))
  use default_timestamp <- decode.optional_field("defaultTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  use empty_blob <- decode.optional_field("emptyBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use empty_string <- decode.optional_field("emptyString", option.None, decode.optional(decode.string))
  use false_boolean <- decode.optional_field("falseBoolean", option.None, decode.optional(decode.bool))
  use zero_byte <- decode.optional_field("zeroByte", option.None, decode.optional(decode.int))
  use zero_double <- decode.optional_field("zeroDouble", option.None, decode.optional(json_float.decoder()))
  use zero_float <- decode.optional_field("zeroFloat", option.None, decode.optional(json_float.decoder()))
  use zero_integer <- decode.optional_field("zeroInteger", option.None, decode.optional(decode.int))
  use zero_long <- decode.optional_field("zeroLong", option.None, decode.optional(decode.int))
  use zero_short <- decode.optional_field("zeroShort", option.None, decode.optional(decode.int))
  decode.success(OperationWithDefaultsOutput(
    default_blob: default_blob,
    default_boolean: default_boolean,
    default_byte: default_byte,
    default_document_boolean: default_document_boolean,
    default_document_list: default_document_list,
    default_document_map: default_document_map,
    default_document_string: default_document_string,
    default_double: default_double,
    default_enum: default_enum,
    default_float: default_float,
    default_int_enum: default_int_enum,
    default_integer: default_integer,
    default_list: default_list,
    default_long: default_long,
    default_map: default_map,
    default_null_document: default_null_document,
    default_short: default_short,
    default_string: default_string,
    default_timestamp: default_timestamp,
    empty_blob: empty_blob,
    empty_string: empty_string,
    false_boolean: false_boolean,
    zero_byte: zero_byte,
    zero_double: zero_double,
    zero_float: zero_float,
    zero_integer: zero_integer,
    zero_long: zero_long,
    zero_short: zero_short,
  ))
}

pub type OperationWithNestedStructureInput {
  OperationWithNestedStructureInput(
    top_level: option.Option(TopLevel),
  )
}

pub fn encode_operation_with_nested_structure_input_struct(input: OperationWithNestedStructureInput) -> json.Json {
  let pairs = []
  let pairs = case input.top_level {
    option.Some(v) -> [#("topLevel", encode_top_level_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_operation_with_nested_structure_input_struct_top(input: OperationWithNestedStructureInput) -> json.Json {
  let pairs = []
  let pairs = case input.top_level {
    option.Some(v) -> [#("topLevel", encode_top_level_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_nested_structure_input_struct() -> decode.Decoder(OperationWithNestedStructureInput) {
  use top_level <- decode.optional_field("topLevel", option.None, decode.optional(decode_top_level_struct()))
  decode.success(OperationWithNestedStructureInput(
    top_level: top_level,
  ))
}

pub fn decode_operation_with_nested_structure_input_struct_params() -> decode.Decoder(OperationWithNestedStructureInput) {
  use top_level <- decode.optional_field("topLevel", option.None, decode.optional(decode_top_level_struct_params()))
  decode.success(OperationWithNestedStructureInput(
    top_level: top_level,
  ))
}

pub type TopLevel {
  TopLevel(
    dialog: option.Option(Dialog),
    dialog_list: option.Option(List(Dialog)),
    dialog_map: option.Option(dict.Dict(String, Dialog)),
  )
}

pub fn encode_top_level_struct(input: TopLevel) -> json.Json {
  let pairs = []
  let pairs = case input.dialog {
    option.Some(v) -> [#("dialog", encode_dialog_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.dialog_list {
    option.Some(v) -> [#("dialogList", fn(xs) { json.array(xs, encode_dialog_struct) }(v)), ..pairs]
    option.None -> [#("dialogList", json.preprocessed_array([])), ..pairs]
  }
  let pairs = case input.dialog_map {
    option.Some(v) -> [#("dialogMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_dialog_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> [#("dialogMap", json.object([])), ..pairs]
  }
  json.object(pairs)
}

pub fn encode_top_level_struct_top(input: TopLevel) -> json.Json {
  let pairs = []
  let pairs = case input.dialog {
    option.Some(v) -> [#("dialog", encode_dialog_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.dialog_list {
    option.Some(v) -> [#("dialogList", fn(xs) { json.array(xs, encode_dialog_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.dialog_map {
    option.Some(v) -> [#("dialogMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_dialog_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_top_level_struct() -> decode.Decoder(TopLevel) {
  use dialog <- decode.optional_field("dialog", option.None, decode.optional(decode_dialog_struct()))
  use dialog_list <- decode.optional_field("dialogList", option.None, decode.optional(decode.list(decode_dialog_struct())))
  use dialog_map <- decode.optional_field("dialogMap", option.None, decode.optional(decode.dict(decode.string, decode_dialog_struct())))
  decode.success(TopLevel(
    dialog: dialog,
    dialog_list: dialog_list,
    dialog_map: dialog_map,
  ))
}

pub fn decode_top_level_struct_params() -> decode.Decoder(TopLevel) {
  use dialog <- decode.optional_field("dialog", option.None, decode.optional(decode_dialog_struct_params()))
  use dialog_list <- decode.optional_field("dialogList", option.None, decode.optional(decode.list(decode_dialog_struct_params())))
  use dialog_map <- decode.optional_field("dialogMap", option.None, decode.optional(decode.dict(decode.string, decode_dialog_struct_params())))
  decode.success(TopLevel(
    dialog: dialog,
    dialog_list: dialog_list,
    dialog_map: dialog_map,
  ))
}

pub type Dialog {
  Dialog(
    farewell: option.Option(Farewell),
    greeting: option.Option(String),
    language: option.Option(String),
  )
}

pub fn encode_dialog_struct(input: Dialog) -> json.Json {
  let pairs = []
  let pairs = case input.farewell {
    option.Some(v) -> [#("farewell", encode_farewell_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> [#("greeting", json.string("hi")), ..pairs]
  }
  let pairs = case input.language {
    option.Some(v) -> [#("language", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_dialog_struct_top(input: Dialog) -> json.Json {
  let pairs = []
  let pairs = case input.farewell {
    option.Some(v) -> [#("farewell", encode_farewell_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.language {
    option.Some(v) -> [#("language", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_dialog_struct() -> decode.Decoder(Dialog) {
  use farewell <- decode.optional_field("farewell", option.None, decode.optional(decode_farewell_struct()))
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  use language <- decode.optional_field("language", option.None, decode.optional(decode.string))
  decode.success(Dialog(
    farewell: farewell,
    greeting: greeting,
    language: language,
  ))
}

pub fn decode_dialog_struct_params() -> decode.Decoder(Dialog) {
  use farewell <- decode.optional_field("farewell", option.None, decode.optional(decode_farewell_struct_params()))
  use greeting <- decode.optional_field("greeting", option.None, decode.optional(decode.string))
  use language <- decode.optional_field("language", option.None, decode.optional(decode.string))
  decode.success(Dialog(
    farewell: farewell,
    greeting: greeting,
    language: language,
  ))
}

pub type Farewell {
  Farewell(
    phrase: option.Option(String),
  )
}

pub fn encode_farewell_struct(input: Farewell) -> json.Json {
  let pairs = []
  let pairs = case input.phrase {
    option.Some(v) -> [#("phrase", json.string(v)), ..pairs]
    option.None -> [#("phrase", json.string("bye")), ..pairs]
  }
  json.object(pairs)
}

pub fn encode_farewell_struct_top(input: Farewell) -> json.Json {
  let pairs = []
  let pairs = case input.phrase {
    option.Some(v) -> [#("phrase", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_farewell_struct() -> decode.Decoder(Farewell) {
  use phrase <- decode.optional_field("phrase", option.None, decode.optional(decode.string))
  decode.success(Farewell(
    phrase: phrase,
  ))
}

pub fn decode_farewell_struct_params() -> decode.Decoder(Farewell) {
  use phrase <- decode.optional_field("phrase", option.None, decode.optional(decode.string))
  decode.success(Farewell(
    phrase: phrase,
  ))
}

pub type OperationWithNestedStructureOutput {
  OperationWithNestedStructureOutput(
    dialog: option.Option(Dialog),
    dialog_list: option.Option(List(Dialog)),
    dialog_map: option.Option(dict.Dict(String, Dialog)),
  )
}

pub fn encode_operation_with_nested_structure_output_struct(input: OperationWithNestedStructureOutput) -> json.Json {
  let pairs = []
  let pairs = case input.dialog {
    option.Some(v) -> [#("dialog", encode_dialog_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.dialog_list {
    option.Some(v) -> [#("dialogList", fn(xs) { json.array(xs, encode_dialog_struct) }(v)), ..pairs]
    option.None -> [#("dialogList", json.preprocessed_array([])), ..pairs]
  }
  let pairs = case input.dialog_map {
    option.Some(v) -> [#("dialogMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_dialog_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> [#("dialogMap", json.object([])), ..pairs]
  }
  json.object(pairs)
}

pub fn encode_operation_with_nested_structure_output_struct_top(input: OperationWithNestedStructureOutput) -> json.Json {
  let pairs = []
  let pairs = case input.dialog {
    option.Some(v) -> [#("dialog", encode_dialog_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.dialog_list {
    option.Some(v) -> [#("dialogList", fn(xs) { json.array(xs, encode_dialog_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.dialog_map {
    option.Some(v) -> [#("dialogMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_dialog_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_nested_structure_output_struct() -> decode.Decoder(OperationWithNestedStructureOutput) {
  use dialog <- decode.optional_field("dialog", option.None, decode.optional(decode_dialog_struct()))
  use dialog_list <- decode.optional_field("dialogList", option.None, decode.optional(decode.list(decode_dialog_struct())))
  use dialog_map <- decode.optional_field("dialogMap", option.None, decode.optional(decode.dict(decode.string, decode_dialog_struct())))
  decode.success(OperationWithNestedStructureOutput(
    dialog: dialog,
    dialog_list: dialog_list,
    dialog_map: dialog_map,
  ))
}

pub fn decode_operation_with_nested_structure_output_struct_params() -> decode.Decoder(OperationWithNestedStructureOutput) {
  use dialog <- decode.optional_field("dialog", option.None, decode.optional(decode_dialog_struct_params()))
  use dialog_list <- decode.optional_field("dialogList", option.None, decode.optional(decode.list(decode_dialog_struct_params())))
  use dialog_map <- decode.optional_field("dialogMap", option.None, decode.optional(decode.dict(decode.string, decode_dialog_struct_params())))
  decode.success(OperationWithNestedStructureOutput(
    dialog: dialog,
    dialog_list: dialog_list,
    dialog_map: dialog_map,
  ))
}

pub type OperationWithRequiredMembersOutput {
  OperationWithRequiredMembersOutput(
    required_blob: option.Option(BitArray),
    required_boolean: option.Option(Bool),
    required_byte: option.Option(Int),
    required_double: option.Option(json_float.SmithyFloat),
    required_float: option.Option(json_float.SmithyFloat),
    required_integer: option.Option(Int),
    required_list: option.Option(List(String)),
    required_long: option.Option(Int),
    required_map: option.Option(dict.Dict(String, String)),
    required_short: option.Option(Int),
    required_string: option.Option(String),
    required_timestamp: option.Option(Int),
  )
}

pub fn encode_operation_with_required_members_output_struct(input: OperationWithRequiredMembersOutput) -> json.Json {
  let pairs = []
  let pairs = case input.required_blob {
    option.Some(v) -> [#("requiredBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_boolean {
    option.Some(v) -> [#("requiredBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_byte {
    option.Some(v) -> [#("requiredByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_double {
    option.Some(v) -> [#("requiredDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_float {
    option.Some(v) -> [#("requiredFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_integer {
    option.Some(v) -> [#("requiredInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_list {
    option.Some(v) -> [#("requiredList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_long {
    option.Some(v) -> [#("requiredLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_map {
    option.Some(v) -> [#("requiredMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_short {
    option.Some(v) -> [#("requiredShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_string {
    option.Some(v) -> [#("requiredString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_timestamp {
    option.Some(v) -> [#("requiredTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_operation_with_required_members_output_struct_top(input: OperationWithRequiredMembersOutput) -> json.Json {
  let pairs = []
  let pairs = case input.required_blob {
    option.Some(v) -> [#("requiredBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_boolean {
    option.Some(v) -> [#("requiredBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_byte {
    option.Some(v) -> [#("requiredByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_double {
    option.Some(v) -> [#("requiredDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_float {
    option.Some(v) -> [#("requiredFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_integer {
    option.Some(v) -> [#("requiredInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_list {
    option.Some(v) -> [#("requiredList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_long {
    option.Some(v) -> [#("requiredLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_map {
    option.Some(v) -> [#("requiredMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_short {
    option.Some(v) -> [#("requiredShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_string {
    option.Some(v) -> [#("requiredString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_timestamp {
    option.Some(v) -> [#("requiredTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_required_members_output_struct() -> decode.Decoder(OperationWithRequiredMembersOutput) {
  use required_blob <- decode.optional_field("requiredBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use required_boolean <- decode.optional_field("requiredBoolean", option.None, decode.optional(decode.bool))
  use required_byte <- decode.optional_field("requiredByte", option.None, decode.optional(decode.int))
  use required_double <- decode.optional_field("requiredDouble", option.None, decode.optional(json_float.decoder()))
  use required_float <- decode.optional_field("requiredFloat", option.None, decode.optional(json_float.decoder()))
  use required_integer <- decode.optional_field("requiredInteger", option.None, decode.optional(decode.int))
  use required_list <- decode.optional_field("requiredList", option.None, decode.optional(decode.list(decode.string)))
  use required_long <- decode.optional_field("requiredLong", option.None, decode.optional(decode.int))
  use required_map <- decode.optional_field("requiredMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use required_short <- decode.optional_field("requiredShort", option.None, decode.optional(decode.int))
  use required_string <- decode.optional_field("requiredString", option.None, decode.optional(decode.string))
  use required_timestamp <- decode.optional_field("requiredTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(OperationWithRequiredMembersOutput(
    required_blob: required_blob,
    required_boolean: required_boolean,
    required_byte: required_byte,
    required_double: required_double,
    required_float: required_float,
    required_integer: required_integer,
    required_list: required_list,
    required_long: required_long,
    required_map: required_map,
    required_short: required_short,
    required_string: required_string,
    required_timestamp: required_timestamp,
  ))
}

pub fn decode_operation_with_required_members_output_struct_params() -> decode.Decoder(OperationWithRequiredMembersOutput) {
  use required_blob <- decode.optional_field("requiredBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use required_boolean <- decode.optional_field("requiredBoolean", option.None, decode.optional(decode.bool))
  use required_byte <- decode.optional_field("requiredByte", option.None, decode.optional(decode.int))
  use required_double <- decode.optional_field("requiredDouble", option.None, decode.optional(json_float.decoder()))
  use required_float <- decode.optional_field("requiredFloat", option.None, decode.optional(json_float.decoder()))
  use required_integer <- decode.optional_field("requiredInteger", option.None, decode.optional(decode.int))
  use required_list <- decode.optional_field("requiredList", option.None, decode.optional(decode.list(decode.string)))
  use required_long <- decode.optional_field("requiredLong", option.None, decode.optional(decode.int))
  use required_map <- decode.optional_field("requiredMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use required_short <- decode.optional_field("requiredShort", option.None, decode.optional(decode.int))
  use required_string <- decode.optional_field("requiredString", option.None, decode.optional(decode.string))
  use required_timestamp <- decode.optional_field("requiredTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(OperationWithRequiredMembersOutput(
    required_blob: required_blob,
    required_boolean: required_boolean,
    required_byte: required_byte,
    required_double: required_double,
    required_float: required_float,
    required_integer: required_integer,
    required_list: required_list,
    required_long: required_long,
    required_map: required_map,
    required_short: required_short,
    required_string: required_string,
    required_timestamp: required_timestamp,
  ))
}

pub type OperationWithRequiredMembersWithDefaultsOutput {
  OperationWithRequiredMembersWithDefaultsOutput(
    required_blob: option.Option(BitArray),
    required_boolean: option.Option(Bool),
    required_byte: option.Option(Int),
    required_double: option.Option(json_float.SmithyFloat),
    required_enum: option.Option(RequiredEnum),
    required_float: option.Option(json_float.SmithyFloat),
    required_int_enum: option.Option(RequiredIntEnum),
    required_integer: option.Option(Int),
    required_list: option.Option(List(String)),
    required_long: option.Option(Int),
    required_map: option.Option(dict.Dict(String, String)),
    required_short: option.Option(Int),
    required_string: option.Option(String),
    required_timestamp: option.Option(Int),
  )
}

pub fn encode_operation_with_required_members_with_defaults_output_struct(input: OperationWithRequiredMembersWithDefaultsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.required_blob {
    option.Some(v) -> [#("requiredBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> [#("requiredBlob", json.string("YmxvYg==")), ..pairs]
  }
  let pairs = case input.required_boolean {
    option.Some(v) -> [#("requiredBoolean", json.bool(v)), ..pairs]
    option.None -> [#("requiredBoolean", json.bool(True)), ..pairs]
  }
  let pairs = case input.required_byte {
    option.Some(v) -> [#("requiredByte", json.int(v)), ..pairs]
    option.None -> [#("requiredByte", json.int(1)), ..pairs]
  }
  let pairs = case input.required_double {
    option.Some(v) -> [#("requiredDouble", json_float.encode(v)), ..pairs]
    option.None -> [#("requiredDouble", json.float(1.0)), ..pairs]
  }
  let pairs = case input.required_enum {
    option.Some(v) -> [#("requiredEnum", encode_required_enum_enum(v)), ..pairs]
    option.None -> [#("requiredEnum", json.string("FOO")), ..pairs]
  }
  let pairs = case input.required_float {
    option.Some(v) -> [#("requiredFloat", json_float.encode(v)), ..pairs]
    option.None -> [#("requiredFloat", json.float(1.0)), ..pairs]
  }
  let pairs = case input.required_int_enum {
    option.Some(v) -> [#("requiredIntEnum", encode_required_int_enum_int_enum(v)), ..pairs]
    option.None -> [#("requiredIntEnum", json.int(1)), ..pairs]
  }
  let pairs = case input.required_integer {
    option.Some(v) -> [#("requiredInteger", json.int(v)), ..pairs]
    option.None -> [#("requiredInteger", json.int(10)), ..pairs]
  }
  let pairs = case input.required_list {
    option.Some(v) -> [#("requiredList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> [#("requiredList", json.preprocessed_array([])), ..pairs]
  }
  let pairs = case input.required_long {
    option.Some(v) -> [#("requiredLong", json.int(v)), ..pairs]
    option.None -> [#("requiredLong", json.int(100)), ..pairs]
  }
  let pairs = case input.required_map {
    option.Some(v) -> [#("requiredMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> [#("requiredMap", json.object([])), ..pairs]
  }
  let pairs = case input.required_short {
    option.Some(v) -> [#("requiredShort", json.int(v)), ..pairs]
    option.None -> [#("requiredShort", json.int(1)), ..pairs]
  }
  let pairs = case input.required_string {
    option.Some(v) -> [#("requiredString", json.string(v)), ..pairs]
    option.None -> [#("requiredString", json.string("hi")), ..pairs]
  }
  let pairs = case input.required_timestamp {
    option.Some(v) -> [#("requiredTimestamp", json.int(v)), ..pairs]
    option.None -> [#("requiredTimestamp", json.int(1)), ..pairs]
  }
  json.object(pairs)
}

pub fn encode_operation_with_required_members_with_defaults_output_struct_top(input: OperationWithRequiredMembersWithDefaultsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.required_blob {
    option.Some(v) -> [#("requiredBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_boolean {
    option.Some(v) -> [#("requiredBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_byte {
    option.Some(v) -> [#("requiredByte", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_double {
    option.Some(v) -> [#("requiredDouble", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_enum {
    option.Some(v) -> [#("requiredEnum", encode_required_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_float {
    option.Some(v) -> [#("requiredFloat", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_int_enum {
    option.Some(v) -> [#("requiredIntEnum", encode_required_int_enum_int_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_integer {
    option.Some(v) -> [#("requiredInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_list {
    option.Some(v) -> [#("requiredList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_long {
    option.Some(v) -> [#("requiredLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_map {
    option.Some(v) -> [#("requiredMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_short {
    option.Some(v) -> [#("requiredShort", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_string {
    option.Some(v) -> [#("requiredString", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.required_timestamp {
    option.Some(v) -> [#("requiredTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_required_members_with_defaults_output_struct() -> decode.Decoder(OperationWithRequiredMembersWithDefaultsOutput) {
  use required_blob <- decode.optional_field("requiredBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use required_boolean <- decode.optional_field("requiredBoolean", option.None, decode.optional(decode.bool))
  use required_byte <- decode.optional_field("requiredByte", option.None, decode.optional(decode.int))
  use required_double <- decode.optional_field("requiredDouble", option.None, decode.optional(json_float.decoder()))
  use required_enum <- decode.optional_field("requiredEnum", option.None, decode.optional(decode_required_enum_enum()))
  use required_float <- decode.optional_field("requiredFloat", option.None, decode.optional(json_float.decoder()))
  use required_int_enum <- decode.optional_field("requiredIntEnum", option.None, decode.optional(decode_required_int_enum_int_enum()))
  use required_integer <- decode.optional_field("requiredInteger", option.None, decode.optional(decode.int))
  use required_list <- decode.optional_field("requiredList", option.None, decode.optional(decode.list(decode.string)))
  use required_long <- decode.optional_field("requiredLong", option.None, decode.optional(decode.int))
  use required_map <- decode.optional_field("requiredMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use required_short <- decode.optional_field("requiredShort", option.None, decode.optional(decode.int))
  use required_string <- decode.optional_field("requiredString", option.None, decode.optional(decode.string))
  use required_timestamp <- decode.optional_field("requiredTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(OperationWithRequiredMembersWithDefaultsOutput(
    required_blob: required_blob,
    required_boolean: required_boolean,
    required_byte: required_byte,
    required_double: required_double,
    required_enum: required_enum,
    required_float: required_float,
    required_int_enum: required_int_enum,
    required_integer: required_integer,
    required_list: required_list,
    required_long: required_long,
    required_map: required_map,
    required_short: required_short,
    required_string: required_string,
    required_timestamp: required_timestamp,
  ))
}

pub fn decode_operation_with_required_members_with_defaults_output_struct_params() -> decode.Decoder(OperationWithRequiredMembersWithDefaultsOutput) {
  use required_blob <- decode.optional_field("requiredBlob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use required_boolean <- decode.optional_field("requiredBoolean", option.None, decode.optional(decode.bool))
  use required_byte <- decode.optional_field("requiredByte", option.None, decode.optional(decode.int))
  use required_double <- decode.optional_field("requiredDouble", option.None, decode.optional(json_float.decoder()))
  use required_enum <- decode.optional_field("requiredEnum", option.None, decode.optional(decode_required_enum_enum()))
  use required_float <- decode.optional_field("requiredFloat", option.None, decode.optional(json_float.decoder()))
  use required_int_enum <- decode.optional_field("requiredIntEnum", option.None, decode.optional(decode_required_int_enum_int_enum()))
  use required_integer <- decode.optional_field("requiredInteger", option.None, decode.optional(decode.int))
  use required_list <- decode.optional_field("requiredList", option.None, decode.optional(decode.list(decode.string)))
  use required_long <- decode.optional_field("requiredLong", option.None, decode.optional(decode.int))
  use required_map <- decode.optional_field("requiredMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use required_short <- decode.optional_field("requiredShort", option.None, decode.optional(decode.int))
  use required_string <- decode.optional_field("requiredString", option.None, decode.optional(decode.string))
  use required_timestamp <- decode.optional_field("requiredTimestamp", option.None, decode.optional(json_timestamp.decoder()))
  decode.success(OperationWithRequiredMembersWithDefaultsOutput(
    required_blob: required_blob,
    required_boolean: required_boolean,
    required_byte: required_byte,
    required_double: required_double,
    required_enum: required_enum,
    required_float: required_float,
    required_int_enum: required_int_enum,
    required_integer: required_integer,
    required_list: required_list,
    required_long: required_long,
    required_map: required_map,
    required_short: required_short,
    required_string: required_string,
    required_timestamp: required_timestamp,
  ))
}

pub type RequiredEnum {
  RequiredEnumBar
  RequiredEnumBaz
  RequiredEnumFoo
}

pub fn encode_required_enum_enum(v: RequiredEnum) -> json.Json {
  case v {
    RequiredEnumBar -> json.string("BAR")
    RequiredEnumBaz -> json.string("BAZ")
    RequiredEnumFoo -> json.string("FOO")
  }
}

pub fn decode_required_enum_enum() -> decode.Decoder(RequiredEnum) {
  decode.then(decode.string, fn(s) {
    case s {
      "BAR" -> decode.success(RequiredEnumBar)
      "BAZ" -> decode.success(RequiredEnumBaz)
      "FOO" -> decode.success(RequiredEnumFoo)
      _ -> decode.failure(RequiredEnumBar, "unknown enum value")
    }
  })
}

pub type RequiredIntEnum {
  RequiredIntEnumOne
  RequiredIntEnumTwo
}

pub fn encode_required_int_enum_int_enum(v: RequiredIntEnum) -> json.Json {
  case v {
    RequiredIntEnumOne -> json.int(1)
    RequiredIntEnumTwo -> json.int(2)
  }
}

pub fn decode_required_int_enum_int_enum() -> decode.Decoder(RequiredIntEnum) {
  decode.then(decode.int, fn(n) {
    case n {
      1 -> decode.success(RequiredIntEnumOne)
      2 -> decode.success(RequiredIntEnumTwo)
      _ -> decode.failure(RequiredIntEnumOne, "unknown int enum value")
    }
  })
}

pub type SimpleScalarPropertiesInput {
  SimpleScalarPropertiesInput(
    double_value: option.Option(json_float.SmithyFloat),
    float_value: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_simple_scalar_properties_input_struct(input: SimpleScalarPropertiesInput) -> json.Json {
  let pairs = []
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_simple_scalar_properties_input_struct_top(input: SimpleScalarPropertiesInput) -> json.Json {
  let pairs = []
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_simple_scalar_properties_input_struct() -> decode.Decoder(SimpleScalarPropertiesInput) {
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  decode.success(SimpleScalarPropertiesInput(
    double_value: double_value,
    float_value: float_value,
  ))
}

pub fn decode_simple_scalar_properties_input_struct_params() -> decode.Decoder(SimpleScalarPropertiesInput) {
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  decode.success(SimpleScalarPropertiesInput(
    double_value: double_value,
    float_value: float_value,
  ))
}

pub type SimpleScalarPropertiesOutput {
  SimpleScalarPropertiesOutput(
    double_value: option.Option(json_float.SmithyFloat),
    float_value: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_simple_scalar_properties_output_struct(input: SimpleScalarPropertiesOutput) -> json.Json {
  let pairs = []
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn encode_simple_scalar_properties_output_struct_top(input: SimpleScalarPropertiesOutput) -> json.Json {
  let pairs = []
  let pairs = case input.double_value {
    option.Some(v) -> [#("doubleValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_value {
    option.Some(v) -> [#("floatValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_simple_scalar_properties_output_struct() -> decode.Decoder(SimpleScalarPropertiesOutput) {
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  decode.success(SimpleScalarPropertiesOutput(
    double_value: double_value,
    float_value: float_value,
  ))
}

pub fn decode_simple_scalar_properties_output_struct_params() -> decode.Decoder(SimpleScalarPropertiesOutput) {
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  decode.success(SimpleScalarPropertiesOutput(
    double_value: double_value,
    float_value: float_value,
  ))
}


pub fn encode_content_type_parameters_input(input: ContentTypeParametersInput) -> String {
  json.to_string(encode_content_type_parameters_input_struct_top(input))
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

pub fn build_content_type_parameters_request(
  input: ContentTypeParametersInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_content_type_parameters_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.ContentTypeParameters"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_content_type_parameters_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ContentTypeParametersOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_content_type_parameters_output("{}")
      _ -> decode_content_type_parameters_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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


pub fn encode_empty_input_and_empty_output_input(input: EmptyInputAndEmptyOutputInput) -> String {
  json.to_string(encode_empty_input_and_empty_output_input_struct_top(input))
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

pub fn build_empty_input_and_empty_output_request(
  input: EmptyInputAndEmptyOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_empty_input_and_empty_output_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.EmptyInputAndEmptyOutput"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_empty_input_and_empty_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_empty_input_and_empty_output_output("{}")
      _ -> decode_empty_input_and_empty_output_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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

pub fn build_endpoint_operation_request(
  input: EndpointOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_endpoint_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.EndpointOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_endpoint_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EndpointOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_endpoint_operation_output("{}")
      _ -> decode_endpoint_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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


pub type EndpointWithHostLabelOperationOutput {
  EndpointWithHostLabelOperationOutput
}

pub fn encode_endpoint_with_host_label_operation_output_struct(_v: EndpointWithHostLabelOperationOutput) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_with_host_label_operation_output_struct() -> decode.Decoder(EndpointWithHostLabelOperationOutput) {
  decode.success(EndpointWithHostLabelOperationOutput)
}

pub fn encode_endpoint_with_host_label_operation_input(input: EndpointWithHostLabelOperationInput) -> String {
  json.to_string(encode_endpoint_with_host_label_operation_input_struct_top(input))
}

pub fn decode_endpoint_with_host_label_operation_input(body: String) -> Result(EndpointWithHostLabelOperationInput, String) {
  case json.parse(body, decode_endpoint_with_host_label_operation_input_struct_params()) {
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

pub fn build_endpoint_with_host_label_operation_request(
  input: EndpointWithHostLabelOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_endpoint_with_host_label_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.EndpointWithHostLabelOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_endpoint_with_host_label_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EndpointWithHostLabelOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_endpoint_with_host_label_operation_output("{}")
      _ -> decode_endpoint_with_host_label_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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


pub fn encode_greeting_with_errors_input(input: GreetingWithErrorsInput) -> String {
  json.to_string(encode_greeting_with_errors_input_struct_top(input))
}

pub fn decode_greeting_with_errors_input(body: String) -> Result(GreetingWithErrorsInput, String) {
  case json.parse(body, decode_greeting_with_errors_input_struct_params()) {
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

pub fn build_greeting_with_errors_request(
  input: GreetingWithErrorsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_greeting_with_errors_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.GreetingWithErrors"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_greeting_with_errors_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GreetingWithErrorsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_greeting_with_errors_output("{}")
      _ -> decode_greeting_with_errors_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type GreetingWithErrorsError {
  GreetingWithErrorsErrorComplexError(value: ComplexError)
  GreetingWithErrorsErrorFooError(value: FooError)
  GreetingWithErrorsErrorInvalidGreeting(value: InvalidGreeting)
  GreetingWithErrorsErrorTransport(reason: String)
  GreetingWithErrorsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_greeting_with_errors_error(err: awsjson_client.ClientError) -> GreetingWithErrorsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
        case awsjson_client.error_type_matches(et, "ComplexError") {
          True -> case bit_array.to_string(b) {
            Ok(text) -> case json.parse(text, decode_complex_error_struct()) {
              Ok(v) -> GreetingWithErrorsErrorComplexError(value: v)
              Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: text)
            }
            Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: "")
          }
          False ->         case awsjson_client.error_type_matches(et, "FooError") {
          True -> case bit_array.to_string(b) {
            Ok(text) -> case json.parse(text, decode_foo_error_struct()) {
              Ok(v) -> GreetingWithErrorsErrorFooError(value: v)
              Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: text)
            }
            Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: "")
          }
          False ->         case awsjson_client.error_type_matches(et, "InvalidGreeting") {
          True -> case bit_array.to_string(b) {
            Ok(text) -> case json.parse(text, decode_invalid_greeting_struct()) {
              Ok(v) -> GreetingWithErrorsErrorInvalidGreeting(value: v)
              Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: text)
            }
            Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: "")
          }
          False -> case bit_array.to_string(b) {
          Ok(text) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> GreetingWithErrorsErrorUnknown(error_type: et, status: s, body: "")
        }
        }
        }
        }
    }
    awsjson_client.TransportError(_) -> GreetingWithErrorsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> GreetingWithErrorsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> GreetingWithErrorsErrorTransport(reason: "decode: " <> r)
  }
}


pub type HostWithPathOperationInput {
  HostWithPathOperationInput
}

pub fn encode_host_with_path_operation_input_struct(_v: HostWithPathOperationInput) -> json.Json {
  json.object([])
}

pub fn decode_host_with_path_operation_input_struct() -> decode.Decoder(HostWithPathOperationInput) {
  decode.success(HostWithPathOperationInput)
}

pub type HostWithPathOperationOutput {
  HostWithPathOperationOutput
}

pub fn encode_host_with_path_operation_output_struct(_v: HostWithPathOperationOutput) -> json.Json {
  json.object([])
}

pub fn decode_host_with_path_operation_output_struct() -> decode.Decoder(HostWithPathOperationOutput) {
  decode.success(HostWithPathOperationOutput)
}

pub fn encode_host_with_path_operation_input(input: HostWithPathOperationInput) -> String {
  json.to_string(encode_host_with_path_operation_input_struct(input))
}

pub fn decode_host_with_path_operation_input(body: String) -> Result(HostWithPathOperationInput, String) {
  case json.parse(body, decode_host_with_path_operation_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_host_with_path_operation_output(body: String) -> Result(HostWithPathOperationOutput, String) {
  case json.parse(body, decode_host_with_path_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_host_with_path_operation_request(
  input: HostWithPathOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_host_with_path_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.HostWithPathOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_host_with_path_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HostWithPathOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_host_with_path_operation_output("{}")
      _ -> decode_host_with_path_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HostWithPathOperationError {
  HostWithPathOperationErrorTransport(reason: String)
  HostWithPathOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_host_with_path_operation_error(err: awsjson_client.ClientError) -> HostWithPathOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> HostWithPathOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> HostWithPathOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> HostWithPathOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> HostWithPathOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> HostWithPathOperationErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_json_unions_input(input: JsonUnionsInput) -> String {
  json.to_string(encode_json_unions_input_struct_top(input))
}

pub fn decode_json_unions_input(body: String) -> Result(JsonUnionsInput, String) {
  case json.parse(body, decode_json_unions_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_unions_output(body: String) -> Result(JsonUnionsOutput, String) {
  case json.parse(body, decode_json_unions_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_json_unions_request(
  input: JsonUnionsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_json_unions_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.JsonUnions"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_json_unions_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonUnionsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_json_unions_output("{}")
      _ -> decode_json_unions_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type JsonUnionsError {
  JsonUnionsErrorTransport(reason: String)
  JsonUnionsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_json_unions_error(err: awsjson_client.ClientError) -> JsonUnionsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> JsonUnionsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> JsonUnionsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> JsonUnionsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> JsonUnionsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> JsonUnionsErrorTransport(reason: "decode: " <> r)
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

pub fn build_no_input_and_no_output_request(
  input: NoInputAndNoOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_no_input_and_no_output_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.NoInputAndNoOutput"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_no_input_and_no_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NoInputAndNoOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_no_input_and_no_output_output("{}")
      _ -> decode_no_input_and_no_output_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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

pub fn build_no_input_and_output_request(
  input: NoInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_no_input_and_output_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.NoInputAndOutput"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_no_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NoInputAndOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_no_input_and_output_output("{}")
      _ -> decode_no_input_and_output_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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


pub fn encode_operation_with_defaults_input(input: OperationWithDefaultsInput) -> String {
  json.to_string(encode_operation_with_defaults_input_struct_top(input))
}

pub fn decode_operation_with_defaults_input(body: String) -> Result(OperationWithDefaultsInput, String) {
  case json.parse(body, decode_operation_with_defaults_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_defaults_output(body: String) -> Result(OperationWithDefaultsOutput, String) {
  case json.parse(body, decode_operation_with_defaults_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_operation_with_defaults_request(
  input: OperationWithDefaultsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_operation_with_defaults_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.OperationWithDefaults"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_operation_with_defaults_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithDefaultsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_operation_with_defaults_output("{}")
      _ -> decode_operation_with_defaults_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OperationWithDefaultsError {
  OperationWithDefaultsErrorTransport(reason: String)
  OperationWithDefaultsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_operation_with_defaults_error(err: awsjson_client.ClientError) -> OperationWithDefaultsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> OperationWithDefaultsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> OperationWithDefaultsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> OperationWithDefaultsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> OperationWithDefaultsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> OperationWithDefaultsErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_operation_with_nested_structure_input(input: OperationWithNestedStructureInput) -> String {
  json.to_string(encode_operation_with_nested_structure_input_struct_top(input))
}

pub fn decode_operation_with_nested_structure_input(body: String) -> Result(OperationWithNestedStructureInput, String) {
  case json.parse(body, decode_operation_with_nested_structure_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_nested_structure_output(body: String) -> Result(OperationWithNestedStructureOutput, String) {
  case json.parse(body, decode_operation_with_nested_structure_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_operation_with_nested_structure_request(
  input: OperationWithNestedStructureInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_operation_with_nested_structure_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.OperationWithNestedStructure"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_operation_with_nested_structure_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithNestedStructureOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_operation_with_nested_structure_output("{}")
      _ -> decode_operation_with_nested_structure_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OperationWithNestedStructureError {
  OperationWithNestedStructureErrorTransport(reason: String)
  OperationWithNestedStructureErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_operation_with_nested_structure_error(err: awsjson_client.ClientError) -> OperationWithNestedStructureError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> OperationWithNestedStructureErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> OperationWithNestedStructureErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> OperationWithNestedStructureErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> OperationWithNestedStructureErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> OperationWithNestedStructureErrorTransport(reason: "decode: " <> r)
  }
}


pub type OperationWithRequiredMembersInput {
  OperationWithRequiredMembersInput
}

pub fn encode_operation_with_required_members_input_struct(_v: OperationWithRequiredMembersInput) -> json.Json {
  json.object([])
}

pub fn decode_operation_with_required_members_input_struct() -> decode.Decoder(OperationWithRequiredMembersInput) {
  decode.success(OperationWithRequiredMembersInput)
}

pub fn encode_operation_with_required_members_input(input: OperationWithRequiredMembersInput) -> String {
  json.to_string(encode_operation_with_required_members_input_struct(input))
}

pub fn decode_operation_with_required_members_input(body: String) -> Result(OperationWithRequiredMembersInput, String) {
  case json.parse(body, decode_operation_with_required_members_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_required_members_output(body: String) -> Result(OperationWithRequiredMembersOutput, String) {
  case json.parse(body, decode_operation_with_required_members_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_operation_with_required_members_request(
  input: OperationWithRequiredMembersInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_operation_with_required_members_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.OperationWithRequiredMembers"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_operation_with_required_members_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithRequiredMembersOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_operation_with_required_members_output("{}")
      _ -> decode_operation_with_required_members_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OperationWithRequiredMembersError {
  OperationWithRequiredMembersErrorTransport(reason: String)
  OperationWithRequiredMembersErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_operation_with_required_members_error(err: awsjson_client.ClientError) -> OperationWithRequiredMembersError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> OperationWithRequiredMembersErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> OperationWithRequiredMembersErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> OperationWithRequiredMembersErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> OperationWithRequiredMembersErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> OperationWithRequiredMembersErrorTransport(reason: "decode: " <> r)
  }
}


pub type OperationWithRequiredMembersWithDefaultsInput {
  OperationWithRequiredMembersWithDefaultsInput
}

pub fn encode_operation_with_required_members_with_defaults_input_struct(_v: OperationWithRequiredMembersWithDefaultsInput) -> json.Json {
  json.object([])
}

pub fn decode_operation_with_required_members_with_defaults_input_struct() -> decode.Decoder(OperationWithRequiredMembersWithDefaultsInput) {
  decode.success(OperationWithRequiredMembersWithDefaultsInput)
}

pub fn encode_operation_with_required_members_with_defaults_input(input: OperationWithRequiredMembersWithDefaultsInput) -> String {
  json.to_string(encode_operation_with_required_members_with_defaults_input_struct(input))
}

pub fn decode_operation_with_required_members_with_defaults_input(body: String) -> Result(OperationWithRequiredMembersWithDefaultsInput, String) {
  case json.parse(body, decode_operation_with_required_members_with_defaults_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_required_members_with_defaults_output(body: String) -> Result(OperationWithRequiredMembersWithDefaultsOutput, String) {
  case json.parse(body, decode_operation_with_required_members_with_defaults_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_operation_with_required_members_with_defaults_request(
  input: OperationWithRequiredMembersWithDefaultsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_operation_with_required_members_with_defaults_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.OperationWithRequiredMembersWithDefaults"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_operation_with_required_members_with_defaults_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithRequiredMembersWithDefaultsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_operation_with_required_members_with_defaults_output("{}")
      _ -> decode_operation_with_required_members_with_defaults_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OperationWithRequiredMembersWithDefaultsError {
  OperationWithRequiredMembersWithDefaultsErrorTransport(reason: String)
  OperationWithRequiredMembersWithDefaultsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_operation_with_required_members_with_defaults_error(err: awsjson_client.ClientError) -> OperationWithRequiredMembersWithDefaultsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> OperationWithRequiredMembersWithDefaultsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> OperationWithRequiredMembersWithDefaultsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> OperationWithRequiredMembersWithDefaultsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> OperationWithRequiredMembersWithDefaultsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> OperationWithRequiredMembersWithDefaultsErrorTransport(reason: "decode: " <> r)
  }
}


pub type QueryIncompatibleOperationInput {
  QueryIncompatibleOperationInput
}

pub fn encode_query_incompatible_operation_input_struct(_v: QueryIncompatibleOperationInput) -> json.Json {
  json.object([])
}

pub fn decode_query_incompatible_operation_input_struct() -> decode.Decoder(QueryIncompatibleOperationInput) {
  decode.success(QueryIncompatibleOperationInput)
}

pub type QueryIncompatibleOperationOutput {
  QueryIncompatibleOperationOutput
}

pub fn encode_query_incompatible_operation_output_struct(_v: QueryIncompatibleOperationOutput) -> json.Json {
  json.object([])
}

pub fn decode_query_incompatible_operation_output_struct() -> decode.Decoder(QueryIncompatibleOperationOutput) {
  decode.success(QueryIncompatibleOperationOutput)
}

pub fn encode_query_incompatible_operation_input(input: QueryIncompatibleOperationInput) -> String {
  json.to_string(encode_query_incompatible_operation_input_struct(input))
}

pub fn decode_query_incompatible_operation_input(body: String) -> Result(QueryIncompatibleOperationInput, String) {
  case json.parse(body, decode_query_incompatible_operation_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_incompatible_operation_output(body: String) -> Result(QueryIncompatibleOperationOutput, String) {
  case json.parse(body, decode_query_incompatible_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_query_incompatible_operation_request(
  input: QueryIncompatibleOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_query_incompatible_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.QueryIncompatibleOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_query_incompatible_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(QueryIncompatibleOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_query_incompatible_operation_output("{}")
      _ -> decode_query_incompatible_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type QueryIncompatibleOperationError {
  QueryIncompatibleOperationErrorTransport(reason: String)
  QueryIncompatibleOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_query_incompatible_operation_error(err: awsjson_client.ClientError) -> QueryIncompatibleOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> QueryIncompatibleOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> QueryIncompatibleOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> QueryIncompatibleOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> QueryIncompatibleOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> QueryIncompatibleOperationErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_simple_scalar_properties_input(input: SimpleScalarPropertiesInput) -> String {
  json.to_string(encode_simple_scalar_properties_input_struct_top(input))
}

pub fn decode_simple_scalar_properties_input(body: String) -> Result(SimpleScalarPropertiesInput, String) {
  case json.parse(body, decode_simple_scalar_properties_input_struct_params()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_simple_scalar_properties_output(body: String) -> Result(SimpleScalarPropertiesOutput, String) {
  case json.parse(body, decode_simple_scalar_properties_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_simple_scalar_properties_request(
  input: SimpleScalarPropertiesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_simple_scalar_properties_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonRpc10.SimpleScalarProperties"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_simple_scalar_properties_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SimpleScalarPropertiesOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_simple_scalar_properties_output("{}")
      _ -> decode_simple_scalar_properties_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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

/// Invoke ContentTypeParameters. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `ContentTypeParametersError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `ContentTypeParametersErrorTransport` variant.
pub fn content_type_parameters(
  client: Client,
  input: ContentTypeParametersInput,
) -> Result(ContentTypeParametersOutput, ContentTypeParametersError) {
  case awsjson_client.invoke(
    client.config,
    build_content_type_parameters_request(input),
    parse_content_type_parameters_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_content_type_parameters_error(err))
  }
}

/// Invoke EmptyInputAndEmptyOutput. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `EmptyInputAndEmptyOutputError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `EmptyInputAndEmptyOutputErrorTransport` variant.
pub fn empty_input_and_empty_output(
  client: Client,
  input: EmptyInputAndEmptyOutputInput,
) -> Result(EmptyInputAndEmptyOutputOutput, EmptyInputAndEmptyOutputError) {
  case awsjson_client.invoke(
    client.config,
    build_empty_input_and_empty_output_request(input),
    parse_empty_input_and_empty_output_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_empty_input_and_empty_output_error(err))
  }
}

/// Invoke EndpointOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `EndpointOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `EndpointOperationErrorTransport` variant.
pub fn endpoint_operation(
  client: Client,
  input: EndpointOperationInput,
) -> Result(EndpointOperationOutput, EndpointOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_endpoint_operation_request(input),
    parse_endpoint_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_endpoint_operation_error(err))
  }
}

/// Invoke EndpointWithHostLabelOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `EndpointWithHostLabelOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `EndpointWithHostLabelOperationErrorTransport` variant.
pub fn endpoint_with_host_label_operation(
  client: Client,
  input: EndpointWithHostLabelOperationInput,
) -> Result(EndpointWithHostLabelOperationOutput, EndpointWithHostLabelOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_endpoint_with_host_label_operation_request(input),
    parse_endpoint_with_host_label_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_endpoint_with_host_label_operation_error(err))
  }
}

/// Invoke GreetingWithErrors. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `GreetingWithErrorsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `GreetingWithErrorsErrorTransport` variant.
pub fn greeting_with_errors(
  client: Client,
  input: GreetingWithErrorsInput,
) -> Result(GreetingWithErrorsOutput, GreetingWithErrorsError) {
  case awsjson_client.invoke(
    client.config,
    build_greeting_with_errors_request(input),
    parse_greeting_with_errors_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_greeting_with_errors_error(err))
  }
}

/// Invoke HostWithPathOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `HostWithPathOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `HostWithPathOperationErrorTransport` variant.
pub fn host_with_path_operation(
  client: Client,
  input: HostWithPathOperationInput,
) -> Result(HostWithPathOperationOutput, HostWithPathOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_host_with_path_operation_request(input),
    parse_host_with_path_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_host_with_path_operation_error(err))
  }
}

/// Invoke JsonUnions. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `JsonUnionsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `JsonUnionsErrorTransport` variant.
pub fn json_unions(
  client: Client,
  input: JsonUnionsInput,
) -> Result(JsonUnionsOutput, JsonUnionsError) {
  case awsjson_client.invoke(
    client.config,
    build_json_unions_request(input),
    parse_json_unions_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_json_unions_error(err))
  }
}

/// Invoke NoInputAndNoOutput. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `NoInputAndNoOutputError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `NoInputAndNoOutputErrorTransport` variant.
pub fn no_input_and_no_output(
  client: Client,
  input: NoInputAndNoOutputInput,
) -> Result(NoInputAndNoOutputOutput, NoInputAndNoOutputError) {
  case awsjson_client.invoke(
    client.config,
    build_no_input_and_no_output_request(input),
    parse_no_input_and_no_output_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_no_input_and_no_output_error(err))
  }
}

/// Invoke NoInputAndOutput. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `NoInputAndOutputError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `NoInputAndOutputErrorTransport` variant.
pub fn no_input_and_output(
  client: Client,
  input: NoInputAndOutputInput,
) -> Result(NoInputAndOutputOutput, NoInputAndOutputError) {
  case awsjson_client.invoke(
    client.config,
    build_no_input_and_output_request(input),
    parse_no_input_and_output_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_no_input_and_output_error(err))
  }
}

/// Invoke OperationWithDefaults. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `OperationWithDefaultsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `OperationWithDefaultsErrorTransport` variant.
pub fn operation_with_defaults(
  client: Client,
  input: OperationWithDefaultsInput,
) -> Result(OperationWithDefaultsOutput, OperationWithDefaultsError) {
  case awsjson_client.invoke(
    client.config,
    build_operation_with_defaults_request(input),
    parse_operation_with_defaults_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_operation_with_defaults_error(err))
  }
}

/// Invoke OperationWithNestedStructure. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `OperationWithNestedStructureError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `OperationWithNestedStructureErrorTransport` variant.
pub fn operation_with_nested_structure(
  client: Client,
  input: OperationWithNestedStructureInput,
) -> Result(OperationWithNestedStructureOutput, OperationWithNestedStructureError) {
  case awsjson_client.invoke(
    client.config,
    build_operation_with_nested_structure_request(input),
    parse_operation_with_nested_structure_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_operation_with_nested_structure_error(err))
  }
}

/// Invoke OperationWithRequiredMembers. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `OperationWithRequiredMembersError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `OperationWithRequiredMembersErrorTransport` variant.
pub fn operation_with_required_members(
  client: Client,
  input: OperationWithRequiredMembersInput,
) -> Result(OperationWithRequiredMembersOutput, OperationWithRequiredMembersError) {
  case awsjson_client.invoke(
    client.config,
    build_operation_with_required_members_request(input),
    parse_operation_with_required_members_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_operation_with_required_members_error(err))
  }
}

/// Invoke OperationWithRequiredMembersWithDefaults. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `OperationWithRequiredMembersWithDefaultsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `OperationWithRequiredMembersWithDefaultsErrorTransport` variant.
pub fn operation_with_required_members_with_defaults(
  client: Client,
  input: OperationWithRequiredMembersWithDefaultsInput,
) -> Result(OperationWithRequiredMembersWithDefaultsOutput, OperationWithRequiredMembersWithDefaultsError) {
  case awsjson_client.invoke(
    client.config,
    build_operation_with_required_members_with_defaults_request(input),
    parse_operation_with_required_members_with_defaults_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_operation_with_required_members_with_defaults_error(err))
  }
}

/// Invoke QueryIncompatibleOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `QueryIncompatibleOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `QueryIncompatibleOperationErrorTransport` variant.
pub fn query_incompatible_operation(
  client: Client,
  input: QueryIncompatibleOperationInput,
) -> Result(QueryIncompatibleOperationOutput, QueryIncompatibleOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_query_incompatible_operation_request(input),
    parse_query_incompatible_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_query_incompatible_operation_error(err))
  }
}

/// Invoke SimpleScalarProperties. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `SimpleScalarPropertiesError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `SimpleScalarPropertiesErrorTransport` variant.
pub fn simple_scalar_properties(
  client: Client,
  input: SimpleScalarPropertiesInput,
) -> Result(SimpleScalarPropertiesOutput, SimpleScalarPropertiesError) {
  case awsjson_client.invoke(
    client.config,
    build_simple_scalar_properties_request(input),
    parse_simple_scalar_properties_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_simple_scalar_properties_error(err))
  }
}

