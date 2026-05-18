# Next steps — distance to a usable Gleam AWS SDK

Status snapshot aligned with `docs/v0.1-plan.md`. The plan defines v0.1
as: a Gleam binary that, in Lambda / ECS Fargate / EC2 / EKS, resolves
credentials + region + endpoint with zero configuration and calls
DynamoDB `GetItem` and S3 `GetObject` end-to-end with typed inputs,
outputs, and per-operation error sums. Items beyond that surface are
explicitly listed in the plan's "Out of scope for v0.1" section and
deferred to v0.2.

## Where each v0.1 milestone stands

| Milestone | Built | Wired into the user-facing client | Gap |
|---|---|---|---|
| M0 — scaffold | ✅ | n/a | — |
| M1 — SigV4 | ✅ | ✅ | — |
| M2 — credential providers + chain | ✅ (env, profile, SSO, web-identity, ECS, IMDS, process) | ✅ via `default_chain` | refresh-actor not on the hot path; STS-AssumeRole combinator missing |
| M3 — region + endpoints | ✅ both modules exist | ❌ — `runtime.default_config` uses static `<prefix>.<region>.amazonaws.com`; `endpoints.resolve` has zero callers; `region.resolve` not auto-called by `service.new(region:)` | wire-in pending |
| M4 — retry | ✅ standard + adaptive in `src/aws/retry.gleam` | ❌ — `runtime.invoke` doesn't call the retry loop | wire-in pending |
| M5 — protocol codecs | ✅ awsJson1_0 / 1_1 / restJson1 / restXml / awsQuery / ec2Query | ✅ | restJson1 has ~30 edge-case failures; restXml + awsQuery + ec2Query have decoder gaps |
| M6 — typed DynamoDB + S3 | ✅ (full services, not just GetItem/GetObject) | ✅ | response-header binding + restXml error extraction missing |
| M7 — codegen | ✅ 5 protocols | ✅ | only DynamoDB + S3 actually generated |

## To close v0.1 (within plan scope)

Ordered cheapest-win first. Each closes a specific milestone gap from
the table above.

1. **Wire retry into `runtime.invoke`** — `src/aws/retry.gleam`
   already implements `standard()` / `adaptive()` plus full-jitter
   backoff per the plan's M4. The runtime just doesn't call it.
   Should be a small change to `runtime.invoke` to loop via
   `retry.with_retry(send, strategy)`. Closes M4.

2. **Wire `endpoints.resolve` + per-service ruleset bundling** —
   `src/aws/endpoints.gleam` parses and evaluates Smithy
   `endpoint-rule-set-1.json` correctly (passes vendored
   `endpoint-tests-1.json` cases). Today no service uses it.
   Need: (a) embed each service's ruleset at codegen time, (b)
   thread the result into `runtime.invoke`, (c) expose `with_*`
   builders for ruleset inputs (`bucket`, `useFips`, `useDualStack`,
   `forcePathStyle` for S3; equivalent on others). Closes M3 and the
   plan's scope-concern #5.

3. **Auto-resolve region when caller omits it** — `region.resolve()`
   walks env → profile → IMDS already. Add `service.new()` overload
   (no region arg) that calls it. Lambda's `AWS_REGION` env var then
   "just works" with no caller code. Closes the plan's
   "zero-config in each environment" rider on M2.

4. **Use the credentials cache on the hot path** —
   `src/aws/internal/credentials_cache.gleam` implements the M2
   refresh actor (coalesces concurrent fetches, refreshes ahead of
   expiry). `runtime.invoke` currently calls `credentials.fetch(provider)`
   directly, bypassing the cache. Mint each `Client` with a
   long-lived cache subject and read from it. Closes M2.

5. **restXml error extraction** —
   `<Error><Code>NoSuchBucket</Code>...</Error>` currently lands in
   `<Op>ErrorUnknown`. The runtime's `extract_error_type` only reads
   `x-amzn-errortype` and a JSON `__type`/`code` field. Add the XML
   path. Closes the M6-audit gap; required for typed S3 errors.

6. **Response header binding in the codegen** — `@httpHeader` /
   `@httpResponseCode` output members currently decode to `None`.
   The runtime already passes headers + status into
   `parse_<op>_response`; the generator just doesn't emit code that
   reads them. Required for S3 outputs to carry `ETag`, `VersionId`,
   `Content-Length`, `Last-Modified`, `x-amz-server-side-encryption`,
   etc. Closes the M6-audit gap.

7. **STS AssumeRole helper for `source_profile` / `role_arn`** —
   Plan scope-concern #6 calls for a minimal
   `src/aws/internal/providers/sts.gleam` covering `AssumeRole` +
   `AssumeRoleWithWebIdentity` so the profile parser's
   `source_profile` chains resolve. The web-identity flow is in
   `sts_web_identity.gleam`; adding plain `AssumeRole` makes the
   profile parser's role-chain support real.

8. **`@xmlFlattened` lists + struct-member `@xmlName`** — Some S3
   response shapes use flattened lists or per-member XML name
   overrides. Both are flagged in M6-audit; both block some S3 ops
   from decoding cleanly.

When items 1–8 are done the v0.1 plan's gate is met: a binary deployed
to Lambda / ECS / EC2 / EKS can call DynamoDB and S3 (within v0.1's
non-streaming bound) with zero configuration, typed errors, retries,
and proper endpoint resolution.

## v0.2 candidates (explicitly out of v0.1)

These are listed in `docs/v0.1-plan.md` § "Out of scope for v0.1".
They're the bulk of what turns the SDK into a general-purpose AWS
client beyond DynamoDB + S3 mainline.

1. **Streaming bodies** (`@streaming`). Required for `S3.GetObject`
   of large objects without OOMing the process, all of
   `S3.PutObject`, S3 multipart, Bedrock streaming responses,
   Kinesis. Runtime needs streaming HTTP send + recv; emitter then
   unskips `@streaming` shapes. v0.1 plan scope-concern #3 says
   GetObject buffers to `BitArray` for v0.1.

2. **Codegen-driven additional services** — DONE (2026-05-18).
   `./scripts/regen.sh` now auto-discovers every `awsJson1_0 /
   awsJson1_1 / restJson1 / restXml` service in
   `vendor/aws-sdk-rust/aws-models/` (~409 services) and runs the
   codegen against each. All generate, format, and compile cleanly
   under `./scripts/test.sh` (which sets `ERL_FLAGS="+t 4194304"`
   to lift Erlang's default 1M-atom ceiling — the generated
   service modules together allocate several million atoms).
   `awsQuery` / `ec2Query` / `rpcv2Cbor` services are intentionally
   skipped until their body codecs land. Per-protocol smoke tests
   (`test/service_smoke_test.gleam`) exercise SQS / CloudWatch Logs
   / EKS end-to-end through SigV4 + the embedded rule sets, on top
   of the existing DynamoDB / S3 endpoint-test coverage.

3. **Paginators** — Smithy `@paginated`. Without these callers loop
   on `next_token` by hand. High-value targets: `ListObjects`,
   DynamoDB `Query` / `Scan`, `ListFunctions`.

4. **Waiters** — `@waitable`. Common needs: `bucket_exists`,
   `table_active`, `function_active`.

5. **Event streams** — `@streaming` on unions. DynamoDB Streams,
   Kinesis, S3 Select, Bedrock `invoke-with-response-stream`.

6. **S3 transfer manager / multipart upload** — built on streaming.

7. **Presigned URLs** — the SigV4 query-string variant.

8. **SigV4a** — multi-region signing for S3 MRAP.

9. **rpcv2Cbor protocol** — needed by a few newer services.

10. **Endpoint ruleset coverage beyond S3 + DynamoDB** — every
    service ships its own `endpoint-rule-set-1.json`. v0.1 wires the
    evaluator (item 2 above); v0.2 bundles all ~300 rulesets at
    codegen time and exposes their parameters via per-service
    builders.

11. **restJson1 edge cases** — `@document`, `@mediaType` streaming,
    fractional-second timestamp headers, `@xmlName` on unions
    (~30 failing protocol tests). v0.1 plan scope-concern #2
    explicitly suggests dropping restJson1 from the M5 gate.

12. **Timestamp fractional seconds + offsets** — currently `Int`
    epoch seconds. CloudWatch / EventBridge / metric APIs lose
    sub-second precision.

13. **HTTP/2** — for services that need it.

14. **JavaScript target** — explicitly out per the plan and
    `CLAUDE.md`.

## Suggested execution order

The cheapest wins for the largest user-visible improvement, in order:

1. Wire retry (v0.1 item 1) — hours, transforms reliability.
2. Wire endpoints + auto-region (v0.1 items 2, 3) — small surface
   change; "zero-config in Lambda" becomes real.
3. Credentials cache on hot path (v0.1 item 4) — eliminates
   per-request creds-fetch.
4. Response header binding + restXml error extraction (v0.1 items 5,
   6) — S3 becomes meaningfully usable.
5. STS AssumeRole (v0.1 item 7) — unblocks cross-account profiles.
6. `@xmlFlattened` + struct-member `@xmlName` (v0.1 item 8) —
   closes the M6-audit XML decoder gaps.
7. Streaming bodies (v0.2 item 1) — gates real-world S3 use.
8. Generate two or three more services (v0.2 item 2) — proves the
   codegen claim end-to-end on services that aren't restXml.

After that, the v0.2 long tail (paginators, waiters, event streams,
SigV4a, etc.) becomes the productisation backlog.

## Related working docs

- `docs/v0.1-plan.md` — the authoritative milestone gate definitions.
- `docs/audits/m5.md` — protocol codec parity vs aws-sdk-rust.
- `docs/audits/m6.md` — typed-client parity vs aws-sdk-rust + the
  "Known gaps" list this document references.
- `fixes.md` — small in-codegen cleanups left after the
  `rest_request` extraction. Orthogonal to the items here.
