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
import gleam/dict.{type Dict}
import gleam/erlang/process
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result

/// Errors a multipart upload surfaces. `CreateFailed` /
/// `UploadPartFailed` / `CompleteFailed` wrap the underlying typed
/// S3 error so callers can pattern-match on the wire-side cause
/// (NoSuchBucket, AccessDenied, etc.). `UploadPartFailed` also
/// records which part number failed so callers know what to retry.
/// `MissingUploadId` fires if S3's `CreateMultipartUpload` response
/// arrives without an `upload_id` (should never happen in
/// production, but the wire-type is `Option(String)` so we surface
/// it explicitly rather than `assert`ing). `InvalidPartSize` rejects
/// caller-supplied part sizes outside S3's documented bounds before
/// any multipart-upload request reaches the bucket.
pub type Error {
  CreateFailed(cause: s3.CreateMultipartUploadError)
  UploadPartFailed(part_number: Int, cause: s3.UploadPartError)
  CompleteFailed(cause: s3.CompleteMultipartUploadError)
  MissingUploadId
  EmptyBody
  InvalidPartSize(part_size_bytes: Int)
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

/// Per-object metadata + access-control options applied at
/// `CreateMultipartUpload` time. Only `content_type`, `metadata`,
/// `acl`, `cache_control`, `content_encoding`,
/// `content_disposition`, `storage_class`, and
/// `server_side_encryption` are surfaced today — they cover the
/// 90% of S3 PutObject use cases (HTTP-content-metadata, ACL,
/// storage tier, SSE). Callers needing more exotic options
/// (object lock, grants, request payer, SSE-C, etc.) should call
/// `s3.create_multipart_upload` / `s3.upload_part` /
/// `s3.complete_multipart_upload` directly until / unless those
/// fields land on `UploadOptions`.
///
/// Construct with `default_options()` and override individual
/// fields via record-update syntax:
///
/// ```gleam
/// let opts = transfer.UploadOptions(
///   ..transfer.default_options(),
///   content_type: option.Some("application/json"),
///   cache_control: option.Some("max-age=3600"),
/// )
/// ```
pub type UploadOptions {
  UploadOptions(
    content_type: Option(String),
    content_encoding: Option(String),
    content_disposition: Option(String),
    cache_control: Option(String),
    metadata: Option(Dict(String, String)),
    acl: Option(s3.ObjectCannedACL),
    storage_class: Option(s3.StorageClass),
    server_side_encryption: Option(s3.ServerSideEncryption),
    /// Upper bound on outstanding `UploadPart` calls. `None`
    /// (default) keeps the sequential one-part-at-a-time
    /// coordinator. `Some(n)` fans out via OTP processes, capping
    /// in-flight parts to `n` — typical values 4-16 saturate a
    /// single Lambda's bandwidth without overwhelming S3's per-
    /// bucket rate limits. Errors short-circuit the whole batch
    /// (one failed part aborts the multipart upload).
    max_concurrency: Option(Int),
  )
}

/// All-`None` options — what `upload` / `upload_from_stream` pass
/// when callers don't supply their own. Equivalent to using
/// `s3.create_multipart_upload` with no metadata overrides; S3
/// applies its bucket-level defaults. `max_concurrency: None`
/// keeps the sequential coordinator — `with_max_concurrency` flips
/// it to the parallel path.
pub fn default_options() -> UploadOptions {
  UploadOptions(
    content_type: None,
    content_encoding: None,
    content_disposition: None,
    cache_control: None,
    metadata: None,
    acl: None,
    storage_class: None,
    server_side_encryption: None,
    max_concurrency: None,
  )
}

/// Override the parallel-upload concurrency cap on an existing
/// `UploadOptions`. `n` must be ≥ 1 — values ≤ 0 are coerced to
/// sequential (None) so callers can pass a derived count without
/// guarding it.
pub fn with_max_concurrency(opts: UploadOptions, n: Int) -> UploadOptions {
  let capped = case n >= 1 {
    True -> Some(n)
    False -> None
  }
  UploadOptions(..opts, max_concurrency: capped)
}

/// S3's documented minimum part size (5 MiB) for all parts except
/// the last. Smaller part sizes are rejected with `EntityTooSmall`
/// at `CompleteMultipartUpload` time; larger sizes cut down on
/// per-part round trips but raise outstanding-request memory.
pub const default_part_size_bytes: Int = 5_242_880

/// S3's maximum size for any individual multipart-upload part
/// (5 GiB). `upload` / `upload_from_stream` reject larger
/// `part_size_bytes` values up front so callers get a typed SDK
/// error instead of a later S3 service error.
pub const max_part_size_bytes: Int = 5_368_709_120

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
/// `part_size_bytes` must be between
/// `default_part_size_bytes` (5 MiB) and `max_part_size_bytes`
/// (5 GiB), inclusive. Invalid values return
/// `Error(InvalidPartSize(part_size_bytes))` before any HTTP work.
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
  upload_with_options(
    client:,
    bucket:,
    key:,
    body:,
    part_size_bytes:,
    options: default_options(),
  )
}

/// `upload` with caller-specified per-object metadata — sets HTTP
/// content metadata (Content-Type, Cache-Control, etc.), the
/// optional ACL / storage class / SSE choice, and any user
/// metadata at `CreateMultipartUpload` time. See `UploadOptions`
/// for the field set.
pub fn upload_with_options(
  client client: s3.Client,
  bucket bucket: String,
  key key: String,
  body body: BitArray,
  part_size_bytes part_size_bytes: Int,
  options options: UploadOptions,
) -> Result(UploadResult, Error) {
  use _ <- result.try(validate_part_size(part_size_bytes))
  case bit_array.byte_size(body) {
    0 -> Error(EmptyBody)
    _ ->
      coordinate(
        client,
        bucket,
        key,
        split_into_parts(body, part_size_bytes),
        options,
      )
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
/// reduce peak memory vs `upload(streaming.to_bit_array(body), ...)`.
/// Once `StreamingBody` grows a lazy `Source(...)` variant (file
/// handles, generators), this path picks up true bounded-memory
/// streaming for free.
///
/// `part_size_bytes` has the same validation as `upload`: it must
/// be between 5 MiB and 5 GiB, inclusive, or the function returns
/// `Error(InvalidPartSize(part_size_bytes))` before reading chunks
/// or creating the multipart upload.
pub fn upload_from_stream(
  client client: s3.Client,
  bucket bucket: String,
  key key: String,
  body body: StreamingBody,
  part_size_bytes part_size_bytes: Int,
) -> Result(UploadResult, Error) {
  upload_from_stream_with_options(
    client:,
    bucket:,
    key:,
    body:,
    part_size_bytes:,
    options: default_options(),
  )
}

/// `upload_from_stream` with caller-specified per-object metadata.
/// See `UploadOptions`.
pub fn upload_from_stream_with_options(
  client client: s3.Client,
  bucket bucket: String,
  key key: String,
  body body: StreamingBody,
  part_size_bytes part_size_bytes: Int,
  options options: UploadOptions,
) -> Result(UploadResult, Error) {
  use _ <- result.try(validate_part_size(part_size_bytes))
  let parts = rechunk_to_parts(body, part_size_bytes)
  case list.is_empty(parts) {
    True -> Error(EmptyBody)
    False -> coordinate(client, bucket, key, parts, options)
  }
}

fn validate_part_size(part_size: Int) -> Result(Nil, Error) {
  case part_size >= default_part_size_bytes && part_size <= max_part_size_bytes {
    True -> Ok(Nil)
    False -> Error(InvalidPartSize(part_size_bytes: part_size))
  }
}

fn coordinate(
  client: s3.Client,
  bucket: String,
  key: String,
  parts: List(BitArray),
  options: UploadOptions,
) -> Result(UploadResult, Error) {
  use create_out <- result.try(
    s3.create_multipart_upload(client, create_request(bucket, key, options))
    |> result.map_error(CreateFailed),
  )
  use upload_id <- result.try(option.to_result(
    create_out.upload_id,
    MissingUploadId,
  ))

  // From here on, any failure must trigger a best-effort abort so the
  // bucket doesn't accumulate dangling multipart uploads. `abort_on_error`
  // wraps both fallible steps with that cleanup.
  use completed_parts <- result.try(
    abort_on_error(
      client,
      bucket,
      key,
      upload_id,
      case options.max_concurrency {
        None -> upload_all_parts(client, bucket, key, upload_id, parts, 1, [])
        Some(n) ->
          upload_all_parts_parallel(client, bucket, key, upload_id, parts, n)
      },
    ),
  )
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

/// Parallel coordinator. Processes `parts` in batches of at most
/// `max_concurrency` simultaneously-in-flight `UploadPart` calls.
/// Each batch spawns a worker per part, awaits all results, then
/// the outer loop moves on to the next batch. Results are sorted
/// by part-number at the end so the `CompleteMultipartUpload`
/// request sees parts in ascending order (S3 requires it).
///
/// First failure in any batch short-circuits the whole upload —
/// the outer `coordinate` then issues a best-effort
/// `AbortMultipartUpload`.
fn upload_all_parts_parallel(
  client: s3.Client,
  bucket: String,
  key: String,
  upload_id: String,
  parts: List(BitArray),
  max_concurrency: Int,
) -> Result(List(s3.CompletedPart), Error) {
  let numbered = list.index_map(parts, fn(p, i) { #(i + 1, p) })
  upload_batches(client, bucket, key, upload_id, numbered, max_concurrency, [])
}

fn upload_batches(
  client: s3.Client,
  bucket: String,
  key: String,
  upload_id: String,
  remaining: List(#(Int, BitArray)),
  max_concurrency: Int,
  acc: List(s3.CompletedPart),
) -> Result(List(s3.CompletedPart), Error) {
  case remaining {
    [] ->
      Ok(
        list.sort(acc, by: fn(a, b) {
          int.compare(
            option.unwrap(a.part_number, 0),
            option.unwrap(b.part_number, 0),
          )
        }),
      )
    _ -> {
      let #(batch, rest) = take_split(remaining, max_concurrency)
      use batch_done <- result.try(upload_one_batch(
        client,
        bucket,
        key,
        upload_id,
        batch,
      ))
      upload_batches(
        client,
        bucket,
        key,
        upload_id,
        rest,
        max_concurrency,
        list.append(batch_done, acc),
      )
    }
  }
}

fn upload_one_batch(
  client: s3.Client,
  bucket: String,
  key: String,
  upload_id: String,
  batch: List(#(Int, BitArray)),
) -> Result(List(s3.CompletedPart), Error) {
  let inbox = process.new_subject()
  list.each(batch, fn(numbered) {
    let #(part_number, part) = numbered
    let _pid =
      process.spawn(fn() {
        let result = case
          s3.upload_part(
            client,
            empty_upload_part_request(bucket, key, upload_id, part_number, part),
          )
        {
          Ok(out) -> Ok(empty_completed_part(part_number, out.e_tag))
          Error(e) -> Error(UploadPartFailed(part_number:, cause: e))
        }
        process.send(inbox, result)
      })
    Nil
  })
  collect_batch_results(inbox, list.length(batch), [])
}

fn collect_batch_results(
  inbox: process.Subject(Result(s3.CompletedPart, Error)),
  remaining: Int,
  acc: List(s3.CompletedPart),
) -> Result(List(s3.CompletedPart), Error) {
  case remaining {
    0 -> Ok(acc)
    _ ->
      case process.receive_forever(inbox) {
        Ok(part) -> collect_batch_results(inbox, remaining - 1, [part, ..acc])
        Error(e) -> {
          // Drain remaining workers so they don't leak; we still
          // return the first error.
          drain_remaining(inbox, remaining - 1)
          Error(e)
        }
      }
  }
}

fn drain_remaining(
  inbox: process.Subject(Result(s3.CompletedPart, Error)),
  remaining: Int,
) -> Nil {
  case remaining {
    0 -> Nil
    _ -> {
      let _ = process.receive_forever(inbox)
      drain_remaining(inbox, remaining - 1)
    }
  }
}

/// Take the first `n` elements; return `(taken, rest)`. Used to
/// chunk the work-list into bounded-concurrency batches.
fn take_split(xs: List(a), n: Int) -> #(List(a), List(a)) {
  do_take_split(xs, n, [])
}

fn do_take_split(xs: List(a), n: Int, acc: List(a)) -> #(List(a), List(a)) {
  case xs, n {
    [], _ -> #(list.reverse(acc), [])
    _, 0 -> #(list.reverse(acc), xs)
    [x, ..rest], _ -> do_take_split(rest, n - 1, [x, ..acc])
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

fn create_request(
  bucket: String,
  key: String,
  options: UploadOptions,
) -> s3.CreateMultipartUploadRequest {
  s3.CreateMultipartUploadRequest(
    acl: options.acl,
    bucket: Some(bucket),
    bucket_key_enabled: None,
    cache_control: options.cache_control,
    checksum_algorithm: None,
    checksum_type: None,
    content_disposition: options.content_disposition,
    content_encoding: options.content_encoding,
    content_language: None,
    content_type: options.content_type,
    expected_bucket_owner: None,
    expires: None,
    grant_full_control: None,
    grant_read: None,
    grant_read_acp: None,
    grant_write_acp: None,
    key: Some(key),
    metadata: options.metadata,
    object_lock_legal_hold_status: None,
    object_lock_mode: None,
    object_lock_retain_until_date: None,
    request_payer: None,
    sse_customer_algorithm: None,
    sse_customer_key: None,
    sse_customer_key_md5: None,
    ssekms_encryption_context: None,
    ssekms_key_id: None,
    server_side_encryption: options.server_side_encryption,
    storage_class: options.storage_class,
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
