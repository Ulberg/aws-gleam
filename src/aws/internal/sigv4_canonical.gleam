//// Canonical-request helpers shared by SigV4 and SigV4a.
////
//// Both algorithms compute the same canonical headers block, the
//// same signed-headers line, the same canonical query string, and
//// the same canonical URI (with RFC 3986 dot-segment removal when
//// requested). The algorithm-specific differences live entirely in
//// `sigv4.gleam` / `sigv4a.gleam`:
////
////   - the algorithm string (`AWS4-HMAC-SHA256` vs
////     `AWS4-ECDSA-P256-SHA256`)
////   - the credential scope (region-bound vs region-less)
////   - the per-algorithm header set (`X-Amz-Region-Set` vs none)
////   - the signing key derivation (HMAC chain vs HMAC-DRBG to an
////     EC scalar)
////   - the signature step (HMAC-SHA256 vs ECDSA P-256)
////
//// The functions in this module are pure — no IO, no clock — and
//// take `List(Header)` / `String` arguments so callers can compose
//// them with their own pre-/post-processing.

import aws/internal/http_request.{type Header}
import aws/internal/uri
import gleam/list
import gleam/order
import gleam/string

/// Build the canonical headers block: lowercase names, trim +
/// collapse internal runs of ASCII whitespace in values, group
/// duplicate header names with comma-joined values, sort by name,
/// emit one `name:value\n` line each.
pub fn canonical_headers(headers: List(Header)) -> String {
  let prepared =
    headers
    |> list.map(fn(h) {
      #(string.lowercase(h.name), collapse_spaces(string.trim(h.value)))
    })
    |> do_group_by_name([])
    |> list.sort(by: fn(a, b) { string.compare(a.0, b.0) })

  prepared
  |> list.map(fn(p) { p.0 <> ":" <> string.join(p.1, ",") <> "\n" })
  |> string.concat
}

/// Semicolon-joined, sorted, lowercased header names — the
/// `SignedHeaders=` value on the `Authorization` line.
pub fn signed_headers(headers: List(Header)) -> String {
  headers
  |> list.map(fn(h) { string.lowercase(h.name) })
  |> list.unique
  |> list.sort(by: string.compare)
  |> string.join(";")
}

/// Canonical query string: split on `&`, URI-encode names + values,
/// sort first by name then by value. Empty input → empty output.
pub fn canonical_query_string(query: String) -> String {
  case query {
    "" -> ""
    _ ->
      string.split(query, "&")
      |> list.map(fn(pair) {
        case string.split_once(pair, "=") {
          Ok(#(name, value)) -> #(
            uri.encode_component(name),
            uri.encode_component(value),
          )
          Error(_) -> #(uri.encode_component(pair), "")
        }
      })
      |> list.sort(by: fn(a, b) {
        case string.compare(a.0, b.0) {
          order.Eq -> string.compare(a.1, b.1)
          other -> other
        }
      })
      |> list.map(fn(p) { p.0 <> "=" <> p.1 })
      |> string.join("&")
  }
}

/// Compose RFC 3986 dot-segment removal (when requested) with
/// percent encoding. S3 callers want `normalize: False` so object
/// keys with `.` / `..` survive; every other AWS service wants
/// `True`.
pub fn build_canonical_uri(path: String, normalize: Bool) -> String {
  case normalize {
    True -> encode_path(normalize_path(path))
    False -> encode_path(path)
  }
}

/// Percent-encode each path segment — the URI representation used
/// in the canonical request line.
pub fn encode_path(path: String) -> String {
  string.split(path, "/")
  |> list.map(uri.encode_segment)
  |> string.join("/")
}

fn do_group_by_name(
  pairs: List(#(String, String)),
  acc: List(#(String, List(String))),
) -> List(#(String, List(String))) {
  case pairs {
    [] -> list.reverse(list.map(acc, fn(p) { #(p.0, list.reverse(p.1)) }))
    [#(name, value), ..rest] -> {
      let updated = case list.key_find(acc, name) {
        Ok(existing) -> {
          let new_values = [value, ..existing]
          list.key_set(acc, name, new_values)
        }
        Error(_) -> [#(name, [value]), ..acc]
      }
      do_group_by_name(rest, updated)
    }
  }
}

fn collapse_spaces(s: String) -> String {
  do_collapse(string.to_graphemes(s), False, [])
  |> list.reverse
  |> string.concat
}

fn do_collapse(
  chars: List(String),
  last_was_space: Bool,
  acc: List(String),
) -> List(String) {
  case chars {
    [] -> acc
    [c, ..rest] ->
      case c == " " || c == "\t" {
        True ->
          case last_was_space {
            True -> do_collapse(rest, True, acc)
            False -> do_collapse(rest, True, [" ", ..acc])
          }
        False -> do_collapse(rest, False, [c, ..acc])
      }
  }
}

fn normalize_path(path: String) -> String {
  let trailing_slash = string.ends_with(path, "/") && path != "/"
  let segments = case string.starts_with(path, "/") {
    True -> string.split(path, "/") |> list.drop(1)
    False -> string.split(path, "/")
  }
  let processed = process_segments(segments, [])
  case processed, trailing_slash {
    [], _ -> "/"
    parts, True -> "/" <> string.join(parts, "/") <> "/"
    parts, False -> "/" <> string.join(parts, "/")
  }
}

fn process_segments(
  segments: List(String),
  stack: List(String),
) -> List(String) {
  case segments {
    [] -> list.reverse(stack)
    ["", ..rest] -> process_segments(rest, stack)
    [".", ..rest] -> process_segments(rest, stack)
    ["..", ..rest] ->
      case stack {
        [_, ..tail] -> process_segments(rest, tail)
        [] -> process_segments(rest, stack)
      }
    [seg, ..rest] -> process_segments(rest, [seg, ..stack])
  }
}
