# aws

Native Gleam AWS SDK targeting Erlang. v0.1 in review on `feat/next-steps`;
not yet published.

The current milestone plan is in [docs/m5-codegen-pivot.md](docs/m5-codegen-pivot.md);
the original v0.1 runtime plan is in [docs/v0.1-plan.md](docs/v0.1-plan.md)
(M1–M4 sections still accurate, M5+ superseded). The next steps and
v0.2 candidates are tracked in [next_steps.md](next_steps.md).

## Status

The v0.1 plan's gate — *"a Gleam binary that, in Lambda / ECS Fargate /
EC2 / EKS, resolves credentials + region + endpoint with zero
configuration and calls DynamoDB `GetItem` and S3 `GetObject`
end-to-end with typed inputs, outputs, and per-operation error sums"* —
is met on `feat/next-steps` (PR #7). Highlights:

- SigV4 signing — 38 official AWS test vectors green at every stage.
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
- restXml decoder: `@xmlFlattened` lists + struct-member `@xmlName` +
  `@httpHeader` / `@httpResponseCode` output bindings + `<Error><Code>`
  error-type extraction.
- STS `AssumeRole` provider; the existing `AssumeRoleWithWebIdentity`
  provider continues to cover IRSA.
- 626 of 808 Smithy protocol-test corpus cases pass; zero fail.

See [docs/audits/m6.md](docs/audits/m6.md) for the 1:1 parity table
vs `aws-sdk-rust`.

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
`./scripts/regen.sh`. End-to-end examples ship in
`src/aws/examples/{dynamodb_list_tables,s3_get}.gleam`.

## Building

Requires Gleam and Erlang/OTP.

```
gleam deps download
scripts/init-submodules.sh    # first time only — pins upstream Smithy + AWS models
./scripts/regen.sh            # generate service clients + protocol-test dispatchers
gleam test
```

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
