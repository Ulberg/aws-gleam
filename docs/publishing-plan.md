# Publishing plan — aws-gleam to hex

This plan splits the monorepo aws-gleam SDK into independently
hex-publishable packages so consumers only compile the AWS services
they actually use, then moves examples into their own repo.

Mirrors `aws-sdk-rust`'s crate split (one crate per service + a
shared runtime crate). Necessary because Gleam compiles dependency
packages whole — a single `aws` hex package shipping 409 service
modules forces every consumer to compile all 409.

## Package layout

| Hex package | Source | Depends on |
|---|---|---|
| `aws_runtime` | `runtime/` in this repo | gleam_stdlib, gleam_otp, gleam_erlang, gleam_http, gleam_httpc, gleam_json |
| `aws_s3` | `services/s3/` (generated) | `aws_runtime` |
| `aws_sqs` | `services/sqs/` (generated) | `aws_runtime` |
| `aws_dynamodb` | `services/dynamodb/` (generated) | `aws_runtime` |
| `aws_<svc>` for each Smithy model we support | `services/<svc>/` (generated) | `aws_runtime` |

Initial hex release: `aws_runtime` + `aws_s3` + `aws_sqs` +
`aws_dynamodb`. Add more services on demand.

## Repo layout after the split

```
aws-gleam/
├── runtime/                          NEW — the aws_runtime hex package
│   ├── gleam.toml                    name = "aws_runtime"
│   ├── src/
│   │   ├── aws/credentials.gleam
│   │   ├── aws/endpoints.gleam
│   │   ├── aws/region.gleam
│   │   ├── aws/retry.gleam
│   │   ├── aws/streaming.gleam
│   │   ├── aws/waiter.gleam
│   │   ├── aws/pagination.gleam
│   │   └── aws/internal/             everything currently under here
│   └── test/                         the runtime-side test suite
├── services/                         NEW — per-service hex packages
│   ├── s3/
│   │   ├── gleam.toml                name = "aws_s3", aws_runtime path-dep
│   │   └── src/aws/services/s3.gleam (codegen output)
│   ├── sqs/
│   │   └── ...
│   └── ...
├── codegen/                          unchanged shape, emit paths shift
├── scripts/
│   ├── regen.sh                      writes to services/<svc>/src/...
│   ├── publish.sh                    NEW — gleam publish per package
│   └── test.sh                       runs aws_runtime tests + spot-checks
│                                     each services/<svc>/
├── docs/
├── vendor/                           unchanged
└── .github/workflows/
    └── publish.yml                   NEW — release pipeline
```

## Compatibility migration

* **Drop** the top-level `gleam.toml`, `src/aws/`, `test/` once
  the runtime package is moved. Replace with a README pointing
  callers at hex.
* **`examples/`** has moved to the separate
  [`aws-gleam-examples`](https://github.com/Ulberg/aws-gleam-examples)
  repo as of the package split landing (Phase 3 below). This repo
  no longer contains any example/consumer code.

## Phase 1 — Package split (this repo)

Goal: hex packages can be built + tested without touching hex.

1. Create `runtime/gleam.toml` (name = `aws_runtime`, version
   `0.1.0`). Move:
   * `src/aws/credentials.gleam` → `runtime/src/aws/credentials.gleam`
   * `src/aws/endpoints.gleam`, `region.gleam`, `retry.gleam`,
     `streaming.gleam`, `waiter.gleam`, `pagination.gleam` → ditto
   * `src/aws/internal/**` → `runtime/src/aws/internal/**`
   * `src/aws_ffi.erl`, `src/aws_streaming_ffi.erl` → `runtime/src/`
   * Tests for runtime modules → `runtime/test/`
2. Modify codegen to emit `services/<svc>/`:
   * Each service's `gleam.toml` declares `aws_runtime = { path = "../../runtime/" }` for local builds.
   * The single existing `src/aws/services/<svc>.gleam` template
     becomes `services/<svc>/src/aws/services/<svc>.gleam` — no
     Gleam code changes needed; only output path shifts.
3. Update `scripts/regen.sh` and `scripts/test.sh` to walk the
   new layout. Each per-service package builds independently.
4. Verify: `cd runtime && gleam test` passes the existing test
   suite. `cd services/s3 && gleam build` compiles. Existing
   smoke-test under `examples/smoke-test/` updated to:
   ```toml
   aws_runtime = { path = "../../runtime/" }
   aws_s3 = { path = "../../services/s3/" }
   aws_sqs = { path = "../../services/sqs/" }
   ```
   and continues to round-trip on Fargate.

## Phase 2 — Hex publish

Goal: `gleam_runtime`, `aws_s3`, `aws_sqs`, `aws_dynamodb` on
hex.pm.

1. Per-package metadata: `description`, `licences = ["Apache-2.0"]`,
   `repository`, `links` in each `gleam.toml`. Top-level
   `README.md` for each package's hexdocs landing page.
2. `scripts/publish.sh` — wraps `gleam publish` for each package
   in dependency order:
   ```sh
   ( cd runtime && gleam publish --replace )
   for svc in s3 sqs dynamodb; do
     ( cd services/$svc && gleam publish --replace )
   done
   ```
3. Manual `gleam publish` once to validate metadata. Then automate
   via `.github/workflows/publish.yml` triggered on tag push
   matching `v*`:
   * Run tests
   * `gleam publish` each package, requiring `HEX_API_KEY` from
     GH Actions secrets.
4. SemVer: lock-step versions across `aws_runtime` + service
   packages for the first few releases. Decouple later if some
   service moves faster than the runtime.

## Phase 3 — Separate examples repo

Goal: `aws-gleam-examples` repo with no SDK source, only consumer
code that imports from hex.

1. Create `aws-gleam-examples` repo on GitHub.
2. `git filter-repo --subdirectory-filter examples/smoke-test`
   (or `git subtree split`) to bootstrap the new repo with the
   smoke-test's history intact.
3. In the new repo's `gleam.toml`:
   ```toml
   aws_runtime = ">= 0.1.0"
   aws_s3 = ">= 0.1.0"
   aws_sqs = ">= 0.1.0"
   ```
4. Remove `examples/` from this repo. Add a one-line README pointer.

## What this does NOT change

* The codegen architecture. `codegen/` is still a single Gleam
  project that knows how to emit each protocol. Only the output
  paths change.
* The Smithy model source. `vendor/aws-sdk-rust/aws-models/`
  stays vendored here.
* The wire-format compliance test suite. The corpus runner
  (`test/protocol_tests_test.gleam`) needs every service's
  decoder. Either: stays in this repo and imports per-service
  packages via path deps; OR moves into `runtime/test/` and uses
  generated proto-test surrogates rather than real services.
  Decision deferred to Phase 1 step 4.

## Risks + open questions

1. **Smoke-test path-dep gymnastics.** When the smoke-test moves
   to its own repo, it consumes from hex — so the in-image
   regen step (`scripts/regen.sh s3 sqs`) goes away. The Dockerfile
   becomes ~5 lines of plain consumer build. Net simpler.
2. **409-service publish.** Publishing all services to hex
   immediately is impractical and clutters hex.pm. Start with
   ~5 services (s3, sqs, dynamodb, lambda, sns) and grow on
   demand.
3. **Atom-table costs disappear naturally.** A consumer who
   only imports `aws_s3` only compiles `aws_s3` + `aws_runtime`
   — no `+t 16777216` needed.
4. **Inter-service deps.** A few services depend on others
   (e.g. STS for AssumeRole). When that's at the typed-client
   level we add a hex dep; when it's at the runtime level
   (current case: STS in `aws_runtime`) no change.
