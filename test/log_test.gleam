//// Tests for the leveled-logger gate (`aws/internal/log`). Only the pure
//// surface is exercised here — level parsing, the severity threshold, and
//// env resolution. The emit side effects through OTP `logger` are a thin
//// FFI shim verified separately; what matters for correctness is that the
//// gate admits exactly the right levels.

import aws/internal/log
import gleeunit/should

// ----- parse_level: case- and whitespace-insensitive, lenient default -----

pub fn parse_level_debug_test() {
  log.parse_level("debug") |> should.equal(log.DebugLevel)
}

pub fn parse_level_is_case_insensitive_test() {
  log.parse_level("Debug") |> should.equal(log.DebugLevel)
  log.parse_level("DEBUG") |> should.equal(log.DebugLevel)
}

pub fn parse_level_trims_whitespace_test() {
  log.parse_level("  debug  ") |> should.equal(log.DebugLevel)
}

pub fn parse_level_warning_aliases_test() {
  log.parse_level("warn") |> should.equal(log.WarningLevel)
  log.parse_level("warning") |> should.equal(log.WarningLevel)
}

pub fn parse_level_error_test() {
  log.parse_level("error") |> should.equal(log.ErrorLevel)
}

pub fn parse_level_silent_aliases_test() {
  log.parse_level("silent") |> should.equal(log.SilentLevel)
  log.parse_level("none") |> should.equal(log.SilentLevel)
  log.parse_level("off") |> should.equal(log.SilentLevel)
}

pub fn parse_level_unknown_falls_back_to_warning_test() {
  log.parse_level("") |> should.equal(log.WarningLevel)
  log.parse_level("verbose") |> should.equal(log.WarningLevel)
}

// ----- should_log: rank(message) >= rank(threshold) -----

pub fn should_log_debug_threshold_admits_everything_test() {
  should.be_true(log.should_log(
    threshold: log.DebugLevel,
    message: log.DebugLevel,
  ))
  should.be_true(log.should_log(
    threshold: log.DebugLevel,
    message: log.WarningLevel,
  ))
  should.be_true(log.should_log(
    threshold: log.DebugLevel,
    message: log.ErrorLevel,
  ))
}

pub fn should_log_warning_threshold_drops_debug_test() {
  should.be_false(log.should_log(
    threshold: log.WarningLevel,
    message: log.DebugLevel,
  ))
  should.be_true(log.should_log(
    threshold: log.WarningLevel,
    message: log.WarningLevel,
  ))
  should.be_true(log.should_log(
    threshold: log.WarningLevel,
    message: log.ErrorLevel,
  ))
}

pub fn should_log_error_threshold_only_admits_error_test() {
  should.be_false(log.should_log(
    threshold: log.ErrorLevel,
    message: log.DebugLevel,
  ))
  should.be_false(log.should_log(
    threshold: log.ErrorLevel,
    message: log.WarningLevel,
  ))
  should.be_true(log.should_log(
    threshold: log.ErrorLevel,
    message: log.ErrorLevel,
  ))
}

pub fn should_log_silent_threshold_drops_everything_test() {
  should.be_false(log.should_log(
    threshold: log.SilentLevel,
    message: log.DebugLevel,
  ))
  should.be_false(log.should_log(
    threshold: log.SilentLevel,
    message: log.WarningLevel,
  ))
  should.be_false(log.should_log(
    threshold: log.SilentLevel,
    message: log.ErrorLevel,
  ))
}

// ----- resolve_level: reads LOGLEVEL, defaults when unset -----

pub fn resolve_level_reads_loglevel_test() {
  log.resolve_level(fn(name) {
    case name {
      "LOGLEVEL" -> Ok("debug")
      _ -> Error(Nil)
    }
  })
  |> should.equal(log.DebugLevel)
}

pub fn resolve_level_defaults_to_warning_when_unset_test() {
  log.resolve_level(fn(_) { Error(Nil) })
  |> should.equal(log.WarningLevel)
}
