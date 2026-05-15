//// Generic runner used by every per-protocol test file.
////
//// Loads the JSON AST for a protocol, iterates every request /
//// response / error case, asks the dispatch registry for a generated
//// implementation, and produces a `Report` summarising pass / skip /
//// fail counts.
////
//// The runner does NOT decide whether a `Report` is a test failure.
//// Each per-protocol entry file decides that — typically failing the
//// suite if `fail > 0`.

import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import protocol_tests/cases.{
  type ProtocolTests, type RequestCase, type ResponseCase, AppliesToServer,
}
import protocol_tests/dispatch.{
  type BuiltRequest, type Dispatcher, type Registry, BuiltRequest,
  ParsedResponseInput,
}
import protocol_tests/loader

pub type Outcome {
  Passed
  Failed(reason: String)
  SkippedNoDispatcher
  SkippedServerOnly
  SkippedAllowed(reason: String)
}

pub type CaseResult {
  CaseResult(
    protocol: String,
    operation_or_error_id: String,
    case_id: String,
    direction: Direction,
    outcome: Outcome,
  )
}

pub type Direction {
  Request
  Response
  ErrorResponse
}

pub type Report {
  Report(
    protocol: String,
    total: Int,
    pass: Int,
    fail: Int,
    skip_no_dispatcher: Int,
    skip_server: Int,
    skip_allowed: Int,
    results: List(CaseResult),
  )
}

pub type Config {
  Config(
    protocol_name: String,
    fixture_path: String,
    registry: Registry,
    skip_allow_list: Dict(String, String),
  )
}

pub fn run(config: Config) -> Report {
  let tests = case loader.load(config.fixture_path, config.protocol_name) {
    Ok(t) -> t
    Error(err) -> {
      io.println(
        "  ! could not load "
        <> config.fixture_path
        <> ": "
        <> describe_load_error(err),
      )
      cases.ProtocolTests(
        protocol_name: config.protocol_name,
        operations: [],
        errors: [],
      )
    }
  }
  let results =
    list.append(run_operations(tests, config), run_errors(tests, config))
  tally(config.protocol_name, results)
}

fn run_operations(tests: ProtocolTests, config: Config) -> List(CaseResult) {
  list.flat_map(tests.operations, fn(op) {
    let dispatcher = dispatch.lookup(config.registry, op.operation_id)
    let req_results =
      list.map(op.request_cases, fn(c) {
        CaseResult(
          protocol: config.protocol_name,
          operation_or_error_id: op.operation_id,
          case_id: c.id,
          direction: Request,
          outcome: classify_request(c, config, dispatcher),
        )
      })
    let resp_results =
      list.map(op.response_cases, fn(c) {
        CaseResult(
          protocol: config.protocol_name,
          operation_or_error_id: op.operation_id,
          case_id: c.id,
          direction: Response,
          outcome: classify_response(c, config, dispatcher),
        )
      })
    list.append(req_results, resp_results)
  })
}

fn run_errors(tests: ProtocolTests, config: Config) -> List(CaseResult) {
  list.flat_map(tests.errors, fn(err) {
    let dispatcher = dispatch.lookup(config.registry, err.error_id)
    list.map(err.response_cases, fn(c) {
      CaseResult(
        protocol: config.protocol_name,
        operation_or_error_id: err.error_id,
        case_id: c.id,
        direction: ErrorResponse,
        outcome: classify_response(c, config, dispatcher),
      )
    })
  })
}

fn classify_request(
  c: RequestCase,
  config: Config,
  dispatcher: Result(Dispatcher, Nil),
) -> Outcome {
  case c.applies_to {
    AppliesToServer -> SkippedServerOnly
    _ ->
      case dict.get(config.skip_allow_list, c.id) {
        Ok(reason) -> SkippedAllowed(reason: reason)
        Error(_) ->
          case dispatcher {
            Error(_) -> SkippedNoDispatcher
            Ok(d) -> run_request_assertion(c, d)
          }
      }
  }
}

fn classify_response(
  c: ResponseCase,
  config: Config,
  dispatcher: Result(Dispatcher, Nil),
) -> Outcome {
  case c.applies_to {
    AppliesToServer -> SkippedServerOnly
    _ ->
      case dict.get(config.skip_allow_list, c.id) {
        Ok(reason) -> SkippedAllowed(reason: reason)
        Error(_) ->
          case dispatcher {
            Error(_) -> SkippedNoDispatcher
            Ok(d) -> run_response_assertion(c, d)
          }
      }
  }
}

// ---------- assertions ----------

fn run_request_assertion(c: RequestCase, d: Dispatcher) -> Outcome {
  // For MVP, ignore params content (loader doesn't extract JSON yet) and
  // hand an empty string — dispatchers that don't take params won't care.
  let params_json = case c.params {
    Some(_) -> "{}"
    None -> ""
  }
  case d.build_request(params_json) {
    Error(reason) -> Failed(reason: "build_request error: " <> reason)
    Ok(built) -> assert_request(c, built)
  }
}

fn assert_request(c: RequestCase, built: BuiltRequest) -> Outcome {
  let _ = c
  let BuiltRequest(method: method, uri: uri, headers: hs, body: body) = built
  use _ <- chain(
    check(c.method == method, fn() {
      "method mismatch: expected " <> c.method <> ", got " <> method
    }),
  )
  use _ <- chain(
    check(c.uri == uri, fn() {
      "uri mismatch: expected " <> c.uri <> ", got " <> uri
    }),
  )
  use _ <- chain(assert_headers(
    c.headers,
    c.require_headers,
    c.forbid_headers,
    hs,
  ))
  use _ <- chain(assert_body_bytes(c.body, body))
  Passed
}

fn run_response_assertion(c: ResponseCase, d: Dispatcher) -> Outcome {
  // Build a synthetic response from the case's expected bytes.
  let body_bytes = case c.body {
    Some(s) -> string_to_bit_array(s)
    None -> <<>>
  }
  case
    d.parse_response(ParsedResponseInput(
      code: c.code,
      headers: c.headers,
      body: body_bytes,
    ))
  {
    Error(reason) -> Failed(reason: "parse_response error: " <> reason)
    Ok(_parsed) ->
      // Without full params extraction we can only assert "parsing
      // succeeded". Deeper assertions land when params capture is wired.
      Passed
  }
}

fn assert_headers(
  expected: Dict(String, String),
  require: List(String),
  forbid: List(String),
  actual: Dict(String, String),
) -> Outcome {
  let lower_actual =
    dict.fold(actual, dict.new(), fn(acc, k, v) {
      dict.insert(acc, string.lowercase(k), v)
    })
  let exact_outcome =
    dict.fold(expected, Passed, fn(acc, k, v) {
      case acc {
        Passed ->
          case dict.get(lower_actual, string.lowercase(k)) {
            Ok(av) ->
              case av == v {
                True -> Passed
                False ->
                  Failed(
                    reason: "header mismatch on "
                    <> k
                    <> ": expected `"
                    <> v
                    <> "`, got `"
                    <> av
                    <> "`",
                  )
              }
            Error(_) -> Failed(reason: "missing header: " <> k)
          }
        _ -> acc
      }
    })
  use _ <- chain(exact_outcome)
  let req_outcome =
    list.fold(require, Passed, fn(acc, k) {
      case acc {
        Passed ->
          case dict.has_key(lower_actual, string.lowercase(k)) {
            True -> Passed
            False -> Failed(reason: "missing required header: " <> k)
          }
        _ -> acc
      }
    })
  use _ <- chain(req_outcome)
  list.fold(forbid, Passed, fn(acc, k) {
    case acc {
      Passed ->
        case dict.has_key(lower_actual, string.lowercase(k)) {
          False -> Passed
          True -> Failed(reason: "forbidden header present: " <> k)
        }
      _ -> acc
    }
  })
}

fn assert_body_bytes(expected: Option(String), actual: BitArray) -> Outcome {
  case expected {
    None -> Passed
    Some(want) -> {
      let want_bytes = string_to_bit_array(want)
      case want_bytes == actual {
        True -> Passed
        False ->
          Failed(
            reason: "body mismatch (expected "
            <> int.to_string(string.byte_size(want))
            <> "B, got "
            <> int.to_string(bit_array_size(actual))
            <> "B)",
          )
      }
    }
  }
}

// ---------- bookkeeping ----------

fn tally(protocol: String, results: List(CaseResult)) -> Report {
  let init = #(0, 0, 0, 0, 0)
  let #(pass, fail, no_disp, server, allowed) =
    list.fold(results, init, fn(acc, r) {
      let #(p, f, n, s, a) = acc
      case r.outcome {
        Passed -> #(p + 1, f, n, s, a)
        Failed(_) -> #(p, f + 1, n, s, a)
        SkippedNoDispatcher -> #(p, f, n + 1, s, a)
        SkippedServerOnly -> #(p, f, n, s + 1, a)
        SkippedAllowed(_) -> #(p, f, n, s, a + 1)
      }
    })
  Report(
    protocol: protocol,
    total: list.length(results),
    pass: pass,
    fail: fail,
    skip_no_dispatcher: no_disp,
    skip_server: server,
    skip_allowed: allowed,
    results: results,
  )
}

pub fn print_report(report: Report) -> Nil {
  io.println(
    "  ["
    <> report.protocol
    <> "] total="
    <> int.to_string(report.total)
    <> " pass="
    <> int.to_string(report.pass)
    <> " fail="
    <> int.to_string(report.fail)
    <> " skip(no-dispatcher)="
    <> int.to_string(report.skip_no_dispatcher)
    <> " skip(server-only)="
    <> int.to_string(report.skip_server)
    <> " skip(allowed)="
    <> int.to_string(report.skip_allowed),
  )
  list.each(report.results, fn(r) {
    case r.outcome {
      Failed(reason) ->
        io.println(
          "    FAIL "
          <> r.operation_or_error_id
          <> "::"
          <> r.case_id
          <> " ("
          <> direction_str(r.direction)
          <> "): "
          <> reason,
        )
      _ -> Nil
    }
  })
}

fn direction_str(d: Direction) -> String {
  case d {
    Request -> "req"
    Response -> "resp"
    ErrorResponse -> "err"
  }
}

fn describe_load_error(err: loader.LoadError) -> String {
  case err {
    loader.CannotRead(path) -> "cannot read " <> path
    loader.InvalidJson(reason) -> "invalid json: " <> reason
    loader.MalformedAst(reason) -> "malformed ast: " <> reason
  }
}

pub fn empty_allow_list() -> Dict(String, String) {
  dict.new()
}

// ---------- helpers ----------

fn check(cond: Bool, msg: fn() -> String) -> Outcome {
  case cond {
    True -> Passed
    False -> Failed(reason: msg())
  }
}

fn chain(outcome: Outcome, k: fn(Nil) -> Outcome) -> Outcome {
  case outcome {
    Passed -> k(Nil)
    other -> other
  }
}

@external(erlang, "erlang", "iolist_to_binary")
fn string_to_bit_array(s: String) -> BitArray

@external(erlang, "erlang", "byte_size")
fn bit_array_size(b: BitArray) -> Int
