//// Generated from aws.protocoltests.restjson#RestJson (restJson1).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/internal/codec/json_float
import aws/internal/codec/rest
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option

pub type AllQueryStringTypesInput {
  AllQueryStringTypesInput(
    query_boolean: option.Option(Bool),
    query_boolean_list: option.Option(List(Bool)),
    query_byte: option.Option(Int),
    query_double: option.Option(json_float.SmithyFloat),
    query_double_list: option.Option(List(json_float.SmithyFloat)),
    query_enum: option.Option(FooEnum),
    query_enum_list: option.Option(List(FooEnum)),
    query_float: option.Option(json_float.SmithyFloat),
    query_integer: option.Option(Int),
    query_integer_enum: option.Option(IntegerEnum),
    query_integer_enum_list: option.Option(List(IntegerEnum)),
    query_integer_list: option.Option(List(Int)),
    query_integer_set: option.Option(List(Int)),
    query_long: option.Option(Int),
    query_params_map_of_string_list: option.Option(
      dict.Dict(String, List(String)),
    ),
    query_short: option.Option(Int),
    query_string: option.Option(String),
    query_string_list: option.Option(List(String)),
    query_string_set: option.Option(List(String)),
    query_timestamp: option.Option(Int),
    query_timestamp_list: option.Option(List(Int)),
  )
}

pub fn encode_all_query_string_types_input_struct(
  input: AllQueryStringTypesInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.query_boolean {
    option.Some(v) -> [#("queryBoolean", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_boolean_list {
    option.Some(v) -> [
      #("queryBooleanList", fn(xs) { json.array(xs, json.bool) }(v)),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("queryDoubleList", fn(xs) { json.array(xs, json_float.encode) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_enum {
    option.Some(v) -> [#("queryEnum", encode_foo_enum_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_enum_list {
    option.Some(v) -> [
      #("queryEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("queryIntegerEnum", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_integer_enum_list {
    option.Some(v) -> [
      #(
        "queryIntegerEnumList",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_integer_list {
    option.Some(v) -> [
      #("queryIntegerList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_integer_set {
    option.Some(v) -> [
      #("queryIntegerSet", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_long {
    option.Some(v) -> [#("queryLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_params_map_of_string_list {
    option.Some(v) -> [
      #(
        "queryParamsMapOfStringList",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("queryStringList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_string_set {
    option.Some(v) -> [
      #("queryStringSet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_timestamp {
    option.Some(v) -> [#("queryTimestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_timestamp_list {
    option.Some(v) -> [
      #("queryTimestampList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_all_query_string_types_input_struct() -> decode.Decoder(
  AllQueryStringTypesInput,
) {
  use query_boolean <- decode.optional_field(
    "queryBoolean",
    option.None,
    decode.optional(decode.bool),
  )
  use query_boolean_list <- decode.optional_field(
    "queryBooleanList",
    option.None,
    decode.optional(decode.list(decode.bool)),
  )
  use query_byte <- decode.optional_field(
    "queryByte",
    option.None,
    decode.optional(decode.int),
  )
  use query_double <- decode.optional_field(
    "queryDouble",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use query_double_list <- decode.optional_field(
    "queryDoubleList",
    option.None,
    decode.optional(decode.list(json_float.decoder())),
  )
  use query_enum <- decode.optional_field(
    "queryEnum",
    option.None,
    decode.optional(decode_foo_enum_enum()),
  )
  use query_enum_list <- decode.optional_field(
    "queryEnumList",
    option.None,
    decode.optional(decode.list(decode_foo_enum_enum())),
  )
  use query_float <- decode.optional_field(
    "queryFloat",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use query_integer <- decode.optional_field(
    "queryInteger",
    option.None,
    decode.optional(decode.int),
  )
  use query_integer_enum <- decode.optional_field(
    "queryIntegerEnum",
    option.None,
    decode.optional(decode_integer_enum_int_enum()),
  )
  use query_integer_enum_list <- decode.optional_field(
    "queryIntegerEnumList",
    option.None,
    decode.optional(decode.list(decode_integer_enum_int_enum())),
  )
  use query_integer_list <- decode.optional_field(
    "queryIntegerList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  use query_integer_set <- decode.optional_field(
    "queryIntegerSet",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  use query_long <- decode.optional_field(
    "queryLong",
    option.None,
    decode.optional(decode.int),
  )
  use query_params_map_of_string_list <- decode.optional_field(
    "queryParamsMapOfStringList",
    option.None,
    decode.optional(decode.dict(decode.string, decode.list(decode.string))),
  )
  use query_short <- decode.optional_field(
    "queryShort",
    option.None,
    decode.optional(decode.int),
  )
  use query_string <- decode.optional_field(
    "queryString",
    option.None,
    decode.optional(decode.string),
  )
  use query_string_list <- decode.optional_field(
    "queryStringList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use query_string_set <- decode.optional_field(
    "queryStringSet",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use query_timestamp <- decode.optional_field(
    "queryTimestamp",
    option.None,
    decode.optional(decode.int),
  )
  use query_timestamp_list <- decode.optional_field(
    "queryTimestampList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
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
    query_params_map_of_string_list: query_params_map_of_string_list,
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

pub type ConstantAndVariableQueryStringInput {
  ConstantAndVariableQueryStringInput(
    baz: option.Option(String),
    maybe_set: option.Option(String),
  )
}

pub fn encode_constant_and_variable_query_string_input_struct(
  input: ConstantAndVariableQueryStringInput,
) -> json.Json {
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

pub fn decode_constant_and_variable_query_string_input_struct() -> decode.Decoder(
  ConstantAndVariableQueryStringInput,
) {
  use baz <- decode.optional_field(
    "baz",
    option.None,
    decode.optional(decode.string),
  )
  use maybe_set <- decode.optional_field(
    "maybeSet",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ConstantAndVariableQueryStringInput(
    baz: baz,
    maybe_set: maybe_set,
  ))
}

pub type ConstantQueryStringInput {
  ConstantQueryStringInput(hello: option.Option(String))
}

pub fn encode_constant_query_string_input_struct(
  input: ConstantQueryStringInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.hello {
    option.Some(v) -> [#("hello", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_constant_query_string_input_struct() -> decode.Decoder(
  ConstantQueryStringInput,
) {
  use hello <- decode.optional_field(
    "hello",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ConstantQueryStringInput(hello: hello))
}

pub type ContentTypeParametersInput {
  ContentTypeParametersInput(value: option.Option(Int))
}

pub fn encode_content_type_parameters_input_struct(
  input: ContentTypeParametersInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("value", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_content_type_parameters_input_struct() -> decode.Decoder(
  ContentTypeParametersInput,
) {
  use value <- decode.optional_field(
    "value",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ContentTypeParametersInput(value: value))
}

pub type ContentTypeParametersOutput {
  ContentTypeParametersOutput
}

pub fn encode_content_type_parameters_output_struct(
  _v: ContentTypeParametersOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_content_type_parameters_output_struct() -> decode.Decoder(
  ContentTypeParametersOutput,
) {
  decode.success(ContentTypeParametersOutput)
}

pub type DatetimeOffsetsOutput {
  DatetimeOffsetsOutput(datetime: option.Option(Int))
}

pub fn encode_datetime_offsets_output_struct(
  input: DatetimeOffsetsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.datetime {
    option.Some(v) -> [#("datetime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_datetime_offsets_output_struct() -> decode.Decoder(
  DatetimeOffsetsOutput,
) {
  use datetime <- decode.optional_field(
    "datetime",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(DatetimeOffsetsOutput(datetime: datetime))
}

pub type DocumentTypeInputOutput {
  DocumentTypeInputOutput(
    document_value: option.Option(json.Json),
    string_value: option.Option(String),
  )
}

pub fn encode_document_type_input_output_struct(
  input: DocumentTypeInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.document_value {
    option.Some(v) -> [#("documentValue", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_value {
    option.Some(v) -> [#("stringValue", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_document_type_input_output_struct() -> decode.Decoder(
  DocumentTypeInputOutput,
) {
  use document_value <- decode.optional_field(
    "documentValue",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use string_value <- decode.optional_field(
    "stringValue",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DocumentTypeInputOutput(
    document_value: document_value,
    string_value: string_value,
  ))
}

pub type DocumentTypeAsMapValueInputOutput {
  DocumentTypeAsMapValueInputOutput(
    doc_valued_map: option.Option(dict.Dict(String, json.Json)),
  )
}

pub fn encode_document_type_as_map_value_input_output_struct(
  input: DocumentTypeAsMapValueInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.doc_valued_map {
    option.Some(v) -> [
      #(
        "docValuedMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, fn(j) { j }(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_document_type_as_map_value_input_output_struct() -> decode.Decoder(
  DocumentTypeAsMapValueInputOutput,
) {
  use doc_valued_map <- decode.optional_field(
    "docValuedMap",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode.dynamic |> decode.map(fn(_) { json.null() }),
    )),
  )
  decode.success(DocumentTypeAsMapValueInputOutput(
    doc_valued_map: doc_valued_map,
  ))
}

pub type DocumentTypeAsPayloadInputOutput {
  DocumentTypeAsPayloadInputOutput(document_value: option.Option(json.Json))
}

pub fn encode_document_type_as_payload_input_output_struct(
  input: DocumentTypeAsPayloadInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.document_value {
    option.Some(v) -> [#("documentValue", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_document_type_as_payload_input_output_struct() -> decode.Decoder(
  DocumentTypeAsPayloadInputOutput,
) {
  use document_value <- decode.optional_field(
    "documentValue",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  decode.success(DocumentTypeAsPayloadInputOutput(
    document_value: document_value,
  ))
}

pub type DuplexStreamInput {
  DuplexStreamInput(stream: option.Option(EventStream))
}

pub fn encode_duplex_stream_input_struct(
  input: DuplexStreamInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_duplex_stream_input_struct() -> decode.Decoder(DuplexStreamInput) {
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(DuplexStreamInput(stream: stream))
}

pub type EventStream {
  EventStreamBlobPayload(BlobPayloadEvent)
  EventStreamError(ErrorEvent)
  EventStreamHeaders(HeadersEvent)
  EventStreamHeadersAndExplicitPayload(HeadersAndExplicitPayloadEvent)
  EventStreamHeadersAndImplicitPayload(HeadersAndImplicitPayloadEvent)
  EventStreamStringPayload(StringPayloadEvent)
  EventStreamStructurePayload(StructurePayloadEvent)
  EventStreamUnionPayload(UnionPayloadEvent)
}

pub fn encode_event_stream_union(v: EventStream) -> json.Json {
  case v {
    EventStreamBlobPayload(x) ->
      json.object([#("blobPayload", encode_blob_payload_event_struct(x))])
    EventStreamError(x) ->
      json.object([#("error", encode_error_event_struct(x))])
    EventStreamHeaders(x) ->
      json.object([#("headers", encode_headers_event_struct(x))])
    EventStreamHeadersAndExplicitPayload(x) ->
      json.object([
        #(
          "headersAndExplicitPayload",
          encode_headers_and_explicit_payload_event_struct(x),
        ),
      ])
    EventStreamHeadersAndImplicitPayload(x) ->
      json.object([
        #(
          "headersAndImplicitPayload",
          encode_headers_and_implicit_payload_event_struct(x),
        ),
      ])
    EventStreamStringPayload(x) ->
      json.object([#("stringPayload", encode_string_payload_event_struct(x))])
    EventStreamStructurePayload(x) ->
      json.object([
        #("structurePayload", encode_structure_payload_event_struct(x)),
      ])
    EventStreamUnionPayload(x) ->
      json.object([#("unionPayload", encode_union_payload_event_struct(x))])
  }
}

pub fn decode_event_stream_union() -> decode.Decoder(EventStream) {
  decode.one_of(
    decode.field("blobPayload", decode_blob_payload_event_struct(), fn(x) {
      decode.success(EventStreamBlobPayload(x))
    }),
    [
      decode.field("error", decode_error_event_struct(), fn(x) {
        decode.success(EventStreamError(x))
      }),
      decode.field("headers", decode_headers_event_struct(), fn(x) {
        decode.success(EventStreamHeaders(x))
      }),
      decode.field(
        "headersAndExplicitPayload",
        decode_headers_and_explicit_payload_event_struct(),
        fn(x) { decode.success(EventStreamHeadersAndExplicitPayload(x)) },
      ),
      decode.field(
        "headersAndImplicitPayload",
        decode_headers_and_implicit_payload_event_struct(),
        fn(x) { decode.success(EventStreamHeadersAndImplicitPayload(x)) },
      ),
      decode.field("stringPayload", decode_string_payload_event_struct(), fn(x) {
        decode.success(EventStreamStringPayload(x))
      }),
      decode.field(
        "structurePayload",
        decode_structure_payload_event_struct(),
        fn(x) { decode.success(EventStreamStructurePayload(x)) },
      ),
      decode.field("unionPayload", decode_union_payload_event_struct(), fn(x) {
        decode.success(EventStreamUnionPayload(x))
      }),
    ],
  )
}

pub type BlobPayloadEvent {
  BlobPayloadEvent(payload: option.Option(BitArray))
}

pub fn encode_blob_payload_event_struct(input: BlobPayloadEvent) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [
      #("payload", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_blob_payload_event_struct() -> decode.Decoder(BlobPayloadEvent) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  decode.success(BlobPayloadEvent(payload: payload))
}

pub type ErrorEvent {
  ErrorEvent(message: option.Option(String))
}

pub fn encode_error_event_struct(input: ErrorEvent) -> json.Json {
  let pairs = []
  let pairs = case input.message {
    option.Some(v) -> [#("message", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_error_event_struct() -> decode.Decoder(ErrorEvent) {
  use message <- decode.optional_field(
    "message",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ErrorEvent(message: message))
}

pub type HeadersEvent {
  HeadersEvent(
    blob_header: option.Option(BitArray),
    boolean_header: option.Option(Bool),
    byte_header: option.Option(Int),
    int_header: option.Option(Int),
    long_header: option.Option(Int),
    short_header: option.Option(Int),
    string_header: option.Option(String),
    timestamp_header: option.Option(Int),
  )
}

pub fn encode_headers_event_struct(input: HeadersEvent) -> json.Json {
  let pairs = []
  let pairs = case input.blob_header {
    option.Some(v) -> [
      #(
        "blobHeader",
        fn(b) { json.string(bit_array.base64_encode(b, True)) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.boolean_header {
    option.Some(v) -> [#("booleanHeader", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.byte_header {
    option.Some(v) -> [#("byteHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int_header {
    option.Some(v) -> [#("intHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long_header {
    option.Some(v) -> [#("longHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short_header {
    option.Some(v) -> [#("shortHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_header {
    option.Some(v) -> [#("stringHeader", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.timestamp_header {
    option.Some(v) -> [#("timestampHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_headers_event_struct() -> decode.Decoder(HeadersEvent) {
  use blob_header <- decode.optional_field(
    "blobHeader",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use boolean_header <- decode.optional_field(
    "booleanHeader",
    option.None,
    decode.optional(decode.bool),
  )
  use byte_header <- decode.optional_field(
    "byteHeader",
    option.None,
    decode.optional(decode.int),
  )
  use int_header <- decode.optional_field(
    "intHeader",
    option.None,
    decode.optional(decode.int),
  )
  use long_header <- decode.optional_field(
    "longHeader",
    option.None,
    decode.optional(decode.int),
  )
  use short_header <- decode.optional_field(
    "shortHeader",
    option.None,
    decode.optional(decode.int),
  )
  use string_header <- decode.optional_field(
    "stringHeader",
    option.None,
    decode.optional(decode.string),
  )
  use timestamp_header <- decode.optional_field(
    "timestampHeader",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(HeadersEvent(
    blob_header: blob_header,
    boolean_header: boolean_header,
    byte_header: byte_header,
    int_header: int_header,
    long_header: long_header,
    short_header: short_header,
    string_header: string_header,
    timestamp_header: timestamp_header,
  ))
}

pub type HeadersAndExplicitPayloadEvent {
  HeadersAndExplicitPayloadEvent(
    header: option.Option(String),
    payload: option.Option(PayloadStructure),
  )
}

pub fn encode_headers_and_explicit_payload_event_struct(
  input: HeadersAndExplicitPayloadEvent,
) -> json.Json {
  let pairs = []
  let pairs = case input.header {
    option.Some(v) -> [#("header", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.payload {
    option.Some(v) -> [
      #("payload", encode_payload_structure_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_headers_and_explicit_payload_event_struct() -> decode.Decoder(
  HeadersAndExplicitPayloadEvent,
) {
  use header <- decode.optional_field(
    "header",
    option.None,
    decode.optional(decode.string),
  )
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode_payload_structure_struct()),
  )
  decode.success(HeadersAndExplicitPayloadEvent(
    header: header,
    payload: payload,
  ))
}

pub type PayloadStructure {
  PayloadStructure(structure_member: option.Option(String))
}

pub fn encode_payload_structure_struct(input: PayloadStructure) -> json.Json {
  let pairs = []
  let pairs = case input.structure_member {
    option.Some(v) -> [#("structureMember", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_payload_structure_struct() -> decode.Decoder(PayloadStructure) {
  use structure_member <- decode.optional_field(
    "structureMember",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(PayloadStructure(structure_member: structure_member))
}

pub type HeadersAndImplicitPayloadEvent {
  HeadersAndImplicitPayloadEvent(
    header: option.Option(String),
    payload: option.Option(String),
  )
}

pub fn encode_headers_and_implicit_payload_event_struct(
  input: HeadersAndImplicitPayloadEvent,
) -> json.Json {
  let pairs = []
  let pairs = case input.header {
    option.Some(v) -> [#("header", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_headers_and_implicit_payload_event_struct() -> decode.Decoder(
  HeadersAndImplicitPayloadEvent,
) {
  use header <- decode.optional_field(
    "header",
    option.None,
    decode.optional(decode.string),
  )
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HeadersAndImplicitPayloadEvent(
    header: header,
    payload: payload,
  ))
}

pub type StringPayloadEvent {
  StringPayloadEvent(payload: option.Option(String))
}

pub fn encode_string_payload_event_struct(
  input: StringPayloadEvent,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_string_payload_event_struct() -> decode.Decoder(
  StringPayloadEvent,
) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(StringPayloadEvent(payload: payload))
}

pub type StructurePayloadEvent {
  StructurePayloadEvent(payload: option.Option(PayloadStructure))
}

pub fn encode_structure_payload_event_struct(
  input: StructurePayloadEvent,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [
      #("payload", encode_payload_structure_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_structure_payload_event_struct() -> decode.Decoder(
  StructurePayloadEvent,
) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode_payload_structure_struct()),
  )
  decode.success(StructurePayloadEvent(payload: payload))
}

pub type UnionPayloadEvent {
  UnionPayloadEvent(payload: option.Option(PayloadUnion))
}

pub fn encode_union_payload_event_struct(
  input: UnionPayloadEvent,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", encode_payload_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_union_payload_event_struct() -> decode.Decoder(UnionPayloadEvent) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode_payload_union_union()),
  )
  decode.success(UnionPayloadEvent(payload: payload))
}

pub type PayloadUnion {
  PayloadUnionUnionMember(String)
}

pub fn encode_payload_union_union(v: PayloadUnion) -> json.Json {
  case v {
    PayloadUnionUnionMember(x) ->
      json.object([#("unionMember", json.string(x))])
  }
}

pub fn decode_payload_union_union() -> decode.Decoder(PayloadUnion) {
  decode.one_of(
    decode.field("unionMember", decode.string, fn(x) {
      decode.success(PayloadUnionUnionMember(x))
    }),
    [],
  )
}

pub type DuplexStreamOutput {
  DuplexStreamOutput(stream: option.Option(EventStream))
}

pub fn encode_duplex_stream_output_struct(
  input: DuplexStreamOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_duplex_stream_output_struct() -> decode.Decoder(
  DuplexStreamOutput,
) {
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(DuplexStreamOutput(stream: stream))
}

pub type DuplexStreamWithDistinctStreamsInput {
  DuplexStreamWithDistinctStreamsInput(stream: option.Option(EventStream))
}

pub fn encode_duplex_stream_with_distinct_streams_input_struct(
  input: DuplexStreamWithDistinctStreamsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_duplex_stream_with_distinct_streams_input_struct() -> decode.Decoder(
  DuplexStreamWithDistinctStreamsInput,
) {
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(DuplexStreamWithDistinctStreamsInput(stream: stream))
}

pub type DuplexStreamWithDistinctStreamsOutput {
  DuplexStreamWithDistinctStreamsOutput(
    stream: option.Option(SingletonEventStream),
  )
}

pub fn encode_duplex_stream_with_distinct_streams_output_struct(
  input: DuplexStreamWithDistinctStreamsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.stream {
    option.Some(v) -> [
      #("stream", encode_singleton_event_stream_union(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_duplex_stream_with_distinct_streams_output_struct() -> decode.Decoder(
  DuplexStreamWithDistinctStreamsOutput,
) {
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_singleton_event_stream_union()),
  )
  decode.success(DuplexStreamWithDistinctStreamsOutput(stream: stream))
}

pub type SingletonEventStream {
  SingletonEventStreamSingleton(SingletonEvent)
}

pub fn encode_singleton_event_stream_union(
  v: SingletonEventStream,
) -> json.Json {
  case v {
    SingletonEventStreamSingleton(x) ->
      json.object([#("singleton", encode_singleton_event_struct(x))])
  }
}

pub fn decode_singleton_event_stream_union() -> decode.Decoder(
  SingletonEventStream,
) {
  decode.one_of(
    decode.field("singleton", decode_singleton_event_struct(), fn(x) {
      decode.success(SingletonEventStreamSingleton(x))
    }),
    [],
  )
}

pub type SingletonEvent {
  SingletonEvent(value: option.Option(String))
}

pub fn encode_singleton_event_struct(input: SingletonEvent) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_singleton_event_struct() -> decode.Decoder(SingletonEvent) {
  use value <- decode.optional_field(
    "value",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(SingletonEvent(value: value))
}

pub type DuplexStreamWithInitialMessagesInput {
  DuplexStreamWithInitialMessagesInput(
    initial_request_member: option.Option(String),
    stream: option.Option(EventStream),
  )
}

pub fn encode_duplex_stream_with_initial_messages_input_struct(
  input: DuplexStreamWithInitialMessagesInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.initial_request_member {
    option.Some(v) -> [#("initialRequestMember", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_duplex_stream_with_initial_messages_input_struct() -> decode.Decoder(
  DuplexStreamWithInitialMessagesInput,
) {
  use initial_request_member <- decode.optional_field(
    "initialRequestMember",
    option.None,
    decode.optional(decode.string),
  )
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(DuplexStreamWithInitialMessagesInput(
    initial_request_member: initial_request_member,
    stream: stream,
  ))
}

pub type DuplexStreamWithInitialMessagesOutput {
  DuplexStreamWithInitialMessagesOutput(
    initial_response_member: option.Option(String),
    stream: option.Option(EventStream),
  )
}

pub fn encode_duplex_stream_with_initial_messages_output_struct(
  input: DuplexStreamWithInitialMessagesOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.initial_response_member {
    option.Some(v) -> [#("initialResponseMember", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_duplex_stream_with_initial_messages_output_struct() -> decode.Decoder(
  DuplexStreamWithInitialMessagesOutput,
) {
  use initial_response_member <- decode.optional_field(
    "initialResponseMember",
    option.None,
    decode.optional(decode.string),
  )
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(DuplexStreamWithInitialMessagesOutput(
    initial_response_member: initial_response_member,
    stream: stream,
  ))
}

pub type EmptyInputAndEmptyOutputInput {
  EmptyInputAndEmptyOutputInput
}

pub fn encode_empty_input_and_empty_output_input_struct(
  _v: EmptyInputAndEmptyOutputInput,
) -> json.Json {
  json.object([])
}

pub fn decode_empty_input_and_empty_output_input_struct() -> decode.Decoder(
  EmptyInputAndEmptyOutputInput,
) {
  decode.success(EmptyInputAndEmptyOutputInput)
}

pub type EmptyInputAndEmptyOutputOutput {
  EmptyInputAndEmptyOutputOutput
}

pub fn encode_empty_input_and_empty_output_output_struct(
  _v: EmptyInputAndEmptyOutputOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_empty_input_and_empty_output_output_struct() -> decode.Decoder(
  EmptyInputAndEmptyOutputOutput,
) {
  decode.success(EmptyInputAndEmptyOutputOutput)
}

pub type HostLabelInput {
  HostLabelInput(label: option.Option(String))
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
  use label <- decode.optional_field(
    "label",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HostLabelInput(label: label))
}

pub type FractionalSecondsOutput {
  FractionalSecondsOutput(datetime: option.Option(Int))
}

pub fn encode_fractional_seconds_output_struct(
  input: FractionalSecondsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.datetime {
    option.Some(v) -> [#("datetime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_fractional_seconds_output_struct() -> decode.Decoder(
  FractionalSecondsOutput,
) {
  use datetime <- decode.optional_field(
    "datetime",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(FractionalSecondsOutput(datetime: datetime))
}

pub type GreetingWithErrorsOutput {
  GreetingWithErrorsOutput(greeting: option.Option(String))
}

pub fn encode_greeting_with_errors_output_struct(
  input: GreetingWithErrorsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.greeting {
    option.Some(v) -> [#("greeting", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_greeting_with_errors_output_struct() -> decode.Decoder(
  GreetingWithErrorsOutput,
) {
  use greeting <- decode.optional_field(
    "greeting",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GreetingWithErrorsOutput(greeting: greeting))
}

pub type HttpEmptyPrefixHeadersInput {
  HttpEmptyPrefixHeadersInput(
    prefix_headers: option.Option(dict.Dict(String, String)),
    specific_header: option.Option(String),
  )
}

pub fn encode_http_empty_prefix_headers_input_struct(
  input: HttpEmptyPrefixHeadersInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.prefix_headers {
    option.Some(v) -> [
      #(
        "prefixHeaders",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.specific_header {
    option.Some(v) -> [#("specificHeader", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_empty_prefix_headers_input_struct() -> decode.Decoder(
  HttpEmptyPrefixHeadersInput,
) {
  use prefix_headers <- decode.optional_field(
    "prefixHeaders",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use specific_header <- decode.optional_field(
    "specificHeader",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HttpEmptyPrefixHeadersInput(
    prefix_headers: prefix_headers,
    specific_header: specific_header,
  ))
}

pub type HttpEmptyPrefixHeadersOutput {
  HttpEmptyPrefixHeadersOutput(
    prefix_headers: option.Option(dict.Dict(String, String)),
    specific_header: option.Option(String),
  )
}

pub fn encode_http_empty_prefix_headers_output_struct(
  input: HttpEmptyPrefixHeadersOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.prefix_headers {
    option.Some(v) -> [
      #(
        "prefixHeaders",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.specific_header {
    option.Some(v) -> [#("specificHeader", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_empty_prefix_headers_output_struct() -> decode.Decoder(
  HttpEmptyPrefixHeadersOutput,
) {
  use prefix_headers <- decode.optional_field(
    "prefixHeaders",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use specific_header <- decode.optional_field(
    "specificHeader",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HttpEmptyPrefixHeadersOutput(
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
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode_string_enum_enum()),
  )
  decode.success(EnumPayloadInput(payload: payload))
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
  HttpPayloadTraitsInputOutput(
    blob: option.Option(BitArray),
    foo: option.Option(String),
  )
}

pub fn encode_http_payload_traits_input_output_struct(
  input: HttpPayloadTraitsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [
      #("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_traits_input_output_struct() -> decode.Decoder(
  HttpPayloadTraitsInputOutput,
) {
  use blob <- decode.optional_field(
    "blob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HttpPayloadTraitsInputOutput(blob: blob, foo: foo))
}

pub type HttpPayloadTraitsWithMediaTypeInputOutput {
  HttpPayloadTraitsWithMediaTypeInputOutput(
    blob: option.Option(BitArray),
    foo: option.Option(String),
  )
}

pub fn encode_http_payload_traits_with_media_type_input_output_struct(
  input: HttpPayloadTraitsWithMediaTypeInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [
      #("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_traits_with_media_type_input_output_struct() -> decode.Decoder(
  HttpPayloadTraitsWithMediaTypeInputOutput,
) {
  use blob <- decode.optional_field(
    "blob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HttpPayloadTraitsWithMediaTypeInputOutput(blob: blob, foo: foo))
}

pub type HttpPayloadWithStructureInputOutput {
  HttpPayloadWithStructureInputOutput(nested: option.Option(NestedPayload))
}

pub fn encode_http_payload_with_structure_input_output_struct(
  input: HttpPayloadWithStructureInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_nested_payload_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_structure_input_output_struct() -> decode.Decoder(
  HttpPayloadWithStructureInputOutput,
) {
  use nested <- decode.optional_field(
    "nested",
    option.None,
    decode.optional(decode_nested_payload_struct()),
  )
  decode.success(HttpPayloadWithStructureInputOutput(nested: nested))
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
  use greeting <- decode.optional_field(
    "greeting",
    option.None,
    decode.optional(decode.string),
  )
  use name <- decode.optional_field(
    "name",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(NestedPayload(greeting: greeting, name: name))
}

pub type HttpPayloadWithUnionInputOutput {
  HttpPayloadWithUnionInputOutput(nested: option.Option(UnionPayload))
}

pub fn encode_http_payload_with_union_input_output_struct(
  input: HttpPayloadWithUnionInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [#("nested", encode_union_payload_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_payload_with_union_input_output_struct() -> decode.Decoder(
  HttpPayloadWithUnionInputOutput,
) {
  use nested <- decode.optional_field(
    "nested",
    option.None,
    decode.optional(decode_union_payload_union()),
  )
  decode.success(HttpPayloadWithUnionInputOutput(nested: nested))
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
  decode.one_of(
    decode.field("greeting", decode.string, fn(x) {
      decode.success(UnionPayloadGreeting(x))
    }),
    [],
  )
}

pub type HttpPrefixHeadersInput {
  HttpPrefixHeadersInput(
    foo: option.Option(String),
    foo_map: option.Option(dict.Dict(String, String)),
  )
}

pub fn encode_http_prefix_headers_input_struct(
  input: HttpPrefixHeadersInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_map {
    option.Some(v) -> [
      #(
        "fooMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_prefix_headers_input_struct() -> decode.Decoder(
  HttpPrefixHeadersInput,
) {
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  use foo_map <- decode.optional_field(
    "fooMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  decode.success(HttpPrefixHeadersInput(foo: foo, foo_map: foo_map))
}

pub type HttpPrefixHeadersOutput {
  HttpPrefixHeadersOutput(
    foo: option.Option(String),
    foo_map: option.Option(dict.Dict(String, String)),
  )
}

pub fn encode_http_prefix_headers_output_struct(
  input: HttpPrefixHeadersOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.foo_map {
    option.Some(v) -> [
      #(
        "fooMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_prefix_headers_output_struct() -> decode.Decoder(
  HttpPrefixHeadersOutput,
) {
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  use foo_map <- decode.optional_field(
    "fooMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  decode.success(HttpPrefixHeadersOutput(foo: foo, foo_map: foo_map))
}

pub type HttpPrefixHeadersInResponseInput {
  HttpPrefixHeadersInResponseInput
}

pub fn encode_http_prefix_headers_in_response_input_struct(
  _v: HttpPrefixHeadersInResponseInput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_prefix_headers_in_response_input_struct() -> decode.Decoder(
  HttpPrefixHeadersInResponseInput,
) {
  decode.success(HttpPrefixHeadersInResponseInput)
}

pub type HttpPrefixHeadersInResponseOutput {
  HttpPrefixHeadersInResponseOutput(
    prefix_headers: option.Option(dict.Dict(String, String)),
  )
}

pub fn encode_http_prefix_headers_in_response_output_struct(
  input: HttpPrefixHeadersInResponseOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.prefix_headers {
    option.Some(v) -> [
      #(
        "prefixHeaders",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_prefix_headers_in_response_output_struct() -> decode.Decoder(
  HttpPrefixHeadersInResponseOutput,
) {
  use prefix_headers <- decode.optional_field(
    "prefixHeaders",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  decode.success(HttpPrefixHeadersInResponseOutput(
    prefix_headers: prefix_headers,
  ))
}

pub type HttpQueryParamsOnlyInput {
  HttpQueryParamsOnlyInput(query_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_http_query_params_only_input_struct(
  input: HttpQueryParamsOnlyInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.query_map {
    option.Some(v) -> [
      #(
        "queryMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_query_params_only_input_struct() -> decode.Decoder(
  HttpQueryParamsOnlyInput,
) {
  use query_map <- decode.optional_field(
    "queryMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  decode.success(HttpQueryParamsOnlyInput(query_map: query_map))
}

pub type HttpRequestWithFloatLabelsInput {
  HttpRequestWithFloatLabelsInput(
    double: option.Option(json_float.SmithyFloat),
    float: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_http_request_with_float_labels_input_struct(
  input: HttpRequestWithFloatLabelsInput,
) -> json.Json {
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

pub fn decode_http_request_with_float_labels_input_struct() -> decode.Decoder(
  HttpRequestWithFloatLabelsInput,
) {
  use double <- decode.optional_field(
    "double",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use float <- decode.optional_field(
    "float",
    option.None,
    decode.optional(json_float.decoder()),
  )
  decode.success(HttpRequestWithFloatLabelsInput(double: double, float: float))
}

pub type HttpRequestWithGreedyLabelInPathInput {
  HttpRequestWithGreedyLabelInPathInput(
    baz: option.Option(String),
    foo: option.Option(String),
  )
}

pub fn encode_http_request_with_greedy_label_in_path_input_struct(
  input: HttpRequestWithGreedyLabelInPathInput,
) -> json.Json {
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

pub fn decode_http_request_with_greedy_label_in_path_input_struct() -> decode.Decoder(
  HttpRequestWithGreedyLabelInPathInput,
) {
  use baz <- decode.optional_field(
    "baz",
    option.None,
    decode.optional(decode.string),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HttpRequestWithGreedyLabelInPathInput(baz: baz, foo: foo))
}

pub type HttpRequestWithLabelsInput {
  HttpRequestWithLabelsInput(
    boolean: option.Option(Bool),
    double: option.Option(json_float.SmithyFloat),
    float: option.Option(json_float.SmithyFloat),
    integer: option.Option(Int),
    long: option.Option(Int),
    short: option.Option(Int),
    string: option.Option(String),
    timestamp: option.Option(Int),
  )
}

pub fn encode_http_request_with_labels_input_struct(
  input: HttpRequestWithLabelsInput,
) -> json.Json {
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

pub fn decode_http_request_with_labels_input_struct() -> decode.Decoder(
  HttpRequestWithLabelsInput,
) {
  use boolean <- decode.optional_field(
    "boolean",
    option.None,
    decode.optional(decode.bool),
  )
  use double <- decode.optional_field(
    "double",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use float <- decode.optional_field(
    "float",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use integer <- decode.optional_field(
    "integer",
    option.None,
    decode.optional(decode.int),
  )
  use long <- decode.optional_field(
    "long",
    option.None,
    decode.optional(decode.int),
  )
  use short <- decode.optional_field(
    "short",
    option.None,
    decode.optional(decode.int),
  )
  use string <- decode.optional_field(
    "string",
    option.None,
    decode.optional(decode.string),
  )
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
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

pub type HttpRequestWithLabelsAndTimestampFormatInput {
  HttpRequestWithLabelsAndTimestampFormatInput(
    default_format: option.Option(Int),
    member_date_time: option.Option(Int),
    member_epoch_seconds: option.Option(Int),
    member_http_date: option.Option(Int),
    target_date_time: option.Option(Int),
    target_epoch_seconds: option.Option(Int),
    target_http_date: option.Option(Int),
  )
}

pub fn encode_http_request_with_labels_and_timestamp_format_input_struct(
  input: HttpRequestWithLabelsAndTimestampFormatInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.default_format {
    option.Some(v) -> [#("defaultFormat", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_date_time {
    option.Some(v) -> [#("memberDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_epoch_seconds {
    option.Some(v) -> [#("memberEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_http_date {
    option.Some(v) -> [#("memberHttpDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_date_time {
    option.Some(v) -> [#("targetDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_epoch_seconds {
    option.Some(v) -> [#("targetEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_http_date {
    option.Some(v) -> [#("targetHttpDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_request_with_labels_and_timestamp_format_input_struct() -> decode.Decoder(
  HttpRequestWithLabelsAndTimestampFormatInput,
) {
  use default_format <- decode.optional_field(
    "defaultFormat",
    option.None,
    decode.optional(decode.int),
  )
  use member_date_time <- decode.optional_field(
    "memberDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use member_epoch_seconds <- decode.optional_field(
    "memberEpochSeconds",
    option.None,
    decode.optional(decode.int),
  )
  use member_http_date <- decode.optional_field(
    "memberHttpDate",
    option.None,
    decode.optional(decode.int),
  )
  use target_date_time <- decode.optional_field(
    "targetDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use target_epoch_seconds <- decode.optional_field(
    "targetEpochSeconds",
    option.None,
    decode.optional(decode.int),
  )
  use target_http_date <- decode.optional_field(
    "targetHttpDate",
    option.None,
    decode.optional(decode.int),
  )
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

pub type HttpRequestWithRegexLiteralInput {
  HttpRequestWithRegexLiteralInput(str: option.Option(String))
}

pub fn encode_http_request_with_regex_literal_input_struct(
  input: HttpRequestWithRegexLiteralInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.str {
    option.Some(v) -> [#("str", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_request_with_regex_literal_input_struct() -> decode.Decoder(
  HttpRequestWithRegexLiteralInput,
) {
  use str <- decode.optional_field(
    "str",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HttpRequestWithRegexLiteralInput(str: str))
}

pub type HttpResponseCodeOutput {
  HttpResponseCodeOutput(status: option.Option(Int))
}

pub fn encode_http_response_code_output_struct(
  input: HttpResponseCodeOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [#("Status", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_http_response_code_output_struct() -> decode.Decoder(
  HttpResponseCodeOutput,
) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(HttpResponseCodeOutput(status: status))
}

pub type StringPayloadInput {
  StringPayloadInput(payload: option.Option(String))
}

pub fn encode_string_payload_input_struct(
  input: StringPayloadInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_string_payload_input_struct() -> decode.Decoder(
  StringPayloadInput,
) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(StringPayloadInput(payload: payload))
}

pub type IgnoreQueryParamsInResponseOutput {
  IgnoreQueryParamsInResponseOutput(baz: option.Option(String))
}

pub fn encode_ignore_query_params_in_response_output_struct(
  input: IgnoreQueryParamsInResponseOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.baz {
    option.Some(v) -> [#("baz", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_ignore_query_params_in_response_output_struct() -> decode.Decoder(
  IgnoreQueryParamsInResponseOutput,
) {
  use baz <- decode.optional_field(
    "baz",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(IgnoreQueryParamsInResponseOutput(baz: baz))
}

pub type InputAndOutputWithHeadersIO {
  InputAndOutputWithHeadersIO(
    header_boolean_list: option.Option(List(Bool)),
    header_byte: option.Option(Int),
    header_double: option.Option(json_float.SmithyFloat),
    header_enum: option.Option(FooEnum),
    header_enum_list: option.Option(List(FooEnum)),
    header_false_bool: option.Option(Bool),
    header_float: option.Option(json_float.SmithyFloat),
    header_integer: option.Option(Int),
    header_integer_enum: option.Option(IntegerEnum),
    header_integer_enum_list: option.Option(List(IntegerEnum)),
    header_integer_list: option.Option(List(Int)),
    header_long: option.Option(Int),
    header_short: option.Option(Int),
    header_string: option.Option(String),
    header_string_list: option.Option(List(String)),
    header_string_set: option.Option(List(String)),
    header_timestamp_list: option.Option(List(Int)),
    header_true_bool: option.Option(Bool),
  )
}

pub fn encode_input_and_output_with_headers_io_struct(
  input: InputAndOutputWithHeadersIO,
) -> json.Json {
  let pairs = []
  let pairs = case input.header_boolean_list {
    option.Some(v) -> [
      #("headerBooleanList", fn(xs) { json.array(xs, json.bool) }(v)),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("headerEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
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
  let pairs = case input.header_integer_enum {
    option.Some(v) -> [
      #("headerIntegerEnum", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.header_integer_enum_list {
    option.Some(v) -> [
      #(
        "headerIntegerEnumList",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.header_integer_list {
    option.Some(v) -> [
      #("headerIntegerList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("headerStringList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.header_string_set {
    option.Some(v) -> [
      #("headerStringSet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.header_timestamp_list {
    option.Some(v) -> [
      #("headerTimestampList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.header_true_bool {
    option.Some(v) -> [#("headerTrueBool", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_input_and_output_with_headers_io_struct() -> decode.Decoder(
  InputAndOutputWithHeadersIO,
) {
  use header_boolean_list <- decode.optional_field(
    "headerBooleanList",
    option.None,
    decode.optional(decode.list(decode.bool)),
  )
  use header_byte <- decode.optional_field(
    "headerByte",
    option.None,
    decode.optional(decode.int),
  )
  use header_double <- decode.optional_field(
    "headerDouble",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use header_enum <- decode.optional_field(
    "headerEnum",
    option.None,
    decode.optional(decode_foo_enum_enum()),
  )
  use header_enum_list <- decode.optional_field(
    "headerEnumList",
    option.None,
    decode.optional(decode.list(decode_foo_enum_enum())),
  )
  use header_false_bool <- decode.optional_field(
    "headerFalseBool",
    option.None,
    decode.optional(decode.bool),
  )
  use header_float <- decode.optional_field(
    "headerFloat",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use header_integer <- decode.optional_field(
    "headerInteger",
    option.None,
    decode.optional(decode.int),
  )
  use header_integer_enum <- decode.optional_field(
    "headerIntegerEnum",
    option.None,
    decode.optional(decode_integer_enum_int_enum()),
  )
  use header_integer_enum_list <- decode.optional_field(
    "headerIntegerEnumList",
    option.None,
    decode.optional(decode.list(decode_integer_enum_int_enum())),
  )
  use header_integer_list <- decode.optional_field(
    "headerIntegerList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  use header_long <- decode.optional_field(
    "headerLong",
    option.None,
    decode.optional(decode.int),
  )
  use header_short <- decode.optional_field(
    "headerShort",
    option.None,
    decode.optional(decode.int),
  )
  use header_string <- decode.optional_field(
    "headerString",
    option.None,
    decode.optional(decode.string),
  )
  use header_string_list <- decode.optional_field(
    "headerStringList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use header_string_set <- decode.optional_field(
    "headerStringSet",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use header_timestamp_list <- decode.optional_field(
    "headerTimestampList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  use header_true_bool <- decode.optional_field(
    "headerTrueBool",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(InputAndOutputWithHeadersIO(
    header_boolean_list: header_boolean_list,
    header_byte: header_byte,
    header_double: header_double,
    header_enum: header_enum,
    header_enum_list: header_enum_list,
    header_false_bool: header_false_bool,
    header_float: header_float,
    header_integer: header_integer,
    header_integer_enum: header_integer_enum,
    header_integer_enum_list: header_integer_enum_list,
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

pub type InputStreamInput {
  InputStreamInput(stream: option.Option(EventStream))
}

pub fn encode_input_stream_input_struct(input: InputStreamInput) -> json.Json {
  let pairs = []
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_input_stream_input_struct() -> decode.Decoder(InputStreamInput) {
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(InputStreamInput(stream: stream))
}

pub type InputStreamWithInitialRequestInput {
  InputStreamWithInitialRequestInput(
    initial_request_member: option.Option(String),
    stream: option.Option(EventStream),
  )
}

pub fn encode_input_stream_with_initial_request_input_struct(
  input: InputStreamWithInitialRequestInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.initial_request_member {
    option.Some(v) -> [#("initialRequestMember", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_input_stream_with_initial_request_input_struct() -> decode.Decoder(
  InputStreamWithInitialRequestInput,
) {
  use initial_request_member <- decode.optional_field(
    "initialRequestMember",
    option.None,
    decode.optional(decode.string),
  )
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(InputStreamWithInitialRequestInput(
    initial_request_member: initial_request_member,
    stream: stream,
  ))
}

pub type JsonBlobsInputOutput {
  JsonBlobsInputOutput(data: option.Option(BitArray))
}

pub fn encode_json_blobs_input_output_struct(
  input: JsonBlobsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [
      #("data", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_blobs_input_output_struct() -> decode.Decoder(
  JsonBlobsInputOutput,
) {
  use data <- decode.optional_field(
    "data",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  decode.success(JsonBlobsInputOutput(data: data))
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

pub fn encode_json_enums_input_output_struct(
  input: JsonEnumsInputOutput,
) -> json.Json {
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
    option.Some(v) -> [
      #("fooEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_map {
    option.Some(v) -> [
      #(
        "fooEnumMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_set {
    option.Some(v) -> [
      #("fooEnumSet", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_enums_input_output_struct() -> decode.Decoder(
  JsonEnumsInputOutput,
) {
  use foo_enum1 <- decode.optional_field(
    "fooEnum1",
    option.None,
    decode.optional(decode_foo_enum_enum()),
  )
  use foo_enum2 <- decode.optional_field(
    "fooEnum2",
    option.None,
    decode.optional(decode_foo_enum_enum()),
  )
  use foo_enum3 <- decode.optional_field(
    "fooEnum3",
    option.None,
    decode.optional(decode_foo_enum_enum()),
  )
  use foo_enum_list <- decode.optional_field(
    "fooEnumList",
    option.None,
    decode.optional(decode.list(decode_foo_enum_enum())),
  )
  use foo_enum_map <- decode.optional_field(
    "fooEnumMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode_foo_enum_enum())),
  )
  use foo_enum_set <- decode.optional_field(
    "fooEnumSet",
    option.None,
    decode.optional(decode.list(decode_foo_enum_enum())),
  )
  decode.success(JsonEnumsInputOutput(
    foo_enum1: foo_enum1,
    foo_enum2: foo_enum2,
    foo_enum3: foo_enum3,
    foo_enum_list: foo_enum_list,
    foo_enum_map: foo_enum_map,
    foo_enum_set: foo_enum_set,
  ))
}

pub type JsonIntEnumsInputOutput {
  JsonIntEnumsInputOutput(
    integer_enum1: option.Option(IntegerEnum),
    integer_enum2: option.Option(IntegerEnum),
    integer_enum3: option.Option(IntegerEnum),
    integer_enum_list: option.Option(List(IntegerEnum)),
    integer_enum_map: option.Option(dict.Dict(String, IntegerEnum)),
    integer_enum_set: option.Option(List(IntegerEnum)),
  )
}

pub fn encode_json_int_enums_input_output_struct(
  input: JsonIntEnumsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.integer_enum1 {
    option.Some(v) -> [
      #("integerEnum1", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum2 {
    option.Some(v) -> [
      #("integerEnum2", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum3 {
    option.Some(v) -> [
      #("integerEnum3", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum_list {
    option.Some(v) -> [
      #(
        "integerEnumList",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum_map {
    option.Some(v) -> [
      #(
        "integerEnumMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_integer_enum_int_enum(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum_set {
    option.Some(v) -> [
      #(
        "integerEnumSet",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_int_enums_input_output_struct() -> decode.Decoder(
  JsonIntEnumsInputOutput,
) {
  use integer_enum1 <- decode.optional_field(
    "integerEnum1",
    option.None,
    decode.optional(decode_integer_enum_int_enum()),
  )
  use integer_enum2 <- decode.optional_field(
    "integerEnum2",
    option.None,
    decode.optional(decode_integer_enum_int_enum()),
  )
  use integer_enum3 <- decode.optional_field(
    "integerEnum3",
    option.None,
    decode.optional(decode_integer_enum_int_enum()),
  )
  use integer_enum_list <- decode.optional_field(
    "integerEnumList",
    option.None,
    decode.optional(decode.list(decode_integer_enum_int_enum())),
  )
  use integer_enum_map <- decode.optional_field(
    "integerEnumMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode_integer_enum_int_enum())),
  )
  use integer_enum_set <- decode.optional_field(
    "integerEnumSet",
    option.None,
    decode.optional(decode.list(decode_integer_enum_int_enum())),
  )
  decode.success(JsonIntEnumsInputOutput(
    integer_enum1: integer_enum1,
    integer_enum2: integer_enum2,
    integer_enum3: integer_enum3,
    integer_enum_list: integer_enum_list,
    integer_enum_map: integer_enum_map,
    integer_enum_set: integer_enum_set,
  ))
}

pub type JsonListsInputOutput {
  JsonListsInputOutput(
    boolean_list: option.Option(List(Bool)),
    enum_list: option.Option(List(FooEnum)),
    int_enum_list: option.Option(List(IntegerEnum)),
    integer_list: option.Option(List(Int)),
    nested_string_list: option.Option(List(List(String))),
    string_list: option.Option(List(String)),
    string_set: option.Option(List(String)),
    structure_list: option.Option(List(StructureListMember)),
    timestamp_list: option.Option(List(Int)),
  )
}

pub fn encode_json_lists_input_output_struct(
  input: JsonListsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_list {
    option.Some(v) -> [
      #("booleanList", fn(xs) { json.array(xs, json.bool) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.enum_list {
    option.Some(v) -> [
      #("enumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [
      #(
        "intEnumList",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_list {
    option.Some(v) -> [
      #("integerList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.nested_string_list {
    option.Some(v) -> [
      #(
        "nestedStringList",
        fn(xs) { json.array(xs, fn(xs) { json.array(xs, json.string) }) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.string_list {
    option.Some(v) -> [
      #("stringList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.string_set {
    option.Some(v) -> [
      #("stringSet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.structure_list {
    option.Some(v) -> [
      #(
        "structureList",
        fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.timestamp_list {
    option.Some(v) -> [
      #("timestampList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_lists_input_output_struct() -> decode.Decoder(
  JsonListsInputOutput,
) {
  use boolean_list <- decode.optional_field(
    "booleanList",
    option.None,
    decode.optional(decode.list(decode.bool)),
  )
  use enum_list <- decode.optional_field(
    "enumList",
    option.None,
    decode.optional(decode.list(decode_foo_enum_enum())),
  )
  use int_enum_list <- decode.optional_field(
    "intEnumList",
    option.None,
    decode.optional(decode.list(decode_integer_enum_int_enum())),
  )
  use integer_list <- decode.optional_field(
    "integerList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  use nested_string_list <- decode.optional_field(
    "nestedStringList",
    option.None,
    decode.optional(decode.list(decode.list(decode.string))),
  )
  use string_list <- decode.optional_field(
    "stringList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use string_set <- decode.optional_field(
    "stringSet",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use structure_list <- decode.optional_field(
    "structureList",
    option.None,
    decode.optional(decode.list(decode_structure_list_member_struct())),
  )
  use timestamp_list <- decode.optional_field(
    "timestampList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  decode.success(JsonListsInputOutput(
    boolean_list: boolean_list,
    enum_list: enum_list,
    int_enum_list: int_enum_list,
    integer_list: integer_list,
    nested_string_list: nested_string_list,
    string_list: string_list,
    string_set: string_set,
    structure_list: structure_list,
    timestamp_list: timestamp_list,
  ))
}

pub type StructureListMember {
  StructureListMember(a: option.Option(String), b: option.Option(String))
}

pub fn encode_structure_list_member_struct(
  input: StructureListMember,
) -> json.Json {
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

pub fn decode_structure_list_member_struct() -> decode.Decoder(
  StructureListMember,
) {
  use a <- decode.optional_field(
    "a",
    option.None,
    decode.optional(decode.string),
  )
  use b <- decode.optional_field(
    "b",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(StructureListMember(a: a, b: b))
}

pub type JsonMapsInputOutput {
  JsonMapsInputOutput(
    dense_boolean_map: option.Option(dict.Dict(String, Bool)),
    dense_number_map: option.Option(dict.Dict(String, Int)),
    dense_set_map: option.Option(dict.Dict(String, List(String))),
    dense_string_map: option.Option(dict.Dict(String, String)),
    dense_struct_map: option.Option(dict.Dict(String, GreetingStruct)),
  )
}

pub fn encode_json_maps_input_output_struct(
  input: JsonMapsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.dense_boolean_map {
    option.Some(v) -> [
      #(
        "denseBooleanMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.bool(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_number_map {
    option.Some(v) -> [
      #(
        "denseNumberMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.int(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_set_map {
    option.Some(v) -> [
      #(
        "denseSetMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_string_map {
    option.Some(v) -> [
      #(
        "denseStringMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_struct_map {
    option.Some(v) -> [
      #(
        "denseStructMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_greeting_struct_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_maps_input_output_struct() -> decode.Decoder(
  JsonMapsInputOutput,
) {
  use dense_boolean_map <- decode.optional_field(
    "denseBooleanMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.bool)),
  )
  use dense_number_map <- decode.optional_field(
    "denseNumberMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.int)),
  )
  use dense_set_map <- decode.optional_field(
    "denseSetMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.list(decode.string))),
  )
  use dense_string_map <- decode.optional_field(
    "denseStringMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use dense_struct_map <- decode.optional_field(
    "denseStructMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())),
  )
  decode.success(JsonMapsInputOutput(
    dense_boolean_map: dense_boolean_map,
    dense_number_map: dense_number_map,
    dense_set_map: dense_set_map,
    dense_string_map: dense_string_map,
    dense_struct_map: dense_struct_map,
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
  use hi <- decode.optional_field(
    "hi",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GreetingStruct(hi: hi))
}

pub type JsonTimestampsInputOutput {
  JsonTimestampsInputOutput(
    date_time: option.Option(Int),
    date_time_on_target: option.Option(Int),
    epoch_seconds: option.Option(Int),
    epoch_seconds_on_target: option.Option(Int),
    http_date: option.Option(Int),
    http_date_on_target: option.Option(Int),
    normal: option.Option(Int),
  )
}

pub fn encode_json_timestamps_input_output_struct(
  input: JsonTimestampsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.date_time {
    option.Some(v) -> [#("dateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.date_time_on_target {
    option.Some(v) -> [#("dateTimeOnTarget", json.int(v)), ..pairs]
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
    option.Some(v) -> [#("httpDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.http_date_on_target {
    option.Some(v) -> [#("httpDateOnTarget", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.normal {
    option.Some(v) -> [#("normal", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_timestamps_input_output_struct() -> decode.Decoder(
  JsonTimestampsInputOutput,
) {
  use date_time <- decode.optional_field(
    "dateTime",
    option.None,
    decode.optional(decode.int),
  )
  use date_time_on_target <- decode.optional_field(
    "dateTimeOnTarget",
    option.None,
    decode.optional(decode.int),
  )
  use epoch_seconds <- decode.optional_field(
    "epochSeconds",
    option.None,
    decode.optional(decode.int),
  )
  use epoch_seconds_on_target <- decode.optional_field(
    "epochSecondsOnTarget",
    option.None,
    decode.optional(decode.int),
  )
  use http_date <- decode.optional_field(
    "httpDate",
    option.None,
    decode.optional(decode.int),
  )
  use http_date_on_target <- decode.optional_field(
    "httpDateOnTarget",
    option.None,
    decode.optional(decode.int),
  )
  use normal <- decode.optional_field(
    "normal",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(JsonTimestampsInputOutput(
    date_time: date_time,
    date_time_on_target: date_time_on_target,
    epoch_seconds: epoch_seconds,
    epoch_seconds_on_target: epoch_seconds_on_target,
    http_date: http_date,
    http_date_on_target: http_date_on_target,
    normal: normal,
  ))
}

pub type UnionInputOutput {
  UnionInputOutput(contents: option.Option(MyUnion))
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
  use contents <- decode.optional_field(
    "contents",
    option.None,
    decode.optional(decode_my_union_union()),
  )
  decode.success(UnionInputOutput(contents: contents))
}

pub type MyUnion {
  MyUnionBlobValue(BitArray)
  MyUnionBooleanValue(Bool)
  MyUnionEnumValue(FooEnum)
  MyUnionListValue(List(String))
  MyUnionMapValue(dict.Dict(String, String))
  MyUnionNumberValue(Int)
  MyUnionRenamedStructureValue(GreetingStruct)
  MyUnionStringValue(String)
  MyUnionStructureValue(GreetingStruct)
  MyUnionTimestampValue(Int)
}

pub fn encode_my_union_union(v: MyUnion) -> json.Json {
  case v {
    MyUnionBlobValue(x) ->
      json.object([
        #(
          "blobValue",
          fn(b) { json.string(bit_array.base64_encode(b, True)) }(x),
        ),
      ])
    MyUnionBooleanValue(x) -> json.object([#("booleanValue", json.bool(x))])
    MyUnionEnumValue(x) ->
      json.object([#("enumValue", encode_foo_enum_enum(x))])
    MyUnionListValue(x) ->
      json.object([#("listValue", fn(xs) { json.array(xs, json.string) }(x))])
    MyUnionMapValue(x) ->
      json.object([
        #(
          "mapValue",
          fn(d) {
            json.object(
              dict.to_list(d)
              |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
            )
          }(x),
        ),
      ])
    MyUnionNumberValue(x) -> json.object([#("numberValue", json.int(x))])
    MyUnionRenamedStructureValue(x) ->
      json.object([#("renamedStructureValue", encode_greeting_struct_struct(x))])
    MyUnionStringValue(x) -> json.object([#("stringValue", json.string(x))])
    MyUnionStructureValue(x) ->
      json.object([#("structureValue", encode_greeting_struct_struct(x))])
    MyUnionTimestampValue(x) -> json.object([#("timestampValue", json.int(x))])
  }
}

pub fn decode_my_union_union() -> decode.Decoder(MyUnion) {
  decode.one_of(
    decode.field(
      "blobValue",
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
      fn(x) { decode.success(MyUnionBlobValue(x)) },
    ),
    [
      decode.field("booleanValue", decode.bool, fn(x) {
        decode.success(MyUnionBooleanValue(x))
      }),
      decode.field("enumValue", decode_foo_enum_enum(), fn(x) {
        decode.success(MyUnionEnumValue(x))
      }),
      decode.field("listValue", decode.list(decode.string), fn(x) {
        decode.success(MyUnionListValue(x))
      }),
      decode.field("mapValue", decode.dict(decode.string, decode.string), fn(x) {
        decode.success(MyUnionMapValue(x))
      }),
      decode.field("numberValue", decode.int, fn(x) {
        decode.success(MyUnionNumberValue(x))
      }),
      decode.field(
        "renamedStructureValue",
        decode_greeting_struct_struct(),
        fn(x) { decode.success(MyUnionRenamedStructureValue(x)) },
      ),
      decode.field("stringValue", decode.string, fn(x) {
        decode.success(MyUnionStringValue(x))
      }),
      decode.field("structureValue", decode_greeting_struct_struct(), fn(x) {
        decode.success(MyUnionStructureValue(x))
      }),
      decode.field("timestampValue", decode.int, fn(x) {
        decode.success(MyUnionTimestampValue(x))
      }),
    ],
  )
}

pub type MalformedAcceptWithGenericStringOutput {
  MalformedAcceptWithGenericStringOutput(payload: option.Option(String))
}

pub fn encode_malformed_accept_with_generic_string_output_struct(
  input: MalformedAcceptWithGenericStringOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_accept_with_generic_string_output_struct() -> decode.Decoder(
  MalformedAcceptWithGenericStringOutput,
) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MalformedAcceptWithGenericStringOutput(payload: payload))
}

pub type MalformedAcceptWithPayloadOutput {
  MalformedAcceptWithPayloadOutput(payload: option.Option(BitArray))
}

pub fn encode_malformed_accept_with_payload_output_struct(
  input: MalformedAcceptWithPayloadOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [
      #("payload", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_accept_with_payload_output_struct() -> decode.Decoder(
  MalformedAcceptWithPayloadOutput,
) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  decode.success(MalformedAcceptWithPayloadOutput(payload: payload))
}

pub type MalformedBlobInput {
  MalformedBlobInput(blob: option.Option(BitArray))
}

pub fn encode_malformed_blob_input_struct(
  input: MalformedBlobInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [
      #("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_blob_input_struct() -> decode.Decoder(
  MalformedBlobInput,
) {
  use blob <- decode.optional_field(
    "blob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  decode.success(MalformedBlobInput(blob: blob))
}

pub type MalformedBooleanInput {
  MalformedBooleanInput(
    boolean_in_body: option.Option(Bool),
    boolean_in_header: option.Option(Bool),
    boolean_in_path: option.Option(Bool),
    boolean_in_query: option.Option(Bool),
  )
}

pub fn encode_malformed_boolean_input_struct(
  input: MalformedBooleanInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_in_body {
    option.Some(v) -> [#("booleanInBody", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.boolean_in_header {
    option.Some(v) -> [#("booleanInHeader", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.boolean_in_path {
    option.Some(v) -> [#("booleanInPath", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.boolean_in_query {
    option.Some(v) -> [#("booleanInQuery", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_boolean_input_struct() -> decode.Decoder(
  MalformedBooleanInput,
) {
  use boolean_in_body <- decode.optional_field(
    "booleanInBody",
    option.None,
    decode.optional(decode.bool),
  )
  use boolean_in_header <- decode.optional_field(
    "booleanInHeader",
    option.None,
    decode.optional(decode.bool),
  )
  use boolean_in_path <- decode.optional_field(
    "booleanInPath",
    option.None,
    decode.optional(decode.bool),
  )
  use boolean_in_query <- decode.optional_field(
    "booleanInQuery",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(MalformedBooleanInput(
    boolean_in_body: boolean_in_body,
    boolean_in_header: boolean_in_header,
    boolean_in_path: boolean_in_path,
    boolean_in_query: boolean_in_query,
  ))
}

pub type MalformedByteInput {
  MalformedByteInput(
    byte_in_body: option.Option(Int),
    byte_in_header: option.Option(Int),
    byte_in_path: option.Option(Int),
    byte_in_query: option.Option(Int),
  )
}

pub fn encode_malformed_byte_input_struct(
  input: MalformedByteInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.byte_in_body {
    option.Some(v) -> [#("byteInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.byte_in_header {
    option.Some(v) -> [#("byteInHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.byte_in_path {
    option.Some(v) -> [#("byteInPath", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.byte_in_query {
    option.Some(v) -> [#("byteInQuery", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_byte_input_struct() -> decode.Decoder(
  MalformedByteInput,
) {
  use byte_in_body <- decode.optional_field(
    "byteInBody",
    option.None,
    decode.optional(decode.int),
  )
  use byte_in_header <- decode.optional_field(
    "byteInHeader",
    option.None,
    decode.optional(decode.int),
  )
  use byte_in_path <- decode.optional_field(
    "byteInPath",
    option.None,
    decode.optional(decode.int),
  )
  use byte_in_query <- decode.optional_field(
    "byteInQuery",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedByteInput(
    byte_in_body: byte_in_body,
    byte_in_header: byte_in_header,
    byte_in_path: byte_in_path,
    byte_in_query: byte_in_query,
  ))
}

pub type MalformedContentTypeWithGenericStringInput {
  MalformedContentTypeWithGenericStringInput(payload: option.Option(String))
}

pub fn encode_malformed_content_type_with_generic_string_input_struct(
  input: MalformedContentTypeWithGenericStringInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [#("payload", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_content_type_with_generic_string_input_struct() -> decode.Decoder(
  MalformedContentTypeWithGenericStringInput,
) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MalformedContentTypeWithGenericStringInput(payload: payload))
}

pub type MalformedContentTypeWithoutBodyEmptyInputInput {
  MalformedContentTypeWithoutBodyEmptyInputInput(header: option.Option(String))
}

pub fn encode_malformed_content_type_without_body_empty_input_input_struct(
  input: MalformedContentTypeWithoutBodyEmptyInputInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.header {
    option.Some(v) -> [#("header", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_content_type_without_body_empty_input_input_struct() -> decode.Decoder(
  MalformedContentTypeWithoutBodyEmptyInputInput,
) {
  use header <- decode.optional_field(
    "header",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MalformedContentTypeWithoutBodyEmptyInputInput(header: header))
}

pub type MalformedContentTypeWithPayloadInput {
  MalformedContentTypeWithPayloadInput(payload: option.Option(BitArray))
}

pub fn encode_malformed_content_type_with_payload_input_struct(
  input: MalformedContentTypeWithPayloadInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [
      #("payload", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_content_type_with_payload_input_struct() -> decode.Decoder(
  MalformedContentTypeWithPayloadInput,
) {
  use payload <- decode.optional_field(
    "payload",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  decode.success(MalformedContentTypeWithPayloadInput(payload: payload))
}

pub type MalformedDoubleInput {
  MalformedDoubleInput(
    double_in_body: option.Option(json_float.SmithyFloat),
    double_in_header: option.Option(json_float.SmithyFloat),
    double_in_path: option.Option(json_float.SmithyFloat),
    double_in_query: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_malformed_double_input_struct(
  input: MalformedDoubleInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.double_in_body {
    option.Some(v) -> [#("doubleInBody", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double_in_header {
    option.Some(v) -> [#("doubleInHeader", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double_in_path {
    option.Some(v) -> [#("doubleInPath", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.double_in_query {
    option.Some(v) -> [#("doubleInQuery", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_double_input_struct() -> decode.Decoder(
  MalformedDoubleInput,
) {
  use double_in_body <- decode.optional_field(
    "doubleInBody",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use double_in_header <- decode.optional_field(
    "doubleInHeader",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use double_in_path <- decode.optional_field(
    "doubleInPath",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use double_in_query <- decode.optional_field(
    "doubleInQuery",
    option.None,
    decode.optional(json_float.decoder()),
  )
  decode.success(MalformedDoubleInput(
    double_in_body: double_in_body,
    double_in_header: double_in_header,
    double_in_path: double_in_path,
    double_in_query: double_in_query,
  ))
}

pub type MalformedFloatInput {
  MalformedFloatInput(
    float_in_body: option.Option(json_float.SmithyFloat),
    float_in_header: option.Option(json_float.SmithyFloat),
    float_in_path: option.Option(json_float.SmithyFloat),
    float_in_query: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_malformed_float_input_struct(
  input: MalformedFloatInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.float_in_body {
    option.Some(v) -> [#("floatInBody", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_in_header {
    option.Some(v) -> [#("floatInHeader", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_in_path {
    option.Some(v) -> [#("floatInPath", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.float_in_query {
    option.Some(v) -> [#("floatInQuery", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_float_input_struct() -> decode.Decoder(
  MalformedFloatInput,
) {
  use float_in_body <- decode.optional_field(
    "floatInBody",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use float_in_header <- decode.optional_field(
    "floatInHeader",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use float_in_path <- decode.optional_field(
    "floatInPath",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use float_in_query <- decode.optional_field(
    "floatInQuery",
    option.None,
    decode.optional(json_float.decoder()),
  )
  decode.success(MalformedFloatInput(
    float_in_body: float_in_body,
    float_in_header: float_in_header,
    float_in_path: float_in_path,
    float_in_query: float_in_query,
  ))
}

pub type MalformedIntegerInput {
  MalformedIntegerInput(
    integer_in_body: option.Option(Int),
    integer_in_header: option.Option(Int),
    integer_in_path: option.Option(Int),
    integer_in_query: option.Option(Int),
  )
}

pub fn encode_malformed_integer_input_struct(
  input: MalformedIntegerInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.integer_in_body {
    option.Some(v) -> [#("integerInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_in_header {
    option.Some(v) -> [#("integerInHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_in_path {
    option.Some(v) -> [#("integerInPath", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.integer_in_query {
    option.Some(v) -> [#("integerInQuery", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_integer_input_struct() -> decode.Decoder(
  MalformedIntegerInput,
) {
  use integer_in_body <- decode.optional_field(
    "integerInBody",
    option.None,
    decode.optional(decode.int),
  )
  use integer_in_header <- decode.optional_field(
    "integerInHeader",
    option.None,
    decode.optional(decode.int),
  )
  use integer_in_path <- decode.optional_field(
    "integerInPath",
    option.None,
    decode.optional(decode.int),
  )
  use integer_in_query <- decode.optional_field(
    "integerInQuery",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedIntegerInput(
    integer_in_body: integer_in_body,
    integer_in_header: integer_in_header,
    integer_in_path: integer_in_path,
    integer_in_query: integer_in_query,
  ))
}

pub type MalformedListInput {
  MalformedListInput(body_list: option.Option(List(String)))
}

pub fn encode_malformed_list_input_struct(
  input: MalformedListInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.body_list {
    option.Some(v) -> [
      #("bodyList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_list_input_struct() -> decode.Decoder(
  MalformedListInput,
) {
  use body_list <- decode.optional_field(
    "bodyList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  decode.success(MalformedListInput(body_list: body_list))
}

pub type MalformedLongInput {
  MalformedLongInput(
    long_in_body: option.Option(Int),
    long_in_header: option.Option(Int),
    long_in_path: option.Option(Int),
    long_in_query: option.Option(Int),
  )
}

pub fn encode_malformed_long_input_struct(
  input: MalformedLongInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.long_in_body {
    option.Some(v) -> [#("longInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long_in_header {
    option.Some(v) -> [#("longInHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long_in_path {
    option.Some(v) -> [#("longInPath", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.long_in_query {
    option.Some(v) -> [#("longInQuery", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_long_input_struct() -> decode.Decoder(
  MalformedLongInput,
) {
  use long_in_body <- decode.optional_field(
    "longInBody",
    option.None,
    decode.optional(decode.int),
  )
  use long_in_header <- decode.optional_field(
    "longInHeader",
    option.None,
    decode.optional(decode.int),
  )
  use long_in_path <- decode.optional_field(
    "longInPath",
    option.None,
    decode.optional(decode.int),
  )
  use long_in_query <- decode.optional_field(
    "longInQuery",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedLongInput(
    long_in_body: long_in_body,
    long_in_header: long_in_header,
    long_in_path: long_in_path,
    long_in_query: long_in_query,
  ))
}

pub type MalformedMapInput {
  MalformedMapInput(body_map: option.Option(dict.Dict(String, String)))
}

pub fn encode_malformed_map_input_struct(
  input: MalformedMapInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.body_map {
    option.Some(v) -> [
      #(
        "bodyMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_map_input_struct() -> decode.Decoder(MalformedMapInput) {
  use body_map <- decode.optional_field(
    "bodyMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  decode.success(MalformedMapInput(body_map: body_map))
}

pub type MalformedRequestBodyInput {
  MalformedRequestBodyInput(
    float: option.Option(json_float.SmithyFloat),
    int: option.Option(Int),
  )
}

pub fn encode_malformed_request_body_input_struct(
  input: MalformedRequestBodyInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.float {
    option.Some(v) -> [#("float", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int {
    option.Some(v) -> [#("int", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_request_body_input_struct() -> decode.Decoder(
  MalformedRequestBodyInput,
) {
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

pub type MalformedShortInput {
  MalformedShortInput(
    short_in_body: option.Option(Int),
    short_in_header: option.Option(Int),
    short_in_path: option.Option(Int),
    short_in_query: option.Option(Int),
  )
}

pub fn encode_malformed_short_input_struct(
  input: MalformedShortInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.short_in_body {
    option.Some(v) -> [#("shortInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short_in_header {
    option.Some(v) -> [#("shortInHeader", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short_in_path {
    option.Some(v) -> [#("shortInPath", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.short_in_query {
    option.Some(v) -> [#("shortInQuery", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_short_input_struct() -> decode.Decoder(
  MalformedShortInput,
) {
  use short_in_body <- decode.optional_field(
    "shortInBody",
    option.None,
    decode.optional(decode.int),
  )
  use short_in_header <- decode.optional_field(
    "shortInHeader",
    option.None,
    decode.optional(decode.int),
  )
  use short_in_path <- decode.optional_field(
    "shortInPath",
    option.None,
    decode.optional(decode.int),
  )
  use short_in_query <- decode.optional_field(
    "shortInQuery",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedShortInput(
    short_in_body: short_in_body,
    short_in_header: short_in_header,
    short_in_path: short_in_path,
    short_in_query: short_in_query,
  ))
}

pub type MalformedStringInput {
  MalformedStringInput(blob: option.Option(String))
}

pub fn encode_malformed_string_input_struct(
  input: MalformedStringInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [#("blob", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_string_input_struct() -> decode.Decoder(
  MalformedStringInput,
) {
  use blob <- decode.optional_field(
    "blob",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MalformedStringInput(blob: blob))
}

pub type MalformedTimestampBodyDateTimeInput {
  MalformedTimestampBodyDateTimeInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_body_date_time_input_struct(
  input: MalformedTimestampBodyDateTimeInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_body_date_time_input_struct() -> decode.Decoder(
  MalformedTimestampBodyDateTimeInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampBodyDateTimeInput(timestamp: timestamp))
}

pub type MalformedTimestampBodyDefaultInput {
  MalformedTimestampBodyDefaultInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_body_default_input_struct(
  input: MalformedTimestampBodyDefaultInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_body_default_input_struct() -> decode.Decoder(
  MalformedTimestampBodyDefaultInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampBodyDefaultInput(timestamp: timestamp))
}

pub type MalformedTimestampBodyHttpDateInput {
  MalformedTimestampBodyHttpDateInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_body_http_date_input_struct(
  input: MalformedTimestampBodyHttpDateInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_body_http_date_input_struct() -> decode.Decoder(
  MalformedTimestampBodyHttpDateInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampBodyHttpDateInput(timestamp: timestamp))
}

pub type MalformedTimestampHeaderDateTimeInput {
  MalformedTimestampHeaderDateTimeInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_header_date_time_input_struct(
  input: MalformedTimestampHeaderDateTimeInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_header_date_time_input_struct() -> decode.Decoder(
  MalformedTimestampHeaderDateTimeInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampHeaderDateTimeInput(timestamp: timestamp))
}

pub type MalformedTimestampHeaderDefaultInput {
  MalformedTimestampHeaderDefaultInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_header_default_input_struct(
  input: MalformedTimestampHeaderDefaultInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_header_default_input_struct() -> decode.Decoder(
  MalformedTimestampHeaderDefaultInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampHeaderDefaultInput(timestamp: timestamp))
}

pub type MalformedTimestampHeaderEpochInput {
  MalformedTimestampHeaderEpochInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_header_epoch_input_struct(
  input: MalformedTimestampHeaderEpochInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_header_epoch_input_struct() -> decode.Decoder(
  MalformedTimestampHeaderEpochInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampHeaderEpochInput(timestamp: timestamp))
}

pub type MalformedTimestampPathDefaultInput {
  MalformedTimestampPathDefaultInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_path_default_input_struct(
  input: MalformedTimestampPathDefaultInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_path_default_input_struct() -> decode.Decoder(
  MalformedTimestampPathDefaultInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampPathDefaultInput(timestamp: timestamp))
}

pub type MalformedTimestampPathEpochInput {
  MalformedTimestampPathEpochInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_path_epoch_input_struct(
  input: MalformedTimestampPathEpochInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_path_epoch_input_struct() -> decode.Decoder(
  MalformedTimestampPathEpochInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampPathEpochInput(timestamp: timestamp))
}

pub type MalformedTimestampPathHttpDateInput {
  MalformedTimestampPathHttpDateInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_path_http_date_input_struct(
  input: MalformedTimestampPathHttpDateInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_path_http_date_input_struct() -> decode.Decoder(
  MalformedTimestampPathHttpDateInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampPathHttpDateInput(timestamp: timestamp))
}

pub type MalformedTimestampQueryDefaultInput {
  MalformedTimestampQueryDefaultInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_query_default_input_struct(
  input: MalformedTimestampQueryDefaultInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_query_default_input_struct() -> decode.Decoder(
  MalformedTimestampQueryDefaultInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampQueryDefaultInput(timestamp: timestamp))
}

pub type MalformedTimestampQueryEpochInput {
  MalformedTimestampQueryEpochInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_query_epoch_input_struct(
  input: MalformedTimestampQueryEpochInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_query_epoch_input_struct() -> decode.Decoder(
  MalformedTimestampQueryEpochInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampQueryEpochInput(timestamp: timestamp))
}

pub type MalformedTimestampQueryHttpDateInput {
  MalformedTimestampQueryHttpDateInput(timestamp: option.Option(Int))
}

pub fn encode_malformed_timestamp_query_http_date_input_struct(
  input: MalformedTimestampQueryHttpDateInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_timestamp_query_http_date_input_struct() -> decode.Decoder(
  MalformedTimestampQueryHttpDateInput,
) {
  use timestamp <- decode.optional_field(
    "timestamp",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(MalformedTimestampQueryHttpDateInput(timestamp: timestamp))
}

pub type MalformedUnionInput {
  MalformedUnionInput(union: option.Option(SimpleUnion))
}

pub fn encode_malformed_union_input_struct(
  input: MalformedUnionInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.union {
    option.Some(v) -> [#("union", encode_simple_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_malformed_union_input_struct() -> decode.Decoder(
  MalformedUnionInput,
) {
  use union <- decode.optional_field(
    "union",
    option.None,
    decode.optional(decode_simple_union_union()),
  )
  decode.success(MalformedUnionInput(union: union))
}

pub type SimpleUnion {
  SimpleUnionInt(Int)
  SimpleUnionString(String)
}

pub fn encode_simple_union_union(v: SimpleUnion) -> json.Json {
  case v {
    SimpleUnionInt(x) -> json.object([#("int", json.int(x))])
    SimpleUnionString(x) -> json.object([#("string", json.string(x))])
  }
}

pub fn decode_simple_union_union() -> decode.Decoder(SimpleUnion) {
  decode.one_of(
    decode.field("int", decode.int, fn(x) { decode.success(SimpleUnionInt(x)) }),
    [
      decode.field("string", decode.string, fn(x) {
        decode.success(SimpleUnionString(x))
      }),
    ],
  )
}

pub type MediaTypeHeaderInput {
  MediaTypeHeaderInput(json: option.Option(String))
}

pub fn encode_media_type_header_input_struct(
  input: MediaTypeHeaderInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.json {
    option.Some(v) -> [#("json", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_media_type_header_input_struct() -> decode.Decoder(
  MediaTypeHeaderInput,
) {
  use json <- decode.optional_field(
    "json",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MediaTypeHeaderInput(json: json))
}

pub type MediaTypeHeaderOutput {
  MediaTypeHeaderOutput(json: option.Option(String))
}

pub fn encode_media_type_header_output_struct(
  input: MediaTypeHeaderOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.json {
    option.Some(v) -> [#("json", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_media_type_header_output_struct() -> decode.Decoder(
  MediaTypeHeaderOutput,
) {
  use json <- decode.optional_field(
    "json",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MediaTypeHeaderOutput(json: json))
}

pub type NoInputAndOutputOutput {
  NoInputAndOutputOutput
}

pub fn encode_no_input_and_output_output_struct(
  _v: NoInputAndOutputOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_output_output_struct() -> decode.Decoder(
  NoInputAndOutputOutput,
) {
  decode.success(NoInputAndOutputOutput)
}

pub type NullAndEmptyHeadersIO {
  NullAndEmptyHeadersIO(
    a: option.Option(String),
    b: option.Option(String),
    c: option.Option(List(String)),
  )
}

pub fn encode_null_and_empty_headers_io_struct(
  input: NullAndEmptyHeadersIO,
) -> json.Json {
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
    option.Some(v) -> [
      #("c", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_null_and_empty_headers_io_struct() -> decode.Decoder(
  NullAndEmptyHeadersIO,
) {
  use a <- decode.optional_field(
    "a",
    option.None,
    decode.optional(decode.string),
  )
  use b <- decode.optional_field(
    "b",
    option.None,
    decode.optional(decode.string),
  )
  use c <- decode.optional_field(
    "c",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  decode.success(NullAndEmptyHeadersIO(a: a, b: b, c: c))
}

pub type OmitsNullSerializesEmptyStringInput {
  OmitsNullSerializesEmptyStringInput(
    empty_string: option.Option(String),
    null_value: option.Option(String),
  )
}

pub fn encode_omits_null_serializes_empty_string_input_struct(
  input: OmitsNullSerializesEmptyStringInput,
) -> json.Json {
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

pub fn decode_omits_null_serializes_empty_string_input_struct() -> decode.Decoder(
  OmitsNullSerializesEmptyStringInput,
) {
  use empty_string <- decode.optional_field(
    "emptyString",
    option.None,
    decode.optional(decode.string),
  )
  use null_value <- decode.optional_field(
    "nullValue",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(OmitsNullSerializesEmptyStringInput(
    empty_string: empty_string,
    null_value: null_value,
  ))
}

pub type OmitsSerializingEmptyListsInput {
  OmitsSerializingEmptyListsInput(
    query_boolean_list: option.Option(List(Bool)),
    query_double_list: option.Option(List(json_float.SmithyFloat)),
    query_enum_list: option.Option(List(FooEnum)),
    query_integer_enum_list: option.Option(List(IntegerEnum)),
    query_integer_list: option.Option(List(Int)),
    query_string_list: option.Option(List(String)),
    query_timestamp_list: option.Option(List(Int)),
  )
}

pub fn encode_omits_serializing_empty_lists_input_struct(
  input: OmitsSerializingEmptyListsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.query_boolean_list {
    option.Some(v) -> [
      #("queryBooleanList", fn(xs) { json.array(xs, json.bool) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_double_list {
    option.Some(v) -> [
      #("queryDoubleList", fn(xs) { json.array(xs, json_float.encode) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_enum_list {
    option.Some(v) -> [
      #("queryEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_integer_enum_list {
    option.Some(v) -> [
      #(
        "queryIntegerEnumList",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_integer_list {
    option.Some(v) -> [
      #("queryIntegerList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_string_list {
    option.Some(v) -> [
      #("queryStringList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.query_timestamp_list {
    option.Some(v) -> [
      #("queryTimestampList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_omits_serializing_empty_lists_input_struct() -> decode.Decoder(
  OmitsSerializingEmptyListsInput,
) {
  use query_boolean_list <- decode.optional_field(
    "queryBooleanList",
    option.None,
    decode.optional(decode.list(decode.bool)),
  )
  use query_double_list <- decode.optional_field(
    "queryDoubleList",
    option.None,
    decode.optional(decode.list(json_float.decoder())),
  )
  use query_enum_list <- decode.optional_field(
    "queryEnumList",
    option.None,
    decode.optional(decode.list(decode_foo_enum_enum())),
  )
  use query_integer_enum_list <- decode.optional_field(
    "queryIntegerEnumList",
    option.None,
    decode.optional(decode.list(decode_integer_enum_int_enum())),
  )
  use query_integer_list <- decode.optional_field(
    "queryIntegerList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  use query_string_list <- decode.optional_field(
    "queryStringList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use query_timestamp_list <- decode.optional_field(
    "queryTimestampList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  decode.success(OmitsSerializingEmptyListsInput(
    query_boolean_list: query_boolean_list,
    query_double_list: query_double_list,
    query_enum_list: query_enum_list,
    query_integer_enum_list: query_integer_enum_list,
    query_integer_list: query_integer_list,
    query_string_list: query_string_list,
    query_timestamp_list: query_timestamp_list,
  ))
}

pub type OperationWithDefaultsInput {
  OperationWithDefaultsInput(
    client_optional_defaults: option.Option(ClientOptionalDefaults),
    defaults: option.Option(Defaults),
    other_top_level_default: option.Option(Int),
    top_level_default: option.Option(String),
  )
}

pub fn encode_operation_with_defaults_input_struct(
  input: OperationWithDefaultsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.client_optional_defaults {
    option.Some(v) -> [
      #("clientOptionalDefaults", encode_client_optional_defaults_struct(v)),
      ..pairs
    ]
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

pub fn decode_operation_with_defaults_input_struct() -> decode.Decoder(
  OperationWithDefaultsInput,
) {
  use client_optional_defaults <- decode.optional_field(
    "clientOptionalDefaults",
    option.None,
    decode.optional(decode_client_optional_defaults_struct()),
  )
  use defaults <- decode.optional_field(
    "defaults",
    option.None,
    decode.optional(decode_defaults_struct()),
  )
  use other_top_level_default <- decode.optional_field(
    "otherTopLevelDefault",
    option.None,
    decode.optional(decode.int),
  )
  use top_level_default <- decode.optional_field(
    "topLevelDefault",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(OperationWithDefaultsInput(
    client_optional_defaults: client_optional_defaults,
    defaults: defaults,
    other_top_level_default: other_top_level_default,
    top_level_default: top_level_default,
  ))
}

pub type ClientOptionalDefaults {
  ClientOptionalDefaults(member: option.Option(Int))
}

pub fn encode_client_optional_defaults_struct(
  input: ClientOptionalDefaults,
) -> json.Json {
  let pairs = []
  let pairs = case input.member {
    option.Some(v) -> [#("member", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_client_optional_defaults_struct() -> decode.Decoder(
  ClientOptionalDefaults,
) {
  use member <- decode.optional_field(
    "member",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ClientOptionalDefaults(member: member))
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
    option.Some(v) -> [
      #(
        "defaultBlob",
        fn(b) { json.string(bit_array.base64_encode(b, True)) }(v),
      ),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("defaultIntEnum", encode_test_int_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.default_integer {
    option.Some(v) -> [#("defaultInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_list {
    option.Some(v) -> [
      #("defaultList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.default_long {
    option.Some(v) -> [#("defaultLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_map {
    option.Some(v) -> [
      #(
        "defaultMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("emptyBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
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
  use default_blob <- decode.optional_field(
    "defaultBlob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use default_boolean <- decode.optional_field(
    "defaultBoolean",
    option.None,
    decode.optional(decode.bool),
  )
  use default_byte <- decode.optional_field(
    "defaultByte",
    option.None,
    decode.optional(decode.int),
  )
  use default_document_boolean <- decode.optional_field(
    "defaultDocumentBoolean",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_document_list <- decode.optional_field(
    "defaultDocumentList",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_document_map <- decode.optional_field(
    "defaultDocumentMap",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_document_string <- decode.optional_field(
    "defaultDocumentString",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_double <- decode.optional_field(
    "defaultDouble",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use default_enum <- decode.optional_field(
    "defaultEnum",
    option.None,
    decode.optional(decode_test_enum_enum()),
  )
  use default_float <- decode.optional_field(
    "defaultFloat",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use default_int_enum <- decode.optional_field(
    "defaultIntEnum",
    option.None,
    decode.optional(decode_test_int_enum_int_enum()),
  )
  use default_integer <- decode.optional_field(
    "defaultInteger",
    option.None,
    decode.optional(decode.int),
  )
  use default_list <- decode.optional_field(
    "defaultList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use default_long <- decode.optional_field(
    "defaultLong",
    option.None,
    decode.optional(decode.int),
  )
  use default_map <- decode.optional_field(
    "defaultMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use default_null_document <- decode.optional_field(
    "defaultNullDocument",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_short <- decode.optional_field(
    "defaultShort",
    option.None,
    decode.optional(decode.int),
  )
  use default_string <- decode.optional_field(
    "defaultString",
    option.None,
    decode.optional(decode.string),
  )
  use default_timestamp <- decode.optional_field(
    "defaultTimestamp",
    option.None,
    decode.optional(decode.int),
  )
  use empty_blob <- decode.optional_field(
    "emptyBlob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use empty_string <- decode.optional_field(
    "emptyString",
    option.None,
    decode.optional(decode.string),
  )
  use false_boolean <- decode.optional_field(
    "falseBoolean",
    option.None,
    decode.optional(decode.bool),
  )
  use zero_byte <- decode.optional_field(
    "zeroByte",
    option.None,
    decode.optional(decode.int),
  )
  use zero_double <- decode.optional_field(
    "zeroDouble",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use zero_float <- decode.optional_field(
    "zeroFloat",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use zero_integer <- decode.optional_field(
    "zeroInteger",
    option.None,
    decode.optional(decode.int),
  )
  use zero_long <- decode.optional_field(
    "zeroLong",
    option.None,
    decode.optional(decode.int),
  )
  use zero_short <- decode.optional_field(
    "zeroShort",
    option.None,
    decode.optional(decode.int),
  )
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

pub fn encode_operation_with_defaults_output_struct(
  input: OperationWithDefaultsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.default_blob {
    option.Some(v) -> [
      #(
        "defaultBlob",
        fn(b) { json.string(bit_array.base64_encode(b, True)) }(v),
      ),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("defaultIntEnum", encode_test_int_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.default_integer {
    option.Some(v) -> [#("defaultInteger", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_list {
    option.Some(v) -> [
      #("defaultList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.default_long {
    option.Some(v) -> [#("defaultLong", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.default_map {
    option.Some(v) -> [
      #(
        "defaultMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
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
    option.Some(v) -> [
      #("emptyBlob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
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

pub fn decode_operation_with_defaults_output_struct() -> decode.Decoder(
  OperationWithDefaultsOutput,
) {
  use default_blob <- decode.optional_field(
    "defaultBlob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use default_boolean <- decode.optional_field(
    "defaultBoolean",
    option.None,
    decode.optional(decode.bool),
  )
  use default_byte <- decode.optional_field(
    "defaultByte",
    option.None,
    decode.optional(decode.int),
  )
  use default_document_boolean <- decode.optional_field(
    "defaultDocumentBoolean",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_document_list <- decode.optional_field(
    "defaultDocumentList",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_document_map <- decode.optional_field(
    "defaultDocumentMap",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_document_string <- decode.optional_field(
    "defaultDocumentString",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_double <- decode.optional_field(
    "defaultDouble",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use default_enum <- decode.optional_field(
    "defaultEnum",
    option.None,
    decode.optional(decode_test_enum_enum()),
  )
  use default_float <- decode.optional_field(
    "defaultFloat",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use default_int_enum <- decode.optional_field(
    "defaultIntEnum",
    option.None,
    decode.optional(decode_test_int_enum_int_enum()),
  )
  use default_integer <- decode.optional_field(
    "defaultInteger",
    option.None,
    decode.optional(decode.int),
  )
  use default_list <- decode.optional_field(
    "defaultList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use default_long <- decode.optional_field(
    "defaultLong",
    option.None,
    decode.optional(decode.int),
  )
  use default_map <- decode.optional_field(
    "defaultMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use default_null_document <- decode.optional_field(
    "defaultNullDocument",
    option.None,
    decode.optional(decode.dynamic |> decode.map(fn(_) { json.null() })),
  )
  use default_short <- decode.optional_field(
    "defaultShort",
    option.None,
    decode.optional(decode.int),
  )
  use default_string <- decode.optional_field(
    "defaultString",
    option.None,
    decode.optional(decode.string),
  )
  use default_timestamp <- decode.optional_field(
    "defaultTimestamp",
    option.None,
    decode.optional(decode.int),
  )
  use empty_blob <- decode.optional_field(
    "emptyBlob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use empty_string <- decode.optional_field(
    "emptyString",
    option.None,
    decode.optional(decode.string),
  )
  use false_boolean <- decode.optional_field(
    "falseBoolean",
    option.None,
    decode.optional(decode.bool),
  )
  use zero_byte <- decode.optional_field(
    "zeroByte",
    option.None,
    decode.optional(decode.int),
  )
  use zero_double <- decode.optional_field(
    "zeroDouble",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use zero_float <- decode.optional_field(
    "zeroFloat",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use zero_integer <- decode.optional_field(
    "zeroInteger",
    option.None,
    decode.optional(decode.int),
  )
  use zero_long <- decode.optional_field(
    "zeroLong",
    option.None,
    decode.optional(decode.int),
  )
  use zero_short <- decode.optional_field(
    "zeroShort",
    option.None,
    decode.optional(decode.int),
  )
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
  OperationWithNestedStructureInput(top_level: option.Option(TopLevel))
}

pub fn encode_operation_with_nested_structure_input_struct(
  input: OperationWithNestedStructureInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.top_level {
    option.Some(v) -> [#("topLevel", encode_top_level_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_nested_structure_input_struct() -> decode.Decoder(
  OperationWithNestedStructureInput,
) {
  use top_level <- decode.optional_field(
    "topLevel",
    option.None,
    decode.optional(decode_top_level_struct()),
  )
  decode.success(OperationWithNestedStructureInput(top_level: top_level))
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
    option.Some(v) -> [
      #("dialogList", fn(xs) { json.array(xs, encode_dialog_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dialog_map {
    option.Some(v) -> [
      #(
        "dialogMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_dialog_struct(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_top_level_struct() -> decode.Decoder(TopLevel) {
  use dialog <- decode.optional_field(
    "dialog",
    option.None,
    decode.optional(decode_dialog_struct()),
  )
  use dialog_list <- decode.optional_field(
    "dialogList",
    option.None,
    decode.optional(decode.list(decode_dialog_struct())),
  )
  use dialog_map <- decode.optional_field(
    "dialogMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode_dialog_struct())),
  )
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
    option.None -> pairs
  }
  let pairs = case input.language {
    option.Some(v) -> [#("language", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_dialog_struct() -> decode.Decoder(Dialog) {
  use farewell <- decode.optional_field(
    "farewell",
    option.None,
    decode.optional(decode_farewell_struct()),
  )
  use greeting <- decode.optional_field(
    "greeting",
    option.None,
    decode.optional(decode.string),
  )
  use language <- decode.optional_field(
    "language",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Dialog(
    farewell: farewell,
    greeting: greeting,
    language: language,
  ))
}

pub type Farewell {
  Farewell(phrase: option.Option(String))
}

pub fn encode_farewell_struct(input: Farewell) -> json.Json {
  let pairs = []
  let pairs = case input.phrase {
    option.Some(v) -> [#("phrase", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_farewell_struct() -> decode.Decoder(Farewell) {
  use phrase <- decode.optional_field(
    "phrase",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Farewell(phrase: phrase))
}

pub type OperationWithNestedStructureOutput {
  OperationWithNestedStructureOutput(
    dialog: option.Option(Dialog),
    dialog_list: option.Option(List(Dialog)),
    dialog_map: option.Option(dict.Dict(String, Dialog)),
  )
}

pub fn encode_operation_with_nested_structure_output_struct(
  input: OperationWithNestedStructureOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.dialog {
    option.Some(v) -> [#("dialog", encode_dialog_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.dialog_list {
    option.Some(v) -> [
      #("dialogList", fn(xs) { json.array(xs, encode_dialog_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dialog_map {
    option.Some(v) -> [
      #(
        "dialogMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_dialog_struct(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_operation_with_nested_structure_output_struct() -> decode.Decoder(
  OperationWithNestedStructureOutput,
) {
  use dialog <- decode.optional_field(
    "dialog",
    option.None,
    decode.optional(decode_dialog_struct()),
  )
  use dialog_list <- decode.optional_field(
    "dialogList",
    option.None,
    decode.optional(decode.list(decode_dialog_struct())),
  )
  use dialog_map <- decode.optional_field(
    "dialogMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode_dialog_struct())),
  )
  decode.success(OperationWithNestedStructureOutput(
    dialog: dialog,
    dialog_list: dialog_list,
    dialog_map: dialog_map,
  ))
}

pub type OutputStreamOutput {
  OutputStreamOutput(stream: option.Option(EventStream))
}

pub fn encode_output_stream_output_struct(
  input: OutputStreamOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_output_stream_output_struct() -> decode.Decoder(
  OutputStreamOutput,
) {
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(OutputStreamOutput(stream: stream))
}

pub type OutputStreamWithInitialResponseOutput {
  OutputStreamWithInitialResponseOutput(
    initial_response_member: option.Option(String),
    stream: option.Option(EventStream),
  )
}

pub fn encode_output_stream_with_initial_response_output_struct(
  input: OutputStreamWithInitialResponseOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.initial_response_member {
    option.Some(v) -> [#("initialResponseMember", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.stream {
    option.Some(v) -> [#("stream", encode_event_stream_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_output_stream_with_initial_response_output_struct() -> decode.Decoder(
  OutputStreamWithInitialResponseOutput,
) {
  use initial_response_member <- decode.optional_field(
    "initialResponseMember",
    option.None,
    decode.optional(decode.string),
  )
  use stream <- decode.optional_field(
    "stream",
    option.None,
    decode.optional(decode_event_stream_union()),
  )
  decode.success(OutputStreamWithInitialResponseOutput(
    initial_response_member: initial_response_member,
    stream: stream,
  ))
}

pub type PostPlayerActionInput {
  PostPlayerActionInput(action: option.Option(PlayerAction))
}

pub fn encode_post_player_action_input_struct(
  input: PostPlayerActionInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.action {
    option.Some(v) -> [#("action", encode_player_action_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_post_player_action_input_struct() -> decode.Decoder(
  PostPlayerActionInput,
) {
  use action <- decode.optional_field(
    "action",
    option.None,
    decode.optional(decode_player_action_union()),
  )
  decode.success(PostPlayerActionInput(action: action))
}

pub type PlayerAction {
  PlayerActionQuit(Nil)
}

pub fn encode_player_action_union(v: PlayerAction) -> json.Json {
  case v {
    PlayerActionQuit(x) ->
      json.object([#("quit", fn(_) { json.object([]) }(x))])
  }
}

pub fn decode_player_action_union() -> decode.Decoder(PlayerAction) {
  decode.one_of(
    decode.field("quit", decode.success(Nil), fn(x) {
      decode.success(PlayerActionQuit(x))
    }),
    [],
  )
}

pub type PostPlayerActionOutput {
  PostPlayerActionOutput(action: option.Option(PlayerAction))
}

pub fn encode_post_player_action_output_struct(
  input: PostPlayerActionOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.action {
    option.Some(v) -> [#("action", encode_player_action_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_post_player_action_output_struct() -> decode.Decoder(
  PostPlayerActionOutput,
) {
  use action <- decode.optional_field(
    "action",
    option.None,
    decode.optional(decode_player_action_union()),
  )
  decode.success(PostPlayerActionOutput(action: action))
}

pub type PostUnionWithJsonNameInput {
  PostUnionWithJsonNameInput(value: option.Option(UnionWithJsonName))
}

pub fn encode_post_union_with_json_name_input_struct(
  input: PostUnionWithJsonNameInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [
      #("value", encode_union_with_json_name_union(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_post_union_with_json_name_input_struct() -> decode.Decoder(
  PostUnionWithJsonNameInput,
) {
  use value <- decode.optional_field(
    "value",
    option.None,
    decode.optional(decode_union_with_json_name_union()),
  )
  decode.success(PostUnionWithJsonNameInput(value: value))
}

pub type UnionWithJsonName {
  UnionWithJsonNameBar(String)
  UnionWithJsonNameBaz(String)
  UnionWithJsonNameFoo(String)
}

pub fn encode_union_with_json_name_union(v: UnionWithJsonName) -> json.Json {
  case v {
    UnionWithJsonNameBar(x) -> json.object([#("bar", json.string(x))])
    UnionWithJsonNameBaz(x) -> json.object([#("baz", json.string(x))])
    UnionWithJsonNameFoo(x) -> json.object([#("foo", json.string(x))])
  }
}

pub fn decode_union_with_json_name_union() -> decode.Decoder(UnionWithJsonName) {
  decode.one_of(
    decode.field("bar", decode.string, fn(x) {
      decode.success(UnionWithJsonNameBar(x))
    }),
    [
      decode.field("baz", decode.string, fn(x) {
        decode.success(UnionWithJsonNameBaz(x))
      }),
      decode.field("foo", decode.string, fn(x) {
        decode.success(UnionWithJsonNameFoo(x))
      }),
    ],
  )
}

pub type PostUnionWithJsonNameOutput {
  PostUnionWithJsonNameOutput(value: option.Option(UnionWithJsonName))
}

pub fn encode_post_union_with_json_name_output_struct(
  input: PostUnionWithJsonNameOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [
      #("value", encode_union_with_json_name_union(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_post_union_with_json_name_output_struct() -> decode.Decoder(
  PostUnionWithJsonNameOutput,
) {
  use value <- decode.optional_field(
    "value",
    option.None,
    decode.optional(decode_union_with_json_name_union()),
  )
  decode.success(PostUnionWithJsonNameOutput(value: value))
}

pub type PutWithContentEncodingInput {
  PutWithContentEncodingInput(
    data: option.Option(String),
    encoding: option.Option(String),
  )
}

pub fn encode_put_with_content_encoding_input_struct(
  input: PutWithContentEncodingInput,
) -> json.Json {
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

pub fn decode_put_with_content_encoding_input_struct() -> decode.Decoder(
  PutWithContentEncodingInput,
) {
  use data <- decode.optional_field(
    "data",
    option.None,
    decode.optional(decode.string),
  )
  use encoding <- decode.optional_field(
    "encoding",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(PutWithContentEncodingInput(data: data, encoding: encoding))
}

pub type QueryIdempotencyTokenAutoFillInput {
  QueryIdempotencyTokenAutoFillInput(token: option.Option(String))
}

pub fn encode_query_idempotency_token_auto_fill_input_struct(
  input: QueryIdempotencyTokenAutoFillInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.token {
    option.Some(v) -> [#("token", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_idempotency_token_auto_fill_input_struct() -> decode.Decoder(
  QueryIdempotencyTokenAutoFillInput,
) {
  use token <- decode.optional_field(
    "token",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(QueryIdempotencyTokenAutoFillInput(token: token))
}

pub type QueryParamsAsStringListMapInput {
  QueryParamsAsStringListMapInput(
    foo: option.Option(dict.Dict(String, List(String))),
    qux: option.Option(String),
  )
}

pub fn encode_query_params_as_string_list_map_input_struct(
  input: QueryParamsAsStringListMapInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [
      #(
        "foo",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.qux {
    option.Some(v) -> [#("qux", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_params_as_string_list_map_input_struct() -> decode.Decoder(
  QueryParamsAsStringListMapInput,
) {
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.dict(decode.string, decode.list(decode.string))),
  )
  use qux <- decode.optional_field(
    "qux",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(QueryParamsAsStringListMapInput(foo: foo, qux: qux))
}

pub type QueryPrecedenceInput {
  QueryPrecedenceInput(
    baz: option.Option(dict.Dict(String, String)),
    foo: option.Option(String),
  )
}

pub fn encode_query_precedence_input_struct(
  input: QueryPrecedenceInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.baz {
    option.Some(v) -> [
      #(
        "baz",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_precedence_input_struct() -> decode.Decoder(
  QueryPrecedenceInput,
) {
  use baz <- decode.optional_field(
    "baz",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(QueryPrecedenceInput(baz: baz, foo: foo))
}

pub type RecursiveShapesInputOutput {
  RecursiveShapesInputOutput(
    nested: option.Option(RecursiveShapesInputOutputNested1),
  )
}

pub fn encode_recursive_shapes_input_output_struct(
  input: RecursiveShapesInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [
      #("nested", encode_recursive_shapes_input_output_nested1_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_recursive_shapes_input_output_struct() -> decode.Decoder(
  RecursiveShapesInputOutput,
) {
  use nested <- decode.optional_field(
    "nested",
    option.None,
    decode.optional(decode_recursive_shapes_input_output_nested1_struct()),
  )
  decode.success(RecursiveShapesInputOutput(nested: nested))
}

pub type RecursiveShapesInputOutputNested1 {
  RecursiveShapesInputOutputNested1(
    foo: option.Option(String),
    nested: option.Option(RecursiveShapesInputOutputNested2),
  )
}

pub fn encode_recursive_shapes_input_output_nested1_struct(
  input: RecursiveShapesInputOutputNested1,
) -> json.Json {
  let pairs = []
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.nested {
    option.Some(v) -> [
      #("nested", encode_recursive_shapes_input_output_nested2_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_recursive_shapes_input_output_nested1_struct() -> decode.Decoder(
  RecursiveShapesInputOutputNested1,
) {
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  use nested <- decode.optional_field(
    "nested",
    option.None,
    decode.optional(decode_recursive_shapes_input_output_nested2_struct()),
  )
  decode.success(RecursiveShapesInputOutputNested1(foo: foo, nested: nested))
}

pub type RecursiveShapesInputOutputNested2 {
  RecursiveShapesInputOutputNested2(
    bar: option.Option(String),
    recursive_member: option.Option(RecursiveShapesInputOutputNested1),
  )
}

pub fn encode_recursive_shapes_input_output_nested2_struct(
  input: RecursiveShapesInputOutputNested2,
) -> json.Json {
  let pairs = []
  let pairs = case input.bar {
    option.Some(v) -> [#("bar", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.recursive_member {
    option.Some(v) -> [
      #(
        "recursiveMember",
        encode_recursive_shapes_input_output_nested1_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_recursive_shapes_input_output_nested2_struct() -> decode.Decoder(
  RecursiveShapesInputOutputNested2,
) {
  use bar <- decode.optional_field(
    "bar",
    option.None,
    decode.optional(decode.string),
  )
  use recursive_member <- decode.optional_field(
    "recursiveMember",
    option.None,
    decode.optional(decode_recursive_shapes_input_output_nested1_struct()),
  )
  decode.success(RecursiveShapesInputOutputNested2(
    bar: bar,
    recursive_member: recursive_member,
  ))
}

pub type ResponseCodeHttpFallbackInputOutput {
  ResponseCodeHttpFallbackInputOutput
}

pub fn encode_response_code_http_fallback_input_output_struct(
  _v: ResponseCodeHttpFallbackInputOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_response_code_http_fallback_input_output_struct() -> decode.Decoder(
  ResponseCodeHttpFallbackInputOutput,
) {
  decode.success(ResponseCodeHttpFallbackInputOutput)
}

pub type ResponseCodeRequiredOutput {
  ResponseCodeRequiredOutput(response_code: option.Option(Int))
}

pub fn encode_response_code_required_output_struct(
  input: ResponseCodeRequiredOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.response_code {
    option.Some(v) -> [#("responseCode", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_response_code_required_output_struct() -> decode.Decoder(
  ResponseCodeRequiredOutput,
) {
  use response_code <- decode.optional_field(
    "responseCode",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ResponseCodeRequiredOutput(response_code: response_code))
}

pub type SimpleScalarPropertiesInputOutput {
  SimpleScalarPropertiesInputOutput(
    byte_value: option.Option(Int),
    double_value: option.Option(json_float.SmithyFloat),
    false_boolean_value: option.Option(Bool),
    float_value: option.Option(json_float.SmithyFloat),
    foo: option.Option(String),
    integer_value: option.Option(Int),
    long_value: option.Option(Int),
    short_value: option.Option(Int),
    string_value: option.Option(String),
    true_boolean_value: option.Option(Bool),
  )
}

pub fn encode_simple_scalar_properties_input_output_struct(
  input: SimpleScalarPropertiesInputOutput,
) -> json.Json {
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

pub fn decode_simple_scalar_properties_input_output_struct() -> decode.Decoder(
  SimpleScalarPropertiesInputOutput,
) {
  use byte_value <- decode.optional_field(
    "byteValue",
    option.None,
    decode.optional(decode.int),
  )
  use double_value <- decode.optional_field(
    "doubleValue",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use false_boolean_value <- decode.optional_field(
    "falseBooleanValue",
    option.None,
    decode.optional(decode.bool),
  )
  use float_value <- decode.optional_field(
    "floatValue",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  use integer_value <- decode.optional_field(
    "integerValue",
    option.None,
    decode.optional(decode.int),
  )
  use long_value <- decode.optional_field(
    "longValue",
    option.None,
    decode.optional(decode.int),
  )
  use short_value <- decode.optional_field(
    "shortValue",
    option.None,
    decode.optional(decode.int),
  )
  use string_value <- decode.optional_field(
    "stringValue",
    option.None,
    decode.optional(decode.string),
  )
  use true_boolean_value <- decode.optional_field(
    "trueBooleanValue",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(SimpleScalarPropertiesInputOutput(
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

pub type SparseJsonListsInputOutput {
  SparseJsonListsInputOutput(
    sparse_short_list: option.Option(List(Int)),
    sparse_string_list: option.Option(List(String)),
  )
}

pub fn encode_sparse_json_lists_input_output_struct(
  input: SparseJsonListsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.sparse_short_list {
    option.Some(v) -> [
      #("sparseShortList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_string_list {
    option.Some(v) -> [
      #("sparseStringList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_sparse_json_lists_input_output_struct() -> decode.Decoder(
  SparseJsonListsInputOutput,
) {
  use sparse_short_list <- decode.optional_field(
    "sparseShortList",
    option.None,
    decode.optional(decode.list(decode.int)),
  )
  use sparse_string_list <- decode.optional_field(
    "sparseStringList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  decode.success(SparseJsonListsInputOutput(
    sparse_short_list: sparse_short_list,
    sparse_string_list: sparse_string_list,
  ))
}

pub type SparseJsonMapsInputOutput {
  SparseJsonMapsInputOutput(
    sparse_boolean_map: option.Option(dict.Dict(String, Bool)),
    sparse_number_map: option.Option(dict.Dict(String, Int)),
    sparse_set_map: option.Option(dict.Dict(String, List(String))),
    sparse_string_map: option.Option(dict.Dict(String, String)),
    sparse_struct_map: option.Option(dict.Dict(String, GreetingStruct)),
  )
}

pub fn encode_sparse_json_maps_input_output_struct(
  input: SparseJsonMapsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.sparse_boolean_map {
    option.Some(v) -> [
      #(
        "sparseBooleanMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.bool(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_number_map {
    option.Some(v) -> [
      #(
        "sparseNumberMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.int(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_set_map {
    option.Some(v) -> [
      #(
        "sparseSetMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_string_map {
    option.Some(v) -> [
      #(
        "sparseStringMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_struct_map {
    option.Some(v) -> [
      #(
        "sparseStructMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_greeting_struct_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_sparse_json_maps_input_output_struct() -> decode.Decoder(
  SparseJsonMapsInputOutput,
) {
  use sparse_boolean_map <- decode.optional_field(
    "sparseBooleanMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.bool)),
  )
  use sparse_number_map <- decode.optional_field(
    "sparseNumberMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.int)),
  )
  use sparse_set_map <- decode.optional_field(
    "sparseSetMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.list(decode.string))),
  )
  use sparse_string_map <- decode.optional_field(
    "sparseStringMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use sparse_struct_map <- decode.optional_field(
    "sparseStructMap",
    option.None,
    decode.optional(decode.dict(decode.string, decode_greeting_struct_struct())),
  )
  decode.success(SparseJsonMapsInputOutput(
    sparse_boolean_map: sparse_boolean_map,
    sparse_number_map: sparse_number_map,
    sparse_set_map: sparse_set_map,
    sparse_string_map: sparse_string_map,
    sparse_struct_map: sparse_struct_map,
  ))
}

pub type StreamingTraitsInputOutput {
  StreamingTraitsInputOutput(
    blob: option.Option(BitArray),
    foo: option.Option(String),
  )
}

pub fn encode_streaming_traits_input_output_struct(
  input: StreamingTraitsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [
      #("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_streaming_traits_input_output_struct() -> decode.Decoder(
  StreamingTraitsInputOutput,
) {
  use blob <- decode.optional_field(
    "blob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(StreamingTraitsInputOutput(blob: blob, foo: foo))
}

pub type StreamingTraitsRequireLengthInput {
  StreamingTraitsRequireLengthInput(
    blob: option.Option(BitArray),
    foo: option.Option(String),
  )
}

pub fn encode_streaming_traits_require_length_input_struct(
  input: StreamingTraitsRequireLengthInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [
      #("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_streaming_traits_require_length_input_struct() -> decode.Decoder(
  StreamingTraitsRequireLengthInput,
) {
  use blob <- decode.optional_field(
    "blob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(StreamingTraitsRequireLengthInput(blob: blob, foo: foo))
}

pub type StreamingTraitsWithMediaTypeInputOutput {
  StreamingTraitsWithMediaTypeInputOutput(
    blob: option.Option(BitArray),
    foo: option.Option(String),
  )
}

pub fn encode_streaming_traits_with_media_type_input_output_struct(
  input: StreamingTraitsWithMediaTypeInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [
      #("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo {
    option.Some(v) -> [#("foo", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_streaming_traits_with_media_type_input_output_struct() -> decode.Decoder(
  StreamingTraitsWithMediaTypeInputOutput,
) {
  use blob <- decode.optional_field(
    "blob",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use foo <- decode.optional_field(
    "foo",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(StreamingTraitsWithMediaTypeInputOutput(blob: blob, foo: foo))
}

pub type TestBodyStructureInputOutput {
  TestBodyStructureInputOutput(
    test_config: option.Option(TestConfig),
    test_id: option.Option(String),
  )
}

pub fn encode_test_body_structure_input_output_struct(
  input: TestBodyStructureInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.test_config {
    option.Some(v) -> [#("testConfig", encode_test_config_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.test_id {
    option.Some(v) -> [#("testId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_test_body_structure_input_output_struct() -> decode.Decoder(
  TestBodyStructureInputOutput,
) {
  use test_config <- decode.optional_field(
    "testConfig",
    option.None,
    decode.optional(decode_test_config_struct()),
  )
  use test_id <- decode.optional_field(
    "testId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(TestBodyStructureInputOutput(
    test_config: test_config,
    test_id: test_id,
  ))
}

pub type TestConfig {
  TestConfig(timeout: option.Option(Int))
}

pub fn encode_test_config_struct(input: TestConfig) -> json.Json {
  let pairs = []
  let pairs = case input.timeout {
    option.Some(v) -> [#("timeout", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_test_config_struct() -> decode.Decoder(TestConfig) {
  use timeout <- decode.optional_field(
    "timeout",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(TestConfig(timeout: timeout))
}

pub type TestNoPayloadInputOutput {
  TestNoPayloadInputOutput(test_id: option.Option(String))
}

pub fn encode_test_no_payload_input_output_struct(
  input: TestNoPayloadInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.test_id {
    option.Some(v) -> [#("testId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_test_no_payload_input_output_struct() -> decode.Decoder(
  TestNoPayloadInputOutput,
) {
  use test_id <- decode.optional_field(
    "testId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(TestNoPayloadInputOutput(test_id: test_id))
}

pub type TestPayloadBlobInputOutput {
  TestPayloadBlobInputOutput(
    content_type: option.Option(String),
    data: option.Option(BitArray),
  )
}

pub fn encode_test_payload_blob_input_output_struct(
  input: TestPayloadBlobInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.content_type {
    option.Some(v) -> [#("contentType", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.data {
    option.Some(v) -> [
      #("data", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_test_payload_blob_input_output_struct() -> decode.Decoder(
  TestPayloadBlobInputOutput,
) {
  use content_type <- decode.optional_field(
    "contentType",
    option.None,
    decode.optional(decode.string),
  )
  use data <- decode.optional_field(
    "data",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  decode.success(TestPayloadBlobInputOutput(
    content_type: content_type,
    data: data,
  ))
}

pub type TestPayloadStructureInputOutput {
  TestPayloadStructureInputOutput(
    payload_config: option.Option(PayloadConfig),
    test_id: option.Option(String),
  )
}

pub fn encode_test_payload_structure_input_output_struct(
  input: TestPayloadStructureInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload_config {
    option.Some(v) -> [
      #("payloadConfig", encode_payload_config_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.test_id {
    option.Some(v) -> [#("testId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_test_payload_structure_input_output_struct() -> decode.Decoder(
  TestPayloadStructureInputOutput,
) {
  use payload_config <- decode.optional_field(
    "payloadConfig",
    option.None,
    decode.optional(decode_payload_config_struct()),
  )
  use test_id <- decode.optional_field(
    "testId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(TestPayloadStructureInputOutput(
    payload_config: payload_config,
    test_id: test_id,
  ))
}

pub type PayloadConfig {
  PayloadConfig(data: option.Option(Int))
}

pub fn encode_payload_config_struct(input: PayloadConfig) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [#("data", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_payload_config_struct() -> decode.Decoder(PayloadConfig) {
  use data <- decode.optional_field(
    "data",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(PayloadConfig(data: data))
}

pub type TimestampFormatHeadersIO {
  TimestampFormatHeadersIO(
    default_format: option.Option(Int),
    member_date_time: option.Option(Int),
    member_epoch_seconds: option.Option(Int),
    member_http_date: option.Option(Int),
    target_date_time: option.Option(Int),
    target_epoch_seconds: option.Option(Int),
    target_http_date: option.Option(Int),
  )
}

pub fn encode_timestamp_format_headers_io_struct(
  input: TimestampFormatHeadersIO,
) -> json.Json {
  let pairs = []
  let pairs = case input.default_format {
    option.Some(v) -> [#("defaultFormat", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_date_time {
    option.Some(v) -> [#("memberDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_epoch_seconds {
    option.Some(v) -> [#("memberEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.member_http_date {
    option.Some(v) -> [#("memberHttpDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_date_time {
    option.Some(v) -> [#("targetDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_epoch_seconds {
    option.Some(v) -> [#("targetEpochSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_http_date {
    option.Some(v) -> [#("targetHttpDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_timestamp_format_headers_io_struct() -> decode.Decoder(
  TimestampFormatHeadersIO,
) {
  use default_format <- decode.optional_field(
    "defaultFormat",
    option.None,
    decode.optional(decode.int),
  )
  use member_date_time <- decode.optional_field(
    "memberDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use member_epoch_seconds <- decode.optional_field(
    "memberEpochSeconds",
    option.None,
    decode.optional(decode.int),
  )
  use member_http_date <- decode.optional_field(
    "memberHttpDate",
    option.None,
    decode.optional(decode.int),
  )
  use target_date_time <- decode.optional_field(
    "targetDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use target_epoch_seconds <- decode.optional_field(
    "targetEpochSeconds",
    option.None,
    decode.optional(decode.int),
  )
  use target_http_date <- decode.optional_field(
    "targetHttpDate",
    option.None,
    decode.optional(decode.int),
  )
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

pub type AllQueryStringTypesOutput {
  AllQueryStringTypesOutput
}

pub fn encode_all_query_string_types_output_struct(
  _v: AllQueryStringTypesOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_all_query_string_types_output_struct() -> decode.Decoder(
  AllQueryStringTypesOutput,
) {
  decode.success(AllQueryStringTypesOutput)
}

pub fn encode_all_query_string_types_input(
  input: AllQueryStringTypesInput,
) -> String {
  json.to_string(encode_all_query_string_types_input_struct(input))
}

pub fn decode_all_query_string_types_input(
  body: String,
) -> Result(AllQueryStringTypesInput, String) {
  case json.parse(body, decode_all_query_string_types_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_all_query_string_types_output(
  body: String,
) -> Result(AllQueryStringTypesOutput, String) {
  case json.parse(body, decode_all_query_string_types_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_all_query_string_types_body(
  _input: AllQueryStringTypesInput,
) -> json.Json {
  json.object([])
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
    option.Some(v) -> rest.add_query(query, "BooleanList", "")
    option.None -> query
  }
  let query = case input.query_byte {
    option.Some(v) -> rest.add_query(query, "Byte", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.query_double {
    option.Some(v) ->
      rest.add_query(query, "Double", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> query
  }
  let query = case input.query_double_list {
    option.Some(v) -> rest.add_query(query, "DoubleList", "")
    option.None -> query
  }
  let query = case input.query_enum {
    option.Some(v) ->
      rest.add_query(
        query,
        "Enum",
        rest.enum_wire_value(encode_foo_enum_enum(v)),
      )
    option.None -> query
  }
  let query = case input.query_enum_list {
    option.Some(v) -> rest.add_query(query, "EnumList", "")
    option.None -> query
  }
  let query = case input.query_float {
    option.Some(v) ->
      rest.add_query(query, "Float", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> query
  }
  let query = case input.query_integer {
    option.Some(v) -> rest.add_query(query, "Integer", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.query_integer_enum {
    option.Some(v) ->
      rest.add_query(
        query,
        "IntegerEnum",
        rest.int_to_query(case encode_integer_enum_int_enum(v) {
          _ -> 0
        }),
      )
    option.None -> query
  }
  let query = case input.query_integer_enum_list {
    option.Some(v) -> rest.add_query(query, "IntegerEnumList", "")
    option.None -> query
  }
  let query = case input.query_integer_list {
    option.Some(v) -> rest.add_query(query, "IntegerList", "")
    option.None -> query
  }
  let query = case input.query_integer_set {
    option.Some(v) -> rest.add_query(query, "IntegerSet", "")
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
    option.Some(v) -> rest.add_query(query, "StringList", "")
    option.None -> query
  }
  let query = case input.query_string_set {
    option.Some(v) -> rest.add_query(query, "StringSet", "")
    option.None -> query
  }
  let query = case input.query_timestamp {
    option.Some(v) ->
      rest.add_query(query, "Timestamp", rest.timestamp_to_header(v))
    option.None -> query
  }
  let query = case input.query_timestamp_list {
    option.Some(v) -> rest.add_query(query, "TimestampList", "")
    option.None -> query
  }
  let query = case input.query_params_map_of_string_list {
    option.Some(m) -> rest.add_query_params_list(query, m)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_all_query_string_types_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(AllQueryStringTypesOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_all_query_string_types_output("{}")
        _ -> decode_all_query_string_types_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type ConstantAndVariableQueryStringOutput {
  ConstantAndVariableQueryStringOutput
}

pub fn encode_constant_and_variable_query_string_output_struct(
  _v: ConstantAndVariableQueryStringOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_constant_and_variable_query_string_output_struct() -> decode.Decoder(
  ConstantAndVariableQueryStringOutput,
) {
  decode.success(ConstantAndVariableQueryStringOutput)
}

pub fn encode_constant_and_variable_query_string_input(
  input: ConstantAndVariableQueryStringInput,
) -> String {
  json.to_string(encode_constant_and_variable_query_string_input_struct(input))
}

pub fn decode_constant_and_variable_query_string_input(
  body: String,
) -> Result(ConstantAndVariableQueryStringInput, String) {
  case
    json.parse(body, decode_constant_and_variable_query_string_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_constant_and_variable_query_string_output(
  body: String,
) -> Result(ConstantAndVariableQueryStringOutput, String) {
  case
    json.parse(body, decode_constant_and_variable_query_string_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_constant_and_variable_query_string_body(
  _input: ConstantAndVariableQueryStringInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_constant_and_variable_query_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ConstantAndVariableQueryStringOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_constant_and_variable_query_string_output("{}")
        _ -> decode_constant_and_variable_query_string_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type ConstantQueryStringOutput {
  ConstantQueryStringOutput
}

pub fn encode_constant_query_string_output_struct(
  _v: ConstantQueryStringOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_constant_query_string_output_struct() -> decode.Decoder(
  ConstantQueryStringOutput,
) {
  decode.success(ConstantQueryStringOutput)
}

pub fn encode_constant_query_string_input(
  input: ConstantQueryStringInput,
) -> String {
  json.to_string(encode_constant_query_string_input_struct(input))
}

pub fn decode_constant_query_string_input(
  body: String,
) -> Result(ConstantQueryStringInput, String) {
  case json.parse(body, decode_constant_query_string_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_constant_query_string_output(
  body: String,
) -> Result(ConstantQueryStringOutput, String) {
  case json.parse(body, decode_constant_query_string_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_constant_query_string_body(
  _input: ConstantQueryStringInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_constant_query_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ConstantQueryStringOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_constant_query_string_output("{}")
        _ -> decode_constant_query_string_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_content_type_parameters_input(
  input: ContentTypeParametersInput,
) -> String {
  json.to_string(encode_content_type_parameters_input_struct(input))
}

pub fn decode_content_type_parameters_input(
  body: String,
) -> Result(ContentTypeParametersInput, String) {
  case json.parse(body, decode_content_type_parameters_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_content_type_parameters_output(
  body: String,
) -> Result(ContentTypeParametersOutput, String) {
  case json.parse(body, decode_content_type_parameters_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_content_type_parameters_body(
  input: ContentTypeParametersInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [#("value", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_content_type_parameters_request(
  input: ContentTypeParametersInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/ContentTypeParameters"
  let query = ""
  let headers = dict.new()
  let body_json = encode_content_type_parameters_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_content_type_parameters_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ContentTypeParametersOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_content_type_parameters_output("{}")
        _ -> decode_content_type_parameters_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DatetimeOffsetsInput {
  DatetimeOffsetsInput
}

pub fn encode_datetime_offsets_input_struct(
  _v: DatetimeOffsetsInput,
) -> json.Json {
  json.object([])
}

pub fn decode_datetime_offsets_input_struct() -> decode.Decoder(
  DatetimeOffsetsInput,
) {
  decode.success(DatetimeOffsetsInput)
}

pub fn encode_datetime_offsets_input(input: DatetimeOffsetsInput) -> String {
  json.to_string(encode_datetime_offsets_input_struct(input))
}

pub fn decode_datetime_offsets_input(
  body: String,
) -> Result(DatetimeOffsetsInput, String) {
  case json.parse(body, decode_datetime_offsets_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_datetime_offsets_output(
  body: String,
) -> Result(DatetimeOffsetsOutput, String) {
  case json.parse(body, decode_datetime_offsets_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_datetime_offsets_body(_input: DatetimeOffsetsInput) -> json.Json {
  json.object([])
}

pub fn build_datetime_offsets_request(
  _input: DatetimeOffsetsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DatetimeOffsets"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_datetime_offsets_output("{}")
        _ -> decode_datetime_offsets_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_document_type_input(input: DocumentTypeInputOutput) -> String {
  json.to_string(encode_document_type_input_output_struct(input))
}

pub fn decode_document_type_input(
  body: String,
) -> Result(DocumentTypeInputOutput, String) {
  case json.parse(body, decode_document_type_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_document_type_output(
  body: String,
) -> Result(DocumentTypeInputOutput, String) {
  case json.parse(body, decode_document_type_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_document_type_body(input: DocumentTypeInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.document_value {
    option.Some(v) -> [#("documentValue", fn(j) { j }(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.string_value {
    option.Some(v) -> [#("stringValue", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_document_type_request(
  input: DocumentTypeInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DocumentType"
  let query = ""
  let headers = dict.new()
  let body_json = encode_document_type_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_document_type_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DocumentTypeInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_document_type_output("{}")
        _ -> decode_document_type_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_document_type_as_map_value_input(
  input: DocumentTypeAsMapValueInputOutput,
) -> String {
  json.to_string(encode_document_type_as_map_value_input_output_struct(input))
}

pub fn decode_document_type_as_map_value_input(
  body: String,
) -> Result(DocumentTypeAsMapValueInputOutput, String) {
  case
    json.parse(body, decode_document_type_as_map_value_input_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_document_type_as_map_value_output(
  body: String,
) -> Result(DocumentTypeAsMapValueInputOutput, String) {
  case
    json.parse(body, decode_document_type_as_map_value_input_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_document_type_as_map_value_body(
  input: DocumentTypeAsMapValueInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.doc_valued_map {
    option.Some(v) -> [
      #(
        "docValuedMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, fn(j) { j }(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_document_type_as_map_value_request(
  input: DocumentTypeAsMapValueInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DocumentTypeAsMapValue"
  let query = ""
  let headers = dict.new()
  let body_json = encode_document_type_as_map_value_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_document_type_as_map_value_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DocumentTypeAsMapValueInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_document_type_as_map_value_output("{}")
        _ -> decode_document_type_as_map_value_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_document_type_as_payload_input(
  input: DocumentTypeAsPayloadInputOutput,
) -> String {
  json.to_string(encode_document_type_as_payload_input_output_struct(input))
}

pub fn decode_document_type_as_payload_input(
  body: String,
) -> Result(DocumentTypeAsPayloadInputOutput, String) {
  case json.parse(body, decode_document_type_as_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_document_type_as_payload_output(
  body: String,
) -> Result(DocumentTypeAsPayloadInputOutput, String) {
  case json.parse(body, decode_document_type_as_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_document_type_as_payload_body(
  _input: DocumentTypeAsPayloadInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_document_type_as_payload_request(
  input: DocumentTypeAsPayloadInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DocumentTypeAsPayload"
  let query = ""
  let headers = dict.new()
  let body = case input.document_value {
    option.Some(v) -> bit_array.from_string(json.to_string(fn(j) { j }(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_document_type_as_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DocumentTypeAsPayloadInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_document_type_as_payload_output("{}")
        _ -> decode_document_type_as_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_duplex_stream_input(input: DuplexStreamInput) -> String {
  json.to_string(encode_duplex_stream_input_struct(input))
}

pub fn decode_duplex_stream_input(
  body: String,
) -> Result(DuplexStreamInput, String) {
  case json.parse(body, decode_duplex_stream_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_duplex_stream_output(
  body: String,
) -> Result(DuplexStreamOutput, String) {
  case json.parse(body, decode_duplex_stream_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_duplex_stream_body(_input: DuplexStreamInput) -> json.Json {
  json.object([])
}

pub fn build_duplex_stream_request(
  input: DuplexStreamInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DuplexStream"
  let query = ""
  let headers = dict.new()
  let body = case input.stream {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_event_stream_union(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_duplex_stream_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DuplexStreamOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_duplex_stream_output("{}")
        _ -> decode_duplex_stream_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_duplex_stream_with_distinct_streams_input(
  input: DuplexStreamWithDistinctStreamsInput,
) -> String {
  json.to_string(encode_duplex_stream_with_distinct_streams_input_struct(input))
}

pub fn decode_duplex_stream_with_distinct_streams_input(
  body: String,
) -> Result(DuplexStreamWithDistinctStreamsInput, String) {
  case
    json.parse(body, decode_duplex_stream_with_distinct_streams_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_duplex_stream_with_distinct_streams_output(
  body: String,
) -> Result(DuplexStreamWithDistinctStreamsOutput, String) {
  case
    json.parse(body, decode_duplex_stream_with_distinct_streams_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_duplex_stream_with_distinct_streams_body(
  _input: DuplexStreamWithDistinctStreamsInput,
) -> json.Json {
  json.object([])
}

pub fn build_duplex_stream_with_distinct_streams_request(
  input: DuplexStreamWithDistinctStreamsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DuplexStreamWithDistinctStreams"
  let query = ""
  let headers = dict.new()
  let body = case input.stream {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_event_stream_union(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_duplex_stream_with_distinct_streams_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DuplexStreamWithDistinctStreamsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_duplex_stream_with_distinct_streams_output("{}")
        _ -> decode_duplex_stream_with_distinct_streams_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_duplex_stream_with_initial_messages_input(
  input: DuplexStreamWithInitialMessagesInput,
) -> String {
  json.to_string(encode_duplex_stream_with_initial_messages_input_struct(input))
}

pub fn decode_duplex_stream_with_initial_messages_input(
  body: String,
) -> Result(DuplexStreamWithInitialMessagesInput, String) {
  case
    json.parse(body, decode_duplex_stream_with_initial_messages_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_duplex_stream_with_initial_messages_output(
  body: String,
) -> Result(DuplexStreamWithInitialMessagesOutput, String) {
  case
    json.parse(body, decode_duplex_stream_with_initial_messages_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_duplex_stream_with_initial_messages_body(
  _input: DuplexStreamWithInitialMessagesInput,
) -> json.Json {
  json.object([])
}

pub fn build_duplex_stream_with_initial_messages_request(
  input: DuplexStreamWithInitialMessagesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/DuplexStreamWithInitialMessages"
  let query = ""
  let headers = dict.new()
  let headers = case input.initial_request_member {
    option.Some(v) ->
      rest.maybe_set_header(headers, "initial-request-member", v)
    option.None -> headers
  }
  let body = case input.stream {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_event_stream_union(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_duplex_stream_with_initial_messages_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DuplexStreamWithInitialMessagesOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_duplex_stream_with_initial_messages_output("{}")
        _ -> decode_duplex_stream_with_initial_messages_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_empty_input_and_empty_output_input(
  input: EmptyInputAndEmptyOutputInput,
) -> String {
  json.to_string(encode_empty_input_and_empty_output_input_struct(input))
}

pub fn decode_empty_input_and_empty_output_input(
  body: String,
) -> Result(EmptyInputAndEmptyOutputInput, String) {
  case json.parse(body, decode_empty_input_and_empty_output_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_empty_input_and_empty_output_output(
  body: String,
) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  case json.parse(body, decode_empty_input_and_empty_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_empty_input_and_empty_output_body(
  _input: EmptyInputAndEmptyOutputInput,
) -> json.Json {
  json.object([])
}

pub fn build_empty_input_and_empty_output_request(
  input: EmptyInputAndEmptyOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EmptyInputAndEmptyOutput"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_empty_input_and_empty_output_output("{}")
        _ -> decode_empty_input_and_empty_output_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type EndpointOperationInput {
  EndpointOperationInput
}

pub fn encode_endpoint_operation_input_struct(
  _v: EndpointOperationInput,
) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_operation_input_struct() -> decode.Decoder(
  EndpointOperationInput,
) {
  decode.success(EndpointOperationInput)
}

pub type EndpointOperationOutput {
  EndpointOperationOutput
}

pub fn encode_endpoint_operation_output_struct(
  _v: EndpointOperationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_operation_output_struct() -> decode.Decoder(
  EndpointOperationOutput,
) {
  decode.success(EndpointOperationOutput)
}

pub fn encode_endpoint_operation_input(
  input: EndpointOperationInput,
) -> String {
  json.to_string(encode_endpoint_operation_input_struct(input))
}

pub fn decode_endpoint_operation_input(
  body: String,
) -> Result(EndpointOperationInput, String) {
  case json.parse(body, decode_endpoint_operation_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_endpoint_operation_output(
  body: String,
) -> Result(EndpointOperationOutput, String) {
  case json.parse(body, decode_endpoint_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_endpoint_operation_body(
  _input: EndpointOperationInput,
) -> json.Json {
  json.object([])
}

pub fn build_endpoint_operation_request(
  _input: EndpointOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EndpointOperation"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_endpoint_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EndpointOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_endpoint_operation_output("{}")
        _ -> decode_endpoint_operation_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type EndpointWithHostLabelOperationOutput {
  EndpointWithHostLabelOperationOutput
}

pub fn encode_endpoint_with_host_label_operation_output_struct(
  _v: EndpointWithHostLabelOperationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_endpoint_with_host_label_operation_output_struct() -> decode.Decoder(
  EndpointWithHostLabelOperationOutput,
) {
  decode.success(EndpointWithHostLabelOperationOutput)
}

pub fn encode_endpoint_with_host_label_operation_input(
  input: HostLabelInput,
) -> String {
  json.to_string(encode_host_label_input_struct(input))
}

pub fn decode_endpoint_with_host_label_operation_input(
  body: String,
) -> Result(HostLabelInput, String) {
  case json.parse(body, decode_host_label_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_endpoint_with_host_label_operation_output(
  body: String,
) -> Result(EndpointWithHostLabelOperationOutput, String) {
  case
    json.parse(body, decode_endpoint_with_host_label_operation_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_endpoint_with_host_label_operation_body(
  input: HostLabelInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.label {
    option.Some(v) -> [#("label", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_endpoint_with_host_label_operation_request(
  input: HostLabelInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EndpointWithHostLabelOperation"
  let query = ""
  let headers = dict.new()
  let body_json = encode_endpoint_with_host_label_operation_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_endpoint_with_host_label_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EndpointWithHostLabelOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_endpoint_with_host_label_operation_output("{}")
        _ -> decode_endpoint_with_host_label_operation_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type FractionalSecondsInput {
  FractionalSecondsInput
}

pub fn encode_fractional_seconds_input_struct(
  _v: FractionalSecondsInput,
) -> json.Json {
  json.object([])
}

pub fn decode_fractional_seconds_input_struct() -> decode.Decoder(
  FractionalSecondsInput,
) {
  decode.success(FractionalSecondsInput)
}

pub fn encode_fractional_seconds_input(
  input: FractionalSecondsInput,
) -> String {
  json.to_string(encode_fractional_seconds_input_struct(input))
}

pub fn decode_fractional_seconds_input(
  body: String,
) -> Result(FractionalSecondsInput, String) {
  case json.parse(body, decode_fractional_seconds_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_fractional_seconds_output(
  body: String,
) -> Result(FractionalSecondsOutput, String) {
  case json.parse(body, decode_fractional_seconds_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_fractional_seconds_body(
  _input: FractionalSecondsInput,
) -> json.Json {
  json.object([])
}

pub fn build_fractional_seconds_request(
  _input: FractionalSecondsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/FractionalSeconds"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_fractional_seconds_output("{}")
        _ -> decode_fractional_seconds_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type GreetingWithErrorsInput {
  GreetingWithErrorsInput
}

pub fn encode_greeting_with_errors_input_struct(
  _v: GreetingWithErrorsInput,
) -> json.Json {
  json.object([])
}

pub fn decode_greeting_with_errors_input_struct() -> decode.Decoder(
  GreetingWithErrorsInput,
) {
  decode.success(GreetingWithErrorsInput)
}

pub fn encode_greeting_with_errors_input(
  input: GreetingWithErrorsInput,
) -> String {
  json.to_string(encode_greeting_with_errors_input_struct(input))
}

pub fn decode_greeting_with_errors_input(
  body: String,
) -> Result(GreetingWithErrorsInput, String) {
  case json.parse(body, decode_greeting_with_errors_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_greeting_with_errors_output(
  body: String,
) -> Result(GreetingWithErrorsOutput, String) {
  case json.parse(body, decode_greeting_with_errors_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_greeting_with_errors_body(
  _input: GreetingWithErrorsInput,
) -> json.Json {
  json.object([])
}

pub fn build_greeting_with_errors_request(
  _input: GreetingWithErrorsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/GreetingWithErrors"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_greeting_with_errors_output("{}")
        _ -> decode_greeting_with_errors_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HostWithPathOperationInput {
  HostWithPathOperationInput
}

pub fn encode_host_with_path_operation_input_struct(
  _v: HostWithPathOperationInput,
) -> json.Json {
  json.object([])
}

pub fn decode_host_with_path_operation_input_struct() -> decode.Decoder(
  HostWithPathOperationInput,
) {
  decode.success(HostWithPathOperationInput)
}

pub type HostWithPathOperationOutput {
  HostWithPathOperationOutput
}

pub fn encode_host_with_path_operation_output_struct(
  _v: HostWithPathOperationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_host_with_path_operation_output_struct() -> decode.Decoder(
  HostWithPathOperationOutput,
) {
  decode.success(HostWithPathOperationOutput)
}

pub fn encode_host_with_path_operation_input(
  input: HostWithPathOperationInput,
) -> String {
  json.to_string(encode_host_with_path_operation_input_struct(input))
}

pub fn decode_host_with_path_operation_input(
  body: String,
) -> Result(HostWithPathOperationInput, String) {
  case json.parse(body, decode_host_with_path_operation_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_host_with_path_operation_output(
  body: String,
) -> Result(HostWithPathOperationOutput, String) {
  case json.parse(body, decode_host_with_path_operation_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_host_with_path_operation_body(
  _input: HostWithPathOperationInput,
) -> json.Json {
  json.object([])
}

pub fn build_host_with_path_operation_request(
  _input: HostWithPathOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HostWithPathOperation"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_host_with_path_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HostWithPathOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_host_with_path_operation_output("{}")
        _ -> decode_host_with_path_operation_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_empty_prefix_headers_input(
  input: HttpEmptyPrefixHeadersInput,
) -> String {
  json.to_string(encode_http_empty_prefix_headers_input_struct(input))
}

pub fn decode_http_empty_prefix_headers_input(
  body: String,
) -> Result(HttpEmptyPrefixHeadersInput, String) {
  case json.parse(body, decode_http_empty_prefix_headers_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_empty_prefix_headers_output(
  body: String,
) -> Result(HttpEmptyPrefixHeadersOutput, String) {
  case json.parse(body, decode_http_empty_prefix_headers_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_empty_prefix_headers_body(
  _input: HttpEmptyPrefixHeadersInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_http_empty_prefix_headers_output("{}")
        _ -> decode_http_empty_prefix_headers_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_enum_payload_input(input: EnumPayloadInput) -> String {
  json.to_string(encode_enum_payload_input_struct(input))
}

pub fn decode_http_enum_payload_input(
  body: String,
) -> Result(EnumPayloadInput, String) {
  case json.parse(body, decode_enum_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_enum_payload_output(
  body: String,
) -> Result(EnumPayloadInput, String) {
  case json.parse(body, decode_enum_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_enum_payload_body(_input: EnumPayloadInput) -> json.Json {
  json.object([])
}

pub fn build_http_enum_payload_request(
  input: EnumPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/EnumPayload"
  let query = ""
  let headers = dict.new()
  let body = case input.payload {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_string_enum_enum(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_enum_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(EnumPayloadInput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_enum_payload_output("{}")
        _ -> decode_http_enum_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_payload_traits_input(
  input: HttpPayloadTraitsInputOutput,
) -> String {
  json.to_string(encode_http_payload_traits_input_output_struct(input))
}

pub fn decode_http_payload_traits_input(
  body: String,
) -> Result(HttpPayloadTraitsInputOutput, String) {
  case json.parse(body, decode_http_payload_traits_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_traits_output(
  body: String,
) -> Result(HttpPayloadTraitsInputOutput, String) {
  case json.parse(body, decode_http_payload_traits_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_traits_body(
  _input: HttpPayloadTraitsInputOutput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_payload_traits_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadTraitsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_payload_traits_output("{}")
        _ -> decode_http_payload_traits_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_payload_traits_with_media_type_input(
  input: HttpPayloadTraitsWithMediaTypeInputOutput,
) -> String {
  json.to_string(encode_http_payload_traits_with_media_type_input_output_struct(
    input,
  ))
}

pub fn decode_http_payload_traits_with_media_type_input(
  body: String,
) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, String) {
  case
    json.parse(
      body,
      decode_http_payload_traits_with_media_type_input_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_traits_with_media_type_output(
  body: String,
) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, String) {
  case
    json.parse(
      body,
      decode_http_payload_traits_with_media_type_input_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_traits_with_media_type_body(
  _input: HttpPayloadTraitsWithMediaTypeInputOutput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_payload_traits_with_media_type_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadTraitsWithMediaTypeInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_payload_traits_with_media_type_output("{}")
        _ -> decode_http_payload_traits_with_media_type_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_payload_with_structure_input(
  input: HttpPayloadWithStructureInputOutput,
) -> String {
  json.to_string(encode_http_payload_with_structure_input_output_struct(input))
}

pub fn decode_http_payload_with_structure_input(
  body: String,
) -> Result(HttpPayloadWithStructureInputOutput, String) {
  case
    json.parse(body, decode_http_payload_with_structure_input_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_structure_output(
  body: String,
) -> Result(HttpPayloadWithStructureInputOutput, String) {
  case
    json.parse(body, decode_http_payload_with_structure_input_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_structure_body(
  _input: HttpPayloadWithStructureInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_http_payload_with_structure_request(
  input: HttpPayloadWithStructureInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithStructure"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_nested_payload_struct(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_structure_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithStructureInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_payload_with_structure_output("{}")
        _ -> decode_http_payload_with_structure_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_payload_with_union_input(
  input: HttpPayloadWithUnionInputOutput,
) -> String {
  json.to_string(encode_http_payload_with_union_input_output_struct(input))
}

pub fn decode_http_payload_with_union_input(
  body: String,
) -> Result(HttpPayloadWithUnionInputOutput, String) {
  case json.parse(body, decode_http_payload_with_union_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_payload_with_union_output(
  body: String,
) -> Result(HttpPayloadWithUnionInputOutput, String) {
  case json.parse(body, decode_http_payload_with_union_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_payload_with_union_body(
  _input: HttpPayloadWithUnionInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_http_payload_with_union_request(
  input: HttpPayloadWithUnionInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPayloadWithUnion"
  let query = ""
  let headers = dict.new()
  let body = case input.nested {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_union_payload_union(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_http_payload_with_union_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPayloadWithUnionInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_payload_with_union_output("{}")
        _ -> decode_http_payload_with_union_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_prefix_headers_input(
  input: HttpPrefixHeadersInput,
) -> String {
  json.to_string(encode_http_prefix_headers_input_struct(input))
}

pub fn decode_http_prefix_headers_input(
  body: String,
) -> Result(HttpPrefixHeadersInput, String) {
  case json.parse(body, decode_http_prefix_headers_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_prefix_headers_output(
  body: String,
) -> Result(HttpPrefixHeadersOutput, String) {
  case json.parse(body, decode_http_prefix_headers_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_prefix_headers_body(
  _input: HttpPrefixHeadersInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_prefix_headers_request(
  input: HttpPrefixHeadersInput,
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_prefix_headers_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPrefixHeadersOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_prefix_headers_output("{}")
        _ -> decode_http_prefix_headers_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_prefix_headers_in_response_input(
  input: HttpPrefixHeadersInResponseInput,
) -> String {
  json.to_string(encode_http_prefix_headers_in_response_input_struct(input))
}

pub fn decode_http_prefix_headers_in_response_input(
  body: String,
) -> Result(HttpPrefixHeadersInResponseInput, String) {
  case json.parse(body, decode_http_prefix_headers_in_response_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_prefix_headers_in_response_output(
  body: String,
) -> Result(HttpPrefixHeadersInResponseOutput, String) {
  case
    json.parse(body, decode_http_prefix_headers_in_response_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_prefix_headers_in_response_body(
  _input: HttpPrefixHeadersInResponseInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_prefix_headers_in_response_request(
  input: HttpPrefixHeadersInResponseInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpPrefixHeadersResponse"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_prefix_headers_in_response_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpPrefixHeadersInResponseOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_prefix_headers_in_response_output("{}")
        _ -> decode_http_prefix_headers_in_response_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HttpQueryParamsOnlyOperationOutput {
  HttpQueryParamsOnlyOperationOutput
}

pub fn encode_http_query_params_only_operation_output_struct(
  _v: HttpQueryParamsOnlyOperationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_query_params_only_operation_output_struct() -> decode.Decoder(
  HttpQueryParamsOnlyOperationOutput,
) {
  decode.success(HttpQueryParamsOnlyOperationOutput)
}

pub fn encode_http_query_params_only_operation_input(
  input: HttpQueryParamsOnlyInput,
) -> String {
  json.to_string(encode_http_query_params_only_input_struct(input))
}

pub fn decode_http_query_params_only_operation_input(
  body: String,
) -> Result(HttpQueryParamsOnlyInput, String) {
  case json.parse(body, decode_http_query_params_only_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_query_params_only_operation_output(
  body: String,
) -> Result(HttpQueryParamsOnlyOperationOutput, String) {
  case
    json.parse(body, decode_http_query_params_only_operation_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_query_params_only_operation_body(
  _input: HttpQueryParamsOnlyInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_query_params_only_operation_request(
  input: HttpQueryParamsOnlyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/http-query-params-only"
  let query = ""
  let query = case input.query_map {
    option.Some(m) -> rest.add_query_params(query, m)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_query_params_only_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpQueryParamsOnlyOperationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_query_params_only_operation_output("{}")
        _ -> decode_http_query_params_only_operation_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HttpRequestWithFloatLabelsOutput {
  HttpRequestWithFloatLabelsOutput
}

pub fn encode_http_request_with_float_labels_output_struct(
  _v: HttpRequestWithFloatLabelsOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_float_labels_output_struct() -> decode.Decoder(
  HttpRequestWithFloatLabelsOutput,
) {
  decode.success(HttpRequestWithFloatLabelsOutput)
}

pub fn encode_http_request_with_float_labels_input(
  input: HttpRequestWithFloatLabelsInput,
) -> String {
  json.to_string(encode_http_request_with_float_labels_input_struct(input))
}

pub fn decode_http_request_with_float_labels_input(
  body: String,
) -> Result(HttpRequestWithFloatLabelsInput, String) {
  case json.parse(body, decode_http_request_with_float_labels_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_float_labels_output(
  body: String,
) -> Result(HttpRequestWithFloatLabelsOutput, String) {
  case json.parse(body, decode_http_request_with_float_labels_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_float_labels_body(
  _input: HttpRequestWithFloatLabelsInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_request_with_float_labels_request(
  input: HttpRequestWithFloatLabelsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/FloatHttpLabels/{float}/{double}"
  let path = case input.double {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "double",
        case v {
          json_float.FloatValue(f) -> rest.float_to_query(f)
          json_float.NaN -> "NaN"
          json_float.PosInfinity -> "Infinity"
          json_float.NegInfinity -> "-Infinity"
        },
        False,
      )
    option.None -> path
  }
  let path = case input.float {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "float",
        case v {
          json_float.FloatValue(f) -> rest.float_to_query(f)
          json_float.NaN -> "NaN"
          json_float.PosInfinity -> "Infinity"
          json_float.NegInfinity -> "-Infinity"
        },
        False,
      )
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_float_labels_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpRequestWithFloatLabelsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_request_with_float_labels_output("{}")
        _ -> decode_http_request_with_float_labels_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HttpRequestWithGreedyLabelInPathOutput {
  HttpRequestWithGreedyLabelInPathOutput
}

pub fn encode_http_request_with_greedy_label_in_path_output_struct(
  _v: HttpRequestWithGreedyLabelInPathOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_greedy_label_in_path_output_struct() -> decode.Decoder(
  HttpRequestWithGreedyLabelInPathOutput,
) {
  decode.success(HttpRequestWithGreedyLabelInPathOutput)
}

pub fn encode_http_request_with_greedy_label_in_path_input(
  input: HttpRequestWithGreedyLabelInPathInput,
) -> String {
  json.to_string(encode_http_request_with_greedy_label_in_path_input_struct(
    input,
  ))
}

pub fn decode_http_request_with_greedy_label_in_path_input(
  body: String,
) -> Result(HttpRequestWithGreedyLabelInPathInput, String) {
  case
    json.parse(
      body,
      decode_http_request_with_greedy_label_in_path_input_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_greedy_label_in_path_output(
  body: String,
) -> Result(HttpRequestWithGreedyLabelInPathOutput, String) {
  case
    json.parse(
      body,
      decode_http_request_with_greedy_label_in_path_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_greedy_label_in_path_body(
  _input: HttpRequestWithGreedyLabelInPathInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_greedy_label_in_path_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpRequestWithGreedyLabelInPathOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_request_with_greedy_label_in_path_output("{}")
        _ -> decode_http_request_with_greedy_label_in_path_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HttpRequestWithLabelsOutput {
  HttpRequestWithLabelsOutput
}

pub fn encode_http_request_with_labels_output_struct(
  _v: HttpRequestWithLabelsOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_labels_output_struct() -> decode.Decoder(
  HttpRequestWithLabelsOutput,
) {
  decode.success(HttpRequestWithLabelsOutput)
}

pub fn encode_http_request_with_labels_input(
  input: HttpRequestWithLabelsInput,
) -> String {
  json.to_string(encode_http_request_with_labels_input_struct(input))
}

pub fn decode_http_request_with_labels_input(
  body: String,
) -> Result(HttpRequestWithLabelsInput, String) {
  case json.parse(body, decode_http_request_with_labels_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_labels_output(
  body: String,
) -> Result(HttpRequestWithLabelsOutput, String) {
  case json.parse(body, decode_http_request_with_labels_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_labels_body(
  _input: HttpRequestWithLabelsInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_request_with_labels_request(
  input: HttpRequestWithLabelsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path =
    "/HttpRequestWithLabels/{string}/{short}/{integer}/{long}/{float}/{double}/{boolean}/{timestamp}"
  let path = case input.boolean {
    option.Some(v) ->
      rest.substitute_label(path, "boolean", rest.bool_to_query(v), False)
    option.None -> path
  }
  let path = case input.double {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "double",
        case v {
          json_float.FloatValue(f) -> rest.float_to_query(f)
          json_float.NaN -> "NaN"
          json_float.PosInfinity -> "Infinity"
          json_float.NegInfinity -> "-Infinity"
        },
        False,
      )
    option.None -> path
  }
  let path = case input.float {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "float",
        case v {
          json_float.FloatValue(f) -> rest.float_to_query(f)
          json_float.NaN -> "NaN"
          json_float.PosInfinity -> "Infinity"
          json_float.NegInfinity -> "-Infinity"
        },
        False,
      )
    option.None -> path
  }
  let path = case input.integer {
    option.Some(v) ->
      rest.substitute_label(path, "integer", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.long {
    option.Some(v) ->
      rest.substitute_label(path, "long", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.short {
    option.Some(v) ->
      rest.substitute_label(path, "short", rest.int_to_query(v), False)
    option.None -> path
  }
  let path = case input.string {
    option.Some(v) -> rest.substitute_label(path, "string", v, False)
    option.None -> path
  }
  let path = case input.timestamp {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "timestamp",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_labels_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpRequestWithLabelsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_request_with_labels_output("{}")
        _ -> decode_http_request_with_labels_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HttpRequestWithLabelsAndTimestampFormatOutput {
  HttpRequestWithLabelsAndTimestampFormatOutput
}

pub fn encode_http_request_with_labels_and_timestamp_format_output_struct(
  _v: HttpRequestWithLabelsAndTimestampFormatOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_labels_and_timestamp_format_output_struct() -> decode.Decoder(
  HttpRequestWithLabelsAndTimestampFormatOutput,
) {
  decode.success(HttpRequestWithLabelsAndTimestampFormatOutput)
}

pub fn encode_http_request_with_labels_and_timestamp_format_input(
  input: HttpRequestWithLabelsAndTimestampFormatInput,
) -> String {
  json.to_string(
    encode_http_request_with_labels_and_timestamp_format_input_struct(input),
  )
}

pub fn decode_http_request_with_labels_and_timestamp_format_input(
  body: String,
) -> Result(HttpRequestWithLabelsAndTimestampFormatInput, String) {
  case
    json.parse(
      body,
      decode_http_request_with_labels_and_timestamp_format_input_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_labels_and_timestamp_format_output(
  body: String,
) -> Result(HttpRequestWithLabelsAndTimestampFormatOutput, String) {
  case
    json.parse(
      body,
      decode_http_request_with_labels_and_timestamp_format_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_labels_and_timestamp_format_body(
  _input: HttpRequestWithLabelsAndTimestampFormatInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_request_with_labels_and_timestamp_format_request(
  input: HttpRequestWithLabelsAndTimestampFormatInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path =
    "/HttpRequestWithLabelsAndTimestampFormat/{memberEpochSeconds}/{memberHttpDate}/{memberDateTime}/{defaultFormat}/{targetEpochSeconds}/{targetHttpDate}/{targetDateTime}"
  let path = case input.default_format {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "defaultFormat",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let path = case input.member_date_time {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "memberDateTime",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let path = case input.member_epoch_seconds {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "memberEpochSeconds",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let path = case input.member_http_date {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "memberHttpDate",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let path = case input.target_date_time {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "targetDateTime",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let path = case input.target_epoch_seconds {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "targetEpochSeconds",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let path = case input.target_http_date {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "targetHttpDate",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_labels_and_timestamp_format_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpRequestWithLabelsAndTimestampFormatOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_request_with_labels_and_timestamp_format_output("{}")
        _ -> decode_http_request_with_labels_and_timestamp_format_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HttpRequestWithRegexLiteralOutput {
  HttpRequestWithRegexLiteralOutput
}

pub fn encode_http_request_with_regex_literal_output_struct(
  _v: HttpRequestWithRegexLiteralOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_request_with_regex_literal_output_struct() -> decode.Decoder(
  HttpRequestWithRegexLiteralOutput,
) {
  decode.success(HttpRequestWithRegexLiteralOutput)
}

pub fn encode_http_request_with_regex_literal_input(
  input: HttpRequestWithRegexLiteralInput,
) -> String {
  json.to_string(encode_http_request_with_regex_literal_input_struct(input))
}

pub fn decode_http_request_with_regex_literal_input(
  body: String,
) -> Result(HttpRequestWithRegexLiteralInput, String) {
  case json.parse(body, decode_http_request_with_regex_literal_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_request_with_regex_literal_output(
  body: String,
) -> Result(HttpRequestWithRegexLiteralOutput, String) {
  case
    json.parse(body, decode_http_request_with_regex_literal_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_request_with_regex_literal_body(
  _input: HttpRequestWithRegexLiteralInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_request_with_regex_literal_request(
  input: HttpRequestWithRegexLiteralInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/ReDosLiteral/{str}/(a+)+"
  let path = case input.str {
    option.Some(v) -> rest.substitute_label(path, "str", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_http_request_with_regex_literal_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HttpRequestWithRegexLiteralOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_request_with_regex_literal_output("{}")
        _ -> decode_http_request_with_regex_literal_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type HttpResponseCodeInput {
  HttpResponseCodeInput
}

pub fn encode_http_response_code_input_struct(
  _v: HttpResponseCodeInput,
) -> json.Json {
  json.object([])
}

pub fn decode_http_response_code_input_struct() -> decode.Decoder(
  HttpResponseCodeInput,
) {
  decode.success(HttpResponseCodeInput)
}

pub fn encode_http_response_code_input(input: HttpResponseCodeInput) -> String {
  json.to_string(encode_http_response_code_input_struct(input))
}

pub fn decode_http_response_code_input(
  body: String,
) -> Result(HttpResponseCodeInput, String) {
  case json.parse(body, decode_http_response_code_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_response_code_output(
  body: String,
) -> Result(HttpResponseCodeOutput, String) {
  case json.parse(body, decode_http_response_code_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_response_code_body(
  _input: HttpResponseCodeInput,
) -> json.Json {
  json.object([])
}

pub fn build_http_response_code_request(
  _input: HttpResponseCodeInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/HttpResponseCode"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_http_response_code_output("{}")
        _ -> decode_http_response_code_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_http_string_payload_input(input: StringPayloadInput) -> String {
  json.to_string(encode_string_payload_input_struct(input))
}

pub fn decode_http_string_payload_input(
  body: String,
) -> Result(StringPayloadInput, String) {
  case json.parse(body, decode_string_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_http_string_payload_output(
  body: String,
) -> Result(StringPayloadInput, String) {
  case json.parse(body, decode_string_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_http_string_payload_body(
  _input: StringPayloadInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_http_string_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(StringPayloadInput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_http_string_payload_output("{}")
        _ -> decode_http_string_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type IgnoreQueryParamsInResponseInput {
  IgnoreQueryParamsInResponseInput
}

pub fn encode_ignore_query_params_in_response_input_struct(
  _v: IgnoreQueryParamsInResponseInput,
) -> json.Json {
  json.object([])
}

pub fn decode_ignore_query_params_in_response_input_struct() -> decode.Decoder(
  IgnoreQueryParamsInResponseInput,
) {
  decode.success(IgnoreQueryParamsInResponseInput)
}

pub fn encode_ignore_query_params_in_response_input(
  input: IgnoreQueryParamsInResponseInput,
) -> String {
  json.to_string(encode_ignore_query_params_in_response_input_struct(input))
}

pub fn decode_ignore_query_params_in_response_input(
  body: String,
) -> Result(IgnoreQueryParamsInResponseInput, String) {
  case json.parse(body, decode_ignore_query_params_in_response_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_ignore_query_params_in_response_output(
  body: String,
) -> Result(IgnoreQueryParamsInResponseOutput, String) {
  case
    json.parse(body, decode_ignore_query_params_in_response_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_ignore_query_params_in_response_body(
  _input: IgnoreQueryParamsInResponseInput,
) -> json.Json {
  json.object([])
}

pub fn build_ignore_query_params_in_response_request(
  _input: IgnoreQueryParamsInResponseInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/IgnoreQueryParamsInResponse"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_ignore_query_params_in_response_output("{}")
        _ -> decode_ignore_query_params_in_response_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_input_and_output_with_headers_input(
  input: InputAndOutputWithHeadersIO,
) -> String {
  json.to_string(encode_input_and_output_with_headers_io_struct(input))
}

pub fn decode_input_and_output_with_headers_input(
  body: String,
) -> Result(InputAndOutputWithHeadersIO, String) {
  case json.parse(body, decode_input_and_output_with_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_input_and_output_with_headers_output(
  body: String,
) -> Result(InputAndOutputWithHeadersIO, String) {
  case json.parse(body, decode_input_and_output_with_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_input_and_output_with_headers_body(
  _input: InputAndOutputWithHeadersIO,
) -> json.Json {
  json.object([])
}

pub fn build_input_and_output_with_headers_request(
  input: InputAndOutputWithHeadersIO,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/InputAndOutputWithHeaders"
  let query = ""
  let headers = dict.new()
  let headers = case input.header_boolean_list {
    option.Some(v) -> rest.maybe_set_header(headers, "X-BooleanList", "")
    option.None -> headers
  }
  let headers = case input.header_byte {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Byte", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_double {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Double", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> headers
  }
  let headers = case input.header_enum {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-Enum",
        rest.enum_wire_value(encode_foo_enum_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.header_enum_list {
    option.Some(v) -> rest.maybe_set_header(headers, "X-EnumList", "")
    option.None -> headers
  }
  let headers = case input.header_false_bool {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Boolean2", rest.bool_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_float {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Float", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> headers
  }
  let headers = case input.header_integer {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Integer", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_integer_enum {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-IntegerEnum",
        rest.int_to_query(case encode_integer_enum_int_enum(v) {
          _ -> 0
        }),
      )
    option.None -> headers
  }
  let headers = case input.header_integer_enum_list {
    option.Some(v) -> rest.maybe_set_header(headers, "X-IntegerEnumList", "")
    option.None -> headers
  }
  let headers = case input.header_integer_list {
    option.Some(v) -> rest.maybe_set_header(headers, "X-IntegerList", "")
    option.None -> headers
  }
  let headers = case input.header_long {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Long", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_short {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Short", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.header_string {
    option.Some(v) -> rest.maybe_set_header(headers, "X-String", v)
    option.None -> headers
  }
  let headers = case input.header_string_list {
    option.Some(v) -> rest.maybe_set_header(headers, "X-StringList", "")
    option.None -> headers
  }
  let headers = case input.header_string_set {
    option.Some(v) -> rest.maybe_set_header(headers, "X-StringSet", "")
    option.None -> headers
  }
  let headers = case input.header_timestamp_list {
    option.Some(v) -> rest.maybe_set_header(headers, "X-TimestampList", "")
    option.None -> headers
  }
  let headers = case input.header_true_bool {
    option.Some(v) ->
      rest.maybe_set_header(headers, "X-Boolean1", rest.bool_to_query(v))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_input_and_output_with_headers_output("{}")
        _ -> decode_input_and_output_with_headers_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type InputStreamOutput {
  InputStreamOutput
}

pub fn encode_input_stream_output_struct(_v: InputStreamOutput) -> json.Json {
  json.object([])
}

pub fn decode_input_stream_output_struct() -> decode.Decoder(InputStreamOutput) {
  decode.success(InputStreamOutput)
}

pub fn encode_input_stream_input(input: InputStreamInput) -> String {
  json.to_string(encode_input_stream_input_struct(input))
}

pub fn decode_input_stream_input(
  body: String,
) -> Result(InputStreamInput, String) {
  case json.parse(body, decode_input_stream_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_input_stream_output(
  body: String,
) -> Result(InputStreamOutput, String) {
  case json.parse(body, decode_input_stream_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_input_stream_body(_input: InputStreamInput) -> json.Json {
  json.object([])
}

pub fn build_input_stream_request(
  input: InputStreamInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/InputStream"
  let query = ""
  let headers = dict.new()
  let body = case input.stream {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_event_stream_union(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_input_stream_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(InputStreamOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_input_stream_output("{}")
        _ -> decode_input_stream_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type InputStreamWithInitialRequestOutput {
  InputStreamWithInitialRequestOutput
}

pub fn encode_input_stream_with_initial_request_output_struct(
  _v: InputStreamWithInitialRequestOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_input_stream_with_initial_request_output_struct() -> decode.Decoder(
  InputStreamWithInitialRequestOutput,
) {
  decode.success(InputStreamWithInitialRequestOutput)
}

pub fn encode_input_stream_with_initial_request_input(
  input: InputStreamWithInitialRequestInput,
) -> String {
  json.to_string(encode_input_stream_with_initial_request_input_struct(input))
}

pub fn decode_input_stream_with_initial_request_input(
  body: String,
) -> Result(InputStreamWithInitialRequestInput, String) {
  case
    json.parse(body, decode_input_stream_with_initial_request_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_input_stream_with_initial_request_output(
  body: String,
) -> Result(InputStreamWithInitialRequestOutput, String) {
  case
    json.parse(body, decode_input_stream_with_initial_request_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_input_stream_with_initial_request_body(
  _input: InputStreamWithInitialRequestInput,
) -> json.Json {
  json.object([])
}

pub fn build_input_stream_with_initial_request_request(
  input: InputStreamWithInitialRequestInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/InputStreamWithInitialRequest"
  let query = ""
  let headers = dict.new()
  let headers = case input.initial_request_member {
    option.Some(v) ->
      rest.maybe_set_header(headers, "initial-request-member", v)
    option.None -> headers
  }
  let body = case input.stream {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_event_stream_union(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_input_stream_with_initial_request_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(InputStreamWithInitialRequestOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_input_stream_with_initial_request_output("{}")
        _ -> decode_input_stream_with_initial_request_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_json_blobs_input(input: JsonBlobsInputOutput) -> String {
  json.to_string(encode_json_blobs_input_output_struct(input))
}

pub fn decode_json_blobs_input(
  body: String,
) -> Result(JsonBlobsInputOutput, String) {
  case json.parse(body, decode_json_blobs_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_blobs_output(
  body: String,
) -> Result(JsonBlobsInputOutput, String) {
  case json.parse(body, decode_json_blobs_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_json_blobs_body(input: JsonBlobsInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [
      #("data", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_json_blobs_request(
  input: JsonBlobsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/JsonBlobs"
  let query = ""
  let headers = dict.new()
  let body_json = encode_json_blobs_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_json_blobs_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonBlobsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_json_blobs_output("{}")
        _ -> decode_json_blobs_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_json_enums_input(input: JsonEnumsInputOutput) -> String {
  json.to_string(encode_json_enums_input_output_struct(input))
}

pub fn decode_json_enums_input(
  body: String,
) -> Result(JsonEnumsInputOutput, String) {
  case json.parse(body, decode_json_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_enums_output(
  body: String,
) -> Result(JsonEnumsInputOutput, String) {
  case json.parse(body, decode_json_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_json_enums_body(input: JsonEnumsInputOutput) -> json.Json {
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
    option.Some(v) -> [
      #("fooEnumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_map {
    option.Some(v) -> [
      #(
        "fooEnumMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_foo_enum_enum(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.foo_enum_set {
    option.Some(v) -> [
      #("fooEnumSet", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_json_enums_request(
  input: JsonEnumsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/JsonEnums"
  let query = ""
  let headers = dict.new()
  let body_json = encode_json_enums_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_json_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonEnumsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_json_enums_output("{}")
        _ -> decode_json_enums_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_json_int_enums_input(input: JsonIntEnumsInputOutput) -> String {
  json.to_string(encode_json_int_enums_input_output_struct(input))
}

pub fn decode_json_int_enums_input(
  body: String,
) -> Result(JsonIntEnumsInputOutput, String) {
  case json.parse(body, decode_json_int_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_int_enums_output(
  body: String,
) -> Result(JsonIntEnumsInputOutput, String) {
  case json.parse(body, decode_json_int_enums_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_json_int_enums_body(input: JsonIntEnumsInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.integer_enum1 {
    option.Some(v) -> [
      #("integerEnum1", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum2 {
    option.Some(v) -> [
      #("integerEnum2", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum3 {
    option.Some(v) -> [
      #("integerEnum3", encode_integer_enum_int_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum_list {
    option.Some(v) -> [
      #(
        "integerEnumList",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum_map {
    option.Some(v) -> [
      #(
        "integerEnumMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_integer_enum_int_enum(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_enum_set {
    option.Some(v) -> [
      #(
        "integerEnumSet",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_json_int_enums_request(
  input: JsonIntEnumsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/JsonIntEnums"
  let query = ""
  let headers = dict.new()
  let body_json = encode_json_int_enums_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_json_int_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonIntEnumsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_json_int_enums_output("{}")
        _ -> decode_json_int_enums_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_json_lists_input(input: JsonListsInputOutput) -> String {
  json.to_string(encode_json_lists_input_output_struct(input))
}

pub fn decode_json_lists_input(
  body: String,
) -> Result(JsonListsInputOutput, String) {
  case json.parse(body, decode_json_lists_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_lists_output(
  body: String,
) -> Result(JsonListsInputOutput, String) {
  case json.parse(body, decode_json_lists_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_json_lists_body(input: JsonListsInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_list {
    option.Some(v) -> [
      #("booleanList", fn(xs) { json.array(xs, json.bool) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.enum_list {
    option.Some(v) -> [
      #("enumList", fn(xs) { json.array(xs, encode_foo_enum_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.int_enum_list {
    option.Some(v) -> [
      #(
        "intEnumList",
        fn(xs) { json.array(xs, encode_integer_enum_int_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.integer_list {
    option.Some(v) -> [
      #("integerList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.nested_string_list {
    option.Some(v) -> [
      #(
        "nestedStringList",
        fn(xs) { json.array(xs, fn(xs) { json.array(xs, json.string) }) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.string_list {
    option.Some(v) -> [
      #("stringList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.string_set {
    option.Some(v) -> [
      #("stringSet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.structure_list {
    option.Some(v) -> [
      #(
        "structureList",
        fn(xs) { json.array(xs, encode_structure_list_member_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.timestamp_list {
    option.Some(v) -> [
      #("timestampList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_json_lists_request(
  input: JsonListsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/JsonLists"
  let query = ""
  let headers = dict.new()
  let body_json = encode_json_lists_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_json_lists_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonListsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_json_lists_output("{}")
        _ -> decode_json_lists_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_json_maps_input(input: JsonMapsInputOutput) -> String {
  json.to_string(encode_json_maps_input_output_struct(input))
}

pub fn decode_json_maps_input(
  body: String,
) -> Result(JsonMapsInputOutput, String) {
  case json.parse(body, decode_json_maps_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_maps_output(
  body: String,
) -> Result(JsonMapsInputOutput, String) {
  case json.parse(body, decode_json_maps_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_json_maps_body(input: JsonMapsInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.dense_boolean_map {
    option.Some(v) -> [
      #(
        "denseBooleanMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.bool(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_number_map {
    option.Some(v) -> [
      #(
        "denseNumberMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.int(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_set_map {
    option.Some(v) -> [
      #(
        "denseSetMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_string_map {
    option.Some(v) -> [
      #(
        "denseStringMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.dense_struct_map {
    option.Some(v) -> [
      #(
        "denseStructMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_greeting_struct_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_json_maps_request(
  input: JsonMapsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/JsonMaps"
  let query = ""
  let headers = dict.new()
  let body_json = encode_json_maps_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_json_maps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonMapsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_json_maps_output("{}")
        _ -> decode_json_maps_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_json_timestamps_input(
  input: JsonTimestampsInputOutput,
) -> String {
  json.to_string(encode_json_timestamps_input_output_struct(input))
}

pub fn decode_json_timestamps_input(
  body: String,
) -> Result(JsonTimestampsInputOutput, String) {
  case json.parse(body, decode_json_timestamps_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_timestamps_output(
  body: String,
) -> Result(JsonTimestampsInputOutput, String) {
  case json.parse(body, decode_json_timestamps_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_json_timestamps_body(
  input: JsonTimestampsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.date_time {
    option.Some(v) -> [#("dateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.date_time_on_target {
    option.Some(v) -> [#("dateTimeOnTarget", json.int(v)), ..pairs]
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
    option.Some(v) -> [#("httpDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.http_date_on_target {
    option.Some(v) -> [#("httpDateOnTarget", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.normal {
    option.Some(v) -> [#("normal", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_json_timestamps_request(
  input: JsonTimestampsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/JsonTimestamps"
  let query = ""
  let headers = dict.new()
  let body_json = encode_json_timestamps_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_json_timestamps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(JsonTimestampsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_json_timestamps_output("{}")
        _ -> decode_json_timestamps_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_json_unions_input(input: UnionInputOutput) -> String {
  json.to_string(encode_union_input_output_struct(input))
}

pub fn decode_json_unions_input(
  body: String,
) -> Result(UnionInputOutput, String) {
  case json.parse(body, decode_union_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_json_unions_output(
  body: String,
) -> Result(UnionInputOutput, String) {
  case json.parse(body, decode_union_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_json_unions_body(input: UnionInputOutput) -> json.Json {
  let pairs = []
  let pairs = case input.contents {
    option.Some(v) -> [#("contents", encode_my_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_json_unions_request(
  input: UnionInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/JsonUnions"
  let query = ""
  let headers = dict.new()
  let body_json = encode_json_unions_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_json_unions_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UnionInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_json_unions_output("{}")
        _ -> decode_json_unions_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedAcceptWithBodyInput {
  MalformedAcceptWithBodyInput
}

pub fn encode_malformed_accept_with_body_input_struct(
  _v: MalformedAcceptWithBodyInput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_accept_with_body_input_struct() -> decode.Decoder(
  MalformedAcceptWithBodyInput,
) {
  decode.success(MalformedAcceptWithBodyInput)
}

pub fn encode_malformed_accept_with_body_input(
  input: MalformedAcceptWithBodyInput,
) -> String {
  json.to_string(encode_malformed_accept_with_body_input_struct(input))
}

pub fn decode_malformed_accept_with_body_input(
  body: String,
) -> Result(MalformedAcceptWithBodyInput, String) {
  case json.parse(body, decode_malformed_accept_with_body_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_accept_with_body_output(
  body: String,
) -> Result(GreetingStruct, String) {
  case json.parse(body, decode_greeting_struct_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_accept_with_body_body(
  _input: MalformedAcceptWithBodyInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_accept_with_body_request(
  _input: MalformedAcceptWithBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedAcceptWithBody"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_accept_with_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GreetingStruct, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_accept_with_body_output("{}")
        _ -> decode_malformed_accept_with_body_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedAcceptWithGenericStringInput {
  MalformedAcceptWithGenericStringInput
}

pub fn encode_malformed_accept_with_generic_string_input_struct(
  _v: MalformedAcceptWithGenericStringInput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_accept_with_generic_string_input_struct() -> decode.Decoder(
  MalformedAcceptWithGenericStringInput,
) {
  decode.success(MalformedAcceptWithGenericStringInput)
}

pub fn encode_malformed_accept_with_generic_string_input(
  input: MalformedAcceptWithGenericStringInput,
) -> String {
  json.to_string(encode_malformed_accept_with_generic_string_input_struct(input))
}

pub fn decode_malformed_accept_with_generic_string_input(
  body: String,
) -> Result(MalformedAcceptWithGenericStringInput, String) {
  case
    json.parse(body, decode_malformed_accept_with_generic_string_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_accept_with_generic_string_output(
  body: String,
) -> Result(MalformedAcceptWithGenericStringOutput, String) {
  case
    json.parse(
      body,
      decode_malformed_accept_with_generic_string_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_accept_with_generic_string_body(
  _input: MalformedAcceptWithGenericStringInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_accept_with_generic_string_request(
  _input: MalformedAcceptWithGenericStringInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedAcceptWithGenericString"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_accept_with_generic_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedAcceptWithGenericStringOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_accept_with_generic_string_output("{}")
        _ -> decode_malformed_accept_with_generic_string_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedAcceptWithPayloadInput {
  MalformedAcceptWithPayloadInput
}

pub fn encode_malformed_accept_with_payload_input_struct(
  _v: MalformedAcceptWithPayloadInput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_accept_with_payload_input_struct() -> decode.Decoder(
  MalformedAcceptWithPayloadInput,
) {
  decode.success(MalformedAcceptWithPayloadInput)
}

pub fn encode_malformed_accept_with_payload_input(
  input: MalformedAcceptWithPayloadInput,
) -> String {
  json.to_string(encode_malformed_accept_with_payload_input_struct(input))
}

pub fn decode_malformed_accept_with_payload_input(
  body: String,
) -> Result(MalformedAcceptWithPayloadInput, String) {
  case json.parse(body, decode_malformed_accept_with_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_accept_with_payload_output(
  body: String,
) -> Result(MalformedAcceptWithPayloadOutput, String) {
  case json.parse(body, decode_malformed_accept_with_payload_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_accept_with_payload_body(
  _input: MalformedAcceptWithPayloadInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_accept_with_payload_request(
  _input: MalformedAcceptWithPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedAcceptWithPayload"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_accept_with_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedAcceptWithPayloadOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_accept_with_payload_output("{}")
        _ -> decode_malformed_accept_with_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedBlobOutput {
  MalformedBlobOutput
}

pub fn encode_malformed_blob_output_struct(
  _v: MalformedBlobOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_blob_output_struct() -> decode.Decoder(
  MalformedBlobOutput,
) {
  decode.success(MalformedBlobOutput)
}

pub fn encode_malformed_blob_input(input: MalformedBlobInput) -> String {
  json.to_string(encode_malformed_blob_input_struct(input))
}

pub fn decode_malformed_blob_input(
  body: String,
) -> Result(MalformedBlobInput, String) {
  case json.parse(body, decode_malformed_blob_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_blob_output(
  body: String,
) -> Result(MalformedBlobOutput, String) {
  case json.parse(body, decode_malformed_blob_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_blob_body(input: MalformedBlobInput) -> json.Json {
  let pairs = []
  let pairs = case input.blob {
    option.Some(v) -> [
      #("blob", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_blob_request(
  input: MalformedBlobInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedBlob"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_blob_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_blob_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedBlobOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_blob_output("{}")
        _ -> decode_malformed_blob_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedBooleanOutput {
  MalformedBooleanOutput
}

pub fn encode_malformed_boolean_output_struct(
  _v: MalformedBooleanOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_boolean_output_struct() -> decode.Decoder(
  MalformedBooleanOutput,
) {
  decode.success(MalformedBooleanOutput)
}

pub fn encode_malformed_boolean_input(input: MalformedBooleanInput) -> String {
  json.to_string(encode_malformed_boolean_input_struct(input))
}

pub fn decode_malformed_boolean_input(
  body: String,
) -> Result(MalformedBooleanInput, String) {
  case json.parse(body, decode_malformed_boolean_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_boolean_output(
  body: String,
) -> Result(MalformedBooleanOutput, String) {
  case json.parse(body, decode_malformed_boolean_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_boolean_body(
  input: MalformedBooleanInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.boolean_in_body {
    option.Some(v) -> [#("booleanInBody", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_boolean_request(
  input: MalformedBooleanInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedBoolean/{booleanInPath}"
  let path = case input.boolean_in_path {
    option.Some(v) ->
      rest.substitute_label(path, "booleanInPath", rest.bool_to_query(v), False)
    option.None -> path
  }
  let query = ""
  let query = case input.boolean_in_query {
    option.Some(v) ->
      rest.add_query(query, "booleanInQuery", rest.bool_to_query(v))
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.boolean_in_header {
    option.Some(v) ->
      rest.maybe_set_header(headers, "booleanInHeader", rest.bool_to_query(v))
    option.None -> headers
  }
  let body_json = encode_malformed_boolean_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_boolean_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedBooleanOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_boolean_output("{}")
        _ -> decode_malformed_boolean_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedByteOutput {
  MalformedByteOutput
}

pub fn encode_malformed_byte_output_struct(
  _v: MalformedByteOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_byte_output_struct() -> decode.Decoder(
  MalformedByteOutput,
) {
  decode.success(MalformedByteOutput)
}

pub fn encode_malformed_byte_input(input: MalformedByteInput) -> String {
  json.to_string(encode_malformed_byte_input_struct(input))
}

pub fn decode_malformed_byte_input(
  body: String,
) -> Result(MalformedByteInput, String) {
  case json.parse(body, decode_malformed_byte_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_byte_output(
  body: String,
) -> Result(MalformedByteOutput, String) {
  case json.parse(body, decode_malformed_byte_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_byte_body(input: MalformedByteInput) -> json.Json {
  let pairs = []
  let pairs = case input.byte_in_body {
    option.Some(v) -> [#("byteInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_byte_request(
  input: MalformedByteInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedByte/{byteInPath}"
  let path = case input.byte_in_path {
    option.Some(v) ->
      rest.substitute_label(path, "byteInPath", rest.int_to_query(v), False)
    option.None -> path
  }
  let query = ""
  let query = case input.byte_in_query {
    option.Some(v) -> rest.add_query(query, "byteInQuery", rest.int_to_query(v))
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.byte_in_header {
    option.Some(v) ->
      rest.maybe_set_header(headers, "byteInHeader", rest.int_to_query(v))
    option.None -> headers
  }
  let body_json = encode_malformed_byte_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_byte_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedByteOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_byte_output("{}")
        _ -> decode_malformed_byte_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedContentTypeWithBodyOutput {
  MalformedContentTypeWithBodyOutput
}

pub fn encode_malformed_content_type_with_body_output_struct(
  _v: MalformedContentTypeWithBodyOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_content_type_with_body_output_struct() -> decode.Decoder(
  MalformedContentTypeWithBodyOutput,
) {
  decode.success(MalformedContentTypeWithBodyOutput)
}

pub fn encode_malformed_content_type_with_body_input(
  input: GreetingStruct,
) -> String {
  json.to_string(encode_greeting_struct_struct(input))
}

pub fn decode_malformed_content_type_with_body_input(
  body: String,
) -> Result(GreetingStruct, String) {
  case json.parse(body, decode_greeting_struct_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_content_type_with_body_output(
  body: String,
) -> Result(MalformedContentTypeWithBodyOutput, String) {
  case
    json.parse(body, decode_malformed_content_type_with_body_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_content_type_with_body_body(
  input: GreetingStruct,
) -> json.Json {
  let pairs = []
  let pairs = case input.hi {
    option.Some(v) -> [#("hi", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_content_type_with_body_request(
  input: GreetingStruct,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedContentTypeWithBody"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_content_type_with_body_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_content_type_with_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedContentTypeWithBodyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_content_type_with_body_output("{}")
        _ -> decode_malformed_content_type_with_body_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedContentTypeWithGenericStringOutput {
  MalformedContentTypeWithGenericStringOutput
}

pub fn encode_malformed_content_type_with_generic_string_output_struct(
  _v: MalformedContentTypeWithGenericStringOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_content_type_with_generic_string_output_struct() -> decode.Decoder(
  MalformedContentTypeWithGenericStringOutput,
) {
  decode.success(MalformedContentTypeWithGenericStringOutput)
}

pub fn encode_malformed_content_type_with_generic_string_input(
  input: MalformedContentTypeWithGenericStringInput,
) -> String {
  json.to_string(encode_malformed_content_type_with_generic_string_input_struct(
    input,
  ))
}

pub fn decode_malformed_content_type_with_generic_string_input(
  body: String,
) -> Result(MalformedContentTypeWithGenericStringInput, String) {
  case
    json.parse(
      body,
      decode_malformed_content_type_with_generic_string_input_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_content_type_with_generic_string_output(
  body: String,
) -> Result(MalformedContentTypeWithGenericStringOutput, String) {
  case
    json.parse(
      body,
      decode_malformed_content_type_with_generic_string_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_content_type_with_generic_string_body(
  _input: MalformedContentTypeWithGenericStringInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_content_type_with_generic_string_request(
  input: MalformedContentTypeWithGenericStringInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedContentTypeWithGenericString"
  let query = ""
  let headers = dict.new()
  let body = case input.payload {
    option.Some(v) -> bit_array.from_string(v)
    option.None -> <<>>
  }
  let content_type = "text/plain"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_content_type_with_generic_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedContentTypeWithGenericStringOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_content_type_with_generic_string_output("{}")
        _ -> decode_malformed_content_type_with_generic_string_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedContentTypeWithoutBodyInput {
  MalformedContentTypeWithoutBodyInput
}

pub fn encode_malformed_content_type_without_body_input_struct(
  _v: MalformedContentTypeWithoutBodyInput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_content_type_without_body_input_struct() -> decode.Decoder(
  MalformedContentTypeWithoutBodyInput,
) {
  decode.success(MalformedContentTypeWithoutBodyInput)
}

pub type MalformedContentTypeWithoutBodyOutput {
  MalformedContentTypeWithoutBodyOutput
}

pub fn encode_malformed_content_type_without_body_output_struct(
  _v: MalformedContentTypeWithoutBodyOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_content_type_without_body_output_struct() -> decode.Decoder(
  MalformedContentTypeWithoutBodyOutput,
) {
  decode.success(MalformedContentTypeWithoutBodyOutput)
}

pub fn encode_malformed_content_type_without_body_input(
  input: MalformedContentTypeWithoutBodyInput,
) -> String {
  json.to_string(encode_malformed_content_type_without_body_input_struct(input))
}

pub fn decode_malformed_content_type_without_body_input(
  body: String,
) -> Result(MalformedContentTypeWithoutBodyInput, String) {
  case
    json.parse(body, decode_malformed_content_type_without_body_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_content_type_without_body_output(
  body: String,
) -> Result(MalformedContentTypeWithoutBodyOutput, String) {
  case
    json.parse(body, decode_malformed_content_type_without_body_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_content_type_without_body_body(
  _input: MalformedContentTypeWithoutBodyInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_content_type_without_body_request(
  _input: MalformedContentTypeWithoutBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedContentTypeWithoutBody"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_content_type_without_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedContentTypeWithoutBodyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_content_type_without_body_output("{}")
        _ -> decode_malformed_content_type_without_body_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedContentTypeWithoutBodyEmptyInputOutput {
  MalformedContentTypeWithoutBodyEmptyInputOutput
}

pub fn encode_malformed_content_type_without_body_empty_input_output_struct(
  _v: MalformedContentTypeWithoutBodyEmptyInputOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_content_type_without_body_empty_input_output_struct() -> decode.Decoder(
  MalformedContentTypeWithoutBodyEmptyInputOutput,
) {
  decode.success(MalformedContentTypeWithoutBodyEmptyInputOutput)
}

pub fn encode_malformed_content_type_without_body_empty_input_input(
  input: MalformedContentTypeWithoutBodyEmptyInputInput,
) -> String {
  json.to_string(
    encode_malformed_content_type_without_body_empty_input_input_struct(input),
  )
}

pub fn decode_malformed_content_type_without_body_empty_input_input(
  body: String,
) -> Result(MalformedContentTypeWithoutBodyEmptyInputInput, String) {
  case
    json.parse(
      body,
      decode_malformed_content_type_without_body_empty_input_input_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_content_type_without_body_empty_input_output(
  body: String,
) -> Result(MalformedContentTypeWithoutBodyEmptyInputOutput, String) {
  case
    json.parse(
      body,
      decode_malformed_content_type_without_body_empty_input_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_content_type_without_body_empty_input_body(
  _input: MalformedContentTypeWithoutBodyEmptyInputInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_content_type_without_body_empty_input_request(
  input: MalformedContentTypeWithoutBodyEmptyInputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedContentTypeWithoutBodyEmptyInput"
  let query = ""
  let headers = dict.new()
  let headers = case input.header {
    option.Some(v) -> rest.maybe_set_header(headers, "header", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_content_type_without_body_empty_input_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedContentTypeWithoutBodyEmptyInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" ->
          decode_malformed_content_type_without_body_empty_input_output("{}")
        _ -> decode_malformed_content_type_without_body_empty_input_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedContentTypeWithPayloadOutput {
  MalformedContentTypeWithPayloadOutput
}

pub fn encode_malformed_content_type_with_payload_output_struct(
  _v: MalformedContentTypeWithPayloadOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_content_type_with_payload_output_struct() -> decode.Decoder(
  MalformedContentTypeWithPayloadOutput,
) {
  decode.success(MalformedContentTypeWithPayloadOutput)
}

pub fn encode_malformed_content_type_with_payload_input(
  input: MalformedContentTypeWithPayloadInput,
) -> String {
  json.to_string(encode_malformed_content_type_with_payload_input_struct(input))
}

pub fn decode_malformed_content_type_with_payload_input(
  body: String,
) -> Result(MalformedContentTypeWithPayloadInput, String) {
  case
    json.parse(body, decode_malformed_content_type_with_payload_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_content_type_with_payload_output(
  body: String,
) -> Result(MalformedContentTypeWithPayloadOutput, String) {
  case
    json.parse(body, decode_malformed_content_type_with_payload_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_content_type_with_payload_body(
  _input: MalformedContentTypeWithPayloadInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_content_type_with_payload_request(
  input: MalformedContentTypeWithPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedContentTypeWithPayload"
  let query = ""
  let headers = dict.new()
  let body = case input.payload {
    option.Some(v) -> v
    option.None -> <<>>
  }
  let content_type = "application/octet-stream"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_content_type_with_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedContentTypeWithPayloadOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_content_type_with_payload_output("{}")
        _ -> decode_malformed_content_type_with_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedDoubleOutput {
  MalformedDoubleOutput
}

pub fn encode_malformed_double_output_struct(
  _v: MalformedDoubleOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_double_output_struct() -> decode.Decoder(
  MalformedDoubleOutput,
) {
  decode.success(MalformedDoubleOutput)
}

pub fn encode_malformed_double_input(input: MalformedDoubleInput) -> String {
  json.to_string(encode_malformed_double_input_struct(input))
}

pub fn decode_malformed_double_input(
  body: String,
) -> Result(MalformedDoubleInput, String) {
  case json.parse(body, decode_malformed_double_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_double_output(
  body: String,
) -> Result(MalformedDoubleOutput, String) {
  case json.parse(body, decode_malformed_double_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_double_body(input: MalformedDoubleInput) -> json.Json {
  let pairs = []
  let pairs = case input.double_in_body {
    option.Some(v) -> [#("doubleInBody", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_double_request(
  input: MalformedDoubleInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedDouble/{doubleInPath}"
  let path = case input.double_in_path {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "doubleInPath",
        case v {
          json_float.FloatValue(f) -> rest.float_to_query(f)
          json_float.NaN -> "NaN"
          json_float.PosInfinity -> "Infinity"
          json_float.NegInfinity -> "-Infinity"
        },
        False,
      )
    option.None -> path
  }
  let query = ""
  let query = case input.double_in_query {
    option.Some(v) ->
      rest.add_query(query, "doubleInQuery", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.double_in_header {
    option.Some(v) ->
      rest.maybe_set_header(headers, "doubleInHeader", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> headers
  }
  let body_json = encode_malformed_double_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_double_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedDoubleOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_double_output("{}")
        _ -> decode_malformed_double_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedFloatOutput {
  MalformedFloatOutput
}

pub fn encode_malformed_float_output_struct(
  _v: MalformedFloatOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_float_output_struct() -> decode.Decoder(
  MalformedFloatOutput,
) {
  decode.success(MalformedFloatOutput)
}

pub fn encode_malformed_float_input(input: MalformedFloatInput) -> String {
  json.to_string(encode_malformed_float_input_struct(input))
}

pub fn decode_malformed_float_input(
  body: String,
) -> Result(MalformedFloatInput, String) {
  case json.parse(body, decode_malformed_float_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_float_output(
  body: String,
) -> Result(MalformedFloatOutput, String) {
  case json.parse(body, decode_malformed_float_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_float_body(input: MalformedFloatInput) -> json.Json {
  let pairs = []
  let pairs = case input.float_in_body {
    option.Some(v) -> [#("floatInBody", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_float_request(
  input: MalformedFloatInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedFloat/{floatInPath}"
  let path = case input.float_in_path {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "floatInPath",
        case v {
          json_float.FloatValue(f) -> rest.float_to_query(f)
          json_float.NaN -> "NaN"
          json_float.PosInfinity -> "Infinity"
          json_float.NegInfinity -> "-Infinity"
        },
        False,
      )
    option.None -> path
  }
  let query = ""
  let query = case input.float_in_query {
    option.Some(v) ->
      rest.add_query(query, "floatInQuery", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.float_in_header {
    option.Some(v) ->
      rest.maybe_set_header(headers, "floatInHeader", case v {
        json_float.FloatValue(f) -> rest.float_to_query(f)
        json_float.NaN -> "NaN"
        json_float.PosInfinity -> "Infinity"
        json_float.NegInfinity -> "-Infinity"
      })
    option.None -> headers
  }
  let body_json = encode_malformed_float_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_float_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedFloatOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_float_output("{}")
        _ -> decode_malformed_float_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedIntegerOutput {
  MalformedIntegerOutput
}

pub fn encode_malformed_integer_output_struct(
  _v: MalformedIntegerOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_integer_output_struct() -> decode.Decoder(
  MalformedIntegerOutput,
) {
  decode.success(MalformedIntegerOutput)
}

pub fn encode_malformed_integer_input(input: MalformedIntegerInput) -> String {
  json.to_string(encode_malformed_integer_input_struct(input))
}

pub fn decode_malformed_integer_input(
  body: String,
) -> Result(MalformedIntegerInput, String) {
  case json.parse(body, decode_malformed_integer_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_integer_output(
  body: String,
) -> Result(MalformedIntegerOutput, String) {
  case json.parse(body, decode_malformed_integer_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_integer_body(
  input: MalformedIntegerInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.integer_in_body {
    option.Some(v) -> [#("integerInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_integer_request(
  input: MalformedIntegerInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedInteger/{integerInPath}"
  let path = case input.integer_in_path {
    option.Some(v) ->
      rest.substitute_label(path, "integerInPath", rest.int_to_query(v), False)
    option.None -> path
  }
  let query = ""
  let query = case input.integer_in_query {
    option.Some(v) ->
      rest.add_query(query, "integerInQuery", rest.int_to_query(v))
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.integer_in_header {
    option.Some(v) ->
      rest.maybe_set_header(headers, "integerInHeader", rest.int_to_query(v))
    option.None -> headers
  }
  let body_json = encode_malformed_integer_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_integer_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedIntegerOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_integer_output("{}")
        _ -> decode_malformed_integer_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedListOutput {
  MalformedListOutput
}

pub fn encode_malformed_list_output_struct(
  _v: MalformedListOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_list_output_struct() -> decode.Decoder(
  MalformedListOutput,
) {
  decode.success(MalformedListOutput)
}

pub fn encode_malformed_list_input(input: MalformedListInput) -> String {
  json.to_string(encode_malformed_list_input_struct(input))
}

pub fn decode_malformed_list_input(
  body: String,
) -> Result(MalformedListInput, String) {
  case json.parse(body, decode_malformed_list_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_list_output(
  body: String,
) -> Result(MalformedListOutput, String) {
  case json.parse(body, decode_malformed_list_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_list_body(input: MalformedListInput) -> json.Json {
  let pairs = []
  let pairs = case input.body_list {
    option.Some(v) -> [
      #("bodyList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_list_request(
  input: MalformedListInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedList"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_list_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_list_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedListOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_list_output("{}")
        _ -> decode_malformed_list_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedLongOutput {
  MalformedLongOutput
}

pub fn encode_malformed_long_output_struct(
  _v: MalformedLongOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_long_output_struct() -> decode.Decoder(
  MalformedLongOutput,
) {
  decode.success(MalformedLongOutput)
}

pub fn encode_malformed_long_input(input: MalformedLongInput) -> String {
  json.to_string(encode_malformed_long_input_struct(input))
}

pub fn decode_malformed_long_input(
  body: String,
) -> Result(MalformedLongInput, String) {
  case json.parse(body, decode_malformed_long_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_long_output(
  body: String,
) -> Result(MalformedLongOutput, String) {
  case json.parse(body, decode_malformed_long_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_long_body(input: MalformedLongInput) -> json.Json {
  let pairs = []
  let pairs = case input.long_in_body {
    option.Some(v) -> [#("longInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_long_request(
  input: MalformedLongInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedLong/{longInPath}"
  let path = case input.long_in_path {
    option.Some(v) ->
      rest.substitute_label(path, "longInPath", rest.int_to_query(v), False)
    option.None -> path
  }
  let query = ""
  let query = case input.long_in_query {
    option.Some(v) -> rest.add_query(query, "longInQuery", rest.int_to_query(v))
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.long_in_header {
    option.Some(v) ->
      rest.maybe_set_header(headers, "longInHeader", rest.int_to_query(v))
    option.None -> headers
  }
  let body_json = encode_malformed_long_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_long_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedLongOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_long_output("{}")
        _ -> decode_malformed_long_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedMapOutput {
  MalformedMapOutput
}

pub fn encode_malformed_map_output_struct(_v: MalformedMapOutput) -> json.Json {
  json.object([])
}

pub fn decode_malformed_map_output_struct() -> decode.Decoder(
  MalformedMapOutput,
) {
  decode.success(MalformedMapOutput)
}

pub fn encode_malformed_map_input(input: MalformedMapInput) -> String {
  json.to_string(encode_malformed_map_input_struct(input))
}

pub fn decode_malformed_map_input(
  body: String,
) -> Result(MalformedMapInput, String) {
  case json.parse(body, decode_malformed_map_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_map_output(
  body: String,
) -> Result(MalformedMapOutput, String) {
  case json.parse(body, decode_malformed_map_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_map_body(input: MalformedMapInput) -> json.Json {
  let pairs = []
  let pairs = case input.body_map {
    option.Some(v) -> [
      #(
        "bodyMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_map_request(
  input: MalformedMapInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedMap"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_map_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_map_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedMapOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_map_output("{}")
        _ -> decode_malformed_map_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedRequestBodyOutput {
  MalformedRequestBodyOutput
}

pub fn encode_malformed_request_body_output_struct(
  _v: MalformedRequestBodyOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_request_body_output_struct() -> decode.Decoder(
  MalformedRequestBodyOutput,
) {
  decode.success(MalformedRequestBodyOutput)
}

pub fn encode_malformed_request_body_input(
  input: MalformedRequestBodyInput,
) -> String {
  json.to_string(encode_malformed_request_body_input_struct(input))
}

pub fn decode_malformed_request_body_input(
  body: String,
) -> Result(MalformedRequestBodyInput, String) {
  case json.parse(body, decode_malformed_request_body_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_request_body_output(
  body: String,
) -> Result(MalformedRequestBodyOutput, String) {
  case json.parse(body, decode_malformed_request_body_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_request_body_body(
  input: MalformedRequestBodyInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.float {
    option.Some(v) -> [#("float", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.int {
    option.Some(v) -> [#("int", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_request_body_request(
  input: MalformedRequestBodyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedRequestBody"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_request_body_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_request_body_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedRequestBodyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_request_body_output("{}")
        _ -> decode_malformed_request_body_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedShortOutput {
  MalformedShortOutput
}

pub fn encode_malformed_short_output_struct(
  _v: MalformedShortOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_short_output_struct() -> decode.Decoder(
  MalformedShortOutput,
) {
  decode.success(MalformedShortOutput)
}

pub fn encode_malformed_short_input(input: MalformedShortInput) -> String {
  json.to_string(encode_malformed_short_input_struct(input))
}

pub fn decode_malformed_short_input(
  body: String,
) -> Result(MalformedShortInput, String) {
  case json.parse(body, decode_malformed_short_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_short_output(
  body: String,
) -> Result(MalformedShortOutput, String) {
  case json.parse(body, decode_malformed_short_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_short_body(input: MalformedShortInput) -> json.Json {
  let pairs = []
  let pairs = case input.short_in_body {
    option.Some(v) -> [#("shortInBody", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_short_request(
  input: MalformedShortInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedShort/{shortInPath}"
  let path = case input.short_in_path {
    option.Some(v) ->
      rest.substitute_label(path, "shortInPath", rest.int_to_query(v), False)
    option.None -> path
  }
  let query = ""
  let query = case input.short_in_query {
    option.Some(v) ->
      rest.add_query(query, "shortInQuery", rest.int_to_query(v))
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.short_in_header {
    option.Some(v) ->
      rest.maybe_set_header(headers, "shortInHeader", rest.int_to_query(v))
    option.None -> headers
  }
  let body_json = encode_malformed_short_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_short_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedShortOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_short_output("{}")
        _ -> decode_malformed_short_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedStringOutput {
  MalformedStringOutput
}

pub fn encode_malformed_string_output_struct(
  _v: MalformedStringOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_string_output_struct() -> decode.Decoder(
  MalformedStringOutput,
) {
  decode.success(MalformedStringOutput)
}

pub fn encode_malformed_string_input(input: MalformedStringInput) -> String {
  json.to_string(encode_malformed_string_input_struct(input))
}

pub fn decode_malformed_string_input(
  body: String,
) -> Result(MalformedStringInput, String) {
  case json.parse(body, decode_malformed_string_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_string_output(
  body: String,
) -> Result(MalformedStringOutput, String) {
  case json.parse(body, decode_malformed_string_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_string_body(_input: MalformedStringInput) -> json.Json {
  json.object([])
}

pub fn build_malformed_string_request(
  input: MalformedStringInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedString"
  let query = ""
  let headers = dict.new()
  let headers = case input.blob {
    option.Some(v) ->
      rest.maybe_set_header(headers, "amz-media-typed-header", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedStringOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_string_output("{}")
        _ -> decode_malformed_string_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampBodyDateTimeOutput {
  MalformedTimestampBodyDateTimeOutput
}

pub fn encode_malformed_timestamp_body_date_time_output_struct(
  _v: MalformedTimestampBodyDateTimeOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_body_date_time_output_struct() -> decode.Decoder(
  MalformedTimestampBodyDateTimeOutput,
) {
  decode.success(MalformedTimestampBodyDateTimeOutput)
}

pub fn encode_malformed_timestamp_body_date_time_input(
  input: MalformedTimestampBodyDateTimeInput,
) -> String {
  json.to_string(encode_malformed_timestamp_body_date_time_input_struct(input))
}

pub fn decode_malformed_timestamp_body_date_time_input(
  body: String,
) -> Result(MalformedTimestampBodyDateTimeInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_body_date_time_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_body_date_time_output(
  body: String,
) -> Result(MalformedTimestampBodyDateTimeOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_body_date_time_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_body_date_time_body(
  input: MalformedTimestampBodyDateTimeInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_timestamp_body_date_time_request(
  input: MalformedTimestampBodyDateTimeInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampBodyDateTime"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_timestamp_body_date_time_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_body_date_time_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampBodyDateTimeOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_body_date_time_output("{}")
        _ -> decode_malformed_timestamp_body_date_time_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampBodyDefaultOutput {
  MalformedTimestampBodyDefaultOutput
}

pub fn encode_malformed_timestamp_body_default_output_struct(
  _v: MalformedTimestampBodyDefaultOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_body_default_output_struct() -> decode.Decoder(
  MalformedTimestampBodyDefaultOutput,
) {
  decode.success(MalformedTimestampBodyDefaultOutput)
}

pub fn encode_malformed_timestamp_body_default_input(
  input: MalformedTimestampBodyDefaultInput,
) -> String {
  json.to_string(encode_malformed_timestamp_body_default_input_struct(input))
}

pub fn decode_malformed_timestamp_body_default_input(
  body: String,
) -> Result(MalformedTimestampBodyDefaultInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_body_default_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_body_default_output(
  body: String,
) -> Result(MalformedTimestampBodyDefaultOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_body_default_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_body_default_body(
  input: MalformedTimestampBodyDefaultInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_timestamp_body_default_request(
  input: MalformedTimestampBodyDefaultInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampBodyDefault"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_timestamp_body_default_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_body_default_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampBodyDefaultOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_body_default_output("{}")
        _ -> decode_malformed_timestamp_body_default_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampBodyHttpDateOutput {
  MalformedTimestampBodyHttpDateOutput
}

pub fn encode_malformed_timestamp_body_http_date_output_struct(
  _v: MalformedTimestampBodyHttpDateOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_body_http_date_output_struct() -> decode.Decoder(
  MalformedTimestampBodyHttpDateOutput,
) {
  decode.success(MalformedTimestampBodyHttpDateOutput)
}

pub fn encode_malformed_timestamp_body_http_date_input(
  input: MalformedTimestampBodyHttpDateInput,
) -> String {
  json.to_string(encode_malformed_timestamp_body_http_date_input_struct(input))
}

pub fn decode_malformed_timestamp_body_http_date_input(
  body: String,
) -> Result(MalformedTimestampBodyHttpDateInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_body_http_date_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_body_http_date_output(
  body: String,
) -> Result(MalformedTimestampBodyHttpDateOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_body_http_date_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_body_http_date_body(
  input: MalformedTimestampBodyHttpDateInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.timestamp {
    option.Some(v) -> [#("timestamp", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_timestamp_body_http_date_request(
  input: MalformedTimestampBodyHttpDateInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampBodyHttpDate"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_timestamp_body_http_date_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_body_http_date_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampBodyHttpDateOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_body_http_date_output("{}")
        _ -> decode_malformed_timestamp_body_http_date_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampHeaderDateTimeOutput {
  MalformedTimestampHeaderDateTimeOutput
}

pub fn encode_malformed_timestamp_header_date_time_output_struct(
  _v: MalformedTimestampHeaderDateTimeOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_header_date_time_output_struct() -> decode.Decoder(
  MalformedTimestampHeaderDateTimeOutput,
) {
  decode.success(MalformedTimestampHeaderDateTimeOutput)
}

pub fn encode_malformed_timestamp_header_date_time_input(
  input: MalformedTimestampHeaderDateTimeInput,
) -> String {
  json.to_string(encode_malformed_timestamp_header_date_time_input_struct(input))
}

pub fn decode_malformed_timestamp_header_date_time_input(
  body: String,
) -> Result(MalformedTimestampHeaderDateTimeInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_header_date_time_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_header_date_time_output(
  body: String,
) -> Result(MalformedTimestampHeaderDateTimeOutput, String) {
  case
    json.parse(
      body,
      decode_malformed_timestamp_header_date_time_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_header_date_time_body(
  _input: MalformedTimestampHeaderDateTimeInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_header_date_time_request(
  input: MalformedTimestampHeaderDateTimeInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampHeaderDateTime"
  let query = ""
  let headers = dict.new()
  let headers = case input.timestamp {
    option.Some(v) ->
      rest.maybe_set_header(headers, "timestamp", rest.timestamp_to_header(v))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_header_date_time_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampHeaderDateTimeOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_header_date_time_output("{}")
        _ -> decode_malformed_timestamp_header_date_time_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampHeaderDefaultOutput {
  MalformedTimestampHeaderDefaultOutput
}

pub fn encode_malformed_timestamp_header_default_output_struct(
  _v: MalformedTimestampHeaderDefaultOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_header_default_output_struct() -> decode.Decoder(
  MalformedTimestampHeaderDefaultOutput,
) {
  decode.success(MalformedTimestampHeaderDefaultOutput)
}

pub fn encode_malformed_timestamp_header_default_input(
  input: MalformedTimestampHeaderDefaultInput,
) -> String {
  json.to_string(encode_malformed_timestamp_header_default_input_struct(input))
}

pub fn decode_malformed_timestamp_header_default_input(
  body: String,
) -> Result(MalformedTimestampHeaderDefaultInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_header_default_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_header_default_output(
  body: String,
) -> Result(MalformedTimestampHeaderDefaultOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_header_default_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_header_default_body(
  _input: MalformedTimestampHeaderDefaultInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_header_default_request(
  input: MalformedTimestampHeaderDefaultInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampHeaderDefault"
  let query = ""
  let headers = dict.new()
  let headers = case input.timestamp {
    option.Some(v) ->
      rest.maybe_set_header(headers, "timestamp", rest.timestamp_to_header(v))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_header_default_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampHeaderDefaultOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_header_default_output("{}")
        _ -> decode_malformed_timestamp_header_default_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampHeaderEpochOutput {
  MalformedTimestampHeaderEpochOutput
}

pub fn encode_malformed_timestamp_header_epoch_output_struct(
  _v: MalformedTimestampHeaderEpochOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_header_epoch_output_struct() -> decode.Decoder(
  MalformedTimestampHeaderEpochOutput,
) {
  decode.success(MalformedTimestampHeaderEpochOutput)
}

pub fn encode_malformed_timestamp_header_epoch_input(
  input: MalformedTimestampHeaderEpochInput,
) -> String {
  json.to_string(encode_malformed_timestamp_header_epoch_input_struct(input))
}

pub fn decode_malformed_timestamp_header_epoch_input(
  body: String,
) -> Result(MalformedTimestampHeaderEpochInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_header_epoch_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_header_epoch_output(
  body: String,
) -> Result(MalformedTimestampHeaderEpochOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_header_epoch_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_header_epoch_body(
  _input: MalformedTimestampHeaderEpochInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_header_epoch_request(
  input: MalformedTimestampHeaderEpochInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampHeaderEpoch"
  let query = ""
  let headers = dict.new()
  let headers = case input.timestamp {
    option.Some(v) ->
      rest.maybe_set_header(headers, "timestamp", rest.timestamp_to_header(v))
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_header_epoch_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampHeaderEpochOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_header_epoch_output("{}")
        _ -> decode_malformed_timestamp_header_epoch_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampPathDefaultOutput {
  MalformedTimestampPathDefaultOutput
}

pub fn encode_malformed_timestamp_path_default_output_struct(
  _v: MalformedTimestampPathDefaultOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_path_default_output_struct() -> decode.Decoder(
  MalformedTimestampPathDefaultOutput,
) {
  decode.success(MalformedTimestampPathDefaultOutput)
}

pub fn encode_malformed_timestamp_path_default_input(
  input: MalformedTimestampPathDefaultInput,
) -> String {
  json.to_string(encode_malformed_timestamp_path_default_input_struct(input))
}

pub fn decode_malformed_timestamp_path_default_input(
  body: String,
) -> Result(MalformedTimestampPathDefaultInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_path_default_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_path_default_output(
  body: String,
) -> Result(MalformedTimestampPathDefaultOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_path_default_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_path_default_body(
  _input: MalformedTimestampPathDefaultInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_path_default_request(
  input: MalformedTimestampPathDefaultInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampPathDefault/{timestamp}"
  let path = case input.timestamp {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "timestamp",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_path_default_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampPathDefaultOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_path_default_output("{}")
        _ -> decode_malformed_timestamp_path_default_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampPathEpochOutput {
  MalformedTimestampPathEpochOutput
}

pub fn encode_malformed_timestamp_path_epoch_output_struct(
  _v: MalformedTimestampPathEpochOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_path_epoch_output_struct() -> decode.Decoder(
  MalformedTimestampPathEpochOutput,
) {
  decode.success(MalformedTimestampPathEpochOutput)
}

pub fn encode_malformed_timestamp_path_epoch_input(
  input: MalformedTimestampPathEpochInput,
) -> String {
  json.to_string(encode_malformed_timestamp_path_epoch_input_struct(input))
}

pub fn decode_malformed_timestamp_path_epoch_input(
  body: String,
) -> Result(MalformedTimestampPathEpochInput, String) {
  case json.parse(body, decode_malformed_timestamp_path_epoch_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_path_epoch_output(
  body: String,
) -> Result(MalformedTimestampPathEpochOutput, String) {
  case json.parse(body, decode_malformed_timestamp_path_epoch_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_path_epoch_body(
  _input: MalformedTimestampPathEpochInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_path_epoch_request(
  input: MalformedTimestampPathEpochInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampPathEpoch/{timestamp}"
  let path = case input.timestamp {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "timestamp",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_path_epoch_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampPathEpochOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_path_epoch_output("{}")
        _ -> decode_malformed_timestamp_path_epoch_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampPathHttpDateOutput {
  MalformedTimestampPathHttpDateOutput
}

pub fn encode_malformed_timestamp_path_http_date_output_struct(
  _v: MalformedTimestampPathHttpDateOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_path_http_date_output_struct() -> decode.Decoder(
  MalformedTimestampPathHttpDateOutput,
) {
  decode.success(MalformedTimestampPathHttpDateOutput)
}

pub fn encode_malformed_timestamp_path_http_date_input(
  input: MalformedTimestampPathHttpDateInput,
) -> String {
  json.to_string(encode_malformed_timestamp_path_http_date_input_struct(input))
}

pub fn decode_malformed_timestamp_path_http_date_input(
  body: String,
) -> Result(MalformedTimestampPathHttpDateInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_path_http_date_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_path_http_date_output(
  body: String,
) -> Result(MalformedTimestampPathHttpDateOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_path_http_date_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_path_http_date_body(
  _input: MalformedTimestampPathHttpDateInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_path_http_date_request(
  input: MalformedTimestampPathHttpDateInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampPathHttpDate/{timestamp}"
  let path = case input.timestamp {
    option.Some(v) ->
      rest.substitute_label(
        path,
        "timestamp",
        rest.timestamp_to_header(v),
        False,
      )
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_path_http_date_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampPathHttpDateOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_path_http_date_output("{}")
        _ -> decode_malformed_timestamp_path_http_date_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampQueryDefaultOutput {
  MalformedTimestampQueryDefaultOutput
}

pub fn encode_malformed_timestamp_query_default_output_struct(
  _v: MalformedTimestampQueryDefaultOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_query_default_output_struct() -> decode.Decoder(
  MalformedTimestampQueryDefaultOutput,
) {
  decode.success(MalformedTimestampQueryDefaultOutput)
}

pub fn encode_malformed_timestamp_query_default_input(
  input: MalformedTimestampQueryDefaultInput,
) -> String {
  json.to_string(encode_malformed_timestamp_query_default_input_struct(input))
}

pub fn decode_malformed_timestamp_query_default_input(
  body: String,
) -> Result(MalformedTimestampQueryDefaultInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_query_default_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_query_default_output(
  body: String,
) -> Result(MalformedTimestampQueryDefaultOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_query_default_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_query_default_body(
  _input: MalformedTimestampQueryDefaultInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_query_default_request(
  input: MalformedTimestampQueryDefaultInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampQueryDefault"
  let query = ""
  let query = case input.timestamp {
    option.Some(v) ->
      rest.add_query(query, "timestamp", rest.timestamp_to_header(v))
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_query_default_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampQueryDefaultOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_query_default_output("{}")
        _ -> decode_malformed_timestamp_query_default_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampQueryEpochOutput {
  MalformedTimestampQueryEpochOutput
}

pub fn encode_malformed_timestamp_query_epoch_output_struct(
  _v: MalformedTimestampQueryEpochOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_query_epoch_output_struct() -> decode.Decoder(
  MalformedTimestampQueryEpochOutput,
) {
  decode.success(MalformedTimestampQueryEpochOutput)
}

pub fn encode_malformed_timestamp_query_epoch_input(
  input: MalformedTimestampQueryEpochInput,
) -> String {
  json.to_string(encode_malformed_timestamp_query_epoch_input_struct(input))
}

pub fn decode_malformed_timestamp_query_epoch_input(
  body: String,
) -> Result(MalformedTimestampQueryEpochInput, String) {
  case json.parse(body, decode_malformed_timestamp_query_epoch_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_query_epoch_output(
  body: String,
) -> Result(MalformedTimestampQueryEpochOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_query_epoch_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_query_epoch_body(
  _input: MalformedTimestampQueryEpochInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_query_epoch_request(
  input: MalformedTimestampQueryEpochInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampQueryEpoch"
  let query = ""
  let query = case input.timestamp {
    option.Some(v) ->
      rest.add_query(query, "timestamp", rest.timestamp_to_header(v))
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_query_epoch_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampQueryEpochOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_query_epoch_output("{}")
        _ -> decode_malformed_timestamp_query_epoch_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedTimestampQueryHttpDateOutput {
  MalformedTimestampQueryHttpDateOutput
}

pub fn encode_malformed_timestamp_query_http_date_output_struct(
  _v: MalformedTimestampQueryHttpDateOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_timestamp_query_http_date_output_struct() -> decode.Decoder(
  MalformedTimestampQueryHttpDateOutput,
) {
  decode.success(MalformedTimestampQueryHttpDateOutput)
}

pub fn encode_malformed_timestamp_query_http_date_input(
  input: MalformedTimestampQueryHttpDateInput,
) -> String {
  json.to_string(encode_malformed_timestamp_query_http_date_input_struct(input))
}

pub fn decode_malformed_timestamp_query_http_date_input(
  body: String,
) -> Result(MalformedTimestampQueryHttpDateInput, String) {
  case
    json.parse(body, decode_malformed_timestamp_query_http_date_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_timestamp_query_http_date_output(
  body: String,
) -> Result(MalformedTimestampQueryHttpDateOutput, String) {
  case
    json.parse(body, decode_malformed_timestamp_query_http_date_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_timestamp_query_http_date_body(
  _input: MalformedTimestampQueryHttpDateInput,
) -> json.Json {
  json.object([])
}

pub fn build_malformed_timestamp_query_http_date_request(
  input: MalformedTimestampQueryHttpDateInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedTimestampQueryHttpDate"
  let query = ""
  let query = case input.timestamp {
    option.Some(v) ->
      rest.add_query(query, "timestamp", rest.timestamp_to_header(v))
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_timestamp_query_http_date_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedTimestampQueryHttpDateOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_timestamp_query_http_date_output("{}")
        _ -> decode_malformed_timestamp_query_http_date_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type MalformedUnionOutput {
  MalformedUnionOutput
}

pub fn encode_malformed_union_output_struct(
  _v: MalformedUnionOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_malformed_union_output_struct() -> decode.Decoder(
  MalformedUnionOutput,
) {
  decode.success(MalformedUnionOutput)
}

pub fn encode_malformed_union_input(input: MalformedUnionInput) -> String {
  json.to_string(encode_malformed_union_input_struct(input))
}

pub fn decode_malformed_union_input(
  body: String,
) -> Result(MalformedUnionInput, String) {
  case json.parse(body, decode_malformed_union_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_malformed_union_output(
  body: String,
) -> Result(MalformedUnionOutput, String) {
  case json.parse(body, decode_malformed_union_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_malformed_union_body(input: MalformedUnionInput) -> json.Json {
  let pairs = []
  let pairs = case input.union {
    option.Some(v) -> [#("union", encode_simple_union_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_malformed_union_request(
  input: MalformedUnionInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MalformedUnion"
  let query = ""
  let headers = dict.new()
  let body_json = encode_malformed_union_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_malformed_union_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MalformedUnionOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_malformed_union_output("{}")
        _ -> decode_malformed_union_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_media_type_header_input(input: MediaTypeHeaderInput) -> String {
  json.to_string(encode_media_type_header_input_struct(input))
}

pub fn decode_media_type_header_input(
  body: String,
) -> Result(MediaTypeHeaderInput, String) {
  case json.parse(body, decode_media_type_header_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_media_type_header_output(
  body: String,
) -> Result(MediaTypeHeaderOutput, String) {
  case json.parse(body, decode_media_type_header_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_media_type_header_body(
  _input: MediaTypeHeaderInput,
) -> json.Json {
  json.object([])
}

pub fn build_media_type_header_request(
  input: MediaTypeHeaderInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/MediaTypeHeader"
  let query = ""
  let headers = dict.new()
  let headers = case input.json {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Json", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_media_type_header_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(MediaTypeHeaderOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_media_type_header_output("{}")
        _ -> decode_media_type_header_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type NoInputAndNoOutputInput {
  NoInputAndNoOutputInput
}

pub fn encode_no_input_and_no_output_input_struct(
  _v: NoInputAndNoOutputInput,
) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_no_output_input_struct() -> decode.Decoder(
  NoInputAndNoOutputInput,
) {
  decode.success(NoInputAndNoOutputInput)
}

pub type NoInputAndNoOutputOutput {
  NoInputAndNoOutputOutput
}

pub fn encode_no_input_and_no_output_output_struct(
  _v: NoInputAndNoOutputOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_no_output_output_struct() -> decode.Decoder(
  NoInputAndNoOutputOutput,
) {
  decode.success(NoInputAndNoOutputOutput)
}

pub fn encode_no_input_and_no_output_input(
  input: NoInputAndNoOutputInput,
) -> String {
  json.to_string(encode_no_input_and_no_output_input_struct(input))
}

pub fn decode_no_input_and_no_output_input(
  body: String,
) -> Result(NoInputAndNoOutputInput, String) {
  case json.parse(body, decode_no_input_and_no_output_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_no_input_and_no_output_output(
  body: String,
) -> Result(NoInputAndNoOutputOutput, String) {
  case json.parse(body, decode_no_input_and_no_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_no_input_and_no_output_body(
  _input: NoInputAndNoOutputInput,
) -> json.Json {
  json.object([])
}

pub fn build_no_input_and_no_output_request(
  _input: NoInputAndNoOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NoInputAndNoOutput"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_no_input_and_no_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NoInputAndNoOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_no_input_and_no_output_output("{}")
        _ -> decode_no_input_and_no_output_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type NoInputAndOutputInput {
  NoInputAndOutputInput
}

pub fn encode_no_input_and_output_input_struct(
  _v: NoInputAndOutputInput,
) -> json.Json {
  json.object([])
}

pub fn decode_no_input_and_output_input_struct() -> decode.Decoder(
  NoInputAndOutputInput,
) {
  decode.success(NoInputAndOutputInput)
}

pub fn encode_no_input_and_output_input(
  input: NoInputAndOutputInput,
) -> String {
  json.to_string(encode_no_input_and_output_input_struct(input))
}

pub fn decode_no_input_and_output_input(
  body: String,
) -> Result(NoInputAndOutputInput, String) {
  case json.parse(body, decode_no_input_and_output_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_no_input_and_output_output(
  body: String,
) -> Result(NoInputAndOutputOutput, String) {
  case json.parse(body, decode_no_input_and_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_no_input_and_output_body(
  _input: NoInputAndOutputInput,
) -> json.Json {
  json.object([])
}

pub fn build_no_input_and_output_request(
  _input: NoInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/NoInputAndOutputOutput"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_no_input_and_output_output("{}")
        _ -> decode_no_input_and_output_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_null_and_empty_headers_client_input(
  input: NullAndEmptyHeadersIO,
) -> String {
  json.to_string(encode_null_and_empty_headers_io_struct(input))
}

pub fn decode_null_and_empty_headers_client_input(
  body: String,
) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_null_and_empty_headers_client_output(
  body: String,
) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_null_and_empty_headers_client_body(
  _input: NullAndEmptyHeadersIO,
) -> json.Json {
  json.object([])
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
    option.Some(v) -> rest.maybe_set_header(headers, "X-C", "")
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_null_and_empty_headers_client_output("{}")
        _ -> decode_null_and_empty_headers_client_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_null_and_empty_headers_server_input(
  input: NullAndEmptyHeadersIO,
) -> String {
  json.to_string(encode_null_and_empty_headers_io_struct(input))
}

pub fn decode_null_and_empty_headers_server_input(
  body: String,
) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_null_and_empty_headers_server_output(
  body: String,
) -> Result(NullAndEmptyHeadersIO, String) {
  case json.parse(body, decode_null_and_empty_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_null_and_empty_headers_server_body(
  _input: NullAndEmptyHeadersIO,
) -> json.Json {
  json.object([])
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
    option.Some(v) -> rest.maybe_set_header(headers, "X-C", "")
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_null_and_empty_headers_server_output("{}")
        _ -> decode_null_and_empty_headers_server_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OmitsNullSerializesEmptyStringOutput {
  OmitsNullSerializesEmptyStringOutput
}

pub fn encode_omits_null_serializes_empty_string_output_struct(
  _v: OmitsNullSerializesEmptyStringOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_omits_null_serializes_empty_string_output_struct() -> decode.Decoder(
  OmitsNullSerializesEmptyStringOutput,
) {
  decode.success(OmitsNullSerializesEmptyStringOutput)
}

pub fn encode_omits_null_serializes_empty_string_input(
  input: OmitsNullSerializesEmptyStringInput,
) -> String {
  json.to_string(encode_omits_null_serializes_empty_string_input_struct(input))
}

pub fn decode_omits_null_serializes_empty_string_input(
  body: String,
) -> Result(OmitsNullSerializesEmptyStringInput, String) {
  case
    json.parse(body, decode_omits_null_serializes_empty_string_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_omits_null_serializes_empty_string_output(
  body: String,
) -> Result(OmitsNullSerializesEmptyStringOutput, String) {
  case
    json.parse(body, decode_omits_null_serializes_empty_string_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_omits_null_serializes_empty_string_body(
  _input: OmitsNullSerializesEmptyStringInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_omits_null_serializes_empty_string_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OmitsNullSerializesEmptyStringOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_omits_null_serializes_empty_string_output("{}")
        _ -> decode_omits_null_serializes_empty_string_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OmitsSerializingEmptyListsOutput {
  OmitsSerializingEmptyListsOutput
}

pub fn encode_omits_serializing_empty_lists_output_struct(
  _v: OmitsSerializingEmptyListsOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_omits_serializing_empty_lists_output_struct() -> decode.Decoder(
  OmitsSerializingEmptyListsOutput,
) {
  decode.success(OmitsSerializingEmptyListsOutput)
}

pub fn encode_omits_serializing_empty_lists_input(
  input: OmitsSerializingEmptyListsInput,
) -> String {
  json.to_string(encode_omits_serializing_empty_lists_input_struct(input))
}

pub fn decode_omits_serializing_empty_lists_input(
  body: String,
) -> Result(OmitsSerializingEmptyListsInput, String) {
  case json.parse(body, decode_omits_serializing_empty_lists_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_omits_serializing_empty_lists_output(
  body: String,
) -> Result(OmitsSerializingEmptyListsOutput, String) {
  case json.parse(body, decode_omits_serializing_empty_lists_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_omits_serializing_empty_lists_body(
  _input: OmitsSerializingEmptyListsInput,
) -> json.Json {
  json.object([])
}

pub fn build_omits_serializing_empty_lists_request(
  input: OmitsSerializingEmptyListsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/OmitsSerializingEmptyLists"
  let query = ""
  let query = case input.query_boolean_list {
    option.Some(v) -> rest.add_query(query, "BooleanList", "")
    option.None -> query
  }
  let query = case input.query_double_list {
    option.Some(v) -> rest.add_query(query, "DoubleList", "")
    option.None -> query
  }
  let query = case input.query_enum_list {
    option.Some(v) -> rest.add_query(query, "EnumList", "")
    option.None -> query
  }
  let query = case input.query_integer_enum_list {
    option.Some(v) -> rest.add_query(query, "IntegerEnumList", "")
    option.None -> query
  }
  let query = case input.query_integer_list {
    option.Some(v) -> rest.add_query(query, "IntegerList", "")
    option.None -> query
  }
  let query = case input.query_string_list {
    option.Some(v) -> rest.add_query(query, "StringList", "")
    option.None -> query
  }
  let query = case input.query_timestamp_list {
    option.Some(v) -> rest.add_query(query, "TimestampList", "")
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_omits_serializing_empty_lists_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OmitsSerializingEmptyListsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_omits_serializing_empty_lists_output("{}")
        _ -> decode_omits_serializing_empty_lists_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_operation_with_defaults_input(
  input: OperationWithDefaultsInput,
) -> String {
  json.to_string(encode_operation_with_defaults_input_struct(input))
}

pub fn decode_operation_with_defaults_input(
  body: String,
) -> Result(OperationWithDefaultsInput, String) {
  case json.parse(body, decode_operation_with_defaults_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_defaults_output(
  body: String,
) -> Result(OperationWithDefaultsOutput, String) {
  case json.parse(body, decode_operation_with_defaults_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_operation_with_defaults_body(
  input: OperationWithDefaultsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.client_optional_defaults {
    option.Some(v) -> [
      #("clientOptionalDefaults", encode_client_optional_defaults_struct(v)),
      ..pairs
    ]
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

pub fn build_operation_with_defaults_request(
  input: OperationWithDefaultsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/OperationWithDefaults"
  let query = ""
  let headers = dict.new()
  let body_json = encode_operation_with_defaults_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_operation_with_defaults_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithDefaultsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_operation_with_defaults_output("{}")
        _ -> decode_operation_with_defaults_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_operation_with_nested_structure_input(
  input: OperationWithNestedStructureInput,
) -> String {
  json.to_string(encode_operation_with_nested_structure_input_struct(input))
}

pub fn decode_operation_with_nested_structure_input(
  body: String,
) -> Result(OperationWithNestedStructureInput, String) {
  case json.parse(body, decode_operation_with_nested_structure_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_operation_with_nested_structure_output(
  body: String,
) -> Result(OperationWithNestedStructureOutput, String) {
  case
    json.parse(body, decode_operation_with_nested_structure_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_operation_with_nested_structure_body(
  input: OperationWithNestedStructureInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.top_level {
    option.Some(v) -> [#("topLevel", encode_top_level_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_operation_with_nested_structure_request(
  input: OperationWithNestedStructureInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/OperationWithNestedStructure"
  let query = ""
  let headers = dict.new()
  let body_json = encode_operation_with_nested_structure_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_operation_with_nested_structure_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OperationWithNestedStructureOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_operation_with_nested_structure_output("{}")
        _ -> decode_operation_with_nested_structure_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OutputStreamInput {
  OutputStreamInput
}

pub fn encode_output_stream_input_struct(_v: OutputStreamInput) -> json.Json {
  json.object([])
}

pub fn decode_output_stream_input_struct() -> decode.Decoder(OutputStreamInput) {
  decode.success(OutputStreamInput)
}

pub fn encode_output_stream_input(input: OutputStreamInput) -> String {
  json.to_string(encode_output_stream_input_struct(input))
}

pub fn decode_output_stream_input(
  body: String,
) -> Result(OutputStreamInput, String) {
  case json.parse(body, decode_output_stream_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_output_stream_output(
  body: String,
) -> Result(OutputStreamOutput, String) {
  case json.parse(body, decode_output_stream_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_output_stream_body(_input: OutputStreamInput) -> json.Json {
  json.object([])
}

pub fn build_output_stream_request(
  _input: OutputStreamInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/OutputStream"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_output_stream_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OutputStreamOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_output_stream_output("{}")
        _ -> decode_output_stream_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type OutputStreamWithInitialResponseInput {
  OutputStreamWithInitialResponseInput
}

pub fn encode_output_stream_with_initial_response_input_struct(
  _v: OutputStreamWithInitialResponseInput,
) -> json.Json {
  json.object([])
}

pub fn decode_output_stream_with_initial_response_input_struct() -> decode.Decoder(
  OutputStreamWithInitialResponseInput,
) {
  decode.success(OutputStreamWithInitialResponseInput)
}

pub fn encode_output_stream_with_initial_response_input(
  input: OutputStreamWithInitialResponseInput,
) -> String {
  json.to_string(encode_output_stream_with_initial_response_input_struct(input))
}

pub fn decode_output_stream_with_initial_response_input(
  body: String,
) -> Result(OutputStreamWithInitialResponseInput, String) {
  case
    json.parse(body, decode_output_stream_with_initial_response_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_output_stream_with_initial_response_output(
  body: String,
) -> Result(OutputStreamWithInitialResponseOutput, String) {
  case
    json.parse(body, decode_output_stream_with_initial_response_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_output_stream_with_initial_response_body(
  _input: OutputStreamWithInitialResponseInput,
) -> json.Json {
  json.object([])
}

pub fn build_output_stream_with_initial_response_request(
  _input: OutputStreamWithInitialResponseInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/OutputStreamWithInitialResponse"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_output_stream_with_initial_response_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(OutputStreamWithInitialResponseOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_output_stream_with_initial_response_output("{}")
        _ -> decode_output_stream_with_initial_response_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_post_player_action_input(input: PostPlayerActionInput) -> String {
  json.to_string(encode_post_player_action_input_struct(input))
}

pub fn decode_post_player_action_input(
  body: String,
) -> Result(PostPlayerActionInput, String) {
  case json.parse(body, decode_post_player_action_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_post_player_action_output(
  body: String,
) -> Result(PostPlayerActionOutput, String) {
  case json.parse(body, decode_post_player_action_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_post_player_action_body(
  input: PostPlayerActionInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.action {
    option.Some(v) -> [#("action", encode_player_action_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_post_player_action_request(
  input: PostPlayerActionInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/PostPlayerAction"
  let query = ""
  let headers = dict.new()
  let body_json = encode_post_player_action_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_post_player_action_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PostPlayerActionOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_post_player_action_output("{}")
        _ -> decode_post_player_action_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_post_union_with_json_name_input(
  input: PostUnionWithJsonNameInput,
) -> String {
  json.to_string(encode_post_union_with_json_name_input_struct(input))
}

pub fn decode_post_union_with_json_name_input(
  body: String,
) -> Result(PostUnionWithJsonNameInput, String) {
  case json.parse(body, decode_post_union_with_json_name_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_post_union_with_json_name_output(
  body: String,
) -> Result(PostUnionWithJsonNameOutput, String) {
  case json.parse(body, decode_post_union_with_json_name_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_post_union_with_json_name_body(
  input: PostUnionWithJsonNameInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.value {
    option.Some(v) -> [
      #("value", encode_union_with_json_name_union(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_post_union_with_json_name_request(
  input: PostUnionWithJsonNameInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/PostUnionWithJsonName"
  let query = ""
  let headers = dict.new()
  let body_json = encode_post_union_with_json_name_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_post_union_with_json_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PostUnionWithJsonNameOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_post_union_with_json_name_output("{}")
        _ -> decode_post_union_with_json_name_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type PutWithContentEncodingOutput {
  PutWithContentEncodingOutput
}

pub fn encode_put_with_content_encoding_output_struct(
  _v: PutWithContentEncodingOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_put_with_content_encoding_output_struct() -> decode.Decoder(
  PutWithContentEncodingOutput,
) {
  decode.success(PutWithContentEncodingOutput)
}

pub fn encode_put_with_content_encoding_input(
  input: PutWithContentEncodingInput,
) -> String {
  json.to_string(encode_put_with_content_encoding_input_struct(input))
}

pub fn decode_put_with_content_encoding_input(
  body: String,
) -> Result(PutWithContentEncodingInput, String) {
  case json.parse(body, decode_put_with_content_encoding_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_with_content_encoding_output(
  body: String,
) -> Result(PutWithContentEncodingOutput, String) {
  case json.parse(body, decode_put_with_content_encoding_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_put_with_content_encoding_body(
  input: PutWithContentEncodingInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.data {
    option.Some(v) -> [#("data", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
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
  let body_json = encode_put_with_content_encoding_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_put_with_content_encoding_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutWithContentEncodingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_with_content_encoding_output("{}")
        _ -> decode_put_with_content_encoding_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type QueryIdempotencyTokenAutoFillOutput {
  QueryIdempotencyTokenAutoFillOutput
}

pub fn encode_query_idempotency_token_auto_fill_output_struct(
  _v: QueryIdempotencyTokenAutoFillOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_query_idempotency_token_auto_fill_output_struct() -> decode.Decoder(
  QueryIdempotencyTokenAutoFillOutput,
) {
  decode.success(QueryIdempotencyTokenAutoFillOutput)
}

pub fn encode_query_idempotency_token_auto_fill_input(
  input: QueryIdempotencyTokenAutoFillInput,
) -> String {
  json.to_string(encode_query_idempotency_token_auto_fill_input_struct(input))
}

pub fn decode_query_idempotency_token_auto_fill_input(
  body: String,
) -> Result(QueryIdempotencyTokenAutoFillInput, String) {
  case
    json.parse(body, decode_query_idempotency_token_auto_fill_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_idempotency_token_auto_fill_output(
  body: String,
) -> Result(QueryIdempotencyTokenAutoFillOutput, String) {
  case
    json.parse(body, decode_query_idempotency_token_auto_fill_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_query_idempotency_token_auto_fill_body(
  _input: QueryIdempotencyTokenAutoFillInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_query_idempotency_token_auto_fill_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(QueryIdempotencyTokenAutoFillOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_query_idempotency_token_auto_fill_output("{}")
        _ -> decode_query_idempotency_token_auto_fill_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type QueryParamsAsStringListMapOutput {
  QueryParamsAsStringListMapOutput
}

pub fn encode_query_params_as_string_list_map_output_struct(
  _v: QueryParamsAsStringListMapOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_query_params_as_string_list_map_output_struct() -> decode.Decoder(
  QueryParamsAsStringListMapOutput,
) {
  decode.success(QueryParamsAsStringListMapOutput)
}

pub fn encode_query_params_as_string_list_map_input(
  input: QueryParamsAsStringListMapInput,
) -> String {
  json.to_string(encode_query_params_as_string_list_map_input_struct(input))
}

pub fn decode_query_params_as_string_list_map_input(
  body: String,
) -> Result(QueryParamsAsStringListMapInput, String) {
  case json.parse(body, decode_query_params_as_string_list_map_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_params_as_string_list_map_output(
  body: String,
) -> Result(QueryParamsAsStringListMapOutput, String) {
  case
    json.parse(body, decode_query_params_as_string_list_map_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_query_params_as_string_list_map_body(
  _input: QueryParamsAsStringListMapInput,
) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_query_params_as_string_list_map_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(QueryParamsAsStringListMapOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_query_params_as_string_list_map_output("{}")
        _ -> decode_query_params_as_string_list_map_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type QueryPrecedenceOutput {
  QueryPrecedenceOutput
}

pub fn encode_query_precedence_output_struct(
  _v: QueryPrecedenceOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_query_precedence_output_struct() -> decode.Decoder(
  QueryPrecedenceOutput,
) {
  decode.success(QueryPrecedenceOutput)
}

pub fn encode_query_precedence_input(input: QueryPrecedenceInput) -> String {
  json.to_string(encode_query_precedence_input_struct(input))
}

pub fn decode_query_precedence_input(
  body: String,
) -> Result(QueryPrecedenceInput, String) {
  case json.parse(body, decode_query_precedence_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_precedence_output(
  body: String,
) -> Result(QueryPrecedenceOutput, String) {
  case json.parse(body, decode_query_precedence_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_query_precedence_body(_input: QueryPrecedenceInput) -> json.Json {
  json.object([])
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_query_precedence_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(QueryPrecedenceOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_query_precedence_output("{}")
        _ -> decode_query_precedence_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_recursive_shapes_input(
  input: RecursiveShapesInputOutput,
) -> String {
  json.to_string(encode_recursive_shapes_input_output_struct(input))
}

pub fn decode_recursive_shapes_input(
  body: String,
) -> Result(RecursiveShapesInputOutput, String) {
  case json.parse(body, decode_recursive_shapes_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_recursive_shapes_output(
  body: String,
) -> Result(RecursiveShapesInputOutput, String) {
  case json.parse(body, decode_recursive_shapes_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_recursive_shapes_body(
  input: RecursiveShapesInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.nested {
    option.Some(v) -> [
      #("nested", encode_recursive_shapes_input_output_nested1_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_recursive_shapes_request(
  input: RecursiveShapesInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/RecursiveShapes"
  let query = ""
  let headers = dict.new()
  let body_json = encode_recursive_shapes_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_recursive_shapes_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(RecursiveShapesInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_recursive_shapes_output("{}")
        _ -> decode_recursive_shapes_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_response_code_http_fallback_input(
  input: ResponseCodeHttpFallbackInputOutput,
) -> String {
  json.to_string(encode_response_code_http_fallback_input_output_struct(input))
}

pub fn decode_response_code_http_fallback_input(
  body: String,
) -> Result(ResponseCodeHttpFallbackInputOutput, String) {
  case
    json.parse(body, decode_response_code_http_fallback_input_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_response_code_http_fallback_output(
  body: String,
) -> Result(ResponseCodeHttpFallbackInputOutput, String) {
  case
    json.parse(body, decode_response_code_http_fallback_input_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_response_code_http_fallback_body(
  _input: ResponseCodeHttpFallbackInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_response_code_http_fallback_request(
  input: ResponseCodeHttpFallbackInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/responseCodeHttpFallback"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_response_code_http_fallback_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ResponseCodeHttpFallbackInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_response_code_http_fallback_output("{}")
        _ -> decode_response_code_http_fallback_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type ResponseCodeRequiredInput {
  ResponseCodeRequiredInput
}

pub fn encode_response_code_required_input_struct(
  _v: ResponseCodeRequiredInput,
) -> json.Json {
  json.object([])
}

pub fn decode_response_code_required_input_struct() -> decode.Decoder(
  ResponseCodeRequiredInput,
) {
  decode.success(ResponseCodeRequiredInput)
}

pub fn encode_response_code_required_input(
  input: ResponseCodeRequiredInput,
) -> String {
  json.to_string(encode_response_code_required_input_struct(input))
}

pub fn decode_response_code_required_input(
  body: String,
) -> Result(ResponseCodeRequiredInput, String) {
  case json.parse(body, decode_response_code_required_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_response_code_required_output(
  body: String,
) -> Result(ResponseCodeRequiredOutput, String) {
  case json.parse(body, decode_response_code_required_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_response_code_required_body(
  _input: ResponseCodeRequiredInput,
) -> json.Json {
  json.object([])
}

pub fn build_response_code_required_request(
  _input: ResponseCodeRequiredInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/responseCodeRequired"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_response_code_required_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ResponseCodeRequiredOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_response_code_required_output("{}")
        _ -> decode_response_code_required_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_simple_scalar_properties_input(
  input: SimpleScalarPropertiesInputOutput,
) -> String {
  json.to_string(encode_simple_scalar_properties_input_output_struct(input))
}

pub fn decode_simple_scalar_properties_input(
  body: String,
) -> Result(SimpleScalarPropertiesInputOutput, String) {
  case json.parse(body, decode_simple_scalar_properties_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_simple_scalar_properties_output(
  body: String,
) -> Result(SimpleScalarPropertiesInputOutput, String) {
  case json.parse(body, decode_simple_scalar_properties_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_simple_scalar_properties_body(
  input: SimpleScalarPropertiesInputOutput,
) -> json.Json {
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

pub fn build_simple_scalar_properties_request(
  input: SimpleScalarPropertiesInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/SimpleScalarProperties"
  let query = ""
  let headers = dict.new()
  let headers = case input.foo {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Foo", v)
    option.None -> headers
  }
  let body_json = encode_simple_scalar_properties_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_simple_scalar_properties_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SimpleScalarPropertiesInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_simple_scalar_properties_output("{}")
        _ -> decode_simple_scalar_properties_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_sparse_json_lists_input(
  input: SparseJsonListsInputOutput,
) -> String {
  json.to_string(encode_sparse_json_lists_input_output_struct(input))
}

pub fn decode_sparse_json_lists_input(
  body: String,
) -> Result(SparseJsonListsInputOutput, String) {
  case json.parse(body, decode_sparse_json_lists_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_sparse_json_lists_output(
  body: String,
) -> Result(SparseJsonListsInputOutput, String) {
  case json.parse(body, decode_sparse_json_lists_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_sparse_json_lists_body(
  input: SparseJsonListsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.sparse_short_list {
    option.Some(v) -> [
      #("sparseShortList", fn(xs) { json.array(xs, json.int) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_string_list {
    option.Some(v) -> [
      #("sparseStringList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_sparse_json_lists_request(
  input: SparseJsonListsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/SparseJsonLists"
  let query = ""
  let headers = dict.new()
  let body_json = encode_sparse_json_lists_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_sparse_json_lists_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SparseJsonListsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_sparse_json_lists_output("{}")
        _ -> decode_sparse_json_lists_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_sparse_json_maps_input(
  input: SparseJsonMapsInputOutput,
) -> String {
  json.to_string(encode_sparse_json_maps_input_output_struct(input))
}

pub fn decode_sparse_json_maps_input(
  body: String,
) -> Result(SparseJsonMapsInputOutput, String) {
  case json.parse(body, decode_sparse_json_maps_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_sparse_json_maps_output(
  body: String,
) -> Result(SparseJsonMapsInputOutput, String) {
  case json.parse(body, decode_sparse_json_maps_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_sparse_json_maps_body(
  input: SparseJsonMapsInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.sparse_boolean_map {
    option.Some(v) -> [
      #(
        "sparseBooleanMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.bool(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_number_map {
    option.Some(v) -> [
      #(
        "sparseNumberMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.int(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_set_map {
    option.Some(v) -> [
      #(
        "sparseSetMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, fn(xs) { json.array(xs, json.string) }(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_string_map {
    option.Some(v) -> [
      #(
        "sparseStringMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sparse_struct_map {
    option.Some(v) -> [
      #(
        "sparseStructMap",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_greeting_struct_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_sparse_json_maps_request(
  input: SparseJsonMapsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/SparseJsonMaps"
  let query = ""
  let headers = dict.new()
  let body_json = encode_sparse_json_maps_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_sparse_json_maps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SparseJsonMapsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_sparse_json_maps_output("{}")
        _ -> decode_sparse_json_maps_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_streaming_traits_input(
  input: StreamingTraitsInputOutput,
) -> String {
  json.to_string(encode_streaming_traits_input_output_struct(input))
}

pub fn decode_streaming_traits_input(
  body: String,
) -> Result(StreamingTraitsInputOutput, String) {
  case json.parse(body, decode_streaming_traits_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_streaming_traits_output(
  body: String,
) -> Result(StreamingTraitsInputOutput, String) {
  case json.parse(body, decode_streaming_traits_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_streaming_traits_body(
  _input: StreamingTraitsInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_streaming_traits_request(
  input: StreamingTraitsInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/StreamingTraits"
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_streaming_traits_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(StreamingTraitsInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_streaming_traits_output("{}")
        _ -> decode_streaming_traits_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type StreamingTraitsRequireLengthOutput {
  StreamingTraitsRequireLengthOutput
}

pub fn encode_streaming_traits_require_length_output_struct(
  _v: StreamingTraitsRequireLengthOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_streaming_traits_require_length_output_struct() -> decode.Decoder(
  StreamingTraitsRequireLengthOutput,
) {
  decode.success(StreamingTraitsRequireLengthOutput)
}

pub fn encode_streaming_traits_require_length_input(
  input: StreamingTraitsRequireLengthInput,
) -> String {
  json.to_string(encode_streaming_traits_require_length_input_struct(input))
}

pub fn decode_streaming_traits_require_length_input(
  body: String,
) -> Result(StreamingTraitsRequireLengthInput, String) {
  case json.parse(body, decode_streaming_traits_require_length_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_streaming_traits_require_length_output(
  body: String,
) -> Result(StreamingTraitsRequireLengthOutput, String) {
  case
    json.parse(body, decode_streaming_traits_require_length_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_streaming_traits_require_length_body(
  _input: StreamingTraitsRequireLengthInput,
) -> json.Json {
  json.object([])
}

pub fn build_streaming_traits_require_length_request(
  input: StreamingTraitsRequireLengthInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/StreamingTraitsRequireLength"
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_streaming_traits_require_length_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(StreamingTraitsRequireLengthOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_streaming_traits_require_length_output("{}")
        _ -> decode_streaming_traits_require_length_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_streaming_traits_with_media_type_input(
  input: StreamingTraitsWithMediaTypeInputOutput,
) -> String {
  json.to_string(encode_streaming_traits_with_media_type_input_output_struct(
    input,
  ))
}

pub fn decode_streaming_traits_with_media_type_input(
  body: String,
) -> Result(StreamingTraitsWithMediaTypeInputOutput, String) {
  case
    json.parse(
      body,
      decode_streaming_traits_with_media_type_input_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_streaming_traits_with_media_type_output(
  body: String,
) -> Result(StreamingTraitsWithMediaTypeInputOutput, String) {
  case
    json.parse(
      body,
      decode_streaming_traits_with_media_type_input_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_streaming_traits_with_media_type_body(
  _input: StreamingTraitsWithMediaTypeInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_streaming_traits_with_media_type_request(
  input: StreamingTraitsWithMediaTypeInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/StreamingTraitsWithMediaType"
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
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_streaming_traits_with_media_type_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(StreamingTraitsWithMediaTypeInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_streaming_traits_with_media_type_output("{}")
        _ -> decode_streaming_traits_with_media_type_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_test_body_structure_input(
  input: TestBodyStructureInputOutput,
) -> String {
  json.to_string(encode_test_body_structure_input_output_struct(input))
}

pub fn decode_test_body_structure_input(
  body: String,
) -> Result(TestBodyStructureInputOutput, String) {
  case json.parse(body, decode_test_body_structure_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_test_body_structure_output(
  body: String,
) -> Result(TestBodyStructureInputOutput, String) {
  case json.parse(body, decode_test_body_structure_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_test_body_structure_body(
  input: TestBodyStructureInputOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.test_config {
    option.Some(v) -> [#("testConfig", encode_test_config_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_test_body_structure_request(
  input: TestBodyStructureInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/body"
  let query = ""
  let headers = dict.new()
  let headers = case input.test_id {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-test-id", v)
    option.None -> headers
  }
  let body_json = encode_test_body_structure_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_test_body_structure_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TestBodyStructureInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_test_body_structure_output("{}")
        _ -> decode_test_body_structure_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type TestGetNoInputNoPayloadInput {
  TestGetNoInputNoPayloadInput
}

pub fn encode_test_get_no_input_no_payload_input_struct(
  _v: TestGetNoInputNoPayloadInput,
) -> json.Json {
  json.object([])
}

pub fn decode_test_get_no_input_no_payload_input_struct() -> decode.Decoder(
  TestGetNoInputNoPayloadInput,
) {
  decode.success(TestGetNoInputNoPayloadInput)
}

pub fn encode_test_get_no_input_no_payload_input(
  input: TestGetNoInputNoPayloadInput,
) -> String {
  json.to_string(encode_test_get_no_input_no_payload_input_struct(input))
}

pub fn decode_test_get_no_input_no_payload_input(
  body: String,
) -> Result(TestGetNoInputNoPayloadInput, String) {
  case json.parse(body, decode_test_get_no_input_no_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_test_get_no_input_no_payload_output(
  body: String,
) -> Result(TestNoPayloadInputOutput, String) {
  case json.parse(body, decode_test_no_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_test_get_no_input_no_payload_body(
  _input: TestGetNoInputNoPayloadInput,
) -> json.Json {
  json.object([])
}

pub fn build_test_get_no_input_no_payload_request(
  _input: TestGetNoInputNoPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/no_input_no_payload"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_test_get_no_input_no_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TestNoPayloadInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_test_get_no_input_no_payload_output("{}")
        _ -> decode_test_get_no_input_no_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_test_get_no_payload_input(
  input: TestNoPayloadInputOutput,
) -> String {
  json.to_string(encode_test_no_payload_input_output_struct(input))
}

pub fn decode_test_get_no_payload_input(
  body: String,
) -> Result(TestNoPayloadInputOutput, String) {
  case json.parse(body, decode_test_no_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_test_get_no_payload_output(
  body: String,
) -> Result(TestNoPayloadInputOutput, String) {
  case json.parse(body, decode_test_no_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_test_get_no_payload_body(
  _input: TestNoPayloadInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_test_get_no_payload_request(
  input: TestNoPayloadInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/no_payload"
  let query = ""
  let headers = dict.new()
  let headers = case input.test_id {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Amz-Test-Id", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_test_get_no_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TestNoPayloadInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_test_get_no_payload_output("{}")
        _ -> decode_test_get_no_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_test_payload_blob_input(
  input: TestPayloadBlobInputOutput,
) -> String {
  json.to_string(encode_test_payload_blob_input_output_struct(input))
}

pub fn decode_test_payload_blob_input(
  body: String,
) -> Result(TestPayloadBlobInputOutput, String) {
  case json.parse(body, decode_test_payload_blob_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_test_payload_blob_output(
  body: String,
) -> Result(TestPayloadBlobInputOutput, String) {
  case json.parse(body, decode_test_payload_blob_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_test_payload_blob_body(
  _input: TestPayloadBlobInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_test_payload_blob_request(
  input: TestPayloadBlobInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/blob_payload"
  let query = ""
  let headers = dict.new()
  let headers = case input.content_type {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Type", v)
    option.None -> headers
  }
  let body = case input.data {
    option.Some(v) -> v
    option.None -> <<>>
  }
  let content_type = "application/octet-stream"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_test_payload_blob_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TestPayloadBlobInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_test_payload_blob_output("{}")
        _ -> decode_test_payload_blob_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_test_payload_structure_input(
  input: TestPayloadStructureInputOutput,
) -> String {
  json.to_string(encode_test_payload_structure_input_output_struct(input))
}

pub fn decode_test_payload_structure_input(
  body: String,
) -> Result(TestPayloadStructureInputOutput, String) {
  case json.parse(body, decode_test_payload_structure_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_test_payload_structure_output(
  body: String,
) -> Result(TestPayloadStructureInputOutput, String) {
  case json.parse(body, decode_test_payload_structure_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_test_payload_structure_body(
  _input: TestPayloadStructureInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_test_payload_structure_request(
  input: TestPayloadStructureInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/payload"
  let query = ""
  let headers = dict.new()
  let headers = case input.test_id {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-test-id", v)
    option.None -> headers
  }
  let body = case input.payload_config {
    option.Some(v) ->
      bit_array.from_string(json.to_string(encode_payload_config_struct(v)))
    option.None -> <<>>
  }
  let content_type = "application/json"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_test_payload_structure_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TestPayloadStructureInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_test_payload_structure_output("{}")
        _ -> decode_test_payload_structure_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type TestPostNoInputNoPayloadInput {
  TestPostNoInputNoPayloadInput
}

pub fn encode_test_post_no_input_no_payload_input_struct(
  _v: TestPostNoInputNoPayloadInput,
) -> json.Json {
  json.object([])
}

pub fn decode_test_post_no_input_no_payload_input_struct() -> decode.Decoder(
  TestPostNoInputNoPayloadInput,
) {
  decode.success(TestPostNoInputNoPayloadInput)
}

pub fn encode_test_post_no_input_no_payload_input(
  input: TestPostNoInputNoPayloadInput,
) -> String {
  json.to_string(encode_test_post_no_input_no_payload_input_struct(input))
}

pub fn decode_test_post_no_input_no_payload_input(
  body: String,
) -> Result(TestPostNoInputNoPayloadInput, String) {
  case json.parse(body, decode_test_post_no_input_no_payload_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_test_post_no_input_no_payload_output(
  body: String,
) -> Result(TestNoPayloadInputOutput, String) {
  case json.parse(body, decode_test_no_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_test_post_no_input_no_payload_body(
  _input: TestPostNoInputNoPayloadInput,
) -> json.Json {
  json.object([])
}

pub fn build_test_post_no_input_no_payload_request(
  _input: TestPostNoInputNoPayloadInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/no_input_no_payload"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_test_post_no_input_no_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TestNoPayloadInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_test_post_no_input_no_payload_output("{}")
        _ -> decode_test_post_no_input_no_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_test_post_no_payload_input(
  input: TestNoPayloadInputOutput,
) -> String {
  json.to_string(encode_test_no_payload_input_output_struct(input))
}

pub fn decode_test_post_no_payload_input(
  body: String,
) -> Result(TestNoPayloadInputOutput, String) {
  case json.parse(body, decode_test_no_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_test_post_no_payload_output(
  body: String,
) -> Result(TestNoPayloadInputOutput, String) {
  case json.parse(body, decode_test_no_payload_input_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_test_post_no_payload_body(
  _input: TestNoPayloadInputOutput,
) -> json.Json {
  json.object([])
}

pub fn build_test_post_no_payload_request(
  input: TestNoPayloadInputOutput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/no_payload"
  let query = ""
  let headers = dict.new()
  let headers = case input.test_id {
    option.Some(v) -> rest.maybe_set_header(headers, "X-Amz-Test-Id", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_test_post_no_payload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TestNoPayloadInputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_test_post_no_payload_output("{}")
        _ -> decode_test_post_no_payload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_timestamp_format_headers_input(
  input: TimestampFormatHeadersIO,
) -> String {
  json.to_string(encode_timestamp_format_headers_io_struct(input))
}

pub fn decode_timestamp_format_headers_input(
  body: String,
) -> Result(TimestampFormatHeadersIO, String) {
  case json.parse(body, decode_timestamp_format_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_timestamp_format_headers_output(
  body: String,
) -> Result(TimestampFormatHeadersIO, String) {
  case json.parse(body, decode_timestamp_format_headers_io_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_timestamp_format_headers_body(
  _input: TimestampFormatHeadersIO,
) -> json.Json {
  json.object([])
}

pub fn build_timestamp_format_headers_request(
  input: TimestampFormatHeadersIO,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/TimestampFormatHeaders"
  let query = ""
  let headers = dict.new()
  let headers = case input.default_format {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-defaultFormat",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.member_date_time {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-memberDateTime",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.member_epoch_seconds {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-memberEpochSeconds",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.member_http_date {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-memberHttpDate",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.target_date_time {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-targetDateTime",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.target_epoch_seconds {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-targetEpochSeconds",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.target_http_date {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "X-targetHttpDate",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
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
    Ok(text) ->
      case text {
        "" -> decode_timestamp_format_headers_output("{}")
        _ -> decode_timestamp_format_headers_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type UnitInputAndOutputInput {
  UnitInputAndOutputInput
}

pub fn encode_unit_input_and_output_input_struct(
  _v: UnitInputAndOutputInput,
) -> json.Json {
  json.object([])
}

pub fn decode_unit_input_and_output_input_struct() -> decode.Decoder(
  UnitInputAndOutputInput,
) {
  decode.success(UnitInputAndOutputInput)
}

pub type UnitInputAndOutputOutput {
  UnitInputAndOutputOutput
}

pub fn encode_unit_input_and_output_output_struct(
  _v: UnitInputAndOutputOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_unit_input_and_output_output_struct() -> decode.Decoder(
  UnitInputAndOutputOutput,
) {
  decode.success(UnitInputAndOutputOutput)
}

pub fn encode_unit_input_and_output_input(
  input: UnitInputAndOutputInput,
) -> String {
  json.to_string(encode_unit_input_and_output_input_struct(input))
}

pub fn decode_unit_input_and_output_input(
  body: String,
) -> Result(UnitInputAndOutputInput, String) {
  case json.parse(body, decode_unit_input_and_output_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_unit_input_and_output_output(
  body: String,
) -> Result(UnitInputAndOutputOutput, String) {
  case json.parse(body, decode_unit_input_and_output_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_unit_input_and_output_body(
  _input: UnitInputAndOutputInput,
) -> json.Json {
  json.object([])
}

pub fn build_unit_input_and_output_request(
  _input: UnitInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/UnitInputAndOutput"
  let query = ""
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_unit_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UnitInputAndOutputOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_unit_input_and_output_output("{}")
        _ -> decode_unit_input_and_output_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}
