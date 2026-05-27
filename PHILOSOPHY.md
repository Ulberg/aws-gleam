# Philosophy

The "why" behind the project. The enforceable patterns are in [RULES.md](RULES.md).

## The aim
A full AWS SDK for Gleam that feels first-party:
- **Every service, from its Smithy model** — all operations, each usable in full, per spec.
- **Runs where the AWS SDKs run** — locally and in the cloud, the Lambda custom runtime included.
- **Compliance is proven, not claimed** — generated code is tested against AWS's own SigV4 and Smithy protocol-test vectors. A service "supports" an operation only when a vector says so.

## Gleam-first, Erlang/Elixir-second
The code is written in Gleam and exists to let Gleam run in AWS environments. Reach for Erlang/Elixir FFI only where Gleam can't express the thing (crypto, OS, BEAM primitives); everything above that is pure Gleam.

## Least-intrusive for the consumer
We absorb maintainer pain so users don't feel it. The default is the most ergonomic path; finer control is always available but never required.
- Default: `<service>.new()` — region and the credential chain resolve themselves, zero config.
- Opt-in: `<service>.new_with(settings, endpoint_params)` — customer config (region, credentials, endpoint, retry, transports, SigV4a) on the shared `config.Settings`, AWS endpoint-rule-set params on the per-service typed `EndpointParams`, each spread off its defaults. Never a builder chain.

The only thing that outranks "make it easy for the consumer" is a trade-off that would be genuinely unreasonable to put on maintainers.

## Mirror the reference; don't invent
Before any non-trivial work the first question is **"How does the AWS Rust SDK do this?"** — then "How does the aws-beam org do this?". They've already found good shapes; stay close to them when uncertain instead of home-brewing. A customization mirrors a real Rust interceptor, not a guess.

## TDD — red, green, refactor
The first move on almost any task is to stand up the verification loop: express the goal as failing tests, make them pass, then simplify to the thinnest thing that holds. Establishing that loop matters more than the first cut of the code.

## Negative-space programming
Encode the invariants you believe hold — don't silently assume them. When a value could in principle be `Error`/`None` but you're convinced a path can't reach that, write `let assert ... as "why"` there instead of unwrapping with a default: a wrong belief then crashes loudly at the exact spot rather than propagating corrupt data. The assertion is a checkable record of your reasoning — and on the BEAM a loud crash is a feature, not a flaw: the supervisor restarts and the fault surfaces, instead of bad data spreading.

Its strongest form is **parse, don't validate**: do the fallible work once, at the edge, turning untrusted input into types that can't be wrong, then trust them everywhere inside. That splits the system in two:
- **Unsafe boundary** — HTTP responses, JSON events, the env, the Runtime API — parsed into typed values, returning a typed `Result`/error sum. The public API never crashes the consumer.
- **Safe interior** — operates on those parsed values and asserts its invariants, because a violation there is an SDK bug to surface, not a runtime condition to handle.

## Lean on the language's grain
Use Gleam's tools — exhaustive `case`, `use`, opaque types, the type system — to make illegal states unrepresentable and intent obvious. Reach for an advanced feature only when it makes the code simpler to read or maintain — never to show off or to shave lines.

## Simplicity, for the human who inherits this
Architect and write so a future maintainer can take over. The bar: good code makes its intent near-obvious — so comments are rare, reserved for the *why* the code can't show (a constraint, an invariant, a workaround). The SDK's depth makes "obvious" an aspiration, not always reachable; aim for it regardless.

## Abstraction handles complexity — it is not code golf
Reuse aggressively, but an abstraction must earn its keep by taming real complexity. A leaky abstraction is fine when the domain genuinely leaks; a premature or obfuscating one is not. Building one is nearly free here, so the failure mode is *over*-abstraction that hides the code — not duplication. Abstract to manage complexity, never to shrink the line count.

## Honesty over a tidy-looking ledger
The recurring failure mode isn't capability — it's the pull to look finished. Guard against it:
- **A suppression states its real reason.** "Needs SDK customization" when the truth is "not done yet" launders deferral as a decision.
- **Visible debt is fine; hidden debt rots.** A documented hack — location, production impact, fix sketch — is an honest liability. Undocumented, it's a trap for the next person.
- **A green test is evidence, not proof.** Know exactly what the harness asserts; a path-only protocol check can pass a request that ships broken headers.
- **Reachability reveals truth.** A skipped / no-dispatcher case is an unasked question, not a pass. Wiring it up turns masked bugs into honest failures.
- **Don't game your own exit condition.** Claim "done" only when it is unequivocally true.

## Logging — quiet by default, a firehose on demand
The SDK says nothing on the happy path and only what an operator must see when something fails; switch on `debug` and it narrates both paths in full. The honesty principle applied to runtime behaviour: when asked, the error paths tell the whole truth. (Exact levels in [RULES.md](RULES.md).)
