# aws-gleam-smoke

Real-world Lambda smoke test for the [aws-gleam](../) SDK. Two
Lambda functions (writer + reader) share a single OTP release zip
and split into roles via a `SMOKE_ROLE` env var:

* **`writer`** (HTTP-invoked) — for each invocation event, writes
  the raw payload to S3 under `events/<request_id>.bin`, then sends
  the key as an SQS message body. Exercises S3 restXml `PutObject`
  and SQS awsJson1_0 `SendMessage` from the same Client config.
* **`reader`** (SQS-triggered) — decodes the standard Lambda → SQS
  event envelope (`{ "Records": [{ "body": "<key>", ... }, ...] }`)
  and `GetObject`-s each key from the bucket. Logs the byte count
  per fetched object.
* **`list_buckets`** (default) — the original proof-of-life scenario.
  Set `var.writer_role = "list_buckets"` on the writer Lambda to
  drop the SQS hop.

The same `bootstrap` + same zip artefact deploys to both functions;
the only deploy-time difference is the env vars Terraform sets on
each.

See [../docs/smoke-test-plan.md](../docs/smoke-test-plan.md) for the
original design + open decisions. The infra under `infra/` is
OpenTofu — pinned defaults are `us-east-1`, `provided.al2023`,
512 MB / 30 s timeout.

## Layout

```
smoke-test/
├── gleam.toml                       path dep: aws = { path = "../" }
├── src/
│   ├── aws_gleam_smoke.gleam        Lambda main: SMOKE_ROLE dispatch
│   ├── runtime_api.gleam            AWS Lambda Runtime API client
│   ├── writer_handler.gleam         PutObject + SendMessage
│   ├── reader_handler.gleam         SQS event decode + GetObject
│   └── list_buckets_handler.gleam   proof-of-life ListBuckets
├── Dockerfile                       container image (erlang:27-slim + shipment)
├── build.sh                         builds image + pushes to ECR + tofu apply
└── infra/                           OpenTofu (ECR + writer + reader + bucket
                                     + queue + IAM)
```

## Why a container image

Lambda's `provided.al2023` base ships no language runtime. The
Gleam-produced OTP shipment expects `erl` on the system PATH; running
the zip on `provided.al2023` produces `exec: erl: not found` at cold
start. The container image bundles ERTS via `erlang:27-slim` so the
BEAM starts cleanly.

## Build + deploy (one command)

`build.sh` does everything: deps, codegen, OTP-shipment, slim,
docker build, ECR push, `tofu apply`.

```
# AWS credentials in the env that's running tofu + docker:
eval "$(aws configure export-credentials --format env)"
export AWS_REGION=us-east-1

./build.sh
```

First run pulls Gleam deps + regenerates the SDK's ~409 services (a
minute or two) + builds the container image. Subsequent runs are
incremental — set `SKIP_REGEN=1` to skip the regen step when only
the handler code changed.

`KEEP_SERVICES` defaults to `s3 sqs`; bump it if adding scenarios
that use more services.

`SKIP_INFRA=1 ./build.sh` stops after the ECR push, useful when
debugging the image with `docker run -it <repo>:latest /bin/sh`.

The OpenTofu module creates:
- An ECR repository for the container image
- An S3 bucket both Lambdas read + write
- An SQS queue
- A writer Lambda function (HTTP-invokable, container image)
- A reader Lambda function (SQS-triggered, same container image)
- Two IAM roles, one per Lambda, with scoped permissions
- Two CloudWatch log groups, both with 7-day retention

## Invoke

```
WRITER_FN=$(tofu output -raw writer_function_name)
READER_LOG=$(tofu output -raw log_group_reader)

aws lambda invoke \
  --function-name "$WRITER_FN" \
  --payload '{"hello":"smoke"}' \
  --cli-binary-format raw-in-base64-out \
  /tmp/response.json
cat /tmp/response.json
# → {"status":"ok","s3_key":"events/<request_id>.bin"}

# Watch the reader pick up the SQS message + fetch the object.
aws logs tail "$READER_LOG" --follow
# → fetched s3://<bucket>/events/<request_id>.bin (17 bytes)
```

## Known limitations of this iteration

- **Cold-start cost.** First invocation compiles the BEAM modules
  the slim step kept. `KEEP_SERVICES` defaults to `s3 sqs` so the
  cold start touches only those clients.
- **Atom table.** The Dockerfile sets `ERL_FLAGS="+t 16777216"` to
  raise the BEAM atom-table ceiling for the SDK; if you trim
  further than `s3 sqs` you can drop this.
- **No DLQ.** The SQS queue has no dead-letter — a poison message
  re-drives forever (up to the queue's retention). Add a DLQ in
  `infra/main.tf` if running for more than a smoke test.
- **No image vulnerability scanning.** The ECR repo's
  `scan_on_push` is `false`. Flip it for any longer-lived deploy.
