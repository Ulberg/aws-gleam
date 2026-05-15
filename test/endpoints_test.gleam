//// Tests for the Smithy endpoint rule set evaluator.

import aws/endpoints.{
  type Endpoint, type ResolveError, BoolVal, Endpoint, NoMatch,
  RequiredParameterMissing, RuleError, StringVal,
}
import gleam/dict
import gleeunit/should

fn parse_or_panic(json_text: String) -> endpoints.RuleSet {
  let assert Ok(rs) = endpoints.parse_rule_set(json_text)
  rs
}

fn resolve_or_error(
  json_text: String,
  strings: List(#(String, String)),
  bools: List(#(String, Bool)),
) -> Result(Endpoint, ResolveError) {
  let rs = parse_or_panic(json_text)
  endpoints.resolve(rs, endpoints.params_from(strings: strings, bools: bools))
}

// ---------- parser ----------

pub fn parses_minimal_rule_set_test() {
  let json_text =
    "{
      \"parameters\": {
        \"Region\": { \"type\": \"String\", \"required\": true }
      },
      \"rules\": [
        {
          \"conditions\": [],
          \"endpoint\": { \"url\": \"https://example.test/\" },
          \"type\": \"endpoint\"
        }
      ]
    }"
  let _rs = parse_or_panic(json_text)
  Nil
}

pub fn rejects_invalid_json_test() {
  endpoints.parse_rule_set("not json")
  |> should.be_error
}

// ---------- evaluation: simple template ----------

pub fn template_substitutes_a_string_parameter_test() {
  let rs =
    "{
      \"parameters\": { \"Region\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [],
          \"endpoint\": { \"url\": \"https://example.{Region}.amazonaws.com\" },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [#("Region", "eu-north-1")], [])
  |> should.equal(
    Ok(Endpoint(
      url: "https://example.eu-north-1.amazonaws.com",
      headers: dict.new(),
    )),
  )
}

// ---------- conditions ----------

pub fn boolean_equals_condition_test() {
  let rs =
    "{
      \"parameters\": {
        \"UseFips\": { \"type\": \"Boolean\", \"required\": true },
        \"Region\": { \"type\": \"String\", \"required\": true }
      },
      \"rules\": [
        { \"conditions\": [
            { \"fn\": \"booleanEquals\",
              \"argv\": [ {\"ref\": \"UseFips\"}, true ] }
          ],
          \"endpoint\": { \"url\": \"https://{Region}-fips.example.test\" },
          \"type\": \"endpoint\" },
        { \"conditions\": [],
          \"endpoint\": { \"url\": \"https://{Region}.example.test\" },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [#("Region", "us-east-1")], [#("UseFips", True)])
  |> should.equal(
    Ok(Endpoint(url: "https://us-east-1-fips.example.test", headers: dict.new())),
  )
  resolve_or_error(rs, [#("Region", "us-east-1")], [#("UseFips", False)])
  |> should.equal(
    Ok(Endpoint(url: "https://us-east-1.example.test", headers: dict.new())),
  )
}

pub fn is_set_condition_test() {
  let rs =
    "{
      \"parameters\": {
        \"Endpoint\": { \"type\": \"String\" },
        \"Region\": { \"type\": \"String\", \"required\": true }
      },
      \"rules\": [
        { \"conditions\": [{ \"fn\": \"isSet\", \"argv\": [{\"ref\": \"Endpoint\"}] }],
          \"endpoint\": { \"url\": \"{Endpoint}\" },
          \"type\": \"endpoint\" },
        { \"conditions\": [],
          \"endpoint\": { \"url\": \"https://default.{Region}.test\" },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(
    rs,
    [#("Region", "x"), #("Endpoint", "https://custom.test")],
    [],
  )
  |> should.equal(Ok(Endpoint(url: "https://custom.test", headers: dict.new())))
  resolve_or_error(rs, [#("Region", "us-east-1")], [])
  |> should.equal(
    Ok(Endpoint(url: "https://default.us-east-1.test", headers: dict.new())),
  )
}

pub fn error_rule_surfaces_message_test() {
  let rs =
    "{
      \"parameters\": {},
      \"rules\": [
        { \"conditions\": [],
          \"error\": \"explicit configuration error\",
          \"type\": \"error\" }
      ]
    }"
  let assert Error(RuleError(message: msg)) = resolve_or_error(rs, [], [])
  msg |> should.equal("explicit configuration error")
}

pub fn required_parameter_missing_test() {
  let rs =
    "{
      \"parameters\": { \"Region\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [],
          \"endpoint\": { \"url\": \"https://{Region}.test\" },
          \"type\": \"endpoint\" }
      ]
    }"
  let assert Error(RequiredParameterMissing(name: n)) =
    resolve_or_error(rs, [], [])
  n |> should.equal("Region")
}

pub fn default_value_filled_when_param_absent_test() {
  let rs =
    "{
      \"parameters\": {
        \"UseFips\": { \"type\": \"Boolean\", \"default\": false }
      },
      \"rules\": [
        { \"conditions\": [{
            \"fn\": \"booleanEquals\",
            \"argv\": [ {\"ref\": \"UseFips\"}, false ]
          }],
          \"endpoint\": { \"url\": \"https://default.test\" },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [], [])
  |> should.equal(
    Ok(Endpoint(url: "https://default.test", headers: dict.new())),
  )
}

// ---------- aws.partition + template field access ----------

pub fn aws_partition_provides_dns_suffix_test() {
  let rs =
    "{
      \"parameters\": { \"Region\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [
            { \"fn\": \"aws.partition\",
              \"argv\": [{\"ref\": \"Region\"}],
              \"assign\": \"P\" }
          ],
          \"endpoint\": {
            \"url\": \"https://svc.{Region}.{P#dnsSuffix}\"
          },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [#("Region", "us-east-1")], [])
  |> should.equal(
    Ok(Endpoint(url: "https://svc.us-east-1.amazonaws.com", headers: dict.new())),
  )
  resolve_or_error(rs, [#("Region", "cn-north-1")], [])
  |> should.equal(
    Ok(Endpoint(
      url: "https://svc.cn-north-1.amazonaws.com.cn",
      headers: dict.new(),
    )),
  )
}

// ---------- built-in functions ----------

pub fn substring_basic_test() {
  let rs =
    "{
      \"parameters\": { \"Input\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [
            { \"fn\": \"substring\",
              \"argv\": [ {\"ref\": \"Input\"}, 0, 3, false ],
              \"assign\": \"Prefix\" }
          ],
          \"endpoint\": { \"url\": \"https://{Prefix}.test\" },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [#("Input", "hello-world")], [])
  |> should.equal(Ok(Endpoint(url: "https://hel.test", headers: dict.new())))
}

pub fn uri_encode_test() {
  let rs =
    "{
      \"parameters\": { \"Value\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [
            { \"fn\": \"uriEncode\", \"argv\": [{\"ref\": \"Value\"}], \"assign\": \"Encoded\" }
          ],
          \"endpoint\": { \"url\": \"https://example.test/{Encoded}\" },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [#("Value", "hello world/x")], [])
  |> should.equal(
    Ok(Endpoint(
      url: "https://example.test/hello%20world%2Fx",
      headers: dict.new(),
    )),
  )
}

pub fn parse_url_extracts_scheme_authority_path_test() {
  let rs =
    "{
      \"parameters\": { \"Url\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [
            { \"fn\": \"parseURL\", \"argv\": [{\"ref\": \"Url\"}], \"assign\": \"P\" }
          ],
          \"endpoint\": {
            \"url\": \"{P#scheme}://{P#authority}{P#path}\"
          },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [#("Url", "https://example.test/p?q=1")], [])
  |> should.equal(
    Ok(Endpoint(url: "https://example.test/p", headers: dict.new())),
  )
}

pub fn parse_arn_extracts_account_and_region_test() {
  let rs =
    "{
      \"parameters\": { \"Arn\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [
            { \"fn\": \"aws.parseArn\", \"argv\": [{\"ref\": \"Arn\"}], \"assign\": \"A\" }
          ],
          \"endpoint\": {
            \"url\": \"https://{A#accountId}.{A#service}.{A#region}.test\"
          },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(
    rs,
    [#("Arn", "arn:aws:s3:us-east-1:123456789012:bucket-name")],
    [],
  )
  |> should.equal(
    Ok(Endpoint(
      url: "https://123456789012.s3.us-east-1.test",
      headers: dict.new(),
    )),
  )
}

pub fn is_virtual_hostable_s3_bucket_test() {
  let rs =
    "{
      \"parameters\": { \"Bucket\": { \"type\": \"String\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [
            { \"fn\": \"aws.isVirtualHostableS3Bucket\",
              \"argv\": [{\"ref\": \"Bucket\"}, false] }
          ],
          \"endpoint\": { \"url\": \"virtual\" },
          \"type\": \"endpoint\" },
        { \"conditions\": [],
          \"endpoint\": { \"url\": \"path\" },
          \"type\": \"endpoint\" }
      ]
    }"
  let assert Ok(Endpoint(url: u, ..)) =
    resolve_or_error(rs, [#("Bucket", "demo-bucket-eu-north-1-an")], [])
  u |> should.equal("virtual")
  // Uppercase + underscore -> invalid.
  let assert Ok(Endpoint(url: u, ..)) =
    resolve_or_error(rs, [#("Bucket", "Has_Underscore")], [])
  u |> should.equal("path")
  // Too short
  let assert Ok(Endpoint(url: u, ..)) =
    resolve_or_error(rs, [#("Bucket", "ab")], [])
  u |> should.equal("path")
}

// ---------- tree rule + no-match fallthrough ----------

pub fn tree_rule_evaluates_nested_rules_test() {
  let rs =
    "{
      \"parameters\": {
        \"UseFips\": { \"type\": \"Boolean\", \"required\": true }
      },
      \"rules\": [
        { \"conditions\": [{
            \"fn\": \"booleanEquals\",
            \"argv\": [{\"ref\": \"UseFips\"}, true]
          }],
          \"rules\": [
            { \"conditions\": [],
              \"endpoint\": { \"url\": \"fips\" },
              \"type\": \"endpoint\" }
          ],
          \"type\": \"tree\" },
        { \"conditions\": [],
          \"endpoint\": { \"url\": \"standard\" },
          \"type\": \"endpoint\" }
      ]
    }"
  let assert Ok(Endpoint(url: u, ..)) =
    resolve_or_error(rs, [], [#("UseFips", True)])
  u |> should.equal("fips")
  let assert Ok(Endpoint(url: u, ..)) =
    resolve_or_error(rs, [], [#("UseFips", False)])
  u |> should.equal("standard")
}

pub fn no_match_when_no_rule_fires_test() {
  let rs =
    "{
      \"parameters\": { \"X\": { \"type\": \"Boolean\", \"required\": true } },
      \"rules\": [
        { \"conditions\": [{
            \"fn\": \"booleanEquals\",
            \"argv\": [{\"ref\": \"X\"}, true]
          }],
          \"endpoint\": { \"url\": \"only-on-true\" },
          \"type\": \"endpoint\" }
      ]
    }"
  resolve_or_error(rs, [], [#("X", False)])
  |> should.equal(Error(NoMatch))
}

// ---------- direct value sanity ----------

pub fn params_from_constructs_a_dict_test() {
  let params =
    endpoints.params_from(strings: [#("a", "1")], bools: [#("b", True)])
  dict.get(params, "a") |> should.equal(Ok(StringVal("1")))
  dict.get(params, "b") |> should.equal(Ok(BoolVal(True)))
  dict.get(params, "missing") |> should.be_error
}
