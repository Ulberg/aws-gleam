//// SigV4a conformance tests driven by the aws-c-auth v4a corpus
//// (`test/fixtures/aws-c-auth/tests/aws-signing-test-suite/v4a/`).
////
//// What we pin: per fixture, the canonical request bytes and the
//// string-to-sign bytes — both deterministic functions of (request,
//// credentials, options). The DER-encoded signature itself uses a
//// random ECDSA nonce on Erlang's `crypto:sign/4`, so byte-pinning
//// it requires RFC 6979 deterministic nonces (separate slice). The
//// canonical + STS pin already catches the bulk of regressions: if
//// either is wrong, AWS rejects the signature regardless of the
//// nonce.
////
//// All v4a fixtures share one canonical IAM pair (AKIDEXAMPLE /
//// wJalrXUtnFEMI...) and derive their EC scalar through
//// `derive_signing_key`. The session-token fixture additionally
//// carries `credentials.token`.

import aws/internal/http_request.{type HttpRequest}
import aws/internal/sigv4a
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleeunit/should
import simplifile

const v4a_suite_root: String = "test/fixtures/aws-c-auth/tests/aws-signing-test-suite/v4a"

type Context {
  Context(
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
    region: String,
    service: String,
    sign_body: Bool,
    normalize: Bool,
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
  use timestamp_iso <- decode.field("timestamp", decode.string)
  decode.success(Context(
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token,
    region: region,
    service: service,
    sign_body: sign_body,
    normalize: normalize,
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

fn build_creds(ctx: Context) -> sigv4a.Sigv4aCredentials {
  let key = sigv4a.derive_signing_key(ctx.access_key_id, ctx.secret_access_key)
  sigv4a.Sigv4aCredentials(
    access_key_id: ctx.access_key_id,
    private_key: key,
    session_token: ctx.session_token,
  )
}

fn build_opts(ctx: Context) -> sigv4a.Sigv4aOptions {
  sigv4a.Sigv4aOptions(
    timestamp: iso_to_compact(ctx.timestamp_iso),
    region_set: [ctx.region],
    service: ctx.service,
    sign_body: ctx.sign_body,
    normalize_path: ctx.normalize,
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

/// Cases that exercise features not yet ported into the SigV4a
/// canonical-request pipeline. Each is a known-skip with a reason;
/// when the feature lands the case should be removed from this list
/// so the corpus loop pins it.
const skip_list: List(#(String, String)) = [
  #("post-sts-header-after", "needs omit_session_token option on Sigv4aOptions"),
]

/// Run one fixture through canonical + STS pinning. Returns a list
/// of diagnostic messages (one per mismatched stage) or empty on
/// success. Fixtures without `header-canonical-request.txt`
/// (`get-vanilla-query-order-{key,value}` in aws-c-auth ship only
/// context + request) are skipped — no expected output to pin.
fn run_case(case_name: String) -> List(String) {
  let dir = v4a_suite_root <> "/" <> case_name
  case list.key_find(skip_list, case_name) {
    Ok(_) -> []
    Error(_) -> run_case_inner(case_name, dir)
  }
}

fn run_case_inner(case_name: String, dir: String) -> List(String) {
  case simplifile.is_file(dir <> "/header-canonical-request.txt") {
    Ok(False) | Error(_) -> []
    Ok(True) -> {
      let ctx = load_context(dir)
      let req = load_request(dir)
      let creds = build_creds(ctx)
      let opts = build_opts(ctx)
      let parts = sigv4a.canonical_request(req, creds, opts)
      let sts = sigv4a.string_to_sign(parts.canonical_request, opts)
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
      ]
      |> list.filter_map(fn(r) {
        case r {
          Error(msg) -> Ok(msg)
          Ok(_) -> Error(Nil)
        }
      })
    }
  }
}

pub fn get_vanilla_canonical_and_sts_test() {
  run_case("get-vanilla")
  |> should.equal([])
}

pub fn all_v4a_cases_canonical_and_sts_test() {
  let assert Ok(entries) = simplifile.read_directory(v4a_suite_root)
  let cases = list.sort(entries, by: string.compare)
  case list.length(cases) >= 30 {
    True -> Nil
    False ->
      panic as {
        "expected ≥30 v4a cases, found " <> int.to_string(list.length(cases))
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
