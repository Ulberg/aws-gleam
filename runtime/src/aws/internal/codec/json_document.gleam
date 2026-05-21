//// `smithy.api#Document` codec. Documents are "any JSON value" — the
//// service doesn't constrain the shape. We carry them as `json.Json`
//// so round-trips are byte-stable: decode a document field, re-encode
//// it, and you get the same JSON back out.
////
//// Backed by FFI because `gleam_json.Json` is opaque and there's no
//// public constructor for "raw JSON". On the Erlang side `Json` is
//// just iodata, so `raw/1` is a no-op cast.

import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/json.{type Json}

/// Take a dynamic value (whatever `decode.dynamic` produced) and turn
/// it into a `json.Json`. Round-trips through `aws_ffi:encode_dynamic_to_json`,
/// then casts the resulting binary back to the opaque `Json` type.
pub fn from_dynamic(d: Dynamic) -> Json {
  case encode_dynamic_ffi(d) {
    Ok(bin) -> raw(bin)
    Error(_) -> json.null()
  }
}

/// Decoder for a Document field. Always succeeds — Documents accept
/// any JSON shape including nulls, so failure is never the right
/// answer at this layer.
pub fn decoder() -> decode.Decoder(Json) {
  decode.then(decode.dynamic, fn(d) { decode.success(from_dynamic(d)) })
}

@external(erlang, "aws_ffi", "encode_dynamic_to_json")
fn encode_dynamic_ffi(d: Dynamic) -> Result(String, Nil)

@external(erlang, "gleam_json_ffi", "json_to_string")
fn raw(bin: String) -> Json
