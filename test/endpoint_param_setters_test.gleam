//// Verifies AWS endpoint-rule-set parameters thread from a service's
//// typed `EndpointParams` record into the runtime `ClientConfig`'s
//// `endpoint_params` dict. Pins the S3 surface (the largest builtIn set in
//// the corpus). The fields are per-service: a service whose rule set
//// doesn't declare a param has no field for it, so an unsupported knob is
//// a compile error rather than a silently-ignored string.

import aws/config
import aws/endpoints
import aws/internal/client/runtime
import aws/services/s3
import gleam/dict
import gleam/option.{Some}
import gleeunit/should

/// Build an S3 client from default customer settings + the given typed
/// `EndpointParams`, read its resolved config, then release the cache
/// actor. The config is an immutable value, so reading it after shutdown
/// is safe.
fn config_for(params: s3.EndpointParams) -> runtime.ClientConfig {
  let assert Ok(client) =
    s3.new_with(
      config.Settings(..config.default_settings(), region: Some("us-east-1")),
      params,
    )
  let cfg = s3.client_config(client)
  s3.shutdown(client)
  cfg
}

pub fn use_fips_threads_through_endpoint_params_test() {
  let cfg =
    config_for(
      s3.EndpointParams(..s3.default_endpoint_params(), use_fips: Some(True)),
    )
  dict.get(cfg.endpoint_params, "UseFIPS")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}

pub fn use_dual_stack_threads_through_endpoint_params_test() {
  let cfg =
    config_for(
      s3.EndpointParams(
        ..s3.default_endpoint_params(),
        use_dual_stack: Some(True),
      ),
    )
  dict.get(cfg.endpoint_params, "UseDualStack")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}

pub fn service_specific_param_threads_through_endpoint_params_test() {
  let cfg =
    config_for(
      s3.EndpointParams(
        ..s3.default_endpoint_params(),
        force_path_style: Some(True),
      ),
    )
  dict.get(cfg.endpoint_params, "ForcePathStyle")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}

pub fn defaults_leave_endpoint_params_empty_test() {
  // `default_endpoint_params()` sets every param to `None` → nothing lands
  // in the dict, so the rule set's own defaults apply at resolution time.
  let cfg = config_for(s3.default_endpoint_params())
  dict.get(cfg.endpoint_params, "UseFIPS") |> should.equal(Error(Nil))
  dict.get(cfg.endpoint_params, "ForcePathStyle") |> should.equal(Error(Nil))
}

pub fn multiple_params_coexist_test() {
  let cfg =
    config_for(
      s3.EndpointParams(
        ..s3.default_endpoint_params(),
        use_fips: Some(True),
        force_path_style: Some(True),
      ),
    )
  dict.get(cfg.endpoint_params, "UseFIPS")
  |> should.equal(Ok(endpoints.BoolVal(True)))
  dict.get(cfg.endpoint_params, "ForcePathStyle")
  |> should.equal(Ok(endpoints.BoolVal(True)))
}
