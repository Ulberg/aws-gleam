//// Verifies endpoint-rule-set parameters thread from `config.Settings`
//// into the runtime `ClientConfig`'s `endpoint_params` dict. The two
//// universal built-ins (`UseFIPS`, `UseDualStack`) have typed Settings
//// fields; service-specific ones (S3's `ForcePathStyle`, …) flow through
//// the generic `endpoint_params` list via `config.bool_param` /
//// `config.string_param`. Pins the S3 surface (the largest builtIn set
//// in the corpus): every supplied param lands under its wire name with
//// a `Value` of the right constructor.

import aws/config
import aws/endpoints
import aws/internal/client/runtime
import aws/services/s3
import gleam/dict
import gleam/option.{Some}
import gleeunit/should

/// Build an S3 client from `settings`, read its resolved config, then
/// release the cache actor. The config is an immutable value, so reading
/// it after shutdown is safe.
fn config_for(settings: config.Settings) -> runtime.ClientConfig {
  let assert Ok(client) = s3.new_with(settings)
  let cfg = s3.client_config(client)
  s3.shutdown(client)
  cfg
}

fn base() -> config.Settings {
  config.Settings(..config.default_settings(), region: Some("us-east-1"))
}

pub fn use_fips_threads_bool_through_endpoint_params_test() {
  let cfg = config_for(config.Settings(..base(), use_fips: Some(True)))
  dict.get(cfg.endpoint_params, "UseFIPS")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}

pub fn use_dual_stack_threads_bool_through_endpoint_params_test() {
  let cfg = config_for(config.Settings(..base(), use_dual_stack: Some(True)))
  dict.get(cfg.endpoint_params, "UseDualStack")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}

pub fn service_specific_param_threads_through_endpoint_params_test() {
  let cfg =
    config_for(
      config.Settings(..base(), endpoint_params: [
        config.bool_param("ForcePathStyle", True),
      ]),
    )
  dict.get(cfg.endpoint_params, "ForcePathStyle")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}

pub fn omitted_params_are_absent_test() {
  // `None` / empty leaves nothing in the dict — the rule set's own
  // defaults then apply at resolution time.
  let cfg = config_for(base())
  dict.get(cfg.endpoint_params, "UseFIPS") |> should.equal(Error(Nil))
  dict.get(cfg.endpoint_params, "ForcePathStyle") |> should.equal(Error(Nil))
}

pub fn later_endpoint_param_overrides_earlier_test() {
  // The list folds left-to-right with `dict.insert`, so a later entry
  // for the same key wins.
  let cfg =
    config_for(
      config.Settings(..base(), endpoint_params: [
        config.bool_param("ForcePathStyle", True),
        config.bool_param("ForcePathStyle", False),
      ]),
    )
  dict.get(cfg.endpoint_params, "ForcePathStyle")
  |> should.equal(Ok(endpoints.BoolVal(False)))
}

pub fn typed_and_generic_params_coexist_test() {
  let cfg =
    config_for(
      config.Settings(..base(), use_fips: Some(True), endpoint_params: [
        config.bool_param("ForcePathStyle", True),
      ]),
    )
  dict.get(cfg.endpoint_params, "UseFIPS")
  |> should.equal(Ok(endpoints.BoolVal(True)))
  dict.get(cfg.endpoint_params, "ForcePathStyle")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}

pub fn string_param_helper_threads_through_test() {
  let cfg =
    config_for(
      config.Settings(..base(), endpoint_params: [
        config.string_param("MyKnob", "on"),
      ]),
    )
  dict.get(cfg.endpoint_params, "MyKnob")
  |> should.equal(Ok(endpoints.StringVal("on")))
}
