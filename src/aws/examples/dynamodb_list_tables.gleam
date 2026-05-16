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
//// Set `AWS_REGION` (and credentials, via env or `~/.aws/credentials`
//// or `aws sso login`) before invoking. Or edit the `region` constant
//// below.

import aws/credentials
import aws/internal/client/awsjson as awsjson_client
import aws/internal/http_send
import aws/services/dynamodb
import gleam/int
import gleam/io
import gleam/list
import gleam/option

const region: String = "us-east-1"

const profile: String = "default"

pub fn main() {
  let send = http_send.default_send
  let provider = credentials.default_chain(send: send, profile: profile)
  let client = dynamodb.new(provider: provider, region: region)

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
      io.println("error: " <> describe_client_error(err))
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

fn describe_client_error(err: awsjson_client.ClientError) -> String {
  case err {
    awsjson_client.CredentialsError(_) ->
      "credentials provider chain failed — check env vars or ~/.aws/credentials"
    awsjson_client.TransportError(_) ->
      "transport error — TLS/DNS/timeout on the HTTP send"
    awsjson_client.DecodeError(reason: r) -> "could not decode response: " <> r
    awsjson_client.ServiceError(status: s, error_type: t, ..) ->
      "service returned HTTP "
      <> int.to_string(s)
      <> " ("
      <> t
      <> ") — common causes: missing IAM permission, wrong region"
  }
}
