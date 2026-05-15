//// Unit tests for the INI parser. Focused on the shape we need for the AWS
//// shared credentials file, not on full INI compatibility.

import aws/internal/ini.{ParseError}
import gleam/dict
import gleeunit/should

pub fn empty_input_parses_to_empty_test() {
  ini.parse("")
  |> should.equal(Ok(dict.new()))
}

pub fn single_section_with_two_properties_test() {
  let assert Ok(parsed) =
    ini.parse(
      "[default]
aws_access_key_id = AKID
aws_secret_access_key = SECRET
",
    )
  ini.get_property(parsed, section: "default", key: "aws_access_key_id")
  |> should.equal(Ok("AKID"))
  ini.get_property(parsed, section: "default", key: "aws_secret_access_key")
  |> should.equal(Ok("SECRET"))
}

pub fn two_sections_isolate_properties_test() {
  let assert Ok(parsed) =
    ini.parse(
      "[default]
aws_access_key_id = DEFAULT_KEY

[prod]
aws_access_key_id = PROD_KEY
",
    )
  ini.get_property(parsed, section: "default", key: "aws_access_key_id")
  |> should.equal(Ok("DEFAULT_KEY"))
  ini.get_property(parsed, section: "prod", key: "aws_access_key_id")
  |> should.equal(Ok("PROD_KEY"))
}

pub fn whitespace_around_equals_is_trimmed_test() {
  let assert Ok(parsed) = ini.parse("[s]\nkey   =   value   ")
  ini.get_property(parsed, section: "s", key: "key")
  |> should.equal(Ok("value"))
}

pub fn hash_and_semicolon_comments_skipped_test() {
  let assert Ok(parsed) =
    ini.parse(
      "# A header comment
[default]
; Inline hash-style is out of scope; the whole-line case is enough for now.
aws_access_key_id = AKID
",
    )
  ini.get_property(parsed, section: "default", key: "aws_access_key_id")
  |> should.equal(Ok("AKID"))
}

pub fn brackets_with_inner_whitespace_normalize_test() {
  let assert Ok(parsed) = ini.parse("[ default ]\nkey = value")
  ini.get_property(parsed, section: "default", key: "key")
  |> should.equal(Ok("value"))
}

pub fn property_before_any_section_is_rejected_test() {
  let assert Error(ParseError(line: line, ..)) =
    ini.parse("orphan = value\n[ok]\nkey = val")
  line |> should.equal(1)
}

pub fn missing_section_close_bracket_is_rejected_test() {
  let assert Error(ParseError(line: line, ..)) =
    ini.parse("[default\nkey = val")
  line |> should.equal(1)
}

pub fn malformed_property_without_equals_is_rejected_test() {
  let assert Error(ParseError(line: line, ..)) = ini.parse("[s]\nkey value")
  line |> should.equal(2)
}

pub fn missing_section_returns_error_on_lookup_test() {
  let assert Ok(parsed) = ini.parse("[default]\nkey = val")
  ini.get_property(parsed, section: "absent", key: "key")
  |> should.be_error
}
