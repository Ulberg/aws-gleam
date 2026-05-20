# Known hacks

Shortcuts that landed during the multi-service codegen / per-service
customizations work (commits `7f1fad0`, `c9330bd`). Each closes a
protocol-test corpus case but is wrong-in-production at some layer.
Documented here so the next slice picks them up cleanly. Cross-
reference: `next_steps.md` Current focus items 7 and 8 cover the
proper-fix shape for the first two.

## 1. S3 `{Bucket}` is unconditionally stripped from URI templates

**Where:** `codegen/src/codegen/service_customizations.gleam`,
`for_service_id("com.amazonaws.s3#AmazonS3")` returns
`omit_uri_labels: ["Bucket"]`. `rest_request.rewrite_uri_template`
deletes `{Bucket}` and `{Bucket}/` from every S3 URI template.

**Why it landed:** the restXml protocol-test corpus's secondary
`com.amazonaws.s3#AmazonS3` service has 10 cases
(`S3DefaultAddressing`, `S3VirtualHostAddressing`, the dualstack /
accelerate variants, `S3PreservesLeadingDotSegmentInUriLabel`,
`S3EscapeObjectKeyInUriLabel`, etc.) that all expect URIs with the
bucket **not** in the path — because the real S3 SDK routes the
bucket into the Host-header subdomain (virtual-host addressing). The
runner only inspects the URI path, so stripping `{Bucket}` from the
template passes those cases.

**Production damage:** the **same customization key** fires for the
real S3 model (`vendor/aws-sdk-rust/aws-models/s3.json`,
service ID `com.amazonaws.s3#AmazonS3`). Every generated S3 op in
`src/aws/services/s3.gleam` now emits a URI **without the bucket**:

```
$ grep "let path = " src/aws/services/s3.gleam | head -5
  let path = "/{Key+}?x-id=AbortMultipartUpload"
  let path = "/{Key+}"
  let path = "/{Key+}?x-id=CopyObject"
  let path = "/"
  let path = "/?metadataConfiguration"
```

Nothing in our runtime puts the bucket back into the Host header
subdomain, so production callers using my code send requests with
**no bucket anywhere**. Real S3 ignores the bucket field entirely
and either routes to the root account or 400s.

**Allow-listed instead?** Currently no — the 10 cases pass via the
hack. `S3PathAddressing` (the 1 remaining allow-list entry) needs
bucket-in-path even under the hack, and is documented as the gap.

**Proper fix:** drive S3 URL assembly off the `endpointRuleSet`
evaluator (`endpoints.resolve`) rather than the codegen template-
substitution path. The resolver takes (region, bucket, `force_path_
style`, `use_dual_stack`, `use_fips`, S3-Express directory bucket
detection, S3 Outposts ARN, MRAP) and outputs a fully-resolved URL.
When that lands, the codegen stops touching S3 URI templates;
`omit_uri_labels` goes away; `S3PathAddressing` becomes a Client-
config question.

---

## 2. Glacier tree-hash is wrong for bodies larger than 1 MiB

**Where:** `src/aws/internal/codec/rest.gleam ::
with_glacier_tree_hash_headers`. Implementation:

```gleam
let digest = crypto.hex_encode(crypto.sha256(body))
// set both headers to `digest`
```

**Why it landed:** the restJson1 corpus's `GlacierChecksums` and
`GlacierMultipartChecksums` cases both use the body `"hello world"`
(11 bytes), and the expected `X-Amz-Sha256-Tree-Hash` /
`X-Amz-Content-Sha256` headers are both the single SHA-256 of
that string (`b94d27b9...`). Single-chunk bodies have tree-hash ==
content-sha256, so my implementation happens to be correct for that
specific fixture.

**Production damage:** the real Glacier tree-hash splits the body
into 1 MiB chunks, hashes each, then recursively pairwise-combines
adjacent digests until one remains
(https://docs.aws.amazon.com/amazonglacier/latest/dev/checksum-
calculations.html). Any caller uploading a body **larger than 1 MiB**
gets the wrong `X-Amz-Sha256-Tree-Hash`. Glacier rejects the upload
with `RequestTimeoutException` / `InvalidParameterValueException`
when the content checksum doesn't match. So `UploadArchive` archives
> 1 MiB fail; `UploadMultipartPart` parts > 1 MiB fail.

**Proper fix:** implement the recursive pairwise algorithm. Sketch
(in pure Gleam — `crypto.sha256` exists, `bit_array.slice` chunks):

```gleam
pub fn glacier_tree_hash(body: BitArray) -> BitArray {
  case bit_array.byte_size(body) {
    0 -> crypto.sha256(<<>>)
    _ -> tree_combine(list.map(chunk_into(body, 1_048_576), crypto.sha256))
  }
}
fn tree_combine(ds) {
  case ds { [single] -> single; _ -> tree_combine(pair_hash(ds)) }
}
fn pair_hash(ds) {
  case ds {
    [] -> []
    [x] -> [x]
    [l, r, ..rest] -> [crypto.sha256(<<l:bits, r:bits>>), ..pair_hash(rest)]
  }
}
```

Pin against AWS reference vectors at the same time.

---

## 3. Glacier tree-hash headers attach to every Glacier op, not just uploads

**Where:** `codegen/src/codegen/rest_request.gleam ::
build_request_module`. The `glacier_treehash` customization fires
unconditionally for every op of a Glacier service.

**Why it landed:** the customization table is per-service, not
per-op. `ListVaults`, `GetJobOutput`, `DescribeVault` — none of them
upload bodies — would get a `X-Amz-Sha256-Tree-Hash: sha256("")`
header attached.

**Production damage:** the empty-body sha256 (`e3b0c442...`) is a
syntactically-valid header value, and Glacier probably ignores it on
non-upload ops, so this is the mildest hack of the four. Still wrong
vs. the Rust SDK's `GlacierTreeHashHeaderInterceptor` registration
scope (only attached to upload ops via codegen).

**Proper fix:** gate the codegen-side step on the op carrying an
`@httpPayload`-bound body member (`cats.payload` is `Ok(_)` in
`rest_request.build_request_module`). One-line conditional change.

---

## 4. Service-level default headers overwrite caller-provided values

**Where:** `codegen/src/codegen/rest_request.gleam ::
emit_default_headers_step`. Emits a plain `let headers =
dict.insert(headers, name, value)` step, which is last-write-wins.
The customization step runs AFTER `emit_header_setup`, so a caller's
`@httpHeader`-bound member value is overwritten by the default.

**Why it landed:** mechanically simplest. The two services this
affects (ApiGateway `Accept`, Glacier `X-Amz-Glacier-Version`) don't
have `@httpHeader`-bound members named `Accept` or `X-Amz-Glacier-
Version` in their Smithy models, so the protocol-test corpus never
exercises the collision path. No fixture detects the bug.

**Production damage:** an ApiGateway caller passing their own
`Accept` header (via an input member with `@httpHeader("Accept")`)
would silently get it overwritten by `application/json`. Same shape
for any other service that lands here later.

**Proper fix:** insert-when-absent. Mirrors Rust SDK's
`set_default_header`:

```gleam
let headers = case dict.has_key(headers, name) {
  True -> headers
  False -> dict.insert(headers, name, value)
}
```

Also worth moving the customization-default-headers step BEFORE
`emit_header_setup` so a caller's value wins on collision even
without the guard (defense in depth).
