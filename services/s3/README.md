# aws_gleam_s3

Typed Gleam client for Amazon S3. The generated client comes from the upstream
Smithy model in [aws-gleam](https://github.com/Ulberg/aws-gleam); this package
also includes S3-specific helpers under `aws/s3/` for streaming and multipart
upload.

```gleam
import aws/services/s3

pub fn main() {
  let assert Ok(client) = s3.new()
  s3.shutdown(client)
}
```

Operations take generated request/input records. Start from the generated
`*_default(...)` helper and override optional fields with Gleam record update.

Use `s3.new_with(settings, endpoint_params)` for explicit `aws/config.Settings`
and S3 endpoint-rule-set parameters such as `UseFIPS`, `UseDualStack`, and
`ForcePathStyle`.

Depends on [`aws_gleam_runtime`](https://hex.pm/packages/aws_gleam_runtime) for
signing, credentials, endpoint resolution, retry, transport, streaming, and
protocol codecs.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_s3>.

## Source

<https://github.com/Ulberg/aws-gleam/tree/main/services/s3>

## License

Apache 2.0. See LICENSE.
