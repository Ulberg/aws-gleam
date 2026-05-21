import gleam/bit_array
import gleam/list
import gleam/result
import gleam/string

pub type HttpRequest {
  HttpRequest(
    method: String,
    path: String,
    query: String,
    headers: List(Header),
    body: BitArray,
  )
}

pub type Header {
  Header(name: String, value: String)
}

pub type ParseError {
  MalformedRequestLine(String)
  MalformedHeader(String)
}

pub fn parse(text: String) -> Result(HttpRequest, ParseError) {
  let #(head, body) = split_head_body(text)
  case string.split(head, "\n") {
    [] -> Error(MalformedRequestLine(""))
    [request_line, ..header_lines] -> {
      use #(method, path, query) <- result.try(parse_request_line(request_line))
      use headers <- result.try(parse_headers(header_lines))
      Ok(HttpRequest(
        method: method,
        path: path,
        query: query,
        headers: headers,
        body: bit_array.from_string(body),
      ))
    }
  }
}

fn split_head_body(text: String) -> #(String, String) {
  let normalized = string.replace(text, "\r\n", "\n")
  case string.split_once(normalized, "\n\n") {
    Ok(#(head, body)) -> #(head, body)
    // No blank-line separator: treat the whole thing as the head and
    // drop any trailing newline so the headers list has no empty tail.
    Error(_) -> #(string.trim_end(normalized), "")
  }
}

fn parse_request_line(
  line: String,
) -> Result(#(String, String, String), ParseError) {
  // Method is before the first space, HTTP version after the last. The
  // request-target sits between, and is allowed to contain spaces (some
  // SigV4 vectors have literal spaces in the path).
  case string.split(line, " ") {
    [method, ..rest] ->
      case list.reverse(rest) {
        [_version, ..target_parts_rev] -> {
          let target = target_parts_rev |> list.reverse |> string.join(" ")
          let #(path, query) = case string.split_once(target, "?") {
            Ok(#(p, q)) -> #(p, q)
            Error(_) -> #(target, "")
          }
          Ok(#(method, path, query))
        }
        [] -> Error(MalformedRequestLine(line))
      }
    [] -> Error(MalformedRequestLine(line))
  }
}

fn parse_headers(lines: List(String)) -> Result(List(Header), ParseError) {
  do_parse_headers(lines, [])
}

fn do_parse_headers(
  lines: List(String),
  acc: List(Header),
) -> Result(List(Header), ParseError) {
  case lines {
    [] -> Ok(list.reverse(acc))
    [line, ..rest] ->
      case is_continuation(line), acc {
        True, [Header(name, value), ..tail] -> {
          let merged =
            Header(name: name, value: value <> " " <> string.trim(line))
          do_parse_headers(rest, [merged, ..tail])
        }
        True, [] -> Error(MalformedHeader(line))
        False, _ ->
          case string.split_once(line, ":") {
            Ok(#(name, value)) ->
              do_parse_headers(rest, [Header(name: name, value: value), ..acc])
            Error(_) -> Error(MalformedHeader(line))
          }
      }
  }
}

fn is_continuation(line: String) -> Bool {
  string.starts_with(line, " ") || string.starts_with(line, "\t")
}
