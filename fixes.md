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

## 2. Inner case ladders in `xml_value_expr`

`restxml.xml_value_expr` still has two 4-way `case` ladders inside its
`RList` and `RMap` branches, dispatching on
`(xml_flattened?, has_member_ns?, has_inner_ns?)`. Each arm picks one
of four call shapes (`xml.flat_list` / `xml.flat_list_ns` /
`xml.list_element` / `xml.list_element_ns`, and the analogous map
quartet). Could become a lookup over the boolean tuple, or split into
a `pick_call_name(...) -> String` helper feeding a single `code.Call`
construction.

## 3. `emit_operation` synth blocks in awsjson + restxml

Both still have ~60 lines of paired
`synth_in_record / synth_in_encoder / synth_in_decoder /
synth_out_record / synth_out_decoder` declarations. The restjson
`synth_io_def` helper doesn't fit because awsjson/restxml gate parts
on `is_dispatcher` and use different `struct_codec` flags. A shared
helper would need extra parameters, but the `rest_request` extraction
showed the shared-module pattern works fine — worth a second look.

## 4. `body_members` filter inside `restjson.emit_operation`

`emit_operation` does its own `list.filter(in_members, Body -> True ...)`
to feed `emit_body_encoder`. After the `types.categorize_bindings`
helper exists, this could become `types.categorize_bindings(in_members).body`
for consistency. Small.

## 5. Pre-existing env-dependent test failure

`test/default_chain_test.gleam:31` —
`default_chain_exhausts_with_all_seven_providers_in_order_test` fails
on the developer's machine because the environment-variables provider
returns real AWS credentials from the shell, breaking the "all 7
providers exhaust" assertion. Not caused by any refactor in this PR.
Either run `unset AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY ...`
before `gleam test`, or rework the test to scrub the env. Flagging for
awareness.
