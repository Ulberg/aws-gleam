# Real-world smoke test — design sketch

This doc captures the shape of the planned Lambda-on-AWS smoke test
that validates the SDK end-to-end. Review + redirect before any of
this is built out. None of the work below has started.

## Goal

A Lambda function deployed to AWS that imports this SDK, hits real
S3 (put then get a small known body, list, multipart upload, etc.),
and returns success / structured error. Run-and-observe surfaces
bugs that the in-process tests (LocalStack + protocol fixtures)
miss — DNS, real ALPN, IAM role assumption from the Lambda
execution environment, throttling responses, the credentials chain
under EC2/Lambda metadata.

## Component sketch

```
aws-gleam-smoke/                 (separate repo)
├── README.md
├── gleam.toml                   gleam.add aws (path or hex)
├── manifest.toml
├── src/
│   ├── aws_gleam_smoke.gleam    Lambda handler — dispatches on event
│   ├── runtime_api.gleam        AWS Lambda Runtime API client
│   └── scenarios.gleam          put / get / list / multipart cases
├── bootstrap                    bash — starts the OTP release
├── build.sh                     gleam export erlang-shipment + zip
└── infra/                       OpenTofu OR SAM (one path picked)
    ├── main.tf                  Lambda + bucket + IAM role
    ├── variables.tf
    └── outputs.tf
```

## Decisions still open

| Question | My lean | Why |
|---|---|---|
| **SAM vs OpenTofu** | OpenTofu | Less AWS-toolchain lock-in; survives outside the Lambda box for multi-environment work later. SAM gives faster local invoke but the package's first deploy doesn't need that. |
| **SDK consumption** | Path dependency for v0, Hex pre-release once kinks are out | `gleam.toml` supports `aws = { path = "../aws-gleam" }`. Faster iteration than republishing on every fix. Once the SDK side is stable, cut `0.2.0-rc.1` to Hex and pin the smoke test to that. |
| **Region** | `us-east-1` | Most-tested SDK path; the corpus loop pins canonical+STS bytes against `us-east-1` fixtures. |
| **Runtime** | `provided.al2023` + BEAM bootstrap | AWS has no native Erlang/Gleam runtime, so we ship an OTP release as a "custom runtime." The `bootstrap` shell script execs the release; the handler implements the Lambda Runtime API polling loop in Gleam. |

## Lambda Runtime API client — the big new piece

AWS Lambda's custom-runtime contract: the function loop polls
`http://${AWS_LAMBDA_RUNTIME_API}/2018-06-01/runtime/invocation/next`,
processes the event, and POSTs back to
`/runtime/invocation/{requestId}/response` or
`/runtime/invocation/{requestId}/error`.

This Gleam module is the load-bearing new code:

```gleam
// src/runtime_api.gleam (smoke test repo)
pub type Invocation { Invocation(request_id: String, payload: BitArray) }

pub fn next() -> Result(Invocation, RuntimeError)
pub fn respond(request_id: String, body: BitArray) -> Result(Nil, RuntimeError)
pub fn report_error(request_id: String, message: String) -> Result(Nil, RuntimeError)
pub fn run_loop(handler: fn(Invocation) -> Result(BitArray, String)) -> Nil
```

`run_loop` runs forever — Lambda kills the container when idle. The
handler delegates to `aws/services/s3` calls.

There's no public Gleam package for this yet; the smoke test gets
the canonical implementation. If it pays off, we'd consider lifting
it into its own `gleam-aws-lambda-runtime` package.

## Scenario list (first round)

1. `put_object` of a 1 KB payload to a known key, then `get_object`
   and assert byte-equality.
2. `head_object` on the same key and assert the `Content-Length`.
3. `list_objects_v2` with a prefix and assert the just-uploaded key
   appears.
4. `transfer.upload_with_options` of a 32 MB payload — exercises
   the multipart-upload coordinator.
5. `delete_object` cleanup.
6. Error path: `get_object` on a missing key returns
   `s3.GetObjectErrorNoSuchKey(_)` rather than a generic transport
   error.

Each scenario's result lands in CloudWatch Logs as structured JSON
so the test runner can scrape it.

## Estimated effort

| Piece | LOC | Notes |
|---|---|---|
| `runtime_api.gleam` | ~150 | New module; the Lambda Runtime API polling loop |
| `aws_gleam_smoke.gleam` | ~80 | Handler dispatch + scenario runner |
| `scenarios.gleam` | ~200 | Six S3 scenarios |
| `bootstrap` + `build.sh` | ~50 | Shell |
| `infra/main.tf` (OpenTofu) | ~120 | Lambda function, bucket, IAM role, log group |
| README + run docs | ~80 | Deploy + invoke instructions |
| **Total** | **~680 LOC** | Spread across ~6 commits in a new repo |

## What I need from you before starting

1. **SAM or OpenTofu?**
2. **Path dependency or Hex pre-release for round 1?**
3. **Region** (defaulting to `us-east-1`)?
4. **Where does the smoke-test repo live?** New top-level repo, or
   subdirectory of this one?
5. **AWS account access** — I assume you'll deploy / provide creds;
   I'll write the scaffolding so it doesn't need them at build time.
6. **Should I finish RFC 6979 first?** It doesn't affect this — the
   SDK already signs valid requests AWS accepts. RFC 6979 is
   test-side polish only. My recommendation: skip it for now,
   revisit after the smoke test exposes any real bugs.
