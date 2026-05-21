# aws_gleam_runtime

Runtime core for the [aws-gleam](https://github.com/Ulberg/aws-gleam)
SDK. Provides everything that's shared across every AWS service
typed client:

- **Credentials chain** — env vars → IRSA → SSO (modern + legacy) →
  shared credentials file → `credential_process` →
  `aws configure export-credentials` → ECS metadata → EC2 IMDSv2.
  Per-client cache actor that coalesces concurrent fetches.
- **Region resolution** — env vars + shared config.
- **SigV4 + SigV4a signing** — including IAM-credentials-derived
  signing keys, session-token handling, path normalization.
- **Endpoint resolver** — Smithy `endpointRuleSet` evaluator; each
  service package embeds its rule set and threads it through here.
- **Retry strategies** — standard + adaptive (per-token-bucket rate
  limiter); pluggable via `runtime.with_retry_strategy`.
- **Protocol codecs** — restXml, restJson1, awsJson1.0/1.1, awsQuery,
  ec2Query, rpcv2Cbor (framing), plus the Smithy
  `application/vnd.amazon.eventstream` framing codec.
- **Streaming HTTP transport** — `aws_streaming_ffi:streaming_send`
  in OTP `httpc` async-self mode (HTTP/1.1 + HTTP/2 variants).
- **Waiters + paginators** — generic helpers each service's
  generated client wires into per-op `wait_until_*` /
  `paginate_*` wrappers.

Not directly consumed: import a typed service client instead
(`aws_s3`, `aws_sqs`, `aws_dynamodb`, ...) — each one declares this
package as a dependency.

## Example

```gleam
import aws/credentials
import aws/region

pub fn debug_chain() {
  let resolved_region =
    region.resolve(profile: "default") |> result.unwrap("us-east-1")

  case credentials.default_chain() |> credentials.fetch() {
    Ok(creds) ->
      io.println("got creds in region " <> resolved_region <> " from "
        <> creds.source_name)
    Error(reason) ->
      io.println_error("no creds: " <> string.inspect(reason))
  }
}
```

In practice you don't reach for these directly — service clients
take care of the SigV4 + credentials wiring in their generated
`new()` constructor. The exception is config tweaks; every service
client exposes `<service>.with_retry_strategy`, `.with_http_send`,
`.with_endpoint_param`, etc., which thread their argument through
to this package's types.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_runtime>.

## License

Apache 2.0. See LICENSE.
