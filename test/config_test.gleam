//// Unit tests for `config.resolve` — the `Settings` → `ClientConfig`
//// mapping every generated `new_with` delegates to. Region resolution
//// itself is covered by `region_test.gleam`; here we pin that each
//// `Settings` field lands on the right `ClientConfig` field, using an
//// explicit region so the resolution step can't fail.

import aws/config
import aws/credentials
import aws/endpoints
import aws/internal/client/runtime
import gleam/dict
import gleam/option.{None, Some}
import gleeunit/should

fn static_provider() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "secret",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

fn resolve(settings: config.Settings) -> runtime.ClientConfig {
  let assert Ok(cfg) =
    config.resolve(settings, endpoint_prefix: "s3", signing_name: "s3")
  cfg
}

fn with_region() -> config.Settings {
  config.Settings(..config.default_settings(), region: Some("us-east-1"))
}

pub fn explicit_region_passes_through_test() {
  let cfg = resolve(with_region())
  cfg.region |> should.equal("us-east-1")
  cfg.endpoint_prefix |> should.equal("s3")
  cfg.signing_name |> should.equal("s3")
}

pub fn defaults_leave_the_runtime_defaults_intact_test() {
  let cfg = resolve(with_region())
  // No endpoint override → the static regional URL.
  cfg.endpoint_url |> should.equal("https://s3.us-east-1.amazonaws.com")
  // No SigV4a opt-in, no endpoint params.
  cfg.sigv4a_signer |> should.equal(None)
  dict.size(cfg.endpoint_params) |> should.equal(0)
  // Default credentials = the standard chain.
  cfg.provider.name |> should.equal("Chain")
}

pub fn custom_credentials_override_the_chain_test() {
  let cfg =
    resolve(
      config.Settings(..with_region(), credentials: Some(static_provider())),
    )
  cfg.provider.name |> should.equal("Static")
}

pub fn endpoint_url_override_is_applied_test() {
  let cfg =
    resolve(
      config.Settings(
        ..with_region(),
        endpoint_url: Some("http://localhost:4566"),
      ),
    )
  cfg.endpoint_url |> should.equal("http://localhost:4566")
}

pub fn use_fips_and_dual_stack_land_in_endpoint_params_test() {
  let cfg =
    resolve(
      config.Settings(
        ..with_region(),
        use_fips: Some(True),
        use_dual_stack: Some(False),
      ),
    )
  dict.get(cfg.endpoint_params, "UseFIPS")
  |> should.equal(Ok(endpoints.BoolVal(True)))
  dict.get(cfg.endpoint_params, "UseDualStack")
  |> should.equal(Ok(endpoints.BoolVal(False)))
}

pub fn sigv4a_region_set_attaches_the_signer_test() {
  let cfg =
    resolve(
      config.Settings(
        ..with_region(),
        sigv4a_region_set: Some(["us-east-1", "us-west-2"]),
        sigv4a_normalize_path: False,
      ),
    )
  cfg.sigv4a_signer
  |> should.equal(
    Some(runtime.Sigv4aSigner(
      region_set: ["us-east-1", "us-west-2"],
      normalize_path: False,
    )),
  )
}

pub fn sigv4a_normalize_path_is_noop_without_region_set_test() {
  // `normalize_path` only matters once `region_set` opts into SigV4a.
  let cfg =
    resolve(config.Settings(..with_region(), sigv4a_normalize_path: False))
  cfg.sigv4a_signer |> should.equal(None)
}

pub fn bool_param_and_string_param_build_tagged_entries_test() {
  config.bool_param("ForcePathStyle", True)
  |> should.equal(#("ForcePathStyle", endpoints.BoolVal(True)))
  config.string_param("Mode", "fast")
  |> should.equal(#("Mode", endpoints.StringVal("fast")))
}
