//// Customer-facing construction settings — the service-agnostic knobs
//// every `Client` is built from. AWS endpoint-rule-set parameters
//// (`UseFIPS`, `UseDualStack`, S3 `ForcePathStyle`, …) are NOT here:
//// they vary per service and live on each service's own typed
//// `EndpointParams` record, kept separate so customer config and AWS
//// rule-set attributes never mix.
////
//// Two construction entry points per service:
////   1. `<service>.new()` — full auto: region resolves from the standard
////      AWS sources, credentials from the default chain. Zero config.
////   2. `<service>.new_with(settings, endpoint_params)` — start each
////      record from its defaults and override only the fields you need:
////
////        import aws/config.{Settings, default_settings}
////        import aws/services/s3
////
////        let assert Ok(client) =
////          s3.new_with(
////            Settings(..default_settings(), region: Some("eu-west-1")),
////            s3.EndpointParams(..s3.default_endpoint_params(), use_fips: Some(True)),
////          )

import aws/credentials.{type Provider}
import aws/internal/client/runtime.{type ClientConfig}
import aws/internal/http_send.{type Send, type StreamingSend}
import aws/region
import aws/retry.{type Strategy}
import gleam/option.{type Option, None, Some}
import gleam/result

/// Declarative, service-agnostic settings for building a `Client`. Start
/// from `default_settings()` and override the fields you care about with a
/// record-update spread — see the module docs. AWS endpoint-rule-set
/// parameters are not here; they live on each service's `EndpointParams`.
pub type Settings {
  Settings(
    /// AWS region. `None` (the default) resolves it at build time from
    /// `AWS_REGION`, `AWS_DEFAULT_REGION`, then `~/.aws/config` under
    /// `profile`. `Some(r)` pins it explicitly.
    region: Option(String),
    /// Profile name used for both region and credential resolution.
    profile: String,
    /// Credentials provider. `None` (the default) uses the standard chain
    /// (env → web-identity → SSO → profile → process → ECS → IMDS).
    credentials: Option(Provider),
    /// Endpoint URL override (LocalStack, FIPS, custom DNS). `None` lets
    /// the service's Smithy endpoint rule set compute the URL.
    endpoint_url: Option(String),
    /// Retry attempt budget. `Some(1)` disables retries (one attempt per
    /// request); `None` keeps the standard 3-attempt strategy (or
    /// `retry_strategy`, when that is set).
    max_attempts: Option(Int),
    /// Full retry-strategy override. `None` keeps `retry.standard()`. When
    /// `max_attempts` is also set, the attempt budget is applied on top of
    /// this strategy.
    retry_strategy: Option(Strategy),
    /// Buffered HTTP transport override (test doubles, proxies). `None`
    /// uses the default httpc sender.
    http_send: Option(Send),
    /// Streaming HTTP transport override for `@streaming` operations.
    /// `None` uses the default chunked sender.
    streaming_http_send: Option(StreamingSend),
    /// Use the HTTP/2 streaming transport. Buffered requests are
    /// unaffected; peers that don't speak HTTP/2 negotiate down via ALPN.
    use_http2: Bool,
    /// Opt into SigV4a (asymmetric ECDSA P-256) signing: `Some(region_set)`
    /// becomes the `X-Amz-Region-Set` header — required for S3 Multi-Region
    /// Access Points. `None` uses SigV4.
    sigv4a_region_set: Option(List(String)),
    /// RFC-3986 dot-segment removal under SigV4a. Leave `True` for most
    /// services; S3 needs `False` so object keys with `.` / `..` survive
    /// the canonical-request step. No effect unless `sigv4a_region_set`
    /// is `Some`.
    sigv4a_normalize_path: Bool,
  )
}

/// The full-auto baseline: region + credentials resolve themselves and
/// every other knob keeps the runtime default. Spread this with a
/// record update and override only the fields you need.
pub fn default_settings() -> Settings {
  Settings(
    region: None,
    profile: "default",
    credentials: None,
    endpoint_url: None,
    max_attempts: None,
    retry_strategy: None,
    http_send: None,
    streaming_http_send: None,
    use_http2: False,
    sigv4a_region_set: None,
    sigv4a_normalize_path: True,
  )
}

/// Resolve `Settings` into a runtime `ClientConfig` for a service,
/// identified by its endpoint prefix + SigV4 signing name. The only
/// failure is region resolution when `region` is `None` and no source
/// supplies one; credentials stay lazy (the per-Client cache fetches them
/// on the first request), so a missing chain surfaces at call time, not
/// here.
///
/// Generated `new` / `new_with` call this, then apply the service's typed
/// `EndpointParams`, attach its endpoint rule set, and start the
/// credentials cache.
pub fn resolve(
  settings: Settings,
  endpoint_prefix endpoint_prefix: String,
  signing_name signing_name: String,
) -> Result(ClientConfig, region.ResolveError) {
  use resolved <- result.map(resolve_region(settings))
  let provider = case settings.credentials {
    Some(p) -> p
    None ->
      credentials.default_chain(
        send: http_send.default_send,
        profile: settings.profile,
      )
  }
  runtime.default_config(resolved, endpoint_prefix, signing_name)
  |> runtime.with_credentials_provider(provider)
  |> apply_endpoint_url(settings)
  |> apply_retry(settings)
  |> apply_transports(settings)
  |> apply_sigv4a(settings)
}

fn resolve_region(settings: Settings) -> Result(String, region.ResolveError) {
  case settings.region {
    Some(r) -> Ok(r)
    None -> region.resolve(profile: settings.profile)
  }
}

fn apply_endpoint_url(
  config: ClientConfig,
  settings: Settings,
) -> ClientConfig {
  case settings.endpoint_url {
    Some(url) -> runtime.with_endpoint_url(config, url)
    None -> config
  }
}

fn apply_retry(config: ClientConfig, settings: Settings) -> ClientConfig {
  let config = case settings.retry_strategy {
    Some(strategy) -> runtime.with_retry_strategy(config, strategy)
    None -> config
  }
  case settings.max_attempts {
    Some(n) -> runtime.with_max_attempts(config, n)
    None -> config
  }
}

fn apply_transports(config: ClientConfig, settings: Settings) -> ClientConfig {
  let config = case settings.http_send {
    Some(send) -> runtime.with_http_send(config, send)
    None -> config
  }
  let config = case settings.streaming_http_send {
    Some(send) -> runtime.with_streaming_http_send(config, send)
    None -> config
  }
  case settings.use_http2 {
    True -> runtime.with_http2(config)
    False -> config
  }
}

fn apply_sigv4a(config: ClientConfig, settings: Settings) -> ClientConfig {
  case settings.sigv4a_region_set {
    None -> config
    Some(region_set) ->
      runtime.with_sigv4a_region_set(config, region_set)
      |> runtime.with_sigv4a_path_normalization(settings.sigv4a_normalize_path)
  }
}
