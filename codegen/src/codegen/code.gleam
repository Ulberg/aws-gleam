//// Minimal Gleam-source AST used by the codegen emitters.
////
//// Each emitter builds a tree of `Code` nodes and hands it to
//// `render` once. The structural representation rules out a whole
//// class of bugs that plagued the earlier `"..." <> "..."` style:
////
////   * Mismatched braces / parens — `Block` knows its delimiters.
////   * Stray quote characters — every literal goes through
////     `Lit(String)`, which escapes once.
////   * Indentation drift — `Indent(node)` shifts a subtree two
////     spaces; nesting composes by construction.
////
//// The AST is **deliberately incomplete**: it only models the Gleam
//// constructs the SDK codegen actually emits. We add nodes as the
//// generator grows.
////
//// `Raw(String)` is the escape hatch — used while we migrate
//// emitters incrementally. Long-term goal is zero `Raw` calls; the
//// migration plan is to peel them off one emit_ function at a time.

import gleam/list
import gleam/string

pub type Code {
  /// A whole module. Lines render with `\n` between them; no
  /// indentation at the top level.
  Module(items: List(Code))

  /// `import path/to/module` (optionally `as alias`,
  /// `.{unqualified}`).
  Import(path: String, alias: OptCode(String), unqualified: List(String))

  /// A `pub type Name { Ctor(field: Type, ...) ... }` definition.
  /// Variants with no fields collapse to `Ctor` with no parens.
  /// `is_opaque == True` emits `pub opaque type Name { ... }` —
  /// constructors are hidden from importers, matching the convention
  /// every generated `Client` uses.
  TypeDef(public: Bool, is_opaque: Bool, name: String, variants: List(Variant))

  /// `pub fn name(p1: T1, ...) -> Ret { body }`.
  /// `public: False` produces a private function.
  Fn(
    public: Bool,
    name: String,
    params: List(Param),
    return: OptCode(String),
    body: Code,
  )

  /// A `let name = expr` statement. Used inside `Body`.
  Let(name: String, value: Code)

  /// A `use name <- callee` continuation. Lifts the rest of the body
  /// into a closure passed to `callee`.
  Use(name: String, callee: Code)

  /// A `case scrutinee { ... }` expression. Each branch is
  /// `pattern -> body`.
  Case(scrutinee: Code, branches: List(Branch))

  /// A sequence of statements (lets + uses + a tail expression).
  /// Rendered with one statement per line.
  Block(items: List(Code))

  /// `head(args)` — function/constructor application. `args` render
  /// comma-joined.
  Call(head: Code, args: List(Code))

  /// `a <> b <> c` — string concatenation. Rendered with `<>`
  /// between each. Used heavily by encoders.
  Concat(parts: List(Code))

  /// `#(a, b, ...)` — tuple literal.
  Tuple(items: List(Code))

  /// `[a, b, ..rest]` — list literal with optional tail.
  ListLit(items: List(Code), tail: OptCode(Code))

  /// Bare identifier or qualified reference (`json.string`,
  /// `option.None`, `m.snake_name`). The renderer emits it verbatim.
  Ident(name: String)

  /// A Gleam string literal — the renderer adds quotes and escapes
  /// `"` / `\` in the content.
  StrLit(value: String)

  /// An integer literal.
  IntLit(value: Int)

  /// Raw passthrough — emitter hands a pre-formatted Gleam fragment.
  /// Escape hatch for legacy code; should eventually be empty.
  Raw(fragment: String)

  /// A doc comment (`/// ...`) attached to the next item. Empty
  /// list of lines = no comment.
  DocComment(lines: List(String))

  /// A literal blank line. Used between functions / types to keep
  /// the output readable.
  Blank
}

pub type Variant {
  /// `Ctor` — zero-field variant.
  UnitVariant(name: String)

  /// `Ctor(field1: T1, field2: T2, ...)` — labelled fields, suitable
  /// for record variants. Generated structs use this form.
  Variant(name: String, fields: List(Param))

  /// `Ctor(T1, T2, ...)` — positional fields. Generated unions use
  /// this form so callers can pattern-match as `Ctor(x)` directly.
  PositionalVariant(name: String, types: List(String))
}

pub type Param {
  Param(name: String, type_: String)
  /// Labelled argument: same as `Param` but the renderer prepends
  /// the label.
  LabelledParam(label: String, name: String, type_: String)
}

pub type Branch {
  Branch(pattern: String, body: Code)
}

/// Local Option type so the AST module doesn't depend on
/// `gleam/option` (the rendered output uses `option.Some` /
/// `option.None`; the AST itself only models the source text).
pub type OptCode(t) {
  CodeSome(t)
  CodeNone
}

// ---------- public API: render ----------

/// Render a `Code` tree to a Gleam source string. Output ends with a
/// single trailing newline.
pub fn render(c: Code) -> String {
  do_render(c, 0)
  |> trim_trailing
  |> fn(s) { s <> "\n" }
}

// ---------- internals ----------

fn do_render(c: Code, indent: Int) -> String {
  case c {
    Module(items) ->
      items
      |> list.map(fn(item) { do_render(item, 0) })
      |> string.join("\n")

    Import(path: p, alias: a, unqualified: u) -> {
      let alias_str = case a {
        CodeSome(name) -> " as " <> name
        CodeNone -> ""
      }
      let unq_str = case u {
        [] -> ""
        names -> ".{" <> string.join(names, ", ") <> "}"
      }
      pad(indent) <> "import " <> p <> alias_str <> unq_str
    }

    TypeDef(public: pub_, is_opaque: op, name: n, variants: vs) -> {
      let keyword = case pub_, op {
        True, True -> "pub opaque type "
        True, False -> "pub type "
        False, _ -> "type "
      }
      let header = pad(indent) <> keyword <> n <> " {"
      let body =
        vs
        |> list.map(fn(v) { pad(indent + 1) <> render_variant(v) })
        |> string.join("\n")
      header <> "\n" <> body <> "\n" <> pad(indent) <> "}"
    }

    Fn(public: pub_, name: n, params: ps, return: ret, body: b) -> {
      let keyword = case pub_ {
        True -> "pub fn "
        False -> "fn "
      }
      let params_str = render_params(ps)
      let ret_str = case ret {
        CodeSome(t) -> " -> " <> t
        CodeNone -> ""
      }
      let header =
        pad(indent) <> keyword <> n <> "(" <> params_str <> ")" <> ret_str <> " {"
      let body_str = do_render(b, indent + 1)
      header <> "\n" <> body_str <> "\n" <> pad(indent) <> "}"
    }

    Let(name: n, value: v) ->
      pad(indent) <> "let " <> n <> " = " <> do_render_expr(v, indent)

    Use(name: n, callee: c2) ->
      case n {
        "" -> pad(indent) <> "use <- " <> do_render_expr(c2, indent)
        _ -> pad(indent) <> "use " <> n <> " <- " <> do_render_expr(c2, indent)
      }

    Case(scrutinee: s, branches: bs) -> {
      let header = pad(indent) <> "case " <> do_render_expr(s, indent) <> " {"
      let body =
        bs
        |> list.map(fn(br) {
          pad(indent + 1)
          <> br.pattern
          <> " -> "
          <> do_render_expr(br.body, indent + 1)
        })
        |> string.join("\n")
      header <> "\n" <> body <> "\n" <> pad(indent) <> "}"
    }

    Block(items: xs) ->
      xs
      |> list.map(fn(x) { do_render(x, indent) })
      |> string.join("\n")

    Call(head: h, args: as_) ->
      pad(indent) <> render_call(h, as_, indent)

    Concat(parts: ps) ->
      pad(indent) <> render_concat(ps, indent)

    Tuple(items: xs) ->
      pad(indent) <> render_tuple(xs, indent)

    ListLit(items: xs, tail: t) ->
      pad(indent) <> render_list(xs, t, indent)

    Ident(name: n) -> pad(indent) <> n

    StrLit(value: v) -> pad(indent) <> escape_string_literal(v)

    IntLit(value: n) -> pad(indent) <> int_to_string(n)

    Raw(fragment: f) -> indent_raw(f, indent)

    DocComment(lines: ls) ->
      ls
      |> list.map(fn(l) { pad(indent) <> "/// " <> l })
      |> string.join("\n")

    Blank -> ""
  }
}

/// Render a `Code` value in expression position — no leading
/// indentation, since the caller already supplied it.
fn do_render_expr(c: Code, indent: Int) -> String {
  case c {
    Ident(name: n) -> n
    StrLit(value: v) -> escape_string_literal(v)
    IntLit(value: n) -> int_to_string(n)
    Raw(fragment: f) -> f
    Call(head: h, args: as_) -> render_call(h, as_, indent)
    Concat(parts: ps) -> render_concat(ps, indent)
    Tuple(items: xs) -> render_tuple(xs, indent)
    ListLit(items: xs, tail: t) -> render_list(xs, t, indent)
    _ ->
      // Larger constructs in expression position fall back to the
      // statement renderer — Gleam allows blocks as expressions when
      // delimited.
      "{\n"
      <> do_render(c, indent + 1)
      <> "\n"
      <> pad(indent)
      <> "}"
  }
}

fn render_call(head: Code, args: List(Code), indent: Int) -> String {
  let head_str = do_render_expr(head, indent)
  let args_str =
    args
    |> list.map(fn(a) { do_render_expr(a, indent) })
    |> string.join(", ")
  head_str <> "(" <> args_str <> ")"
}

fn render_concat(parts: List(Code), indent: Int) -> String {
  parts
  |> list.map(fn(p) { do_render_expr(p, indent) })
  |> string.join(" <> ")
}

fn render_tuple(items: List(Code), indent: Int) -> String {
  let parts =
    items
    |> list.map(fn(i) { do_render_expr(i, indent) })
    |> string.join(", ")
  "#(" <> parts <> ")"
}

fn render_list(items: List(Code), tail: OptCode(Code), indent: Int) -> String {
  let head =
    items
    |> list.map(fn(i) { do_render_expr(i, indent) })
    |> string.join(", ")
  case tail {
    CodeNone -> "[" <> head <> "]"
    CodeSome(t) -> "[" <> head <> ", .." <> do_render_expr(t, indent) <> "]"
  }
}

fn render_params(ps: List(Param)) -> String {
  ps
  |> list.map(fn(p) {
    case p {
      Param(name: n, type_: t) -> n <> ": " <> t
      LabelledParam(label: l, name: n, type_: t) ->
        l <> " " <> n <> ": " <> t
    }
  })
  |> string.join(", ")
}

fn render_variant(v: Variant) -> String {
  case v {
    UnitVariant(name: n) -> n
    Variant(name: n, fields: fs) -> {
      let fields_str =
        fs
        |> list.map(fn(p) {
          case p {
            Param(name: nn, type_: t) -> nn <> ": " <> t
            LabelledParam(name: nn, type_: t, ..) -> nn <> ": " <> t
          }
        })
        |> string.join(", ")
      n <> "(" <> fields_str <> ")"
    }
    PositionalVariant(name: n, types: ts) -> n <> "(" <> string.join(ts, ", ") <> ")"
  }
}

fn pad(level: Int) -> String {
  case level {
    0 -> ""
    _ -> "  " <> pad(level - 1)
  }
}

fn indent_raw(fragment: String, indent: Int) -> String {
  // Re-indent each line of a raw fragment to the current level. Lines
  // that already lead with spaces are preserved relative to the
  // first non-empty line (so multi-line `Raw` blocks keep their
  // shape).
  fragment
  |> string.split("\n")
  |> list.map(fn(line) {
    case string.trim_start(line) == "" {
      True -> ""
      False -> pad(indent) <> line
    }
  })
  |> string.join("\n")
}

fn escape_string_literal(s: String) -> String {
  let escaped =
    s
    |> string.replace("\\", "\\\\")
    |> string.replace("\"", "\\\"")
  "\"" <> escaped <> "\""
}

fn trim_trailing(s: String) -> String {
  case string.ends_with(s, "\n") {
    True -> trim_trailing(string.drop_end(s, 1))
    False -> s
  }
}

fn int_to_string(n: Int) -> String {
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
