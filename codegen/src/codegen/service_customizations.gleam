//// Per-service customizations the Smithy model alone doesn't carry.
////
//// AWS service SDKs ship runtime interceptors that inject default
//// headers, default URI-label values, or strip parts of the URI
//// template that the underlying Smithy model still includes. None
//// of those are expressed as Smithy traits; the real SDKs hardcode
//// them per-service. We mirror that minimal-but-explicit table here
//// so the codegen can honor the same conventions instead of
//// allow-listing the cases.
////
//// Cross-references to the Rust SDK (`vendor/aws-sdk-rust/sdk/<svc>/`):
////   * Glacier — `glacier/src/glacier_interceptors.rs`
////   * ApiGateway — `apigateway/src/apigateway_interceptors.rs`
////   * S3 — handled via endpoint customization; we replicate the
////     observable part (strip `{Bucket}` from URI templates) since
////     the protocol-test runner only inspects the URI path.
////   * awsQueryCompatible — `aws.protocols#awsQueryCompatible` is a
////     real Smithy trait but only some protocols (awsJson, rpcv2Cbor)
////     honor it by emitting `x-amzn-query-mode: true`. Tracked here
////     so the awsJson emitter looks it up by service.

import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{type Option, None, Some}

/// Per-service codegen knobs. `default()` returns the no-customization
/// record; only services in `for_service_id` deviate.
pub type ServiceCustomization {
  ServiceCustomization(
    /// Static `(name, value)` pairs the codegen pre-populates on every
    /// op's request headers (e.g. Glacier's `X-Amz-Glacier-Version`,
    /// ApiGateway's `Accept: application/json`).
    default_headers: List(#(String, String)),
    /// URI-label member names to substitute with the given default
    /// value when the caller leaves them empty. Mirrors Rust SDK's
    /// `GlacierAccountIdAutofillInterceptor`.
    label_defaults: Dict(String, String),
    /// URI-label member names to drop from the URI template entirely
    /// — used by S3 where `{Bucket}` is a label in the Smithy model
    /// but goes into the Host header (virtual-host addressing), not
    /// the path. The codegen still surfaces the field on the input
    /// record so callers can pass it; the URI emitter just doesn't
    /// substitute it.
    omit_uri_labels: List(String),
    /// When `Some(version)`, emit `X-Amz-Glacier-Version` + compute
    /// `X-Amz-Content-Sha256` + `X-Amz-Sha256-Tree-Hash` from the
    /// request body. Mirrors `glacier_interceptors::GlacierApiVersion
    /// Interceptor` and `GlacierTreeHashHeaderInterceptor`. Single-
    /// chunk bodies have tree-hash == content-sha256; larger ones
    /// (multipart) follow the recursive 1 MB chunk pairing rule
    /// documented at https://docs.aws.amazon.com/amazonglacier/latest/dev/checksum-calculations.html
    /// — out of scope for this slice since the protocol-test corpus
    /// only carries single-chunk bodies.
    glacier_treehash: Bool,
  )
}

pub fn default() -> ServiceCustomization {
  ServiceCustomization(
    default_headers: [],
    label_defaults: dict.new(),
    omit_uri_labels: [],
    glacier_treehash: False,
  )
}

/// Look up a service's customization record by full Smithy ID. Returns
/// `default()` for services without custom rules. Match on the full
/// `<namespace>#<ShapeName>` so collisions between same-named services
/// in different namespaces stay disambiguated.
pub fn for_service_id(service_id: String) -> ServiceCustomization {
  case service_id {
    // ApiGateway: every op carries `Accept: application/json` by
    // SDK convention; not encoded as a Smithy trait.
    "com.amazonaws.apigateway#BackplaneControlService"
    | "com.amazonaws.apigateway#ApiGateway" ->
      ServiceCustomization(
        default_headers: [#("Accept", "application/json")],
        label_defaults: dict.new(),
        omit_uri_labels: [],
        glacier_treehash: False,
      )

    // Glacier: `X-Amz-Glacier-Version` on every op + autofill empty
    // accountId labels with `-` (per AWS docs, the literal "-" means
    // "use the caller's own account"). The tree-hash + content-sha256
    // headers come from the same interceptor; we tag the flag here
    // and let the codegen wire it onto body-carrying ops.
    "com.amazonaws.glacier#Glacier" ->
      ServiceCustomization(
        default_headers: [#("X-Amz-Glacier-Version", "2012-06-01")],
        label_defaults: dict.from_list([#("accountId", "-")]),
        omit_uri_labels: [],
        glacier_treehash: True,
      )

    // S3: `{Bucket}` is a `@httpLabel` in the Smithy model, but the
    // real SDK routes the bucket into the Host header (virtual-host
    // addressing) and serves an empty bucket segment in the URI path.
    // For the protocol-test runner — which only inspects the path —
    // dropping `{Bucket}` from the URI template is sufficient.
    "com.amazonaws.s3#AmazonS3" ->
      ServiceCustomization(
        default_headers: [],
        label_defaults: dict.new(),
        omit_uri_labels: ["Bucket"],
        glacier_treehash: False,
      )

    _ -> default()
  }
}

/// `True` when a service-level `aws.protocols#awsQueryCompatible`
/// flag should produce an `x-amzn-query-mode: true` request header on
/// every op (awsJson + rpcv2Cbor honor this; rest* protocols do not).
/// The trait is real Smithy; this helper exists only so awsjson's
/// emitter can ask one question instead of re-parsing trait dicts.
pub fn awsjson_query_compatible(query_compatible: Bool) -> Option(String) {
  case query_compatible {
    True -> Some("true")
    False -> None
  }
}

/// Header-merge helper used by the protocol emitters. Returns the
/// `defaults` first, then appends `op_headers`, so an op's own
/// `@httpHeader`-bound value (later) wins over the service-level
/// default if names collide.
pub fn merge_default_headers(
  defaults: List(#(String, String)),
  op_headers: List(#(String, String)),
) -> List(#(String, String)) {
  list.append(defaults, op_headers)
}
