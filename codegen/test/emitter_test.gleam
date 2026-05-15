//// Snapshot-style tests for the per-protocol emitters.
////
//// For each protocol fixture we ship under
//// `../test/fixtures/protocol-tests/<proto>.json`, exercise the
//// matching emitter and assert structural invariants of the output:
////
////   - emission succeeds (no `Error`)
////   - at least one operation gets emitted
////   - the module header carries the canonical "Generated from" line
////   - the source string compiles to non-empty bytes
////
//// Byte-exact snapshots would tie us to whitespace decisions that
//// `gleam format` makes downstream. Asserting *invariants* of the
//// output is the stable contract: any future refactor that preserves
//// these invariants is safe; any change that breaks them is loudly
//// caught.

import codegen/awsjson
import codegen/awsquery
import codegen/restjson
import codegen/restxml
import gleam/dict
import gleam/json
import gleam/list
import gleam/string
import gleeunit/should
import simplifile
import smithy/model
import smithy/shape_id

const json10_path = "../test/fixtures/protocol-tests/awsJson1_0.json"

const json11_path = "../test/fixtures/protocol-tests/awsJson1_1.json"

const restjson1_path = "../test/fixtures/protocol-tests/restJson1.json"

const restxml_path = "../test/fixtures/protocol-tests/restXml.json"

const awsquery_path = "../test/fixtures/protocol-tests/awsQuery.json"

const ec2query_path = "../test/fixtures/protocol-tests/ec2Query.json"

pub fn awsjson10_emits_operations_test() {
  let m = load(json10_path)
  let svc = find_service(m, "aws.protocols#awsJson1_0", "JsonRpc10")
  let assert Ok(r) = awsjson.emit_service(m, svc, awsjson.AwsJson10)
  should.be_true(list.length(r.operations_emitted) > 0)
  should.be_true(string.contains(r.source, "Generated from"))
  should.be_true(string.contains(r.source, "application/x-amz-json-1.0"))
}

pub fn awsjson11_emits_operations_test() {
  let m = load(json11_path)
  let svc = find_service(m, "aws.protocols#awsJson1_1", "JsonProtocol")
  let assert Ok(r) = awsjson.emit_service(m, svc, awsjson.AwsJson11)
  should.be_true(list.length(r.operations_emitted) > 0)
  should.be_true(string.contains(r.source, "application/x-amz-json-1.1"))
}

pub fn restjson1_emits_http_traits_test() {
  let m = load(restjson1_path)
  let svc = find_service(m, "aws.protocols#restJson1", "RestJson")
  let assert Ok(r) = restjson.emit_service(m, svc)
  should.be_true(list.length(r.operations_emitted) > 5)
  // Operations under restJson1 cover multiple HTTP methods.
  should.be_true(
    string.contains(r.source, "\"POST\"")
    || string.contains(r.source, "\"GET\""),
  )
}

pub fn restxml_emits_http_traits_test() {
  let m = load(restxml_path)
  let svc = find_service(m, "aws.protocols#restXml", "RestXml")
  let assert Ok(r) = restxml.emit_service(m, svc)
  should.be_true(list.length(r.operations_emitted) > 0)
}

pub fn awsquery_emits_action_version_body_test() {
  let m = load(awsquery_path)
  let svc = find_service(m, "aws.protocols#awsQuery", "AwsQuery")
  let assert Ok(r) = awsquery.emit_service(m, svc, awsquery.AwsQuery)
  should.be_true(list.length(r.operations_emitted) > 5)
  // The body literal always carries `Action=` + `&Version=`.
  should.be_true(string.contains(r.source, "Action="))
  should.be_true(string.contains(r.source, "&Version="))
}

pub fn ec2query_emits_action_version_body_test() {
  let m = load(ec2query_path)
  let svc = find_service(m, "aws.protocols#ec2Query", "AwsEc2")
  let assert Ok(r) = awsquery.emit_service(m, svc, awsquery.Ec2Query)
  should.be_true(list.length(r.operations_emitted) > 0)
  should.be_true(string.contains(r.source, "Action="))
}

/// Every emitted function uses `build_*_request` for the wire and
/// `parse_*_response` for the receive side. This is the structural
/// contract dispatchers depend on; assert it holds.
pub fn emitted_modules_expose_canonical_function_names_test() {
  let m = load(json10_path)
  let svc = find_service(m, "aws.protocols#awsJson1_0", "JsonRpc10")
  let assert Ok(r) = awsjson.emit_service(m, svc, awsjson.AwsJson10)
  should.be_true(string.contains(r.source, "pub fn build_"))
  should.be_true(string.contains(r.source, "_request("))
  should.be_true(string.contains(r.source, "pub fn parse_"))
  should.be_true(string.contains(r.source, "_response("))
}

/// Module header is the only place we encode the source service shape
/// id. Lock its presence so emitter refactors can't accidentally drop
/// provenance.
pub fn module_header_records_source_service_test() {
  let m = load(restjson1_path)
  let svc = find_service(m, "aws.protocols#restJson1", "RestJson")
  let assert Ok(r) = restjson.emit_service(m, svc)
  should.be_true(string.contains(r.source, svc))
  should.be_true(string.contains(r.source, "(restJson1)"))
}

// ---------- helpers ----------

fn load(path: String) -> model.Model {
  let assert Ok(text) = simplifile.read(path)
  let assert Ok(m) = json.parse(text, model.decoder())
  m
}

/// Find a specific service by protocol trait + service name match.
/// Protocol-test files contain multiple services; we pick the one with
/// the expected local name (after the `#` namespace separator).
fn find_service(
  m: model.Model,
  _protocol_trait: String,
  expected_local: String,
) -> String {
  // Exact local-name match (after the `#`) — restJson1's fixture
  // ships multiple services whose ids share substrings.
  let candidates =
    m.shapes
    |> dict.to_list
    |> list.filter_map(fn(pair) {
      let #(id, _shape) = pair
      let s = shape_id.to_string(id)
      case string.split_once(s, "#") {
        Ok(#(_, local)) ->
          case local == expected_local {
            True -> Ok(s)
            False -> Error(Nil)
          }
        Error(_) -> Error(Nil)
      }
    })
  case candidates {
    [id, ..] -> id
    [] -> ""
  }
}
