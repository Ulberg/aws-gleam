//// Run the official Smithy endpoint test fixtures (vendored from the
//// AWS Smithy models for S3 and DynamoDB) through our evaluator. The
//// fixtures live under `test/fixtures/endpoints/`.
////
//// Each test case shape:
////
////   {
////     "documentation": "...",
////     "params": { "Region": "us-east-1", "UseFIPS": false, ... },
////     "expect": {
////       "endpoint": { "url": "...", "headers": {...} } |
////       "error": "..."
////     }
////   }
////
//// We surface a pass/fail count per service rather than panicking on the
//// first mismatch — the goal is to track coverage as the evaluator matures.

import aws/endpoints.{
  type Endpoint, type RuleSet, BoolVal, Endpoint, RuleError, StringVal,
}
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import simplifile

const dynamodb_threshold: Int = 354

// 354/370 DynamoDB cases pass at the time of this commit. The 16 failures
// all use `ResourceArnList` (StringArray parameter type), which the
// evaluator deliberately doesn't support yet — adding it bumps the
// threshold. Treat this as a regression gate: if a future change drops the
// pass count, the test fails.

const s3_threshold: Int = 287

// 287/393 S3 cases pass at the time of this commit. The remaining ~100
// failures are mostly about specific phrasings in the S3 rule set's
// ARN-validation error messages — fine-grained checks on accesspoint /
// outposts / multi-region access points that need finer error reporting
// out of `aws.parseArn` than our current implementation provides. Same
// regression-gate semantics as the DynamoDB threshold.

// ---------- runner ----------

type CaseExpectation {
  ExpectEndpoint(url: String)
  ExpectError(message: String)
}

type TestCase {
  TestCase(
    documentation: String,
    params: Dict(String, endpoints.Value),
    expect: CaseExpectation,
  )
}

type TestCases {
  TestCases(cases: List(TestCase))
}

fn test_cases_decoder() -> decode.Decoder(TestCases) {
  use cases <- decode.field("testCases", decode.list(test_case_decoder()))
  decode.success(TestCases(cases: cases))
}

fn test_case_decoder() -> decode.Decoder(TestCase) {
  use documentation <- decode.optional_field("documentation", "", decode.string)
  use params <- decode.optional_field(
    "params",
    dict.new(),
    decode.dict(decode.string, param_value_decoder()),
  )
  use expect <- decode.field("expect", expectation_decoder())
  decode.success(TestCase(
    documentation: documentation,
    params: params,
    expect: expect,
  ))
}

fn param_value_decoder() -> decode.Decoder(endpoints.Value) {
  decode.one_of(decode.map(decode.bool, BoolVal), [
    decode.map(decode.string, StringVal),
    // StringArray params are encoded as JSON arrays; we don't support them
    // and treat them as empty so the evaluator can decide what to do.
    decode.success(StringVal("")),
  ])
}

fn expectation_decoder() -> decode.Decoder(CaseExpectation) {
  decode.one_of(
    {
      use url <- decode.subfield(["endpoint", "url"], decode.string)
      decode.success(ExpectEndpoint(url: url))
    },
    [
      {
        use msg <- decode.field("error", decode.string)
        decode.success(ExpectError(message: msg))
      },
    ],
  )
}

type Outcome {
  Pass
  Fail(reason: String)
  /// Evaluator returned Unsupported — counts as "skipped" rather than failed
  /// so unimplemented builtins don't masquerade as bugs in cases that touch
  /// them.
  Skip(reason: String)
}

fn run_case(rs: RuleSet, case_: TestCase) -> Outcome {
  case endpoints.resolve(rs, case_.params), case_.expect {
    Ok(Endpoint(url: actual, ..)), ExpectEndpoint(url: expected) ->
      case actual == expected {
        True -> Pass
        False ->
          Fail(
            reason: "url mismatch:\n  expected: "
            <> expected
            <> "\n  actual:   "
            <> actual,
          )
      }
    Error(RuleError(message: actual)), ExpectError(message: expected) ->
      case actual == expected {
        True -> Pass
        False ->
          Fail(
            reason: "error mismatch:\n  expected: "
            <> expected
            <> "\n  actual:   "
            <> actual,
          )
      }
    Error(endpoints.Unsupported(reason: r)), _ -> Skip(reason: r)
    other, ExpectEndpoint(url: expected) ->
      Fail(
        reason: "expected endpoint "
        <> expected
        <> ", got "
        <> describe_result(other),
      )
    other, ExpectError(message: expected) ->
      Fail(
        reason: "expected error "
        <> expected
        <> ", got "
        <> describe_result(other),
      )
  }
}

fn describe_result(r: Result(Endpoint, endpoints.ResolveError)) -> String {
  case r {
    Ok(Endpoint(url: u, ..)) -> "endpoint " <> u
    Error(endpoints.RuleError(message: m)) -> "rule-error: " <> m
    Error(endpoints.NoMatch) -> "no-match"
    Error(endpoints.InvalidRuleSet(reason: r)) -> "invalid: " <> r
    Error(endpoints.Unsupported(reason: r)) -> "unsupported: " <> r
    Error(endpoints.MissingParameter(name: n)) -> "missing param: " <> n
    Error(endpoints.RequiredParameterMissing(name: n)) -> "required: " <> n
  }
}

fn load_rule_set(path: String) -> RuleSet {
  let assert Ok(text) = simplifile.read(path)
  let assert Ok(rs) = endpoints.parse_rule_set(text)
  rs
}

fn load_cases(path: String) -> List(TestCase) {
  let assert Ok(text) = simplifile.read(path)
  let assert Ok(TestCases(cases: cases)) =
    json.parse(text, test_cases_decoder())
  cases
}

type Summary {
  Summary(passed: Int, failed: Int, skipped: Int, first_failures: List(String))
}

fn run_suite(name: String, rs_path: String, tests_path: String) -> Summary {
  let rs = load_rule_set(rs_path)
  let cases = load_cases(tests_path)
  let initial = Summary(passed: 0, failed: 0, skipped: 0, first_failures: [])
  let summary =
    list.fold(cases, initial, fn(acc, case_) {
      case run_case(rs, case_) {
        Pass -> Summary(..acc, passed: acc.passed + 1)
        Skip(reason: _) -> Summary(..acc, skipped: acc.skipped + 1)
        Fail(reason: r) -> {
          let new_failures = case list.length(acc.first_failures) >= 3 {
            True -> acc.first_failures
            False -> [case_.documentation <> ": " <> r, ..acc.first_failures]
          }
          Summary(..acc, failed: acc.failed + 1, first_failures: new_failures)
        }
      }
    })
  io.println(
    name
    <> ": "
    <> int.to_string(summary.passed)
    <> " passed, "
    <> int.to_string(summary.failed)
    <> " failed, "
    <> int.to_string(summary.skipped)
    <> " skipped (of "
    <> int.to_string(list.length(cases))
    <> ")",
  )
  case summary.first_failures {
    [] -> Nil
    failures -> {
      io.println("  First failures:")
      list.each(list.reverse(failures), fn(f) { io.println("    - " <> f) })
    }
  }
  summary
}

// ---------- tests ----------

pub fn dynamodb_official_fixtures_test() {
  let summary =
    run_suite(
      "dynamodb",
      "test/fixtures/endpoints/dynamodb-rule-set.json",
      "test/fixtures/endpoints/dynamodb-tests.json",
    )
  case summary.passed >= dynamodb_threshold {
    True -> Nil
    False ->
      panic as {
        "DynamoDB fixtures: only "
        <> int.to_string(summary.passed)
        <> " passed, expected >= "
        <> int.to_string(dynamodb_threshold)
      }
  }
}

pub fn s3_official_fixtures_test() {
  let summary =
    run_suite(
      "s3",
      "test/fixtures/endpoints/s3-rule-set.json",
      "test/fixtures/endpoints/s3-tests.json",
    )
  case summary.passed >= s3_threshold {
    True -> Nil
    False ->
      panic as {
        "S3 fixtures: only "
        <> int.to_string(summary.passed)
        <> " passed, expected >= "
        <> int.to_string(s3_threshold)
      }
  }
}
