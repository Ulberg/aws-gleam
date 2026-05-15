//// SigV4 conformance tests driven by the official AWS SigV4 test suite,
//// vendored under `test/fixtures/aws-c-auth/tests/aws-sig-v4-test-suite/`.

import aws/credentials
import aws/internal/http_request.{type HttpRequest}
import aws/internal/sigv4
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleeunit/should
import simplifile

const v4_suite_root = "test/fixtures/aws-c-auth/tests/aws-sig-v4-test-suite/v4"

type Context {
  Context(
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
    region: String,
    service: String,
    sign_body: Bool,
    normalize: Bool,
    omit_session_token: Bool,
    timestamp_iso: String,
  )
}

fn context_decoder() -> decode.Decoder(Context) {
  use access_key_id <- decode.subfield(
    ["credentials", "access_key_id"],
    decode.string,
  )
  use secret_access_key <- decode.subfield(
    ["credentials", "secret_access_key"],
    decode.string,
  )
  use session_token <- decode.then(decode.optionally_at(
    ["credentials", "token"],
    None,
    decode.map(decode.string, Some),
  ))
  use region <- decode.field("region", decode.string)
  use service <- decode.field("service", decode.string)
  use sign_body <- decode.field("sign_body", decode.bool)
  use normalize <- decode.field("normalize", decode.bool)
  use omit_session_token <- decode.optional_field(
    "omit_session_token",
    False,
    decode.bool,
  )
  use timestamp_iso <- decode.field("timestamp", decode.string)
  decode.success(Context(
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token,
    region: region,
    service: service,
    sign_body: sign_body,
    normalize: normalize,
    omit_session_token: omit_session_token,
    timestamp_iso: timestamp_iso,
  ))
}

fn iso_to_compact(ts: String) -> String {
  ts
  |> string.replace("-", "")
  |> string.replace(":", "")
}

fn load_context(dir: String) -> Context {
  let assert Ok(text) = simplifile.read(dir <> "/context.json")
  let assert Ok(ctx) = json.parse(text, context_decoder())
  ctx
}

fn load_request(dir: String) -> HttpRequest {
  let assert Ok(text) = simplifile.read(dir <> "/request.txt")
  let assert Ok(req) = http_request.parse(text)
  req
}

fn build_creds(ctx: Context) -> credentials.Credentials {
  credentials.Credentials(
    access_key_id: ctx.access_key_id,
    secret_access_key: ctx.secret_access_key,
    session_token: ctx.session_token,
    expires_at: None,
    source: "Fixture",
  )
}

fn build_opts(ctx: Context) -> sigv4.SigningOptions {
  sigv4.SigningOptions(
    timestamp: iso_to_compact(ctx.timestamp_iso),
    region: ctx.region,
    service: ctx.service,
    normalize_path: ctx.normalize,
    sign_body: ctx.sign_body,
    omit_session_token: ctx.omit_session_token,
  )
}

fn read_expected(dir: String, basename: String) -> String {
  let assert Ok(text) = simplifile.read(dir <> "/" <> basename)
  string.trim_end(text)
}

fn check(
  case_name: String,
  stage: String,
  actual: String,
  expected: String,
) -> Result(Nil, String) {
  case actual == expected {
    True -> Ok(Nil)
    False ->
      Error(
        case_name
        <> " ["
        <> stage
        <> "]:\nexpected:\n"
        <> expected
        <> "\n---\nactual:\n"
        <> actual,
      )
  }
}

/// Extract the value of the `Authorization` header from a signed-request
/// fixture. The fixture is a raw HTTP message — we just need the value, not a
/// full re-parse, so a line scan is enough.
fn extract_authorization(signed_request: String) -> String {
  signed_request
  |> string.split("\n")
  |> list.find_map(fn(line) {
    case string.split_once(line, ":") {
      Ok(#(name, value)) ->
        case string.lowercase(string.trim(name)) {
          "authorization" -> Ok(string.trim_start(value))
          _ -> Error(Nil)
        }
      Error(_) -> Error(Nil)
    }
  })
  |> result.unwrap("")
}

/// Run one case through all four sigv4 stages, returning the list of stage
/// names that produced a mismatch (with diagnostic context attached).
fn run_case(case_name: String) -> List(String) {
  let dir = v4_suite_root <> "/" <> case_name
  let ctx = load_context(dir)
  let req = load_request(dir)
  let creds = build_creds(ctx)
  let opts = build_opts(ctx)

  let parts = sigv4.canonical_request(req, creds, opts)
  let sts =
    sigv4.string_to_sign(
      parts.canonical_request,
      opts.timestamp,
      opts.region,
      opts.service,
    )
  let date = string.slice(opts.timestamp, 0, 8)
  let key =
    sigv4.signing_key(creds.secret_access_key, date, opts.region, opts.service)
  let sig = sigv4.signature(key, sts)
  let auth =
    sigv4.authorization_header(
      creds,
      opts.timestamp,
      opts.region,
      opts.service,
      parts.signed_headers,
      sig,
    )

  let expected_auth =
    read_expected(dir, "header-signed-request.txt")
    |> extract_authorization

  [
    check(
      case_name,
      "canonical",
      parts.canonical_request,
      read_expected(dir, "header-canonical-request.txt"),
    ),
    check(
      case_name,
      "string-to-sign",
      sts,
      read_expected(dir, "header-string-to-sign.txt"),
    ),
    check(
      case_name,
      "signature",
      sig,
      read_expected(dir, "header-signature.txt"),
    ),
    check(case_name, "authorization", auth, expected_auth),
  ]
  |> list.filter_map(fn(r) {
    case r {
      Error(message) -> Ok(message)
      Ok(_) -> Error(Nil)
    }
  })
}

/// Smoke test: simplest header-signed GET case.
pub fn get_vanilla_test() {
  run_case("get-vanilla")
  |> should.equal([])
}

/// Full AWS SigV4 v4 suite. A single test that runs every case directory and
/// reports any mismatches as one consolidated diff so you can see which cases
/// fail in one pass.
pub fn all_v4_cases_test() {
  let assert Ok(entries) = simplifile.read_directory(v4_suite_root)
  let cases = list.sort(entries, by: string.compare)

  // Guard against the harness silently passing with zero cases (e.g. if the
  // fixture path is wrong or read_directory returns something unexpected).
  // The aws-c-auth v4 suite ships 38 cases; any drop is worth surfacing.
  case list.length(cases) >= 38 {
    True -> Nil
    False ->
      panic as {
        "expected ≥38 v4 cases, found " <> int.to_string(list.length(cases))
      }
  }

  let failures = list.flat_map(cases, run_case)
  case failures {
    [] -> Nil
    _ -> {
      let report = string.join(failures, "\n\n===========\n\n")
      report |> should.equal("")
    }
  }
}
