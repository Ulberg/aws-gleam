//// Tests for the `Trait` value sum + its JSON re-serializer. The
//// serializer is the only path that gets the raw `endpoint-rule-set`
//// JSON back out of the typed model so it can be embedded as a
//// constant in generated modules — round-tripping it through
//// `decode -> to_json_string -> decode` is the canonical contract.

import gleam/dict
import gleam/dynamic/decode
import gleam/float
import gleam/json
import gleam/list
import gleeunit/should
import smithy/shape_id.{ShapeId}
import smithy/trait

pub fn to_json_string_handles_primitive_values_test() {
  trait.to_json_string(trait.Null) |> should.equal("null")
  trait.to_json_string(trait.Bool(True)) |> should.equal("true")
  trait.to_json_string(trait.Bool(False)) |> should.equal("false")
  trait.to_json_string(trait.Int(42)) |> should.equal("42")
}

pub fn to_json_string_quotes_and_escapes_strings_test() {
  trait.to_json_string(trait.String("hello"))
  |> should.equal("\"hello\"")
  // Double-quote inside a string must be `\"`.
  trait.to_json_string(trait.String("he said \"hi\""))
  |> should.equal("\"he said \\\"hi\\\"\"")
  // Backslash inside a string must be `\\`.
  trait.to_json_string(trait.String("path\\name"))
  |> should.equal("\"path\\\\name\"")
  // Newlines and tabs become JSON control escapes.
  trait.to_json_string(trait.String("a\nb\tc"))
  |> should.equal("\"a\\nb\\tc\"")
}

pub fn to_json_string_emits_lists_test() {
  trait.to_json_string(trait.List([trait.Int(1), trait.Int(2), trait.Int(3)]))
  |> should.equal("[1,2,3]")
}

pub fn to_json_string_emits_objects_test() {
  let d =
    dict.from_list([
      #(ShapeId("name"), trait.String("alice")),
      #(ShapeId("age"), trait.Int(30)),
    ])
  let out = trait.to_json_string(trait.Dict(d))
  // Dict iteration order is unspecified — accept both orderings.
  let possibilities = [
    "{\"name\":\"alice\",\"age\":30}",
    "{\"age\":30,\"name\":\"alice\"}",
  ]
  list.contains(possibilities, out) |> should.be_true
}

pub fn to_json_string_round_trips_through_decoder_test() {
  // Build a nested object, serialize it, decode it back, and assert
  // structural equality on the trait shape — the strongest contract
  // for the serializer.
  let original =
    trait.Dict(
      dict.from_list([
        #(ShapeId("version"), trait.String("1.0")),
        #(ShapeId("debug"), trait.Bool(True)),
        #(
          ShapeId("rules"),
          trait.List([
            trait.Dict(
              dict.from_list([
                #(ShapeId("type"), trait.String("endpoint")),
                #(ShapeId("count"), trait.Int(7)),
              ]),
            ),
          ]),
        ),
      ]),
    )

  let serialized = trait.to_json_string(original)
  let assert Ok(parsed) = json.parse(serialized, trait.decoder())

  // Decode-then-encode-then-decode is idempotent on the canonical form.
  trait.to_json_string(parsed)
  |> json.parse(trait.decoder())
  |> should.equal(Ok(parsed))
}

pub fn to_json_string_handles_floats_test() {
  // Floats round through `float.to_string` — the contract here is just
  // that the output parses back as a number, not the exact text.
  let serialized = trait.to_json_string(trait.Float(3.14))
  let assert Ok(parsed) = json.parse(serialized, decode.float)
  // Allow tiny rounding tolerance — 3.14 has no exact binary
  // representation, but we should be within 1e-9.
  let diff = case parsed >. 3.14 {
    True -> parsed -. 3.14
    False -> 3.14 -. parsed
  }
  { diff <. 0.000_000_001 } |> should.be_true
  // Silence unused-import warning on float in case the conditional
  // version is removed later.
  let _ = float.to_string
}
