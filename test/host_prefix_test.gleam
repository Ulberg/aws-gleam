//// Covers `@smithy.api#endpoint.hostPrefix` substitution at the
//// runtime layer (`invoke_with_endpoint_params_and_host_prefix`).
//// Mirrors the Rust SDK's `apply_endpoint_to_request` — prepend the
//// already-substituted prefix to the authority, leave scheme + path
//// untouched, and update the Host header so SigV4 canonicalises
//// against the prefixed host.

import aws/credentials
import aws/internal/client/runtime
import aws/internal/http_send
import gleam/bit_array
import gleam/dict
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleeunit/should

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

fn capture_send(
  inbox: process.Subject(#(String, String, String)),
) -> http_send.Send {
  fn(req: Request(BitArray)) {
    let host =
      list.find(req.headers, fn(h) { h.0 == "host" })
      |> result.map(fn(h) { h.1 })
      |> result.unwrap("")
    process.send(inbox, #(req.host, req.path, host))
    Ok(response.Response(status: 200, headers: [], body: <<>>))
  }
}

fn fresh_config(send: http_send.Send) -> runtime.ClientConfig {
  runtime.default_config("us-east-1", "s3", "s3")
  |> runtime.with_credentials_provider(static_credentials())
  |> runtime.with_http_send(send)
}

pub fn host_prefix_prepends_to_authority_and_host_header_test() {
  let inbox = process.new_subject()
  let config = fresh_config(capture_send(inbox))
  let built = #(
    "POST",
    "/WriteGetObjectResponse",
    dict.from_list([#("Content-Type", "application/octet-stream")]),
    bit_array.from_string("body"),
  )
  let _ =
    runtime.invoke_with_endpoint_params_and_host_prefix(
      config,
      dict.new(),
      Some("foo."),
      built,
      fn(_code, _headers, _body) { Ok(Nil) },
    )
  case process.receive(inbox, 1000) {
    Ok(#(req_host, req_path, host_header)) -> {
      // The transport sees the prefixed authority on both the
      // request URL and the Host header.
      req_host |> should.equal("foo.s3.us-east-1.amazonaws.com")
      req_path |> should.equal("/WriteGetObjectResponse")
      host_header |> should.equal("foo.s3.us-east-1.amazonaws.com")
    }
    Error(_) -> should.fail()
  }
}

pub fn host_prefix_none_leaves_authority_unchanged_test() {
  let inbox = process.new_subject()
  let config = fresh_config(capture_send(inbox))
  let built = #(
    "GET",
    "/",
    dict.new(),
    <<>>,
  )
  let _ =
    runtime.invoke_with_endpoint_params_and_host_prefix(
      config,
      dict.new(),
      None,
      built,
      fn(_code, _headers, _body) { Ok(Nil) },
    )
  case process.receive(inbox, 1000) {
    Ok(#(req_host, _, host_header)) -> {
      req_host |> should.equal("s3.us-east-1.amazonaws.com")
      host_header |> should.equal("s3.us-east-1.amazonaws.com")
    }
    Error(_) -> should.fail()
  }
}
