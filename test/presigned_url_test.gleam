//// Tests for `sigv4.presigned_url` — the query-string variant of
//// SigV4 used for shared pre-signed URLs (S3 downloads, etc.).
////
//// Driven by the aws-c-auth v4 test suite's per-case
//// `query-canonical-request.txt` / `query-signature.txt` /
//// `query-signed-request.txt` fixtures — the authoritative
//// conformance reference for the query-auth variant. Mirrors the
//// pattern `sigv4_test.gleam` uses for the header-auth side.

import aws/internal/http_request.{type HttpRequest, Header, HttpRequest}
import aws/internal/sigv4
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
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
    expiration_seconds: Int,
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
  use expiration_seconds <- decode.optional_field(
    "expiration_in_seconds",
    3600,
    decode.int,
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
    expiration_seconds: expiration_seconds,
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

fn build_creds(ctx: Context) -> sigv4.SigningCredentials {
  sigv4.SigningCredentials(
    access_key_id: ctx.access_key_id,
    secret_access_key: ctx.secret_access_key,
    session_token: ctx.session_token,
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

/// Run a single case directory, returning an empty list on match
/// and a one-element list with a diff message on mismatch — same
/// shape as `sigv4_test.gleam`'s `run_case` so the harness aggregates
/// failures consistently.
fn run_case(name: String) -> List(String) {
  let dir = v4_suite_root <> "/" <> name
  let signature_path = dir <> "/query-signature.txt"
  case simplifile.read(signature_path) {
    Error(_) -> []
    Ok(raw_expected) -> {
      let expected = string.trim(raw_expected)
      let ctx = load_context(dir)
      let req = load_request(dir)
      let url =
        sigv4.presigned_url(
          req,
          build_creds(ctx),
          build_opts(ctx),
          ctx.expiration_seconds,
          None,
        )
      // The signature sits after `&X-Amz-Signature=` in the URL.
      // When `omit_session_token` is set, an `&X-Amz-Security-Token=`
      // suffix follows the signature — split on `&` to isolate the
      // signature itself.
      case string.split_once(url, "&X-Amz-Signature=") {
        Ok(#(_, after_sig)) -> {
          let actual = case string.split_once(after_sig, "&") {
            Ok(#(sig, _)) -> sig
            Error(_) -> after_sig
          }
          case actual == expected {
            True -> []
            False -> [
              name
              <> ": query signature mismatch\n  expected: "
              <> expected
              <> "\n  actual:   "
              <> actual,
            ]
          }
        }
        Error(_) -> [name <> ": signed URL missing X-Amz-Signature suffix"]
      }
    }
  }
}

pub fn get_vanilla_query_test() {
  run_case("get-vanilla")
  |> should.equal([])
}

pub fn get_vanilla_query_order_test() {
  // Existing query params + auth params must merge + sort.
  run_case("get-vanilla-query")
  |> should.equal([])
}

/// Full sweep across every v4 case directory that ships a
/// `query-signature.txt`. Aggregates failures so a single test
/// run surfaces every regression at once.
pub fn all_v4_query_cases_test() {
  let assert Ok(entries) = simplifile.read_directory(v4_suite_root)
  let cases = list.sort(entries, by: string.compare)

  // Guard: drop in case count would silently pass.
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

pub fn presigned_url_includes_session_token_when_present_test() {
  // Session-token credentials extend the credential scope query
  // params with X-Amz-Security-Token. The token is URL-encoded as
  // a component (slashes / `+` / `=` become %2F / %2B / %3D).
  let creds =
    sigv4.SigningCredentials(
      access_key_id: "AKIDEXAMPLE",
      secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
      session_token: Some("session/token+with=special"),
    )
  let opts =
    sigv4.SigningOptions(
      timestamp: "20150830T123600Z",
      region: "us-east-1",
      service: "service",
      normalize_path: True,
      sign_body: False,
      omit_session_token: False,
    )
  let req =
    HttpRequest(
      method: "GET",
      path: "/",
      query: "",
      headers: [Header(name: "Host", value: "example.amazonaws.com")],
      body: <<>>,
    )
  let url = sigv4.presigned_url(req, creds, opts, 60, None)
  string.contains(url, "X-Amz-Security-Token=session%2Ftoken%2Bwith%3Dspecial")
  |> should.be_true
}

