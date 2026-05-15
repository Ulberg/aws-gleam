# aws

Native Gleam AWS SDK targeting Erlang. Pre-v0.1; not published.

The current milestone plan is in [docs/m5-codegen-pivot.md](docs/m5-codegen-pivot.md);
the original v0.1 runtime plan is in [docs/v0.1-plan.md](docs/v0.1-plan.md)
(M1–M4 sections still accurate, M5+ superseded).

## Status

M1–M4 merged on `main`: SigV4, credential providers + cache, region
resolution + endpoint rule-set evaluator, retry middleware. Smoke-tested
end-to-end against a live S3 bucket. M5+ pivots to Smithy-driven codegen
pinned to upstream model SHAs.

## Building

Requires Gleam and Erlang/OTP.

```
gleam deps download
gleam build
gleam test
```

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
