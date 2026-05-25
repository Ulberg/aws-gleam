# Planned architectural changes

Three changes to the SDK's shape, surfaced by a design review against [`ryanmiville/aws_api`](https://github.com/ryanmiville/aws_api) and the AWS Rust SDK. The project is in alpha — breaking the public API to land these is acceptable.

Two further candidates were considered and intentionally deferred. They are listed at the end.

## 1. Separate request-building from request-execution

### What

Each operation grows a sibling that stops at "request built and signed" instead of going through dispatch, retry, and parsing. The existing high-level call stays. The sibling exposes the signed request as a plain value the caller can route, log, mock, or hand off.

### Why

Today, "build a SigV4-signed AWS request" and "execute a signed request and parse the response" are one thing, both hidden behind `runtime.invoke`. The Rust SDK keeps these separable inside its orchestrator (the `Operation` carries `serializer` / `deserializer` closures the orchestrator drives). Ryan's library exposes only the build half.

Bundling closes off legitimate uses:

- Testing signing without HTTP mocks.
- Per-call HTTP transport — custom dispatchers, queues, batch processors.
- Pre-built requests handed off to a worker pool.
- Inspecting or modifying the outgoing request before send.

Purely additive. Existing callers see no change.

## 2. Make the credentials cache actor opt-in

### What

`new()` returns a `Client` with no actor lifecycle attached. Long-running services opt into the per-client credentials cache actor explicitly.

### Why

The README currently warns: *"Long-running processes that build many clients should release the per-client cache actor on teardown to avoid process leaks."* That warning exists because we made the wrong thing the default.

For the dominant short-lived use cases — Lambda, scripts, batch jobs, one-off CLI calls — the cache actor is overkill, and forgetting `shutdown()` leaks a process. For Phoenix-style long-running services, the cache is the right choice. Today everyone pays the lifecycle cost; only the second group benefits.

Inverting the default makes the simple case simple. Services that benefit from coalesced and cached credential fetches opt in. The implicit lifecycle contract on `new()` disappears.

Breaking change. Acceptable in alpha.

## 3. Extract SigV4 into its own hex package

### What

The signer — SigV4, SigV4a, the deterministic ECDSA nonce code, and their test fixtures — moves out of the SDK runtime and becomes a standalone hex package. The runtime depends on it as an external library, like any other.

### Why

SigV4 is not specific to this SDK. Any Gleam codebase talking to AWS-compatible services needs it — including [`ryanmiville/aws_api`](https://github.com/ryanmiville/aws_api) and any future entrant. Today we duplicate work that [`lpil/aws4_request`](https://github.com/lpil/aws4_request) already does for SigV4. Lpil's library does not cover SigV4a; ours does, with 38 AWS C-Auth vectors green across canonical-request, string-to-sign, and authorization-header stages, plus the aws-signing-test-suite v4a corpus pinned byte-for-byte through canonical request and string-to-sign.

Extracting our signer:

- Shrinks the SDK runtime's surface area and the concerns it owns.
- Forces a clean public boundary, separating SDK runtime concerns from a reusable primitive.
- Ships a well-tested SigV4 + SigV4a library to the Gleam ecosystem.
- Leaves convergence with `aws4_request` as a downstream choice — not a prerequisite for the extraction itself.

Adopting `aws4_request` is a separate question and an informational one. The extraction is the design change; whether we then drop our SigV4 in favour of lpil's library is decided on the merits later, with no architectural coupling either way.

## Deferred

### Raw-bytes operation companion

Generating a second per-operation companion that takes a `BitArray` body and skips the typed codecs would let users with their own AttributeValue mappers or domain serializers ride the credentials / signing / retry stack without paying the codec tax. The typed pitch — typed input, typed output, per-operation error sums — is the SDK's headline value. Building a parallel raw API speculatively, without a real user saying *"I have my own codec layer and just want signing,"* is unjustified surface area. Revisit on demand.

### Codegen consolidation

Our codegen is ~16K LOC across 24 files versus Ryan's ~1.2K across 3. Most of that difference is genuine work — we generate vastly more (typed inputs, typed outputs, per-operation error sums, per-shape bidirectional codecs, Smithy endpoint rule sets, paginators, waiters, streaming variants). The structure has accumulated splits (`member_order`, `error_dispatch`, `service_customizations`, …) that could plausibly be consolidated, but consolidation is internal churn with no user-visible win. Revisit only if a maintenance burden becomes concrete.
