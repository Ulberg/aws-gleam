# aws_gleam_runtime

Shared runtime package for the [aws-gleam](https://github.com/Ulberg/aws-gleam)
SDK. Service clients depend on this package for the behavior that is common
across AWS services.

It provides:

- Credential providers and the default chain: environment, IRSA, SSO, shared
  credentials, process providers, `aws configure export-credentials`, ECS
  metadata, and EC2 IMDSv2.
- Region resolution from `AWS_REGION`, `AWS_DEFAULT_REGION`, and
  `~/.aws/config`.
- SigV4 and SigV4a signing.
- Smithy endpoint rule-set evaluation.
- Standard and adaptive retry strategies.
- Buffered and streaming HTTP transport hooks.
- Protocol codecs for restXml, restJson, awsJson, awsQuery, ec2Query,
  rpcv2Cbor, and Smithy event-stream framing.
- Generic waiter, paginator, and streaming-body helpers.

Most applications should import a typed service client such as
`aws_gleam_s3`, `aws_gleam_sqs`, or `aws_gleam_dynamodb` rather than using this
package directly. The service packages expose two construction paths:

- `<service>.new()` for automatic region and credential resolution.
- `<service>.new_with(settings, endpoint_params)` for explicit customer
  settings plus the service's typed endpoint-rule-set parameters.

## Configuration

Shared customer settings live in `aws/config.Settings`. Start from
`default_settings()` and override only the fields you need:

```gleam
import aws/config.{Settings, default_settings}
import aws/retry
import gleam/option.{Some}

let settings =
  Settings(
    ..default_settings(),
    region: Some("eu-west-1"),
    max_attempts: Some(5),
    retry_strategy: Some(retry.standard()),
  )
```

Service-specific endpoint parameters do not live in `Settings`. They are
generated per service as `<service>.EndpointParams`, so a parameter is only
settable where that service's Smithy rule set declares it.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_runtime>.

## License

Apache 2.0. See LICENSE.
