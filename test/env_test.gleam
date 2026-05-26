//// Tests for `aws/env`.

import aws/env
import gleeunit/should

pub fn get_env_reads_present_var_test() {
  // PATH is present in any spawned process.
  env.get_env("PATH") |> should.be_ok
}

pub fn get_env_missing_var_is_error_test() {
  env.get_env("AWS_GLEAM_NO_SUCH_VAR_42") |> should.equal(Error(Nil))
}
