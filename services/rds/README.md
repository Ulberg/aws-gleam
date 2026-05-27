# aws_gleam_rds

Typed Gleam client for AWS rds. Auto-generated from the
upstream Smithy model in [aws-gleam](https://github.com/Ulberg/aws-gleam).

```gleam
import aws/services/rds

pub fn main() {
  let assert Ok(client) = rds.new()
  // ... typed ops, e.g. rds.<op>(client, input)
}
```

Depends on
[`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime)
for SigV4 signing, credentials, endpoint resolution, retry, and
the protocol codecs. Each AWS service ships as a separate hex
package so consumers only compile the services they import; the
SDK's full set of ~409 generated services lives at
<https://github.com/Ulberg/aws-gleam/tree/main/services>.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_rds>.

## License

Apache 2.0. See LICENSE.
