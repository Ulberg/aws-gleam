# AWS SDK for Gleam — project conventions

## Target and runtime
- Erlang target only. No JavaScript target. `gleam.toml` has `target = "erlang"`.
- OTP-native. Long-lived state (credentials, retry rate limiter) lives in `gleam_otp` actors, not in module-level mutable refs or FFI'd `gen_server`s.
- The `Client(service)` value is threaded explicitly through every operation. No implicit globals, no process dictionary, no named registries for SDK state.

## Code style
- Use `use` for `Result` and `Option` chains. Never write nested `case` ladders when `use` expresses the same thing.
- One error sum type per operation, generated from the Smithy `errors` list for that operation plus a `Transport(TransportError)` variant. No global `AwsError` type.
- `Option(T)` for every optional field. Builder-style APIs are not idiomatic Gleam — prefer record constructors with named arguments and `*_with_defaults` helpers where ergonomics demand it.
- `gleam format` after every edit. `gleam test` is the canonical test command.
- Public API doc comments on every `pub` function and type. Internal modules go under `aws/internal/`.

## Verification — non-negotiable
Tests must pass before any milestone is considered done.
- SigV4 signing: AWS official test vectors under `test/fixtures/aws-c-auth/tests/aws-sig-v4-test-suite/`. Every canonical-request, string-to-sign, and authorization-header step must match.
- Protocol codecs: Smithy compliance fixtures under `test/fixtures/protocol-tests/`. Each `@httpRequestTests` and `@httpResponseTests` case must round-trip.
- Credential providers: unit tests per provider with mocked HTTP for IMDS/ECS endpoints. Chain integration test asserts precedence order.
- End-to-end: LocalStack-backed tests for DynamoDB `GetItem` and S3 `GetObject`, spun up via `testcontainers` from `gleam test`.
- Live AWS smoke suite is gated on `--include live` and `AWS_PROFILE` being set. Not run on every commit.

## Reference material — read from the graph MCP servers, do not invent
For any non-trivial design question, query the relevant graph rather than guessing from training data:
- `graph-aws-sdk-rust` — typed SDK runtime reference (credential types, runtime, smithy runtime). Closest analog to what we're building.
- `graph-aws-sdk-go-v2` — credential chain and config resolution reference. The most mature implementation of the chain.
- `graph-smithy-rs` — codegen reference for generating typed SDKs from Smithy models.
- `graph-aws-codegen` — existing BEAM-targeted codegen, Elixir.
- `graph-aws-erlang` — generated BEAM output, dynamically typed.
- `graph-ryan-codegen` and `graph-ryan-aws-api` — existing Gleam attempts, prior art. Useful for "what's been tried and where did it stop."

When in doubt about how something works in real AWS SDKs, query the Rust or Go graph first.

## Local Gleam codebase
- Use the Gleam LSP (already wired via the `gleam@claude-code-lsps` plugin) for navigation, references, and type information within this codebase. Don't grep when the LSP can answer.
- Once the local codebase grows past a few hundred lines, it will also be graphify-able via the in-progress Gleam mapper.

## What not to do
- Do not FFI to `aws_credentials` for the chain composition. Individual providers may shell out to OS-level pieces (IMDS HTTP, file reads). The chain itself is Gleam.
- Do not invent test fixtures. SigV4 vectors and Smithy protocol tests both live on disk under `test/fixtures/`.
- Do not collapse the request-builder layer and the typed SDK layer. They are separate concerns; the SDK depends on the builder, not the other way around.
- Do not generate code in milestone 1–6. Codegen is milestone 7, and only after the hand-written version of one service has stabilized.
