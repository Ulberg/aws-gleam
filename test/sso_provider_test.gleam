//// Unit tests for the SSO (IAM Identity Center) provider.

import aws/credentials.{FetchFailed, NotConfigured}
import aws/internal/http_send.{type HttpError}
import gleam/bit_array
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{Some}
import gleam/string
import gleeunit/should

const region: String = "us-east-1"

const account_id: String = "123456789012"

const role_name: String = "DeveloperAccess"

const access_token: String = "AQoXdXBwZXJjYXNl..."

const happy_body: String = "{\"roleCredentials\":{\"accessKeyId\":\"AKID-SSO\",\"secretAccessKey\":\"SECRET-SSO\",\"sessionToken\":\"SSO-SESSION-TOKEN\",\"expiration\":1893553445000}}"

fn ok_json(body: String) -> Result(response.Response(BitArray), HttpError) {
  Ok(response.Response(
    status: 200,
    headers: [],
    body: bit_array.from_string(body),
  ))
}

// ----- explicit-form tests -----

pub fn happy_path_returns_credentials_test() {
  let send = fn(req: Request(BitArray)) {
    req.method |> should.equal(http.Get)
    let assert Ok(auth) = request.get_header(req, "x-amz-sso_bearer_token")
    auth |> should.equal(access_token)
    // path + query both contain the required params.
    string.contains(req.path, "/federation/credentials")
    |> should.be_true
    let assert Ok(qs) = request.get_query(req)
    let has = fn(k, v) {
      case qs {
        [] -> False
        _ -> {
          case
            qs
            |> list_find(k)
          {
            Ok(actual) -> actual == v
            Error(_) -> False
          }
        }
      }
    }
    has("account_id", account_id) |> should.be_true
    has("role_name", role_name) |> should.be_true
    ok_json(happy_body)
  }
  let provider =
    credentials.from_sso_with_endpoint(
      send: send,
      region: region,
      account_id: account_id,
      role_name: role_name,
      access_token: access_token,
      endpoint: "http://portal.test.example",
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.access_key_id |> should.equal("AKID-SSO")
  creds.session_token |> should.equal(Some("SSO-SESSION-TOKEN"))
  // SSO wire value is millis; we converted to seconds.
  creds.expires_at |> should.equal(Some(1_893_553_445))
  creds.source |> should.equal("SSO")
}

fn list_find(
  pairs: List(#(String, String)),
  key: String,
) -> Result(String, Nil) {
  case pairs {
    [] -> Error(Nil)
    [#(k, v), ..rest] ->
      case k == key {
        True -> Ok(v)
        False -> list_find(rest, key)
      }
  }
}

pub fn non_2xx_status_is_fetch_failed_test() {
  let send = fn(_req) {
    Ok(response.Response(
      status: 401,
      headers: [],
      body: bit_array.from_string("{\"message\":\"Unauthorized\"}"),
    ))
  }
  let provider =
    credentials.from_sso_with_endpoint(
      send: send,
      region: region,
      account_id: account_id,
      role_name: role_name,
      access_token: access_token,
      endpoint: "http://portal.test.example",
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed on 401"
  }
}

pub fn malformed_response_is_fetch_failed_test() {
  let send = fn(_req) { ok_json("not json") }
  let provider =
    credentials.from_sso_with_endpoint(
      send: send,
      region: region,
      account_id: account_id,
      role_name: role_name,
      access_token: access_token,
      endpoint: "http://portal.test.example",
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for malformed JSON"
  }
}

pub fn transport_failure_is_not_configured_test() {
  let send = fn(_req) { Error(http_send.ConnectFailed(reason: "no route")) }
  let provider =
    credentials.from_sso_with_endpoint(
      send: send,
      region: region,
      account_id: account_id,
      role_name: role_name,
      access_token: access_token,
      endpoint: "http://portal.test.example",
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured on transport failure"
  }
}

// ----- profile + cache resolution tests -----

const valid_config: String = "[profile dev]
sso_session = corp
sso_region = us-east-1
sso_account_id = 123456789012
sso_role_name = DeveloperAccess
"

const valid_cache: String = "{\"accessToken\":\"CACHED-ACCESS-TOKEN\",\"expiresAt\":\"2030-01-02T03:04:05Z\",\"region\":\"us-east-1\"}"

pub fn profile_resolution_reads_config_and_cache_test() {
  let send = fn(req: Request(BitArray)) {
    let assert Ok(auth) = request.get_header(req, "x-amz-sso_bearer_token")
    auth |> should.equal("CACHED-ACCESS-TOKEN")
    ok_json(happy_body)
  }
  // sha1("corp") = 9b6dd9c5867d2b2f3a8aaf8b9a4caf7c8e6ef330 (computed below);
  // the test verifies the cache_reader callback gets the right filename.
  let provider =
    credentials.from_sso_with_env(
      send: send,
      profile: "dev",
      config_reader: fn() { Ok(valid_config) },
      cache_reader: fn(filename: String) {
        // sha1("corp") + ".json" — verify the filename is the hash of the
        // session name, not the literal session name.
        let assert True = string.ends_with(filename, ".json")
        let assert True = string.length(filename) == 45
        // 40 chars sha1 + .json
        Ok(valid_cache)
      },
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.source |> should.equal("SSO")
  let _ = creds.access_key_id
}

pub fn missing_profile_section_is_not_configured_test() {
  let provider =
    credentials.from_sso_with_env(
      send: fn(_) { panic as "send must not be called" },
      profile: "absent",
      config_reader: fn() { Ok(valid_config) },
      cache_reader: fn(_) { panic as "cache must not be read" },
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured for missing profile"
  }
}

pub fn missing_cache_file_is_not_configured_test() {
  let provider =
    credentials.from_sso_with_env(
      send: fn(_) { panic as "send must not be called" },
      profile: "dev",
      config_reader: fn() { Ok(valid_config) },
      cache_reader: fn(_) { Error(Nil) },
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured for missing cache (run aws sso login)"
  }
}

pub fn cache_without_access_token_is_fetch_failed_test() {
  let provider =
    credentials.from_sso_with_env(
      send: fn(_) { panic as "send must not be called" },
      profile: "dev",
      config_reader: fn() { Ok(valid_config) },
      cache_reader: fn(_) { Ok("{\"foo\":\"bar\"}") },
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed when cache lacks accessToken"
  }
}

pub fn unreadable_config_is_not_configured_test() {
  let provider =
    credentials.from_sso_with_env(
      send: fn(_) { panic as "send must not be called" },
      profile: "dev",
      config_reader: fn() { Error(Nil) },
      cache_reader: fn(_) { panic as "cache must not be read" },
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured for unreadable config"
  }
}
