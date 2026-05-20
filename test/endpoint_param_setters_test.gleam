//// Verifies the typed per-service endpoint-rule-set parameter
//// setters emitted by the codegen (`v0.2 item 10`). For every
//// builtIn-flagged parameter in a service's
//// `smithy.rules#endpointRuleSet` trait, the Client section gains
//// a `with_<snake>` function that takes a typed `Bool` / `String`
//// and threads it through `runtime.with_endpoint_param` with the
//// correct `endpoints.BoolVal` / `endpoints.StringVal` constructor.
////
//// These tests pin the S3 surface (the service with the largest
//// builtIn parameter set in the v0.2 corpus) — the round-trip
//// covers: setter callable, returns Client, the underlying
//// `runtime.ClientConfig`'s `endpoint_params` dict gains the wire
//// name + a `Value` of the correct constructor.

import aws/endpoints
import aws/internal/client/runtime
import aws/services/s3
import gleam/dict
import gleeunit/should

fn fresh_client() -> s3.Client {
  s3.new(region: "us-east-1")
}

fn config(client: s3.Client) -> runtime.ClientConfig {
  s3.config(client)
}

pub fn with_force_path_style_threads_bool_through_endpoint_params_test() {
  let client = fresh_client() |> s3.with_force_path_style(True)
  let cfg = config(client)
  case dict.get(cfg.endpoint_params, "ForcePathStyle") {
    Ok(endpoints.BoolVal(True)) -> Nil
    other -> {
      let _ = other
      should.fail()
    }
  }
  s3.shutdown(client)
}

pub fn with_use_fips_threads_bool_through_endpoint_params_test() {
  let client = fresh_client() |> s3.with_use_fips(True)
  let cfg = config(client)
  case dict.get(cfg.endpoint_params, "UseFIPS") {
    Ok(endpoints.BoolVal(True)) -> Nil
    other -> {
      let _ = other
      should.fail()
    }
  }
  s3.shutdown(client)
}

pub fn with_use_dual_stack_threads_bool_through_endpoint_params_test() {
  let client = fresh_client() |> s3.with_use_dual_stack(True)
  let cfg = config(client)
  case dict.get(cfg.endpoint_params, "UseDualStack") {
    Ok(endpoints.BoolVal(True)) -> Nil
    other -> {
      let _ = other
      should.fail()
    }
  }
  s3.shutdown(client)
}

pub fn last_call_overrides_prior_value_test() {
  // Setter is a pure record-update — calling it twice on the same
  // Client should leave the second value in the dict.
  let client =
    fresh_client()
    |> s3.with_force_path_style(True)
    |> s3.with_force_path_style(False)
  let cfg = config(client)
  case dict.get(cfg.endpoint_params, "ForcePathStyle") {
    Ok(endpoints.BoolVal(False)) -> Nil
    other -> {
      let _ = other
      should.fail()
    }
  }
  s3.shutdown(client)
}

pub fn distinct_setters_coexist_test() {
  // Independent setters land under distinct keys; setting one
  // doesn't disturb another.
  let client =
    fresh_client()
    |> s3.with_use_fips(True)
    |> s3.with_force_path_style(True)
  let cfg = config(client)
  case
    dict.get(cfg.endpoint_params, "UseFIPS"),
    dict.get(cfg.endpoint_params, "ForcePathStyle")
  {
    Ok(endpoints.BoolVal(True)), Ok(endpoints.BoolVal(True)) -> Nil
    a, b -> {
      let _ = #(a, b)
      should.fail()
    }
  }
  s3.shutdown(client)
}
