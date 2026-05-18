//// End-to-end smoke test for the codegen-emitted `paginate_<op>`
//// wrappers, using DynamoDB.ListTables as the representative case
//// (it has a `@paginated` trait with a `String` cursor and a
//// `List(String)` items field — the cleanest possible shape).
////
//// The mock HTTP transport returns two pages of pre-canned
//// `ListTablesOutput` JSON, then asserts the paginator both
//// reduced both pages into the accumulator AND threaded the
//// `ExclusiveStartTableName` cursor between calls. A regression in
//// the codegen-emitted closure (wrong field name, wrong cursor
//// projection, missing fold call) surfaces here.

import aws/credentials
import aws/internal/http_send as aws_http
import aws/services/dynamodb
import gleam/bit_array
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None}
import gleam/string
import gleeunit/should

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

fn unwrap_or(r: Result(a, b), default: a) -> a {
  case r {
    Ok(v) -> v
    Error(_) -> default
  }
}

fn json_bytes(s: String) -> BitArray {
  bit_array.from_string(s)
}

pub fn paginate_list_tables_folds_two_pages_test() {
  let state = process.new_subject()
  process.send(state, 0)
  let send: fn(Request(BitArray)) ->
    Result(response.Response(BitArray), aws_http.HttpError) =
    fn(_req: Request(BitArray)) {
      let n = unwrap_or(process.receive(state, 0), 0)
      process.send(state, n + 1)
      let body = case n {
        0 ->
          "{\"TableNames\":[\"alpha\",\"beta\"],\"LastEvaluatedTableName\":\"beta\"}"
        _ -> "{\"TableNames\":[\"gamma\"]}"
      }
      Ok(response.Response(status: 200, headers: [], body: json_bytes(body)))
    }
  let client =
    dynamodb.new(region: "us-east-1")
    |> dynamodb.with_credentials_provider(static_credentials())
    |> dynamodb.with_http_send(send)

  let result =
    dynamodb.paginate_list_tables(
      client,
      dynamodb.ListTablesInput(
        exclusive_start_table_name: None,
        limit: None,
      ),
      [],
      fn(acc, items) { list.append(acc, items) },
    )

  result |> should.equal(Ok(["alpha", "beta", "gamma"]))
}

pub fn paginate_list_tables_threads_cursor_between_pages_test() {
  // The second request to the mock should carry
  // `ExclusiveStartTableName: "alpha"` — the cursor projected from
  // the first page's `LastEvaluatedTableName`. We capture each
  // request's body and assert the second body mentions the cursor
  // value verbatim.
  let bodies = process.new_subject()
  let counter = process.new_subject()
  process.send(counter, 0)
  let send: fn(Request(BitArray)) ->
    Result(response.Response(BitArray), aws_http.HttpError) =
    fn(req: Request(BitArray)) {
      process.send(bodies, req.body)
      let n = unwrap_or(process.receive(counter, 0), 0)
      process.send(counter, n + 1)
      let body = case n {
        0 ->
          "{\"TableNames\":[\"alpha\"],\"LastEvaluatedTableName\":\"alpha\"}"
        _ -> "{\"TableNames\":[\"beta\"]}"
      }
      Ok(response.Response(status: 200, headers: [], body: json_bytes(body)))
    }
  let client =
    dynamodb.new(region: "us-east-1")
    |> dynamodb.with_credentials_provider(static_credentials())
    |> dynamodb.with_http_send(send)

  let _ =
    dynamodb.paginate_list_tables(
      client,
      dynamodb.ListTablesInput(
        exclusive_start_table_name: None,
        limit: None,
      ),
      0,
      fn(acc, items) { acc + list.length(items) },
    )

  let _first = process.receive(bodies, 0)
  let second = process.receive(bodies, 0)
  case second {
    Ok(b) -> {
      let s = unwrap_or(bit_array.to_string(b), "")
      string.contains(s, "alpha") |> should.be_true
    }
    Error(_) -> should.fail()
  }
}
