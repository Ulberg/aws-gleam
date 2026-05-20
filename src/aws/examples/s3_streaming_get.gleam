//// End-to-end demo of S3 streaming GetObject.
////
//// Uses the codegen-emitted `s3.get_object_streaming` to fetch an
//// object whose body arrives as a `streaming.StreamingBody`
//// (chunked), then materialises the bytes via
//// `streaming.collect_to_bit_array_max` so the caller gets a hard
//// upper bound on memory use. Multi-GB objects skip the
//// materialisation step and consume chunks via
//// `streaming.fold_chunks` instead — the request itself is the
//// same.
////
//// Run as: `gleam run -m aws/examples/s3_streaming_get`
//// Requires AWS credentials reachable by the default chain and a
//// real bucket / key. Edit `bucket` and `key` below before
//// invoking.

import aws/internal/client/runtime
import aws/region as aws_region
import aws/services/s3
import aws/streaming
import gleam/bit_array
import gleam/int
import gleam/io
import gleam/option

const fallback_region: String = "eu-north-1"

const profile: String = "default"

const bucket: String = "your-bucket-here"

const key: String = "aws-gleam-demo/multipart.bin"

/// Cap downloaded bodies at 50 MiB — caller-side guard against an
/// unexpectedly-large object OOMing the process. Tune for the
/// workload; multi-GB objects should use `streaming.fold_chunks`
/// directly to stay bounded.
const max_download_bytes: Int = 52_428_800

pub fn main() {
  let resolved_region = case aws_region.resolve(profile:) {
    Ok(r) -> r
    Error(_) -> fallback_region
  }

  let client = s3.new(region: resolved_region)

  let input =
    s3.GetObjectRequest(
      bucket: option.Some(bucket),
      checksum_mode: option.None,
      expected_bucket_owner: option.None,
      if_match: option.None,
      if_modified_since: option.None,
      if_none_match: option.None,
      if_unmodified_since: option.None,
      key: option.Some(key),
      part_number: option.None,
      range: option.None,
      request_payer: option.None,
      response_cache_control: option.None,
      response_content_disposition: option.None,
      response_content_encoding: option.None,
      response_content_language: option.None,
      response_content_type: option.None,
      response_expires: option.None,
      sse_customer_algorithm: option.None,
      sse_customer_key: option.None,
      sse_customer_key_md5: option.None,
      version_id: option.None,
    )

  case
    streaming.collect_to_bit_array_max(
      s3.get_object_streaming(client, input),
      max_download_bytes,
    )
  {
    Ok(bytes) -> {
      io.println("get_object_streaming OK")
      io.println("  bytes: " <> int.to_string(bit_array.byte_size(bytes)))
    }
    Error(streaming.Transport(cause: cause)) ->
      io.println("get_object_streaming transport: " <> describe(cause))
    Error(streaming.TooLarge(max_bytes: n)) ->
      io.println(
        "get_object_streaming: body exceeded "
        <> int.to_string(n)
        <> " bytes; switch to streaming.fold_chunks for unbounded objects",
      )
    Error(streaming.InvalidUtf8) ->
      io.println(
        "get_object_streaming: unreachable — InvalidUtf8 only fires for collect_to_string_max",
      )
  }
}

fn describe(err: runtime.ClientError) -> String {
  case err {
    runtime.TransportError(_) -> "transport error"
    runtime.CredentialsError(_) -> "credentials error"
    runtime.DecodeError(reason: r) -> "decode: " <> r
    runtime.ServiceError(status: s, error_type: t, ..) ->
      "service: HTTP " <> int.to_string(s) <> " (" <> t <> ")"
  }
}
