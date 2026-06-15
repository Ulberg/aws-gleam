# aws_gleam_rds

Typed Gleam client for Amazon RDS, generated from the upstream Smithy model in
[aws-gleam](https://github.com/Ulberg/aws-gleam).

```gleam
import aws/services/rds

pub fn main() {
  let assert Ok(client) = rds.new()
  rds.shutdown(client)
}
```

Operations take generated request/input records. Start from the generated
`*_default(...)` helper and override optional fields with Gleam record update.

Use `rds.new_with(settings, endpoint_params)` for explicit
`aws/config.Settings` and RDS endpoint-rule-set parameters.

Depends on [`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime) for
signing, credentials, endpoint resolution, retry, transport, and protocol
codecs.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_rds>.

## Source

<https://github.com/Ulberg/aws-gleam/tree/main/services/rds>

## License

Apache 2.0. See LICENSE.
