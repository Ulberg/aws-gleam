//// Tests for `aws/env`.

import aws/env
import gleeunit/should

@external(erlang, "aws_ffi", "set_env")
fn set_env(name: String, value: String) -> Nil

pub fn get_env_reads_present_var_test() {
  // PATH is present in any spawned process.
  env.get_env("PATH") |> should.be_ok
}

pub fn get_env_reads_utf8_value_test() {
  let name = "AWS_GLEAM_UTF8_ENV_TEST"
  let value = "folder "

  set_env(name, value)
  env.get_env(name) |> should.equal(Ok(value))
}

pub fn get_env_missing_var_is_error_test() {
  env.get_env("AWS_GLEAM_NO_SUCH_VAR_42") |> should.equal(Error(Nil))
}
