//// End-to-end smoke test of the generated S3 client.
////
//// Pipes everything through the typed API the codegen layer produces:
////
////   credentials → s3.new() → s3.list_buckets(...)
////
//// The full pipeline is exercised: provider chain → SigV4 signing →
//// HTTP send → XML body decoding via xml_decode + the generated
//// `decode_list_buckets_output_xml`. On success, the typed
//// `ListBucketsOutput` is printed with the bucket count.
////
//// Run as: `gleam run -m aws/examples/s3_get`
//// Requires AWS credentials reachable by the default chain.

import aws/region as aws_region
import aws/services/s3
import gleam/int
import gleam/io
import gleam/list
import gleam/option

const fallback_region: String = "eu-north-1"

const profile: String = "default"

pub fn main() {
  let resolved_region = case aws_region.resolve(profile: profile) {
    Ok(r) -> r
    Error(_) -> fallback_region
  }

  let client = s3.new(region: resolved_region)

  let input =
    s3.ListBucketsRequest(
      bucket_region: option.None,
      continuation_token: option.None,
      max_buckets: option.None,
      prefix: option.None,
    )

  case s3.list_buckets(client, input) {
    Ok(out) -> {
      io.println("ListBuckets OK")
      io.println(
        "  buckets: "
        <> case out.buckets {
          option.None -> "<no field>"
          option.Some(bs) -> int.to_string(list.length(bs))
        },
      )
    }
    Error(err) -> {
      io.println("ListBuckets failed: " <> describe(err))
    }
  }
}

fn describe(err: s3.ListBucketsError) -> String {
  case err {
    s3.ListBucketsErrorTransport(reason: r) -> "transport: " <> r
    s3.ListBucketsErrorUnknown(error_type: t, status: s, body: b) ->
      "service: HTTP " <> int.to_string(s) <> " (" <> t <> ")\n  body: " <> b
  }
}
