//// Unit tests for the IMDSv2 provider. Drives the 3-step flow with a stub
//// `Send` callback that pattern-matches on (method, path) and returns
//// scripted responses.

import aws/credentials.{FetchFailed, NotConfigured}
import aws/internal/http_send.{type HttpError}
import gleam/bit_array
import gleam/http
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/option.{Some}
import gleeunit/should

const test_endpoint: String = "http://169.254.169.254"

const fake_token: String = "FAKETOKEN"

const fake_role: String = "ec2-role"

// A `Send` that scripts the canonical happy-path responses for the 3-step
// IMDSv2 flow.
fn happy_path_send(
  req: Request(BitArray),
) -> Result(response.Response(BitArray), HttpError) {
  case req.method, req.path {
    http.Put, "/latest/api/token" ->
      ok_response(200, bit_array.from_string(fake_token))
    http.Get, "/latest/meta-data/iam/security-credentials/" ->
      ok_response(200, bit_array.from_string(fake_role))
    http.Get, "/latest/meta-data/iam/security-credentials/" <> _rest ->
      ok_response(
        200,
        bit_array.from_string(
          "{\"Code\":\"Success\","
          <> "\"AccessKeyId\":\"AKID\","
          <> "\"SecretAccessKey\":\"SECRET\","
          <> "\"Token\":\"SESSIONTOKEN\","
          <> "\"Expiration\":\"2030-01-02T03:04:05Z\","
          <> "\"LastUpdated\":\"2030-01-02T03:00:00Z\"}",
        ),
      )
    _, _ -> Error(http_send.Other(reason: "unexpected request"))
  }
}

fn ok_response(
  status: Int,
  body: BitArray,
) -> Result(response.Response(BitArray), HttpError) {
  Ok(response.Response(status: status, headers: [], body: body))
}

fn imds_provider_with(
  send: fn(Request(BitArray)) -> Result(response.Response(BitArray), HttpError),
) -> credentials.Provider {
  credentials.from_imds_with(
    send: send,
    endpoint: test_endpoint,
    token_ttl_seconds: 60,
  )
}

pub fn happy_path_returns_credentials_test() {
  let provider = imds_provider_with(happy_path_send)
  let assert Ok(creds) = credentials.fetch(provider)
  creds.access_key_id |> should.equal("AKID")
  creds.secret_access_key |> should.equal("SECRET")
  creds.session_token |> should.equal(Some("SESSIONTOKEN"))
  // 2030-01-02T03:04:05Z = 1893553445 (cross-check against Python's
  // datetime(2030,1,2,3,4,5,tzinfo=timezone.utc).timestamp()).
  creds.expires_at |> should.equal(Some(1_893_553_445))
  creds.source |> should.equal("IMDSv2")
}

pub fn token_put_uses_put_method_and_ttl_header_test() {
  // Capture the request that comes through as the token PUT, then short-
  // circuit the rest of the flow.
  let send = fn(req: Request(BitArray)) {
    case req.method, req.path {
      http.Put, "/latest/api/token" -> {
        // Header lookup is case-insensitive in gleam_http.
        let assert Ok(ttl) =
          request.get_header(req, "x-aws-ec2-metadata-token-ttl-seconds")
        ttl |> should.equal("60")
        ok_response(200, bit_array.from_string(fake_token))
      }
      _, _ -> happy_path_send(req)
    }
  }
  let provider = imds_provider_with(send)
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn role_and_creds_calls_include_token_header_test() {
  let send = fn(req: Request(BitArray)) {
    case req.method, req.path {
      http.Put, "/latest/api/token" ->
        ok_response(200, bit_array.from_string(fake_token))
      http.Get, _ -> {
        let assert Ok(token) =
          request.get_header(req, "x-aws-ec2-metadata-token")
        token |> should.equal(fake_token)
        happy_path_send(req)
      }
      _, _ -> happy_path_send(req)
    }
  }
  let provider = imds_provider_with(send)
  let assert Ok(_) = credentials.fetch(provider)
}

pub fn token_request_failure_yields_not_configured_test() {
  let send = fn(req: Request(BitArray)) {
    case req.method, req.path {
      http.Put, "/latest/api/token" ->
        Error(http_send.ConnectFailed(reason: "no route to host"))
      _, _ -> happy_path_send(req)
    }
  }
  let provider = imds_provider_with(send)
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured when token PUT fails"
  }
}

pub fn token_404_yields_not_configured_test() {
  let send = fn(req: Request(BitArray)) {
    case req.method, req.path {
      http.Put, "/latest/api/token" ->
        ok_response(404, bit_array.from_string(""))
      _, _ -> happy_path_send(req)
    }
  }
  let provider = imds_provider_with(send)
  let assert Error(err) = credentials.fetch(provider)
  case err {
    NotConfigured(_) -> Nil
    _ -> panic as "expected NotConfigured on 404 token"
  }
}

pub fn role_fetch_failure_yields_fetch_failed_test() {
  // Token succeeded → past the "not on EC2" gate. Downstream failure is loud.
  let send = fn(req: Request(BitArray)) {
    case req.method, req.path {
      http.Put, "/latest/api/token" ->
        ok_response(200, bit_array.from_string(fake_token))
      http.Get, "/latest/meta-data/iam/security-credentials/" ->
        ok_response(500, bit_array.from_string(""))
      _, _ -> happy_path_send(req)
    }
  }
  let provider = imds_provider_with(send)
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed when role listing 500s"
  }
}

pub fn malformed_credentials_json_yields_fetch_failed_test() {
  let send = fn(req: Request(BitArray)) {
    case req.method, req.path {
      http.Get, "/latest/meta-data/iam/security-credentials/" <> _ ->
        ok_response(200, bit_array.from_string("not json"))
      _, _ -> happy_path_send(req)
    }
  }
  let provider = imds_provider_with(send)
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed for malformed JSON"
  }
}

pub fn code_not_success_yields_fetch_failed_test() {
  let send = fn(req: Request(BitArray)) {
    case req.method, req.path {
      http.Get, "/latest/meta-data/iam/security-credentials/" <> _ ->
        ok_response(
          200,
          bit_array.from_string(
            "{\"Code\":\"AssumeRoleUnauthorizedAccess\","
            <> "\"Message\":\"can't get creds\"}",
          ),
        )
      _, _ -> happy_path_send(req)
    }
  }
  let provider = imds_provider_with(send)
  let assert Error(err) = credentials.fetch(provider)
  case err {
    FetchFailed(_) -> Nil
    _ -> panic as "expected FetchFailed when Code != Success"
  }
}
