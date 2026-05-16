//// Small string-mangling helpers used by the codegen layer. No
//// dependency on `gleam/regexp` — the rules are simple enough to
//// express directly.

import gleam/list
import gleam/string

/// `MyHTTPRequest` → `my_http_request`. Inserts an underscore between a
/// lowercase/digit boundary and the next uppercase, and between a run of
/// uppercase letters and a final upper-then-lower (e.g. `HTTPRequest` →
/// `http_request`). Trailing lowercase preserved as-is, then the whole
/// result is lowercased.
pub fn pascal_to_snake(input: String) -> String {
  input
  |> string.to_graphemes
  |> insert_underscores
  |> string.concat
  |> string.lowercase
  |> escape_reserved
}

/// Gleam reserved keywords. Member names that collide get an
/// underscore suffix so they remain valid identifiers in record
/// fields and function arguments.
fn escape_reserved(s: String) -> String {
  case s {
    "type"
    | "import"
    | "pub"
    | "fn"
    | "case"
    | "let"
    | "use"
    | "if"
    | "as"
    | "const"
    | "external"
    | "todo"
    | "panic"
    | "opaque"
    | "auto"
    | "delegate"
    | "derive"
    | "echo"
    | "else"
    | "implement"
    | "macro"
    | "test" -> s <> "_"
    _ -> s
  }
}

fn insert_underscores(graphemes: List(String)) -> List(String) {
  do_insert(graphemes, "", "", [])
  |> list.reverse
}

fn do_insert(
  remaining: List(String),
  prev: String,
  prev2: String,
  acc: List(String),
) -> List(String) {
  case remaining {
    [] -> acc
    [c, ..rest] -> {
      let needs_sep = should_insert_underscore(c, prev, prev2, rest)
      let acc2 = case needs_sep {
        True -> [c, "_", ..acc]
        False -> [c, ..acc]
      }
      do_insert(rest, c, prev, acc2)
    }
  }
}

fn should_insert_underscore(
  current: String,
  prev: String,
  _prev2: String,
  rest: List(String),
) -> Bool {
  case prev == "" {
    True -> False
    False ->
      case is_upper(current) {
        False -> False
        True ->
          // boundary between lower/digit and upper:
          // "fooB" → "foo_b"
          case is_lower(prev) || is_digit(prev) {
            True -> True
            False ->
              // Boundary inside an acronym followed by a normal word:
              // "HTTPRequest" → "HTTP_Request" → "http_request".
              // Triggered when current is upper, prev is upper, and the
              // next char is lower.
              case rest {
                [next, ..] -> is_lower(next)
                [] -> False
              }
          }
      }
  }
}

fn is_upper(s: String) -> Bool {
  s != string.lowercase(s) && s == string.uppercase(s)
}

fn is_lower(s: String) -> Bool {
  s != string.uppercase(s) && s == string.lowercase(s)
}

fn is_digit(s: String) -> Bool {
  case s {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}
