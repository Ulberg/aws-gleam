//// Tests for the tiny text-extraction helpers in
//// `aws/internal/text_scan`. Three call sites in production (STS,
//// STS WebIdentity, the runtime's error parser) and one in the SSO
//// cache reader rely on these — covering the obvious shapes here
//// keeps regressions visible in one place rather than scattered
//// across provider test files.

import aws/internal/text_scan
import gleeunit/should

pub fn xml_tag_text_returns_inner_content_test() {
  text_scan.xml_tag_text("<Code>NoSuchBucket</Code>", "Code")
  |> should.equal(Ok("NoSuchBucket"))
}

pub fn xml_tag_text_handles_surrounding_content_test() {
  text_scan.xml_tag_text(
    "<Error><Code>InvalidArgument</Code><Message>Bad</Message></Error>",
    "Code",
  )
  |> should.equal(Ok("InvalidArgument"))
}

pub fn xml_tag_text_picks_first_occurrence_test() {
  // Two `<Code>` blocks; the scanner returns the first one.
  text_scan.xml_tag_text(
    "<ErrorResponse><Error><Code>X</Code></Error><Code>Y</Code></ErrorResponse>",
    "Code",
  )
  |> should.equal(Ok("X"))
}

pub fn xml_tag_text_returns_error_when_missing_test() {
  text_scan.xml_tag_text("<Error><Message>oops</Message></Error>", "Code")
  |> should.equal(Error(Nil))
}

pub fn xml_tag_text_returns_error_when_close_missing_test() {
  // Open without close — split_once for the close tag fails.
  text_scan.xml_tag_text("<Code>nope", "Code")
  |> should.equal(Error(Nil))
}

pub fn json_string_after_key_reads_value_test() {
  text_scan.json_string_after_key(
    "{\"accessToken\": \"abc-123\", \"expiresAt\": \"...\"}",
    "accessToken",
  )
  |> should.equal(Ok("abc-123"))
}

pub fn json_string_after_key_tolerates_no_space_test() {
  text_scan.json_string_after_key("{\"code\":\"InvalidArgument\"}", "code")
  |> should.equal(Ok("InvalidArgument"))
}

pub fn json_string_after_key_returns_error_when_absent_test() {
  text_scan.json_string_after_key("{\"other\": \"value\"}", "missing")
  |> should.equal(Error(Nil))
}
