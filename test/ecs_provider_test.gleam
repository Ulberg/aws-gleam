//// Unit tests for the ECS container credentials provider.

import aws/credentials.{FetchFailed, NotConfigured}
import aws/internal/http_send.{type HttpError}
import gleam/bit_array
import gleam/dict
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{None, Some}
import gleeunit/should

fn env_from(
  pairs: List(#(String, String)),
) -> fn(String) -> Result(String, Nil) {
  let env = dict.from_list(pairs)
  fn(name: String) { dict.get(env, name) }
}

fn no_files() -> fn(String) -> Result(String, Nil) {
  fn(_path: String) { Error(Nil) }
}

fn ok_response(
  status: Int,
  body: String,
) -> Result(response.Response(BitArray), HttpError) {
  Ok(response.Response(
    status: status,
    headers: [],
    body: bit_array.from_string(body),
  ))
}

const happy_body: String = "{\"AccessKeyId\":\"AKID\",\"SecretAccessKey\":\"SECRET\",\"Token\":\"TOK\",\"Expiration\":\"2030-01-02T03:04:05Z\"}"

pub fn happy_path_with_full_uri_test() {
  let lookup =
    env_from([
      #(
        "AWS_CONTAINER_CREDENTIALS_FULL_URI",
        "http://10.0.0.1:80/v2/credentials/abc",
      ),
    ])
  let send = fn(req: Request(BitArray)) {
    req.host |> should.equal("10.0.0.1")
    req.path |> should.equal("/v2/credentials/abc")
    req.method |> should.equal(http.Get)
    ok_response(200, happy_body)
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.access_key_id |> should.equal("AKID")
  creds.session_token |> should.equal(Some("TOK"))
  creds.expires_at |> should.equal(Some(1_893_553_445))
  creds.source |> should.equal("ECS")
}

pub fn relative_uri_uses_link_local_base_test() {
  let lookup =
    env_from([
      #("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI", "/v2/credentials/task-arn"),
    ])
  let send = fn(req: Request(BitArray)) {
    req.host |> should.equal("169.254.170.2")
    req.path |> should.equal("/v2/credentials/task-arn")
    ok_response(200, happy_body)
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn full_uri_takes_precedence_over_relative_test() {
  let lookup =
    env_from([
      #("AWS_CONTAINER_CREDENTIALS_FULL_URI", "http://full.example/abc"),
      #("AWS_CONTAINER_CREDENTIALS_RELATIVE_URI", "/should-be-ignored"),
    ])
  let send = fn(req: Request(BitArray)) {
    req.host |> should.equal("full.example")
    req.path |> should.equal("/abc")
    ok_response(200, happy_body)
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn no_uri_env_var_is_not_configured_test() {
  let provider =
    credentials.from_ecs_with_env(
      send: fn(_) { panic as "send must not be called" },
      lookup: env_from([]),
      read_file: no_files(),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured"
  }
}

pub fn auth_token_env_sets_authorization_header_test() {
  let lookup =
    env_from([
      #("AWS_CONTAINER_CREDENTIALS_FULL_URI", "http://10.0.0.1/abc"),
      #("AWS_CONTAINER_AUTHORIZATION_TOKEN", "Bearer hunter2"),
    ])
  let send = fn(req: Request(BitArray)) {
    let assert Ok(auth) = request.get_header(req, "authorization")
    auth |> should.equal("Bearer hunter2")
    ok_response(200, happy_body)
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn auth_token_file_is_read_when_inline_token_absent_test() {
  let lookup =
    env_from([
      #("AWS_CONTAINER_CREDENTIALS_FULL_URI", "http://10.0.0.1/abc"),
      #("AWS_CONTAINER_AUTHORIZATION_TOKEN_FILE", "/secrets/auth.token"),
    ])
  let read_file = fn(path: String) {
    case path {
      "/secrets/auth.token" -> Ok("ROTATED-TOKEN-VALUE\n")
      _ -> Error(Nil)
    }
  }
  let send = fn(req: Request(BitArray)) {
    let assert Ok(auth) = request.get_header(req, "authorization")
    // Whitespace trimmed by resolver.
    auth |> should.equal("ROTATED-TOKEN-VALUE")
    ok_response(200, happy_body)
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: read_file,
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn no_auth_token_omits_authorization_header_test() {
  let lookup =
    env_from([#("AWS_CONTAINER_CREDENTIALS_FULL_URI", "http://10.0.0.1/abc")])
  let send = fn(req: Request(BitArray)) {
    request.get_header(req, "authorization") |> should.equal(Error(Nil))
    ok_response(200, happy_body)
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn transport_failure_is_not_configured_test() {
  // ECS doesn't have the equivalent of IMDS's token-PUT gate; any transport
  // failure is the chain's "not in this environment" signal.
  let lookup =
    env_from([#("AWS_CONTAINER_CREDENTIALS_FULL_URI", "http://10.0.0.1/abc")])
  let send = fn(_req) {
    Error(http_send.ConnectFailed(reason: "no route to host"))
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured on transport failure"
  }
}

pub fn non_200_status_is_fetch_failed_test() {
  let lookup =
    env_from([#("AWS_CONTAINER_CREDENTIALS_FULL_URI", "http://10.0.0.1/abc")])
  let send = fn(_req) { ok_response(500, "") }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed on 500"
  }
}

pub fn missing_token_in_response_yields_none_session_token_test() {
  // ECS responses for IAM Roles for Tasks always include Token, but the
  // wire format permits its absence. Verify we tolerate that.
  let lookup =
    env_from([#("AWS_CONTAINER_CREDENTIALS_FULL_URI", "http://10.0.0.1/abc")])
  let send = fn(_req) {
    ok_response(
      200,
      "{\"AccessKeyId\":\"AKID\",\"SecretAccessKey\":\"SECRET\",\"Expiration\":\"2030-01-02T03:04:05Z\"}",
    )
  }
  let provider =
    credentials.from_ecs_with_env(
      send: send,
      lookup: lookup,
      read_file: no_files(),
    )
  let assert Ok(creds) = credentials.fetch(provider)
  creds.session_token |> should.equal(None)
}
