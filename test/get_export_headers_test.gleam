//// Regression test: restjson1's `parse_<op>_response` ignores
//// `@httpHeader` and `@httpResponseCode` members. API Gateway's
//// `GetExport` is the simplest concrete case — its `ExportResponse`
//// binds:
////
////   * `body`               — `@httpPayload` (raw bytes)
////   * `content_disposition` — `@httpHeader("Content-Disposition")`
////   * `content_type`        — `@httpHeader("Content-Type")`
////
//// Before this fix, the codegen hardcoded the two header members to
//// `option.None`, so every caller of `get_export` silently lost the
//// MIME info needed to actually save the export to disk.

import aws/services/api_gateway
import gleam/dict
import gleam/option
import gleeunit/should

fn fake_headers() -> dict.Dict(String, String) {
  dict.from_list([
    #("content-type", "application/yaml"),
    #("content-disposition", "attachment; filename=\"export.yaml\""),
  ])
}

pub fn parse_get_export_response_extracts_header_members_test() {
  let body = <<"openapi: 3.0.1":utf8>>
  let assert Ok(out) =
    api_gateway.parse_get_export_response(200, fake_headers(), body)

  out.content_type |> should.equal(option.Some("application/yaml"))
  out.content_disposition
  |> should.equal(option.Some("attachment; filename=\"export.yaml\""))
}

pub fn parse_get_export_response_payload_still_populates_test() {
  // Don't regress the payload binding while wiring headers in.
  let body = <<"openapi: 3.0.1":utf8>>
  let assert Ok(out) =
    api_gateway.parse_get_export_response(200, fake_headers(), body)
  let assert option.Some(payload_bytes) = out.body
  payload_bytes |> should.equal(body)
}
