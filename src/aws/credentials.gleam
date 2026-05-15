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

import aws/internal/http_send.{type Send as HttpSend}
import aws/internal/ini
import aws/internal/providers/ecs
import aws/internal/providers/imds
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

/// AWS shared credentials file provider. Reads `[profile_name]` from the file
/// returned by `reader`. The reader is injected so tests can drive the
/// provider with an in-memory string; `from_profile` plugs in a real
/// `~/.aws/credentials` reader.
///
/// Errors:
///   - reader fails → NotConfigured (file not present is the normal "I'm
///     not running on a profile-using machine" signal; the chain should fall
///     through quietly)
///   - INI parse fails → FetchFailed (the file exists but is corrupt; loud)
///   - profile section missing → NotConfigured (likewise quiet — they may
///     have meant to use a different provider)
///   - profile present but missing access_key_id or secret_access_key →
///     FetchFailed (clearly a misconfiguration worth surfacing)
pub fn from_profile_with(
  name profile_name: String,
  reader reader: fn() -> Result(String, Nil),
) -> Provider {
  Provider(name: "Profile(" <> profile_name <> ")", fetch: fn() {
    fetch_from_profile(profile_name, reader)
  })
}

/// Default profile-file reader: `~/.aws/credentials` for the named profile.
pub fn from_profile(name profile_name: String) -> Provider {
  from_profile_with(name: profile_name, reader: read_default_profile_file)
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
  reader: fn() -> Result(String, Nil),
) -> Result(Credentials, ProviderError) {
  use text <- result.try(
    reader()
    |> result.replace_error(NotConfigured(
      reason: "shared credentials file not readable",
    )),
  )
  use parsed <- result.try(
    ini.parse(text)
    |> result.map_error(fn(e) {
      FetchFailed(
        reason: "shared credentials parse error at line "
        <> int.to_string(e.line)
        <> ": "
        <> e.message,
      )
    }),
  )
  use access_key_id <- result.try(
    ini.get_property(parsed, section: profile_name, key: "aws_access_key_id")
    |> result.replace_error(NotConfigured(
      reason: "profile '" <> profile_name <> "' has no aws_access_key_id",
    )),
  )
  use secret_access_key <- result.try(
    ini.get_property(
      parsed,
      section: profile_name,
      key: "aws_secret_access_key",
    )
    |> result.replace_error(FetchFailed(
      reason: "profile '"
      <> profile_name
      <> "' has aws_access_key_id but no aws_secret_access_key",
    )),
  )
  let session_token = case
    ini.get_property(parsed, section: profile_name, key: "aws_session_token")
  {
    Ok(token) ->
      case string.is_empty(token) {
        True -> None
        False -> Some(token)
      }
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
