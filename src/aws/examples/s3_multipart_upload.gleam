//// End-to-end demo of the S3 multipart-upload helper.
////
//// Uploads a small in-memory payload as `bucket/key` via the
//// multipart API, picking a part size with `transfer.part_size_for`
//// and threading a `content_type` through `UploadOptions`. Prints
//// the resulting upload_id + part count.
////
//// Run as: `gleam run -m aws/examples/s3_multipart_upload`
//// Requires AWS credentials reachable by the default chain and a
//// pre-existing bucket the caller's credentials can write to.
//// Edit `bucket` and `key` below before invoking.
////
//// In production callers usually want larger bodies than the demo
//// payload — `transfer.part_size_for(total_bytes)` keeps the part
//// count inside S3's 10,000-parts-per-upload cap for any size
//// from KB to multi-TB.

import aws/region as aws_region
import aws/s3/transfer
import aws/services/s3
import gleam/int
import gleam/io
import gleam/option

const fallback_region: String = "eu-north-1"

const profile: String = "default"

const bucket: String = "your-bucket-here"

const key: String = "aws-gleam-demo/multipart.bin"

pub fn main() {
  let resolved_region = case aws_region.resolve(profile:) {
    Ok(r) -> r
    Error(_) -> fallback_region
  }

  let client = s3.new(region: resolved_region)

  // Demo payload — replace with real bytes (a file read, an HTTP
  // response body, etc.) in production.
  let payload = <<"hello multipart world":utf8>>
  let total = 21
  let opts =
    transfer.UploadOptions(
      ..transfer.default_options(),
      content_type: option.Some("application/octet-stream"),
    )

  let part_size = transfer.part_size_for(total)
  case
    transfer.upload_with_options(
      client:,
      bucket:,
      key:,
      body: payload,
      part_size_bytes: part_size,
      options: opts,
    )
  {
    Ok(result) -> {
      io.println("upload OK")
      io.println("  upload_id:      " <> result.upload_id)
      io.println("  parts_uploaded: " <> int.to_string(result.parts_uploaded))
      io.println("  key:            " <> bucket <> "/" <> result.key)
    }
    Error(err) -> {
      io.println("upload failed: " <> describe(err))
    }
  }
}

fn describe(err: transfer.Error) -> String {
  case err {
    transfer.EmptyBody -> "EmptyBody — body was empty before any HTTP work"
    transfer.MissingUploadId -> "MissingUploadId — server returned no upload_id"
    transfer.CreateFailed(_) ->
      "CreateMultipartUpload failed (NoSuchBucket / AccessDenied / ...)"
    transfer.UploadPartFailed(part_number: n, ..) ->
      "UploadPart failed at part " <> int.to_string(n)
    transfer.CompleteFailed(_) ->
      "CompleteMultipartUpload failed; abort was attempted"
  }
}
