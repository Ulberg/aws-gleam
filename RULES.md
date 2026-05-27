# Rules

Non-negotiable patterns. The reasoning is in [PHILOSOPHY.md](PHILOSOPHY.md).

## Target & runtime
- Erlang target only; no JavaScript target.
- OTP-native: long-lived state (credentials cache, retry rate-limiter) lives in `gleam_otp` actors — not module-level refs or hand-written gen_servers.
- `Client(service)` is threaded explicitly through every operation. No globals, no process dictionary, no named registries for SDK state.

## Code
- `use` for `Result`/`Option` chains; never a nested `case` ladder where `use` reads the same.
- One error sum type per operation — its Smithy `errors` plus a `Transport` variant. No global `AwsError`.
- `Option(T)` for every optional field. Record constructors with named arguments + `*_default` helpers — not builder chains.
- `gleam format` after every edit; `gleam test` is the test command.
- A doc comment on every `pub` type and function. Internal modules under `aws/internal/`.
- Comments only when the *why* isn't visible. Never narrate *what* the code does.

## API
- The default path is the most ergonomic one: `new()` auto-resolves region + the credential chain. Fine-grained control is opt-in via `new_with(settings, endpoint_params)` — customer config on `config.Settings`, AWS rule-set params on the per-service `EndpointParams`, no builder chains — never required.
- Absorb maintainer pain rather than push it to the consumer — unless the trade-off is genuinely unreasonable.

## Gleam idioms
- **Opaque types for invariants.** A type with a construction invariant (e.g. `Client`) is `opaque`, built by a smart constructor and read via accessors — consumers can't construct or pattern-match it into an invalid state.
- **Parse at the edge; assert invariants inside (negative space).** Untrusted input (HTTP, JSON, env) is parsed into typed values at the boundary, returning a typed `Result` — the public API never crashes the consumer. In the safe interior, encode "this can't happen" with `let assert ... as "why"` rather than an unchecked default; a violation is an SDK bug and *should* crash. `panic`/`let assert` always carry a message and never substitute for a recoverable error.
- **Loops are tail-recursive.** Long-running recursion (the runtime loop, list folds) calls itself in tail position so the stack can't grow; keep the accumulator behind a public wrapper.
- **Relocate published API with `@deprecated`, don't delete.** A moved or renamed `pub` item keeps a thin deprecated alias delegating to the new home until a major bump.
- **Label shorthand** (`Foo(name:)`) where the variable already matches the label; prefer stdlib `result`/`option`/`list` combinators over hand-rolled equivalents.

## Process
- TDD: red → green → refactor. Write the test (the goal) before the implementation.
- Before non-trivial work, answer "How does the AWS Rust SDK do this?" (then aws-beam). Mirror the reference.
- Verify against AWS's own vectors; never invent fixtures. SigV4 + Smithy protocol tests live under `test/fixtures/`.
- A skip or suppression must state its real reason — not "needs customization" standing in for "not done."
- Record debt where it lives (`HACK.md`): location + production impact + fix sketch. No undocumented hacks.
- "Done" is claimed only when unequivocally true.

## Codegen
- Services are generated from `vendor/aws-sdk-rust/aws-models/*.json` via `scripts/regen.sh`; generated `src` is not committed.
- Don't hand-edit generated output — change the codegen and regenerate.
- The request-builder layer and the typed SDK layer stay separate — the SDK depends on the builder, not the reverse.

## Logging
Mechanism: a leveled logger (OTP `logger`); `debug` is gated by the configured level.
- `error` — unrecoverable, operator-must-see: credential chain exhausted, retries exhausted, Runtime API fatal. Default-on, sparse.
- `warning` — notable but recovered: a retry fired, a chain provider missed, a deprecation. Default-on, sparing.
- `debug` — the firehose, both paths: every request + resolved endpoint + response status, each retry and backoff, each credential provider tried, cache hit/miss, and full per-attempt error detail.
- Nothing at `info` or above on the happy path. Quiet by default; `debug` is opt-in.
