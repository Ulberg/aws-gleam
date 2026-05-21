//// Minimal Gleam-source AST used by the codegen emitters.
////
//// Each emitter builds a tree of `Code` nodes and hands it to
//// `render` once. The structural representation rules out a whole
//// class of bugs that plagued the earlier string-concat style:
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

  /// A `let assert <pattern> = expr` statement. `pattern` is a Gleam
  /// pattern as a string (e.g. `"Ok(rule_set)"`); the renderer emits
  /// it verbatim, just as `Use` emits its `name` verbatim. Reserved
  /// for invariants that hold by construction — the caller has
  /// already proved the match is total, and a runtime failure would
  /// be a generator bug rather than an end-user condition.
  LetAssert(pattern: String, value: Code)

  /// A module-level `const NAME: Type = value` declaration. Rendered
  /// as a top-level item; not allowed inside a function body.
  Const(name: String, type_: String, value: Code)

  /// A `use name <- callee` continuation. Lifts the rest of the body
  /// into a closure passed to `callee`.
  Use(name: String, callee: Code)

  /// A `fn(p1, p2, ...) { body }` anonymous-function expression.
  /// Parameters are bare identifier names — anonymous functions in
  /// Gleam don't carry type annotations on params. Used by the codegen
  /// for body closures fed to `list.map` / `list.fold` / similar; lets
  /// emitters compose the closure body out of typed AST instead of
  /// templating a `code.Raw` fragment.
  Lambda(params: List(String), body: Code)

  /// A `case scrutinee { ... }` expression. Each branch is
  /// `pattern -> body`.
  Case(scrutinee: Code, branches: List(Branch))

  /// A sequence of statements (lets + uses + a tail expression).
  /// Rendered with one statement per line.
  Block(items: List(Code))

  /// `head(args)` — function/constructor application. `args` render
  /// comma-joined.
  Call(head: Code, args: List(Code))

  /// String concatenation of multiple parts. Rendered as a
  /// `string.concat([a, b, c])` call. Used heavily by encoders.
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

  /// `Ctor(..record, field1: v1, field2: v2)` — Gleam record update
  /// expression. `record` is the base value, `type_` is the
  /// constructor name (Gleam requires it explicitly), and `fields`
  /// are `Labelled(field, value)` overrides. Used by the codegen for
  /// in-place updates that would otherwise need a manual rebuild —
  /// e.g. threading a pagination cursor into a typed input.
  RecordUpdate(record: Code, type_: String, fields: List(Code))

  /// Raw passthrough — emitter hands a pre-formatted Gleam fragment.
  /// Escape hatch for legacy code; should eventually be empty.
  Raw(fragment: String)

  /// A doc comment (`/// ...`) attached to the next item. Empty
  /// list of lines = no comment.
  DocComment(lines: List(String))

  /// A module-level doc comment (`//// ...`). Differs from
  /// `DocComment` only in slash count; Gleam's parser uses the
  /// 4-slash form for the module preamble.
  ModuleDocComment(lines: List(String))

  /// `label: value` — a labelled argument. Only meaningful inside
  /// `Call.args`; the renderer prepends `<label>: ` before the
  /// value expression. Used for labelled record construction
  /// (`Dispatcher(operation_id: "...", build_request: fn(...) ...)`)
  /// and any labelled function call. Pass 7 of plan.md.
  Labelled(label: String, value: Code)

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
  |> fn(s) { string.concat([s, "\n"]) }
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
        CodeSome(name) -> string.concat([" as ", name])
        CodeNone -> ""
      }
      let unq_str = case u {
        [] -> ""
        names -> string.concat([".{", string.join(names, ", "), "}"])
      }
      string.concat([pad(indent), "import ", p, alias_str, unq_str])
    }

    TypeDef(public: pub_, is_opaque: op, name: n, variants: vs) -> {
      let keyword = case pub_, op {
        True, True -> "pub opaque type "
        True, False -> "pub type "
        False, _ -> "type "
      }
      let header = string.concat([pad(indent), keyword, n, " {"])
      let body =
        vs
        |> list.map(fn(v) {
          string.concat([pad(indent + 1), render_variant(v)])
        })
        |> string.join("\n")
      string.concat([header, "\n", body, "\n", pad(indent), "}"])
    }

    Fn(public: pub_, name: n, params: ps, return: ret, body: b) -> {
      let keyword = case pub_ {
        True -> "pub fn "
        False -> "fn "
      }
      let params_str = render_params(ps)
      let ret_str = case ret {
        CodeSome(t) -> string.concat([" -> ", t])
        CodeNone -> ""
      }
      let header =
        string.concat([
          pad(indent),
          keyword,
          n,
          "(",
          params_str,
          ")",
          ret_str,
          " {",
        ])
      let body_str = do_render(b, indent + 1)
      string.concat([header, "\n", body_str, "\n", pad(indent), "}"])
    }

    Let(name: n, value: v) ->
      string.concat([pad(indent), "let ", n, " = ", do_render_expr(v, indent)])

    LetAssert(pattern: p, value: v) ->
      string.concat([
        pad(indent),
        "let assert ",
        p,
        " = ",
        do_render_expr(v, indent),
      ])

    Const(name: n, type_: t, value: v) ->
      string.concat([
        pad(indent),
        "const ",
        n,
        ": ",
        t,
        " = ",
        do_render_expr(v, indent),
      ])

    Use(name: n, callee: c2) ->
      case n {
        "" ->
          string.concat([pad(indent), "use <- ", do_render_expr(c2, indent)])
        _ ->
          string.concat([
            pad(indent),
            "use ",
            n,
            " <- ",
            do_render_expr(c2, indent),
          ])
      }

    Lambda(params: ps, body: b) ->
      string.concat([
        pad(indent),
        "fn(",
        string.join(ps, ", "),
        ") { ",
        do_render_expr(b, indent),
        " }",
      ])

    Case(scrutinee: s, branches: bs) -> {
      let header =
        string.concat([pad(indent), "case ", do_render_expr(s, indent), " {"])
      let body =
        bs
        |> list.map(fn(br) {
          string.concat([
            pad(indent + 1),
            br.pattern,
            " -> ",
            do_render_expr(br.body, indent + 1),
          ])
        })
        |> string.join("\n")
      string.concat([header, "\n", body, "\n", pad(indent), "}"])
    }

    Block(items: xs) ->
      xs
      |> list.map(fn(x) { do_render(x, indent) })
      |> string.join("\n")

    Call(head: h, args: as_) ->
      string.concat([pad(indent), render_call(h, as_, indent)])

    Concat(parts: ps) -> string.concat([pad(indent), render_concat(ps, indent)])

    Tuple(items: xs) -> string.concat([pad(indent), render_tuple(xs, indent)])

    ListLit(items: xs, tail: t) ->
      string.concat([pad(indent), render_list(xs, t, indent)])

    Ident(name: n) -> string.concat([pad(indent), n])

    StrLit(value: v) -> string.concat([pad(indent), escape_string_literal(v)])

    IntLit(value: n) -> string.concat([pad(indent), int_to_string(n)])

    RecordUpdate(record: r, type_: t, fields: fs) ->
      string.concat([pad(indent), render_record_update(r, t, fs, indent)])

    Raw(fragment: f) -> indent_raw(f, indent)

    DocComment(lines: ls) ->
      ls
      |> list.map(fn(l) { string.concat([pad(indent), "/// ", l]) })
      |> string.join("\n")

    ModuleDocComment(lines: ls) ->
      ls
      |> list.map(fn(l) { string.concat([pad(indent), "//// ", l]) })
      |> string.join("\n")

    // `Labelled` only renders inside `Call.args` (handled in
    // `render_call`). If it appears at top-level the renderer
    // falls through to its value, which is reasonable for nested
    // contexts but ideally never reached.
    Labelled(label: l, value: v) ->
      string.concat([pad(indent), l, ": ", do_render_expr(v, indent)])

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
    RecordUpdate(record: r, type_: t, fields: fs) ->
      render_record_update(r, t, fs, indent)
    Call(head: h, args: as_) -> render_call(h, as_, indent)
    Concat(parts: ps) -> render_concat(ps, indent)
    Tuple(items: xs) -> render_tuple(xs, indent)
    ListLit(items: xs, tail: t) -> render_list(xs, t, indent)
    // `case` is itself an expression in Gleam; render it inline
    // without the explicit-block braces the fallback would wrap it
    // in. Skipping the wrap matches the hand-written style and
    // avoids artificial indentation on `let x = case ... { ... }`.
    Case(..) -> string.trim_start(do_render(c, indent))
    // Anonymous functions render inline too: `fn(p) { body }`. The
    // body uses `do_render_expr` so we don't add line breaks for
    // simple bodies, matching how callers template them today.
    Lambda(params: ps, body: b) ->
      string.concat([
        "fn(",
        string.join(ps, ", "),
        ") { ",
        do_render_expr(b, indent),
        " }",
      ])
    _ ->
      // Larger constructs in expression position fall back to the
      // statement renderer — Gleam allows blocks as expressions when
      // delimited.
      string.concat(["{\n", do_render(c, indent + 1), "\n", pad(indent), "}"])
  }
}

fn render_record_update(
  record: Code,
  type_: String,
  fields: List(Code),
  indent: Int,
) -> String {
  // Gleam syntax: `Ctor(..base, field1: v1, field2: v2)`.
  let record_str = do_render_expr(record, indent)
  let field_str =
    fields
    |> list.map(fn(f) {
      case f {
        Labelled(label: l, value: v) ->
          string.concat([l, ": ", do_render_expr(v, indent)])
        _ -> do_render_expr(f, indent)
      }
    })
    |> string.join(", ")
  string.concat([type_, "(..", record_str, ", ", field_str, ")"])
}

fn render_call(head: Code, args: List(Code), indent: Int) -> String {
  let head_str = do_render_expr(head, indent)
  let args_str =
    args
    |> list.map(fn(a) {
      case a {
        Labelled(label: l, value: v) ->
          string.concat([l, ": ", do_render_expr(v, indent)])
        _ -> do_render_expr(a, indent)
      }
    })
    |> string.join(", ")
  string.concat([head_str, "(", args_str, ")"])
}

fn render_concat(parts: List(Code), indent: Int) -> String {
  // Render `code.Concat([a, b, c])` as `string.concat([a, b, c])` in
  // the generated Gleam code — semantically equivalent to a chain of
  // string-append operators but keeps the output operator-free. The
  // render is string-only (this function returns the joined source
  // text); no call back into the AST machinery.
  let parts_str =
    parts
    |> list.map(fn(p) { do_render_expr(p, indent) })
    |> string.join(", ")
  string.concat(["string.concat([", parts_str, "])"])
}

fn render_tuple(items: List(Code), indent: Int) -> String {
  let parts =
    items
    |> list.map(fn(i) { do_render_expr(i, indent) })
    |> string.join(", ")
  string.concat(["#(", parts, ")"])
}

fn render_list(items: List(Code), tail: OptCode(Code), indent: Int) -> String {
  let head =
    items
    |> list.map(fn(i) { do_render_expr(i, indent) })
    |> string.join(", ")
  case tail {
    CodeNone -> string.concat(["[", head, "]"])
    CodeSome(t) ->
      string.concat(["[", head, ", ..", do_render_expr(t, indent), "]"])
  }
}

fn render_params(ps: List(Param)) -> String {
  ps
  |> list.map(fn(p) {
    case p {
      Param(name: n, type_: t) -> string.concat([n, ": ", t])
      LabelledParam(label: l, name: n, type_: t) ->
        string.concat([l, " ", n, ": ", t])
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
            Param(name: nn, type_: t) -> string.concat([nn, ": ", t])
            LabelledParam(name: nn, type_: t, ..) ->
              string.concat([nn, ": ", t])
          }
        })
        |> string.join(", ")
      string.concat([n, "(", fields_str, ")"])
    }
    PositionalVariant(name: n, types: ts) ->
      string.concat([n, "(", string.join(ts, ", "), ")"])
  }
}

fn pad(level: Int) -> String {
  case level {
    0 -> ""
    _ -> string.concat(["  ", pad(level - 1)])
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
      False -> string.concat([pad(indent), line])
    }
  })
  |> string.join("\n")
}

fn escape_string_literal(s: String) -> String {
  let escaped =
    s
    |> string.replace("\\", "\\\\")
    |> string.replace("\"", "\\\"")
  string.concat(["\"", escaped, "\""])
}

fn trim_trailing(s: String) -> String {
  case string.ends_with(s, "\n") {
    True -> trim_trailing(string.drop_end(s, 1))
    False -> s
  }
}

/// Does the rendered body actually reference a module via its qualifier
/// `prefix` (e.g. `"decode."`)?  Used by file-header emitters to import
/// only modules a generated body uses. Naive substring matching trips on
/// suffixes — `"decode."` inside `"xml_decode."` would falsely "use" the
/// `decode` module. This walks the body and accepts a match only when the
/// character immediately before the prefix is *not* an identifier
/// character (i.e. it sits on a real word boundary).
pub fn references_module(body: String, prefix: String) -> Bool {
  any_word_boundary(strip_comments(body), prefix)
}

/// Drop everything from `//` to end-of-line on every line. Catches
/// `//` regular, `///` doc, and `////` module-doc comments — all are
/// `//`-prefixed in Gleam. Caller uses this to scan code text
/// without false-positives from doc text (e.g. a `// the full
/// list. Required for ...` triggering a `list.` import check).
fn strip_comments(body: String) -> String {
  string.split(body, on: "\n")
  |> list.map(fn(line) {
    case string.split_once(line, on: "//") {
      Ok(#(before, _)) -> before
      Error(_) -> line
    }
  })
  |> string.join("\n")
}

/// True iff `body` contains `name` as a standalone identifier — i.e.
/// `name` appears with non-identifier characters on BOTH sides (or
/// at start/end of string). Stricter than `references_module/2`,
/// which only checks the left boundary. Use this when you need to
/// know "did body actually use the identifier `name`", not just
/// "did body contain anything starting with `name`".
///
/// Picks up `input.x`, `input)`, `input,`, `input ` — anything where
/// the next char isn't part of an identifier. Skips `input_type`,
/// `inputs`, etc.
pub fn references_identifier(body: String, name: String) -> Bool {
  any_identifier_match(body, name)
}

fn any_identifier_match(body: String, name: String) -> Bool {
  case string.split_once(body, on: name) {
    Error(_) -> False
    Ok(#(before, after)) ->
      case ends_with_ident_char(before) || starts_with_ident_char(after) {
        True -> any_identifier_match(after, name)
        False -> True
      }
  }
}

fn starts_with_ident_char(s: String) -> Bool {
  case string.length(s) {
    0 -> False
    _ -> is_ident_char(string.slice(s, at_index: 0, length: 1))
  }
}

fn any_word_boundary(body: String, prefix: String) -> Bool {
  case string.split_once(body, on: prefix) {
    Error(_) -> False
    Ok(#(before, after)) ->
      case ends_with_ident_char(before) {
        // identifier ran straight into prefix — keep scanning after it.
        True -> any_word_boundary(after, prefix)
        False -> True
      }
  }
}

fn ends_with_ident_char(s: String) -> Bool {
  case string.length(s) {
    0 -> False
    n -> is_ident_char(string.slice(s, at_index: n - 1, length: 1))
  }
}

fn is_ident_char(c: String) -> Bool {
  case c {
    "a" | "b" | "c" | "d" | "e" | "f" | "g" | "h" | "i" | "j" -> True
    "k" | "l" | "m" | "n" | "o" | "p" | "q" | "r" | "s" | "t" -> True
    "u" | "v" | "w" | "x" | "y" | "z" -> True
    "A" | "B" | "C" | "D" | "E" | "F" | "G" | "H" | "I" | "J" -> True
    "K" | "L" | "M" | "N" | "O" | "P" | "Q" | "R" | "S" | "T" -> True
    "U" | "V" | "W" | "X" | "Y" | "Z" -> True
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    "_" -> True
    _ -> False
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
      int_str(n / 10, string.concat([c, acc]))
    }
  }
}
