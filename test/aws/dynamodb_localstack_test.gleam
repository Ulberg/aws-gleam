//// LocalStack-backed end-to-end test for the v0.1 gate operation
//// `DynamoDB.GetItem`. Per CLAUDE.md this is a non-negotiable
//// verification gate.
////
//// The test is gated on `INCLUDE_LOCALSTACK=1` in the environment
//// — a plain `gleam test` skips it so the default suite stays fast.
//// CI sets the env var; developers can opt in with
////
////   INCLUDE_LOCALSTACK=1 gleam test
////
//// The harness shells out to `docker compose` via the Erlang FFI in
//// `aws_test_support_ffi`; see `test/support/{localstack,docker-compose.yml}`
//// for the container shape.

import aws/config
import aws/services/dynamodb
import gleam/dict
import gleam/option.{None, Some}
import gleeunit/should
import support/localstack

const region: String = "us-east-1"

const table_name: String = "aws-sdk-gleam-e2e"

const partition_key: String = "id"

fn build_client(endpoint: String) -> dynamodb.Client {
  let assert Ok(client) =
    dynamodb.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some(region),
        credentials: Some(localstack.fake_credentials()),
        endpoint_url: Some(endpoint),
      ),
      dynamodb.default_endpoint_params(),
    )
  client
}

fn create_table_input() -> dynamodb.CreateTableInput {
  dynamodb.CreateTableInput(
    attribute_definitions: Some([
      dynamodb.AttributeDefinition(
        attribute_name: Some(partition_key),
        attribute_type: Some(dynamodb.ScalarAttributeTypeS),
      ),
    ]),
    billing_mode: Some(dynamodb.BillingModePayPerRequest),
    deletion_protection_enabled: None,
    global_secondary_indexes: None,
    global_table_settings_replication_mode: None,
    global_table_source_arn: None,
    key_schema: Some([
      dynamodb.KeySchemaElement(
        attribute_name: Some(partition_key),
        key_type: Some(dynamodb.KeyTypeHash),
      ),
    ]),
    local_secondary_indexes: None,
    on_demand_throughput: None,
    provisioned_throughput: None,
    resource_policy: None,
    sse_specification: None,
    stream_specification: None,
    table_class: None,
    table_name: Some(table_name),
    tags: None,
    warm_throughput: None,
  )
}

fn put_item_input(id: String, value: String) -> dynamodb.PutItemInput {
  dynamodb.PutItemInput(
    condition_expression: None,
    conditional_operator: None,
    expected: None,
    expression_attribute_names: None,
    expression_attribute_values: None,
    item: Some(
      dict.from_list([
        #(partition_key, dynamodb.AttributeValueS(id)),
        #("value", dynamodb.AttributeValueS(value)),
      ]),
    ),
    return_consumed_capacity: None,
    return_item_collection_metrics: None,
    return_values: None,
    return_values_on_condition_check_failure: None,
    table_name: Some(table_name),
  )
}

fn get_item_input(id: String) -> dynamodb.GetItemInput {
  dynamodb.GetItemInput(
    attributes_to_get: None,
    consistent_read: None,
    expression_attribute_names: None,
    key: Some(dict.from_list([#(partition_key, dynamodb.AttributeValueS(id))])),
    projection_expression: None,
    return_consumed_capacity: None,
    table_name: Some(table_name),
  )
}

pub fn dynamodb_get_item_round_trip_test() {
  use container <- localstack.when_enabled
  let client = build_client(container.endpoint)
  let assert Ok(_) = dynamodb.create_table(client, create_table_input())
  let assert Ok(_) = dynamodb.put_item(client, put_item_input("k1", "hello"))
  let assert Ok(out) = dynamodb.get_item(client, get_item_input("k1"))
  let assert Some(item) = out.item
  // `value` from the PutItem should round-trip back as
  // `AttributeValueS("hello")`. The String tag is the proof the
  // typed encoder + decoder cycle is wire-compatible with a real
  // DynamoDB API impl (LocalStack is faithful).
  let assert Ok(dynamodb.AttributeValueS(s)) = dict.get(item, "value")
  s |> should.equal("hello")
  dynamodb.shutdown(client)
}
