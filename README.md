# aws-gleam

Native Gleam AWS SDK for Erlang/OTP.

Install the service packages you use; each one depends on
[`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime).

```sh
gleam add aws_gleam_s3
gleam add aws_gleam_dynamodb
gleam add aws_gleam_sqs
```

Published packages:

- [`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime)
- [`aws_gleam_s3`](https://hex.pm/packages/aws_gleam_s3)
- [`aws_gleam_dynamodb`](https://hex.pm/packages/aws_gleam_dynamodb)
- [`aws_gleam_sqs`](https://hex.pm/packages/aws_gleam_sqs)
- [`aws_gleam_rds`](https://hex.pm/packages/aws_gleam_rds)
- [`aws_gleam_sesv2`](https://hex.pm/packages/aws_gleam_sesv2)

## Usage

Generated service clients expose two constructors:

- `<service>.new()` resolves region and credentials automatically.
- `<service>.new_with(settings, endpoint_params)` accepts explicit customer
  settings and the service's typed endpoint parameters.

```gleam
import aws/services/s3
import gleam/option.{Some}

pub fn main() {
  let assert Ok(client) = s3.new()

  let request =
    s3.ListObjectsV2Request(
      ..s3.list_objects_v2_request_default(bucket: "my-bucket"),
      prefix: Some("photos/"),
    )

  let _ = s3.list_objects_v2(client, request)

  s3.shutdown(client)
}
```

Generated operations take request/input records. Use the generated
`*_default(...)` helper with the operation's required fields, then override
optional fields with Gleam record update. Optional fields are `Option(...)`;
fields required by Smithy are plain values.

Custom configuration stays split between shared SDK settings and
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

`config.Settings` covers region, profile, credentials, endpoint URL, retry,
transports, HTTP/2, and SigV4a options. `<service>.EndpointParams` covers only
the Smithy endpoint-rule-set parameters declared by that service.

## Runtime

The runtime provides:

- Region and credential resolution.
- SigV4 and SigV4a signing.
- Smithy endpoint rule-set evaluation.
- Standard and adaptive retry.
- Buffered and streaming HTTP transports.
- Smithy protocol codecs, waiters, paginators, presigned URLs, and streaming
  body helpers.
- S3 multipart upload helpers under `aws/s3/transfer`.

Logging goes through Erlang/OTP `logger`. The SDK installs no handler and
does not mutate global logger configuration. Enable debug logs the usual BEAM
way:

```sh
ERL_FLAGS="-kernel logger_level debug" gleam run
```

## Build and Regen

Requires Gleam and Erlang/OTP.

```sh
gleam deps download
./scripts/test.sh             # bootstraps missing generated artifacts, then gleam test
./scripts/regen.sh            # explicit full regeneration when codegen changes
```

Focused regeneration accepts service names:

```sh
./scripts/regen.sh s3
./scripts/regen.sh s3 polly kinesis
```

Generated service source comes from:

- `vendor/aws-sdk-rust/aws-models/*.json`
- `test/fixtures/protocol-tests/*.json`
- `codegen/src/codegen/`

CI regenerates before tests. Hex packages include the generated service source,
so consumers do not need the codegen toolchain.

Project rules live in [RULES.md](RULES.md), with rationale in
[PHILOSOPHY.md](PHILOSOPHY.md).
