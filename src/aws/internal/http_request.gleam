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
      use #(method, path, query) <- result.try(parse_request_line(
        request_line,
      ))
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
    Error(_) -> #(normalized, "")
  }
}

fn parse_request_line(
  line: String,
) -> Result(#(String, String, String), ParseError) {
  case string.split(line, " ") {
    [method, target, _version] -> {
      let #(path, query) = case string.split_once(target, "?") {
        Ok(#(p, q)) -> #(p, q)
        Error(_) -> #(target, "")
      }
      Ok(#(method, path, query))
    }
    _ -> Error(MalformedRequestLine(line))
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
