//// Leveled logging for the SDK runtime.
////
//// Quiet by default, a firehose on demand (see `PHILOSOPHY.md` and the
//// `Logging` section of `RULES.md`). The SDK says nothing on the happy
//// path and only what an operator must see when something fails; turn the
//// logger up to `debug` and it narrates both paths in full.
////
//// This is a thin pass-through to OTP `logger` (via `aws_log_ffi`) — the
//// idiomatic BEAM mechanism, mirroring how the AWS Rust SDK leaves the sink
//// to the application. There is no SDK-specific level knob: the operator
//// configures verbosity and destination the standard way.
////
////   - Levels — the logger's primary level gates everything. It defaults to
////     `notice`, under which `error` and `warning` are shown and `debug` is
////     hidden. Turn on the firehose with, e.g.,
////     `logger:set_primary_config(level, debug)` or a `kernel` `sys.config`
////     entry. (Per-module control via `logger:set_module_level/2` also works
////     — SDK events are emitted from the `aws_log_ffi` module.)
////   - Destination — the logger's handler decides. The default handler writes
////     to standard_io (stdout); point it elsewhere (e.g. `standard_error`) via
////     the handler config if you prefer. The SDK installs no handler of its
////     own, so its lines pick up the host's formatter and routing.

/// Log at `debug` — the firehose, off unless the logger level is `debug`.
/// The message is a thunk so its (often expensive) construction is skipped
/// entirely when debug is not enabled.
pub fn debug(message: fn() -> String) -> Nil {
  emit_debug(message)
}

/// Log at `warning` — notable but recovered (a retry fired, a credential
/// provider was configured but failed). On by default (outranks `notice`).
pub fn warning(message: String) -> Nil {
  emit_warning(message)
}

/// Log at `error` — unrecoverable, operator-must-see (credential chain
/// exhausted, retries exhausted, the Lambda Runtime API gone fatal). Sparse,
/// and on by default (outranks `notice`).
pub fn error(message: String) -> Nil {
  emit_error(message)
}

@external(erlang, "aws_log_ffi", "emit_debug")
fn emit_debug(message: fn() -> String) -> Nil

@external(erlang, "aws_log_ffi", "emit_warning")
fn emit_warning(message: String) -> Nil

@external(erlang, "aws_log_ffi", "emit_error")
fn emit_error(message: String) -> Nil
