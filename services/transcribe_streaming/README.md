# aws_transcribe_streaming

Typed Gleam client for AWS transcribe streaming. Auto-generated from the
upstream Smithy model in [aws-gleam](https://github.com/Ulberg/aws-gleam).

```gleam
import aws/services/transcribe_streaming

pub fn main() {
  let assert Ok(client) = transcribe_streaming.new_with_auto_region()
  // ... typed ops, e.g. transcribe_streaming.<op>(client, input)
}
```

Depends on [`aws_runtime`](https://hex.pm/packages/aws_runtime)
for SigV4 signing, credentials, endpoint resolution, retry, and
the protocol codecs. Each AWS service ships as a separate hex
package so consumers only compile the services they import; the
SDK's full set of ~409 generated services lives at
<https://github.com/Ulberg/aws-gleam/tree/main/services>.

## Documentation

Full docs at <https://hexdocs.pm/aws_transcribe_streaming>.

## License

Apache 2.0. See LICENSE.
