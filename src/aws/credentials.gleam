//// Credentials and credential providers.
////
//// A `Provider` is a thin record wrapping a fetch function; providers compose
//// into a `chain` that returns the first success and reports every attempt
//// when it exhausts. The actual provider implementations (static, env,
//// profile, IMDS, ECS, STS web identity, SSO, process) live in
//// `aws/internal/providers/*` and are surfaced through builder functions on
//// this module.
////
//// The same `Credentials` value flows into SigV4 signing; the signer ignores
//// the expiry/source metadata that's relevant only to the chain.

import aws/internal/http_send.{type Send as HttpSend, imds_send}
import aws/internal/ini
import aws/internal/os_process
import aws/internal/providers/ecs
import aws/internal/providers/imds
import aws/internal/providers/process as process_provider
import aws/internal/providers/sso
import aws/internal/providers/sts_web_identity as web_identity
import gleam/bit_array
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// An AWS credentials triple plus optional expiry and provenance.
///
/// - `expires_at` is unix seconds since epoch. `None` means non-expiring
///   (typical for static or environment credentials).
/// - `source` records the provider that produced the credentials, useful for
///   logging and for debugging chain selection.
pub type Credentials {
  Credentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
    expires_at: Option(Int),
    source: String,
  )
}

/// Why a single provider failed. The chain collects one of these per provider
/// it tried, then bundles them in `ChainExhausted` if none succeeded.
pub type ProviderError {
  /// Provider is not configured for this environment (e.g. env vars unset,
  /// IMDS not reachable). Distinct from an actual fetch failure so the chain
  /// can keep going without surfacing a noisy error.
  NotConfigured(reason: String)
  /// Provider was configured and tried to fetch, but failed (e.g. HTTP error
  /// from IMDS, malformed credentials file, STS rejected the request).
  FetchFailed(reason: String)
  /// Every provider in the chain failed. Carries the per-provider attempt log
  /// so callers can see which providers were tried in what order and why
  /// each one declined.
  ChainExhausted(attempts: List(#(String, ProviderError)))
}

/// A credential provider. Library code threads `Provider` values around the
/// way it would thread a `Box<dyn ProvideCredentials>` in Rust or a
/// `CredentialsProvider` interface in Go — the call site doesn't care how the
/// credentials get sourced.
pub type Provider {
  Provider(name: String, fetch: fn() -> Result(Credentials, ProviderError))
}

/// Run a provider and return whatever it produced.
pub fn fetch(provider: Provider) -> Result(Credentials, ProviderError) {
  provider.fetch()
}

/// Compose providers into a single provider that walks them in order and
/// returns the first success. If every provider fails, the resulting error is
/// `ChainExhausted` with one `(name, error)` entry per attempt in the order
/// they were tried — useful for debugging "why didn't my IMDS creds get
/// picked up?" without having to instrument each provider individually.
pub fn chain(providers: List(Provider)) -> Provider {
  Provider(name: "Chain", fetch: fn() { try_each(providers, []) })
}

fn try_each(
  providers: List(Provider),
  attempts: List(#(String, ProviderError)),
) -> Result(Credentials, ProviderError) {
  case providers {
    [] -> Error(ChainExhausted(attempts: list.reverse(attempts)))
    [p, ..rest] ->
      case p.fetch() {
        Ok(credentials) -> Ok(credentials)
        Error(reason) -> try_each(rest, [#(p.name, reason), ..attempts])
      }
  }
}

/// A provider that always returns the same hardcoded credentials. The primary
/// use is tests and scripts where you have keys in hand; in production the
/// chain pulls from env/profile/IMDS instead.
pub fn static_provider(credentials: Credentials) -> Provider {
  let labelled = Credentials(..credentials, source: "Static")
  Provider(name: "Static", fetch: fn() { Ok(labelled) })
}

@external(erlang, "aws_ffi", "get_env")
fn os_get_env(name: String) -> Result(String, Nil)

/// Environment-variable provider. Reads `AWS_ACCESS_KEY_ID`,
/// `AWS_SECRET_ACCESS_KEY`, and (optionally) `AWS_SESSION_TOKEN`.
///
/// `lookup` is injected so tests can drive the provider with a fixed map
/// instead of mutating real process env. Use `from_environment` for the
/// default production wiring.
pub fn from_environment_with(
  lookup lookup: fn(String) -> Result(String, Nil),
) -> Provider {
  Provider(name: "Environment", fetch: fn() { fetch_from_env(lookup) })
}

/// Environment-variable provider using real OS env. Production default.
pub fn from_environment() -> Provider {
  from_environment_with(lookup: os_get_env)
}

fn fetch_from_env(
  lookup: fn(String) -> Result(String, Nil),
) -> Result(Credentials, ProviderError) {
  use access_key_id <- result.try(
    lookup("AWS_ACCESS_KEY_ID")
    |> result.replace_error(NotConfigured(reason: "AWS_ACCESS_KEY_ID not set")),
  )
  use secret_access_key <- result.try(
    lookup("AWS_SECRET_ACCESS_KEY")
    |> result.replace_error(NotConfigured(
      reason: "AWS_SECRET_ACCESS_KEY not set",
    )),
  )
  // Reject pathological "set but empty" values — treat them as not configured
  // so the chain can fall through to the next provider rather than try to
  // sign with an empty access key.
  case string.is_empty(access_key_id), string.is_empty(secret_access_key) {
    True, _ ->
      Error(NotConfigured(reason: "AWS_ACCESS_KEY_ID is set but empty"))
    _, True ->
      Error(NotConfigured(reason: "AWS_SECRET_ACCESS_KEY is set but empty"))
    False, False -> {
      let session_token = case lookup("AWS_SESSION_TOKEN") {
        Ok(token) ->
          case string.is_empty(token) {
            True -> None
            False -> option.Some(token)
          }
        Error(_) -> None
      }
      Ok(Credentials(
        access_key_id: access_key_id,
        secret_access_key: secret_access_key,
        session_token: session_token,
        expires_at: None,
        source: "Environment",
      ))
    }
  }
}

// ----- profile (shared credentials file) provider -----

/// AWS shared credentials provider. Reads `[profile_name]` from both
/// `~/.aws/credentials` (section name: `[name]`) and `~/.aws/config`
/// (section name: `[profile name]`, or `[default]` for the default profile).
/// If a property is set in both files, the credentials file wins — that's
/// the AWS CLI convention. Either file may be missing.
///
/// Both readers are injected so tests can drive the provider with in-memory
/// strings; `from_profile` plugs in real readers for the two canonical paths.
///
/// Errors:
///   - both readers fail → NotConfigured (no AWS config on this host)
///   - either file parses badly → FetchFailed (file exists but corrupt)
///   - profile section absent from both files → NotConfigured
///   - aws_access_key_id missing → NotConfigured (treat as "this profile
///     isn't a static-key profile; chain should keep going")
///   - aws_access_key_id present without aws_secret_access_key → FetchFailed
pub fn from_profile_with(
  name profile_name: String,
  credentials_reader credentials_reader: fn() -> Result(String, Nil),
  config_reader config_reader: fn() -> Result(String, Nil),
) -> Provider {
  Provider(name: "Profile(" <> profile_name <> ")", fetch: fn() {
    fetch_from_profile(profile_name, credentials_reader, config_reader)
  })
}

/// Profile provider using the canonical default file paths
/// (`~/.aws/credentials` + `~/.aws/config`).
pub fn from_profile(name profile_name: String) -> Provider {
  from_profile_with(
    name: profile_name,
    credentials_reader: read_default_profile_file,
    config_reader: read_default_config_file,
  )
}

@external(erlang, "aws_ffi", "read_file")
fn read_file(path: String) -> Result(BitArray, Nil)

fn read_default_profile_file() -> Result(String, Nil) {
  use home <- result.try(os_get_env("HOME"))
  let path = home <> "/.aws/credentials"
  use bits <- result.try(read_file(path))
  bit_array.to_string(bits) |> result.replace_error(Nil)
}

fn fetch_from_profile(
  profile_name: String,
  credentials_reader: fn() -> Result(String, Nil),
  config_reader: fn() -> Result(String, Nil),
) -> Result(Credentials, ProviderError) {
  let parsed_creds = parse_profile_file(credentials_reader)
  let parsed_config = parse_profile_file(config_reader)
  case parsed_creds, parsed_config {
    // Both files unreadable — the chain should fall through quietly.
    Error(NotConfigured(_)), Error(NotConfigured(_)) ->
      Error(NotConfigured(
        reason: "no AWS shared credentials or config file readable",
      ))
    // Either file is present but malformed — surface loudly.
    Error(FetchFailed(reason: r)), _ -> Error(FetchFailed(reason: r))
    _, Error(FetchFailed(reason: r)) -> Error(FetchFailed(reason: r))
    _, _ -> {
      let creds_section = profile_name
      let config_section = case profile_name {
        "default" -> "default"
        other -> "profile " <> other
      }
      let lookup =
        merged_lookup(
          parsed_creds,
          parsed_config,
          creds_section,
          config_section,
        )
      build_credentials_from_lookup(profile_name, lookup)
    }
  }
}

fn parse_profile_file(
  reader: fn() -> Result(String, Nil),
) -> Result(ini.Ini, ProviderError) {
  use text <- result.try(
    reader()
    |> result.replace_error(NotConfigured(reason: "file not readable")),
  )
  ini.parse(text)
  |> result.map_error(fn(e) {
    FetchFailed(
      reason: "shared profile parse error at line "
      <> int.to_string(e.line)
      <> ": "
      <> e.message,
    )
  })
}

/// Returns a `(key) -> Result(value, Nil)` closure that walks the credentials
/// file first, then the config file. Empty values count as absent so a half-
/// commented-out key doesn't accidentally take effect.
fn merged_lookup(
  parsed_creds: Result(ini.Ini, ProviderError),
  parsed_config: Result(ini.Ini, ProviderError),
  creds_section: String,
  config_section: String,
) -> fn(String) -> Result(String, Nil) {
  let from_creds = fn(key: String) -> Result(String, Nil) {
    case parsed_creds {
      Ok(p) ->
        case ini.get_property(p, section: creds_section, key: key) {
          Ok(v) ->
            case v {
              "" -> Error(Nil)
              _ -> Ok(v)
            }
          Error(_) -> Error(Nil)
        }
      Error(_) -> Error(Nil)
    }
  }
  let from_config = fn(key: String) -> Result(String, Nil) {
    case parsed_config {
      Ok(p) ->
        case ini.get_property(p, section: config_section, key: key) {
          Ok(v) ->
            case v {
              "" -> Error(Nil)
              _ -> Ok(v)
            }
          Error(_) -> Error(Nil)
        }
      Error(_) -> Error(Nil)
    }
  }
  fn(key: String) {
    case from_creds(key) {
      Ok(v) -> Ok(v)
      Error(_) -> from_config(key)
    }
  }
}

fn build_credentials_from_lookup(
  profile_name: String,
  lookup: fn(String) -> Result(String, Nil),
) -> Result(Credentials, ProviderError) {
  use access_key_id <- result.try(
    lookup("aws_access_key_id")
    |> result.replace_error(NotConfigured(
      reason: "profile '" <> profile_name <> "' has no aws_access_key_id",
    )),
  )
  use secret_access_key <- result.try(
    lookup("aws_secret_access_key")
    |> result.replace_error(FetchFailed(
      reason: "profile '"
      <> profile_name
      <> "' has aws_access_key_id but no aws_secret_access_key",
    )),
  )
  let session_token = case lookup("aws_session_token") {
    Ok(t) -> Some(t)
    Error(_) -> None
  }
  Ok(Credentials(
    access_key_id: access_key_id,
    secret_access_key: secret_access_key,
    session_token: session_token,
    expires_at: None,
    source: "Profile(" <> profile_name <> ")",
  ))
}

// ----- IMDSv2 (EC2 instance metadata) provider -----

/// IMDSv2 credentials provider. Performs the standard PUT-token / GET-role /
/// GET-creds dance against the link-local metadata endpoint at
/// `http://169.254.169.254` and parses the JSON credentials response.
///
/// Failure of step 1 (the token PUT) is treated as `NotConfigured` so the
/// chain quietly falls through to the next provider when we're not on EC2
/// or Lambda. Failures past that point are `FetchFailed`.
///
/// `send` is the HTTP transport — pass `aws/internal/http_send.default_send`
/// in production, or a stub in tests.
pub fn from_imds(send send: HttpSend) -> Provider {
  from_imds_with(
    send: send,
    endpoint: "http://169.254.169.254",
    token_ttl_seconds: 21_600,
  )
}

/// IMDSv2 provider with overridable endpoint and token TTL. Test stubs and
/// fleet-specific deployments (e.g. when AWS_EC2_METADATA_SERVICE_ENDPOINT
/// is set) use this form.
pub fn from_imds_with(
  send send: HttpSend,
  endpoint endpoint: String,
  token_ttl_seconds token_ttl_seconds: Int,
) -> Provider {
  let options =
    imds.Options(endpoint: endpoint, token_ttl_seconds: token_ttl_seconds)
  Provider(name: "IMDSv2", fetch: fn() {
    case imds.fetch(send, options) {
      Ok(c) ->
        Ok(Credentials(
          access_key_id: c.access_key_id,
          secret_access_key: c.secret_access_key,
          session_token: Some(c.session_token),
          expires_at: Some(c.expires_at),
          source: "IMDSv2",
        ))
      Error(imds.NotOnInstance(reason: reason)) ->
        Error(NotConfigured(reason: reason))
      Error(imds.Failed(reason: reason)) -> Error(FetchFailed(reason: reason))
    }
  })
}

// ----- ECS container credentials provider -----

/// ECS / EKS / Fargate container metadata provider. Resolves the metadata
/// URL from the standard environment variables (AWS_CONTAINER_-
/// CREDENTIALS_FULL_URI takes precedence; otherwise AWS_CONTAINER_-
/// CREDENTIALS_RELATIVE_URI is appended to `http://169.254.170.2`). The
/// `Authorization` header value is read from AWS_CONTAINER_AUTHORIZATION_-
/// TOKEN (or _TOKEN_FILE, if set instead).
///
/// If neither URI env var is set, the provider always returns
/// `NotConfigured` so the chain falls through quietly.
pub fn from_ecs(send send: HttpSend) -> Provider {
  from_ecs_with_env(send: send, lookup: os_get_env, read_file: read_file_string)
}

/// Like `from_ecs` but with injectable env-var lookup and file reader so
/// tests can drive the provider without mutating real OS state.
pub fn from_ecs_with_env(
  send send: HttpSend,
  lookup lookup: fn(String) -> Result(String, Nil),
  read_file read_file: fn(String) -> Result(String, Nil),
) -> Provider {
  let url = resolve_ecs_url(lookup)
  let token = resolve_ecs_auth_token(lookup, read_file)
  case url {
    Some(u) -> from_ecs_with(send: send, url: u, auth_token: token)
    None ->
      Provider(name: "ECS", fetch: fn() {
        Error(NotConfigured(
          reason: "no AWS_CONTAINER_CREDENTIALS_*_URI in environment",
        ))
      })
  }
}

/// ECS provider with the URL and auth token supplied explicitly. Useful when
/// the env-resolution logic isn't a fit (e.g. a sidecar configures things
/// programmatically).
pub fn from_ecs_with(
  send send: HttpSend,
  url url: String,
  auth_token auth_token: Option(String),
) -> Provider {
  let options = ecs.Options(url: url, auth_token: auth_token)
  Provider(name: "ECS", fetch: fn() {
    case ecs.fetch(send, options) {
      Ok(c) ->
        Ok(Credentials(
          access_key_id: c.access_key_id,
          secret_access_key: c.secret_access_key,
          session_token: c.session_token,
          expires_at: c.expires_at,
          source: "ECS",
        ))
      Error(ecs.Unreachable(reason: reason)) ->
        Error(NotConfigured(reason: reason))
      Error(ecs.Failed(reason: reason)) -> Error(FetchFailed(reason: reason))
    }
  })
}

fn resolve_ecs_url(
  lookup: fn(String) -> Result(String, Nil),
) -> Option(String) {
  case lookup("AWS_CONTAINER_CREDENTIALS_FULL_URI") {
    Ok(full) if full != "" -> Some(full)
    _ ->
      case lookup("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI") {
        Ok(rel) if rel != "" -> Some("http://169.254.170.2" <> rel)
        _ -> None
      }
  }
}

fn resolve_ecs_auth_token(
  lookup: fn(String) -> Result(String, Nil),
  read_file: fn(String) -> Result(String, Nil),
) -> Option(String) {
  case lookup("AWS_CONTAINER_AUTHORIZATION_TOKEN") {
    Ok(t) if t != "" -> Some(t)
    _ ->
      case lookup("AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE") {
        Ok(path) if path != "" ->
          case read_file(path) {
            Ok(contents) ->
              case string.trim(contents) {
                "" -> None
                t -> Some(t)
              }
            Error(_) -> None
          }
        _ -> None
      }
  }
}

fn read_file_string(path: String) -> Result(String, Nil) {
  use bits <- result.try(read_file(path))
  bit_array.to_string(bits) |> result.replace_error(Nil)
}

// ----- STS Web Identity (IRSA) provider -----

/// Default STS endpoint for the AssumeRoleWithWebIdentity call. Regional
/// endpoints would be more correct, but the global endpoint works from
/// anywhere and is what most SDKs reach for in the absence of region.
const default_sts_endpoint: String = "https://sts.amazonaws.com/"

/// Default session lifetime requested from STS. AWS caps this at the role's
/// max-session-duration; one hour is the conservative-but-useful default.
const default_web_identity_duration: Int = 3600

/// IRSA / STS Web Identity provider. Reads the token from
/// `AWS_WEB_IDENTITY_TOKEN_FILE` *each fetch* (IRSA rotates the file), reads
/// `AWS_ROLE_ARN` once at construction, and POSTs to STS.
pub fn from_web_identity(send send: HttpSend) -> Provider {
  from_web_identity_with_env(
    send: send,
    lookup: os_get_env,
    read_file: read_file_string,
  )
}

/// Injectable env / file reader variant for tests.
pub fn from_web_identity_with_env(
  send send: HttpSend,
  lookup lookup: fn(String) -> Result(String, Nil),
  read_file read_file: fn(String) -> Result(String, Nil),
) -> Provider {
  Provider(name: "WebIdentity", fetch: fn() {
    fetch_web_identity(send, lookup, read_file, default_sts_endpoint)
  })
}

/// Fully-explicit variant — caller provides every parameter. Used by tests
/// to point at a stub endpoint, and by callers who configure programmatically.
pub fn from_web_identity_with(
  send send: HttpSend,
  endpoint endpoint: String,
  role_arn role_arn: String,
  role_session_name role_session_name: String,
  token_file token_file: String,
  duration_seconds duration_seconds: Int,
  read_file read_file: fn(String) -> Result(String, Nil),
) -> Provider {
  Provider(name: "WebIdentity", fetch: fn() {
    do_fetch_web_identity(
      send,
      endpoint,
      role_arn,
      role_session_name,
      token_file,
      duration_seconds,
      read_file,
    )
  })
}

fn fetch_web_identity(
  send: HttpSend,
  lookup: fn(String) -> Result(String, Nil),
  read_file: fn(String) -> Result(String, Nil),
  endpoint: String,
) -> Result(Credentials, ProviderError) {
  use token_file <- result.try(
    lookup("AWS_WEB_IDENTITY_TOKEN_FILE")
    |> result.replace_error(NotConfigured(
      reason: "AWS_WEB_IDENTITY_TOKEN_FILE not set",
    )),
  )
  use role_arn <- result.try(
    lookup("AWS_ROLE_ARN")
    |> result.replace_error(NotConfigured(reason: "AWS_ROLE_ARN not set")),
  )
  let role_session_name = case lookup("AWS_ROLE_SESSION_NAME") {
    Ok(name) if name != "" -> name
    _ -> "aws-sdk-gleam-session"
  }
  do_fetch_web_identity(
    send,
    endpoint,
    role_arn,
    role_session_name,
    token_file,
    default_web_identity_duration,
    read_file,
  )
}

fn do_fetch_web_identity(
  send: HttpSend,
  endpoint: String,
  role_arn: String,
  role_session_name: String,
  token_file: String,
  duration_seconds: Int,
  read_file: fn(String) -> Result(String, Nil),
) -> Result(Credentials, ProviderError) {
  use token <- result.try(
    read_file(token_file)
    |> result.replace_error(FetchFailed(
      reason: "could not read web identity token from " <> token_file,
    )),
  )
  let options =
    web_identity.Options(
      endpoint: endpoint,
      role_arn: role_arn,
      role_session_name: role_session_name,
      token: string.trim(token),
      duration_seconds: duration_seconds,
    )
  case web_identity.fetch(send, options) {
    Ok(c) ->
      Ok(Credentials(
        access_key_id: c.access_key_id,
        secret_access_key: c.secret_access_key,
        session_token: Some(c.session_token),
        expires_at: Some(c.expires_at),
        source: "WebIdentity",
      ))
    Error(web_identity.Misconfigured(reason: reason)) ->
      Error(NotConfigured(reason: reason))
    Error(web_identity.Failed(reason: reason)) ->
      Error(FetchFailed(reason: reason))
  }
}

// ----- SSO (IAM Identity Center) provider -----

@external(erlang, "aws_ffi", "sha1_hex")
fn sha1_hex(input: String) -> String

/// SSO credentials provider. Consumes a cached SSO access token (produced
/// by `aws sso login`) and exchanges it at the portal for short-lived
/// credentials.
///
/// `from_sso_with` is the explicit form — used by tests and by callers that
/// resolve their own session / role configuration.
pub fn from_sso_with(
  send send: HttpSend,
  region region: String,
  account_id account_id: String,
  role_name role_name: String,
  access_token access_token: String,
) -> Provider {
  let options =
    sso.Options(
      region: region,
      account_id: account_id,
      role_name: role_name,
      access_token: access_token,
      endpoint: sso.default_endpoint(region),
    )
  Provider(name: "SSO", fetch: fn() {
    wrap_sso_result(sso.fetch(send, options))
  })
}

/// Same shape as `from_sso_with` but with an overridable portal endpoint.
/// Tests aim a stub server at the portal path and pass it here.
pub fn from_sso_with_endpoint(
  send send: HttpSend,
  region region: String,
  account_id account_id: String,
  role_name role_name: String,
  access_token access_token: String,
  endpoint endpoint: String,
) -> Provider {
  let options =
    sso.Options(
      region: region,
      account_id: account_id,
      role_name: role_name,
      access_token: access_token,
      endpoint: endpoint,
    )
  Provider(name: "SSO", fetch: fn() {
    wrap_sso_result(sso.fetch(send, options))
  })
}

fn wrap_sso_result(
  result: Result(sso.SsoCredentials, sso.Error),
) -> Result(Credentials, ProviderError) {
  case result {
    Ok(c) ->
      Ok(Credentials(
        access_key_id: c.access_key_id,
        secret_access_key: c.secret_access_key,
        session_token: Some(c.session_token),
        expires_at: Some(c.expires_at),
        source: "SSO",
      ))
    Error(sso.Unreachable(reason: reason)) ->
      Error(NotConfigured(reason: reason))
    Error(sso.Failed(reason: reason)) -> Error(FetchFailed(reason: reason))
  }
}

/// Production SSO provider. Reads the named profile from `~/.aws/config`,
/// pulls the cached SSO access token from `~/.aws/sso/cache/<sha1>.json`,
/// and exchanges it at the portal. The cache filename is `sha1(session-or-
/// start-url)` per the AWS CLI convention.
pub fn from_sso(send send: HttpSend, profile profile: String) -> Provider {
  from_sso_with_env(
    send: send,
    profile: profile,
    config_reader: read_default_config_file,
    cache_reader: read_sso_cache_file,
  )
}

/// Injectable variant for tests.
pub fn from_sso_with_env(
  send send: HttpSend,
  profile profile: String,
  config_reader config_reader: fn() -> Result(String, Nil),
  cache_reader cache_reader: fn(String) -> Result(String, Nil),
) -> Provider {
  Provider(name: "SSO(" <> profile <> ")", fetch: fn() {
    resolve_and_fetch_sso(send, profile, config_reader, cache_reader)
  })
}

fn resolve_and_fetch_sso(
  send: HttpSend,
  profile: String,
  config_reader: fn() -> Result(String, Nil),
  cache_reader: fn(String) -> Result(String, Nil),
) -> Result(Credentials, ProviderError) {
  use config_text <- result.try(
    config_reader()
    |> result.replace_error(NotConfigured(reason: "~/.aws/config not readable")),
  )
  use config <- result.try(
    ini.parse(config_text)
    |> result.map_error(fn(e) {
      FetchFailed(
        reason: "config parse error at line " <> int.to_string(e.line),
      )
    }),
  )
  // Profiles in ~/.aws/config are spelled `[profile NAME]` (except the
  // implicit default which is `[default]`).
  let section = case profile {
    "default" -> "default"
    other -> "profile " <> other
  }
  use sso_session <- result.try(
    ini.get_property(config, section: section, key: "sso_session")
    |> result.replace_error(NotConfigured(
      reason: "profile '" <> profile <> "' has no sso_session",
    )),
  )
  use region <- result.try(
    ini.get_property(config, section: section, key: "sso_region")
    |> result.replace_error(NotConfigured(
      reason: "profile '" <> profile <> "' has no sso_region",
    )),
  )
  use account_id <- result.try(
    ini.get_property(config, section: section, key: "sso_account_id")
    |> result.replace_error(NotConfigured(
      reason: "profile '" <> profile <> "' has no sso_account_id",
    )),
  )
  use role_name <- result.try(
    ini.get_property(config, section: section, key: "sso_role_name")
    |> result.replace_error(NotConfigured(
      reason: "profile '" <> profile <> "' has no sso_role_name",
    )),
  )
  let cache_filename = sha1_hex(sso_session) <> ".json"
  use cache_text <- result.try(
    cache_reader(cache_filename)
    |> result.replace_error(NotConfigured(
      reason: "no SSO token cache for session '"
      <> sso_session
      <> "' — run `aws sso login`",
    )),
  )
  use access_token <- result.try(
    extract_access_token(cache_text)
    |> result.replace_error(FetchFailed(
      reason: "SSO token cache for session '"
      <> sso_session
      <> "' is missing accessToken",
    )),
  )
  wrap_sso_result(sso.fetch(
    send,
    sso.Options(
      region: region,
      account_id: account_id,
      role_name: role_name,
      access_token: access_token,
      endpoint: sso.default_endpoint(region),
    ),
  ))
}

fn extract_access_token(json_text: String) -> Result(String, Nil) {
  // The token cache JSON has `{"accessToken": "...", "expiresAt": "...", ...}`.
  // A full decoder is overkill; pull just the one field.
  case string.split_once(json_text, "\"accessToken\"") {
    Ok(#(_, after_key)) ->
      case string.split_once(after_key, "\"") {
        Ok(#(_, after_first_quote)) ->
          case string.split_once(after_first_quote, "\"") {
            Ok(#(value, _)) -> Ok(value)
            Error(_) -> Error(Nil)
          }
        Error(_) -> Error(Nil)
      }
    Error(_) -> Error(Nil)
  }
}

fn read_default_config_file() -> Result(String, Nil) {
  use home <- result.try(os_get_env("HOME"))
  let path = home <> "/.aws/config"
  use bits <- result.try(read_file(path))
  bit_array.to_string(bits) |> result.replace_error(Nil)
}

fn read_sso_cache_file(filename: String) -> Result(String, Nil) {
  use home <- result.try(os_get_env("HOME"))
  let path = home <> "/.aws/sso/cache/" <> filename
  use bits <- result.try(read_file(path))
  bit_array.to_string(bits) |> result.replace_error(Nil)
}

// ----- credential_process provider -----

/// Credential-process provider. Runs the configured command and parses its
/// stdout as the AWS credential-process JSON.
///
/// `from_process_with_command` takes a command line literally; tests and
/// programmatic configs use this form.
pub fn from_process_with_command(command command: String) -> Provider {
  from_process_with_runner(command: command, runner: os_process.run)
}

/// Same shape but with an injectable runner so tests can drive scripted
/// stdout/exit values without spawning real processes.
pub fn from_process_with_runner(
  command command: String,
  runner runner: fn(String, List(String)) -> Result(#(Int, BitArray), Nil),
) -> Provider {
  Provider(name: "Process", fetch: fn() {
    wrap_process_result(process_provider.fetch(runner, command))
  })
}

fn wrap_process_result(
  result: Result(process_provider.ProcessCredentials, process_provider.Error),
) -> Result(Credentials, ProviderError) {
  case result {
    Ok(c) ->
      Ok(Credentials(
        access_key_id: c.access_key_id,
        secret_access_key: c.secret_access_key,
        session_token: c.session_token,
        expires_at: c.expires_at,
        source: "Process",
      ))
    // Couldn't even launch the program -> chain falls through quietly.
    Error(process_provider.LaunchFailed(reason: reason)) ->
      Error(NotConfigured(reason: reason))
    // Process ran but produced bad output -> loud misconfig.
    Error(process_provider.BadOutput(reason: reason)) ->
      Error(FetchFailed(reason: reason))
  }
}

/// Production credential-process provider. Reads `credential_process` from
/// the named profile in `~/.aws/config` (or `~/.aws/credentials` for the
/// `[default]` profile only — both files are checked).
pub fn from_process(profile profile: String) -> Provider {
  from_process_with_env(
    profile: profile,
    config_reader: read_default_config_file,
    credentials_reader: read_default_profile_file,
    runner: os_process.run,
  )
}

/// Injectable variant for tests.
pub fn from_process_with_env(
  profile profile: String,
  config_reader config_reader: fn() -> Result(String, Nil),
  credentials_reader credentials_reader: fn() -> Result(String, Nil),
  runner runner: fn(String, List(String)) -> Result(#(Int, BitArray), Nil),
) -> Provider {
  Provider(name: "Process(" <> profile <> ")", fetch: fn() {
    resolve_and_run_process(profile, config_reader, credentials_reader, runner)
  })
}

fn resolve_and_run_process(
  profile: String,
  config_reader: fn() -> Result(String, Nil),
  credentials_reader: fn() -> Result(String, Nil),
  runner: fn(String, List(String)) -> Result(#(Int, BitArray), Nil),
) -> Result(Credentials, ProviderError) {
  // Look in ~/.aws/config first (where credential_process is officially
  // documented), then fall back to ~/.aws/credentials.
  let command =
    lookup_credential_process(profile, config_reader, in_config: True)
    |> result.or(lookup_credential_process(
      profile,
      credentials_reader,
      in_config: False,
    ))
  use cmd <- result.try(
    command
    |> result.replace_error(NotConfigured(
      reason: "profile '" <> profile <> "' has no credential_process setting",
    )),
  )
  wrap_process_result(process_provider.fetch(runner, cmd))
}

fn lookup_credential_process(
  profile: String,
  reader: fn() -> Result(String, Nil),
  in_config in_config: Bool,
) -> Result(String, Nil) {
  use text <- result.try(reader())
  use parsed <- result.try(
    ini.parse(text)
    |> result.replace_error(Nil),
  )
  // In ~/.aws/config profiles are spelled `[profile NAME]`; in
  // ~/.aws/credentials they're plain `[NAME]`. The `[default]` profile is
  // the exception — bare in both files.
  let section = case in_config, profile {
    True, "default" -> "default"
    True, other -> "profile " <> other
    False, other -> other
  }
  ini.get_property(parsed, section: section, key: "credential_process")
}

// ----- AWS CLI export-credentials fallback -----

/// Use the AWS CLI (`aws configure export-credentials`) to resolve
/// credentials for a profile. Covers any auth flow the CLI supports — SSO,
/// IRSA, `login_session`, anything we haven't natively implemented yet.
///
/// The CLI's `--format process` output is the same shape as
/// `credential_process` (`Version: 1`, `AccessKeyId`, etc.), so this is
/// effectively a thin wrapper that runs the right command and feeds the
/// output through the existing `credential_process` decoder.
///
/// Specifically a deliberate alternative to a native `login_session`
/// provider: the upstream Go SDK's `credentials/logincreds` uses **DPoP**
/// (RFC 9449) — every portal request needs a JWT signed with an ECDSA P-256
/// private key from the local cache. Implementing that natively would add
/// JWK parsing, JWS signing, and a new crypto FFI, plus the cache file
/// schema isn't published outside the Go implementation. Until we take on
/// that work, shelling out to the AWS CLI is the practical bridge.
///
/// Requires AWS CLI v2 (`aws configure export-credentials` was added in
/// 2022). Returns `NotConfigured` if the binary isn't on PATH or the
/// profile doesn't exist; `FetchFailed` if the CLI exits non-zero or
/// emits malformed JSON.
pub fn from_aws_cli(profile profile: String) -> Provider {
  from_aws_cli_with(profile: profile, runner: os_process.run)
}

/// `from_aws_cli` with an injectable runner so tests don't actually spawn
/// `aws`.
pub fn from_aws_cli_with(
  profile profile: String,
  runner runner: fn(String, List(String)) -> Result(#(Int, BitArray), Nil),
) -> Provider {
  let command =
    "aws configure export-credentials --profile "
    <> profile
    <> " --format process"
  Provider(name: "AwsCli(" <> profile <> ")", fetch: fn() {
    case process_provider.fetch(runner, command) {
      Ok(c) ->
        Ok(Credentials(
          access_key_id: c.access_key_id,
          secret_access_key: c.secret_access_key,
          session_token: c.session_token,
          expires_at: c.expires_at,
          source: "AwsCli(" <> profile <> ")",
        ))
      Error(process_provider.LaunchFailed(reason: reason)) ->
        Error(NotConfigured(reason: reason))
      Error(process_provider.BadOutput(reason: reason)) ->
        Error(FetchFailed(reason: reason))
    }
  })
}

// ----- default chain -----

/// Standard AWS credential-provider chain, in the precedence order other AWS
/// SDKs use:
///
///   1. Environment variables (`AWS_ACCESS_KEY_ID` and friends)
///   2. AssumeRoleWithWebIdentity / IRSA (`AWS_WEB_IDENTITY_TOKEN_FILE`)
///   3. SSO session, via `~/.aws/config` + the cached SSO token
///   4. Shared credentials file (`~/.aws/credentials`)
///   5. `credential_process` from the named profile
///   6. ECS container metadata (`AWS_CONTAINER_CREDENTIALS_*_URI`)
///   7. EC2 IMDSv2
///
/// The returned `Provider` is the bare chain — it does not cache. Wrap it in
/// `aws/internal/credentials_cache.start_default` to get the cache + refresh
/// behaviour every long-running process wants.
///
/// `profile` selects which profile name is used by the profile, SSO, and
/// credential_process branches (they all share the AWS-CLI profile concept).
/// Pass `"default"` to mimic the AWS CLI's default behaviour.
pub fn default_chain(send send: HttpSend, profile profile: String) -> Provider {
  chain([
    from_environment(),
    from_web_identity(send: send),
    from_sso(send: send, profile: profile),
    from_profile(name: profile),
    from_process(profile: profile),
    from_ecs(send: send),
    // IMDS uses a short-timeout sender so its link-local connect fails fast
    // when we're not on EC2 instead of stalling the whole chain.
    from_imds(send: imds_send),
  ])
}
