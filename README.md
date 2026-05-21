# aws

Native Gleam AWS SDK targeting Erlang. Published on hex as
[`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime) plus
per-service packages ([`aws_gleam_s3`](https://hex.pm/packages/aws_gleam_s3),
[`aws_gleam_dynamodb`](https://hex.pm/packages/aws_gleam_dynamodb),
[`aws_gleam_sqs`](https://hex.pm/packages/aws_gleam_sqs),
[`aws_gleam_rds`](https://hex.pm/packages/aws_gleam_rds),
[`aws_gleam_sesv2`](https://hex.pm/packages/aws_gleam_sesv2)).

## Status

The v0.1 gate — *"a Gleam binary that, in Lambda / ECS Fargate /
EC2 / EKS, resolves credentials + region + endpoint with zero
configuration and calls DynamoDB `GetItem` and S3 `GetObject`
end-to-end with typed inputs, outputs, and per-operation error sums"* —
shipped. Current capabilities:

- SigV4 signing — 38 official AWS test vectors green at every stage.
- **SigV4a** (asymmetric ECDSA P-256 for S3 MRAP / multi-region
  endpoints) — algorithm, IAM key derivation
  (`derive_signing_key(akid, secret)`), one-call
  `sign_with_iam_credentials`, session-token + `omit_session_token`,
  `normalize_path`, plus per-Client opt-in via
  `<service>.with_sigv4a_region_set(client, region_set)` — every
  generated service has the setter, and `runtime.prepare_signed_request`
  routes through `sigv4a.sign_with_credentials` when present. Fixture-
  driven corpus loop pins canonical request + string-to-sign byte-
  for-byte across the aws-c-auth `aws-signing-test-suite/v4a/*` set.
  RFC 6979 deterministic nonces (which would unblock signature-byte
  pinning too) are the remaining piece.
- Eight-stage credential chain: env → IRSA → SSO (modern + legacy
  profile shapes) → shared credentials → `credential_process` →
  `aws configure export-credentials` → ECS metadata → EC2 IMDSv2.
  Per-`Client` cache actor (`credentials_cache`) coalesces concurrent
  fetches; both it and the retry `rate_limiter` expose
  `shutdown` / `shutdown_sync` lifecycle helpers.
- Auto-region: `<service>.new_with_auto_region()` walks
  `AWS_REGION` / `AWS_DEFAULT_REGION` / `~/.aws/config`.
- Smithy endpoint rule sets bundled at codegen time and evaluated per
  request. `runtime.invoke_with_endpoint_params` threads
  operation-specific params (S3 `Bucket` / `Key`).
- Retry: `retry.standard` (default) + `retry.adaptive(bucket)` —
  wired into `runtime.invoke`.
  Per-Client tuning via `<service>.with_max_attempts(client, n)`.
- restXml decoder: `@xmlFlattened` lists + struct-member `@xmlName` +
  `@httpHeader` / `@httpResponseCode` output bindings + `<Error><Code>`
  error-type extraction.
- STS `AssumeRole` provider; the existing `AssumeRoleWithWebIdentity`
  provider continues to cover IRSA.
- `smithy.api#httpChecksumRequired` middleware: codegen appends a
  `Content-MD5: base64(md5(body))` step on ops that need it, plus
  the multi-algorithm `aws.protocols#httpChecksum` algorithm-member
  dispatcher (M18: SHA256 / SHA1 / CRC32 / CRC32C).
- **Streaming HTTP transport** (chunked) via `aws_streaming_ffi:streaming_send`
  in OTP's `httpc` async-self mode. The SDK runtime's
  `streaming_http_send` defaults to this; opt into HTTP/2 via
  `<service>.with_http2(client)`. Codegen-emitted
  `<op>_streaming(client, input) -> Result(streaming.Response,
  runtime.ClientError)` for every `@streaming`-blob output op
  (S3.GetObject, Polly.SynthesizeSpeech, Bedrock, etc.) and
  `<op>_event_stream(client, input)` for every `@streaming`-union
  output op (Transcribe Streaming, Kinesis SubscribeToShard,
  S3.SelectObjectContent, etc.). Consumer helpers
  (`streaming.fold_chunks`, `collect_to_bit_array_max`,
  `collect_to_string_max`) cover the common patterns.
- **S3 multipart upload** via `aws/s3/transfer`. `upload`,
  `upload_from_stream`, `upload_with_options` (content-type, ACL,
  storage class, SSE, etc.), plus `part_size_for(total_bytes)` that
  scales the part size to stay inside S3's 10,000-parts cap.
  Best-effort abort on any mid-flight failure.
- **Event-stream framing codec** (`aws/internal/codec/event_stream`)
  — `application/vnd.amazon.eventstream` encode + decode, all ten
  header wire-codes, prelude + message CRC validation, plus
  `decode_all` / `fold_events` consumers bridging from
  `StreamingBody`.
- Paginators, waiters, presigned URLs, rpcv2Cbor (4/4 corpus),
  precise-Timestamp (`json_timestamp.Timestamp` with seconds +
  nanoseconds, emitted by the codegen for awsJson / restJson /
  restXml types).

## Using the SDK

```gleam
import aws/services/dynamodb
import gleam/option.{None, Some}

pub fn main() {
  // Build a client. Credentials resolve through the default chain;
  // region resolves from AWS_REGION / config when `new_with_auto_region`
  // is used.
  let assert Ok(client) = dynamodb.new_with_auto_region()

  let input =
    dynamodb.GetItemInput(
      table_name: Some("my-table"),
      key: Some(...),
      // ...
    )
  case dynamodb.get_item(client, input) {
    Ok(out) -> ...
    Error(dynamodb.GetItemErrorResourceNotFoundException(_)) -> ...
    Error(dynamodb.GetItemErrorTransport(reason: r)) -> ...
    Error(dynamodb.GetItemErrorUnknown(...)) -> ...
  }

  // Long-running processes that build many clients should release
  // the per-client cache actor on teardown to avoid process leaks.
  dynamodb.shutdown(client)
}
```

`s3.new(region:)` / `s3.list_buckets`, etc. follow the same shape — see
the generated module under `src/aws/services/s3.gleam` after running
`./scripts/regen.sh`. End-to-end examples ship in `src/aws/examples/`:

- `dynamodb_list_tables.gleam` — buffered awsJson1_0 call.
- `s3_get.gleam` — buffered restXml call (ListBuckets).
- `s3_multipart_upload.gleam` — `aws/s3/transfer.upload_with_options`
  driving CreateMultipartUpload → UploadPart × N →
  CompleteMultipartUpload with content-type set.
- `s3_streaming_get.gleam` — codegen-emitted
  `s3.get_object_streaming` + `streaming.collect_to_bit_array_max`
  for a size-bounded streaming download.

## Building

Requires Gleam and Erlang/OTP.

```
gleam deps download
scripts/init-submodules.sh    # first time only — pins upstream Smithy + AWS models
./scripts/regen.sh            # generate service clients + protocol-test dispatchers
./scripts/test.sh             # gleam test with ERL_FLAGS="+t 4194304"
```

`regen.sh` also takes positional service names for focused
iteration during codegen work:

```
./scripts/regen.sh s3                  # one service (~3s vs ~minute)
./scripts/regen.sh s3 polly kinesis    # multiple
```

The full-run path is what CI uses and what every commit's pre-test
sequence assumes; focused mode skips the protocol-test fixture
regen, the global service-count guard, and the all-of-services
`gleam format` walk so the inner-loop cost shrinks to roughly the
single-service codegen + a per-file format.

The atom-table bump is required when all ~409 services are generated:
each service module allocates a few thousand atoms at compile time
(type names, function names, etc.), which blows past Erlang's default
1M-atom ceiling. `+t 4194304` raises it to 4M, more than enough for
the full service set. Without it the BEAM crashes mid-compile with
`no more index entries in atom_tab`.

### Why regen?

`src/aws/services/*` (the typed service clients — DynamoDB, S3, the
protocol-test stubs) and `test/protocol_tests/*_dispatchers.gleam`
(the protocol-test harness glue) are **derived files**. They're
deterministic functions of:

- `vendor/aws-sdk-rust/aws-models/*.json` (Smithy models, ~100 k LOC each)
- `test/fixtures/protocol-tests/*.json` (Smithy protocol-test fixtures)
- The codegen in `codegen/src/codegen/`

…so we keep them OUT of git (~110 k LOC of derived noise) and
regenerate on demand. CI runs `./scripts/regen.sh` before tests;
when publishing to Hex we include the generated files in the
tarball so consumers don't need to run the codegen themselves.

## Submodules

The codegen subproject reads from pinned upstream sources:

- `vendor/aws-sdk-rust` — 428 AWS service Smithy JSON models +
  `sdk-partitions.json` + `sdk-endpoints.json`. Sparse-checkout to
  `aws-models/` only (184 MB on disk).
- `vendor/smithy` — `smithy-aws-protocol-tests/` model files (all six
  AWS protocols, ~1.4 MB).

Both are sparse-checkout submodules. After cloning this repo:

```
scripts/init-submodules.sh
```

This handles the sparse-init flow that a plain `git submodule update
--init` does NOT do — without it you'd pull the full 2.7 GB
`aws-sdk-rust` tree. Re-run after a `git submodule update --remote` to
re-apply the sparse config.

## Test fixtures

- `test/fixtures/aws-c-auth/tests/aws-sig-v4-test-suite/v4/` — vendored
  SigV4 vectors from [awslabs/aws-c-auth](https://github.com/awslabs/aws-c-auth).
- `test/fixtures/endpoints/` — endpoint rule-set + test cases extracted
  from aws-sdk-rust models (M3).
- `test/fixtures/partitions.json` — snapshot of AWS partitions data.
  Re-pointed to the submodule in M5.
- Protocol-test fixtures come in via `vendor/smithy/smithy-aws-protocol-tests/`
  as of M5.
