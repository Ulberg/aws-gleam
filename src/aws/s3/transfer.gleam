//// S3 multipart-upload helper. Splits a buffered body into parts,
//// runs `CreateMultipartUpload` → `UploadPart` × N →
//// `CompleteMultipartUpload`, and best-effort aborts the upload on
//// any failure so dangling uploads don't accumulate in the bucket
//// (S3 charges storage for incomplete multipart uploads until you
//// abort them, and large numbers of orphaned uploads slow down
//// `ListObjects`).
////
//// Two entry points: `upload` for callers that already have the
//// bytes in a `BitArray`, and `upload_from_stream` for callers
//// holding a `StreamingBody`. The streaming variant rechunks across
//// chunk boundaries so wire-side part sizes follow `part_size_bytes`
//// rather than the source's chunking. Both today hold the full body
//// in memory; bounded-memory streaming arrives when `StreamingBody`
//// grows a lazy `Source(...)` variant (file handles, generators).
////
//// The upload-coordination logic is sequential — parts upload one
//// at a time. Parallel uploads (the bandwidth-saturating common
//// case) want a Task-based fan-out around this helper; building
//// that lives in `aws/s3/transfer_parallel.gleam` once a use case
//// pins the right concurrency knob.

import aws/services/s3
import aws/streaming.{type StreamingBody}
import gleam/bit_array
import gleam/list
import gleam/option.{None, Some}
import gleam/result

/// Errors a multipart upload surfaces. `CreateFailed` /
/// `UploadPartFailed` / `CompleteFailed` wrap the underlying typed
/// S3 error so callers can pattern-match on the wire-side cause
/// (NoSuchBucket, AccessDenied, etc.). `UploadPartFailed` also
/// records which part number failed so callers know what to retry.
/// `MissingUploadId` fires if S3's `CreateMultipartUpload` response
/// arrives without an `upload_id` (should never happen in
/// production, but the wire-type is `Option(String)` so we surface
/// it explicitly rather than `assert`ing).
pub type Error {
  CreateFailed(cause: s3.CreateMultipartUploadError)
  UploadPartFailed(part_number: Int, cause: s3.UploadPartError)
  CompleteFailed(cause: s3.CompleteMultipartUploadError)
  MissingUploadId
  EmptyBody
}

/// Result of a successful multipart upload. `upload_id` is exposed
/// so callers can correlate with S3 access logs or with their own
/// audit trail.
pub type UploadResult {
  UploadResult(
    bucket: String,
    key: String,
    upload_id: String,
    parts_uploaded: Int,
  )
}

/// S3's documented minimum part size (5 MiB) for all parts except
/// the last. Smaller part sizes are rejected with `EntityTooSmall`
/// at `CompleteMultipartUpload` time; larger sizes cut down on
/// per-part round trips but raise outstanding-request memory.
pub const default_part_size_bytes: Int = 5_242_880

/// S3's hard cap on parts per multipart upload. Past 10,000 the
/// `Complete` call returns `InvalidArgument` regardless of total
/// size, so `part_size_for` scales `part_size_bytes` up for large
/// totals to stay inside this limit.
pub const max_parts_per_upload: Int = 10_000

/// Pick a part size large enough to fit `total_bytes` inside S3's
/// 10,000-parts-per-upload cap. Always returns at least
/// `default_part_size_bytes` (5 MiB, the S3 minimum). Use this to
/// drive `upload` / `upload_from_stream` when the body could be
/// arbitrarily large — under 50 GB it returns the 5 MiB default,
/// past 50 GB it scales up so the part count stays at or under
/// 10,000.
///
/// For zero or negative `total_bytes` the helper returns the
/// default — callers that don't know the size up front can pass 0
/// and accept the 5 MiB part size until they have a better estimate.
pub fn part_size_for(total_bytes: Int) -> Int {
  case total_bytes <= 0 {
    True -> default_part_size_bytes
    False -> {
      // ceil(total_bytes / max_parts_per_upload), so that
      // ceil(total_bytes / part_size) <= max_parts_per_upload.
      let needed =
        { total_bytes + max_parts_per_upload - 1 } / max_parts_per_upload
      case needed < default_part_size_bytes {
        True -> default_part_size_bytes
        False -> needed
      }
    }
  }
}

/// Upload `body` as `bucket/key` via S3's multipart API. Splits the
/// body into parts of `part_size_bytes` (the last part may be
/// smaller), uploads each, then finalises with
/// `CompleteMultipartUpload`.
///
/// Any failure mid-flight triggers a best-effort
/// `AbortMultipartUpload` so the bucket doesn't accumulate dangling
/// uploads. The abort's own success / failure is intentionally
/// silenced — the caller already has the more interesting error
/// from the step that failed.
///
/// An empty body returns `Error(EmptyBody)`; S3 rejects empty
/// multipart uploads with `EntityTooSmall`, so we short-circuit
/// before the create round trip.
pub fn upload(
  client client: s3.Client,
  bucket bucket: String,
  key key: String,
  body body: BitArray,
  part_size_bytes part_size_bytes: Int,
) -> Result(UploadResult, Error) {
  case bit_array.byte_size(body) {
    0 -> Error(EmptyBody)
    _ ->
      coordinate(client, bucket, key, split_into_parts(body, part_size_bytes))
  }
}

/// Same as `upload`, but takes a `StreamingBody` instead of a buffered
/// `BitArray`. Walks the body's chunks once, re-aggregating across
/// chunk boundaries so the wire-side part sizes follow
/// `part_size_bytes` rather than the source's chunking — useful when
/// the body comes from a chunked transport or builder that emits
/// frequent small chunks (request streaming, log ingestion, line-
/// oriented producers).
///
/// Today both `StreamingBody` representations (Buffered / Chunked)
/// hold their full bytes in memory, so this variant doesn't yet
/// reduce peak memory vs `upload(buffer_to_bit_array(body), ...)`.
/// Once `StreamingBody` grows a lazy `Source(...)` variant (file
/// handles, generators), this path picks up true bounded-memory
/// streaming for free.
pub fn upload_from_stream(
  client client: s3.Client,
  bucket bucket: String,
  key key: String,
  body body: StreamingBody,
  part_size_bytes part_size_bytes: Int,
) -> Result(UploadResult, Error) {
  let parts = rechunk_to_parts(body, part_size_bytes)
  case list.is_empty(parts) {
    True -> Error(EmptyBody)
    False -> coordinate(client, bucket, key, parts)
  }
}

fn coordinate(
  client: s3.Client,
  bucket: String,
  key: String,
  parts: List(BitArray),
) -> Result(UploadResult, Error) {
  use create_out <- result.try(
    s3.create_multipart_upload(client, empty_create_request(bucket, key))
    |> result.map_error(CreateFailed),
  )
  use upload_id <- result.try(option.to_result(
    create_out.upload_id,
    MissingUploadId,
  ))

  // From here on, any failure must trigger a best-effort abort so the
  // bucket doesn't accumulate dangling multipart uploads. `abort_on_error`
  // wraps both fallible steps with that cleanup.
  use completed_parts <- result.try(abort_on_error(
    client,
    bucket,
    key,
    upload_id,
    upload_all_parts(client, bucket, key, upload_id, parts, 1, []),
  ))
  use _ <- result.try(abort_on_error(
    client,
    bucket,
    key,
    upload_id,
    s3.complete_multipart_upload(
      client,
      empty_complete_request(bucket, key, upload_id, completed_parts),
    )
      |> result.map_error(CompleteFailed),
  ))
  Ok(UploadResult(
    bucket: bucket,
    key: key,
    upload_id: upload_id,
    parts_uploaded: list.length(completed_parts),
  ))
}

// Pass-through on `Ok`; on `Error` fire a best-effort `AbortMultipartUpload`
// before propagating the error. Used post-create to clean up dangling
// uploads when a part upload or complete call fails.
fn abort_on_error(
  client: s3.Client,
  bucket: String,
  key: String,
  upload_id: String,
  result: Result(a, Error),
) -> Result(a, Error) {
  case result {
    Ok(value) -> Ok(value)
    Error(e) -> {
      abort_quietly(client, bucket, key, upload_id)
      Error(e)
    }
  }
}

fn split_into_parts(bytes: BitArray, part_size: Int) -> List(BitArray) {
  let total = bit_array.byte_size(bytes)
  case total {
    0 -> []
    n if n <= part_size -> [bytes]
    _ -> {
      let assert Ok(head) = bit_array.slice(bytes, 0, part_size)
      let assert Ok(tail) = bit_array.slice(bytes, part_size, total - part_size)
      [head, ..split_into_parts(tail, part_size)]
    }
  }
}

/// Re-aggregate a `StreamingBody`'s chunks into parts of size
/// `part_size`. Walks each chunk once, appending to a running
/// buffer; flushes a part every time the buffer reaches
/// `part_size`, and flushes any remainder as the final (possibly
/// undersized) part.
fn rechunk_to_parts(body: StreamingBody, part_size: Int) -> List(BitArray) {
  let chunks = streaming.to_chunks(body)
  let #(parts_rev, leftover) =
    list.fold(chunks, #([], <<>>), fn(state, chunk) {
      let #(parts, buf) = state
      flush_full_parts(bit_array.append(buf, chunk), part_size, parts)
    })
  let parts_with_tail = case bit_array.byte_size(leftover) {
    0 -> parts_rev
    _ -> [leftover, ..parts_rev]
  }
  list.reverse(parts_with_tail)
}

fn flush_full_parts(
  buf: BitArray,
  part_size: Int,
  acc: List(BitArray),
) -> #(List(BitArray), BitArray) {
  let size = bit_array.byte_size(buf)
  case size >= part_size {
    True -> {
      let assert Ok(head) = bit_array.slice(buf, 0, part_size)
      let assert Ok(tail) = bit_array.slice(buf, part_size, size - part_size)
      flush_full_parts(tail, part_size, [head, ..acc])
    }
    False -> #(acc, buf)
  }
}

fn upload_all_parts(
  client: s3.Client,
  bucket: String,
  key: String,
  upload_id: String,
  parts: List(BitArray),
  next_part_number: Int,
  acc: List(s3.CompletedPart),
) -> Result(List(s3.CompletedPart), Error) {
  case parts {
    [] -> Ok(list.reverse(acc))
    [part, ..rest] -> {
      let req =
        empty_upload_part_request(
          bucket,
          key,
          upload_id,
          next_part_number,
          part,
        )
      use out <- result.try(
        s3.upload_part(client, req)
        |> result.map_error(fn(e) {
          UploadPartFailed(part_number: next_part_number, cause: e)
        }),
      )
      let completed = empty_completed_part(next_part_number, out.e_tag)
      upload_all_parts(
        client,
        bucket,
        key,
        upload_id,
        rest,
        next_part_number + 1,
        [completed, ..acc],
      )
    }
  }
}

fn abort_quietly(
  client: s3.Client,
  bucket: String,
  key: String,
  upload_id: String,
) -> Nil {
  let _ =
    s3.abort_multipart_upload(
      client,
      empty_abort_request(bucket, key, upload_id),
    )
  Nil
}

// ---------- request constructors ----------
//
// All four request types carry ~10–30 optional fields, none of
// which the helper needs to thread. Inlining the field-by-field
// `None` defaults keeps the call sites above terse and lets the
// codegen evolve the wire types without dragging this helper.

fn empty_create_request(
  bucket: String,
  key: String,
) -> s3.CreateMultipartUploadRequest {
  s3.CreateMultipartUploadRequest(
    acl: None,
    bucket: Some(bucket),
    bucket_key_enabled: None,
    cache_control: None,
    checksum_algorithm: None,
    checksum_type: None,
    content_disposition: None,
    content_encoding: None,
    content_language: None,
    content_type: None,
    expected_bucket_owner: None,
    expires: None,
    grant_full_control: None,
    grant_read: None,
    grant_read_acp: None,
    grant_write_acp: None,
    key: Some(key),
    metadata: None,
    object_lock_legal_hold_status: None,
    object_lock_mode: None,
    object_lock_retain_until_date: None,
    request_payer: None,
    sse_customer_algorithm: None,
    sse_customer_key: None,
    sse_customer_key_md5: None,
    ssekms_encryption_context: None,
    ssekms_key_id: None,
    server_side_encryption: None,
    storage_class: None,
    tagging: None,
    website_redirect_location: None,
  )
}

fn empty_upload_part_request(
  bucket: String,
  key: String,
  upload_id: String,
  part_number: Int,
  body: BitArray,
) -> s3.UploadPartRequest {
  s3.UploadPartRequest(
    body: Some(streaming.from_bit_array(body)),
    bucket: Some(bucket),
    checksum_algorithm: None,
    checksum_crc32: None,
    checksum_crc32_c: None,
    checksum_crc64_nvme: None,
    checksum_md5: None,
    checksum_sha1: None,
    checksum_sha256: None,
    checksum_sha512: None,
    checksum_xxhash128: None,
    checksum_xxhash3: None,
    checksum_xxhash64: None,
    content_length: Some(bit_array.byte_size(body)),
    content_md5: None,
    expected_bucket_owner: None,
    key: Some(key),
    part_number: Some(part_number),
    request_payer: None,
    sse_customer_algorithm: None,
    sse_customer_key: None,
    sse_customer_key_md5: None,
    upload_id: Some(upload_id),
  )
}

fn empty_completed_part(
  part_number: Int,
  e_tag: option.Option(String),
) -> s3.CompletedPart {
  s3.CompletedPart(
    checksum_crc32: None,
    checksum_crc32_c: None,
    checksum_crc64_nvme: None,
    checksum_md5: None,
    checksum_sha1: None,
    checksum_sha256: None,
    checksum_sha512: None,
    checksum_xxhash128: None,
    checksum_xxhash3: None,
    checksum_xxhash64: None,
    e_tag: e_tag,
    part_number: Some(part_number),
  )
}

fn empty_complete_request(
  bucket: String,
  key: String,
  upload_id: String,
  parts: List(s3.CompletedPart),
) -> s3.CompleteMultipartUploadRequest {
  s3.CompleteMultipartUploadRequest(
    bucket: Some(bucket),
    checksum_crc32: None,
    checksum_crc32_c: None,
    checksum_crc64_nvme: None,
    checksum_md5: None,
    checksum_sha1: None,
    checksum_sha256: None,
    checksum_sha512: None,
    checksum_type: None,
    checksum_xxhash128: None,
    checksum_xxhash3: None,
    checksum_xxhash64: None,
    expected_bucket_owner: None,
    if_match: None,
    if_none_match: None,
    key: Some(key),
    mpu_object_size: None,
    multipart_upload: Some(s3.CompletedMultipartUpload(parts: Some(parts))),
    request_payer: None,
    sse_customer_algorithm: None,
    sse_customer_key: None,
    sse_customer_key_md5: None,
    upload_id: Some(upload_id),
  )
}

fn empty_abort_request(
  bucket: String,
  key: String,
  upload_id: String,
) -> s3.AbortMultipartUploadRequest {
  s3.AbortMultipartUploadRequest(
    bucket: Some(bucket),
    expected_bucket_owner: None,
    if_match_initiated_time: None,
    key: Some(key),
    request_payer: None,
    upload_id: Some(upload_id),
  )
}
