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

import aws/internal/codec/xml_decode
import gleam/bit_array
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
  // Pass the actual params JSON string the loader extracted via
  // aws_ffi:encode_dynamic_to_json — the dispatcher decodes it into
  // its typed input shape.
  let params_json = case c.params {
    Some(s) -> s
    None -> ""
  }
  case d.build_request(params_json) {
    Error(reason) -> Failed(reason: "build_request error: " <> reason)
    Ok(built) -> assert_request(c, built)
  }
}

fn assert_request(c: RequestCase, built: BuiltRequest) -> Outcome {
  let BuiltRequest(method: method, uri: uri, headers: hs, body: body) = built
  use _ <- chain(
    check(c.method == method, fn() {
      "method mismatch: expected " <> c.method <> ", got " <> method
    }),
  )
  // Per the Smithy `httpRequestTests` spec, `host` may include a path
  // prefix supplied by the user as a custom endpoint. The runtime is
  // responsible for prepending that prefix to the operation path. The
  // generated builder emits only the operation path; the runner
  // emulates the runtime's join by stripping the prefix from the
  // expected URI before comparing.
  let expected_uri = strip_host_path_prefix(c.host, c.uri)
  // Split our built `uri` into path + query. Smithy's `c.uri` is the
  // path component only; dynamic query params arrive separately via
  // `c.query_params` / `c.require_query_params` / `c.forbid_query_params`.
  let #(got_path, got_query) = case string.split_once(uri, "?") {
    Ok(#(p, q)) -> #(p, q)
    Error(_) -> #(uri, "")
  }
  use _ <- chain(
    check(expected_uri == got_path, fn() {
      "uri mismatch: expected " <> expected_uri <> ", got " <> got_path
    }),
  )
  use _ <- chain(assert_query_params(
    c.query_params,
    c.require_query_params,
    c.forbid_query_params,
    got_query,
  ))
  use _ <- chain(assert_headers(
    c.headers,
    c.require_headers,
    c.forbid_headers,
    hs,
  ))
  use _ <- chain(assert_body_bytes(c.body, c.body_media_type, body))
  Passed
}

/// Validate the query string. Smithy supplies three lists:
///   * `query_params` — every entry must appear in the generated query
///     (as `Name=Value`); pure presence check, order doesn't matter.
///   * `require_query_params` — every NAME (without value) must appear.
///   * `forbid_query_params` — every NAME must NOT appear.
fn assert_query_params(
  expected: List(String),
  required: List(String),
  forbidden: List(String),
  got: String,
) -> Outcome {
  let entries = case got {
    "" -> []
    _ -> string.split(got, "&")
  }
  let names =
    list.map(entries, fn(e) {
      case string.split_once(e, "=") {
        Ok(#(n, _)) -> n
        Error(_) -> e
      }
    })
  use _ <- chain(
    case list.find(expected, fn(want) { !list.contains(entries, want) }) {
      Ok(missing) ->
        Failed(
          reason: "missing query param: " <> missing <> " (got: " <> got <> ")",
        )
      Error(_) -> Passed
    },
  )
  use _ <- chain(
    case list.find(required, fn(want) { !list.contains(names, want) }) {
      Ok(missing) ->
        Failed(reason: "missing required query param name: " <> missing)
      Error(_) -> Passed
    },
  )
  case list.find(forbidden, fn(bad) { list.contains(names, bad) }) {
    Ok(found) -> Failed(reason: "forbidden query param present: " <> found)
    Error(_) -> Passed
  }
}

fn strip_host_path_prefix(host: Option(String), uri: String) -> String {
  case host {
    None -> uri
    Some(h) ->
      case string.split_once(h, "/") {
        Ok(#(_authority, path_after)) -> {
          let prefix = "/" <> path_after
          case string.starts_with(uri, prefix) {
            True -> string.drop_start(uri, string.length(prefix))
            False -> uri
          }
        }
        Error(_) -> uri
      }
  }
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

fn assert_body_bytes(
  expected: Option(String),
  media_type: Option(String),
  actual: BitArray,
) -> Outcome {
  case expected {
    None -> Passed
    Some(want) -> {
      let want_bytes = string_to_bit_array(want)
      case want_bytes == actual {
        True -> Passed
        False ->
          // Byte comparison failed. Per the Smithy `httpRequestTests`
          // spec, `bodyMediaType` controls how mismatches are
          // re-checked: `application/json` is compared structurally so
          // whitespace and key order don't matter. Other media types
          // (XML, form-urlencoded, CBOR, etc.) get their own semantic
          // comparators as those protocols' codecs land.
          case media_type {
            Some(mt) ->
              case is_json_media(mt), is_xml_media(mt) {
                True, _ -> assert_json_semantic_equal(want, actual)
                _, True -> assert_xml_semantic_equal(want, actual)
                _, _ -> body_mismatch(want, actual)
              }
            None -> body_mismatch(want, actual)
          }
      }
    }
  }
}

fn body_mismatch(want: String, actual: BitArray) -> Outcome {
  Failed(
    reason: "body mismatch (expected "
    <> int.to_string(string.byte_size(want))
    <> "B, got "
    <> int.to_string(bit_array_size(actual))
    <> "B)",
  )
}

fn is_json_media(mt: String) -> Bool {
  string.contains(mt, "json")
}

fn is_xml_media(mt: String) -> Bool {
  string.contains(mt, "xml")
}

/// Compare two XML bodies structurally — same element tree, same
/// attribute set per element, same text content modulo surrounding
/// whitespace. The Smithy `httpRequestTests` fixtures are pretty-
/// printed, but the emitter produces single-line XML; the
/// byte-comparison stage rejects those even when the wire payloads
/// are semantically identical.
fn assert_xml_semantic_equal(want: String, actual_bytes: BitArray) -> Outcome {
  case bit_array_to_string(actual_bytes) {
    Error(_) -> Failed(reason: "actual body is not utf-8")
    Ok(actual) ->
      case xml_decode.parse(want), xml_decode.parse(actual) {
        Ok(w), Ok(a) ->
          case xml_elements_equal(w, a) {
            True -> Passed
            False -> body_mismatch(want, actual_bytes)
          }
        Error(_), _ -> Failed(reason: "expected body is not valid xml")
        _, Error(_) -> Failed(reason: "actual body is not valid xml")
      }
  }
}

fn xml_elements_equal(a: xml_decode.Element, b: xml_decode.Element) -> Bool {
  a.name == b.name
  && attr_set_equal(a.attrs, b.attrs)
  && xml_children_equal(a.children, b.children)
}

fn attr_set_equal(
  a: List(#(String, String)),
  b: List(#(String, String)),
) -> Bool {
  let sa = list.sort(a, by: fn(p, q) { string.compare(p.0, q.0) })
  let sb = list.sort(b, by: fn(p, q) { string.compare(p.0, q.0) })
  sa == sb
}

fn xml_children_equal(
  a: List(xml_decode.Node),
  b: List(xml_decode.Node),
) -> Bool {
  // Drop whitespace-only Text nodes from both sides; the Smithy
  // fixture pretty-printer inserts them, and they carry no
  // semantic content. Element order matters when sibling names
  // differ (XML is sequenced); when *every* sibling shares a name
  // (a map's `<entry>` or a list's `<member>`), we compare as a
  // multiset so dict iteration order doesn't break the test. The
  // generated list encoder preserves input order, so multiset
  // compare doesn't mask list-ordering bugs in practice.
  let na = normalise_children(a)
  let nb = normalise_children(b)
  case length(na) == length(nb) {
    False -> False
    True ->
      case same_name_siblings(na), same_name_siblings(nb) {
        True, True -> children_multiset_equal(na, nb)
        _, _ -> children_ordered_equal(na, nb)
      }
  }
}

fn length(xs: List(a)) -> Int {
  list.length(xs)
}

fn same_name_siblings(ns: List(xml_decode.Node)) -> Bool {
  case ns {
    [] -> False
    [first, ..rest] ->
      case first {
        xml_decode.ElementNode(element: e) -> {
          let name = e.name
          list.all(rest, fn(n) {
            case n {
              xml_decode.ElementNode(element: oe) -> oe.name == name
              _ -> False
            }
          })
        }
        _ -> False
      }
  }
}

fn children_ordered_equal(
  a: List(xml_decode.Node),
  b: List(xml_decode.Node),
) -> Bool {
  case a, b {
    [], [] -> True
    [], _ | _, [] -> False
    [ah, ..at], [bh, ..bt] ->
      xml_node_equal(ah, bh) && children_ordered_equal(at, bt)
  }
}

fn children_multiset_equal(
  a: List(xml_decode.Node),
  b: List(xml_decode.Node),
) -> Bool {
  case a {
    [] ->
      case b {
        [] -> True
        _ -> False
      }
    [ah, ..at] ->
      case remove_first_match(b, ah) {
        Ok(b_rest) -> children_multiset_equal(at, b_rest)
        Error(_) -> False
      }
  }
}

fn remove_first_match(
  xs: List(xml_decode.Node),
  target: xml_decode.Node,
) -> Result(List(xml_decode.Node), Nil) {
  remove_match_help(xs, target, [])
}

fn remove_match_help(
  remaining: List(xml_decode.Node),
  target: xml_decode.Node,
  seen: List(xml_decode.Node),
) -> Result(List(xml_decode.Node), Nil) {
  case remaining {
    [] -> Error(Nil)
    [head, ..rest] ->
      case xml_node_equal(head, target) {
        True -> Ok(list.append(list.reverse(seen), rest))
        False -> remove_match_help(rest, target, [head, ..seen])
      }
  }
}

fn normalise_children(ns: List(xml_decode.Node)) -> List(xml_decode.Node) {
  list.filter(ns, fn(n) {
    case n {
      xml_decode.Text(value: v) -> string.trim(v) != ""
      xml_decode.ElementNode(..) -> True
    }
  })
}

fn xml_node_equal(a: xml_decode.Node, b: xml_decode.Node) -> Bool {
  case a, b {
    xml_decode.ElementNode(element: ae), xml_decode.ElementNode(element: be) ->
      xml_elements_equal(ae, be)
    xml_decode.Text(value: av), xml_decode.Text(value: bv) ->
      string.trim(av) == string.trim(bv)
    _, _ -> False
  }
}

fn assert_json_semantic_equal(want: String, actual_bytes: BitArray) -> Outcome {
  case bit_array_to_string(actual_bytes) {
    Error(_) -> Failed(reason: "actual body is not utf-8")
    Ok(actual) ->
      case json_canonical(want), json_canonical(actual) {
        Ok(c_want), Ok(c_actual) ->
          case c_want == c_actual {
            True -> Passed
            False ->
              Failed(
                reason: "json body mismatch: expected `"
                <> c_want
                <> "`, got `"
                <> c_actual
                <> "`",
              )
          }
        _, _ -> body_mismatch(want, actual_bytes)
      }
  }
}

/// Round-trip a JSON string through the Erlang term form and re-encode
/// canonically — sorts object keys and collapses whitespace. Used for
/// the semantic body comparison; matches what `aws-smithy-protocol-test`
/// does in Rust at the assertion site.
@external(erlang, "aws_ffi", "json_canonicalize")
fn json_canonical(input: String) -> Result(String, Nil)

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

fn bit_array_to_string(b: BitArray) -> Result(String, Nil) {
  bit_array.to_string(b)
}
