//// Tiny text-extraction helpers shared by the credential providers
//// and the runtime's error parser. Both shapes — XML `<Tag>X</Tag>`
//// and JSON `"key": "value"` — appear in places where dragging in a
//// full XML / JSON parser would be over-investment.
////
//// `xml_tag_text` and `json_string_after_key` each scan once with two
//// `split_once` calls; neither validates the surrounding document. Use
//// them only on inputs whose structure you trust (STS / SSO responses,
//// error envelopes), never on arbitrary user-supplied text.

import gleam/result
import gleam/string

/// Pull the text content between the first `<tag>` and its matching
/// `</tag>`. Returns `Error(Nil)` if either tag is absent. Used by the
/// STS providers (`<AccessKeyId>...</AccessKeyId>`) and the runtime's
/// restXml error path (`<Code>NoSuchBucket</Code>`).
pub fn xml_tag_text(text: String, tag: String) -> Result(String, Nil) {
  let open = "<" <> tag <> ">"
  let close = "</" <> tag <> ">"
  use #(_, after_open) <- result.try(string.split_once(text, open))
  use #(content, _) <- result.try(string.split_once(after_open, close))
  Ok(content)
}

/// Pull the string value that follows a quoted JSON `"key"`. Skips the
/// first quote after the key (i.e. tolerates `"key": "value"`,
/// `"key":"value"`, `"key" : "value"`), then reads the next two
/// quotes as the value's delimiters. Returns `Error(Nil)` if the key
/// is absent or the value isn't a string-typed JSON field.
///
/// The function deliberately doesn't unescape backslash sequences in
/// the value — callers either don't expect them (STS tokens, error
/// codes) or do their own decoding.
pub fn json_string_after_key(text: String, key: String) -> Result(String, Nil) {
  let needle = "\"" <> key <> "\""
  use #(_, after_key) <- result.try(string.split_once(text, needle))
  use #(_, after_first_quote) <- result.try(string.split_once(after_key, "\""))
  use #(value, _) <- result.try(string.split_once(after_first_quote, "\""))
  Ok(value)
}
