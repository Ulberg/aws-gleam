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

pub fn default_chain_has_name_chain_test() {
  let provider =
    credentials.default_chain(send: always_unreachable, profile: "default")
  provider.name |> should.equal("Chain")
}

pub fn default_chain_exhausts_with_all_seven_providers_in_order_test() {
  // No env / config / token files exist in the test process, and our send
  // refuses to reach anything. Every provider should fail; the exhausted
  // attempt list lets us assert the canonical order without needing any
  // provider to actually succeed.
  let provider =
    credentials.default_chain(send: always_unreachable, profile: "default")
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
