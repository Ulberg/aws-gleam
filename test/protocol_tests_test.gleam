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

import gleam/io
import gleeunit/should
import protocol_tests/dispatch
import protocol_tests/runner

pub fn awsjson10_protocol_test() {
  run("awsJson1_0", "test/fixtures/protocol-tests/awsJson1_0.json")
}

pub fn awsjson11_protocol_test() {
  run("awsJson1_1", "test/fixtures/protocol-tests/awsJson1_1.json")
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
  let report =
    runner.run(runner.Config(
      protocol_name: name,
      fixture_path: path,
      registry: dispatch.new(),
      skip_allow_list: runner.empty_allow_list(),
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
