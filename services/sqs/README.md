# aws_gleam_sqs

Typed Gleam client for Amazon SQS, generated from the upstream Smithy model in
[aws-gleam](https://github.com/Ulberg/aws-gleam).

```gleam
import aws/services/sqs

pub fn main() {
  let assert Ok(client) = sqs.new()
  sqs.shutdown(client)
}
```

Operations take generated request/input records. Start from the generated
`*_default(...)` helper and override optional fields with Gleam record update.

Use `sqs.new_with(settings, endpoint_params)` for explicit
`aws/config.Settings` and SQS endpoint-rule-set parameters.

Depends on [`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime) for
signing, credentials, endpoint resolution, retry, transport, and protocol
codecs.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_sqs>.

## Source

<https://github.com/Ulberg/aws-gleam/tree/main/services/sqs>

## License

Apache 2.0. See LICENSE.
