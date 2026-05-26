# Codegen — rules

Loaded when working under `codegen/`. Project-wide conventions live in [`../RULES.md`](../RULES.md) and [`../PHILOSOPHY.md`](../PHILOSOPHY.md); this is the do/don't list for editing the generator itself.

## Emit through the typed AST
- Build generated source with the `Code` constructors in `src/codegen/code.gleam` (`Fn`, `Call`, `Ident`, `Let`, `Case`, `RecordUpdate`, `Labelled`, `Import`, …) and `code.render`. Don't hand-concatenate source strings.
- `Raw(fragment)` is the escape hatch — reach for it only when no AST node fits, and prefer adding a node over spreading `Raw` through an emitter.
- Add a new generated pattern once, in the emitter — never patch it per-service after the fact.

## Logging
- Code you *emit* logs through the runtime's leveled logger at the levels in [`../RULES.md`](../RULES.md) (Logging) — emit those calls via the AST, not raw strings.
- The codegen's *own* diagnostics are a build-tool concern, not the SDK: `io.println` to stdout/stderr (as in `src/aws_codegen.gleam`) is fine here.

## Verify by regenerating, never by reading output
- After changing an emitter, run `scripts/regen.sh <service>` and the protocol-test suite — compliance is proven against AWS's vectors, not by eyeballing the generated `.gleam`.
- A protocol case with no dispatcher is an unasked question, not a pass.

## Don't
- Don't hand-edit generated output (`services/*/src`, `src/aws/services/`) — change the emitter and regenerate.
- Don't special-case one service inside a shared emitter; per-service quirks go in `src/codegen/service_customizations.gleam`, modelled on a real AWS Rust SDK interceptor.
