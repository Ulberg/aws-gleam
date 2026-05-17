//// Tests for the STS AssumeRole provider. We don't talk to real STS —
//// the upstream contract is well-defined, so we drive a stub `Send`
//// that returns the same XML shape the live service does and assert
//// the provider unpacks it correctly. The signature on the outgoing
//// request is also asserted: AssumeRole MUST sign with the supplied
//// source credentials (it's how STS authenticates the caller).

import aws/credentials
import aws/internal/http_send
import aws/internal/providers/sts
import aws/internal/sigv4
import gleam/bit_array
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

fn fixed_timestamp() -> String {
  "20240117T000000Z"
}

fn source_credentials() -> sigv4.SigningCredentials {
  sigv4.SigningCredentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
  )
}

fn canned_response_xml() -> BitArray {
  <<
    "<AssumeRoleResponse><AssumeRoleResult><Credentials><AccessKeyId>ASIAXIAOXEX1AMPLE</AccessKeyId><SecretAccessKey>SECRET/EXAMPLE</SecretAccessKey><SessionToken>SESSION-EXAMPLE-TOKEN</SessionToken><Expiration>2024-01-17T01:00:00Z</Expiration></Credentials></AssumeRoleResult></AssumeRoleResponse>":utf8,
  >>
}

fn capturing_send(
  captured: process.Subject(Request(BitArray)),
  body: BitArray,
) -> http_send.Send {
  fn(req: Request(BitArray)) {
    process.send(captured, req)
    Ok(response.Response(status: 200, headers: [], body: body))
  }
}

fn options() -> sts.Options {
  sts.Options(
    endpoint: "https://sts.amazonaws.com/",
    region: "us-east-1",
    role_arn: "arn:aws:iam::123456789012:role/Demo",
    role_session_name: "test-session",
    duration_seconds: 900,
    external_id: None,
  )
}

pub fn fetch_unpacks_assume_role_credentials_test() {
  let captured = process.new_subject()
  let send = capturing_send(captured, canned_response_xml())

  let result =
    sts.fetch(
      send: send,
      source: source_credentials(),
      options: options(),
      timestamp: fixed_timestamp,
    )

  case result {
    Ok(c) -> {
      c.access_key_id |> should.equal("ASIAXIAOXEX1AMPLE")
      c.secret_access_key |> should.equal("SECRET/EXAMPLE")
      c.session_token |> should.equal("SESSION-EXAMPLE-TOKEN")
      // 2024-01-17T01:00:00Z = 1705453200
      c.expires_at |> should.equal(1_705_453_200)
    }
    Error(e) -> panic as { "expected Ok, got error: " <> describe_error(e) }
  }
}

pub fn fetch_signs_the_outgoing_request_with_sigv4_test() {
  let captured = process.new_subject()
  let send = capturing_send(captured, canned_response_xml())

  let _ =
    sts.fetch(
      send: send,
      source: source_credentials(),
      options: options(),
      timestamp: fixed_timestamp,
    )

  case process.receive(captured, 0) {
    Ok(req) -> {
      // SigV4 always sets these headers; their presence is the strongest
      // contract test for "we actually signed it".
      has_header(req, "authorization") |> should.be_true
      has_header(req, "x-amz-date") |> should.be_true
      has_header(req, "x-amz-content-sha256") |> should.be_true
    }
    Error(_) -> panic as "no request captured"
  }
}

pub fn fetch_emits_assume_role_action_in_body_test() {
  let captured = process.new_subject()
  let send = capturing_send(captured, canned_response_xml())

  let _ =
    sts.fetch(
      send: send,
      source: source_credentials(),
      options: options(),
      timestamp: fixed_timestamp,
    )

  case process.receive(captured, 0) {
    Ok(req) -> {
      let body_str = case bit_array.to_string(req.body) {
        Ok(s) -> s
        Error(_) -> ""
      }
      // Assert on substrings so the test is robust to parameter
      // ordering inside the form-encoded body.
      string.contains(body_str, "Action=AssumeRole") |> should.be_true
      string.contains(body_str, "Version=2011-06-15") |> should.be_true
      string.contains(body_str, "RoleSessionName=test-session")
      |> should.be_true
      string.contains(body_str, "DurationSeconds=900") |> should.be_true
    }
    Error(_) -> panic as "no request captured"
  }
}

pub fn fetch_surfaces_http_failure_as_failed_test() {
  let send = fn(_req) {
    Ok(response.Response(status: 403, headers: [], body: <<>>))
  }

  case
    sts.fetch(
      send: send,
      source: source_credentials(),
      options: options(),
      timestamp: fixed_timestamp,
    )
  {
    Error(sts.Failed(reason: r)) ->
      string.contains(r, "status 403") |> should.be_true
    other -> panic as { "expected Failed, got " <> describe_either(other) }
  }
}

pub fn from_assume_role_wraps_source_provider_test() {
  let send = fn(_req) {
    Ok(response.Response(status: 200, headers: [], body: canned_response_xml()))
  }
  let static_outer =
    credentials.static_provider(credentials.Credentials(
      access_key_id: "OUTER-AKID",
      secret_access_key: "outer-secret",
      session_token: None,
      expires_at: None,
      source: "Static",
    ))

  let provider =
    credentials.from_assume_role_with(
      source: static_outer,
      send: send,
      region: "us-east-1",
      role_arn: "arn:aws:iam::1:role/Demo",
      role_session_name: "test",
      external_id: None,
      endpoint: "https://sts.amazonaws.com/",
      duration_seconds: 900,
      timestamp: fixed_timestamp,
    )

  case credentials.fetch(provider) {
    Ok(c) -> {
      c.access_key_id |> should.equal("ASIAXIAOXEX1AMPLE")
      c.session_token |> should.equal(Some("SESSION-EXAMPLE-TOKEN"))
    }
    Error(_) -> panic as "expected Ok credentials"
  }
}

pub fn from_assume_role_propagates_source_failure_test() {
  // If the source provider can't produce creds, the assume-role wrap
  // must surface the underlying error rather than papering over it.
  let failing_source =
    credentials.Provider(name: "AlwaysFails", fetch: fn() {
      Error(credentials.NotConfigured(reason: "no source"))
    })
  let provider =
    credentials.from_assume_role_with(
      source: failing_source,
      send: fn(_req) {
        // Should never be called when source fails.
        Ok(response.Response(status: 200, headers: [], body: <<>>))
      },
      region: "us-east-1",
      role_arn: "arn:aws:iam::1:role/Demo",
      role_session_name: "test",
      external_id: None,
      endpoint: "https://sts.amazonaws.com/",
      duration_seconds: 900,
      timestamp: fixed_timestamp,
    )

  case credentials.fetch(provider) {
    Error(credentials.NotConfigured(_)) -> Nil
    other ->
      panic as { "expected NotConfigured, got " <> describe_provider(other) }
  }
}

fn has_header(req: Request(a), name: String) -> Bool {
  list.any(req.headers, fn(h) {
    string.lowercase(h.0) == string.lowercase(name)
  })
}

fn describe_error(e: sts.Error) -> String {
  case e {
    sts.Misconfigured(reason: r) -> "Misconfigured: " <> r
    sts.Failed(reason: r) -> "Failed: " <> r
  }
}

fn describe_either(r: Result(sts.StsCredentials, sts.Error)) -> String {
  case r {
    Ok(_) -> "Ok(_)"
    Error(e) -> "Error(" <> describe_error(e) <> ")"
  }
}

fn describe_provider(
  r: Result(credentials.Credentials, credentials.ProviderError),
) -> String {
  case r {
    Ok(_) -> "Ok(_)"
    Error(credentials.NotConfigured(reason: r)) -> "NotConfigured: " <> r
    Error(credentials.FetchFailed(reason: r)) -> "FetchFailed: " <> r
    Error(credentials.ChainExhausted(_)) -> "ChainExhausted"
  }
}
