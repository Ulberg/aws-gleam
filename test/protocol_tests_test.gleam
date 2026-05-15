//// Entry point for Layer 2 (Smithy protocol-test) conformance.
////
//// Each `*_protocol_test` function runs one protocol's full case
//// corpus through the registry. With no dispatchers registered yet,
//// every case lands in `skip_no_dispatcher`. The suite passes as long
//// as no case explicitly FAILS — skipped cases are visible in the
//// report and shrink as the emitter learns more shapes.
////
//// `skip_allow_list` deliberately defaults to empty. Smithy and
//// aws-sdk-rust do not document protocol-test cases as "skippable",
//// so we don't either. A case either passes against our generated
//// code, or it fails loudly. `appliesTo: "server"` is the only
//// documented exemption and is handled inside the runner.

import gleam/io
import gleeunit/should
import protocol_tests/awsjson10_dispatchers
import protocol_tests/awsjson11_dispatchers
import protocol_tests/awsquery_dispatchers
import protocol_tests/dispatch
import protocol_tests/ec2query_dispatchers
import protocol_tests/restjson1_dispatchers
import protocol_tests/restxml_dispatchers
import protocol_tests/runner

pub fn awsjson10_protocol_test() {
  run_with(
    "awsJson1_0",
    "test/fixtures/protocol-tests/awsJson1_0.json",
    awsjson10_dispatchers.register_all(dispatch.new()),
  )
}

pub fn awsjson11_protocol_test() {
  run_with(
    "awsJson1_1",
    "test/fixtures/protocol-tests/awsJson1_1.json",
    awsjson11_dispatchers.register_all(dispatch.new()),
  )
}

pub fn restjson1_protocol_test() {
  run_with(
    "restJson1",
    "test/fixtures/protocol-tests/restJson1.json",
    restjson1_dispatchers.register_all(dispatch.new()),
  )
}

pub fn restxml_protocol_test() {
  run_with(
    "restXml",
    "test/fixtures/protocol-tests/restXml.json",
    restxml_dispatchers.register_all(dispatch.new()),
  )
}

pub fn restxml_with_namespace_protocol_test() {
  run(
    "restXmlWithNamespace",
    "test/fixtures/protocol-tests/restXmlWithNamespace.json",
  )
}

pub fn awsquery_protocol_test() {
  run_with(
    "awsQuery",
    "test/fixtures/protocol-tests/awsQuery.json",
    awsquery_dispatchers.register_all(dispatch.new()),
  )
}

pub fn ec2query_protocol_test() {
  run_with(
    "ec2Query",
    "test/fixtures/protocol-tests/ec2Query.json",
    ec2query_dispatchers.register_all(dispatch.new()),
  )
}

pub fn rpcv2cbor_protocol_test() {
  run("rpcv2Cbor", "test/fixtures/protocol-tests/rpcv2Cbor.json")
}

fn run(name: String, path: String) {
  run_with(name, path, dispatch.new())
}

fn run_with(name: String, path: String, registry: dispatch.Registry) {
  let report =
    runner.run(runner.Config(
      protocol_name: name,
      fixture_path: path,
      registry: registry,
      skip_allow_list: runner.empty_allow_list(),
    ))
  runner.print_report(report)
  case report.fail {
    0 -> Nil
    _ -> {
      io.println("  ! " <> name <> " had failing cases (see above)")
      should.fail()
    }
  }
}
