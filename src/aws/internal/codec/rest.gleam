//// Shared runtime helpers for the rest-protocol emitters
//// (restJson1, restXml). Holds the URI / query / header glue that
//// generated `build_*_request` functions call into for each
//// `@httpLabel`, `@httpQuery`, `@httpHeader` member.

import aws/internal/crypto
import aws/internal/uri
import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// Substitute a single `@httpLabel` member into the URI template.
/// Templates use `{Name}` or `{Name+}` (the `+` marks a greedy label
/// that may contain `/`). Values are percent-encoded; greedy labels
/// preserve `/` in the value.
pub fn substitute_label(
  template: String,
  name: String,
  value: String,
  greedy: Bool,
) -> String {
  let placeholder = "{" <> name <> "}"
  let greedy_placeholder = "{" <> name <> "+}"
  let encoded = case greedy {
    True -> encode_path_preserve_slash(value)
    False -> uri.encode_segment(value)
  }
  template
  |> string.replace(greedy_placeholder, encoded)
  |> string.replace(placeholder, encoded)
}

/// Encode each path segment but keep the `/` separators intact.
fn encode_path_preserve_slash(path: String) -> String {
  string.split(path, "/")
  |> list.map(uri.encode_segment)
  |> string.join("/")
}

/// Append a query parameter pair. Returns the resulting query string
/// (without the leading `?`); call sites prepend it themselves.
pub fn add_query(existing: String, name: String, value: String) -> String {
  let pair = uri.encode_component(name) <> "=" <> uri.encode_component(value)
  case existing {
    "" -> pair
    _ -> existing <> "&" <> pair
  }
}

/// Bool → query value: "true" / "false".
pub fn bool_to_query(b: Bool) -> String {
  case b {
    True -> "true"
    False -> "false"
  }
}

/// Int → query / header value as decimal.
pub fn int_to_query(n: Int) -> String {
  int.to_string(n)
}

/// Float → query / header / URI-label value. Uses Erlang's `short`
/// formatter so `1.1` round-trips as the literal `"1.1"` — the AWS
/// SimpleScalarProperties protocol-test corpus rejects scientific
/// notation in these positions.
pub fn float_to_query(f: Float) -> String {
  float_to_string(f)
}

@external(erlang, "aws_ffi", "float_short")
fn float_to_string(f: Float) -> String

/// `@httpHeader` on a list member emits the values comma-joined, per
/// HTTP/1.1 header-folding rules. `Some(["a", "b"])` becomes
/// `Name: a, b`. Empty lists drop the header entirely.
pub fn maybe_set_list_header(
  headers: Dict(String, String),
  name: String,
  values: List(String),
) -> Dict(String, String) {
  // Each entry arrives already rendered as a wire string. Strings are
  // RFC 7230-quoted by `quote_list_string_entry` at the codegen layer
  // (only that type needs quoting; numeric / boolean / http-date
  // values are unambiguous by shape).
  dict.insert(headers, name, string.join(values, ", "))
}

/// Append a `@requestCompression` encoding to the `Content-Encoding`
/// header. Existing encodings (e.g. caller-set `Content-Encoding:
/// custom`) are preserved with the new value appended after a comma:
/// `custom` + `gzip` ⇒ `custom, gzip`.
pub fn append_content_encoding(
  headers: Dict(String, String),
  encoding: String,
) -> Dict(String, String) {
  case dict.get(headers, "Content-Encoding") {
    Ok(existing) ->
      dict.insert(headers, "Content-Encoding", existing <> ", " <> encoding)
    Error(_) -> dict.insert(headers, "Content-Encoding", encoding)
  }
}

/// Generated `@idempotencyToken` value, used when a request member
/// with that trait is left as `Option.None`. Backed by the runtime
/// FFI so tests can pin a deterministic UUID via `application:set_env`.
@external(erlang, "aws_ffi", "idempotency_token")
pub fn idempotency_token() -> String

/// RFC 7230 list-header quoting for string elements. Smithy applies
/// this only to string-typed entries — timestamp values use the raw
/// `Mon, 16 Dec ... GMT` form even though it contains a comma.
pub fn quote_list_string_entry(v: String) -> String {
  case string.contains(v, ",") || string.contains(v, "\"") {
    True -> "\"" <> string.replace(v, "\"", "\\\"") <> "\""
    False -> v
  }
}

/// Build the full path: substitute labels, then append query (with `?`)
/// if non-empty.
/// Merge a path that may already carry a static query string (from the
/// `@http` URI template, e.g. `/Foo?bar=baz`) with the dynamically
/// built query string from `@httpQuery` members. Either or both can be
/// empty. The static-query side wins on key order; dynamic params are
/// appended.
pub fn build_path(uri_path: String, query: String) -> String {
  let #(path_only, static_query) = case string.split_once(uri_path, "?") {
    Ok(#(p, q)) -> #(p, q)
    Error(_) -> #(uri_path, "")
  }
  let combined = case static_query, query {
    "", "" -> ""
    "", q -> q
    sq, "" -> sq
    sq, q -> sq <> "&" <> q
  }
  case combined {
    "" -> path_only
    _ -> path_only <> "?" <> combined
  }
}

/// Set a header on the headers dict if the value is non-empty (Smithy
/// `@httpHeader` typically omits the header when the value is None).
pub fn maybe_set_header(
  headers: Dict(String, String),
  name: String,
  value: String,
) -> Dict(String, String) {
  // Always set, including empty-string values — Smithy's
  // `@httpHeader` semantics treat `""` as a present (empty) header.
  // Absent is expressed at the codegen layer by skipping the call.
  dict.insert(headers, name, value)
}

/// Iterate `@httpPrefixHeaders` map members: for each entry,
/// emit a header `<prefix><key>: <value>`.
pub fn add_prefix_headers(
  headers: Dict(String, String),
  prefix: String,
  entries: Dict(String, String),
) -> Dict(String, String) {
  dict.fold(entries, headers, fn(acc, k, v) { dict.insert(acc, prefix <> k, v) })
}

/// Iterate `@httpQueryParams` map members (Map<String, String>).
pub fn add_query_params(
  query: String,
  entries: Dict(String, String),
) -> String {
  dict.fold(entries, query, fn(acc, k, v) { add_query(acc, k, v) })
}

/// Iterate `@httpQueryParams` map members (Map<String, List<String>>).
/// Each list value emits one query param per element.
pub fn add_query_params_list(
  query: String,
  entries: Dict(String, List(String)),
) -> String {
  dict.fold(entries, query, fn(acc, k, vs) {
    list.fold(vs, acc, fn(q, v) { add_query(q, k, v) })
  })
}

/// Format a timestamp for use in URI labels / query strings / headers.
/// Smithy's default `@timestampFormat` for `date-time` (the
/// restJson1 + restXml default) is RFC 3339, e.g. `2019-12-16T23:48:18Z`.
/// We always emit Z-suffixed UTC; the wire form remains stable even if
/// the input came from a system clock in a different zone.
pub fn timestamp_to_header(epoch_seconds: Int) -> String {
  iso8601_format(epoch_seconds)
}

@external(erlang, "aws_ffi", "format_iso8601")
fn iso8601_format(epoch_seconds: Int) -> String

/// Extract the raw wire string from a JSON-encoded enum value. The
/// generated `encode_<enum>_enum(v)` returns a `json.Json` like
/// `json.string("VALUE")`; URI / query / header position wants just
/// `VALUE`. We render to JSON text and strip the surrounding quotes.
pub fn enum_wire_value(j: json.Json) -> String {
  let s = json.to_string(j)
  let len = string.length(s)
  case len > 2 {
    True -> string.slice(s, 1, len - 2)
    False -> s
  }
}

// ---------- response-side header extraction ----------
//
// The runtime gives `parse_<op>_response` a `dict.Dict(String, String)`
// with lowercased keys. The helpers below normalise the caller-supplied
// header name to lowercase for the lookup so generated code can use the
// header's wire spelling verbatim — e.g. `string_header(headers, "ETag")`
// works the same whether the server replied with `ETag:` or `etag:`.

pub fn string_header(
  headers: Dict(String, String),
  name: String,
) -> Option(String) {
  dict.get(headers, string.lowercase(name))
  |> option.from_result
}

pub fn int_header(headers: Dict(String, String), name: String) -> Option(Int) {
  use raw <- option.then(string_header(headers, name))
  raw
  |> string.trim
  |> int.parse
  |> option.from_result
}

pub fn bool_header(
  headers: Dict(String, String),
  name: String,
) -> Option(Bool) {
  use raw <- option.then(string_header(headers, name))
  case string.lowercase(string.trim(raw)) {
    "true" -> Some(True)
    "false" -> Some(False)
    _ -> None
  }
}

/// Float header — used for shapes that bind a `Float` member to a
/// response header. Falls through to `None` if the value can't be
/// parsed; same forgiving contract as `int_header` / `bool_header`.
pub fn float_header(
  headers: Dict(String, String),
  name: String,
) -> Option(Float) {
  use raw <- option.then(string_header(headers, name))
  parse_float(string.trim(raw))
}

// ---------- @httpChecksumRequired ----------

/// Set the `Content-MD5` header to `base64(md5(body))`. Used by the
/// Smithy `smithy.api#httpChecksumRequired` trait — the codegen
/// emits a call to this helper at the tail of `build_<op>_request`
/// for any operation that carries the trait.
///
/// Always overwrites a previous `Content-MD5` entry: the SDK is
/// responsible for the canonical value, and a stale caller-supplied
/// one would surface as a 400 from the service. Other headers pass
/// through unchanged.
///
/// MD5 is not a security primitive here. The wire contract requires
/// it (S3-control + restJson1 protocol tests fix the exact bytes);
/// SigV4 covers the actual auth on the request.
pub fn with_content_md5_header(
  headers: Dict(String, String),
  body: BitArray,
) -> Dict(String, String) {
  let digest = bit_array.base64_encode(crypto.md5(body), True)
  dict.insert(headers, "Content-MD5", digest)
}

fn parse_float(s: String) -> Option(Float) {
  // Integer literals are valid Float wire values per the Smithy spec —
  // `1` decodes to `1.0`. The stdlib's float parser rejects them, so
  // fall back to int + cast on the `Error` side via `lazy_or`.
  float.parse(s)
  |> result.lazy_or(fn() { int.parse(s) |> result.map(int.to_float) })
  |> option.from_result
}
