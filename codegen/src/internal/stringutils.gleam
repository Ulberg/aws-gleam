//// Small string-mangling helpers used by the codegen layer. No
//// dependency on `gleam/regexp` — the rules are simple enough to
//// express directly.

import gleam/list
import gleam/set.{type Set}
import gleam/string

/// `Foo` → `Foo`, `foo` → `Foo`, `__Bar` → `Bar`, `AbpV1_0_x` →
/// `AbpV10X` — strips every underscore (Gleam type and constructor
/// names cannot contain `_`) and uppercases the grapheme that
/// follows it, preserving word boundaries Smithy expressed with
/// the underscore. Used by the union variant constructor name
/// builders and by `Resolved.gleam_name` for structs / unions /
/// enums.
pub fn pascalize_member(s: String) -> String {
  pascalize_member_loop(string.to_graphemes(s), True)
}

fn pascalize_member_loop(graphemes: List(String), upper: Bool) -> String {
  case graphemes {
    ["_", ..rest] -> pascalize_member_loop(rest, True)
    [g, ..rest] -> {
      let head = case upper {
        True -> string.uppercase(g)
        False -> g
      }
      head <> pascalize_member_loop(rest, False)
    }
    [] -> ""
  }
}

/// Like `pascalize_member` but additionally suffixes the result with
/// `Shape` when it collides with a Gleam prelude type name. Some
/// Smithy shapes are literally named `Result` / `List` / `Bool` /
/// etc. (see `transcribe-streaming` → `pub type Result`); the prelude
/// types are auto-imported and would shadow each other, so the
/// codegen emits a suffixed Gleam type while keeping `local_name` —
/// which still drives wire-format serialisation — untouched.
/// `Shape` is used (not `_`) because Gleam type names cannot contain
/// underscores.
pub fn gleam_type_name(s: String) -> String {
  let pascalized = pascalize_member(s)
  case is_reserved_type_name(pascalized) {
    True -> pascalized <> "Shape"
    False -> pascalized
  }
}

/// Build the Gleam variant constructor name for a Smithy union
/// member. Default convention is `<UnionLocal><Pascalized(Member)>` —
/// e.g. `Principal` with member `User` → `PrincipalUser`. If that
/// collides with another top-level type name in the same module
/// (e.g. a struct also named `PrincipalUser`), the constructor is
/// renamed to `<UnionLocal>Variant<Pascalized(Member)>` so the
/// emitted module compiles. Pass the set of *already-emitted Gleam
/// type names* (`gleam_name` for each struct / union / enum /
/// int-enum) so the check is module-scoped.
pub fn union_variant_ctor(
  union_name: String,
  member_name: String,
  emitted: Set(String),
) -> String {
  let suffix = pascalize_member(member_name)
  let candidate = union_name <> suffix
  case set.contains(emitted, candidate) {
    True -> union_name <> "Variant" <> suffix
    False -> candidate
  }
}

fn is_reserved_type_name(s: String) -> Bool {
  case s {
    "Result"
    | "List"
    | "BitArray"
    | "Bool"
    | "Float"
    | "Int"
    | "String"
    | "Nil"
    | "Iterator"
    | "Dynamic"
    | "Option"
    | "Dict"
    | "Set"
    // `Ok` / `Error` are `Result`'s variant constructors, not
    // types — but Gleam will treat a user-defined `pub type Error`
    // as shadowing `Result.Error` whenever the variant name
    // resolves the same way, breaking generated enum decoders
    // that emit `Error("unknown enum value")` etc. S3's
    // `com.amazonaws.s3#Error` is the canonical offender. Rename
    // the user struct to `ErrorShape` so the prelude wins.
    | "Error"
    | "Ok"
    | "None"
    | "Some" -> True
    _ -> False
  }
}

/// Manual `Int → String` so the codegen modules don't need to
/// import `gleam/int`. Tail-recursive: `int_to_string(123)` →
/// `int_str(123, "")` → `int_str(12, "3")` → … → `"123"`.
pub fn int_to_string(n: Int) -> String {
  case n {
    0 -> "0"
    _ -> int_str(n, "")
  }
}

fn int_str(n: Int, acc: String) -> String {
  case n {
    0 -> acc
    _ -> {
      let d = n - { n / 10 } * 10
      let c = case d {
        0 -> "0"
        1 -> "1"
        2 -> "2"
        3 -> "3"
        4 -> "4"
        5 -> "5"
        6 -> "6"
        7 -> "7"
        8 -> "8"
        9 -> "9"
        _ -> "?"
      }
      int_str(n / 10, c <> acc)
    }
  }
}

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
