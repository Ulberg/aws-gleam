//// Minimal INI parser, sized for the AWS shared credentials file and the
//// flat parts of `~/.aws/config`. Supports the subset:
////
////   - `[section-name]` headers
////   - `key = value` properties (whitespace around `=` trimmed)
////   - `#` and `;` whole-line comments
////   - blank lines
////
//// Out of scope for now (we'll grow into these when SSO and assume-role
//// providers need them):
////
////   - line continuation for multi-line values
////   - sub-properties (nested key/value inside a property)
////   - inline `#`/`;` comments mid-value
////
//// Errors carry the offending line number so the surfaced message can
//// point the user at the broken line of their credentials file.

import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/string

/// Parsed INI representation: section name -> property name -> value.
pub type Ini =
  Dict(String, Dict(String, String))

pub type ParseError {
  ParseError(line: Int, message: String)
}

pub fn parse(text: String) -> Result(Ini, ParseError) {
  text
  |> string.split("\n")
  |> list.index_map(fn(line, i) { #(i + 1, line) })
  |> parse_lines("", dict.new(), dict.new())
}

fn parse_lines(
  lines: List(#(Int, String)),
  current_section: String,
  current_props: Dict(String, String),
  ini: Ini,
) -> Result(Ini, ParseError) {
  case lines {
    [] -> Ok(commit_section(current_section, current_props, ini))
    [#(line_no, raw), ..rest] -> {
      let trimmed = string.trim(raw)
      case classify(trimmed) {
        Blank | Comment ->
          parse_lines(rest, current_section, current_props, ini)
        Section(name) -> {
          let new_ini = commit_section(current_section, current_props, ini)
          parse_lines(rest, name, dict.new(), new_ini)
        }
        Property(key, value) ->
          case current_section {
            "" ->
              Error(ParseError(
                line: line_no,
                message: "property '" <> key <> "' outside any section",
              ))
            _ ->
              parse_lines(
                rest,
                current_section,
                dict.insert(current_props, key, value),
                ini,
              )
          }
        Malformed(message) -> Error(ParseError(line: line_no, message: message))
      }
    }
  }
}

type LineKind {
  Blank
  Comment
  Section(String)
  Property(String, String)
  Malformed(String)
}

fn classify(line: String) -> LineKind {
  case line {
    "" -> Blank
    _ ->
      case string.slice(line, 0, 1) {
        "#" | ";" -> Comment
        "[" -> classify_section(line)
        _ -> classify_property(line)
      }
  }
}

fn classify_section(line: String) -> LineKind {
  case string.ends_with(line, "]") {
    False -> Malformed("section header missing closing ']'")
    True -> {
      // Strip the surrounding brackets and trim any inner whitespace so
      // `[ default ]` and `[default]` both map to the section "default".
      let inner = string.slice(line, 1, string.length(line) - 2)
      Section(string.trim(inner))
    }
  }
}

fn classify_property(line: String) -> LineKind {
  case string.split_once(line, "=") {
    Error(_) -> Malformed("expected 'key = value'")
    Ok(#(key, value)) -> {
      let key = string.trim(key)
      let value = string.trim(value)
      case key {
        "" -> Malformed("property name is empty")
        _ -> Property(key, value)
      }
    }
  }
}

fn commit_section(name: String, props: Dict(String, String), ini: Ini) -> Ini {
  case name {
    "" -> ini
    _ -> dict.insert(ini, name, props)
  }
}

/// Look up a single property value inside a section.
pub fn get_property(
  ini: Ini,
  section section: String,
  key key: String,
) -> Result(String, Nil) {
  use props <- result.try(dict.get(ini, section))
  dict.get(props, key)
}
