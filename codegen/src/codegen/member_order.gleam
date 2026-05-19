//// Wrapper around the `aws_codegen_ffi:extract_member_orders/1`
//// Erlang FFI. The shape decoder in `smithy/shape.gleam` parses
//// `members` into a `Dict(String, Member)` which loses declaration
//// order (Erlang maps are unordered). awsQuery / ec2Query / restXml
//// all require wire serialization to follow the model's *declared*
//// member order. This helper does a second pass over the raw model
//// JSON with order-preserving callbacks and returns
//// `Dict(shape_id, List(member_name))` for every aggregate shape.

import gleam/dict.{type Dict}

@external(erlang, "aws_codegen_ffi", "extract_member_orders")
pub fn extract(json: String) -> Dict(String, List(String))
