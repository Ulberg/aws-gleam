//// Shared runtime helpers for the rest-protocol emitters
//// (restJson1, restXml). Holds the URI / query / header glue that
//// generated `build_*_request` functions call into for each
//// `@httpLabel`, `@httpQuery`, `@httpHeader` member.

import aws/internal/uri
import gleam/dict.{type Dict}
import gleam/int
import gleam/json
import gleam/list
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

/// Float → query / header value with full precision.
pub fn float_to_query(f: Float) -> String {
  // Use Erlang's float formatting; Gleam's `float.to_string` uses
  // exponential for some values which we don't want for query
  // parameters.
  float_to_string(f)
}

@external(erlang, "erlang", "float_to_binary")
fn float_to_string(f: Float) -> String

/// Build the full path: substitute labels, then append query (with `?`)
/// if non-empty.
pub fn build_path(uri_path: String, query: String) -> String {
  case query {
    "" -> uri_path
    _ -> uri_path <> "?" <> query
  }
}

/// Set a header on the headers dict if the value is non-empty (Smithy
/// `@httpHeader` typically omits the header when the value is None).
pub fn maybe_set_header(
  headers: Dict(String, String),
  name: String,
  value: String,
) -> Dict(String, String) {
  case value {
    "" -> headers
    _ -> dict.insert(headers, name, value)
  }
}

/// Iterate `@httpPrefixHeaders` map members: for each entry,
/// emit a header `<prefix><key>: <value>`.
pub fn add_prefix_headers(
  headers: Dict(String, String),
  prefix: String,
  entries: Dict(String, String),
) -> Dict(String, String) {
  dict.fold(entries, headers, fn(acc, k, v) {
    dict.insert(acc, prefix <> k, v)
  })
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

/// Format an `If-Modified-Since` header / similar epoch-seconds
/// timestamps in HTTP-date form. Placeholder while we don't honour
/// @timestampFormat — emits raw integer for now.
pub fn timestamp_to_header(epoch_seconds: Int) -> String {
  int.to_string(epoch_seconds)
}

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
