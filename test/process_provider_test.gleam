//// Unit tests for the credential_process provider.

import aws/credentials.{FetchFailed, NotConfigured}
import gleam/bit_array
import gleam/option.{None, Some}
import gleeunit/should

const happy_v1: String = "{\"Version\":1,\"AccessKeyId\":\"AKID-PROC\",\"SecretAccessKey\":\"SECRET-PROC\",\"SessionToken\":\"TOK-PROC\",\"Expiration\":\"2030-01-02T03:04:05Z\"}"

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
    credentials.from_process_with_runner(
      command: "/usr/local/bin/aws-creds-helper --profile dev",
      runner: runner_returning(0, happy_v1),
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.access_key_id |> should.equal("AKID-PROC")
  creds.secret_access_key |> should.equal("SECRET-PROC")
  creds.session_token |> should.equal(Some("TOK-PROC"))
  creds.expires_at |> should.equal(Some(1_893_553_445))
  creds.source |> should.equal("Process")
}

pub fn command_splits_into_program_and_args_test() {
  let assert_args = fn(program: String, args: List(String)) {
    program |> should.equal("/usr/bin/myhelper")
    args |> should.equal(["--flag", "value", "--other"])
    Ok(#(0, bit_array.from_string(happy_v1)))
  }
  let provider =
    credentials.from_process_with_runner(
      command: "/usr/bin/myhelper --flag value --other",
      runner: assert_args,
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn multiple_spaces_collapse_test() {
  // Defensive — make sure messed-up profile entries don't produce empty argv
  // entries.
  let runner = fn(program: String, args: List(String)) {
    program |> should.equal("prog")
    args |> should.equal(["a", "b"])
    Ok(#(0, bit_array.from_string(happy_v1)))
  }
  let provider =
    credentials.from_process_with_runner(
      command: "prog   a    b",
      runner: runner,
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn empty_command_is_not_configured_test() {
  let provider =
    credentials.from_process_with_runner(
      command: "   ",
      runner: runner_returning(0, happy_v1),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured"
  }
}

pub fn runner_failure_is_not_configured_test() {
  let provider =
    credentials.from_process_with_runner(
      command: "/missing/path",
      runner: runner_failing(),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured when command can't launch"
  }
}

pub fn nonzero_exit_is_fetch_failed_test() {
  let provider =
    credentials.from_process_with_runner(
      command: "/bin/false",
      runner: runner_returning(1, ""),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for non-zero exit"
  }
}

pub fn malformed_stdout_is_fetch_failed_test() {
  let provider =
    credentials.from_process_with_runner(
      command: "/usr/bin/whatever",
      runner: runner_returning(0, "not json"),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for malformed JSON"
  }
}

pub fn unsupported_version_is_fetch_failed_test() {
  let provider =
    credentials.from_process_with_runner(
      command: "/usr/bin/whatever",
      runner: runner_returning(
        0,
        "{\"Version\":2,\"AccessKeyId\":\"AKID\",\"SecretAccessKey\":\"SECRET\"}",
      ),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for non-Version-1 output"
  }
}

pub fn missing_session_token_and_expiry_treated_as_non_expiring_test() {
  let provider =
    credentials.from_process_with_runner(
      command: "/usr/bin/whatever",
      runner: runner_returning(
        0,
        "{\"Version\":1,\"AccessKeyId\":\"AKID\",\"SecretAccessKey\":\"SECRET\"}",
      ),
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.session_token |> should.equal(None)
  creds.expires_at |> should.equal(None)
}

// ----- profile-resolution tests -----

pub fn profile_resolved_from_config_file_test() {
  let config =
    "[profile dev]
credential_process = /usr/local/bin/get-creds --profile dev
"
  let runner = fn(program: String, args: List(String)) {
    program |> should.equal("/usr/local/bin/get-creds")
    args |> should.equal(["--profile", "dev"])
    Ok(#(0, bit_array.from_string(happy_v1)))
  }
  let provider =
    credentials.from_process_with_env(
      profile: "dev",
      config_reader: fn() { Ok(config) },
      credentials_reader: fn() { Error(Nil) },
      runner: runner,
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn profile_falls_back_to_credentials_file_test() {
  let creds_file =
    "[dev]
credential_process = /usr/local/bin/get-creds --legacy
"
  let runner = fn(program: String, args: List(String)) {
    program |> should.equal("/usr/local/bin/get-creds")
    args |> should.equal(["--legacy"])
    Ok(#(0, bit_array.from_string(happy_v1)))
  }
  let provider =
    credentials.from_process_with_env(
      profile: "dev",
      config_reader: fn() { Error(Nil) },
      credentials_reader: fn() { Ok(creds_file) },
      runner: runner,
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn missing_credential_process_setting_is_not_configured_test() {
  let provider =
    credentials.from_process_with_env(
      profile: "dev",
      config_reader: fn() { Ok("[profile dev]\nregion = us-east-1\n") },
      credentials_reader: fn() { Error(Nil) },
      runner: fn(_, _) { panic as "runner must not be invoked" },
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured when credential_process unset"
  }
}
