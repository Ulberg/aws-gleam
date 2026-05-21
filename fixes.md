# Outstanding follow-ups

Small simplifications and clean-ups that remain after the
`rest_request` extraction and the smells.md sweep. None are urgent;
each can be picked up independently.

## 1. Lambda-body templates still emitted via `code.Raw` — DONE

Closed by adding `code.Lambda(params, body)` and lifting both
closures in `rest_request.gleam` (`query_member_let`'s `list.fold`
and `header_member_let`'s `list.map`) onto it. Inner-expression
rendering keys on the `v` binding via `code.Let(name: "v", value:
item)` inside the Lambda body, so the existing
`value_to_string_with_format` helper still works without parameter-
name plumbing.

## 2. Inner case ladders in `xml_value_expr` — REJECTED

The two 4-way cases in `xml_value_expr`'s `RList` and `RMap` branches
dispatch on `(xml_flattened?, has_member_ns?, has_inner_ns?)`. The
function name AND the argument arity vary across the four branches
(`flat_list(name, items)` vs `list_element_ns(name, mem_ns, entry,
ens, items)`), so a `pick_call_name + single Call` factoring needs a
parallel `pick_args` helper that's no shorter than the current case.
The runtime `aws/internal/codec/xml` module is the right place for
an "always-optional-ns" merger — but that's a larger reshape of the
runtime API for marginal codegen-side gain. Leaving as-is.

## 3. `emit_operation` synth blocks in awsjson + restxml — REJECTED

`synth_in_record` / `synth_in_decoder` / `synth_out_record` are
already one-line wrappers (`case should { True -> emit_record_def(...)
False -> "" }`) around shared helpers. A `synth_text(should, fn() {
... })` factoring adds a closure parameter per call site without
shrinking line count. The duplication is real but cheap; leaving
as-is preserves locality.

## 4. `body_members` filter inside `restjson.emit_operation` — DONE

Replaced the open-coded `list.filter(..., Body -> True ...)` with
`types.categorize_bindings(in_members).body`. The unused `Body`
constructor import dropped out of `restjson.gleam` at the same time.

## 5. Pre-existing env-dependent test failure — DONE

Closed by adding `credentials.default_chain_with` (injectable env /
file / runner seams) and switching the test to use it. The "all
providers exhaust" assertion no longer depends on real env scrubbing.
