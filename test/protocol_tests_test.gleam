//// Entry point for Layer 2 (Smithy protocol-test) conformance.
////
//// Per-protocol gleeunit test that runs the full case corpus through
//// the dispatcher registry and asserts `fail` count is zero.
////
//// `appliesTo: "server"` is the only Smithy-documented skip and is
//// handled inside the runner itself. No other skip lists.

import gleam/dict.{type Dict}
import gleam/io
import gleeunit/should
import protocol_tests/awsjson10_dispatchers
import protocol_tests/awsjson11_dispatchers
import protocol_tests/awsquery_dispatchers
import protocol_tests/dispatch
import protocol_tests/ec2query_dispatchers
import protocol_tests/restjson1_dispatchers
import protocol_tests/restxml_dispatchers
import protocol_tests/restxml_with_namespace_dispatchers
import protocol_tests/rpcv2cbor_dispatchers
import protocol_tests/runner

/// Test cases the runner explicitly skips, keyed by case ID with a
/// short reason. Reserved for cases whose Smithy shape pulls the
/// SDK into an infinite-recursion decoder path we haven't unblocked
/// yet — every entry here is a known codec gap, not a wire-format
/// disagreement.
fn skip_allow_list() -> Dict(String, String) {
  dict.new()
  // S3 path-style addressing (`vendorParams.scopedConfig.client.s3.
  // addressing_style: 'path'`). The SDK now supports path-style at
  // runtime via the codegen-emitted endpoint params dict (the
  // `@contextParam` Bucket binding flows into `endpoints.resolve`)
  // combined with `client.with_endpoint_param(client, "ForcePathStyle",
  // endpoints.BoolVal(True))`. What's missing is the protocol-test
  // runner side: dispatchers only call `build_*_request` (URI
  // template substitution), they don't invoke the endpoint resolver,
  // so the expected `/mybucket` path the rule set would prepend
  // never lands in `BuiltRequest.uri`. Closing this case is a runner
  // change (run the resolver, join with the URI template) — out of
  // scope for the HACK.md sweep.
  |> dict.insert(
    "S3PathAddressing",
    "SDK supports path-style via endpoint params; runner needs to invoke the endpoint resolver to assemble the full URL before assertion",
  )
}

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
  run_with(
    "restXmlWithNamespace",
    "test/fixtures/protocol-tests/restXmlWithNamespace.json",
    restxml_with_namespace_dispatchers.register_all(dispatch.new()),
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
  run_with(
    "rpcv2Cbor",
    "test/fixtures/protocol-tests/rpcv2Cbor.json",
    rpcv2cbor_dispatchers.register_all(dispatch.new()),
  )
}

fn run_with(name: String, path: String, registry: dispatch.Registry) {
  let report =
    runner.run(runner.Config(
      protocol_name: name,
      fixture_path: path,
      registry: registry,
      skip_allow_list: skip_allow_list(),
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
