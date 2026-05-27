//// Per-protocol smoke tests for codegen-emitted service clients
//// beyond DynamoDB / S3.
////
//// `gleam test` already validates that all ~409 generated modules
//// compile and type-check. This file goes one step further: for
//// each mainline protocol it picks a representative service,
//// constructs a Client, threads in static credentials + a host-
//// capturing HTTP send, and dispatches one list-style operation.
//// The assertion is on the resulting request URL — proving that
//// the embedded endpoint rule set, the `<service>.new` constructor,
//// the per-op request builder, the SigV4 path, and the runtime
//// invoke loop are all wired together end-to-end.
////
//// The smoke is intentionally narrow: one happy-path call per
//// protocol. Deep behavioural coverage lives in the protocol-test
//// corpus (`protocol_tests_test.gleam`, ~800 cases).

import aws/config
import aws/credentials
import aws/internal/http_send as aws_http
import aws/services/cloudwatch_logs
import aws/services/eks
import aws/services/sqs
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None, Some}
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
    Ok(response.Response(status: 400, headers: [], body: <<>>))
  }
}

/// awsJson1_0 smoke: SQS.ListQueues lands on `sqs.us-east-1.amazonaws.com`.
pub fn sqs_list_queues_resolves_to_regional_host_test() {
  let captured = process.new_subject()
  let assert Ok(client) =
    sqs.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(host_capturing_send(captured)),
      ),
      sqs.default_endpoint_params(),
    )

  let _ =
    sqs.list_queues(
      client,
      sqs.ListQueuesRequest(
        max_results: None,
        next_token: None,
        queue_name_prefix: None,
      ),
    )

  process.receive(captured, 0)
  |> should.equal(Ok("sqs.us-east-1.amazonaws.com"))
}

/// awsJson1_1 smoke: CloudWatchLogs.DescribeLogGroups lands on
/// `logs.us-east-1.amazonaws.com`.
pub fn cloudwatch_logs_describe_log_groups_resolves_to_regional_host_test() {
  let captured = process.new_subject()
  let assert Ok(client) =
    cloudwatch_logs.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(host_capturing_send(captured)),
      ),
      cloudwatch_logs.default_endpoint_params(),
    )

  let _ =
    cloudwatch_logs.describe_log_groups(
      client,
      cloudwatch_logs.DescribeLogGroupsRequest(
        account_identifiers: None,
        include_linked_accounts: None,
        limit: None,
        log_group_class: None,
        log_group_identifiers: None,
        log_group_name_pattern: None,
        log_group_name_prefix: None,
        next_token: None,
      ),
    )

  process.receive(captured, 0)
  |> should.equal(Ok("logs.us-east-1.amazonaws.com"))
}

/// restJson1 smoke: EKS.ListClusters lands on
/// `eks.us-east-1.amazonaws.com`. EKS exercises the rest-protocol
/// build path (URI template + headers + body) end-to-end.
pub fn eks_list_clusters_resolves_to_regional_host_test() {
  let captured = process.new_subject()
  let assert Ok(client) =
    eks.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some("us-east-1"),
        credentials: Some(static_credentials()),
        http_send: Some(host_capturing_send(captured)),
      ),
      eks.default_endpoint_params(),
    )

  let _ =
    eks.list_clusters(
      client,
      eks.ListClustersRequest(
        include: None,
        max_results: None,
        next_token: None,
      ),
    )

  process.receive(captured, 0)
  |> should.equal(Ok("eks.us-east-1.amazonaws.com"))
}
