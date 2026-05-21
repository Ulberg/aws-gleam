//// Credential-process provider. Runs an external command and reads JSON
//// credentials from its standard output, per the AWS CLI's
//// `credential_process` spec.
////
//// Expected output:
////   {
////     "Version": 1,
////     "AccessKeyId": "...",
////     "SecretAccessKey": "...",
////     "SessionToken": "...",        // optional
////     "Expiration": "ISO 8601 Z"    // optional; absent = non-expiring
////   }

import aws/internal/datetime
import gleam/bit_array
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

pub type Runner =
  fn(String, List(String)) -> Result(#(Int, BitArray), Nil)

pub type ProcessCredentials {
  ProcessCredentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
    expires_at: Option(Int),
  )
}

pub type Error {
  /// We could not even start the configured command.
  LaunchFailed(reason: String)
  /// The command ran but produced an unexpected exit code or output.
  BadOutput(reason: String)
}

/// Run the given command line and decode its stdout as credential-process
/// JSON. `command` is the verbatim string from `credential_process`; we
/// split it on whitespace into program + arguments before launch.
pub fn fetch(
  runner: Runner,
  command: String,
) -> Result(ProcessCredentials, Error) {
  use #(program, args) <- result.try(
    split_command(command)
    |> result.replace_error(LaunchFailed(
      reason: "empty credential_process command",
    )),
  )
  use #(exit, stdout) <- result.try(
    runner(program, args)
    |> result.replace_error(LaunchFailed(
      reason: "could not run '" <> program <> "'",
    )),
  )
  case exit {
    0 -> decode_credentials(stdout)
    code ->
      Error(BadOutput(
        reason: "credential_process exited with status " <> int.to_string(code),
      ))
  }
}

fn split_command(command: String) -> Result(#(String, List(String)), Nil) {
  let parts =
    command
    |> string.split(" ")
    |> list_filter(fn(s) { s != "" })
  case parts {
    [] -> Error(Nil)
    [program, ..args] -> Ok(#(program, args))
  }
}

fn list_filter(xs: List(a), keep: fn(a) -> Bool) -> List(a) {
  do_filter(xs, keep, [])
}

fn do_filter(xs: List(a), keep: fn(a) -> Bool, acc: List(a)) -> List(a) {
  case xs {
    [] -> list_reverse(acc)
    [h, ..t] ->
      case keep(h) {
        True -> do_filter(t, keep, [h, ..acc])
        False -> do_filter(t, keep, acc)
      }
  }
}

fn list_reverse(xs: List(a)) -> List(a) {
  do_reverse(xs, [])
}

fn do_reverse(xs: List(a), acc: List(a)) -> List(a) {
  case xs {
    [] -> acc
    [h, ..t] -> do_reverse(t, [h, ..acc])
  }
}

// ---- output decoding ----

type RawOutput {
  RawOutput(
    version: Int,
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
    expiration: Option(String),
  )
}

fn raw_decoder() -> decode.Decoder(RawOutput) {
  use version <- decode.field("Version", decode.int)
  use access_key_id <- decode.field("AccessKeyId", decode.string)
  use secret_access_key <- decode.field("SecretAccessKey", decode.string)
  use session_token <- decode.then(decode.optionally_at(
    ["SessionToken"],
    None,
    decode.map(decode.string, Some),
  ))
  use expiration <- decode.then(decode.optionally_at(
    ["Expiration"],
    None,
    decode.map(decode.string, Some),
  ))
  decode.success(RawOutput(
    version: version,
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token,
    expiration: expiration,
  ))
}

fn decode_credentials(stdout: BitArray) -> Result(ProcessCredentials, Error) {
  use text <- result.try(
    bit_array.to_string(stdout)
    |> result.replace_error(BadOutput(reason: "non-utf8 stdout")),
  )
  use raw <- result.try(
    json.parse(text, raw_decoder())
    |> result.map_error(fn(_) {
      BadOutput(reason: "stdout is not the expected credential_process JSON")
    }),
  )
  // AWS only ships Version 1 today; reject anything else loudly so a future
  // Version 2 doesn't get silently mis-parsed against the wrong schema.
  case raw.version {
    1 -> {
      let expires_at = case raw.expiration {
        Some(ts) ->
          case datetime.parse_iso8601(ts) {
            Ok(t) -> Some(t)
            Error(_) -> None
          }
        None -> None
      }
      Ok(ProcessCredentials(
        access_key_id: raw.access_key_id,
        secret_access_key: raw.secret_access_key,
        session_token: raw.session_token,
        expires_at: expires_at,
      ))
    }
    other ->
      Error(BadOutput(
        reason: "unsupported credential_process Version "
        <> int.to_string(other),
      ))
  }
}
