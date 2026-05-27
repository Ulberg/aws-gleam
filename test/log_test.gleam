//// Smoke tests for `aws/internal/log`. It's a thin pass-through to OTP
//// `logger` — verbosity and destination are the operator's to configure, so
//// there's no pure gate logic to assert here. These confirm the FFI bindings
//// are wired (arity, the `debug` thunk form) and that a log call returns `Nil`
//// without crashing the caller. At the default logger level `debug` is
//// suppressed, so the debug thunk is not evaluated — hence it is safe for the
//// thunk to be arbitrarily expensive.

import aws/internal/log
import gleeunit/should

pub fn debug_is_callable_test() {
  log.debug(fn() { "debug smoke" }) |> should.equal(Nil)
}

pub fn warning_is_callable_test() {
  log.warning("warning smoke") |> should.equal(Nil)
}

pub fn error_is_callable_test() {
  log.error("error smoke") |> should.equal(Nil)
}
