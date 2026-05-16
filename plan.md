# Plan: shrink aws_sdk_gleam

Goal: lean codegen-from-Smithy SDK that runs natively on EC2 / local, passes the
Smithy protocol-compliance fixtures, and ships as a typed AST. No protocol
drops, no service drops, no runner-depth changes from today.

## Accounting

229,254 tracked LOC on `plan/m5-codegen`. ~210k of that is derived from
`vendor/smithy`, `vendor/aws-sdk-rust`, or the codegen itself:

| Bucket | LOC | Source |
|---|---|---|
| `src/aws/services/*.gleam` | 93,596 | `scripts/regen.sh`. Already in `.gitignore` but still tracked (added before gitignore). |
| `test/fixtures/protocol-tests/*.json` | 72,086 | `scripts/build-protocol-test-asts.sh` from `vendor/smithy`. |
| `src/aws/services/protocoltests/*.gleam` | 37,510 | `scripts/regen.sh`. |
| `test/fixtures/endpoints/*.json` | 34,193 | Extracted from `vendor/aws-sdk-rust/aws-models/*.json` (each service model carries `endpointRuleSet` + `endpointTests`). |
| `test/protocol_tests/*_dispatchers.gleam` | 4,210 | `scripts/emit-dispatchers.py`. |
| Hand-authored everything else | ~19,600 | The actual codebase. |

Baseline test counts (fresh `scripts/regen.sh && gleam test`):

| Protocol | total | pass | fail | skip(no-disp) | skip(server-only) |
|---|---|---|---|---|---|
| awsJson1_0 | 75 | 51 | 0 | 18 | 6 |
| awsJson1_1 | 122 | 102 | 0 | 16 | 4 |
| restJson1 | 272 | 227 | 0 | 20 | 25 |
| restXml | 197 | 112 | **62** | 15 | 6 |
| restXmlWithNamespace | 2 | 0 | 0 | 2 | 0 |
| awsQuery | 77 | 41 | 0 | 36 | 0 |
| ec2Query | 59 | 31 | 0 | 28 | 0 |
| rpcv2Cbor | 4 | 0 | 0 | 4 | 0 |

The "466/466" figure in commit `0ab7528` holds only with hand-curated
dispatcher modules. A fresh `regen.sh` overwrites the curation and surfaces
the 62 restXml gaps — they're real codec gaps documented in
`docs/audits/m6.md`, hidden by the curation today.

## Pass 1 — stop tracking derived files

Pure plumbing. No behavior change. One PR. Tracked LOC drops from ~229k to ~25k.

1. `git rm --cached -r src/aws/services/` (already in `.gitignore`; evicting from the index).
2. Add to `.gitignore`:
   - `src/aws/services/protocoltests/`
   - `test/fixtures/protocol-tests/*.json`
   - `test/fixtures/endpoints/*.json`
3. `git rm --cached -r` those paths.
4. Write `scripts/extract-endpoints.sh` that lifts `endpointRuleSet` + `endpointTests` blocks from each `vendor/aws-sdk-rust/aws-models/*.json` and writes the corresponding `test/fixtures/endpoints/*.json` files. (The script is small — `jq` over the trait blob; see existing endpoint test files for the expected output shape.)
5. `.github/workflows/ci.yml`: before `gleam test`, run
   ```
   bash scripts/build-protocol-test-asts.sh   # needs smithy CLI; cache .tools/
   bash scripts/extract-endpoints.sh
   bash scripts/regen.sh
   ```
6. README + CLAUDE.md: document the "fresh clone → regen → test" workflow.

Leaves `test/protocol_tests/*_dispatchers.gleam` tracked (4,210 LOC). Pass 2
unblocks evicting those.

## Pass 2 — move dispatcher generation into the Gleam emitter

One PR. Deletes `scripts/emit-dispatchers.py` and the
regen-overwrites-curation footgun.

Today: `emit-dispatchers.py` (120 LOC) regex-scrapes the just-emitted Gleam
service modules and produces `<protocol>_dispatchers.gleam`. The Gleam
emitter already knows every operation, its Input type, and whether
`decode_<op>_input` was emitted.

Steps:

1. Add `pub type EmitMode { ProductionService | ProtocolTest }` to the protocol emitters.
2. In `ProtocolTest` mode, the emitter additionally writes the paired `<protocol>_dispatchers.gleam` to `test/protocol_tests/`. Output matches today's Python output byte-for-byte (so the runner doesn't change).
3. `codegen/src/aws_codegen.gleam` (the `main`) accepts the mode + dispatcher output path.
4. `scripts/regen.sh`: invoke codegen with `ProtocolTest` mode for protocol-test targets; drop the `python3 scripts/emit-dispatchers.py` lines.
5. Delete `scripts/emit-dispatchers.py`.
6. Once green: `git rm --cached test/protocol_tests/*_dispatchers.gleam` + add to `.gitignore`.

Files touched: `codegen/src/codegen/{awsjson,restjson,restxml,awsquery}.gleam`,
`codegen/src/aws_codegen.gleam`, `scripts/regen.sh`.

## Pass 3 — shrink per-operation generated LOC

Today's per-op LOC:
- dynamodb: ~470 LOC/op (57 ops, 26,797 LOC)
- s3: ~380 LOC/op (77 ops, 29,289 LOC)

The emitter writes 18 functions per operation. Three independent cuts:

### 3a — drop output encoders from production services

`encode_<op>_output_struct{,_top}` exists for symmetry. **The wire never
encodes an output.** SDK callers never reach these. Gate behind
`EmitMode::ProtocolTest`.

- Saves: ~15–25 LOC/op.
- Files: `codegen/src/codegen/{awsjson,restjson,restxml}.gleam`.

### 3b — drop test-only input decoders from production services

`decode_<op>_input`, `decode_<op>_output` (outer wrappers), and
`decode_<op>_input_struct_params` (member-keyed variant in `struct_codec.gleam`)
exist only so the protocol-test dispatcher can lift the case's `params` JSON
into a typed input. Real SDK callers construct `ListTablesInput(...)`
directly. Gate behind `EmitMode::ProtocolTest`.

- Saves: ~10–15 LOC/op.
- Also drops the `member_keyed: True` axis from `codegen/src/codegen/struct_codec.gleam` for production codecs.

### 3c — table-ize the error translator

Today: `translate_<op>_error` is a nested-case ladder, ~15 LOC per modeled
error + ~15 LOC scaffolding.

Replace with a table + one runtime helper:

```gleam
// emitted per op
fn list_tables_error_decoders() {
  [
    #("InternalServerError", decode_internal_server_error_struct, ListTablesErrorInternalServerError),
    #("InvalidEndpointException", decode_invalid_endpoint_exception_struct, ListTablesErrorInvalidEndpointException),
  ]
}

fn translate_list_tables_error(err) -> ListTablesError {
  runtime.translate_service_error(
    err,
    list_tables_error_decoders(),
    ListTablesErrorTransport,
    ListTablesErrorUnknown,
  )
}
```

`runtime.translate_service_error/4` lives in
`src/aws/internal/client/runtime.gleam` (post pass 5.1 rename).

- Saves: ~15–30 LOC/op.
- Files: `codegen/src/codegen/{awsjson,restjson,restxml}.gleam` for the emitter side; `src/aws/internal/client/runtime.gleam` for the helper.

### Pass 3 expected outcome

Per-op LOC drops from ~470 to ~250. Generated mass roughly halves:

| File | Before | After (est.) |
|---|---|---|
| `dynamodb.gleam` | 26,797 | ~14,000 |
| `s3.gleam` | 29,289 | ~17,000 |
| `protocoltests/restjson1.gleam` | 17,197 | ~10,000 |
| `protocoltests/restxml.gleam` | 12,055 | ~7,500 |

Files are gitignored after pass 1, so the dent is in compile + regen time,
not tracked LOC.

## Pass 4 — emitter dedup

Lowest-priority. Codegen is ~4 kLOC total. No tracked-LOC dent. Worth doing
for maintainability.

Lift into shared modules:

- `codegen/src/codegen/shape_walker.gleam` — `collect_named_shapes`, `walk`, `remember`, `resolve_or_unit` (byte-identical between restjson/restxml; awsjson differs trivially).
- `codegen/src/codegen/type_defs.gleam` — `emit_record_def`, `emit_enum_def`, `emit_int_enum_def`, `emit_union_def`, `emit_enum_codec` (byte-identical across all three protocols).
- `codegen/src/codegen/http_binding.gleam` — `emit_path_setup`, `emit_query_setup`, `emit_header_setup`, `emit_payload_body`, `http_trait`, `string_field`, `int_field` (byte-identical between restjson/restxml).
- `codegen/src/codegen/client_wiring.gleam` — `emit_client`, `emit_invoke`, `service_metadata`, `string_field_under`, `emit_parse_via_decoder`, `emit_error_type` (byte-identical).
- Lift `int_to_string`, `int_str`, `pascalize_member`, `strip_namespace`, `derive_module_name`, `op_uses_unsupported_trait` to `codegen/src/internal/stringutils.gleam` (which already exists).

After: per-protocol emitters drop to ~150–250 LOC each — focused on body
codec + content-type + a couple of protocol-specific tweaks.

Codegen ~4,000 LOC → ~2,200 LOC. Generated output must be byte-identical
before and after — verify by diffing regenerated `dynamodb.gleam` / `s3.gleam`.

## Pass 5 — small wins

Independent cleanups. Each one PR.

1. **Rename** `src/aws/internal/client/awsjson.gleam` → `src/aws/internal/client/runtime.gleam`. Module is protocol-agnostic but mis-named; every generated `s3.gleam` (rest-XML) operation imports it as `awsjson_client`. Updates 6 emitter lines.
2. **Drop unused imports from generated services.** Emitter writes `import aws/internal/codec/json_document`, `json_float`, `gleam/string` unconditionally. Track which imports the body codec actually uses.
3. **Drop unused `input` params** on empty-input XML encoders (`encode_X_xml_inner(input: ...)` warning).
4. **Drop the JSON struct codecs from the restxml emitter.** Header comment in `codegen/src/codegen/restxml.gleam` self-flags them as dead.

## Pass 7 — kill remaining string concats in the emitter (final pass)

After all the architecture-level changes land (passes 1–6), the
emitter still leans on `"..." <> "..."` string templating in many
places — XML codec emission, error-translator helpers, payload
body setup, query / header / label routing, file headers (before
pass 5.2 lifted those to `code.Module`). Mixed AST + string output
is the worst of both worlds: the AST nodes silently lose context
inside `code.Raw`, and the surrounding `<>` chains keep us one
typo away from invalid Gleam.

Goal: every emitter writes a `code.Code` tree end-to-end. `code.
Raw` survives as the escape hatch but is reserved for fragments
the AST genuinely doesn't model (e.g. user-supplied default
expressions parsed straight from the Smithy `@default` trait).

Inventory of remaining string-concat call sites (grep
`"\\n.*<>"` over `codegen/src/codegen`):

- `codegen/src/codegen/restxml.gleam` — `emit_struct_xml_inner_
  encoder`, `emit_struct_xml_decoder`, `emit_struct_xml_encoder`,
  `xml_value_expr`, `xml_value_decoder_expr`, `emit_payload_body`,
  `value_to_string_with_format`, the wireform helpers, the error-
  translator body, plus `emit_build`'s URI / query / header setup.

- `codegen/src/codegen/restjson.gleam` — `emit_build`,
  `emit_payload_body`, `value_to_string_with_format`, the error-
  translator body. Mirrors restxml.

- `codegen/src/codegen/awsjson.gleam` — `emit_build`, `emit_parse`,
  `emit_error_translator`, `emit_invoke`. Smaller surface because
  there's no XML or REST binding routing.

- `codegen/src/codegen/types.gleam` — `json_encoder*`,
  `json_decoder*` produce inline expression strings used both by
  the struct codec AST and the XML / REST emitters. Lifting these
  to `Code` nodes is the biggest win — they're the source of most
  `code.Raw(fragment: ...)` calls in `struct_codec.gleam` today.

- `codegen/src/codegen/dispatcher.gleam` — already strings, but
  short enough that wrapping the doc + register-chain in a
  `code.Module` is a five-minute change.

Approach: one PR per emitter (restxml has the biggest surface, do
it first), each PR is "produce the same byte output, but via the
AST." Verify by `diff`ing the regenerated services before and
after.

After this pass, `grep -rn '"\\\\n' codegen/src/codegen` should
hit ~zero matches outside `code.gleam`'s renderer internals and
the documented `Raw` escape hatches.

## Pass 6 — close the 62 restXml codec gaps

Real parity work. Not LOC reduction.

After pass 2, every restXml operation has a dispatcher registered → the 62
failures are genuine and unhidden. Each maps to a documented gap in
`docs/audits/m6.md`:

- `@xmlFlattened` lists
- `@xmlName` on struct members
- XML float specials (NaN / Infinity / -Infinity, both directions)
- HTTP-date timestamp format on XML headers
- Union XML emission (`XmlUnions` cases)
- XML map encoding for empty / flattened cases (`XmlEmptyMaps`, `XmlMaps`)
- `@xmlNamespace` for body wrappers
- `@httpResponseCode` / `@httpHeader` binding in response decoders
- `restXmlWithNamespace` protocol — currently `0/2` no-dispatcher; needs separate emitter path or trait-aware fallback through the existing restxml emitter

One PR per gap. Each is independently verifiable against the fixture cases
named in the test output.

## Dependencies

```
Pass 1 (gitignore derived)         — standalone
Pass 2 (Gleam emitter dispatchers) — unblocks gitignoring dispatchers in pass 1's tail
Pass 3 (per-op LOC)                — standalone; reads better after Pass 5.1 rename
Pass 4 (emitter dedup)             — standalone
Pass 5 (small wins)                — standalone
Pass 6 (restXml codec gaps)        — standalone; benefits from pass 4 dedup
Pass 7 (kill string concats)       — last; needs the arch passes settled so the
                                     remaining concats are stable refactor targets
```

Suggested order: 1 → 2 → 5.1 (rename) → 3 → 4 → 5.2–4 → 6 → 7.

## Non-goals

- No protocol drops. awsQuery (16 services), ec2Query (1), restXmlWithNamespace stay.
- No service drops.
- Runner depth unchanged: request-side strict, response-side parse-only. Tightening response-case assertions is a future milestone.
- No live-AWS gating changes — Smithy fixtures remain the parity bar.

## Open questions

1. **Endpoint extraction script** — pass 1.4. Need to confirm `endpointRuleSet` / `endpointTests` are present in every model under `vendor/aws-sdk-rust/aws-models/` and that the `jq` shape matches what's currently committed to `test/fixtures/endpoints/`. If not, fall back to keeping endpoint fixtures tracked (loses ~34 kLOC of the win).
2. **Smithy CLI in CI** — pass 1.5. `scripts/build-protocol-test-asts.sh` requires `.tools/smithy-cli-darwin-aarch64/bin/smithy` — currently a manual download. CI needs to fetch it (cache by SHA). Linux runner needs the linux build.
3. **Pass 2 dispatcher output parity** — must match today's Python output exactly, or the runner needs updates. Verify with `diff` over a regenerated dispatcher set before deleting the Python script.
