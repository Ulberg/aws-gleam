//// Entry point for Layer 2 (Smithy protocol-test) conformance.
////
//// Each `*_protocol_test` function runs one protocol's full case
//// corpus through the registry. With no dispatchers registered yet,
//// every case lands in `skip_no_dispatcher`. The suite passes as long
//// as no case explicitly FAILS — skipped cases are visible in the
//// report and shrink as M5.3 emits more code.
////
//// To watch progress: `gleam test` shows per-protocol counts. Drop the
//// allow-list cap (in this file) for each protocol as the emitter
//// supports more cases.

import gleam/dict.{type Dict}
import gleam/io
import gleeunit/should
import protocol_tests/awsjson10_dispatchers
import protocol_tests/awsjson11_dispatchers
import protocol_tests/dispatch
import protocol_tests/runner

pub fn awsjson10_protocol_test() {
  run_with(
    "awsJson1_0",
    "test/fixtures/protocol-tests/awsJson1_0.json",
    awsjson10_dispatchers.register_all(dispatch.new()),
    awsjson10_allow_list(),
  )
}

/// Explicit allow-list of cases the awsJson1_0 emitter is known not to
/// handle yet. Each entry has a `<case-id>: <why>` shape so a future
/// reader can decide whether to fix or keep skipping.
fn awsjson10_allow_list() -> Dict(String, String) {
  dict.from_list([
    #(
      "AwsJson10HostWithPath",
      "user-supplied endpoint path prefix is a runtime concern; "
        <> "request builder correctly emits operation path `/`",
    ),
    #(
      "AwsJson10EndpointTrait",
      "smithy.api#endpoint hostPrefix substitution not yet supported",
    ),
  ])
}

fn awsjson11_allow_list() -> Dict(String, String) {
  dict.from_list([
    #(
      "AwsJson11HostWithPath",
      "user-supplied endpoint path prefix is a runtime concern",
    ),
    #(
      "AwsJson11EndpointTrait",
      "smithy.api#endpoint hostPrefix substitution not yet supported",
    ),
  ])
}

pub fn awsjson11_protocol_test() {
  run_with(
    "awsJson1_1",
    "test/fixtures/protocol-tests/awsJson1_1.json",
    awsjson11_dispatchers.register_all(dispatch.new()),
    awsjson11_allow_list(),
  )
}

pub fn restjson1_protocol_test() {
  run("restJson1", "test/fixtures/protocol-tests/restJson1.json")
}

pub fn restxml_protocol_test() {
  run("restXml", "test/fixtures/protocol-tests/restXml.json")
}

pub fn restxml_with_namespace_protocol_test() {
  run(
    "restXmlWithNamespace",
    "test/fixtures/protocol-tests/restXmlWithNamespace.json",
  )
}

pub fn awsquery_protocol_test() {
  run("awsQuery", "test/fixtures/protocol-tests/awsQuery.json")
}

pub fn ec2query_protocol_test() {
  run("ec2Query", "test/fixtures/protocol-tests/ec2Query.json")
}

pub fn rpcv2cbor_protocol_test() {
  run("rpcv2Cbor", "test/fixtures/protocol-tests/rpcv2Cbor.json")
}

fn run(name: String, path: String) {
  run_with(name, path, dispatch.new(), runner.empty_allow_list())
}

fn run_with(
  name: String,
  path: String,
  registry: dispatch.Registry,
  allow: Dict(String, String),
) {
  let report =
    runner.run(runner.Config(
      protocol_name: name,
      fixture_path: path,
      registry: registry,
      skip_allow_list: allow,
    ))
  runner.print_report(report)
  // The suite fails only on actual FAIL outcomes — skips don't fail the
  // build. Counts are visible in stdout.
  case report.fail {
    0 -> Nil
    _ -> {
      io.println("  ! " <> name <> " had failing cases (see above)")
      should.fail()
    }
  }
}
