# Known hacks

All four items from the multi-service codegen / per-service
customizations work (commits `7f1fad0`, `c9330bd`) are now closed.
This file is kept as a record of what landed and where the proper
fixes live; remove it when the entries roll into release notes.

## 1. S3 `{Bucket}` is routed via endpointRuleSet — CLOSED

**Closed by:** codegen now emits a `build_<op>_endpoint_params(input)`
helper per operation whose input has `smithy.rules#contextParam`-
tagged members, and routes the per-op invoke through
`runtime.invoke_with_endpoint_params`. The S3 model's `Bucket`,
`Key`, `CopySource`, and `Prefix` members are all tagged with
`@contextParam`, so the resolved endpoint URL now reflects the
bucket (virtual-host subdomain by default, path prefix when
`ForcePathStyle: true` is set on the Client).

The `omit_uri_labels: ["Bucket"]` customization remains intentionally
— that mirrors the Rust SDK's codegen, which also emits S3 URI
templates without `{Bucket}` because the rule set places it
elsewhere (see `aws-sdk-rust/sdk/s3/src/operation/get_object.rs::
uri_base`, which writes only `/{Key}`). Confirmed against the rule-
set test fixtures in `test/fixtures/endpoints/s3-tests.json`:
virtual-host returns `https://<bucket>.s3.<region>.amazonaws.com`,
path-style returns `https://s3.<region>.amazonaws.com/<bucket>`,
both of which compose with the codegen-emitted `/<key>` to yield
the correct production URL.

Verified by:
* `grep "build_get_object_endpoint_params" src/aws/services/s3.gleam`
  shows the per-op param builder is emitted
* `grep "runtime.invoke_with_endpoint_params" src/aws/services/s3.gleam`
  counts every S3 op routing through the new path
* Existing endpoint corpus (`test/endpoint_fixtures_test.gleam`)
  continues to pass

## 2. Glacier tree-hash recursive 1 MiB algorithm — CLOSED

**Closed by:** `rest.glacier_tree_hash(body)` in
`src/aws/internal/codec/rest.gleam` now implements the canonical
recursive 1 MiB chunk algorithm. `rest.with_glacier_tree_hash_headers`
calls it for `X-Amz-Sha256-Tree-Hash`; `X-Amz-Content-Sha256` still
carries the flat SHA-256 of the body (matches the Rust SDK).
Verified against the Rust SDK's reference test vector
(`glacier_interceptors::treehash_checksum_tests::hash_value_test` —
11-byte `01245678912` × ~101 MiB → expected tree-hash
`3d417484359fc9f5a3bafd576dc47b8b2de2bf2d4fdac5aa2aff768f2210d386`).
Pinned by `test/glacier_tree_hash_test.gleam`.

## 3. Glacier tree-hash scoped to blob-payload ops — CLOSED

**Closed by:** `rest_request.build_request_module` now gates the
`with_glacier_tree_hash_headers` step on
`cats.payload` being `Ok(m)` with `m.target` ∈ {`RBlob`,
`RStreamingBlob`}. After `./scripts/regen.sh glacier`, the codegen
emits the tree-hash header on exactly `UploadArchive` and
`UploadMultipartPart` — matching the Rust SDK's
`GlacierTreeHashHeaderInterceptor` registration scope (which the
Rust codegen attaches at the same two operation sites).

## 4. Default headers insert-when-absent — CLOSED

**Closed by:** `rest_request.emit_default_headers_step` now calls
`rest.set_default_header(headers, name, value)` instead of
`dict.insert`. The runtime helper at
`aws/internal/codec/rest.set_default_header` does
`case dict.has_key { True -> headers; False -> dict.insert(...) }`
— mirrors the Rust SDK's `set_default_header` and the
`contains_key` guard inside `glacier_interceptors::
add_checksum_treehash`.

ApiGateway `Accept` and Glacier `X-Amz-Glacier-Version` now both
respect a caller-provided value on the rare future op model where a
`@httpHeader`-bound member collides with the default name.
