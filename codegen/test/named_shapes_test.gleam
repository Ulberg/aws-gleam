import codegen/code
import codegen/named_shapes
import codegen/struct_codec
import codegen/types
import gleam/option
import gleam/string
import gleeunit/should

fn member(name: String, required: Bool) -> types.MemberDef {
  types.MemberDef(
    json_name: name,
    snake_name: string.lowercase(name),
    member_name: name,
    target: types.RPrim(primitive: types.PString),
    required: required,
    binding: types.Body,
    media_type: option.None,
    timestamp_format: option.None,
    default_json: option.None,
    idempotency_token: False,
    xml_flattened: False,
    xml_attribute: False,
    xml_namespace: option.None,
  )
}

pub fn record_def_uses_plain_types_for_required_members_test() {
  code.render(
    named_shapes.record_def("ExampleRequest", [
      member("Bucket", True),
      member("Prefix", False),
    ]),
  )
  |> should.equal(
    "pub type ExampleRequest {\n  ExampleRequest(bucket: String, prefix: option.Option(String))\n}\n",
  )
}

pub fn optional_members_keep_output_surfaces_optional_test() {
  let members =
    types.optional_members([member("Bucket", True), member("Prefix", False)])
  code.render(named_shapes.record_def("ExampleOutput", members))
  |> should.equal(
    "pub type ExampleOutput {\n  ExampleOutput(bucket: option.Option(String), prefix: option.Option(String))\n}\n",
  )
}

pub fn record_default_takes_required_members_and_defaults_optional_ones_test() {
  code.render(
    named_shapes.record_default_fn("example_request", "ExampleRequest", [
      member("Bucket", True),
      member("Prefix", False),
    ]),
  )
  |> should.equal(
    "pub fn example_request_default(bucket bucket: String) -> ExampleRequest {\n  ExampleRequest(\n    bucket: bucket,\n    prefix: option.None,\n  )\n}\n",
  )
}

pub fn json_encoder_always_writes_required_members_test() {
  let source =
    code.render(struct_codec.encoder(
      "encode_example_request_struct",
      "ExampleRequest",
      [member("Bucket", True), member("Prefix", False)],
      True,
      True,
    ))
  string.contains(source, "let v = input.bucket") |> should.be_true
  string.contains(source, "#(\"Bucket\", json.string(v))") |> should.be_true
  string.contains(source, "case input.prefix") |> should.be_true
}

pub fn json_decoder_requires_required_members_test() {
  let source =
    code.render(struct_codec.decoder(
      "decode_example_request_struct",
      "ExampleRequest",
      [member("Bucket", True), member("Prefix", False)],
      True,
      False,
    ))
  string.contains(source, "decode.field(\"Bucket\", decode.string)")
  |> should.be_true
  string.contains(source, "decode.optional_field(\"Prefix\"") |> should.be_true
}
