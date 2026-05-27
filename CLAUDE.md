# Working notes — AWS SDK for Gleam

Conventions are in @RULES.md; the reasoning is in @PHILOSOPHY.md. Read both first — they are the source of truth. This file holds only the repo-specific operational detail and AI-assistant tooling that doesn't belong in either.

## Reference material — mirror the implementation, don't invent
PHILOSOPHY's "mirror the reference" rule, operationally: for any non-trivial design question, consult a real implementation rather than guessing from training data. Where these graph MCP servers are wired, query them; otherwise read the source directly.
- `graph-aws-sdk-rust` — typed SDK runtime (credential types, runtime, smithy runtime). The closest analog; check it first.
- `graph-aws-sdk-go-v2` — the most mature credential chain + config resolution.
- `graph-smithy-rs` — codegen reference (typed SDKs from Smithy models).
- `graph-aws-codegen` (Elixir BEAM codegen), `graph-aws-erlang` (generated BEAM output).
- `graph-ryan-codegen`, `graph-ryan-aws-api` — prior Gleam attempts; "what's been tried, and where it stopped."

Source fallbacks, always reachable: `github.com/awslabs/aws-sdk-rust`, `github.com/aws-beam`.

## Build, test, regen
- `gleam test` is the test command — run it via `scripts/test.sh`, which bumps the BEAM atom table (generating ~409 services creates millions of atoms; the default 1M ceiling crashes the compile).
- Generated service code is NOT committed. Regenerate from `vendor/aws-sdk-rust/aws-models/*.json` with `scripts/regen.sh [service…]` (no args = full run).
- Fixtures live on disk — don't invent them: SigV4 vectors under `test/fixtures/aws-c-auth/tests/aws-sig-v4-test-suite/`, Smithy protocol tests under `test/fixtures/protocol-tests/`.
- LocalStack-backed e2e (DynamoDB `GetItem`, S3 `GetObject`) and the live smoke suite (`--include live`, needs `AWS_PROFILE`) are gated — not run on every commit.

## Tooling
- Use the Gleam LSP (wired via the `gleam@claude-code-lsps` plugin) for navigation, references, and types in this codebase — don't grep when the LSP can answer.
