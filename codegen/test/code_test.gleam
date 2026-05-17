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
