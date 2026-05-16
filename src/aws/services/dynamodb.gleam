//// Generated from com.amazonaws.dynamodb#DynamoDB_20120810 (awsJson1_0).
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
    "dynamodb",
    "dynamodb",
  ))
}

/// Override the endpoint URL (LocalStack, FIPS endpoints, custom DNS).
pub fn with_endpoint_url(client: Client, url: String) -> Client {
  Client(config: awsjson_client.with_endpoint_url(client.config, url))
}

/// Swap the HTTP transport — useful for canned-response test doubles.
pub fn with_http_send(client: Client, send: http_send.Send) -> Client {
  Client(config: awsjson_client.with_http_send(client.config, send))
}

pub type BatchExecuteStatementInput {
  BatchExecuteStatementInput(
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    statements: option.Option(List(BatchStatementRequest)),
  )
}

pub fn encode_batch_execute_statement_input_struct(
  input: BatchExecuteStatementInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.statements {
    option.Some(v) -> [
      #(
        "Statements",
        fn(xs) { json.array(xs, encode_batch_statement_request_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_batch_execute_statement_input_struct() -> decode.Decoder(
  BatchExecuteStatementInput,
) {
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use statements <- decode.optional_field(
    "Statements",
    option.None,
    decode.optional(decode.list(decode_batch_statement_request_struct())),
  )
  decode.success(BatchExecuteStatementInput(
    return_consumed_capacity: return_consumed_capacity,
    statements: statements,
  ))
}

pub type ReturnConsumedCapacity {
  ReturnConsumedCapacityIndexes
  ReturnConsumedCapacityNone
  ReturnConsumedCapacityTotal
}

pub fn encode_return_consumed_capacity_enum(
  v: ReturnConsumedCapacity,
) -> json.Json {
  case v {
    ReturnConsumedCapacityIndexes -> json.string("INDEXES")
    ReturnConsumedCapacityNone -> json.string("NONE")
    ReturnConsumedCapacityTotal -> json.string("TOTAL")
  }
}

pub fn decode_return_consumed_capacity_enum() -> decode.Decoder(
  ReturnConsumedCapacity,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "INDEXES" -> decode.success(ReturnConsumedCapacityIndexes)
      "NONE" -> decode.success(ReturnConsumedCapacityNone)
      "TOTAL" -> decode.success(ReturnConsumedCapacityTotal)
      _ -> decode.failure(ReturnConsumedCapacityIndexes, "unknown enum value")
    }
  })
}

pub type BatchStatementRequest {
  BatchStatementRequest(
    consistent_read: option.Option(Bool),
    parameters: option.Option(List(AttributeValue)),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    statement: option.Option(String),
  )
}

pub fn encode_batch_statement_request_struct(
  input: BatchStatementRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.consistent_read {
    option.Some(v) -> [#("ConsistentRead", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.parameters {
    option.Some(v) -> [
      #(
        "Parameters",
        fn(xs) { json.array(xs, encode_attribute_value_union) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.statement {
    option.Some(v) -> [#("Statement", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_batch_statement_request_struct() -> decode.Decoder(
  BatchStatementRequest,
) {
  use consistent_read <- decode.optional_field(
    "ConsistentRead",
    option.None,
    decode.optional(decode.bool),
  )
  use parameters <- decode.optional_field(
    "Parameters",
    option.None,
    decode.optional(decode.list(decode_attribute_value_union())),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use statement <- decode.optional_field(
    "Statement",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(BatchStatementRequest(
    consistent_read: consistent_read,
    parameters: parameters,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    statement: statement,
  ))
}

pub type AttributeValue {
  AttributeValueB(BitArray)
  AttributeValueBOOL(Bool)
  AttributeValueBS(List(BitArray))
  AttributeValueL(List(AttributeValue))
  AttributeValueM(dict.Dict(String, AttributeValue))
  AttributeValueN(String)
  AttributeValueNS(List(String))
  AttributeValueNULL(Bool)
  AttributeValueS(String)
  AttributeValueSS(List(String))
}

pub fn encode_attribute_value_union(v: AttributeValue) -> json.Json {
  case v {
    AttributeValueB(x) ->
      json.object([
        #("B", fn(b) { json.string(bit_array.base64_encode(b, True)) }(x)),
      ])
    AttributeValueBOOL(x) -> json.object([#("BOOL", json.bool(x))])
    AttributeValueBS(x) ->
      json.object([
        #(
          "BS",
          fn(xs) {
            json.array(xs, fn(b) {
              json.string(bit_array.base64_encode(b, True))
            })
          }(x),
        ),
      ])
    AttributeValueL(x) ->
      json.object([
        #("L", fn(xs) { json.array(xs, encode_attribute_value_union) }(x)),
      ])
    AttributeValueM(x) ->
      json.object([
        #(
          "M",
          fn(d) {
            json.object(
              dict.to_list(d)
              |> list.map(fn(pair) {
                #(pair.0, encode_attribute_value_union(pair.1))
              }),
            )
          }(x),
        ),
      ])
    AttributeValueN(x) -> json.object([#("N", json.string(x))])
    AttributeValueNS(x) ->
      json.object([#("NS", fn(xs) { json.array(xs, json.string) }(x))])
    AttributeValueNULL(x) -> json.object([#("NULL", json.bool(x))])
    AttributeValueS(x) -> json.object([#("S", json.string(x))])
    AttributeValueSS(x) ->
      json.object([#("SS", fn(xs) { json.array(xs, json.string) }(x))])
  }
}

pub fn decode_attribute_value_union() -> decode.Decoder(AttributeValue) {
  decode.one_of(
    decode.field(
      "B",
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
      fn(x) { decode.success(AttributeValueB(x)) },
    ),
    [
      decode.field("BOOL", decode.bool, fn(x) {
        decode.success(AttributeValueBOOL(x))
      }),
      decode.field(
        "BS",
        decode.list(
          decode.then(decode.string, fn(s) {
            decode.success(bit_array.from_string(s))
          }),
        ),
        fn(x) { decode.success(AttributeValueBS(x)) },
      ),
      decode.field("L", decode.list(decode_attribute_value_union()), fn(x) {
        decode.success(AttributeValueL(x))
      }),
      decode.field(
        "M",
        decode.dict(decode.string, decode_attribute_value_union()),
        fn(x) { decode.success(AttributeValueM(x)) },
      ),
      decode.field("N", decode.string, fn(x) {
        decode.success(AttributeValueN(x))
      }),
      decode.field("NS", decode.list(decode.string), fn(x) {
        decode.success(AttributeValueNS(x))
      }),
      decode.field("NULL", decode.bool, fn(x) {
        decode.success(AttributeValueNULL(x))
      }),
      decode.field("S", decode.string, fn(x) {
        decode.success(AttributeValueS(x))
      }),
      decode.field("SS", decode.list(decode.string), fn(x) {
        decode.success(AttributeValueSS(x))
      }),
    ],
  )
}

pub type ReturnValuesOnConditionCheckFailure {
  ReturnValuesOnConditionCheckFailureAllOld
  ReturnValuesOnConditionCheckFailureNone
}

pub fn encode_return_values_on_condition_check_failure_enum(
  v: ReturnValuesOnConditionCheckFailure,
) -> json.Json {
  case v {
    ReturnValuesOnConditionCheckFailureAllOld -> json.string("ALL_OLD")
    ReturnValuesOnConditionCheckFailureNone -> json.string("NONE")
  }
}

pub fn decode_return_values_on_condition_check_failure_enum() -> decode.Decoder(
  ReturnValuesOnConditionCheckFailure,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "ALL_OLD" -> decode.success(ReturnValuesOnConditionCheckFailureAllOld)
      "NONE" -> decode.success(ReturnValuesOnConditionCheckFailureNone)
      _ ->
        decode.failure(
          ReturnValuesOnConditionCheckFailureAllOld,
          "unknown enum value",
        )
    }
  })
}

pub type BatchExecuteStatementOutput {
  BatchExecuteStatementOutput(
    consumed_capacity: option.Option(List(ConsumedCapacity)),
    responses: option.Option(List(BatchStatementResponse)),
  )
}

pub fn encode_batch_execute_statement_output_struct(
  input: BatchExecuteStatementOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #(
        "ConsumedCapacity",
        fn(xs) { json.array(xs, encode_consumed_capacity_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.responses {
    option.Some(v) -> [
      #(
        "Responses",
        fn(xs) { json.array(xs, encode_batch_statement_response_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_batch_execute_statement_output_struct() -> decode.Decoder(
  BatchExecuteStatementOutput,
) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode.list(decode_consumed_capacity_struct())),
  )
  use responses <- decode.optional_field(
    "Responses",
    option.None,
    decode.optional(decode.list(decode_batch_statement_response_struct())),
  )
  decode.success(BatchExecuteStatementOutput(
    consumed_capacity: consumed_capacity,
    responses: responses,
  ))
}

pub type ConsumedCapacity {
  ConsumedCapacity(
    capacity_units: option.Option(json_float.SmithyFloat),
    global_secondary_indexes: option.Option(dict.Dict(String, Capacity)),
    local_secondary_indexes: option.Option(dict.Dict(String, Capacity)),
    read_capacity_units: option.Option(json_float.SmithyFloat),
    table: option.Option(Capacity),
    table_name: option.Option(String),
    write_capacity_units: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_consumed_capacity_struct(input: ConsumedCapacity) -> json.Json {
  let pairs = []
  let pairs = case input.capacity_units {
    option.Some(v) -> [#("CapacityUnits", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_capacity_struct(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.local_secondary_indexes {
    option.Some(v) -> [
      #(
        "LocalSecondaryIndexes",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_capacity_struct(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.read_capacity_units {
    option.Some(v) -> [#("ReadCapacityUnits", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table {
    option.Some(v) -> [#("Table", encode_capacity_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.write_capacity_units {
    option.Some(v) -> [#("WriteCapacityUnits", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_consumed_capacity_struct() -> decode.Decoder(ConsumedCapacity) {
  use capacity_units <- decode.optional_field(
    "CapacityUnits",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(decode.dict(decode.string, decode_capacity_struct())),
  )
  use local_secondary_indexes <- decode.optional_field(
    "LocalSecondaryIndexes",
    option.None,
    decode.optional(decode.dict(decode.string, decode_capacity_struct())),
  )
  use read_capacity_units <- decode.optional_field(
    "ReadCapacityUnits",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use table <- decode.optional_field(
    "Table",
    option.None,
    decode.optional(decode_capacity_struct()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use write_capacity_units <- decode.optional_field(
    "WriteCapacityUnits",
    option.None,
    decode.optional(json_float.decoder()),
  )
  decode.success(ConsumedCapacity(
    capacity_units: capacity_units,
    global_secondary_indexes: global_secondary_indexes,
    local_secondary_indexes: local_secondary_indexes,
    read_capacity_units: read_capacity_units,
    table: table,
    table_name: table_name,
    write_capacity_units: write_capacity_units,
  ))
}

pub type Capacity {
  Capacity(
    capacity_units: option.Option(json_float.SmithyFloat),
    read_capacity_units: option.Option(json_float.SmithyFloat),
    write_capacity_units: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_capacity_struct(input: Capacity) -> json.Json {
  let pairs = []
  let pairs = case input.capacity_units {
    option.Some(v) -> [#("CapacityUnits", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.read_capacity_units {
    option.Some(v) -> [#("ReadCapacityUnits", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.write_capacity_units {
    option.Some(v) -> [#("WriteCapacityUnits", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_capacity_struct() -> decode.Decoder(Capacity) {
  use capacity_units <- decode.optional_field(
    "CapacityUnits",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use read_capacity_units <- decode.optional_field(
    "ReadCapacityUnits",
    option.None,
    decode.optional(json_float.decoder()),
  )
  use write_capacity_units <- decode.optional_field(
    "WriteCapacityUnits",
    option.None,
    decode.optional(json_float.decoder()),
  )
  decode.success(Capacity(
    capacity_units: capacity_units,
    read_capacity_units: read_capacity_units,
    write_capacity_units: write_capacity_units,
  ))
}

pub type BatchStatementResponse {
  BatchStatementResponse(
    error: option.Option(BatchStatementError),
    item: option.Option(dict.Dict(String, AttributeValue)),
    table_name: option.Option(String),
  )
}

pub fn encode_batch_statement_response_struct(
  input: BatchStatementResponse,
) -> json.Json {
  let pairs = []
  let pairs = case input.error {
    option.Some(v) -> [
      #("Error", encode_batch_statement_error_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item {
    option.Some(v) -> [
      #(
        "Item",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_batch_statement_response_struct() -> decode.Decoder(
  BatchStatementResponse,
) {
  use error <- decode.optional_field(
    "Error",
    option.None,
    decode.optional(decode_batch_statement_error_struct()),
  )
  use item <- decode.optional_field(
    "Item",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(BatchStatementResponse(
    error: error,
    item: item,
    table_name: table_name,
  ))
}

pub type BatchStatementError {
  BatchStatementError(
    code: option.Option(BatchStatementErrorCodeEnum),
    item: option.Option(dict.Dict(String, AttributeValue)),
    message: option.Option(String),
  )
}

pub fn encode_batch_statement_error_struct(
  input: BatchStatementError,
) -> json.Json {
  let pairs = []
  let pairs = case input.code {
    option.Some(v) -> [
      #("Code", encode_batch_statement_error_code_enum_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item {
    option.Some(v) -> [
      #(
        "Item",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.message {
    option.Some(v) -> [#("Message", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_batch_statement_error_struct() -> decode.Decoder(
  BatchStatementError,
) {
  use code <- decode.optional_field(
    "Code",
    option.None,
    decode.optional(decode_batch_statement_error_code_enum_enum()),
  )
  use item <- decode.optional_field(
    "Item",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use message <- decode.optional_field(
    "Message",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(BatchStatementError(code: code, item: item, message: message))
}

pub type BatchStatementErrorCodeEnum {
  BatchStatementErrorCodeEnumAccessdenied
  BatchStatementErrorCodeEnumConditionalcheckfailed
  BatchStatementErrorCodeEnumDuplicateitem
  BatchStatementErrorCodeEnumInternalservererror
  BatchStatementErrorCodeEnumItemcollectionsizelimitexceeded
  BatchStatementErrorCodeEnumProvisionedthroughputexceeded
  BatchStatementErrorCodeEnumRequestlimitexceeded
  BatchStatementErrorCodeEnumResourcenotfound
  BatchStatementErrorCodeEnumThrottlingerror
  BatchStatementErrorCodeEnumTransactionconflict
  BatchStatementErrorCodeEnumValidationerror
}

pub fn encode_batch_statement_error_code_enum_enum(
  v: BatchStatementErrorCodeEnum,
) -> json.Json {
  case v {
    BatchStatementErrorCodeEnumAccessdenied -> json.string("AccessDenied")
    BatchStatementErrorCodeEnumConditionalcheckfailed ->
      json.string("ConditionalCheckFailed")
    BatchStatementErrorCodeEnumDuplicateitem -> json.string("DuplicateItem")
    BatchStatementErrorCodeEnumInternalservererror ->
      json.string("InternalServerError")
    BatchStatementErrorCodeEnumItemcollectionsizelimitexceeded ->
      json.string("ItemCollectionSizeLimitExceeded")
    BatchStatementErrorCodeEnumProvisionedthroughputexceeded ->
      json.string("ProvisionedThroughputExceeded")
    BatchStatementErrorCodeEnumRequestlimitexceeded ->
      json.string("RequestLimitExceeded")
    BatchStatementErrorCodeEnumResourcenotfound ->
      json.string("ResourceNotFound")
    BatchStatementErrorCodeEnumThrottlingerror -> json.string("ThrottlingError")
    BatchStatementErrorCodeEnumTransactionconflict ->
      json.string("TransactionConflict")
    BatchStatementErrorCodeEnumValidationerror -> json.string("ValidationError")
  }
}

pub fn decode_batch_statement_error_code_enum_enum() -> decode.Decoder(
  BatchStatementErrorCodeEnum,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "AccessDenied" -> decode.success(BatchStatementErrorCodeEnumAccessdenied)
      "ConditionalCheckFailed" ->
        decode.success(BatchStatementErrorCodeEnumConditionalcheckfailed)
      "DuplicateItem" ->
        decode.success(BatchStatementErrorCodeEnumDuplicateitem)
      "InternalServerError" ->
        decode.success(BatchStatementErrorCodeEnumInternalservererror)
      "ItemCollectionSizeLimitExceeded" ->
        decode.success(
          BatchStatementErrorCodeEnumItemcollectionsizelimitexceeded,
        )
      "ProvisionedThroughputExceeded" ->
        decode.success(BatchStatementErrorCodeEnumProvisionedthroughputexceeded)
      "RequestLimitExceeded" ->
        decode.success(BatchStatementErrorCodeEnumRequestlimitexceeded)
      "ResourceNotFound" ->
        decode.success(BatchStatementErrorCodeEnumResourcenotfound)
      "ThrottlingError" ->
        decode.success(BatchStatementErrorCodeEnumThrottlingerror)
      "TransactionConflict" ->
        decode.success(BatchStatementErrorCodeEnumTransactionconflict)
      "ValidationError" ->
        decode.success(BatchStatementErrorCodeEnumValidationerror)
      _ ->
        decode.failure(
          BatchStatementErrorCodeEnumAccessdenied,
          "unknown enum value",
        )
    }
  })
}

pub type BatchGetItemInput {
  BatchGetItemInput(
    request_items: option.Option(dict.Dict(String, KeysAndAttributes)),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
  )
}

pub fn encode_batch_get_item_input_struct(
  input: BatchGetItemInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.request_items {
    option.Some(v) -> [
      #(
        "RequestItems",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_keys_and_attributes_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_batch_get_item_input_struct() -> decode.Decoder(BatchGetItemInput) {
  use request_items <- decode.optional_field(
    "RequestItems",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode_keys_and_attributes_struct(),
    )),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  decode.success(BatchGetItemInput(
    request_items: request_items,
    return_consumed_capacity: return_consumed_capacity,
  ))
}

pub type KeysAndAttributes {
  KeysAndAttributes(
    attributes_to_get: option.Option(List(String)),
    consistent_read: option.Option(Bool),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    keys: option.Option(List(dict.Dict(String, AttributeValue))),
    projection_expression: option.Option(String),
  )
}

pub fn encode_keys_and_attributes_struct(
  input: KeysAndAttributes,
) -> json.Json {
  let pairs = []
  let pairs = case input.attributes_to_get {
    option.Some(v) -> [
      #("AttributesToGet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.consistent_read {
    option.Some(v) -> [#("ConsistentRead", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.keys {
    option.Some(v) -> [
      #(
        "Keys",
        fn(xs) {
          json.array(xs, fn(d) {
            json.object(
              dict.to_list(d)
              |> list.map(fn(pair) {
                #(pair.0, encode_attribute_value_union(pair.1))
              }),
            )
          })
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection_expression {
    option.Some(v) -> [#("ProjectionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_keys_and_attributes_struct() -> decode.Decoder(KeysAndAttributes) {
  use attributes_to_get <- decode.optional_field(
    "AttributesToGet",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use consistent_read <- decode.optional_field(
    "ConsistentRead",
    option.None,
    decode.optional(decode.bool),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use keys <- decode.optional_field(
    "Keys",
    option.None,
    decode.optional(
      decode.list(decode.dict(decode.string, decode_attribute_value_union())),
    ),
  )
  use projection_expression <- decode.optional_field(
    "ProjectionExpression",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(KeysAndAttributes(
    attributes_to_get: attributes_to_get,
    consistent_read: consistent_read,
    expression_attribute_names: expression_attribute_names,
    keys: keys,
    projection_expression: projection_expression,
  ))
}

pub type BatchGetItemOutput {
  BatchGetItemOutput(
    consumed_capacity: option.Option(List(ConsumedCapacity)),
    responses: option.Option(
      dict.Dict(String, List(dict.Dict(String, AttributeValue))),
    ),
    unprocessed_keys: option.Option(dict.Dict(String, KeysAndAttributes)),
  )
}

pub fn encode_batch_get_item_output_struct(
  input: BatchGetItemOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #(
        "ConsumedCapacity",
        fn(xs) { json.array(xs, encode_consumed_capacity_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.responses {
    option.Some(v) -> [
      #(
        "Responses",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(
                pair.0,
                fn(xs) {
                  json.array(xs, fn(d) {
                    json.object(
                      dict.to_list(d)
                      |> list.map(fn(pair) {
                        #(pair.0, encode_attribute_value_union(pair.1))
                      }),
                    )
                  })
                }(pair.1),
              )
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.unprocessed_keys {
    option.Some(v) -> [
      #(
        "UnprocessedKeys",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_keys_and_attributes_struct(pair.1))
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

pub fn decode_batch_get_item_output_struct() -> decode.Decoder(
  BatchGetItemOutput,
) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode.list(decode_consumed_capacity_struct())),
  )
  use responses <- decode.optional_field(
    "Responses",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode.list(decode.dict(decode.string, decode_attribute_value_union())),
    )),
  )
  use unprocessed_keys <- decode.optional_field(
    "UnprocessedKeys",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode_keys_and_attributes_struct(),
    )),
  )
  decode.success(BatchGetItemOutput(
    consumed_capacity: consumed_capacity,
    responses: responses,
    unprocessed_keys: unprocessed_keys,
  ))
}

pub type BatchWriteItemInput {
  BatchWriteItemInput(
    request_items: option.Option(dict.Dict(String, List(WriteRequest))),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    return_item_collection_metrics: option.Option(ReturnItemCollectionMetrics),
  )
}

pub fn encode_batch_write_item_input_struct(
  input: BatchWriteItemInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.request_items {
    option.Some(v) -> [
      #(
        "RequestItems",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(
                pair.0,
                fn(xs) { json.array(xs, encode_write_request_struct) }(pair.1),
              )
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_item_collection_metrics {
    option.Some(v) -> [
      #(
        "ReturnItemCollectionMetrics",
        encode_return_item_collection_metrics_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_batch_write_item_input_struct() -> decode.Decoder(
  BatchWriteItemInput,
) {
  use request_items <- decode.optional_field(
    "RequestItems",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode.list(decode_write_request_struct()),
    )),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use return_item_collection_metrics <- decode.optional_field(
    "ReturnItemCollectionMetrics",
    option.None,
    decode.optional(decode_return_item_collection_metrics_enum()),
  )
  decode.success(BatchWriteItemInput(
    request_items: request_items,
    return_consumed_capacity: return_consumed_capacity,
    return_item_collection_metrics: return_item_collection_metrics,
  ))
}

pub type WriteRequest {
  WriteRequest(
    delete_request: option.Option(DeleteRequest),
    put_request: option.Option(PutRequest),
  )
}

pub fn encode_write_request_struct(input: WriteRequest) -> json.Json {
  let pairs = []
  let pairs = case input.delete_request {
    option.Some(v) -> [
      #("DeleteRequest", encode_delete_request_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.put_request {
    option.Some(v) -> [#("PutRequest", encode_put_request_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_write_request_struct() -> decode.Decoder(WriteRequest) {
  use delete_request <- decode.optional_field(
    "DeleteRequest",
    option.None,
    decode.optional(decode_delete_request_struct()),
  )
  use put_request <- decode.optional_field(
    "PutRequest",
    option.None,
    decode.optional(decode_put_request_struct()),
  )
  decode.success(WriteRequest(
    delete_request: delete_request,
    put_request: put_request,
  ))
}

pub type DeleteRequest {
  DeleteRequest(key: option.Option(dict.Dict(String, AttributeValue)))
}

pub fn encode_delete_request_struct(input: DeleteRequest) -> json.Json {
  let pairs = []
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
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

pub fn decode_delete_request_struct() -> decode.Decoder(DeleteRequest) {
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  decode.success(DeleteRequest(key: key))
}

pub type PutRequest {
  PutRequest(item: option.Option(dict.Dict(String, AttributeValue)))
}

pub fn encode_put_request_struct(input: PutRequest) -> json.Json {
  let pairs = []
  let pairs = case input.item {
    option.Some(v) -> [
      #(
        "Item",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
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

pub fn decode_put_request_struct() -> decode.Decoder(PutRequest) {
  use item <- decode.optional_field(
    "Item",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  decode.success(PutRequest(item: item))
}

pub type ReturnItemCollectionMetrics {
  ReturnItemCollectionMetricsNone
  ReturnItemCollectionMetricsSize
}

pub fn encode_return_item_collection_metrics_enum(
  v: ReturnItemCollectionMetrics,
) -> json.Json {
  case v {
    ReturnItemCollectionMetricsNone -> json.string("NONE")
    ReturnItemCollectionMetricsSize -> json.string("SIZE")
  }
}

pub fn decode_return_item_collection_metrics_enum() -> decode.Decoder(
  ReturnItemCollectionMetrics,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "NONE" -> decode.success(ReturnItemCollectionMetricsNone)
      "SIZE" -> decode.success(ReturnItemCollectionMetricsSize)
      _ -> decode.failure(ReturnItemCollectionMetricsNone, "unknown enum value")
    }
  })
}

pub type BatchWriteItemOutput {
  BatchWriteItemOutput(
    consumed_capacity: option.Option(List(ConsumedCapacity)),
    item_collection_metrics: option.Option(
      dict.Dict(String, List(ItemCollectionMetrics)),
    ),
    unprocessed_items: option.Option(dict.Dict(String, List(WriteRequest))),
  )
}

pub fn encode_batch_write_item_output_struct(
  input: BatchWriteItemOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #(
        "ConsumedCapacity",
        fn(xs) { json.array(xs, encode_consumed_capacity_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item_collection_metrics {
    option.Some(v) -> [
      #(
        "ItemCollectionMetrics",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(
                pair.0,
                fn(xs) { json.array(xs, encode_item_collection_metrics_struct) }(
                  pair.1,
                ),
              )
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.unprocessed_items {
    option.Some(v) -> [
      #(
        "UnprocessedItems",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(
                pair.0,
                fn(xs) { json.array(xs, encode_write_request_struct) }(pair.1),
              )
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

pub fn decode_batch_write_item_output_struct() -> decode.Decoder(
  BatchWriteItemOutput,
) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode.list(decode_consumed_capacity_struct())),
  )
  use item_collection_metrics <- decode.optional_field(
    "ItemCollectionMetrics",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode.list(decode_item_collection_metrics_struct()),
    )),
  )
  use unprocessed_items <- decode.optional_field(
    "UnprocessedItems",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode.list(decode_write_request_struct()),
    )),
  )
  decode.success(BatchWriteItemOutput(
    consumed_capacity: consumed_capacity,
    item_collection_metrics: item_collection_metrics,
    unprocessed_items: unprocessed_items,
  ))
}

pub type ItemCollectionMetrics {
  ItemCollectionMetrics(
    item_collection_key: option.Option(dict.Dict(String, AttributeValue)),
    size_estimate_range_gb: option.Option(List(json_float.SmithyFloat)),
  )
}

pub fn encode_item_collection_metrics_struct(
  input: ItemCollectionMetrics,
) -> json.Json {
  let pairs = []
  let pairs = case input.item_collection_key {
    option.Some(v) -> [
      #(
        "ItemCollectionKey",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.size_estimate_range_gb {
    option.Some(v) -> [
      #("SizeEstimateRangeGB", fn(xs) { json.array(xs, json_float.encode) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_item_collection_metrics_struct() -> decode.Decoder(
  ItemCollectionMetrics,
) {
  use item_collection_key <- decode.optional_field(
    "ItemCollectionKey",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use size_estimate_range_gb <- decode.optional_field(
    "SizeEstimateRangeGB",
    option.None,
    decode.optional(decode.list(json_float.decoder())),
  )
  decode.success(ItemCollectionMetrics(
    item_collection_key: item_collection_key,
    size_estimate_range_gb: size_estimate_range_gb,
  ))
}

pub type CreateBackupInput {
  CreateBackupInput(
    backup_name: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_create_backup_input_struct(
  input: CreateBackupInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_name {
    option.Some(v) -> [#("BackupName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_backup_input_struct() -> decode.Decoder(CreateBackupInput) {
  use backup_name <- decode.optional_field(
    "BackupName",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CreateBackupInput(
    backup_name: backup_name,
    table_name: table_name,
  ))
}

pub type CreateBackupOutput {
  CreateBackupOutput(backup_details: option.Option(BackupDetails))
}

pub fn encode_create_backup_output_struct(
  input: CreateBackupOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_details {
    option.Some(v) -> [
      #("BackupDetails", encode_backup_details_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_backup_output_struct() -> decode.Decoder(
  CreateBackupOutput,
) {
  use backup_details <- decode.optional_field(
    "BackupDetails",
    option.None,
    decode.optional(decode_backup_details_struct()),
  )
  decode.success(CreateBackupOutput(backup_details: backup_details))
}

pub type BackupDetails {
  BackupDetails(
    backup_arn: option.Option(String),
    backup_creation_date_time: option.Option(Int),
    backup_expiry_date_time: option.Option(Int),
    backup_name: option.Option(String),
    backup_size_bytes: option.Option(Int),
    backup_status: option.Option(BackupStatus),
    backup_type: option.Option(BackupType),
  )
}

pub fn encode_backup_details_struct(input: BackupDetails) -> json.Json {
  let pairs = []
  let pairs = case input.backup_arn {
    option.Some(v) -> [#("BackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_creation_date_time {
    option.Some(v) -> [#("BackupCreationDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_expiry_date_time {
    option.Some(v) -> [#("BackupExpiryDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_name {
    option.Some(v) -> [#("BackupName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_size_bytes {
    option.Some(v) -> [#("BackupSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_status {
    option.Some(v) -> [#("BackupStatus", encode_backup_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_type {
    option.Some(v) -> [#("BackupType", encode_backup_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_backup_details_struct() -> decode.Decoder(BackupDetails) {
  use backup_arn <- decode.optional_field(
    "BackupArn",
    option.None,
    decode.optional(decode.string),
  )
  use backup_creation_date_time <- decode.optional_field(
    "BackupCreationDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use backup_expiry_date_time <- decode.optional_field(
    "BackupExpiryDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use backup_name <- decode.optional_field(
    "BackupName",
    option.None,
    decode.optional(decode.string),
  )
  use backup_size_bytes <- decode.optional_field(
    "BackupSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  use backup_status <- decode.optional_field(
    "BackupStatus",
    option.None,
    decode.optional(decode_backup_status_enum()),
  )
  use backup_type <- decode.optional_field(
    "BackupType",
    option.None,
    decode.optional(decode_backup_type_enum()),
  )
  decode.success(BackupDetails(
    backup_arn: backup_arn,
    backup_creation_date_time: backup_creation_date_time,
    backup_expiry_date_time: backup_expiry_date_time,
    backup_name: backup_name,
    backup_size_bytes: backup_size_bytes,
    backup_status: backup_status,
    backup_type: backup_type,
  ))
}

pub type BackupStatus {
  BackupStatusAvailable
  BackupStatusCreating
  BackupStatusDeleted
}

pub fn encode_backup_status_enum(v: BackupStatus) -> json.Json {
  case v {
    BackupStatusAvailable -> json.string("AVAILABLE")
    BackupStatusCreating -> json.string("CREATING")
    BackupStatusDeleted -> json.string("DELETED")
  }
}

pub fn decode_backup_status_enum() -> decode.Decoder(BackupStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "AVAILABLE" -> decode.success(BackupStatusAvailable)
      "CREATING" -> decode.success(BackupStatusCreating)
      "DELETED" -> decode.success(BackupStatusDeleted)
      _ -> decode.failure(BackupStatusAvailable, "unknown enum value")
    }
  })
}

pub type BackupType {
  BackupTypeAwsBackup
  BackupTypeSystem
  BackupTypeUser
}

pub fn encode_backup_type_enum(v: BackupType) -> json.Json {
  case v {
    BackupTypeAwsBackup -> json.string("AWS_BACKUP")
    BackupTypeSystem -> json.string("SYSTEM")
    BackupTypeUser -> json.string("USER")
  }
}

pub fn decode_backup_type_enum() -> decode.Decoder(BackupType) {
  decode.then(decode.string, fn(s) {
    case s {
      "AWS_BACKUP" -> decode.success(BackupTypeAwsBackup)
      "SYSTEM" -> decode.success(BackupTypeSystem)
      "USER" -> decode.success(BackupTypeUser)
      _ -> decode.failure(BackupTypeAwsBackup, "unknown enum value")
    }
  })
}

pub type CreateGlobalTableInput {
  CreateGlobalTableInput(
    global_table_name: option.Option(String),
    replication_group: option.Option(List(Replica)),
  )
}

pub fn encode_create_global_table_input_struct(
  input: CreateGlobalTableInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replication_group {
    option.Some(v) -> [
      #("ReplicationGroup", fn(xs) { json.array(xs, encode_replica_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_global_table_input_struct() -> decode.Decoder(
  CreateGlobalTableInput,
) {
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use replication_group <- decode.optional_field(
    "ReplicationGroup",
    option.None,
    decode.optional(decode.list(decode_replica_struct())),
  )
  decode.success(CreateGlobalTableInput(
    global_table_name: global_table_name,
    replication_group: replication_group,
  ))
}

pub type Replica {
  Replica(region_name: option.Option(String))
}

pub fn encode_replica_struct(input: Replica) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_struct() -> decode.Decoder(Replica) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Replica(region_name: region_name))
}

pub type CreateGlobalTableOutput {
  CreateGlobalTableOutput(
    global_table_description: option.Option(GlobalTableDescription),
  )
}

pub fn encode_create_global_table_output_struct(
  input: CreateGlobalTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_description {
    option.Some(v) -> [
      #("GlobalTableDescription", encode_global_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_global_table_output_struct() -> decode.Decoder(
  CreateGlobalTableOutput,
) {
  use global_table_description <- decode.optional_field(
    "GlobalTableDescription",
    option.None,
    decode.optional(decode_global_table_description_struct()),
  )
  decode.success(CreateGlobalTableOutput(
    global_table_description: global_table_description,
  ))
}

pub type GlobalTableDescription {
  GlobalTableDescription(
    creation_date_time: option.Option(Int),
    global_table_arn: option.Option(String),
    global_table_name: option.Option(String),
    global_table_status: option.Option(GlobalTableStatus),
    replication_group: option.Option(List(ReplicaDescription)),
  )
}

pub fn encode_global_table_description_struct(
  input: GlobalTableDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.creation_date_time {
    option.Some(v) -> [#("CreationDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_table_arn {
    option.Some(v) -> [#("GlobalTableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_table_status {
    option.Some(v) -> [
      #("GlobalTableStatus", encode_global_table_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replication_group {
    option.Some(v) -> [
      #(
        "ReplicationGroup",
        fn(xs) { json.array(xs, encode_replica_description_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_table_description_struct() -> decode.Decoder(
  GlobalTableDescription,
) {
  use creation_date_time <- decode.optional_field(
    "CreationDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use global_table_arn <- decode.optional_field(
    "GlobalTableArn",
    option.None,
    decode.optional(decode.string),
  )
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use global_table_status <- decode.optional_field(
    "GlobalTableStatus",
    option.None,
    decode.optional(decode_global_table_status_enum()),
  )
  use replication_group <- decode.optional_field(
    "ReplicationGroup",
    option.None,
    decode.optional(decode.list(decode_replica_description_struct())),
  )
  decode.success(GlobalTableDescription(
    creation_date_time: creation_date_time,
    global_table_arn: global_table_arn,
    global_table_name: global_table_name,
    global_table_status: global_table_status,
    replication_group: replication_group,
  ))
}

pub type GlobalTableStatus {
  GlobalTableStatusActive
  GlobalTableStatusCreating
  GlobalTableStatusDeleting
  GlobalTableStatusUpdating
}

pub fn encode_global_table_status_enum(v: GlobalTableStatus) -> json.Json {
  case v {
    GlobalTableStatusActive -> json.string("ACTIVE")
    GlobalTableStatusCreating -> json.string("CREATING")
    GlobalTableStatusDeleting -> json.string("DELETING")
    GlobalTableStatusUpdating -> json.string("UPDATING")
  }
}

pub fn decode_global_table_status_enum() -> decode.Decoder(GlobalTableStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "ACTIVE" -> decode.success(GlobalTableStatusActive)
      "CREATING" -> decode.success(GlobalTableStatusCreating)
      "DELETING" -> decode.success(GlobalTableStatusDeleting)
      "UPDATING" -> decode.success(GlobalTableStatusUpdating)
      _ -> decode.failure(GlobalTableStatusActive, "unknown enum value")
    }
  })
}

pub type ReplicaDescription {
  ReplicaDescription(
    global_secondary_indexes: option.Option(
      List(ReplicaGlobalSecondaryIndexDescription),
    ),
    global_table_settings_replication_mode: option.Option(
      GlobalTableSettingsReplicationMode,
    ),
    kms_master_key_id: option.Option(String),
    on_demand_throughput_override: option.Option(OnDemandThroughputOverride),
    provisioned_throughput_override: option.Option(
      ProvisionedThroughputOverride,
    ),
    region_name: option.Option(String),
    replica_arn: option.Option(String),
    replica_inaccessible_date_time: option.Option(Int),
    replica_status: option.Option(ReplicaStatus),
    replica_status_description: option.Option(String),
    replica_status_percent_progress: option.Option(String),
    replica_table_class_summary: option.Option(TableClassSummary),
    warm_throughput: option.Option(TableWarmThroughputDescription),
  )
}

pub fn encode_replica_description_struct(
  input: ReplicaDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) {
          json.array(
            xs,
            encode_replica_global_secondary_index_description_struct,
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_settings_replication_mode {
    option.Some(v) -> [
      #(
        "GlobalTableSettingsReplicationMode",
        encode_global_table_settings_replication_mode_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.kms_master_key_id {
    option.Some(v) -> [#("KMSMasterKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput_override {
    option.Some(v) -> [
      #(
        "OnDemandThroughputOverride",
        encode_on_demand_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput_override {
    option.Some(v) -> [
      #(
        "ProvisionedThroughputOverride",
        encode_provisioned_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_arn {
    option.Some(v) -> [#("ReplicaArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_inaccessible_date_time {
    option.Some(v) -> [#("ReplicaInaccessibleDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_status {
    option.Some(v) -> [
      #("ReplicaStatus", encode_replica_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_status_description {
    option.Some(v) -> [#("ReplicaStatusDescription", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_status_percent_progress {
    option.Some(v) -> [
      #("ReplicaStatusPercentProgress", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_table_class_summary {
    option.Some(v) -> [
      #("ReplicaTableClassSummary", encode_table_class_summary_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #("WarmThroughput", encode_table_warm_throughput_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_description_struct() -> decode.Decoder(ReplicaDescription) {
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(
      decode.list(decode_replica_global_secondary_index_description_struct()),
    ),
  )
  use global_table_settings_replication_mode <- decode.optional_field(
    "GlobalTableSettingsReplicationMode",
    option.None,
    decode.optional(decode_global_table_settings_replication_mode_enum()),
  )
  use kms_master_key_id <- decode.optional_field(
    "KMSMasterKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use on_demand_throughput_override <- decode.optional_field(
    "OnDemandThroughputOverride",
    option.None,
    decode.optional(decode_on_demand_throughput_override_struct()),
  )
  use provisioned_throughput_override <- decode.optional_field(
    "ProvisionedThroughputOverride",
    option.None,
    decode.optional(decode_provisioned_throughput_override_struct()),
  )
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_arn <- decode.optional_field(
    "ReplicaArn",
    option.None,
    decode.optional(decode.string),
  )
  use replica_inaccessible_date_time <- decode.optional_field(
    "ReplicaInaccessibleDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use replica_status <- decode.optional_field(
    "ReplicaStatus",
    option.None,
    decode.optional(decode_replica_status_enum()),
  )
  use replica_status_description <- decode.optional_field(
    "ReplicaStatusDescription",
    option.None,
    decode.optional(decode.string),
  )
  use replica_status_percent_progress <- decode.optional_field(
    "ReplicaStatusPercentProgress",
    option.None,
    decode.optional(decode.string),
  )
  use replica_table_class_summary <- decode.optional_field(
    "ReplicaTableClassSummary",
    option.None,
    decode.optional(decode_table_class_summary_struct()),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(decode_table_warm_throughput_description_struct()),
  )
  decode.success(ReplicaDescription(
    global_secondary_indexes: global_secondary_indexes,
    global_table_settings_replication_mode: global_table_settings_replication_mode,
    kms_master_key_id: kms_master_key_id,
    on_demand_throughput_override: on_demand_throughput_override,
    provisioned_throughput_override: provisioned_throughput_override,
    region_name: region_name,
    replica_arn: replica_arn,
    replica_inaccessible_date_time: replica_inaccessible_date_time,
    replica_status: replica_status,
    replica_status_description: replica_status_description,
    replica_status_percent_progress: replica_status_percent_progress,
    replica_table_class_summary: replica_table_class_summary,
    warm_throughput: warm_throughput,
  ))
}

pub type ReplicaGlobalSecondaryIndexDescription {
  ReplicaGlobalSecondaryIndexDescription(
    index_name: option.Option(String),
    on_demand_throughput_override: option.Option(OnDemandThroughputOverride),
    provisioned_throughput_override: option.Option(
      ProvisionedThroughputOverride,
    ),
    warm_throughput: option.Option(
      GlobalSecondaryIndexWarmThroughputDescription,
    ),
  )
}

pub fn encode_replica_global_secondary_index_description_struct(
  input: ReplicaGlobalSecondaryIndexDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput_override {
    option.Some(v) -> [
      #(
        "OnDemandThroughputOverride",
        encode_on_demand_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput_override {
    option.Some(v) -> [
      #(
        "ProvisionedThroughputOverride",
        encode_provisioned_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #(
        "WarmThroughput",
        encode_global_secondary_index_warm_throughput_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_global_secondary_index_description_struct() -> decode.Decoder(
  ReplicaGlobalSecondaryIndexDescription,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use on_demand_throughput_override <- decode.optional_field(
    "OnDemandThroughputOverride",
    option.None,
    decode.optional(decode_on_demand_throughput_override_struct()),
  )
  use provisioned_throughput_override <- decode.optional_field(
    "ProvisionedThroughputOverride",
    option.None,
    decode.optional(decode_provisioned_throughput_override_struct()),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(
      decode_global_secondary_index_warm_throughput_description_struct(),
    ),
  )
  decode.success(ReplicaGlobalSecondaryIndexDescription(
    index_name: index_name,
    on_demand_throughput_override: on_demand_throughput_override,
    provisioned_throughput_override: provisioned_throughput_override,
    warm_throughput: warm_throughput,
  ))
}

pub type OnDemandThroughputOverride {
  OnDemandThroughputOverride(max_read_request_units: option.Option(Int))
}

pub fn encode_on_demand_throughput_override_struct(
  input: OnDemandThroughputOverride,
) -> json.Json {
  let pairs = []
  let pairs = case input.max_read_request_units {
    option.Some(v) -> [#("MaxReadRequestUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_on_demand_throughput_override_struct() -> decode.Decoder(
  OnDemandThroughputOverride,
) {
  use max_read_request_units <- decode.optional_field(
    "MaxReadRequestUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(OnDemandThroughputOverride(
    max_read_request_units: max_read_request_units,
  ))
}

pub type ProvisionedThroughputOverride {
  ProvisionedThroughputOverride(read_capacity_units: option.Option(Int))
}

pub fn encode_provisioned_throughput_override_struct(
  input: ProvisionedThroughputOverride,
) -> json.Json {
  let pairs = []
  let pairs = case input.read_capacity_units {
    option.Some(v) -> [#("ReadCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_provisioned_throughput_override_struct() -> decode.Decoder(
  ProvisionedThroughputOverride,
) {
  use read_capacity_units <- decode.optional_field(
    "ReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ProvisionedThroughputOverride(
    read_capacity_units: read_capacity_units,
  ))
}

pub type GlobalSecondaryIndexWarmThroughputDescription {
  GlobalSecondaryIndexWarmThroughputDescription(
    read_units_per_second: option.Option(Int),
    status: option.Option(IndexStatus),
    write_units_per_second: option.Option(Int),
  )
}

pub fn encode_global_secondary_index_warm_throughput_description_struct(
  input: GlobalSecondaryIndexWarmThroughputDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.read_units_per_second {
    option.Some(v) -> [#("ReadUnitsPerSecond", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [#("Status", encode_index_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.write_units_per_second {
    option.Some(v) -> [#("WriteUnitsPerSecond", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_secondary_index_warm_throughput_description_struct() -> decode.Decoder(
  GlobalSecondaryIndexWarmThroughputDescription,
) {
  use read_units_per_second <- decode.optional_field(
    "ReadUnitsPerSecond",
    option.None,
    decode.optional(decode.int),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_index_status_enum()),
  )
  use write_units_per_second <- decode.optional_field(
    "WriteUnitsPerSecond",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(GlobalSecondaryIndexWarmThroughputDescription(
    read_units_per_second: read_units_per_second,
    status: status,
    write_units_per_second: write_units_per_second,
  ))
}

pub type IndexStatus {
  IndexStatusActive
  IndexStatusCreating
  IndexStatusDeleting
  IndexStatusUpdating
}

pub fn encode_index_status_enum(v: IndexStatus) -> json.Json {
  case v {
    IndexStatusActive -> json.string("ACTIVE")
    IndexStatusCreating -> json.string("CREATING")
    IndexStatusDeleting -> json.string("DELETING")
    IndexStatusUpdating -> json.string("UPDATING")
  }
}

pub fn decode_index_status_enum() -> decode.Decoder(IndexStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "ACTIVE" -> decode.success(IndexStatusActive)
      "CREATING" -> decode.success(IndexStatusCreating)
      "DELETING" -> decode.success(IndexStatusDeleting)
      "UPDATING" -> decode.success(IndexStatusUpdating)
      _ -> decode.failure(IndexStatusActive, "unknown enum value")
    }
  })
}

pub type GlobalTableSettingsReplicationMode {
  GlobalTableSettingsReplicationModeDisabled
  GlobalTableSettingsReplicationModeEnabled
  GlobalTableSettingsReplicationModeEnabledWithOverrides
}

pub fn encode_global_table_settings_replication_mode_enum(
  v: GlobalTableSettingsReplicationMode,
) -> json.Json {
  case v {
    GlobalTableSettingsReplicationModeDisabled -> json.string("DISABLED")
    GlobalTableSettingsReplicationModeEnabled -> json.string("ENABLED")
    GlobalTableSettingsReplicationModeEnabledWithOverrides ->
      json.string("ENABLED_WITH_OVERRIDES")
  }
}

pub fn decode_global_table_settings_replication_mode_enum() -> decode.Decoder(
  GlobalTableSettingsReplicationMode,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(GlobalTableSettingsReplicationModeDisabled)
      "ENABLED" -> decode.success(GlobalTableSettingsReplicationModeEnabled)
      "ENABLED_WITH_OVERRIDES" ->
        decode.success(GlobalTableSettingsReplicationModeEnabledWithOverrides)
      _ ->
        decode.failure(
          GlobalTableSettingsReplicationModeDisabled,
          "unknown enum value",
        )
    }
  })
}

pub type ReplicaStatus {
  ReplicaStatusActive
  ReplicaStatusArchived
  ReplicaStatusArchiving
  ReplicaStatusCreating
  ReplicaStatusCreationFailed
  ReplicaStatusDeleting
  ReplicaStatusInaccessibleEncryptionCredentials
  ReplicaStatusRegionDisabled
  ReplicaStatusReplicationNotAuthorized
  ReplicaStatusUpdating
}

pub fn encode_replica_status_enum(v: ReplicaStatus) -> json.Json {
  case v {
    ReplicaStatusActive -> json.string("ACTIVE")
    ReplicaStatusArchived -> json.string("ARCHIVED")
    ReplicaStatusArchiving -> json.string("ARCHIVING")
    ReplicaStatusCreating -> json.string("CREATING")
    ReplicaStatusCreationFailed -> json.string("CREATION_FAILED")
    ReplicaStatusDeleting -> json.string("DELETING")
    ReplicaStatusInaccessibleEncryptionCredentials ->
      json.string("INACCESSIBLE_ENCRYPTION_CREDENTIALS")
    ReplicaStatusRegionDisabled -> json.string("REGION_DISABLED")
    ReplicaStatusReplicationNotAuthorized ->
      json.string("REPLICATION_NOT_AUTHORIZED")
    ReplicaStatusUpdating -> json.string("UPDATING")
  }
}

pub fn decode_replica_status_enum() -> decode.Decoder(ReplicaStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "ACTIVE" -> decode.success(ReplicaStatusActive)
      "ARCHIVED" -> decode.success(ReplicaStatusArchived)
      "ARCHIVING" -> decode.success(ReplicaStatusArchiving)
      "CREATING" -> decode.success(ReplicaStatusCreating)
      "CREATION_FAILED" -> decode.success(ReplicaStatusCreationFailed)
      "DELETING" -> decode.success(ReplicaStatusDeleting)
      "INACCESSIBLE_ENCRYPTION_CREDENTIALS" ->
        decode.success(ReplicaStatusInaccessibleEncryptionCredentials)
      "REGION_DISABLED" -> decode.success(ReplicaStatusRegionDisabled)
      "REPLICATION_NOT_AUTHORIZED" ->
        decode.success(ReplicaStatusReplicationNotAuthorized)
      "UPDATING" -> decode.success(ReplicaStatusUpdating)
      _ -> decode.failure(ReplicaStatusActive, "unknown enum value")
    }
  })
}

pub type TableClassSummary {
  TableClassSummary(
    last_update_date_time: option.Option(Int),
    table_class: option.Option(TableClass),
  )
}

pub fn encode_table_class_summary_struct(
  input: TableClassSummary,
) -> json.Json {
  let pairs = []
  let pairs = case input.last_update_date_time {
    option.Some(v) -> [#("LastUpdateDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_class {
    option.Some(v) -> [#("TableClass", encode_table_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_table_class_summary_struct() -> decode.Decoder(TableClassSummary) {
  use last_update_date_time <- decode.optional_field(
    "LastUpdateDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use table_class <- decode.optional_field(
    "TableClass",
    option.None,
    decode.optional(decode_table_class_enum()),
  )
  decode.success(TableClassSummary(
    last_update_date_time: last_update_date_time,
    table_class: table_class,
  ))
}

pub type TableClass {
  TableClassStandard
  TableClassStandardInfrequentAccess
}

pub fn encode_table_class_enum(v: TableClass) -> json.Json {
  case v {
    TableClassStandard -> json.string("STANDARD")
    TableClassStandardInfrequentAccess ->
      json.string("STANDARD_INFREQUENT_ACCESS")
  }
}

pub fn decode_table_class_enum() -> decode.Decoder(TableClass) {
  decode.then(decode.string, fn(s) {
    case s {
      "STANDARD" -> decode.success(TableClassStandard)
      "STANDARD_INFREQUENT_ACCESS" ->
        decode.success(TableClassStandardInfrequentAccess)
      _ -> decode.failure(TableClassStandard, "unknown enum value")
    }
  })
}

pub type TableWarmThroughputDescription {
  TableWarmThroughputDescription(
    read_units_per_second: option.Option(Int),
    status: option.Option(TableStatus),
    write_units_per_second: option.Option(Int),
  )
}

pub fn encode_table_warm_throughput_description_struct(
  input: TableWarmThroughputDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.read_units_per_second {
    option.Some(v) -> [#("ReadUnitsPerSecond", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [#("Status", encode_table_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.write_units_per_second {
    option.Some(v) -> [#("WriteUnitsPerSecond", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_table_warm_throughput_description_struct() -> decode.Decoder(
  TableWarmThroughputDescription,
) {
  use read_units_per_second <- decode.optional_field(
    "ReadUnitsPerSecond",
    option.None,
    decode.optional(decode.int),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_table_status_enum()),
  )
  use write_units_per_second <- decode.optional_field(
    "WriteUnitsPerSecond",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(TableWarmThroughputDescription(
    read_units_per_second: read_units_per_second,
    status: status,
    write_units_per_second: write_units_per_second,
  ))
}

pub type TableStatus {
  TableStatusActive
  TableStatusArchived
  TableStatusArchiving
  TableStatusCreating
  TableStatusDeleting
  TableStatusInaccessibleEncryptionCredentials
  TableStatusReplicationNotAuthorized
  TableStatusUpdating
}

pub fn encode_table_status_enum(v: TableStatus) -> json.Json {
  case v {
    TableStatusActive -> json.string("ACTIVE")
    TableStatusArchived -> json.string("ARCHIVED")
    TableStatusArchiving -> json.string("ARCHIVING")
    TableStatusCreating -> json.string("CREATING")
    TableStatusDeleting -> json.string("DELETING")
    TableStatusInaccessibleEncryptionCredentials ->
      json.string("INACCESSIBLE_ENCRYPTION_CREDENTIALS")
    TableStatusReplicationNotAuthorized ->
      json.string("REPLICATION_NOT_AUTHORIZED")
    TableStatusUpdating -> json.string("UPDATING")
  }
}

pub fn decode_table_status_enum() -> decode.Decoder(TableStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "ACTIVE" -> decode.success(TableStatusActive)
      "ARCHIVED" -> decode.success(TableStatusArchived)
      "ARCHIVING" -> decode.success(TableStatusArchiving)
      "CREATING" -> decode.success(TableStatusCreating)
      "DELETING" -> decode.success(TableStatusDeleting)
      "INACCESSIBLE_ENCRYPTION_CREDENTIALS" ->
        decode.success(TableStatusInaccessibleEncryptionCredentials)
      "REPLICATION_NOT_AUTHORIZED" ->
        decode.success(TableStatusReplicationNotAuthorized)
      "UPDATING" -> decode.success(TableStatusUpdating)
      _ -> decode.failure(TableStatusActive, "unknown enum value")
    }
  })
}

pub type CreateTableInput {
  CreateTableInput(
    attribute_definitions: option.Option(List(AttributeDefinition)),
    billing_mode: option.Option(BillingMode),
    deletion_protection_enabled: option.Option(Bool),
    global_secondary_indexes: option.Option(List(GlobalSecondaryIndex)),
    global_table_settings_replication_mode: option.Option(
      GlobalTableSettingsReplicationMode,
    ),
    global_table_source_arn: option.Option(String),
    key_schema: option.Option(List(KeySchemaElement)),
    local_secondary_indexes: option.Option(List(LocalSecondaryIndex)),
    on_demand_throughput: option.Option(OnDemandThroughput),
    provisioned_throughput: option.Option(ProvisionedThroughput),
    resource_policy: option.Option(String),
    sse_specification: option.Option(SSESpecification),
    stream_specification: option.Option(StreamSpecification),
    table_class: option.Option(TableClass),
    table_name: option.Option(String),
    tags: option.Option(List(Tag)),
    warm_throughput: option.Option(WarmThroughput),
  )
}

pub fn encode_create_table_input_struct(input: CreateTableInput) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_definitions {
    option.Some(v) -> [
      #(
        "AttributeDefinitions",
        fn(xs) { json.array(xs, encode_attribute_definition_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.billing_mode {
    option.Some(v) -> [#("BillingMode", encode_billing_mode_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.deletion_protection_enabled {
    option.Some(v) -> [#("DeletionProtectionEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) { json.array(xs, encode_global_secondary_index_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_settings_replication_mode {
    option.Some(v) -> [
      #(
        "GlobalTableSettingsReplicationMode",
        encode_global_table_settings_replication_mode_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_source_arn {
    option.Some(v) -> [#("GlobalTableSourceArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.local_secondary_indexes {
    option.Some(v) -> [
      #(
        "LocalSecondaryIndexes",
        fn(xs) { json.array(xs, encode_local_secondary_index_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.resource_policy {
    option.Some(v) -> [#("ResourcePolicy", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_specification {
    option.Some(v) -> [
      #("SSESpecification", encode_sse_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_specification {
    option.Some(v) -> [
      #("StreamSpecification", encode_stream_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_class {
    option.Some(v) -> [#("TableClass", encode_table_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #("WarmThroughput", encode_warm_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_table_input_struct() -> decode.Decoder(CreateTableInput) {
  use attribute_definitions <- decode.optional_field(
    "AttributeDefinitions",
    option.None,
    decode.optional(decode.list(decode_attribute_definition_struct())),
  )
  use billing_mode <- decode.optional_field(
    "BillingMode",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use deletion_protection_enabled <- decode.optional_field(
    "DeletionProtectionEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(decode.list(decode_global_secondary_index_struct())),
  )
  use global_table_settings_replication_mode <- decode.optional_field(
    "GlobalTableSettingsReplicationMode",
    option.None,
    decode.optional(decode_global_table_settings_replication_mode_enum()),
  )
  use global_table_source_arn <- decode.optional_field(
    "GlobalTableSourceArn",
    option.None,
    decode.optional(decode.string),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use local_secondary_indexes <- decode.optional_field(
    "LocalSecondaryIndexes",
    option.None,
    decode.optional(decode.list(decode_local_secondary_index_struct())),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use resource_policy <- decode.optional_field(
    "ResourcePolicy",
    option.None,
    decode.optional(decode.string),
  )
  use sse_specification <- decode.optional_field(
    "SSESpecification",
    option.None,
    decode.optional(decode_sse_specification_struct()),
  )
  use stream_specification <- decode.optional_field(
    "StreamSpecification",
    option.None,
    decode.optional(decode_stream_specification_struct()),
  )
  use table_class <- decode.optional_field(
    "TableClass",
    option.None,
    decode.optional(decode_table_class_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(decode_warm_throughput_struct()),
  )
  decode.success(CreateTableInput(
    attribute_definitions: attribute_definitions,
    billing_mode: billing_mode,
    deletion_protection_enabled: deletion_protection_enabled,
    global_secondary_indexes: global_secondary_indexes,
    global_table_settings_replication_mode: global_table_settings_replication_mode,
    global_table_source_arn: global_table_source_arn,
    key_schema: key_schema,
    local_secondary_indexes: local_secondary_indexes,
    on_demand_throughput: on_demand_throughput,
    provisioned_throughput: provisioned_throughput,
    resource_policy: resource_policy,
    sse_specification: sse_specification,
    stream_specification: stream_specification,
    table_class: table_class,
    table_name: table_name,
    tags: tags,
    warm_throughput: warm_throughput,
  ))
}

pub type AttributeDefinition {
  AttributeDefinition(
    attribute_name: option.Option(String),
    attribute_type: option.Option(ScalarAttributeType),
  )
}

pub fn encode_attribute_definition_struct(
  input: AttributeDefinition,
) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_name {
    option.Some(v) -> [#("AttributeName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.attribute_type {
    option.Some(v) -> [
      #("AttributeType", encode_scalar_attribute_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_attribute_definition_struct() -> decode.Decoder(
  AttributeDefinition,
) {
  use attribute_name <- decode.optional_field(
    "AttributeName",
    option.None,
    decode.optional(decode.string),
  )
  use attribute_type <- decode.optional_field(
    "AttributeType",
    option.None,
    decode.optional(decode_scalar_attribute_type_enum()),
  )
  decode.success(AttributeDefinition(
    attribute_name: attribute_name,
    attribute_type: attribute_type,
  ))
}

pub type ScalarAttributeType {
  ScalarAttributeTypeB
  ScalarAttributeTypeN
  ScalarAttributeTypeS
}

pub fn encode_scalar_attribute_type_enum(v: ScalarAttributeType) -> json.Json {
  case v {
    ScalarAttributeTypeB -> json.string("B")
    ScalarAttributeTypeN -> json.string("N")
    ScalarAttributeTypeS -> json.string("S")
  }
}

pub fn decode_scalar_attribute_type_enum() -> decode.Decoder(
  ScalarAttributeType,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "B" -> decode.success(ScalarAttributeTypeB)
      "N" -> decode.success(ScalarAttributeTypeN)
      "S" -> decode.success(ScalarAttributeTypeS)
      _ -> decode.failure(ScalarAttributeTypeB, "unknown enum value")
    }
  })
}

pub type BillingMode {
  BillingModePayPerRequest
  BillingModeProvisioned
}

pub fn encode_billing_mode_enum(v: BillingMode) -> json.Json {
  case v {
    BillingModePayPerRequest -> json.string("PAY_PER_REQUEST")
    BillingModeProvisioned -> json.string("PROVISIONED")
  }
}

pub fn decode_billing_mode_enum() -> decode.Decoder(BillingMode) {
  decode.then(decode.string, fn(s) {
    case s {
      "PAY_PER_REQUEST" -> decode.success(BillingModePayPerRequest)
      "PROVISIONED" -> decode.success(BillingModeProvisioned)
      _ -> decode.failure(BillingModePayPerRequest, "unknown enum value")
    }
  })
}

pub type GlobalSecondaryIndex {
  GlobalSecondaryIndex(
    index_name: option.Option(String),
    key_schema: option.Option(List(KeySchemaElement)),
    on_demand_throughput: option.Option(OnDemandThroughput),
    projection: option.Option(Projection),
    provisioned_throughput: option.Option(ProvisionedThroughput),
    warm_throughput: option.Option(WarmThroughput),
  )
}

pub fn encode_global_secondary_index_struct(
  input: GlobalSecondaryIndex,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection {
    option.Some(v) -> [#("Projection", encode_projection_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #("WarmThroughput", encode_warm_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_secondary_index_struct() -> decode.Decoder(
  GlobalSecondaryIndex,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use projection <- decode.optional_field(
    "Projection",
    option.None,
    decode.optional(decode_projection_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(decode_warm_throughput_struct()),
  )
  decode.success(GlobalSecondaryIndex(
    index_name: index_name,
    key_schema: key_schema,
    on_demand_throughput: on_demand_throughput,
    projection: projection,
    provisioned_throughput: provisioned_throughput,
    warm_throughput: warm_throughput,
  ))
}

pub type KeySchemaElement {
  KeySchemaElement(
    attribute_name: option.Option(String),
    key_type: option.Option(KeyType),
  )
}

pub fn encode_key_schema_element_struct(input: KeySchemaElement) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_name {
    option.Some(v) -> [#("AttributeName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_type {
    option.Some(v) -> [#("KeyType", encode_key_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_key_schema_element_struct() -> decode.Decoder(KeySchemaElement) {
  use attribute_name <- decode.optional_field(
    "AttributeName",
    option.None,
    decode.optional(decode.string),
  )
  use key_type <- decode.optional_field(
    "KeyType",
    option.None,
    decode.optional(decode_key_type_enum()),
  )
  decode.success(KeySchemaElement(
    attribute_name: attribute_name,
    key_type: key_type,
  ))
}

pub type KeyType {
  KeyTypeHash
  KeyTypeRange
}

pub fn encode_key_type_enum(v: KeyType) -> json.Json {
  case v {
    KeyTypeHash -> json.string("HASH")
    KeyTypeRange -> json.string("RANGE")
  }
}

pub fn decode_key_type_enum() -> decode.Decoder(KeyType) {
  decode.then(decode.string, fn(s) {
    case s {
      "HASH" -> decode.success(KeyTypeHash)
      "RANGE" -> decode.success(KeyTypeRange)
      _ -> decode.failure(KeyTypeHash, "unknown enum value")
    }
  })
}

pub type OnDemandThroughput {
  OnDemandThroughput(
    max_read_request_units: option.Option(Int),
    max_write_request_units: option.Option(Int),
  )
}

pub fn encode_on_demand_throughput_struct(
  input: OnDemandThroughput,
) -> json.Json {
  let pairs = []
  let pairs = case input.max_read_request_units {
    option.Some(v) -> [#("MaxReadRequestUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_write_request_units {
    option.Some(v) -> [#("MaxWriteRequestUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_on_demand_throughput_struct() -> decode.Decoder(
  OnDemandThroughput,
) {
  use max_read_request_units <- decode.optional_field(
    "MaxReadRequestUnits",
    option.None,
    decode.optional(decode.int),
  )
  use max_write_request_units <- decode.optional_field(
    "MaxWriteRequestUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(OnDemandThroughput(
    max_read_request_units: max_read_request_units,
    max_write_request_units: max_write_request_units,
  ))
}

pub type Projection {
  Projection(
    non_key_attributes: option.Option(List(String)),
    projection_type: option.Option(ProjectionType),
  )
}

pub fn encode_projection_struct(input: Projection) -> json.Json {
  let pairs = []
  let pairs = case input.non_key_attributes {
    option.Some(v) -> [
      #("NonKeyAttributes", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection_type {
    option.Some(v) -> [
      #("ProjectionType", encode_projection_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_projection_struct() -> decode.Decoder(Projection) {
  use non_key_attributes <- decode.optional_field(
    "NonKeyAttributes",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use projection_type <- decode.optional_field(
    "ProjectionType",
    option.None,
    decode.optional(decode_projection_type_enum()),
  )
  decode.success(Projection(
    non_key_attributes: non_key_attributes,
    projection_type: projection_type,
  ))
}

pub type ProjectionType {
  ProjectionTypeAll
  ProjectionTypeInclude
  ProjectionTypeKeysOnly
}

pub fn encode_projection_type_enum(v: ProjectionType) -> json.Json {
  case v {
    ProjectionTypeAll -> json.string("ALL")
    ProjectionTypeInclude -> json.string("INCLUDE")
    ProjectionTypeKeysOnly -> json.string("KEYS_ONLY")
  }
}

pub fn decode_projection_type_enum() -> decode.Decoder(ProjectionType) {
  decode.then(decode.string, fn(s) {
    case s {
      "ALL" -> decode.success(ProjectionTypeAll)
      "INCLUDE" -> decode.success(ProjectionTypeInclude)
      "KEYS_ONLY" -> decode.success(ProjectionTypeKeysOnly)
      _ -> decode.failure(ProjectionTypeAll, "unknown enum value")
    }
  })
}

pub type ProvisionedThroughput {
  ProvisionedThroughput(
    read_capacity_units: option.Option(Int),
    write_capacity_units: option.Option(Int),
  )
}

pub fn encode_provisioned_throughput_struct(
  input: ProvisionedThroughput,
) -> json.Json {
  let pairs = []
  let pairs = case input.read_capacity_units {
    option.Some(v) -> [#("ReadCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.write_capacity_units {
    option.Some(v) -> [#("WriteCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_provisioned_throughput_struct() -> decode.Decoder(
  ProvisionedThroughput,
) {
  use read_capacity_units <- decode.optional_field(
    "ReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use write_capacity_units <- decode.optional_field(
    "WriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ProvisionedThroughput(
    read_capacity_units: read_capacity_units,
    write_capacity_units: write_capacity_units,
  ))
}

pub type WarmThroughput {
  WarmThroughput(
    read_units_per_second: option.Option(Int),
    write_units_per_second: option.Option(Int),
  )
}

pub fn encode_warm_throughput_struct(input: WarmThroughput) -> json.Json {
  let pairs = []
  let pairs = case input.read_units_per_second {
    option.Some(v) -> [#("ReadUnitsPerSecond", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.write_units_per_second {
    option.Some(v) -> [#("WriteUnitsPerSecond", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_warm_throughput_struct() -> decode.Decoder(WarmThroughput) {
  use read_units_per_second <- decode.optional_field(
    "ReadUnitsPerSecond",
    option.None,
    decode.optional(decode.int),
  )
  use write_units_per_second <- decode.optional_field(
    "WriteUnitsPerSecond",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(WarmThroughput(
    read_units_per_second: read_units_per_second,
    write_units_per_second: write_units_per_second,
  ))
}

pub type LocalSecondaryIndex {
  LocalSecondaryIndex(
    index_name: option.Option(String),
    key_schema: option.Option(List(KeySchemaElement)),
    projection: option.Option(Projection),
  )
}

pub fn encode_local_secondary_index_struct(
  input: LocalSecondaryIndex,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection {
    option.Some(v) -> [#("Projection", encode_projection_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_local_secondary_index_struct() -> decode.Decoder(
  LocalSecondaryIndex,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use projection <- decode.optional_field(
    "Projection",
    option.None,
    decode.optional(decode_projection_struct()),
  )
  decode.success(LocalSecondaryIndex(
    index_name: index_name,
    key_schema: key_schema,
    projection: projection,
  ))
}

pub type SSESpecification {
  SSESpecification(
    enabled: option.Option(Bool),
    kms_master_key_id: option.Option(String),
    sse_type: option.Option(SSEType),
  )
}

pub fn encode_sse_specification_struct(input: SSESpecification) -> json.Json {
  let pairs = []
  let pairs = case input.enabled {
    option.Some(v) -> [#("Enabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.kms_master_key_id {
    option.Some(v) -> [#("KMSMasterKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_type {
    option.Some(v) -> [#("SSEType", encode_sse_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_sse_specification_struct() -> decode.Decoder(SSESpecification) {
  use enabled <- decode.optional_field(
    "Enabled",
    option.None,
    decode.optional(decode.bool),
  )
  use kms_master_key_id <- decode.optional_field(
    "KMSMasterKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use sse_type <- decode.optional_field(
    "SSEType",
    option.None,
    decode.optional(decode_sse_type_enum()),
  )
  decode.success(SSESpecification(
    enabled: enabled,
    kms_master_key_id: kms_master_key_id,
    sse_type: sse_type,
  ))
}

pub type SSEType {
  SSETypeAes256
  SSETypeKms
}

pub fn encode_sse_type_enum(v: SSEType) -> json.Json {
  case v {
    SSETypeAes256 -> json.string("AES256")
    SSETypeKms -> json.string("KMS")
  }
}

pub fn decode_sse_type_enum() -> decode.Decoder(SSEType) {
  decode.then(decode.string, fn(s) {
    case s {
      "AES256" -> decode.success(SSETypeAes256)
      "KMS" -> decode.success(SSETypeKms)
      _ -> decode.failure(SSETypeAes256, "unknown enum value")
    }
  })
}

pub type StreamSpecification {
  StreamSpecification(
    stream_enabled: option.Option(Bool),
    stream_view_type: option.Option(StreamViewType),
  )
}

pub fn encode_stream_specification_struct(
  input: StreamSpecification,
) -> json.Json {
  let pairs = []
  let pairs = case input.stream_enabled {
    option.Some(v) -> [#("StreamEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.stream_view_type {
    option.Some(v) -> [
      #("StreamViewType", encode_stream_view_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_stream_specification_struct() -> decode.Decoder(
  StreamSpecification,
) {
  use stream_enabled <- decode.optional_field(
    "StreamEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use stream_view_type <- decode.optional_field(
    "StreamViewType",
    option.None,
    decode.optional(decode_stream_view_type_enum()),
  )
  decode.success(StreamSpecification(
    stream_enabled: stream_enabled,
    stream_view_type: stream_view_type,
  ))
}

pub type StreamViewType {
  StreamViewTypeKeysOnly
  StreamViewTypeNewAndOldImages
  StreamViewTypeNewImage
  StreamViewTypeOldImage
}

pub fn encode_stream_view_type_enum(v: StreamViewType) -> json.Json {
  case v {
    StreamViewTypeKeysOnly -> json.string("KEYS_ONLY")
    StreamViewTypeNewAndOldImages -> json.string("NEW_AND_OLD_IMAGES")
    StreamViewTypeNewImage -> json.string("NEW_IMAGE")
    StreamViewTypeOldImage -> json.string("OLD_IMAGE")
  }
}

pub fn decode_stream_view_type_enum() -> decode.Decoder(StreamViewType) {
  decode.then(decode.string, fn(s) {
    case s {
      "KEYS_ONLY" -> decode.success(StreamViewTypeKeysOnly)
      "NEW_AND_OLD_IMAGES" -> decode.success(StreamViewTypeNewAndOldImages)
      "NEW_IMAGE" -> decode.success(StreamViewTypeNewImage)
      "OLD_IMAGE" -> decode.success(StreamViewTypeOldImage)
      _ -> decode.failure(StreamViewTypeKeysOnly, "unknown enum value")
    }
  })
}

pub type Tag {
  Tag(key: option.Option(String), value: option.Option(String))
}

pub fn encode_tag_struct(input: Tag) -> json.Json {
  let pairs = []
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_tag_struct() -> decode.Decoder(Tag) {
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use value <- decode.optional_field(
    "Value",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Tag(key: key, value: value))
}

pub type CreateTableOutput {
  CreateTableOutput(table_description: option.Option(TableDescription))
}

pub fn encode_create_table_output_struct(
  input: CreateTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_description {
    option.Some(v) -> [
      #("TableDescription", encode_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_table_output_struct() -> decode.Decoder(CreateTableOutput) {
  use table_description <- decode.optional_field(
    "TableDescription",
    option.None,
    decode.optional(decode_table_description_struct()),
  )
  decode.success(CreateTableOutput(table_description: table_description))
}

pub type TableDescription {
  TableDescription(
    archival_summary: option.Option(ArchivalSummary),
    attribute_definitions: option.Option(List(AttributeDefinition)),
    billing_mode_summary: option.Option(BillingModeSummary),
    creation_date_time: option.Option(Int),
    deletion_protection_enabled: option.Option(Bool),
    global_secondary_indexes: option.Option(
      List(GlobalSecondaryIndexDescription),
    ),
    global_table_settings_replication_mode: option.Option(
      GlobalTableSettingsReplicationMode,
    ),
    global_table_version: option.Option(String),
    global_table_witnesses: option.Option(List(GlobalTableWitnessDescription)),
    item_count: option.Option(Int),
    key_schema: option.Option(List(KeySchemaElement)),
    latest_stream_arn: option.Option(String),
    latest_stream_label: option.Option(String),
    local_secondary_indexes: option.Option(List(LocalSecondaryIndexDescription)),
    multi_region_consistency: option.Option(MultiRegionConsistency),
    on_demand_throughput: option.Option(OnDemandThroughput),
    provisioned_throughput: option.Option(ProvisionedThroughputDescription),
    replicas: option.Option(List(ReplicaDescription)),
    restore_summary: option.Option(RestoreSummary),
    sse_description: option.Option(SSEDescription),
    stream_specification: option.Option(StreamSpecification),
    table_arn: option.Option(String),
    table_class_summary: option.Option(TableClassSummary),
    table_id: option.Option(String),
    table_name: option.Option(String),
    table_size_bytes: option.Option(Int),
    table_status: option.Option(TableStatus),
    warm_throughput: option.Option(TableWarmThroughputDescription),
  )
}

pub fn encode_table_description_struct(input: TableDescription) -> json.Json {
  let pairs = []
  let pairs = case input.archival_summary {
    option.Some(v) -> [
      #("ArchivalSummary", encode_archival_summary_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.attribute_definitions {
    option.Some(v) -> [
      #(
        "AttributeDefinitions",
        fn(xs) { json.array(xs, encode_attribute_definition_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.billing_mode_summary {
    option.Some(v) -> [
      #("BillingModeSummary", encode_billing_mode_summary_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.creation_date_time {
    option.Some(v) -> [#("CreationDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.deletion_protection_enabled {
    option.Some(v) -> [#("DeletionProtectionEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) {
          json.array(xs, encode_global_secondary_index_description_struct)
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_settings_replication_mode {
    option.Some(v) -> [
      #(
        "GlobalTableSettingsReplicationMode",
        encode_global_table_settings_replication_mode_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_version {
    option.Some(v) -> [#("GlobalTableVersion", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_table_witnesses {
    option.Some(v) -> [
      #(
        "GlobalTableWitnesses",
        fn(xs) {
          json.array(xs, encode_global_table_witness_description_struct)
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item_count {
    option.Some(v) -> [#("ItemCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.latest_stream_arn {
    option.Some(v) -> [#("LatestStreamArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.latest_stream_label {
    option.Some(v) -> [#("LatestStreamLabel", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.local_secondary_indexes {
    option.Some(v) -> [
      #(
        "LocalSecondaryIndexes",
        fn(xs) {
          json.array(xs, encode_local_secondary_index_description_struct)
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.multi_region_consistency {
    option.Some(v) -> [
      #("MultiRegionConsistency", encode_multi_region_consistency_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #(
        "ProvisionedThroughput",
        encode_provisioned_throughput_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replicas {
    option.Some(v) -> [
      #(
        "Replicas",
        fn(xs) { json.array(xs, encode_replica_description_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.restore_summary {
    option.Some(v) -> [
      #("RestoreSummary", encode_restore_summary_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_description {
    option.Some(v) -> [
      #("SSEDescription", encode_sse_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_specification {
    option.Some(v) -> [
      #("StreamSpecification", encode_stream_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_class_summary {
    option.Some(v) -> [
      #("TableClassSummary", encode_table_class_summary_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_id {
    option.Some(v) -> [#("TableId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_size_bytes {
    option.Some(v) -> [#("TableSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_status {
    option.Some(v) -> [#("TableStatus", encode_table_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #("WarmThroughput", encode_table_warm_throughput_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_table_description_struct() -> decode.Decoder(TableDescription) {
  use archival_summary <- decode.optional_field(
    "ArchivalSummary",
    option.None,
    decode.optional(decode_archival_summary_struct()),
  )
  use attribute_definitions <- decode.optional_field(
    "AttributeDefinitions",
    option.None,
    decode.optional(decode.list(decode_attribute_definition_struct())),
  )
  use billing_mode_summary <- decode.optional_field(
    "BillingModeSummary",
    option.None,
    decode.optional(decode_billing_mode_summary_struct()),
  )
  use creation_date_time <- decode.optional_field(
    "CreationDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use deletion_protection_enabled <- decode.optional_field(
    "DeletionProtectionEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(
      decode.list(decode_global_secondary_index_description_struct()),
    ),
  )
  use global_table_settings_replication_mode <- decode.optional_field(
    "GlobalTableSettingsReplicationMode",
    option.None,
    decode.optional(decode_global_table_settings_replication_mode_enum()),
  )
  use global_table_version <- decode.optional_field(
    "GlobalTableVersion",
    option.None,
    decode.optional(decode.string),
  )
  use global_table_witnesses <- decode.optional_field(
    "GlobalTableWitnesses",
    option.None,
    decode.optional(
      decode.list(decode_global_table_witness_description_struct()),
    ),
  )
  use item_count <- decode.optional_field(
    "ItemCount",
    option.None,
    decode.optional(decode.int),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use latest_stream_arn <- decode.optional_field(
    "LatestStreamArn",
    option.None,
    decode.optional(decode.string),
  )
  use latest_stream_label <- decode.optional_field(
    "LatestStreamLabel",
    option.None,
    decode.optional(decode.string),
  )
  use local_secondary_indexes <- decode.optional_field(
    "LocalSecondaryIndexes",
    option.None,
    decode.optional(
      decode.list(decode_local_secondary_index_description_struct()),
    ),
  )
  use multi_region_consistency <- decode.optional_field(
    "MultiRegionConsistency",
    option.None,
    decode.optional(decode_multi_region_consistency_enum()),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_description_struct()),
  )
  use replicas <- decode.optional_field(
    "Replicas",
    option.None,
    decode.optional(decode.list(decode_replica_description_struct())),
  )
  use restore_summary <- decode.optional_field(
    "RestoreSummary",
    option.None,
    decode.optional(decode_restore_summary_struct()),
  )
  use sse_description <- decode.optional_field(
    "SSEDescription",
    option.None,
    decode.optional(decode_sse_description_struct()),
  )
  use stream_specification <- decode.optional_field(
    "StreamSpecification",
    option.None,
    decode.optional(decode_stream_specification_struct()),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_class_summary <- decode.optional_field(
    "TableClassSummary",
    option.None,
    decode.optional(decode_table_class_summary_struct()),
  )
  use table_id <- decode.optional_field(
    "TableId",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use table_size_bytes <- decode.optional_field(
    "TableSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  use table_status <- decode.optional_field(
    "TableStatus",
    option.None,
    decode.optional(decode_table_status_enum()),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(decode_table_warm_throughput_description_struct()),
  )
  decode.success(TableDescription(
    archival_summary: archival_summary,
    attribute_definitions: attribute_definitions,
    billing_mode_summary: billing_mode_summary,
    creation_date_time: creation_date_time,
    deletion_protection_enabled: deletion_protection_enabled,
    global_secondary_indexes: global_secondary_indexes,
    global_table_settings_replication_mode: global_table_settings_replication_mode,
    global_table_version: global_table_version,
    global_table_witnesses: global_table_witnesses,
    item_count: item_count,
    key_schema: key_schema,
    latest_stream_arn: latest_stream_arn,
    latest_stream_label: latest_stream_label,
    local_secondary_indexes: local_secondary_indexes,
    multi_region_consistency: multi_region_consistency,
    on_demand_throughput: on_demand_throughput,
    provisioned_throughput: provisioned_throughput,
    replicas: replicas,
    restore_summary: restore_summary,
    sse_description: sse_description,
    stream_specification: stream_specification,
    table_arn: table_arn,
    table_class_summary: table_class_summary,
    table_id: table_id,
    table_name: table_name,
    table_size_bytes: table_size_bytes,
    table_status: table_status,
    warm_throughput: warm_throughput,
  ))
}

pub type ArchivalSummary {
  ArchivalSummary(
    archival_backup_arn: option.Option(String),
    archival_date_time: option.Option(Int),
    archival_reason: option.Option(String),
  )
}

pub fn encode_archival_summary_struct(input: ArchivalSummary) -> json.Json {
  let pairs = []
  let pairs = case input.archival_backup_arn {
    option.Some(v) -> [#("ArchivalBackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.archival_date_time {
    option.Some(v) -> [#("ArchivalDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.archival_reason {
    option.Some(v) -> [#("ArchivalReason", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_archival_summary_struct() -> decode.Decoder(ArchivalSummary) {
  use archival_backup_arn <- decode.optional_field(
    "ArchivalBackupArn",
    option.None,
    decode.optional(decode.string),
  )
  use archival_date_time <- decode.optional_field(
    "ArchivalDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use archival_reason <- decode.optional_field(
    "ArchivalReason",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ArchivalSummary(
    archival_backup_arn: archival_backup_arn,
    archival_date_time: archival_date_time,
    archival_reason: archival_reason,
  ))
}

pub type BillingModeSummary {
  BillingModeSummary(
    billing_mode: option.Option(BillingMode),
    last_update_to_pay_per_request_date_time: option.Option(Int),
  )
}

pub fn encode_billing_mode_summary_struct(
  input: BillingModeSummary,
) -> json.Json {
  let pairs = []
  let pairs = case input.billing_mode {
    option.Some(v) -> [#("BillingMode", encode_billing_mode_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_update_to_pay_per_request_date_time {
    option.Some(v) -> [
      #("LastUpdateToPayPerRequestDateTime", json.int(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_billing_mode_summary_struct() -> decode.Decoder(
  BillingModeSummary,
) {
  use billing_mode <- decode.optional_field(
    "BillingMode",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use last_update_to_pay_per_request_date_time <- decode.optional_field(
    "LastUpdateToPayPerRequestDateTime",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(BillingModeSummary(
    billing_mode: billing_mode,
    last_update_to_pay_per_request_date_time: last_update_to_pay_per_request_date_time,
  ))
}

pub type GlobalSecondaryIndexDescription {
  GlobalSecondaryIndexDescription(
    backfilling: option.Option(Bool),
    index_arn: option.Option(String),
    index_name: option.Option(String),
    index_size_bytes: option.Option(Int),
    index_status: option.Option(IndexStatus),
    item_count: option.Option(Int),
    key_schema: option.Option(List(KeySchemaElement)),
    on_demand_throughput: option.Option(OnDemandThroughput),
    projection: option.Option(Projection),
    provisioned_throughput: option.Option(ProvisionedThroughputDescription),
    warm_throughput: option.Option(
      GlobalSecondaryIndexWarmThroughputDescription,
    ),
  )
}

pub fn encode_global_secondary_index_description_struct(
  input: GlobalSecondaryIndexDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.backfilling {
    option.Some(v) -> [#("Backfilling", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_arn {
    option.Some(v) -> [#("IndexArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_size_bytes {
    option.Some(v) -> [#("IndexSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_status {
    option.Some(v) -> [#("IndexStatus", encode_index_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.item_count {
    option.Some(v) -> [#("ItemCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection {
    option.Some(v) -> [#("Projection", encode_projection_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #(
        "ProvisionedThroughput",
        encode_provisioned_throughput_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #(
        "WarmThroughput",
        encode_global_secondary_index_warm_throughput_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_secondary_index_description_struct() -> decode.Decoder(
  GlobalSecondaryIndexDescription,
) {
  use backfilling <- decode.optional_field(
    "Backfilling",
    option.None,
    decode.optional(decode.bool),
  )
  use index_arn <- decode.optional_field(
    "IndexArn",
    option.None,
    decode.optional(decode.string),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use index_size_bytes <- decode.optional_field(
    "IndexSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  use index_status <- decode.optional_field(
    "IndexStatus",
    option.None,
    decode.optional(decode_index_status_enum()),
  )
  use item_count <- decode.optional_field(
    "ItemCount",
    option.None,
    decode.optional(decode.int),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use projection <- decode.optional_field(
    "Projection",
    option.None,
    decode.optional(decode_projection_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_description_struct()),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(
      decode_global_secondary_index_warm_throughput_description_struct(),
    ),
  )
  decode.success(GlobalSecondaryIndexDescription(
    backfilling: backfilling,
    index_arn: index_arn,
    index_name: index_name,
    index_size_bytes: index_size_bytes,
    index_status: index_status,
    item_count: item_count,
    key_schema: key_schema,
    on_demand_throughput: on_demand_throughput,
    projection: projection,
    provisioned_throughput: provisioned_throughput,
    warm_throughput: warm_throughput,
  ))
}

pub type ProvisionedThroughputDescription {
  ProvisionedThroughputDescription(
    last_decrease_date_time: option.Option(Int),
    last_increase_date_time: option.Option(Int),
    number_of_decreases_today: option.Option(Int),
    read_capacity_units: option.Option(Int),
    write_capacity_units: option.Option(Int),
  )
}

pub fn encode_provisioned_throughput_description_struct(
  input: ProvisionedThroughputDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.last_decrease_date_time {
    option.Some(v) -> [#("LastDecreaseDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_increase_date_time {
    option.Some(v) -> [#("LastIncreaseDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.number_of_decreases_today {
    option.Some(v) -> [#("NumberOfDecreasesToday", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.read_capacity_units {
    option.Some(v) -> [#("ReadCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.write_capacity_units {
    option.Some(v) -> [#("WriteCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_provisioned_throughput_description_struct() -> decode.Decoder(
  ProvisionedThroughputDescription,
) {
  use last_decrease_date_time <- decode.optional_field(
    "LastDecreaseDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use last_increase_date_time <- decode.optional_field(
    "LastIncreaseDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use number_of_decreases_today <- decode.optional_field(
    "NumberOfDecreasesToday",
    option.None,
    decode.optional(decode.int),
  )
  use read_capacity_units <- decode.optional_field(
    "ReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use write_capacity_units <- decode.optional_field(
    "WriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ProvisionedThroughputDescription(
    last_decrease_date_time: last_decrease_date_time,
    last_increase_date_time: last_increase_date_time,
    number_of_decreases_today: number_of_decreases_today,
    read_capacity_units: read_capacity_units,
    write_capacity_units: write_capacity_units,
  ))
}

pub type GlobalTableWitnessDescription {
  GlobalTableWitnessDescription(
    region_name: option.Option(String),
    witness_status: option.Option(WitnessStatus),
  )
}

pub fn encode_global_table_witness_description_struct(
  input: GlobalTableWitnessDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.witness_status {
    option.Some(v) -> [
      #("WitnessStatus", encode_witness_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_table_witness_description_struct() -> decode.Decoder(
  GlobalTableWitnessDescription,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use witness_status <- decode.optional_field(
    "WitnessStatus",
    option.None,
    decode.optional(decode_witness_status_enum()),
  )
  decode.success(GlobalTableWitnessDescription(
    region_name: region_name,
    witness_status: witness_status,
  ))
}

pub type WitnessStatus {
  WitnessStatusActive
  WitnessStatusCreating
  WitnessStatusDeleting
}

pub fn encode_witness_status_enum(v: WitnessStatus) -> json.Json {
  case v {
    WitnessStatusActive -> json.string("ACTIVE")
    WitnessStatusCreating -> json.string("CREATING")
    WitnessStatusDeleting -> json.string("DELETING")
  }
}

pub fn decode_witness_status_enum() -> decode.Decoder(WitnessStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "ACTIVE" -> decode.success(WitnessStatusActive)
      "CREATING" -> decode.success(WitnessStatusCreating)
      "DELETING" -> decode.success(WitnessStatusDeleting)
      _ -> decode.failure(WitnessStatusActive, "unknown enum value")
    }
  })
}

pub type LocalSecondaryIndexDescription {
  LocalSecondaryIndexDescription(
    index_arn: option.Option(String),
    index_name: option.Option(String),
    index_size_bytes: option.Option(Int),
    item_count: option.Option(Int),
    key_schema: option.Option(List(KeySchemaElement)),
    projection: option.Option(Projection),
  )
}

pub fn encode_local_secondary_index_description_struct(
  input: LocalSecondaryIndexDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_arn {
    option.Some(v) -> [#("IndexArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_size_bytes {
    option.Some(v) -> [#("IndexSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.item_count {
    option.Some(v) -> [#("ItemCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection {
    option.Some(v) -> [#("Projection", encode_projection_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_local_secondary_index_description_struct() -> decode.Decoder(
  LocalSecondaryIndexDescription,
) {
  use index_arn <- decode.optional_field(
    "IndexArn",
    option.None,
    decode.optional(decode.string),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use index_size_bytes <- decode.optional_field(
    "IndexSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  use item_count <- decode.optional_field(
    "ItemCount",
    option.None,
    decode.optional(decode.int),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use projection <- decode.optional_field(
    "Projection",
    option.None,
    decode.optional(decode_projection_struct()),
  )
  decode.success(LocalSecondaryIndexDescription(
    index_arn: index_arn,
    index_name: index_name,
    index_size_bytes: index_size_bytes,
    item_count: item_count,
    key_schema: key_schema,
    projection: projection,
  ))
}

pub type MultiRegionConsistency {
  MultiRegionConsistencyEventual
  MultiRegionConsistencyStrong
}

pub fn encode_multi_region_consistency_enum(
  v: MultiRegionConsistency,
) -> json.Json {
  case v {
    MultiRegionConsistencyEventual -> json.string("EVENTUAL")
    MultiRegionConsistencyStrong -> json.string("STRONG")
  }
}

pub fn decode_multi_region_consistency_enum() -> decode.Decoder(
  MultiRegionConsistency,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "EVENTUAL" -> decode.success(MultiRegionConsistencyEventual)
      "STRONG" -> decode.success(MultiRegionConsistencyStrong)
      _ -> decode.failure(MultiRegionConsistencyEventual, "unknown enum value")
    }
  })
}

pub type RestoreSummary {
  RestoreSummary(
    restore_date_time: option.Option(Int),
    restore_in_progress: option.Option(Bool),
    source_backup_arn: option.Option(String),
    source_table_arn: option.Option(String),
  )
}

pub fn encode_restore_summary_struct(input: RestoreSummary) -> json.Json {
  let pairs = []
  let pairs = case input.restore_date_time {
    option.Some(v) -> [#("RestoreDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.restore_in_progress {
    option.Some(v) -> [#("RestoreInProgress", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_backup_arn {
    option.Some(v) -> [#("SourceBackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_table_arn {
    option.Some(v) -> [#("SourceTableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_restore_summary_struct() -> decode.Decoder(RestoreSummary) {
  use restore_date_time <- decode.optional_field(
    "RestoreDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use restore_in_progress <- decode.optional_field(
    "RestoreInProgress",
    option.None,
    decode.optional(decode.bool),
  )
  use source_backup_arn <- decode.optional_field(
    "SourceBackupArn",
    option.None,
    decode.optional(decode.string),
  )
  use source_table_arn <- decode.optional_field(
    "SourceTableArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(RestoreSummary(
    restore_date_time: restore_date_time,
    restore_in_progress: restore_in_progress,
    source_backup_arn: source_backup_arn,
    source_table_arn: source_table_arn,
  ))
}

pub type SSEDescription {
  SSEDescription(
    inaccessible_encryption_date_time: option.Option(Int),
    kms_master_key_arn: option.Option(String),
    sse_type: option.Option(SSEType),
    status: option.Option(SSEStatus),
  )
}

pub fn encode_sse_description_struct(input: SSEDescription) -> json.Json {
  let pairs = []
  let pairs = case input.inaccessible_encryption_date_time {
    option.Some(v) -> [
      #("InaccessibleEncryptionDateTime", json.int(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.kms_master_key_arn {
    option.Some(v) -> [#("KMSMasterKeyArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_type {
    option.Some(v) -> [#("SSEType", encode_sse_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [#("Status", encode_sse_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_sse_description_struct() -> decode.Decoder(SSEDescription) {
  use inaccessible_encryption_date_time <- decode.optional_field(
    "InaccessibleEncryptionDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use kms_master_key_arn <- decode.optional_field(
    "KMSMasterKeyArn",
    option.None,
    decode.optional(decode.string),
  )
  use sse_type <- decode.optional_field(
    "SSEType",
    option.None,
    decode.optional(decode_sse_type_enum()),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_sse_status_enum()),
  )
  decode.success(SSEDescription(
    inaccessible_encryption_date_time: inaccessible_encryption_date_time,
    kms_master_key_arn: kms_master_key_arn,
    sse_type: sse_type,
    status: status,
  ))
}

pub type SSEStatus {
  SSEStatusDisabled
  SSEStatusDisabling
  SSEStatusEnabled
  SSEStatusEnabling
  SSEStatusUpdating
}

pub fn encode_sse_status_enum(v: SSEStatus) -> json.Json {
  case v {
    SSEStatusDisabled -> json.string("DISABLED")
    SSEStatusDisabling -> json.string("DISABLING")
    SSEStatusEnabled -> json.string("ENABLED")
    SSEStatusEnabling -> json.string("ENABLING")
    SSEStatusUpdating -> json.string("UPDATING")
  }
}

pub fn decode_sse_status_enum() -> decode.Decoder(SSEStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(SSEStatusDisabled)
      "DISABLING" -> decode.success(SSEStatusDisabling)
      "ENABLED" -> decode.success(SSEStatusEnabled)
      "ENABLING" -> decode.success(SSEStatusEnabling)
      "UPDATING" -> decode.success(SSEStatusUpdating)
      _ -> decode.failure(SSEStatusDisabled, "unknown enum value")
    }
  })
}

pub type DeleteBackupInput {
  DeleteBackupInput(backup_arn: option.Option(String))
}

pub fn encode_delete_backup_input_struct(
  input: DeleteBackupInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_arn {
    option.Some(v) -> [#("BackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_backup_input_struct() -> decode.Decoder(DeleteBackupInput) {
  use backup_arn <- decode.optional_field(
    "BackupArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBackupInput(backup_arn: backup_arn))
}

pub type DeleteBackupOutput {
  DeleteBackupOutput(backup_description: option.Option(BackupDescription))
}

pub fn encode_delete_backup_output_struct(
  input: DeleteBackupOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_description {
    option.Some(v) -> [
      #("BackupDescription", encode_backup_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_backup_output_struct() -> decode.Decoder(
  DeleteBackupOutput,
) {
  use backup_description <- decode.optional_field(
    "BackupDescription",
    option.None,
    decode.optional(decode_backup_description_struct()),
  )
  decode.success(DeleteBackupOutput(backup_description: backup_description))
}

pub type BackupDescription {
  BackupDescription(
    backup_details: option.Option(BackupDetails),
    source_table_details: option.Option(SourceTableDetails),
    source_table_feature_details: option.Option(SourceTableFeatureDetails),
  )
}

pub fn encode_backup_description_struct(input: BackupDescription) -> json.Json {
  let pairs = []
  let pairs = case input.backup_details {
    option.Some(v) -> [
      #("BackupDetails", encode_backup_details_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.source_table_details {
    option.Some(v) -> [
      #("SourceTableDetails", encode_source_table_details_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.source_table_feature_details {
    option.Some(v) -> [
      #(
        "SourceTableFeatureDetails",
        encode_source_table_feature_details_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_backup_description_struct() -> decode.Decoder(BackupDescription) {
  use backup_details <- decode.optional_field(
    "BackupDetails",
    option.None,
    decode.optional(decode_backup_details_struct()),
  )
  use source_table_details <- decode.optional_field(
    "SourceTableDetails",
    option.None,
    decode.optional(decode_source_table_details_struct()),
  )
  use source_table_feature_details <- decode.optional_field(
    "SourceTableFeatureDetails",
    option.None,
    decode.optional(decode_source_table_feature_details_struct()),
  )
  decode.success(BackupDescription(
    backup_details: backup_details,
    source_table_details: source_table_details,
    source_table_feature_details: source_table_feature_details,
  ))
}

pub type SourceTableDetails {
  SourceTableDetails(
    billing_mode: option.Option(BillingMode),
    item_count: option.Option(Int),
    key_schema: option.Option(List(KeySchemaElement)),
    on_demand_throughput: option.Option(OnDemandThroughput),
    provisioned_throughput: option.Option(ProvisionedThroughput),
    table_arn: option.Option(String),
    table_creation_date_time: option.Option(Int),
    table_id: option.Option(String),
    table_name: option.Option(String),
    table_size_bytes: option.Option(Int),
  )
}

pub fn encode_source_table_details_struct(
  input: SourceTableDetails,
) -> json.Json {
  let pairs = []
  let pairs = case input.billing_mode {
    option.Some(v) -> [#("BillingMode", encode_billing_mode_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.item_count {
    option.Some(v) -> [#("ItemCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_creation_date_time {
    option.Some(v) -> [#("TableCreationDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_id {
    option.Some(v) -> [#("TableId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_size_bytes {
    option.Some(v) -> [#("TableSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_source_table_details_struct() -> decode.Decoder(
  SourceTableDetails,
) {
  use billing_mode <- decode.optional_field(
    "BillingMode",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use item_count <- decode.optional_field(
    "ItemCount",
    option.None,
    decode.optional(decode.int),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_creation_date_time <- decode.optional_field(
    "TableCreationDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use table_id <- decode.optional_field(
    "TableId",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use table_size_bytes <- decode.optional_field(
    "TableSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(SourceTableDetails(
    billing_mode: billing_mode,
    item_count: item_count,
    key_schema: key_schema,
    on_demand_throughput: on_demand_throughput,
    provisioned_throughput: provisioned_throughput,
    table_arn: table_arn,
    table_creation_date_time: table_creation_date_time,
    table_id: table_id,
    table_name: table_name,
    table_size_bytes: table_size_bytes,
  ))
}

pub type SourceTableFeatureDetails {
  SourceTableFeatureDetails(
    global_secondary_indexes: option.Option(List(GlobalSecondaryIndexInfo)),
    local_secondary_indexes: option.Option(List(LocalSecondaryIndexInfo)),
    sse_description: option.Option(SSEDescription),
    stream_description: option.Option(StreamSpecification),
    time_to_live_description: option.Option(TimeToLiveDescription),
  )
}

pub fn encode_source_table_feature_details_struct(
  input: SourceTableFeatureDetails,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) { json.array(xs, encode_global_secondary_index_info_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.local_secondary_indexes {
    option.Some(v) -> [
      #(
        "LocalSecondaryIndexes",
        fn(xs) { json.array(xs, encode_local_secondary_index_info_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_description {
    option.Some(v) -> [
      #("SSEDescription", encode_sse_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_description {
    option.Some(v) -> [
      #("StreamDescription", encode_stream_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.time_to_live_description {
    option.Some(v) -> [
      #("TimeToLiveDescription", encode_time_to_live_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_source_table_feature_details_struct() -> decode.Decoder(
  SourceTableFeatureDetails,
) {
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(decode.list(decode_global_secondary_index_info_struct())),
  )
  use local_secondary_indexes <- decode.optional_field(
    "LocalSecondaryIndexes",
    option.None,
    decode.optional(decode.list(decode_local_secondary_index_info_struct())),
  )
  use sse_description <- decode.optional_field(
    "SSEDescription",
    option.None,
    decode.optional(decode_sse_description_struct()),
  )
  use stream_description <- decode.optional_field(
    "StreamDescription",
    option.None,
    decode.optional(decode_stream_specification_struct()),
  )
  use time_to_live_description <- decode.optional_field(
    "TimeToLiveDescription",
    option.None,
    decode.optional(decode_time_to_live_description_struct()),
  )
  decode.success(SourceTableFeatureDetails(
    global_secondary_indexes: global_secondary_indexes,
    local_secondary_indexes: local_secondary_indexes,
    sse_description: sse_description,
    stream_description: stream_description,
    time_to_live_description: time_to_live_description,
  ))
}

pub type GlobalSecondaryIndexInfo {
  GlobalSecondaryIndexInfo(
    index_name: option.Option(String),
    key_schema: option.Option(List(KeySchemaElement)),
    on_demand_throughput: option.Option(OnDemandThroughput),
    projection: option.Option(Projection),
    provisioned_throughput: option.Option(ProvisionedThroughput),
  )
}

pub fn encode_global_secondary_index_info_struct(
  input: GlobalSecondaryIndexInfo,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection {
    option.Some(v) -> [#("Projection", encode_projection_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_secondary_index_info_struct() -> decode.Decoder(
  GlobalSecondaryIndexInfo,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use projection <- decode.optional_field(
    "Projection",
    option.None,
    decode.optional(decode_projection_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  decode.success(GlobalSecondaryIndexInfo(
    index_name: index_name,
    key_schema: key_schema,
    on_demand_throughput: on_demand_throughput,
    projection: projection,
    provisioned_throughput: provisioned_throughput,
  ))
}

pub type LocalSecondaryIndexInfo {
  LocalSecondaryIndexInfo(
    index_name: option.Option(String),
    key_schema: option.Option(List(KeySchemaElement)),
    projection: option.Option(Projection),
  )
}

pub fn encode_local_secondary_index_info_struct(
  input: LocalSecondaryIndexInfo,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection {
    option.Some(v) -> [#("Projection", encode_projection_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_local_secondary_index_info_struct() -> decode.Decoder(
  LocalSecondaryIndexInfo,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use projection <- decode.optional_field(
    "Projection",
    option.None,
    decode.optional(decode_projection_struct()),
  )
  decode.success(LocalSecondaryIndexInfo(
    index_name: index_name,
    key_schema: key_schema,
    projection: projection,
  ))
}

pub type TimeToLiveDescription {
  TimeToLiveDescription(
    attribute_name: option.Option(String),
    time_to_live_status: option.Option(TimeToLiveStatus),
  )
}

pub fn encode_time_to_live_description_struct(
  input: TimeToLiveDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_name {
    option.Some(v) -> [#("AttributeName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.time_to_live_status {
    option.Some(v) -> [
      #("TimeToLiveStatus", encode_time_to_live_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_time_to_live_description_struct() -> decode.Decoder(
  TimeToLiveDescription,
) {
  use attribute_name <- decode.optional_field(
    "AttributeName",
    option.None,
    decode.optional(decode.string),
  )
  use time_to_live_status <- decode.optional_field(
    "TimeToLiveStatus",
    option.None,
    decode.optional(decode_time_to_live_status_enum()),
  )
  decode.success(TimeToLiveDescription(
    attribute_name: attribute_name,
    time_to_live_status: time_to_live_status,
  ))
}

pub type TimeToLiveStatus {
  TimeToLiveStatusDisabled
  TimeToLiveStatusDisabling
  TimeToLiveStatusEnabled
  TimeToLiveStatusEnabling
}

pub fn encode_time_to_live_status_enum(v: TimeToLiveStatus) -> json.Json {
  case v {
    TimeToLiveStatusDisabled -> json.string("DISABLED")
    TimeToLiveStatusDisabling -> json.string("DISABLING")
    TimeToLiveStatusEnabled -> json.string("ENABLED")
    TimeToLiveStatusEnabling -> json.string("ENABLING")
  }
}

pub fn decode_time_to_live_status_enum() -> decode.Decoder(TimeToLiveStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(TimeToLiveStatusDisabled)
      "DISABLING" -> decode.success(TimeToLiveStatusDisabling)
      "ENABLED" -> decode.success(TimeToLiveStatusEnabled)
      "ENABLING" -> decode.success(TimeToLiveStatusEnabling)
      _ -> decode.failure(TimeToLiveStatusDisabled, "unknown enum value")
    }
  })
}

pub type DeleteItemInput {
  DeleteItemInput(
    condition_expression: option.Option(String),
    conditional_operator: option.Option(ConditionalOperator),
    expected: option.Option(dict.Dict(String, ExpectedAttributeValue)),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    key: option.Option(dict.Dict(String, AttributeValue)),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    return_item_collection_metrics: option.Option(ReturnItemCollectionMetrics),
    return_values: option.Option(ReturnValue),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    table_name: option.Option(String),
  )
}

pub fn encode_delete_item_input_struct(input: DeleteItemInput) -> json.Json {
  let pairs = []
  let pairs = case input.condition_expression {
    option.Some(v) -> [#("ConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.conditional_operator {
    option.Some(v) -> [
      #("ConditionalOperator", encode_conditional_operator_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expected {
    option.Some(v) -> [
      #(
        "Expected",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_expected_attribute_value_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_item_collection_metrics {
    option.Some(v) -> [
      #(
        "ReturnItemCollectionMetrics",
        encode_return_item_collection_metrics_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values {
    option.Some(v) -> [#("ReturnValues", encode_return_value_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_item_input_struct() -> decode.Decoder(DeleteItemInput) {
  use condition_expression <- decode.optional_field(
    "ConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use conditional_operator <- decode.optional_field(
    "ConditionalOperator",
    option.None,
    decode.optional(decode_conditional_operator_enum()),
  )
  use expected <- decode.optional_field(
    "Expected",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode_expected_attribute_value_struct(),
    )),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use return_item_collection_metrics <- decode.optional_field(
    "ReturnItemCollectionMetrics",
    option.None,
    decode.optional(decode_return_item_collection_metrics_enum()),
  )
  use return_values <- decode.optional_field(
    "ReturnValues",
    option.None,
    decode.optional(decode_return_value_enum()),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteItemInput(
    condition_expression: condition_expression,
    conditional_operator: conditional_operator,
    expected: expected,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    key: key,
    return_consumed_capacity: return_consumed_capacity,
    return_item_collection_metrics: return_item_collection_metrics,
    return_values: return_values,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    table_name: table_name,
  ))
}

pub type ConditionalOperator {
  ConditionalOperatorAnd
  ConditionalOperatorOr
}

pub fn encode_conditional_operator_enum(v: ConditionalOperator) -> json.Json {
  case v {
    ConditionalOperatorAnd -> json.string("AND")
    ConditionalOperatorOr -> json.string("OR")
  }
}

pub fn decode_conditional_operator_enum() -> decode.Decoder(ConditionalOperator) {
  decode.then(decode.string, fn(s) {
    case s {
      "AND" -> decode.success(ConditionalOperatorAnd)
      "OR" -> decode.success(ConditionalOperatorOr)
      _ -> decode.failure(ConditionalOperatorAnd, "unknown enum value")
    }
  })
}

pub type ExpectedAttributeValue {
  ExpectedAttributeValue(
    attribute_value_list: option.Option(List(AttributeValue)),
    comparison_operator: option.Option(ComparisonOperator),
    exists: option.Option(Bool),
    value: option.Option(AttributeValue),
  )
}

pub fn encode_expected_attribute_value_struct(
  input: ExpectedAttributeValue,
) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_value_list {
    option.Some(v) -> [
      #(
        "AttributeValueList",
        fn(xs) { json.array(xs, encode_attribute_value_union) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.comparison_operator {
    option.Some(v) -> [
      #("ComparisonOperator", encode_comparison_operator_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.exists {
    option.Some(v) -> [#("Exists", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.value {
    option.Some(v) -> [#("Value", encode_attribute_value_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_expected_attribute_value_struct() -> decode.Decoder(
  ExpectedAttributeValue,
) {
  use attribute_value_list <- decode.optional_field(
    "AttributeValueList",
    option.None,
    decode.optional(decode.list(decode_attribute_value_union())),
  )
  use comparison_operator <- decode.optional_field(
    "ComparisonOperator",
    option.None,
    decode.optional(decode_comparison_operator_enum()),
  )
  use exists <- decode.optional_field(
    "Exists",
    option.None,
    decode.optional(decode.bool),
  )
  use value <- decode.optional_field(
    "Value",
    option.None,
    decode.optional(decode_attribute_value_union()),
  )
  decode.success(ExpectedAttributeValue(
    attribute_value_list: attribute_value_list,
    comparison_operator: comparison_operator,
    exists: exists,
    value: value,
  ))
}

pub type ComparisonOperator {
  ComparisonOperatorBeginsWith
  ComparisonOperatorBetween
  ComparisonOperatorContains
  ComparisonOperatorEq
  ComparisonOperatorGe
  ComparisonOperatorGt
  ComparisonOperatorIn
  ComparisonOperatorLe
  ComparisonOperatorLt
  ComparisonOperatorNe
  ComparisonOperatorNotContains
  ComparisonOperatorNotNull
  ComparisonOperatorNull
}

pub fn encode_comparison_operator_enum(v: ComparisonOperator) -> json.Json {
  case v {
    ComparisonOperatorBeginsWith -> json.string("BEGINS_WITH")
    ComparisonOperatorBetween -> json.string("BETWEEN")
    ComparisonOperatorContains -> json.string("CONTAINS")
    ComparisonOperatorEq -> json.string("EQ")
    ComparisonOperatorGe -> json.string("GE")
    ComparisonOperatorGt -> json.string("GT")
    ComparisonOperatorIn -> json.string("IN")
    ComparisonOperatorLe -> json.string("LE")
    ComparisonOperatorLt -> json.string("LT")
    ComparisonOperatorNe -> json.string("NE")
    ComparisonOperatorNotContains -> json.string("NOT_CONTAINS")
    ComparisonOperatorNotNull -> json.string("NOT_NULL")
    ComparisonOperatorNull -> json.string("NULL")
  }
}

pub fn decode_comparison_operator_enum() -> decode.Decoder(ComparisonOperator) {
  decode.then(decode.string, fn(s) {
    case s {
      "BEGINS_WITH" -> decode.success(ComparisonOperatorBeginsWith)
      "BETWEEN" -> decode.success(ComparisonOperatorBetween)
      "CONTAINS" -> decode.success(ComparisonOperatorContains)
      "EQ" -> decode.success(ComparisonOperatorEq)
      "GE" -> decode.success(ComparisonOperatorGe)
      "GT" -> decode.success(ComparisonOperatorGt)
      "IN" -> decode.success(ComparisonOperatorIn)
      "LE" -> decode.success(ComparisonOperatorLe)
      "LT" -> decode.success(ComparisonOperatorLt)
      "NE" -> decode.success(ComparisonOperatorNe)
      "NOT_CONTAINS" -> decode.success(ComparisonOperatorNotContains)
      "NOT_NULL" -> decode.success(ComparisonOperatorNotNull)
      "NULL" -> decode.success(ComparisonOperatorNull)
      _ -> decode.failure(ComparisonOperatorBeginsWith, "unknown enum value")
    }
  })
}

pub type ReturnValue {
  ReturnValueAllNew
  ReturnValueAllOld
  ReturnValueNone
  ReturnValueUpdatedNew
  ReturnValueUpdatedOld
}

pub fn encode_return_value_enum(v: ReturnValue) -> json.Json {
  case v {
    ReturnValueAllNew -> json.string("ALL_NEW")
    ReturnValueAllOld -> json.string("ALL_OLD")
    ReturnValueNone -> json.string("NONE")
    ReturnValueUpdatedNew -> json.string("UPDATED_NEW")
    ReturnValueUpdatedOld -> json.string("UPDATED_OLD")
  }
}

pub fn decode_return_value_enum() -> decode.Decoder(ReturnValue) {
  decode.then(decode.string, fn(s) {
    case s {
      "ALL_NEW" -> decode.success(ReturnValueAllNew)
      "ALL_OLD" -> decode.success(ReturnValueAllOld)
      "NONE" -> decode.success(ReturnValueNone)
      "UPDATED_NEW" -> decode.success(ReturnValueUpdatedNew)
      "UPDATED_OLD" -> decode.success(ReturnValueUpdatedOld)
      _ -> decode.failure(ReturnValueAllNew, "unknown enum value")
    }
  })
}

pub type DeleteItemOutput {
  DeleteItemOutput(
    attributes: option.Option(dict.Dict(String, AttributeValue)),
    consumed_capacity: option.Option(ConsumedCapacity),
    item_collection_metrics: option.Option(ItemCollectionMetrics),
  )
}

pub fn encode_delete_item_output_struct(input: DeleteItemOutput) -> json.Json {
  let pairs = []
  let pairs = case input.attributes {
    option.Some(v) -> [
      #(
        "Attributes",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #("ConsumedCapacity", encode_consumed_capacity_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item_collection_metrics {
    option.Some(v) -> [
      #("ItemCollectionMetrics", encode_item_collection_metrics_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_item_output_struct() -> decode.Decoder(DeleteItemOutput) {
  use attributes <- decode.optional_field(
    "Attributes",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode_consumed_capacity_struct()),
  )
  use item_collection_metrics <- decode.optional_field(
    "ItemCollectionMetrics",
    option.None,
    decode.optional(decode_item_collection_metrics_struct()),
  )
  decode.success(DeleteItemOutput(
    attributes: attributes,
    consumed_capacity: consumed_capacity,
    item_collection_metrics: item_collection_metrics,
  ))
}

pub type DeleteResourcePolicyInput {
  DeleteResourcePolicyInput(
    expected_revision_id: option.Option(String),
    resource_arn: option.Option(String),
  )
}

pub fn encode_delete_resource_policy_input_struct(
  input: DeleteResourcePolicyInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.expected_revision_id {
    option.Some(v) -> [#("ExpectedRevisionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.resource_arn {
    option.Some(v) -> [#("ResourceArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_resource_policy_input_struct() -> decode.Decoder(
  DeleteResourcePolicyInput,
) {
  use expected_revision_id <- decode.optional_field(
    "ExpectedRevisionId",
    option.None,
    decode.optional(decode.string),
  )
  use resource_arn <- decode.optional_field(
    "ResourceArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteResourcePolicyInput(
    expected_revision_id: expected_revision_id,
    resource_arn: resource_arn,
  ))
}

pub type DeleteResourcePolicyOutput {
  DeleteResourcePolicyOutput(revision_id: option.Option(String))
}

pub fn encode_delete_resource_policy_output_struct(
  input: DeleteResourcePolicyOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.revision_id {
    option.Some(v) -> [#("RevisionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_resource_policy_output_struct() -> decode.Decoder(
  DeleteResourcePolicyOutput,
) {
  use revision_id <- decode.optional_field(
    "RevisionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteResourcePolicyOutput(revision_id: revision_id))
}

pub type DeleteTableInput {
  DeleteTableInput(table_name: option.Option(String))
}

pub fn encode_delete_table_input_struct(input: DeleteTableInput) -> json.Json {
  let pairs = []
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_table_input_struct() -> decode.Decoder(DeleteTableInput) {
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteTableInput(table_name: table_name))
}

pub type DeleteTableOutput {
  DeleteTableOutput(table_description: option.Option(TableDescription))
}

pub fn encode_delete_table_output_struct(
  input: DeleteTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_description {
    option.Some(v) -> [
      #("TableDescription", encode_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_table_output_struct() -> decode.Decoder(DeleteTableOutput) {
  use table_description <- decode.optional_field(
    "TableDescription",
    option.None,
    decode.optional(decode_table_description_struct()),
  )
  decode.success(DeleteTableOutput(table_description: table_description))
}

pub type DescribeBackupInput {
  DescribeBackupInput(backup_arn: option.Option(String))
}

pub fn encode_describe_backup_input_struct(
  input: DescribeBackupInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_arn {
    option.Some(v) -> [#("BackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_backup_input_struct() -> decode.Decoder(
  DescribeBackupInput,
) {
  use backup_arn <- decode.optional_field(
    "BackupArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeBackupInput(backup_arn: backup_arn))
}

pub type DescribeBackupOutput {
  DescribeBackupOutput(backup_description: option.Option(BackupDescription))
}

pub fn encode_describe_backup_output_struct(
  input: DescribeBackupOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_description {
    option.Some(v) -> [
      #("BackupDescription", encode_backup_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_backup_output_struct() -> decode.Decoder(
  DescribeBackupOutput,
) {
  use backup_description <- decode.optional_field(
    "BackupDescription",
    option.None,
    decode.optional(decode_backup_description_struct()),
  )
  decode.success(DescribeBackupOutput(backup_description: backup_description))
}

pub type DescribeContinuousBackupsInput {
  DescribeContinuousBackupsInput(table_name: option.Option(String))
}

pub fn encode_describe_continuous_backups_input_struct(
  input: DescribeContinuousBackupsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_continuous_backups_input_struct() -> decode.Decoder(
  DescribeContinuousBackupsInput,
) {
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeContinuousBackupsInput(table_name: table_name))
}

pub type DescribeContinuousBackupsOutput {
  DescribeContinuousBackupsOutput(
    continuous_backups_description: option.Option(ContinuousBackupsDescription),
  )
}

pub fn encode_describe_continuous_backups_output_struct(
  input: DescribeContinuousBackupsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.continuous_backups_description {
    option.Some(v) -> [
      #(
        "ContinuousBackupsDescription",
        encode_continuous_backups_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_continuous_backups_output_struct() -> decode.Decoder(
  DescribeContinuousBackupsOutput,
) {
  use continuous_backups_description <- decode.optional_field(
    "ContinuousBackupsDescription",
    option.None,
    decode.optional(decode_continuous_backups_description_struct()),
  )
  decode.success(DescribeContinuousBackupsOutput(
    continuous_backups_description: continuous_backups_description,
  ))
}

pub type ContinuousBackupsDescription {
  ContinuousBackupsDescription(
    continuous_backups_status: option.Option(ContinuousBackupsStatus),
    point_in_time_recovery_description: option.Option(
      PointInTimeRecoveryDescription,
    ),
  )
}

pub fn encode_continuous_backups_description_struct(
  input: ContinuousBackupsDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.continuous_backups_status {
    option.Some(v) -> [
      #("ContinuousBackupsStatus", encode_continuous_backups_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.point_in_time_recovery_description {
    option.Some(v) -> [
      #(
        "PointInTimeRecoveryDescription",
        encode_point_in_time_recovery_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_continuous_backups_description_struct() -> decode.Decoder(
  ContinuousBackupsDescription,
) {
  use continuous_backups_status <- decode.optional_field(
    "ContinuousBackupsStatus",
    option.None,
    decode.optional(decode_continuous_backups_status_enum()),
  )
  use point_in_time_recovery_description <- decode.optional_field(
    "PointInTimeRecoveryDescription",
    option.None,
    decode.optional(decode_point_in_time_recovery_description_struct()),
  )
  decode.success(ContinuousBackupsDescription(
    continuous_backups_status: continuous_backups_status,
    point_in_time_recovery_description: point_in_time_recovery_description,
  ))
}

pub type ContinuousBackupsStatus {
  ContinuousBackupsStatusDisabled
  ContinuousBackupsStatusEnabled
}

pub fn encode_continuous_backups_status_enum(
  v: ContinuousBackupsStatus,
) -> json.Json {
  case v {
    ContinuousBackupsStatusDisabled -> json.string("DISABLED")
    ContinuousBackupsStatusEnabled -> json.string("ENABLED")
  }
}

pub fn decode_continuous_backups_status_enum() -> decode.Decoder(
  ContinuousBackupsStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(ContinuousBackupsStatusDisabled)
      "ENABLED" -> decode.success(ContinuousBackupsStatusEnabled)
      _ -> decode.failure(ContinuousBackupsStatusDisabled, "unknown enum value")
    }
  })
}

pub type PointInTimeRecoveryDescription {
  PointInTimeRecoveryDescription(
    earliest_restorable_date_time: option.Option(Int),
    latest_restorable_date_time: option.Option(Int),
    point_in_time_recovery_status: option.Option(PointInTimeRecoveryStatus),
    recovery_period_in_days: option.Option(Int),
  )
}

pub fn encode_point_in_time_recovery_description_struct(
  input: PointInTimeRecoveryDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.earliest_restorable_date_time {
    option.Some(v) -> [#("EarliestRestorableDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.latest_restorable_date_time {
    option.Some(v) -> [#("LatestRestorableDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.point_in_time_recovery_status {
    option.Some(v) -> [
      #(
        "PointInTimeRecoveryStatus",
        encode_point_in_time_recovery_status_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.recovery_period_in_days {
    option.Some(v) -> [#("RecoveryPeriodInDays", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_point_in_time_recovery_description_struct() -> decode.Decoder(
  PointInTimeRecoveryDescription,
) {
  use earliest_restorable_date_time <- decode.optional_field(
    "EarliestRestorableDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use latest_restorable_date_time <- decode.optional_field(
    "LatestRestorableDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use point_in_time_recovery_status <- decode.optional_field(
    "PointInTimeRecoveryStatus",
    option.None,
    decode.optional(decode_point_in_time_recovery_status_enum()),
  )
  use recovery_period_in_days <- decode.optional_field(
    "RecoveryPeriodInDays",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(PointInTimeRecoveryDescription(
    earliest_restorable_date_time: earliest_restorable_date_time,
    latest_restorable_date_time: latest_restorable_date_time,
    point_in_time_recovery_status: point_in_time_recovery_status,
    recovery_period_in_days: recovery_period_in_days,
  ))
}

pub type PointInTimeRecoveryStatus {
  PointInTimeRecoveryStatusDisabled
  PointInTimeRecoveryStatusEnabled
}

pub fn encode_point_in_time_recovery_status_enum(
  v: PointInTimeRecoveryStatus,
) -> json.Json {
  case v {
    PointInTimeRecoveryStatusDisabled -> json.string("DISABLED")
    PointInTimeRecoveryStatusEnabled -> json.string("ENABLED")
  }
}

pub fn decode_point_in_time_recovery_status_enum() -> decode.Decoder(
  PointInTimeRecoveryStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(PointInTimeRecoveryStatusDisabled)
      "ENABLED" -> decode.success(PointInTimeRecoveryStatusEnabled)
      _ ->
        decode.failure(PointInTimeRecoveryStatusDisabled, "unknown enum value")
    }
  })
}

pub type DescribeContributorInsightsInput {
  DescribeContributorInsightsInput(
    index_name: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_describe_contributor_insights_input_struct(
  input: DescribeContributorInsightsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_contributor_insights_input_struct() -> decode.Decoder(
  DescribeContributorInsightsInput,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeContributorInsightsInput(
    index_name: index_name,
    table_name: table_name,
  ))
}

pub type DescribeContributorInsightsOutput {
  DescribeContributorInsightsOutput(
    contributor_insights_mode: option.Option(ContributorInsightsMode),
    contributor_insights_rule_list: option.Option(List(String)),
    contributor_insights_status: option.Option(ContributorInsightsStatus),
    failure_exception: option.Option(FailureException),
    index_name: option.Option(String),
    last_update_date_time: option.Option(Int),
    table_name: option.Option(String),
  )
}

pub fn encode_describe_contributor_insights_output_struct(
  input: DescribeContributorInsightsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.contributor_insights_mode {
    option.Some(v) -> [
      #("ContributorInsightsMode", encode_contributor_insights_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.contributor_insights_rule_list {
    option.Some(v) -> [
      #(
        "ContributorInsightsRuleList",
        fn(xs) { json.array(xs, json.string) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.contributor_insights_status {
    option.Some(v) -> [
      #("ContributorInsightsStatus", encode_contributor_insights_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.failure_exception {
    option.Some(v) -> [
      #("FailureException", encode_failure_exception_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_update_date_time {
    option.Some(v) -> [#("LastUpdateDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_contributor_insights_output_struct() -> decode.Decoder(
  DescribeContributorInsightsOutput,
) {
  use contributor_insights_mode <- decode.optional_field(
    "ContributorInsightsMode",
    option.None,
    decode.optional(decode_contributor_insights_mode_enum()),
  )
  use contributor_insights_rule_list <- decode.optional_field(
    "ContributorInsightsRuleList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use contributor_insights_status <- decode.optional_field(
    "ContributorInsightsStatus",
    option.None,
    decode.optional(decode_contributor_insights_status_enum()),
  )
  use failure_exception <- decode.optional_field(
    "FailureException",
    option.None,
    decode.optional(decode_failure_exception_struct()),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use last_update_date_time <- decode.optional_field(
    "LastUpdateDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeContributorInsightsOutput(
    contributor_insights_mode: contributor_insights_mode,
    contributor_insights_rule_list: contributor_insights_rule_list,
    contributor_insights_status: contributor_insights_status,
    failure_exception: failure_exception,
    index_name: index_name,
    last_update_date_time: last_update_date_time,
    table_name: table_name,
  ))
}

pub type ContributorInsightsMode {
  ContributorInsightsModeAccessedAndThrottledKeys
  ContributorInsightsModeThrottledKeys
}

pub fn encode_contributor_insights_mode_enum(
  v: ContributorInsightsMode,
) -> json.Json {
  case v {
    ContributorInsightsModeAccessedAndThrottledKeys ->
      json.string("ACCESSED_AND_THROTTLED_KEYS")
    ContributorInsightsModeThrottledKeys -> json.string("THROTTLED_KEYS")
  }
}

pub fn decode_contributor_insights_mode_enum() -> decode.Decoder(
  ContributorInsightsMode,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "ACCESSED_AND_THROTTLED_KEYS" ->
        decode.success(ContributorInsightsModeAccessedAndThrottledKeys)
      "THROTTLED_KEYS" -> decode.success(ContributorInsightsModeThrottledKeys)
      _ ->
        decode.failure(
          ContributorInsightsModeAccessedAndThrottledKeys,
          "unknown enum value",
        )
    }
  })
}

pub type ContributorInsightsStatus {
  ContributorInsightsStatusDisabled
  ContributorInsightsStatusDisabling
  ContributorInsightsStatusEnabled
  ContributorInsightsStatusEnabling
  ContributorInsightsStatusFailed
}

pub fn encode_contributor_insights_status_enum(
  v: ContributorInsightsStatus,
) -> json.Json {
  case v {
    ContributorInsightsStatusDisabled -> json.string("DISABLED")
    ContributorInsightsStatusDisabling -> json.string("DISABLING")
    ContributorInsightsStatusEnabled -> json.string("ENABLED")
    ContributorInsightsStatusEnabling -> json.string("ENABLING")
    ContributorInsightsStatusFailed -> json.string("FAILED")
  }
}

pub fn decode_contributor_insights_status_enum() -> decode.Decoder(
  ContributorInsightsStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(ContributorInsightsStatusDisabled)
      "DISABLING" -> decode.success(ContributorInsightsStatusDisabling)
      "ENABLED" -> decode.success(ContributorInsightsStatusEnabled)
      "ENABLING" -> decode.success(ContributorInsightsStatusEnabling)
      "FAILED" -> decode.success(ContributorInsightsStatusFailed)
      _ ->
        decode.failure(ContributorInsightsStatusDisabled, "unknown enum value")
    }
  })
}

pub type FailureException {
  FailureException(
    exception_description: option.Option(String),
    exception_name: option.Option(String),
  )
}

pub fn encode_failure_exception_struct(input: FailureException) -> json.Json {
  let pairs = []
  let pairs = case input.exception_description {
    option.Some(v) -> [#("ExceptionDescription", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.exception_name {
    option.Some(v) -> [#("ExceptionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_failure_exception_struct() -> decode.Decoder(FailureException) {
  use exception_description <- decode.optional_field(
    "ExceptionDescription",
    option.None,
    decode.optional(decode.string),
  )
  use exception_name <- decode.optional_field(
    "ExceptionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(FailureException(
    exception_description: exception_description,
    exception_name: exception_name,
  ))
}

pub type DescribeEndpointsRequest {
  DescribeEndpointsRequest
}

pub fn encode_describe_endpoints_request_struct(
  _v: DescribeEndpointsRequest,
) -> json.Json {
  json.object([])
}

pub fn decode_describe_endpoints_request_struct() -> decode.Decoder(
  DescribeEndpointsRequest,
) {
  decode.success(DescribeEndpointsRequest)
}

pub type DescribeEndpointsResponse {
  DescribeEndpointsResponse(endpoints: option.Option(List(Endpoint)))
}

pub fn encode_describe_endpoints_response_struct(
  input: DescribeEndpointsResponse,
) -> json.Json {
  let pairs = []
  let pairs = case input.endpoints {
    option.Some(v) -> [
      #("Endpoints", fn(xs) { json.array(xs, encode_endpoint_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_endpoints_response_struct() -> decode.Decoder(
  DescribeEndpointsResponse,
) {
  use endpoints <- decode.optional_field(
    "Endpoints",
    option.None,
    decode.optional(decode.list(decode_endpoint_struct())),
  )
  decode.success(DescribeEndpointsResponse(endpoints: endpoints))
}

pub type Endpoint {
  Endpoint(
    address: option.Option(String),
    cache_period_in_minutes: option.Option(Int),
  )
}

pub fn encode_endpoint_struct(input: Endpoint) -> json.Json {
  let pairs = []
  let pairs = case input.address {
    option.Some(v) -> [#("Address", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.cache_period_in_minutes {
    option.Some(v) -> [#("CachePeriodInMinutes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_endpoint_struct() -> decode.Decoder(Endpoint) {
  use address <- decode.optional_field(
    "Address",
    option.None,
    decode.optional(decode.string),
  )
  use cache_period_in_minutes <- decode.optional_field(
    "CachePeriodInMinutes",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(Endpoint(
    address: address,
    cache_period_in_minutes: cache_period_in_minutes,
  ))
}

pub type DescribeExportInput {
  DescribeExportInput(export_arn: option.Option(String))
}

pub fn encode_describe_export_input_struct(
  input: DescribeExportInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.export_arn {
    option.Some(v) -> [#("ExportArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_export_input_struct() -> decode.Decoder(
  DescribeExportInput,
) {
  use export_arn <- decode.optional_field(
    "ExportArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeExportInput(export_arn: export_arn))
}

pub type DescribeExportOutput {
  DescribeExportOutput(export_description: option.Option(ExportDescription))
}

pub fn encode_describe_export_output_struct(
  input: DescribeExportOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.export_description {
    option.Some(v) -> [
      #("ExportDescription", encode_export_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_export_output_struct() -> decode.Decoder(
  DescribeExportOutput,
) {
  use export_description <- decode.optional_field(
    "ExportDescription",
    option.None,
    decode.optional(decode_export_description_struct()),
  )
  decode.success(DescribeExportOutput(export_description: export_description))
}

pub type ExportDescription {
  ExportDescription(
    billed_size_bytes: option.Option(Int),
    client_token: option.Option(String),
    end_time: option.Option(Int),
    export_arn: option.Option(String),
    export_format: option.Option(ExportFormat),
    export_manifest: option.Option(String),
    export_status: option.Option(ExportStatus),
    export_time: option.Option(Int),
    export_type: option.Option(ExportType),
    failure_code: option.Option(String),
    failure_message: option.Option(String),
    incremental_export_specification: option.Option(
      IncrementalExportSpecification,
    ),
    item_count: option.Option(Int),
    s3_bucket: option.Option(String),
    s3_bucket_owner: option.Option(String),
    s3_prefix: option.Option(String),
    s3_sse_algorithm: option.Option(S3SseAlgorithm),
    s3_sse_kms_key_id: option.Option(String),
    start_time: option.Option(Int),
    table_arn: option.Option(String),
    table_id: option.Option(String),
  )
}

pub fn encode_export_description_struct(input: ExportDescription) -> json.Json {
  let pairs = []
  let pairs = case input.billed_size_bytes {
    option.Some(v) -> [#("BilledSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.client_token {
    option.Some(v) -> [#("ClientToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.end_time {
    option.Some(v) -> [#("EndTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_arn {
    option.Some(v) -> [#("ExportArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_format {
    option.Some(v) -> [#("ExportFormat", encode_export_format_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_manifest {
    option.Some(v) -> [#("ExportManifest", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_status {
    option.Some(v) -> [#("ExportStatus", encode_export_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_time {
    option.Some(v) -> [#("ExportTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_type {
    option.Some(v) -> [#("ExportType", encode_export_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.failure_code {
    option.Some(v) -> [#("FailureCode", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.failure_message {
    option.Some(v) -> [#("FailureMessage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.incremental_export_specification {
    option.Some(v) -> [
      #(
        "IncrementalExportSpecification",
        encode_incremental_export_specification_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item_count {
    option.Some(v) -> [#("ItemCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket {
    option.Some(v) -> [#("S3Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket_owner {
    option.Some(v) -> [#("S3BucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_prefix {
    option.Some(v) -> [#("S3Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_sse_algorithm {
    option.Some(v) -> [
      #("S3SseAlgorithm", encode_s3_sse_algorithm_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.s3_sse_kms_key_id {
    option.Some(v) -> [#("S3SseKmsKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.start_time {
    option.Some(v) -> [#("StartTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_id {
    option.Some(v) -> [#("TableId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_export_description_struct() -> decode.Decoder(ExportDescription) {
  use billed_size_bytes <- decode.optional_field(
    "BilledSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  use client_token <- decode.optional_field(
    "ClientToken",
    option.None,
    decode.optional(decode.string),
  )
  use end_time <- decode.optional_field(
    "EndTime",
    option.None,
    decode.optional(decode.int),
  )
  use export_arn <- decode.optional_field(
    "ExportArn",
    option.None,
    decode.optional(decode.string),
  )
  use export_format <- decode.optional_field(
    "ExportFormat",
    option.None,
    decode.optional(decode_export_format_enum()),
  )
  use export_manifest <- decode.optional_field(
    "ExportManifest",
    option.None,
    decode.optional(decode.string),
  )
  use export_status <- decode.optional_field(
    "ExportStatus",
    option.None,
    decode.optional(decode_export_status_enum()),
  )
  use export_time <- decode.optional_field(
    "ExportTime",
    option.None,
    decode.optional(decode.int),
  )
  use export_type <- decode.optional_field(
    "ExportType",
    option.None,
    decode.optional(decode_export_type_enum()),
  )
  use failure_code <- decode.optional_field(
    "FailureCode",
    option.None,
    decode.optional(decode.string),
  )
  use failure_message <- decode.optional_field(
    "FailureMessage",
    option.None,
    decode.optional(decode.string),
  )
  use incremental_export_specification <- decode.optional_field(
    "IncrementalExportSpecification",
    option.None,
    decode.optional(decode_incremental_export_specification_struct()),
  )
  use item_count <- decode.optional_field(
    "ItemCount",
    option.None,
    decode.optional(decode.int),
  )
  use s3_bucket <- decode.optional_field(
    "S3Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use s3_bucket_owner <- decode.optional_field(
    "S3BucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use s3_prefix <- decode.optional_field(
    "S3Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use s3_sse_algorithm <- decode.optional_field(
    "S3SseAlgorithm",
    option.None,
    decode.optional(decode_s3_sse_algorithm_enum()),
  )
  use s3_sse_kms_key_id <- decode.optional_field(
    "S3SseKmsKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use start_time <- decode.optional_field(
    "StartTime",
    option.None,
    decode.optional(decode.int),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_id <- decode.optional_field(
    "TableId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ExportDescription(
    billed_size_bytes: billed_size_bytes,
    client_token: client_token,
    end_time: end_time,
    export_arn: export_arn,
    export_format: export_format,
    export_manifest: export_manifest,
    export_status: export_status,
    export_time: export_time,
    export_type: export_type,
    failure_code: failure_code,
    failure_message: failure_message,
    incremental_export_specification: incremental_export_specification,
    item_count: item_count,
    s3_bucket: s3_bucket,
    s3_bucket_owner: s3_bucket_owner,
    s3_prefix: s3_prefix,
    s3_sse_algorithm: s3_sse_algorithm,
    s3_sse_kms_key_id: s3_sse_kms_key_id,
    start_time: start_time,
    table_arn: table_arn,
    table_id: table_id,
  ))
}

pub type ExportFormat {
  ExportFormatDynamodbJson
  ExportFormatIon
}

pub fn encode_export_format_enum(v: ExportFormat) -> json.Json {
  case v {
    ExportFormatDynamodbJson -> json.string("DYNAMODB_JSON")
    ExportFormatIon -> json.string("ION")
  }
}

pub fn decode_export_format_enum() -> decode.Decoder(ExportFormat) {
  decode.then(decode.string, fn(s) {
    case s {
      "DYNAMODB_JSON" -> decode.success(ExportFormatDynamodbJson)
      "ION" -> decode.success(ExportFormatIon)
      _ -> decode.failure(ExportFormatDynamodbJson, "unknown enum value")
    }
  })
}

pub type ExportStatus {
  ExportStatusCompleted
  ExportStatusFailed
  ExportStatusInProgress
}

pub fn encode_export_status_enum(v: ExportStatus) -> json.Json {
  case v {
    ExportStatusCompleted -> json.string("COMPLETED")
    ExportStatusFailed -> json.string("FAILED")
    ExportStatusInProgress -> json.string("IN_PROGRESS")
  }
}

pub fn decode_export_status_enum() -> decode.Decoder(ExportStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "COMPLETED" -> decode.success(ExportStatusCompleted)
      "FAILED" -> decode.success(ExportStatusFailed)
      "IN_PROGRESS" -> decode.success(ExportStatusInProgress)
      _ -> decode.failure(ExportStatusCompleted, "unknown enum value")
    }
  })
}

pub type ExportType {
  ExportTypeFullExport
  ExportTypeIncrementalExport
}

pub fn encode_export_type_enum(v: ExportType) -> json.Json {
  case v {
    ExportTypeFullExport -> json.string("FULL_EXPORT")
    ExportTypeIncrementalExport -> json.string("INCREMENTAL_EXPORT")
  }
}

pub fn decode_export_type_enum() -> decode.Decoder(ExportType) {
  decode.then(decode.string, fn(s) {
    case s {
      "FULL_EXPORT" -> decode.success(ExportTypeFullExport)
      "INCREMENTAL_EXPORT" -> decode.success(ExportTypeIncrementalExport)
      _ -> decode.failure(ExportTypeFullExport, "unknown enum value")
    }
  })
}

pub type IncrementalExportSpecification {
  IncrementalExportSpecification(
    export_from_time: option.Option(Int),
    export_to_time: option.Option(Int),
    export_view_type: option.Option(ExportViewType),
  )
}

pub fn encode_incremental_export_specification_struct(
  input: IncrementalExportSpecification,
) -> json.Json {
  let pairs = []
  let pairs = case input.export_from_time {
    option.Some(v) -> [#("ExportFromTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_to_time {
    option.Some(v) -> [#("ExportToTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_view_type {
    option.Some(v) -> [
      #("ExportViewType", encode_export_view_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_incremental_export_specification_struct() -> decode.Decoder(
  IncrementalExportSpecification,
) {
  use export_from_time <- decode.optional_field(
    "ExportFromTime",
    option.None,
    decode.optional(decode.int),
  )
  use export_to_time <- decode.optional_field(
    "ExportToTime",
    option.None,
    decode.optional(decode.int),
  )
  use export_view_type <- decode.optional_field(
    "ExportViewType",
    option.None,
    decode.optional(decode_export_view_type_enum()),
  )
  decode.success(IncrementalExportSpecification(
    export_from_time: export_from_time,
    export_to_time: export_to_time,
    export_view_type: export_view_type,
  ))
}

pub type ExportViewType {
  ExportViewTypeNewAndOldImages
  ExportViewTypeNewImage
}

pub fn encode_export_view_type_enum(v: ExportViewType) -> json.Json {
  case v {
    ExportViewTypeNewAndOldImages -> json.string("NEW_AND_OLD_IMAGES")
    ExportViewTypeNewImage -> json.string("NEW_IMAGE")
  }
}

pub fn decode_export_view_type_enum() -> decode.Decoder(ExportViewType) {
  decode.then(decode.string, fn(s) {
    case s {
      "NEW_AND_OLD_IMAGES" -> decode.success(ExportViewTypeNewAndOldImages)
      "NEW_IMAGE" -> decode.success(ExportViewTypeNewImage)
      _ -> decode.failure(ExportViewTypeNewAndOldImages, "unknown enum value")
    }
  })
}

pub type S3SseAlgorithm {
  S3SseAlgorithmAes256
  S3SseAlgorithmKms
}

pub fn encode_s3_sse_algorithm_enum(v: S3SseAlgorithm) -> json.Json {
  case v {
    S3SseAlgorithmAes256 -> json.string("AES256")
    S3SseAlgorithmKms -> json.string("KMS")
  }
}

pub fn decode_s3_sse_algorithm_enum() -> decode.Decoder(S3SseAlgorithm) {
  decode.then(decode.string, fn(s) {
    case s {
      "AES256" -> decode.success(S3SseAlgorithmAes256)
      "KMS" -> decode.success(S3SseAlgorithmKms)
      _ -> decode.failure(S3SseAlgorithmAes256, "unknown enum value")
    }
  })
}

pub type DescribeGlobalTableInput {
  DescribeGlobalTableInput(global_table_name: option.Option(String))
}

pub fn encode_describe_global_table_input_struct(
  input: DescribeGlobalTableInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_global_table_input_struct() -> decode.Decoder(
  DescribeGlobalTableInput,
) {
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeGlobalTableInput(global_table_name: global_table_name))
}

pub type DescribeGlobalTableOutput {
  DescribeGlobalTableOutput(
    global_table_description: option.Option(GlobalTableDescription),
  )
}

pub fn encode_describe_global_table_output_struct(
  input: DescribeGlobalTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_description {
    option.Some(v) -> [
      #("GlobalTableDescription", encode_global_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_global_table_output_struct() -> decode.Decoder(
  DescribeGlobalTableOutput,
) {
  use global_table_description <- decode.optional_field(
    "GlobalTableDescription",
    option.None,
    decode.optional(decode_global_table_description_struct()),
  )
  decode.success(DescribeGlobalTableOutput(
    global_table_description: global_table_description,
  ))
}

pub type DescribeGlobalTableSettingsInput {
  DescribeGlobalTableSettingsInput(global_table_name: option.Option(String))
}

pub fn encode_describe_global_table_settings_input_struct(
  input: DescribeGlobalTableSettingsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_global_table_settings_input_struct() -> decode.Decoder(
  DescribeGlobalTableSettingsInput,
) {
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeGlobalTableSettingsInput(
    global_table_name: global_table_name,
  ))
}

pub type DescribeGlobalTableSettingsOutput {
  DescribeGlobalTableSettingsOutput(
    global_table_name: option.Option(String),
    replica_settings: option.Option(List(ReplicaSettingsDescription)),
  )
}

pub fn encode_describe_global_table_settings_output_struct(
  input: DescribeGlobalTableSettingsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_settings {
    option.Some(v) -> [
      #(
        "ReplicaSettings",
        fn(xs) { json.array(xs, encode_replica_settings_description_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_global_table_settings_output_struct() -> decode.Decoder(
  DescribeGlobalTableSettingsOutput,
) {
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_settings <- decode.optional_field(
    "ReplicaSettings",
    option.None,
    decode.optional(decode.list(decode_replica_settings_description_struct())),
  )
  decode.success(DescribeGlobalTableSettingsOutput(
    global_table_name: global_table_name,
    replica_settings: replica_settings,
  ))
}

pub type ReplicaSettingsDescription {
  ReplicaSettingsDescription(
    region_name: option.Option(String),
    replica_billing_mode_summary: option.Option(BillingModeSummary),
    replica_global_secondary_index_settings: option.Option(
      List(ReplicaGlobalSecondaryIndexSettingsDescription),
    ),
    replica_provisioned_read_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
    replica_provisioned_read_capacity_units: option.Option(Int),
    replica_provisioned_write_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
    replica_provisioned_write_capacity_units: option.Option(Int),
    replica_status: option.Option(ReplicaStatus),
    replica_table_class_summary: option.Option(TableClassSummary),
  )
}

pub fn encode_replica_settings_description_struct(
  input: ReplicaSettingsDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_billing_mode_summary {
    option.Some(v) -> [
      #("ReplicaBillingModeSummary", encode_billing_mode_summary_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_global_secondary_index_settings {
    option.Some(v) -> [
      #(
        "ReplicaGlobalSecondaryIndexSettings",
        fn(xs) {
          json.array(
            xs,
            encode_replica_global_secondary_index_settings_description_struct,
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case
    input.replica_provisioned_read_capacity_auto_scaling_settings
  {
    option.Some(v) -> [
      #(
        "ReplicaProvisionedReadCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_provisioned_read_capacity_units {
    option.Some(v) -> [
      #("ReplicaProvisionedReadCapacityUnits", json.int(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case
    input.replica_provisioned_write_capacity_auto_scaling_settings
  {
    option.Some(v) -> [
      #(
        "ReplicaProvisionedWriteCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_provisioned_write_capacity_units {
    option.Some(v) -> [
      #("ReplicaProvisionedWriteCapacityUnits", json.int(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_status {
    option.Some(v) -> [
      #("ReplicaStatus", encode_replica_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_table_class_summary {
    option.Some(v) -> [
      #("ReplicaTableClassSummary", encode_table_class_summary_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_settings_description_struct() -> decode.Decoder(
  ReplicaSettingsDescription,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_billing_mode_summary <- decode.optional_field(
    "ReplicaBillingModeSummary",
    option.None,
    decode.optional(decode_billing_mode_summary_struct()),
  )
  use replica_global_secondary_index_settings <- decode.optional_field(
    "ReplicaGlobalSecondaryIndexSettings",
    option.None,
    decode.optional(
      decode.list(
        decode_replica_global_secondary_index_settings_description_struct(),
      ),
    ),
  )
  use replica_provisioned_read_capacity_auto_scaling_settings <- decode.optional_field(
    "ReplicaProvisionedReadCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  use replica_provisioned_read_capacity_units <- decode.optional_field(
    "ReplicaProvisionedReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use replica_provisioned_write_capacity_auto_scaling_settings <- decode.optional_field(
    "ReplicaProvisionedWriteCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  use replica_provisioned_write_capacity_units <- decode.optional_field(
    "ReplicaProvisionedWriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use replica_status <- decode.optional_field(
    "ReplicaStatus",
    option.None,
    decode.optional(decode_replica_status_enum()),
  )
  use replica_table_class_summary <- decode.optional_field(
    "ReplicaTableClassSummary",
    option.None,
    decode.optional(decode_table_class_summary_struct()),
  )
  decode.success(ReplicaSettingsDescription(
    region_name: region_name,
    replica_billing_mode_summary: replica_billing_mode_summary,
    replica_global_secondary_index_settings: replica_global_secondary_index_settings,
    replica_provisioned_read_capacity_auto_scaling_settings: replica_provisioned_read_capacity_auto_scaling_settings,
    replica_provisioned_read_capacity_units: replica_provisioned_read_capacity_units,
    replica_provisioned_write_capacity_auto_scaling_settings: replica_provisioned_write_capacity_auto_scaling_settings,
    replica_provisioned_write_capacity_units: replica_provisioned_write_capacity_units,
    replica_status: replica_status,
    replica_table_class_summary: replica_table_class_summary,
  ))
}

pub type ReplicaGlobalSecondaryIndexSettingsDescription {
  ReplicaGlobalSecondaryIndexSettingsDescription(
    index_name: option.Option(String),
    index_status: option.Option(IndexStatus),
    provisioned_read_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
    provisioned_read_capacity_units: option.Option(Int),
    provisioned_write_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
    provisioned_write_capacity_units: option.Option(Int),
  )
}

pub fn encode_replica_global_secondary_index_settings_description_struct(
  input: ReplicaGlobalSecondaryIndexSettingsDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_status {
    option.Some(v) -> [#("IndexStatus", encode_index_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_read_capacity_auto_scaling_settings {
    option.Some(v) -> [
      #(
        "ProvisionedReadCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_read_capacity_units {
    option.Some(v) -> [#("ProvisionedReadCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_write_capacity_auto_scaling_settings {
    option.Some(v) -> [
      #(
        "ProvisionedWriteCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_write_capacity_units {
    option.Some(v) -> [#("ProvisionedWriteCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_global_secondary_index_settings_description_struct() -> decode.Decoder(
  ReplicaGlobalSecondaryIndexSettingsDescription,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use index_status <- decode.optional_field(
    "IndexStatus",
    option.None,
    decode.optional(decode_index_status_enum()),
  )
  use provisioned_read_capacity_auto_scaling_settings <- decode.optional_field(
    "ProvisionedReadCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  use provisioned_read_capacity_units <- decode.optional_field(
    "ProvisionedReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use provisioned_write_capacity_auto_scaling_settings <- decode.optional_field(
    "ProvisionedWriteCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  use provisioned_write_capacity_units <- decode.optional_field(
    "ProvisionedWriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ReplicaGlobalSecondaryIndexSettingsDescription(
    index_name: index_name,
    index_status: index_status,
    provisioned_read_capacity_auto_scaling_settings: provisioned_read_capacity_auto_scaling_settings,
    provisioned_read_capacity_units: provisioned_read_capacity_units,
    provisioned_write_capacity_auto_scaling_settings: provisioned_write_capacity_auto_scaling_settings,
    provisioned_write_capacity_units: provisioned_write_capacity_units,
  ))
}

pub type AutoScalingSettingsDescription {
  AutoScalingSettingsDescription(
    auto_scaling_disabled: option.Option(Bool),
    auto_scaling_role_arn: option.Option(String),
    maximum_units: option.Option(Int),
    minimum_units: option.Option(Int),
    scaling_policies: option.Option(List(AutoScalingPolicyDescription)),
  )
}

pub fn encode_auto_scaling_settings_description_struct(
  input: AutoScalingSettingsDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.auto_scaling_disabled {
    option.Some(v) -> [#("AutoScalingDisabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.auto_scaling_role_arn {
    option.Some(v) -> [#("AutoScalingRoleArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.maximum_units {
    option.Some(v) -> [#("MaximumUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.minimum_units {
    option.Some(v) -> [#("MinimumUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.scaling_policies {
    option.Some(v) -> [
      #(
        "ScalingPolicies",
        fn(xs) { json.array(xs, encode_auto_scaling_policy_description_struct) }(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_auto_scaling_settings_description_struct() -> decode.Decoder(
  AutoScalingSettingsDescription,
) {
  use auto_scaling_disabled <- decode.optional_field(
    "AutoScalingDisabled",
    option.None,
    decode.optional(decode.bool),
  )
  use auto_scaling_role_arn <- decode.optional_field(
    "AutoScalingRoleArn",
    option.None,
    decode.optional(decode.string),
  )
  use maximum_units <- decode.optional_field(
    "MaximumUnits",
    option.None,
    decode.optional(decode.int),
  )
  use minimum_units <- decode.optional_field(
    "MinimumUnits",
    option.None,
    decode.optional(decode.int),
  )
  use scaling_policies <- decode.optional_field(
    "ScalingPolicies",
    option.None,
    decode.optional(
      decode.list(decode_auto_scaling_policy_description_struct()),
    ),
  )
  decode.success(AutoScalingSettingsDescription(
    auto_scaling_disabled: auto_scaling_disabled,
    auto_scaling_role_arn: auto_scaling_role_arn,
    maximum_units: maximum_units,
    minimum_units: minimum_units,
    scaling_policies: scaling_policies,
  ))
}

pub type AutoScalingPolicyDescription {
  AutoScalingPolicyDescription(
    policy_name: option.Option(String),
    target_tracking_scaling_policy_configuration: option.Option(
      AutoScalingTargetTrackingScalingPolicyConfigurationDescription,
    ),
  )
}

pub fn encode_auto_scaling_policy_description_struct(
  input: AutoScalingPolicyDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.policy_name {
    option.Some(v) -> [#("PolicyName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_tracking_scaling_policy_configuration {
    option.Some(v) -> [
      #(
        "TargetTrackingScalingPolicyConfiguration",
        encode_auto_scaling_target_tracking_scaling_policy_configuration_description_struct(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_auto_scaling_policy_description_struct() -> decode.Decoder(
  AutoScalingPolicyDescription,
) {
  use policy_name <- decode.optional_field(
    "PolicyName",
    option.None,
    decode.optional(decode.string),
  )
  use target_tracking_scaling_policy_configuration <- decode.optional_field(
    "TargetTrackingScalingPolicyConfiguration",
    option.None,
    decode.optional(
      decode_auto_scaling_target_tracking_scaling_policy_configuration_description_struct(),
    ),
  )
  decode.success(AutoScalingPolicyDescription(
    policy_name: policy_name,
    target_tracking_scaling_policy_configuration: target_tracking_scaling_policy_configuration,
  ))
}

pub type AutoScalingTargetTrackingScalingPolicyConfigurationDescription {
  AutoScalingTargetTrackingScalingPolicyConfigurationDescription(
    disable_scale_in: option.Option(Bool),
    scale_in_cooldown: option.Option(Int),
    scale_out_cooldown: option.Option(Int),
    target_value: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_auto_scaling_target_tracking_scaling_policy_configuration_description_struct(
  input: AutoScalingTargetTrackingScalingPolicyConfigurationDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.disable_scale_in {
    option.Some(v) -> [#("DisableScaleIn", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.scale_in_cooldown {
    option.Some(v) -> [#("ScaleInCooldown", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.scale_out_cooldown {
    option.Some(v) -> [#("ScaleOutCooldown", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_value {
    option.Some(v) -> [#("TargetValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_auto_scaling_target_tracking_scaling_policy_configuration_description_struct() -> decode.Decoder(
  AutoScalingTargetTrackingScalingPolicyConfigurationDescription,
) {
  use disable_scale_in <- decode.optional_field(
    "DisableScaleIn",
    option.None,
    decode.optional(decode.bool),
  )
  use scale_in_cooldown <- decode.optional_field(
    "ScaleInCooldown",
    option.None,
    decode.optional(decode.int),
  )
  use scale_out_cooldown <- decode.optional_field(
    "ScaleOutCooldown",
    option.None,
    decode.optional(decode.int),
  )
  use target_value <- decode.optional_field(
    "TargetValue",
    option.None,
    decode.optional(json_float.decoder()),
  )
  decode.success(AutoScalingTargetTrackingScalingPolicyConfigurationDescription(
    disable_scale_in: disable_scale_in,
    scale_in_cooldown: scale_in_cooldown,
    scale_out_cooldown: scale_out_cooldown,
    target_value: target_value,
  ))
}

pub type DescribeImportInput {
  DescribeImportInput(import_arn: option.Option(String))
}

pub fn encode_describe_import_input_struct(
  input: DescribeImportInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.import_arn {
    option.Some(v) -> [#("ImportArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_import_input_struct() -> decode.Decoder(
  DescribeImportInput,
) {
  use import_arn <- decode.optional_field(
    "ImportArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeImportInput(import_arn: import_arn))
}

pub type DescribeImportOutput {
  DescribeImportOutput(
    import_table_description: option.Option(ImportTableDescription),
  )
}

pub fn encode_describe_import_output_struct(
  input: DescribeImportOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.import_table_description {
    option.Some(v) -> [
      #("ImportTableDescription", encode_import_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_import_output_struct() -> decode.Decoder(
  DescribeImportOutput,
) {
  use import_table_description <- decode.optional_field(
    "ImportTableDescription",
    option.None,
    decode.optional(decode_import_table_description_struct()),
  )
  decode.success(DescribeImportOutput(
    import_table_description: import_table_description,
  ))
}

pub type ImportTableDescription {
  ImportTableDescription(
    client_token: option.Option(String),
    cloud_watch_log_group_arn: option.Option(String),
    end_time: option.Option(Int),
    error_count: option.Option(Int),
    failure_code: option.Option(String),
    failure_message: option.Option(String),
    import_arn: option.Option(String),
    import_status: option.Option(ImportStatus),
    imported_item_count: option.Option(Int),
    input_compression_type: option.Option(InputCompressionType),
    input_format: option.Option(InputFormat),
    input_format_options: option.Option(InputFormatOptions),
    processed_item_count: option.Option(Int),
    processed_size_bytes: option.Option(Int),
    s3_bucket_source: option.Option(S3BucketSource),
    start_time: option.Option(Int),
    table_arn: option.Option(String),
    table_creation_parameters: option.Option(TableCreationParameters),
    table_id: option.Option(String),
  )
}

pub fn encode_import_table_description_struct(
  input: ImportTableDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.client_token {
    option.Some(v) -> [#("ClientToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.cloud_watch_log_group_arn {
    option.Some(v) -> [#("CloudWatchLogGroupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.end_time {
    option.Some(v) -> [#("EndTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.error_count {
    option.Some(v) -> [#("ErrorCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.failure_code {
    option.Some(v) -> [#("FailureCode", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.failure_message {
    option.Some(v) -> [#("FailureMessage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.import_arn {
    option.Some(v) -> [#("ImportArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.import_status {
    option.Some(v) -> [#("ImportStatus", encode_import_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.imported_item_count {
    option.Some(v) -> [#("ImportedItemCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.input_compression_type {
    option.Some(v) -> [
      #("InputCompressionType", encode_input_compression_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.input_format {
    option.Some(v) -> [#("InputFormat", encode_input_format_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.input_format_options {
    option.Some(v) -> [
      #("InputFormatOptions", encode_input_format_options_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.processed_item_count {
    option.Some(v) -> [#("ProcessedItemCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.processed_size_bytes {
    option.Some(v) -> [#("ProcessedSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket_source {
    option.Some(v) -> [
      #("S3BucketSource", encode_s3_bucket_source_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.start_time {
    option.Some(v) -> [#("StartTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_creation_parameters {
    option.Some(v) -> [
      #("TableCreationParameters", encode_table_creation_parameters_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_id {
    option.Some(v) -> [#("TableId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_import_table_description_struct() -> decode.Decoder(
  ImportTableDescription,
) {
  use client_token <- decode.optional_field(
    "ClientToken",
    option.None,
    decode.optional(decode.string),
  )
  use cloud_watch_log_group_arn <- decode.optional_field(
    "CloudWatchLogGroupArn",
    option.None,
    decode.optional(decode.string),
  )
  use end_time <- decode.optional_field(
    "EndTime",
    option.None,
    decode.optional(decode.int),
  )
  use error_count <- decode.optional_field(
    "ErrorCount",
    option.None,
    decode.optional(decode.int),
  )
  use failure_code <- decode.optional_field(
    "FailureCode",
    option.None,
    decode.optional(decode.string),
  )
  use failure_message <- decode.optional_field(
    "FailureMessage",
    option.None,
    decode.optional(decode.string),
  )
  use import_arn <- decode.optional_field(
    "ImportArn",
    option.None,
    decode.optional(decode.string),
  )
  use import_status <- decode.optional_field(
    "ImportStatus",
    option.None,
    decode.optional(decode_import_status_enum()),
  )
  use imported_item_count <- decode.optional_field(
    "ImportedItemCount",
    option.None,
    decode.optional(decode.int),
  )
  use input_compression_type <- decode.optional_field(
    "InputCompressionType",
    option.None,
    decode.optional(decode_input_compression_type_enum()),
  )
  use input_format <- decode.optional_field(
    "InputFormat",
    option.None,
    decode.optional(decode_input_format_enum()),
  )
  use input_format_options <- decode.optional_field(
    "InputFormatOptions",
    option.None,
    decode.optional(decode_input_format_options_struct()),
  )
  use processed_item_count <- decode.optional_field(
    "ProcessedItemCount",
    option.None,
    decode.optional(decode.int),
  )
  use processed_size_bytes <- decode.optional_field(
    "ProcessedSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  use s3_bucket_source <- decode.optional_field(
    "S3BucketSource",
    option.None,
    decode.optional(decode_s3_bucket_source_struct()),
  )
  use start_time <- decode.optional_field(
    "StartTime",
    option.None,
    decode.optional(decode.int),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_creation_parameters <- decode.optional_field(
    "TableCreationParameters",
    option.None,
    decode.optional(decode_table_creation_parameters_struct()),
  )
  use table_id <- decode.optional_field(
    "TableId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ImportTableDescription(
    client_token: client_token,
    cloud_watch_log_group_arn: cloud_watch_log_group_arn,
    end_time: end_time,
    error_count: error_count,
    failure_code: failure_code,
    failure_message: failure_message,
    import_arn: import_arn,
    import_status: import_status,
    imported_item_count: imported_item_count,
    input_compression_type: input_compression_type,
    input_format: input_format,
    input_format_options: input_format_options,
    processed_item_count: processed_item_count,
    processed_size_bytes: processed_size_bytes,
    s3_bucket_source: s3_bucket_source,
    start_time: start_time,
    table_arn: table_arn,
    table_creation_parameters: table_creation_parameters,
    table_id: table_id,
  ))
}

pub type ImportStatus {
  ImportStatusCancelled
  ImportStatusCancelling
  ImportStatusCompleted
  ImportStatusFailed
  ImportStatusInProgress
}

pub fn encode_import_status_enum(v: ImportStatus) -> json.Json {
  case v {
    ImportStatusCancelled -> json.string("CANCELLED")
    ImportStatusCancelling -> json.string("CANCELLING")
    ImportStatusCompleted -> json.string("COMPLETED")
    ImportStatusFailed -> json.string("FAILED")
    ImportStatusInProgress -> json.string("IN_PROGRESS")
  }
}

pub fn decode_import_status_enum() -> decode.Decoder(ImportStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "CANCELLED" -> decode.success(ImportStatusCancelled)
      "CANCELLING" -> decode.success(ImportStatusCancelling)
      "COMPLETED" -> decode.success(ImportStatusCompleted)
      "FAILED" -> decode.success(ImportStatusFailed)
      "IN_PROGRESS" -> decode.success(ImportStatusInProgress)
      _ -> decode.failure(ImportStatusCancelled, "unknown enum value")
    }
  })
}

pub type InputCompressionType {
  InputCompressionTypeGzip
  InputCompressionTypeNone
  InputCompressionTypeZstd
}

pub fn encode_input_compression_type_enum(
  v: InputCompressionType,
) -> json.Json {
  case v {
    InputCompressionTypeGzip -> json.string("GZIP")
    InputCompressionTypeNone -> json.string("NONE")
    InputCompressionTypeZstd -> json.string("ZSTD")
  }
}

pub fn decode_input_compression_type_enum() -> decode.Decoder(
  InputCompressionType,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "GZIP" -> decode.success(InputCompressionTypeGzip)
      "NONE" -> decode.success(InputCompressionTypeNone)
      "ZSTD" -> decode.success(InputCompressionTypeZstd)
      _ -> decode.failure(InputCompressionTypeGzip, "unknown enum value")
    }
  })
}

pub type InputFormat {
  InputFormatCsv
  InputFormatDynamodbJson
  InputFormatIon
}

pub fn encode_input_format_enum(v: InputFormat) -> json.Json {
  case v {
    InputFormatCsv -> json.string("CSV")
    InputFormatDynamodbJson -> json.string("DYNAMODB_JSON")
    InputFormatIon -> json.string("ION")
  }
}

pub fn decode_input_format_enum() -> decode.Decoder(InputFormat) {
  decode.then(decode.string, fn(s) {
    case s {
      "CSV" -> decode.success(InputFormatCsv)
      "DYNAMODB_JSON" -> decode.success(InputFormatDynamodbJson)
      "ION" -> decode.success(InputFormatIon)
      _ -> decode.failure(InputFormatCsv, "unknown enum value")
    }
  })
}

pub type InputFormatOptions {
  InputFormatOptions(csv: option.Option(CsvOptions))
}

pub fn encode_input_format_options_struct(
  input: InputFormatOptions,
) -> json.Json {
  let pairs = []
  let pairs = case input.csv {
    option.Some(v) -> [#("Csv", encode_csv_options_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_input_format_options_struct() -> decode.Decoder(
  InputFormatOptions,
) {
  use csv <- decode.optional_field(
    "Csv",
    option.None,
    decode.optional(decode_csv_options_struct()),
  )
  decode.success(InputFormatOptions(csv: csv))
}

pub type CsvOptions {
  CsvOptions(
    delimiter: option.Option(String),
    header_list: option.Option(List(String)),
  )
}

pub fn encode_csv_options_struct(input: CsvOptions) -> json.Json {
  let pairs = []
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.header_list {
    option.Some(v) -> [
      #("HeaderList", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_csv_options_struct() -> decode.Decoder(CsvOptions) {
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use header_list <- decode.optional_field(
    "HeaderList",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  decode.success(CsvOptions(delimiter: delimiter, header_list: header_list))
}

pub type S3BucketSource {
  S3BucketSource(
    s3_bucket: option.Option(String),
    s3_bucket_owner: option.Option(String),
    s3_key_prefix: option.Option(String),
  )
}

pub fn encode_s3_bucket_source_struct(input: S3BucketSource) -> json.Json {
  let pairs = []
  let pairs = case input.s3_bucket {
    option.Some(v) -> [#("S3Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket_owner {
    option.Some(v) -> [#("S3BucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_key_prefix {
    option.Some(v) -> [#("S3KeyPrefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_s3_bucket_source_struct() -> decode.Decoder(S3BucketSource) {
  use s3_bucket <- decode.optional_field(
    "S3Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use s3_bucket_owner <- decode.optional_field(
    "S3BucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use s3_key_prefix <- decode.optional_field(
    "S3KeyPrefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(S3BucketSource(
    s3_bucket: s3_bucket,
    s3_bucket_owner: s3_bucket_owner,
    s3_key_prefix: s3_key_prefix,
  ))
}

pub type TableCreationParameters {
  TableCreationParameters(
    attribute_definitions: option.Option(List(AttributeDefinition)),
    billing_mode: option.Option(BillingMode),
    global_secondary_indexes: option.Option(List(GlobalSecondaryIndex)),
    key_schema: option.Option(List(KeySchemaElement)),
    on_demand_throughput: option.Option(OnDemandThroughput),
    provisioned_throughput: option.Option(ProvisionedThroughput),
    sse_specification: option.Option(SSESpecification),
    table_name: option.Option(String),
  )
}

pub fn encode_table_creation_parameters_struct(
  input: TableCreationParameters,
) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_definitions {
    option.Some(v) -> [
      #(
        "AttributeDefinitions",
        fn(xs) { json.array(xs, encode_attribute_definition_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.billing_mode {
    option.Some(v) -> [#("BillingMode", encode_billing_mode_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) { json.array(xs, encode_global_secondary_index_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_specification {
    option.Some(v) -> [
      #("SSESpecification", encode_sse_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_table_creation_parameters_struct() -> decode.Decoder(
  TableCreationParameters,
) {
  use attribute_definitions <- decode.optional_field(
    "AttributeDefinitions",
    option.None,
    decode.optional(decode.list(decode_attribute_definition_struct())),
  )
  use billing_mode <- decode.optional_field(
    "BillingMode",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(decode.list(decode_global_secondary_index_struct())),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use sse_specification <- decode.optional_field(
    "SSESpecification",
    option.None,
    decode.optional(decode_sse_specification_struct()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(TableCreationParameters(
    attribute_definitions: attribute_definitions,
    billing_mode: billing_mode,
    global_secondary_indexes: global_secondary_indexes,
    key_schema: key_schema,
    on_demand_throughput: on_demand_throughput,
    provisioned_throughput: provisioned_throughput,
    sse_specification: sse_specification,
    table_name: table_name,
  ))
}

pub type DescribeKinesisStreamingDestinationInput {
  DescribeKinesisStreamingDestinationInput(table_name: option.Option(String))
}

pub fn encode_describe_kinesis_streaming_destination_input_struct(
  input: DescribeKinesisStreamingDestinationInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_kinesis_streaming_destination_input_struct() -> decode.Decoder(
  DescribeKinesisStreamingDestinationInput,
) {
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeKinesisStreamingDestinationInput(
    table_name: table_name,
  ))
}

pub type DescribeKinesisStreamingDestinationOutput {
  DescribeKinesisStreamingDestinationOutput(
    kinesis_data_stream_destinations: option.Option(
      List(KinesisDataStreamDestination),
    ),
    table_name: option.Option(String),
  )
}

pub fn encode_describe_kinesis_streaming_destination_output_struct(
  input: DescribeKinesisStreamingDestinationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.kinesis_data_stream_destinations {
    option.Some(v) -> [
      #(
        "KinesisDataStreamDestinations",
        fn(xs) { json.array(xs, encode_kinesis_data_stream_destination_struct) }(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_kinesis_streaming_destination_output_struct() -> decode.Decoder(
  DescribeKinesisStreamingDestinationOutput,
) {
  use kinesis_data_stream_destinations <- decode.optional_field(
    "KinesisDataStreamDestinations",
    option.None,
    decode.optional(
      decode.list(decode_kinesis_data_stream_destination_struct()),
    ),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeKinesisStreamingDestinationOutput(
    kinesis_data_stream_destinations: kinesis_data_stream_destinations,
    table_name: table_name,
  ))
}

pub type KinesisDataStreamDestination {
  KinesisDataStreamDestination(
    approximate_creation_date_time_precision: option.Option(
      ApproximateCreationDateTimePrecision,
    ),
    destination_status: option.Option(DestinationStatus),
    destination_status_description: option.Option(String),
    stream_arn: option.Option(String),
  )
}

pub fn encode_kinesis_data_stream_destination_struct(
  input: KinesisDataStreamDestination,
) -> json.Json {
  let pairs = []
  let pairs = case input.approximate_creation_date_time_precision {
    option.Some(v) -> [
      #(
        "ApproximateCreationDateTimePrecision",
        encode_approximate_creation_date_time_precision_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.destination_status {
    option.Some(v) -> [
      #("DestinationStatus", encode_destination_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.destination_status_description {
    option.Some(v) -> [
      #("DestinationStatusDescription", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_arn {
    option.Some(v) -> [#("StreamArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_kinesis_data_stream_destination_struct() -> decode.Decoder(
  KinesisDataStreamDestination,
) {
  use approximate_creation_date_time_precision <- decode.optional_field(
    "ApproximateCreationDateTimePrecision",
    option.None,
    decode.optional(decode_approximate_creation_date_time_precision_enum()),
  )
  use destination_status <- decode.optional_field(
    "DestinationStatus",
    option.None,
    decode.optional(decode_destination_status_enum()),
  )
  use destination_status_description <- decode.optional_field(
    "DestinationStatusDescription",
    option.None,
    decode.optional(decode.string),
  )
  use stream_arn <- decode.optional_field(
    "StreamArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(KinesisDataStreamDestination(
    approximate_creation_date_time_precision: approximate_creation_date_time_precision,
    destination_status: destination_status,
    destination_status_description: destination_status_description,
    stream_arn: stream_arn,
  ))
}

pub type ApproximateCreationDateTimePrecision {
  ApproximateCreationDateTimePrecisionMicrosecond
  ApproximateCreationDateTimePrecisionMillisecond
}

pub fn encode_approximate_creation_date_time_precision_enum(
  v: ApproximateCreationDateTimePrecision,
) -> json.Json {
  case v {
    ApproximateCreationDateTimePrecisionMicrosecond ->
      json.string("MICROSECOND")
    ApproximateCreationDateTimePrecisionMillisecond ->
      json.string("MILLISECOND")
  }
}

pub fn decode_approximate_creation_date_time_precision_enum() -> decode.Decoder(
  ApproximateCreationDateTimePrecision,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "MICROSECOND" ->
        decode.success(ApproximateCreationDateTimePrecisionMicrosecond)
      "MILLISECOND" ->
        decode.success(ApproximateCreationDateTimePrecisionMillisecond)
      _ ->
        decode.failure(
          ApproximateCreationDateTimePrecisionMicrosecond,
          "unknown enum value",
        )
    }
  })
}

pub type DestinationStatus {
  DestinationStatusActive
  DestinationStatusDisabled
  DestinationStatusDisabling
  DestinationStatusEnableFailed
  DestinationStatusEnabling
  DestinationStatusUpdating
}

pub fn encode_destination_status_enum(v: DestinationStatus) -> json.Json {
  case v {
    DestinationStatusActive -> json.string("ACTIVE")
    DestinationStatusDisabled -> json.string("DISABLED")
    DestinationStatusDisabling -> json.string("DISABLING")
    DestinationStatusEnableFailed -> json.string("ENABLE_FAILED")
    DestinationStatusEnabling -> json.string("ENABLING")
    DestinationStatusUpdating -> json.string("UPDATING")
  }
}

pub fn decode_destination_status_enum() -> decode.Decoder(DestinationStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "ACTIVE" -> decode.success(DestinationStatusActive)
      "DISABLED" -> decode.success(DestinationStatusDisabled)
      "DISABLING" -> decode.success(DestinationStatusDisabling)
      "ENABLE_FAILED" -> decode.success(DestinationStatusEnableFailed)
      "ENABLING" -> decode.success(DestinationStatusEnabling)
      "UPDATING" -> decode.success(DestinationStatusUpdating)
      _ -> decode.failure(DestinationStatusActive, "unknown enum value")
    }
  })
}

pub type DescribeLimitsInput {
  DescribeLimitsInput
}

pub fn encode_describe_limits_input_struct(
  _v: DescribeLimitsInput,
) -> json.Json {
  json.object([])
}

pub fn decode_describe_limits_input_struct() -> decode.Decoder(
  DescribeLimitsInput,
) {
  decode.success(DescribeLimitsInput)
}

pub type DescribeLimitsOutput {
  DescribeLimitsOutput(
    account_max_read_capacity_units: option.Option(Int),
    account_max_write_capacity_units: option.Option(Int),
    table_max_read_capacity_units: option.Option(Int),
    table_max_write_capacity_units: option.Option(Int),
  )
}

pub fn encode_describe_limits_output_struct(
  input: DescribeLimitsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.account_max_read_capacity_units {
    option.Some(v) -> [#("AccountMaxReadCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.account_max_write_capacity_units {
    option.Some(v) -> [#("AccountMaxWriteCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_max_read_capacity_units {
    option.Some(v) -> [#("TableMaxReadCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_max_write_capacity_units {
    option.Some(v) -> [#("TableMaxWriteCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_limits_output_struct() -> decode.Decoder(
  DescribeLimitsOutput,
) {
  use account_max_read_capacity_units <- decode.optional_field(
    "AccountMaxReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use account_max_write_capacity_units <- decode.optional_field(
    "AccountMaxWriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use table_max_read_capacity_units <- decode.optional_field(
    "TableMaxReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use table_max_write_capacity_units <- decode.optional_field(
    "TableMaxWriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(DescribeLimitsOutput(
    account_max_read_capacity_units: account_max_read_capacity_units,
    account_max_write_capacity_units: account_max_write_capacity_units,
    table_max_read_capacity_units: table_max_read_capacity_units,
    table_max_write_capacity_units: table_max_write_capacity_units,
  ))
}

pub type DescribeTableInput {
  DescribeTableInput(table_name: option.Option(String))
}

pub fn encode_describe_table_input_struct(
  input: DescribeTableInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_table_input_struct() -> decode.Decoder(
  DescribeTableInput,
) {
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeTableInput(table_name: table_name))
}

pub type DescribeTableOutput {
  DescribeTableOutput(table: option.Option(TableDescription))
}

pub fn encode_describe_table_output_struct(
  input: DescribeTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table {
    option.Some(v) -> [#("Table", encode_table_description_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_table_output_struct() -> decode.Decoder(
  DescribeTableOutput,
) {
  use table <- decode.optional_field(
    "Table",
    option.None,
    decode.optional(decode_table_description_struct()),
  )
  decode.success(DescribeTableOutput(table: table))
}

pub type DescribeTableReplicaAutoScalingInput {
  DescribeTableReplicaAutoScalingInput(table_name: option.Option(String))
}

pub fn encode_describe_table_replica_auto_scaling_input_struct(
  input: DescribeTableReplicaAutoScalingInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_table_replica_auto_scaling_input_struct() -> decode.Decoder(
  DescribeTableReplicaAutoScalingInput,
) {
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeTableReplicaAutoScalingInput(table_name: table_name))
}

pub type DescribeTableReplicaAutoScalingOutput {
  DescribeTableReplicaAutoScalingOutput(
    table_auto_scaling_description: option.Option(TableAutoScalingDescription),
  )
}

pub fn encode_describe_table_replica_auto_scaling_output_struct(
  input: DescribeTableReplicaAutoScalingOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_auto_scaling_description {
    option.Some(v) -> [
      #(
        "TableAutoScalingDescription",
        encode_table_auto_scaling_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_table_replica_auto_scaling_output_struct() -> decode.Decoder(
  DescribeTableReplicaAutoScalingOutput,
) {
  use table_auto_scaling_description <- decode.optional_field(
    "TableAutoScalingDescription",
    option.None,
    decode.optional(decode_table_auto_scaling_description_struct()),
  )
  decode.success(DescribeTableReplicaAutoScalingOutput(
    table_auto_scaling_description: table_auto_scaling_description,
  ))
}

pub type TableAutoScalingDescription {
  TableAutoScalingDescription(
    replicas: option.Option(List(ReplicaAutoScalingDescription)),
    table_name: option.Option(String),
    table_status: option.Option(TableStatus),
  )
}

pub fn encode_table_auto_scaling_description_struct(
  input: TableAutoScalingDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.replicas {
    option.Some(v) -> [
      #(
        "Replicas",
        fn(xs) {
          json.array(xs, encode_replica_auto_scaling_description_struct)
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_status {
    option.Some(v) -> [#("TableStatus", encode_table_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_table_auto_scaling_description_struct() -> decode.Decoder(
  TableAutoScalingDescription,
) {
  use replicas <- decode.optional_field(
    "Replicas",
    option.None,
    decode.optional(
      decode.list(decode_replica_auto_scaling_description_struct()),
    ),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use table_status <- decode.optional_field(
    "TableStatus",
    option.None,
    decode.optional(decode_table_status_enum()),
  )
  decode.success(TableAutoScalingDescription(
    replicas: replicas,
    table_name: table_name,
    table_status: table_status,
  ))
}

pub type ReplicaAutoScalingDescription {
  ReplicaAutoScalingDescription(
    global_secondary_indexes: option.Option(
      List(ReplicaGlobalSecondaryIndexAutoScalingDescription),
    ),
    region_name: option.Option(String),
    replica_provisioned_read_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
    replica_provisioned_write_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
    replica_status: option.Option(ReplicaStatus),
  )
}

pub fn encode_replica_auto_scaling_description_struct(
  input: ReplicaAutoScalingDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) {
          json.array(
            xs,
            encode_replica_global_secondary_index_auto_scaling_description_struct,
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case
    input.replica_provisioned_read_capacity_auto_scaling_settings
  {
    option.Some(v) -> [
      #(
        "ReplicaProvisionedReadCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case
    input.replica_provisioned_write_capacity_auto_scaling_settings
  {
    option.Some(v) -> [
      #(
        "ReplicaProvisionedWriteCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_status {
    option.Some(v) -> [
      #("ReplicaStatus", encode_replica_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_auto_scaling_description_struct() -> decode.Decoder(
  ReplicaAutoScalingDescription,
) {
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(
      decode.list(
        decode_replica_global_secondary_index_auto_scaling_description_struct(),
      ),
    ),
  )
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_provisioned_read_capacity_auto_scaling_settings <- decode.optional_field(
    "ReplicaProvisionedReadCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  use replica_provisioned_write_capacity_auto_scaling_settings <- decode.optional_field(
    "ReplicaProvisionedWriteCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  use replica_status <- decode.optional_field(
    "ReplicaStatus",
    option.None,
    decode.optional(decode_replica_status_enum()),
  )
  decode.success(ReplicaAutoScalingDescription(
    global_secondary_indexes: global_secondary_indexes,
    region_name: region_name,
    replica_provisioned_read_capacity_auto_scaling_settings: replica_provisioned_read_capacity_auto_scaling_settings,
    replica_provisioned_write_capacity_auto_scaling_settings: replica_provisioned_write_capacity_auto_scaling_settings,
    replica_status: replica_status,
  ))
}

pub type ReplicaGlobalSecondaryIndexAutoScalingDescription {
  ReplicaGlobalSecondaryIndexAutoScalingDescription(
    index_name: option.Option(String),
    index_status: option.Option(IndexStatus),
    provisioned_read_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
    provisioned_write_capacity_auto_scaling_settings: option.Option(
      AutoScalingSettingsDescription,
    ),
  )
}

pub fn encode_replica_global_secondary_index_auto_scaling_description_struct(
  input: ReplicaGlobalSecondaryIndexAutoScalingDescription,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_status {
    option.Some(v) -> [#("IndexStatus", encode_index_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_read_capacity_auto_scaling_settings {
    option.Some(v) -> [
      #(
        "ProvisionedReadCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_write_capacity_auto_scaling_settings {
    option.Some(v) -> [
      #(
        "ProvisionedWriteCapacityAutoScalingSettings",
        encode_auto_scaling_settings_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_global_secondary_index_auto_scaling_description_struct() -> decode.Decoder(
  ReplicaGlobalSecondaryIndexAutoScalingDescription,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use index_status <- decode.optional_field(
    "IndexStatus",
    option.None,
    decode.optional(decode_index_status_enum()),
  )
  use provisioned_read_capacity_auto_scaling_settings <- decode.optional_field(
    "ProvisionedReadCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  use provisioned_write_capacity_auto_scaling_settings <- decode.optional_field(
    "ProvisionedWriteCapacityAutoScalingSettings",
    option.None,
    decode.optional(decode_auto_scaling_settings_description_struct()),
  )
  decode.success(ReplicaGlobalSecondaryIndexAutoScalingDescription(
    index_name: index_name,
    index_status: index_status,
    provisioned_read_capacity_auto_scaling_settings: provisioned_read_capacity_auto_scaling_settings,
    provisioned_write_capacity_auto_scaling_settings: provisioned_write_capacity_auto_scaling_settings,
  ))
}

pub type DescribeTimeToLiveInput {
  DescribeTimeToLiveInput(table_name: option.Option(String))
}

pub fn encode_describe_time_to_live_input_struct(
  input: DescribeTimeToLiveInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_time_to_live_input_struct() -> decode.Decoder(
  DescribeTimeToLiveInput,
) {
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DescribeTimeToLiveInput(table_name: table_name))
}

pub type DescribeTimeToLiveOutput {
  DescribeTimeToLiveOutput(
    time_to_live_description: option.Option(TimeToLiveDescription),
  )
}

pub fn encode_describe_time_to_live_output_struct(
  input: DescribeTimeToLiveOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.time_to_live_description {
    option.Some(v) -> [
      #("TimeToLiveDescription", encode_time_to_live_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_describe_time_to_live_output_struct() -> decode.Decoder(
  DescribeTimeToLiveOutput,
) {
  use time_to_live_description <- decode.optional_field(
    "TimeToLiveDescription",
    option.None,
    decode.optional(decode_time_to_live_description_struct()),
  )
  decode.success(DescribeTimeToLiveOutput(
    time_to_live_description: time_to_live_description,
  ))
}

pub type KinesisStreamingDestinationInput {
  KinesisStreamingDestinationInput(
    enable_kinesis_streaming_configuration: option.Option(
      EnableKinesisStreamingConfiguration,
    ),
    stream_arn: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_kinesis_streaming_destination_input_struct(
  input: KinesisStreamingDestinationInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.enable_kinesis_streaming_configuration {
    option.Some(v) -> [
      #(
        "EnableKinesisStreamingConfiguration",
        encode_enable_kinesis_streaming_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_arn {
    option.Some(v) -> [#("StreamArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_kinesis_streaming_destination_input_struct() -> decode.Decoder(
  KinesisStreamingDestinationInput,
) {
  use enable_kinesis_streaming_configuration <- decode.optional_field(
    "EnableKinesisStreamingConfiguration",
    option.None,
    decode.optional(decode_enable_kinesis_streaming_configuration_struct()),
  )
  use stream_arn <- decode.optional_field(
    "StreamArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(KinesisStreamingDestinationInput(
    enable_kinesis_streaming_configuration: enable_kinesis_streaming_configuration,
    stream_arn: stream_arn,
    table_name: table_name,
  ))
}

pub type EnableKinesisStreamingConfiguration {
  EnableKinesisStreamingConfiguration(
    approximate_creation_date_time_precision: option.Option(
      ApproximateCreationDateTimePrecision,
    ),
  )
}

pub fn encode_enable_kinesis_streaming_configuration_struct(
  input: EnableKinesisStreamingConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.approximate_creation_date_time_precision {
    option.Some(v) -> [
      #(
        "ApproximateCreationDateTimePrecision",
        encode_approximate_creation_date_time_precision_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_enable_kinesis_streaming_configuration_struct() -> decode.Decoder(
  EnableKinesisStreamingConfiguration,
) {
  use approximate_creation_date_time_precision <- decode.optional_field(
    "ApproximateCreationDateTimePrecision",
    option.None,
    decode.optional(decode_approximate_creation_date_time_precision_enum()),
  )
  decode.success(EnableKinesisStreamingConfiguration(
    approximate_creation_date_time_precision: approximate_creation_date_time_precision,
  ))
}

pub type KinesisStreamingDestinationOutput {
  KinesisStreamingDestinationOutput(
    destination_status: option.Option(DestinationStatus),
    enable_kinesis_streaming_configuration: option.Option(
      EnableKinesisStreamingConfiguration,
    ),
    stream_arn: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_kinesis_streaming_destination_output_struct(
  input: KinesisStreamingDestinationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.destination_status {
    option.Some(v) -> [
      #("DestinationStatus", encode_destination_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.enable_kinesis_streaming_configuration {
    option.Some(v) -> [
      #(
        "EnableKinesisStreamingConfiguration",
        encode_enable_kinesis_streaming_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_arn {
    option.Some(v) -> [#("StreamArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_kinesis_streaming_destination_output_struct() -> decode.Decoder(
  KinesisStreamingDestinationOutput,
) {
  use destination_status <- decode.optional_field(
    "DestinationStatus",
    option.None,
    decode.optional(decode_destination_status_enum()),
  )
  use enable_kinesis_streaming_configuration <- decode.optional_field(
    "EnableKinesisStreamingConfiguration",
    option.None,
    decode.optional(decode_enable_kinesis_streaming_configuration_struct()),
  )
  use stream_arn <- decode.optional_field(
    "StreamArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(KinesisStreamingDestinationOutput(
    destination_status: destination_status,
    enable_kinesis_streaming_configuration: enable_kinesis_streaming_configuration,
    stream_arn: stream_arn,
    table_name: table_name,
  ))
}

pub type ExecuteStatementInput {
  ExecuteStatementInput(
    consistent_read: option.Option(Bool),
    limit: option.Option(Int),
    next_token: option.Option(String),
    parameters: option.Option(List(AttributeValue)),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    statement: option.Option(String),
  )
}

pub fn encode_execute_statement_input_struct(
  input: ExecuteStatementInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consistent_read {
    option.Some(v) -> [#("ConsistentRead", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.limit {
    option.Some(v) -> [#("Limit", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.parameters {
    option.Some(v) -> [
      #(
        "Parameters",
        fn(xs) { json.array(xs, encode_attribute_value_union) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.statement {
    option.Some(v) -> [#("Statement", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_execute_statement_input_struct() -> decode.Decoder(
  ExecuteStatementInput,
) {
  use consistent_read <- decode.optional_field(
    "ConsistentRead",
    option.None,
    decode.optional(decode.bool),
  )
  use limit <- decode.optional_field(
    "Limit",
    option.None,
    decode.optional(decode.int),
  )
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  use parameters <- decode.optional_field(
    "Parameters",
    option.None,
    decode.optional(decode.list(decode_attribute_value_union())),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use statement <- decode.optional_field(
    "Statement",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ExecuteStatementInput(
    consistent_read: consistent_read,
    limit: limit,
    next_token: next_token,
    parameters: parameters,
    return_consumed_capacity: return_consumed_capacity,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    statement: statement,
  ))
}

pub type ExecuteStatementOutput {
  ExecuteStatementOutput(
    consumed_capacity: option.Option(ConsumedCapacity),
    items: option.Option(List(dict.Dict(String, AttributeValue))),
    last_evaluated_key: option.Option(dict.Dict(String, AttributeValue)),
    next_token: option.Option(String),
  )
}

pub fn encode_execute_statement_output_struct(
  input: ExecuteStatementOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #("ConsumedCapacity", encode_consumed_capacity_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.items {
    option.Some(v) -> [
      #(
        "Items",
        fn(xs) {
          json.array(xs, fn(d) {
            json.object(
              dict.to_list(d)
              |> list.map(fn(pair) {
                #(pair.0, encode_attribute_value_union(pair.1))
              }),
            )
          })
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.last_evaluated_key {
    option.Some(v) -> [
      #(
        "LastEvaluatedKey",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_execute_statement_output_struct() -> decode.Decoder(
  ExecuteStatementOutput,
) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode_consumed_capacity_struct()),
  )
  use items <- decode.optional_field(
    "Items",
    option.None,
    decode.optional(
      decode.list(decode.dict(decode.string, decode_attribute_value_union())),
    ),
  )
  use last_evaluated_key <- decode.optional_field(
    "LastEvaluatedKey",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ExecuteStatementOutput(
    consumed_capacity: consumed_capacity,
    items: items,
    last_evaluated_key: last_evaluated_key,
    next_token: next_token,
  ))
}

pub type ExecuteTransactionInput {
  ExecuteTransactionInput(
    client_request_token: option.Option(String),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    transact_statements: option.Option(List(ParameterizedStatement)),
  )
}

pub fn encode_execute_transaction_input_struct(
  input: ExecuteTransactionInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.client_request_token {
    option.Some(v) -> [#("ClientRequestToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.transact_statements {
    option.Some(v) -> [
      #(
        "TransactStatements",
        fn(xs) { json.array(xs, encode_parameterized_statement_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_execute_transaction_input_struct() -> decode.Decoder(
  ExecuteTransactionInput,
) {
  use client_request_token <- decode.optional_field(
    "ClientRequestToken",
    option.None,
    decode.optional(decode.string),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use transact_statements <- decode.optional_field(
    "TransactStatements",
    option.None,
    decode.optional(decode.list(decode_parameterized_statement_struct())),
  )
  decode.success(ExecuteTransactionInput(
    client_request_token: client_request_token,
    return_consumed_capacity: return_consumed_capacity,
    transact_statements: transact_statements,
  ))
}

pub type ParameterizedStatement {
  ParameterizedStatement(
    parameters: option.Option(List(AttributeValue)),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    statement: option.Option(String),
  )
}

pub fn encode_parameterized_statement_struct(
  input: ParameterizedStatement,
) -> json.Json {
  let pairs = []
  let pairs = case input.parameters {
    option.Some(v) -> [
      #(
        "Parameters",
        fn(xs) { json.array(xs, encode_attribute_value_union) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.statement {
    option.Some(v) -> [#("Statement", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_parameterized_statement_struct() -> decode.Decoder(
  ParameterizedStatement,
) {
  use parameters <- decode.optional_field(
    "Parameters",
    option.None,
    decode.optional(decode.list(decode_attribute_value_union())),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use statement <- decode.optional_field(
    "Statement",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ParameterizedStatement(
    parameters: parameters,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    statement: statement,
  ))
}

pub type ExecuteTransactionOutput {
  ExecuteTransactionOutput(
    consumed_capacity: option.Option(List(ConsumedCapacity)),
    responses: option.Option(List(ItemResponse)),
  )
}

pub fn encode_execute_transaction_output_struct(
  input: ExecuteTransactionOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #(
        "ConsumedCapacity",
        fn(xs) { json.array(xs, encode_consumed_capacity_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.responses {
    option.Some(v) -> [
      #("Responses", fn(xs) { json.array(xs, encode_item_response_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_execute_transaction_output_struct() -> decode.Decoder(
  ExecuteTransactionOutput,
) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode.list(decode_consumed_capacity_struct())),
  )
  use responses <- decode.optional_field(
    "Responses",
    option.None,
    decode.optional(decode.list(decode_item_response_struct())),
  )
  decode.success(ExecuteTransactionOutput(
    consumed_capacity: consumed_capacity,
    responses: responses,
  ))
}

pub type ItemResponse {
  ItemResponse(item: option.Option(dict.Dict(String, AttributeValue)))
}

pub fn encode_item_response_struct(input: ItemResponse) -> json.Json {
  let pairs = []
  let pairs = case input.item {
    option.Some(v) -> [
      #(
        "Item",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
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

pub fn decode_item_response_struct() -> decode.Decoder(ItemResponse) {
  use item <- decode.optional_field(
    "Item",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  decode.success(ItemResponse(item: item))
}

pub type ExportTableToPointInTimeInput {
  ExportTableToPointInTimeInput(
    client_token: option.Option(String),
    export_format: option.Option(ExportFormat),
    export_time: option.Option(Int),
    export_type: option.Option(ExportType),
    incremental_export_specification: option.Option(
      IncrementalExportSpecification,
    ),
    s3_bucket: option.Option(String),
    s3_bucket_owner: option.Option(String),
    s3_prefix: option.Option(String),
    s3_sse_algorithm: option.Option(S3SseAlgorithm),
    s3_sse_kms_key_id: option.Option(String),
    table_arn: option.Option(String),
  )
}

pub fn encode_export_table_to_point_in_time_input_struct(
  input: ExportTableToPointInTimeInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.client_token {
    option.Some(v) -> [#("ClientToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_format {
    option.Some(v) -> [#("ExportFormat", encode_export_format_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_time {
    option.Some(v) -> [#("ExportTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_type {
    option.Some(v) -> [#("ExportType", encode_export_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.incremental_export_specification {
    option.Some(v) -> [
      #(
        "IncrementalExportSpecification",
        encode_incremental_export_specification_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket {
    option.Some(v) -> [#("S3Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket_owner {
    option.Some(v) -> [#("S3BucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_prefix {
    option.Some(v) -> [#("S3Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_sse_algorithm {
    option.Some(v) -> [
      #("S3SseAlgorithm", encode_s3_sse_algorithm_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.s3_sse_kms_key_id {
    option.Some(v) -> [#("S3SseKmsKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_export_table_to_point_in_time_input_struct() -> decode.Decoder(
  ExportTableToPointInTimeInput,
) {
  use client_token <- decode.optional_field(
    "ClientToken",
    option.None,
    decode.optional(decode.string),
  )
  use export_format <- decode.optional_field(
    "ExportFormat",
    option.None,
    decode.optional(decode_export_format_enum()),
  )
  use export_time <- decode.optional_field(
    "ExportTime",
    option.None,
    decode.optional(decode.int),
  )
  use export_type <- decode.optional_field(
    "ExportType",
    option.None,
    decode.optional(decode_export_type_enum()),
  )
  use incremental_export_specification <- decode.optional_field(
    "IncrementalExportSpecification",
    option.None,
    decode.optional(decode_incremental_export_specification_struct()),
  )
  use s3_bucket <- decode.optional_field(
    "S3Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use s3_bucket_owner <- decode.optional_field(
    "S3BucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use s3_prefix <- decode.optional_field(
    "S3Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use s3_sse_algorithm <- decode.optional_field(
    "S3SseAlgorithm",
    option.None,
    decode.optional(decode_s3_sse_algorithm_enum()),
  )
  use s3_sse_kms_key_id <- decode.optional_field(
    "S3SseKmsKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ExportTableToPointInTimeInput(
    client_token: client_token,
    export_format: export_format,
    export_time: export_time,
    export_type: export_type,
    incremental_export_specification: incremental_export_specification,
    s3_bucket: s3_bucket,
    s3_bucket_owner: s3_bucket_owner,
    s3_prefix: s3_prefix,
    s3_sse_algorithm: s3_sse_algorithm,
    s3_sse_kms_key_id: s3_sse_kms_key_id,
    table_arn: table_arn,
  ))
}

pub type ExportTableToPointInTimeOutput {
  ExportTableToPointInTimeOutput(
    export_description: option.Option(ExportDescription),
  )
}

pub fn encode_export_table_to_point_in_time_output_struct(
  input: ExportTableToPointInTimeOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.export_description {
    option.Some(v) -> [
      #("ExportDescription", encode_export_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_export_table_to_point_in_time_output_struct() -> decode.Decoder(
  ExportTableToPointInTimeOutput,
) {
  use export_description <- decode.optional_field(
    "ExportDescription",
    option.None,
    decode.optional(decode_export_description_struct()),
  )
  decode.success(ExportTableToPointInTimeOutput(
    export_description: export_description,
  ))
}

pub type GetItemInput {
  GetItemInput(
    attributes_to_get: option.Option(List(String)),
    consistent_read: option.Option(Bool),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    key: option.Option(dict.Dict(String, AttributeValue)),
    projection_expression: option.Option(String),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    table_name: option.Option(String),
  )
}

pub fn encode_get_item_input_struct(input: GetItemInput) -> json.Json {
  let pairs = []
  let pairs = case input.attributes_to_get {
    option.Some(v) -> [
      #("AttributesToGet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.consistent_read {
    option.Some(v) -> [#("ConsistentRead", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection_expression {
    option.Some(v) -> [#("ProjectionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_item_input_struct() -> decode.Decoder(GetItemInput) {
  use attributes_to_get <- decode.optional_field(
    "AttributesToGet",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use consistent_read <- decode.optional_field(
    "ConsistentRead",
    option.None,
    decode.optional(decode.bool),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use projection_expression <- decode.optional_field(
    "ProjectionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetItemInput(
    attributes_to_get: attributes_to_get,
    consistent_read: consistent_read,
    expression_attribute_names: expression_attribute_names,
    key: key,
    projection_expression: projection_expression,
    return_consumed_capacity: return_consumed_capacity,
    table_name: table_name,
  ))
}

pub type GetItemOutput {
  GetItemOutput(
    consumed_capacity: option.Option(ConsumedCapacity),
    item: option.Option(dict.Dict(String, AttributeValue)),
  )
}

pub fn encode_get_item_output_struct(input: GetItemOutput) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #("ConsumedCapacity", encode_consumed_capacity_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item {
    option.Some(v) -> [
      #(
        "Item",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
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

pub fn decode_get_item_output_struct() -> decode.Decoder(GetItemOutput) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode_consumed_capacity_struct()),
  )
  use item <- decode.optional_field(
    "Item",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  decode.success(GetItemOutput(consumed_capacity: consumed_capacity, item: item))
}

pub type GetResourcePolicyInput {
  GetResourcePolicyInput(resource_arn: option.Option(String))
}

pub fn encode_get_resource_policy_input_struct(
  input: GetResourcePolicyInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.resource_arn {
    option.Some(v) -> [#("ResourceArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_resource_policy_input_struct() -> decode.Decoder(
  GetResourcePolicyInput,
) {
  use resource_arn <- decode.optional_field(
    "ResourceArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetResourcePolicyInput(resource_arn: resource_arn))
}

pub type GetResourcePolicyOutput {
  GetResourcePolicyOutput(
    policy: option.Option(String),
    revision_id: option.Option(String),
  )
}

pub fn encode_get_resource_policy_output_struct(
  input: GetResourcePolicyOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.policy {
    option.Some(v) -> [#("Policy", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.revision_id {
    option.Some(v) -> [#("RevisionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_resource_policy_output_struct() -> decode.Decoder(
  GetResourcePolicyOutput,
) {
  use policy <- decode.optional_field(
    "Policy",
    option.None,
    decode.optional(decode.string),
  )
  use revision_id <- decode.optional_field(
    "RevisionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetResourcePolicyOutput(
    policy: policy,
    revision_id: revision_id,
  ))
}

pub type ImportTableInput {
  ImportTableInput(
    client_token: option.Option(String),
    input_compression_type: option.Option(InputCompressionType),
    input_format: option.Option(InputFormat),
    input_format_options: option.Option(InputFormatOptions),
    s3_bucket_source: option.Option(S3BucketSource),
    table_creation_parameters: option.Option(TableCreationParameters),
  )
}

pub fn encode_import_table_input_struct(input: ImportTableInput) -> json.Json {
  let pairs = []
  let pairs = case input.client_token {
    option.Some(v) -> [#("ClientToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.input_compression_type {
    option.Some(v) -> [
      #("InputCompressionType", encode_input_compression_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.input_format {
    option.Some(v) -> [#("InputFormat", encode_input_format_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.input_format_options {
    option.Some(v) -> [
      #("InputFormatOptions", encode_input_format_options_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket_source {
    option.Some(v) -> [
      #("S3BucketSource", encode_s3_bucket_source_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_creation_parameters {
    option.Some(v) -> [
      #("TableCreationParameters", encode_table_creation_parameters_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_import_table_input_struct() -> decode.Decoder(ImportTableInput) {
  use client_token <- decode.optional_field(
    "ClientToken",
    option.None,
    decode.optional(decode.string),
  )
  use input_compression_type <- decode.optional_field(
    "InputCompressionType",
    option.None,
    decode.optional(decode_input_compression_type_enum()),
  )
  use input_format <- decode.optional_field(
    "InputFormat",
    option.None,
    decode.optional(decode_input_format_enum()),
  )
  use input_format_options <- decode.optional_field(
    "InputFormatOptions",
    option.None,
    decode.optional(decode_input_format_options_struct()),
  )
  use s3_bucket_source <- decode.optional_field(
    "S3BucketSource",
    option.None,
    decode.optional(decode_s3_bucket_source_struct()),
  )
  use table_creation_parameters <- decode.optional_field(
    "TableCreationParameters",
    option.None,
    decode.optional(decode_table_creation_parameters_struct()),
  )
  decode.success(ImportTableInput(
    client_token: client_token,
    input_compression_type: input_compression_type,
    input_format: input_format,
    input_format_options: input_format_options,
    s3_bucket_source: s3_bucket_source,
    table_creation_parameters: table_creation_parameters,
  ))
}

pub type ImportTableOutput {
  ImportTableOutput(
    import_table_description: option.Option(ImportTableDescription),
  )
}

pub fn encode_import_table_output_struct(
  input: ImportTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.import_table_description {
    option.Some(v) -> [
      #("ImportTableDescription", encode_import_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_import_table_output_struct() -> decode.Decoder(ImportTableOutput) {
  use import_table_description <- decode.optional_field(
    "ImportTableDescription",
    option.None,
    decode.optional(decode_import_table_description_struct()),
  )
  decode.success(ImportTableOutput(
    import_table_description: import_table_description,
  ))
}

pub type ListBackupsInput {
  ListBackupsInput(
    backup_type: option.Option(BackupTypeFilter),
    exclusive_start_backup_arn: option.Option(String),
    limit: option.Option(Int),
    table_name: option.Option(String),
    time_range_lower_bound: option.Option(Int),
    time_range_upper_bound: option.Option(Int),
  )
}

pub fn encode_list_backups_input_struct(input: ListBackupsInput) -> json.Json {
  let pairs = []
  let pairs = case input.backup_type {
    option.Some(v) -> [
      #("BackupType", encode_backup_type_filter_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.exclusive_start_backup_arn {
    option.Some(v) -> [#("ExclusiveStartBackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.limit {
    option.Some(v) -> [#("Limit", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.time_range_lower_bound {
    option.Some(v) -> [#("TimeRangeLowerBound", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.time_range_upper_bound {
    option.Some(v) -> [#("TimeRangeUpperBound", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_backups_input_struct() -> decode.Decoder(ListBackupsInput) {
  use backup_type <- decode.optional_field(
    "BackupType",
    option.None,
    decode.optional(decode_backup_type_filter_enum()),
  )
  use exclusive_start_backup_arn <- decode.optional_field(
    "ExclusiveStartBackupArn",
    option.None,
    decode.optional(decode.string),
  )
  use limit <- decode.optional_field(
    "Limit",
    option.None,
    decode.optional(decode.int),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use time_range_lower_bound <- decode.optional_field(
    "TimeRangeLowerBound",
    option.None,
    decode.optional(decode.int),
  )
  use time_range_upper_bound <- decode.optional_field(
    "TimeRangeUpperBound",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ListBackupsInput(
    backup_type: backup_type,
    exclusive_start_backup_arn: exclusive_start_backup_arn,
    limit: limit,
    table_name: table_name,
    time_range_lower_bound: time_range_lower_bound,
    time_range_upper_bound: time_range_upper_bound,
  ))
}

pub type BackupTypeFilter {
  BackupTypeFilterAll
  BackupTypeFilterAwsBackup
  BackupTypeFilterSystem
  BackupTypeFilterUser
}

pub fn encode_backup_type_filter_enum(v: BackupTypeFilter) -> json.Json {
  case v {
    BackupTypeFilterAll -> json.string("ALL")
    BackupTypeFilterAwsBackup -> json.string("AWS_BACKUP")
    BackupTypeFilterSystem -> json.string("SYSTEM")
    BackupTypeFilterUser -> json.string("USER")
  }
}

pub fn decode_backup_type_filter_enum() -> decode.Decoder(BackupTypeFilter) {
  decode.then(decode.string, fn(s) {
    case s {
      "ALL" -> decode.success(BackupTypeFilterAll)
      "AWS_BACKUP" -> decode.success(BackupTypeFilterAwsBackup)
      "SYSTEM" -> decode.success(BackupTypeFilterSystem)
      "USER" -> decode.success(BackupTypeFilterUser)
      _ -> decode.failure(BackupTypeFilterAll, "unknown enum value")
    }
  })
}

pub type ListBackupsOutput {
  ListBackupsOutput(
    backup_summaries: option.Option(List(BackupSummary)),
    last_evaluated_backup_arn: option.Option(String),
  )
}

pub fn encode_list_backups_output_struct(
  input: ListBackupsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_summaries {
    option.Some(v) -> [
      #(
        "BackupSummaries",
        fn(xs) { json.array(xs, encode_backup_summary_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.last_evaluated_backup_arn {
    option.Some(v) -> [#("LastEvaluatedBackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_backups_output_struct() -> decode.Decoder(ListBackupsOutput) {
  use backup_summaries <- decode.optional_field(
    "BackupSummaries",
    option.None,
    decode.optional(decode.list(decode_backup_summary_struct())),
  )
  use last_evaluated_backup_arn <- decode.optional_field(
    "LastEvaluatedBackupArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBackupsOutput(
    backup_summaries: backup_summaries,
    last_evaluated_backup_arn: last_evaluated_backup_arn,
  ))
}

pub type BackupSummary {
  BackupSummary(
    backup_arn: option.Option(String),
    backup_creation_date_time: option.Option(Int),
    backup_expiry_date_time: option.Option(Int),
    backup_name: option.Option(String),
    backup_size_bytes: option.Option(Int),
    backup_status: option.Option(BackupStatus),
    backup_type: option.Option(BackupType),
    table_arn: option.Option(String),
    table_id: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_backup_summary_struct(input: BackupSummary) -> json.Json {
  let pairs = []
  let pairs = case input.backup_arn {
    option.Some(v) -> [#("BackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_creation_date_time {
    option.Some(v) -> [#("BackupCreationDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_expiry_date_time {
    option.Some(v) -> [#("BackupExpiryDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_name {
    option.Some(v) -> [#("BackupName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_size_bytes {
    option.Some(v) -> [#("BackupSizeBytes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_status {
    option.Some(v) -> [#("BackupStatus", encode_backup_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.backup_type {
    option.Some(v) -> [#("BackupType", encode_backup_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_id {
    option.Some(v) -> [#("TableId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_backup_summary_struct() -> decode.Decoder(BackupSummary) {
  use backup_arn <- decode.optional_field(
    "BackupArn",
    option.None,
    decode.optional(decode.string),
  )
  use backup_creation_date_time <- decode.optional_field(
    "BackupCreationDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use backup_expiry_date_time <- decode.optional_field(
    "BackupExpiryDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use backup_name <- decode.optional_field(
    "BackupName",
    option.None,
    decode.optional(decode.string),
  )
  use backup_size_bytes <- decode.optional_field(
    "BackupSizeBytes",
    option.None,
    decode.optional(decode.int),
  )
  use backup_status <- decode.optional_field(
    "BackupStatus",
    option.None,
    decode.optional(decode_backup_status_enum()),
  )
  use backup_type <- decode.optional_field(
    "BackupType",
    option.None,
    decode.optional(decode_backup_type_enum()),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_id <- decode.optional_field(
    "TableId",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(BackupSummary(
    backup_arn: backup_arn,
    backup_creation_date_time: backup_creation_date_time,
    backup_expiry_date_time: backup_expiry_date_time,
    backup_name: backup_name,
    backup_size_bytes: backup_size_bytes,
    backup_status: backup_status,
    backup_type: backup_type,
    table_arn: table_arn,
    table_id: table_id,
    table_name: table_name,
  ))
}

pub type ListContributorInsightsInput {
  ListContributorInsightsInput(
    max_results: option.Option(Int),
    next_token: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_list_contributor_insights_input_struct(
  input: ListContributorInsightsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.max_results {
    option.Some(v) -> [#("MaxResults", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_contributor_insights_input_struct() -> decode.Decoder(
  ListContributorInsightsInput,
) {
  use max_results <- decode.optional_field(
    "MaxResults",
    option.None,
    decode.optional(decode.int),
  )
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListContributorInsightsInput(
    max_results: max_results,
    next_token: next_token,
    table_name: table_name,
  ))
}

pub type ListContributorInsightsOutput {
  ListContributorInsightsOutput(
    contributor_insights_summaries: option.Option(
      List(ContributorInsightsSummary),
    ),
    next_token: option.Option(String),
  )
}

pub fn encode_list_contributor_insights_output_struct(
  input: ListContributorInsightsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.contributor_insights_summaries {
    option.Some(v) -> [
      #(
        "ContributorInsightsSummaries",
        fn(xs) { json.array(xs, encode_contributor_insights_summary_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_contributor_insights_output_struct() -> decode.Decoder(
  ListContributorInsightsOutput,
) {
  use contributor_insights_summaries <- decode.optional_field(
    "ContributorInsightsSummaries",
    option.None,
    decode.optional(decode.list(decode_contributor_insights_summary_struct())),
  )
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListContributorInsightsOutput(
    contributor_insights_summaries: contributor_insights_summaries,
    next_token: next_token,
  ))
}

pub type ContributorInsightsSummary {
  ContributorInsightsSummary(
    contributor_insights_mode: option.Option(ContributorInsightsMode),
    contributor_insights_status: option.Option(ContributorInsightsStatus),
    index_name: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_contributor_insights_summary_struct(
  input: ContributorInsightsSummary,
) -> json.Json {
  let pairs = []
  let pairs = case input.contributor_insights_mode {
    option.Some(v) -> [
      #("ContributorInsightsMode", encode_contributor_insights_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.contributor_insights_status {
    option.Some(v) -> [
      #("ContributorInsightsStatus", encode_contributor_insights_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_contributor_insights_summary_struct() -> decode.Decoder(
  ContributorInsightsSummary,
) {
  use contributor_insights_mode <- decode.optional_field(
    "ContributorInsightsMode",
    option.None,
    decode.optional(decode_contributor_insights_mode_enum()),
  )
  use contributor_insights_status <- decode.optional_field(
    "ContributorInsightsStatus",
    option.None,
    decode.optional(decode_contributor_insights_status_enum()),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ContributorInsightsSummary(
    contributor_insights_mode: contributor_insights_mode,
    contributor_insights_status: contributor_insights_status,
    index_name: index_name,
    table_name: table_name,
  ))
}

pub type ListExportsInput {
  ListExportsInput(
    max_results: option.Option(Int),
    next_token: option.Option(String),
    table_arn: option.Option(String),
  )
}

pub fn encode_list_exports_input_struct(input: ListExportsInput) -> json.Json {
  let pairs = []
  let pairs = case input.max_results {
    option.Some(v) -> [#("MaxResults", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_exports_input_struct() -> decode.Decoder(ListExportsInput) {
  use max_results <- decode.optional_field(
    "MaxResults",
    option.None,
    decode.optional(decode.int),
  )
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListExportsInput(
    max_results: max_results,
    next_token: next_token,
    table_arn: table_arn,
  ))
}

pub type ListExportsOutput {
  ListExportsOutput(
    export_summaries: option.Option(List(ExportSummary)),
    next_token: option.Option(String),
  )
}

pub fn encode_list_exports_output_struct(
  input: ListExportsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.export_summaries {
    option.Some(v) -> [
      #(
        "ExportSummaries",
        fn(xs) { json.array(xs, encode_export_summary_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_exports_output_struct() -> decode.Decoder(ListExportsOutput) {
  use export_summaries <- decode.optional_field(
    "ExportSummaries",
    option.None,
    decode.optional(decode.list(decode_export_summary_struct())),
  )
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListExportsOutput(
    export_summaries: export_summaries,
    next_token: next_token,
  ))
}

pub type ExportSummary {
  ExportSummary(
    export_arn: option.Option(String),
    export_status: option.Option(ExportStatus),
    export_type: option.Option(ExportType),
  )
}

pub fn encode_export_summary_struct(input: ExportSummary) -> json.Json {
  let pairs = []
  let pairs = case input.export_arn {
    option.Some(v) -> [#("ExportArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_status {
    option.Some(v) -> [#("ExportStatus", encode_export_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.export_type {
    option.Some(v) -> [#("ExportType", encode_export_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_export_summary_struct() -> decode.Decoder(ExportSummary) {
  use export_arn <- decode.optional_field(
    "ExportArn",
    option.None,
    decode.optional(decode.string),
  )
  use export_status <- decode.optional_field(
    "ExportStatus",
    option.None,
    decode.optional(decode_export_status_enum()),
  )
  use export_type <- decode.optional_field(
    "ExportType",
    option.None,
    decode.optional(decode_export_type_enum()),
  )
  decode.success(ExportSummary(
    export_arn: export_arn,
    export_status: export_status,
    export_type: export_type,
  ))
}

pub type ListGlobalTablesInput {
  ListGlobalTablesInput(
    exclusive_start_global_table_name: option.Option(String),
    limit: option.Option(Int),
    region_name: option.Option(String),
  )
}

pub fn encode_list_global_tables_input_struct(
  input: ListGlobalTablesInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.exclusive_start_global_table_name {
    option.Some(v) -> [
      #("ExclusiveStartGlobalTableName", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.limit {
    option.Some(v) -> [#("Limit", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_global_tables_input_struct() -> decode.Decoder(
  ListGlobalTablesInput,
) {
  use exclusive_start_global_table_name <- decode.optional_field(
    "ExclusiveStartGlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use limit <- decode.optional_field(
    "Limit",
    option.None,
    decode.optional(decode.int),
  )
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListGlobalTablesInput(
    exclusive_start_global_table_name: exclusive_start_global_table_name,
    limit: limit,
    region_name: region_name,
  ))
}

pub type ListGlobalTablesOutput {
  ListGlobalTablesOutput(
    global_tables: option.Option(List(GlobalTable)),
    last_evaluated_global_table_name: option.Option(String),
  )
}

pub fn encode_list_global_tables_output_struct(
  input: ListGlobalTablesOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_tables {
    option.Some(v) -> [
      #(
        "GlobalTables",
        fn(xs) { json.array(xs, encode_global_table_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.last_evaluated_global_table_name {
    option.Some(v) -> [
      #("LastEvaluatedGlobalTableName", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_global_tables_output_struct() -> decode.Decoder(
  ListGlobalTablesOutput,
) {
  use global_tables <- decode.optional_field(
    "GlobalTables",
    option.None,
    decode.optional(decode.list(decode_global_table_struct())),
  )
  use last_evaluated_global_table_name <- decode.optional_field(
    "LastEvaluatedGlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListGlobalTablesOutput(
    global_tables: global_tables,
    last_evaluated_global_table_name: last_evaluated_global_table_name,
  ))
}

pub type GlobalTable {
  GlobalTable(
    global_table_name: option.Option(String),
    replication_group: option.Option(List(Replica)),
  )
}

pub fn encode_global_table_struct(input: GlobalTable) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replication_group {
    option.Some(v) -> [
      #("ReplicationGroup", fn(xs) { json.array(xs, encode_replica_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_table_struct() -> decode.Decoder(GlobalTable) {
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use replication_group <- decode.optional_field(
    "ReplicationGroup",
    option.None,
    decode.optional(decode.list(decode_replica_struct())),
  )
  decode.success(GlobalTable(
    global_table_name: global_table_name,
    replication_group: replication_group,
  ))
}

pub type ListImportsInput {
  ListImportsInput(
    next_token: option.Option(String),
    page_size: option.Option(Int),
    table_arn: option.Option(String),
  )
}

pub fn encode_list_imports_input_struct(input: ListImportsInput) -> json.Json {
  let pairs = []
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.page_size {
    option.Some(v) -> [#("PageSize", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_imports_input_struct() -> decode.Decoder(ListImportsInput) {
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  use page_size <- decode.optional_field(
    "PageSize",
    option.None,
    decode.optional(decode.int),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListImportsInput(
    next_token: next_token,
    page_size: page_size,
    table_arn: table_arn,
  ))
}

pub type ListImportsOutput {
  ListImportsOutput(
    import_summary_list: option.Option(List(ImportSummary)),
    next_token: option.Option(String),
  )
}

pub fn encode_list_imports_output_struct(
  input: ListImportsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.import_summary_list {
    option.Some(v) -> [
      #(
        "ImportSummaryList",
        fn(xs) { json.array(xs, encode_import_summary_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_imports_output_struct() -> decode.Decoder(ListImportsOutput) {
  use import_summary_list <- decode.optional_field(
    "ImportSummaryList",
    option.None,
    decode.optional(decode.list(decode_import_summary_struct())),
  )
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListImportsOutput(
    import_summary_list: import_summary_list,
    next_token: next_token,
  ))
}

pub type ImportSummary {
  ImportSummary(
    cloud_watch_log_group_arn: option.Option(String),
    end_time: option.Option(Int),
    import_arn: option.Option(String),
    import_status: option.Option(ImportStatus),
    input_format: option.Option(InputFormat),
    s3_bucket_source: option.Option(S3BucketSource),
    start_time: option.Option(Int),
    table_arn: option.Option(String),
  )
}

pub fn encode_import_summary_struct(input: ImportSummary) -> json.Json {
  let pairs = []
  let pairs = case input.cloud_watch_log_group_arn {
    option.Some(v) -> [#("CloudWatchLogGroupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.end_time {
    option.Some(v) -> [#("EndTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.import_arn {
    option.Some(v) -> [#("ImportArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.import_status {
    option.Some(v) -> [#("ImportStatus", encode_import_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.input_format {
    option.Some(v) -> [#("InputFormat", encode_input_format_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.s3_bucket_source {
    option.Some(v) -> [
      #("S3BucketSource", encode_s3_bucket_source_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.start_time {
    option.Some(v) -> [#("StartTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_import_summary_struct() -> decode.Decoder(ImportSummary) {
  use cloud_watch_log_group_arn <- decode.optional_field(
    "CloudWatchLogGroupArn",
    option.None,
    decode.optional(decode.string),
  )
  use end_time <- decode.optional_field(
    "EndTime",
    option.None,
    decode.optional(decode.int),
  )
  use import_arn <- decode.optional_field(
    "ImportArn",
    option.None,
    decode.optional(decode.string),
  )
  use import_status <- decode.optional_field(
    "ImportStatus",
    option.None,
    decode.optional(decode_import_status_enum()),
  )
  use input_format <- decode.optional_field(
    "InputFormat",
    option.None,
    decode.optional(decode_input_format_enum()),
  )
  use s3_bucket_source <- decode.optional_field(
    "S3BucketSource",
    option.None,
    decode.optional(decode_s3_bucket_source_struct()),
  )
  use start_time <- decode.optional_field(
    "StartTime",
    option.None,
    decode.optional(decode.int),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ImportSummary(
    cloud_watch_log_group_arn: cloud_watch_log_group_arn,
    end_time: end_time,
    import_arn: import_arn,
    import_status: import_status,
    input_format: input_format,
    s3_bucket_source: s3_bucket_source,
    start_time: start_time,
    table_arn: table_arn,
  ))
}

pub type ListTablesInput {
  ListTablesInput(
    exclusive_start_table_name: option.Option(String),
    limit: option.Option(Int),
  )
}

pub fn encode_list_tables_input_struct(input: ListTablesInput) -> json.Json {
  let pairs = []
  let pairs = case input.exclusive_start_table_name {
    option.Some(v) -> [#("ExclusiveStartTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.limit {
    option.Some(v) -> [#("Limit", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_tables_input_struct() -> decode.Decoder(ListTablesInput) {
  use exclusive_start_table_name <- decode.optional_field(
    "ExclusiveStartTableName",
    option.None,
    decode.optional(decode.string),
  )
  use limit <- decode.optional_field(
    "Limit",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ListTablesInput(
    exclusive_start_table_name: exclusive_start_table_name,
    limit: limit,
  ))
}

pub type ListTablesOutput {
  ListTablesOutput(
    last_evaluated_table_name: option.Option(String),
    table_names: option.Option(List(String)),
  )
}

pub fn encode_list_tables_output_struct(input: ListTablesOutput) -> json.Json {
  let pairs = []
  let pairs = case input.last_evaluated_table_name {
    option.Some(v) -> [#("LastEvaluatedTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_names {
    option.Some(v) -> [
      #("TableNames", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_tables_output_struct() -> decode.Decoder(ListTablesOutput) {
  use last_evaluated_table_name <- decode.optional_field(
    "LastEvaluatedTableName",
    option.None,
    decode.optional(decode.string),
  )
  use table_names <- decode.optional_field(
    "TableNames",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  decode.success(ListTablesOutput(
    last_evaluated_table_name: last_evaluated_table_name,
    table_names: table_names,
  ))
}

pub type ListTagsOfResourceInput {
  ListTagsOfResourceInput(
    next_token: option.Option(String),
    resource_arn: option.Option(String),
  )
}

pub fn encode_list_tags_of_resource_input_struct(
  input: ListTagsOfResourceInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.resource_arn {
    option.Some(v) -> [#("ResourceArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_tags_of_resource_input_struct() -> decode.Decoder(
  ListTagsOfResourceInput,
) {
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  use resource_arn <- decode.optional_field(
    "ResourceArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListTagsOfResourceInput(
    next_token: next_token,
    resource_arn: resource_arn,
  ))
}

pub type ListTagsOfResourceOutput {
  ListTagsOfResourceOutput(
    next_token: option.Option(String),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_list_tags_of_resource_output_struct(
  input: ListTagsOfResourceOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.next_token {
    option.Some(v) -> [#("NextToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_tags_of_resource_output_struct() -> decode.Decoder(
  ListTagsOfResourceOutput,
) {
  use next_token <- decode.optional_field(
    "NextToken",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(ListTagsOfResourceOutput(next_token: next_token, tags: tags))
}

pub type PutItemInput {
  PutItemInput(
    condition_expression: option.Option(String),
    conditional_operator: option.Option(ConditionalOperator),
    expected: option.Option(dict.Dict(String, ExpectedAttributeValue)),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    item: option.Option(dict.Dict(String, AttributeValue)),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    return_item_collection_metrics: option.Option(ReturnItemCollectionMetrics),
    return_values: option.Option(ReturnValue),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    table_name: option.Option(String),
  )
}

pub fn encode_put_item_input_struct(input: PutItemInput) -> json.Json {
  let pairs = []
  let pairs = case input.condition_expression {
    option.Some(v) -> [#("ConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.conditional_operator {
    option.Some(v) -> [
      #("ConditionalOperator", encode_conditional_operator_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expected {
    option.Some(v) -> [
      #(
        "Expected",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_expected_attribute_value_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item {
    option.Some(v) -> [
      #(
        "Item",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_item_collection_metrics {
    option.Some(v) -> [
      #(
        "ReturnItemCollectionMetrics",
        encode_return_item_collection_metrics_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values {
    option.Some(v) -> [#("ReturnValues", encode_return_value_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_item_input_struct() -> decode.Decoder(PutItemInput) {
  use condition_expression <- decode.optional_field(
    "ConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use conditional_operator <- decode.optional_field(
    "ConditionalOperator",
    option.None,
    decode.optional(decode_conditional_operator_enum()),
  )
  use expected <- decode.optional_field(
    "Expected",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode_expected_attribute_value_struct(),
    )),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use item <- decode.optional_field(
    "Item",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use return_item_collection_metrics <- decode.optional_field(
    "ReturnItemCollectionMetrics",
    option.None,
    decode.optional(decode_return_item_collection_metrics_enum()),
  )
  use return_values <- decode.optional_field(
    "ReturnValues",
    option.None,
    decode.optional(decode_return_value_enum()),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(PutItemInput(
    condition_expression: condition_expression,
    conditional_operator: conditional_operator,
    expected: expected,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    item: item,
    return_consumed_capacity: return_consumed_capacity,
    return_item_collection_metrics: return_item_collection_metrics,
    return_values: return_values,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    table_name: table_name,
  ))
}

pub type PutItemOutput {
  PutItemOutput(
    attributes: option.Option(dict.Dict(String, AttributeValue)),
    consumed_capacity: option.Option(ConsumedCapacity),
    item_collection_metrics: option.Option(ItemCollectionMetrics),
  )
}

pub fn encode_put_item_output_struct(input: PutItemOutput) -> json.Json {
  let pairs = []
  let pairs = case input.attributes {
    option.Some(v) -> [
      #(
        "Attributes",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #("ConsumedCapacity", encode_consumed_capacity_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item_collection_metrics {
    option.Some(v) -> [
      #("ItemCollectionMetrics", encode_item_collection_metrics_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_item_output_struct() -> decode.Decoder(PutItemOutput) {
  use attributes <- decode.optional_field(
    "Attributes",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode_consumed_capacity_struct()),
  )
  use item_collection_metrics <- decode.optional_field(
    "ItemCollectionMetrics",
    option.None,
    decode.optional(decode_item_collection_metrics_struct()),
  )
  decode.success(PutItemOutput(
    attributes: attributes,
    consumed_capacity: consumed_capacity,
    item_collection_metrics: item_collection_metrics,
  ))
}

pub type PutResourcePolicyInput {
  PutResourcePolicyInput(
    confirm_remove_self_resource_access: option.Option(Bool),
    expected_revision_id: option.Option(String),
    policy: option.Option(String),
    resource_arn: option.Option(String),
  )
}

pub fn encode_put_resource_policy_input_struct(
  input: PutResourcePolicyInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.confirm_remove_self_resource_access {
    option.Some(v) -> [
      #("ConfirmRemoveSelfResourceAccess", json.bool(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expected_revision_id {
    option.Some(v) -> [#("ExpectedRevisionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.policy {
    option.Some(v) -> [#("Policy", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.resource_arn {
    option.Some(v) -> [#("ResourceArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_resource_policy_input_struct() -> decode.Decoder(
  PutResourcePolicyInput,
) {
  use confirm_remove_self_resource_access <- decode.optional_field(
    "ConfirmRemoveSelfResourceAccess",
    option.None,
    decode.optional(decode.bool),
  )
  use expected_revision_id <- decode.optional_field(
    "ExpectedRevisionId",
    option.None,
    decode.optional(decode.string),
  )
  use policy <- decode.optional_field(
    "Policy",
    option.None,
    decode.optional(decode.string),
  )
  use resource_arn <- decode.optional_field(
    "ResourceArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(PutResourcePolicyInput(
    confirm_remove_self_resource_access: confirm_remove_self_resource_access,
    expected_revision_id: expected_revision_id,
    policy: policy,
    resource_arn: resource_arn,
  ))
}

pub type PutResourcePolicyOutput {
  PutResourcePolicyOutput(revision_id: option.Option(String))
}

pub fn encode_put_resource_policy_output_struct(
  input: PutResourcePolicyOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.revision_id {
    option.Some(v) -> [#("RevisionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_resource_policy_output_struct() -> decode.Decoder(
  PutResourcePolicyOutput,
) {
  use revision_id <- decode.optional_field(
    "RevisionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(PutResourcePolicyOutput(revision_id: revision_id))
}

pub type QueryInput {
  QueryInput(
    attributes_to_get: option.Option(List(String)),
    conditional_operator: option.Option(ConditionalOperator),
    consistent_read: option.Option(Bool),
    exclusive_start_key: option.Option(dict.Dict(String, AttributeValue)),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    filter_expression: option.Option(String),
    index_name: option.Option(String),
    key_condition_expression: option.Option(String),
    key_conditions: option.Option(dict.Dict(String, Condition)),
    limit: option.Option(Int),
    projection_expression: option.Option(String),
    query_filter: option.Option(dict.Dict(String, Condition)),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    scan_index_forward: option.Option(Bool),
    select: option.Option(Select),
    table_name: option.Option(String),
  )
}

pub fn encode_query_input_struct(input: QueryInput) -> json.Json {
  let pairs = []
  let pairs = case input.attributes_to_get {
    option.Some(v) -> [
      #("AttributesToGet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.conditional_operator {
    option.Some(v) -> [
      #("ConditionalOperator", encode_conditional_operator_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.consistent_read {
    option.Some(v) -> [#("ConsistentRead", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.exclusive_start_key {
    option.Some(v) -> [
      #(
        "ExclusiveStartKey",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter_expression {
    option.Some(v) -> [#("FilterExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_condition_expression {
    option.Some(v) -> [#("KeyConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_conditions {
    option.Some(v) -> [
      #(
        "KeyConditions",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_condition_struct(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.limit {
    option.Some(v) -> [#("Limit", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.projection_expression {
    option.Some(v) -> [#("ProjectionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.query_filter {
    option.Some(v) -> [
      #(
        "QueryFilter",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_condition_struct(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.scan_index_forward {
    option.Some(v) -> [#("ScanIndexForward", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.select {
    option.Some(v) -> [#("Select", encode_select_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_input_struct() -> decode.Decoder(QueryInput) {
  use attributes_to_get <- decode.optional_field(
    "AttributesToGet",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use conditional_operator <- decode.optional_field(
    "ConditionalOperator",
    option.None,
    decode.optional(decode_conditional_operator_enum()),
  )
  use consistent_read <- decode.optional_field(
    "ConsistentRead",
    option.None,
    decode.optional(decode.bool),
  )
  use exclusive_start_key <- decode.optional_field(
    "ExclusiveStartKey",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use filter_expression <- decode.optional_field(
    "FilterExpression",
    option.None,
    decode.optional(decode.string),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use key_condition_expression <- decode.optional_field(
    "KeyConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use key_conditions <- decode.optional_field(
    "KeyConditions",
    option.None,
    decode.optional(decode.dict(decode.string, decode_condition_struct())),
  )
  use limit <- decode.optional_field(
    "Limit",
    option.None,
    decode.optional(decode.int),
  )
  use projection_expression <- decode.optional_field(
    "ProjectionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use query_filter <- decode.optional_field(
    "QueryFilter",
    option.None,
    decode.optional(decode.dict(decode.string, decode_condition_struct())),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use scan_index_forward <- decode.optional_field(
    "ScanIndexForward",
    option.None,
    decode.optional(decode.bool),
  )
  use select <- decode.optional_field(
    "Select",
    option.None,
    decode.optional(decode_select_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(QueryInput(
    attributes_to_get: attributes_to_get,
    conditional_operator: conditional_operator,
    consistent_read: consistent_read,
    exclusive_start_key: exclusive_start_key,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    filter_expression: filter_expression,
    index_name: index_name,
    key_condition_expression: key_condition_expression,
    key_conditions: key_conditions,
    limit: limit,
    projection_expression: projection_expression,
    query_filter: query_filter,
    return_consumed_capacity: return_consumed_capacity,
    scan_index_forward: scan_index_forward,
    select: select,
    table_name: table_name,
  ))
}

pub type Condition {
  Condition(
    attribute_value_list: option.Option(List(AttributeValue)),
    comparison_operator: option.Option(ComparisonOperator),
  )
}

pub fn encode_condition_struct(input: Condition) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_value_list {
    option.Some(v) -> [
      #(
        "AttributeValueList",
        fn(xs) { json.array(xs, encode_attribute_value_union) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.comparison_operator {
    option.Some(v) -> [
      #("ComparisonOperator", encode_comparison_operator_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_condition_struct() -> decode.Decoder(Condition) {
  use attribute_value_list <- decode.optional_field(
    "AttributeValueList",
    option.None,
    decode.optional(decode.list(decode_attribute_value_union())),
  )
  use comparison_operator <- decode.optional_field(
    "ComparisonOperator",
    option.None,
    decode.optional(decode_comparison_operator_enum()),
  )
  decode.success(Condition(
    attribute_value_list: attribute_value_list,
    comparison_operator: comparison_operator,
  ))
}

pub type Select {
  SelectAllAttributes
  SelectAllProjectedAttributes
  SelectCount
  SelectSpecificAttributes
}

pub fn encode_select_enum(v: Select) -> json.Json {
  case v {
    SelectAllAttributes -> json.string("ALL_ATTRIBUTES")
    SelectAllProjectedAttributes -> json.string("ALL_PROJECTED_ATTRIBUTES")
    SelectCount -> json.string("COUNT")
    SelectSpecificAttributes -> json.string("SPECIFIC_ATTRIBUTES")
  }
}

pub fn decode_select_enum() -> decode.Decoder(Select) {
  decode.then(decode.string, fn(s) {
    case s {
      "ALL_ATTRIBUTES" -> decode.success(SelectAllAttributes)
      "ALL_PROJECTED_ATTRIBUTES" -> decode.success(SelectAllProjectedAttributes)
      "COUNT" -> decode.success(SelectCount)
      "SPECIFIC_ATTRIBUTES" -> decode.success(SelectSpecificAttributes)
      _ -> decode.failure(SelectAllAttributes, "unknown enum value")
    }
  })
}

pub type QueryOutput {
  QueryOutput(
    consumed_capacity: option.Option(ConsumedCapacity),
    count: option.Option(Int),
    items: option.Option(List(dict.Dict(String, AttributeValue))),
    last_evaluated_key: option.Option(dict.Dict(String, AttributeValue)),
    scanned_count: option.Option(Int),
  )
}

pub fn encode_query_output_struct(input: QueryOutput) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #("ConsumedCapacity", encode_consumed_capacity_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.count {
    option.Some(v) -> [#("Count", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.items {
    option.Some(v) -> [
      #(
        "Items",
        fn(xs) {
          json.array(xs, fn(d) {
            json.object(
              dict.to_list(d)
              |> list.map(fn(pair) {
                #(pair.0, encode_attribute_value_union(pair.1))
              }),
            )
          })
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.last_evaluated_key {
    option.Some(v) -> [
      #(
        "LastEvaluatedKey",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.scanned_count {
    option.Some(v) -> [#("ScannedCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_query_output_struct() -> decode.Decoder(QueryOutput) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode_consumed_capacity_struct()),
  )
  use count <- decode.optional_field(
    "Count",
    option.None,
    decode.optional(decode.int),
  )
  use items <- decode.optional_field(
    "Items",
    option.None,
    decode.optional(
      decode.list(decode.dict(decode.string, decode_attribute_value_union())),
    ),
  )
  use last_evaluated_key <- decode.optional_field(
    "LastEvaluatedKey",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use scanned_count <- decode.optional_field(
    "ScannedCount",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(QueryOutput(
    consumed_capacity: consumed_capacity,
    count: count,
    items: items,
    last_evaluated_key: last_evaluated_key,
    scanned_count: scanned_count,
  ))
}

pub type RestoreTableFromBackupInput {
  RestoreTableFromBackupInput(
    backup_arn: option.Option(String),
    billing_mode_override: option.Option(BillingMode),
    global_secondary_index_override: option.Option(List(GlobalSecondaryIndex)),
    local_secondary_index_override: option.Option(List(LocalSecondaryIndex)),
    on_demand_throughput_override: option.Option(OnDemandThroughput),
    provisioned_throughput_override: option.Option(ProvisionedThroughput),
    sse_specification_override: option.Option(SSESpecification),
    target_table_name: option.Option(String),
  )
}

pub fn encode_restore_table_from_backup_input_struct(
  input: RestoreTableFromBackupInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.backup_arn {
    option.Some(v) -> [#("BackupArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.billing_mode_override {
    option.Some(v) -> [
      #("BillingModeOverride", encode_billing_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_secondary_index_override {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexOverride",
        fn(xs) { json.array(xs, encode_global_secondary_index_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.local_secondary_index_override {
    option.Some(v) -> [
      #(
        "LocalSecondaryIndexOverride",
        fn(xs) { json.array(xs, encode_local_secondary_index_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput_override {
    option.Some(v) -> [
      #("OnDemandThroughputOverride", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput_override {
    option.Some(v) -> [
      #(
        "ProvisionedThroughputOverride",
        encode_provisioned_throughput_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_specification_override {
    option.Some(v) -> [
      #("SSESpecificationOverride", encode_sse_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.target_table_name {
    option.Some(v) -> [#("TargetTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_restore_table_from_backup_input_struct() -> decode.Decoder(
  RestoreTableFromBackupInput,
) {
  use backup_arn <- decode.optional_field(
    "BackupArn",
    option.None,
    decode.optional(decode.string),
  )
  use billing_mode_override <- decode.optional_field(
    "BillingModeOverride",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use global_secondary_index_override <- decode.optional_field(
    "GlobalSecondaryIndexOverride",
    option.None,
    decode.optional(decode.list(decode_global_secondary_index_struct())),
  )
  use local_secondary_index_override <- decode.optional_field(
    "LocalSecondaryIndexOverride",
    option.None,
    decode.optional(decode.list(decode_local_secondary_index_struct())),
  )
  use on_demand_throughput_override <- decode.optional_field(
    "OnDemandThroughputOverride",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput_override <- decode.optional_field(
    "ProvisionedThroughputOverride",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use sse_specification_override <- decode.optional_field(
    "SSESpecificationOverride",
    option.None,
    decode.optional(decode_sse_specification_struct()),
  )
  use target_table_name <- decode.optional_field(
    "TargetTableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(RestoreTableFromBackupInput(
    backup_arn: backup_arn,
    billing_mode_override: billing_mode_override,
    global_secondary_index_override: global_secondary_index_override,
    local_secondary_index_override: local_secondary_index_override,
    on_demand_throughput_override: on_demand_throughput_override,
    provisioned_throughput_override: provisioned_throughput_override,
    sse_specification_override: sse_specification_override,
    target_table_name: target_table_name,
  ))
}

pub type RestoreTableFromBackupOutput {
  RestoreTableFromBackupOutput(
    table_description: option.Option(TableDescription),
  )
}

pub fn encode_restore_table_from_backup_output_struct(
  input: RestoreTableFromBackupOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_description {
    option.Some(v) -> [
      #("TableDescription", encode_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_restore_table_from_backup_output_struct() -> decode.Decoder(
  RestoreTableFromBackupOutput,
) {
  use table_description <- decode.optional_field(
    "TableDescription",
    option.None,
    decode.optional(decode_table_description_struct()),
  )
  decode.success(RestoreTableFromBackupOutput(
    table_description: table_description,
  ))
}

pub type RestoreTableToPointInTimeInput {
  RestoreTableToPointInTimeInput(
    billing_mode_override: option.Option(BillingMode),
    global_secondary_index_override: option.Option(List(GlobalSecondaryIndex)),
    local_secondary_index_override: option.Option(List(LocalSecondaryIndex)),
    on_demand_throughput_override: option.Option(OnDemandThroughput),
    provisioned_throughput_override: option.Option(ProvisionedThroughput),
    restore_date_time: option.Option(Int),
    sse_specification_override: option.Option(SSESpecification),
    source_table_arn: option.Option(String),
    source_table_name: option.Option(String),
    target_table_name: option.Option(String),
    use_latest_restorable_time: option.Option(Bool),
  )
}

pub fn encode_restore_table_to_point_in_time_input_struct(
  input: RestoreTableToPointInTimeInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.billing_mode_override {
    option.Some(v) -> [
      #("BillingModeOverride", encode_billing_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_secondary_index_override {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexOverride",
        fn(xs) { json.array(xs, encode_global_secondary_index_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.local_secondary_index_override {
    option.Some(v) -> [
      #(
        "LocalSecondaryIndexOverride",
        fn(xs) { json.array(xs, encode_local_secondary_index_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput_override {
    option.Some(v) -> [
      #("OnDemandThroughputOverride", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput_override {
    option.Some(v) -> [
      #(
        "ProvisionedThroughputOverride",
        encode_provisioned_throughput_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.restore_date_time {
    option.Some(v) -> [#("RestoreDateTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_specification_override {
    option.Some(v) -> [
      #("SSESpecificationOverride", encode_sse_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.source_table_arn {
    option.Some(v) -> [#("SourceTableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_table_name {
    option.Some(v) -> [#("SourceTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_table_name {
    option.Some(v) -> [#("TargetTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.use_latest_restorable_time {
    option.Some(v) -> [#("UseLatestRestorableTime", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_restore_table_to_point_in_time_input_struct() -> decode.Decoder(
  RestoreTableToPointInTimeInput,
) {
  use billing_mode_override <- decode.optional_field(
    "BillingModeOverride",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use global_secondary_index_override <- decode.optional_field(
    "GlobalSecondaryIndexOverride",
    option.None,
    decode.optional(decode.list(decode_global_secondary_index_struct())),
  )
  use local_secondary_index_override <- decode.optional_field(
    "LocalSecondaryIndexOverride",
    option.None,
    decode.optional(decode.list(decode_local_secondary_index_struct())),
  )
  use on_demand_throughput_override <- decode.optional_field(
    "OnDemandThroughputOverride",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput_override <- decode.optional_field(
    "ProvisionedThroughputOverride",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use restore_date_time <- decode.optional_field(
    "RestoreDateTime",
    option.None,
    decode.optional(decode.int),
  )
  use sse_specification_override <- decode.optional_field(
    "SSESpecificationOverride",
    option.None,
    decode.optional(decode_sse_specification_struct()),
  )
  use source_table_arn <- decode.optional_field(
    "SourceTableArn",
    option.None,
    decode.optional(decode.string),
  )
  use source_table_name <- decode.optional_field(
    "SourceTableName",
    option.None,
    decode.optional(decode.string),
  )
  use target_table_name <- decode.optional_field(
    "TargetTableName",
    option.None,
    decode.optional(decode.string),
  )
  use use_latest_restorable_time <- decode.optional_field(
    "UseLatestRestorableTime",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(RestoreTableToPointInTimeInput(
    billing_mode_override: billing_mode_override,
    global_secondary_index_override: global_secondary_index_override,
    local_secondary_index_override: local_secondary_index_override,
    on_demand_throughput_override: on_demand_throughput_override,
    provisioned_throughput_override: provisioned_throughput_override,
    restore_date_time: restore_date_time,
    sse_specification_override: sse_specification_override,
    source_table_arn: source_table_arn,
    source_table_name: source_table_name,
    target_table_name: target_table_name,
    use_latest_restorable_time: use_latest_restorable_time,
  ))
}

pub type RestoreTableToPointInTimeOutput {
  RestoreTableToPointInTimeOutput(
    table_description: option.Option(TableDescription),
  )
}

pub fn encode_restore_table_to_point_in_time_output_struct(
  input: RestoreTableToPointInTimeOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_description {
    option.Some(v) -> [
      #("TableDescription", encode_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_restore_table_to_point_in_time_output_struct() -> decode.Decoder(
  RestoreTableToPointInTimeOutput,
) {
  use table_description <- decode.optional_field(
    "TableDescription",
    option.None,
    decode.optional(decode_table_description_struct()),
  )
  decode.success(RestoreTableToPointInTimeOutput(
    table_description: table_description,
  ))
}

pub type ScanInput {
  ScanInput(
    attributes_to_get: option.Option(List(String)),
    conditional_operator: option.Option(ConditionalOperator),
    consistent_read: option.Option(Bool),
    exclusive_start_key: option.Option(dict.Dict(String, AttributeValue)),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    filter_expression: option.Option(String),
    index_name: option.Option(String),
    limit: option.Option(Int),
    projection_expression: option.Option(String),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    scan_filter: option.Option(dict.Dict(String, Condition)),
    segment: option.Option(Int),
    select: option.Option(Select),
    table_name: option.Option(String),
    total_segments: option.Option(Int),
  )
}

pub fn encode_scan_input_struct(input: ScanInput) -> json.Json {
  let pairs = []
  let pairs = case input.attributes_to_get {
    option.Some(v) -> [
      #("AttributesToGet", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.conditional_operator {
    option.Some(v) -> [
      #("ConditionalOperator", encode_conditional_operator_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.consistent_read {
    option.Some(v) -> [#("ConsistentRead", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.exclusive_start_key {
    option.Some(v) -> [
      #(
        "ExclusiveStartKey",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter_expression {
    option.Some(v) -> [#("FilterExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.limit {
    option.Some(v) -> [#("Limit", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.projection_expression {
    option.Some(v) -> [#("ProjectionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.scan_filter {
    option.Some(v) -> [
      #(
        "ScanFilter",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, encode_condition_struct(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.segment {
    option.Some(v) -> [#("Segment", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.select {
    option.Some(v) -> [#("Select", encode_select_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.total_segments {
    option.Some(v) -> [#("TotalSegments", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_scan_input_struct() -> decode.Decoder(ScanInput) {
  use attributes_to_get <- decode.optional_field(
    "AttributesToGet",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use conditional_operator <- decode.optional_field(
    "ConditionalOperator",
    option.None,
    decode.optional(decode_conditional_operator_enum()),
  )
  use consistent_read <- decode.optional_field(
    "ConsistentRead",
    option.None,
    decode.optional(decode.bool),
  )
  use exclusive_start_key <- decode.optional_field(
    "ExclusiveStartKey",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use filter_expression <- decode.optional_field(
    "FilterExpression",
    option.None,
    decode.optional(decode.string),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use limit <- decode.optional_field(
    "Limit",
    option.None,
    decode.optional(decode.int),
  )
  use projection_expression <- decode.optional_field(
    "ProjectionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use scan_filter <- decode.optional_field(
    "ScanFilter",
    option.None,
    decode.optional(decode.dict(decode.string, decode_condition_struct())),
  )
  use segment <- decode.optional_field(
    "Segment",
    option.None,
    decode.optional(decode.int),
  )
  use select <- decode.optional_field(
    "Select",
    option.None,
    decode.optional(decode_select_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use total_segments <- decode.optional_field(
    "TotalSegments",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ScanInput(
    attributes_to_get: attributes_to_get,
    conditional_operator: conditional_operator,
    consistent_read: consistent_read,
    exclusive_start_key: exclusive_start_key,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    filter_expression: filter_expression,
    index_name: index_name,
    limit: limit,
    projection_expression: projection_expression,
    return_consumed_capacity: return_consumed_capacity,
    scan_filter: scan_filter,
    segment: segment,
    select: select,
    table_name: table_name,
    total_segments: total_segments,
  ))
}

pub type ScanOutput {
  ScanOutput(
    consumed_capacity: option.Option(ConsumedCapacity),
    count: option.Option(Int),
    items: option.Option(List(dict.Dict(String, AttributeValue))),
    last_evaluated_key: option.Option(dict.Dict(String, AttributeValue)),
    scanned_count: option.Option(Int),
  )
}

pub fn encode_scan_output_struct(input: ScanOutput) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #("ConsumedCapacity", encode_consumed_capacity_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.count {
    option.Some(v) -> [#("Count", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.items {
    option.Some(v) -> [
      #(
        "Items",
        fn(xs) {
          json.array(xs, fn(d) {
            json.object(
              dict.to_list(d)
              |> list.map(fn(pair) {
                #(pair.0, encode_attribute_value_union(pair.1))
              }),
            )
          })
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.last_evaluated_key {
    option.Some(v) -> [
      #(
        "LastEvaluatedKey",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.scanned_count {
    option.Some(v) -> [#("ScannedCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_scan_output_struct() -> decode.Decoder(ScanOutput) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode_consumed_capacity_struct()),
  )
  use count <- decode.optional_field(
    "Count",
    option.None,
    decode.optional(decode.int),
  )
  use items <- decode.optional_field(
    "Items",
    option.None,
    decode.optional(
      decode.list(decode.dict(decode.string, decode_attribute_value_union())),
    ),
  )
  use last_evaluated_key <- decode.optional_field(
    "LastEvaluatedKey",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use scanned_count <- decode.optional_field(
    "ScannedCount",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ScanOutput(
    consumed_capacity: consumed_capacity,
    count: count,
    items: items,
    last_evaluated_key: last_evaluated_key,
    scanned_count: scanned_count,
  ))
}

pub type TagResourceInput {
  TagResourceInput(
    resource_arn: option.Option(String),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_tag_resource_input_struct(input: TagResourceInput) -> json.Json {
  let pairs = []
  let pairs = case input.resource_arn {
    option.Some(v) -> [#("ResourceArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_tag_resource_input_struct() -> decode.Decoder(TagResourceInput) {
  use resource_arn <- decode.optional_field(
    "ResourceArn",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(TagResourceInput(resource_arn: resource_arn, tags: tags))
}

pub type TransactGetItemsInput {
  TransactGetItemsInput(
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    transact_items: option.Option(List(TransactGetItem)),
  )
}

pub fn encode_transact_get_items_input_struct(
  input: TransactGetItemsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.transact_items {
    option.Some(v) -> [
      #(
        "TransactItems",
        fn(xs) { json.array(xs, encode_transact_get_item_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_transact_get_items_input_struct() -> decode.Decoder(
  TransactGetItemsInput,
) {
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use transact_items <- decode.optional_field(
    "TransactItems",
    option.None,
    decode.optional(decode.list(decode_transact_get_item_struct())),
  )
  decode.success(TransactGetItemsInput(
    return_consumed_capacity: return_consumed_capacity,
    transact_items: transact_items,
  ))
}

pub type TransactGetItem {
  TransactGetItem(get: option.Option(Get))
}

pub fn encode_transact_get_item_struct(input: TransactGetItem) -> json.Json {
  let pairs = []
  let pairs = case input.get {
    option.Some(v) -> [#("Get", encode_get_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_transact_get_item_struct() -> decode.Decoder(TransactGetItem) {
  use get <- decode.optional_field(
    "Get",
    option.None,
    decode.optional(decode_get_struct()),
  )
  decode.success(TransactGetItem(get: get))
}

pub type Get {
  Get(
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    key: option.Option(dict.Dict(String, AttributeValue)),
    projection_expression: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_get_struct(input: Get) -> json.Json {
  let pairs = []
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection_expression {
    option.Some(v) -> [#("ProjectionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_struct() -> decode.Decoder(Get) {
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use projection_expression <- decode.optional_field(
    "ProjectionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Get(
    expression_attribute_names: expression_attribute_names,
    key: key,
    projection_expression: projection_expression,
    table_name: table_name,
  ))
}

pub type TransactGetItemsOutput {
  TransactGetItemsOutput(
    consumed_capacity: option.Option(List(ConsumedCapacity)),
    responses: option.Option(List(ItemResponse)),
  )
}

pub fn encode_transact_get_items_output_struct(
  input: TransactGetItemsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #(
        "ConsumedCapacity",
        fn(xs) { json.array(xs, encode_consumed_capacity_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.responses {
    option.Some(v) -> [
      #("Responses", fn(xs) { json.array(xs, encode_item_response_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_transact_get_items_output_struct() -> decode.Decoder(
  TransactGetItemsOutput,
) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode.list(decode_consumed_capacity_struct())),
  )
  use responses <- decode.optional_field(
    "Responses",
    option.None,
    decode.optional(decode.list(decode_item_response_struct())),
  )
  decode.success(TransactGetItemsOutput(
    consumed_capacity: consumed_capacity,
    responses: responses,
  ))
}

pub type TransactWriteItemsInput {
  TransactWriteItemsInput(
    client_request_token: option.Option(String),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    return_item_collection_metrics: option.Option(ReturnItemCollectionMetrics),
    transact_items: option.Option(List(TransactWriteItem)),
  )
}

pub fn encode_transact_write_items_input_struct(
  input: TransactWriteItemsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.client_request_token {
    option.Some(v) -> [#("ClientRequestToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_item_collection_metrics {
    option.Some(v) -> [
      #(
        "ReturnItemCollectionMetrics",
        encode_return_item_collection_metrics_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.transact_items {
    option.Some(v) -> [
      #(
        "TransactItems",
        fn(xs) { json.array(xs, encode_transact_write_item_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_transact_write_items_input_struct() -> decode.Decoder(
  TransactWriteItemsInput,
) {
  use client_request_token <- decode.optional_field(
    "ClientRequestToken",
    option.None,
    decode.optional(decode.string),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use return_item_collection_metrics <- decode.optional_field(
    "ReturnItemCollectionMetrics",
    option.None,
    decode.optional(decode_return_item_collection_metrics_enum()),
  )
  use transact_items <- decode.optional_field(
    "TransactItems",
    option.None,
    decode.optional(decode.list(decode_transact_write_item_struct())),
  )
  decode.success(TransactWriteItemsInput(
    client_request_token: client_request_token,
    return_consumed_capacity: return_consumed_capacity,
    return_item_collection_metrics: return_item_collection_metrics,
    transact_items: transact_items,
  ))
}

pub type TransactWriteItem {
  TransactWriteItem(
    condition_check: option.Option(ConditionCheck),
    delete: option.Option(Delete),
    put: option.Option(Put),
    update: option.Option(Update),
  )
}

pub fn encode_transact_write_item_struct(
  input: TransactWriteItem,
) -> json.Json {
  let pairs = []
  let pairs = case input.condition_check {
    option.Some(v) -> [
      #("ConditionCheck", encode_condition_check_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delete {
    option.Some(v) -> [#("Delete", encode_delete_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.put {
    option.Some(v) -> [#("Put", encode_put_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.update {
    option.Some(v) -> [#("Update", encode_update_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_transact_write_item_struct() -> decode.Decoder(TransactWriteItem) {
  use condition_check <- decode.optional_field(
    "ConditionCheck",
    option.None,
    decode.optional(decode_condition_check_struct()),
  )
  use delete <- decode.optional_field(
    "Delete",
    option.None,
    decode.optional(decode_delete_struct()),
  )
  use put <- decode.optional_field(
    "Put",
    option.None,
    decode.optional(decode_put_struct()),
  )
  use update <- decode.optional_field(
    "Update",
    option.None,
    decode.optional(decode_update_struct()),
  )
  decode.success(TransactWriteItem(
    condition_check: condition_check,
    delete: delete,
    put: put,
    update: update,
  ))
}

pub type ConditionCheck {
  ConditionCheck(
    condition_expression: option.Option(String),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    key: option.Option(dict.Dict(String, AttributeValue)),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    table_name: option.Option(String),
  )
}

pub fn encode_condition_check_struct(input: ConditionCheck) -> json.Json {
  let pairs = []
  let pairs = case input.condition_expression {
    option.Some(v) -> [#("ConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_condition_check_struct() -> decode.Decoder(ConditionCheck) {
  use condition_expression <- decode.optional_field(
    "ConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ConditionCheck(
    condition_expression: condition_expression,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    key: key,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    table_name: table_name,
  ))
}

pub type Delete {
  Delete(
    condition_expression: option.Option(String),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    key: option.Option(dict.Dict(String, AttributeValue)),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    table_name: option.Option(String),
  )
}

pub fn encode_delete_struct(input: Delete) -> json.Json {
  let pairs = []
  let pairs = case input.condition_expression {
    option.Some(v) -> [#("ConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_struct() -> decode.Decoder(Delete) {
  use condition_expression <- decode.optional_field(
    "ConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Delete(
    condition_expression: condition_expression,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    key: key,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    table_name: table_name,
  ))
}

pub type Put {
  Put(
    condition_expression: option.Option(String),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    item: option.Option(dict.Dict(String, AttributeValue)),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    table_name: option.Option(String),
  )
}

pub fn encode_put_struct(input: Put) -> json.Json {
  let pairs = []
  let pairs = case input.condition_expression {
    option.Some(v) -> [#("ConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item {
    option.Some(v) -> [
      #(
        "Item",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_struct() -> decode.Decoder(Put) {
  use condition_expression <- decode.optional_field(
    "ConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use item <- decode.optional_field(
    "Item",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Put(
    condition_expression: condition_expression,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    item: item,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    table_name: table_name,
  ))
}

pub type Update {
  Update(
    condition_expression: option.Option(String),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    key: option.Option(dict.Dict(String, AttributeValue)),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    table_name: option.Option(String),
    update_expression: option.Option(String),
  )
}

pub fn encode_update_struct(input: Update) -> json.Json {
  let pairs = []
  let pairs = case input.condition_expression {
    option.Some(v) -> [#("ConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.update_expression {
    option.Some(v) -> [#("UpdateExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_struct() -> decode.Decoder(Update) {
  use condition_expression <- decode.optional_field(
    "ConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use update_expression <- decode.optional_field(
    "UpdateExpression",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Update(
    condition_expression: condition_expression,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    key: key,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    table_name: table_name,
    update_expression: update_expression,
  ))
}

pub type TransactWriteItemsOutput {
  TransactWriteItemsOutput(
    consumed_capacity: option.Option(List(ConsumedCapacity)),
    item_collection_metrics: option.Option(
      dict.Dict(String, List(ItemCollectionMetrics)),
    ),
  )
}

pub fn encode_transact_write_items_output_struct(
  input: TransactWriteItemsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #(
        "ConsumedCapacity",
        fn(xs) { json.array(xs, encode_consumed_capacity_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item_collection_metrics {
    option.Some(v) -> [
      #(
        "ItemCollectionMetrics",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(
                pair.0,
                fn(xs) { json.array(xs, encode_item_collection_metrics_struct) }(
                  pair.1,
                ),
              )
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

pub fn decode_transact_write_items_output_struct() -> decode.Decoder(
  TransactWriteItemsOutput,
) {
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode.list(decode_consumed_capacity_struct())),
  )
  use item_collection_metrics <- decode.optional_field(
    "ItemCollectionMetrics",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode.list(decode_item_collection_metrics_struct()),
    )),
  )
  decode.success(TransactWriteItemsOutput(
    consumed_capacity: consumed_capacity,
    item_collection_metrics: item_collection_metrics,
  ))
}

pub type UntagResourceInput {
  UntagResourceInput(
    resource_arn: option.Option(String),
    tag_keys: option.Option(List(String)),
  )
}

pub fn encode_untag_resource_input_struct(
  input: UntagResourceInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.resource_arn {
    option.Some(v) -> [#("ResourceArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tag_keys {
    option.Some(v) -> [
      #("TagKeys", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_untag_resource_input_struct() -> decode.Decoder(
  UntagResourceInput,
) {
  use resource_arn <- decode.optional_field(
    "ResourceArn",
    option.None,
    decode.optional(decode.string),
  )
  use tag_keys <- decode.optional_field(
    "TagKeys",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  decode.success(UntagResourceInput(
    resource_arn: resource_arn,
    tag_keys: tag_keys,
  ))
}

pub type UpdateContinuousBackupsInput {
  UpdateContinuousBackupsInput(
    point_in_time_recovery_specification: option.Option(
      PointInTimeRecoverySpecification,
    ),
    table_name: option.Option(String),
  )
}

pub fn encode_update_continuous_backups_input_struct(
  input: UpdateContinuousBackupsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.point_in_time_recovery_specification {
    option.Some(v) -> [
      #(
        "PointInTimeRecoverySpecification",
        encode_point_in_time_recovery_specification_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_continuous_backups_input_struct() -> decode.Decoder(
  UpdateContinuousBackupsInput,
) {
  use point_in_time_recovery_specification <- decode.optional_field(
    "PointInTimeRecoverySpecification",
    option.None,
    decode.optional(decode_point_in_time_recovery_specification_struct()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(UpdateContinuousBackupsInput(
    point_in_time_recovery_specification: point_in_time_recovery_specification,
    table_name: table_name,
  ))
}

pub type PointInTimeRecoverySpecification {
  PointInTimeRecoverySpecification(
    point_in_time_recovery_enabled: option.Option(Bool),
    recovery_period_in_days: option.Option(Int),
  )
}

pub fn encode_point_in_time_recovery_specification_struct(
  input: PointInTimeRecoverySpecification,
) -> json.Json {
  let pairs = []
  let pairs = case input.point_in_time_recovery_enabled {
    option.Some(v) -> [#("PointInTimeRecoveryEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.recovery_period_in_days {
    option.Some(v) -> [#("RecoveryPeriodInDays", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_point_in_time_recovery_specification_struct() -> decode.Decoder(
  PointInTimeRecoverySpecification,
) {
  use point_in_time_recovery_enabled <- decode.optional_field(
    "PointInTimeRecoveryEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use recovery_period_in_days <- decode.optional_field(
    "RecoveryPeriodInDays",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(PointInTimeRecoverySpecification(
    point_in_time_recovery_enabled: point_in_time_recovery_enabled,
    recovery_period_in_days: recovery_period_in_days,
  ))
}

pub type UpdateContinuousBackupsOutput {
  UpdateContinuousBackupsOutput(
    continuous_backups_description: option.Option(ContinuousBackupsDescription),
  )
}

pub fn encode_update_continuous_backups_output_struct(
  input: UpdateContinuousBackupsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.continuous_backups_description {
    option.Some(v) -> [
      #(
        "ContinuousBackupsDescription",
        encode_continuous_backups_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_continuous_backups_output_struct() -> decode.Decoder(
  UpdateContinuousBackupsOutput,
) {
  use continuous_backups_description <- decode.optional_field(
    "ContinuousBackupsDescription",
    option.None,
    decode.optional(decode_continuous_backups_description_struct()),
  )
  decode.success(UpdateContinuousBackupsOutput(
    continuous_backups_description: continuous_backups_description,
  ))
}

pub type UpdateContributorInsightsInput {
  UpdateContributorInsightsInput(
    contributor_insights_action: option.Option(ContributorInsightsAction),
    contributor_insights_mode: option.Option(ContributorInsightsMode),
    index_name: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_update_contributor_insights_input_struct(
  input: UpdateContributorInsightsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.contributor_insights_action {
    option.Some(v) -> [
      #("ContributorInsightsAction", encode_contributor_insights_action_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.contributor_insights_mode {
    option.Some(v) -> [
      #("ContributorInsightsMode", encode_contributor_insights_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_contributor_insights_input_struct() -> decode.Decoder(
  UpdateContributorInsightsInput,
) {
  use contributor_insights_action <- decode.optional_field(
    "ContributorInsightsAction",
    option.None,
    decode.optional(decode_contributor_insights_action_enum()),
  )
  use contributor_insights_mode <- decode.optional_field(
    "ContributorInsightsMode",
    option.None,
    decode.optional(decode_contributor_insights_mode_enum()),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(UpdateContributorInsightsInput(
    contributor_insights_action: contributor_insights_action,
    contributor_insights_mode: contributor_insights_mode,
    index_name: index_name,
    table_name: table_name,
  ))
}

pub type ContributorInsightsAction {
  ContributorInsightsActionDisable
  ContributorInsightsActionEnable
}

pub fn encode_contributor_insights_action_enum(
  v: ContributorInsightsAction,
) -> json.Json {
  case v {
    ContributorInsightsActionDisable -> json.string("DISABLE")
    ContributorInsightsActionEnable -> json.string("ENABLE")
  }
}

pub fn decode_contributor_insights_action_enum() -> decode.Decoder(
  ContributorInsightsAction,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLE" -> decode.success(ContributorInsightsActionDisable)
      "ENABLE" -> decode.success(ContributorInsightsActionEnable)
      _ ->
        decode.failure(ContributorInsightsActionDisable, "unknown enum value")
    }
  })
}

pub type UpdateContributorInsightsOutput {
  UpdateContributorInsightsOutput(
    contributor_insights_mode: option.Option(ContributorInsightsMode),
    contributor_insights_status: option.Option(ContributorInsightsStatus),
    index_name: option.Option(String),
    table_name: option.Option(String),
  )
}

pub fn encode_update_contributor_insights_output_struct(
  input: UpdateContributorInsightsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.contributor_insights_mode {
    option.Some(v) -> [
      #("ContributorInsightsMode", encode_contributor_insights_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.contributor_insights_status {
    option.Some(v) -> [
      #("ContributorInsightsStatus", encode_contributor_insights_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_contributor_insights_output_struct() -> decode.Decoder(
  UpdateContributorInsightsOutput,
) {
  use contributor_insights_mode <- decode.optional_field(
    "ContributorInsightsMode",
    option.None,
    decode.optional(decode_contributor_insights_mode_enum()),
  )
  use contributor_insights_status <- decode.optional_field(
    "ContributorInsightsStatus",
    option.None,
    decode.optional(decode_contributor_insights_status_enum()),
  )
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(UpdateContributorInsightsOutput(
    contributor_insights_mode: contributor_insights_mode,
    contributor_insights_status: contributor_insights_status,
    index_name: index_name,
    table_name: table_name,
  ))
}

pub type UpdateGlobalTableInput {
  UpdateGlobalTableInput(
    global_table_name: option.Option(String),
    replica_updates: option.Option(List(ReplicaUpdate)),
  )
}

pub fn encode_update_global_table_input_struct(
  input: UpdateGlobalTableInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_updates {
    option.Some(v) -> [
      #(
        "ReplicaUpdates",
        fn(xs) { json.array(xs, encode_replica_update_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_global_table_input_struct() -> decode.Decoder(
  UpdateGlobalTableInput,
) {
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_updates <- decode.optional_field(
    "ReplicaUpdates",
    option.None,
    decode.optional(decode.list(decode_replica_update_struct())),
  )
  decode.success(UpdateGlobalTableInput(
    global_table_name: global_table_name,
    replica_updates: replica_updates,
  ))
}

pub type ReplicaUpdate {
  ReplicaUpdate(
    create: option.Option(CreateReplicaAction),
    delete: option.Option(DeleteReplicaAction),
  )
}

pub fn encode_replica_update_struct(input: ReplicaUpdate) -> json.Json {
  let pairs = []
  let pairs = case input.create {
    option.Some(v) -> [
      #("Create", encode_create_replica_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delete {
    option.Some(v) -> [
      #("Delete", encode_delete_replica_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_update_struct() -> decode.Decoder(ReplicaUpdate) {
  use create <- decode.optional_field(
    "Create",
    option.None,
    decode.optional(decode_create_replica_action_struct()),
  )
  use delete <- decode.optional_field(
    "Delete",
    option.None,
    decode.optional(decode_delete_replica_action_struct()),
  )
  decode.success(ReplicaUpdate(create: create, delete: delete))
}

pub type CreateReplicaAction {
  CreateReplicaAction(region_name: option.Option(String))
}

pub fn encode_create_replica_action_struct(
  input: CreateReplicaAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_replica_action_struct() -> decode.Decoder(
  CreateReplicaAction,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CreateReplicaAction(region_name: region_name))
}

pub type DeleteReplicaAction {
  DeleteReplicaAction(region_name: option.Option(String))
}

pub fn encode_delete_replica_action_struct(
  input: DeleteReplicaAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_replica_action_struct() -> decode.Decoder(
  DeleteReplicaAction,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteReplicaAction(region_name: region_name))
}

pub type UpdateGlobalTableOutput {
  UpdateGlobalTableOutput(
    global_table_description: option.Option(GlobalTableDescription),
  )
}

pub fn encode_update_global_table_output_struct(
  input: UpdateGlobalTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_description {
    option.Some(v) -> [
      #("GlobalTableDescription", encode_global_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_global_table_output_struct() -> decode.Decoder(
  UpdateGlobalTableOutput,
) {
  use global_table_description <- decode.optional_field(
    "GlobalTableDescription",
    option.None,
    decode.optional(decode_global_table_description_struct()),
  )
  decode.success(UpdateGlobalTableOutput(
    global_table_description: global_table_description,
  ))
}

pub type UpdateGlobalTableSettingsInput {
  UpdateGlobalTableSettingsInput(
    global_table_billing_mode: option.Option(BillingMode),
    global_table_global_secondary_index_settings_update: option.Option(
      List(GlobalTableGlobalSecondaryIndexSettingsUpdate),
    ),
    global_table_name: option.Option(String),
    global_table_provisioned_write_capacity_auto_scaling_settings_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
    global_table_provisioned_write_capacity_units: option.Option(Int),
    replica_settings_update: option.Option(List(ReplicaSettingsUpdate)),
  )
}

pub fn encode_update_global_table_settings_input_struct(
  input: UpdateGlobalTableSettingsInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_billing_mode {
    option.Some(v) -> [
      #("GlobalTableBillingMode", encode_billing_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_global_secondary_index_settings_update {
    option.Some(v) -> [
      #(
        "GlobalTableGlobalSecondaryIndexSettingsUpdate",
        fn(xs) {
          json.array(
            xs,
            encode_global_table_global_secondary_index_settings_update_struct,
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case
    input.global_table_provisioned_write_capacity_auto_scaling_settings_update
  {
    option.Some(v) -> [
      #(
        "GlobalTableProvisionedWriteCapacityAutoScalingSettingsUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_provisioned_write_capacity_units {
    option.Some(v) -> [
      #("GlobalTableProvisionedWriteCapacityUnits", json.int(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_settings_update {
    option.Some(v) -> [
      #(
        "ReplicaSettingsUpdate",
        fn(xs) { json.array(xs, encode_replica_settings_update_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_global_table_settings_input_struct() -> decode.Decoder(
  UpdateGlobalTableSettingsInput,
) {
  use global_table_billing_mode <- decode.optional_field(
    "GlobalTableBillingMode",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use global_table_global_secondary_index_settings_update <- decode.optional_field(
    "GlobalTableGlobalSecondaryIndexSettingsUpdate",
    option.None,
    decode.optional(
      decode.list(
        decode_global_table_global_secondary_index_settings_update_struct(),
      ),
    ),
  )
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use global_table_provisioned_write_capacity_auto_scaling_settings_update <- decode.optional_field(
    "GlobalTableProvisionedWriteCapacityAutoScalingSettingsUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  use global_table_provisioned_write_capacity_units <- decode.optional_field(
    "GlobalTableProvisionedWriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use replica_settings_update <- decode.optional_field(
    "ReplicaSettingsUpdate",
    option.None,
    decode.optional(decode.list(decode_replica_settings_update_struct())),
  )
  decode.success(UpdateGlobalTableSettingsInput(
    global_table_billing_mode: global_table_billing_mode,
    global_table_global_secondary_index_settings_update: global_table_global_secondary_index_settings_update,
    global_table_name: global_table_name,
    global_table_provisioned_write_capacity_auto_scaling_settings_update: global_table_provisioned_write_capacity_auto_scaling_settings_update,
    global_table_provisioned_write_capacity_units: global_table_provisioned_write_capacity_units,
    replica_settings_update: replica_settings_update,
  ))
}

pub type GlobalTableGlobalSecondaryIndexSettingsUpdate {
  GlobalTableGlobalSecondaryIndexSettingsUpdate(
    index_name: option.Option(String),
    provisioned_write_capacity_auto_scaling_settings_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
    provisioned_write_capacity_units: option.Option(Int),
  )
}

pub fn encode_global_table_global_secondary_index_settings_update_struct(
  input: GlobalTableGlobalSecondaryIndexSettingsUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case
    input.provisioned_write_capacity_auto_scaling_settings_update
  {
    option.Some(v) -> [
      #(
        "ProvisionedWriteCapacityAutoScalingSettingsUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_write_capacity_units {
    option.Some(v) -> [#("ProvisionedWriteCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_table_global_secondary_index_settings_update_struct() -> decode.Decoder(
  GlobalTableGlobalSecondaryIndexSettingsUpdate,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use provisioned_write_capacity_auto_scaling_settings_update <- decode.optional_field(
    "ProvisionedWriteCapacityAutoScalingSettingsUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  use provisioned_write_capacity_units <- decode.optional_field(
    "ProvisionedWriteCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(GlobalTableGlobalSecondaryIndexSettingsUpdate(
    index_name: index_name,
    provisioned_write_capacity_auto_scaling_settings_update: provisioned_write_capacity_auto_scaling_settings_update,
    provisioned_write_capacity_units: provisioned_write_capacity_units,
  ))
}

pub type AutoScalingSettingsUpdate {
  AutoScalingSettingsUpdate(
    auto_scaling_disabled: option.Option(Bool),
    auto_scaling_role_arn: option.Option(String),
    maximum_units: option.Option(Int),
    minimum_units: option.Option(Int),
    scaling_policy_update: option.Option(AutoScalingPolicyUpdate),
  )
}

pub fn encode_auto_scaling_settings_update_struct(
  input: AutoScalingSettingsUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.auto_scaling_disabled {
    option.Some(v) -> [#("AutoScalingDisabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.auto_scaling_role_arn {
    option.Some(v) -> [#("AutoScalingRoleArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.maximum_units {
    option.Some(v) -> [#("MaximumUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.minimum_units {
    option.Some(v) -> [#("MinimumUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.scaling_policy_update {
    option.Some(v) -> [
      #("ScalingPolicyUpdate", encode_auto_scaling_policy_update_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_auto_scaling_settings_update_struct() -> decode.Decoder(
  AutoScalingSettingsUpdate,
) {
  use auto_scaling_disabled <- decode.optional_field(
    "AutoScalingDisabled",
    option.None,
    decode.optional(decode.bool),
  )
  use auto_scaling_role_arn <- decode.optional_field(
    "AutoScalingRoleArn",
    option.None,
    decode.optional(decode.string),
  )
  use maximum_units <- decode.optional_field(
    "MaximumUnits",
    option.None,
    decode.optional(decode.int),
  )
  use minimum_units <- decode.optional_field(
    "MinimumUnits",
    option.None,
    decode.optional(decode.int),
  )
  use scaling_policy_update <- decode.optional_field(
    "ScalingPolicyUpdate",
    option.None,
    decode.optional(decode_auto_scaling_policy_update_struct()),
  )
  decode.success(AutoScalingSettingsUpdate(
    auto_scaling_disabled: auto_scaling_disabled,
    auto_scaling_role_arn: auto_scaling_role_arn,
    maximum_units: maximum_units,
    minimum_units: minimum_units,
    scaling_policy_update: scaling_policy_update,
  ))
}

pub type AutoScalingPolicyUpdate {
  AutoScalingPolicyUpdate(
    policy_name: option.Option(String),
    target_tracking_scaling_policy_configuration: option.Option(
      AutoScalingTargetTrackingScalingPolicyConfigurationUpdate,
    ),
  )
}

pub fn encode_auto_scaling_policy_update_struct(
  input: AutoScalingPolicyUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.policy_name {
    option.Some(v) -> [#("PolicyName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_tracking_scaling_policy_configuration {
    option.Some(v) -> [
      #(
        "TargetTrackingScalingPolicyConfiguration",
        encode_auto_scaling_target_tracking_scaling_policy_configuration_update_struct(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_auto_scaling_policy_update_struct() -> decode.Decoder(
  AutoScalingPolicyUpdate,
) {
  use policy_name <- decode.optional_field(
    "PolicyName",
    option.None,
    decode.optional(decode.string),
  )
  use target_tracking_scaling_policy_configuration <- decode.optional_field(
    "TargetTrackingScalingPolicyConfiguration",
    option.None,
    decode.optional(
      decode_auto_scaling_target_tracking_scaling_policy_configuration_update_struct(),
    ),
  )
  decode.success(AutoScalingPolicyUpdate(
    policy_name: policy_name,
    target_tracking_scaling_policy_configuration: target_tracking_scaling_policy_configuration,
  ))
}

pub type AutoScalingTargetTrackingScalingPolicyConfigurationUpdate {
  AutoScalingTargetTrackingScalingPolicyConfigurationUpdate(
    disable_scale_in: option.Option(Bool),
    scale_in_cooldown: option.Option(Int),
    scale_out_cooldown: option.Option(Int),
    target_value: option.Option(json_float.SmithyFloat),
  )
}

pub fn encode_auto_scaling_target_tracking_scaling_policy_configuration_update_struct(
  input: AutoScalingTargetTrackingScalingPolicyConfigurationUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.disable_scale_in {
    option.Some(v) -> [#("DisableScaleIn", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.scale_in_cooldown {
    option.Some(v) -> [#("ScaleInCooldown", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.scale_out_cooldown {
    option.Some(v) -> [#("ScaleOutCooldown", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_value {
    option.Some(v) -> [#("TargetValue", json_float.encode(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_auto_scaling_target_tracking_scaling_policy_configuration_update_struct() -> decode.Decoder(
  AutoScalingTargetTrackingScalingPolicyConfigurationUpdate,
) {
  use disable_scale_in <- decode.optional_field(
    "DisableScaleIn",
    option.None,
    decode.optional(decode.bool),
  )
  use scale_in_cooldown <- decode.optional_field(
    "ScaleInCooldown",
    option.None,
    decode.optional(decode.int),
  )
  use scale_out_cooldown <- decode.optional_field(
    "ScaleOutCooldown",
    option.None,
    decode.optional(decode.int),
  )
  use target_value <- decode.optional_field(
    "TargetValue",
    option.None,
    decode.optional(json_float.decoder()),
  )
  decode.success(AutoScalingTargetTrackingScalingPolicyConfigurationUpdate(
    disable_scale_in: disable_scale_in,
    scale_in_cooldown: scale_in_cooldown,
    scale_out_cooldown: scale_out_cooldown,
    target_value: target_value,
  ))
}

pub type ReplicaSettingsUpdate {
  ReplicaSettingsUpdate(
    region_name: option.Option(String),
    replica_global_secondary_index_settings_update: option.Option(
      List(ReplicaGlobalSecondaryIndexSettingsUpdate),
    ),
    replica_provisioned_read_capacity_auto_scaling_settings_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
    replica_provisioned_read_capacity_units: option.Option(Int),
    replica_table_class: option.Option(TableClass),
  )
}

pub fn encode_replica_settings_update_struct(
  input: ReplicaSettingsUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_global_secondary_index_settings_update {
    option.Some(v) -> [
      #(
        "ReplicaGlobalSecondaryIndexSettingsUpdate",
        fn(xs) {
          json.array(
            xs,
            encode_replica_global_secondary_index_settings_update_struct,
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case
    input.replica_provisioned_read_capacity_auto_scaling_settings_update
  {
    option.Some(v) -> [
      #(
        "ReplicaProvisionedReadCapacityAutoScalingSettingsUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_provisioned_read_capacity_units {
    option.Some(v) -> [
      #("ReplicaProvisionedReadCapacityUnits", json.int(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_table_class {
    option.Some(v) -> [
      #("ReplicaTableClass", encode_table_class_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_settings_update_struct() -> decode.Decoder(
  ReplicaSettingsUpdate,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_global_secondary_index_settings_update <- decode.optional_field(
    "ReplicaGlobalSecondaryIndexSettingsUpdate",
    option.None,
    decode.optional(
      decode.list(
        decode_replica_global_secondary_index_settings_update_struct(),
      ),
    ),
  )
  use replica_provisioned_read_capacity_auto_scaling_settings_update <- decode.optional_field(
    "ReplicaProvisionedReadCapacityAutoScalingSettingsUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  use replica_provisioned_read_capacity_units <- decode.optional_field(
    "ReplicaProvisionedReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  use replica_table_class <- decode.optional_field(
    "ReplicaTableClass",
    option.None,
    decode.optional(decode_table_class_enum()),
  )
  decode.success(ReplicaSettingsUpdate(
    region_name: region_name,
    replica_global_secondary_index_settings_update: replica_global_secondary_index_settings_update,
    replica_provisioned_read_capacity_auto_scaling_settings_update: replica_provisioned_read_capacity_auto_scaling_settings_update,
    replica_provisioned_read_capacity_units: replica_provisioned_read_capacity_units,
    replica_table_class: replica_table_class,
  ))
}

pub type ReplicaGlobalSecondaryIndexSettingsUpdate {
  ReplicaGlobalSecondaryIndexSettingsUpdate(
    index_name: option.Option(String),
    provisioned_read_capacity_auto_scaling_settings_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
    provisioned_read_capacity_units: option.Option(Int),
  )
}

pub fn encode_replica_global_secondary_index_settings_update_struct(
  input: ReplicaGlobalSecondaryIndexSettingsUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case
    input.provisioned_read_capacity_auto_scaling_settings_update
  {
    option.Some(v) -> [
      #(
        "ProvisionedReadCapacityAutoScalingSettingsUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_read_capacity_units {
    option.Some(v) -> [#("ProvisionedReadCapacityUnits", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_global_secondary_index_settings_update_struct() -> decode.Decoder(
  ReplicaGlobalSecondaryIndexSettingsUpdate,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use provisioned_read_capacity_auto_scaling_settings_update <- decode.optional_field(
    "ProvisionedReadCapacityAutoScalingSettingsUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  use provisioned_read_capacity_units <- decode.optional_field(
    "ProvisionedReadCapacityUnits",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ReplicaGlobalSecondaryIndexSettingsUpdate(
    index_name: index_name,
    provisioned_read_capacity_auto_scaling_settings_update: provisioned_read_capacity_auto_scaling_settings_update,
    provisioned_read_capacity_units: provisioned_read_capacity_units,
  ))
}

pub type UpdateGlobalTableSettingsOutput {
  UpdateGlobalTableSettingsOutput(
    global_table_name: option.Option(String),
    replica_settings: option.Option(List(ReplicaSettingsDescription)),
  )
}

pub fn encode_update_global_table_settings_output_struct(
  input: UpdateGlobalTableSettingsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_table_name {
    option.Some(v) -> [#("GlobalTableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_settings {
    option.Some(v) -> [
      #(
        "ReplicaSettings",
        fn(xs) { json.array(xs, encode_replica_settings_description_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_global_table_settings_output_struct() -> decode.Decoder(
  UpdateGlobalTableSettingsOutput,
) {
  use global_table_name <- decode.optional_field(
    "GlobalTableName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_settings <- decode.optional_field(
    "ReplicaSettings",
    option.None,
    decode.optional(decode.list(decode_replica_settings_description_struct())),
  )
  decode.success(UpdateGlobalTableSettingsOutput(
    global_table_name: global_table_name,
    replica_settings: replica_settings,
  ))
}

pub type UpdateItemInput {
  UpdateItemInput(
    attribute_updates: option.Option(dict.Dict(String, AttributeValueUpdate)),
    condition_expression: option.Option(String),
    conditional_operator: option.Option(ConditionalOperator),
    expected: option.Option(dict.Dict(String, ExpectedAttributeValue)),
    expression_attribute_names: option.Option(dict.Dict(String, String)),
    expression_attribute_values: option.Option(
      dict.Dict(String, AttributeValue),
    ),
    key: option.Option(dict.Dict(String, AttributeValue)),
    return_consumed_capacity: option.Option(ReturnConsumedCapacity),
    return_item_collection_metrics: option.Option(ReturnItemCollectionMetrics),
    return_values: option.Option(ReturnValue),
    return_values_on_condition_check_failure: option.Option(
      ReturnValuesOnConditionCheckFailure,
    ),
    table_name: option.Option(String),
    update_expression: option.Option(String),
  )
}

pub fn encode_update_item_input_struct(input: UpdateItemInput) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_updates {
    option.Some(v) -> [
      #(
        "AttributeUpdates",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_update_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.condition_expression {
    option.Some(v) -> [#("ConditionExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.conditional_operator {
    option.Some(v) -> [
      #("ConditionalOperator", encode_conditional_operator_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expected {
    option.Some(v) -> [
      #(
        "Expected",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_expected_attribute_value_struct(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expression_attribute_names {
    option.Some(v) -> [
      #(
        "ExpressionAttributeNames",
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
  let pairs = case input.expression_attribute_values {
    option.Some(v) -> [
      #(
        "ExpressionAttributeValues",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [
      #(
        "Key",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_consumed_capacity {
    option.Some(v) -> [
      #("ReturnConsumedCapacity", encode_return_consumed_capacity_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_item_collection_metrics {
    option.Some(v) -> [
      #(
        "ReturnItemCollectionMetrics",
        encode_return_item_collection_metrics_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.return_values {
    option.Some(v) -> [#("ReturnValues", encode_return_value_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.return_values_on_condition_check_failure {
    option.Some(v) -> [
      #(
        "ReturnValuesOnConditionCheckFailure",
        encode_return_values_on_condition_check_failure_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.update_expression {
    option.Some(v) -> [#("UpdateExpression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_item_input_struct() -> decode.Decoder(UpdateItemInput) {
  use attribute_updates <- decode.optional_field(
    "AttributeUpdates",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode_attribute_value_update_struct(),
    )),
  )
  use condition_expression <- decode.optional_field(
    "ConditionExpression",
    option.None,
    decode.optional(decode.string),
  )
  use conditional_operator <- decode.optional_field(
    "ConditionalOperator",
    option.None,
    decode.optional(decode_conditional_operator_enum()),
  )
  use expected <- decode.optional_field(
    "Expected",
    option.None,
    decode.optional(decode.dict(
      decode.string,
      decode_expected_attribute_value_struct(),
    )),
  )
  use expression_attribute_names <- decode.optional_field(
    "ExpressionAttributeNames",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use expression_attribute_values <- decode.optional_field(
    "ExpressionAttributeValues",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use return_consumed_capacity <- decode.optional_field(
    "ReturnConsumedCapacity",
    option.None,
    decode.optional(decode_return_consumed_capacity_enum()),
  )
  use return_item_collection_metrics <- decode.optional_field(
    "ReturnItemCollectionMetrics",
    option.None,
    decode.optional(decode_return_item_collection_metrics_enum()),
  )
  use return_values <- decode.optional_field(
    "ReturnValues",
    option.None,
    decode.optional(decode_return_value_enum()),
  )
  use return_values_on_condition_check_failure <- decode.optional_field(
    "ReturnValuesOnConditionCheckFailure",
    option.None,
    decode.optional(decode_return_values_on_condition_check_failure_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use update_expression <- decode.optional_field(
    "UpdateExpression",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(UpdateItemInput(
    attribute_updates: attribute_updates,
    condition_expression: condition_expression,
    conditional_operator: conditional_operator,
    expected: expected,
    expression_attribute_names: expression_attribute_names,
    expression_attribute_values: expression_attribute_values,
    key: key,
    return_consumed_capacity: return_consumed_capacity,
    return_item_collection_metrics: return_item_collection_metrics,
    return_values: return_values,
    return_values_on_condition_check_failure: return_values_on_condition_check_failure,
    table_name: table_name,
    update_expression: update_expression,
  ))
}

pub type AttributeValueUpdate {
  AttributeValueUpdate(
    action: option.Option(AttributeAction),
    value: option.Option(AttributeValue),
  )
}

pub fn encode_attribute_value_update_struct(
  input: AttributeValueUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.action {
    option.Some(v) -> [#("Action", encode_attribute_action_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.value {
    option.Some(v) -> [#("Value", encode_attribute_value_union(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_attribute_value_update_struct() -> decode.Decoder(
  AttributeValueUpdate,
) {
  use action <- decode.optional_field(
    "Action",
    option.None,
    decode.optional(decode_attribute_action_enum()),
  )
  use value <- decode.optional_field(
    "Value",
    option.None,
    decode.optional(decode_attribute_value_union()),
  )
  decode.success(AttributeValueUpdate(action: action, value: value))
}

pub type AttributeAction {
  AttributeActionAdd
  AttributeActionDelete
  AttributeActionPut
}

pub fn encode_attribute_action_enum(v: AttributeAction) -> json.Json {
  case v {
    AttributeActionAdd -> json.string("ADD")
    AttributeActionDelete -> json.string("DELETE")
    AttributeActionPut -> json.string("PUT")
  }
}

pub fn decode_attribute_action_enum() -> decode.Decoder(AttributeAction) {
  decode.then(decode.string, fn(s) {
    case s {
      "ADD" -> decode.success(AttributeActionAdd)
      "DELETE" -> decode.success(AttributeActionDelete)
      "PUT" -> decode.success(AttributeActionPut)
      _ -> decode.failure(AttributeActionAdd, "unknown enum value")
    }
  })
}

pub type UpdateItemOutput {
  UpdateItemOutput(
    attributes: option.Option(dict.Dict(String, AttributeValue)),
    consumed_capacity: option.Option(ConsumedCapacity),
    item_collection_metrics: option.Option(ItemCollectionMetrics),
  )
}

pub fn encode_update_item_output_struct(input: UpdateItemOutput) -> json.Json {
  let pairs = []
  let pairs = case input.attributes {
    option.Some(v) -> [
      #(
        "Attributes",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) {
              #(pair.0, encode_attribute_value_union(pair.1))
            }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.consumed_capacity {
    option.Some(v) -> [
      #("ConsumedCapacity", encode_consumed_capacity_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.item_collection_metrics {
    option.Some(v) -> [
      #("ItemCollectionMetrics", encode_item_collection_metrics_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_item_output_struct() -> decode.Decoder(UpdateItemOutput) {
  use attributes <- decode.optional_field(
    "Attributes",
    option.None,
    decode.optional(decode.dict(decode.string, decode_attribute_value_union())),
  )
  use consumed_capacity <- decode.optional_field(
    "ConsumedCapacity",
    option.None,
    decode.optional(decode_consumed_capacity_struct()),
  )
  use item_collection_metrics <- decode.optional_field(
    "ItemCollectionMetrics",
    option.None,
    decode.optional(decode_item_collection_metrics_struct()),
  )
  decode.success(UpdateItemOutput(
    attributes: attributes,
    consumed_capacity: consumed_capacity,
    item_collection_metrics: item_collection_metrics,
  ))
}

pub type UpdateKinesisStreamingDestinationInput {
  UpdateKinesisStreamingDestinationInput(
    stream_arn: option.Option(String),
    table_name: option.Option(String),
    update_kinesis_streaming_configuration: option.Option(
      UpdateKinesisStreamingConfiguration,
    ),
  )
}

pub fn encode_update_kinesis_streaming_destination_input_struct(
  input: UpdateKinesisStreamingDestinationInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.stream_arn {
    option.Some(v) -> [#("StreamArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.update_kinesis_streaming_configuration {
    option.Some(v) -> [
      #(
        "UpdateKinesisStreamingConfiguration",
        encode_update_kinesis_streaming_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_kinesis_streaming_destination_input_struct() -> decode.Decoder(
  UpdateKinesisStreamingDestinationInput,
) {
  use stream_arn <- decode.optional_field(
    "StreamArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use update_kinesis_streaming_configuration <- decode.optional_field(
    "UpdateKinesisStreamingConfiguration",
    option.None,
    decode.optional(decode_update_kinesis_streaming_configuration_struct()),
  )
  decode.success(UpdateKinesisStreamingDestinationInput(
    stream_arn: stream_arn,
    table_name: table_name,
    update_kinesis_streaming_configuration: update_kinesis_streaming_configuration,
  ))
}

pub type UpdateKinesisStreamingConfiguration {
  UpdateKinesisStreamingConfiguration(
    approximate_creation_date_time_precision: option.Option(
      ApproximateCreationDateTimePrecision,
    ),
  )
}

pub fn encode_update_kinesis_streaming_configuration_struct(
  input: UpdateKinesisStreamingConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.approximate_creation_date_time_precision {
    option.Some(v) -> [
      #(
        "ApproximateCreationDateTimePrecision",
        encode_approximate_creation_date_time_precision_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_kinesis_streaming_configuration_struct() -> decode.Decoder(
  UpdateKinesisStreamingConfiguration,
) {
  use approximate_creation_date_time_precision <- decode.optional_field(
    "ApproximateCreationDateTimePrecision",
    option.None,
    decode.optional(decode_approximate_creation_date_time_precision_enum()),
  )
  decode.success(UpdateKinesisStreamingConfiguration(
    approximate_creation_date_time_precision: approximate_creation_date_time_precision,
  ))
}

pub type UpdateKinesisStreamingDestinationOutput {
  UpdateKinesisStreamingDestinationOutput(
    destination_status: option.Option(DestinationStatus),
    stream_arn: option.Option(String),
    table_name: option.Option(String),
    update_kinesis_streaming_configuration: option.Option(
      UpdateKinesisStreamingConfiguration,
    ),
  )
}

pub fn encode_update_kinesis_streaming_destination_output_struct(
  input: UpdateKinesisStreamingDestinationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.destination_status {
    option.Some(v) -> [
      #("DestinationStatus", encode_destination_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_arn {
    option.Some(v) -> [#("StreamArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.update_kinesis_streaming_configuration {
    option.Some(v) -> [
      #(
        "UpdateKinesisStreamingConfiguration",
        encode_update_kinesis_streaming_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_kinesis_streaming_destination_output_struct() -> decode.Decoder(
  UpdateKinesisStreamingDestinationOutput,
) {
  use destination_status <- decode.optional_field(
    "DestinationStatus",
    option.None,
    decode.optional(decode_destination_status_enum()),
  )
  use stream_arn <- decode.optional_field(
    "StreamArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use update_kinesis_streaming_configuration <- decode.optional_field(
    "UpdateKinesisStreamingConfiguration",
    option.None,
    decode.optional(decode_update_kinesis_streaming_configuration_struct()),
  )
  decode.success(UpdateKinesisStreamingDestinationOutput(
    destination_status: destination_status,
    stream_arn: stream_arn,
    table_name: table_name,
    update_kinesis_streaming_configuration: update_kinesis_streaming_configuration,
  ))
}

pub type UpdateTableInput {
  UpdateTableInput(
    attribute_definitions: option.Option(List(AttributeDefinition)),
    billing_mode: option.Option(BillingMode),
    deletion_protection_enabled: option.Option(Bool),
    global_secondary_index_updates: option.Option(
      List(GlobalSecondaryIndexUpdate),
    ),
    global_table_settings_replication_mode: option.Option(
      GlobalTableSettingsReplicationMode,
    ),
    global_table_witness_updates: option.Option(
      List(GlobalTableWitnessGroupUpdate),
    ),
    multi_region_consistency: option.Option(MultiRegionConsistency),
    on_demand_throughput: option.Option(OnDemandThroughput),
    provisioned_throughput: option.Option(ProvisionedThroughput),
    replica_updates: option.Option(List(ReplicationGroupUpdate)),
    sse_specification: option.Option(SSESpecification),
    stream_specification: option.Option(StreamSpecification),
    table_class: option.Option(TableClass),
    table_name: option.Option(String),
    warm_throughput: option.Option(WarmThroughput),
  )
}

pub fn encode_update_table_input_struct(input: UpdateTableInput) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_definitions {
    option.Some(v) -> [
      #(
        "AttributeDefinitions",
        fn(xs) { json.array(xs, encode_attribute_definition_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.billing_mode {
    option.Some(v) -> [#("BillingMode", encode_billing_mode_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.deletion_protection_enabled {
    option.Some(v) -> [#("DeletionProtectionEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.global_secondary_index_updates {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexUpdates",
        fn(xs) { json.array(xs, encode_global_secondary_index_update_struct) }(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_settings_replication_mode {
    option.Some(v) -> [
      #(
        "GlobalTableSettingsReplicationMode",
        encode_global_table_settings_replication_mode_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.global_table_witness_updates {
    option.Some(v) -> [
      #(
        "GlobalTableWitnessUpdates",
        fn(xs) {
          json.array(xs, encode_global_table_witness_group_update_struct)
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.multi_region_consistency {
    option.Some(v) -> [
      #("MultiRegionConsistency", encode_multi_region_consistency_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_updates {
    option.Some(v) -> [
      #(
        "ReplicaUpdates",
        fn(xs) { json.array(xs, encode_replication_group_update_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_specification {
    option.Some(v) -> [
      #("SSESpecification", encode_sse_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.stream_specification {
    option.Some(v) -> [
      #("StreamSpecification", encode_stream_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_class {
    option.Some(v) -> [#("TableClass", encode_table_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #("WarmThroughput", encode_warm_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_table_input_struct() -> decode.Decoder(UpdateTableInput) {
  use attribute_definitions <- decode.optional_field(
    "AttributeDefinitions",
    option.None,
    decode.optional(decode.list(decode_attribute_definition_struct())),
  )
  use billing_mode <- decode.optional_field(
    "BillingMode",
    option.None,
    decode.optional(decode_billing_mode_enum()),
  )
  use deletion_protection_enabled <- decode.optional_field(
    "DeletionProtectionEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use global_secondary_index_updates <- decode.optional_field(
    "GlobalSecondaryIndexUpdates",
    option.None,
    decode.optional(decode.list(decode_global_secondary_index_update_struct())),
  )
  use global_table_settings_replication_mode <- decode.optional_field(
    "GlobalTableSettingsReplicationMode",
    option.None,
    decode.optional(decode_global_table_settings_replication_mode_enum()),
  )
  use global_table_witness_updates <- decode.optional_field(
    "GlobalTableWitnessUpdates",
    option.None,
    decode.optional(
      decode.list(decode_global_table_witness_group_update_struct()),
    ),
  )
  use multi_region_consistency <- decode.optional_field(
    "MultiRegionConsistency",
    option.None,
    decode.optional(decode_multi_region_consistency_enum()),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use replica_updates <- decode.optional_field(
    "ReplicaUpdates",
    option.None,
    decode.optional(decode.list(decode_replication_group_update_struct())),
  )
  use sse_specification <- decode.optional_field(
    "SSESpecification",
    option.None,
    decode.optional(decode_sse_specification_struct()),
  )
  use stream_specification <- decode.optional_field(
    "StreamSpecification",
    option.None,
    decode.optional(decode_stream_specification_struct()),
  )
  use table_class <- decode.optional_field(
    "TableClass",
    option.None,
    decode.optional(decode_table_class_enum()),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(decode_warm_throughput_struct()),
  )
  decode.success(UpdateTableInput(
    attribute_definitions: attribute_definitions,
    billing_mode: billing_mode,
    deletion_protection_enabled: deletion_protection_enabled,
    global_secondary_index_updates: global_secondary_index_updates,
    global_table_settings_replication_mode: global_table_settings_replication_mode,
    global_table_witness_updates: global_table_witness_updates,
    multi_region_consistency: multi_region_consistency,
    on_demand_throughput: on_demand_throughput,
    provisioned_throughput: provisioned_throughput,
    replica_updates: replica_updates,
    sse_specification: sse_specification,
    stream_specification: stream_specification,
    table_class: table_class,
    table_name: table_name,
    warm_throughput: warm_throughput,
  ))
}

pub type GlobalSecondaryIndexUpdate {
  GlobalSecondaryIndexUpdate(
    create: option.Option(CreateGlobalSecondaryIndexAction),
    delete: option.Option(DeleteGlobalSecondaryIndexAction),
    update: option.Option(UpdateGlobalSecondaryIndexAction),
  )
}

pub fn encode_global_secondary_index_update_struct(
  input: GlobalSecondaryIndexUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.create {
    option.Some(v) -> [
      #("Create", encode_create_global_secondary_index_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delete {
    option.Some(v) -> [
      #("Delete", encode_delete_global_secondary_index_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.update {
    option.Some(v) -> [
      #("Update", encode_update_global_secondary_index_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_secondary_index_update_struct() -> decode.Decoder(
  GlobalSecondaryIndexUpdate,
) {
  use create <- decode.optional_field(
    "Create",
    option.None,
    decode.optional(decode_create_global_secondary_index_action_struct()),
  )
  use delete <- decode.optional_field(
    "Delete",
    option.None,
    decode.optional(decode_delete_global_secondary_index_action_struct()),
  )
  use update <- decode.optional_field(
    "Update",
    option.None,
    decode.optional(decode_update_global_secondary_index_action_struct()),
  )
  decode.success(GlobalSecondaryIndexUpdate(
    create: create,
    delete: delete,
    update: update,
  ))
}

pub type CreateGlobalSecondaryIndexAction {
  CreateGlobalSecondaryIndexAction(
    index_name: option.Option(String),
    key_schema: option.Option(List(KeySchemaElement)),
    on_demand_throughput: option.Option(OnDemandThroughput),
    projection: option.Option(Projection),
    provisioned_throughput: option.Option(ProvisionedThroughput),
    warm_throughput: option.Option(WarmThroughput),
  )
}

pub fn encode_create_global_secondary_index_action_struct(
  input: CreateGlobalSecondaryIndexAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_schema {
    option.Some(v) -> [
      #(
        "KeySchema",
        fn(xs) { json.array(xs, encode_key_schema_element_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.projection {
    option.Some(v) -> [#("Projection", encode_projection_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #("WarmThroughput", encode_warm_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_global_secondary_index_action_struct() -> decode.Decoder(
  CreateGlobalSecondaryIndexAction,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use key_schema <- decode.optional_field(
    "KeySchema",
    option.None,
    decode.optional(decode.list(decode_key_schema_element_struct())),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use projection <- decode.optional_field(
    "Projection",
    option.None,
    decode.optional(decode_projection_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(decode_warm_throughput_struct()),
  )
  decode.success(CreateGlobalSecondaryIndexAction(
    index_name: index_name,
    key_schema: key_schema,
    on_demand_throughput: on_demand_throughput,
    projection: projection,
    provisioned_throughput: provisioned_throughput,
    warm_throughput: warm_throughput,
  ))
}

pub type DeleteGlobalSecondaryIndexAction {
  DeleteGlobalSecondaryIndexAction(index_name: option.Option(String))
}

pub fn encode_delete_global_secondary_index_action_struct(
  input: DeleteGlobalSecondaryIndexAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_global_secondary_index_action_struct() -> decode.Decoder(
  DeleteGlobalSecondaryIndexAction,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteGlobalSecondaryIndexAction(index_name: index_name))
}

pub type UpdateGlobalSecondaryIndexAction {
  UpdateGlobalSecondaryIndexAction(
    index_name: option.Option(String),
    on_demand_throughput: option.Option(OnDemandThroughput),
    provisioned_throughput: option.Option(ProvisionedThroughput),
    warm_throughput: option.Option(WarmThroughput),
  )
}

pub fn encode_update_global_secondary_index_action_struct(
  input: UpdateGlobalSecondaryIndexAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput {
    option.Some(v) -> [
      #("OnDemandThroughput", encode_on_demand_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput {
    option.Some(v) -> [
      #("ProvisionedThroughput", encode_provisioned_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.warm_throughput {
    option.Some(v) -> [
      #("WarmThroughput", encode_warm_throughput_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_global_secondary_index_action_struct() -> decode.Decoder(
  UpdateGlobalSecondaryIndexAction,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use on_demand_throughput <- decode.optional_field(
    "OnDemandThroughput",
    option.None,
    decode.optional(decode_on_demand_throughput_struct()),
  )
  use provisioned_throughput <- decode.optional_field(
    "ProvisionedThroughput",
    option.None,
    decode.optional(decode_provisioned_throughput_struct()),
  )
  use warm_throughput <- decode.optional_field(
    "WarmThroughput",
    option.None,
    decode.optional(decode_warm_throughput_struct()),
  )
  decode.success(UpdateGlobalSecondaryIndexAction(
    index_name: index_name,
    on_demand_throughput: on_demand_throughput,
    provisioned_throughput: provisioned_throughput,
    warm_throughput: warm_throughput,
  ))
}

pub type GlobalTableWitnessGroupUpdate {
  GlobalTableWitnessGroupUpdate(
    create: option.Option(CreateGlobalTableWitnessGroupMemberAction),
    delete: option.Option(DeleteGlobalTableWitnessGroupMemberAction),
  )
}

pub fn encode_global_table_witness_group_update_struct(
  input: GlobalTableWitnessGroupUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.create {
    option.Some(v) -> [
      #(
        "Create",
        encode_create_global_table_witness_group_member_action_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delete {
    option.Some(v) -> [
      #(
        "Delete",
        encode_delete_global_table_witness_group_member_action_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_table_witness_group_update_struct() -> decode.Decoder(
  GlobalTableWitnessGroupUpdate,
) {
  use create <- decode.optional_field(
    "Create",
    option.None,
    decode.optional(
      decode_create_global_table_witness_group_member_action_struct(),
    ),
  )
  use delete <- decode.optional_field(
    "Delete",
    option.None,
    decode.optional(
      decode_delete_global_table_witness_group_member_action_struct(),
    ),
  )
  decode.success(GlobalTableWitnessGroupUpdate(create: create, delete: delete))
}

pub type CreateGlobalTableWitnessGroupMemberAction {
  CreateGlobalTableWitnessGroupMemberAction(region_name: option.Option(String))
}

pub fn encode_create_global_table_witness_group_member_action_struct(
  input: CreateGlobalTableWitnessGroupMemberAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_global_table_witness_group_member_action_struct() -> decode.Decoder(
  CreateGlobalTableWitnessGroupMemberAction,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CreateGlobalTableWitnessGroupMemberAction(
    region_name: region_name,
  ))
}

pub type DeleteGlobalTableWitnessGroupMemberAction {
  DeleteGlobalTableWitnessGroupMemberAction(region_name: option.Option(String))
}

pub fn encode_delete_global_table_witness_group_member_action_struct(
  input: DeleteGlobalTableWitnessGroupMemberAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_global_table_witness_group_member_action_struct() -> decode.Decoder(
  DeleteGlobalTableWitnessGroupMemberAction,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteGlobalTableWitnessGroupMemberAction(
    region_name: region_name,
  ))
}

pub type ReplicationGroupUpdate {
  ReplicationGroupUpdate(
    create: option.Option(CreateReplicationGroupMemberAction),
    delete: option.Option(DeleteReplicationGroupMemberAction),
    update: option.Option(UpdateReplicationGroupMemberAction),
  )
}

pub fn encode_replication_group_update_struct(
  input: ReplicationGroupUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.create {
    option.Some(v) -> [
      #("Create", encode_create_replication_group_member_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delete {
    option.Some(v) -> [
      #("Delete", encode_delete_replication_group_member_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.update {
    option.Some(v) -> [
      #("Update", encode_update_replication_group_member_action_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replication_group_update_struct() -> decode.Decoder(
  ReplicationGroupUpdate,
) {
  use create <- decode.optional_field(
    "Create",
    option.None,
    decode.optional(decode_create_replication_group_member_action_struct()),
  )
  use delete <- decode.optional_field(
    "Delete",
    option.None,
    decode.optional(decode_delete_replication_group_member_action_struct()),
  )
  use update <- decode.optional_field(
    "Update",
    option.None,
    decode.optional(decode_update_replication_group_member_action_struct()),
  )
  decode.success(ReplicationGroupUpdate(
    create: create,
    delete: delete,
    update: update,
  ))
}

pub type CreateReplicationGroupMemberAction {
  CreateReplicationGroupMemberAction(
    global_secondary_indexes: option.Option(List(ReplicaGlobalSecondaryIndex)),
    kms_master_key_id: option.Option(String),
    on_demand_throughput_override: option.Option(OnDemandThroughputOverride),
    provisioned_throughput_override: option.Option(
      ProvisionedThroughputOverride,
    ),
    region_name: option.Option(String),
    table_class_override: option.Option(TableClass),
  )
}

pub fn encode_create_replication_group_member_action_struct(
  input: CreateReplicationGroupMemberAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) { json.array(xs, encode_replica_global_secondary_index_struct) }(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.kms_master_key_id {
    option.Some(v) -> [#("KMSMasterKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput_override {
    option.Some(v) -> [
      #(
        "OnDemandThroughputOverride",
        encode_on_demand_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput_override {
    option.Some(v) -> [
      #(
        "ProvisionedThroughputOverride",
        encode_provisioned_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_class_override {
    option.Some(v) -> [
      #("TableClassOverride", encode_table_class_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_replication_group_member_action_struct() -> decode.Decoder(
  CreateReplicationGroupMemberAction,
) {
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(decode.list(decode_replica_global_secondary_index_struct())),
  )
  use kms_master_key_id <- decode.optional_field(
    "KMSMasterKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use on_demand_throughput_override <- decode.optional_field(
    "OnDemandThroughputOverride",
    option.None,
    decode.optional(decode_on_demand_throughput_override_struct()),
  )
  use provisioned_throughput_override <- decode.optional_field(
    "ProvisionedThroughputOverride",
    option.None,
    decode.optional(decode_provisioned_throughput_override_struct()),
  )
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use table_class_override <- decode.optional_field(
    "TableClassOverride",
    option.None,
    decode.optional(decode_table_class_enum()),
  )
  decode.success(CreateReplicationGroupMemberAction(
    global_secondary_indexes: global_secondary_indexes,
    kms_master_key_id: kms_master_key_id,
    on_demand_throughput_override: on_demand_throughput_override,
    provisioned_throughput_override: provisioned_throughput_override,
    region_name: region_name,
    table_class_override: table_class_override,
  ))
}

pub type ReplicaGlobalSecondaryIndex {
  ReplicaGlobalSecondaryIndex(
    index_name: option.Option(String),
    on_demand_throughput_override: option.Option(OnDemandThroughputOverride),
    provisioned_throughput_override: option.Option(
      ProvisionedThroughputOverride,
    ),
  )
}

pub fn encode_replica_global_secondary_index_struct(
  input: ReplicaGlobalSecondaryIndex,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput_override {
    option.Some(v) -> [
      #(
        "OnDemandThroughputOverride",
        encode_on_demand_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput_override {
    option.Some(v) -> [
      #(
        "ProvisionedThroughputOverride",
        encode_provisioned_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_global_secondary_index_struct() -> decode.Decoder(
  ReplicaGlobalSecondaryIndex,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use on_demand_throughput_override <- decode.optional_field(
    "OnDemandThroughputOverride",
    option.None,
    decode.optional(decode_on_demand_throughput_override_struct()),
  )
  use provisioned_throughput_override <- decode.optional_field(
    "ProvisionedThroughputOverride",
    option.None,
    decode.optional(decode_provisioned_throughput_override_struct()),
  )
  decode.success(ReplicaGlobalSecondaryIndex(
    index_name: index_name,
    on_demand_throughput_override: on_demand_throughput_override,
    provisioned_throughput_override: provisioned_throughput_override,
  ))
}

pub type DeleteReplicationGroupMemberAction {
  DeleteReplicationGroupMemberAction(region_name: option.Option(String))
}

pub fn encode_delete_replication_group_member_action_struct(
  input: DeleteReplicationGroupMemberAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_replication_group_member_action_struct() -> decode.Decoder(
  DeleteReplicationGroupMemberAction,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteReplicationGroupMemberAction(region_name: region_name))
}

pub type UpdateReplicationGroupMemberAction {
  UpdateReplicationGroupMemberAction(
    global_secondary_indexes: option.Option(List(ReplicaGlobalSecondaryIndex)),
    kms_master_key_id: option.Option(String),
    on_demand_throughput_override: option.Option(OnDemandThroughputOverride),
    provisioned_throughput_override: option.Option(
      ProvisionedThroughputOverride,
    ),
    region_name: option.Option(String),
    table_class_override: option.Option(TableClass),
  )
}

pub fn encode_update_replication_group_member_action_struct(
  input: UpdateReplicationGroupMemberAction,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_secondary_indexes {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexes",
        fn(xs) { json.array(xs, encode_replica_global_secondary_index_struct) }(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.kms_master_key_id {
    option.Some(v) -> [#("KMSMasterKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.on_demand_throughput_override {
    option.Some(v) -> [
      #(
        "OnDemandThroughputOverride",
        encode_on_demand_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_throughput_override {
    option.Some(v) -> [
      #(
        "ProvisionedThroughputOverride",
        encode_provisioned_throughput_override_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_class_override {
    option.Some(v) -> [
      #("TableClassOverride", encode_table_class_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_replication_group_member_action_struct() -> decode.Decoder(
  UpdateReplicationGroupMemberAction,
) {
  use global_secondary_indexes <- decode.optional_field(
    "GlobalSecondaryIndexes",
    option.None,
    decode.optional(decode.list(decode_replica_global_secondary_index_struct())),
  )
  use kms_master_key_id <- decode.optional_field(
    "KMSMasterKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use on_demand_throughput_override <- decode.optional_field(
    "OnDemandThroughputOverride",
    option.None,
    decode.optional(decode_on_demand_throughput_override_struct()),
  )
  use provisioned_throughput_override <- decode.optional_field(
    "ProvisionedThroughputOverride",
    option.None,
    decode.optional(decode_provisioned_throughput_override_struct()),
  )
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use table_class_override <- decode.optional_field(
    "TableClassOverride",
    option.None,
    decode.optional(decode_table_class_enum()),
  )
  decode.success(UpdateReplicationGroupMemberAction(
    global_secondary_indexes: global_secondary_indexes,
    kms_master_key_id: kms_master_key_id,
    on_demand_throughput_override: on_demand_throughput_override,
    provisioned_throughput_override: provisioned_throughput_override,
    region_name: region_name,
    table_class_override: table_class_override,
  ))
}

pub type UpdateTableOutput {
  UpdateTableOutput(table_description: option.Option(TableDescription))
}

pub fn encode_update_table_output_struct(
  input: UpdateTableOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_description {
    option.Some(v) -> [
      #("TableDescription", encode_table_description_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_table_output_struct() -> decode.Decoder(UpdateTableOutput) {
  use table_description <- decode.optional_field(
    "TableDescription",
    option.None,
    decode.optional(decode_table_description_struct()),
  )
  decode.success(UpdateTableOutput(table_description: table_description))
}

pub type UpdateTableReplicaAutoScalingInput {
  UpdateTableReplicaAutoScalingInput(
    global_secondary_index_updates: option.Option(
      List(GlobalSecondaryIndexAutoScalingUpdate),
    ),
    provisioned_write_capacity_auto_scaling_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
    replica_updates: option.Option(List(ReplicaAutoScalingUpdate)),
    table_name: option.Option(String),
  )
}

pub fn encode_update_table_replica_auto_scaling_input_struct(
  input: UpdateTableReplicaAutoScalingInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.global_secondary_index_updates {
    option.Some(v) -> [
      #(
        "GlobalSecondaryIndexUpdates",
        fn(xs) {
          json.array(
            xs,
            encode_global_secondary_index_auto_scaling_update_struct,
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.provisioned_write_capacity_auto_scaling_update {
    option.Some(v) -> [
      #(
        "ProvisionedWriteCapacityAutoScalingUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_updates {
    option.Some(v) -> [
      #(
        "ReplicaUpdates",
        fn(xs) { json.array(xs, encode_replica_auto_scaling_update_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_table_replica_auto_scaling_input_struct() -> decode.Decoder(
  UpdateTableReplicaAutoScalingInput,
) {
  use global_secondary_index_updates <- decode.optional_field(
    "GlobalSecondaryIndexUpdates",
    option.None,
    decode.optional(
      decode.list(decode_global_secondary_index_auto_scaling_update_struct()),
    ),
  )
  use provisioned_write_capacity_auto_scaling_update <- decode.optional_field(
    "ProvisionedWriteCapacityAutoScalingUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  use replica_updates <- decode.optional_field(
    "ReplicaUpdates",
    option.None,
    decode.optional(decode.list(decode_replica_auto_scaling_update_struct())),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(UpdateTableReplicaAutoScalingInput(
    global_secondary_index_updates: global_secondary_index_updates,
    provisioned_write_capacity_auto_scaling_update: provisioned_write_capacity_auto_scaling_update,
    replica_updates: replica_updates,
    table_name: table_name,
  ))
}

pub type GlobalSecondaryIndexAutoScalingUpdate {
  GlobalSecondaryIndexAutoScalingUpdate(
    index_name: option.Option(String),
    provisioned_write_capacity_auto_scaling_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
  )
}

pub fn encode_global_secondary_index_auto_scaling_update_struct(
  input: GlobalSecondaryIndexAutoScalingUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_write_capacity_auto_scaling_update {
    option.Some(v) -> [
      #(
        "ProvisionedWriteCapacityAutoScalingUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_global_secondary_index_auto_scaling_update_struct() -> decode.Decoder(
  GlobalSecondaryIndexAutoScalingUpdate,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use provisioned_write_capacity_auto_scaling_update <- decode.optional_field(
    "ProvisionedWriteCapacityAutoScalingUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  decode.success(GlobalSecondaryIndexAutoScalingUpdate(
    index_name: index_name,
    provisioned_write_capacity_auto_scaling_update: provisioned_write_capacity_auto_scaling_update,
  ))
}

pub type ReplicaAutoScalingUpdate {
  ReplicaAutoScalingUpdate(
    region_name: option.Option(String),
    replica_global_secondary_index_updates: option.Option(
      List(ReplicaGlobalSecondaryIndexAutoScalingUpdate),
    ),
    replica_provisioned_read_capacity_auto_scaling_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
  )
}

pub fn encode_replica_auto_scaling_update_struct(
  input: ReplicaAutoScalingUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.region_name {
    option.Some(v) -> [#("RegionName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replica_global_secondary_index_updates {
    option.Some(v) -> [
      #(
        "ReplicaGlobalSecondaryIndexUpdates",
        fn(xs) {
          json.array(
            xs,
            encode_replica_global_secondary_index_auto_scaling_update_struct,
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.replica_provisioned_read_capacity_auto_scaling_update {
    option.Some(v) -> [
      #(
        "ReplicaProvisionedReadCapacityAutoScalingUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_auto_scaling_update_struct() -> decode.Decoder(
  ReplicaAutoScalingUpdate,
) {
  use region_name <- decode.optional_field(
    "RegionName",
    option.None,
    decode.optional(decode.string),
  )
  use replica_global_secondary_index_updates <- decode.optional_field(
    "ReplicaGlobalSecondaryIndexUpdates",
    option.None,
    decode.optional(
      decode.list(
        decode_replica_global_secondary_index_auto_scaling_update_struct(),
      ),
    ),
  )
  use replica_provisioned_read_capacity_auto_scaling_update <- decode.optional_field(
    "ReplicaProvisionedReadCapacityAutoScalingUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  decode.success(ReplicaAutoScalingUpdate(
    region_name: region_name,
    replica_global_secondary_index_updates: replica_global_secondary_index_updates,
    replica_provisioned_read_capacity_auto_scaling_update: replica_provisioned_read_capacity_auto_scaling_update,
  ))
}

pub type ReplicaGlobalSecondaryIndexAutoScalingUpdate {
  ReplicaGlobalSecondaryIndexAutoScalingUpdate(
    index_name: option.Option(String),
    provisioned_read_capacity_auto_scaling_update: option.Option(
      AutoScalingSettingsUpdate,
    ),
  )
}

pub fn encode_replica_global_secondary_index_auto_scaling_update_struct(
  input: ReplicaGlobalSecondaryIndexAutoScalingUpdate,
) -> json.Json {
  let pairs = []
  let pairs = case input.index_name {
    option.Some(v) -> [#("IndexName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.provisioned_read_capacity_auto_scaling_update {
    option.Some(v) -> [
      #(
        "ProvisionedReadCapacityAutoScalingUpdate",
        encode_auto_scaling_settings_update_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_global_secondary_index_auto_scaling_update_struct() -> decode.Decoder(
  ReplicaGlobalSecondaryIndexAutoScalingUpdate,
) {
  use index_name <- decode.optional_field(
    "IndexName",
    option.None,
    decode.optional(decode.string),
  )
  use provisioned_read_capacity_auto_scaling_update <- decode.optional_field(
    "ProvisionedReadCapacityAutoScalingUpdate",
    option.None,
    decode.optional(decode_auto_scaling_settings_update_struct()),
  )
  decode.success(ReplicaGlobalSecondaryIndexAutoScalingUpdate(
    index_name: index_name,
    provisioned_read_capacity_auto_scaling_update: provisioned_read_capacity_auto_scaling_update,
  ))
}

pub type UpdateTableReplicaAutoScalingOutput {
  UpdateTableReplicaAutoScalingOutput(
    table_auto_scaling_description: option.Option(TableAutoScalingDescription),
  )
}

pub fn encode_update_table_replica_auto_scaling_output_struct(
  input: UpdateTableReplicaAutoScalingOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_auto_scaling_description {
    option.Some(v) -> [
      #(
        "TableAutoScalingDescription",
        encode_table_auto_scaling_description_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_table_replica_auto_scaling_output_struct() -> decode.Decoder(
  UpdateTableReplicaAutoScalingOutput,
) {
  use table_auto_scaling_description <- decode.optional_field(
    "TableAutoScalingDescription",
    option.None,
    decode.optional(decode_table_auto_scaling_description_struct()),
  )
  decode.success(UpdateTableReplicaAutoScalingOutput(
    table_auto_scaling_description: table_auto_scaling_description,
  ))
}

pub type UpdateTimeToLiveInput {
  UpdateTimeToLiveInput(
    table_name: option.Option(String),
    time_to_live_specification: option.Option(TimeToLiveSpecification),
  )
}

pub fn encode_update_time_to_live_input_struct(
  input: UpdateTimeToLiveInput,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.time_to_live_specification {
    option.Some(v) -> [
      #("TimeToLiveSpecification", encode_time_to_live_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_time_to_live_input_struct() -> decode.Decoder(
  UpdateTimeToLiveInput,
) {
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use time_to_live_specification <- decode.optional_field(
    "TimeToLiveSpecification",
    option.None,
    decode.optional(decode_time_to_live_specification_struct()),
  )
  decode.success(UpdateTimeToLiveInput(
    table_name: table_name,
    time_to_live_specification: time_to_live_specification,
  ))
}

pub type TimeToLiveSpecification {
  TimeToLiveSpecification(
    attribute_name: option.Option(String),
    enabled: option.Option(Bool),
  )
}

pub fn encode_time_to_live_specification_struct(
  input: TimeToLiveSpecification,
) -> json.Json {
  let pairs = []
  let pairs = case input.attribute_name {
    option.Some(v) -> [#("AttributeName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.enabled {
    option.Some(v) -> [#("Enabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_time_to_live_specification_struct() -> decode.Decoder(
  TimeToLiveSpecification,
) {
  use attribute_name <- decode.optional_field(
    "AttributeName",
    option.None,
    decode.optional(decode.string),
  )
  use enabled <- decode.optional_field(
    "Enabled",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(TimeToLiveSpecification(
    attribute_name: attribute_name,
    enabled: enabled,
  ))
}

pub type UpdateTimeToLiveOutput {
  UpdateTimeToLiveOutput(
    time_to_live_specification: option.Option(TimeToLiveSpecification),
  )
}

pub fn encode_update_time_to_live_output_struct(
  input: UpdateTimeToLiveOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.time_to_live_specification {
    option.Some(v) -> [
      #("TimeToLiveSpecification", encode_time_to_live_specification_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_update_time_to_live_output_struct() -> decode.Decoder(
  UpdateTimeToLiveOutput,
) {
  use time_to_live_specification <- decode.optional_field(
    "TimeToLiveSpecification",
    option.None,
    decode.optional(decode_time_to_live_specification_struct()),
  )
  decode.success(UpdateTimeToLiveOutput(
    time_to_live_specification: time_to_live_specification,
  ))
}

pub fn encode_batch_execute_statement_input(
  input: BatchExecuteStatementInput,
) -> String {
  json.to_string(encode_batch_execute_statement_input_struct(input))
}

pub fn decode_batch_execute_statement_input(
  body: String,
) -> Result(BatchExecuteStatementInput, String) {
  case json.parse(body, decode_batch_execute_statement_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_batch_execute_statement_output(
  body: String,
) -> Result(BatchExecuteStatementOutput, String) {
  case json.parse(body, decode_batch_execute_statement_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_batch_execute_statement_request(
  input: BatchExecuteStatementInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_batch_execute_statement_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.BatchExecuteStatement"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_batch_execute_statement_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(BatchExecuteStatementOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_batch_execute_statement_output("{}")
        _ -> decode_batch_execute_statement_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_batch_get_item_input(input: BatchGetItemInput) -> String {
  json.to_string(encode_batch_get_item_input_struct(input))
}

pub fn decode_batch_get_item_input(
  body: String,
) -> Result(BatchGetItemInput, String) {
  case json.parse(body, decode_batch_get_item_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_batch_get_item_output(
  body: String,
) -> Result(BatchGetItemOutput, String) {
  case json.parse(body, decode_batch_get_item_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_batch_get_item_request(
  input: BatchGetItemInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_batch_get_item_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.BatchGetItem"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_batch_get_item_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(BatchGetItemOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_batch_get_item_output("{}")
        _ -> decode_batch_get_item_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_batch_write_item_input(input: BatchWriteItemInput) -> String {
  json.to_string(encode_batch_write_item_input_struct(input))
}

pub fn decode_batch_write_item_input(
  body: String,
) -> Result(BatchWriteItemInput, String) {
  case json.parse(body, decode_batch_write_item_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_batch_write_item_output(
  body: String,
) -> Result(BatchWriteItemOutput, String) {
  case json.parse(body, decode_batch_write_item_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_batch_write_item_request(
  input: BatchWriteItemInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_batch_write_item_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.BatchWriteItem"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_batch_write_item_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(BatchWriteItemOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_batch_write_item_output("{}")
        _ -> decode_batch_write_item_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_create_backup_input(input: CreateBackupInput) -> String {
  json.to_string(encode_create_backup_input_struct(input))
}

pub fn decode_create_backup_input(
  body: String,
) -> Result(CreateBackupInput, String) {
  case json.parse(body, decode_create_backup_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_create_backup_output(
  body: String,
) -> Result(CreateBackupOutput, String) {
  case json.parse(body, decode_create_backup_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_create_backup_request(
  input: CreateBackupInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_create_backup_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.CreateBackup"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_create_backup_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CreateBackupOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_create_backup_output("{}")
        _ -> decode_create_backup_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_create_global_table_input(
  input: CreateGlobalTableInput,
) -> String {
  json.to_string(encode_create_global_table_input_struct(input))
}

pub fn decode_create_global_table_input(
  body: String,
) -> Result(CreateGlobalTableInput, String) {
  case json.parse(body, decode_create_global_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_create_global_table_output(
  body: String,
) -> Result(CreateGlobalTableOutput, String) {
  case json.parse(body, decode_create_global_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_create_global_table_request(
  input: CreateGlobalTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_create_global_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.CreateGlobalTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_create_global_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CreateGlobalTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_create_global_table_output("{}")
        _ -> decode_create_global_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_create_table_input(input: CreateTableInput) -> String {
  json.to_string(encode_create_table_input_struct(input))
}

pub fn decode_create_table_input(
  body: String,
) -> Result(CreateTableInput, String) {
  case json.parse(body, decode_create_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_create_table_output(
  body: String,
) -> Result(CreateTableOutput, String) {
  case json.parse(body, decode_create_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_create_table_request(
  input: CreateTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_create_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.CreateTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_create_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CreateTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_create_table_output("{}")
        _ -> decode_create_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_delete_backup_input(input: DeleteBackupInput) -> String {
  json.to_string(encode_delete_backup_input_struct(input))
}

pub fn decode_delete_backup_input(
  body: String,
) -> Result(DeleteBackupInput, String) {
  case json.parse(body, decode_delete_backup_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_backup_output(
  body: String,
) -> Result(DeleteBackupOutput, String) {
  case json.parse(body, decode_delete_backup_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_delete_backup_request(
  input: DeleteBackupInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_delete_backup_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DeleteBackup"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_delete_backup_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBackupOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_backup_output("{}")
        _ -> decode_delete_backup_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_delete_item_input(input: DeleteItemInput) -> String {
  json.to_string(encode_delete_item_input_struct(input))
}

pub fn decode_delete_item_input(
  body: String,
) -> Result(DeleteItemInput, String) {
  case json.parse(body, decode_delete_item_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_item_output(
  body: String,
) -> Result(DeleteItemOutput, String) {
  case json.parse(body, decode_delete_item_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_delete_item_request(
  input: DeleteItemInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_delete_item_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DeleteItem"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_delete_item_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteItemOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_item_output("{}")
        _ -> decode_delete_item_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_delete_resource_policy_input(
  input: DeleteResourcePolicyInput,
) -> String {
  json.to_string(encode_delete_resource_policy_input_struct(input))
}

pub fn decode_delete_resource_policy_input(
  body: String,
) -> Result(DeleteResourcePolicyInput, String) {
  case json.parse(body, decode_delete_resource_policy_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_resource_policy_output(
  body: String,
) -> Result(DeleteResourcePolicyOutput, String) {
  case json.parse(body, decode_delete_resource_policy_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_delete_resource_policy_request(
  input: DeleteResourcePolicyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_delete_resource_policy_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DeleteResourcePolicy"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_delete_resource_policy_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteResourcePolicyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_resource_policy_output("{}")
        _ -> decode_delete_resource_policy_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_delete_table_input(input: DeleteTableInput) -> String {
  json.to_string(encode_delete_table_input_struct(input))
}

pub fn decode_delete_table_input(
  body: String,
) -> Result(DeleteTableInput, String) {
  case json.parse(body, decode_delete_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_table_output(
  body: String,
) -> Result(DeleteTableOutput, String) {
  case json.parse(body, decode_delete_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_delete_table_request(
  input: DeleteTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_delete_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DeleteTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_delete_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_table_output("{}")
        _ -> decode_delete_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_backup_input(input: DescribeBackupInput) -> String {
  json.to_string(encode_describe_backup_input_struct(input))
}

pub fn decode_describe_backup_input(
  body: String,
) -> Result(DescribeBackupInput, String) {
  case json.parse(body, decode_describe_backup_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_backup_output(
  body: String,
) -> Result(DescribeBackupOutput, String) {
  case json.parse(body, decode_describe_backup_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_backup_request(
  input: DescribeBackupInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_backup_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeBackup"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_backup_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeBackupOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_backup_output("{}")
        _ -> decode_describe_backup_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_continuous_backups_input(
  input: DescribeContinuousBackupsInput,
) -> String {
  json.to_string(encode_describe_continuous_backups_input_struct(input))
}

pub fn decode_describe_continuous_backups_input(
  body: String,
) -> Result(DescribeContinuousBackupsInput, String) {
  case json.parse(body, decode_describe_continuous_backups_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_continuous_backups_output(
  body: String,
) -> Result(DescribeContinuousBackupsOutput, String) {
  case json.parse(body, decode_describe_continuous_backups_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_continuous_backups_request(
  input: DescribeContinuousBackupsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_continuous_backups_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeContinuousBackups"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_continuous_backups_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeContinuousBackupsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_continuous_backups_output("{}")
        _ -> decode_describe_continuous_backups_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_contributor_insights_input(
  input: DescribeContributorInsightsInput,
) -> String {
  json.to_string(encode_describe_contributor_insights_input_struct(input))
}

pub fn decode_describe_contributor_insights_input(
  body: String,
) -> Result(DescribeContributorInsightsInput, String) {
  case json.parse(body, decode_describe_contributor_insights_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_contributor_insights_output(
  body: String,
) -> Result(DescribeContributorInsightsOutput, String) {
  case json.parse(body, decode_describe_contributor_insights_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_contributor_insights_request(
  input: DescribeContributorInsightsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_contributor_insights_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeContributorInsights"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_contributor_insights_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeContributorInsightsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_contributor_insights_output("{}")
        _ -> decode_describe_contributor_insights_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_endpoints_input(
  input: DescribeEndpointsRequest,
) -> String {
  json.to_string(encode_describe_endpoints_request_struct(input))
}

pub fn decode_describe_endpoints_input(
  body: String,
) -> Result(DescribeEndpointsRequest, String) {
  case json.parse(body, decode_describe_endpoints_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_endpoints_output(
  body: String,
) -> Result(DescribeEndpointsResponse, String) {
  case json.parse(body, decode_describe_endpoints_response_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_endpoints_request(
  input: DescribeEndpointsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_endpoints_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeEndpoints"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_endpoints_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeEndpointsResponse, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_endpoints_output("{}")
        _ -> decode_describe_endpoints_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_export_input(input: DescribeExportInput) -> String {
  json.to_string(encode_describe_export_input_struct(input))
}

pub fn decode_describe_export_input(
  body: String,
) -> Result(DescribeExportInput, String) {
  case json.parse(body, decode_describe_export_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_export_output(
  body: String,
) -> Result(DescribeExportOutput, String) {
  case json.parse(body, decode_describe_export_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_export_request(
  input: DescribeExportInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_export_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeExport"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_export_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeExportOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_export_output("{}")
        _ -> decode_describe_export_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_global_table_input(
  input: DescribeGlobalTableInput,
) -> String {
  json.to_string(encode_describe_global_table_input_struct(input))
}

pub fn decode_describe_global_table_input(
  body: String,
) -> Result(DescribeGlobalTableInput, String) {
  case json.parse(body, decode_describe_global_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_global_table_output(
  body: String,
) -> Result(DescribeGlobalTableOutput, String) {
  case json.parse(body, decode_describe_global_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_global_table_request(
  input: DescribeGlobalTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_global_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeGlobalTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_global_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeGlobalTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_global_table_output("{}")
        _ -> decode_describe_global_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_global_table_settings_input(
  input: DescribeGlobalTableSettingsInput,
) -> String {
  json.to_string(encode_describe_global_table_settings_input_struct(input))
}

pub fn decode_describe_global_table_settings_input(
  body: String,
) -> Result(DescribeGlobalTableSettingsInput, String) {
  case json.parse(body, decode_describe_global_table_settings_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_global_table_settings_output(
  body: String,
) -> Result(DescribeGlobalTableSettingsOutput, String) {
  case json.parse(body, decode_describe_global_table_settings_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_global_table_settings_request(
  input: DescribeGlobalTableSettingsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_global_table_settings_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeGlobalTableSettings"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_global_table_settings_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeGlobalTableSettingsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_global_table_settings_output("{}")
        _ -> decode_describe_global_table_settings_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_import_input(input: DescribeImportInput) -> String {
  json.to_string(encode_describe_import_input_struct(input))
}

pub fn decode_describe_import_input(
  body: String,
) -> Result(DescribeImportInput, String) {
  case json.parse(body, decode_describe_import_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_import_output(
  body: String,
) -> Result(DescribeImportOutput, String) {
  case json.parse(body, decode_describe_import_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_import_request(
  input: DescribeImportInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_import_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeImport"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_import_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeImportOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_import_output("{}")
        _ -> decode_describe_import_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_kinesis_streaming_destination_input(
  input: DescribeKinesisStreamingDestinationInput,
) -> String {
  json.to_string(encode_describe_kinesis_streaming_destination_input_struct(
    input,
  ))
}

pub fn decode_describe_kinesis_streaming_destination_input(
  body: String,
) -> Result(DescribeKinesisStreamingDestinationInput, String) {
  case
    json.parse(
      body,
      decode_describe_kinesis_streaming_destination_input_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_kinesis_streaming_destination_output(
  body: String,
) -> Result(DescribeKinesisStreamingDestinationOutput, String) {
  case
    json.parse(
      body,
      decode_describe_kinesis_streaming_destination_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_kinesis_streaming_destination_request(
  input: DescribeKinesisStreamingDestinationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_kinesis_streaming_destination_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeKinesisStreamingDestination"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_kinesis_streaming_destination_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeKinesisStreamingDestinationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_kinesis_streaming_destination_output("{}")
        _ -> decode_describe_kinesis_streaming_destination_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_limits_input(input: DescribeLimitsInput) -> String {
  json.to_string(encode_describe_limits_input_struct(input))
}

pub fn decode_describe_limits_input(
  body: String,
) -> Result(DescribeLimitsInput, String) {
  case json.parse(body, decode_describe_limits_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_limits_output(
  body: String,
) -> Result(DescribeLimitsOutput, String) {
  case json.parse(body, decode_describe_limits_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_limits_request(
  input: DescribeLimitsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_limits_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeLimits"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_limits_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeLimitsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_limits_output("{}")
        _ -> decode_describe_limits_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_table_input(input: DescribeTableInput) -> String {
  json.to_string(encode_describe_table_input_struct(input))
}

pub fn decode_describe_table_input(
  body: String,
) -> Result(DescribeTableInput, String) {
  case json.parse(body, decode_describe_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_table_output(
  body: String,
) -> Result(DescribeTableOutput, String) {
  case json.parse(body, decode_describe_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_table_request(
  input: DescribeTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_table_output("{}")
        _ -> decode_describe_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_table_replica_auto_scaling_input(
  input: DescribeTableReplicaAutoScalingInput,
) -> String {
  json.to_string(encode_describe_table_replica_auto_scaling_input_struct(input))
}

pub fn decode_describe_table_replica_auto_scaling_input(
  body: String,
) -> Result(DescribeTableReplicaAutoScalingInput, String) {
  case
    json.parse(body, decode_describe_table_replica_auto_scaling_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_table_replica_auto_scaling_output(
  body: String,
) -> Result(DescribeTableReplicaAutoScalingOutput, String) {
  case
    json.parse(body, decode_describe_table_replica_auto_scaling_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_table_replica_auto_scaling_request(
  input: DescribeTableReplicaAutoScalingInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_table_replica_auto_scaling_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeTableReplicaAutoScaling"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_table_replica_auto_scaling_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeTableReplicaAutoScalingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_table_replica_auto_scaling_output("{}")
        _ -> decode_describe_table_replica_auto_scaling_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_describe_time_to_live_input(
  input: DescribeTimeToLiveInput,
) -> String {
  json.to_string(encode_describe_time_to_live_input_struct(input))
}

pub fn decode_describe_time_to_live_input(
  body: String,
) -> Result(DescribeTimeToLiveInput, String) {
  case json.parse(body, decode_describe_time_to_live_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_describe_time_to_live_output(
  body: String,
) -> Result(DescribeTimeToLiveOutput, String) {
  case json.parse(body, decode_describe_time_to_live_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_describe_time_to_live_request(
  input: DescribeTimeToLiveInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_describe_time_to_live_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DescribeTimeToLive"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_describe_time_to_live_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DescribeTimeToLiveOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_describe_time_to_live_output("{}")
        _ -> decode_describe_time_to_live_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_disable_kinesis_streaming_destination_input(
  input: KinesisStreamingDestinationInput,
) -> String {
  json.to_string(encode_kinesis_streaming_destination_input_struct(input))
}

pub fn decode_disable_kinesis_streaming_destination_input(
  body: String,
) -> Result(KinesisStreamingDestinationInput, String) {
  case json.parse(body, decode_kinesis_streaming_destination_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_disable_kinesis_streaming_destination_output(
  body: String,
) -> Result(KinesisStreamingDestinationOutput, String) {
  case json.parse(body, decode_kinesis_streaming_destination_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_disable_kinesis_streaming_destination_request(
  input: KinesisStreamingDestinationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_disable_kinesis_streaming_destination_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.DisableKinesisStreamingDestination"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_disable_kinesis_streaming_destination_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(KinesisStreamingDestinationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_disable_kinesis_streaming_destination_output("{}")
        _ -> decode_disable_kinesis_streaming_destination_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_enable_kinesis_streaming_destination_input(
  input: KinesisStreamingDestinationInput,
) -> String {
  json.to_string(encode_kinesis_streaming_destination_input_struct(input))
}

pub fn decode_enable_kinesis_streaming_destination_input(
  body: String,
) -> Result(KinesisStreamingDestinationInput, String) {
  case json.parse(body, decode_kinesis_streaming_destination_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_enable_kinesis_streaming_destination_output(
  body: String,
) -> Result(KinesisStreamingDestinationOutput, String) {
  case json.parse(body, decode_kinesis_streaming_destination_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_enable_kinesis_streaming_destination_request(
  input: KinesisStreamingDestinationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_enable_kinesis_streaming_destination_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.EnableKinesisStreamingDestination"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_enable_kinesis_streaming_destination_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(KinesisStreamingDestinationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_enable_kinesis_streaming_destination_output("{}")
        _ -> decode_enable_kinesis_streaming_destination_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_execute_statement_input(input: ExecuteStatementInput) -> String {
  json.to_string(encode_execute_statement_input_struct(input))
}

pub fn decode_execute_statement_input(
  body: String,
) -> Result(ExecuteStatementInput, String) {
  case json.parse(body, decode_execute_statement_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_execute_statement_output(
  body: String,
) -> Result(ExecuteStatementOutput, String) {
  case json.parse(body, decode_execute_statement_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_execute_statement_request(
  input: ExecuteStatementInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_execute_statement_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ExecuteStatement"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_execute_statement_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ExecuteStatementOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_execute_statement_output("{}")
        _ -> decode_execute_statement_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_execute_transaction_input(
  input: ExecuteTransactionInput,
) -> String {
  json.to_string(encode_execute_transaction_input_struct(input))
}

pub fn decode_execute_transaction_input(
  body: String,
) -> Result(ExecuteTransactionInput, String) {
  case json.parse(body, decode_execute_transaction_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_execute_transaction_output(
  body: String,
) -> Result(ExecuteTransactionOutput, String) {
  case json.parse(body, decode_execute_transaction_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_execute_transaction_request(
  input: ExecuteTransactionInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_execute_transaction_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ExecuteTransaction"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_execute_transaction_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ExecuteTransactionOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_execute_transaction_output("{}")
        _ -> decode_execute_transaction_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_export_table_to_point_in_time_input(
  input: ExportTableToPointInTimeInput,
) -> String {
  json.to_string(encode_export_table_to_point_in_time_input_struct(input))
}

pub fn decode_export_table_to_point_in_time_input(
  body: String,
) -> Result(ExportTableToPointInTimeInput, String) {
  case json.parse(body, decode_export_table_to_point_in_time_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_export_table_to_point_in_time_output(
  body: String,
) -> Result(ExportTableToPointInTimeOutput, String) {
  case json.parse(body, decode_export_table_to_point_in_time_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_export_table_to_point_in_time_request(
  input: ExportTableToPointInTimeInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_export_table_to_point_in_time_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ExportTableToPointInTime"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_export_table_to_point_in_time_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ExportTableToPointInTimeOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_export_table_to_point_in_time_output("{}")
        _ -> decode_export_table_to_point_in_time_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_item_input(input: GetItemInput) -> String {
  json.to_string(encode_get_item_input_struct(input))
}

pub fn decode_get_item_input(body: String) -> Result(GetItemInput, String) {
  case json.parse(body, decode_get_item_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_item_output(body: String) -> Result(GetItemOutput, String) {
  case json.parse(body, decode_get_item_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_get_item_request(
  input: GetItemInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_get_item_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.GetItem"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_get_item_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetItemOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_item_output("{}")
        _ -> decode_get_item_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_resource_policy_input(
  input: GetResourcePolicyInput,
) -> String {
  json.to_string(encode_get_resource_policy_input_struct(input))
}

pub fn decode_get_resource_policy_input(
  body: String,
) -> Result(GetResourcePolicyInput, String) {
  case json.parse(body, decode_get_resource_policy_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_resource_policy_output(
  body: String,
) -> Result(GetResourcePolicyOutput, String) {
  case json.parse(body, decode_get_resource_policy_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_get_resource_policy_request(
  input: GetResourcePolicyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_get_resource_policy_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.GetResourcePolicy"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_get_resource_policy_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetResourcePolicyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_resource_policy_output("{}")
        _ -> decode_get_resource_policy_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_import_table_input(input: ImportTableInput) -> String {
  json.to_string(encode_import_table_input_struct(input))
}

pub fn decode_import_table_input(
  body: String,
) -> Result(ImportTableInput, String) {
  case json.parse(body, decode_import_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_import_table_output(
  body: String,
) -> Result(ImportTableOutput, String) {
  case json.parse(body, decode_import_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_import_table_request(
  input: ImportTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_import_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ImportTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_import_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ImportTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_import_table_output("{}")
        _ -> decode_import_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_backups_input(input: ListBackupsInput) -> String {
  json.to_string(encode_list_backups_input_struct(input))
}

pub fn decode_list_backups_input(
  body: String,
) -> Result(ListBackupsInput, String) {
  case json.parse(body, decode_list_backups_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_backups_output(
  body: String,
) -> Result(ListBackupsOutput, String) {
  case json.parse(body, decode_list_backups_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_list_backups_request(
  input: ListBackupsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_list_backups_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ListBackups"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_list_backups_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListBackupsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_backups_output("{}")
        _ -> decode_list_backups_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_contributor_insights_input(
  input: ListContributorInsightsInput,
) -> String {
  json.to_string(encode_list_contributor_insights_input_struct(input))
}

pub fn decode_list_contributor_insights_input(
  body: String,
) -> Result(ListContributorInsightsInput, String) {
  case json.parse(body, decode_list_contributor_insights_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_contributor_insights_output(
  body: String,
) -> Result(ListContributorInsightsOutput, String) {
  case json.parse(body, decode_list_contributor_insights_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_list_contributor_insights_request(
  input: ListContributorInsightsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_list_contributor_insights_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ListContributorInsights"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_list_contributor_insights_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListContributorInsightsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_contributor_insights_output("{}")
        _ -> decode_list_contributor_insights_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_exports_input(input: ListExportsInput) -> String {
  json.to_string(encode_list_exports_input_struct(input))
}

pub fn decode_list_exports_input(
  body: String,
) -> Result(ListExportsInput, String) {
  case json.parse(body, decode_list_exports_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_exports_output(
  body: String,
) -> Result(ListExportsOutput, String) {
  case json.parse(body, decode_list_exports_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_list_exports_request(
  input: ListExportsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_list_exports_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ListExports"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_list_exports_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListExportsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_exports_output("{}")
        _ -> decode_list_exports_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_global_tables_input(input: ListGlobalTablesInput) -> String {
  json.to_string(encode_list_global_tables_input_struct(input))
}

pub fn decode_list_global_tables_input(
  body: String,
) -> Result(ListGlobalTablesInput, String) {
  case json.parse(body, decode_list_global_tables_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_global_tables_output(
  body: String,
) -> Result(ListGlobalTablesOutput, String) {
  case json.parse(body, decode_list_global_tables_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_list_global_tables_request(
  input: ListGlobalTablesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_list_global_tables_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ListGlobalTables"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_list_global_tables_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListGlobalTablesOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_global_tables_output("{}")
        _ -> decode_list_global_tables_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_imports_input(input: ListImportsInput) -> String {
  json.to_string(encode_list_imports_input_struct(input))
}

pub fn decode_list_imports_input(
  body: String,
) -> Result(ListImportsInput, String) {
  case json.parse(body, decode_list_imports_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_imports_output(
  body: String,
) -> Result(ListImportsOutput, String) {
  case json.parse(body, decode_list_imports_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_list_imports_request(
  input: ListImportsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_list_imports_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ListImports"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_list_imports_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListImportsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_imports_output("{}")
        _ -> decode_list_imports_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_tables_input(input: ListTablesInput) -> String {
  json.to_string(encode_list_tables_input_struct(input))
}

pub fn decode_list_tables_input(
  body: String,
) -> Result(ListTablesInput, String) {
  case json.parse(body, decode_list_tables_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_tables_output(
  body: String,
) -> Result(ListTablesOutput, String) {
  case json.parse(body, decode_list_tables_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_list_tables_request(
  input: ListTablesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_list_tables_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ListTables"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_list_tables_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListTablesOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_tables_output("{}")
        _ -> decode_list_tables_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_tags_of_resource_input(
  input: ListTagsOfResourceInput,
) -> String {
  json.to_string(encode_list_tags_of_resource_input_struct(input))
}

pub fn decode_list_tags_of_resource_input(
  body: String,
) -> Result(ListTagsOfResourceInput, String) {
  case json.parse(body, decode_list_tags_of_resource_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_tags_of_resource_output(
  body: String,
) -> Result(ListTagsOfResourceOutput, String) {
  case json.parse(body, decode_list_tags_of_resource_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_list_tags_of_resource_request(
  input: ListTagsOfResourceInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_list_tags_of_resource_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.ListTagsOfResource"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_list_tags_of_resource_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListTagsOfResourceOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_tags_of_resource_output("{}")
        _ -> decode_list_tags_of_resource_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_put_item_input(input: PutItemInput) -> String {
  json.to_string(encode_put_item_input_struct(input))
}

pub fn decode_put_item_input(body: String) -> Result(PutItemInput, String) {
  case json.parse(body, decode_put_item_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_item_output(body: String) -> Result(PutItemOutput, String) {
  case json.parse(body, decode_put_item_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_put_item_request(
  input: PutItemInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_put_item_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.PutItem"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_put_item_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutItemOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_item_output("{}")
        _ -> decode_put_item_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_put_resource_policy_input(
  input: PutResourcePolicyInput,
) -> String {
  json.to_string(encode_put_resource_policy_input_struct(input))
}

pub fn decode_put_resource_policy_input(
  body: String,
) -> Result(PutResourcePolicyInput, String) {
  case json.parse(body, decode_put_resource_policy_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_resource_policy_output(
  body: String,
) -> Result(PutResourcePolicyOutput, String) {
  case json.parse(body, decode_put_resource_policy_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_put_resource_policy_request(
  input: PutResourcePolicyInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_put_resource_policy_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.PutResourcePolicy"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_put_resource_policy_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutResourcePolicyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_resource_policy_output("{}")
        _ -> decode_put_resource_policy_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_query_input(input: QueryInput) -> String {
  json.to_string(encode_query_input_struct(input))
}

pub fn decode_query_input(body: String) -> Result(QueryInput, String) {
  case json.parse(body, decode_query_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_query_output(body: String) -> Result(QueryOutput, String) {
  case json.parse(body, decode_query_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_query_request(
  input: QueryInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_query_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.Query"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_query_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(QueryOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_query_output("{}")
        _ -> decode_query_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_restore_table_from_backup_input(
  input: RestoreTableFromBackupInput,
) -> String {
  json.to_string(encode_restore_table_from_backup_input_struct(input))
}

pub fn decode_restore_table_from_backup_input(
  body: String,
) -> Result(RestoreTableFromBackupInput, String) {
  case json.parse(body, decode_restore_table_from_backup_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_restore_table_from_backup_output(
  body: String,
) -> Result(RestoreTableFromBackupOutput, String) {
  case json.parse(body, decode_restore_table_from_backup_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_restore_table_from_backup_request(
  input: RestoreTableFromBackupInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_restore_table_from_backup_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.RestoreTableFromBackup"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_restore_table_from_backup_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(RestoreTableFromBackupOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_restore_table_from_backup_output("{}")
        _ -> decode_restore_table_from_backup_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_restore_table_to_point_in_time_input(
  input: RestoreTableToPointInTimeInput,
) -> String {
  json.to_string(encode_restore_table_to_point_in_time_input_struct(input))
}

pub fn decode_restore_table_to_point_in_time_input(
  body: String,
) -> Result(RestoreTableToPointInTimeInput, String) {
  case json.parse(body, decode_restore_table_to_point_in_time_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_restore_table_to_point_in_time_output(
  body: String,
) -> Result(RestoreTableToPointInTimeOutput, String) {
  case json.parse(body, decode_restore_table_to_point_in_time_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_restore_table_to_point_in_time_request(
  input: RestoreTableToPointInTimeInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_restore_table_to_point_in_time_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.RestoreTableToPointInTime"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_restore_table_to_point_in_time_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(RestoreTableToPointInTimeOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_restore_table_to_point_in_time_output("{}")
        _ -> decode_restore_table_to_point_in_time_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_scan_input(input: ScanInput) -> String {
  json.to_string(encode_scan_input_struct(input))
}

pub fn decode_scan_input(body: String) -> Result(ScanInput, String) {
  case json.parse(body, decode_scan_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_scan_output(body: String) -> Result(ScanOutput, String) {
  case json.parse(body, decode_scan_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_scan_request(
  input: ScanInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_scan_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.Scan"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_scan_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ScanOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_scan_output("{}")
        _ -> decode_scan_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type TagResourceOutput {
  TagResourceOutput
}

pub fn encode_tag_resource_output_struct(_v: TagResourceOutput) -> json.Json {
  json.object([])
}

pub fn decode_tag_resource_output_struct() -> decode.Decoder(TagResourceOutput) {
  decode.success(TagResourceOutput)
}

pub fn encode_tag_resource_input(input: TagResourceInput) -> String {
  json.to_string(encode_tag_resource_input_struct(input))
}

pub fn decode_tag_resource_input(
  body: String,
) -> Result(TagResourceInput, String) {
  case json.parse(body, decode_tag_resource_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_tag_resource_output(
  body: String,
) -> Result(TagResourceOutput, String) {
  case json.parse(body, decode_tag_resource_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_tag_resource_request(
  input: TagResourceInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_tag_resource_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.TagResource"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_tag_resource_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TagResourceOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_tag_resource_output("{}")
        _ -> decode_tag_resource_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_transact_get_items_input(input: TransactGetItemsInput) -> String {
  json.to_string(encode_transact_get_items_input_struct(input))
}

pub fn decode_transact_get_items_input(
  body: String,
) -> Result(TransactGetItemsInput, String) {
  case json.parse(body, decode_transact_get_items_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_transact_get_items_output(
  body: String,
) -> Result(TransactGetItemsOutput, String) {
  case json.parse(body, decode_transact_get_items_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_transact_get_items_request(
  input: TransactGetItemsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_transact_get_items_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.TransactGetItems"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_transact_get_items_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TransactGetItemsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_transact_get_items_output("{}")
        _ -> decode_transact_get_items_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_transact_write_items_input(
  input: TransactWriteItemsInput,
) -> String {
  json.to_string(encode_transact_write_items_input_struct(input))
}

pub fn decode_transact_write_items_input(
  body: String,
) -> Result(TransactWriteItemsInput, String) {
  case json.parse(body, decode_transact_write_items_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_transact_write_items_output(
  body: String,
) -> Result(TransactWriteItemsOutput, String) {
  case json.parse(body, decode_transact_write_items_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_transact_write_items_request(
  input: TransactWriteItemsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_transact_write_items_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.TransactWriteItems"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_transact_write_items_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(TransactWriteItemsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_transact_write_items_output("{}")
        _ -> decode_transact_write_items_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type UntagResourceOutput {
  UntagResourceOutput
}

pub fn encode_untag_resource_output_struct(
  _v: UntagResourceOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_untag_resource_output_struct() -> decode.Decoder(
  UntagResourceOutput,
) {
  decode.success(UntagResourceOutput)
}

pub fn encode_untag_resource_input(input: UntagResourceInput) -> String {
  json.to_string(encode_untag_resource_input_struct(input))
}

pub fn decode_untag_resource_input(
  body: String,
) -> Result(UntagResourceInput, String) {
  case json.parse(body, decode_untag_resource_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_untag_resource_output(
  body: String,
) -> Result(UntagResourceOutput, String) {
  case json.parse(body, decode_untag_resource_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_untag_resource_request(
  input: UntagResourceInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_untag_resource_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UntagResource"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_untag_resource_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UntagResourceOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_untag_resource_output("{}")
        _ -> decode_untag_resource_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_continuous_backups_input(
  input: UpdateContinuousBackupsInput,
) -> String {
  json.to_string(encode_update_continuous_backups_input_struct(input))
}

pub fn decode_update_continuous_backups_input(
  body: String,
) -> Result(UpdateContinuousBackupsInput, String) {
  case json.parse(body, decode_update_continuous_backups_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_continuous_backups_output(
  body: String,
) -> Result(UpdateContinuousBackupsOutput, String) {
  case json.parse(body, decode_update_continuous_backups_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_continuous_backups_request(
  input: UpdateContinuousBackupsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_continuous_backups_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateContinuousBackups"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_continuous_backups_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateContinuousBackupsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_continuous_backups_output("{}")
        _ -> decode_update_continuous_backups_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_contributor_insights_input(
  input: UpdateContributorInsightsInput,
) -> String {
  json.to_string(encode_update_contributor_insights_input_struct(input))
}

pub fn decode_update_contributor_insights_input(
  body: String,
) -> Result(UpdateContributorInsightsInput, String) {
  case json.parse(body, decode_update_contributor_insights_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_contributor_insights_output(
  body: String,
) -> Result(UpdateContributorInsightsOutput, String) {
  case json.parse(body, decode_update_contributor_insights_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_contributor_insights_request(
  input: UpdateContributorInsightsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_contributor_insights_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateContributorInsights"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_contributor_insights_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateContributorInsightsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_contributor_insights_output("{}")
        _ -> decode_update_contributor_insights_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_global_table_input(
  input: UpdateGlobalTableInput,
) -> String {
  json.to_string(encode_update_global_table_input_struct(input))
}

pub fn decode_update_global_table_input(
  body: String,
) -> Result(UpdateGlobalTableInput, String) {
  case json.parse(body, decode_update_global_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_global_table_output(
  body: String,
) -> Result(UpdateGlobalTableOutput, String) {
  case json.parse(body, decode_update_global_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_global_table_request(
  input: UpdateGlobalTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_global_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateGlobalTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_global_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateGlobalTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_global_table_output("{}")
        _ -> decode_update_global_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_global_table_settings_input(
  input: UpdateGlobalTableSettingsInput,
) -> String {
  json.to_string(encode_update_global_table_settings_input_struct(input))
}

pub fn decode_update_global_table_settings_input(
  body: String,
) -> Result(UpdateGlobalTableSettingsInput, String) {
  case json.parse(body, decode_update_global_table_settings_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_global_table_settings_output(
  body: String,
) -> Result(UpdateGlobalTableSettingsOutput, String) {
  case json.parse(body, decode_update_global_table_settings_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_global_table_settings_request(
  input: UpdateGlobalTableSettingsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_global_table_settings_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateGlobalTableSettings"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_global_table_settings_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateGlobalTableSettingsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_global_table_settings_output("{}")
        _ -> decode_update_global_table_settings_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_item_input(input: UpdateItemInput) -> String {
  json.to_string(encode_update_item_input_struct(input))
}

pub fn decode_update_item_input(
  body: String,
) -> Result(UpdateItemInput, String) {
  case json.parse(body, decode_update_item_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_item_output(
  body: String,
) -> Result(UpdateItemOutput, String) {
  case json.parse(body, decode_update_item_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_item_request(
  input: UpdateItemInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_item_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateItem"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_item_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateItemOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_item_output("{}")
        _ -> decode_update_item_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_kinesis_streaming_destination_input(
  input: UpdateKinesisStreamingDestinationInput,
) -> String {
  json.to_string(encode_update_kinesis_streaming_destination_input_struct(input))
}

pub fn decode_update_kinesis_streaming_destination_input(
  body: String,
) -> Result(UpdateKinesisStreamingDestinationInput, String) {
  case
    json.parse(body, decode_update_kinesis_streaming_destination_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_kinesis_streaming_destination_output(
  body: String,
) -> Result(UpdateKinesisStreamingDestinationOutput, String) {
  case
    json.parse(
      body,
      decode_update_kinesis_streaming_destination_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_kinesis_streaming_destination_request(
  input: UpdateKinesisStreamingDestinationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_kinesis_streaming_destination_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateKinesisStreamingDestination"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_kinesis_streaming_destination_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateKinesisStreamingDestinationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_kinesis_streaming_destination_output("{}")
        _ -> decode_update_kinesis_streaming_destination_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_table_input(input: UpdateTableInput) -> String {
  json.to_string(encode_update_table_input_struct(input))
}

pub fn decode_update_table_input(
  body: String,
) -> Result(UpdateTableInput, String) {
  case json.parse(body, decode_update_table_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_table_output(
  body: String,
) -> Result(UpdateTableOutput, String) {
  case json.parse(body, decode_update_table_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_table_request(
  input: UpdateTableInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_table_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateTable"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_table_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateTableOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_table_output("{}")
        _ -> decode_update_table_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_table_replica_auto_scaling_input(
  input: UpdateTableReplicaAutoScalingInput,
) -> String {
  json.to_string(encode_update_table_replica_auto_scaling_input_struct(input))
}

pub fn decode_update_table_replica_auto_scaling_input(
  body: String,
) -> Result(UpdateTableReplicaAutoScalingInput, String) {
  case
    json.parse(body, decode_update_table_replica_auto_scaling_input_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_table_replica_auto_scaling_output(
  body: String,
) -> Result(UpdateTableReplicaAutoScalingOutput, String) {
  case
    json.parse(body, decode_update_table_replica_auto_scaling_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_table_replica_auto_scaling_request(
  input: UpdateTableReplicaAutoScalingInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_table_replica_auto_scaling_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateTableReplicaAutoScaling"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_table_replica_auto_scaling_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateTableReplicaAutoScalingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_table_replica_auto_scaling_output("{}")
        _ -> decode_update_table_replica_auto_scaling_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_update_time_to_live_input(
  input: UpdateTimeToLiveInput,
) -> String {
  json.to_string(encode_update_time_to_live_input_struct(input))
}

pub fn decode_update_time_to_live_input(
  body: String,
) -> Result(UpdateTimeToLiveInput, String) {
  case json.parse(body, decode_update_time_to_live_input_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_update_time_to_live_output(
  body: String,
) -> Result(UpdateTimeToLiveOutput, String) {
  case json.parse(body, decode_update_time_to_live_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn build_update_time_to_live_request(
  input: UpdateTimeToLiveInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let body_str = encode_update_time_to_live_input(input)
  let body = bit_array.from_string(body_str)
  let headers =
    dict.from_list([
      #("Content-Type", "application/x-amz-json-1.0"),
      #("Content-Length", int.to_string(bit_array.byte_size(body))),
      #("X-Amz-Target", "DynamoDB_20120810.UpdateTimeToLive"),
    ])
  #("POST", "/", headers, body)
}

pub fn parse_update_time_to_live_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UpdateTimeToLiveOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_update_time_to_live_output("{}")
        _ -> decode_update_time_to_live_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

/// Invoke BatchExecuteStatement. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn batch_execute_statement(
  client: Client,
  input: BatchExecuteStatementInput,
) -> Result(BatchExecuteStatementOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_batch_execute_statement_request(input),
    parse_batch_execute_statement_response,
  )
}

/// Invoke BatchGetItem. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn batch_get_item(
  client: Client,
  input: BatchGetItemInput,
) -> Result(BatchGetItemOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_batch_get_item_request(input),
    parse_batch_get_item_response,
  )
}

/// Invoke BatchWriteItem. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn batch_write_item(
  client: Client,
  input: BatchWriteItemInput,
) -> Result(BatchWriteItemOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_batch_write_item_request(input),
    parse_batch_write_item_response,
  )
}

/// Invoke CreateBackup. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn create_backup(
  client: Client,
  input: CreateBackupInput,
) -> Result(CreateBackupOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_create_backup_request(input),
    parse_create_backup_response,
  )
}

/// Invoke CreateGlobalTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn create_global_table(
  client: Client,
  input: CreateGlobalTableInput,
) -> Result(CreateGlobalTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_create_global_table_request(input),
    parse_create_global_table_response,
  )
}

/// Invoke CreateTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn create_table(
  client: Client,
  input: CreateTableInput,
) -> Result(CreateTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_create_table_request(input),
    parse_create_table_response,
  )
}

/// Invoke DeleteBackup. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn delete_backup(
  client: Client,
  input: DeleteBackupInput,
) -> Result(DeleteBackupOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_backup_request(input),
    parse_delete_backup_response,
  )
}

/// Invoke DeleteItem. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn delete_item(
  client: Client,
  input: DeleteItemInput,
) -> Result(DeleteItemOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_item_request(input),
    parse_delete_item_response,
  )
}

/// Invoke DeleteResourcePolicy. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn delete_resource_policy(
  client: Client,
  input: DeleteResourcePolicyInput,
) -> Result(DeleteResourcePolicyOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_resource_policy_request(input),
    parse_delete_resource_policy_response,
  )
}

/// Invoke DeleteTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn delete_table(
  client: Client,
  input: DeleteTableInput,
) -> Result(DeleteTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_table_request(input),
    parse_delete_table_response,
  )
}

/// Invoke DescribeBackup. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_backup(
  client: Client,
  input: DescribeBackupInput,
) -> Result(DescribeBackupOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_backup_request(input),
    parse_describe_backup_response,
  )
}

/// Invoke DescribeContinuousBackups. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_continuous_backups(
  client: Client,
  input: DescribeContinuousBackupsInput,
) -> Result(DescribeContinuousBackupsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_continuous_backups_request(input),
    parse_describe_continuous_backups_response,
  )
}

/// Invoke DescribeContributorInsights. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_contributor_insights(
  client: Client,
  input: DescribeContributorInsightsInput,
) -> Result(DescribeContributorInsightsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_contributor_insights_request(input),
    parse_describe_contributor_insights_response,
  )
}

/// Invoke DescribeEndpoints. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_endpoints(
  client: Client,
  input: DescribeEndpointsRequest,
) -> Result(DescribeEndpointsResponse, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_endpoints_request(input),
    parse_describe_endpoints_response,
  )
}

/// Invoke DescribeExport. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_export(
  client: Client,
  input: DescribeExportInput,
) -> Result(DescribeExportOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_export_request(input),
    parse_describe_export_response,
  )
}

/// Invoke DescribeGlobalTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_global_table(
  client: Client,
  input: DescribeGlobalTableInput,
) -> Result(DescribeGlobalTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_global_table_request(input),
    parse_describe_global_table_response,
  )
}

/// Invoke DescribeGlobalTableSettings. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_global_table_settings(
  client: Client,
  input: DescribeGlobalTableSettingsInput,
) -> Result(DescribeGlobalTableSettingsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_global_table_settings_request(input),
    parse_describe_global_table_settings_response,
  )
}

/// Invoke DescribeImport. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_import(
  client: Client,
  input: DescribeImportInput,
) -> Result(DescribeImportOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_import_request(input),
    parse_describe_import_response,
  )
}

/// Invoke DescribeKinesisStreamingDestination. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_kinesis_streaming_destination(
  client: Client,
  input: DescribeKinesisStreamingDestinationInput,
) -> Result(
  DescribeKinesisStreamingDestinationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_describe_kinesis_streaming_destination_request(input),
    parse_describe_kinesis_streaming_destination_response,
  )
}

/// Invoke DescribeLimits. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_limits(
  client: Client,
  input: DescribeLimitsInput,
) -> Result(DescribeLimitsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_limits_request(input),
    parse_describe_limits_response,
  )
}

/// Invoke DescribeTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_table(
  client: Client,
  input: DescribeTableInput,
) -> Result(DescribeTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_table_request(input),
    parse_describe_table_response,
  )
}

/// Invoke DescribeTableReplicaAutoScaling. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_table_replica_auto_scaling(
  client: Client,
  input: DescribeTableReplicaAutoScalingInput,
) -> Result(DescribeTableReplicaAutoScalingOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_table_replica_auto_scaling_request(input),
    parse_describe_table_replica_auto_scaling_response,
  )
}

/// Invoke DescribeTimeToLive. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn describe_time_to_live(
  client: Client,
  input: DescribeTimeToLiveInput,
) -> Result(DescribeTimeToLiveOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_describe_time_to_live_request(input),
    parse_describe_time_to_live_response,
  )
}

/// Invoke DisableKinesisStreamingDestination. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn disable_kinesis_streaming_destination(
  client: Client,
  input: KinesisStreamingDestinationInput,
) -> Result(KinesisStreamingDestinationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_disable_kinesis_streaming_destination_request(input),
    parse_disable_kinesis_streaming_destination_response,
  )
}

/// Invoke EnableKinesisStreamingDestination. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn enable_kinesis_streaming_destination(
  client: Client,
  input: KinesisStreamingDestinationInput,
) -> Result(KinesisStreamingDestinationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_enable_kinesis_streaming_destination_request(input),
    parse_enable_kinesis_streaming_destination_response,
  )
}

/// Invoke ExecuteStatement. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn execute_statement(
  client: Client,
  input: ExecuteStatementInput,
) -> Result(ExecuteStatementOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_execute_statement_request(input),
    parse_execute_statement_response,
  )
}

/// Invoke ExecuteTransaction. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn execute_transaction(
  client: Client,
  input: ExecuteTransactionInput,
) -> Result(ExecuteTransactionOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_execute_transaction_request(input),
    parse_execute_transaction_response,
  )
}

/// Invoke ExportTableToPointInTime. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn export_table_to_point_in_time(
  client: Client,
  input: ExportTableToPointInTimeInput,
) -> Result(ExportTableToPointInTimeOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_export_table_to_point_in_time_request(input),
    parse_export_table_to_point_in_time_response,
  )
}

/// Invoke GetItem. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn get_item(
  client: Client,
  input: GetItemInput,
) -> Result(GetItemOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_item_request(input),
    parse_get_item_response,
  )
}

/// Invoke GetResourcePolicy. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn get_resource_policy(
  client: Client,
  input: GetResourcePolicyInput,
) -> Result(GetResourcePolicyOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_resource_policy_request(input),
    parse_get_resource_policy_response,
  )
}

/// Invoke ImportTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn import_table(
  client: Client,
  input: ImportTableInput,
) -> Result(ImportTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_import_table_request(input),
    parse_import_table_response,
  )
}

/// Invoke ListBackups. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn list_backups(
  client: Client,
  input: ListBackupsInput,
) -> Result(ListBackupsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_backups_request(input),
    parse_list_backups_response,
  )
}

/// Invoke ListContributorInsights. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn list_contributor_insights(
  client: Client,
  input: ListContributorInsightsInput,
) -> Result(ListContributorInsightsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_contributor_insights_request(input),
    parse_list_contributor_insights_response,
  )
}

/// Invoke ListExports. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn list_exports(
  client: Client,
  input: ListExportsInput,
) -> Result(ListExportsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_exports_request(input),
    parse_list_exports_response,
  )
}

/// Invoke ListGlobalTables. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn list_global_tables(
  client: Client,
  input: ListGlobalTablesInput,
) -> Result(ListGlobalTablesOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_global_tables_request(input),
    parse_list_global_tables_response,
  )
}

/// Invoke ListImports. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn list_imports(
  client: Client,
  input: ListImportsInput,
) -> Result(ListImportsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_imports_request(input),
    parse_list_imports_response,
  )
}

/// Invoke ListTables. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn list_tables(
  client: Client,
  input: ListTablesInput,
) -> Result(ListTablesOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_tables_request(input),
    parse_list_tables_response,
  )
}

/// Invoke ListTagsOfResource. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn list_tags_of_resource(
  client: Client,
  input: ListTagsOfResourceInput,
) -> Result(ListTagsOfResourceOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_tags_of_resource_request(input),
    parse_list_tags_of_resource_response,
  )
}

/// Invoke PutItem. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn put_item(
  client: Client,
  input: PutItemInput,
) -> Result(PutItemOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_put_item_request(input),
    parse_put_item_response,
  )
}

/// Invoke PutResourcePolicy. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn put_resource_policy(
  client: Client,
  input: PutResourcePolicyInput,
) -> Result(PutResourcePolicyOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_put_resource_policy_request(input),
    parse_put_resource_policy_response,
  )
}

/// Invoke Query. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn query(
  client: Client,
  input: QueryInput,
) -> Result(QueryOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_query_request(input),
    parse_query_response,
  )
}

/// Invoke RestoreTableFromBackup. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn restore_table_from_backup(
  client: Client,
  input: RestoreTableFromBackupInput,
) -> Result(RestoreTableFromBackupOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_restore_table_from_backup_request(input),
    parse_restore_table_from_backup_response,
  )
}

/// Invoke RestoreTableToPointInTime. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn restore_table_to_point_in_time(
  client: Client,
  input: RestoreTableToPointInTimeInput,
) -> Result(RestoreTableToPointInTimeOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_restore_table_to_point_in_time_request(input),
    parse_restore_table_to_point_in_time_response,
  )
}

/// Invoke Scan. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn scan(
  client: Client,
  input: ScanInput,
) -> Result(ScanOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_scan_request(input),
    parse_scan_response,
  )
}

/// Invoke TagResource. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn tag_resource(
  client: Client,
  input: TagResourceInput,
) -> Result(TagResourceOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_tag_resource_request(input),
    parse_tag_resource_response,
  )
}

/// Invoke TransactGetItems. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn transact_get_items(
  client: Client,
  input: TransactGetItemsInput,
) -> Result(TransactGetItemsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_transact_get_items_request(input),
    parse_transact_get_items_response,
  )
}

/// Invoke TransactWriteItems. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn transact_write_items(
  client: Client,
  input: TransactWriteItemsInput,
) -> Result(TransactWriteItemsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_transact_write_items_request(input),
    parse_transact_write_items_response,
  )
}

/// Invoke UntagResource. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn untag_resource(
  client: Client,
  input: UntagResourceInput,
) -> Result(UntagResourceOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_untag_resource_request(input),
    parse_untag_resource_response,
  )
}

/// Invoke UpdateContinuousBackups. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_continuous_backups(
  client: Client,
  input: UpdateContinuousBackupsInput,
) -> Result(UpdateContinuousBackupsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_continuous_backups_request(input),
    parse_update_continuous_backups_response,
  )
}

/// Invoke UpdateContributorInsights. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_contributor_insights(
  client: Client,
  input: UpdateContributorInsightsInput,
) -> Result(UpdateContributorInsightsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_contributor_insights_request(input),
    parse_update_contributor_insights_response,
  )
}

/// Invoke UpdateGlobalTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_global_table(
  client: Client,
  input: UpdateGlobalTableInput,
) -> Result(UpdateGlobalTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_global_table_request(input),
    parse_update_global_table_response,
  )
}

/// Invoke UpdateGlobalTableSettings. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_global_table_settings(
  client: Client,
  input: UpdateGlobalTableSettingsInput,
) -> Result(UpdateGlobalTableSettingsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_global_table_settings_request(input),
    parse_update_global_table_settings_response,
  )
}

/// Invoke UpdateItem. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_item(
  client: Client,
  input: UpdateItemInput,
) -> Result(UpdateItemOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_item_request(input),
    parse_update_item_response,
  )
}

/// Invoke UpdateKinesisStreamingDestination. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_kinesis_streaming_destination(
  client: Client,
  input: UpdateKinesisStreamingDestinationInput,
) -> Result(UpdateKinesisStreamingDestinationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_kinesis_streaming_destination_request(input),
    parse_update_kinesis_streaming_destination_response,
  )
}

/// Invoke UpdateTable. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_table(
  client: Client,
  input: UpdateTableInput,
) -> Result(UpdateTableOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_table_request(input),
    parse_update_table_response,
  )
}

/// Invoke UpdateTableReplicaAutoScaling. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_table_replica_auto_scaling(
  client: Client,
  input: UpdateTableReplicaAutoScalingInput,
) -> Result(UpdateTableReplicaAutoScalingOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_table_replica_auto_scaling_request(input),
    parse_update_table_replica_auto_scaling_response,
  )
}

/// Invoke UpdateTimeToLive. Signs the request with SigV4 and dispatches via the configured
/// HTTP transport.
pub fn update_time_to_live(
  client: Client,
  input: UpdateTimeToLiveInput,
) -> Result(UpdateTimeToLiveOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_update_time_to_live_request(input),
    parse_update_time_to_live_response,
  )
}
