# aws-gleam-smoke

Real-world end-to-end test for the [aws-gleam](../) SDK. Deploys two
ECS Fargate workloads that exercise S3 + SQS from inside the container,
with credentials coming from the task role via the standard ECS
metadata endpoint — same path real production workloads use.

* **`writer`** — one-shot Fargate task. Reads a payload from
  `SMOKE_PAYLOAD`, writes it to S3 under `events/<unique>.bin`, then
  sends the key as an SQS message body. Triggered on demand via
  `aws ecs run-task` (see `run-smoke.sh`).
* **`reader`** — long-running Fargate service (`desired_count = 1`).
  Long-polls SQS (20 s), fetches each S3 object whose key arrives
  in a message body, logs the byte count, deletes the message.
  Stays alive across many writer runs.

Both deploy from the **same container image** — `SMOKE_ROLE` env var
selects the entry point. Same OTP release, same `gleam export
erlang-shipment` build.

## Why Fargate, not Lambda

The smoke test originally targeted Lambda. Five problems pushed us
to Fargate:

1. `provided.al2023` ships no Erlang runtime; zip deploys fail at
   cold start with `exec: erl: not found`.
2. Mixing OTP versions between host-side `gleam export` and the
   runtime image gives `undef` on every module load. Forces a
   same-image build chain.
3. ~1-2 s cold start per invocation is fine on Fargate (amortized
   across hours), prohibitive on Lambda for chatty workloads.
4. The SDK's `credentials_cache` actor, retry `rate_limiter`, and
   endpoint rule-set evaluator assume a long-lived process. Lambda
   resets them per cold start.
5. The Lambda Runtime API polling loop (`runtime_api.gleam`, ~200
   LOC) only exists to satisfy Lambda's invoke contract. On Fargate
   the BEAM just runs — the file goes away.

For callers who **do** want Gleam-on-Lambda, see
[`../docs/lambda-gleam.md`](../docs/lambda-gleam.md) — it documents
three working approaches with pros/cons.

## Layout

```
smoke-test/
├── gleam.toml                       path dep: aws = { path = "../" }
├── src/
│   ├── aws_gleam_smoke.gleam        Entry: SMOKE_ROLE dispatch
│   ├── writer_handler.gleam         PutObject + SendMessage, exit(0)
│   └── reader_handler.gleam         Long-poll SQS → GetObject → log
├── Dockerfile                       gleam-lang:erlang-alpine base
├── build.sh                         build image → push ECR → tofu apply
├── run-smoke.sh                     run a writer task + tail logs
└── infra/                           OpenTofu: cluster + task defs +
                                     reader service + bucket + queue
```

## One-time setup

```sh
# Configure AWS creds (any working profile is fine)
eval "$(aws configure export-credentials --format env)"
export AWS_REGION=us-east-1

# Pin a globally-unique bucket name based on your account
cd smoke-test/infra
cat > terraform.tfvars <<EOF
bucket_name = "$(aws sts get-caller-identity --query Account --output text)-aws-gleam-smoke"
EOF
```

## Build + deploy

`build.sh` does everything: ECR repo, docker build, push, apply.

```sh
cd smoke-test
./build.sh
```

First run takes ~5-10 min (pulls the gleam-lang base image, runs
the SDK's 409-service codegen inside the container, builds the
OTP shipment). Subsequent runs hit Docker's layer cache and are
near-instant unless the SDK source changed.

## Run a smoke iteration

```sh
./run-smoke.sh                       # default payload
./run-smoke.sh "custom payload"      # any string
```

The script starts a one-shot writer task with `SMOKE_PAYLOAD`
overridden, then `aws logs tail`s the shared log group. Expected
output:

```
2026-… writer/<task-id> writer ok: wrote s3://…/events/…bin (NN bytes), enqueued to https://sqs…/queue
2026-… reader/<task-id> reader: fetched s3://…/events/…bin (NN bytes)
```

Reader log appears within ~5-25 s of the writer's (long-poll
latency). The reader service is always running, so this is just
an SQS round-trip — no cold start on the read side.

## What it proves

| Code path | Exercised by |
|---|---|
| Credentials chain (Fargate task role → ECS metadata endpoint) | both tasks at boot |
| Region resolution from `AWS_REGION` | both tasks |
| S3 endpoint rule set with `@contextParam Bucket` | writer.PutObject + reader.GetObject |
| restXml encoder/decoder | S3 PutObject/GetObject |
| awsJson1_0 codec | SQS SendMessage/ReceiveMessage/DeleteMessage |
| SigV4 signing against live AWS endpoints | every call |
| Per-Client credentials cache + retry rate limiter | reader (alive across many messages) |

## Tear down

```sh
cd smoke-test/infra
tofu destroy -auto-approve
```

`force_destroy = true` on the S3 bucket means objects are removed
with the bucket. ECR images go with the repo.

## Known limitations

- **No DLQ.** A poison message re-drives until it ages out
  (1-hour message retention by default).
- **Public subnets only.** The default-VPC layout uses public
  subnets + `assign_public_ip` so Fargate can pull from ECR and
  reach S3/SQS without VPC endpoints. Production would use
  private subnets + a NAT or VPC endpoints.
- **No image vulnerability scanning.** `scan_on_push = false` on
  the ECR repo. Flip it for any longer-lived deploy.
