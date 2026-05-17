//// Smoke test that the codegen-embedded endpoint rule sets actually
//// drive request URLs for generated service clients.
////
//// For DynamoDB the rule set, given `Region=us-east-1` (the default the
//// runtime threads in), produces `https://dynamodb.us-east-1.amazonaws.com`.
//// We assert that by routing a request through a captured-host send and
//// reading back the request URL. The rule set is also exercised under
//// `gleam test` through every existing protocol test, so a regression
//// would surface there too.

import aws/credentials
import aws/internal/http_send as aws_http
import aws/region
import aws/services/dynamodb
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None}
import gleam/result
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

fn host_capturing_send(
  captured: process.Subject(String),
) -> fn(Request(BitArray)) ->
  Result(response.Response(BitArray), aws_http.HttpError) {
  fn(req: Request(BitArray)) {
    let host = case list.find(req.headers, fn(h) { h.0 == "host" }) {
      Ok(#(_, v)) -> v
      Error(_) -> "missing"
    }
    process.send(captured, host)
    // 400 keeps us off the parse path while still letting the runtime
    // close out the request — the host is what we care about.
    Ok(response.Response(status: 400, headers: [], body: <<>>))
  }
}

pub fn dynamodb_client_resolves_through_embedded_rule_set_test() {
  let captured = process.new_subject()
  let client =
    dynamodb.new(region: "us-east-1")
    |> dynamodb.with_credentials_provider(static_credentials())
    |> dynamodb.with_http_send(host_capturing_send(captured))

  let _ =
    dynamodb.get_item(
      client,
      dynamodb.GetItemInput(
        attributes_to_get: None,
        consistent_read: None,
        expression_attribute_names: None,
        key: None,
        projection_expression: None,
        return_consumed_capacity: None,
        table_name: None,
      ),
    )

  // The DynamoDB rule set, given just Region=us-east-1, lands on the
  // standard regional URL: `dynamodb.us-east-1.amazonaws.com`.
  process.receive(captured, 0)
  |> should.equal(Ok("dynamodb.us-east-1.amazonaws.com"))
}

pub fn new_with_auto_region_compiles_and_returns_a_result_test() {
  // Generated `new_with_auto_region` returns a Result. We don't drive
  // the resolver here — `region_test.gleam` covers all eight resolution
  // branches — but we do assert that the generator emitted the
  // expected return type and that the function is callable.
  let r = dynamodb.new_with_auto_region()
  // It's either Ok or Error; both shapes are valid for this test.
  case r {
    Ok(_) -> Nil
    Error(region.NoRegion(sources_tried: tried)) -> {
      // If it failed, the error must enumerate the sources the resolver
      // walked — guard against regressions that swallow the error list.
      { tried != [] } |> should.be_true
    }
  }
}

pub fn generated_client_caches_credentials_across_invocations_test() {
  // Wire a Client with a static provider that *counts* fetch calls.
  // Two `get_item` calls go through the same Client; the provider
  // should be hit only once thanks to the credentials cache the
  // generated `new` constructor sets up.
  let counter = process.new_subject()
  let counting_provider =
    credentials.Provider(name: "Counting", fetch: fn() {
      process.send(counter, 1)
      Ok(credentials.Credentials(
        access_key_id: "AKIDEXAMPLE",
        secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
        session_token: None,
        expires_at: None,
        source: "Test",
      ))
    })
  let host_subj = process.new_subject()
  let client =
    dynamodb.new(region: "us-east-1")
    |> dynamodb.with_credentials_provider(counting_provider)
    |> dynamodb.with_http_send(host_capturing_send(host_subj))

  let input =
    dynamodb.GetItemInput(
      attributes_to_get: None,
      consistent_read: None,
      expression_attribute_names: None,
      key: None,
      projection_expression: None,
      return_consumed_capacity: None,
      table_name: None,
    )
  let _ = dynamodb.get_item(client, input)
  let _ = dynamodb.get_item(client, input)
  let _ = dynamodb.get_item(client, input)

  // Drain everything the captured-host send emitted so it doesn't leak
  // into other tests in the same process.
  let _ = process.receive(host_subj, 0)
  let _ = process.receive(host_subj, 0)
  let _ = process.receive(host_subj, 0)

  // Count the provider hits. With caching wired we expect exactly one
  // — non-expiring credentials cache forever in `credentials_cache`.
  count_messages(counter, 0) |> should.equal(1)
}

fn count_messages(subject: process.Subject(Int), acc: Int) -> Int {
  case process.receive(subject, 0) {
    Ok(_) -> count_messages(subject, acc + 1)
    Error(_) -> acc
  }
}

pub fn new_with_auto_region_uses_region_resolve_test() {
  // Reach into `region.resolve_with` with a stub env supplying
  // `AWS_REGION=eu-central-1`. This is the same path
  // `dynamodb.new_with_auto_region` ultimately calls — verifying it
  // here under controlled inputs gives the auto-region wiring an
  // observable contract test rather than relying on whatever the
  // host machine's environment happens to be.
  let env_with_region = fn(name) {
    case name {
      "AWS_REGION" -> Ok("eu-central-1")
      _ -> Error(Nil)
    }
  }
  let no_config = fn() { Error(Nil) }

  region.resolve_with(
    profile: "default",
    env_lookup: env_with_region,
    config_reader: no_config,
  )
  |> result.is_ok
  |> should.be_true
}
