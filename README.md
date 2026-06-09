# aws-gleam

Native Gleam AWS SDK for Erlang/OTP.

The repository contains the shared runtime, the Smithy-based code generator,
and package skeletons for generated service clients. Generated service source
is not committed; `scripts/regen.sh` recreates it from the pinned AWS models.

Published packages:

- [`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime)
- [`aws_gleam_s3`](https://hex.pm/packages/aws_gleam_s3)
- [`aws_gleam_dynamodb`](https://hex.pm/packages/aws_gleam_dynamodb)
- [`aws_gleam_sqs`](https://hex.pm/packages/aws_gleam_sqs)
- [`aws_gleam_rds`](https://hex.pm/packages/aws_gleam_rds)
- [`aws_gleam_sesv2`](https://hex.pm/packages/aws_gleam_sesv2)

## Status

The v0.1 gate has shipped: a Gleam binary can resolve AWS region, credentials,
and endpoints with no explicit configuration, then call DynamoDB `GetItem` and
S3 `GetObject` end to end with typed input, output, and per-operation error
sums.

Implemented and covered areas include:

- SigV4 signing, pinned against the official aws-c-auth SigV4 vectors.
- SigV4a signing for S3 multi-region access points, including IAM key
  derivation, session-token handling, path-normalization controls, and
  deterministic P-256 signing. The aws-c-auth SigV4a corpus pins canonical
  requests and strings-to-sign; focused tests cover signature verification.
- Region resolution from `AWS_REGION`, `AWS_DEFAULT_REGION`, and
  `~/.aws/config`.
- Credential chain: environment, IRSA, SSO, shared credentials, process
  providers, `aws configure export-credentials`, ECS metadata, and EC2 IMDSv2.
- Smithy endpoint rule-set evaluation, including service endpoint parameters
  such as S3 `Bucket`, `Key`, `UseFIPS`, `UseDualStack`, and `ForcePathStyle`.
- Standard retry plus token-bucket adaptive retry, wired through the runtime.
- Smithy protocol codecs for restXml, restJson, awsJson, awsQuery, ec2Query,
  rpcv2Cbor, event-stream framing, timestamps, checksums, paginators, waiters,
  presigned URLs, and streaming bodies.
- S3 multipart upload helpers under `aws/s3/transfer`.

This is still pre-1.0 SDK work. Generated code is only a starting point; a
service operation is treated as supported when fixtures, local e2e, or live
smoke coverage prove the path.

## Usage

Every generated service client has the same construction shape:

- `new()` resolves region and credentials automatically.
- `new_with(settings, endpoint_params)` accepts explicit customer settings plus
  the service's typed Smithy endpoint parameters.

```gleam
import aws/services/s3

pub fn main() {
  let assert Ok(client) = s3.new()

  // Call typed operations with their generated input records.
  // Errors are per-operation sums: Smithy errors plus Transport.

  s3.shutdown(client)
}
```

Custom configuration stays split between shared customer settings and
service-specific endpoint parameters:

```gleam
import aws/config.{Settings, default_settings}
import aws/services/s3
import gleam/option.{Some}

pub fn main() {
  let settings =
    Settings(
      ..default_settings(),
      region: Some("eu-west-1"),
      max_attempts: Some(5),
    )

  let endpoint_params =
    s3.EndpointParams(
      ..s3.default_endpoint_params(),
      use_fips: Some(True),
      force_path_style: Some(True),
    )

  let assert Ok(client) = s3.new_with(settings, endpoint_params)
  s3.shutdown(client)
}
```

`config.Settings` holds customer-controlled settings: region, profile,
credentials, endpoint URL, retry, transports, HTTP/2, and SigV4a options.
`<service>.EndpointParams` holds only the endpoint-rule-set parameters declared
by that service model. There are no post-construction `with_*` setters in the
generated client API.

Long-running processes that create many clients should call
`<service>.shutdown(client)` or `<service>.shutdown_sync(client, timeout_ms)` on
teardown so the per-client credentials cache actor exits cleanly.

## Logging

The SDK logs through Erlang/OTP
[`logger`](https://www.erlang.org/doc/apps/kernel/logger_chapter.html). It
does not install handlers or mutate global logger configuration.

Levels used by the SDK:

- `error`: unrecoverable failures, such as exhausted credentials or retries.
- `warning`: recovered but notable failures, such as a retry or configured
  credential provider miss.
- `debug`: request, endpoint, response, retry, credential-provider, cache, and
  per-attempt detail.

At OTP's default `notice` level, `error` and `warning` are visible and `debug`
is hidden. Enable debug logging with normal BEAM configuration:

```sh
ERL_FLAGS="-kernel logger_level debug" gleam run
```

For releases, set `logger_level` or module-specific logger settings in
`sys.config`.

## Build, Test, Regen

Requires Gleam and Erlang/OTP.

```sh
gleam deps download
scripts/init-submodules.sh    # first time only
./scripts/regen.sh            # generate service clients + protocol dispatchers
./scripts/test.sh             # gleam test with ERL_FLAGS="+t 4194304"
```

Focused regeneration accepts service names:

```sh
./scripts/regen.sh s3
./scripts/regen.sh s3 polly kinesis
```

Use `scripts/test.sh` rather than plain `gleam test` for full generated builds.
The full service set creates enough BEAM atoms to exceed Erlang's default
1,000,000 atom-table limit; the script raises it to 4,194,304.

LocalStack e2e and live smoke tests are gated and are not part of the default
test command. Live smoke tests require `AWS_PROFILE`.

## Generated Code

The generated files are deterministic outputs of:

- `vendor/aws-sdk-rust/aws-models/*.json`
- `test/fixtures/protocol-tests/*.json`
- `codegen/src/codegen/`

Do not hand-edit generated service source. Change the code generator and
regenerate. CI regenerates before tests, and Hex package publishing includes
the generated service source so consumers do not need the codegen toolchain.

## Submodules

The code generator reads pinned upstream material:

- `vendor/aws-sdk-rust`: AWS service models, partitions, and endpoints.
- `vendor/smithy`: Smithy AWS protocol-test models.

After cloning:

```sh
scripts/init-submodules.sh
```

## Conventions

Project rules live in [RULES.md](RULES.md), with rationale in
[PHILOSOPHY.md](PHILOSOPHY.md). Read those before changing codegen or runtime
behavior.
