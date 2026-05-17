//// End-to-end smoke test of the generated DynamoDB client.
////
//// Calls `dynamodb.list_tables(client, input)` and prints the result.
//// Proves the codegen pipeline ships a usable typed API:
////
////   1. Credentials resolved through the default chain.
////   2. SigV4 signing via the generated client → shared awsJson
////      runtime.
////   3. HTTP send via gleam_httpc.
////   4. Response parsed into a typed `ListTablesOutput`.
////
//// ## How to run
////
////   gleam run -m aws/examples/dynamodb_list_tables
////
//// Set credentials via env or `~/.aws/credentials` (or `aws sso
//// login`) before invoking. Edit `region` below if needed.

import aws/services/dynamodb
import gleam/int
import gleam/io
import gleam/list
import gleam/option

const region: String = "us-east-1"

pub fn main() {
  let client = dynamodb.new(region: region)

  let input =
    dynamodb.ListTablesInput(
      exclusive_start_table_name: option.None,
      limit: option.None,
    )

  case dynamodb.list_tables(client, input) {
    Ok(out) -> {
      io.println("ok: ListTables returned " <> tables_summary(out))
    }
    Error(err) -> {
      io.println("error: " <> describe_error(err))
    }
  }
}

fn tables_summary(out: dynamodb.ListTablesOutput) -> String {
  case out.table_names {
    option.None -> "no tables field set"
    option.Some(names) -> {
      let count = list.length(names)
      int.to_string(count) <> " table(s)"
    }
  }
}

/// Surface the typed `ListTablesError` produced by the generated
/// client. ServiceError-style variants (InternalServerError etc.)
/// carry their own struct; Transport / Unknown carry plain strings.
fn describe_error(err: dynamodb.ListTablesError) -> String {
  case err {
    dynamodb.ListTablesErrorTransport(reason: r) -> "transport: " <> r
    dynamodb.ListTablesErrorInternalServerError(..) ->
      "service: InternalServerError"
    dynamodb.ListTablesErrorInvalidEndpointException(..) ->
      "service: InvalidEndpointException"
    dynamodb.ListTablesErrorUnknown(error_type: t, status: s, ..) ->
      "service: HTTP " <> int.to_string(s) <> " (" <> t <> ")"
  }
}
