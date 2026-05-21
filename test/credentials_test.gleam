//// Unit tests for the credentials module: static + env providers in
//// isolation, and the chain combinator's first-success / collect-errors
//// behaviour.

import aws/credentials.{
  type Credentials, type Provider, type ProviderError, ChainExhausted,
  Credentials, FetchFailed, NotConfigured, Provider,
}
import aws/internal/http_send
import gleam/dict
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

/// Build a lookup function backed by a dict — lets us drive `from_environment`
/// in tests without ever touching real OS env.
fn env_from(
  pairs: List(#(String, String)),
) -> fn(String) -> Result(String, Nil) {
  let env = dict.from_list(pairs)
  fn(name: String) -> Result(String, Nil) { dict.get(env, name) }
}

fn empty_env() -> fn(String) -> Result(String, Nil) {
  env_from([])
}

// ---------- static provider ----------

pub fn static_provider_returns_given_credentials_test() {
  let creds =
    Credentials(
      access_key_id: "AKID",
      secret_access_key: "SECRET",
      session_token: None,
      expires_at: None,
      source: "ignored",
    )
  credentials.static_provider(creds)
  |> credentials.fetch
  |> should.equal(Ok(Credentials(..creds, source: "Static")))
}

// ---------- env provider ----------

pub fn env_provider_reads_all_three_vars_test() {
  let lookup =
    env_from([
      #("AWS_ACCESS_KEY_ID", "AKID"),
      #("AWS_SECRET_ACCESS_KEY", "SECRET"),
      #("AWS_SESSION_TOKEN", "TOK"),
    ])
  credentials.from_environment_with(lookup: lookup)
  |> credentials.fetch
  |> should.equal(
    Ok(Credentials(
      access_key_id: "AKID",
      secret_access_key: "SECRET",
      session_token: Some("TOK"),
      expires_at: None,
      source: "Environment",
    )),
  )
}

pub fn env_provider_session_token_optional_test() {
  let lookup =
    env_from([
      #("AWS_ACCESS_KEY_ID", "AKID"),
      #("AWS_SECRET_ACCESS_KEY", "SECRET"),
    ])
  let assert Ok(creds) =
    credentials.from_environment_with(lookup: lookup)
    |> credentials.fetch
  creds.session_token |> should.equal(None)
}

pub fn env_provider_missing_access_key_id_test() {
  credentials.from_environment_with(lookup: empty_env())
  |> credentials.fetch
  |> should.be_error
}

pub fn env_provider_empty_access_key_is_not_configured_test() {
  let lookup =
    env_from([
      #("AWS_ACCESS_KEY_ID", ""),
      #("AWS_SECRET_ACCESS_KEY", "SECRET"),
    ])
  let assert Error(err) =
    credentials.from_environment_with(lookup: lookup)
    |> credentials.fetch
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured"
  }
}

pub fn env_provider_empty_session_token_treated_as_absent_test() {
  let lookup =
    env_from([
      #("AWS_ACCESS_KEY_ID", "AKID"),
      #("AWS_SECRET_ACCESS_KEY", "SECRET"),
      #("AWS_SESSION_TOKEN", ""),
    ])
  let assert Ok(creds) =
    credentials.from_environment_with(lookup: lookup)
    |> credentials.fetch
  creds.session_token |> should.equal(None)
}

// ---------- chain ----------

fn always_fails(name: String, why: ProviderError) -> Provider {
  Provider(name: name, fetch: fn() { Error(why) })
}

fn always_succeeds(name: String, with creds: Credentials) -> Provider {
  Provider(name: name, fetch: fn() { Ok(creds) })
}

fn sample_creds() -> Credentials {
  Credentials(
    access_key_id: "AKID",
    secret_access_key: "SECRET",
    session_token: None,
    expires_at: None,
    source: "test",
  )
}

pub fn chain_returns_first_success_test() {
  let chosen = sample_creds()
  let provider =
    credentials.chain([
      always_fails("Env", NotConfigured(reason: "missing")),
      always_succeeds("Profile", with: chosen),
      always_fails("IMDS", FetchFailed(reason: "should never be reached")),
    ])
  provider |> credentials.fetch |> should.equal(Ok(chosen))
}

pub fn chain_exhausted_reports_all_attempts_in_order_test() {
  let provider =
    credentials.chain([
      always_fails("Env", NotConfigured(reason: "no env")),
      always_fails("Profile", NotConfigured(reason: "no file")),
      always_fails("IMDS", FetchFailed(reason: "timeout")),
    ])
  let assert Error(ChainExhausted(attempts: attempts)) =
    credentials.fetch(provider)
  attempts
  |> should.equal([
    #("Env", NotConfigured(reason: "no env")),
    #("Profile", NotConfigured(reason: "no file")),
    #("IMDS", FetchFailed(reason: "timeout")),
  ])
}

pub fn empty_chain_returns_exhausted_with_no_attempts_test() {
  let assert Error(ChainExhausted(attempts: attempts)) =
    credentials.fetch(credentials.chain([]))
  attempts |> should.equal([])
}

// ---------- profile provider ----------

fn ok_reader(text: String) -> fn() -> Result(String, Nil) {
  fn() { Ok(text) }
}

fn no_file() -> fn() -> Result(String, Nil) {
  fn() { Error(Nil) }
}

pub fn profile_provider_loads_named_profile_from_credentials_file_test() {
  let creds =
    ok_reader(
      "[default]
aws_access_key_id = DEFAULT_KEY
aws_secret_access_key = DEFAULT_SECRET

[prod]
aws_access_key_id = PROD_KEY
aws_secret_access_key = PROD_SECRET
aws_session_token = PROD_TOKEN
",
    )
  credentials.from_profile_with(
    name: "prod",
    credentials_reader: creds,
    config_reader: no_file(),
  )
  |> credentials.fetch
  |> should.equal(
    Ok(Credentials(
      access_key_id: "PROD_KEY",
      secret_access_key: "PROD_SECRET",
      session_token: Some("PROD_TOKEN"),
      expires_at: None,
      source: "Profile(prod)",
    )),
  )
}

pub fn profile_provider_default_section_session_token_optional_test() {
  let creds =
    ok_reader(
      "[default]
aws_access_key_id = K
aws_secret_access_key = S
",
    )
  let assert Ok(creds_out) =
    credentials.from_profile_with(
      name: "default",
      credentials_reader: creds,
      config_reader: no_file(),
    )
    |> credentials.fetch
  creds_out.session_token |> should.equal(None)
}

pub fn profile_provider_missing_both_files_is_not_configured_test() {
  let assert Error(err) =
    credentials.from_profile_with(
      name: "default",
      credentials_reader: no_file(),
      config_reader: no_file(),
    )
    |> credentials.fetch
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured for missing files"
  }
}

pub fn profile_provider_unknown_profile_is_not_configured_test() {
  let creds =
    ok_reader("[default]\naws_access_key_id=K\naws_secret_access_key=S")
  let assert Error(err) =
    credentials.from_profile_with(
      name: "nope",
      credentials_reader: creds,
      config_reader: no_file(),
    )
    |> credentials.fetch
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured for unknown profile"
  }
}

pub fn profile_provider_half_configured_profile_is_fetch_failed_test() {
  // Access key but no secret — clearly a misconfiguration, not "no creds
  // here, move on".
  let creds = ok_reader("[default]\naws_access_key_id = K\n")
  let assert Error(err) =
    credentials.from_profile_with(
      name: "default",
      credentials_reader: creds,
      config_reader: no_file(),
    )
    |> credentials.fetch
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for half-configured profile"
  }
}

pub fn profile_provider_malformed_file_is_fetch_failed_test() {
  // Property outside any section -> INI parse error.
  let creds = ok_reader("orphan = value")
  let assert Error(err) =
    credentials.from_profile_with(
      name: "default",
      credentials_reader: creds,
      config_reader: no_file(),
    )
    |> credentials.fetch
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for malformed credentials file"
  }
}

// ---------- profile provider: credentials+config merge ----------

pub fn profile_provider_reads_keys_from_config_file_alone_test() {
  // Some users keep static keys in ~/.aws/config (unusual but valid).
  // The provider should find them when ~/.aws/credentials is absent.
  let config =
    ok_reader(
      "[profile dev]
aws_access_key_id = CONFIG_KEY
aws_secret_access_key = CONFIG_SECRET
",
    )
  credentials.from_profile_with(
    name: "dev",
    credentials_reader: no_file(),
    config_reader: config,
  )
  |> credentials.fetch
  |> should.equal(
    Ok(Credentials(
      access_key_id: "CONFIG_KEY",
      secret_access_key: "CONFIG_SECRET",
      session_token: None,
      expires_at: None,
      source: "Profile(dev)",
    )),
  )
}

pub fn profile_provider_credentials_file_overrides_config_file_test() {
  // Standard AWS CLI: keys in ~/.aws/credentials beat keys in ~/.aws/config.
  let creds =
    ok_reader(
      "[default]
aws_access_key_id = CREDS_KEY
aws_secret_access_key = CREDS_SECRET
",
    )
  let config =
    ok_reader(
      "[default]
aws_access_key_id = CONFIG_KEY
aws_secret_access_key = CONFIG_SECRET
",
    )
  credentials.from_profile_with(
    name: "default",
    credentials_reader: creds,
    config_reader: config,
  )
  |> credentials.fetch
  |> should.equal(
    Ok(Credentials(
      access_key_id: "CREDS_KEY",
      secret_access_key: "CREDS_SECRET",
      session_token: None,
      expires_at: None,
      source: "Profile(default)",
    )),
  )
}

pub fn profile_provider_uses_profile_prefix_in_config_file_test() {
  // Verify the section spelling difference: bare in credentials, `profile X`
  // in config.
  let config =
    ok_reader(
      "[default]
aws_access_key_id = DEFAULT_KEY
aws_secret_access_key = DEFAULT_SECRET

[profile prod]
aws_access_key_id = PROD_KEY
aws_secret_access_key = PROD_SECRET
",
    )
  let assert Ok(out) =
    credentials.from_profile_with(
      name: "prod",
      credentials_reader: no_file(),
      config_reader: config,
    )
    |> credentials.fetch
  out.access_key_id |> should.equal("PROD_KEY")
}

pub fn profile_provider_partial_merge_test() {
  // credentials.aws_access_key_id + config.aws_secret_access_key -> both used.
  let creds = ok_reader("[default]\naws_access_key_id = FROM_CREDS\n")
  let config = ok_reader("[default]\naws_secret_access_key = FROM_CONFIG\n")
  credentials.from_profile_with(
    name: "default",
    credentials_reader: creds,
    config_reader: config,
  )
  |> credentials.fetch
  |> should.equal(
    Ok(Credentials(
      access_key_id: "FROM_CREDS",
      secret_access_key: "FROM_CONFIG",
      session_token: None,
      expires_at: None,
      source: "Profile(default)",
    )),
  )
}

// ---------- profile_assume_role provider ----------

fn assume_role_canned_xml() -> BitArray {
  // Mirrors what the real STS returns for AssumeRole; the inner
  // `<Credentials>` block is the only structure the SDK decodes.
  <<
    "<AssumeRoleResponse><AssumeRoleResult><Credentials><AccessKeyId>ASIAEXAMPLEROLE</AccessKeyId><SecretAccessKey>ROLE_SECRET</SecretAccessKey><SessionToken>ROLE_SESSION_TOKEN</SessionToken><Expiration>2024-01-17T01:00:00Z</Expiration></Credentials></AssumeRoleResult></AssumeRoleResponse>":utf8,
  >>
}

fn canned_send(body: BitArray) -> http_send.Send {
  fn(_req: Request(BitArray)) {
    Ok(response.Response(status: 200, headers: [], body: body))
  }
}

fn fixed_timestamp() -> String {
  "20240117T000000Z"
}

pub fn profile_assume_role_falls_through_to_static_keys_test() {
  // No role_arn → behaves identically to `from_profile`. Confirms the
  // chained constructor is a strict superset of the simple one.
  let creds =
    ok_reader(
      "[default]
aws_access_key_id = DK
aws_secret_access_key = DS
",
    )
  credentials.from_profile_assume_role_with(
    name: "default",
    send: canned_send(<<>>),
    region: "us-east-1",
    endpoint: "https://sts.amazonaws.com/",
    credentials_reader: creds,
    config_reader: no_file(),
    timestamp: fixed_timestamp,
  )
  |> credentials.fetch
  |> should.equal(
    Ok(Credentials(
      access_key_id: "DK",
      secret_access_key: "DS",
      session_token: None,
      expires_at: None,
      source: "Profile(default)",
    )),
  )
}

pub fn profile_assume_role_chains_via_sts_when_role_arn_present_test() {
  // Static keys live under [source]; the role-bearing profile points
  // at it via `source_profile`. The STS Send returns canned AssumeRole
  // XML; we assert the unpacked role credentials flow through.
  let config =
    ok_reader(
      "[profile dev]
role_arn = arn:aws:iam::123456789012:role/Demo
source_profile = source
role_session_name = my-session

[profile source]
aws_access_key_id = SRC_KEY
aws_secret_access_key = SRC_SECRET
",
    )
  let assert Ok(out) =
    credentials.from_profile_assume_role_with(
      name: "dev",
      send: canned_send(assume_role_canned_xml()),
      region: "us-east-1",
      endpoint: "https://sts.amazonaws.com/",
      credentials_reader: no_file(),
      config_reader: config,
      timestamp: fixed_timestamp,
    )
    |> credentials.fetch
  out.access_key_id |> should.equal("ASIAEXAMPLEROLE")
  out.secret_access_key |> should.equal("ROLE_SECRET")
  out.session_token |> should.equal(Some("ROLE_SESSION_TOKEN"))
  out.expires_at |> should.equal(Some(1_705_453_200))
  // The provider label carries the role ARN so the chain log says
  // which hop fetched the credentials.
  out.source
  |> string.contains("AssumeRole(arn:aws:iam::123456789012:role/Demo)")
  |> should.be_true
}

pub fn profile_assume_role_missing_source_profile_is_not_configured_test() {
  // `role_arn` without `source_profile` is a malformed chain — the
  // SDK can't know which profile holds the bootstrap credentials.
  let config =
    ok_reader(
      "[profile dev]
role_arn = arn:aws:iam::123456789012:role/Demo
",
    )
  let assert Error(err) =
    credentials.from_profile_assume_role_with(
      name: "dev",
      send: canned_send(<<>>),
      region: "us-east-1",
      endpoint: "https://sts.amazonaws.com/",
      credentials_reader: no_file(),
      config_reader: config,
      timestamp: fixed_timestamp,
    )
    |> credentials.fetch
  case err {
    NotConfigured(reason: r) ->
      r |> string.contains("source_profile") |> should.be_true
    _ -> panic as "expected NotConfigured for missing source_profile"
  }
}

pub fn profile_assume_role_signs_with_source_profile_credentials_test() {
  // The outbound request to STS must be SigV4-signed with the source
  // profile's keys (that's how STS authenticates the caller). We
  // capture the request, then verify the Authorization header
  // includes the source profile's access key id in the credential
  // scope.
  let config =
    ok_reader(
      "[profile dev]
role_arn = arn:aws:iam::123456789012:role/Demo
source_profile = source

[profile source]
aws_access_key_id = SRC_KEY_FOR_SIGNING
aws_secret_access_key = SRC_SECRET
",
    )
  let captured = make_request_capture()
  let send = capture_then_canned(captured, assume_role_canned_xml())
  let _ =
    credentials.from_profile_assume_role_with(
      name: "dev",
      send: send,
      region: "us-east-1",
      endpoint: "https://sts.amazonaws.com/",
      credentials_reader: no_file(),
      config_reader: config,
      timestamp: fixed_timestamp,
    )
    |> credentials.fetch
  let req = read_captured_request(captured)
  let auth = read_header(req, "authorization")
  auth |> string.contains("SRC_KEY_FOR_SIGNING") |> should.be_true
}

// --- request-capture helpers ---
// `process.new_subject` would be cleaner but introduces an inter-test
// ordering hazard (gleeunit interleaves tests). Use a per-call ETS-
// backed ref via `aws_test_support_ffi:make_ref/0` instead.

type RequestCapture {
  RequestCapture(get: fn() -> Request(BitArray))
}

fn make_request_capture() -> RequestCapture {
  let ref = capture_new()
  RequestCapture(get: fn() { capture_get(ref) })
}

fn capture_then_canned(
  capture: RequestCapture,
  body: BitArray,
) -> http_send.Send {
  fn(req: Request(BitArray)) {
    let RequestCapture(get: _) = capture
    capture_put(req)
    Ok(response.Response(status: 200, headers: [], body: body))
  }
}

fn read_captured_request(capture: RequestCapture) -> Request(BitArray) {
  let RequestCapture(get: get) = capture
  get()
}

fn read_header(req: Request(BitArray), name: String) -> String {
  case request.get_header(req, name) {
    Ok(v) -> v
    Error(_) -> ""
  }
}

@external(erlang, "aws_test_support_ffi", "capture_new")
fn capture_new() -> Int

@external(erlang, "aws_test_support_ffi", "capture_put")
fn capture_put(req: Request(BitArray)) -> Nil

@external(erlang, "aws_test_support_ffi", "capture_get")
fn capture_get(ref: Int) -> Request(BitArray)
