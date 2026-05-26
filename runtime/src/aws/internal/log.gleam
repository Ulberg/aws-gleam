//// Leveled logging for the SDK runtime.
////
//// Quiet by default, a firehose on demand (see `PHILOSOPHY.md` and the
//// `Logging` section of `RULES.md`). The SDK says nothing on the happy
//// path and only what an operator must see when something fails; switch
//// on `debug` and it narrates both paths in full.
////
//// The mechanism is OTP `logger` (via `aws_log_ffi`), but the verbosity
//// gate is owned here and resolved once from the `LOGLEVEL` environment
//// variable:
////
////   - unset / unrecognised → `WarningLevel`: `error` and `warning` emit,
////     `debug` is suppressed. This is the default-on, always-visible set.
////   - `LOGLEVEL=debug`      → `DebugLevel`: the firehose — `debug` too.
////   - `LOGLEVEL=error`      → `ErrorLevel`: only `error`.
////   - `LOGLEVEL=silent`     → `SilentLevel`: nothing (the opt-out; also
////     `none` / `off`).
////
//// `error` and `warning` are routed so they reach handlers regardless of
//// the logger's primary level, so the always-on contract holds even under
//// a host that has raised the primary level. `LOGLEVEL=silent` is the way
//// to quiet the SDK completely.
////
//// The level is read once and cached for the lifetime of the VM, so
//// changing `LOGLEVEL` after the first log has no effect — the standard
//// resolve-at-startup behaviour every leveled logger follows.

import aws/env
import gleam/string

/// SDK log levels, in increasing severity. `SilentLevel` is a threshold
/// only (never emitted): selecting it suppresses every level.
///
/// The variants carry the `Level` suffix because a bare `Error` would
/// collide with the prelude's `Result` constructor of the same name.
pub type Level {
  DebugLevel
  WarningLevel
  ErrorLevel
  SilentLevel
}

/// Level used when `LOGLEVEL` is unset or unrecognised. `WarningLevel`
/// keeps `error` + `warning` always-on (sparse, operator-must-see) while
/// leaving the `debug` firehose off until explicitly requested.
const default_level: Level = WarningLevel

/// Severity rank. A message at level `m` is emitted when
/// `rank(m) >= rank(configured_threshold)`. `SilentLevel`'s rank sits above
/// any real message level, so selecting it drops everything.
fn rank(level: Level) -> Int {
  case level {
    DebugLevel -> 10
    WarningLevel -> 20
    ErrorLevel -> 30
    SilentLevel -> 40
  }
}

/// Would a `message`-level event be emitted under the given `threshold`?
/// Pure; exposed for tests.
pub fn should_log(threshold threshold: Level, message message: Level) -> Bool {
  rank(message) >= rank(threshold)
}

/// Parse a `LOGLEVEL` value (case- and whitespace-insensitive). Anything
/// unrecognised falls back to `default_level` rather than failing — a typo
/// in an env var should not crash the caller's first AWS request. Pure;
/// exposed for tests.
pub fn parse_level(raw: String) -> Level {
  case string.lowercase(string.trim(raw)) {
    "debug" -> DebugLevel
    "warn" | "warning" -> WarningLevel
    "error" -> ErrorLevel
    "silent" | "none" | "off" -> SilentLevel
    _ -> default_level
  }
}

/// Resolve the threshold from an injected env lookup. Pure given `lookup`;
/// exposed for tests. Production uses `level/0`, which threads `env.get_env`
/// and caches the result.
pub fn resolve_level(lookup: fn(String) -> Result(String, Nil)) -> Level {
  case lookup("LOGLEVEL") {
    Ok(raw) -> parse_level(raw)
    Error(_) -> default_level
  }
}

/// The configured threshold, resolved once from `LOGLEVEL` and cached.
fn level() -> Level {
  case cached_level() {
    Ok(cached) -> cached
    Error(_) -> {
      let resolved = resolve_level(env.get_env)
      store_level(resolved)
      resolved
    }
  }
}

/// Is the `debug` firehose on? Lets hot-path callers skip building an
/// expensive message even before the thunk in `debug/1`.
pub fn debug_enabled() -> Bool {
  should_log(threshold: level(), message: DebugLevel)
}

/// Log at `debug` — the firehose, gated off unless `LOGLEVEL=debug`. The
/// message is a thunk so its (often expensive) construction is skipped
/// entirely when debug is off.
pub fn debug(message: fn() -> String) -> Nil {
  case debug_enabled() {
    True -> emit("debug", message())
    False -> Nil
  }
}

/// Log at `warning` — notable but recovered (a retry fired, a credential
/// provider was configured but failed). Default-on.
pub fn warning(message: String) -> Nil {
  case should_log(threshold: level(), message: WarningLevel) {
    True -> emit("warning", message)
    False -> Nil
  }
}

/// Log at `error` — unrecoverable, operator-must-see (credential chain
/// exhausted, retries exhausted, the Lambda Runtime API gone fatal).
/// Default-on and sparse.
pub fn error(message: String) -> Nil {
  case should_log(threshold: level(), message: ErrorLevel) {
    True -> emit("error", message)
    False -> Nil
  }
}

/// Emit through OTP `logger`. `tag` is `"debug"` | `"warning"` | `"error"`;
/// the caller has already passed the `LOGLEVEL` gate.
@external(erlang, "aws_log_ffi", "emit")
fn emit(tag: String, message: String) -> Nil

@external(erlang, "aws_log_ffi", "cached_level")
fn cached_level() -> Result(Level, Nil)

@external(erlang, "aws_log_ffi", "cache_level")
fn store_level(level: Level) -> Nil
