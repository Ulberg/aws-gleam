//// Unit tests for the AWS CLI export-credentials provider.

import aws/credentials.{FetchFailed, NotConfigured}
import gleam/bit_array
import gleam/option.{Some}
import gleam/string
import gleeunit/should

const happy_v1: String = "{\"Version\":1,\"AccessKeyId\":\"AKID-CLI\",\"SecretAccessKey\":\"SECRET-CLI\",\"SessionToken\":\"TOK-CLI\",\"Expiration\":\"2030-01-02T03:04:05Z\"}"

fn runner_returning(
  exit: Int,
  stdout: String,
) -> fn(String, List(String)) -> Result(#(Int, BitArray), Nil) {
  fn(_program, _args) { Ok(#(exit, bit_array.from_string(stdout))) }
}

fn runner_failing() -> fn(String, List(String)) -> Result(#(Int, BitArray), Nil) {
  fn(_program, _args) { Error(Nil) }
}

pub fn happy_path_returns_credentials_test() {
  let provider =
    credentials.from_aws_cli_with(
      profile: "default",
      runner: runner_returning(0, happy_v1),
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.access_key_id |> should.equal("AKID-CLI")
  creds.secret_access_key |> should.equal("SECRET-CLI")
  creds.session_token |> should.equal(Some("TOK-CLI"))
  creds.expires_at |> should.equal(Some(1_893_553_445))
  creds.source |> should.equal("AwsCli(default)")
}

pub fn correct_command_is_built_test() {
  let assert_command = fn(program: String, args: List(String)) {
    program |> should.equal("aws")
    args
    |> should.equal([
      "configure",
      "export-credentials",
      "--profile",
      "prod",
      "--format",
      "process",
    ])
    Ok(#(0, bit_array.from_string(happy_v1)))
  }
  let provider =
    credentials.from_aws_cli_with(profile: "prod", runner: assert_command)
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn aws_binary_missing_is_not_configured_test() {
  let provider =
    credentials.from_aws_cli_with(profile: "default", runner: runner_failing())
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured when aws binary not found"
  }
}

pub fn nonzero_exit_is_fetch_failed_test() {
  // E.g. "the SSO session is expired; run aws sso login".
  let provider =
    credentials.from_aws_cli_with(
      profile: "default",
      runner: runner_returning(255, ""),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for non-zero exit"
  }
}

pub fn malformed_output_is_fetch_failed_test() {
  let provider =
    credentials.from_aws_cli_with(
      profile: "default",
      runner: runner_returning(0, "not json"),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for malformed JSON"
  }
}

pub fn profile_name_appears_in_source_test() {
  let assert Ok(out) =
    credentials.from_aws_cli_with(
      profile: "my-special-profile",
      runner: runner_returning(0, happy_v1),
    )
    |> credentials.fetch
  string.contains(out.source, "my-special-profile") |> should.be_true
}
