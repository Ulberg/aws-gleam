//// Run an external command and capture its stdout + exit status. Used by
//// the credential-process provider; not a general-purpose subprocess
//// library. Arguments are passed as an explicit list (no shell), so there
//// is no shell-injection surface on the call side.

/// Run `command` with the given argument list. Returns the exit code paired
/// with the captured combined stdout + stderr on success, or `Error(Nil)` if
/// the executable could not be located or launched.
@external(erlang, "aws_ffi", "run_process")
pub fn run(command: String, args: List(String)) -> Result(#(Int, BitArray), Nil)
