//// XML decoder for restXml / awsQuery / ec2Query responses.
////
//// The Erlang side (`aws_ffi:xml_parse/1`) does the heavy lifting via
//// xmerl from the OTP standard library. It returns a `Element` tree
//// shaped as nested tuples; on the Gleam side we expose that tree and
//// a handful of accessor helpers that the generated decoders call
//// (`find_child`, `find_children`, `child_text`, ...).
////
//// Whitespace-only text nodes between elements are stripped on the
//// Erlang side so the generated code can address members by element
//// name without thinking about layout. Repeated child elements (used
//// for `@xmlFlattened` lists) are surfaced by `find_children`.

import aws/internal/codec/json_float
import aws/internal/codec/json_timestamp
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

/// Parsed XML element. The first variant is the only one a generated
/// decoder ever sees directly — `Text` only appears as a child of an
/// element, surfaced via `child_text` rather than pattern-matched
/// against by callers.
pub type Element {
  Element(name: String, attrs: List(#(String, String)), children: List(Node))
}

pub type Node {
  ElementNode(element: Element)
  Text(value: String)
}

/// Parse an XML document into an `Element`. Returns `Error("...")` on
/// malformed input — generated decoders propagate this up as a
/// `DecodeError`.
pub fn parse(body: String) -> Result(Element, String) {
  case xml_parse_ffi(body) {
    Ok(t) ->
      case node_from_tuple(t) {
        ElementNode(e) -> Ok(e)
        _ -> Error("xml: root is not an element")
      }
    Error(_) -> Error("xml: parse failed")
  }
}

@external(erlang, "aws_ffi", "xml_parse")
fn xml_parse_ffi(body: String) -> Result(RawNode, Nil)

/// Tag for the raw Erlang tuple shape coming back from `xml_parse`.
/// Kept opaque on the Gleam side; converted via `node_from_tuple`.
pub type RawNode

@external(erlang, "erlang", "element")
fn tuple_element(index: Int, tup: RawNode) -> RawNode

fn tag_of(t: RawNode) -> String {
  unsafe_atom_to_string(tuple_element(1, t))
}

@external(erlang, "erlang", "atom_to_binary")
fn unsafe_atom_to_string(a: RawNode) -> String

@external(erlang, "gleam@function", "identity")
fn coerce_string(x: RawNode) -> String

@external(erlang, "gleam@function", "identity")
fn coerce_list(x: RawNode) -> List(RawNode)

fn node_from_tuple(t: RawNode) -> Node {
  case tag_of(t) {
    "element" -> {
      let name = coerce_string(tuple_element(2, t))
      let attrs_raw = coerce_list(tuple_element(3, t))
      let children_raw = coerce_list(tuple_element(4, t))
      let attrs =
        list.map(attrs_raw, fn(p) {
          #(
            coerce_string(tuple_element(1, p)),
            coerce_string(tuple_element(2, p)),
          )
        })
      let children = list.map(children_raw, node_from_tuple)
      ElementNode(Element(name: name, attrs: attrs, children: children))
    }
    "text" -> Text(value: coerce_string(tuple_element(2, t)))
    _ -> Text(value: "")
  }
}

/// Find the first child element with the given local name.
pub fn find_child(parent: Element, name: String) -> Option(Element) {
  do_find_child(parent.children, name)
}

fn do_find_child(nodes: List(Node), name: String) -> Option(Element) {
  case nodes {
    [] -> None
    [ElementNode(e), ..rest] ->
      case e.name == name {
        True -> Some(e)
        False -> do_find_child(rest, name)
      }
    [_, ..rest] -> do_find_child(rest, name)
  }
}

/// Find all child elements with the given local name. Used for both
/// `@xmlFlattened` lists (which appear as repeated siblings of the
/// parent) and for normal wrapped lists (after stepping into the
/// wrapper element).
pub fn find_children(parent: Element, name: String) -> List(Element) {
  list.filter_map(parent.children, fn(n) {
    case n {
      ElementNode(e) ->
        case e.name == name {
          True -> Ok(e)
          False -> Error(Nil)
        }
      _ -> Error(Nil)
    }
  })
}

/// Concatenate all direct text-node children. Used for primitive
/// element values like `<Name>foo</Name>`.
pub fn text_content(e: Element) -> String {
  list.fold(e.children, "", fn(acc, n) {
    case n {
      Text(value: v) -> acc <> v
      _ -> acc
    }
  })
}

/// Lookup an attribute by name on an element.
pub fn attr(e: Element, name: String) -> Option(String) {
  case list.find(e.attrs, fn(p) { p.0 == name }) {
    Ok(#(_, v)) -> Some(v)
    Error(_) -> None
  }
}

// ---------- primitive decoders ----------

pub fn string_text(e: Element) -> Result(String, String) {
  Ok(text_content(e))
}

pub fn bool_text(e: Element) -> Result(Bool, String) {
  case string.trim(text_content(e)) {
    "true" -> Ok(True)
    "false" -> Ok(False)
    other -> Error("xml: invalid bool: " <> other)
  }
}

pub fn int_text(e: Element) -> Result(Int, String) {
  let t = string.trim(text_content(e))
  case int.parse(t) {
    Ok(n) -> Ok(n)
    Error(_) -> Error("xml: invalid int: " <> t)
  }
}

pub fn float_text(e: Element) -> Result(Float, String) {
  let t = string.trim(text_content(e))
  case float.parse(t) {
    Ok(f) -> Ok(f)
    Error(_) ->
      // Try parsing as int and converting — `<Price>10</Price>` is
      // valid XML float input but float.parse needs a decimal point.
      case int.parse(t) {
        Ok(n) -> Ok(int.to_float(n))
        Error(_) -> Error("xml: invalid float: " <> t)
      }
  }
}

/// Like `float_text` but recognises the Smithy IEEE-754 special-
/// value tokens (`NaN` / `Infinity` / `-Infinity`) and surfaces
/// them as `json_float.SmithyFloat` variants. Used by generated
/// Float decoders so the typed output carries the special value
/// rather than failing the entire decode.
pub fn smithy_float_text(e: Element) -> Result(json_float.SmithyFloat, String) {
  let t = string.trim(text_content(e))
  case t {
    "NaN" -> Ok(json_float.NaN)
    "Infinity" -> Ok(json_float.PosInfinity)
    "-Infinity" -> Ok(json_float.NegInfinity)
    _ ->
      case float_text(e) {
        Ok(f) -> Ok(json_float.FloatValue(f))
        Error(r) -> Error(r)
      }
  }
}

/// Decode a Smithy `@timestamp` element. AWS XML APIs serialise these
/// as ISO 8601 (e.g. `2024-01-02T03:04:05.000Z`); our type walker
/// surfaces timestamps as `Int` (epoch seconds), so we parse the text
/// and convert. Falls back to plain integer parsing for the rare case
/// where the wire form is already epoch seconds.
pub fn timestamp_text(e: Element) -> Result(Int, String) {
  let t = string.trim(text_content(e))
  // Try ISO 8601 first (the protocol default for body timestamps),
  // then HTTP-date (`Tue, 29 Apr 2014 18:30:38 GMT`, used when
  // `@timestampFormat("http-date")` is set), then plain epoch.
  parse_iso8601_ffi(t)
  |> result.lazy_or(fn() { parse_http_date_ffi(t) })
  |> result.lazy_or(fn() { int.parse(t) })
  |> result.map_error(fn(_) { "xml: invalid timestamp: " <> t })
}

/// Decode a Smithy `@timestamp` XML element into the precise
/// `Timestamp` shape (seconds + nanoseconds). The FFI ISO 8601
/// parser is currently whole-second precision so `nanoseconds`
/// will be 0 — once the parser learns fractional seconds we
/// flip that here without breaking the API.
pub fn timestamp_text_precise(
  e: Element,
) -> Result(json_timestamp.Timestamp, String) {
  case timestamp_text(e) {
    Ok(secs) -> Ok(json_timestamp.Timestamp(seconds: secs, nanoseconds: 0))
    Error(msg) -> Error(msg)
  }
}

@external(erlang, "aws_ffi", "parse_iso8601")
fn parse_iso8601_ffi(t: String) -> Result(Int, Nil)

@external(erlang, "aws_ffi", "parse_http_date")
fn parse_http_date_ffi(t: String) -> Result(Int, Nil)

// ---------- struct-decoder helpers ----------

/// Decode an optional child element if present, otherwise return None.
/// Used in the generated `decode_<struct>_xml_inner` for member fields.
pub fn optional_child(
  parent: Element,
  name: String,
  decode: fn(Element) -> Result(a, String),
) -> Result(Option(a), String) {
  case find_child(parent, name) {
    None -> Ok(None)
    Some(e) -> result.map(decode(e), Some)
  }
}

/// Decode a wrapped list: `<Wrapper><member>v</member>...</Wrapper>`.
/// `wrapper` is the parent name, `member_name` is the per-entry tag.
pub fn optional_list(
  parent: Element,
  wrapper: String,
  member_name: String,
  decode: fn(Element) -> Result(a, String),
) -> Result(Option(List(a)), String) {
  case find_child(parent, wrapper) {
    None -> Ok(None)
    Some(w) -> {
      let entries = find_children(w, member_name)
      list.try_map(entries, decode) |> result.map(Some)
    }
  }
}

/// Decode a flattened list: each entry is a direct child of the
/// parent (no wrapping element). Returns None when there are zero
/// entries, matching the Option(List(a)) shape of normal lists.
pub fn optional_flat_list(
  parent: Element,
  name: String,
  decode: fn(Element) -> Result(a, String),
) -> Result(Option(List(a)), String) {
  case find_children(parent, name) {
    [] -> Ok(None)
    entries -> list.try_map(entries, decode) |> result.map(Some)
  }
}

/// Decode the *inner* portion of a list element — used for nested
/// lists where the outer caller has already wrapped each entry in
/// `<member>...</member>` and we need to extract its children as a
/// sub-list. Returns a bare `List(a)` (not optional) since the
/// surrounding `optional_list` already gates on presence.
pub fn inner_list(
  elem: Element,
  member_name: String,
  decode: fn(Element) -> Result(a, String),
) -> Result(List(a), String) {
  list.try_map(find_children(elem, member_name), decode)
}
