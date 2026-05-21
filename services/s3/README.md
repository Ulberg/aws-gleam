# aws_gleam_s3

Typed Gleam client for AWS s3. Auto-generated from the
upstream Smithy model in [aws-gleam](https://github.com/Ulberg/aws-gleam).

```gleam
import aws/services/s3

pub fn main() {
  let assert Ok(client) = s3.new_with_auto_region()
  // ... typed ops, e.g. s3.<op>(client, input)
}
```

Depends on [`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime)
for SigV4 signing, credentials, endpoint resolution, retry, and
the protocol codecs. Each AWS service ships as a separate hex
package so consumers only compile the services they import; the
SDK's full set of ~409 generated services lives at
<https://github.com/Ulberg/aws-gleam/tree/main/services>.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_s3>.

## License

Apache 2.0. See LICENSE.
