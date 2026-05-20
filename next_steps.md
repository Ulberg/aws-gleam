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
| M5 — protocol codecs | ✅ awsJson1_0 / 1_1 / restJson1 / restXml / awsQuery / ec2Query / rpcv2Cbor | ✅ | corpus pass-rates per protocol below; failures across all eight = 0 |
| M6 — typed DynamoDB + S3 | ✅ (full services, not just GetItem/GetObject) | ✅ | response-header binding ✅ (2026-05-19); restXml error extraction ✅ |
| M7 — codegen | ✅ 7 protocols | ✅ | all 409 services emitted on full regen; v0.2 codegen flips (streaming-blob + streaming-union) covered |

### Protocol-test corpus snapshot (2026-05-19)

All eight corpora report `fail=0`. The remaining skips are spec-driven
or codegen-bounded:

| Protocol | pass | fail | skip(no-dispatcher) | skip(server-only) | skip(allowed) | total |
|---|---|---|---|---|---|---|
| awsJson1_0 | 64 | 0 | 5 | 6 | 0 | 75 |
| awsJson1_1 | 115 | 0 | 3 | 4 | 0 | 122 |
| restJson1 | 241 | 0 | 6 | 25 | 0 | 272 |
| restXml | 176 | 0 | 13 | 6 | 2 | 197 |
| restXmlWithNamespace | 2 | 0 | 0 | 0 | 0 | 2 |
| awsQuery | 74 | 0 | 3 | 0 | 0 | 77 |
| ec2Query | 56 | 0 | 3 | 0 | 0 | 59 |
| rpcv2Cbor | 4 | 0 | 0 | 0 | 0 | 4 |

The `no-dispatcher` counts decompose as follows:
- **awsQuery (15) / ec2Query (6)** — slices 1 + 2 of typed-input
  codegen landed (2026-05-19).
  Slice 1: scalars (String / Int / Bool / Float / Blob) + enums +
  integer-enums + declaration-member-order preservation +
  `@aws.protocols#ec2QueryName` / `@xmlName` precedence.
  Slice 2: lists with `@xmlFlattened` + member `@xmlName` (the
  list shape's `xml_entry_name`) + nested structs reachable from
  list members. `QueryLists`, `NestedStructures`, `Ec2Lists`,
  `Ec2NestedStructures` etc. all flip to dispatched.
  Combined delta from pre-slice baseline: awsQuery pass 44 → 62
  (+18), ec2Query pass 33 → 53 (+20). Zero failures.
  Wire format validated against the Rust SDK's
  `aws_smithy_query::QueryWriter` (see
  `vendor/aws-sdk-rust/sdk/aws-smithy-query/src/lib.rs`).
  ec2Query-specific quirks honored: all lists flat regardless of
  `@xmlFlattened`; empty lists not serialized (vs awsQuery's
  `<prefix>=` bare-name form); nested-struct member names follow
  ec2 first-letter-upper-case rule.
  Member declaration order extracted via a new `aws_codegen_ffi.erl`
  order-preserving JSON pre-pass (Erlang maps lose key order).
  Remaining no-dispatcher cases need slices 3 (maps) + 5
  (timestamps), plus a few ops with HTTP-binding traits
  (`@idempotencyToken`, `@hostLabel`).
- **restJson1 (6)** — three ops live in services we don't emit
  (`RestJsonValidation.RecursiveStructures`, `BackplaneControlService.GetRestApis`,
  `Glacier.UploadArchive`/`UploadMultipartPart`); the codegen's `find_service`
  picks the single service with the most ops per protocol. The remaining
  skips on `Malformed*` ops carry `httpMalformedRequestTests` only, which
  the loader doesn't parse (validation/server concern).
- **restXml (13) / awsJson1_0 (5) / awsJson1_1 (3)** — analogous mix of
  unsupported-input ops + non-canonical services in the fixture.

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
   DONE (2026-05-19). `credentials.from_profile_assume_role(name,
   send, region)` honours `role_arn` when present: walks
   `source_profile`, builds its static credentials, wraps them as a
   one-shot Provider, then composes via `from_assume_role_with` to
   hit STS. Falls through to the static-keys path when `role_arn`
   is absent, so the chained constructor is a strict superset of
   `from_profile` — chains drop into `default_chain` by just
   swapping the constructor. Honoured profile keys: `role_arn`
   (required), `source_profile` (required when role_arn present),
   `role_session_name` (defaults to `aws-gleam-session`),
   `external_id` (optional). Only single-hop chains today —
   multi-hop (A→B→C where source_profile itself has role_arn) is
   a separate follow-up. Pinned by 4 tests in
   `test/credentials_test.gleam`: static-fallthrough, chained STS
   fetch, missing-source-profile → NotConfigured, and the outbound
   STS request signing assertion (Authorization header carries the
   source profile's access-key id).

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

1. **Streaming bodies** (`@streaming`) — DONE (2026-05-19).
   `aws/streaming.gleam` defines the opaque `StreamingBody` with
   `Buffered` / `Chunked` variants; `aws_streaming_ffi.erl` drives
   `httpc:request` in `{sync, false}, {stream, self}` async-self
   mode and assembles chunks via `collect_stream/2`. The Gleam
   wrapper at `aws/internal/http_streaming.gleam` exposes
   `default_send` (the runtime's `streaming_http_send` default)
   plus `default_send_http2` for the HTTP/2 variant. Codegen-side
   `@streaming` blob members surface as `StreamingBody` end-to-end
   (`RStreamingBlob` → `streaming.from_bit_array`). Consumer
   helpers (`fold_chunks`, `try_fold_chunks`, `to_bit_array_max`,
   `to_string_max`) cover both buffered and chunked consumption.

   Per-op routing through the chunked transport landed via
   `runtime.invoke_streaming` — same credential / endpoint / SigV4
   pipeline as `invoke`, but dispatches through
   `streaming_http_send` and returns `streaming.Response` (the
   shared `status + headers + StreamingBody` shape every wrapper
   returns). Error responses materialise via
   `streaming.to_bit_array_max(body, 1 MiB)` so typed-error
   extraction works identically to `invoke`.

   The codegen now flips `@streaming`-output ops automatically —
   `types.has_streaming_blob_member(model, shape_id)` detects which
   operations qualify, and `restxml` / `restjson` / `awsjson`
   emitters all append a
   `<op>_streaming(client, input) -> Result(streaming.Response,
   runtime.ClientError)` wrapper alongside the buffered op. 16
   services across the SDK now expose codegen-emitted streaming
   wrappers (S3.GetObject, Polly.SynthesizeSpeech, Bedrock
   InvokeModelWithResponseStream, MediaLive log streams, Kinesis
   Video Media, Lex Runtime, EBS GetSnapshotBlock, Glacier,
   MediaStore Data, Translate, WorkMail, etc.). Per-service Client
   setters (`config`, `with_streaming_http_send`, `with_http2`,
   `with_max_attempts`) are emitted on every Client. End-to-end
   LocalStack round-trip exercises `s3.get_object_streaming`.

   Event-stream operations (Smithy `@streaming` on a union, not a
   blob — Transcribe StartStreamTranscription, Kinesis
   SubscribeToShard, S3 SelectObjectContent, etc.) are detected by
   `types.has_streaming_union_member` but not yet emitted; that's
   the next codegen pass. The planned lazy `Source(...)` variant
   for file-backed streaming arrives when a use case pins the
   ergonomics.

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
   Kinesis, S3 Select, Bedrock `invoke-with-response-stream`,
   Transcribe Streaming, CloudWatch Logs Live Tail.
   PARTIAL (2026-05-19). Framing codec landed at
   `aws/internal/codec/event_stream.gleam` — encode/decode of the
   `application/vnd.amazon.eventstream` wire format including all
   ten header wire-codes (0..9), prelude + message CRC validation,
   plus `decode_all` and `fold_events` consumers that bridge from
   `StreamingBody`.

   Codegen detection landed via `types.has_streaming_union_member`
   + `has_streaming_union_in_members` (the resolved-members
   variant that the protocol emitters call directly). Catches
   both response-side event streams
   (Transcribe.StartStreamTranscriptionResponse →
   TranscriptResultStream) and request-side ones
   (StartStreamTranscriptionRequest → AudioStream, used for HTTP/2
   bidirectional audio streaming).

   Codegen emit landed across all three http-shaped protocols
   (restxml / restjson / awsjson). Operations with a `@streaming`
   union output get an extra
   `<op>_event_stream(client, input) -> Result(streaming.Response,
   runtime.ClientError)` wrapper via the shared
   `client.invoke_event_stream_fn` AST builder. Same wire shape as
   the streaming-blob `<op>_streaming` variant; the distinct
   function-name suffix signals the
   `application/vnd.amazon.eventstream` framing to callers.
   Services with codegen-emitted event-stream wrappers include
   S3.SelectObjectContent (restXml), Transcribe Streaming
   StartStreamTranscription (restJson1), Kinesis SubscribeToShard
   (awsJson1_1), Bedrock AgentCore InvokeAgentRuntime,
   CloudWatch Logs StartLiveTail, Lex Runtime V2 StartConversation,
   IoT SiteWise, Pinpoint, SageMaker Runtime HTTP/2.

   End-to-end pipeline test
   (`test/transcribe_streaming_event_stream_test.gleam`) verifies
   the wrapper passes framed bytes through unchanged and the
   `event_stream.fold_events` consumer round-trips them.

   Remaining: typed per-event-union decoding — instead of returning
   the raw `streaming.Response` for callers to dispatch on, future
   codegen could emit a `parse_<op>_event(event) -> Result(<Op>Event,
   _)` helper that decodes each frame into the matching union
   variant. Needs a user-facing API-shape call first (callback /
   Iterator / Process subject) since BEAM concurrency idioms differ
   from the Rust SDK's `Stream` and the JS SDK's `AsyncIterable`.

6. **S3 transfer manager / multipart upload** — DONE (2026-05-19).
   `aws/s3/transfer.upload(client, bucket, key, body, part_size_bytes)`
   runs `CreateMultipartUpload` → `UploadPart` × N →
   `CompleteMultipartUpload`, with best-effort `AbortMultipartUpload`
   on any failure. `upload_from_stream` accepts a `StreamingBody`
   and rechunks across chunk boundaries so wire-side part sizes
   follow `part_size_bytes`. `part_size_for(total_bytes)` picks a
   safe part size for any total inside S3's 10,000-parts cap.
   `upload_with_options` + `upload_from_stream_with_options` thread
   `UploadOptions` (content_type, content_encoding,
   content_disposition, cache_control, metadata, acl, storage_class,
   server_side_encryption) into the CreateMultipartUpload request.
   `aws/s3/streaming.get_object_streaming` exposes the read-side
   counterpart on the chunked transport. End-to-end LocalStack tests
   cover both the multipart upload round-trip and the streaming
   GetObject round-trip; unit suite at 8 transfer tests + 2
   s3_streaming tests + the size-scaler edges. Parallel upload
   (Task-based fan-out) is the next extension; today's coordinator
   is sequential.

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

9. **rpcv2Cbor protocol** — DONE (2026-05-19). CBOR codec at
   `aws/internal/codec/cbor.gleam` covers RFC 8949 with canonical
   bytewise key sort (16 round-trip tests from RFC App. A).
   `codegen/src/codegen/cbor_rpc.gleam` emits build_request +
   parse_response for every rpcv2Cbor operation in the corpus.
   Protocol-test corpus reports 4/4 passing.

10. **Endpoint ruleset coverage beyond S3 + DynamoDB** — DONE
    (2026-05-20). v0.1 already bundled every service's
    `endpoint-rule-set-1.json` and wired the evaluator. v0.2 closed
    the parameter-builder gap: each builtIn-flagged param in the
    rule-set trait now emits a typed
    `with_<param>(client, value: Bool|String) -> Client` setter
    in the per-service module. `trait_helpers.endpoint_param_setters`
    extracts the list (Bool / String params with a `builtIn` field,
    excluding `AWS::Region` + `SDK::Endpoint` since those already
    have first-class plumbing); `client.gleam` emits one setter per
    param, threading through `runtime.with_endpoint_param` with the
    right `endpoints.BoolVal` / `endpoints.StringVal` wrapper. Doc
    comments lifted verbatim from the trait's `documentation` field.
    S3 picks up `with_force_path_style`, `with_use_fips`,
    `with_use_dual_stack`, `with_use_arn_region`, `with_accelerate`,
    `with_disable_multi_region_access_points`,
    `with_use_global_endpoint`. Pinned by 5 tests in
    `test/endpoint_param_setters_test.gleam` covering Bool round-
    trip, last-call-wins, and independence of distinct keys.
    487/487 unit tests pass after a full
    `./scripts/regen.sh` of all 409 services.

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
    built-in for it).

    Codegen middleware landed (2026-05-19, M18): algorithm-member
    dispatch for `aws.protocols#httpChecksum`. The codegen now
    emits `build_checksum_step` per operation that reads the
    request's algorithm-member, picks the matching digest
    function, computes the body hash, and sets the
    `x-amz-checksum-<algo>` header before SigV4 signing. End-to-
    end smoke test uses `S3.put_bucket_accelerate_configuration`.

12. **Timestamp fractional seconds + offsets** — DONE (2026-05-19).
    `json_timestamp.Timestamp(seconds, nanoseconds)` with
    `decoder_precise()` is wired through the codegen for awsJson,
    restJson, and restXml type emission, plus the rest-side
    header / query / URI formatters
    (`format_iso8601_precise`, `format_http_date_precise`,
    `epoch_seconds_text`). CloudWatch / EventBridge / metric APIs
    preserve sub-second precision through the type. Note: the
    ISO 8601 + HTTP-date FFI parsers only emit second-level
    precision today; sub-second on the receive side from those
    formats lands when the FFI gains fractional-second parsing.

13. **HTTP/2** — DONE (2026-05-19). `aws_streaming_ffi.streaming_send/7`
    threads `{http_version, "HTTP/2"}` into the httpc option list.
    Gleam side surfaces as `http_streaming.default_send_http2` +
    `with_timeout_tls_http2`; `runtime.with_http2(config)` and the
    codegen-emitted `s3.with_http2(client)` (and every other
    service's `with_http2`) are the caller-facing knobs that swap
    `streaming_http_send` to the HTTP/2 variant. Buffered path
    stays HTTP/1.1 (gleam_httpc doesn't expose the option); HTTP/2
    is for high-throughput streaming endpoints (S3 multipart,
    Bedrock streaming, Transcribe). Build-option count tests +
    runtime setter tests pin the wiring.

14. **JavaScript target** — explicitly out per the plan and
    `CLAUDE.md`.

## Current focus (2026-05-19)

Items still open after the streaming + multipart + event-stream
codegen pass:

1. **Pull-based event-stream iterator** — DONE.
   `event_stream.iter_events(body) -> IterStep` returns Yield /
   Done / Failed steps callers can drive explicitly. Per-event
   typed-union decoding (codegen-emitted per-union variant
   decoders) is the next layer on top of this and lands when a
   real consumer needs it.
2. **`Source(...)` variant for `StreamingBody`** — DONE.
   `from_source(next: fn() -> Result(BitArray, Nil))` constructor;
   `fold_chunks` / `try_fold_chunks` stream chunk-by-chunk via the
   callback; `to_chunks` / `byte_size` materialise (consume) the
   stream. Single-pass — once consumed it's exhausted. File-
   backed `from_file(path)` helper follows when the smoke-test's
   upload-from-disk scenario needs it.
3. **Parallel multipart upload** — DONE.
   `UploadOptions` gains `max_concurrency: Option(Int)`;
   `with_max_concurrency(opts, n)` flips the coordinator to fan
   out via OTP processes capping in-flight `UploadPart` calls to
   `n`. First failure short-circuits the whole upload with
   best-effort abort.
4. **awsQuery / ec2Query typed-input codegen** (corpus snapshot
   above). Multi-slice codegen project; slices 1 + 2 LANDED
   2026-05-19.
   - Slice 1 (DONE): scalars + Blob + Enum + IntegerEnum +
     Float-specials + member declaration-order preservation +
     ec2QueryName / xmlName precedence. +25 dispatched corpus cases.
   - Slice 2 (DONE): lists w/ `@xmlFlattened` + list-element
     `@xmlName` + nested struct emission (so `QueryLists` /
     `NestedStructures` / `Ec2Lists` flip). ec2Query-specific
     flat-by-default and empty-list-suppressed rules honored.
     +13 more dispatched corpus cases. Total slices 1+2:
     +38 from baseline. Zero failures.
   - Slice 3: maps (`start_map(flat, key_name, value_name)`).
   - Slice 4: deeper recursive nested structs already work via the
     same `encode_<S>_at` helper; remaining is HTTP-binding
     trait skip-list extension (`@idempotencyToken`, `@hostLabel`)
     for the few ops still excluded by `no_member_traits`.
   - Slice 5: timestamps with `@timestampFormat`
     (date-time / http-date / epoch-seconds).
5. **SigV4a** (v0.2 item 8). Algorithm + IAM key derivation are
   in place — see SigV4a sub-status below. Remaining: runtime
   dispatch wiring + session-token + path normalization + RFC
   6979 deterministic nonces (each its own slice).
6. **Endpoint ruleset coverage beyond S3 + DynamoDB** (v0.2
   item 10). The evaluator is wired; bundling all ~300 rulesets
   at codegen time + per-service builders is remaining.

### SigV4a sub-status (2026-05-19)

| Piece | Status | Notes |
|---|---|---|
| `sigv4a.sign` (canonical req, STS, ECDSA P-256 signing) | DONE | `src/aws/internal/sigv4a.gleam`; round-trip verified via `sigv4a_test`. |
| `derive_signing_key(akid, secret)` — IAM → P-256 scalar | DONE | matches `aws-sigv4::sign::v4a::generate_signing_key`; public key pinned against `aws-c-auth v4a/*/public-key.json`. |
| `sign_with_iam_credentials(req, akid, secret, opts)` | DONE | one-call wrapper; round-trip-verified. |
| `ecdsa_p256_public_key/1` FFI | DONE | exposed for tests + anyone surfacing the public side of a derived key. |
| `Sigv4aCredentials` + `sign_with_credentials` + session token | DONE | `Sigv4aCredentials(access_key_id, private_key, session_token: Option(String))` mirrors `sigv4.SigningCredentials`; `X-Amz-Security-Token` participates in canonical headers + SignedHeaders when present. |
| `Sigv4aOptions.normalize_path` (RFC 3986 dot-segments) | DONE | Ported from `sigv4.normalize_path` (intentional duplication per module docstring). Required for the `get-*-normalized` aws-c-auth v4a fixtures. |
| `canonical_request` / `string_to_sign` extracted as public | DONE | mirrors `sigv4.CanonicalParts` shape — enables fixture-driven pinning of canonical-request and STS bytes per fixture without re-implementing the pipeline in the test. |
| Header canonicalization (duplicate-name comma-join + value space-collapse) | DONE | bugs surfaced by the corpus loop on `get-header-key-duplicate`, `get-header-value-order`, `get-header-value-trim`; fixed by porting `sigv4.group_by_name` + `collapse_spaces`. |
| Fixture-driven loop test (canonical + STS bytes vs `aws-c-auth v4a/*`) | DONE (canonical + STS) | `test/sigv4a_fixtures_test.all_v4a_cases_canonical_and_sts_test` loops the corpus and pins both stages with an empty skip-list. Signature byte-pin still blocked on RFC 6979. |
| `omit_session_token` option on `Sigv4aOptions` | DONE | Mirrors `sigv4.SigningOptions.omit_session_token` + `headers_for_signing` filter; flips the `post-sts-header-after` fixture from skip → pass. |
| Runtime-side wiring + codegen-emitted `<service>.with_sigv4a_region_set` | DONE | `runtime.Sigv4aSigner` + `with_sigv4a_region_set` setter; `prepare_signed_request` branches between `sign_sigv4` (default) and `sign_sigv4a` (signer present). Codegen emits a uniform `with_sigv4a_region_set(client, region_set)` setter per service mirroring `with_http2`. Three end-to-end tests on S3 pin algorithm + region-set header. Per-request key derivation; caching is a follow-up. |
| `with_sigv4a_path_normalization` per-Client knob | DONE | `Sigv4aSigner` carries `normalize_path: Bool` (default `True`); `with_sigv4a_path_normalization(client, False)` is the S3 caller story so object keys with `.` / `..` survive. Setter is a no-op when called before `with_sigv4a_region_set` (no signer to override). |
| `sigv4_canonical` shared module (canonical-request helpers) | DONE | `canonical_headers` / `signed_headers` / `canonical_query_string` / `build_canonical_uri` / `encode_path` lifted into `aws/internal/sigv4_canonical`. sigv4 + sigv4a both delegate; ~150 LOC of duplication removed. |
| RFC 6979 deterministic nonces | DONE | `aws/internal/ecdsa_deterministic.gleam`: HMAC-DRBG nonce derivation + modular inverse + DER encoding in pure Gleam; the EC point multiplication `k·G` outsourced to Erlang's `crypto:generate_key(ecdh, secp256r1, k)` via the existing `aws_ffi:ecdsa_p256_public_key/1` FFI. Pinned against RFC 6979 §A.2.5 reference vectors for both `"sample"` and `"test"` messages. `sigv4a.sign_with_credentials` now signs through this path; the random-nonce Erlang FFI is no longer reachable. |

## Suggested execution order (historical)

The order v0.1 was shipped in, kept for context:

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

## Related working docs

- `docs/v0.1-plan.md` — the authoritative milestone gate definitions.
- `docs/audits/m5.md` — protocol codec parity vs aws-sdk-rust.
- `docs/audits/m6.md` — typed-client parity vs aws-sdk-rust + the
  "Known gaps" list this document references.
- `fixes.md` — small in-codegen cleanups left after the
  `rest_request` extraction. Orthogonal to the items here.
