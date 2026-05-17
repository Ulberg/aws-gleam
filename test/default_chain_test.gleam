//// Smoke tests for the default credential provider chain. The individual
//// providers have their own dedicated test files; here we only verify that
//// they're composed in the documented precedence order and that the
//// resulting Provider behaves like any other chain.

import aws/credentials.{ChainExhausted}
import aws/internal/http_send.{type HttpError}
import gleam/http/request.{type Request}
import gleam/http/response
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

pub fn default_chain_exhausts_with_all_seven_providers_in_order_test() {
  // Every seam refuses (no env, no files, no subprocess, no network), so
  // every provider should fail; the exhausted attempt list lets us assert
  // the canonical order without needing any provider to actually succeed.
  let provider = unconfigured_chain()
  let assert Error(ChainExhausted(attempts: attempts)) =
    credentials.fetch(provider)

  // Pull the provider names out of the attempt log.
  let names = list_map_first(attempts)

  // Length tells us we composed 7 providers; the order tells us we composed
  // them in the right sequence.
  names
  |> should.equal([
    "Environment",
    "WebIdentity",
    "SSO(default)",
    "Profile(default)",
    "Process(default)",
    "ECS",
    "IMDSv2",
  ])
}

fn list_map_first(
  pairs: List(#(String, credentials.ProviderError)),
) -> List(String) {
  case pairs {
    [] -> []
    [#(name, _), ..rest] -> [name, ..list_map_first(rest)]
  }
}
