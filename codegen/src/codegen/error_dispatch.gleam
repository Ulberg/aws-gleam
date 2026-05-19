//// Per-error-shape protocol-test dispatcher helpers shared between
//// the restjson1, restxml, awsjson, cbor_rpc, and awsquery/ec2query
//// emitters.
////
//// Each protocol emitter walks its OpSpec list, collects the union of
//// declared error shape IDs, and asks for one
//// `parse_<errsnake>_response` function per shape. The runner uses
//// these to verify discriminator routing for `@httpResponseTests`
//// cases attached directly to error structures (FooError, ComplexError,
//// InvalidGreeting, etc.) — without them every such case skips as
//// `no-dispatcher` even though the runtime can route the response
//// correctly.

import codegen/dispatcher
import gleam/list
import gleam/string
import internal/stringutils

/// Dedupe a list of strings, preserving first-occurrence order. The
/// concrete fold pattern shows up in every protocol emitter's error
/// collation; centralising avoids drift if the ordering contract
/// changes (e.g. sorted output, lexicographic).
pub fn dedupe_strings(xs: List(String)) -> List(String) {
  list.fold(xs, [], fn(acc, x) {
    case list.contains(acc, x) {
      True -> acc
      False -> [x, ..acc]
    }
  })
  |> list.reverse
}

/// Render `pub fn parse_<errsnake>_response(code, headers, body)` for
/// one error shape. Body delegates to
/// `runtime.check_error_type_matches`, which runs the per-protocol
/// discriminator (X-Amzn-Errortype header → __type / code body field
/// → `<Code>` XML element). Returning `Result(Nil, String)` matches
/// the runner's binary Ok/Error contract — the per-op error decoder
/// path still owns field-level decoding for real callers.
pub fn emit_parse_fn(local: String) -> String {
  let snake = stringutils.pascal_to_snake(local)
  string.concat([
    "\npub fn parse_",
    snake,
    "_response(\n",
    "  _code: Int,\n",
    "  headers: dict.Dict(String, String),\n",
    "  body: BitArray,\n",
    ") -> Result(Nil, String) {\n",
    "  runtime.check_error_type_matches(headers, body, \"",
    local,
    "\")\n",
    "}\n",
  ])
}

/// Build a `DispatcherSpec` for each unique error shape ID. `op_id`
/// carries the original `<namespace>#<ErrorLocal>` form because the
/// runner looks dispatchers up by the error's Smithy ID; the snake /
/// input_type fields use the stripped local name to match the
/// `parse_<errsnake>_response` function `emit_parse_fn` writes.
pub fn dispatcher_specs(
  unique_err_ids: List(String),
  strip_namespace: fn(String) -> String,
) -> List(dispatcher.DispatcherSpec) {
  list.map(unique_err_ids, fn(err_id) {
    let local = strip_namespace(err_id)
    dispatcher.DispatcherSpec(
      op_id: err_id,
      snake: stringutils.pascal_to_snake(local),
      input_type: local,
      has_typed_input: False,
      is_error_shape: True,
    )
  })
}
