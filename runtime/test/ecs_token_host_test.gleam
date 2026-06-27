//// Security regression tests for issue #28: the ECS auth token must only be
//// attached to the metadata request when the destination is trusted (a
//// loopback / ECS / EKS host, or any https host). Otherwise an attacker who
//// controls `AWS_CONTAINER_CREDENTIALS_FULL_URI` could exfiltrate the bearer
//// token to an arbitrary host over plain HTTP.

import aws/credentials
import aws/internal/http_send.{type HttpError}
import aws/internal/providers/ecs
import gleam/bit_array
import gleam/dict
import gleam/http/request.{type Request}
import gleam/http/response
import gleeunit/should

const happy_body: String = "{\"AccessKeyId\":\"AKID\",\"SecretAccessKey\":\"SECRET\",\"Token\":\"TOK\",\"Expiration\":\"2030-01-02T03:04:05Z\"}"

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

/// Drive the ECS provider against `full_uri` with an auth token configured,
/// asserting that the outgoing `Authorization` header matches `expect_header`
/// (`Ok(token)` when sent, `Error(Nil)` when withheld).
fn assert_auth_header(full_uri: String, expect_header: Result(String, Nil)) {
  let token = "Bearer secret-token"
  let lookup =
    env_from([
      #("AWS_CONTAINER_CREDENTIALS_FULL_URI", full_uri),
      #("AWS_CONTAINER_AUTHORIZATION_TOKEN", token),
    ])
  let send = fn(req: Request(BitArray)) {
    let expected = case expect_header {
      Ok(_) -> Ok(token)
      Error(Nil) -> Error(Nil)
    }
    request.get_header(req, "authorization") |> should.equal(expected)
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

// ---- pure helper: `ecs_uri_allows_auth` ----

pub fn allows_auth_loopback_ipv4_test() {
  ecs.ecs_uri_allows_auth("http://127.0.0.1/v2/credentials")
  |> should.be_true
}

pub fn allows_auth_loopback_ipv4_anywhere_in_block_test() {
  // Any 127.x.x.x is loopback (127.0.0.0/8).
  ecs.ecs_uri_allows_auth("http://127.255.1.9:8080/creds") |> should.be_true
}

pub fn allows_auth_localhost_test() {
  ecs.ecs_uri_allows_auth("http://localhost/creds") |> should.be_true
}

pub fn allows_auth_localhost_is_case_insensitive_test() {
  ecs.ecs_uri_allows_auth("http://LOCALHOST/creds") |> should.be_true
}

pub fn allows_auth_ipv6_loopback_test() {
  ecs.ecs_uri_allows_auth("http://[::1]/creds") |> should.be_true
}

pub fn allows_auth_ecs_link_local_test() {
  ecs.ecs_uri_allows_auth("http://169.254.170.2/v2/credentials/x")
  |> should.be_true
}

pub fn allows_auth_eks_link_local_test() {
  ecs.ecs_uri_allows_auth("http://169.254.170.23/v1/credentials")
  |> should.be_true
}

pub fn allows_auth_https_any_host_test() {
  ecs.ecs_uri_allows_auth("https://example.com/creds") |> should.be_true
}

pub fn allows_auth_https_is_case_insensitive_scheme_test() {
  ecs.ecs_uri_allows_auth("HTTPS://example.com/creds") |> should.be_true
}

pub fn withholds_auth_arbitrary_http_host_test() {
  ecs.ecs_uri_allows_auth("http://attacker.example/creds") |> should.be_false
}

pub fn withholds_auth_imds_address_test() {
  // The IMDS link-local address (169.254.169.254) is NOT the ECS/EKS host.
  ecs.ecs_uri_allows_auth("http://169.254.169.254/creds") |> should.be_false
}

pub fn withholds_auth_private_http_host_test() {
  ecs.ecs_uri_allows_auth("http://10.0.0.1/creds") |> should.be_false
}

pub fn withholds_auth_unparseable_url_test() {
  ecs.ecs_uri_allows_auth("not a url") |> should.be_false
}

// ---- wired behavior: token sent vs withheld through the provider ----

pub fn token_sent_to_loopback_test() {
  assert_auth_header("http://127.0.0.1/creds", Ok("sent"))
}

pub fn token_sent_to_localhost_test() {
  assert_auth_header("http://localhost/creds", Ok("sent"))
}

pub fn token_sent_to_ecs_endpoint_test() {
  assert_auth_header("http://169.254.170.2/v2/credentials/x", Ok("sent"))
}

pub fn token_sent_to_eks_endpoint_test() {
  assert_auth_header("http://169.254.170.23/v1/credentials", Ok("sent"))
}

pub fn token_sent_over_https_test() {
  assert_auth_header("https://example.com/creds", Ok("sent"))
}

pub fn token_withheld_from_attacker_test() {
  assert_auth_header("http://attacker.example/creds", Error(Nil))
}

pub fn token_withheld_from_imds_address_test() {
  assert_auth_header("http://169.254.169.254/creds", Error(Nil))
}
