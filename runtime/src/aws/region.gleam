//// Region resolution.
////
//// Precedence (matches go-v2 / Rust SDK):
////
////   1. `AWS_REGION` environment variable
////   2. `AWS_DEFAULT_REGION` environment variable
////   3. `region` setting in `~/.aws/config` under the active profile
////
//// Resolution from EC2 IMDS is not implemented — most workloads set
//// `AWS_REGION` explicitly, and the few that rely on IMDS region
//// auto-detection can call `from_imds` themselves and feed the result in.

import aws/env.{get_env}
import aws/internal/ini
import gleam/bit_array
import gleam/option.{type Option, None, Some}
import gleam/result

pub type ResolveError {
  /// No region found in any of the sources tried. The accompanying list
  /// records every source that was checked, in order, so an end-user log
  /// message can read like "tried AWS_REGION, AWS_DEFAULT_REGION,
  /// ~/.aws/config[profile=default]".
  NoRegion(sources_tried: List(String))
}

/// Resolve a region using the real OS env and `~/.aws/config`. Standard
/// production wiring.
pub fn resolve(profile profile: String) -> Result(String, ResolveError) {
  resolve_with(
    profile: profile,
    env_lookup: get_env,
    config_reader: read_default_config,
  )
}

/// Resolve a region with injectable env and config-file access — used by
/// tests, and available to callers that want to feed in their own sources.
pub fn resolve_with(
  profile profile: String,
  env_lookup env_lookup: fn(String) -> Result(String, Nil),
  config_reader config_reader: fn() -> Result(String, Nil),
) -> Result(String, ResolveError) {
  case try_env(env_lookup) {
    Some(region) -> Ok(region)
    None ->
      case try_config(config_reader, profile) {
        Some(region) -> Ok(region)
        None ->
          Error(
            NoRegion(sources_tried: [
              "AWS_REGION",
              "AWS_DEFAULT_REGION",
              "~/.aws/config[profile=" <> profile <> "].region",
            ]),
          )
      }
  }
}

fn try_env(lookup: fn(String) -> Result(String, Nil)) -> Option(String) {
  case non_empty(lookup("AWS_REGION")) {
    Some(r) -> Some(r)
    None -> non_empty(lookup("AWS_DEFAULT_REGION"))
  }
}

fn try_config(
  config_reader: fn() -> Result(String, Nil),
  profile: String,
) -> Option(String) {
  use text <- option_try(config_reader())
  use parsed <- option_try(ini.parse(text))
  let section = case profile {
    "default" -> "default"
    other -> "profile " <> other
  }
  non_empty(ini.get_property(parsed, section: section, key: "region"))
}

fn non_empty(result: Result(String, e)) -> Option(String) {
  case result {
    Ok(s) ->
      case s {
        "" -> None
        _ -> Some(s)
      }
    Error(_) -> None
  }
}

fn option_try(
  result: Result(a, e),
  then next: fn(a) -> Option(b),
) -> Option(b) {
  case result {
    Ok(value) -> next(value)
    Error(_) -> None
  }
}

// --- FFI wrapper, scoped to this module ---

@external(erlang, "aws_ffi", "read_file")
fn read_file_bits(path: String) -> Result(BitArray, Nil)

fn read_default_config() -> Result(String, Nil) {
  use home <- result.try(get_env("HOME"))
  use bits <- result.try(read_file_bits(home <> "/.aws/config"))
  bit_array.to_string(bits) |> result.replace_error(Nil)
}
