//// XML encoder helpers for restXml / awsQuery / ec2Query bodies.
//// Minimum viable: element-per-member, text-content for primitives,
//// proper escaping of `<>&"'`. Honours `@xmlName` overrides at the
//// call site (the emitter passes the resolved element name).
////
//// The XML response decoder lives in
//// `src/aws/internal/codec/xml_decode.gleam` — kept separate because
//// it pulls in xmerl via FFI, which is heavier than the pure-string
//// encoder side.

import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/list
import gleam/string

/// `<Name>...</Name>` wrapper around inner content.
pub fn element(name: String, inner: String) -> String {
  "<" <> name <> ">" <> inner <> "</" <> name <> ">"
}

/// `<Name attr1="v1" attr2="v2">inner</Name>`. Attribute values are
/// escaped the same way as text content; attribute names are passed
/// verbatim and assumed to be safe (Smithy member names).
pub fn element_with_attrs(
  name: String,
  attrs: List(#(String, String)),
  inner: String,
) -> String {
  let attr_str = case attrs {
    [] -> ""
    _ ->
      list.fold(attrs, "", fn(acc, p) {
        let #(k, v) = p
        acc <> " " <> k <> "=\"" <> escape_attr(v) <> "\""
      })
  }
  "<" <> name <> attr_str <> ">" <> inner <> "</" <> name <> ">"
}

/// `<Name/>` — short form for empty elements.
pub fn empty_element(name: String) -> String {
  "<" <> name <> "/>"
}

pub fn text(value: String) -> String {
  escape_text(value)
}

/// Escape `<`, `>`, `&` in element text content.
pub fn escape_text(s: String) -> String {
  s
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
}

/// Escape `&`, `<`, `>`, `"`, and `'` in attribute values. AWS
/// service XML is double-quoted, so `'` doesn't strictly need
/// escaping, but the entity is harmless and keeps the encoder
/// quote-style agnostic.
pub fn escape_attr(s: String) -> String {
  s
  |> escape_text
  |> string.replace("\"", "&quot;")
  |> string.replace("'", "&apos;")
}

/// Format helpers for primitive members.
pub fn bool_text(b: Bool) -> String {
  case b {
    True -> "true"
    False -> "false"
  }
}

@external(erlang, "erlang", "integer_to_binary")
pub fn int_text(n: Int) -> String

@external(erlang, "aws_ffi", "float_short")
pub fn float_text(f: Float) -> String

/// Base64-encode a blob value for XML body inclusion. S3 uses base64
/// for binary fields inside XML bodies (Content-MD5, ChecksumSHA256).
pub fn blob_text(b: BitArray) -> String {
  bit_array.base64_encode(b, True)
}

/// Build a list element with each entry as `<member_name>value</member_name>`
/// children. The wrapper element comes from the list shape's name; the
/// per-entry element name comes from the list member's `@xmlName` (the
/// emitter passes both).
pub fn list_element(
  wrapper: String,
  member_name: String,
  entries: List(String),
) -> String {
  let inner =
    list.fold(entries, "", fn(acc, entry_inner) {
      acc <> element(member_name, entry_inner)
    })
  element(wrapper, inner)
}

/// Same as `list_element` but for `@xmlFlattened` lists — no
/// wrapper element; entries become direct siblings.
pub fn flat_list(member_name: String, entries: List(String)) -> String {
  list.fold(entries, "", fn(acc, entry_inner) {
    acc <> element(member_name, entry_inner)
  })
}

/// Build a map element: each entry becomes `<entry><key>K</key><value>V</value></entry>`
/// inside a wrapper. Smithy default uses `entry` / `key` / `value` —
/// `@xmlName` overrides land in the caller.
pub fn map_element(
  wrapper: String,
  key_name: String,
  value_name: String,
  entries: Dict(String, String),
) -> String {
  let inner =
    dict.fold(entries, "", fn(acc, k, v) {
      acc
      <> element(
        "entry",
        element(key_name, escape_text(k)) <> element(value_name, v),
      )
    })
  element(wrapper, inner)
}
