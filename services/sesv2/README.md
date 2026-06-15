# aws_gleam_sesv2

Typed Gleam client for Amazon SES v2, generated from the upstream Smithy model
in [aws-gleam](https://github.com/Ulberg/aws-gleam).

```gleam
import aws/services/sesv2

pub fn main() {
  let assert Ok(client) = sesv2.new()
  sesv2.shutdown(client)
}
```

Operations take generated request/input records. Start from the generated
`*_default(...)` helper and override optional fields with Gleam record update.

Use `sesv2.new_with(settings, endpoint_params)` for explicit
`aws/config.Settings` and SES v2 endpoint-rule-set parameters.

Depends on [`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime) for
signing, credentials, endpoint resolution, retry, transport, and protocol
codecs.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_sesv2>.

## Source

<https://github.com/Ulberg/aws-gleam/tree/main/services/sesv2>

## License

Apache 2.0. See LICENSE.
