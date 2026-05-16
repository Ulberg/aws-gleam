//// Generated from aws.protocoltests.json#JsonProtocol (awsJson1_1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/credentials
import aws/internal/client/awsjson as awsjson_client
import aws/internal/codec/json_float
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

/// Build a Client given a credentials provider and an AWS region. The
/// generated module hard-codes the service's endpoint prefix and SigV4
/// signing name; everything else is configurable via the `with_*`
/// helpers below.
pub fn new(
  provider provider: credentials.Provider,
  region region: String,
) -> Client {
  Client(config: awsjson_client.default_config(
    provider,
    region,
    "jsonprotocol",
    "jsonprotocol",
  ))
}

/// Override the endpoint URL (LocalStack, FIPS endpoints, custom DNS).
pub fn with_endpoint_url(client: Client, url: String) -> Client {
  Client(config: awsjson_client.with_endpoint_url(client.config, url))
}

/// Swap the HTTP transport — useful for canned-response test doubles.
pub fn with_http_send(
  client: Client,
  send: http_send.Send,
) -> Client {
  Client(config: awsjson_client.with_http_send(client.config, send))
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

pub fn decode_content_type_parameters_input_struct() -> decode.Decoder(ContentTypeParametersInput) {
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

pub fn decode_content_type_parameters_output_struct() -> decode.Decoder(ContentTypeParametersOutput) {
  decode.success(ContentTypeParametersOutput)
}

pub type DatetimeOffsetsOutput {
  DatetimeOffsetsOutput(
    datetime: option.Option(Int),
  )
}

pub fn encode_datetime_offsets_output_struct(input: DatetimeOffsetsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.datetime {
    option.Some(v) -> [#("datetime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_datetime_offsets_output_struct() -> decode.Decoder(DatetimeOffsetsOutput) {
  use datetime <- decode.optional_field("datetime", option.None, decode.optional(decode.int))
  decode.success(DatetimeOffsetsOutput(
    datetime: datetime,
  ))
}

pub type HostLabelInput {
  HostLabelInput(
    label: option.Option(String),
  )
}

pub fn encode_host_label_input_struct(input: HostLabelInput) -> json.Json {
  let pairs = []
  let pairs = case input.label {
    option.Some(v) -> [#("label", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_host_label_input_struct() -> decode.Decoder(HostLabelInput) {
  use label <- decode.optional_field("label", option.None, decode.optional(decode.string))
  decode.success(HostLabelInput(
    label: label,
  ))
}

pub type FractionalSecondsOutput {
  FractionalSecondsOutput(
    datetime: option.Option(Int),
  )
}

pub fn encode_fractional_seconds_output_struct(input: FractionalSecondsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.datetime {
    option.Some(v) -> [#("datetime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_fractional_seconds_output_struct() -> decode.Decoder(FractionalSecondsOutput) {
  use datetime <- decode.optional_field("datetime", option.None, decode.optional(decode.int))
  decode.success(FractionalSecondsOutput(
    datetime: datetime,
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

pub fn decode_greeting_with_errors_output_struct() -> decode.Decoder(GreetingWithErrorsOutput) {
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

pub fn decode_complex_error_struct() -> decode.Decoder(ComplexError) {
  use nested <- decode.optional_field("Nested", option.None, decode.optional(decode_complex_nested_error_data_struct()))
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

pub fn decode_complex_nested_error_data_struct() -> decode.Decoder(ComplexNestedErrorData) {
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

pub fn decode_foo_error_struct() -> decode.Decoder(FooError) {
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

pub fn decode_invalid_greeting_struct() -> decode.Decoder(InvalidGreeting) {
  use message <- decode.optional_field("Message", option.None, decode.optional(decode.string))
  decode.success(InvalidGreeting(
    message: message,
  ))
}

pub type JsonEnumsInputOutput {
  JsonEnumsInputOutput(
    foo_enum1: option.Option(FooEnum),
    foo_enum2: option.Option(FooEnum),
    foo_enum3: option.Option(FooEnum),
    foo_enum_list: option.Option(List(FooEnum)),
    foo_enum_map: option.Option(dict.Dict(String, FooEnum)),
    foo_enum_set: option.Option(List(FooEnum)),
  )
}

pub fn encode_json_enums_input_output_struct(input: JsonEnumsInputOutput) -> json.Json {
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

pub fn decode_json_enums_input_output_struct() -> decode.Decoder(JsonEnumsInputOutput) {
  use foo_enum1 <- decode.optional_field("fooEnum1", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum2 <- decode.optional_field("fooEnum2", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum3 <- decode.optional_field("fooEnum3", option.None, decode.optional(decode_foo_enum_enum()))
  use foo_enum_list <- decode.optional_field("fooEnumList", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  use foo_enum_map <- decode.optional_field("fooEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_foo_enum_enum())))
  use foo_enum_set <- decode.optional_field("fooEnumSet", option.None, decode.optional(decode.list(decode_foo_enum_enum())))
  decode.success(JsonEnumsInputOutput(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
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

pub type JsonIntEnumsInputOutput {
  JsonIntEnumsInputOutput(
    int_enum1: option.Option(IntegerEnum),
    int_enum2: option.Option(IntegerEnum),
    int_enum3: option.Option(IntegerEnum),
    int_enum_list: option.Option(List(IntegerEnum)),
    int_enum_map: option.Option(dict.Dict(String, IntegerEnum)),
    int_enum_set: option.Option(List(IntegerEnum)),
  )
}

pub fn encode_json_int_enums_input_output_struct(input: JsonIntEnumsInputOutput) -> json.Json {
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

pub fn decode_json_int_enums_input_output_struct() -> decode.Decoder(JsonIntEnumsInputOutput) {
  use int_enum1 <- decode.optional_field("intEnum1", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum2 <- decode.optional_field("intEnum2", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum3 <- decode.optional_field("intEnum3", option.None, decode.optional(decode_integer_enum_int_enum()))
  use int_enum_list <- decode.optional_field("intEnumList", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  use int_enum_map <- decode.optional_field("intEnumMap", option.None, decode.optional(decode.dict(decode.string, decode_integer_enum_int_enum())))
  use int_enum_set <- decode.optional_field("intEnumSet", option.None, decode.optional(decode.list(decode_integer_enum_int_enum())))
  decode.success(JsonIntEnumsInputOutput(
    int_enum1: int_enum1,
    int_enum2: int_enum2,
    int_enum3: int_enum3,
    int_enum_list: int_enum_list,
    int_enum_map: int_enum_map,
    int_enum_set: int_enum_set,
  ))
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

pub type UnionInputOutput {
  UnionInputOutput(
    contents: option.Option(MyUnion),
  )
}

pub fn encode_union_input_output_struct(input: UnionInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.contents {
    option.Some(v) -> [#("contents", encode_my_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_union_input_output_struct() -> decode.Decoder(UnionInputOutput) {
  use contents <- decode.optional_field("contents", option.None, decode.optional(decode_my_union_union()))
  decode.success(UnionInputOutput(
    contents: contents,
  ))
}

pub type MyUnion {
  MyUnionBlobValue(BitArray)
  MyUnionBooleanValue(Bool)
  MyUnionEnumValue(FooEnum)
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
      decode.field("listValue", decode.list(decode.string), fn(x) { decode.success(MyUnionListValue(x)) }),
      decode.field("mapValue", decode.dict(decode.string, decode.string), fn(x) { decode.success(MyUnionMapValue(x)) }),
      decode.field("numberValue", decode.int, fn(x) { decode.success(MyUnionNumberValue(x)) }),
      decode.field("stringValue", decode.string, fn(x) { decode.success(MyUnionStringValue(x)) }),
      decode.field("structureValue", decode_greeting_struct_struct(), fn(x) { decode.success(MyUnionStructureValue(x)) }),
      decode.field("timestampValue", decode.int, fn(x) { decode.success(MyUnionTimestampValue(x)) }),
    ],
  )
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

pub fn decode_greeting_struct_struct() -> decode.Decoder(GreetingStruct) {
  use hi <- decode.optional_field("hi", option.None, decode.optional(decode.string))
  decode.success(GreetingStruct(
    hi: hi,
  ))
}

pub type KitchenSink {
  KitchenSink(
    blob: option.Option(BitArray),
    boolean: option.Option(Bool),
    double: option.Option(json_float.SmithyFloat),
    empty_struct: option.Option(EmptyStruct),
    float: option.Option(json_float.SmithyFloat),
    httpdate_timestamp: option.Option(Int),
    integer: option.Option(Int),
    iso8601_timestamp: option.Option(Int),
    json_value: option.Option(String),
    list_of_lists: option.Option(List(List(String))),
    list_of_maps_of_strings: option.Option(List(dict.Dict(String, String))),
    list_of_strings: option.Option(List(String)),
    list_of_structs: option.Option(List(SimpleStruct)),
    long: option.Option(Int),
    map_of_lists_of_strings: option.Option(dict.Dict(String, List(String))),
    map_of_maps: option.Option(dict.Dict(String, dict.Dict(String, String))),
    map_of_strings: option.Option(dict.Dict(String, String)),
    map_of_structs: option.Option(dict.Dict(String, SimpleStruct)),
    recursive_list: option.Option(List(KitchenSink)),
    recursive_map: option.Option(dict.Dict(String, KitchenSink)),
    recursive_struct: option.Option(KitchenSink),
    simple_struct: option.Option(SimpleStruct),
    string: option.Option(String),
    struct_with_json_name: option.Option(StructWithJsonName),
    timestamp: option.Option(Int),
    unix_timestamp: option.Option(Int),
  )
}

pub fn encode_kitchen_sink_struct(input: KitchenSink) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [#("Blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.boolean {
    option.Some(v) -> [#("Boolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double {
    option.Some(v) -> [#("Double", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.empty_struct {
    option.Some(v) -> [#("EmptyStruct", encode_empty_struct_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float {
    option.Some(v) -> [#("Float", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.httpdate_timestamp {
    option.Some(v) -> [#("HttpdateTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer {
    option.Some(v) -> [#("Integer", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.iso8601_timestamp {
    option.Some(v) -> [#("Iso8601Timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.json_value {
    option.Some(v) -> [#("JsonValue", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.list_of_lists {
    option.Some(v) -> [#("ListOfLists", fn(xs) { json.array(xs, fn(xs) { json.array(xs, json.string) }) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.list_of_maps_of_strings {
    option.Some(v) -> [#("ListOfMapsOfStrings", fn(xs) { json.array(xs, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.list_of_strings {
    option.Some(v) -> [#("ListOfStrings", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.list_of_structs {
    option.Some(v) -> [#("ListOfStructs", fn(xs) { json.array(xs, encode_simple_struct_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long {
    option.Some(v) -> [#("Long", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.map_of_lists_of_strings {
    option.Some(v) -> [#("MapOfListsOfStrings", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.map_of_maps {
    option.Some(v) -> [#("MapOfMaps", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.map_of_strings {
    option.Some(v) -> [#("MapOfStrings", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.map_of_structs {
    option.Some(v) -> [#("MapOfStructs", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_simple_struct_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.recursive_list {
    option.Some(v) -> [#("RecursiveList", fn(xs) { json.array(xs, encode_kitchen_sink_struct) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.recursive_map {
    option.Some(v) -> [#("RecursiveMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, encode_kitchen_sink_struct(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.recursive_struct {
    option.Some(v) -> [#("RecursiveStruct", encode_kitchen_sink_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.simple_struct {
    option.Some(v) -> [#("SimpleStruct", encode_simple_struct_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string {
    option.Some(v) -> [#("String", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.struct_with_json_name {
    option.Some(v) -> [#("StructWithJsonName", encode_struct_with_json_name_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.timestamp {
    option.Some(v) -> [#("Timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.unix_timestamp {
    option.Some(v) -> [#("UnixTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_kitchen_sink_struct() -> decode.Decoder(KitchenSink) {
  use blob <- decode.optional_field("Blob", option.None, decode.optional(decode.then(decode.string, fn(s) { decode.success(bit_array.from_string(s)) })))
  use boolean <- decode.optional_field("Boolean", option.None, decode.optional(decode.bool))
  use double <- decode.optional_field("Double", option.None, decode.optional(json_float.decoder()))
  use empty_struct <- decode.optional_field("EmptyStruct", option.None, decode.optional(decode_empty_struct_struct()))
  use float <- decode.optional_field("Float", option.None, decode.optional(json_float.decoder()))
  use httpdate_timestamp <- decode.optional_field("HttpdateTimestamp", option.None, decode.optional(decode.int))
  use integer <- decode.optional_field("Integer", option.None, decode.optional(decode.int))
  use iso8601_timestamp <- decode.optional_field("Iso8601Timestamp", option.None, decode.optional(decode.int))
  use json_value <- decode.optional_field("JsonValue", option.None, decode.optional(decode.string))
  use list_of_lists <- decode.optional_field("ListOfLists", option.None, decode.optional(decode.list(decode.list(decode.string))))
  use list_of_maps_of_strings <- decode.optional_field("ListOfMapsOfStrings", option.None, decode.optional(decode.list(decode.dict(decode.string, decode.string))))
  use list_of_strings <- decode.optional_field("ListOfStrings", option.None, decode.optional(decode.list(decode.string)))
  use list_of_structs <- decode.optional_field("ListOfStructs", option.None, decode.optional(decode.list(decode_simple_struct_struct())))
  use long <- decode.optional_field("Long", option.None, decode.optional(decode.int))
  use map_of_lists_of_strings <- decode.optional_field("MapOfListsOfStrings", option.None, decode.optional(decode.dict(decode.string, decode.list(decode.string))))
  use map_of_maps <- decode.optional_field("MapOfMaps", option.None, decode.optional(decode.dict(decode.string, decode.dict(decode.string, decode.string))))
  use map_of_strings <- decode.optional_field("MapOfStrings", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use map_of_structs <- decode.optional_field("MapOfStructs", option.None, decode.optional(decode.dict(decode.string, decode_simple_struct_struct())))
  use recursive_list <- decode.optional_field("RecursiveList", option.None, decode.optional(decode.list(decode_kitchen_sink_struct())))
  use recursive_map <- decode.optional_field("RecursiveMap", option.None, decode.optional(decode.dict(decode.string, decode_kitchen_sink_struct())))
  use recursive_struct <- decode.optional_field("RecursiveStruct", option.None, decode.optional(decode_kitchen_sink_struct()))
  use simple_struct <- decode.optional_field("SimpleStruct", option.None, decode.optional(decode_simple_struct_struct()))
  use string <- decode.optional_field("String", option.None, decode.optional(decode.string))
  use struct_with_json_name <- decode.optional_field("StructWithJsonName", option.None, decode.optional(decode_struct_with_json_name_struct()))
  use timestamp <- decode.optional_field("Timestamp", option.None, decode.optional(decode.int))
  use unix_timestamp <- decode.optional_field("UnixTimestamp", option.None, decode.optional(decode.int))
  decode.success(KitchenSink(
    blob: blob,
    boolean: boolean,
    double: double,
    empty_struct: empty_struct,
    float: float,
    httpdate_timestamp: httpdate_timestamp,
    integer: integer,
    iso8601_timestamp: iso8601_timestamp,
    json_value: json_value,
    list_of_lists: list_of_lists,
    list_of_maps_of_strings: list_of_maps_of_strings,
    list_of_strings: list_of_strings,
    list_of_structs: list_of_structs,
    long: long,
    map_of_lists_of_strings: map_of_lists_of_strings,
    map_of_maps: map_of_maps,
    map_of_strings: map_of_strings,
    map_of_structs: map_of_structs,
    recursive_list: recursive_list,
    recursive_map: recursive_map,
    recursive_struct: recursive_struct,
    simple_struct: simple_struct,
    string: string,
    struct_with_json_name: struct_with_json_name,
    timestamp: timestamp,
    unix_timestamp: unix_timestamp,
  ))
}

pub type EmptyStruct {
  EmptyStruct
}

pub fn encode_empty_struct_struct(_v: EmptyStruct) -> json.Json {
  json.object([])
}

pub fn decode_empty_struct_struct() -> decode.Decoder(EmptyStruct) {
  decode.success(EmptyStruct)
}

pub type SimpleStruct {
  SimpleStruct(
    value: option.Option(String),
  )
}

pub fn encode_simple_struct_struct(input: SimpleStruct) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_simple_struct_struct() -> decode.Decoder(SimpleStruct) {
  use value <- decode.optional_field("Value", option.None, decode.optional(decode.string))
  decode.success(SimpleStruct(
    value: value,
  ))
}

pub type StructWithJsonName {
  StructWithJsonName(
    value: option.Option(String),
  )
}

pub fn encode_struct_with_json_name_struct(input: StructWithJsonName) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_struct_with_json_name_struct() -> decode.Decoder(StructWithJsonName) {
  use value <- decode.optional_field("Value", option.None, decode.optional(decode.string))
  decode.success(StructWithJsonName(
    value: value,
  ))
}

pub type ErrorWithMembers {
  ErrorWithMembers(
    code: option.Option(String),
    complex_data: option.Option(KitchenSink),
    integer_field: option.Option(Int),
    list_field: option.Option(List(String)),
    map_field: option.Option(dict.Dict(String, String)),
    message: option.Option(String),
    string_field: option.Option(String),
  )
}

pub fn encode_error_with_members_struct(input: ErrorWithMembers) -> json.Json {
  let pairs = []
  let pairs = case input.code {
    option.Some(v) -> [#("Code", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.complex_data {
    option.Some(v) -> [#("ComplexData", encode_kitchen_sink_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_field {
    option.Some(v) -> [#("IntegerField", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.list_field {
    option.Some(v) -> [#("ListField", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.map_field {
    option.Some(v) -> [#("MapField", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.message {
    option.Some(v) -> [#("Message", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_field {
    option.Some(v) -> [#("StringField", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_error_with_members_struct() -> decode.Decoder(ErrorWithMembers) {
  use code <- decode.optional_field("Code", option.None, decode.optional(decode.string))
  use complex_data <- decode.optional_field("ComplexData", option.None, decode.optional(decode_kitchen_sink_struct()))
  use integer_field <- decode.optional_field("IntegerField", option.None, decode.optional(decode.int))
  use list_field <- decode.optional_field("ListField", option.None, decode.optional(decode.list(decode.string)))
  use map_field <- decode.optional_field("MapField", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  use message <- decode.optional_field("Message", option.None, decode.optional(decode.string))
  use string_field <- decode.optional_field("StringField", option.None, decode.optional(decode.string))
  decode.success(ErrorWithMembers(
    code: code,
    complex_data: complex_data,
    integer_field: integer_field,
    list_field: list_field,
    map_field: map_field,
    message: message,
    string_field: string_field,
  ))
}

pub type ErrorWithoutMembers {
  ErrorWithoutMembers
}

pub fn encode_error_without_members_struct(_v: ErrorWithoutMembers) -> json.Json {
  json.object([])
}

pub fn decode_error_without_members_struct() -> decode.Decoder(ErrorWithoutMembers) {
  decode.success(ErrorWithoutMembers)
}

pub type NullOperationInputOutput {
  NullOperationInputOutput(
    string: option.Option(String),
  )
}

pub fn encode_null_operation_input_output_struct(input: NullOperationInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.string {
    option.Some(v) -> [#("string", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_null_operation_input_output_struct() -> decode.Decoder(NullOperationInputOutput) {
  use string <- decode.optional_field("string", option.None, decode.optional(decode.string))
  decode.success(NullOperationInputOutput(
    string: string,
  ))
}

pub type OperationWithOptionalInputOutputInput {
  OperationWithOptionalInputOutputInput(
    value: option.Option(String),
  )
}

pub fn encode_operation_with_optional_input_output_input_struct(input: OperationWithOptionalInputOutputInput) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_optional_input_output_input_struct() -> decode.Decoder(OperationWithOptionalInputOutputInput) {
  use value <- decode.optional_field("Value", option.None, decode.optional(decode.string))
  decode.success(OperationWithOptionalInputOutputInput(
    value: value,
  ))
}

pub type OperationWithOptionalInputOutputOutput {
  OperationWithOptionalInputOutputOutput(
    value: option.Option(String),
  )
}

pub fn encode_operation_with_optional_input_output_output_struct(input: OperationWithOptionalInputOutputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_optional_input_output_output_struct() -> decode.Decoder(OperationWithOptionalInputOutputOutput) {
  use value <- decode.optional_field("Value", option.None, decode.optional(decode.string))
  decode.success(OperationWithOptionalInputOutputOutput(
    value: value,
  ))
}

pub type PutAndGetInlineDocumentsInputOutput {
  PutAndGetInlineDocumentsInputOutput(
    inline_document: option.Option(json.Json),
  )
}

pub fn encode_put_and_get_inline_documents_input_output_struct(input: PutAndGetInlineDocumentsInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.inline_document {
    option.Some(v) -> [#("inlineDocument", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_and_get_inline_documents_input_output_struct() -> decode.Decoder(PutAndGetInlineDocumentsInputOutput) {
  use inline_document <- decode.optional_field("inlineDocument", option.None, decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })))
  decode.success(PutAndGetInlineDocumentsInputOutput(
    inline_document: inline_document,
  ))
}

pub type SimpleScalarPropertiesInputOutput {
  SimpleScalarPropertiesInputOutput(
    double_value: option.Option(json_float.SmithyFloat),
    float_value: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_simple_scalar_properties_input_output_struct(input: SimpleScalarPropertiesInputOutput) -> json.Json {
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

pub fn decode_simple_scalar_properties_input_output_struct() -> decode.Decoder(SimpleScalarPropertiesInputOutput) {
  use double_value <- decode.optional_field("doubleValue", option.None, decode.optional(json_float.decoder()))
  use float_value <- decode.optional_field("floatValue", option.None, decode.optional(json_float.decoder()))
  decode.success(SimpleScalarPropertiesInputOutput(
    double_value: double_value,
    float_value: float_value,
  ))
}

pub type SparseNullsOperationInputOutput {
  SparseNullsOperationInputOutput(
    sparse_string_list: option.Option(List(String)),
    sparse_string_map: option.Option(dict.Dict(String, String)),
  )
}

pub fn encode_sparse_nulls_operation_input_output_struct(input: SparseNullsOperationInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.sparse_string_list {
    option.Some(v) -> [#("sparseStringList", fn(xs) { json.array(xs, json.string) }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sparse_string_map {
    option.Some(v) -> [#("sparseStringMap", fn(d) { json.object(dict.to_list(d) |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) })) }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_sparse_nulls_operation_input_output_struct() -> decode.Decoder(SparseNullsOperationInputOutput) {
  use sparse_string_list <- decode.optional_field("sparseStringList", option.None, decode.optional(decode.list(decode.string)))
  use sparse_string_map <- decode.optional_field("sparseStringMap", option.None, decode.optional(decode.dict(decode.string, decode.string)))
  decode.success(SparseNullsOperationInputOutput(
    sparse_string_list: sparse_string_list,
    sparse_string_map: sparse_string_map,
  ))
}


pub fn encode_content_type_parameters_input(input: ContentTypeParametersInput) -> String {
  json.to_string(encode_content_type_parameters_input_struct(input))
}

pub fn decode_content_type_parameters_input(body: String) -> Result(ContentTypeParametersInput, String) {
  case json.parse(body, decode_content_type_parameters_input_struct()) {
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
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.ContentTypeParameters"),
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

pub fn build_datetime_offsets_request(
  input: DatetimeOffsetsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_datetime_offsets_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.DatetimeOffsets"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_datetime_offsets_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DatetimeOffsetsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_datetime_offsets_output("{}")
      _ -> decode_datetime_offsets_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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


pub type EmptyOperationInput {
  EmptyOperationInput
}

pub fn encode_empty_operation_input_struct(_v: EmptyOperationInput) -> json.Json {
  json.object([])
}

pub fn decode_empty_operation_input_struct() -> decode.Decoder(EmptyOperationInput) {
  decode.success(EmptyOperationInput)
}

pub type EmptyOperationOutput {
  EmptyOperationOutput
}

pub fn encode_empty_operation_output_struct(_v: EmptyOperationOutput) -> json.Json {
  json.object([])
}

pub fn decode_empty_operation_output_struct() -> decode.Decoder(EmptyOperationOutput) {
  decode.success(EmptyOperationOutput)
}

pub fn encode_empty_operation_input(input: EmptyOperationInput) -> String {
  json.to_string(encode_empty_operation_input_struct(input))
}

pub fn decode_empty_operation_input(body: String) -> Result(EmptyOperationInput, String) {
  case json.parse(body, decode_empty_operation_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_empty_operation_output(body: String) -> Result(EmptyOperationOutput, String) {
  case json.parse(body, decode_empty_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_empty_operation_request(
  input: EmptyOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_empty_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.EmptyOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_empty_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EmptyOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_empty_operation_output("{}")
      _ -> decode_empty_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type EmptyOperationError {
  EmptyOperationErrorTransport(reason: String)
  EmptyOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_empty_operation_error(err: awsjson_client.ClientError) -> EmptyOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> EmptyOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> EmptyOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> EmptyOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> EmptyOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> EmptyOperationErrorTransport(reason: "decode: " <> r)
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
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.EndpointOperation"),
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

pub fn encode_endpoint_with_host_label_operation_input(input: HostLabelInput) -> String {
  json.to_string(encode_host_label_input_struct(input))
}

pub fn decode_endpoint_with_host_label_operation_input(body: String) -> Result(HostLabelInput, String) {
  case json.parse(body, decode_host_label_input_struct()) {
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
  input: HostLabelInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_endpoint_with_host_label_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.EndpointWithHostLabelOperation"),
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

pub fn build_fractional_seconds_request(
  input: FractionalSecondsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_fractional_seconds_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.FractionalSeconds"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_fractional_seconds_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(FractionalSecondsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_fractional_seconds_output("{}")
      _ -> decode_fractional_seconds_output(text)
    }
    Error(_) -> Error("non-utf8 body")
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

pub fn build_greeting_with_errors_request(
  input: GreetingWithErrorsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_greeting_with_errors_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.GreetingWithErrors"),
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
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.HostWithPathOperation"),
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


pub fn encode_json_enums_input(input: JsonEnumsInputOutput) -> String {
  json.to_string(encode_json_enums_input_output_struct(input))
}

pub fn decode_json_enums_input(body: String) -> Result(JsonEnumsInputOutput, String) {
  case json.parse(body, decode_json_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_enums_output(body: String) -> Result(JsonEnumsInputOutput, String) {
  case json.parse(body, decode_json_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_json_enums_request(
  input: JsonEnumsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_json_enums_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.JsonEnums"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_json_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonEnumsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_json_enums_output("{}")
      _ -> decode_json_enums_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type JsonEnumsError {
  JsonEnumsErrorTransport(reason: String)
  JsonEnumsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_json_enums_error(err: awsjson_client.ClientError) -> JsonEnumsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> JsonEnumsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> JsonEnumsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> JsonEnumsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> JsonEnumsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> JsonEnumsErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_json_int_enums_input(input: JsonIntEnumsInputOutput) -> String {
  json.to_string(encode_json_int_enums_input_output_struct(input))
}

pub fn decode_json_int_enums_input(body: String) -> Result(JsonIntEnumsInputOutput, String) {
  case json.parse(body, decode_json_int_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_int_enums_output(body: String) -> Result(JsonIntEnumsInputOutput, String) {
  case json.parse(body, decode_json_int_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_json_int_enums_request(
  input: JsonIntEnumsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_json_int_enums_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.JsonIntEnums"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_json_int_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonIntEnumsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_json_int_enums_output("{}")
      _ -> decode_json_int_enums_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type JsonIntEnumsError {
  JsonIntEnumsErrorTransport(reason: String)
  JsonIntEnumsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_json_int_enums_error(err: awsjson_client.ClientError) -> JsonIntEnumsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> JsonIntEnumsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> JsonIntEnumsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> JsonIntEnumsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> JsonIntEnumsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> JsonIntEnumsErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_json_unions_input(input: UnionInputOutput) -> String {
  json.to_string(encode_union_input_output_struct(input))
}

pub fn decode_json_unions_input(body: String) -> Result(UnionInputOutput, String) {
  case json.parse(body, decode_union_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_unions_output(body: String) -> Result(UnionInputOutput, String) {
  case json.parse(body, decode_union_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_json_unions_request(
  input: UnionInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_json_unions_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.JsonUnions"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_json_unions_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UnionInputOutput, String) {
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


pub fn encode_kitchen_sink_operation_input(input: KitchenSink) -> String {
  json.to_string(encode_kitchen_sink_struct(input))
}

pub fn decode_kitchen_sink_operation_input(body: String) -> Result(KitchenSink, String) {
  case json.parse(body, decode_kitchen_sink_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_kitchen_sink_operation_output(body: String) -> Result(KitchenSink, String) {
  case json.parse(body, decode_kitchen_sink_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_kitchen_sink_operation_request(
  input: KitchenSink,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_kitchen_sink_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.KitchenSinkOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_kitchen_sink_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(KitchenSink, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_kitchen_sink_operation_output("{}")
      _ -> decode_kitchen_sink_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type KitchenSinkOperationError {
  KitchenSinkOperationErrorErrorWithMembers(value: ErrorWithMembers)
  KitchenSinkOperationErrorErrorWithoutMembers(value: ErrorWithoutMembers)
  KitchenSinkOperationErrorTransport(reason: String)
  KitchenSinkOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_kitchen_sink_operation_error(err: awsjson_client.ClientError) -> KitchenSinkOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
        case awsjson_client.error_type_matches(et, "ErrorWithMembers") {
          True -> case bit_array.to_string(b) {
            Ok(text) -> case json.parse(text, decode_error_with_members_struct()) {
              Ok(v) -> KitchenSinkOperationErrorErrorWithMembers(value: v)
              Error(_) -> KitchenSinkOperationErrorUnknown(error_type: et, status: s, body: text)
            }
            Error(_) -> KitchenSinkOperationErrorUnknown(error_type: et, status: s, body: "")
          }
          False ->         case awsjson_client.error_type_matches(et, "ErrorWithoutMembers") {
          True -> case bit_array.to_string(b) {
            Ok(text) -> case json.parse(text, decode_error_without_members_struct()) {
              Ok(v) -> KitchenSinkOperationErrorErrorWithoutMembers(value: v)
              Error(_) -> KitchenSinkOperationErrorUnknown(error_type: et, status: s, body: text)
            }
            Error(_) -> KitchenSinkOperationErrorUnknown(error_type: et, status: s, body: "")
          }
          False -> case bit_array.to_string(b) {
          Ok(text) -> KitchenSinkOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> KitchenSinkOperationErrorUnknown(error_type: et, status: s, body: "")
        }
        }
        }
    }
    awsjson_client.TransportError(_) -> KitchenSinkOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> KitchenSinkOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> KitchenSinkOperationErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_null_operation_input(input: NullOperationInputOutput) -> String {
  json.to_string(encode_null_operation_input_output_struct(input))
}

pub fn decode_null_operation_input(body: String) -> Result(NullOperationInputOutput, String) {
  case json.parse(body, decode_null_operation_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_null_operation_output(body: String) -> Result(NullOperationInputOutput, String) {
  case json.parse(body, decode_null_operation_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_null_operation_request(
  input: NullOperationInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_null_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.NullOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_null_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NullOperationInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_null_operation_output("{}")
      _ -> decode_null_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type NullOperationError {
  NullOperationErrorTransport(reason: String)
  NullOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_null_operation_error(err: awsjson_client.ClientError) -> NullOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> NullOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> NullOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> NullOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> NullOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> NullOperationErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_operation_with_optional_input_output_input(input: OperationWithOptionalInputOutputInput) -> String {
  json.to_string(encode_operation_with_optional_input_output_input_struct(input))
}

pub fn decode_operation_with_optional_input_output_input(body: String) -> Result(OperationWithOptionalInputOutputInput, String) {
  case json.parse(body, decode_operation_with_optional_input_output_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_optional_input_output_output(body: String) -> Result(OperationWithOptionalInputOutputOutput, String) {
  case json.parse(body, decode_operation_with_optional_input_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_operation_with_optional_input_output_request(
  input: OperationWithOptionalInputOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_operation_with_optional_input_output_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.OperationWithOptionalInputOutput"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_operation_with_optional_input_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithOptionalInputOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_operation_with_optional_input_output_output("{}")
      _ -> decode_operation_with_optional_input_output_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OperationWithOptionalInputOutputError {
  OperationWithOptionalInputOutputErrorTransport(reason: String)
  OperationWithOptionalInputOutputErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_operation_with_optional_input_output_error(err: awsjson_client.ClientError) -> OperationWithOptionalInputOutputError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> OperationWithOptionalInputOutputErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> OperationWithOptionalInputOutputErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> OperationWithOptionalInputOutputErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> OperationWithOptionalInputOutputErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> OperationWithOptionalInputOutputErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_put_and_get_inline_documents_input(input: PutAndGetInlineDocumentsInputOutput) -> String {
  json.to_string(encode_put_and_get_inline_documents_input_output_struct(input))
}

pub fn decode_put_and_get_inline_documents_input(body: String) -> Result(PutAndGetInlineDocumentsInputOutput, String) {
  case json.parse(body, decode_put_and_get_inline_documents_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_and_get_inline_documents_output(body: String) -> Result(PutAndGetInlineDocumentsInputOutput, String) {
  case json.parse(body, decode_put_and_get_inline_documents_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_put_and_get_inline_documents_request(
  input: PutAndGetInlineDocumentsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_put_and_get_inline_documents_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.PutAndGetInlineDocuments"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_put_and_get_inline_documents_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutAndGetInlineDocumentsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_put_and_get_inline_documents_output("{}")
      _ -> decode_put_and_get_inline_documents_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type PutAndGetInlineDocumentsError {
  PutAndGetInlineDocumentsErrorTransport(reason: String)
  PutAndGetInlineDocumentsErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_put_and_get_inline_documents_error(err: awsjson_client.ClientError) -> PutAndGetInlineDocumentsError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> PutAndGetInlineDocumentsErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> PutAndGetInlineDocumentsErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> PutAndGetInlineDocumentsErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> PutAndGetInlineDocumentsErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> PutAndGetInlineDocumentsErrorTransport(reason: "decode: " <> r)
  }
}


pub fn encode_simple_scalar_properties_input(input: SimpleScalarPropertiesInputOutput) -> String {
  json.to_string(encode_simple_scalar_properties_input_output_struct(input))
}

pub fn decode_simple_scalar_properties_input(body: String) -> Result(SimpleScalarPropertiesInputOutput, String) {
  case json.parse(body, decode_simple_scalar_properties_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_simple_scalar_properties_output(body: String) -> Result(SimpleScalarPropertiesInputOutput, String) {
  case json.parse(body, decode_simple_scalar_properties_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_simple_scalar_properties_request(
  input: SimpleScalarPropertiesInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_simple_scalar_properties_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.SimpleScalarProperties"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_simple_scalar_properties_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SimpleScalarPropertiesInputOutput, String) {
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


pub fn encode_sparse_nulls_operation_input(input: SparseNullsOperationInputOutput) -> String {
  json.to_string(encode_sparse_nulls_operation_input_output_struct(input))
}

pub fn decode_sparse_nulls_operation_input(body: String) -> Result(SparseNullsOperationInputOutput, String) {
  case json.parse(body, decode_sparse_nulls_operation_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_sparse_nulls_operation_output(body: String) -> Result(SparseNullsOperationInputOutput, String) {
  case json.parse(body, decode_sparse_nulls_operation_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_sparse_nulls_operation_request(
  input: SparseNullsOperationInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_sparse_nulls_operation_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.1"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "JsonProtocol.SparseNullsOperation"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_sparse_nulls_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SparseNullsOperationInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) -> case text {
      "" -> decode_sparse_nulls_operation_output("{}")
      _ -> decode_sparse_nulls_operation_output(text)
    }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type SparseNullsOperationError {
  SparseNullsOperationErrorTransport(reason: String)
  SparseNullsOperationErrorUnknown(error_type: String, status: Int, body: String)
}

fn translate_sparse_nulls_operation_error(err: awsjson_client.ClientError) -> SparseNullsOperationError {
  case err {
    awsjson_client.ServiceError(status: s, error_type: et, body: b) -> {
case bit_array.to_string(b) {
          Ok(text) -> SparseNullsOperationErrorUnknown(error_type: et, status: s, body: text)
          Error(_) -> SparseNullsOperationErrorUnknown(error_type: et, status: s, body: "")
        }
    }
    awsjson_client.TransportError(_) -> SparseNullsOperationErrorTransport(reason: "transport error")
    awsjson_client.CredentialsError(_) -> SparseNullsOperationErrorTransport(reason: "credentials error")
    awsjson_client.DecodeError(reason: r) -> SparseNullsOperationErrorTransport(reason: "decode: " <> r)
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

/// Invoke DatetimeOffsets. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `DatetimeOffsetsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `DatetimeOffsetsErrorTransport` variant.
pub fn datetime_offsets(
  client: Client,
  input: DatetimeOffsetsInput,
) -> Result(DatetimeOffsetsOutput, DatetimeOffsetsError) {
  case awsjson_client.invoke(
    client.config,
    build_datetime_offsets_request(input),
    parse_datetime_offsets_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_datetime_offsets_error(err))
  }
}

/// Invoke EmptyOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `EmptyOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `EmptyOperationErrorTransport` variant.
pub fn empty_operation(
  client: Client,
  input: EmptyOperationInput,
) -> Result(EmptyOperationOutput, EmptyOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_empty_operation_request(input),
    parse_empty_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_empty_operation_error(err))
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
  input: HostLabelInput,
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

/// Invoke FractionalSeconds. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `FractionalSecondsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `FractionalSecondsErrorTransport` variant.
pub fn fractional_seconds(
  client: Client,
  input: FractionalSecondsInput,
) -> Result(FractionalSecondsOutput, FractionalSecondsError) {
  case awsjson_client.invoke(
    client.config,
    build_fractional_seconds_request(input),
    parse_fractional_seconds_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_fractional_seconds_error(err))
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

/// Invoke JsonEnums. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `JsonEnumsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `JsonEnumsErrorTransport` variant.
pub fn json_enums(
  client: Client,
  input: JsonEnumsInputOutput,
) -> Result(JsonEnumsInputOutput, JsonEnumsError) {
  case awsjson_client.invoke(
    client.config,
    build_json_enums_request(input),
    parse_json_enums_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_json_enums_error(err))
  }
}

/// Invoke JsonIntEnums. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `JsonIntEnumsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `JsonIntEnumsErrorTransport` variant.
pub fn json_int_enums(
  client: Client,
  input: JsonIntEnumsInputOutput,
) -> Result(JsonIntEnumsInputOutput, JsonIntEnumsError) {
  case awsjson_client.invoke(
    client.config,
    build_json_int_enums_request(input),
    parse_json_int_enums_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_json_int_enums_error(err))
  }
}

/// Invoke JsonUnions. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `JsonUnionsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `JsonUnionsErrorTransport` variant.
pub fn json_unions(
  client: Client,
  input: UnionInputOutput,
) -> Result(UnionInputOutput, JsonUnionsError) {
  case awsjson_client.invoke(
    client.config,
    build_json_unions_request(input),
    parse_json_unions_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_json_unions_error(err))
  }
}

/// Invoke KitchenSinkOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `KitchenSinkOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `KitchenSinkOperationErrorTransport` variant.
pub fn kitchen_sink_operation(
  client: Client,
  input: KitchenSink,
) -> Result(KitchenSink, KitchenSinkOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_kitchen_sink_operation_request(input),
    parse_kitchen_sink_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_kitchen_sink_operation_error(err))
  }
}

/// Invoke NullOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `NullOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `NullOperationErrorTransport` variant.
pub fn null_operation(
  client: Client,
  input: NullOperationInputOutput,
) -> Result(NullOperationInputOutput, NullOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_null_operation_request(input),
    parse_null_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_null_operation_error(err))
  }
}

/// Invoke OperationWithOptionalInputOutput. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `OperationWithOptionalInputOutputError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `OperationWithOptionalInputOutputErrorTransport` variant.
pub fn operation_with_optional_input_output(
  client: Client,
  input: OperationWithOptionalInputOutputInput,
) -> Result(OperationWithOptionalInputOutputOutput, OperationWithOptionalInputOutputError) {
  case awsjson_client.invoke(
    client.config,
    build_operation_with_optional_input_output_request(input),
    parse_operation_with_optional_input_output_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_operation_with_optional_input_output_error(err))
  }
}

/// Invoke PutAndGetInlineDocuments. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `PutAndGetInlineDocumentsError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `PutAndGetInlineDocumentsErrorTransport` variant.
pub fn put_and_get_inline_documents(
  client: Client,
  input: PutAndGetInlineDocumentsInputOutput,
) -> Result(PutAndGetInlineDocumentsInputOutput, PutAndGetInlineDocumentsError) {
  case awsjson_client.invoke(
    client.config,
    build_put_and_get_inline_documents_request(input),
    parse_put_and_get_inline_documents_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_put_and_get_inline_documents_error(err))
  }
}

/// Invoke SimpleScalarProperties. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `SimpleScalarPropertiesError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `SimpleScalarPropertiesErrorTransport` variant.
pub fn simple_scalar_properties(
  client: Client,
  input: SimpleScalarPropertiesInputOutput,
) -> Result(SimpleScalarPropertiesInputOutput, SimpleScalarPropertiesError) {
  case awsjson_client.invoke(
    client.config,
    build_simple_scalar_properties_request(input),
    parse_simple_scalar_properties_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_simple_scalar_properties_error(err))
  }
}

/// Invoke SparseNullsOperation. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport. Service errors come back as typed `SparseNullsOperationError`
/// variants; transport, decode, and credentials failures all collapse
/// into the generic `SparseNullsOperationErrorTransport` variant.
pub fn sparse_nulls_operation(
  client: Client,
  input: SparseNullsOperationInputOutput,
) -> Result(SparseNullsOperationInputOutput, SparseNullsOperationError) {
  case awsjson_client.invoke(
    client.config,
    build_sparse_nulls_operation_request(input),
    parse_sparse_nulls_operation_response,
  ) {
    Ok(out) -> Ok(out)
    Error(err) -> Error(translate_sparse_nulls_operation_error(err))
  }
}

