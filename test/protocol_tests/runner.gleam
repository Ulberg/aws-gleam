//// Generic runner used by every per-protocol test file.
////
//// Loads the JSON AST for a protocol, iterates every request /
//// response / error case, asks the dispatch registry for a generated
//// implementation, and produces a `Report` summarising pass / skip /
//// fail counts.
////
//// The runner does NOT decide whether a `Report` is a test failure.
//// Each per-protocol entry file (`awsjson10_test.gleam` etc.) decides
//// that: typically failing the suite if `fail` > 0 OR if `skip_no_dispatcher`
//// drops below the milestone's allowed cap. Per the M5 plan, the cap
//// shrinks over time as the emitter grows.

import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import protocol_tests/cases.{type ProtocolTests, AppliesToServer}
import protocol_tests/dispatch.{type Registry}
import protocol_tests/loader

/// Each individual case lands in exactly one outcome bucket. The
/// granular split lets the per-protocol entry assert specific things
/// (e.g. "no actual fails", "at most N skipped for X reason").
pub type Outcome {
  Passed
  /// Case ran and its assertion mismatched. The string explains.
  Failed(reason: String)
  /// No dispatcher registered for this operation/error — the emitter
  /// has not produced code for it yet. Expected for early milestones.
  SkippedNoDispatcher
  /// `appliesTo: "server"`. Not relevant to a client SDK.
  SkippedServerOnly
  /// Documented gap, listed in the per-protocol allow-list with a reason.
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
        "  ! could not load " <> config.fixture_path <> ": " <> describe_load_error(err),
      )
      cases.ProtocolTests(
        protocol_name: config.protocol_name,
        operations: [],
        errors: [],
      )
    }
  }
  let results =
    run_operations(tests, config) |> list.append(run_errors(tests, config))
  tally(config.protocol_name, results)
}

fn run_operations(
  tests: ProtocolTests,
  config: Config,
) -> List(CaseResult) {
  list.flat_map(tests.operations, fn(op) {
    let dispatcher = dispatch.lookup(config.registry, op.operation_id)
    let req_results =
      list.map(op.request_cases, fn(c) {
        let outcome =
          classify_request_outcome(c.applies_to, c.id, config, dispatcher)
        CaseResult(
          protocol: config.protocol_name,
          operation_or_error_id: op.operation_id,
          case_id: c.id,
          direction: Request,
          outcome: outcome,
        )
      })
    let resp_results =
      list.map(op.response_cases, fn(c) {
        let outcome =
          classify_response_outcome(c.applies_to, c.id, config, dispatcher)
        CaseResult(
          protocol: config.protocol_name,
          operation_or_error_id: op.operation_id,
          case_id: c.id,
          direction: Response,
          outcome: outcome,
        )
      })
    list.append(req_results, resp_results)
  })
}

fn run_errors(
  tests: ProtocolTests,
  config: Config,
) -> List(CaseResult) {
  list.flat_map(tests.errors, fn(err) {
    // Error-response cases dispatch on the error structure's shape ID,
    // not the operation. We register error parsers by error shape ID.
    let dispatcher = dispatch.lookup(config.registry, err.error_id)
    list.map(err.response_cases, fn(c) {
      let outcome =
        classify_response_outcome(c.applies_to, c.id, config, dispatcher)
      CaseResult(
        protocol: config.protocol_name,
        operation_or_error_id: err.error_id,
        case_id: c.id,
        direction: ErrorResponse,
        outcome: outcome,
      )
    })
  })
}

fn classify_request_outcome(
  applies_to: cases.AppliesTo,
  case_id: String,
  config: Config,
  dispatcher: Result(dispatch.Dispatcher, Nil),
) -> Outcome {
  case applies_to {
    AppliesToServer -> SkippedServerOnly
    _ ->
      case dict.get(config.skip_allow_list, case_id) {
        Ok(reason) -> SkippedAllowed(reason: reason)
        Error(_) ->
          case dispatcher {
            Error(_) -> SkippedNoDispatcher
            Ok(_) ->
              // M5.3 fills this in. For now it's still "no dispatcher".
              SkippedNoDispatcher
          }
      }
  }
}

fn classify_response_outcome(
  applies_to: cases.AppliesTo,
  case_id: String,
  config: Config,
  dispatcher: Result(dispatch.Dispatcher, Nil),
) -> Outcome {
  case applies_to {
    AppliesToServer -> SkippedServerOnly
    _ ->
      case dict.get(config.skip_allow_list, case_id) {
        Ok(reason) -> SkippedAllowed(reason: reason)
        Error(_) ->
          case dispatcher {
            Error(_) -> SkippedNoDispatcher
            Ok(_) -> SkippedNoDispatcher
          }
      }
  }
}

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

// Re-export helpers the per-protocol entry files use without having to
// import multiple modules each. Keeps callers focused.
pub fn empty_allow_list() -> Dict(String, String) {
  dict.new()
}
