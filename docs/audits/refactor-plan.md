# Refactor plan — post-`feat/next-steps` review

Written after the final review on `feat/next-steps` closed every
entry in `HACK.md` (1-4) and landed the smoke-test lambdas. Scope is
**code shape**, not feature work: simplifications, duplication
removal, and the few places where the codebase has drifted away from
the Rust SDK's published patterns. The Rust SDK
(`vendor/aws-sdk-rust/`) is the canonical reference because it is
the most direct analogue — same Smithy models, same runtime
concerns, same wire format. The graph-aws-sdk-rust MCP backs the
specific pointers below.

The plan is intentionally **non-blocking**. Every item below is
optional polish — the SDK ships correct behaviour today.

## 1. Distill the per-op invoker into one renderer

**Where:** `codegen/src/codegen/client.gleam::invoke_fn`.

The function currently `case`-fans on `host_prefix, context_params`
to pick between `runtime.invoke`,
`runtime.invoke_with_endpoint_params`, and
`runtime.invoke_with_endpoint_params_and_host_prefix`. Three runtime
entry points isn't right shape: the host-prefix-aware one is a
strict superset of the others, and the runtime already tolerates an
empty params dict and an `option.None` host prefix.

**Fix:** keep one entry point `runtime.invoke_with_endpoint_params`
(rename to `runtime.invoke`, the existing un-suffixed name takes the
extra args). All three call sites in the codegen collapse to
`Call(Ident("runtime.invoke"), [config, params_expr, host_expr,
build_fn, parse_fn])` with `params_expr = dict.new()` and
`host_expr = option.None` as defaults when no context params /
host prefix are declared.

Saves ~40 lines in `client.gleam` and the runtime, and makes
adding the next per-op concern (e.g. operation-name as a sigv4
config, telemetry attributes) a single-site change instead of
three.

Rust SDK parallel: `client/orchestrator.rs::invoke()` takes a single
`Operation` value carrying every per-op concern as `ConfigBag`
attachments. We don't need the full ConfigBag pattern, but we do
want a single entry point that takes a single rich value.

## 2. Hoist the per-protocol `emit_invoke` shape

**Where:** `codegen/src/codegen/awsjson.gleam::emit_invoke`,
`codegen/src/codegen/restjson.gleam::emit_invoke`,
`codegen/src/codegen/restxml.gleam::emit_invoke`.

All three now follow identical structure:

```
let context_params = trait_helpers.context_params_for_op_by_id(...)
let base = client.invoke_fn(...)
let host_prefix_validator = ...
let endpoint_params_builder = ...
let streaming_blob_items = ...
let event_stream_items = ...
code.render(Module(items: list.flatten([...])))
```

The only protocol-specific piece is the doc-comment header
generation. Lift the whole shape into `client.gleam::emit_op_module`
and have each protocol emitter call it with a `doc` string. Removes
~120 lines of triplicated dispatch. Each addition above
("Operations whose output carries…") would otherwise need to land
three times.

## 3. Collapse `dict.has_key + dict.insert` guards

**Where:** `src/aws/internal/codec/rest.gleam` —
`with_glacier_tree_hash_headers`, plus several call sites that the
codegen emits.

After this branch, `rest.set_default_header(headers, name, value)`
encapsulates the insert-when-absent pattern. The tree-hash helper
still inlines the same `case dict.has_key { True -> headers; False
-> dict.insert(...) }` four times. Rewrite using
`set_default_header`:

```
headers
|> set_default_header("X-Amz-Sha256-Tree-Hash", tree_hash)
|> set_default_header("X-Amz-Content-Sha256", content_sha256)
```

Same pattern at the codegen emit site for the `@httpHeader`-bound
member-with-default case. Strictly cosmetic; saves a few lines and
threads the insert-when-absent semantics through one named helper.

## 4. Generalise `omit_uri_labels` from `@contextParam`

**Where:** `codegen/src/codegen/service_customizations.gleam` for
the hardcoded S3 entry, `codegen/src/codegen/rest_request.gleam`
for the consumer.

Today `omit_uri_labels` is a per-service hardcoded list (`["Bucket"]`
for S3, empty elsewhere). The signal that a URI label should be
stripped is "this member carries a `smithy.rules#contextParam`" —
that's exactly the data we already extract via
`trait_helpers.context_param_bindings`. The Rust SDK derives the
same decision from the same trait, no hardcoded list.

**Fix:** drop `omit_uri_labels` from `ServiceCustomization`; derive
it on the fly from `context_param_bindings(in_members) |>
list.map(.member_pascal)`. Anywhere the rest emitter currently asks
"should I strip `{X}`?", it instead asks "does input member X carry
`@contextParam`?".

Net effect: S3 stays correct, and any future service that mirrors
the S3 pattern (e.g. S3 Outposts, S3 Control) gets the right
behaviour without touching `service_customizations.gleam`.

## 5. Move `runtime.invoke` retry construction inline

**Where:** `src/aws/internal/client/runtime.gleam` lines around the
`invoke` body that builds `retry.with_retry(config.http_send,
config.retry_strategy)` per call.

Per-call closure construction is wasted work — the strategy lives
on the client config for the lifetime of the client. Pre-bind it
once at `Client` construction time and cache on
`ClientConfig.bound_send`. Cuts ~3 allocations per request.

Rust SDK parallel: `RuntimeComponents` carries the resolved send
closure as a `SharedHttpClient` attached to the client config,
constructed once at `aws_config::from_env()` time.

## 6. Fold the four `os_process` callers into one

**Where:** `src/aws/internal/os_process.gleam` is a 10-line
two-fn shim; its callers are spread across
`src/aws/internal/providers/{process,sso}.gleam` and
`src/aws/credentials.gleam` (the `aws configure
export-credentials` path).

Each caller invokes `os_process.run(...)` and parses the JSON
output identically. Inline the shim into a single
`internal/aws_cli.gleam` that exposes
`run_credential_command(cmd, args) -> Result(StaticCredentials,
ProcessError)`, hiding the JSON parse + the shape mapping. Two
callers shrink to one-liners; the third (SSO legacy path) drops a
parser duplicate.

## 7. Drop the `actor_lifecycle` indirection

**Where:** `src/aws/internal/actor_lifecycle.gleam` (51 lines).

Wraps `gleam_otp.actor` start / stop with one extra layer. Both
`credentials_cache.gleam` and `retry/rate_limiter.gleam` are the
only callers; they each carry their own typed start fn, so the
indirection doesn't actually de-duplicate. Either:

* Inline back into each caller and delete the file. Two ~5-line
  diffs.
* Or keep it but rename to `internal/actor_helper` and add the one
  helper that callers DO duplicate (the `shutdown_sync` pattern
  that waits for the actor to drain).

The current shape is the worst-of-both: adds a file without
removing any duplication.

## 8. Lift the codegen's per-emitter `OpSpec` into one place

**Where:** each of `awsjson.gleam`, `restjson.gleam`,
`restxml.gleam` declares its own `OpSpec` record type. The fields
differ in 1-2 protocol-specific knobs (awsJson has
`source_service_local`, `query_compatible`; rest* don't) but the
rest is identical.

**Fix:** define `pub type OpSpec` in `codegen/op_spec.gleam` (new
module) with **every** field; protocol emitters set their unused
fields to `None`/`""`. Same shape across the three emitters means
shared `extract_*` helpers (currently three near-clones) collapse
to one.

Plus: `extract_host_prefix_info` exists in two of the three files,
verbatim. That alone is ~25 lines * 2.

## 9. Streamline credential chain construction

**Where:** `src/aws/credentials.gleam::default_chain` and
`default_chain_with`.

Both are large `case`-fan-outs picking the first non-`NotConfigured`
provider. The Rust SDK uses a `CredentialsProviderChain::first_try`
fold over a list of providers, with each provider's error
propagating through a shared `try_next` helper.

**Fix:** introduce
`fn try_chain(providers: List(fn() -> Result(Credentials, Err))) ->
Result(Credentials, Err)` that folds with the
`NotConfigured -> next; other -> propagate` rule. The two
`default_chain` functions then become a list-literal each.

Saves ~80 lines and adds the missing chain ordering assertions
(today the alphabetical visual order of the case-arms is the only
documentation of precedence).

## 10. Drop dead `omit_uri_labels` once #4 lands

Stale-flag cleanup that becomes a no-op once #4 is done. Listed
separately so it doesn't get forgotten.

---

## Architectural review (Rust SDK parallels)

The Rust SDK divides its runtime into three crates and the codegen
mirrors the split. We're a single-crate (single-target) project so
the equivalents would be:

| Rust crate | Gleam analogue today | Health |
|---|---|---|
| `aws-credential-types` | `src/aws/credentials.gleam` + `src/aws/internal/credentials_cache.gleam` + `src/aws/internal/providers/*` | Good. The 8-stage chain matches Rust's `DefaultProviderChain` order. |
| `aws-runtime` (interceptors, sigv4 wiring) | `src/aws/internal/client/runtime.gleam` + `src/aws/internal/sigv4*.gleam` | OK. We don't have the `Interceptor` trait; per-op concerns are threaded through `invoke_with_endpoint_params*` instead. See refactor #1. |
| `aws-smithy-runtime-api` (types) | `src/aws/streaming.gleam`, `src/aws/endpoints.gleam`, `src/aws/retry.gleam` | Good. Types are flat, no orchestration leak. |
| `aws-smithy-runtime` (orchestrator) | The body of `runtime.invoke` | Lean by comparison — we don't have `try_attempt` / `try_op` / `finally_op` phase split. Acceptable for v0.2 scope; revisit if/when interceptors land. |
| Codegen | `codegen/src/codegen/` | Good. The protocol-emitter split matches Rust's per-protocol code generators in `smithy-rs/codegen-client/src/main/kotlin/.../protocol/`. Refactor #2 closes the cross-protocol duplication. |

### What we deliberately don't mirror

* **Interceptors.** Rust runs every per-op concern (UA stamping, MD5,
  tree-hash, request-compression, default headers) as an
  `Intercept` trait implementation, with `BeforeSerialization`,
  `BeforeTransmit`, `ReadAfterResponse` lifecycle hooks. We emit
  them inline in the per-op `build_<op>_request` function. Pros:
  zero runtime indirection, fewer abstractions to learn. Cons: every
  hook lands at codegen time, callers can't slot their own. The
  v0.3 question is whether to add a thin interceptor layer (the
  hook positions in `runtime.invoke` already align with the Rust
  phases) or to keep the codegen-emit model.
* **ConfigBag.** Rust threads request-scoped state through a typed
  HashMap. We use plain function arguments. Same pros/cons as
  above; the boundary is the same — adding an interceptor layer
  necessarily adds a config bag.
* **Identity caching framework.** Rust's `IdentityCache` is
  partitioned by provider so multiple providers in a chain can
  share an in-flight refresh. Ours is one-cache-per-client and
  works fine because we only resolve one provider at a time. If
  multi-provider scenarios show up (e.g. dual SigV4 + Bedrock
  bearer token), we'll need the partitioned cache.

### What we should mirror but don't yet

* **`finally_op` / `finally_attempt`.** Rust runs cleanup hooks
  unconditionally — closes connection on cancellation, etc. We have
  no equivalent. If the host process is killed mid-request the
  outstanding `httpc` request leaks until OTP cleans up. Not a
  correctness issue, but worth tracking.
* **`BehaviorVersion`.** Rust requires clients to declare which
  behaviour version they target so the SDK can opt-in to default
  changes safely. We don't, and probably won't until a v1.0
  release-compat story exists.

---

## How to sequence

If you're picking these up:

* **#3, #6, #10** are pure cleanups — land in any order, single
  commit each.
* **#4** depends on #3 (sets up the pattern); both then prepare
  for #1 (which extends the renderer for the new shape).
* **#2** is a big one; do it last because every other refactor
  reduces the surface that needs lifting.
* **#5, #7, #8, #9** are independent. #9 has the highest test
  coverage cost (touch every chain test).

None of these change wire behaviour. Run `./scripts/test.sh` after
each — protocol-test corpus, endpoint fixture replay, SigV4 vectors
all stay green.
