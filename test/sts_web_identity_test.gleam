//// Unit tests for the STS Web Identity (IRSA) provider.

import aws/credentials.{FetchFailed, NotConfigured}
import aws/internal/http_send.{type HttpError}
import gleam/bit_array
import gleam/dict
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{Some}
import gleam/string
import gleeunit/should

const test_endpoint: String = "https://sts.test.example/"

const role_arn: String = "arn:aws:iam::123456789012:role/test-role"

const session_name: String = "test-session"

const token_file_path: String = "/var/run/secrets/eks.amazonaws.com/serviceaccount/token"

const fake_token: String = "JWT.TOKEN.SIGNATURE"

const happy_xml: String = "<?xml version=\"1.0\" ?>
<AssumeRoleWithWebIdentityResponse xmlns=\"https://sts.amazonaws.com/doc/2011-06-15/\">
  <AssumeRoleWithWebIdentityResult>
    <Credentials>
      <AccessKeyId>AKID-WEB-IDENTITY</AccessKeyId>
      <SecretAccessKey>SECRET-WEB-IDENTITY</SecretAccessKey>
      <SessionToken>STS-SESSION-TOKEN</SessionToken>
      <Expiration>2030-01-02T03:04:05Z</Expiration>
    </Credentials>
    <SubjectFromWebIdentityToken>system:serviceaccount:default:test</SubjectFromWebIdentityToken>
  </AssumeRoleWithWebIdentityResult>
</AssumeRoleWithWebIdentityResponse>"

fn env_from(
  pairs: List(#(String, String)),
) -> fn(String) -> Result(String, Nil) {
  let env = dict.from_list(pairs)
  fn(name: String) { dict.get(env, name) }
}

fn reader_returning(contents: String) -> fn(String) -> Result(String, Nil) {
  fn(_path) { Ok(contents) }
}

fn ok_xml_response(
  xml: String,
) -> Result(response.Response(BitArray), HttpError) {
  Ok(response.Response(
    status: 200,
    headers: [],
    body: bit_array.from_string(xml),
  ))
}

pub fn happy_path_returns_credentials_test() {
  let send = fn(_req: Request(BitArray)) { ok_xml_response(happy_xml) }
  let provider =
    credentials.from_web_identity_with(
      send: send,
      endpoint: test_endpoint,
      role_arn: role_arn,
      role_session_name: session_name,
      token_file: token_file_path,
      duration_seconds: 3600,
      read_file: reader_returning(fake_token),
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.access_key_id |> should.equal("AKID-WEB-IDENTITY")
  creds.secret_access_key |> should.equal("SECRET-WEB-IDENTITY")
  creds.session_token |> should.equal(Some("STS-SESSION-TOKEN"))
  creds.expires_at |> should.equal(Some(1_893_553_445))
  creds.source |> should.equal("WebIdentity")
}

pub fn posts_form_encoded_body_with_required_fields_test() {
  let send = fn(req: Request(BitArray)) {
    req.method |> should.equal(http.Post)
    let assert Ok(ct) = request.get_header(req, "content-type")
    ct |> should.equal("application/x-www-form-urlencoded")
    let assert Ok(body) = bit_array.to_string(req.body)
    // Should include each required form field — URL-encoded.
    string.contains(body, "Action=AssumeRoleWithWebIdentity") |> should.be_true
    string.contains(body, "Version=2011-06-15") |> should.be_true
    // RoleArn is URL-encoded (`:` -> %3A, `/` -> %2F).
    string.contains(
      body,
      "RoleArn=arn%3Aaws%3Aiam%3A%3A123456789012%3Arole%2Ftest-role",
    )
    |> should.be_true
    string.contains(body, "RoleSessionName=" <> session_name)
    |> should.be_true
    string.contains(body, "WebIdentityToken=JWT.TOKEN.SIGNATURE")
    |> should.be_true
    string.contains(body, "DurationSeconds=3600") |> should.be_true
    ok_xml_response(happy_xml)
  }
  let provider =
    credentials.from_web_identity_with(
      send: send,
      endpoint: test_endpoint,
      role_arn: role_arn,
      role_session_name: session_name,
      token_file: token_file_path,
      duration_seconds: 3600,
      read_file: reader_returning(fake_token),
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn missing_token_file_env_is_not_configured_test() {
  let provider =
    credentials.from_web_identity_with_env(
      send: fn(_) { panic as "send must not be called" },
      lookup: env_from([]),
      read_file: reader_returning("ignored"),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured"
  }
}

pub fn missing_role_arn_env_is_not_configured_test() {
  let provider =
    credentials.from_web_identity_with_env(
      send: fn(_) { panic as "send must not be called" },
      lookup: env_from([
        #("AWS_WEB_IDENTITY_TOKEN_FILE", token_file_path),
      ]),
      read_file: reader_returning(fake_token),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured when AWS_ROLE_ARN missing"
  }
}

pub fn unreadable_token_file_is_fetch_failed_test() {
  // Both env vars present, but token file read fails — clearly a
  // misconfiguration the user needs to see.
  let provider =
    credentials.from_web_identity_with_env(
      send: fn(_) { panic as "send must not be called" },
      lookup: env_from([
        #("AWS_WEB_IDENTITY_TOKEN_FILE", token_file_path),
        #("AWS_ROLE_ARN", role_arn),
      ]),
      read_file: fn(_) { Error(Nil) },
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed when token file unreadable"
  }
}

pub fn non_2xx_response_is_fetch_failed_test() {
  let send = fn(_req: Request(BitArray)) {
    Ok(response.Response(
      status: 403,
      headers: [],
      body: bit_array.from_string("<Error>...</Error>"),
    ))
  }
  let provider =
    credentials.from_web_identity_with(
      send: send,
      endpoint: test_endpoint,
      role_arn: role_arn,
      role_session_name: session_name,
      token_file: token_file_path,
      duration_seconds: 3600,
      read_file: reader_returning(fake_token),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed on 403"
  }
}

pub fn malformed_xml_is_fetch_failed_test() {
  let send = fn(_req: Request(BitArray)) {
    ok_xml_response("<not><well-formed></enough>")
  }
  let provider =
    credentials.from_web_identity_with(
      send: send,
      endpoint: test_endpoint,
      role_arn: role_arn,
      role_session_name: session_name,
      token_file: token_file_path,
      duration_seconds: 3600,
      read_file: reader_returning(fake_token),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for malformed XML"
  }
}

pub fn token_file_whitespace_trimmed_test() {
  let send = fn(req: Request(BitArray)) {
    let assert Ok(body) = bit_array.to_string(req.body)
    // Whitespace at edges of token file content shouldn't leak into form body.
    string.contains(body, "WebIdentityToken=TOKEN-VALUE")
    |> should.be_true
    string.contains(body, "WebIdentityToken=TOKEN-VALUE%0A")
    |> should.be_false
    ok_xml_response(happy_xml)
  }
  let provider =
    credentials.from_web_identity_with(
      send: send,
      endpoint: test_endpoint,
      role_arn: role_arn,
      role_session_name: session_name,
      token_file: token_file_path,
      duration_seconds: 3600,
      read_file: reader_returning("  TOKEN-VALUE\n"),
    )
  let assert Ok(_) = credentials.fetch(provider)
}
