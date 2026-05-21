//// Smoke tests for the default credential provider chain. The individual
//// providers have their own dedicated test files; here we only verify that
//// they're composed in the documented precedence order and that the
//// resulting Provider behaves like any other chain.

import aws/credentials.{ChainExhausted}
import aws/internal/http_send.{type HttpError}
import gleam/bit_array
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/string
import gleeunit/should

fn always_unreachable(
  _req: Request(BitArray),
) -> Result(response.Response(BitArray), HttpError) {
  Error(http_send.ConnectFailed(reason: "no network in tests"))
}

fn empty_env(_name: String) -> Result(String, Nil) {
  Error(Nil)
}

fn no_files(_path: String) -> Result(String, Nil) {
  Error(Nil)
}

fn no_runner(
  _command: String,
  _args: List(String),
) -> Result(#(Int, BitArray), Nil) {
  Error(Nil)
}

fn unconfigured_chain() -> credentials.Provider {
  credentials.default_chain_with(
    send: always_unreachable,
    imds_send: always_unreachable,
    profile: "default",
    env: empty_env,
    read_file: no_files,
    runner: no_runner,
  )
}

pub fn default_chain_has_name_chain_test() {
  let provider = unconfigured_chain()
  provider.name |> should.equal("Chain")
}

pub fn default_chain_exhausts_with_all_eight_providers_in_order_test() {
  // Every seam refuses (no env, no files, no subprocess, no network), so
  // every provider should fail; the exhausted attempt log lets us assert
  // the canonical order without needing any provider to actually succeed.
  let provider = unconfigured_chain()
  let assert Error(ChainExhausted(attempts: attempts)) =
    credentials.fetch(provider)

  // Pull the provider names out of the attempt log.
  let names = list_map_first(attempts)

  // Length tells us we composed 8 providers; the order tells us we
  // composed them in the right sequence. AwsCli sits before ECS because
  // it's the catch-all for CLI-only auth flows (Identity Center, etc.);
  // ECS / IMDS are reserved for compute-platform metadata services.
  names
  |> should.equal([
    "Environment",
    "WebIdentity",
    "SSO(default)",
    "Profile(default)",
    "Process(default)",
    "AwsCli(default)",
    "ECS",
    "IMDSv2",
  ])
}

pub fn default_chain_resolves_through_aws_cli_when_native_providers_fall_through_test() {
  // Native env/web-identity/SSO/profile/process all decline (no env, no
  // files, no subprocess for `credential_process`). The CLI fallback's
  // runner returns the canonical `aws configure export-credentials
  // --format process` JSON payload — the chain should land on the CLI
  // creds and return them as `AwsCli(default)`-sourced.
  let aws_cli_json =
    "{\"Version\": 1, \"AccessKeyId\": \"CLI-AKID\", "
    <> "\"SecretAccessKey\": \"cli-secret\", "
    <> "\"SessionToken\": \"cli-session\", "
    <> "\"Expiration\": \"2026-01-01T00:00:00Z\"}"
  // `process_provider.fetch` splits the command line on whitespace into
  // (program, args), so we get cmd="aws" and args=["configure",
  // "export-credentials", ...] — assert on the joined form so the test
  // doesn't bind to the splitter's exact behaviour.
  let cli_runner = fn(cmd: String, args: List(String)) {
    let joined = string.join([cmd, ..args], " ")
    case string.contains(joined, "aws configure export-credentials") {
      True -> Ok(#(0, bit_array.from_string(aws_cli_json)))
      False -> Error(Nil)
    }
  }
  let provider =
    credentials.default_chain_with(
      send: always_unreachable,
      imds_send: always_unreachable,
      profile: "default",
      env: empty_env,
      read_file: no_files,
      runner: cli_runner,
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.access_key_id |> should.equal("CLI-AKID")
  creds.source |> should.equal("AwsCli(default)")
}

fn list_map_first(
  pairs: List(#(String, credentials.ProviderError)),
) -> List(String) {
  case pairs {
    [] -> []
    [#(name, _), ..rest] -> [name, ..list_map_first(rest)]
  }
}
