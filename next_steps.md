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
| M2 — credential providers + chain | ✅ (env, profile, SSO, web-identity, ECS, IMDS, process) | ✅ via `default_chain` + per-service `credentials_cache` actor on the hot path | profile→AssumeRole auto-chaining (`source_profile` / `role_arn`) still manual via `from_assume_role` |
| M3 — region + endpoints | ✅ both modules exist | ✅ — every generated service embeds its rule set and threads it through `runtime.with_endpoint_rule_set`; `service.new()` auto-calls `region.resolve` | — |
| M4 — retry | ✅ standard + adaptive in `src/aws/retry.gleam` | ✅ — `runtime.invoke` wraps via `retry.with_retry(config.http_send, config.retry_strategy)` | — |
| M5 — protocol codecs | ✅ awsJson1_0 / 1_1 / restJson1 / restXml / awsQuery / ec2Query | ✅ | restJson1 has ~30 edge-case failures; restXml + awsQuery + ec2Query have decoder gaps |
| M6 — typed DynamoDB + S3 | ✅ (full services, not just GetItem/GetObject) | ✅ | response-header binding ✅ (2026-05-19); restXml error extraction ✅ |
| M7 — codegen | ✅ 5 protocols | ✅ | only DynamoDB + S3 actually generated |

## To close v0.1 (within plan scope)

Ordered cheapest-win first. Each closes a specific milestone gap from
the table above.

1. **Wire retry into `runtime.invoke`** — DONE.
   `runtime.invoke` builds `retry.with_retry(send: config.http_send,
   strategy: config.retry_strategy)` and dispatches through that, so
   the standard / adaptive strategy from `ClientConfig.retry_strategy`
   wraps every request. `ClientConfig` defaults to `retry.standard()`;
   callers override via `runtime.with_retry_strategy`.

2. **Wire `endpoints.resolve` + per-service ruleset bundling** —
   DONE. Each generated service module embeds its Smithy
   `endpoint-rule-set-1.json` as a literal string and threads it
   into `ClientConfig` via `runtime.with_endpoint_rule_set`. The
   runtime evaluates it per call with `endpoints.resolve` and merges
   the per-op `endpoint_params` (S3's `Bucket` / `Key` / `CopySource`
   etc. flow in from each op's `invoke_with_endpoint_params` call
   site). `runtime.with_endpoint_param` is the caller-facing knob
   for `useFips` / `useDualStack` / `forcePathStyle` — service-
   specific named wrappers (`with_force_path_style` etc.) are a
   polish item that would just call this with a known key.

3. **Auto-resolve region when caller omits it** — DONE.
   Every generated service's `service.new()` / `service.new_with_*`
   calls `region.resolve(profile: "default")` so callers in Lambda /
   ECS / EC2 hit the env-var / profile / IMDS chain automatically;
   `service.new_with_region` lets callers pin a region explicitly.

4. **Use the credentials cache on the hot path** — DONE.
   Each generated service's `Client` carries a `credentials_cache.Cache`
   minted in `service.new()` via `credentials_cache.start_default(provider)`,
   exposed to the runtime as `credentials_cache.as_provider(cache)`.
   The cache actor coalesces concurrent fetches and refreshes ahead
   of expiry. `shutdown` / `shutdown_sync` helpers per service stop
   the actor cleanly on teardown.

5. **restXml error extraction** — DONE (earlier).
   `runtime.extract_xml_error_code` is wired as the third fallback
   in `error_type_from_body` (after JSON `__type` and `code`). It
   handles both S3-style `<Error><Code>NoSuchBucket</Code>...</Error>`
   and SQS/SNS-style `<ErrorResponse><Error><Code>X</Code>...</Error>...`
   via the same `xml_tag_text` text-scan, no full XML decoder needed.
   Pinned by `test/runtime_test.gleam`'s NoSuchBucket case.

6. **Response header binding in the codegen** — DONE (2026-05-19).
   restxml + restjson1 emitters now extract `@httpHeader` and
   `@httpResponseCode` members on both the no-payload and
   payload-bearing code paths. String / Int / Bool / Enum target
   types are wired via `rest.{string_header, int_header, bool_header,
   enum_header}`; restjson1 also emits a `<enum>_from_wire` helper
   so the enum-header extractor resolves cleanly. Float / Timestamp
   / List targets still fall through to `None` (follow-up work; the
   `header_extractor` match in both protocols is the single place
   to extend). `test/get_object_headers_test.gleam` and
   `test/get_export_headers_test.gleam` regression-pin the
   restxml + restjson1 paths respectively. Closes the M6-audit gap.

7. **STS AssumeRole helper for `source_profile` / `role_arn`** —
   PARTIAL. The minimal `sts.gleam` + `web_identity.gleam` providers
   are in place, and `credentials.from_assume_role` /
   `from_assume_role_with` wrap them as composable providers — so
   programmatic role-chain hops work today. The remaining gap is
   the *automatic* path: `build_credentials_from_lookup` in
   `credentials.gleam` only reads `aws_access_key_id` /
   `aws_secret_access_key` / `aws_session_token` from the profile
   file; it doesn't yet inspect `role_arn` / `source_profile` and
   spin up a chained `from_assume_role` provider transparently.
   That's a small follow-up — add a branch in the profile builder
   that, when `role_arn` is present, walks to the source profile and
   composes via `from_assume_role`.

8. **`@xmlFlattened` lists + struct-member `@xmlName`** — DONE.
   `xml_decode.optional_flat_list` and the restxml codegen
   (`xml.flat_list` / `xml.flat_list_ns`) handle flattened-list
   members; `@xmlName` on struct members is consumed via
   `member.xml_name` in the encoder/decoder emit. Pinned by
   `test/xml_decode_test.gleam::decode_flattened_list_test`
   (S3 `ListObjects` `Contents` + `CommonPrefixes`).

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

3. **Paginators** — DONE (2026-05-18). `aws/pagination.fold` lives
   in the runtime; the codegen emits a `paginate_<op>` wrapper per
   operation carrying `smithy.api#paginated`. The wrapper threads
   the input/output cursor field (`@paginated.inputToken` /
   `outputToken`), projects the items list (`@paginated.items`),
   and folds across pages into a caller-supplied accumulator. The
   cursor type is parametric — DynamoDB's `LastEvaluatedKey`
   (`Dict(String, AttributeValue)`) flows through the same helper
   as a `String` `NextToken`. End-to-end smoke tests in
   `test/paginator_smoke_test.gleam` cover the
   `DynamoDB.ListTables` case (2-page fold + cursor threading).

4. **Waiters** — DONE (2026-05-18). `aws/waiter.wait(step,
   max_attempts, min_delay_ms, max_delay_ms)` drives a polling
   closure with exponential backoff, returning `Ok(Nil)` /
   `Error(Failed(_))` / `Error(MaxAttemptsExceeded(_))`. The
   codegen emits one `wait_until_<waiter>` Gleam function per
   `smithy.waiters#waitable` waiter on an op. Acceptors with
   `success: true|false` and `errorType: "..."` matchers are
   translated to the appropriate `Settled` / `Continue` /
   `FailedNow` step expression; the `errorType` match is dispatched
   on either the typed `<Op>Error<X>(_)` variant when the op
   declared `X` as a known error, or the `<Op>ErrorUnknown(error_type:
   "<X>", ..)` catch-all otherwise. Waiters with any unsupported
   matcher (`output`, `inputOutput`, `outputCount`,
   `errorContains` — JMESPath) are dropped at trait-parse time.
   End-to-end smoke test in `test/waiter_smoke_test.gleam` covers
   `S3.wait_until_bucket_exists` (settles on first 200) and the
   runtime's `MaxAttemptsExceeded` path.
   `table_active`, `function_active`.

5. **Event streams** — `@streaming` on unions. DynamoDB Streams,
   Kinesis, S3 Select, Bedrock `invoke-with-response-stream`.

6. **S3 transfer manager / multipart upload** — built on streaming.

7. **Presigned URLs** — DONE (2026-05-18). `sigv4.presigned_url`
   builds the query-string-auth variant of SigV4 — the auth fields
   (`X-Amz-Algorithm`, `X-Amz-Credential`, `X-Amz-Date`,
   `X-Amz-Expires`, `X-Amz-SignedHeaders`, optionally
   `X-Amz-Security-Token`, and `X-Amz-Signature`) ride in the URL
   query string instead of headers. Reuses the existing canonical-
   header / signed-header helpers so all headers the caller carries
   on the request get signed (not just `Host`). Honours
   `opts.omit_session_token` per the v4 spec — the token is
   appended to the URL AFTER signing rather than included in the
   canonical request. `payload_hash: Option(String)` lets callers
   pin `UNSIGNED-PAYLOAD` (S3's per-service convention) or pass a
   pre-computed body hash; `None` falls back to the standard
   `sign_body`-driven path. Verified end-to-end against every
   `query-signature.txt` fixture in the aws-c-auth v4 suite
   (`test/presigned_url_test.gleam`).

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

    Building blocks landed (2026-05-18): `crypto.sha1`,
    `crypto.crc32`, `crypto.crc32c`, `crypto.crc32_be_bytes`,
    plus `rest.checksum_header` / `rest.with_checksum_header`
    covering all four `aws.protocols#httpChecksum` algorithms
    (`sha256` / `sha1` / `crc32` / `crc32c`). CRC32C uses a
    pure-Erlang Castagnoli implementation (OTP's stdlib has no
    built-in for it). The middleware that wires these into
    operations carrying the multi-algorithm trait — picking
    the algorithm from request options + service config,
    computing the digest, and verifying the response header
    — is the next codegen-side piece.

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
