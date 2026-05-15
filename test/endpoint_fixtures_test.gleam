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

// Honest gating: any test case using an unsupported parameter type
// (StringArray) is marked Skip. Everything else MUST pass — `failed = 0`
// is the only acceptable outcome. When new functionality lands, the skip
// count should drop and the pass count should rise; if anything moves a
// case from Pass to Fail, the suite breaks loudly.

// ---------- runner ----------

type CaseExpectation {
  ExpectEndpoint(url: String)
  ExpectError(message: String)
}

type ParamValue {
  Supported(value: endpoints.Value)
  /// Param value is an array — our evaluator doesn't implement
  /// `StringArray` yet, so any test case touching one of these gets
  /// classified as `Skip` rather than `Fail`.
  UnsupportedArray
}

type TestCase {
  TestCase(
    documentation: String,
    params: Dict(String, ParamValue),
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

fn param_value_decoder() -> decode.Decoder(ParamValue) {
  decode.one_of(
    decode.map(decode.bool, fn(b) { Supported(value: BoolVal(b)) }),
    [
      decode.map(decode.string, fn(s) { Supported(value: StringVal(s)) }),
      // Anything else — JSON array, number, etc. — is StringArray-shaped and
      // tags the whole test case as a skip.
      decode.success(UnsupportedArray),
    ],
  )
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
  // Bail out before running the rule set if any param is StringArray-shaped:
  // the evaluator can't reason about lists today, so the case would simply
  // produce the wrong endpoint. Treat as Skip, not Fail.
  let has_unsupported =
    case_.params
    |> dict.values
    |> list.any(fn(value) {
      case value {
        UnsupportedArray -> True
        Supported(_) -> False
      }
    })
  case has_unsupported {
    True -> Skip(reason: "test case uses an unsupported StringArray parameter")
    False -> {
      let supported_params =
        dict.fold(case_.params, dict.new(), fn(acc, key, value) {
          case value {
            Supported(value: v) -> dict.insert(acc, key, v)
            UnsupportedArray -> acc
          }
        })
      do_run_case(rs, supported_params, case_)
    }
  }
}

fn do_run_case(
  rs: RuleSet,
  params: Dict(String, endpoints.Value),
  case_: TestCase,
) -> Outcome {
  case endpoints.resolve(rs, params), case_.expect {
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
  assert_zero_failures("dynamodb", summary)
}

pub fn s3_official_fixtures_test() {
  let summary =
    run_suite(
      "s3",
      "test/fixtures/endpoints/s3-rule-set.json",
      "test/fixtures/endpoints/s3-tests.json",
    )
  assert_zero_failures("s3", summary)
}

fn assert_zero_failures(name: String, summary: Summary) -> Nil {
  case summary.failed {
    0 -> Nil
    n ->
      panic as {
        name
        <> " fixtures: "
        <> int.to_string(n)
        <> " unexpected failures (out of "
        <> int.to_string(summary.passed + n + summary.skipped)
        <> " cases). First failures:\n  - "
        <> list.reverse(summary.first_failures)
        |> list.first
        |> int_or_empty
      }
  }
}

fn int_or_empty(r: Result(String, Nil)) -> String {
  case r {
    Ok(s) -> s
    Error(_) -> "(no details captured)"
  }
}
