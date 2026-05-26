//// OS environment-variable access.
////
//// A typed wrapper over Erlang's `os:getenv/1`: `Ok(value)` when the
//// variable is set, `Error(Nil)` when it is not. The credential chain and
//// region resolver read the environment internally; this exposes the same
//// accessor for application code — for example a Lambda handler reading its
//// configured `MY_BUCKET` / `MY_TABLE` without hand-rolling an FFI.

/// Read an OS environment variable, returning `Error(Nil)` if it is unset.
/// (`os:getenv/1` deals in charlists; this bridges to/from Gleam `String`
/// and maps the unset miss to `Error(Nil)`.)
@external(erlang, "aws_ffi", "get_env")
pub fn get_env(name: String) -> Result(String, Nil)
