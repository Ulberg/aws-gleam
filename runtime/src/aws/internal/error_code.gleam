//// Shared modeled-error-code extraction. AWS error responses carry the
//// modeled error *code* (the Smithy shape's local name) in one of three
//// places, depending on protocol: the `X-Amzn-Errortype` header
//// (awsJson*, restJson1), a JSON body `__type` / `code` field, or a
//// restXml `<Code>` element. This module pulls that local shape name
//// out — namespace prefix, URI suffix, and Smithy `[Charlie,foo]`
//// disambiguation suffix all stripped.
////
//// Both the retry middleware (`aws/retry`), which inspects the raw
//// `Response` *inside* the retry loop before any typed parsing, and the
//// runtime (`aws/internal/client/runtime`), which builds the typed
//// `ServiceError` *after* the loop, need the same extraction — so it
//// lives here once rather than being duplicated across the two layers.

import aws/internal/text_scan
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/result
import gleam/string

/// Pull the wire-error-type local name out of an error response's
/// already-lowercased headers + body. Prefers the `x-amzn-errortype`
/// header (restJson1, awsJson*), then falls back to the body's
/// `__type` / `code` (JSON) or `<Code>` (restXml). Returns the *local*
/// shape name with namespace / URI / disambiguation suffixes stripped,
/// or `"Unknown"` when nothing matches.
pub fn from_headers_and_body(
  headers: Dict(String, String),
  body: BitArray,
) -> String {
  from_header_value_and_body(dict.get(headers, "x-amzn-errortype"), body)
}

/// Like `from_headers_and_body` but taking the `x-amzn-errortype`
/// header value as a pre-resolved `Result`. The retry layer holds a
/// `Response` (not a header dict) and reads the header via
/// `response.get_header`, so this entry point lets it reuse the exact
/// same extraction without rebuilding a dict.
pub fn from_header_value_and_body(
  error_type_header: Result(String, Nil),
  body: BitArray,
) -> String {
  case error_type_header {
    Ok(v) -> normalise(v)
    Error(_) ->
      case bit_array.to_string(body) {
        Error(_) -> "Unknown"
        Ok(text) -> from_body(text)
      }
  }
}

/// Strip an error-type wire value down to its local Smithy shape name:
/// drop any `Type:uri` suffix, any `,` disambiguation list, and any
/// `namespace#` prefix. Exposed so callers that already hold a raw
/// header value (not a full response) can normalise it consistently.
pub fn normalise(raw: String) -> String {
  let s = case string.split_once(raw, ":") {
    Ok(#(prefix, _)) -> prefix
    Error(_) -> raw
  }
  let s = case string.split_once(s, ",") {
    Ok(#(prefix, _)) -> prefix
    Error(_) -> s
  }
  case string.split_once(s, "#") {
    Ok(#(_, local)) -> local
    Error(_) -> s
  }
}

fn from_body(body: String) -> String {
  let found =
    text_scan.json_string_after_key(body, "__type")
    |> result.lazy_or(fn() { text_scan.json_string_after_key(body, "code") })
    |> result.lazy_or(fn() { from_xml(body) })
  case found {
    Ok(v) -> normalise(v)
    Error(_) -> "Unknown"
  }
}

/// Pull the error code out of a restXml error body. Two shapes appear
/// in the wild — S3-style `<Error><Code>NoSuchBucket</Code>...</Error>`
/// and SQS/SNS-style `<ErrorResponse><Error><Code>X</Code>...</Error>`.
/// In both, the first `<Code>` element holds the error type, so a
/// single text search covers both without dragging in the full XML
/// decoder. The trim + empty-check rejects `<Code/>` / `<Code>   </Code>`
/// so the fallback to "Unknown" still fires for malformed bodies.
fn from_xml(body: String) -> Result(String, Nil) {
  use raw <- result.try(text_scan.xml_tag_text(body, "Code"))
  case string.trim(raw) {
    "" -> Error(Nil)
    non_empty -> Ok(non_empty)
  }
}
