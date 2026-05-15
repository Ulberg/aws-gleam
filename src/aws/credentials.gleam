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

import gleam/list
import gleam/option.{type Option, None}
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
