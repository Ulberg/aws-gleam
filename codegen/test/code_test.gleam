//// Tests for the Gleam-source AST helpers in `codegen/code`.

import codegen/code
import gleeunit/should

pub fn references_module_detects_qualified_use_test() {
  code.references_module("foo decode.run()", "decode.")
  |> should.be_true
}

pub fn references_module_ignores_identifier_suffix_match_test() {
  // `decode.` appears as the suffix of `xml_decode.` — this MUST NOT
  // be treated as a real reference to the `decode` module, since it
  // is actually a member of `xml_decode`.
  code.references_module("let _ = xml_decode.Element", "decode.")
  |> should.be_false
}

pub fn references_module_matches_at_start_of_body_test() {
  code.references_module("decode.run()", "decode.")
  |> should.be_true
}

pub fn references_module_handles_underscore_prefix_test() {
  code.references_module("a_decode.x", "decode.")
  |> should.be_false
}

pub fn references_module_handles_digit_prefix_test() {
  code.references_module("v2decode.x", "decode.")
  |> should.be_false
}

pub fn references_module_finds_use_after_initial_false_match_test() {
  // First "decode." sits inside `xml_decode.`; the second is a real use.
  code.references_module("xml_decode.Element ; decode.run()", "decode.")
  |> should.be_true
}

pub fn references_module_returns_false_when_absent_test() {
  code.references_module("no references here", "decode.")
  |> should.be_false
}

pub fn let_assert_renders_with_pattern_test() {
  code.render(code.LetAssert(
    pattern: "Ok(x)",
    value: code.Call(head: code.Ident(name: "parse"), args: [
      code.Ident(name: "input"),
    ]),
  ))
  |> should.equal("let assert Ok(x) = parse(input)\n")
}

pub fn let_assert_supports_complex_patterns_test() {
  // Patterns can be arbitrary Gleam pattern syntax — the renderer
  // doesn't interpret them. Used for tuple destructuring, record
  // patterns, etc.
  code.render(code.LetAssert(
    pattern: "#(a, b)",
    value: code.Call(head: code.Ident(name: "pair"), args: [
      code.IntLit(value: 1),
    ]),
  ))
  |> should.equal("let assert #(a, b) = pair(1)\n")
}

pub fn const_renders_with_type_annotation_test() {
  code.render(code.Const(
    name: "greeting",
    type_: "String",
    value: code.StrLit(value: "hi"),
  ))
  |> should.equal("const greeting: String = \"hi\"\n")
}

pub fn lambda_renders_inline_test() {
  code.render(code.Lambda(
    params: ["x"],
    body: code.Call(head: code.Ident(name: "double"), args: [
      code.Ident(name: "x"),
    ]),
  ))
  |> should.equal("fn(x) { double(x) }\n")
}

pub fn lambda_with_no_params_renders_test() {
  code.render(code.Lambda(params: [], body: code.IntLit(value: 42)))
  |> should.equal("fn() { 42 }\n")
}

pub fn lambda_with_multiple_params_renders_test() {
  code.render(code.Lambda(
    params: ["a", "b"],
    body: code.Call(head: code.Ident(name: "plus"), args: [
      code.Ident(name: "a"),
      code.Ident(name: "b"),
    ]),
  ))
  |> should.equal("fn(a, b) { plus(a, b) }\n")
}

pub fn lambda_works_as_call_argument_test() {
  // The motivating use case: passing a closure to `list.map` /
  // `list.fold` without templating it as a Raw fragment.
  code.render(
    code.Call(head: code.Ident(name: "list.map"), args: [
      code.Ident(name: "xs"),
      code.Lambda(
        params: ["x"],
        body: code.Call(head: code.Ident(name: "f"), args: [
          code.Ident(name: "x"),
        ]),
      ),
    ]),
  )
  |> should.equal("list.map(xs, fn(x) { f(x) })\n")
}

pub fn const_inside_module_renders_with_blank_separation_test() {
  code.render(
    code.Module(items: [
      code.Const(name: "foo", type_: "Int", value: code.IntLit(value: 1)),
      code.Blank,
      code.Fn(
        public: True,
        name: "use_foo",
        params: [],
        return: code.CodeSome("Int"),
        body: code.Ident(name: "foo"),
      ),
    ]),
  )
  |> should.equal("const foo: Int = 1\n\npub fn use_foo() -> Int {\n  foo\n}\n")
}
