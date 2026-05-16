//// Generated from com.amazonaws.s3#AmazonS3 (restXml).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import aws/credentials
import aws/internal/client/awsjson as awsjson_client
import aws/internal/codec/json_float
import aws/internal/codec/rest
import aws/internal/http_send
import gleam/bit_array
import gleam/dict
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option
import gleam/string

pub opaque type Client {
  Client(config: awsjson_client.ClientConfig)
}

pub fn new(
  provider provider: credentials.Provider,
  region region: String,
) -> Client {
  Client(config: awsjson_client.default_config(provider, region, "s3", "s3"))
}

pub fn with_endpoint_url(client: Client, url: String) -> Client {
  Client(config: awsjson_client.with_endpoint_url(client.config, url))
}

pub fn with_http_send(client: Client, send: http_send.Send) -> Client {
  Client(config: awsjson_client.with_http_send(client.config, send))
}

pub type AbortMultipartUploadRequest {
  AbortMultipartUploadRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    if_match_initiated_time: option.Option(Int),
    key: option.Option(String),
    request_payer: option.Option(RequestPayer),
    upload_id: option.Option(String),
  )
}

pub fn encode_abort_multipart_upload_request_struct(
  input: AbortMultipartUploadRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_match_initiated_time {
    option.Some(v) -> [#("IfMatchInitiatedTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.upload_id {
    option.Some(v) -> [#("UploadId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_abort_multipart_upload_request_struct() -> decode.Decoder(
  AbortMultipartUploadRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use if_match_initiated_time <- decode.optional_field(
    "IfMatchInitiatedTime",
    option.None,
    decode.optional(decode.int),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use upload_id <- decode.optional_field(
    "UploadId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(AbortMultipartUploadRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    if_match_initiated_time: if_match_initiated_time,
    key: key,
    request_payer: request_payer,
    upload_id: upload_id,
  ))
}

pub type RequestPayer {
  RequestPayerRequester
}

pub fn encode_request_payer_enum(v: RequestPayer) -> json.Json {
  case v {
    RequestPayerRequester -> json.string("requester")
  }
}

pub fn decode_request_payer_enum() -> decode.Decoder(RequestPayer) {
  decode.then(decode.string, fn(s) {
    case s {
      "requester" -> decode.success(RequestPayerRequester)
      _ -> decode.failure(RequestPayerRequester, "unknown enum value")
    }
  })
}

pub type AbortMultipartUploadOutput {
  AbortMultipartUploadOutput(request_charged: option.Option(RequestCharged))
}

pub fn encode_abort_multipart_upload_output_struct(
  input: AbortMultipartUploadOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_abort_multipart_upload_output_struct() -> decode.Decoder(
  AbortMultipartUploadOutput,
) {
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  decode.success(AbortMultipartUploadOutput(request_charged: request_charged))
}

pub type RequestCharged {
  RequestChargedRequester
}

pub fn encode_request_charged_enum(v: RequestCharged) -> json.Json {
  case v {
    RequestChargedRequester -> json.string("requester")
  }
}

pub fn decode_request_charged_enum() -> decode.Decoder(RequestCharged) {
  decode.then(decode.string, fn(s) {
    case s {
      "requester" -> decode.success(RequestChargedRequester)
      _ -> decode.failure(RequestChargedRequester, "unknown enum value")
    }
  })
}

pub type CompleteMultipartUploadRequest {
  CompleteMultipartUploadRequest(
    bucket: option.Option(String),
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_type: option.Option(ChecksumType),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    expected_bucket_owner: option.Option(String),
    if_match: option.Option(String),
    if_none_match: option.Option(String),
    key: option.Option(String),
    mpu_object_size: option.Option(Int),
    multipart_upload: option.Option(CompletedMultipartUpload),
    request_payer: option.Option(RequestPayer),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    upload_id: option.Option(String),
  )
}

pub fn encode_complete_multipart_upload_request_struct(
  input: CompleteMultipartUploadRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_match {
    option.Some(v) -> [#("IfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_none_match {
    option.Some(v) -> [#("IfNoneMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.mpu_object_size {
    option.Some(v) -> [#("MpuObjectSize", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.multipart_upload {
    option.Some(v) -> [
      #("MultipartUpload", encode_completed_multipart_upload_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.upload_id {
    option.Some(v) -> [#("UploadId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_complete_multipart_upload_request_struct() -> decode.Decoder(
  CompleteMultipartUploadRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use if_match <- decode.optional_field(
    "IfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use if_none_match <- decode.optional_field(
    "IfNoneMatch",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use mpu_object_size <- decode.optional_field(
    "MpuObjectSize",
    option.None,
    decode.optional(decode.int),
  )
  use multipart_upload <- decode.optional_field(
    "MultipartUpload",
    option.None,
    decode.optional(decode_completed_multipart_upload_struct()),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use upload_id <- decode.optional_field(
    "UploadId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CompleteMultipartUploadRequest(
    bucket: bucket,
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_type: checksum_type,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    expected_bucket_owner: expected_bucket_owner,
    if_match: if_match,
    if_none_match: if_none_match,
    key: key,
    mpu_object_size: mpu_object_size,
    multipart_upload: multipart_upload,
    request_payer: request_payer,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    upload_id: upload_id,
  ))
}

pub type ChecksumType {
  ChecksumTypeComposite
  ChecksumTypeFullObject
}

pub fn encode_checksum_type_enum(v: ChecksumType) -> json.Json {
  case v {
    ChecksumTypeComposite -> json.string("COMPOSITE")
    ChecksumTypeFullObject -> json.string("FULL_OBJECT")
  }
}

pub fn decode_checksum_type_enum() -> decode.Decoder(ChecksumType) {
  decode.then(decode.string, fn(s) {
    case s {
      "COMPOSITE" -> decode.success(ChecksumTypeComposite)
      "FULL_OBJECT" -> decode.success(ChecksumTypeFullObject)
      _ -> decode.failure(ChecksumTypeComposite, "unknown enum value")
    }
  })
}

pub type CompletedMultipartUpload {
  CompletedMultipartUpload(parts: option.Option(List(CompletedPart)))
}

pub fn encode_completed_multipart_upload_struct(
  input: CompletedMultipartUpload,
) -> json.Json {
  let pairs = []
  let pairs = case input.parts {
    option.Some(v) -> [
      #("Parts", fn(xs) { json.array(xs, encode_completed_part_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_completed_multipart_upload_struct() -> decode.Decoder(
  CompletedMultipartUpload,
) {
  use parts <- decode.optional_field(
    "Parts",
    option.None,
    decode.optional(decode.list(decode_completed_part_struct())),
  )
  decode.success(CompletedMultipartUpload(parts: parts))
}

pub type CompletedPart {
  CompletedPart(
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    e_tag: option.Option(String),
    part_number: option.Option(Int),
  )
}

pub fn encode_completed_part_struct(input: CompletedPart) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number {
    option.Some(v) -> [#("PartNumber", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_completed_part_struct() -> decode.Decoder(CompletedPart) {
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use part_number <- decode.optional_field(
    "PartNumber",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(CompletedPart(
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    e_tag: e_tag,
    part_number: part_number,
  ))
}

pub type CompleteMultipartUploadOutput {
  CompleteMultipartUploadOutput(
    bucket: option.Option(String),
    bucket_key_enabled: option.Option(Bool),
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_type: option.Option(ChecksumType),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    e_tag: option.Option(String),
    expiration: option.Option(String),
    key: option.Option(String),
    location: option.Option(String),
    request_charged: option.Option(RequestCharged),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    version_id: option.Option(String),
  )
}

pub fn encode_complete_multipart_upload_output_struct(
  input: CompleteMultipartUploadOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expiration {
    option.Some(v) -> [#("Expiration", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.location {
    option.Some(v) -> [#("Location", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_complete_multipart_upload_output_struct() -> decode.Decoder(
  CompleteMultipartUploadOutput,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use expiration <- decode.optional_field(
    "Expiration",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use location <- decode.optional_field(
    "Location",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CompleteMultipartUploadOutput(
    bucket: bucket,
    bucket_key_enabled: bucket_key_enabled,
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_type: checksum_type,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    e_tag: e_tag,
    expiration: expiration,
    key: key,
    location: location,
    request_charged: request_charged,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    version_id: version_id,
  ))
}

pub type ServerSideEncryption {
  ServerSideEncryptionAes256
  ServerSideEncryptionAwsFsx
  ServerSideEncryptionAwsKms
  ServerSideEncryptionAwsKmsDsse
}

pub fn encode_server_side_encryption_enum(
  v: ServerSideEncryption,
) -> json.Json {
  case v {
    ServerSideEncryptionAes256 -> json.string("AES256")
    ServerSideEncryptionAwsFsx -> json.string("aws:fsx")
    ServerSideEncryptionAwsKms -> json.string("aws:kms")
    ServerSideEncryptionAwsKmsDsse -> json.string("aws:kms:dsse")
  }
}

pub fn decode_server_side_encryption_enum() -> decode.Decoder(
  ServerSideEncryption,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "AES256" -> decode.success(ServerSideEncryptionAes256)
      "aws:fsx" -> decode.success(ServerSideEncryptionAwsFsx)
      "aws:kms" -> decode.success(ServerSideEncryptionAwsKms)
      "aws:kms:dsse" -> decode.success(ServerSideEncryptionAwsKmsDsse)
      _ -> decode.failure(ServerSideEncryptionAes256, "unknown enum value")
    }
  })
}

pub type CopyObjectRequest {
  CopyObjectRequest(
    acl: option.Option(ObjectCannedACL),
    bucket: option.Option(String),
    bucket_key_enabled: option.Option(Bool),
    cache_control: option.Option(String),
    checksum_algorithm: option.Option(ChecksumAlgorithm),
    content_disposition: option.Option(String),
    content_encoding: option.Option(String),
    content_language: option.Option(String),
    content_type: option.Option(String),
    copy_source: option.Option(String),
    copy_source_if_match: option.Option(String),
    copy_source_if_modified_since: option.Option(Int),
    copy_source_if_none_match: option.Option(String),
    copy_source_if_unmodified_since: option.Option(Int),
    copy_source_sse_customer_algorithm: option.Option(String),
    copy_source_sse_customer_key: option.Option(String),
    copy_source_sse_customer_key_md5: option.Option(String),
    expected_bucket_owner: option.Option(String),
    expected_source_bucket_owner: option.Option(String),
    expires: option.Option(String),
    grant_full_control: option.Option(String),
    grant_read: option.Option(String),
    grant_read_acp: option.Option(String),
    grant_write_acp: option.Option(String),
    if_match: option.Option(String),
    if_none_match: option.Option(String),
    key: option.Option(String),
    metadata: option.Option(dict.Dict(String, String)),
    metadata_directive: option.Option(MetadataDirective),
    object_lock_legal_hold_status: option.Option(ObjectLockLegalHoldStatus),
    object_lock_mode: option.Option(ObjectLockMode),
    object_lock_retain_until_date: option.Option(Int),
    request_payer: option.Option(RequestPayer),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    ssekms_encryption_context: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    storage_class: option.Option(StorageClass),
    tagging: option.Option(String),
    tagging_directive: option.Option(TaggingDirective),
    website_redirect_location: option.Option(String),
  )
}

pub fn encode_copy_object_request_struct(
  input: CopyObjectRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.acl {
    option.Some(v) -> [#("ACL", encode_object_canned_acl_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.cache_control {
    option.Some(v) -> [#("CacheControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_algorithm {
    option.Some(v) -> [
      #("ChecksumAlgorithm", encode_checksum_algorithm_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.content_disposition {
    option.Some(v) -> [#("ContentDisposition", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_encoding {
    option.Some(v) -> [#("ContentEncoding", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_language {
    option.Some(v) -> [#("ContentLanguage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_type {
    option.Some(v) -> [#("ContentType", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source {
    option.Some(v) -> [#("CopySource", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_match {
    option.Some(v) -> [#("CopySourceIfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_modified_since {
    option.Some(v) -> [#("CopySourceIfModifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_none_match {
    option.Some(v) -> [#("CopySourceIfNoneMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_unmodified_since {
    option.Some(v) -> [#("CopySourceIfUnmodifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_sse_customer_algorithm {
    option.Some(v) -> [
      #("CopySourceSSECustomerAlgorithm", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.copy_source_sse_customer_key {
    option.Some(v) -> [#("CopySourceSSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_sse_customer_key_md5 {
    option.Some(v) -> [
      #("CopySourceSSECustomerKeyMD5", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_source_bucket_owner {
    option.Some(v) -> [#("ExpectedSourceBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expires {
    option.Some(v) -> [#("Expires", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_full_control {
    option.Some(v) -> [#("GrantFullControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_read {
    option.Some(v) -> [#("GrantRead", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_read_acp {
    option.Some(v) -> [#("GrantReadACP", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_write_acp {
    option.Some(v) -> [#("GrantWriteACP", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_match {
    option.Some(v) -> [#("IfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_none_match {
    option.Some(v) -> [#("IfNoneMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.metadata {
    option.Some(v) -> [
      #(
        "Metadata",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.metadata_directive {
    option.Some(v) -> [
      #("MetadataDirective", encode_metadata_directive_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_legal_hold_status {
    option.Some(v) -> [
      #(
        "ObjectLockLegalHoldStatus",
        encode_object_lock_legal_hold_status_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_mode {
    option.Some(v) -> [
      #("ObjectLockMode", encode_object_lock_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_retain_until_date {
    option.Some(v) -> [#("ObjectLockRetainUntilDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_encryption_context {
    option.Some(v) -> [#("SSEKMSEncryptionContext", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tagging {
    option.Some(v) -> [#("Tagging", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tagging_directive {
    option.Some(v) -> [
      #("TaggingDirective", encode_tagging_directive_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.website_redirect_location {
    option.Some(v) -> [#("WebsiteRedirectLocation", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_copy_object_request_struct() -> decode.Decoder(CopyObjectRequest) {
  use acl <- decode.optional_field(
    "ACL",
    option.None,
    decode.optional(decode_object_canned_acl_enum()),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use cache_control <- decode.optional_field(
    "CacheControl",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_algorithm <- decode.optional_field(
    "ChecksumAlgorithm",
    option.None,
    decode.optional(decode_checksum_algorithm_enum()),
  )
  use content_disposition <- decode.optional_field(
    "ContentDisposition",
    option.None,
    decode.optional(decode.string),
  )
  use content_encoding <- decode.optional_field(
    "ContentEncoding",
    option.None,
    decode.optional(decode.string),
  )
  use content_language <- decode.optional_field(
    "ContentLanguage",
    option.None,
    decode.optional(decode.string),
  )
  use content_type <- decode.optional_field(
    "ContentType",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source <- decode.optional_field(
    "CopySource",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_if_match <- decode.optional_field(
    "CopySourceIfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_if_modified_since <- decode.optional_field(
    "CopySourceIfModifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use copy_source_if_none_match <- decode.optional_field(
    "CopySourceIfNoneMatch",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_if_unmodified_since <- decode.optional_field(
    "CopySourceIfUnmodifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use copy_source_sse_customer_algorithm <- decode.optional_field(
    "CopySourceSSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_sse_customer_key <- decode.optional_field(
    "CopySourceSSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_sse_customer_key_md5 <- decode.optional_field(
    "CopySourceSSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use expected_source_bucket_owner <- decode.optional_field(
    "ExpectedSourceBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use expires <- decode.optional_field(
    "Expires",
    option.None,
    decode.optional(decode.string),
  )
  use grant_full_control <- decode.optional_field(
    "GrantFullControl",
    option.None,
    decode.optional(decode.string),
  )
  use grant_read <- decode.optional_field(
    "GrantRead",
    option.None,
    decode.optional(decode.string),
  )
  use grant_read_acp <- decode.optional_field(
    "GrantReadACP",
    option.None,
    decode.optional(decode.string),
  )
  use grant_write_acp <- decode.optional_field(
    "GrantWriteACP",
    option.None,
    decode.optional(decode.string),
  )
  use if_match <- decode.optional_field(
    "IfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use if_none_match <- decode.optional_field(
    "IfNoneMatch",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use metadata <- decode.optional_field(
    "Metadata",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use metadata_directive <- decode.optional_field(
    "MetadataDirective",
    option.None,
    decode.optional(decode_metadata_directive_enum()),
  )
  use object_lock_legal_hold_status <- decode.optional_field(
    "ObjectLockLegalHoldStatus",
    option.None,
    decode.optional(decode_object_lock_legal_hold_status_enum()),
  )
  use object_lock_mode <- decode.optional_field(
    "ObjectLockMode",
    option.None,
    decode.optional(decode_object_lock_mode_enum()),
  )
  use object_lock_retain_until_date <- decode.optional_field(
    "ObjectLockRetainUntilDate",
    option.None,
    decode.optional(decode.int),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_encryption_context <- decode.optional_field(
    "SSEKMSEncryptionContext",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  use tagging <- decode.optional_field(
    "Tagging",
    option.None,
    decode.optional(decode.string),
  )
  use tagging_directive <- decode.optional_field(
    "TaggingDirective",
    option.None,
    decode.optional(decode_tagging_directive_enum()),
  )
  use website_redirect_location <- decode.optional_field(
    "WebsiteRedirectLocation",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CopyObjectRequest(
    acl: acl,
    bucket: bucket,
    bucket_key_enabled: bucket_key_enabled,
    cache_control: cache_control,
    checksum_algorithm: checksum_algorithm,
    content_disposition: content_disposition,
    content_encoding: content_encoding,
    content_language: content_language,
    content_type: content_type,
    copy_source: copy_source,
    copy_source_if_match: copy_source_if_match,
    copy_source_if_modified_since: copy_source_if_modified_since,
    copy_source_if_none_match: copy_source_if_none_match,
    copy_source_if_unmodified_since: copy_source_if_unmodified_since,
    copy_source_sse_customer_algorithm: copy_source_sse_customer_algorithm,
    copy_source_sse_customer_key: copy_source_sse_customer_key,
    copy_source_sse_customer_key_md5: copy_source_sse_customer_key_md5,
    expected_bucket_owner: expected_bucket_owner,
    expected_source_bucket_owner: expected_source_bucket_owner,
    expires: expires,
    grant_full_control: grant_full_control,
    grant_read: grant_read,
    grant_read_acp: grant_read_acp,
    grant_write_acp: grant_write_acp,
    if_match: if_match,
    if_none_match: if_none_match,
    key: key,
    metadata: metadata,
    metadata_directive: metadata_directive,
    object_lock_legal_hold_status: object_lock_legal_hold_status,
    object_lock_mode: object_lock_mode,
    object_lock_retain_until_date: object_lock_retain_until_date,
    request_payer: request_payer,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    ssekms_encryption_context: ssekms_encryption_context,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    storage_class: storage_class,
    tagging: tagging,
    tagging_directive: tagging_directive,
    website_redirect_location: website_redirect_location,
  ))
}

pub type ObjectCannedACL {
  ObjectCannedACLAuthenticatedRead
  ObjectCannedACLAwsExecRead
  ObjectCannedACLBucketOwnerFullControl
  ObjectCannedACLBucketOwnerRead
  ObjectCannedACLPrivate
  ObjectCannedACLPublicRead
  ObjectCannedACLPublicReadWrite
}

pub fn encode_object_canned_acl_enum(v: ObjectCannedACL) -> json.Json {
  case v {
    ObjectCannedACLAuthenticatedRead -> json.string("authenticated-read")
    ObjectCannedACLAwsExecRead -> json.string("aws-exec-read")
    ObjectCannedACLBucketOwnerFullControl ->
      json.string("bucket-owner-full-control")
    ObjectCannedACLBucketOwnerRead -> json.string("bucket-owner-read")
    ObjectCannedACLPrivate -> json.string("private")
    ObjectCannedACLPublicRead -> json.string("public-read")
    ObjectCannedACLPublicReadWrite -> json.string("public-read-write")
  }
}

pub fn decode_object_canned_acl_enum() -> decode.Decoder(ObjectCannedACL) {
  decode.then(decode.string, fn(s) {
    case s {
      "authenticated-read" -> decode.success(ObjectCannedACLAuthenticatedRead)
      "aws-exec-read" -> decode.success(ObjectCannedACLAwsExecRead)
      "bucket-owner-full-control" ->
        decode.success(ObjectCannedACLBucketOwnerFullControl)
      "bucket-owner-read" -> decode.success(ObjectCannedACLBucketOwnerRead)
      "private" -> decode.success(ObjectCannedACLPrivate)
      "public-read" -> decode.success(ObjectCannedACLPublicRead)
      "public-read-write" -> decode.success(ObjectCannedACLPublicReadWrite)
      _ ->
        decode.failure(ObjectCannedACLAuthenticatedRead, "unknown enum value")
    }
  })
}

pub type ChecksumAlgorithm {
  ChecksumAlgorithmCrc32
  ChecksumAlgorithmCrc32c
  ChecksumAlgorithmCrc64nvme
  ChecksumAlgorithmMd5
  ChecksumAlgorithmSha1
  ChecksumAlgorithmSha256
  ChecksumAlgorithmSha512
  ChecksumAlgorithmXxhash128
  ChecksumAlgorithmXxhash3
  ChecksumAlgorithmXxhash64
}

pub fn encode_checksum_algorithm_enum(v: ChecksumAlgorithm) -> json.Json {
  case v {
    ChecksumAlgorithmCrc32 -> json.string("CRC32")
    ChecksumAlgorithmCrc32c -> json.string("CRC32C")
    ChecksumAlgorithmCrc64nvme -> json.string("CRC64NVME")
    ChecksumAlgorithmMd5 -> json.string("MD5")
    ChecksumAlgorithmSha1 -> json.string("SHA1")
    ChecksumAlgorithmSha256 -> json.string("SHA256")
    ChecksumAlgorithmSha512 -> json.string("SHA512")
    ChecksumAlgorithmXxhash128 -> json.string("XXHASH128")
    ChecksumAlgorithmXxhash3 -> json.string("XXHASH3")
    ChecksumAlgorithmXxhash64 -> json.string("XXHASH64")
  }
}

pub fn decode_checksum_algorithm_enum() -> decode.Decoder(ChecksumAlgorithm) {
  decode.then(decode.string, fn(s) {
    case s {
      "CRC32" -> decode.success(ChecksumAlgorithmCrc32)
      "CRC32C" -> decode.success(ChecksumAlgorithmCrc32c)
      "CRC64NVME" -> decode.success(ChecksumAlgorithmCrc64nvme)
      "MD5" -> decode.success(ChecksumAlgorithmMd5)
      "SHA1" -> decode.success(ChecksumAlgorithmSha1)
      "SHA256" -> decode.success(ChecksumAlgorithmSha256)
      "SHA512" -> decode.success(ChecksumAlgorithmSha512)
      "XXHASH128" -> decode.success(ChecksumAlgorithmXxhash128)
      "XXHASH3" -> decode.success(ChecksumAlgorithmXxhash3)
      "XXHASH64" -> decode.success(ChecksumAlgorithmXxhash64)
      _ -> decode.failure(ChecksumAlgorithmCrc32, "unknown enum value")
    }
  })
}

pub type MetadataDirective {
  MetadataDirectiveCopy
  MetadataDirectiveReplace
}

pub fn encode_metadata_directive_enum(v: MetadataDirective) -> json.Json {
  case v {
    MetadataDirectiveCopy -> json.string("COPY")
    MetadataDirectiveReplace -> json.string("REPLACE")
  }
}

pub fn decode_metadata_directive_enum() -> decode.Decoder(MetadataDirective) {
  decode.then(decode.string, fn(s) {
    case s {
      "COPY" -> decode.success(MetadataDirectiveCopy)
      "REPLACE" -> decode.success(MetadataDirectiveReplace)
      _ -> decode.failure(MetadataDirectiveCopy, "unknown enum value")
    }
  })
}

pub type ObjectLockLegalHoldStatus {
  ObjectLockLegalHoldStatusOff
  ObjectLockLegalHoldStatusOn
}

pub fn encode_object_lock_legal_hold_status_enum(
  v: ObjectLockLegalHoldStatus,
) -> json.Json {
  case v {
    ObjectLockLegalHoldStatusOff -> json.string("OFF")
    ObjectLockLegalHoldStatusOn -> json.string("ON")
  }
}

pub fn decode_object_lock_legal_hold_status_enum() -> decode.Decoder(
  ObjectLockLegalHoldStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "OFF" -> decode.success(ObjectLockLegalHoldStatusOff)
      "ON" -> decode.success(ObjectLockLegalHoldStatusOn)
      _ -> decode.failure(ObjectLockLegalHoldStatusOff, "unknown enum value")
    }
  })
}

pub type ObjectLockMode {
  ObjectLockModeCompliance
  ObjectLockModeGovernance
}

pub fn encode_object_lock_mode_enum(v: ObjectLockMode) -> json.Json {
  case v {
    ObjectLockModeCompliance -> json.string("COMPLIANCE")
    ObjectLockModeGovernance -> json.string("GOVERNANCE")
  }
}

pub fn decode_object_lock_mode_enum() -> decode.Decoder(ObjectLockMode) {
  decode.then(decode.string, fn(s) {
    case s {
      "COMPLIANCE" -> decode.success(ObjectLockModeCompliance)
      "GOVERNANCE" -> decode.success(ObjectLockModeGovernance)
      _ -> decode.failure(ObjectLockModeCompliance, "unknown enum value")
    }
  })
}

pub type StorageClass {
  StorageClassDeepArchive
  StorageClassExpressOnezone
  StorageClassFsxOntap
  StorageClassFsxOpenzfs
  StorageClassGlacier
  StorageClassGlacierIr
  StorageClassIntelligentTiering
  StorageClassOnezoneIa
  StorageClassOutposts
  StorageClassReducedRedundancy
  StorageClassSnow
  StorageClassStandard
  StorageClassStandardIa
}

pub fn encode_storage_class_enum(v: StorageClass) -> json.Json {
  case v {
    StorageClassDeepArchive -> json.string("DEEP_ARCHIVE")
    StorageClassExpressOnezone -> json.string("EXPRESS_ONEZONE")
    StorageClassFsxOntap -> json.string("FSX_ONTAP")
    StorageClassFsxOpenzfs -> json.string("FSX_OPENZFS")
    StorageClassGlacier -> json.string("GLACIER")
    StorageClassGlacierIr -> json.string("GLACIER_IR")
    StorageClassIntelligentTiering -> json.string("INTELLIGENT_TIERING")
    StorageClassOnezoneIa -> json.string("ONEZONE_IA")
    StorageClassOutposts -> json.string("OUTPOSTS")
    StorageClassReducedRedundancy -> json.string("REDUCED_REDUNDANCY")
    StorageClassSnow -> json.string("SNOW")
    StorageClassStandard -> json.string("STANDARD")
    StorageClassStandardIa -> json.string("STANDARD_IA")
  }
}

pub fn decode_storage_class_enum() -> decode.Decoder(StorageClass) {
  decode.then(decode.string, fn(s) {
    case s {
      "DEEP_ARCHIVE" -> decode.success(StorageClassDeepArchive)
      "EXPRESS_ONEZONE" -> decode.success(StorageClassExpressOnezone)
      "FSX_ONTAP" -> decode.success(StorageClassFsxOntap)
      "FSX_OPENZFS" -> decode.success(StorageClassFsxOpenzfs)
      "GLACIER" -> decode.success(StorageClassGlacier)
      "GLACIER_IR" -> decode.success(StorageClassGlacierIr)
      "INTELLIGENT_TIERING" -> decode.success(StorageClassIntelligentTiering)
      "ONEZONE_IA" -> decode.success(StorageClassOnezoneIa)
      "OUTPOSTS" -> decode.success(StorageClassOutposts)
      "REDUCED_REDUNDANCY" -> decode.success(StorageClassReducedRedundancy)
      "SNOW" -> decode.success(StorageClassSnow)
      "STANDARD" -> decode.success(StorageClassStandard)
      "STANDARD_IA" -> decode.success(StorageClassStandardIa)
      _ -> decode.failure(StorageClassDeepArchive, "unknown enum value")
    }
  })
}

pub type TaggingDirective {
  TaggingDirectiveCopy
  TaggingDirectiveReplace
}

pub fn encode_tagging_directive_enum(v: TaggingDirective) -> json.Json {
  case v {
    TaggingDirectiveCopy -> json.string("COPY")
    TaggingDirectiveReplace -> json.string("REPLACE")
  }
}

pub fn decode_tagging_directive_enum() -> decode.Decoder(TaggingDirective) {
  decode.then(decode.string, fn(s) {
    case s {
      "COPY" -> decode.success(TaggingDirectiveCopy)
      "REPLACE" -> decode.success(TaggingDirectiveReplace)
      _ -> decode.failure(TaggingDirectiveCopy, "unknown enum value")
    }
  })
}

pub type CopyObjectOutput {
  CopyObjectOutput(
    bucket_key_enabled: option.Option(Bool),
    copy_object_result: option.Option(CopyObjectResult),
    copy_source_version_id: option.Option(String),
    expiration: option.Option(String),
    request_charged: option.Option(RequestCharged),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    ssekms_encryption_context: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    version_id: option.Option(String),
  )
}

pub fn encode_copy_object_output_struct(input: CopyObjectOutput) -> json.Json {
  let pairs = []
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_object_result {
    option.Some(v) -> [
      #("CopyObjectResult", encode_copy_object_result_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.copy_source_version_id {
    option.Some(v) -> [#("CopySourceVersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expiration {
    option.Some(v) -> [#("Expiration", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_encryption_context {
    option.Some(v) -> [#("SSEKMSEncryptionContext", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_copy_object_output_struct() -> decode.Decoder(CopyObjectOutput) {
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use copy_object_result <- decode.optional_field(
    "CopyObjectResult",
    option.None,
    decode.optional(decode_copy_object_result_struct()),
  )
  use copy_source_version_id <- decode.optional_field(
    "CopySourceVersionId",
    option.None,
    decode.optional(decode.string),
  )
  use expiration <- decode.optional_field(
    "Expiration",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_encryption_context <- decode.optional_field(
    "SSEKMSEncryptionContext",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CopyObjectOutput(
    bucket_key_enabled: bucket_key_enabled,
    copy_object_result: copy_object_result,
    copy_source_version_id: copy_source_version_id,
    expiration: expiration,
    request_charged: request_charged,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key_md5: sse_customer_key_md5,
    ssekms_encryption_context: ssekms_encryption_context,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    version_id: version_id,
  ))
}

pub type CopyObjectResult {
  CopyObjectResult(
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_type: option.Option(ChecksumType),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    e_tag: option.Option(String),
    last_modified: option.Option(Int),
  )
}

pub fn encode_copy_object_result_struct(input: CopyObjectResult) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_copy_object_result_struct() -> decode.Decoder(CopyObjectResult) {
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(CopyObjectResult(
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_type: checksum_type,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    e_tag: e_tag,
    last_modified: last_modified,
  ))
}

pub type CreateBucketRequest {
  CreateBucketRequest(
    acl: option.Option(BucketCannedACL),
    bucket: option.Option(String),
    bucket_namespace: option.Option(BucketNamespace),
    create_bucket_configuration: option.Option(CreateBucketConfiguration),
    grant_full_control: option.Option(String),
    grant_read: option.Option(String),
    grant_read_acp: option.Option(String),
    grant_write: option.Option(String),
    grant_write_acp: option.Option(String),
    object_lock_enabled_for_bucket: option.Option(Bool),
    object_ownership: option.Option(ObjectOwnership),
  )
}

pub fn encode_create_bucket_request_struct(
  input: CreateBucketRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.acl {
    option.Some(v) -> [#("ACL", encode_bucket_canned_acl_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_namespace {
    option.Some(v) -> [
      #("BucketNamespace", encode_bucket_namespace_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.create_bucket_configuration {
    option.Some(v) -> [
      #(
        "CreateBucketConfiguration",
        encode_create_bucket_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.grant_full_control {
    option.Some(v) -> [#("GrantFullControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_read {
    option.Some(v) -> [#("GrantRead", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_read_acp {
    option.Some(v) -> [#("GrantReadACP", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_write {
    option.Some(v) -> [#("GrantWrite", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_write_acp {
    option.Some(v) -> [#("GrantWriteACP", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_lock_enabled_for_bucket {
    option.Some(v) -> [#("ObjectLockEnabledForBucket", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_ownership {
    option.Some(v) -> [
      #("ObjectOwnership", encode_object_ownership_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_bucket_request_struct() -> decode.Decoder(
  CreateBucketRequest,
) {
  use acl <- decode.optional_field(
    "ACL",
    option.None,
    decode.optional(decode_bucket_canned_acl_enum()),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_namespace <- decode.optional_field(
    "BucketNamespace",
    option.None,
    decode.optional(decode_bucket_namespace_enum()),
  )
  use create_bucket_configuration <- decode.optional_field(
    "CreateBucketConfiguration",
    option.None,
    decode.optional(decode_create_bucket_configuration_struct()),
  )
  use grant_full_control <- decode.optional_field(
    "GrantFullControl",
    option.None,
    decode.optional(decode.string),
  )
  use grant_read <- decode.optional_field(
    "GrantRead",
    option.None,
    decode.optional(decode.string),
  )
  use grant_read_acp <- decode.optional_field(
    "GrantReadACP",
    option.None,
    decode.optional(decode.string),
  )
  use grant_write <- decode.optional_field(
    "GrantWrite",
    option.None,
    decode.optional(decode.string),
  )
  use grant_write_acp <- decode.optional_field(
    "GrantWriteACP",
    option.None,
    decode.optional(decode.string),
  )
  use object_lock_enabled_for_bucket <- decode.optional_field(
    "ObjectLockEnabledForBucket",
    option.None,
    decode.optional(decode.bool),
  )
  use object_ownership <- decode.optional_field(
    "ObjectOwnership",
    option.None,
    decode.optional(decode_object_ownership_enum()),
  )
  decode.success(CreateBucketRequest(
    acl: acl,
    bucket: bucket,
    bucket_namespace: bucket_namespace,
    create_bucket_configuration: create_bucket_configuration,
    grant_full_control: grant_full_control,
    grant_read: grant_read,
    grant_read_acp: grant_read_acp,
    grant_write: grant_write,
    grant_write_acp: grant_write_acp,
    object_lock_enabled_for_bucket: object_lock_enabled_for_bucket,
    object_ownership: object_ownership,
  ))
}

pub type BucketCannedACL {
  BucketCannedACLAuthenticatedRead
  BucketCannedACLPrivate
  BucketCannedACLPublicRead
  BucketCannedACLPublicReadWrite
}

pub fn encode_bucket_canned_acl_enum(v: BucketCannedACL) -> json.Json {
  case v {
    BucketCannedACLAuthenticatedRead -> json.string("authenticated-read")
    BucketCannedACLPrivate -> json.string("private")
    BucketCannedACLPublicRead -> json.string("public-read")
    BucketCannedACLPublicReadWrite -> json.string("public-read-write")
  }
}

pub fn decode_bucket_canned_acl_enum() -> decode.Decoder(BucketCannedACL) {
  decode.then(decode.string, fn(s) {
    case s {
      "authenticated-read" -> decode.success(BucketCannedACLAuthenticatedRead)
      "private" -> decode.success(BucketCannedACLPrivate)
      "public-read" -> decode.success(BucketCannedACLPublicRead)
      "public-read-write" -> decode.success(BucketCannedACLPublicReadWrite)
      _ ->
        decode.failure(BucketCannedACLAuthenticatedRead, "unknown enum value")
    }
  })
}

pub type BucketNamespace {
  BucketNamespaceAccountRegional
  BucketNamespaceGlobal
}

pub fn encode_bucket_namespace_enum(v: BucketNamespace) -> json.Json {
  case v {
    BucketNamespaceAccountRegional -> json.string("account-regional")
    BucketNamespaceGlobal -> json.string("global")
  }
}

pub fn decode_bucket_namespace_enum() -> decode.Decoder(BucketNamespace) {
  decode.then(decode.string, fn(s) {
    case s {
      "account-regional" -> decode.success(BucketNamespaceAccountRegional)
      "global" -> decode.success(BucketNamespaceGlobal)
      _ -> decode.failure(BucketNamespaceAccountRegional, "unknown enum value")
    }
  })
}

pub type CreateBucketConfiguration {
  CreateBucketConfiguration(
    bucket: option.Option(BucketInfo),
    location: option.Option(LocationInfo),
    location_constraint: option.Option(BucketLocationConstraint),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_create_bucket_configuration_struct(
  input: CreateBucketConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", encode_bucket_info_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.location {
    option.Some(v) -> [#("Location", encode_location_info_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.location_constraint {
    option.Some(v) -> [
      #("LocationConstraint", encode_bucket_location_constraint_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_bucket_configuration_struct() -> decode.Decoder(
  CreateBucketConfiguration,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode_bucket_info_struct()),
  )
  use location <- decode.optional_field(
    "Location",
    option.None,
    decode.optional(decode_location_info_struct()),
  )
  use location_constraint <- decode.optional_field(
    "LocationConstraint",
    option.None,
    decode.optional(decode_bucket_location_constraint_enum()),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(CreateBucketConfiguration(
    bucket: bucket,
    location: location,
    location_constraint: location_constraint,
    tags: tags,
  ))
}

pub type BucketInfo {
  BucketInfo(
    data_redundancy: option.Option(DataRedundancy),
    type_: option.Option(BucketType),
  )
}

pub fn encode_bucket_info_struct(input: BucketInfo) -> json.Json {
  let pairs = []
  let pairs = case input.data_redundancy {
    option.Some(v) -> [
      #("DataRedundancy", encode_data_redundancy_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.type_ {
    option.Some(v) -> [#("Type", encode_bucket_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_bucket_info_struct() -> decode.Decoder(BucketInfo) {
  use data_redundancy <- decode.optional_field(
    "DataRedundancy",
    option.None,
    decode.optional(decode_data_redundancy_enum()),
  )
  use type_ <- decode.optional_field(
    "Type",
    option.None,
    decode.optional(decode_bucket_type_enum()),
  )
  decode.success(BucketInfo(data_redundancy: data_redundancy, type_: type_))
}

pub type DataRedundancy {
  DataRedundancySingleavailabilityzone
  DataRedundancySinglelocalzone
}

pub fn encode_data_redundancy_enum(v: DataRedundancy) -> json.Json {
  case v {
    DataRedundancySingleavailabilityzone ->
      json.string("SingleAvailabilityZone")
    DataRedundancySinglelocalzone -> json.string("SingleLocalZone")
  }
}

pub fn decode_data_redundancy_enum() -> decode.Decoder(DataRedundancy) {
  decode.then(decode.string, fn(s) {
    case s {
      "SingleAvailabilityZone" ->
        decode.success(DataRedundancySingleavailabilityzone)
      "SingleLocalZone" -> decode.success(DataRedundancySinglelocalzone)
      _ ->
        decode.failure(
          DataRedundancySingleavailabilityzone,
          "unknown enum value",
        )
    }
  })
}

pub type BucketType {
  BucketTypeDirectory
}

pub fn encode_bucket_type_enum(v: BucketType) -> json.Json {
  case v {
    BucketTypeDirectory -> json.string("Directory")
  }
}

pub fn decode_bucket_type_enum() -> decode.Decoder(BucketType) {
  decode.then(decode.string, fn(s) {
    case s {
      "Directory" -> decode.success(BucketTypeDirectory)
      _ -> decode.failure(BucketTypeDirectory, "unknown enum value")
    }
  })
}

pub type LocationInfo {
  LocationInfo(name: option.Option(String), type_: option.Option(LocationType))
}

pub fn encode_location_info_struct(input: LocationInfo) -> json.Json {
  let pairs = []
  let pairs = case input.name {
    option.Some(v) -> [#("Name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.type_ {
    option.Some(v) -> [#("Type", encode_location_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_location_info_struct() -> decode.Decoder(LocationInfo) {
  use name <- decode.optional_field(
    "Name",
    option.None,
    decode.optional(decode.string),
  )
  use type_ <- decode.optional_field(
    "Type",
    option.None,
    decode.optional(decode_location_type_enum()),
  )
  decode.success(LocationInfo(name: name, type_: type_))
}

pub type LocationType {
  LocationTypeAvailabilityzone
  LocationTypeLocalzone
}

pub fn encode_location_type_enum(v: LocationType) -> json.Json {
  case v {
    LocationTypeAvailabilityzone -> json.string("AvailabilityZone")
    LocationTypeLocalzone -> json.string("LocalZone")
  }
}

pub fn decode_location_type_enum() -> decode.Decoder(LocationType) {
  decode.then(decode.string, fn(s) {
    case s {
      "AvailabilityZone" -> decode.success(LocationTypeAvailabilityzone)
      "LocalZone" -> decode.success(LocationTypeLocalzone)
      _ -> decode.failure(LocationTypeAvailabilityzone, "unknown enum value")
    }
  })
}

pub type BucketLocationConstraint {
  BucketLocationConstraintEu
  BucketLocationConstraintAfSouth1
  BucketLocationConstraintApEast1
  BucketLocationConstraintApEast2
  BucketLocationConstraintApNortheast1
  BucketLocationConstraintApNortheast2
  BucketLocationConstraintApNortheast3
  BucketLocationConstraintApSouth1
  BucketLocationConstraintApSouth2
  BucketLocationConstraintApSoutheast1
  BucketLocationConstraintApSoutheast2
  BucketLocationConstraintApSoutheast3
  BucketLocationConstraintApSoutheast4
  BucketLocationConstraintApSoutheast5
  BucketLocationConstraintApSoutheast6
  BucketLocationConstraintApSoutheast7
  BucketLocationConstraintCaCentral1
  BucketLocationConstraintCaWest1
  BucketLocationConstraintCnNorth1
  BucketLocationConstraintCnNorthwest1
  BucketLocationConstraintEuCentral1
  BucketLocationConstraintEuCentral2
  BucketLocationConstraintEuNorth1
  BucketLocationConstraintEuSouth1
  BucketLocationConstraintEuSouth2
  BucketLocationConstraintEuWest1
  BucketLocationConstraintEuWest2
  BucketLocationConstraintEuWest3
  BucketLocationConstraintIlCentral1
  BucketLocationConstraintMeCentral1
  BucketLocationConstraintMeSouth1
  BucketLocationConstraintMxCentral1
  BucketLocationConstraintSaEast1
  BucketLocationConstraintUsEast2
  BucketLocationConstraintUsGovEast1
  BucketLocationConstraintUsGovWest1
  BucketLocationConstraintUsWest1
  BucketLocationConstraintUsWest2
}

pub fn encode_bucket_location_constraint_enum(
  v: BucketLocationConstraint,
) -> json.Json {
  case v {
    BucketLocationConstraintEu -> json.string("EU")
    BucketLocationConstraintAfSouth1 -> json.string("af-south-1")
    BucketLocationConstraintApEast1 -> json.string("ap-east-1")
    BucketLocationConstraintApEast2 -> json.string("ap-east-2")
    BucketLocationConstraintApNortheast1 -> json.string("ap-northeast-1")
    BucketLocationConstraintApNortheast2 -> json.string("ap-northeast-2")
    BucketLocationConstraintApNortheast3 -> json.string("ap-northeast-3")
    BucketLocationConstraintApSouth1 -> json.string("ap-south-1")
    BucketLocationConstraintApSouth2 -> json.string("ap-south-2")
    BucketLocationConstraintApSoutheast1 -> json.string("ap-southeast-1")
    BucketLocationConstraintApSoutheast2 -> json.string("ap-southeast-2")
    BucketLocationConstraintApSoutheast3 -> json.string("ap-southeast-3")
    BucketLocationConstraintApSoutheast4 -> json.string("ap-southeast-4")
    BucketLocationConstraintApSoutheast5 -> json.string("ap-southeast-5")
    BucketLocationConstraintApSoutheast6 -> json.string("ap-southeast-6")
    BucketLocationConstraintApSoutheast7 -> json.string("ap-southeast-7")
    BucketLocationConstraintCaCentral1 -> json.string("ca-central-1")
    BucketLocationConstraintCaWest1 -> json.string("ca-west-1")
    BucketLocationConstraintCnNorth1 -> json.string("cn-north-1")
    BucketLocationConstraintCnNorthwest1 -> json.string("cn-northwest-1")
    BucketLocationConstraintEuCentral1 -> json.string("eu-central-1")
    BucketLocationConstraintEuCentral2 -> json.string("eu-central-2")
    BucketLocationConstraintEuNorth1 -> json.string("eu-north-1")
    BucketLocationConstraintEuSouth1 -> json.string("eu-south-1")
    BucketLocationConstraintEuSouth2 -> json.string("eu-south-2")
    BucketLocationConstraintEuWest1 -> json.string("eu-west-1")
    BucketLocationConstraintEuWest2 -> json.string("eu-west-2")
    BucketLocationConstraintEuWest3 -> json.string("eu-west-3")
    BucketLocationConstraintIlCentral1 -> json.string("il-central-1")
    BucketLocationConstraintMeCentral1 -> json.string("me-central-1")
    BucketLocationConstraintMeSouth1 -> json.string("me-south-1")
    BucketLocationConstraintMxCentral1 -> json.string("mx-central-1")
    BucketLocationConstraintSaEast1 -> json.string("sa-east-1")
    BucketLocationConstraintUsEast2 -> json.string("us-east-2")
    BucketLocationConstraintUsGovEast1 -> json.string("us-gov-east-1")
    BucketLocationConstraintUsGovWest1 -> json.string("us-gov-west-1")
    BucketLocationConstraintUsWest1 -> json.string("us-west-1")
    BucketLocationConstraintUsWest2 -> json.string("us-west-2")
  }
}

pub fn decode_bucket_location_constraint_enum() -> decode.Decoder(
  BucketLocationConstraint,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "EU" -> decode.success(BucketLocationConstraintEu)
      "af-south-1" -> decode.success(BucketLocationConstraintAfSouth1)
      "ap-east-1" -> decode.success(BucketLocationConstraintApEast1)
      "ap-east-2" -> decode.success(BucketLocationConstraintApEast2)
      "ap-northeast-1" -> decode.success(BucketLocationConstraintApNortheast1)
      "ap-northeast-2" -> decode.success(BucketLocationConstraintApNortheast2)
      "ap-northeast-3" -> decode.success(BucketLocationConstraintApNortheast3)
      "ap-south-1" -> decode.success(BucketLocationConstraintApSouth1)
      "ap-south-2" -> decode.success(BucketLocationConstraintApSouth2)
      "ap-southeast-1" -> decode.success(BucketLocationConstraintApSoutheast1)
      "ap-southeast-2" -> decode.success(BucketLocationConstraintApSoutheast2)
      "ap-southeast-3" -> decode.success(BucketLocationConstraintApSoutheast3)
      "ap-southeast-4" -> decode.success(BucketLocationConstraintApSoutheast4)
      "ap-southeast-5" -> decode.success(BucketLocationConstraintApSoutheast5)
      "ap-southeast-6" -> decode.success(BucketLocationConstraintApSoutheast6)
      "ap-southeast-7" -> decode.success(BucketLocationConstraintApSoutheast7)
      "ca-central-1" -> decode.success(BucketLocationConstraintCaCentral1)
      "ca-west-1" -> decode.success(BucketLocationConstraintCaWest1)
      "cn-north-1" -> decode.success(BucketLocationConstraintCnNorth1)
      "cn-northwest-1" -> decode.success(BucketLocationConstraintCnNorthwest1)
      "eu-central-1" -> decode.success(BucketLocationConstraintEuCentral1)
      "eu-central-2" -> decode.success(BucketLocationConstraintEuCentral2)
      "eu-north-1" -> decode.success(BucketLocationConstraintEuNorth1)
      "eu-south-1" -> decode.success(BucketLocationConstraintEuSouth1)
      "eu-south-2" -> decode.success(BucketLocationConstraintEuSouth2)
      "eu-west-1" -> decode.success(BucketLocationConstraintEuWest1)
      "eu-west-2" -> decode.success(BucketLocationConstraintEuWest2)
      "eu-west-3" -> decode.success(BucketLocationConstraintEuWest3)
      "il-central-1" -> decode.success(BucketLocationConstraintIlCentral1)
      "me-central-1" -> decode.success(BucketLocationConstraintMeCentral1)
      "me-south-1" -> decode.success(BucketLocationConstraintMeSouth1)
      "mx-central-1" -> decode.success(BucketLocationConstraintMxCentral1)
      "sa-east-1" -> decode.success(BucketLocationConstraintSaEast1)
      "us-east-2" -> decode.success(BucketLocationConstraintUsEast2)
      "us-gov-east-1" -> decode.success(BucketLocationConstraintUsGovEast1)
      "us-gov-west-1" -> decode.success(BucketLocationConstraintUsGovWest1)
      "us-west-1" -> decode.success(BucketLocationConstraintUsWest1)
      "us-west-2" -> decode.success(BucketLocationConstraintUsWest2)
      _ -> decode.failure(BucketLocationConstraintEu, "unknown enum value")
    }
  })
}

pub type Tag {
  Tag(key: option.Option(String), value: option.Option(String))
}

pub fn encode_tag_struct(input: Tag) -> json.Json {
  let pairs = []
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_tag_struct() -> decode.Decoder(Tag) {
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use value <- decode.optional_field(
    "Value",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Tag(key: key, value: value))
}

pub type ObjectOwnership {
  ObjectOwnershipBucketownerenforced
  ObjectOwnershipBucketownerpreferred
  ObjectOwnershipObjectwriter
}

pub fn encode_object_ownership_enum(v: ObjectOwnership) -> json.Json {
  case v {
    ObjectOwnershipBucketownerenforced -> json.string("BucketOwnerEnforced")
    ObjectOwnershipBucketownerpreferred -> json.string("BucketOwnerPreferred")
    ObjectOwnershipObjectwriter -> json.string("ObjectWriter")
  }
}

pub fn decode_object_ownership_enum() -> decode.Decoder(ObjectOwnership) {
  decode.then(decode.string, fn(s) {
    case s {
      "BucketOwnerEnforced" ->
        decode.success(ObjectOwnershipBucketownerenforced)
      "BucketOwnerPreferred" ->
        decode.success(ObjectOwnershipBucketownerpreferred)
      "ObjectWriter" -> decode.success(ObjectOwnershipObjectwriter)
      _ ->
        decode.failure(ObjectOwnershipBucketownerenforced, "unknown enum value")
    }
  })
}

pub type CreateBucketOutput {
  CreateBucketOutput(
    bucket_arn: option.Option(String),
    location: option.Option(String),
  )
}

pub fn encode_create_bucket_output_struct(
  input: CreateBucketOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket_arn {
    option.Some(v) -> [#("BucketArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.location {
    option.Some(v) -> [#("Location", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_bucket_output_struct() -> decode.Decoder(
  CreateBucketOutput,
) {
  use bucket_arn <- decode.optional_field(
    "BucketArn",
    option.None,
    decode.optional(decode.string),
  )
  use location <- decode.optional_field(
    "Location",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CreateBucketOutput(bucket_arn: bucket_arn, location: location))
}

pub type CreateMultipartUploadRequest {
  CreateMultipartUploadRequest(
    acl: option.Option(ObjectCannedACL),
    bucket: option.Option(String),
    bucket_key_enabled: option.Option(Bool),
    cache_control: option.Option(String),
    checksum_algorithm: option.Option(ChecksumAlgorithm),
    checksum_type: option.Option(ChecksumType),
    content_disposition: option.Option(String),
    content_encoding: option.Option(String),
    content_language: option.Option(String),
    content_type: option.Option(String),
    expected_bucket_owner: option.Option(String),
    expires: option.Option(String),
    grant_full_control: option.Option(String),
    grant_read: option.Option(String),
    grant_read_acp: option.Option(String),
    grant_write_acp: option.Option(String),
    key: option.Option(String),
    metadata: option.Option(dict.Dict(String, String)),
    object_lock_legal_hold_status: option.Option(ObjectLockLegalHoldStatus),
    object_lock_mode: option.Option(ObjectLockMode),
    object_lock_retain_until_date: option.Option(Int),
    request_payer: option.Option(RequestPayer),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    ssekms_encryption_context: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    storage_class: option.Option(StorageClass),
    tagging: option.Option(String),
    website_redirect_location: option.Option(String),
  )
}

pub fn encode_create_multipart_upload_request_struct(
  input: CreateMultipartUploadRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.acl {
    option.Some(v) -> [#("ACL", encode_object_canned_acl_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.cache_control {
    option.Some(v) -> [#("CacheControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_algorithm {
    option.Some(v) -> [
      #("ChecksumAlgorithm", encode_checksum_algorithm_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_disposition {
    option.Some(v) -> [#("ContentDisposition", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_encoding {
    option.Some(v) -> [#("ContentEncoding", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_language {
    option.Some(v) -> [#("ContentLanguage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_type {
    option.Some(v) -> [#("ContentType", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expires {
    option.Some(v) -> [#("Expires", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_full_control {
    option.Some(v) -> [#("GrantFullControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_read {
    option.Some(v) -> [#("GrantRead", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_read_acp {
    option.Some(v) -> [#("GrantReadACP", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.grant_write_acp {
    option.Some(v) -> [#("GrantWriteACP", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.metadata {
    option.Some(v) -> [
      #(
        "Metadata",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_legal_hold_status {
    option.Some(v) -> [
      #(
        "ObjectLockLegalHoldStatus",
        encode_object_lock_legal_hold_status_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_mode {
    option.Some(v) -> [
      #("ObjectLockMode", encode_object_lock_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_retain_until_date {
    option.Some(v) -> [#("ObjectLockRetainUntilDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_encryption_context {
    option.Some(v) -> [#("SSEKMSEncryptionContext", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tagging {
    option.Some(v) -> [#("Tagging", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.website_redirect_location {
    option.Some(v) -> [#("WebsiteRedirectLocation", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_multipart_upload_request_struct() -> decode.Decoder(
  CreateMultipartUploadRequest,
) {
  use acl <- decode.optional_field(
    "ACL",
    option.None,
    decode.optional(decode_object_canned_acl_enum()),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use cache_control <- decode.optional_field(
    "CacheControl",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_algorithm <- decode.optional_field(
    "ChecksumAlgorithm",
    option.None,
    decode.optional(decode_checksum_algorithm_enum()),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use content_disposition <- decode.optional_field(
    "ContentDisposition",
    option.None,
    decode.optional(decode.string),
  )
  use content_encoding <- decode.optional_field(
    "ContentEncoding",
    option.None,
    decode.optional(decode.string),
  )
  use content_language <- decode.optional_field(
    "ContentLanguage",
    option.None,
    decode.optional(decode.string),
  )
  use content_type <- decode.optional_field(
    "ContentType",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use expires <- decode.optional_field(
    "Expires",
    option.None,
    decode.optional(decode.string),
  )
  use grant_full_control <- decode.optional_field(
    "GrantFullControl",
    option.None,
    decode.optional(decode.string),
  )
  use grant_read <- decode.optional_field(
    "GrantRead",
    option.None,
    decode.optional(decode.string),
  )
  use grant_read_acp <- decode.optional_field(
    "GrantReadACP",
    option.None,
    decode.optional(decode.string),
  )
  use grant_write_acp <- decode.optional_field(
    "GrantWriteACP",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use metadata <- decode.optional_field(
    "Metadata",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use object_lock_legal_hold_status <- decode.optional_field(
    "ObjectLockLegalHoldStatus",
    option.None,
    decode.optional(decode_object_lock_legal_hold_status_enum()),
  )
  use object_lock_mode <- decode.optional_field(
    "ObjectLockMode",
    option.None,
    decode.optional(decode_object_lock_mode_enum()),
  )
  use object_lock_retain_until_date <- decode.optional_field(
    "ObjectLockRetainUntilDate",
    option.None,
    decode.optional(decode.int),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_encryption_context <- decode.optional_field(
    "SSEKMSEncryptionContext",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  use tagging <- decode.optional_field(
    "Tagging",
    option.None,
    decode.optional(decode.string),
  )
  use website_redirect_location <- decode.optional_field(
    "WebsiteRedirectLocation",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CreateMultipartUploadRequest(
    acl: acl,
    bucket: bucket,
    bucket_key_enabled: bucket_key_enabled,
    cache_control: cache_control,
    checksum_algorithm: checksum_algorithm,
    checksum_type: checksum_type,
    content_disposition: content_disposition,
    content_encoding: content_encoding,
    content_language: content_language,
    content_type: content_type,
    expected_bucket_owner: expected_bucket_owner,
    expires: expires,
    grant_full_control: grant_full_control,
    grant_read: grant_read,
    grant_read_acp: grant_read_acp,
    grant_write_acp: grant_write_acp,
    key: key,
    metadata: metadata,
    object_lock_legal_hold_status: object_lock_legal_hold_status,
    object_lock_mode: object_lock_mode,
    object_lock_retain_until_date: object_lock_retain_until_date,
    request_payer: request_payer,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    ssekms_encryption_context: ssekms_encryption_context,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    storage_class: storage_class,
    tagging: tagging,
    website_redirect_location: website_redirect_location,
  ))
}

pub type CreateMultipartUploadOutput {
  CreateMultipartUploadOutput(
    abort_date: option.Option(Int),
    abort_rule_id: option.Option(String),
    bucket: option.Option(String),
    bucket_key_enabled: option.Option(Bool),
    checksum_algorithm: option.Option(ChecksumAlgorithm),
    checksum_type: option.Option(ChecksumType),
    key: option.Option(String),
    request_charged: option.Option(RequestCharged),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    ssekms_encryption_context: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    upload_id: option.Option(String),
  )
}

pub fn encode_create_multipart_upload_output_struct(
  input: CreateMultipartUploadOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.abort_date {
    option.Some(v) -> [#("AbortDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.abort_rule_id {
    option.Some(v) -> [#("AbortRuleId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_algorithm {
    option.Some(v) -> [
      #("ChecksumAlgorithm", encode_checksum_algorithm_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_encryption_context {
    option.Some(v) -> [#("SSEKMSEncryptionContext", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.upload_id {
    option.Some(v) -> [#("UploadId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_multipart_upload_output_struct() -> decode.Decoder(
  CreateMultipartUploadOutput,
) {
  use abort_date <- decode.optional_field(
    "AbortDate",
    option.None,
    decode.optional(decode.int),
  )
  use abort_rule_id <- decode.optional_field(
    "AbortRuleId",
    option.None,
    decode.optional(decode.string),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use checksum_algorithm <- decode.optional_field(
    "ChecksumAlgorithm",
    option.None,
    decode.optional(decode_checksum_algorithm_enum()),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_encryption_context <- decode.optional_field(
    "SSEKMSEncryptionContext",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use upload_id <- decode.optional_field(
    "UploadId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CreateMultipartUploadOutput(
    abort_date: abort_date,
    abort_rule_id: abort_rule_id,
    bucket: bucket,
    bucket_key_enabled: bucket_key_enabled,
    checksum_algorithm: checksum_algorithm,
    checksum_type: checksum_type,
    key: key,
    request_charged: request_charged,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key_md5: sse_customer_key_md5,
    ssekms_encryption_context: ssekms_encryption_context,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    upload_id: upload_id,
  ))
}

pub type CreateSessionRequest {
  CreateSessionRequest(
    bucket: option.Option(String),
    bucket_key_enabled: option.Option(Bool),
    ssekms_encryption_context: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    session_mode: option.Option(SessionMode),
  )
}

pub fn encode_create_session_request_struct(
  input: CreateSessionRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_encryption_context {
    option.Some(v) -> [#("SSEKMSEncryptionContext", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.session_mode {
    option.Some(v) -> [#("SessionMode", encode_session_mode_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_session_request_struct() -> decode.Decoder(
  CreateSessionRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use ssekms_encryption_context <- decode.optional_field(
    "SSEKMSEncryptionContext",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use session_mode <- decode.optional_field(
    "SessionMode",
    option.None,
    decode.optional(decode_session_mode_enum()),
  )
  decode.success(CreateSessionRequest(
    bucket: bucket,
    bucket_key_enabled: bucket_key_enabled,
    ssekms_encryption_context: ssekms_encryption_context,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    session_mode: session_mode,
  ))
}

pub type SessionMode {
  SessionModeReadonly
  SessionModeReadwrite
}

pub fn encode_session_mode_enum(v: SessionMode) -> json.Json {
  case v {
    SessionModeReadonly -> json.string("ReadOnly")
    SessionModeReadwrite -> json.string("ReadWrite")
  }
}

pub fn decode_session_mode_enum() -> decode.Decoder(SessionMode) {
  decode.then(decode.string, fn(s) {
    case s {
      "ReadOnly" -> decode.success(SessionModeReadonly)
      "ReadWrite" -> decode.success(SessionModeReadwrite)
      _ -> decode.failure(SessionModeReadonly, "unknown enum value")
    }
  })
}

pub type CreateSessionOutput {
  CreateSessionOutput(
    bucket_key_enabled: option.Option(Bool),
    credentials: option.Option(SessionCredentials),
    ssekms_encryption_context: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
  )
}

pub fn encode_create_session_output_struct(
  input: CreateSessionOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.credentials {
    option.Some(v) -> [
      #("Credentials", encode_session_credentials_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.ssekms_encryption_context {
    option.Some(v) -> [#("SSEKMSEncryptionContext", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_create_session_output_struct() -> decode.Decoder(
  CreateSessionOutput,
) {
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use credentials <- decode.optional_field(
    "Credentials",
    option.None,
    decode.optional(decode_session_credentials_struct()),
  )
  use ssekms_encryption_context <- decode.optional_field(
    "SSEKMSEncryptionContext",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  decode.success(CreateSessionOutput(
    bucket_key_enabled: bucket_key_enabled,
    credentials: credentials,
    ssekms_encryption_context: ssekms_encryption_context,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
  ))
}

pub type SessionCredentials {
  SessionCredentials(
    access_key_id: option.Option(String),
    expiration: option.Option(Int),
    secret_access_key: option.Option(String),
    session_token: option.Option(String),
  )
}

pub fn encode_session_credentials_struct(
  input: SessionCredentials,
) -> json.Json {
  let pairs = []
  let pairs = case input.access_key_id {
    option.Some(v) -> [#("AccessKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expiration {
    option.Some(v) -> [#("Expiration", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.secret_access_key {
    option.Some(v) -> [#("SecretAccessKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.session_token {
    option.Some(v) -> [#("SessionToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_session_credentials_struct() -> decode.Decoder(SessionCredentials) {
  use access_key_id <- decode.optional_field(
    "AccessKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use expiration <- decode.optional_field(
    "Expiration",
    option.None,
    decode.optional(decode.int),
  )
  use secret_access_key <- decode.optional_field(
    "SecretAccessKey",
    option.None,
    decode.optional(decode.string),
  )
  use session_token <- decode.optional_field(
    "SessionToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(SessionCredentials(
    access_key_id: access_key_id,
    expiration: expiration,
    secret_access_key: secret_access_key,
    session_token: session_token,
  ))
}

pub type DeleteBucketRequest {
  DeleteBucketRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_request_struct(
  input: DeleteBucketRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_request_struct() -> decode.Decoder(
  DeleteBucketRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketAnalyticsConfigurationRequest {
  DeleteBucketAnalyticsConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_delete_bucket_analytics_configuration_request_struct(
  input: DeleteBucketAnalyticsConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_analytics_configuration_request_struct() -> decode.Decoder(
  DeleteBucketAnalyticsConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketAnalyticsConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type DeleteBucketCorsRequest {
  DeleteBucketCorsRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_cors_request_struct(
  input: DeleteBucketCorsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_cors_request_struct() -> decode.Decoder(
  DeleteBucketCorsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketCorsRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketEncryptionRequest {
  DeleteBucketEncryptionRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_encryption_request_struct(
  input: DeleteBucketEncryptionRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_encryption_request_struct() -> decode.Decoder(
  DeleteBucketEncryptionRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketEncryptionRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketIntelligentTieringConfigurationRequest {
  DeleteBucketIntelligentTieringConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_delete_bucket_intelligent_tiering_configuration_request_struct(
  input: DeleteBucketIntelligentTieringConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_intelligent_tiering_configuration_request_struct() -> decode.Decoder(
  DeleteBucketIntelligentTieringConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketIntelligentTieringConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type DeleteBucketInventoryConfigurationRequest {
  DeleteBucketInventoryConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_delete_bucket_inventory_configuration_request_struct(
  input: DeleteBucketInventoryConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_inventory_configuration_request_struct() -> decode.Decoder(
  DeleteBucketInventoryConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketInventoryConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type DeleteBucketLifecycleRequest {
  DeleteBucketLifecycleRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_lifecycle_request_struct(
  input: DeleteBucketLifecycleRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_lifecycle_request_struct() -> decode.Decoder(
  DeleteBucketLifecycleRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketLifecycleRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketMetadataConfigurationRequest {
  DeleteBucketMetadataConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_metadata_configuration_request_struct(
  input: DeleteBucketMetadataConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_metadata_configuration_request_struct() -> decode.Decoder(
  DeleteBucketMetadataConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketMetadataConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketMetadataTableConfigurationRequest {
  DeleteBucketMetadataTableConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_metadata_table_configuration_request_struct(
  input: DeleteBucketMetadataTableConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_metadata_table_configuration_request_struct() -> decode.Decoder(
  DeleteBucketMetadataTableConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketMetadataTableConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketMetricsConfigurationRequest {
  DeleteBucketMetricsConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_delete_bucket_metrics_configuration_request_struct(
  input: DeleteBucketMetricsConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_metrics_configuration_request_struct() -> decode.Decoder(
  DeleteBucketMetricsConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketMetricsConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type DeleteBucketOwnershipControlsRequest {
  DeleteBucketOwnershipControlsRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_ownership_controls_request_struct(
  input: DeleteBucketOwnershipControlsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_ownership_controls_request_struct() -> decode.Decoder(
  DeleteBucketOwnershipControlsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketOwnershipControlsRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketPolicyRequest {
  DeleteBucketPolicyRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_policy_request_struct(
  input: DeleteBucketPolicyRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_policy_request_struct() -> decode.Decoder(
  DeleteBucketPolicyRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketPolicyRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketReplicationRequest {
  DeleteBucketReplicationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_replication_request_struct(
  input: DeleteBucketReplicationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_replication_request_struct() -> decode.Decoder(
  DeleteBucketReplicationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketReplicationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketTaggingRequest {
  DeleteBucketTaggingRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_tagging_request_struct(
  input: DeleteBucketTaggingRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_tagging_request_struct() -> decode.Decoder(
  DeleteBucketTaggingRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketTaggingRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteBucketWebsiteRequest {
  DeleteBucketWebsiteRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_bucket_website_request_struct(
  input: DeleteBucketWebsiteRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_bucket_website_request_struct() -> decode.Decoder(
  DeleteBucketWebsiteRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteBucketWebsiteRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type DeleteObjectRequest {
  DeleteObjectRequest(
    bucket: option.Option(String),
    bypass_governance_retention: option.Option(Bool),
    expected_bucket_owner: option.Option(String),
    if_match: option.Option(String),
    if_match_last_modified_time: option.Option(Int),
    if_match_size: option.Option(Int),
    key: option.Option(String),
    mfa: option.Option(String),
    request_payer: option.Option(RequestPayer),
    version_id: option.Option(String),
  )
}

pub fn encode_delete_object_request_struct(
  input: DeleteObjectRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bypass_governance_retention {
    option.Some(v) -> [#("BypassGovernanceRetention", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_match {
    option.Some(v) -> [#("IfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_match_last_modified_time {
    option.Some(v) -> [#("IfMatchLastModifiedTime", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_match_size {
    option.Some(v) -> [#("IfMatchSize", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.mfa {
    option.Some(v) -> [#("MFA", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_object_request_struct() -> decode.Decoder(
  DeleteObjectRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bypass_governance_retention <- decode.optional_field(
    "BypassGovernanceRetention",
    option.None,
    decode.optional(decode.bool),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use if_match <- decode.optional_field(
    "IfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use if_match_last_modified_time <- decode.optional_field(
    "IfMatchLastModifiedTime",
    option.None,
    decode.optional(decode.int),
  )
  use if_match_size <- decode.optional_field(
    "IfMatchSize",
    option.None,
    decode.optional(decode.int),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use mfa <- decode.optional_field(
    "MFA",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteObjectRequest(
    bucket: bucket,
    bypass_governance_retention: bypass_governance_retention,
    expected_bucket_owner: expected_bucket_owner,
    if_match: if_match,
    if_match_last_modified_time: if_match_last_modified_time,
    if_match_size: if_match_size,
    key: key,
    mfa: mfa,
    request_payer: request_payer,
    version_id: version_id,
  ))
}

pub type DeleteObjectOutput {
  DeleteObjectOutput(
    delete_marker: option.Option(Bool),
    request_charged: option.Option(RequestCharged),
    version_id: option.Option(String),
  )
}

pub fn encode_delete_object_output_struct(
  input: DeleteObjectOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.delete_marker {
    option.Some(v) -> [#("DeleteMarker", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_object_output_struct() -> decode.Decoder(
  DeleteObjectOutput,
) {
  use delete_marker <- decode.optional_field(
    "DeleteMarker",
    option.None,
    decode.optional(decode.bool),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteObjectOutput(
    delete_marker: delete_marker,
    request_charged: request_charged,
    version_id: version_id,
  ))
}

pub type DeleteObjectTaggingRequest {
  DeleteObjectTaggingRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    version_id: option.Option(String),
  )
}

pub fn encode_delete_object_tagging_request_struct(
  input: DeleteObjectTaggingRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_object_tagging_request_struct() -> decode.Decoder(
  DeleteObjectTaggingRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteObjectTaggingRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    version_id: version_id,
  ))
}

pub type DeleteObjectTaggingOutput {
  DeleteObjectTaggingOutput(version_id: option.Option(String))
}

pub fn encode_delete_object_tagging_output_struct(
  input: DeleteObjectTaggingOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_object_tagging_output_struct() -> decode.Decoder(
  DeleteObjectTaggingOutput,
) {
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteObjectTaggingOutput(version_id: version_id))
}

pub type DeletePublicAccessBlockRequest {
  DeletePublicAccessBlockRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_delete_public_access_block_request_struct(
  input: DeletePublicAccessBlockRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_public_access_block_request_struct() -> decode.Decoder(
  DeletePublicAccessBlockRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeletePublicAccessBlockRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketAbacRequest {
  GetBucketAbacRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_abac_request_struct(
  input: GetBucketAbacRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_abac_request_struct() -> decode.Decoder(
  GetBucketAbacRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketAbacRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketAbacOutput {
  GetBucketAbacOutput(abac_status: option.Option(AbacStatus))
}

pub fn encode_get_bucket_abac_output_struct(
  input: GetBucketAbacOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.abac_status {
    option.Some(v) -> [#("AbacStatus", encode_abac_status_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_abac_output_struct() -> decode.Decoder(
  GetBucketAbacOutput,
) {
  use abac_status <- decode.optional_field(
    "AbacStatus",
    option.None,
    decode.optional(decode_abac_status_struct()),
  )
  decode.success(GetBucketAbacOutput(abac_status: abac_status))
}

pub type AbacStatus {
  AbacStatus(status: option.Option(BucketAbacStatus))
}

pub fn encode_abac_status_struct(input: AbacStatus) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [#("Status", encode_bucket_abac_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_abac_status_struct() -> decode.Decoder(AbacStatus) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_bucket_abac_status_enum()),
  )
  decode.success(AbacStatus(status: status))
}

pub type BucketAbacStatus {
  BucketAbacStatusDisabled
  BucketAbacStatusEnabled
}

pub fn encode_bucket_abac_status_enum(v: BucketAbacStatus) -> json.Json {
  case v {
    BucketAbacStatusDisabled -> json.string("Disabled")
    BucketAbacStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_bucket_abac_status_enum() -> decode.Decoder(BucketAbacStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(BucketAbacStatusDisabled)
      "Enabled" -> decode.success(BucketAbacStatusEnabled)
      _ -> decode.failure(BucketAbacStatusDisabled, "unknown enum value")
    }
  })
}

pub type GetBucketAccelerateConfigurationRequest {
  GetBucketAccelerateConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    request_payer: option.Option(RequestPayer),
  )
}

pub fn encode_get_bucket_accelerate_configuration_request_struct(
  input: GetBucketAccelerateConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_accelerate_configuration_request_struct() -> decode.Decoder(
  GetBucketAccelerateConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  decode.success(GetBucketAccelerateConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    request_payer: request_payer,
  ))
}

pub type GetBucketAccelerateConfigurationOutput {
  GetBucketAccelerateConfigurationOutput(
    request_charged: option.Option(RequestCharged),
    status: option.Option(BucketAccelerateStatus),
  )
}

pub fn encode_get_bucket_accelerate_configuration_output_struct(
  input: GetBucketAccelerateConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_bucket_accelerate_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_accelerate_configuration_output_struct() -> decode.Decoder(
  GetBucketAccelerateConfigurationOutput,
) {
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_bucket_accelerate_status_enum()),
  )
  decode.success(GetBucketAccelerateConfigurationOutput(
    request_charged: request_charged,
    status: status,
  ))
}

pub type BucketAccelerateStatus {
  BucketAccelerateStatusEnabled
  BucketAccelerateStatusSuspended
}

pub fn encode_bucket_accelerate_status_enum(
  v: BucketAccelerateStatus,
) -> json.Json {
  case v {
    BucketAccelerateStatusEnabled -> json.string("Enabled")
    BucketAccelerateStatusSuspended -> json.string("Suspended")
  }
}

pub fn decode_bucket_accelerate_status_enum() -> decode.Decoder(
  BucketAccelerateStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Enabled" -> decode.success(BucketAccelerateStatusEnabled)
      "Suspended" -> decode.success(BucketAccelerateStatusSuspended)
      _ -> decode.failure(BucketAccelerateStatusEnabled, "unknown enum value")
    }
  })
}

pub type GetBucketAclRequest {
  GetBucketAclRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_acl_request_struct(
  input: GetBucketAclRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_acl_request_struct() -> decode.Decoder(
  GetBucketAclRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketAclRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketAclOutput {
  GetBucketAclOutput(
    grants: option.Option(List(Grant)),
    owner: option.Option(Owner),
  )
}

pub fn encode_get_bucket_acl_output_struct(
  input: GetBucketAclOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.grants {
    option.Some(v) -> [
      #("Grants", fn(xs) { json.array(xs, encode_grant_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_acl_output_struct() -> decode.Decoder(
  GetBucketAclOutput,
) {
  use grants <- decode.optional_field(
    "Grants",
    option.None,
    decode.optional(decode.list(decode_grant_struct())),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  decode.success(GetBucketAclOutput(grants: grants, owner: owner))
}

pub type Grant {
  Grant(grantee: option.Option(Grantee), permission: option.Option(Permission))
}

pub fn encode_grant_struct(input: Grant) -> json.Json {
  let pairs = []
  let pairs = case input.grantee {
    option.Some(v) -> [#("Grantee", encode_grantee_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.permission {
    option.Some(v) -> [#("Permission", encode_permission_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_grant_struct() -> decode.Decoder(Grant) {
  use grantee <- decode.optional_field(
    "Grantee",
    option.None,
    decode.optional(decode_grantee_struct()),
  )
  use permission <- decode.optional_field(
    "Permission",
    option.None,
    decode.optional(decode_permission_enum()),
  )
  decode.success(Grant(grantee: grantee, permission: permission))
}

pub type Grantee {
  Grantee(
    display_name: option.Option(String),
    email_address: option.Option(String),
    id: option.Option(String),
    type_: option.Option(Type),
    uri: option.Option(String),
  )
}

pub fn encode_grantee_struct(input: Grantee) -> json.Json {
  let pairs = []
  let pairs = case input.display_name {
    option.Some(v) -> [#("DisplayName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.email_address {
    option.Some(v) -> [#("EmailAddress", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("ID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.type_ {
    option.Some(v) -> [#("Type", encode_type__enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.uri {
    option.Some(v) -> [#("URI", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_grantee_struct() -> decode.Decoder(Grantee) {
  use display_name <- decode.optional_field(
    "DisplayName",
    option.None,
    decode.optional(decode.string),
  )
  use email_address <- decode.optional_field(
    "EmailAddress",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "ID",
    option.None,
    decode.optional(decode.string),
  )
  use type_ <- decode.optional_field(
    "Type",
    option.None,
    decode.optional(decode_type__enum()),
  )
  use uri <- decode.optional_field(
    "URI",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Grantee(
    display_name: display_name,
    email_address: email_address,
    id: id,
    type_: type_,
    uri: uri,
  ))
}

pub type Type {
  TypeAmazoncustomerbyemail
  TypeCanonicaluser
  TypeGroup
}

pub fn encode_type__enum(v: Type) -> json.Json {
  case v {
    TypeAmazoncustomerbyemail -> json.string("AmazonCustomerByEmail")
    TypeCanonicaluser -> json.string("CanonicalUser")
    TypeGroup -> json.string("Group")
  }
}

pub fn decode_type__enum() -> decode.Decoder(Type) {
  decode.then(decode.string, fn(s) {
    case s {
      "AmazonCustomerByEmail" -> decode.success(TypeAmazoncustomerbyemail)
      "CanonicalUser" -> decode.success(TypeCanonicaluser)
      "Group" -> decode.success(TypeGroup)
      _ -> decode.failure(TypeAmazoncustomerbyemail, "unknown enum value")
    }
  })
}

pub type Permission {
  PermissionFullControl
  PermissionRead
  PermissionReadAcp
  PermissionWrite
  PermissionWriteAcp
}

pub fn encode_permission_enum(v: Permission) -> json.Json {
  case v {
    PermissionFullControl -> json.string("FULL_CONTROL")
    PermissionRead -> json.string("READ")
    PermissionReadAcp -> json.string("READ_ACP")
    PermissionWrite -> json.string("WRITE")
    PermissionWriteAcp -> json.string("WRITE_ACP")
  }
}

pub fn decode_permission_enum() -> decode.Decoder(Permission) {
  decode.then(decode.string, fn(s) {
    case s {
      "FULL_CONTROL" -> decode.success(PermissionFullControl)
      "READ" -> decode.success(PermissionRead)
      "READ_ACP" -> decode.success(PermissionReadAcp)
      "WRITE" -> decode.success(PermissionWrite)
      "WRITE_ACP" -> decode.success(PermissionWriteAcp)
      _ -> decode.failure(PermissionFullControl, "unknown enum value")
    }
  })
}

pub type Owner {
  Owner(display_name: option.Option(String), id: option.Option(String))
}

pub fn encode_owner_struct(input: Owner) -> json.Json {
  let pairs = []
  let pairs = case input.display_name {
    option.Some(v) -> [#("DisplayName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("ID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_owner_struct() -> decode.Decoder(Owner) {
  use display_name <- decode.optional_field(
    "DisplayName",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "ID",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Owner(display_name: display_name, id: id))
}

pub type GetBucketAnalyticsConfigurationRequest {
  GetBucketAnalyticsConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_get_bucket_analytics_configuration_request_struct(
  input: GetBucketAnalyticsConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_analytics_configuration_request_struct() -> decode.Decoder(
  GetBucketAnalyticsConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketAnalyticsConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type GetBucketAnalyticsConfigurationOutput {
  GetBucketAnalyticsConfigurationOutput(
    analytics_configuration: option.Option(AnalyticsConfiguration),
  )
}

pub fn encode_get_bucket_analytics_configuration_output_struct(
  input: GetBucketAnalyticsConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.analytics_configuration {
    option.Some(v) -> [
      #("AnalyticsConfiguration", encode_analytics_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_analytics_configuration_output_struct() -> decode.Decoder(
  GetBucketAnalyticsConfigurationOutput,
) {
  use analytics_configuration <- decode.optional_field(
    "AnalyticsConfiguration",
    option.None,
    decode.optional(decode_analytics_configuration_struct()),
  )
  decode.success(GetBucketAnalyticsConfigurationOutput(
    analytics_configuration: analytics_configuration,
  ))
}

pub type AnalyticsConfiguration {
  AnalyticsConfiguration(
    filter: option.Option(AnalyticsFilter),
    id: option.Option(String),
    storage_class_analysis: option.Option(StorageClassAnalysis),
  )
}

pub fn encode_analytics_configuration_struct(
  input: AnalyticsConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.filter {
    option.Some(v) -> [#("Filter", encode_analytics_filter_union(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.storage_class_analysis {
    option.Some(v) -> [
      #("StorageClassAnalysis", encode_storage_class_analysis_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_analytics_configuration_struct() -> decode.Decoder(
  AnalyticsConfiguration,
) {
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_analytics_filter_union()),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use storage_class_analysis <- decode.optional_field(
    "StorageClassAnalysis",
    option.None,
    decode.optional(decode_storage_class_analysis_struct()),
  )
  decode.success(AnalyticsConfiguration(
    filter: filter,
    id: id,
    storage_class_analysis: storage_class_analysis,
  ))
}

pub type AnalyticsFilter {
  AnalyticsFilterAnd(AnalyticsAndOperator)
  AnalyticsFilterPrefix(String)
  AnalyticsFilterTag(Tag)
}

pub fn encode_analytics_filter_union(v: AnalyticsFilter) -> json.Json {
  case v {
    AnalyticsFilterAnd(x) ->
      json.object([#("And", encode_analytics_and_operator_struct(x))])
    AnalyticsFilterPrefix(x) -> json.object([#("Prefix", json.string(x))])
    AnalyticsFilterTag(x) -> json.object([#("Tag", encode_tag_struct(x))])
  }
}

pub fn decode_analytics_filter_union() -> decode.Decoder(AnalyticsFilter) {
  decode.one_of(
    decode.field("And", decode_analytics_and_operator_struct(), fn(x) {
      decode.success(AnalyticsFilterAnd(x))
    }),
    [
      decode.field("Prefix", decode.string, fn(x) {
        decode.success(AnalyticsFilterPrefix(x))
      }),
      decode.field("Tag", decode_tag_struct(), fn(x) {
        decode.success(AnalyticsFilterTag(x))
      }),
    ],
  )
}

pub type AnalyticsAndOperator {
  AnalyticsAndOperator(
    prefix: option.Option(String),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_analytics_and_operator_struct(
  input: AnalyticsAndOperator,
) -> json.Json {
  let pairs = []
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_analytics_and_operator_struct() -> decode.Decoder(
  AnalyticsAndOperator,
) {
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(AnalyticsAndOperator(prefix: prefix, tags: tags))
}

pub type StorageClassAnalysis {
  StorageClassAnalysis(
    data_export: option.Option(StorageClassAnalysisDataExport),
  )
}

pub fn encode_storage_class_analysis_struct(
  input: StorageClassAnalysis,
) -> json.Json {
  let pairs = []
  let pairs = case input.data_export {
    option.Some(v) -> [
      #("DataExport", encode_storage_class_analysis_data_export_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_storage_class_analysis_struct() -> decode.Decoder(
  StorageClassAnalysis,
) {
  use data_export <- decode.optional_field(
    "DataExport",
    option.None,
    decode.optional(decode_storage_class_analysis_data_export_struct()),
  )
  decode.success(StorageClassAnalysis(data_export: data_export))
}

pub type StorageClassAnalysisDataExport {
  StorageClassAnalysisDataExport(
    destination: option.Option(AnalyticsExportDestination),
    output_schema_version: option.Option(StorageClassAnalysisSchemaVersion),
  )
}

pub fn encode_storage_class_analysis_data_export_struct(
  input: StorageClassAnalysisDataExport,
) -> json.Json {
  let pairs = []
  let pairs = case input.destination {
    option.Some(v) -> [
      #("Destination", encode_analytics_export_destination_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.output_schema_version {
    option.Some(v) -> [
      #(
        "OutputSchemaVersion",
        encode_storage_class_analysis_schema_version_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_storage_class_analysis_data_export_struct() -> decode.Decoder(
  StorageClassAnalysisDataExport,
) {
  use destination <- decode.optional_field(
    "Destination",
    option.None,
    decode.optional(decode_analytics_export_destination_struct()),
  )
  use output_schema_version <- decode.optional_field(
    "OutputSchemaVersion",
    option.None,
    decode.optional(decode_storage_class_analysis_schema_version_enum()),
  )
  decode.success(StorageClassAnalysisDataExport(
    destination: destination,
    output_schema_version: output_schema_version,
  ))
}

pub type AnalyticsExportDestination {
  AnalyticsExportDestination(
    s3_bucket_destination: option.Option(AnalyticsS3BucketDestination),
  )
}

pub fn encode_analytics_export_destination_struct(
  input: AnalyticsExportDestination,
) -> json.Json {
  let pairs = []
  let pairs = case input.s3_bucket_destination {
    option.Some(v) -> [
      #("S3BucketDestination", encode_analytics_s3_bucket_destination_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_analytics_export_destination_struct() -> decode.Decoder(
  AnalyticsExportDestination,
) {
  use s3_bucket_destination <- decode.optional_field(
    "S3BucketDestination",
    option.None,
    decode.optional(decode_analytics_s3_bucket_destination_struct()),
  )
  decode.success(AnalyticsExportDestination(
    s3_bucket_destination: s3_bucket_destination,
  ))
}

pub type AnalyticsS3BucketDestination {
  AnalyticsS3BucketDestination(
    bucket: option.Option(String),
    bucket_account_id: option.Option(String),
    format: option.Option(AnalyticsS3ExportFileFormat),
    prefix: option.Option(String),
  )
}

pub fn encode_analytics_s3_bucket_destination_struct(
  input: AnalyticsS3BucketDestination,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_account_id {
    option.Some(v) -> [#("BucketAccountId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.format {
    option.Some(v) -> [
      #("Format", encode_analytics_s3_export_file_format_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_analytics_s3_bucket_destination_struct() -> decode.Decoder(
  AnalyticsS3BucketDestination,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_account_id <- decode.optional_field(
    "BucketAccountId",
    option.None,
    decode.optional(decode.string),
  )
  use format <- decode.optional_field(
    "Format",
    option.None,
    decode.optional(decode_analytics_s3_export_file_format_enum()),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(AnalyticsS3BucketDestination(
    bucket: bucket,
    bucket_account_id: bucket_account_id,
    format: format,
    prefix: prefix,
  ))
}

pub type AnalyticsS3ExportFileFormat {
  AnalyticsS3ExportFileFormatCsv
}

pub fn encode_analytics_s3_export_file_format_enum(
  v: AnalyticsS3ExportFileFormat,
) -> json.Json {
  case v {
    AnalyticsS3ExportFileFormatCsv -> json.string("CSV")
  }
}

pub fn decode_analytics_s3_export_file_format_enum() -> decode.Decoder(
  AnalyticsS3ExportFileFormat,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "CSV" -> decode.success(AnalyticsS3ExportFileFormatCsv)
      _ -> decode.failure(AnalyticsS3ExportFileFormatCsv, "unknown enum value")
    }
  })
}

pub type StorageClassAnalysisSchemaVersion {
  StorageClassAnalysisSchemaVersionV1
}

pub fn encode_storage_class_analysis_schema_version_enum(
  v: StorageClassAnalysisSchemaVersion,
) -> json.Json {
  case v {
    StorageClassAnalysisSchemaVersionV1 -> json.string("V_1")
  }
}

pub fn decode_storage_class_analysis_schema_version_enum() -> decode.Decoder(
  StorageClassAnalysisSchemaVersion,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "V_1" -> decode.success(StorageClassAnalysisSchemaVersionV1)
      _ ->
        decode.failure(
          StorageClassAnalysisSchemaVersionV1,
          "unknown enum value",
        )
    }
  })
}

pub type GetBucketCorsRequest {
  GetBucketCorsRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_cors_request_struct(
  input: GetBucketCorsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_cors_request_struct() -> decode.Decoder(
  GetBucketCorsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketCorsRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketCorsOutput {
  GetBucketCorsOutput(cors_rules: option.Option(List(CORSRule)))
}

pub fn encode_get_bucket_cors_output_struct(
  input: GetBucketCorsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.cors_rules {
    option.Some(v) -> [
      #("CORSRules", fn(xs) { json.array(xs, encode_cors_rule_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_cors_output_struct() -> decode.Decoder(
  GetBucketCorsOutput,
) {
  use cors_rules <- decode.optional_field(
    "CORSRules",
    option.None,
    decode.optional(decode.list(decode_cors_rule_struct())),
  )
  decode.success(GetBucketCorsOutput(cors_rules: cors_rules))
}

pub type CORSRule {
  CORSRule(
    allowed_headers: option.Option(List(String)),
    allowed_methods: option.Option(List(String)),
    allowed_origins: option.Option(List(String)),
    expose_headers: option.Option(List(String)),
    id: option.Option(String),
    max_age_seconds: option.Option(Int),
  )
}

pub fn encode_cors_rule_struct(input: CORSRule) -> json.Json {
  let pairs = []
  let pairs = case input.allowed_headers {
    option.Some(v) -> [
      #("AllowedHeaders", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.allowed_methods {
    option.Some(v) -> [
      #("AllowedMethods", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.allowed_origins {
    option.Some(v) -> [
      #("AllowedOrigins", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expose_headers {
    option.Some(v) -> [
      #("ExposeHeaders", fn(xs) { json.array(xs, json.string) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("ID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_age_seconds {
    option.Some(v) -> [#("MaxAgeSeconds", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_cors_rule_struct() -> decode.Decoder(CORSRule) {
  use allowed_headers <- decode.optional_field(
    "AllowedHeaders",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use allowed_methods <- decode.optional_field(
    "AllowedMethods",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use allowed_origins <- decode.optional_field(
    "AllowedOrigins",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use expose_headers <- decode.optional_field(
    "ExposeHeaders",
    option.None,
    decode.optional(decode.list(decode.string)),
  )
  use id <- decode.optional_field(
    "ID",
    option.None,
    decode.optional(decode.string),
  )
  use max_age_seconds <- decode.optional_field(
    "MaxAgeSeconds",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(CORSRule(
    allowed_headers: allowed_headers,
    allowed_methods: allowed_methods,
    allowed_origins: allowed_origins,
    expose_headers: expose_headers,
    id: id,
    max_age_seconds: max_age_seconds,
  ))
}

pub type GetBucketEncryptionRequest {
  GetBucketEncryptionRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_encryption_request_struct(
  input: GetBucketEncryptionRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_encryption_request_struct() -> decode.Decoder(
  GetBucketEncryptionRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketEncryptionRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketEncryptionOutput {
  GetBucketEncryptionOutput(
    server_side_encryption_configuration: option.Option(
      ServerSideEncryptionConfiguration,
    ),
  )
}

pub fn encode_get_bucket_encryption_output_struct(
  input: GetBucketEncryptionOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.server_side_encryption_configuration {
    option.Some(v) -> [
      #(
        "ServerSideEncryptionConfiguration",
        encode_server_side_encryption_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_encryption_output_struct() -> decode.Decoder(
  GetBucketEncryptionOutput,
) {
  use server_side_encryption_configuration <- decode.optional_field(
    "ServerSideEncryptionConfiguration",
    option.None,
    decode.optional(decode_server_side_encryption_configuration_struct()),
  )
  decode.success(GetBucketEncryptionOutput(
    server_side_encryption_configuration: server_side_encryption_configuration,
  ))
}

pub type ServerSideEncryptionConfiguration {
  ServerSideEncryptionConfiguration(
    rules: option.Option(List(ServerSideEncryptionRule)),
  )
}

pub fn encode_server_side_encryption_configuration_struct(
  input: ServerSideEncryptionConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.rules {
    option.Some(v) -> [
      #(
        "Rules",
        fn(xs) { json.array(xs, encode_server_side_encryption_rule_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_server_side_encryption_configuration_struct() -> decode.Decoder(
  ServerSideEncryptionConfiguration,
) {
  use rules <- decode.optional_field(
    "Rules",
    option.None,
    decode.optional(decode.list(decode_server_side_encryption_rule_struct())),
  )
  decode.success(ServerSideEncryptionConfiguration(rules: rules))
}

pub type ServerSideEncryptionRule {
  ServerSideEncryptionRule(
    apply_server_side_encryption_by_default: option.Option(
      ServerSideEncryptionByDefault,
    ),
    blocked_encryption_types: option.Option(BlockedEncryptionTypes),
    bucket_key_enabled: option.Option(Bool),
  )
}

pub fn encode_server_side_encryption_rule_struct(
  input: ServerSideEncryptionRule,
) -> json.Json {
  let pairs = []
  let pairs = case input.apply_server_side_encryption_by_default {
    option.Some(v) -> [
      #(
        "ApplyServerSideEncryptionByDefault",
        encode_server_side_encryption_by_default_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.blocked_encryption_types {
    option.Some(v) -> [
      #("BlockedEncryptionTypes", encode_blocked_encryption_types_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_server_side_encryption_rule_struct() -> decode.Decoder(
  ServerSideEncryptionRule,
) {
  use apply_server_side_encryption_by_default <- decode.optional_field(
    "ApplyServerSideEncryptionByDefault",
    option.None,
    decode.optional(decode_server_side_encryption_by_default_struct()),
  )
  use blocked_encryption_types <- decode.optional_field(
    "BlockedEncryptionTypes",
    option.None,
    decode.optional(decode_blocked_encryption_types_struct()),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(ServerSideEncryptionRule(
    apply_server_side_encryption_by_default: apply_server_side_encryption_by_default,
    blocked_encryption_types: blocked_encryption_types,
    bucket_key_enabled: bucket_key_enabled,
  ))
}

pub type ServerSideEncryptionByDefault {
  ServerSideEncryptionByDefault(
    kms_master_key_id: option.Option(String),
    sse_algorithm: option.Option(ServerSideEncryption),
  )
}

pub fn encode_server_side_encryption_by_default_struct(
  input: ServerSideEncryptionByDefault,
) -> json.Json {
  let pairs = []
  let pairs = case input.kms_master_key_id {
    option.Some(v) -> [#("KMSMasterKeyID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_algorithm {
    option.Some(v) -> [
      #("SSEAlgorithm", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_server_side_encryption_by_default_struct() -> decode.Decoder(
  ServerSideEncryptionByDefault,
) {
  use kms_master_key_id <- decode.optional_field(
    "KMSMasterKeyID",
    option.None,
    decode.optional(decode.string),
  )
  use sse_algorithm <- decode.optional_field(
    "SSEAlgorithm",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  decode.success(ServerSideEncryptionByDefault(
    kms_master_key_id: kms_master_key_id,
    sse_algorithm: sse_algorithm,
  ))
}

pub type BlockedEncryptionTypes {
  BlockedEncryptionTypes(encryption_type: option.Option(List(EncryptionType)))
}

pub fn encode_blocked_encryption_types_struct(
  input: BlockedEncryptionTypes,
) -> json.Json {
  let pairs = []
  let pairs = case input.encryption_type {
    option.Some(v) -> [
      #(
        "EncryptionType",
        fn(xs) { json.array(xs, encode_encryption_type_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_blocked_encryption_types_struct() -> decode.Decoder(
  BlockedEncryptionTypes,
) {
  use encryption_type <- decode.optional_field(
    "EncryptionType",
    option.None,
    decode.optional(decode.list(decode_encryption_type_enum())),
  )
  decode.success(BlockedEncryptionTypes(encryption_type: encryption_type))
}

pub type EncryptionType {
  EncryptionTypeNone
  EncryptionTypeSseC
}

pub fn encode_encryption_type_enum(v: EncryptionType) -> json.Json {
  case v {
    EncryptionTypeNone -> json.string("NONE")
    EncryptionTypeSseC -> json.string("SSE-C")
  }
}

pub fn decode_encryption_type_enum() -> decode.Decoder(EncryptionType) {
  decode.then(decode.string, fn(s) {
    case s {
      "NONE" -> decode.success(EncryptionTypeNone)
      "SSE-C" -> decode.success(EncryptionTypeSseC)
      _ -> decode.failure(EncryptionTypeNone, "unknown enum value")
    }
  })
}

pub type GetBucketIntelligentTieringConfigurationRequest {
  GetBucketIntelligentTieringConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_get_bucket_intelligent_tiering_configuration_request_struct(
  input: GetBucketIntelligentTieringConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_intelligent_tiering_configuration_request_struct() -> decode.Decoder(
  GetBucketIntelligentTieringConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketIntelligentTieringConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type GetBucketIntelligentTieringConfigurationOutput {
  GetBucketIntelligentTieringConfigurationOutput(
    intelligent_tiering_configuration: option.Option(
      IntelligentTieringConfiguration,
    ),
  )
}

pub fn encode_get_bucket_intelligent_tiering_configuration_output_struct(
  input: GetBucketIntelligentTieringConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.intelligent_tiering_configuration {
    option.Some(v) -> [
      #(
        "IntelligentTieringConfiguration",
        encode_intelligent_tiering_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_intelligent_tiering_configuration_output_struct() -> decode.Decoder(
  GetBucketIntelligentTieringConfigurationOutput,
) {
  use intelligent_tiering_configuration <- decode.optional_field(
    "IntelligentTieringConfiguration",
    option.None,
    decode.optional(decode_intelligent_tiering_configuration_struct()),
  )
  decode.success(GetBucketIntelligentTieringConfigurationOutput(
    intelligent_tiering_configuration: intelligent_tiering_configuration,
  ))
}

pub type IntelligentTieringConfiguration {
  IntelligentTieringConfiguration(
    filter: option.Option(IntelligentTieringFilter),
    id: option.Option(String),
    status: option.Option(IntelligentTieringStatus),
    tierings: option.Option(List(Tiering)),
  )
}

pub fn encode_intelligent_tiering_configuration_struct(
  input: IntelligentTieringConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.filter {
    option.Some(v) -> [
      #("Filter", encode_intelligent_tiering_filter_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_intelligent_tiering_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.tierings {
    option.Some(v) -> [
      #("Tierings", fn(xs) { json.array(xs, encode_tiering_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_intelligent_tiering_configuration_struct() -> decode.Decoder(
  IntelligentTieringConfiguration,
) {
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_intelligent_tiering_filter_struct()),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_intelligent_tiering_status_enum()),
  )
  use tierings <- decode.optional_field(
    "Tierings",
    option.None,
    decode.optional(decode.list(decode_tiering_struct())),
  )
  decode.success(IntelligentTieringConfiguration(
    filter: filter,
    id: id,
    status: status,
    tierings: tierings,
  ))
}

pub type IntelligentTieringFilter {
  IntelligentTieringFilter(
    and: option.Option(IntelligentTieringAndOperator),
    prefix: option.Option(String),
    tag: option.Option(Tag),
  )
}

pub fn encode_intelligent_tiering_filter_struct(
  input: IntelligentTieringFilter,
) -> json.Json {
  let pairs = []
  let pairs = case input.and {
    option.Some(v) -> [
      #("And", encode_intelligent_tiering_and_operator_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tag {
    option.Some(v) -> [#("Tag", encode_tag_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_intelligent_tiering_filter_struct() -> decode.Decoder(
  IntelligentTieringFilter,
) {
  use and <- decode.optional_field(
    "And",
    option.None,
    decode.optional(decode_intelligent_tiering_and_operator_struct()),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tag <- decode.optional_field(
    "Tag",
    option.None,
    decode.optional(decode_tag_struct()),
  )
  decode.success(IntelligentTieringFilter(and: and, prefix: prefix, tag: tag))
}

pub type IntelligentTieringAndOperator {
  IntelligentTieringAndOperator(
    prefix: option.Option(String),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_intelligent_tiering_and_operator_struct(
  input: IntelligentTieringAndOperator,
) -> json.Json {
  let pairs = []
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_intelligent_tiering_and_operator_struct() -> decode.Decoder(
  IntelligentTieringAndOperator,
) {
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(IntelligentTieringAndOperator(prefix: prefix, tags: tags))
}

pub type IntelligentTieringStatus {
  IntelligentTieringStatusDisabled
  IntelligentTieringStatusEnabled
}

pub fn encode_intelligent_tiering_status_enum(
  v: IntelligentTieringStatus,
) -> json.Json {
  case v {
    IntelligentTieringStatusDisabled -> json.string("Disabled")
    IntelligentTieringStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_intelligent_tiering_status_enum() -> decode.Decoder(
  IntelligentTieringStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(IntelligentTieringStatusDisabled)
      "Enabled" -> decode.success(IntelligentTieringStatusEnabled)
      _ ->
        decode.failure(IntelligentTieringStatusDisabled, "unknown enum value")
    }
  })
}

pub type Tiering {
  Tiering(
    access_tier: option.Option(IntelligentTieringAccessTier),
    days: option.Option(Int),
  )
}

pub fn encode_tiering_struct(input: Tiering) -> json.Json {
  let pairs = []
  let pairs = case input.access_tier {
    option.Some(v) -> [
      #("AccessTier", encode_intelligent_tiering_access_tier_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.days {
    option.Some(v) -> [#("Days", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_tiering_struct() -> decode.Decoder(Tiering) {
  use access_tier <- decode.optional_field(
    "AccessTier",
    option.None,
    decode.optional(decode_intelligent_tiering_access_tier_enum()),
  )
  use days <- decode.optional_field(
    "Days",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(Tiering(access_tier: access_tier, days: days))
}

pub type IntelligentTieringAccessTier {
  IntelligentTieringAccessTierArchiveAccess
  IntelligentTieringAccessTierDeepArchiveAccess
}

pub fn encode_intelligent_tiering_access_tier_enum(
  v: IntelligentTieringAccessTier,
) -> json.Json {
  case v {
    IntelligentTieringAccessTierArchiveAccess -> json.string("ARCHIVE_ACCESS")
    IntelligentTieringAccessTierDeepArchiveAccess ->
      json.string("DEEP_ARCHIVE_ACCESS")
  }
}

pub fn decode_intelligent_tiering_access_tier_enum() -> decode.Decoder(
  IntelligentTieringAccessTier,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "ARCHIVE_ACCESS" ->
        decode.success(IntelligentTieringAccessTierArchiveAccess)
      "DEEP_ARCHIVE_ACCESS" ->
        decode.success(IntelligentTieringAccessTierDeepArchiveAccess)
      _ ->
        decode.failure(
          IntelligentTieringAccessTierArchiveAccess,
          "unknown enum value",
        )
    }
  })
}

pub type GetBucketInventoryConfigurationRequest {
  GetBucketInventoryConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_get_bucket_inventory_configuration_request_struct(
  input: GetBucketInventoryConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_inventory_configuration_request_struct() -> decode.Decoder(
  GetBucketInventoryConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketInventoryConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type GetBucketInventoryConfigurationOutput {
  GetBucketInventoryConfigurationOutput(
    inventory_configuration: option.Option(InventoryConfiguration),
  )
}

pub fn encode_get_bucket_inventory_configuration_output_struct(
  input: GetBucketInventoryConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.inventory_configuration {
    option.Some(v) -> [
      #("InventoryConfiguration", encode_inventory_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_inventory_configuration_output_struct() -> decode.Decoder(
  GetBucketInventoryConfigurationOutput,
) {
  use inventory_configuration <- decode.optional_field(
    "InventoryConfiguration",
    option.None,
    decode.optional(decode_inventory_configuration_struct()),
  )
  decode.success(GetBucketInventoryConfigurationOutput(
    inventory_configuration: inventory_configuration,
  ))
}

pub type InventoryConfiguration {
  InventoryConfiguration(
    destination: option.Option(InventoryDestination),
    filter: option.Option(InventoryFilter),
    id: option.Option(String),
    included_object_versions: option.Option(InventoryIncludedObjectVersions),
    is_enabled: option.Option(Bool),
    optional_fields: option.Option(List(InventoryOptionalField)),
    schedule: option.Option(InventorySchedule),
  )
}

pub fn encode_inventory_configuration_struct(
  input: InventoryConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.destination {
    option.Some(v) -> [
      #("Destination", encode_inventory_destination_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter {
    option.Some(v) -> [#("Filter", encode_inventory_filter_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.included_object_versions {
    option.Some(v) -> [
      #(
        "IncludedObjectVersions",
        encode_inventory_included_object_versions_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.is_enabled {
    option.Some(v) -> [#("IsEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.optional_fields {
    option.Some(v) -> [
      #(
        "OptionalFields",
        fn(xs) { json.array(xs, encode_inventory_optional_field_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.schedule {
    option.Some(v) -> [
      #("Schedule", encode_inventory_schedule_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_inventory_configuration_struct() -> decode.Decoder(
  InventoryConfiguration,
) {
  use destination <- decode.optional_field(
    "Destination",
    option.None,
    decode.optional(decode_inventory_destination_struct()),
  )
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_inventory_filter_struct()),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use included_object_versions <- decode.optional_field(
    "IncludedObjectVersions",
    option.None,
    decode.optional(decode_inventory_included_object_versions_enum()),
  )
  use is_enabled <- decode.optional_field(
    "IsEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use optional_fields <- decode.optional_field(
    "OptionalFields",
    option.None,
    decode.optional(decode.list(decode_inventory_optional_field_enum())),
  )
  use schedule <- decode.optional_field(
    "Schedule",
    option.None,
    decode.optional(decode_inventory_schedule_struct()),
  )
  decode.success(InventoryConfiguration(
    destination: destination,
    filter: filter,
    id: id,
    included_object_versions: included_object_versions,
    is_enabled: is_enabled,
    optional_fields: optional_fields,
    schedule: schedule,
  ))
}

pub type InventoryDestination {
  InventoryDestination(
    s3_bucket_destination: option.Option(InventoryS3BucketDestination),
  )
}

pub fn encode_inventory_destination_struct(
  input: InventoryDestination,
) -> json.Json {
  let pairs = []
  let pairs = case input.s3_bucket_destination {
    option.Some(v) -> [
      #("S3BucketDestination", encode_inventory_s3_bucket_destination_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_inventory_destination_struct() -> decode.Decoder(
  InventoryDestination,
) {
  use s3_bucket_destination <- decode.optional_field(
    "S3BucketDestination",
    option.None,
    decode.optional(decode_inventory_s3_bucket_destination_struct()),
  )
  decode.success(InventoryDestination(
    s3_bucket_destination: s3_bucket_destination,
  ))
}

pub type InventoryS3BucketDestination {
  InventoryS3BucketDestination(
    account_id: option.Option(String),
    bucket: option.Option(String),
    encryption: option.Option(InventoryEncryption),
    format: option.Option(InventoryFormat),
    prefix: option.Option(String),
  )
}

pub fn encode_inventory_s3_bucket_destination_struct(
  input: InventoryS3BucketDestination,
) -> json.Json {
  let pairs = []
  let pairs = case input.account_id {
    option.Some(v) -> [#("AccountId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encryption {
    option.Some(v) -> [
      #("Encryption", encode_inventory_encryption_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.format {
    option.Some(v) -> [#("Format", encode_inventory_format_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_inventory_s3_bucket_destination_struct() -> decode.Decoder(
  InventoryS3BucketDestination,
) {
  use account_id <- decode.optional_field(
    "AccountId",
    option.None,
    decode.optional(decode.string),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use encryption <- decode.optional_field(
    "Encryption",
    option.None,
    decode.optional(decode_inventory_encryption_struct()),
  )
  use format <- decode.optional_field(
    "Format",
    option.None,
    decode.optional(decode_inventory_format_enum()),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(InventoryS3BucketDestination(
    account_id: account_id,
    bucket: bucket,
    encryption: encryption,
    format: format,
    prefix: prefix,
  ))
}

pub type InventoryEncryption {
  InventoryEncryption(
    ssekms: option.Option(SSEKMS),
    sses3: option.Option(SSES3),
  )
}

pub fn encode_inventory_encryption_struct(
  input: InventoryEncryption,
) -> json.Json {
  let pairs = []
  let pairs = case input.ssekms {
    option.Some(v) -> [#("SSEKMS", encode_ssekms_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sses3 {
    option.Some(v) -> [#("SSES3", encode_sses3_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_inventory_encryption_struct() -> decode.Decoder(
  InventoryEncryption,
) {
  use ssekms <- decode.optional_field(
    "SSEKMS",
    option.None,
    decode.optional(decode_ssekms_struct()),
  )
  use sses3 <- decode.optional_field(
    "SSES3",
    option.None,
    decode.optional(decode_sses3_struct()),
  )
  decode.success(InventoryEncryption(ssekms: ssekms, sses3: sses3))
}

pub type SSEKMS {
  SSEKMS(key_id: option.Option(String))
}

pub fn encode_ssekms_struct(input: SSEKMS) -> json.Json {
  let pairs = []
  let pairs = case input.key_id {
    option.Some(v) -> [#("KeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_ssekms_struct() -> decode.Decoder(SSEKMS) {
  use key_id <- decode.optional_field(
    "KeyId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(SSEKMS(key_id: key_id))
}

pub type SSES3 {
  SSES3
}

pub fn encode_sses3_struct(_v: SSES3) -> json.Json {
  json.object([])
}

pub fn decode_sses3_struct() -> decode.Decoder(SSES3) {
  decode.success(SSES3)
}

pub type InventoryFormat {
  InventoryFormatCsv
  InventoryFormatOrc
  InventoryFormatParquet
}

pub fn encode_inventory_format_enum(v: InventoryFormat) -> json.Json {
  case v {
    InventoryFormatCsv -> json.string("CSV")
    InventoryFormatOrc -> json.string("ORC")
    InventoryFormatParquet -> json.string("Parquet")
  }
}

pub fn decode_inventory_format_enum() -> decode.Decoder(InventoryFormat) {
  decode.then(decode.string, fn(s) {
    case s {
      "CSV" -> decode.success(InventoryFormatCsv)
      "ORC" -> decode.success(InventoryFormatOrc)
      "Parquet" -> decode.success(InventoryFormatParquet)
      _ -> decode.failure(InventoryFormatCsv, "unknown enum value")
    }
  })
}

pub type InventoryFilter {
  InventoryFilter(prefix: option.Option(String))
}

pub fn encode_inventory_filter_struct(input: InventoryFilter) -> json.Json {
  let pairs = []
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_inventory_filter_struct() -> decode.Decoder(InventoryFilter) {
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(InventoryFilter(prefix: prefix))
}

pub type InventoryIncludedObjectVersions {
  InventoryIncludedObjectVersionsAll
  InventoryIncludedObjectVersionsCurrent
}

pub fn encode_inventory_included_object_versions_enum(
  v: InventoryIncludedObjectVersions,
) -> json.Json {
  case v {
    InventoryIncludedObjectVersionsAll -> json.string("All")
    InventoryIncludedObjectVersionsCurrent -> json.string("Current")
  }
}

pub fn decode_inventory_included_object_versions_enum() -> decode.Decoder(
  InventoryIncludedObjectVersions,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "All" -> decode.success(InventoryIncludedObjectVersionsAll)
      "Current" -> decode.success(InventoryIncludedObjectVersionsCurrent)
      _ ->
        decode.failure(InventoryIncludedObjectVersionsAll, "unknown enum value")
    }
  })
}

pub type InventoryOptionalField {
  InventoryOptionalFieldBucketkeystatus
  InventoryOptionalFieldChecksumalgorithm
  InventoryOptionalFieldEtag
  InventoryOptionalFieldEncryptionstatus
  InventoryOptionalFieldIntelligenttieringaccesstier
  InventoryOptionalFieldIsmultipartuploaded
  InventoryOptionalFieldLastmodifieddate
  InventoryOptionalFieldLifecycleexpirationdate
  InventoryOptionalFieldObjectaccesscontrollist
  InventoryOptionalFieldObjectlocklegalholdstatus
  InventoryOptionalFieldObjectlockmode
  InventoryOptionalFieldObjectlockretainuntildate
  InventoryOptionalFieldObjectowner
  InventoryOptionalFieldReplicationstatus
  InventoryOptionalFieldSize
  InventoryOptionalFieldStorageclass
}

pub fn encode_inventory_optional_field_enum(
  v: InventoryOptionalField,
) -> json.Json {
  case v {
    InventoryOptionalFieldBucketkeystatus -> json.string("BucketKeyStatus")
    InventoryOptionalFieldChecksumalgorithm -> json.string("ChecksumAlgorithm")
    InventoryOptionalFieldEtag -> json.string("ETag")
    InventoryOptionalFieldEncryptionstatus -> json.string("EncryptionStatus")
    InventoryOptionalFieldIntelligenttieringaccesstier ->
      json.string("IntelligentTieringAccessTier")
    InventoryOptionalFieldIsmultipartuploaded ->
      json.string("IsMultipartUploaded")
    InventoryOptionalFieldLastmodifieddate -> json.string("LastModifiedDate")
    InventoryOptionalFieldLifecycleexpirationdate ->
      json.string("LifecycleExpirationDate")
    InventoryOptionalFieldObjectaccesscontrollist ->
      json.string("ObjectAccessControlList")
    InventoryOptionalFieldObjectlocklegalholdstatus ->
      json.string("ObjectLockLegalHoldStatus")
    InventoryOptionalFieldObjectlockmode -> json.string("ObjectLockMode")
    InventoryOptionalFieldObjectlockretainuntildate ->
      json.string("ObjectLockRetainUntilDate")
    InventoryOptionalFieldObjectowner -> json.string("ObjectOwner")
    InventoryOptionalFieldReplicationstatus -> json.string("ReplicationStatus")
    InventoryOptionalFieldSize -> json.string("Size")
    InventoryOptionalFieldStorageclass -> json.string("StorageClass")
  }
}

pub fn decode_inventory_optional_field_enum() -> decode.Decoder(
  InventoryOptionalField,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "BucketKeyStatus" -> decode.success(InventoryOptionalFieldBucketkeystatus)
      "ChecksumAlgorithm" ->
        decode.success(InventoryOptionalFieldChecksumalgorithm)
      "ETag" -> decode.success(InventoryOptionalFieldEtag)
      "EncryptionStatus" ->
        decode.success(InventoryOptionalFieldEncryptionstatus)
      "IntelligentTieringAccessTier" ->
        decode.success(InventoryOptionalFieldIntelligenttieringaccesstier)
      "IsMultipartUploaded" ->
        decode.success(InventoryOptionalFieldIsmultipartuploaded)
      "LastModifiedDate" ->
        decode.success(InventoryOptionalFieldLastmodifieddate)
      "LifecycleExpirationDate" ->
        decode.success(InventoryOptionalFieldLifecycleexpirationdate)
      "ObjectAccessControlList" ->
        decode.success(InventoryOptionalFieldObjectaccesscontrollist)
      "ObjectLockLegalHoldStatus" ->
        decode.success(InventoryOptionalFieldObjectlocklegalholdstatus)
      "ObjectLockMode" -> decode.success(InventoryOptionalFieldObjectlockmode)
      "ObjectLockRetainUntilDate" ->
        decode.success(InventoryOptionalFieldObjectlockretainuntildate)
      "ObjectOwner" -> decode.success(InventoryOptionalFieldObjectowner)
      "ReplicationStatus" ->
        decode.success(InventoryOptionalFieldReplicationstatus)
      "Size" -> decode.success(InventoryOptionalFieldSize)
      "StorageClass" -> decode.success(InventoryOptionalFieldStorageclass)
      _ ->
        decode.failure(
          InventoryOptionalFieldBucketkeystatus,
          "unknown enum value",
        )
    }
  })
}

pub type InventorySchedule {
  InventorySchedule(frequency: option.Option(InventoryFrequency))
}

pub fn encode_inventory_schedule_struct(input: InventorySchedule) -> json.Json {
  let pairs = []
  let pairs = case input.frequency {
    option.Some(v) -> [
      #("Frequency", encode_inventory_frequency_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_inventory_schedule_struct() -> decode.Decoder(InventorySchedule) {
  use frequency <- decode.optional_field(
    "Frequency",
    option.None,
    decode.optional(decode_inventory_frequency_enum()),
  )
  decode.success(InventorySchedule(frequency: frequency))
}

pub type InventoryFrequency {
  InventoryFrequencyDaily
  InventoryFrequencyWeekly
}

pub fn encode_inventory_frequency_enum(v: InventoryFrequency) -> json.Json {
  case v {
    InventoryFrequencyDaily -> json.string("Daily")
    InventoryFrequencyWeekly -> json.string("Weekly")
  }
}

pub fn decode_inventory_frequency_enum() -> decode.Decoder(InventoryFrequency) {
  decode.then(decode.string, fn(s) {
    case s {
      "Daily" -> decode.success(InventoryFrequencyDaily)
      "Weekly" -> decode.success(InventoryFrequencyWeekly)
      _ -> decode.failure(InventoryFrequencyDaily, "unknown enum value")
    }
  })
}

pub type GetBucketLifecycleConfigurationRequest {
  GetBucketLifecycleConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_lifecycle_configuration_request_struct(
  input: GetBucketLifecycleConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_lifecycle_configuration_request_struct() -> decode.Decoder(
  GetBucketLifecycleConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketLifecycleConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketLifecycleConfigurationOutput {
  GetBucketLifecycleConfigurationOutput(
    rules: option.Option(List(LifecycleRule)),
    transition_default_minimum_object_size: option.Option(
      TransitionDefaultMinimumObjectSize,
    ),
  )
}

pub fn encode_get_bucket_lifecycle_configuration_output_struct(
  input: GetBucketLifecycleConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.rules {
    option.Some(v) -> [
      #("Rules", fn(xs) { json.array(xs, encode_lifecycle_rule_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.transition_default_minimum_object_size {
    option.Some(v) -> [
      #(
        "TransitionDefaultMinimumObjectSize",
        encode_transition_default_minimum_object_size_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_lifecycle_configuration_output_struct() -> decode.Decoder(
  GetBucketLifecycleConfigurationOutput,
) {
  use rules <- decode.optional_field(
    "Rules",
    option.None,
    decode.optional(decode.list(decode_lifecycle_rule_struct())),
  )
  use transition_default_minimum_object_size <- decode.optional_field(
    "TransitionDefaultMinimumObjectSize",
    option.None,
    decode.optional(decode_transition_default_minimum_object_size_enum()),
  )
  decode.success(GetBucketLifecycleConfigurationOutput(
    rules: rules,
    transition_default_minimum_object_size: transition_default_minimum_object_size,
  ))
}

pub type LifecycleRule {
  LifecycleRule(
    abort_incomplete_multipart_upload: option.Option(
      AbortIncompleteMultipartUpload,
    ),
    expiration: option.Option(LifecycleExpiration),
    filter: option.Option(LifecycleRuleFilter),
    id: option.Option(String),
    noncurrent_version_expiration: option.Option(NoncurrentVersionExpiration),
    noncurrent_version_transitions: option.Option(
      List(NoncurrentVersionTransition),
    ),
    prefix: option.Option(String),
    status: option.Option(ExpirationStatus),
    transitions: option.Option(List(Transition)),
  )
}

pub fn encode_lifecycle_rule_struct(input: LifecycleRule) -> json.Json {
  let pairs = []
  let pairs = case input.abort_incomplete_multipart_upload {
    option.Some(v) -> [
      #(
        "AbortIncompleteMultipartUpload",
        encode_abort_incomplete_multipart_upload_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expiration {
    option.Some(v) -> [
      #("Expiration", encode_lifecycle_expiration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter {
    option.Some(v) -> [
      #("Filter", encode_lifecycle_rule_filter_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("ID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.noncurrent_version_expiration {
    option.Some(v) -> [
      #(
        "NoncurrentVersionExpiration",
        encode_noncurrent_version_expiration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.noncurrent_version_transitions {
    option.Some(v) -> [
      #(
        "NoncurrentVersionTransitions",
        fn(xs) { json.array(xs, encode_noncurrent_version_transition_struct) }(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [#("Status", encode_expiration_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.transitions {
    option.Some(v) -> [
      #("Transitions", fn(xs) { json.array(xs, encode_transition_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_lifecycle_rule_struct() -> decode.Decoder(LifecycleRule) {
  use abort_incomplete_multipart_upload <- decode.optional_field(
    "AbortIncompleteMultipartUpload",
    option.None,
    decode.optional(decode_abort_incomplete_multipart_upload_struct()),
  )
  use expiration <- decode.optional_field(
    "Expiration",
    option.None,
    decode.optional(decode_lifecycle_expiration_struct()),
  )
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_lifecycle_rule_filter_struct()),
  )
  use id <- decode.optional_field(
    "ID",
    option.None,
    decode.optional(decode.string),
  )
  use noncurrent_version_expiration <- decode.optional_field(
    "NoncurrentVersionExpiration",
    option.None,
    decode.optional(decode_noncurrent_version_expiration_struct()),
  )
  use noncurrent_version_transitions <- decode.optional_field(
    "NoncurrentVersionTransitions",
    option.None,
    decode.optional(decode.list(decode_noncurrent_version_transition_struct())),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_expiration_status_enum()),
  )
  use transitions <- decode.optional_field(
    "Transitions",
    option.None,
    decode.optional(decode.list(decode_transition_struct())),
  )
  decode.success(LifecycleRule(
    abort_incomplete_multipart_upload: abort_incomplete_multipart_upload,
    expiration: expiration,
    filter: filter,
    id: id,
    noncurrent_version_expiration: noncurrent_version_expiration,
    noncurrent_version_transitions: noncurrent_version_transitions,
    prefix: prefix,
    status: status,
    transitions: transitions,
  ))
}

pub type AbortIncompleteMultipartUpload {
  AbortIncompleteMultipartUpload(days_after_initiation: option.Option(Int))
}

pub fn encode_abort_incomplete_multipart_upload_struct(
  input: AbortIncompleteMultipartUpload,
) -> json.Json {
  let pairs = []
  let pairs = case input.days_after_initiation {
    option.Some(v) -> [#("DaysAfterInitiation", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_abort_incomplete_multipart_upload_struct() -> decode.Decoder(
  AbortIncompleteMultipartUpload,
) {
  use days_after_initiation <- decode.optional_field(
    "DaysAfterInitiation",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(AbortIncompleteMultipartUpload(
    days_after_initiation: days_after_initiation,
  ))
}

pub type LifecycleExpiration {
  LifecycleExpiration(
    date: option.Option(Int),
    days: option.Option(Int),
    expired_object_delete_marker: option.Option(Bool),
  )
}

pub fn encode_lifecycle_expiration_struct(
  input: LifecycleExpiration,
) -> json.Json {
  let pairs = []
  let pairs = case input.date {
    option.Some(v) -> [#("Date", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.days {
    option.Some(v) -> [#("Days", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expired_object_delete_marker {
    option.Some(v) -> [#("ExpiredObjectDeleteMarker", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_lifecycle_expiration_struct() -> decode.Decoder(
  LifecycleExpiration,
) {
  use date <- decode.optional_field(
    "Date",
    option.None,
    decode.optional(decode.int),
  )
  use days <- decode.optional_field(
    "Days",
    option.None,
    decode.optional(decode.int),
  )
  use expired_object_delete_marker <- decode.optional_field(
    "ExpiredObjectDeleteMarker",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(LifecycleExpiration(
    date: date,
    days: days,
    expired_object_delete_marker: expired_object_delete_marker,
  ))
}

pub type LifecycleRuleFilter {
  LifecycleRuleFilter(
    and: option.Option(LifecycleRuleAndOperator),
    object_size_greater_than: option.Option(Int),
    object_size_less_than: option.Option(Int),
    prefix: option.Option(String),
    tag: option.Option(Tag),
  )
}

pub fn encode_lifecycle_rule_filter_struct(
  input: LifecycleRuleFilter,
) -> json.Json {
  let pairs = []
  let pairs = case input.and {
    option.Some(v) -> [
      #("And", encode_lifecycle_rule_and_operator_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_size_greater_than {
    option.Some(v) -> [#("ObjectSizeGreaterThan", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_size_less_than {
    option.Some(v) -> [#("ObjectSizeLessThan", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tag {
    option.Some(v) -> [#("Tag", encode_tag_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_lifecycle_rule_filter_struct() -> decode.Decoder(
  LifecycleRuleFilter,
) {
  use and <- decode.optional_field(
    "And",
    option.None,
    decode.optional(decode_lifecycle_rule_and_operator_struct()),
  )
  use object_size_greater_than <- decode.optional_field(
    "ObjectSizeGreaterThan",
    option.None,
    decode.optional(decode.int),
  )
  use object_size_less_than <- decode.optional_field(
    "ObjectSizeLessThan",
    option.None,
    decode.optional(decode.int),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tag <- decode.optional_field(
    "Tag",
    option.None,
    decode.optional(decode_tag_struct()),
  )
  decode.success(LifecycleRuleFilter(
    and: and,
    object_size_greater_than: object_size_greater_than,
    object_size_less_than: object_size_less_than,
    prefix: prefix,
    tag: tag,
  ))
}

pub type LifecycleRuleAndOperator {
  LifecycleRuleAndOperator(
    object_size_greater_than: option.Option(Int),
    object_size_less_than: option.Option(Int),
    prefix: option.Option(String),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_lifecycle_rule_and_operator_struct(
  input: LifecycleRuleAndOperator,
) -> json.Json {
  let pairs = []
  let pairs = case input.object_size_greater_than {
    option.Some(v) -> [#("ObjectSizeGreaterThan", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_size_less_than {
    option.Some(v) -> [#("ObjectSizeLessThan", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_lifecycle_rule_and_operator_struct() -> decode.Decoder(
  LifecycleRuleAndOperator,
) {
  use object_size_greater_than <- decode.optional_field(
    "ObjectSizeGreaterThan",
    option.None,
    decode.optional(decode.int),
  )
  use object_size_less_than <- decode.optional_field(
    "ObjectSizeLessThan",
    option.None,
    decode.optional(decode.int),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(LifecycleRuleAndOperator(
    object_size_greater_than: object_size_greater_than,
    object_size_less_than: object_size_less_than,
    prefix: prefix,
    tags: tags,
  ))
}

pub type NoncurrentVersionExpiration {
  NoncurrentVersionExpiration(
    newer_noncurrent_versions: option.Option(Int),
    noncurrent_days: option.Option(Int),
  )
}

pub fn encode_noncurrent_version_expiration_struct(
  input: NoncurrentVersionExpiration,
) -> json.Json {
  let pairs = []
  let pairs = case input.newer_noncurrent_versions {
    option.Some(v) -> [#("NewerNoncurrentVersions", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.noncurrent_days {
    option.Some(v) -> [#("NoncurrentDays", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_noncurrent_version_expiration_struct() -> decode.Decoder(
  NoncurrentVersionExpiration,
) {
  use newer_noncurrent_versions <- decode.optional_field(
    "NewerNoncurrentVersions",
    option.None,
    decode.optional(decode.int),
  )
  use noncurrent_days <- decode.optional_field(
    "NoncurrentDays",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(NoncurrentVersionExpiration(
    newer_noncurrent_versions: newer_noncurrent_versions,
    noncurrent_days: noncurrent_days,
  ))
}

pub type NoncurrentVersionTransition {
  NoncurrentVersionTransition(
    newer_noncurrent_versions: option.Option(Int),
    noncurrent_days: option.Option(Int),
    storage_class: option.Option(TransitionStorageClass),
  )
}

pub fn encode_noncurrent_version_transition_struct(
  input: NoncurrentVersionTransition,
) -> json.Json {
  let pairs = []
  let pairs = case input.newer_noncurrent_versions {
    option.Some(v) -> [#("NewerNoncurrentVersions", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.noncurrent_days {
    option.Some(v) -> [#("NoncurrentDays", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [
      #("StorageClass", encode_transition_storage_class_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_noncurrent_version_transition_struct() -> decode.Decoder(
  NoncurrentVersionTransition,
) {
  use newer_noncurrent_versions <- decode.optional_field(
    "NewerNoncurrentVersions",
    option.None,
    decode.optional(decode.int),
  )
  use noncurrent_days <- decode.optional_field(
    "NoncurrentDays",
    option.None,
    decode.optional(decode.int),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_transition_storage_class_enum()),
  )
  decode.success(NoncurrentVersionTransition(
    newer_noncurrent_versions: newer_noncurrent_versions,
    noncurrent_days: noncurrent_days,
    storage_class: storage_class,
  ))
}

pub type TransitionStorageClass {
  TransitionStorageClassDeepArchive
  TransitionStorageClassGlacier
  TransitionStorageClassGlacierIr
  TransitionStorageClassIntelligentTiering
  TransitionStorageClassOnezoneIa
  TransitionStorageClassStandardIa
}

pub fn encode_transition_storage_class_enum(
  v: TransitionStorageClass,
) -> json.Json {
  case v {
    TransitionStorageClassDeepArchive -> json.string("DEEP_ARCHIVE")
    TransitionStorageClassGlacier -> json.string("GLACIER")
    TransitionStorageClassGlacierIr -> json.string("GLACIER_IR")
    TransitionStorageClassIntelligentTiering ->
      json.string("INTELLIGENT_TIERING")
    TransitionStorageClassOnezoneIa -> json.string("ONEZONE_IA")
    TransitionStorageClassStandardIa -> json.string("STANDARD_IA")
  }
}

pub fn decode_transition_storage_class_enum() -> decode.Decoder(
  TransitionStorageClass,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DEEP_ARCHIVE" -> decode.success(TransitionStorageClassDeepArchive)
      "GLACIER" -> decode.success(TransitionStorageClassGlacier)
      "GLACIER_IR" -> decode.success(TransitionStorageClassGlacierIr)
      "INTELLIGENT_TIERING" ->
        decode.success(TransitionStorageClassIntelligentTiering)
      "ONEZONE_IA" -> decode.success(TransitionStorageClassOnezoneIa)
      "STANDARD_IA" -> decode.success(TransitionStorageClassStandardIa)
      _ ->
        decode.failure(TransitionStorageClassDeepArchive, "unknown enum value")
    }
  })
}

pub type ExpirationStatus {
  ExpirationStatusDisabled
  ExpirationStatusEnabled
}

pub fn encode_expiration_status_enum(v: ExpirationStatus) -> json.Json {
  case v {
    ExpirationStatusDisabled -> json.string("Disabled")
    ExpirationStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_expiration_status_enum() -> decode.Decoder(ExpirationStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(ExpirationStatusDisabled)
      "Enabled" -> decode.success(ExpirationStatusEnabled)
      _ -> decode.failure(ExpirationStatusDisabled, "unknown enum value")
    }
  })
}

pub type Transition {
  Transition(
    date: option.Option(Int),
    days: option.Option(Int),
    storage_class: option.Option(TransitionStorageClass),
  )
}

pub fn encode_transition_struct(input: Transition) -> json.Json {
  let pairs = []
  let pairs = case input.date {
    option.Some(v) -> [#("Date", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.days {
    option.Some(v) -> [#("Days", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [
      #("StorageClass", encode_transition_storage_class_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_transition_struct() -> decode.Decoder(Transition) {
  use date <- decode.optional_field(
    "Date",
    option.None,
    decode.optional(decode.int),
  )
  use days <- decode.optional_field(
    "Days",
    option.None,
    decode.optional(decode.int),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_transition_storage_class_enum()),
  )
  decode.success(Transition(
    date: date,
    days: days,
    storage_class: storage_class,
  ))
}

pub type TransitionDefaultMinimumObjectSize {
  TransitionDefaultMinimumObjectSizeAllStorageClasses128k
  TransitionDefaultMinimumObjectSizeVariesByStorageClass
}

pub fn encode_transition_default_minimum_object_size_enum(
  v: TransitionDefaultMinimumObjectSize,
) -> json.Json {
  case v {
    TransitionDefaultMinimumObjectSizeAllStorageClasses128k ->
      json.string("all_storage_classes_128K")
    TransitionDefaultMinimumObjectSizeVariesByStorageClass ->
      json.string("varies_by_storage_class")
  }
}

pub fn decode_transition_default_minimum_object_size_enum() -> decode.Decoder(
  TransitionDefaultMinimumObjectSize,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "all_storage_classes_128K" ->
        decode.success(TransitionDefaultMinimumObjectSizeAllStorageClasses128k)
      "varies_by_storage_class" ->
        decode.success(TransitionDefaultMinimumObjectSizeVariesByStorageClass)
      _ ->
        decode.failure(
          TransitionDefaultMinimumObjectSizeAllStorageClasses128k,
          "unknown enum value",
        )
    }
  })
}

pub type GetBucketLocationRequest {
  GetBucketLocationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_location_request_struct(
  input: GetBucketLocationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_location_request_struct() -> decode.Decoder(
  GetBucketLocationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketLocationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketLocationOutput {
  GetBucketLocationOutput(
    location_constraint: option.Option(BucketLocationConstraint),
  )
}

pub fn encode_get_bucket_location_output_struct(
  input: GetBucketLocationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.location_constraint {
    option.Some(v) -> [
      #("LocationConstraint", encode_bucket_location_constraint_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_location_output_struct() -> decode.Decoder(
  GetBucketLocationOutput,
) {
  use location_constraint <- decode.optional_field(
    "LocationConstraint",
    option.None,
    decode.optional(decode_bucket_location_constraint_enum()),
  )
  decode.success(GetBucketLocationOutput(
    location_constraint: location_constraint,
  ))
}

pub type GetBucketLoggingRequest {
  GetBucketLoggingRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_logging_request_struct(
  input: GetBucketLoggingRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_logging_request_struct() -> decode.Decoder(
  GetBucketLoggingRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketLoggingRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketLoggingOutput {
  GetBucketLoggingOutput(logging_enabled: option.Option(LoggingEnabled))
}

pub fn encode_get_bucket_logging_output_struct(
  input: GetBucketLoggingOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.logging_enabled {
    option.Some(v) -> [
      #("LoggingEnabled", encode_logging_enabled_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_logging_output_struct() -> decode.Decoder(
  GetBucketLoggingOutput,
) {
  use logging_enabled <- decode.optional_field(
    "LoggingEnabled",
    option.None,
    decode.optional(decode_logging_enabled_struct()),
  )
  decode.success(GetBucketLoggingOutput(logging_enabled: logging_enabled))
}

pub type LoggingEnabled {
  LoggingEnabled(
    target_bucket: option.Option(String),
    target_grants: option.Option(List(TargetGrant)),
    target_object_key_format: option.Option(TargetObjectKeyFormat),
    target_prefix: option.Option(String),
  )
}

pub fn encode_logging_enabled_struct(input: LoggingEnabled) -> json.Json {
  let pairs = []
  let pairs = case input.target_bucket {
    option.Some(v) -> [#("TargetBucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.target_grants {
    option.Some(v) -> [
      #(
        "TargetGrants",
        fn(xs) { json.array(xs, encode_target_grant_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.target_object_key_format {
    option.Some(v) -> [
      #("TargetObjectKeyFormat", encode_target_object_key_format_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.target_prefix {
    option.Some(v) -> [#("TargetPrefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_logging_enabled_struct() -> decode.Decoder(LoggingEnabled) {
  use target_bucket <- decode.optional_field(
    "TargetBucket",
    option.None,
    decode.optional(decode.string),
  )
  use target_grants <- decode.optional_field(
    "TargetGrants",
    option.None,
    decode.optional(decode.list(decode_target_grant_struct())),
  )
  use target_object_key_format <- decode.optional_field(
    "TargetObjectKeyFormat",
    option.None,
    decode.optional(decode_target_object_key_format_struct()),
  )
  use target_prefix <- decode.optional_field(
    "TargetPrefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(LoggingEnabled(
    target_bucket: target_bucket,
    target_grants: target_grants,
    target_object_key_format: target_object_key_format,
    target_prefix: target_prefix,
  ))
}

pub type TargetGrant {
  TargetGrant(
    grantee: option.Option(Grantee),
    permission: option.Option(BucketLogsPermission),
  )
}

pub fn encode_target_grant_struct(input: TargetGrant) -> json.Json {
  let pairs = []
  let pairs = case input.grantee {
    option.Some(v) -> [#("Grantee", encode_grantee_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.permission {
    option.Some(v) -> [
      #("Permission", encode_bucket_logs_permission_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_target_grant_struct() -> decode.Decoder(TargetGrant) {
  use grantee <- decode.optional_field(
    "Grantee",
    option.None,
    decode.optional(decode_grantee_struct()),
  )
  use permission <- decode.optional_field(
    "Permission",
    option.None,
    decode.optional(decode_bucket_logs_permission_enum()),
  )
  decode.success(TargetGrant(grantee: grantee, permission: permission))
}

pub type BucketLogsPermission {
  BucketLogsPermissionFullControl
  BucketLogsPermissionRead
  BucketLogsPermissionWrite
}

pub fn encode_bucket_logs_permission_enum(
  v: BucketLogsPermission,
) -> json.Json {
  case v {
    BucketLogsPermissionFullControl -> json.string("FULL_CONTROL")
    BucketLogsPermissionRead -> json.string("READ")
    BucketLogsPermissionWrite -> json.string("WRITE")
  }
}

pub fn decode_bucket_logs_permission_enum() -> decode.Decoder(
  BucketLogsPermission,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "FULL_CONTROL" -> decode.success(BucketLogsPermissionFullControl)
      "READ" -> decode.success(BucketLogsPermissionRead)
      "WRITE" -> decode.success(BucketLogsPermissionWrite)
      _ -> decode.failure(BucketLogsPermissionFullControl, "unknown enum value")
    }
  })
}

pub type TargetObjectKeyFormat {
  TargetObjectKeyFormat(
    partitioned_prefix: option.Option(PartitionedPrefix),
    simple_prefix: option.Option(SimplePrefix),
  )
}

pub fn encode_target_object_key_format_struct(
  input: TargetObjectKeyFormat,
) -> json.Json {
  let pairs = []
  let pairs = case input.partitioned_prefix {
    option.Some(v) -> [
      #("PartitionedPrefix", encode_partitioned_prefix_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.simple_prefix {
    option.Some(v) -> [
      #("SimplePrefix", encode_simple_prefix_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_target_object_key_format_struct() -> decode.Decoder(
  TargetObjectKeyFormat,
) {
  use partitioned_prefix <- decode.optional_field(
    "PartitionedPrefix",
    option.None,
    decode.optional(decode_partitioned_prefix_struct()),
  )
  use simple_prefix <- decode.optional_field(
    "SimplePrefix",
    option.None,
    decode.optional(decode_simple_prefix_struct()),
  )
  decode.success(TargetObjectKeyFormat(
    partitioned_prefix: partitioned_prefix,
    simple_prefix: simple_prefix,
  ))
}

pub type PartitionedPrefix {
  PartitionedPrefix(partition_date_source: option.Option(PartitionDateSource))
}

pub fn encode_partitioned_prefix_struct(input: PartitionedPrefix) -> json.Json {
  let pairs = []
  let pairs = case input.partition_date_source {
    option.Some(v) -> [
      #("PartitionDateSource", encode_partition_date_source_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_partitioned_prefix_struct() -> decode.Decoder(PartitionedPrefix) {
  use partition_date_source <- decode.optional_field(
    "PartitionDateSource",
    option.None,
    decode.optional(decode_partition_date_source_enum()),
  )
  decode.success(PartitionedPrefix(partition_date_source: partition_date_source))
}

pub type PartitionDateSource {
  PartitionDateSourceDeliverytime
  PartitionDateSourceEventtime
}

pub fn encode_partition_date_source_enum(v: PartitionDateSource) -> json.Json {
  case v {
    PartitionDateSourceDeliverytime -> json.string("DeliveryTime")
    PartitionDateSourceEventtime -> json.string("EventTime")
  }
}

pub fn decode_partition_date_source_enum() -> decode.Decoder(
  PartitionDateSource,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DeliveryTime" -> decode.success(PartitionDateSourceDeliverytime)
      "EventTime" -> decode.success(PartitionDateSourceEventtime)
      _ -> decode.failure(PartitionDateSourceDeliverytime, "unknown enum value")
    }
  })
}

pub type SimplePrefix {
  SimplePrefix
}

pub fn encode_simple_prefix_struct(_v: SimplePrefix) -> json.Json {
  json.object([])
}

pub fn decode_simple_prefix_struct() -> decode.Decoder(SimplePrefix) {
  decode.success(SimplePrefix)
}

pub type GetBucketMetadataConfigurationRequest {
  GetBucketMetadataConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_metadata_configuration_request_struct(
  input: GetBucketMetadataConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metadata_configuration_request_struct() -> decode.Decoder(
  GetBucketMetadataConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketMetadataConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketMetadataConfigurationOutput {
  GetBucketMetadataConfigurationOutput(
    get_bucket_metadata_configuration_result: option.Option(
      GetBucketMetadataConfigurationResult,
    ),
  )
}

pub fn encode_get_bucket_metadata_configuration_output_struct(
  input: GetBucketMetadataConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.get_bucket_metadata_configuration_result {
    option.Some(v) -> [
      #(
        "GetBucketMetadataConfigurationResult",
        encode_get_bucket_metadata_configuration_result_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metadata_configuration_output_struct() -> decode.Decoder(
  GetBucketMetadataConfigurationOutput,
) {
  use get_bucket_metadata_configuration_result <- decode.optional_field(
    "GetBucketMetadataConfigurationResult",
    option.None,
    decode.optional(decode_get_bucket_metadata_configuration_result_struct()),
  )
  decode.success(GetBucketMetadataConfigurationOutput(
    get_bucket_metadata_configuration_result: get_bucket_metadata_configuration_result,
  ))
}

pub type GetBucketMetadataConfigurationResult {
  GetBucketMetadataConfigurationResult(
    metadata_configuration_result: option.Option(MetadataConfigurationResult),
  )
}

pub fn encode_get_bucket_metadata_configuration_result_struct(
  input: GetBucketMetadataConfigurationResult,
) -> json.Json {
  let pairs = []
  let pairs = case input.metadata_configuration_result {
    option.Some(v) -> [
      #(
        "MetadataConfigurationResult",
        encode_metadata_configuration_result_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metadata_configuration_result_struct() -> decode.Decoder(
  GetBucketMetadataConfigurationResult,
) {
  use metadata_configuration_result <- decode.optional_field(
    "MetadataConfigurationResult",
    option.None,
    decode.optional(decode_metadata_configuration_result_struct()),
  )
  decode.success(GetBucketMetadataConfigurationResult(
    metadata_configuration_result: metadata_configuration_result,
  ))
}

pub type MetadataConfigurationResult {
  MetadataConfigurationResult(
    destination_result: option.Option(DestinationResult),
    inventory_table_configuration_result: option.Option(
      InventoryTableConfigurationResult,
    ),
    journal_table_configuration_result: option.Option(
      JournalTableConfigurationResult,
    ),
  )
}

pub fn encode_metadata_configuration_result_struct(
  input: MetadataConfigurationResult,
) -> json.Json {
  let pairs = []
  let pairs = case input.destination_result {
    option.Some(v) -> [
      #("DestinationResult", encode_destination_result_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.inventory_table_configuration_result {
    option.Some(v) -> [
      #(
        "InventoryTableConfigurationResult",
        encode_inventory_table_configuration_result_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.journal_table_configuration_result {
    option.Some(v) -> [
      #(
        "JournalTableConfigurationResult",
        encode_journal_table_configuration_result_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_metadata_configuration_result_struct() -> decode.Decoder(
  MetadataConfigurationResult,
) {
  use destination_result <- decode.optional_field(
    "DestinationResult",
    option.None,
    decode.optional(decode_destination_result_struct()),
  )
  use inventory_table_configuration_result <- decode.optional_field(
    "InventoryTableConfigurationResult",
    option.None,
    decode.optional(decode_inventory_table_configuration_result_struct()),
  )
  use journal_table_configuration_result <- decode.optional_field(
    "JournalTableConfigurationResult",
    option.None,
    decode.optional(decode_journal_table_configuration_result_struct()),
  )
  decode.success(MetadataConfigurationResult(
    destination_result: destination_result,
    inventory_table_configuration_result: inventory_table_configuration_result,
    journal_table_configuration_result: journal_table_configuration_result,
  ))
}

pub type DestinationResult {
  DestinationResult(
    table_bucket_arn: option.Option(String),
    table_bucket_type: option.Option(S3TablesBucketType),
    table_namespace: option.Option(String),
  )
}

pub fn encode_destination_result_struct(input: DestinationResult) -> json.Json {
  let pairs = []
  let pairs = case input.table_bucket_arn {
    option.Some(v) -> [#("TableBucketArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_bucket_type {
    option.Some(v) -> [
      #("TableBucketType", encode_s3_tables_bucket_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_namespace {
    option.Some(v) -> [#("TableNamespace", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_destination_result_struct() -> decode.Decoder(DestinationResult) {
  use table_bucket_arn <- decode.optional_field(
    "TableBucketArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_bucket_type <- decode.optional_field(
    "TableBucketType",
    option.None,
    decode.optional(decode_s3_tables_bucket_type_enum()),
  )
  use table_namespace <- decode.optional_field(
    "TableNamespace",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DestinationResult(
    table_bucket_arn: table_bucket_arn,
    table_bucket_type: table_bucket_type,
    table_namespace: table_namespace,
  ))
}

pub type S3TablesBucketType {
  S3TablesBucketTypeAws
  S3TablesBucketTypeCustomer
}

pub fn encode_s3_tables_bucket_type_enum(v: S3TablesBucketType) -> json.Json {
  case v {
    S3TablesBucketTypeAws -> json.string("aws")
    S3TablesBucketTypeCustomer -> json.string("customer")
  }
}

pub fn decode_s3_tables_bucket_type_enum() -> decode.Decoder(S3TablesBucketType) {
  decode.then(decode.string, fn(s) {
    case s {
      "aws" -> decode.success(S3TablesBucketTypeAws)
      "customer" -> decode.success(S3TablesBucketTypeCustomer)
      _ -> decode.failure(S3TablesBucketTypeAws, "unknown enum value")
    }
  })
}

pub type InventoryTableConfigurationResult {
  InventoryTableConfigurationResult(
    configuration_state: option.Option(InventoryConfigurationState),
    error: option.Option(ErrorDetails),
    table_arn: option.Option(String),
    table_name: option.Option(String),
    table_status: option.Option(String),
  )
}

pub fn encode_inventory_table_configuration_result_struct(
  input: InventoryTableConfigurationResult,
) -> json.Json {
  let pairs = []
  let pairs = case input.configuration_state {
    option.Some(v) -> [
      #("ConfigurationState", encode_inventory_configuration_state_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.error {
    option.Some(v) -> [#("Error", encode_error_details_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_status {
    option.Some(v) -> [#("TableStatus", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_inventory_table_configuration_result_struct() -> decode.Decoder(
  InventoryTableConfigurationResult,
) {
  use configuration_state <- decode.optional_field(
    "ConfigurationState",
    option.None,
    decode.optional(decode_inventory_configuration_state_enum()),
  )
  use error <- decode.optional_field(
    "Error",
    option.None,
    decode.optional(decode_error_details_struct()),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use table_status <- decode.optional_field(
    "TableStatus",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(InventoryTableConfigurationResult(
    configuration_state: configuration_state,
    error: error,
    table_arn: table_arn,
    table_name: table_name,
    table_status: table_status,
  ))
}

pub type InventoryConfigurationState {
  InventoryConfigurationStateDisabled
  InventoryConfigurationStateEnabled
}

pub fn encode_inventory_configuration_state_enum(
  v: InventoryConfigurationState,
) -> json.Json {
  case v {
    InventoryConfigurationStateDisabled -> json.string("DISABLED")
    InventoryConfigurationStateEnabled -> json.string("ENABLED")
  }
}

pub fn decode_inventory_configuration_state_enum() -> decode.Decoder(
  InventoryConfigurationState,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(InventoryConfigurationStateDisabled)
      "ENABLED" -> decode.success(InventoryConfigurationStateEnabled)
      _ ->
        decode.failure(
          InventoryConfigurationStateDisabled,
          "unknown enum value",
        )
    }
  })
}

pub type ErrorDetails {
  ErrorDetails(
    error_code: option.Option(String),
    error_message: option.Option(String),
  )
}

pub fn encode_error_details_struct(input: ErrorDetails) -> json.Json {
  let pairs = []
  let pairs = case input.error_code {
    option.Some(v) -> [#("ErrorCode", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.error_message {
    option.Some(v) -> [#("ErrorMessage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_error_details_struct() -> decode.Decoder(ErrorDetails) {
  use error_code <- decode.optional_field(
    "ErrorCode",
    option.None,
    decode.optional(decode.string),
  )
  use error_message <- decode.optional_field(
    "ErrorMessage",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ErrorDetails(
    error_code: error_code,
    error_message: error_message,
  ))
}

pub type JournalTableConfigurationResult {
  JournalTableConfigurationResult(
    error: option.Option(ErrorDetails),
    record_expiration: option.Option(RecordExpiration),
    table_arn: option.Option(String),
    table_name: option.Option(String),
    table_status: option.Option(String),
  )
}

pub fn encode_journal_table_configuration_result_struct(
  input: JournalTableConfigurationResult,
) -> json.Json {
  let pairs = []
  let pairs = case input.error {
    option.Some(v) -> [#("Error", encode_error_details_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.record_expiration {
    option.Some(v) -> [
      #("RecordExpiration", encode_record_expiration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_status {
    option.Some(v) -> [#("TableStatus", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_journal_table_configuration_result_struct() -> decode.Decoder(
  JournalTableConfigurationResult,
) {
  use error <- decode.optional_field(
    "Error",
    option.None,
    decode.optional(decode_error_details_struct()),
  )
  use record_expiration <- decode.optional_field(
    "RecordExpiration",
    option.None,
    decode.optional(decode_record_expiration_struct()),
  )
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use table_status <- decode.optional_field(
    "TableStatus",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(JournalTableConfigurationResult(
    error: error,
    record_expiration: record_expiration,
    table_arn: table_arn,
    table_name: table_name,
    table_status: table_status,
  ))
}

pub type RecordExpiration {
  RecordExpiration(
    days: option.Option(Int),
    expiration: option.Option(ExpirationState),
  )
}

pub fn encode_record_expiration_struct(input: RecordExpiration) -> json.Json {
  let pairs = []
  let pairs = case input.days {
    option.Some(v) -> [#("Days", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expiration {
    option.Some(v) -> [
      #("Expiration", encode_expiration_state_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_record_expiration_struct() -> decode.Decoder(RecordExpiration) {
  use days <- decode.optional_field(
    "Days",
    option.None,
    decode.optional(decode.int),
  )
  use expiration <- decode.optional_field(
    "Expiration",
    option.None,
    decode.optional(decode_expiration_state_enum()),
  )
  decode.success(RecordExpiration(days: days, expiration: expiration))
}

pub type ExpirationState {
  ExpirationStateDisabled
  ExpirationStateEnabled
}

pub fn encode_expiration_state_enum(v: ExpirationState) -> json.Json {
  case v {
    ExpirationStateDisabled -> json.string("DISABLED")
    ExpirationStateEnabled -> json.string("ENABLED")
  }
}

pub fn decode_expiration_state_enum() -> decode.Decoder(ExpirationState) {
  decode.then(decode.string, fn(s) {
    case s {
      "DISABLED" -> decode.success(ExpirationStateDisabled)
      "ENABLED" -> decode.success(ExpirationStateEnabled)
      _ -> decode.failure(ExpirationStateDisabled, "unknown enum value")
    }
  })
}

pub type GetBucketMetadataTableConfigurationRequest {
  GetBucketMetadataTableConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_metadata_table_configuration_request_struct(
  input: GetBucketMetadataTableConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metadata_table_configuration_request_struct() -> decode.Decoder(
  GetBucketMetadataTableConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketMetadataTableConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketMetadataTableConfigurationOutput {
  GetBucketMetadataTableConfigurationOutput(
    get_bucket_metadata_table_configuration_result: option.Option(
      GetBucketMetadataTableConfigurationResult,
    ),
  )
}

pub fn encode_get_bucket_metadata_table_configuration_output_struct(
  input: GetBucketMetadataTableConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.get_bucket_metadata_table_configuration_result {
    option.Some(v) -> [
      #(
        "GetBucketMetadataTableConfigurationResult",
        encode_get_bucket_metadata_table_configuration_result_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metadata_table_configuration_output_struct() -> decode.Decoder(
  GetBucketMetadataTableConfigurationOutput,
) {
  use get_bucket_metadata_table_configuration_result <- decode.optional_field(
    "GetBucketMetadataTableConfigurationResult",
    option.None,
    decode.optional(
      decode_get_bucket_metadata_table_configuration_result_struct(),
    ),
  )
  decode.success(GetBucketMetadataTableConfigurationOutput(
    get_bucket_metadata_table_configuration_result: get_bucket_metadata_table_configuration_result,
  ))
}

pub type GetBucketMetadataTableConfigurationResult {
  GetBucketMetadataTableConfigurationResult(
    error: option.Option(ErrorDetails),
    metadata_table_configuration_result: option.Option(
      MetadataTableConfigurationResult,
    ),
    status: option.Option(String),
  )
}

pub fn encode_get_bucket_metadata_table_configuration_result_struct(
  input: GetBucketMetadataTableConfigurationResult,
) -> json.Json {
  let pairs = []
  let pairs = case input.error {
    option.Some(v) -> [#("Error", encode_error_details_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.metadata_table_configuration_result {
    option.Some(v) -> [
      #(
        "MetadataTableConfigurationResult",
        encode_metadata_table_configuration_result_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [#("Status", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metadata_table_configuration_result_struct() -> decode.Decoder(
  GetBucketMetadataTableConfigurationResult,
) {
  use error <- decode.optional_field(
    "Error",
    option.None,
    decode.optional(decode_error_details_struct()),
  )
  use metadata_table_configuration_result <- decode.optional_field(
    "MetadataTableConfigurationResult",
    option.None,
    decode.optional(decode_metadata_table_configuration_result_struct()),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketMetadataTableConfigurationResult(
    error: error,
    metadata_table_configuration_result: metadata_table_configuration_result,
    status: status,
  ))
}

pub type MetadataTableConfigurationResult {
  MetadataTableConfigurationResult(
    s3_tables_destination_result: option.Option(S3TablesDestinationResult),
  )
}

pub fn encode_metadata_table_configuration_result_struct(
  input: MetadataTableConfigurationResult,
) -> json.Json {
  let pairs = []
  let pairs = case input.s3_tables_destination_result {
    option.Some(v) -> [
      #(
        "S3TablesDestinationResult",
        encode_s3_tables_destination_result_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_metadata_table_configuration_result_struct() -> decode.Decoder(
  MetadataTableConfigurationResult,
) {
  use s3_tables_destination_result <- decode.optional_field(
    "S3TablesDestinationResult",
    option.None,
    decode.optional(decode_s3_tables_destination_result_struct()),
  )
  decode.success(MetadataTableConfigurationResult(
    s3_tables_destination_result: s3_tables_destination_result,
  ))
}

pub type S3TablesDestinationResult {
  S3TablesDestinationResult(
    table_arn: option.Option(String),
    table_bucket_arn: option.Option(String),
    table_name: option.Option(String),
    table_namespace: option.Option(String),
  )
}

pub fn encode_s3_tables_destination_result_struct(
  input: S3TablesDestinationResult,
) -> json.Json {
  let pairs = []
  let pairs = case input.table_arn {
    option.Some(v) -> [#("TableArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_bucket_arn {
    option.Some(v) -> [#("TableBucketArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_name {
    option.Some(v) -> [#("TableName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.table_namespace {
    option.Some(v) -> [#("TableNamespace", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_s3_tables_destination_result_struct() -> decode.Decoder(
  S3TablesDestinationResult,
) {
  use table_arn <- decode.optional_field(
    "TableArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_bucket_arn <- decode.optional_field(
    "TableBucketArn",
    option.None,
    decode.optional(decode.string),
  )
  use table_name <- decode.optional_field(
    "TableName",
    option.None,
    decode.optional(decode.string),
  )
  use table_namespace <- decode.optional_field(
    "TableNamespace",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(S3TablesDestinationResult(
    table_arn: table_arn,
    table_bucket_arn: table_bucket_arn,
    table_name: table_name,
    table_namespace: table_namespace,
  ))
}

pub type GetBucketMetricsConfigurationRequest {
  GetBucketMetricsConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_get_bucket_metrics_configuration_request_struct(
  input: GetBucketMetricsConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metrics_configuration_request_struct() -> decode.Decoder(
  GetBucketMetricsConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketMetricsConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type GetBucketMetricsConfigurationOutput {
  GetBucketMetricsConfigurationOutput(
    metrics_configuration: option.Option(MetricsConfiguration),
  )
}

pub fn encode_get_bucket_metrics_configuration_output_struct(
  input: GetBucketMetricsConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.metrics_configuration {
    option.Some(v) -> [
      #("MetricsConfiguration", encode_metrics_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_metrics_configuration_output_struct() -> decode.Decoder(
  GetBucketMetricsConfigurationOutput,
) {
  use metrics_configuration <- decode.optional_field(
    "MetricsConfiguration",
    option.None,
    decode.optional(decode_metrics_configuration_struct()),
  )
  decode.success(GetBucketMetricsConfigurationOutput(
    metrics_configuration: metrics_configuration,
  ))
}

pub type MetricsConfiguration {
  MetricsConfiguration(
    filter: option.Option(MetricsFilter),
    id: option.Option(String),
  )
}

pub fn encode_metrics_configuration_struct(
  input: MetricsConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.filter {
    option.Some(v) -> [#("Filter", encode_metrics_filter_union(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_metrics_configuration_struct() -> decode.Decoder(
  MetricsConfiguration,
) {
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_metrics_filter_union()),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MetricsConfiguration(filter: filter, id: id))
}

pub type MetricsFilter {
  MetricsFilterAccessPointArn(String)
  MetricsFilterAnd(MetricsAndOperator)
  MetricsFilterPrefix(String)
  MetricsFilterTag(Tag)
}

pub fn encode_metrics_filter_union(v: MetricsFilter) -> json.Json {
  case v {
    MetricsFilterAccessPointArn(x) ->
      json.object([#("AccessPointArn", json.string(x))])
    MetricsFilterAnd(x) ->
      json.object([#("And", encode_metrics_and_operator_struct(x))])
    MetricsFilterPrefix(x) -> json.object([#("Prefix", json.string(x))])
    MetricsFilterTag(x) -> json.object([#("Tag", encode_tag_struct(x))])
  }
}

pub fn decode_metrics_filter_union() -> decode.Decoder(MetricsFilter) {
  decode.one_of(
    decode.field("AccessPointArn", decode.string, fn(x) {
      decode.success(MetricsFilterAccessPointArn(x))
    }),
    [
      decode.field("And", decode_metrics_and_operator_struct(), fn(x) {
        decode.success(MetricsFilterAnd(x))
      }),
      decode.field("Prefix", decode.string, fn(x) {
        decode.success(MetricsFilterPrefix(x))
      }),
      decode.field("Tag", decode_tag_struct(), fn(x) {
        decode.success(MetricsFilterTag(x))
      }),
    ],
  )
}

pub type MetricsAndOperator {
  MetricsAndOperator(
    access_point_arn: option.Option(String),
    prefix: option.Option(String),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_metrics_and_operator_struct(
  input: MetricsAndOperator,
) -> json.Json {
  let pairs = []
  let pairs = case input.access_point_arn {
    option.Some(v) -> [#("AccessPointArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_metrics_and_operator_struct() -> decode.Decoder(
  MetricsAndOperator,
) {
  use access_point_arn <- decode.optional_field(
    "AccessPointArn",
    option.None,
    decode.optional(decode.string),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(MetricsAndOperator(
    access_point_arn: access_point_arn,
    prefix: prefix,
    tags: tags,
  ))
}

pub type GetBucketNotificationConfigurationRequest {
  GetBucketNotificationConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_notification_configuration_request_struct(
  input: GetBucketNotificationConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_notification_configuration_request_struct() -> decode.Decoder(
  GetBucketNotificationConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketNotificationConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type NotificationConfiguration {
  NotificationConfiguration(
    event_bridge_configuration: option.Option(EventBridgeConfiguration),
    lambda_function_configurations: option.Option(
      List(LambdaFunctionConfiguration),
    ),
    queue_configurations: option.Option(List(QueueConfiguration)),
    topic_configurations: option.Option(List(TopicConfiguration)),
  )
}

pub fn encode_notification_configuration_struct(
  input: NotificationConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.event_bridge_configuration {
    option.Some(v) -> [
      #("EventBridgeConfiguration", encode_event_bridge_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.lambda_function_configurations {
    option.Some(v) -> [
      #(
        "LambdaFunctionConfigurations",
        fn(xs) { json.array(xs, encode_lambda_function_configuration_struct) }(
          v,
        ),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.queue_configurations {
    option.Some(v) -> [
      #(
        "QueueConfigurations",
        fn(xs) { json.array(xs, encode_queue_configuration_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.topic_configurations {
    option.Some(v) -> [
      #(
        "TopicConfigurations",
        fn(xs) { json.array(xs, encode_topic_configuration_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_notification_configuration_struct() -> decode.Decoder(
  NotificationConfiguration,
) {
  use event_bridge_configuration <- decode.optional_field(
    "EventBridgeConfiguration",
    option.None,
    decode.optional(decode_event_bridge_configuration_struct()),
  )
  use lambda_function_configurations <- decode.optional_field(
    "LambdaFunctionConfigurations",
    option.None,
    decode.optional(decode.list(decode_lambda_function_configuration_struct())),
  )
  use queue_configurations <- decode.optional_field(
    "QueueConfigurations",
    option.None,
    decode.optional(decode.list(decode_queue_configuration_struct())),
  )
  use topic_configurations <- decode.optional_field(
    "TopicConfigurations",
    option.None,
    decode.optional(decode.list(decode_topic_configuration_struct())),
  )
  decode.success(NotificationConfiguration(
    event_bridge_configuration: event_bridge_configuration,
    lambda_function_configurations: lambda_function_configurations,
    queue_configurations: queue_configurations,
    topic_configurations: topic_configurations,
  ))
}

pub type EventBridgeConfiguration {
  EventBridgeConfiguration
}

pub fn encode_event_bridge_configuration_struct(
  _v: EventBridgeConfiguration,
) -> json.Json {
  json.object([])
}

pub fn decode_event_bridge_configuration_struct() -> decode.Decoder(
  EventBridgeConfiguration,
) {
  decode.success(EventBridgeConfiguration)
}

pub type LambdaFunctionConfiguration {
  LambdaFunctionConfiguration(
    events: option.Option(List(Event)),
    filter: option.Option(NotificationConfigurationFilter),
    id: option.Option(String),
    lambda_function_arn: option.Option(String),
  )
}

pub fn encode_lambda_function_configuration_struct(
  input: LambdaFunctionConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.events {
    option.Some(v) -> [
      #("Events", fn(xs) { json.array(xs, encode_event_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter {
    option.Some(v) -> [
      #("Filter", encode_notification_configuration_filter_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.lambda_function_arn {
    option.Some(v) -> [#("LambdaFunctionArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_lambda_function_configuration_struct() -> decode.Decoder(
  LambdaFunctionConfiguration,
) {
  use events <- decode.optional_field(
    "Events",
    option.None,
    decode.optional(decode.list(decode_event_enum())),
  )
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_notification_configuration_filter_struct()),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use lambda_function_arn <- decode.optional_field(
    "LambdaFunctionArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(LambdaFunctionConfiguration(
    events: events,
    filter: filter,
    id: id,
    lambda_function_arn: lambda_function_arn,
  ))
}

pub type Event {
  EventS3Intelligenttiering
  EventS3Lifecycleexpiration
  EventS3LifecycleexpirationDelete
  EventS3LifecycleexpirationDeletemarkercreated
  EventS3Lifecycletransition
  EventS3ObjectaclPut
  EventS3Objectcreated
  EventS3ObjectcreatedCompletemultipartupload
  EventS3ObjectcreatedCopy
  EventS3ObjectcreatedPost
  EventS3ObjectcreatedPut
  EventS3Objectremoved
  EventS3ObjectremovedDelete
  EventS3ObjectremovedDeletemarkercreated
  EventS3Objectrestore
  EventS3ObjectrestoreCompleted
  EventS3ObjectrestoreDelete
  EventS3ObjectrestorePost
  EventS3Objecttagging
  EventS3ObjecttaggingDelete
  EventS3ObjecttaggingPut
  EventS3Reducedredundancylostobject
  EventS3Replication
  EventS3ReplicationOperationfailedreplication
  EventS3ReplicationOperationmissedthreshold
  EventS3ReplicationOperationnottracked
  EventS3ReplicationOperationreplicatedafterthreshold
}

pub fn encode_event_enum(v: Event) -> json.Json {
  case v {
    EventS3Intelligenttiering -> json.string("s3:IntelligentTiering")
    EventS3Lifecycleexpiration -> json.string("s3:LifecycleExpiration:*")
    EventS3LifecycleexpirationDelete ->
      json.string("s3:LifecycleExpiration:Delete")
    EventS3LifecycleexpirationDeletemarkercreated ->
      json.string("s3:LifecycleExpiration:DeleteMarkerCreated")
    EventS3Lifecycletransition -> json.string("s3:LifecycleTransition")
    EventS3ObjectaclPut -> json.string("s3:ObjectAcl:Put")
    EventS3Objectcreated -> json.string("s3:ObjectCreated:*")
    EventS3ObjectcreatedCompletemultipartupload ->
      json.string("s3:ObjectCreated:CompleteMultipartUpload")
    EventS3ObjectcreatedCopy -> json.string("s3:ObjectCreated:Copy")
    EventS3ObjectcreatedPost -> json.string("s3:ObjectCreated:Post")
    EventS3ObjectcreatedPut -> json.string("s3:ObjectCreated:Put")
    EventS3Objectremoved -> json.string("s3:ObjectRemoved:*")
    EventS3ObjectremovedDelete -> json.string("s3:ObjectRemoved:Delete")
    EventS3ObjectremovedDeletemarkercreated ->
      json.string("s3:ObjectRemoved:DeleteMarkerCreated")
    EventS3Objectrestore -> json.string("s3:ObjectRestore:*")
    EventS3ObjectrestoreCompleted -> json.string("s3:ObjectRestore:Completed")
    EventS3ObjectrestoreDelete -> json.string("s3:ObjectRestore:Delete")
    EventS3ObjectrestorePost -> json.string("s3:ObjectRestore:Post")
    EventS3Objecttagging -> json.string("s3:ObjectTagging:*")
    EventS3ObjecttaggingDelete -> json.string("s3:ObjectTagging:Delete")
    EventS3ObjecttaggingPut -> json.string("s3:ObjectTagging:Put")
    EventS3Reducedredundancylostobject ->
      json.string("s3:ReducedRedundancyLostObject")
    EventS3Replication -> json.string("s3:Replication:*")
    EventS3ReplicationOperationfailedreplication ->
      json.string("s3:Replication:OperationFailedReplication")
    EventS3ReplicationOperationmissedthreshold ->
      json.string("s3:Replication:OperationMissedThreshold")
    EventS3ReplicationOperationnottracked ->
      json.string("s3:Replication:OperationNotTracked")
    EventS3ReplicationOperationreplicatedafterthreshold ->
      json.string("s3:Replication:OperationReplicatedAfterThreshold")
  }
}

pub fn decode_event_enum() -> decode.Decoder(Event) {
  decode.then(decode.string, fn(s) {
    case s {
      "s3:IntelligentTiering" -> decode.success(EventS3Intelligenttiering)
      "s3:LifecycleExpiration:*" -> decode.success(EventS3Lifecycleexpiration)
      "s3:LifecycleExpiration:Delete" ->
        decode.success(EventS3LifecycleexpirationDelete)
      "s3:LifecycleExpiration:DeleteMarkerCreated" ->
        decode.success(EventS3LifecycleexpirationDeletemarkercreated)
      "s3:LifecycleTransition" -> decode.success(EventS3Lifecycletransition)
      "s3:ObjectAcl:Put" -> decode.success(EventS3ObjectaclPut)
      "s3:ObjectCreated:*" -> decode.success(EventS3Objectcreated)
      "s3:ObjectCreated:CompleteMultipartUpload" ->
        decode.success(EventS3ObjectcreatedCompletemultipartupload)
      "s3:ObjectCreated:Copy" -> decode.success(EventS3ObjectcreatedCopy)
      "s3:ObjectCreated:Post" -> decode.success(EventS3ObjectcreatedPost)
      "s3:ObjectCreated:Put" -> decode.success(EventS3ObjectcreatedPut)
      "s3:ObjectRemoved:*" -> decode.success(EventS3Objectremoved)
      "s3:ObjectRemoved:Delete" -> decode.success(EventS3ObjectremovedDelete)
      "s3:ObjectRemoved:DeleteMarkerCreated" ->
        decode.success(EventS3ObjectremovedDeletemarkercreated)
      "s3:ObjectRestore:*" -> decode.success(EventS3Objectrestore)
      "s3:ObjectRestore:Completed" ->
        decode.success(EventS3ObjectrestoreCompleted)
      "s3:ObjectRestore:Delete" -> decode.success(EventS3ObjectrestoreDelete)
      "s3:ObjectRestore:Post" -> decode.success(EventS3ObjectrestorePost)
      "s3:ObjectTagging:*" -> decode.success(EventS3Objecttagging)
      "s3:ObjectTagging:Delete" -> decode.success(EventS3ObjecttaggingDelete)
      "s3:ObjectTagging:Put" -> decode.success(EventS3ObjecttaggingPut)
      "s3:ReducedRedundancyLostObject" ->
        decode.success(EventS3Reducedredundancylostobject)
      "s3:Replication:*" -> decode.success(EventS3Replication)
      "s3:Replication:OperationFailedReplication" ->
        decode.success(EventS3ReplicationOperationfailedreplication)
      "s3:Replication:OperationMissedThreshold" ->
        decode.success(EventS3ReplicationOperationmissedthreshold)
      "s3:Replication:OperationNotTracked" ->
        decode.success(EventS3ReplicationOperationnottracked)
      "s3:Replication:OperationReplicatedAfterThreshold" ->
        decode.success(EventS3ReplicationOperationreplicatedafterthreshold)
      _ -> decode.failure(EventS3Intelligenttiering, "unknown enum value")
    }
  })
}

pub type NotificationConfigurationFilter {
  NotificationConfigurationFilter(key: option.Option(S3KeyFilter))
}

pub fn encode_notification_configuration_filter_struct(
  input: NotificationConfigurationFilter,
) -> json.Json {
  let pairs = []
  let pairs = case input.key {
    option.Some(v) -> [#("Key", encode_s3_key_filter_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_notification_configuration_filter_struct() -> decode.Decoder(
  NotificationConfigurationFilter,
) {
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode_s3_key_filter_struct()),
  )
  decode.success(NotificationConfigurationFilter(key: key))
}

pub type S3KeyFilter {
  S3KeyFilter(filter_rules: option.Option(List(FilterRule)))
}

pub fn encode_s3_key_filter_struct(input: S3KeyFilter) -> json.Json {
  let pairs = []
  let pairs = case input.filter_rules {
    option.Some(v) -> [
      #("FilterRules", fn(xs) { json.array(xs, encode_filter_rule_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_s3_key_filter_struct() -> decode.Decoder(S3KeyFilter) {
  use filter_rules <- decode.optional_field(
    "FilterRules",
    option.None,
    decode.optional(decode.list(decode_filter_rule_struct())),
  )
  decode.success(S3KeyFilter(filter_rules: filter_rules))
}

pub type FilterRule {
  FilterRule(name: option.Option(FilterRuleName), value: option.Option(String))
}

pub fn encode_filter_rule_struct(input: FilterRule) -> json.Json {
  let pairs = []
  let pairs = case input.name {
    option.Some(v) -> [#("Name", encode_filter_rule_name_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.value {
    option.Some(v) -> [#("Value", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_filter_rule_struct() -> decode.Decoder(FilterRule) {
  use name <- decode.optional_field(
    "Name",
    option.None,
    decode.optional(decode_filter_rule_name_enum()),
  )
  use value <- decode.optional_field(
    "Value",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(FilterRule(name: name, value: value))
}

pub type FilterRuleName {
  FilterRuleNamePrefix
  FilterRuleNameSuffix
}

pub fn encode_filter_rule_name_enum(v: FilterRuleName) -> json.Json {
  case v {
    FilterRuleNamePrefix -> json.string("prefix")
    FilterRuleNameSuffix -> json.string("suffix")
  }
}

pub fn decode_filter_rule_name_enum() -> decode.Decoder(FilterRuleName) {
  decode.then(decode.string, fn(s) {
    case s {
      "prefix" -> decode.success(FilterRuleNamePrefix)
      "suffix" -> decode.success(FilterRuleNameSuffix)
      _ -> decode.failure(FilterRuleNamePrefix, "unknown enum value")
    }
  })
}

pub type QueueConfiguration {
  QueueConfiguration(
    events: option.Option(List(Event)),
    filter: option.Option(NotificationConfigurationFilter),
    id: option.Option(String),
    queue_arn: option.Option(String),
  )
}

pub fn encode_queue_configuration_struct(
  input: QueueConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.events {
    option.Some(v) -> [
      #("Events", fn(xs) { json.array(xs, encode_event_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter {
    option.Some(v) -> [
      #("Filter", encode_notification_configuration_filter_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.queue_arn {
    option.Some(v) -> [#("QueueArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_queue_configuration_struct() -> decode.Decoder(QueueConfiguration) {
  use events <- decode.optional_field(
    "Events",
    option.None,
    decode.optional(decode.list(decode_event_enum())),
  )
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_notification_configuration_filter_struct()),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use queue_arn <- decode.optional_field(
    "QueueArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(QueueConfiguration(
    events: events,
    filter: filter,
    id: id,
    queue_arn: queue_arn,
  ))
}

pub type TopicConfiguration {
  TopicConfiguration(
    events: option.Option(List(Event)),
    filter: option.Option(NotificationConfigurationFilter),
    id: option.Option(String),
    topic_arn: option.Option(String),
  )
}

pub fn encode_topic_configuration_struct(
  input: TopicConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.events {
    option.Some(v) -> [
      #("Events", fn(xs) { json.array(xs, encode_event_enum) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter {
    option.Some(v) -> [
      #("Filter", encode_notification_configuration_filter_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.topic_arn {
    option.Some(v) -> [#("TopicArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_topic_configuration_struct() -> decode.Decoder(TopicConfiguration) {
  use events <- decode.optional_field(
    "Events",
    option.None,
    decode.optional(decode.list(decode_event_enum())),
  )
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_notification_configuration_filter_struct()),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use topic_arn <- decode.optional_field(
    "TopicArn",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(TopicConfiguration(
    events: events,
    filter: filter,
    id: id,
    topic_arn: topic_arn,
  ))
}

pub type GetBucketOwnershipControlsRequest {
  GetBucketOwnershipControlsRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_ownership_controls_request_struct(
  input: GetBucketOwnershipControlsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_ownership_controls_request_struct() -> decode.Decoder(
  GetBucketOwnershipControlsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketOwnershipControlsRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketOwnershipControlsOutput {
  GetBucketOwnershipControlsOutput(
    ownership_controls: option.Option(OwnershipControls),
  )
}

pub fn encode_get_bucket_ownership_controls_output_struct(
  input: GetBucketOwnershipControlsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.ownership_controls {
    option.Some(v) -> [
      #("OwnershipControls", encode_ownership_controls_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_ownership_controls_output_struct() -> decode.Decoder(
  GetBucketOwnershipControlsOutput,
) {
  use ownership_controls <- decode.optional_field(
    "OwnershipControls",
    option.None,
    decode.optional(decode_ownership_controls_struct()),
  )
  decode.success(GetBucketOwnershipControlsOutput(
    ownership_controls: ownership_controls,
  ))
}

pub type OwnershipControls {
  OwnershipControls(rules: option.Option(List(OwnershipControlsRule)))
}

pub fn encode_ownership_controls_struct(input: OwnershipControls) -> json.Json {
  let pairs = []
  let pairs = case input.rules {
    option.Some(v) -> [
      #(
        "Rules",
        fn(xs) { json.array(xs, encode_ownership_controls_rule_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_ownership_controls_struct() -> decode.Decoder(OwnershipControls) {
  use rules <- decode.optional_field(
    "Rules",
    option.None,
    decode.optional(decode.list(decode_ownership_controls_rule_struct())),
  )
  decode.success(OwnershipControls(rules: rules))
}

pub type OwnershipControlsRule {
  OwnershipControlsRule(object_ownership: option.Option(ObjectOwnership))
}

pub fn encode_ownership_controls_rule_struct(
  input: OwnershipControlsRule,
) -> json.Json {
  let pairs = []
  let pairs = case input.object_ownership {
    option.Some(v) -> [
      #("ObjectOwnership", encode_object_ownership_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_ownership_controls_rule_struct() -> decode.Decoder(
  OwnershipControlsRule,
) {
  use object_ownership <- decode.optional_field(
    "ObjectOwnership",
    option.None,
    decode.optional(decode_object_ownership_enum()),
  )
  decode.success(OwnershipControlsRule(object_ownership: object_ownership))
}

pub type GetBucketPolicyRequest {
  GetBucketPolicyRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_policy_request_struct(
  input: GetBucketPolicyRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_policy_request_struct() -> decode.Decoder(
  GetBucketPolicyRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketPolicyRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketPolicyOutput {
  GetBucketPolicyOutput(policy: option.Option(String))
}

pub fn encode_get_bucket_policy_output_struct(
  input: GetBucketPolicyOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.policy {
    option.Some(v) -> [#("Policy", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_policy_output_struct() -> decode.Decoder(
  GetBucketPolicyOutput,
) {
  use policy <- decode.optional_field(
    "Policy",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketPolicyOutput(policy: policy))
}

pub type GetBucketPolicyStatusRequest {
  GetBucketPolicyStatusRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_policy_status_request_struct(
  input: GetBucketPolicyStatusRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_policy_status_request_struct() -> decode.Decoder(
  GetBucketPolicyStatusRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketPolicyStatusRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketPolicyStatusOutput {
  GetBucketPolicyStatusOutput(policy_status: option.Option(PolicyStatus))
}

pub fn encode_get_bucket_policy_status_output_struct(
  input: GetBucketPolicyStatusOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.policy_status {
    option.Some(v) -> [
      #("PolicyStatus", encode_policy_status_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_policy_status_output_struct() -> decode.Decoder(
  GetBucketPolicyStatusOutput,
) {
  use policy_status <- decode.optional_field(
    "PolicyStatus",
    option.None,
    decode.optional(decode_policy_status_struct()),
  )
  decode.success(GetBucketPolicyStatusOutput(policy_status: policy_status))
}

pub type PolicyStatus {
  PolicyStatus(is_public: option.Option(Bool))
}

pub fn encode_policy_status_struct(input: PolicyStatus) -> json.Json {
  let pairs = []
  let pairs = case input.is_public {
    option.Some(v) -> [#("IsPublic", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_policy_status_struct() -> decode.Decoder(PolicyStatus) {
  use is_public <- decode.optional_field(
    "IsPublic",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(PolicyStatus(is_public: is_public))
}

pub type GetBucketReplicationRequest {
  GetBucketReplicationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_replication_request_struct(
  input: GetBucketReplicationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_replication_request_struct() -> decode.Decoder(
  GetBucketReplicationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketReplicationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketReplicationOutput {
  GetBucketReplicationOutput(
    replication_configuration: option.Option(ReplicationConfiguration),
  )
}

pub fn encode_get_bucket_replication_output_struct(
  input: GetBucketReplicationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.replication_configuration {
    option.Some(v) -> [
      #("ReplicationConfiguration", encode_replication_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_replication_output_struct() -> decode.Decoder(
  GetBucketReplicationOutput,
) {
  use replication_configuration <- decode.optional_field(
    "ReplicationConfiguration",
    option.None,
    decode.optional(decode_replication_configuration_struct()),
  )
  decode.success(GetBucketReplicationOutput(
    replication_configuration: replication_configuration,
  ))
}

pub type ReplicationConfiguration {
  ReplicationConfiguration(
    role: option.Option(String),
    rules: option.Option(List(ReplicationRule)),
  )
}

pub fn encode_replication_configuration_struct(
  input: ReplicationConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.role {
    option.Some(v) -> [#("Role", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.rules {
    option.Some(v) -> [
      #("Rules", fn(xs) { json.array(xs, encode_replication_rule_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replication_configuration_struct() -> decode.Decoder(
  ReplicationConfiguration,
) {
  use role <- decode.optional_field(
    "Role",
    option.None,
    decode.optional(decode.string),
  )
  use rules <- decode.optional_field(
    "Rules",
    option.None,
    decode.optional(decode.list(decode_replication_rule_struct())),
  )
  decode.success(ReplicationConfiguration(role: role, rules: rules))
}

pub type ReplicationRule {
  ReplicationRule(
    delete_marker_replication: option.Option(DeleteMarkerReplication),
    destination: option.Option(Destination),
    existing_object_replication: option.Option(ExistingObjectReplication),
    filter: option.Option(ReplicationRuleFilter),
    id: option.Option(String),
    prefix: option.Option(String),
    priority: option.Option(Int),
    source_selection_criteria: option.Option(SourceSelectionCriteria),
    status: option.Option(ReplicationRuleStatus),
  )
}

pub fn encode_replication_rule_struct(input: ReplicationRule) -> json.Json {
  let pairs = []
  let pairs = case input.delete_marker_replication {
    option.Some(v) -> [
      #("DeleteMarkerReplication", encode_delete_marker_replication_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.destination {
    option.Some(v) -> [#("Destination", encode_destination_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.existing_object_replication {
    option.Some(v) -> [
      #(
        "ExistingObjectReplication",
        encode_existing_object_replication_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.filter {
    option.Some(v) -> [
      #("Filter", encode_replication_rule_filter_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("ID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.priority {
    option.Some(v) -> [#("Priority", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_selection_criteria {
    option.Some(v) -> [
      #("SourceSelectionCriteria", encode_source_selection_criteria_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_replication_rule_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replication_rule_struct() -> decode.Decoder(ReplicationRule) {
  use delete_marker_replication <- decode.optional_field(
    "DeleteMarkerReplication",
    option.None,
    decode.optional(decode_delete_marker_replication_struct()),
  )
  use destination <- decode.optional_field(
    "Destination",
    option.None,
    decode.optional(decode_destination_struct()),
  )
  use existing_object_replication <- decode.optional_field(
    "ExistingObjectReplication",
    option.None,
    decode.optional(decode_existing_object_replication_struct()),
  )
  use filter <- decode.optional_field(
    "Filter",
    option.None,
    decode.optional(decode_replication_rule_filter_struct()),
  )
  use id <- decode.optional_field(
    "ID",
    option.None,
    decode.optional(decode.string),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use priority <- decode.optional_field(
    "Priority",
    option.None,
    decode.optional(decode.int),
  )
  use source_selection_criteria <- decode.optional_field(
    "SourceSelectionCriteria",
    option.None,
    decode.optional(decode_source_selection_criteria_struct()),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_replication_rule_status_enum()),
  )
  decode.success(ReplicationRule(
    delete_marker_replication: delete_marker_replication,
    destination: destination,
    existing_object_replication: existing_object_replication,
    filter: filter,
    id: id,
    prefix: prefix,
    priority: priority,
    source_selection_criteria: source_selection_criteria,
    status: status,
  ))
}

pub type DeleteMarkerReplication {
  DeleteMarkerReplication(status: option.Option(DeleteMarkerReplicationStatus))
}

pub fn encode_delete_marker_replication_struct(
  input: DeleteMarkerReplication,
) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_delete_marker_replication_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_marker_replication_struct() -> decode.Decoder(
  DeleteMarkerReplication,
) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_delete_marker_replication_status_enum()),
  )
  decode.success(DeleteMarkerReplication(status: status))
}

pub type DeleteMarkerReplicationStatus {
  DeleteMarkerReplicationStatusDisabled
  DeleteMarkerReplicationStatusEnabled
}

pub fn encode_delete_marker_replication_status_enum(
  v: DeleteMarkerReplicationStatus,
) -> json.Json {
  case v {
    DeleteMarkerReplicationStatusDisabled -> json.string("Disabled")
    DeleteMarkerReplicationStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_delete_marker_replication_status_enum() -> decode.Decoder(
  DeleteMarkerReplicationStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(DeleteMarkerReplicationStatusDisabled)
      "Enabled" -> decode.success(DeleteMarkerReplicationStatusEnabled)
      _ ->
        decode.failure(
          DeleteMarkerReplicationStatusDisabled,
          "unknown enum value",
        )
    }
  })
}

pub type Destination {
  Destination(
    access_control_translation: option.Option(AccessControlTranslation),
    account: option.Option(String),
    bucket: option.Option(String),
    encryption_configuration: option.Option(EncryptionConfiguration),
    metrics: option.Option(Metrics),
    replication_time: option.Option(ReplicationTime),
    storage_class: option.Option(StorageClass),
  )
}

pub fn encode_destination_struct(input: Destination) -> json.Json {
  let pairs = []
  let pairs = case input.access_control_translation {
    option.Some(v) -> [
      #("AccessControlTranslation", encode_access_control_translation_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.account {
    option.Some(v) -> [#("Account", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encryption_configuration {
    option.Some(v) -> [
      #("EncryptionConfiguration", encode_encryption_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.metrics {
    option.Some(v) -> [#("Metrics", encode_metrics_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replication_time {
    option.Some(v) -> [
      #("ReplicationTime", encode_replication_time_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_destination_struct() -> decode.Decoder(Destination) {
  use access_control_translation <- decode.optional_field(
    "AccessControlTranslation",
    option.None,
    decode.optional(decode_access_control_translation_struct()),
  )
  use account <- decode.optional_field(
    "Account",
    option.None,
    decode.optional(decode.string),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use encryption_configuration <- decode.optional_field(
    "EncryptionConfiguration",
    option.None,
    decode.optional(decode_encryption_configuration_struct()),
  )
  use metrics <- decode.optional_field(
    "Metrics",
    option.None,
    decode.optional(decode_metrics_struct()),
  )
  use replication_time <- decode.optional_field(
    "ReplicationTime",
    option.None,
    decode.optional(decode_replication_time_struct()),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  decode.success(Destination(
    access_control_translation: access_control_translation,
    account: account,
    bucket: bucket,
    encryption_configuration: encryption_configuration,
    metrics: metrics,
    replication_time: replication_time,
    storage_class: storage_class,
  ))
}

pub type AccessControlTranslation {
  AccessControlTranslation(owner: option.Option(OwnerOverride))
}

pub fn encode_access_control_translation_struct(
  input: AccessControlTranslation,
) -> json.Json {
  let pairs = []
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_override_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_access_control_translation_struct() -> decode.Decoder(
  AccessControlTranslation,
) {
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_override_enum()),
  )
  decode.success(AccessControlTranslation(owner: owner))
}

pub type OwnerOverride {
  OwnerOverrideDestination
}

pub fn encode_owner_override_enum(v: OwnerOverride) -> json.Json {
  case v {
    OwnerOverrideDestination -> json.string("Destination")
  }
}

pub fn decode_owner_override_enum() -> decode.Decoder(OwnerOverride) {
  decode.then(decode.string, fn(s) {
    case s {
      "Destination" -> decode.success(OwnerOverrideDestination)
      _ -> decode.failure(OwnerOverrideDestination, "unknown enum value")
    }
  })
}

pub type EncryptionConfiguration {
  EncryptionConfiguration(replica_kms_key_id: option.Option(String))
}

pub fn encode_encryption_configuration_struct(
  input: EncryptionConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.replica_kms_key_id {
    option.Some(v) -> [#("ReplicaKmsKeyID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_encryption_configuration_struct() -> decode.Decoder(
  EncryptionConfiguration,
) {
  use replica_kms_key_id <- decode.optional_field(
    "ReplicaKmsKeyID",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(EncryptionConfiguration(replica_kms_key_id: replica_kms_key_id))
}

pub type Metrics {
  Metrics(
    event_threshold: option.Option(ReplicationTimeValue),
    status: option.Option(MetricsStatus),
  )
}

pub fn encode_metrics_struct(input: Metrics) -> json.Json {
  let pairs = []
  let pairs = case input.event_threshold {
    option.Some(v) -> [
      #("EventThreshold", encode_replication_time_value_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [#("Status", encode_metrics_status_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_metrics_struct() -> decode.Decoder(Metrics) {
  use event_threshold <- decode.optional_field(
    "EventThreshold",
    option.None,
    decode.optional(decode_replication_time_value_struct()),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_metrics_status_enum()),
  )
  decode.success(Metrics(event_threshold: event_threshold, status: status))
}

pub type ReplicationTimeValue {
  ReplicationTimeValue(minutes: option.Option(Int))
}

pub fn encode_replication_time_value_struct(
  input: ReplicationTimeValue,
) -> json.Json {
  let pairs = []
  let pairs = case input.minutes {
    option.Some(v) -> [#("Minutes", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replication_time_value_struct() -> decode.Decoder(
  ReplicationTimeValue,
) {
  use minutes <- decode.optional_field(
    "Minutes",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ReplicationTimeValue(minutes: minutes))
}

pub type MetricsStatus {
  MetricsStatusDisabled
  MetricsStatusEnabled
}

pub fn encode_metrics_status_enum(v: MetricsStatus) -> json.Json {
  case v {
    MetricsStatusDisabled -> json.string("Disabled")
    MetricsStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_metrics_status_enum() -> decode.Decoder(MetricsStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(MetricsStatusDisabled)
      "Enabled" -> decode.success(MetricsStatusEnabled)
      _ -> decode.failure(MetricsStatusDisabled, "unknown enum value")
    }
  })
}

pub type ReplicationTime {
  ReplicationTime(
    status: option.Option(ReplicationTimeStatus),
    time: option.Option(ReplicationTimeValue),
  )
}

pub fn encode_replication_time_struct(input: ReplicationTime) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_replication_time_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.time {
    option.Some(v) -> [
      #("Time", encode_replication_time_value_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replication_time_struct() -> decode.Decoder(ReplicationTime) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_replication_time_status_enum()),
  )
  use time <- decode.optional_field(
    "Time",
    option.None,
    decode.optional(decode_replication_time_value_struct()),
  )
  decode.success(ReplicationTime(status: status, time: time))
}

pub type ReplicationTimeStatus {
  ReplicationTimeStatusDisabled
  ReplicationTimeStatusEnabled
}

pub fn encode_replication_time_status_enum(
  v: ReplicationTimeStatus,
) -> json.Json {
  case v {
    ReplicationTimeStatusDisabled -> json.string("Disabled")
    ReplicationTimeStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_replication_time_status_enum() -> decode.Decoder(
  ReplicationTimeStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(ReplicationTimeStatusDisabled)
      "Enabled" -> decode.success(ReplicationTimeStatusEnabled)
      _ -> decode.failure(ReplicationTimeStatusDisabled, "unknown enum value")
    }
  })
}

pub type ExistingObjectReplication {
  ExistingObjectReplication(
    status: option.Option(ExistingObjectReplicationStatus),
  )
}

pub fn encode_existing_object_replication_struct(
  input: ExistingObjectReplication,
) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_existing_object_replication_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_existing_object_replication_struct() -> decode.Decoder(
  ExistingObjectReplication,
) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_existing_object_replication_status_enum()),
  )
  decode.success(ExistingObjectReplication(status: status))
}

pub type ExistingObjectReplicationStatus {
  ExistingObjectReplicationStatusDisabled
  ExistingObjectReplicationStatusEnabled
}

pub fn encode_existing_object_replication_status_enum(
  v: ExistingObjectReplicationStatus,
) -> json.Json {
  case v {
    ExistingObjectReplicationStatusDisabled -> json.string("Disabled")
    ExistingObjectReplicationStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_existing_object_replication_status_enum() -> decode.Decoder(
  ExistingObjectReplicationStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(ExistingObjectReplicationStatusDisabled)
      "Enabled" -> decode.success(ExistingObjectReplicationStatusEnabled)
      _ ->
        decode.failure(
          ExistingObjectReplicationStatusDisabled,
          "unknown enum value",
        )
    }
  })
}

pub type ReplicationRuleFilter {
  ReplicationRuleFilter(
    and: option.Option(ReplicationRuleAndOperator),
    prefix: option.Option(String),
    tag: option.Option(Tag),
  )
}

pub fn encode_replication_rule_filter_struct(
  input: ReplicationRuleFilter,
) -> json.Json {
  let pairs = []
  let pairs = case input.and {
    option.Some(v) -> [
      #("And", encode_replication_rule_and_operator_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tag {
    option.Some(v) -> [#("Tag", encode_tag_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replication_rule_filter_struct() -> decode.Decoder(
  ReplicationRuleFilter,
) {
  use and <- decode.optional_field(
    "And",
    option.None,
    decode.optional(decode_replication_rule_and_operator_struct()),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tag <- decode.optional_field(
    "Tag",
    option.None,
    decode.optional(decode_tag_struct()),
  )
  decode.success(ReplicationRuleFilter(and: and, prefix: prefix, tag: tag))
}

pub type ReplicationRuleAndOperator {
  ReplicationRuleAndOperator(
    prefix: option.Option(String),
    tags: option.Option(List(Tag)),
  )
}

pub fn encode_replication_rule_and_operator_struct(
  input: ReplicationRuleAndOperator,
) -> json.Json {
  let pairs = []
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tags {
    option.Some(v) -> [
      #("Tags", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replication_rule_and_operator_struct() -> decode.Decoder(
  ReplicationRuleAndOperator,
) {
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use tags <- decode.optional_field(
    "Tags",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(ReplicationRuleAndOperator(prefix: prefix, tags: tags))
}

pub type SourceSelectionCriteria {
  SourceSelectionCriteria(
    replica_modifications: option.Option(ReplicaModifications),
    sse_kms_encrypted_objects: option.Option(SseKmsEncryptedObjects),
  )
}

pub fn encode_source_selection_criteria_struct(
  input: SourceSelectionCriteria,
) -> json.Json {
  let pairs = []
  let pairs = case input.replica_modifications {
    option.Some(v) -> [
      #("ReplicaModifications", encode_replica_modifications_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_kms_encrypted_objects {
    option.Some(v) -> [
      #("SseKmsEncryptedObjects", encode_sse_kms_encrypted_objects_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_source_selection_criteria_struct() -> decode.Decoder(
  SourceSelectionCriteria,
) {
  use replica_modifications <- decode.optional_field(
    "ReplicaModifications",
    option.None,
    decode.optional(decode_replica_modifications_struct()),
  )
  use sse_kms_encrypted_objects <- decode.optional_field(
    "SseKmsEncryptedObjects",
    option.None,
    decode.optional(decode_sse_kms_encrypted_objects_struct()),
  )
  decode.success(SourceSelectionCriteria(
    replica_modifications: replica_modifications,
    sse_kms_encrypted_objects: sse_kms_encrypted_objects,
  ))
}

pub type ReplicaModifications {
  ReplicaModifications(status: option.Option(ReplicaModificationsStatus))
}

pub fn encode_replica_modifications_struct(
  input: ReplicaModifications,
) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_replica_modifications_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_replica_modifications_struct() -> decode.Decoder(
  ReplicaModifications,
) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_replica_modifications_status_enum()),
  )
  decode.success(ReplicaModifications(status: status))
}

pub type ReplicaModificationsStatus {
  ReplicaModificationsStatusDisabled
  ReplicaModificationsStatusEnabled
}

pub fn encode_replica_modifications_status_enum(
  v: ReplicaModificationsStatus,
) -> json.Json {
  case v {
    ReplicaModificationsStatusDisabled -> json.string("Disabled")
    ReplicaModificationsStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_replica_modifications_status_enum() -> decode.Decoder(
  ReplicaModificationsStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(ReplicaModificationsStatusDisabled)
      "Enabled" -> decode.success(ReplicaModificationsStatusEnabled)
      _ ->
        decode.failure(ReplicaModificationsStatusDisabled, "unknown enum value")
    }
  })
}

pub type SseKmsEncryptedObjects {
  SseKmsEncryptedObjects(status: option.Option(SseKmsEncryptedObjectsStatus))
}

pub fn encode_sse_kms_encrypted_objects_struct(
  input: SseKmsEncryptedObjects,
) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_sse_kms_encrypted_objects_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_sse_kms_encrypted_objects_struct() -> decode.Decoder(
  SseKmsEncryptedObjects,
) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_sse_kms_encrypted_objects_status_enum()),
  )
  decode.success(SseKmsEncryptedObjects(status: status))
}

pub type SseKmsEncryptedObjectsStatus {
  SseKmsEncryptedObjectsStatusDisabled
  SseKmsEncryptedObjectsStatusEnabled
}

pub fn encode_sse_kms_encrypted_objects_status_enum(
  v: SseKmsEncryptedObjectsStatus,
) -> json.Json {
  case v {
    SseKmsEncryptedObjectsStatusDisabled -> json.string("Disabled")
    SseKmsEncryptedObjectsStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_sse_kms_encrypted_objects_status_enum() -> decode.Decoder(
  SseKmsEncryptedObjectsStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(SseKmsEncryptedObjectsStatusDisabled)
      "Enabled" -> decode.success(SseKmsEncryptedObjectsStatusEnabled)
      _ ->
        decode.failure(
          SseKmsEncryptedObjectsStatusDisabled,
          "unknown enum value",
        )
    }
  })
}

pub type ReplicationRuleStatus {
  ReplicationRuleStatusDisabled
  ReplicationRuleStatusEnabled
}

pub fn encode_replication_rule_status_enum(
  v: ReplicationRuleStatus,
) -> json.Json {
  case v {
    ReplicationRuleStatusDisabled -> json.string("Disabled")
    ReplicationRuleStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_replication_rule_status_enum() -> decode.Decoder(
  ReplicationRuleStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(ReplicationRuleStatusDisabled)
      "Enabled" -> decode.success(ReplicationRuleStatusEnabled)
      _ -> decode.failure(ReplicationRuleStatusDisabled, "unknown enum value")
    }
  })
}

pub type GetBucketRequestPaymentRequest {
  GetBucketRequestPaymentRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_request_payment_request_struct(
  input: GetBucketRequestPaymentRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_request_payment_request_struct() -> decode.Decoder(
  GetBucketRequestPaymentRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketRequestPaymentRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketRequestPaymentOutput {
  GetBucketRequestPaymentOutput(payer: option.Option(Payer))
}

pub fn encode_get_bucket_request_payment_output_struct(
  input: GetBucketRequestPaymentOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payer {
    option.Some(v) -> [#("Payer", encode_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_request_payment_output_struct() -> decode.Decoder(
  GetBucketRequestPaymentOutput,
) {
  use payer <- decode.optional_field(
    "Payer",
    option.None,
    decode.optional(decode_payer_enum()),
  )
  decode.success(GetBucketRequestPaymentOutput(payer: payer))
}

pub type Payer {
  PayerBucketowner
  PayerRequester
}

pub fn encode_payer_enum(v: Payer) -> json.Json {
  case v {
    PayerBucketowner -> json.string("BucketOwner")
    PayerRequester -> json.string("Requester")
  }
}

pub fn decode_payer_enum() -> decode.Decoder(Payer) {
  decode.then(decode.string, fn(s) {
    case s {
      "BucketOwner" -> decode.success(PayerBucketowner)
      "Requester" -> decode.success(PayerRequester)
      _ -> decode.failure(PayerBucketowner, "unknown enum value")
    }
  })
}

pub type GetBucketTaggingRequest {
  GetBucketTaggingRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_tagging_request_struct(
  input: GetBucketTaggingRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_tagging_request_struct() -> decode.Decoder(
  GetBucketTaggingRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketTaggingRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketTaggingOutput {
  GetBucketTaggingOutput(tag_set: option.Option(List(Tag)))
}

pub fn encode_get_bucket_tagging_output_struct(
  input: GetBucketTaggingOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.tag_set {
    option.Some(v) -> [
      #("TagSet", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_tagging_output_struct() -> decode.Decoder(
  GetBucketTaggingOutput,
) {
  use tag_set <- decode.optional_field(
    "TagSet",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  decode.success(GetBucketTaggingOutput(tag_set: tag_set))
}

pub type GetBucketVersioningRequest {
  GetBucketVersioningRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_versioning_request_struct(
  input: GetBucketVersioningRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_versioning_request_struct() -> decode.Decoder(
  GetBucketVersioningRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketVersioningRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketVersioningOutput {
  GetBucketVersioningOutput(
    mfa_delete: option.Option(MFADeleteStatus),
    status: option.Option(BucketVersioningStatus),
  )
}

pub fn encode_get_bucket_versioning_output_struct(
  input: GetBucketVersioningOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.mfa_delete {
    option.Some(v) -> [
      #("MFADelete", encode_mfa_delete_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_bucket_versioning_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_versioning_output_struct() -> decode.Decoder(
  GetBucketVersioningOutput,
) {
  use mfa_delete <- decode.optional_field(
    "MFADelete",
    option.None,
    decode.optional(decode_mfa_delete_status_enum()),
  )
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_bucket_versioning_status_enum()),
  )
  decode.success(GetBucketVersioningOutput(
    mfa_delete: mfa_delete,
    status: status,
  ))
}

pub type MFADeleteStatus {
  MFADeleteStatusDisabled
  MFADeleteStatusEnabled
}

pub fn encode_mfa_delete_status_enum(v: MFADeleteStatus) -> json.Json {
  case v {
    MFADeleteStatusDisabled -> json.string("Disabled")
    MFADeleteStatusEnabled -> json.string("Enabled")
  }
}

pub fn decode_mfa_delete_status_enum() -> decode.Decoder(MFADeleteStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "Disabled" -> decode.success(MFADeleteStatusDisabled)
      "Enabled" -> decode.success(MFADeleteStatusEnabled)
      _ -> decode.failure(MFADeleteStatusDisabled, "unknown enum value")
    }
  })
}

pub type BucketVersioningStatus {
  BucketVersioningStatusEnabled
  BucketVersioningStatusSuspended
}

pub fn encode_bucket_versioning_status_enum(
  v: BucketVersioningStatus,
) -> json.Json {
  case v {
    BucketVersioningStatusEnabled -> json.string("Enabled")
    BucketVersioningStatusSuspended -> json.string("Suspended")
  }
}

pub fn decode_bucket_versioning_status_enum() -> decode.Decoder(
  BucketVersioningStatus,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "Enabled" -> decode.success(BucketVersioningStatusEnabled)
      "Suspended" -> decode.success(BucketVersioningStatusSuspended)
      _ -> decode.failure(BucketVersioningStatusEnabled, "unknown enum value")
    }
  })
}

pub type GetBucketWebsiteRequest {
  GetBucketWebsiteRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_bucket_website_request_struct(
  input: GetBucketWebsiteRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_website_request_struct() -> decode.Decoder(
  GetBucketWebsiteRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetBucketWebsiteRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetBucketWebsiteOutput {
  GetBucketWebsiteOutput(
    error_document: option.Option(ErrorDocument),
    index_document: option.Option(IndexDocument),
    redirect_all_requests_to: option.Option(RedirectAllRequestsTo),
    routing_rules: option.Option(List(RoutingRule)),
  )
}

pub fn encode_get_bucket_website_output_struct(
  input: GetBucketWebsiteOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.error_document {
    option.Some(v) -> [
      #("ErrorDocument", encode_error_document_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.index_document {
    option.Some(v) -> [
      #("IndexDocument", encode_index_document_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.redirect_all_requests_to {
    option.Some(v) -> [
      #("RedirectAllRequestsTo", encode_redirect_all_requests_to_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.routing_rules {
    option.Some(v) -> [
      #(
        "RoutingRules",
        fn(xs) { json.array(xs, encode_routing_rule_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_bucket_website_output_struct() -> decode.Decoder(
  GetBucketWebsiteOutput,
) {
  use error_document <- decode.optional_field(
    "ErrorDocument",
    option.None,
    decode.optional(decode_error_document_struct()),
  )
  use index_document <- decode.optional_field(
    "IndexDocument",
    option.None,
    decode.optional(decode_index_document_struct()),
  )
  use redirect_all_requests_to <- decode.optional_field(
    "RedirectAllRequestsTo",
    option.None,
    decode.optional(decode_redirect_all_requests_to_struct()),
  )
  use routing_rules <- decode.optional_field(
    "RoutingRules",
    option.None,
    decode.optional(decode.list(decode_routing_rule_struct())),
  )
  decode.success(GetBucketWebsiteOutput(
    error_document: error_document,
    index_document: index_document,
    redirect_all_requests_to: redirect_all_requests_to,
    routing_rules: routing_rules,
  ))
}

pub type ErrorDocument {
  ErrorDocument(key: option.Option(String))
}

pub fn encode_error_document_struct(input: ErrorDocument) -> json.Json {
  let pairs = []
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_error_document_struct() -> decode.Decoder(ErrorDocument) {
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ErrorDocument(key: key))
}

pub type IndexDocument {
  IndexDocument(suffix: option.Option(String))
}

pub fn encode_index_document_struct(input: IndexDocument) -> json.Json {
  let pairs = []
  let pairs = case input.suffix {
    option.Some(v) -> [#("Suffix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_index_document_struct() -> decode.Decoder(IndexDocument) {
  use suffix <- decode.optional_field(
    "Suffix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(IndexDocument(suffix: suffix))
}

pub type RedirectAllRequestsTo {
  RedirectAllRequestsTo(
    host_name: option.Option(String),
    protocol: option.Option(Protocol),
  )
}

pub fn encode_redirect_all_requests_to_struct(
  input: RedirectAllRequestsTo,
) -> json.Json {
  let pairs = []
  let pairs = case input.host_name {
    option.Some(v) -> [#("HostName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.protocol {
    option.Some(v) -> [#("Protocol", encode_protocol_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_redirect_all_requests_to_struct() -> decode.Decoder(
  RedirectAllRequestsTo,
) {
  use host_name <- decode.optional_field(
    "HostName",
    option.None,
    decode.optional(decode.string),
  )
  use protocol <- decode.optional_field(
    "Protocol",
    option.None,
    decode.optional(decode_protocol_enum()),
  )
  decode.success(RedirectAllRequestsTo(host_name: host_name, protocol: protocol))
}

pub type Protocol {
  ProtocolHttp
  ProtocolHttps
}

pub fn encode_protocol_enum(v: Protocol) -> json.Json {
  case v {
    ProtocolHttp -> json.string("http")
    ProtocolHttps -> json.string("https")
  }
}

pub fn decode_protocol_enum() -> decode.Decoder(Protocol) {
  decode.then(decode.string, fn(s) {
    case s {
      "http" -> decode.success(ProtocolHttp)
      "https" -> decode.success(ProtocolHttps)
      _ -> decode.failure(ProtocolHttp, "unknown enum value")
    }
  })
}

pub type RoutingRule {
  RoutingRule(
    condition: option.Option(Condition),
    redirect: option.Option(Redirect),
  )
}

pub fn encode_routing_rule_struct(input: RoutingRule) -> json.Json {
  let pairs = []
  let pairs = case input.condition {
    option.Some(v) -> [#("Condition", encode_condition_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.redirect {
    option.Some(v) -> [#("Redirect", encode_redirect_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_routing_rule_struct() -> decode.Decoder(RoutingRule) {
  use condition <- decode.optional_field(
    "Condition",
    option.None,
    decode.optional(decode_condition_struct()),
  )
  use redirect <- decode.optional_field(
    "Redirect",
    option.None,
    decode.optional(decode_redirect_struct()),
  )
  decode.success(RoutingRule(condition: condition, redirect: redirect))
}

pub type Condition {
  Condition(
    http_error_code_returned_equals: option.Option(String),
    key_prefix_equals: option.Option(String),
  )
}

pub fn encode_condition_struct(input: Condition) -> json.Json {
  let pairs = []
  let pairs = case input.http_error_code_returned_equals {
    option.Some(v) -> [
      #("HttpErrorCodeReturnedEquals", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key_prefix_equals {
    option.Some(v) -> [#("KeyPrefixEquals", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_condition_struct() -> decode.Decoder(Condition) {
  use http_error_code_returned_equals <- decode.optional_field(
    "HttpErrorCodeReturnedEquals",
    option.None,
    decode.optional(decode.string),
  )
  use key_prefix_equals <- decode.optional_field(
    "KeyPrefixEquals",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Condition(
    http_error_code_returned_equals: http_error_code_returned_equals,
    key_prefix_equals: key_prefix_equals,
  ))
}

pub type Redirect {
  Redirect(
    host_name: option.Option(String),
    http_redirect_code: option.Option(String),
    protocol: option.Option(Protocol),
    replace_key_prefix_with: option.Option(String),
    replace_key_with: option.Option(String),
  )
}

pub fn encode_redirect_struct(input: Redirect) -> json.Json {
  let pairs = []
  let pairs = case input.host_name {
    option.Some(v) -> [#("HostName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.http_redirect_code {
    option.Some(v) -> [#("HttpRedirectCode", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.protocol {
    option.Some(v) -> [#("Protocol", encode_protocol_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replace_key_prefix_with {
    option.Some(v) -> [#("ReplaceKeyPrefixWith", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replace_key_with {
    option.Some(v) -> [#("ReplaceKeyWith", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_redirect_struct() -> decode.Decoder(Redirect) {
  use host_name <- decode.optional_field(
    "HostName",
    option.None,
    decode.optional(decode.string),
  )
  use http_redirect_code <- decode.optional_field(
    "HttpRedirectCode",
    option.None,
    decode.optional(decode.string),
  )
  use protocol <- decode.optional_field(
    "Protocol",
    option.None,
    decode.optional(decode_protocol_enum()),
  )
  use replace_key_prefix_with <- decode.optional_field(
    "ReplaceKeyPrefixWith",
    option.None,
    decode.optional(decode.string),
  )
  use replace_key_with <- decode.optional_field(
    "ReplaceKeyWith",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Redirect(
    host_name: host_name,
    http_redirect_code: http_redirect_code,
    protocol: protocol,
    replace_key_prefix_with: replace_key_prefix_with,
    replace_key_with: replace_key_with,
  ))
}

pub type GetObjectAclRequest {
  GetObjectAclRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    request_payer: option.Option(RequestPayer),
    version_id: option.Option(String),
  )
}

pub fn encode_get_object_acl_request_struct(
  input: GetObjectAclRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_acl_request_struct() -> decode.Decoder(
  GetObjectAclRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectAclRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    request_payer: request_payer,
    version_id: version_id,
  ))
}

pub type GetObjectAclOutput {
  GetObjectAclOutput(
    grants: option.Option(List(Grant)),
    owner: option.Option(Owner),
    request_charged: option.Option(RequestCharged),
  )
}

pub fn encode_get_object_acl_output_struct(
  input: GetObjectAclOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.grants {
    option.Some(v) -> [
      #("Grants", fn(xs) { json.array(xs, encode_grant_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_acl_output_struct() -> decode.Decoder(
  GetObjectAclOutput,
) {
  use grants <- decode.optional_field(
    "Grants",
    option.None,
    decode.optional(decode.list(decode_grant_struct())),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  decode.success(GetObjectAclOutput(
    grants: grants,
    owner: owner,
    request_charged: request_charged,
  ))
}

pub type GetObjectAttributesRequest {
  GetObjectAttributesRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    max_parts: option.Option(Int),
    object_attributes: option.Option(List(ObjectAttributes)),
    part_number_marker: option.Option(String),
    request_payer: option.Option(RequestPayer),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    version_id: option.Option(String),
  )
}

pub fn encode_get_object_attributes_request_struct(
  input: GetObjectAttributesRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_parts {
    option.Some(v) -> [#("MaxParts", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_attributes {
    option.Some(v) -> [
      #(
        "ObjectAttributes",
        fn(xs) { json.array(xs, encode_object_attributes_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.part_number_marker {
    option.Some(v) -> [#("PartNumberMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_attributes_request_struct() -> decode.Decoder(
  GetObjectAttributesRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use max_parts <- decode.optional_field(
    "MaxParts",
    option.None,
    decode.optional(decode.int),
  )
  use object_attributes <- decode.optional_field(
    "ObjectAttributes",
    option.None,
    decode.optional(decode.list(decode_object_attributes_enum())),
  )
  use part_number_marker <- decode.optional_field(
    "PartNumberMarker",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectAttributesRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    max_parts: max_parts,
    object_attributes: object_attributes,
    part_number_marker: part_number_marker,
    request_payer: request_payer,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    version_id: version_id,
  ))
}

pub type ObjectAttributes {
  ObjectAttributesChecksum
  ObjectAttributesEtag
  ObjectAttributesObjectParts
  ObjectAttributesObjectSize
  ObjectAttributesStorageClass
}

pub fn encode_object_attributes_enum(v: ObjectAttributes) -> json.Json {
  case v {
    ObjectAttributesChecksum -> json.string("Checksum")
    ObjectAttributesEtag -> json.string("ETag")
    ObjectAttributesObjectParts -> json.string("ObjectParts")
    ObjectAttributesObjectSize -> json.string("ObjectSize")
    ObjectAttributesStorageClass -> json.string("StorageClass")
  }
}

pub fn decode_object_attributes_enum() -> decode.Decoder(ObjectAttributes) {
  decode.then(decode.string, fn(s) {
    case s {
      "Checksum" -> decode.success(ObjectAttributesChecksum)
      "ETag" -> decode.success(ObjectAttributesEtag)
      "ObjectParts" -> decode.success(ObjectAttributesObjectParts)
      "ObjectSize" -> decode.success(ObjectAttributesObjectSize)
      "StorageClass" -> decode.success(ObjectAttributesStorageClass)
      _ -> decode.failure(ObjectAttributesChecksum, "unknown enum value")
    }
  })
}

pub type GetObjectAttributesOutput {
  GetObjectAttributesOutput(
    checksum: option.Option(Checksum),
    delete_marker: option.Option(Bool),
    e_tag: option.Option(String),
    last_modified: option.Option(Int),
    object_parts: option.Option(GetObjectAttributesParts),
    object_size: option.Option(Int),
    request_charged: option.Option(RequestCharged),
    storage_class: option.Option(StorageClass),
    version_id: option.Option(String),
  )
}

pub fn encode_get_object_attributes_output_struct(
  input: GetObjectAttributesOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.checksum {
    option.Some(v) -> [#("Checksum", encode_checksum_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delete_marker {
    option.Some(v) -> [#("DeleteMarker", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_parts {
    option.Some(v) -> [
      #("ObjectParts", encode_get_object_attributes_parts_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_size {
    option.Some(v) -> [#("ObjectSize", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_attributes_output_struct() -> decode.Decoder(
  GetObjectAttributesOutput,
) {
  use checksum <- decode.optional_field(
    "Checksum",
    option.None,
    decode.optional(decode_checksum_struct()),
  )
  use delete_marker <- decode.optional_field(
    "DeleteMarker",
    option.None,
    decode.optional(decode.bool),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  use object_parts <- decode.optional_field(
    "ObjectParts",
    option.None,
    decode.optional(decode_get_object_attributes_parts_struct()),
  )
  use object_size <- decode.optional_field(
    "ObjectSize",
    option.None,
    decode.optional(decode.int),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectAttributesOutput(
    checksum: checksum,
    delete_marker: delete_marker,
    e_tag: e_tag,
    last_modified: last_modified,
    object_parts: object_parts,
    object_size: object_size,
    request_charged: request_charged,
    storage_class: storage_class,
    version_id: version_id,
  ))
}

pub type Checksum {
  Checksum(
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_type: option.Option(ChecksumType),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
  )
}

pub fn encode_checksum_struct(input: Checksum) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_checksum_struct() -> decode.Decoder(Checksum) {
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Checksum(
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_type: checksum_type,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
  ))
}

pub type GetObjectAttributesParts {
  GetObjectAttributesParts(
    is_truncated: option.Option(Bool),
    max_parts: option.Option(Int),
    next_part_number_marker: option.Option(String),
    part_number_marker: option.Option(String),
    parts: option.Option(List(ObjectPart)),
    total_parts_count: option.Option(Int),
  )
}

pub fn encode_get_object_attributes_parts_struct(
  input: GetObjectAttributesParts,
) -> json.Json {
  let pairs = []
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_parts {
    option.Some(v) -> [#("MaxParts", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_part_number_marker {
    option.Some(v) -> [#("NextPartNumberMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number_marker {
    option.Some(v) -> [#("PartNumberMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.parts {
    option.Some(v) -> [
      #("Parts", fn(xs) { json.array(xs, encode_object_part_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.total_parts_count {
    option.Some(v) -> [#("TotalPartsCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_attributes_parts_struct() -> decode.Decoder(
  GetObjectAttributesParts,
) {
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use max_parts <- decode.optional_field(
    "MaxParts",
    option.None,
    decode.optional(decode.int),
  )
  use next_part_number_marker <- decode.optional_field(
    "NextPartNumberMarker",
    option.None,
    decode.optional(decode.string),
  )
  use part_number_marker <- decode.optional_field(
    "PartNumberMarker",
    option.None,
    decode.optional(decode.string),
  )
  use parts <- decode.optional_field(
    "Parts",
    option.None,
    decode.optional(decode.list(decode_object_part_struct())),
  )
  use total_parts_count <- decode.optional_field(
    "TotalPartsCount",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(GetObjectAttributesParts(
    is_truncated: is_truncated,
    max_parts: max_parts,
    next_part_number_marker: next_part_number_marker,
    part_number_marker: part_number_marker,
    parts: parts,
    total_parts_count: total_parts_count,
  ))
}

pub type ObjectPart {
  ObjectPart(
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    part_number: option.Option(Int),
    size: option.Option(Int),
  )
}

pub fn encode_object_part_struct(input: ObjectPart) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number {
    option.Some(v) -> [#("PartNumber", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.size {
    option.Some(v) -> [#("Size", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_object_part_struct() -> decode.Decoder(ObjectPart) {
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use part_number <- decode.optional_field(
    "PartNumber",
    option.None,
    decode.optional(decode.int),
  )
  use size <- decode.optional_field(
    "Size",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ObjectPart(
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    part_number: part_number,
    size: size,
  ))
}

pub type GetObjectLegalHoldRequest {
  GetObjectLegalHoldRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    request_payer: option.Option(RequestPayer),
    version_id: option.Option(String),
  )
}

pub fn encode_get_object_legal_hold_request_struct(
  input: GetObjectLegalHoldRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_legal_hold_request_struct() -> decode.Decoder(
  GetObjectLegalHoldRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectLegalHoldRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    request_payer: request_payer,
    version_id: version_id,
  ))
}

pub type GetObjectLegalHoldOutput {
  GetObjectLegalHoldOutput(legal_hold: option.Option(ObjectLockLegalHold))
}

pub fn encode_get_object_legal_hold_output_struct(
  input: GetObjectLegalHoldOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.legal_hold {
    option.Some(v) -> [
      #("LegalHold", encode_object_lock_legal_hold_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_legal_hold_output_struct() -> decode.Decoder(
  GetObjectLegalHoldOutput,
) {
  use legal_hold <- decode.optional_field(
    "LegalHold",
    option.None,
    decode.optional(decode_object_lock_legal_hold_struct()),
  )
  decode.success(GetObjectLegalHoldOutput(legal_hold: legal_hold))
}

pub type ObjectLockLegalHold {
  ObjectLockLegalHold(status: option.Option(ObjectLockLegalHoldStatus))
}

pub fn encode_object_lock_legal_hold_struct(
  input: ObjectLockLegalHold,
) -> json.Json {
  let pairs = []
  let pairs = case input.status {
    option.Some(v) -> [
      #("Status", encode_object_lock_legal_hold_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_object_lock_legal_hold_struct() -> decode.Decoder(
  ObjectLockLegalHold,
) {
  use status <- decode.optional_field(
    "Status",
    option.None,
    decode.optional(decode_object_lock_legal_hold_status_enum()),
  )
  decode.success(ObjectLockLegalHold(status: status))
}

pub type GetObjectLockConfigurationRequest {
  GetObjectLockConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_object_lock_configuration_request_struct(
  input: GetObjectLockConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_lock_configuration_request_struct() -> decode.Decoder(
  GetObjectLockConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectLockConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetObjectLockConfigurationOutput {
  GetObjectLockConfigurationOutput(
    object_lock_configuration: option.Option(ObjectLockConfiguration),
  )
}

pub fn encode_get_object_lock_configuration_output_struct(
  input: GetObjectLockConfigurationOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.object_lock_configuration {
    option.Some(v) -> [
      #("ObjectLockConfiguration", encode_object_lock_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_lock_configuration_output_struct() -> decode.Decoder(
  GetObjectLockConfigurationOutput,
) {
  use object_lock_configuration <- decode.optional_field(
    "ObjectLockConfiguration",
    option.None,
    decode.optional(decode_object_lock_configuration_struct()),
  )
  decode.success(GetObjectLockConfigurationOutput(
    object_lock_configuration: object_lock_configuration,
  ))
}

pub type ObjectLockConfiguration {
  ObjectLockConfiguration(
    object_lock_enabled: option.Option(ObjectLockEnabled),
    rule: option.Option(ObjectLockRule),
  )
}

pub fn encode_object_lock_configuration_struct(
  input: ObjectLockConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.object_lock_enabled {
    option.Some(v) -> [
      #("ObjectLockEnabled", encode_object_lock_enabled_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.rule {
    option.Some(v) -> [#("Rule", encode_object_lock_rule_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_object_lock_configuration_struct() -> decode.Decoder(
  ObjectLockConfiguration,
) {
  use object_lock_enabled <- decode.optional_field(
    "ObjectLockEnabled",
    option.None,
    decode.optional(decode_object_lock_enabled_enum()),
  )
  use rule <- decode.optional_field(
    "Rule",
    option.None,
    decode.optional(decode_object_lock_rule_struct()),
  )
  decode.success(ObjectLockConfiguration(
    object_lock_enabled: object_lock_enabled,
    rule: rule,
  ))
}

pub type ObjectLockEnabled {
  ObjectLockEnabledEnabled
}

pub fn encode_object_lock_enabled_enum(v: ObjectLockEnabled) -> json.Json {
  case v {
    ObjectLockEnabledEnabled -> json.string("Enabled")
  }
}

pub fn decode_object_lock_enabled_enum() -> decode.Decoder(ObjectLockEnabled) {
  decode.then(decode.string, fn(s) {
    case s {
      "Enabled" -> decode.success(ObjectLockEnabledEnabled)
      _ -> decode.failure(ObjectLockEnabledEnabled, "unknown enum value")
    }
  })
}

pub type ObjectLockRule {
  ObjectLockRule(default_retention: option.Option(DefaultRetention))
}

pub fn encode_object_lock_rule_struct(input: ObjectLockRule) -> json.Json {
  let pairs = []
  let pairs = case input.default_retention {
    option.Some(v) -> [
      #("DefaultRetention", encode_default_retention_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_object_lock_rule_struct() -> decode.Decoder(ObjectLockRule) {
  use default_retention <- decode.optional_field(
    "DefaultRetention",
    option.None,
    decode.optional(decode_default_retention_struct()),
  )
  decode.success(ObjectLockRule(default_retention: default_retention))
}

pub type DefaultRetention {
  DefaultRetention(
    days: option.Option(Int),
    mode: option.Option(ObjectLockRetentionMode),
    years: option.Option(Int),
  )
}

pub fn encode_default_retention_struct(input: DefaultRetention) -> json.Json {
  let pairs = []
  let pairs = case input.days {
    option.Some(v) -> [#("Days", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.mode {
    option.Some(v) -> [
      #("Mode", encode_object_lock_retention_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.years {
    option.Some(v) -> [#("Years", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_default_retention_struct() -> decode.Decoder(DefaultRetention) {
  use days <- decode.optional_field(
    "Days",
    option.None,
    decode.optional(decode.int),
  )
  use mode <- decode.optional_field(
    "Mode",
    option.None,
    decode.optional(decode_object_lock_retention_mode_enum()),
  )
  use years <- decode.optional_field(
    "Years",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(DefaultRetention(days: days, mode: mode, years: years))
}

pub type ObjectLockRetentionMode {
  ObjectLockRetentionModeCompliance
  ObjectLockRetentionModeGovernance
}

pub fn encode_object_lock_retention_mode_enum(
  v: ObjectLockRetentionMode,
) -> json.Json {
  case v {
    ObjectLockRetentionModeCompliance -> json.string("COMPLIANCE")
    ObjectLockRetentionModeGovernance -> json.string("GOVERNANCE")
  }
}

pub fn decode_object_lock_retention_mode_enum() -> decode.Decoder(
  ObjectLockRetentionMode,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "COMPLIANCE" -> decode.success(ObjectLockRetentionModeCompliance)
      "GOVERNANCE" -> decode.success(ObjectLockRetentionModeGovernance)
      _ ->
        decode.failure(ObjectLockRetentionModeCompliance, "unknown enum value")
    }
  })
}

pub type GetObjectRetentionRequest {
  GetObjectRetentionRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    request_payer: option.Option(RequestPayer),
    version_id: option.Option(String),
  )
}

pub fn encode_get_object_retention_request_struct(
  input: GetObjectRetentionRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_retention_request_struct() -> decode.Decoder(
  GetObjectRetentionRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectRetentionRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    request_payer: request_payer,
    version_id: version_id,
  ))
}

pub type GetObjectRetentionOutput {
  GetObjectRetentionOutput(retention: option.Option(ObjectLockRetention))
}

pub fn encode_get_object_retention_output_struct(
  input: GetObjectRetentionOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.retention {
    option.Some(v) -> [
      #("Retention", encode_object_lock_retention_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_retention_output_struct() -> decode.Decoder(
  GetObjectRetentionOutput,
) {
  use retention <- decode.optional_field(
    "Retention",
    option.None,
    decode.optional(decode_object_lock_retention_struct()),
  )
  decode.success(GetObjectRetentionOutput(retention: retention))
}

pub type ObjectLockRetention {
  ObjectLockRetention(
    mode: option.Option(ObjectLockRetentionMode),
    retain_until_date: option.Option(Int),
  )
}

pub fn encode_object_lock_retention_struct(
  input: ObjectLockRetention,
) -> json.Json {
  let pairs = []
  let pairs = case input.mode {
    option.Some(v) -> [
      #("Mode", encode_object_lock_retention_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.retain_until_date {
    option.Some(v) -> [#("RetainUntilDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_object_lock_retention_struct() -> decode.Decoder(
  ObjectLockRetention,
) {
  use mode <- decode.optional_field(
    "Mode",
    option.None,
    decode.optional(decode_object_lock_retention_mode_enum()),
  )
  use retain_until_date <- decode.optional_field(
    "RetainUntilDate",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ObjectLockRetention(
    mode: mode,
    retain_until_date: retain_until_date,
  ))
}

pub type GetObjectTaggingRequest {
  GetObjectTaggingRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    request_payer: option.Option(RequestPayer),
    version_id: option.Option(String),
  )
}

pub fn encode_get_object_tagging_request_struct(
  input: GetObjectTaggingRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_tagging_request_struct() -> decode.Decoder(
  GetObjectTaggingRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectTaggingRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    request_payer: request_payer,
    version_id: version_id,
  ))
}

pub type GetObjectTaggingOutput {
  GetObjectTaggingOutput(
    tag_set: option.Option(List(Tag)),
    version_id: option.Option(String),
  )
}

pub fn encode_get_object_tagging_output_struct(
  input: GetObjectTaggingOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.tag_set {
    option.Some(v) -> [
      #("TagSet", fn(xs) { json.array(xs, encode_tag_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_tagging_output_struct() -> decode.Decoder(
  GetObjectTaggingOutput,
) {
  use tag_set <- decode.optional_field(
    "TagSet",
    option.None,
    decode.optional(decode.list(decode_tag_struct())),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetObjectTaggingOutput(
    tag_set: tag_set,
    version_id: version_id,
  ))
}

pub type GetObjectTorrentRequest {
  GetObjectTorrentRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    request_payer: option.Option(RequestPayer),
  )
}

pub fn encode_get_object_torrent_request_struct(
  input: GetObjectTorrentRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_torrent_request_struct() -> decode.Decoder(
  GetObjectTorrentRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  decode.success(GetObjectTorrentRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    request_payer: request_payer,
  ))
}

pub type GetObjectTorrentOutput {
  GetObjectTorrentOutput(
    body: option.Option(BitArray),
    request_charged: option.Option(RequestCharged),
  )
}

pub fn encode_get_object_torrent_output_struct(
  input: GetObjectTorrentOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.body {
    option.Some(v) -> [
      #("Body", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_object_torrent_output_struct() -> decode.Decoder(
  GetObjectTorrentOutput,
) {
  use body <- decode.optional_field(
    "Body",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  decode.success(GetObjectTorrentOutput(
    body: body,
    request_charged: request_charged,
  ))
}

pub type GetPublicAccessBlockRequest {
  GetPublicAccessBlockRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_get_public_access_block_request_struct(
  input: GetPublicAccessBlockRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_public_access_block_request_struct() -> decode.Decoder(
  GetPublicAccessBlockRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(GetPublicAccessBlockRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type GetPublicAccessBlockOutput {
  GetPublicAccessBlockOutput(
    public_access_block_configuration: option.Option(
      PublicAccessBlockConfiguration,
    ),
  )
}

pub fn encode_get_public_access_block_output_struct(
  input: GetPublicAccessBlockOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.public_access_block_configuration {
    option.Some(v) -> [
      #(
        "PublicAccessBlockConfiguration",
        encode_public_access_block_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_get_public_access_block_output_struct() -> decode.Decoder(
  GetPublicAccessBlockOutput,
) {
  use public_access_block_configuration <- decode.optional_field(
    "PublicAccessBlockConfiguration",
    option.None,
    decode.optional(decode_public_access_block_configuration_struct()),
  )
  decode.success(GetPublicAccessBlockOutput(
    public_access_block_configuration: public_access_block_configuration,
  ))
}

pub type PublicAccessBlockConfiguration {
  PublicAccessBlockConfiguration(
    block_public_acls: option.Option(Bool),
    block_public_policy: option.Option(Bool),
    ignore_public_acls: option.Option(Bool),
    restrict_public_buckets: option.Option(Bool),
  )
}

pub fn encode_public_access_block_configuration_struct(
  input: PublicAccessBlockConfiguration,
) -> json.Json {
  let pairs = []
  let pairs = case input.block_public_acls {
    option.Some(v) -> [#("BlockPublicAcls", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.block_public_policy {
    option.Some(v) -> [#("BlockPublicPolicy", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ignore_public_acls {
    option.Some(v) -> [#("IgnorePublicAcls", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.restrict_public_buckets {
    option.Some(v) -> [#("RestrictPublicBuckets", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_public_access_block_configuration_struct() -> decode.Decoder(
  PublicAccessBlockConfiguration,
) {
  use block_public_acls <- decode.optional_field(
    "BlockPublicAcls",
    option.None,
    decode.optional(decode.bool),
  )
  use block_public_policy <- decode.optional_field(
    "BlockPublicPolicy",
    option.None,
    decode.optional(decode.bool),
  )
  use ignore_public_acls <- decode.optional_field(
    "IgnorePublicAcls",
    option.None,
    decode.optional(decode.bool),
  )
  use restrict_public_buckets <- decode.optional_field(
    "RestrictPublicBuckets",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(PublicAccessBlockConfiguration(
    block_public_acls: block_public_acls,
    block_public_policy: block_public_policy,
    ignore_public_acls: ignore_public_acls,
    restrict_public_buckets: restrict_public_buckets,
  ))
}

pub type HeadBucketRequest {
  HeadBucketRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_head_bucket_request_struct(
  input: HeadBucketRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_head_bucket_request_struct() -> decode.Decoder(HeadBucketRequest) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HeadBucketRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type HeadBucketOutput {
  HeadBucketOutput(
    access_point_alias: option.Option(Bool),
    bucket_arn: option.Option(String),
    bucket_location_name: option.Option(String),
    bucket_location_type: option.Option(LocationType),
    bucket_region: option.Option(String),
  )
}

pub fn encode_head_bucket_output_struct(input: HeadBucketOutput) -> json.Json {
  let pairs = []
  let pairs = case input.access_point_alias {
    option.Some(v) -> [#("AccessPointAlias", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_arn {
    option.Some(v) -> [#("BucketArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_location_name {
    option.Some(v) -> [#("BucketLocationName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_location_type {
    option.Some(v) -> [
      #("BucketLocationType", encode_location_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.bucket_region {
    option.Some(v) -> [#("BucketRegion", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_head_bucket_output_struct() -> decode.Decoder(HeadBucketOutput) {
  use access_point_alias <- decode.optional_field(
    "AccessPointAlias",
    option.None,
    decode.optional(decode.bool),
  )
  use bucket_arn <- decode.optional_field(
    "BucketArn",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_location_name <- decode.optional_field(
    "BucketLocationName",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_location_type <- decode.optional_field(
    "BucketLocationType",
    option.None,
    decode.optional(decode_location_type_enum()),
  )
  use bucket_region <- decode.optional_field(
    "BucketRegion",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HeadBucketOutput(
    access_point_alias: access_point_alias,
    bucket_arn: bucket_arn,
    bucket_location_name: bucket_location_name,
    bucket_location_type: bucket_location_type,
    bucket_region: bucket_region,
  ))
}

pub type HeadObjectRequest {
  HeadObjectRequest(
    bucket: option.Option(String),
    checksum_mode: option.Option(ChecksumMode),
    expected_bucket_owner: option.Option(String),
    if_match: option.Option(String),
    if_modified_since: option.Option(Int),
    if_none_match: option.Option(String),
    if_unmodified_since: option.Option(Int),
    key: option.Option(String),
    part_number: option.Option(Int),
    range: option.Option(String),
    request_payer: option.Option(RequestPayer),
    response_cache_control: option.Option(String),
    response_content_disposition: option.Option(String),
    response_content_encoding: option.Option(String),
    response_content_language: option.Option(String),
    response_content_type: option.Option(String),
    response_expires: option.Option(Int),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    version_id: option.Option(String),
  )
}

pub fn encode_head_object_request_struct(
  input: HeadObjectRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_mode {
    option.Some(v) -> [#("ChecksumMode", encode_checksum_mode_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_match {
    option.Some(v) -> [#("IfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_modified_since {
    option.Some(v) -> [#("IfModifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_none_match {
    option.Some(v) -> [#("IfNoneMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.if_unmodified_since {
    option.Some(v) -> [#("IfUnmodifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number {
    option.Some(v) -> [#("PartNumber", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.range {
    option.Some(v) -> [#("Range", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.response_cache_control {
    option.Some(v) -> [#("ResponseCacheControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.response_content_disposition {
    option.Some(v) -> [#("ResponseContentDisposition", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.response_content_encoding {
    option.Some(v) -> [#("ResponseContentEncoding", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.response_content_language {
    option.Some(v) -> [#("ResponseContentLanguage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.response_content_type {
    option.Some(v) -> [#("ResponseContentType", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.response_expires {
    option.Some(v) -> [#("ResponseExpires", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_head_object_request_struct() -> decode.Decoder(HeadObjectRequest) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_mode <- decode.optional_field(
    "ChecksumMode",
    option.None,
    decode.optional(decode_checksum_mode_enum()),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use if_match <- decode.optional_field(
    "IfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use if_modified_since <- decode.optional_field(
    "IfModifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use if_none_match <- decode.optional_field(
    "IfNoneMatch",
    option.None,
    decode.optional(decode.string),
  )
  use if_unmodified_since <- decode.optional_field(
    "IfUnmodifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use part_number <- decode.optional_field(
    "PartNumber",
    option.None,
    decode.optional(decode.int),
  )
  use range <- decode.optional_field(
    "Range",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use response_cache_control <- decode.optional_field(
    "ResponseCacheControl",
    option.None,
    decode.optional(decode.string),
  )
  use response_content_disposition <- decode.optional_field(
    "ResponseContentDisposition",
    option.None,
    decode.optional(decode.string),
  )
  use response_content_encoding <- decode.optional_field(
    "ResponseContentEncoding",
    option.None,
    decode.optional(decode.string),
  )
  use response_content_language <- decode.optional_field(
    "ResponseContentLanguage",
    option.None,
    decode.optional(decode.string),
  )
  use response_content_type <- decode.optional_field(
    "ResponseContentType",
    option.None,
    decode.optional(decode.string),
  )
  use response_expires <- decode.optional_field(
    "ResponseExpires",
    option.None,
    decode.optional(decode.int),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HeadObjectRequest(
    bucket: bucket,
    checksum_mode: checksum_mode,
    expected_bucket_owner: expected_bucket_owner,
    if_match: if_match,
    if_modified_since: if_modified_since,
    if_none_match: if_none_match,
    if_unmodified_since: if_unmodified_since,
    key: key,
    part_number: part_number,
    range: range,
    request_payer: request_payer,
    response_cache_control: response_cache_control,
    response_content_disposition: response_content_disposition,
    response_content_encoding: response_content_encoding,
    response_content_language: response_content_language,
    response_content_type: response_content_type,
    response_expires: response_expires,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    version_id: version_id,
  ))
}

pub type ChecksumMode {
  ChecksumModeEnabled
}

pub fn encode_checksum_mode_enum(v: ChecksumMode) -> json.Json {
  case v {
    ChecksumModeEnabled -> json.string("ENABLED")
  }
}

pub fn decode_checksum_mode_enum() -> decode.Decoder(ChecksumMode) {
  decode.then(decode.string, fn(s) {
    case s {
      "ENABLED" -> decode.success(ChecksumModeEnabled)
      _ -> decode.failure(ChecksumModeEnabled, "unknown enum value")
    }
  })
}

pub type HeadObjectOutput {
  HeadObjectOutput(
    accept_ranges: option.Option(String),
    archive_status: option.Option(ArchiveStatus),
    bucket_key_enabled: option.Option(Bool),
    cache_control: option.Option(String),
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_type: option.Option(ChecksumType),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    content_disposition: option.Option(String),
    content_encoding: option.Option(String),
    content_language: option.Option(String),
    content_length: option.Option(Int),
    content_range: option.Option(String),
    content_type: option.Option(String),
    delete_marker: option.Option(Bool),
    e_tag: option.Option(String),
    expiration: option.Option(String),
    expires: option.Option(String),
    last_modified: option.Option(Int),
    metadata: option.Option(dict.Dict(String, String)),
    missing_meta: option.Option(Int),
    object_lock_legal_hold_status: option.Option(ObjectLockLegalHoldStatus),
    object_lock_mode: option.Option(ObjectLockMode),
    object_lock_retain_until_date: option.Option(Int),
    parts_count: option.Option(Int),
    replication_status: option.Option(ReplicationStatus),
    request_charged: option.Option(RequestCharged),
    restore: option.Option(String),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    storage_class: option.Option(StorageClass),
    tag_count: option.Option(Int),
    version_id: option.Option(String),
    website_redirect_location: option.Option(String),
  )
}

pub fn encode_head_object_output_struct(input: HeadObjectOutput) -> json.Json {
  let pairs = []
  let pairs = case input.accept_ranges {
    option.Some(v) -> [#("AcceptRanges", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.archive_status {
    option.Some(v) -> [
      #("ArchiveStatus", encode_archive_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.cache_control {
    option.Some(v) -> [#("CacheControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_disposition {
    option.Some(v) -> [#("ContentDisposition", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_encoding {
    option.Some(v) -> [#("ContentEncoding", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_language {
    option.Some(v) -> [#("ContentLanguage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_length {
    option.Some(v) -> [#("ContentLength", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_range {
    option.Some(v) -> [#("ContentRange", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_type {
    option.Some(v) -> [#("ContentType", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delete_marker {
    option.Some(v) -> [#("DeleteMarker", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expiration {
    option.Some(v) -> [#("Expiration", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expires {
    option.Some(v) -> [#("Expires", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.metadata {
    option.Some(v) -> [
      #(
        "Metadata",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.missing_meta {
    option.Some(v) -> [#("MissingMeta", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_lock_legal_hold_status {
    option.Some(v) -> [
      #(
        "ObjectLockLegalHoldStatus",
        encode_object_lock_legal_hold_status_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_mode {
    option.Some(v) -> [
      #("ObjectLockMode", encode_object_lock_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_retain_until_date {
    option.Some(v) -> [#("ObjectLockRetainUntilDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.parts_count {
    option.Some(v) -> [#("PartsCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replication_status {
    option.Some(v) -> [
      #("ReplicationStatus", encode_replication_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.restore {
    option.Some(v) -> [#("Restore", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tag_count {
    option.Some(v) -> [#("TagCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.website_redirect_location {
    option.Some(v) -> [#("WebsiteRedirectLocation", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_head_object_output_struct() -> decode.Decoder(HeadObjectOutput) {
  use accept_ranges <- decode.optional_field(
    "AcceptRanges",
    option.None,
    decode.optional(decode.string),
  )
  use archive_status <- decode.optional_field(
    "ArchiveStatus",
    option.None,
    decode.optional(decode_archive_status_enum()),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use cache_control <- decode.optional_field(
    "CacheControl",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use content_disposition <- decode.optional_field(
    "ContentDisposition",
    option.None,
    decode.optional(decode.string),
  )
  use content_encoding <- decode.optional_field(
    "ContentEncoding",
    option.None,
    decode.optional(decode.string),
  )
  use content_language <- decode.optional_field(
    "ContentLanguage",
    option.None,
    decode.optional(decode.string),
  )
  use content_length <- decode.optional_field(
    "ContentLength",
    option.None,
    decode.optional(decode.int),
  )
  use content_range <- decode.optional_field(
    "ContentRange",
    option.None,
    decode.optional(decode.string),
  )
  use content_type <- decode.optional_field(
    "ContentType",
    option.None,
    decode.optional(decode.string),
  )
  use delete_marker <- decode.optional_field(
    "DeleteMarker",
    option.None,
    decode.optional(decode.bool),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use expiration <- decode.optional_field(
    "Expiration",
    option.None,
    decode.optional(decode.string),
  )
  use expires <- decode.optional_field(
    "Expires",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  use metadata <- decode.optional_field(
    "Metadata",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use missing_meta <- decode.optional_field(
    "MissingMeta",
    option.None,
    decode.optional(decode.int),
  )
  use object_lock_legal_hold_status <- decode.optional_field(
    "ObjectLockLegalHoldStatus",
    option.None,
    decode.optional(decode_object_lock_legal_hold_status_enum()),
  )
  use object_lock_mode <- decode.optional_field(
    "ObjectLockMode",
    option.None,
    decode.optional(decode_object_lock_mode_enum()),
  )
  use object_lock_retain_until_date <- decode.optional_field(
    "ObjectLockRetainUntilDate",
    option.None,
    decode.optional(decode.int),
  )
  use parts_count <- decode.optional_field(
    "PartsCount",
    option.None,
    decode.optional(decode.int),
  )
  use replication_status <- decode.optional_field(
    "ReplicationStatus",
    option.None,
    decode.optional(decode_replication_status_enum()),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use restore <- decode.optional_field(
    "Restore",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  use tag_count <- decode.optional_field(
    "TagCount",
    option.None,
    decode.optional(decode.int),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  use website_redirect_location <- decode.optional_field(
    "WebsiteRedirectLocation",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(HeadObjectOutput(
    accept_ranges: accept_ranges,
    archive_status: archive_status,
    bucket_key_enabled: bucket_key_enabled,
    cache_control: cache_control,
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_type: checksum_type,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    content_disposition: content_disposition,
    content_encoding: content_encoding,
    content_language: content_language,
    content_length: content_length,
    content_range: content_range,
    content_type: content_type,
    delete_marker: delete_marker,
    e_tag: e_tag,
    expiration: expiration,
    expires: expires,
    last_modified: last_modified,
    metadata: metadata,
    missing_meta: missing_meta,
    object_lock_legal_hold_status: object_lock_legal_hold_status,
    object_lock_mode: object_lock_mode,
    object_lock_retain_until_date: object_lock_retain_until_date,
    parts_count: parts_count,
    replication_status: replication_status,
    request_charged: request_charged,
    restore: restore,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key_md5: sse_customer_key_md5,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    storage_class: storage_class,
    tag_count: tag_count,
    version_id: version_id,
    website_redirect_location: website_redirect_location,
  ))
}

pub type ArchiveStatus {
  ArchiveStatusArchiveAccess
  ArchiveStatusDeepArchiveAccess
}

pub fn encode_archive_status_enum(v: ArchiveStatus) -> json.Json {
  case v {
    ArchiveStatusArchiveAccess -> json.string("ARCHIVE_ACCESS")
    ArchiveStatusDeepArchiveAccess -> json.string("DEEP_ARCHIVE_ACCESS")
  }
}

pub fn decode_archive_status_enum() -> decode.Decoder(ArchiveStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "ARCHIVE_ACCESS" -> decode.success(ArchiveStatusArchiveAccess)
      "DEEP_ARCHIVE_ACCESS" -> decode.success(ArchiveStatusDeepArchiveAccess)
      _ -> decode.failure(ArchiveStatusArchiveAccess, "unknown enum value")
    }
  })
}

pub type ReplicationStatus {
  ReplicationStatusComplete
  ReplicationStatusCompleted
  ReplicationStatusFailed
  ReplicationStatusPending
  ReplicationStatusReplica
}

pub fn encode_replication_status_enum(v: ReplicationStatus) -> json.Json {
  case v {
    ReplicationStatusComplete -> json.string("COMPLETE")
    ReplicationStatusCompleted -> json.string("COMPLETED")
    ReplicationStatusFailed -> json.string("FAILED")
    ReplicationStatusPending -> json.string("PENDING")
    ReplicationStatusReplica -> json.string("REPLICA")
  }
}

pub fn decode_replication_status_enum() -> decode.Decoder(ReplicationStatus) {
  decode.then(decode.string, fn(s) {
    case s {
      "COMPLETE" -> decode.success(ReplicationStatusComplete)
      "COMPLETED" -> decode.success(ReplicationStatusCompleted)
      "FAILED" -> decode.success(ReplicationStatusFailed)
      "PENDING" -> decode.success(ReplicationStatusPending)
      "REPLICA" -> decode.success(ReplicationStatusReplica)
      _ -> decode.failure(ReplicationStatusComplete, "unknown enum value")
    }
  })
}

pub type ListBucketAnalyticsConfigurationsRequest {
  ListBucketAnalyticsConfigurationsRequest(
    bucket: option.Option(String),
    continuation_token: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_list_bucket_analytics_configurations_request_struct(
  input: ListBucketAnalyticsConfigurationsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_analytics_configurations_request_struct() -> decode.Decoder(
  ListBucketAnalyticsConfigurationsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketAnalyticsConfigurationsRequest(
    bucket: bucket,
    continuation_token: continuation_token,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type ListBucketAnalyticsConfigurationsOutput {
  ListBucketAnalyticsConfigurationsOutput(
    analytics_configuration_list: option.Option(List(AnalyticsConfiguration)),
    continuation_token: option.Option(String),
    is_truncated: option.Option(Bool),
    next_continuation_token: option.Option(String),
  )
}

pub fn encode_list_bucket_analytics_configurations_output_struct(
  input: ListBucketAnalyticsConfigurationsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.analytics_configuration_list {
    option.Some(v) -> [
      #(
        "AnalyticsConfigurationList",
        fn(xs) { json.array(xs, encode_analytics_configuration_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_continuation_token {
    option.Some(v) -> [#("NextContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_analytics_configurations_output_struct() -> decode.Decoder(
  ListBucketAnalyticsConfigurationsOutput,
) {
  use analytics_configuration_list <- decode.optional_field(
    "AnalyticsConfigurationList",
    option.None,
    decode.optional(decode.list(decode_analytics_configuration_struct())),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use next_continuation_token <- decode.optional_field(
    "NextContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketAnalyticsConfigurationsOutput(
    analytics_configuration_list: analytics_configuration_list,
    continuation_token: continuation_token,
    is_truncated: is_truncated,
    next_continuation_token: next_continuation_token,
  ))
}

pub type ListBucketIntelligentTieringConfigurationsRequest {
  ListBucketIntelligentTieringConfigurationsRequest(
    bucket: option.Option(String),
    continuation_token: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_list_bucket_intelligent_tiering_configurations_request_struct(
  input: ListBucketIntelligentTieringConfigurationsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_intelligent_tiering_configurations_request_struct() -> decode.Decoder(
  ListBucketIntelligentTieringConfigurationsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketIntelligentTieringConfigurationsRequest(
    bucket: bucket,
    continuation_token: continuation_token,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type ListBucketIntelligentTieringConfigurationsOutput {
  ListBucketIntelligentTieringConfigurationsOutput(
    continuation_token: option.Option(String),
    intelligent_tiering_configuration_list: option.Option(
      List(IntelligentTieringConfiguration),
    ),
    is_truncated: option.Option(Bool),
    next_continuation_token: option.Option(String),
  )
}

pub fn encode_list_bucket_intelligent_tiering_configurations_output_struct(
  input: ListBucketIntelligentTieringConfigurationsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.intelligent_tiering_configuration_list {
    option.Some(v) -> [
      #(
        "IntelligentTieringConfigurationList",
        fn(xs) {
          json.array(xs, encode_intelligent_tiering_configuration_struct)
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_continuation_token {
    option.Some(v) -> [#("NextContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_intelligent_tiering_configurations_output_struct() -> decode.Decoder(
  ListBucketIntelligentTieringConfigurationsOutput,
) {
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use intelligent_tiering_configuration_list <- decode.optional_field(
    "IntelligentTieringConfigurationList",
    option.None,
    decode.optional(
      decode.list(decode_intelligent_tiering_configuration_struct()),
    ),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use next_continuation_token <- decode.optional_field(
    "NextContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketIntelligentTieringConfigurationsOutput(
    continuation_token: continuation_token,
    intelligent_tiering_configuration_list: intelligent_tiering_configuration_list,
    is_truncated: is_truncated,
    next_continuation_token: next_continuation_token,
  ))
}

pub type ListBucketInventoryConfigurationsRequest {
  ListBucketInventoryConfigurationsRequest(
    bucket: option.Option(String),
    continuation_token: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_list_bucket_inventory_configurations_request_struct(
  input: ListBucketInventoryConfigurationsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_inventory_configurations_request_struct() -> decode.Decoder(
  ListBucketInventoryConfigurationsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketInventoryConfigurationsRequest(
    bucket: bucket,
    continuation_token: continuation_token,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type ListBucketInventoryConfigurationsOutput {
  ListBucketInventoryConfigurationsOutput(
    continuation_token: option.Option(String),
    inventory_configuration_list: option.Option(List(InventoryConfiguration)),
    is_truncated: option.Option(Bool),
    next_continuation_token: option.Option(String),
  )
}

pub fn encode_list_bucket_inventory_configurations_output_struct(
  input: ListBucketInventoryConfigurationsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.inventory_configuration_list {
    option.Some(v) -> [
      #(
        "InventoryConfigurationList",
        fn(xs) { json.array(xs, encode_inventory_configuration_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_continuation_token {
    option.Some(v) -> [#("NextContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_inventory_configurations_output_struct() -> decode.Decoder(
  ListBucketInventoryConfigurationsOutput,
) {
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use inventory_configuration_list <- decode.optional_field(
    "InventoryConfigurationList",
    option.None,
    decode.optional(decode.list(decode_inventory_configuration_struct())),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use next_continuation_token <- decode.optional_field(
    "NextContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketInventoryConfigurationsOutput(
    continuation_token: continuation_token,
    inventory_configuration_list: inventory_configuration_list,
    is_truncated: is_truncated,
    next_continuation_token: next_continuation_token,
  ))
}

pub type ListBucketMetricsConfigurationsRequest {
  ListBucketMetricsConfigurationsRequest(
    bucket: option.Option(String),
    continuation_token: option.Option(String),
    expected_bucket_owner: option.Option(String),
  )
}

pub fn encode_list_bucket_metrics_configurations_request_struct(
  input: ListBucketMetricsConfigurationsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_metrics_configurations_request_struct() -> decode.Decoder(
  ListBucketMetricsConfigurationsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketMetricsConfigurationsRequest(
    bucket: bucket,
    continuation_token: continuation_token,
    expected_bucket_owner: expected_bucket_owner,
  ))
}

pub type ListBucketMetricsConfigurationsOutput {
  ListBucketMetricsConfigurationsOutput(
    continuation_token: option.Option(String),
    is_truncated: option.Option(Bool),
    metrics_configuration_list: option.Option(List(MetricsConfiguration)),
    next_continuation_token: option.Option(String),
  )
}

pub fn encode_list_bucket_metrics_configurations_output_struct(
  input: ListBucketMetricsConfigurationsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.metrics_configuration_list {
    option.Some(v) -> [
      #(
        "MetricsConfigurationList",
        fn(xs) { json.array(xs, encode_metrics_configuration_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.next_continuation_token {
    option.Some(v) -> [#("NextContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_bucket_metrics_configurations_output_struct() -> decode.Decoder(
  ListBucketMetricsConfigurationsOutput,
) {
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use metrics_configuration_list <- decode.optional_field(
    "MetricsConfigurationList",
    option.None,
    decode.optional(decode.list(decode_metrics_configuration_struct())),
  )
  use next_continuation_token <- decode.optional_field(
    "NextContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketMetricsConfigurationsOutput(
    continuation_token: continuation_token,
    is_truncated: is_truncated,
    metrics_configuration_list: metrics_configuration_list,
    next_continuation_token: next_continuation_token,
  ))
}

pub type ListBucketsRequest {
  ListBucketsRequest(
    bucket_region: option.Option(String),
    continuation_token: option.Option(String),
    max_buckets: option.Option(Int),
    prefix: option.Option(String),
  )
}

pub fn encode_list_buckets_request_struct(
  input: ListBucketsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket_region {
    option.Some(v) -> [#("BucketRegion", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_buckets {
    option.Some(v) -> [#("MaxBuckets", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_buckets_request_struct() -> decode.Decoder(
  ListBucketsRequest,
) {
  use bucket_region <- decode.optional_field(
    "BucketRegion",
    option.None,
    decode.optional(decode.string),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use max_buckets <- decode.optional_field(
    "MaxBuckets",
    option.None,
    decode.optional(decode.int),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketsRequest(
    bucket_region: bucket_region,
    continuation_token: continuation_token,
    max_buckets: max_buckets,
    prefix: prefix,
  ))
}

pub type ListBucketsOutput {
  ListBucketsOutput(
    buckets: option.Option(List(Bucket)),
    continuation_token: option.Option(String),
    owner: option.Option(Owner),
    prefix: option.Option(String),
  )
}

pub fn encode_list_buckets_output_struct(
  input: ListBucketsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.buckets {
    option.Some(v) -> [
      #("Buckets", fn(xs) { json.array(xs, encode_bucket_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_buckets_output_struct() -> decode.Decoder(ListBucketsOutput) {
  use buckets <- decode.optional_field(
    "Buckets",
    option.None,
    decode.optional(decode.list(decode_bucket_struct())),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListBucketsOutput(
    buckets: buckets,
    continuation_token: continuation_token,
    owner: owner,
    prefix: prefix,
  ))
}

pub type Bucket {
  Bucket(
    bucket_arn: option.Option(String),
    bucket_region: option.Option(String),
    creation_date: option.Option(Int),
    name: option.Option(String),
  )
}

pub fn encode_bucket_struct(input: Bucket) -> json.Json {
  let pairs = []
  let pairs = case input.bucket_arn {
    option.Some(v) -> [#("BucketArn", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket_region {
    option.Some(v) -> [#("BucketRegion", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.creation_date {
    option.Some(v) -> [#("CreationDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.name {
    option.Some(v) -> [#("Name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_bucket_struct() -> decode.Decoder(Bucket) {
  use bucket_arn <- decode.optional_field(
    "BucketArn",
    option.None,
    decode.optional(decode.string),
  )
  use bucket_region <- decode.optional_field(
    "BucketRegion",
    option.None,
    decode.optional(decode.string),
  )
  use creation_date <- decode.optional_field(
    "CreationDate",
    option.None,
    decode.optional(decode.int),
  )
  use name <- decode.optional_field(
    "Name",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Bucket(
    bucket_arn: bucket_arn,
    bucket_region: bucket_region,
    creation_date: creation_date,
    name: name,
  ))
}

pub type ListDirectoryBucketsRequest {
  ListDirectoryBucketsRequest(
    continuation_token: option.Option(String),
    max_directory_buckets: option.Option(Int),
  )
}

pub fn encode_list_directory_buckets_request_struct(
  input: ListDirectoryBucketsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_directory_buckets {
    option.Some(v) -> [#("MaxDirectoryBuckets", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_directory_buckets_request_struct() -> decode.Decoder(
  ListDirectoryBucketsRequest,
) {
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use max_directory_buckets <- decode.optional_field(
    "MaxDirectoryBuckets",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ListDirectoryBucketsRequest(
    continuation_token: continuation_token,
    max_directory_buckets: max_directory_buckets,
  ))
}

pub type ListDirectoryBucketsOutput {
  ListDirectoryBucketsOutput(
    buckets: option.Option(List(Bucket)),
    continuation_token: option.Option(String),
  )
}

pub fn encode_list_directory_buckets_output_struct(
  input: ListDirectoryBucketsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.buckets {
    option.Some(v) -> [
      #("Buckets", fn(xs) { json.array(xs, encode_bucket_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_directory_buckets_output_struct() -> decode.Decoder(
  ListDirectoryBucketsOutput,
) {
  use buckets <- decode.optional_field(
    "Buckets",
    option.None,
    decode.optional(decode.list(decode_bucket_struct())),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListDirectoryBucketsOutput(
    buckets: buckets,
    continuation_token: continuation_token,
  ))
}

pub type ListMultipartUploadsRequest {
  ListMultipartUploadsRequest(
    bucket: option.Option(String),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    expected_bucket_owner: option.Option(String),
    key_marker: option.Option(String),
    max_uploads: option.Option(Int),
    prefix: option.Option(String),
    request_payer: option.Option(RequestPayer),
    upload_id_marker: option.Option(String),
  )
}

pub fn encode_list_multipart_uploads_request_struct(
  input: ListMultipartUploadsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_marker {
    option.Some(v) -> [#("KeyMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_uploads {
    option.Some(v) -> [#("MaxUploads", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.upload_id_marker {
    option.Some(v) -> [#("UploadIdMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_multipart_uploads_request_struct() -> decode.Decoder(
  ListMultipartUploadsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key_marker <- decode.optional_field(
    "KeyMarker",
    option.None,
    decode.optional(decode.string),
  )
  use max_uploads <- decode.optional_field(
    "MaxUploads",
    option.None,
    decode.optional(decode.int),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use upload_id_marker <- decode.optional_field(
    "UploadIdMarker",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListMultipartUploadsRequest(
    bucket: bucket,
    delimiter: delimiter,
    encoding_type: encoding_type,
    expected_bucket_owner: expected_bucket_owner,
    key_marker: key_marker,
    max_uploads: max_uploads,
    prefix: prefix,
    request_payer: request_payer,
    upload_id_marker: upload_id_marker,
  ))
}

pub type EncodingType {
  EncodingTypeUrl
}

pub fn encode_encoding_type_enum(v: EncodingType) -> json.Json {
  case v {
    EncodingTypeUrl -> json.string("url")
  }
}

pub fn decode_encoding_type_enum() -> decode.Decoder(EncodingType) {
  decode.then(decode.string, fn(s) {
    case s {
      "url" -> decode.success(EncodingTypeUrl)
      _ -> decode.failure(EncodingTypeUrl, "unknown enum value")
    }
  })
}

pub type ListMultipartUploadsOutput {
  ListMultipartUploadsOutput(
    bucket: option.Option(String),
    common_prefixes: option.Option(List(CommonPrefix)),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    is_truncated: option.Option(Bool),
    key_marker: option.Option(String),
    max_uploads: option.Option(Int),
    next_key_marker: option.Option(String),
    next_upload_id_marker: option.Option(String),
    prefix: option.Option(String),
    request_charged: option.Option(RequestCharged),
    upload_id_marker: option.Option(String),
    uploads: option.Option(List(MultipartUpload)),
  )
}

pub fn encode_list_multipart_uploads_output_struct(
  input: ListMultipartUploadsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.common_prefixes {
    option.Some(v) -> [
      #(
        "CommonPrefixes",
        fn(xs) { json.array(xs, encode_common_prefix_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_marker {
    option.Some(v) -> [#("KeyMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_uploads {
    option.Some(v) -> [#("MaxUploads", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_key_marker {
    option.Some(v) -> [#("NextKeyMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_upload_id_marker {
    option.Some(v) -> [#("NextUploadIdMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.upload_id_marker {
    option.Some(v) -> [#("UploadIdMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.uploads {
    option.Some(v) -> [
      #("Uploads", fn(xs) { json.array(xs, encode_multipart_upload_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_multipart_uploads_output_struct() -> decode.Decoder(
  ListMultipartUploadsOutput,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use common_prefixes <- decode.optional_field(
    "CommonPrefixes",
    option.None,
    decode.optional(decode.list(decode_common_prefix_struct())),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use key_marker <- decode.optional_field(
    "KeyMarker",
    option.None,
    decode.optional(decode.string),
  )
  use max_uploads <- decode.optional_field(
    "MaxUploads",
    option.None,
    decode.optional(decode.int),
  )
  use next_key_marker <- decode.optional_field(
    "NextKeyMarker",
    option.None,
    decode.optional(decode.string),
  )
  use next_upload_id_marker <- decode.optional_field(
    "NextUploadIdMarker",
    option.None,
    decode.optional(decode.string),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use upload_id_marker <- decode.optional_field(
    "UploadIdMarker",
    option.None,
    decode.optional(decode.string),
  )
  use uploads <- decode.optional_field(
    "Uploads",
    option.None,
    decode.optional(decode.list(decode_multipart_upload_struct())),
  )
  decode.success(ListMultipartUploadsOutput(
    bucket: bucket,
    common_prefixes: common_prefixes,
    delimiter: delimiter,
    encoding_type: encoding_type,
    is_truncated: is_truncated,
    key_marker: key_marker,
    max_uploads: max_uploads,
    next_key_marker: next_key_marker,
    next_upload_id_marker: next_upload_id_marker,
    prefix: prefix,
    request_charged: request_charged,
    upload_id_marker: upload_id_marker,
    uploads: uploads,
  ))
}

pub type CommonPrefix {
  CommonPrefix(prefix: option.Option(String))
}

pub fn encode_common_prefix_struct(input: CommonPrefix) -> json.Json {
  let pairs = []
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_common_prefix_struct() -> decode.Decoder(CommonPrefix) {
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CommonPrefix(prefix: prefix))
}

pub type MultipartUpload {
  MultipartUpload(
    checksum_algorithm: option.Option(ChecksumAlgorithm),
    checksum_type: option.Option(ChecksumType),
    initiated: option.Option(Int),
    initiator: option.Option(Initiator),
    key: option.Option(String),
    owner: option.Option(Owner),
    storage_class: option.Option(StorageClass),
    upload_id: option.Option(String),
  )
}

pub fn encode_multipart_upload_struct(input: MultipartUpload) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_algorithm {
    option.Some(v) -> [
      #("ChecksumAlgorithm", encode_checksum_algorithm_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.initiated {
    option.Some(v) -> [#("Initiated", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.initiator {
    option.Some(v) -> [#("Initiator", encode_initiator_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.upload_id {
    option.Some(v) -> [#("UploadId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_multipart_upload_struct() -> decode.Decoder(MultipartUpload) {
  use checksum_algorithm <- decode.optional_field(
    "ChecksumAlgorithm",
    option.None,
    decode.optional(decode_checksum_algorithm_enum()),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use initiated <- decode.optional_field(
    "Initiated",
    option.None,
    decode.optional(decode.int),
  )
  use initiator <- decode.optional_field(
    "Initiator",
    option.None,
    decode.optional(decode_initiator_struct()),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  use upload_id <- decode.optional_field(
    "UploadId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(MultipartUpload(
    checksum_algorithm: checksum_algorithm,
    checksum_type: checksum_type,
    initiated: initiated,
    initiator: initiator,
    key: key,
    owner: owner,
    storage_class: storage_class,
    upload_id: upload_id,
  ))
}

pub type Initiator {
  Initiator(display_name: option.Option(String), id: option.Option(String))
}

pub fn encode_initiator_struct(input: Initiator) -> json.Json {
  let pairs = []
  let pairs = case input.display_name {
    option.Some(v) -> [#("DisplayName", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("ID", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_initiator_struct() -> decode.Decoder(Initiator) {
  use display_name <- decode.optional_field(
    "DisplayName",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "ID",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(Initiator(display_name: display_name, id: id))
}

pub type ListObjectsRequest {
  ListObjectsRequest(
    bucket: option.Option(String),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    expected_bucket_owner: option.Option(String),
    marker: option.Option(String),
    max_keys: option.Option(Int),
    optional_object_attributes: option.Option(List(OptionalObjectAttributes)),
    prefix: option.Option(String),
    request_payer: option.Option(RequestPayer),
  )
}

pub fn encode_list_objects_request_struct(
  input: ListObjectsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.marker {
    option.Some(v) -> [#("Marker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_keys {
    option.Some(v) -> [#("MaxKeys", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.optional_object_attributes {
    option.Some(v) -> [
      #(
        "OptionalObjectAttributes",
        fn(xs) { json.array(xs, encode_optional_object_attributes_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_objects_request_struct() -> decode.Decoder(
  ListObjectsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use marker <- decode.optional_field(
    "Marker",
    option.None,
    decode.optional(decode.string),
  )
  use max_keys <- decode.optional_field(
    "MaxKeys",
    option.None,
    decode.optional(decode.int),
  )
  use optional_object_attributes <- decode.optional_field(
    "OptionalObjectAttributes",
    option.None,
    decode.optional(decode.list(decode_optional_object_attributes_enum())),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  decode.success(ListObjectsRequest(
    bucket: bucket,
    delimiter: delimiter,
    encoding_type: encoding_type,
    expected_bucket_owner: expected_bucket_owner,
    marker: marker,
    max_keys: max_keys,
    optional_object_attributes: optional_object_attributes,
    prefix: prefix,
    request_payer: request_payer,
  ))
}

pub type OptionalObjectAttributes {
  OptionalObjectAttributesRestoreStatus
}

pub fn encode_optional_object_attributes_enum(
  v: OptionalObjectAttributes,
) -> json.Json {
  case v {
    OptionalObjectAttributesRestoreStatus -> json.string("RestoreStatus")
  }
}

pub fn decode_optional_object_attributes_enum() -> decode.Decoder(
  OptionalObjectAttributes,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "RestoreStatus" -> decode.success(OptionalObjectAttributesRestoreStatus)
      _ ->
        decode.failure(
          OptionalObjectAttributesRestoreStatus,
          "unknown enum value",
        )
    }
  })
}

pub type ListObjectsOutput {
  ListObjectsOutput(
    common_prefixes: option.Option(List(CommonPrefix)),
    contents: option.Option(List(Object)),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    is_truncated: option.Option(Bool),
    marker: option.Option(String),
    max_keys: option.Option(Int),
    name: option.Option(String),
    next_marker: option.Option(String),
    prefix: option.Option(String),
    request_charged: option.Option(RequestCharged),
  )
}

pub fn encode_list_objects_output_struct(
  input: ListObjectsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.common_prefixes {
    option.Some(v) -> [
      #(
        "CommonPrefixes",
        fn(xs) { json.array(xs, encode_common_prefix_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.contents {
    option.Some(v) -> [
      #("Contents", fn(xs) { json.array(xs, encode_object_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.marker {
    option.Some(v) -> [#("Marker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_keys {
    option.Some(v) -> [#("MaxKeys", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.name {
    option.Some(v) -> [#("Name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_marker {
    option.Some(v) -> [#("NextMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_objects_output_struct() -> decode.Decoder(ListObjectsOutput) {
  use common_prefixes <- decode.optional_field(
    "CommonPrefixes",
    option.None,
    decode.optional(decode.list(decode_common_prefix_struct())),
  )
  use contents <- decode.optional_field(
    "Contents",
    option.None,
    decode.optional(decode.list(decode_object_struct())),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use marker <- decode.optional_field(
    "Marker",
    option.None,
    decode.optional(decode.string),
  )
  use max_keys <- decode.optional_field(
    "MaxKeys",
    option.None,
    decode.optional(decode.int),
  )
  use name <- decode.optional_field(
    "Name",
    option.None,
    decode.optional(decode.string),
  )
  use next_marker <- decode.optional_field(
    "NextMarker",
    option.None,
    decode.optional(decode.string),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  decode.success(ListObjectsOutput(
    common_prefixes: common_prefixes,
    contents: contents,
    delimiter: delimiter,
    encoding_type: encoding_type,
    is_truncated: is_truncated,
    marker: marker,
    max_keys: max_keys,
    name: name,
    next_marker: next_marker,
    prefix: prefix,
    request_charged: request_charged,
  ))
}

pub type Object {
  Object(
    checksum_algorithm: option.Option(List(ChecksumAlgorithm)),
    checksum_type: option.Option(ChecksumType),
    e_tag: option.Option(String),
    key: option.Option(String),
    last_modified: option.Option(Int),
    owner: option.Option(Owner),
    restore_status: option.Option(RestoreStatus),
    size: option.Option(Int),
    storage_class: option.Option(ObjectStorageClass),
  )
}

pub fn encode_object_struct(input: Object) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_algorithm {
    option.Some(v) -> [
      #(
        "ChecksumAlgorithm",
        fn(xs) { json.array(xs, encode_checksum_algorithm_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.restore_status {
    option.Some(v) -> [
      #("RestoreStatus", encode_restore_status_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.size {
    option.Some(v) -> [#("Size", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [
      #("StorageClass", encode_object_storage_class_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_object_struct() -> decode.Decoder(Object) {
  use checksum_algorithm <- decode.optional_field(
    "ChecksumAlgorithm",
    option.None,
    decode.optional(decode.list(decode_checksum_algorithm_enum())),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  use restore_status <- decode.optional_field(
    "RestoreStatus",
    option.None,
    decode.optional(decode_restore_status_struct()),
  )
  use size <- decode.optional_field(
    "Size",
    option.None,
    decode.optional(decode.int),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_object_storage_class_enum()),
  )
  decode.success(Object(
    checksum_algorithm: checksum_algorithm,
    checksum_type: checksum_type,
    e_tag: e_tag,
    key: key,
    last_modified: last_modified,
    owner: owner,
    restore_status: restore_status,
    size: size,
    storage_class: storage_class,
  ))
}

pub type RestoreStatus {
  RestoreStatus(
    is_restore_in_progress: option.Option(Bool),
    restore_expiry_date: option.Option(Int),
  )
}

pub fn encode_restore_status_struct(input: RestoreStatus) -> json.Json {
  let pairs = []
  let pairs = case input.is_restore_in_progress {
    option.Some(v) -> [#("IsRestoreInProgress", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.restore_expiry_date {
    option.Some(v) -> [#("RestoreExpiryDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_restore_status_struct() -> decode.Decoder(RestoreStatus) {
  use is_restore_in_progress <- decode.optional_field(
    "IsRestoreInProgress",
    option.None,
    decode.optional(decode.bool),
  )
  use restore_expiry_date <- decode.optional_field(
    "RestoreExpiryDate",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(RestoreStatus(
    is_restore_in_progress: is_restore_in_progress,
    restore_expiry_date: restore_expiry_date,
  ))
}

pub type ObjectStorageClass {
  ObjectStorageClassDeepArchive
  ObjectStorageClassExpressOnezone
  ObjectStorageClassFsxOntap
  ObjectStorageClassFsxOpenzfs
  ObjectStorageClassGlacier
  ObjectStorageClassGlacierIr
  ObjectStorageClassIntelligentTiering
  ObjectStorageClassOnezoneIa
  ObjectStorageClassOutposts
  ObjectStorageClassReducedRedundancy
  ObjectStorageClassSnow
  ObjectStorageClassStandard
  ObjectStorageClassStandardIa
}

pub fn encode_object_storage_class_enum(v: ObjectStorageClass) -> json.Json {
  case v {
    ObjectStorageClassDeepArchive -> json.string("DEEP_ARCHIVE")
    ObjectStorageClassExpressOnezone -> json.string("EXPRESS_ONEZONE")
    ObjectStorageClassFsxOntap -> json.string("FSX_ONTAP")
    ObjectStorageClassFsxOpenzfs -> json.string("FSX_OPENZFS")
    ObjectStorageClassGlacier -> json.string("GLACIER")
    ObjectStorageClassGlacierIr -> json.string("GLACIER_IR")
    ObjectStorageClassIntelligentTiering -> json.string("INTELLIGENT_TIERING")
    ObjectStorageClassOnezoneIa -> json.string("ONEZONE_IA")
    ObjectStorageClassOutposts -> json.string("OUTPOSTS")
    ObjectStorageClassReducedRedundancy -> json.string("REDUCED_REDUNDANCY")
    ObjectStorageClassSnow -> json.string("SNOW")
    ObjectStorageClassStandard -> json.string("STANDARD")
    ObjectStorageClassStandardIa -> json.string("STANDARD_IA")
  }
}

pub fn decode_object_storage_class_enum() -> decode.Decoder(ObjectStorageClass) {
  decode.then(decode.string, fn(s) {
    case s {
      "DEEP_ARCHIVE" -> decode.success(ObjectStorageClassDeepArchive)
      "EXPRESS_ONEZONE" -> decode.success(ObjectStorageClassExpressOnezone)
      "FSX_ONTAP" -> decode.success(ObjectStorageClassFsxOntap)
      "FSX_OPENZFS" -> decode.success(ObjectStorageClassFsxOpenzfs)
      "GLACIER" -> decode.success(ObjectStorageClassGlacier)
      "GLACIER_IR" -> decode.success(ObjectStorageClassGlacierIr)
      "INTELLIGENT_TIERING" ->
        decode.success(ObjectStorageClassIntelligentTiering)
      "ONEZONE_IA" -> decode.success(ObjectStorageClassOnezoneIa)
      "OUTPOSTS" -> decode.success(ObjectStorageClassOutposts)
      "REDUCED_REDUNDANCY" ->
        decode.success(ObjectStorageClassReducedRedundancy)
      "SNOW" -> decode.success(ObjectStorageClassSnow)
      "STANDARD" -> decode.success(ObjectStorageClassStandard)
      "STANDARD_IA" -> decode.success(ObjectStorageClassStandardIa)
      _ -> decode.failure(ObjectStorageClassDeepArchive, "unknown enum value")
    }
  })
}

pub type ListObjectsV2Request {
  ListObjectsV2Request(
    bucket: option.Option(String),
    continuation_token: option.Option(String),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    expected_bucket_owner: option.Option(String),
    fetch_owner: option.Option(Bool),
    max_keys: option.Option(Int),
    optional_object_attributes: option.Option(List(OptionalObjectAttributes)),
    prefix: option.Option(String),
    request_payer: option.Option(RequestPayer),
    start_after: option.Option(String),
  )
}

pub fn encode_list_objects_v2_request_struct(
  input: ListObjectsV2Request,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.fetch_owner {
    option.Some(v) -> [#("FetchOwner", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_keys {
    option.Some(v) -> [#("MaxKeys", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.optional_object_attributes {
    option.Some(v) -> [
      #(
        "OptionalObjectAttributes",
        fn(xs) { json.array(xs, encode_optional_object_attributes_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.start_after {
    option.Some(v) -> [#("StartAfter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_objects_v2_request_struct() -> decode.Decoder(
  ListObjectsV2Request,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use fetch_owner <- decode.optional_field(
    "FetchOwner",
    option.None,
    decode.optional(decode.bool),
  )
  use max_keys <- decode.optional_field(
    "MaxKeys",
    option.None,
    decode.optional(decode.int),
  )
  use optional_object_attributes <- decode.optional_field(
    "OptionalObjectAttributes",
    option.None,
    decode.optional(decode.list(decode_optional_object_attributes_enum())),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use start_after <- decode.optional_field(
    "StartAfter",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListObjectsV2Request(
    bucket: bucket,
    continuation_token: continuation_token,
    delimiter: delimiter,
    encoding_type: encoding_type,
    expected_bucket_owner: expected_bucket_owner,
    fetch_owner: fetch_owner,
    max_keys: max_keys,
    optional_object_attributes: optional_object_attributes,
    prefix: prefix,
    request_payer: request_payer,
    start_after: start_after,
  ))
}

pub type ListObjectsV2Output {
  ListObjectsV2Output(
    common_prefixes: option.Option(List(CommonPrefix)),
    contents: option.Option(List(Object)),
    continuation_token: option.Option(String),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    is_truncated: option.Option(Bool),
    key_count: option.Option(Int),
    max_keys: option.Option(Int),
    name: option.Option(String),
    next_continuation_token: option.Option(String),
    prefix: option.Option(String),
    request_charged: option.Option(RequestCharged),
    start_after: option.Option(String),
  )
}

pub fn encode_list_objects_v2_output_struct(
  input: ListObjectsV2Output,
) -> json.Json {
  let pairs = []
  let pairs = case input.common_prefixes {
    option.Some(v) -> [
      #(
        "CommonPrefixes",
        fn(xs) { json.array(xs, encode_common_prefix_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.contents {
    option.Some(v) -> [
      #("Contents", fn(xs) { json.array(xs, encode_object_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.continuation_token {
    option.Some(v) -> [#("ContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_count {
    option.Some(v) -> [#("KeyCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_keys {
    option.Some(v) -> [#("MaxKeys", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.name {
    option.Some(v) -> [#("Name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_continuation_token {
    option.Some(v) -> [#("NextContinuationToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.start_after {
    option.Some(v) -> [#("StartAfter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_objects_v2_output_struct() -> decode.Decoder(
  ListObjectsV2Output,
) {
  use common_prefixes <- decode.optional_field(
    "CommonPrefixes",
    option.None,
    decode.optional(decode.list(decode_common_prefix_struct())),
  )
  use contents <- decode.optional_field(
    "Contents",
    option.None,
    decode.optional(decode.list(decode_object_struct())),
  )
  use continuation_token <- decode.optional_field(
    "ContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use key_count <- decode.optional_field(
    "KeyCount",
    option.None,
    decode.optional(decode.int),
  )
  use max_keys <- decode.optional_field(
    "MaxKeys",
    option.None,
    decode.optional(decode.int),
  )
  use name <- decode.optional_field(
    "Name",
    option.None,
    decode.optional(decode.string),
  )
  use next_continuation_token <- decode.optional_field(
    "NextContinuationToken",
    option.None,
    decode.optional(decode.string),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use start_after <- decode.optional_field(
    "StartAfter",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListObjectsV2Output(
    common_prefixes: common_prefixes,
    contents: contents,
    continuation_token: continuation_token,
    delimiter: delimiter,
    encoding_type: encoding_type,
    is_truncated: is_truncated,
    key_count: key_count,
    max_keys: max_keys,
    name: name,
    next_continuation_token: next_continuation_token,
    prefix: prefix,
    request_charged: request_charged,
    start_after: start_after,
  ))
}

pub type ListObjectVersionsRequest {
  ListObjectVersionsRequest(
    bucket: option.Option(String),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    expected_bucket_owner: option.Option(String),
    key_marker: option.Option(String),
    max_keys: option.Option(Int),
    optional_object_attributes: option.Option(List(OptionalObjectAttributes)),
    prefix: option.Option(String),
    request_payer: option.Option(RequestPayer),
    version_id_marker: option.Option(String),
  )
}

pub fn encode_list_object_versions_request_struct(
  input: ListObjectVersionsRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_marker {
    option.Some(v) -> [#("KeyMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_keys {
    option.Some(v) -> [#("MaxKeys", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.optional_object_attributes {
    option.Some(v) -> [
      #(
        "OptionalObjectAttributes",
        fn(xs) { json.array(xs, encode_optional_object_attributes_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id_marker {
    option.Some(v) -> [#("VersionIdMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_object_versions_request_struct() -> decode.Decoder(
  ListObjectVersionsRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key_marker <- decode.optional_field(
    "KeyMarker",
    option.None,
    decode.optional(decode.string),
  )
  use max_keys <- decode.optional_field(
    "MaxKeys",
    option.None,
    decode.optional(decode.int),
  )
  use optional_object_attributes <- decode.optional_field(
    "OptionalObjectAttributes",
    option.None,
    decode.optional(decode.list(decode_optional_object_attributes_enum())),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use version_id_marker <- decode.optional_field(
    "VersionIdMarker",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListObjectVersionsRequest(
    bucket: bucket,
    delimiter: delimiter,
    encoding_type: encoding_type,
    expected_bucket_owner: expected_bucket_owner,
    key_marker: key_marker,
    max_keys: max_keys,
    optional_object_attributes: optional_object_attributes,
    prefix: prefix,
    request_payer: request_payer,
    version_id_marker: version_id_marker,
  ))
}

pub type ListObjectVersionsOutput {
  ListObjectVersionsOutput(
    common_prefixes: option.Option(List(CommonPrefix)),
    delete_markers: option.Option(List(DeleteMarkerEntry)),
    delimiter: option.Option(String),
    encoding_type: option.Option(EncodingType),
    is_truncated: option.Option(Bool),
    key_marker: option.Option(String),
    max_keys: option.Option(Int),
    name: option.Option(String),
    next_key_marker: option.Option(String),
    next_version_id_marker: option.Option(String),
    prefix: option.Option(String),
    request_charged: option.Option(RequestCharged),
    version_id_marker: option.Option(String),
    versions: option.Option(List(ObjectVersion)),
  )
}

pub fn encode_list_object_versions_output_struct(
  input: ListObjectVersionsOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.common_prefixes {
    option.Some(v) -> [
      #(
        "CommonPrefixes",
        fn(xs) { json.array(xs, encode_common_prefix_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delete_markers {
    option.Some(v) -> [
      #(
        "DeleteMarkers",
        fn(xs) { json.array(xs, encode_delete_marker_entry_struct) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.delimiter {
    option.Some(v) -> [#("Delimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.encoding_type {
    option.Some(v) -> [#("EncodingType", encode_encoding_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key_marker {
    option.Some(v) -> [#("KeyMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_keys {
    option.Some(v) -> [#("MaxKeys", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.name {
    option.Some(v) -> [#("Name", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_key_marker {
    option.Some(v) -> [#("NextKeyMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_version_id_marker {
    option.Some(v) -> [#("NextVersionIdMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.prefix {
    option.Some(v) -> [#("Prefix", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.version_id_marker {
    option.Some(v) -> [#("VersionIdMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.versions {
    option.Some(v) -> [
      #("Versions", fn(xs) { json.array(xs, encode_object_version_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_object_versions_output_struct() -> decode.Decoder(
  ListObjectVersionsOutput,
) {
  use common_prefixes <- decode.optional_field(
    "CommonPrefixes",
    option.None,
    decode.optional(decode.list(decode_common_prefix_struct())),
  )
  use delete_markers <- decode.optional_field(
    "DeleteMarkers",
    option.None,
    decode.optional(decode.list(decode_delete_marker_entry_struct())),
  )
  use delimiter <- decode.optional_field(
    "Delimiter",
    option.None,
    decode.optional(decode.string),
  )
  use encoding_type <- decode.optional_field(
    "EncodingType",
    option.None,
    decode.optional(decode_encoding_type_enum()),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use key_marker <- decode.optional_field(
    "KeyMarker",
    option.None,
    decode.optional(decode.string),
  )
  use max_keys <- decode.optional_field(
    "MaxKeys",
    option.None,
    decode.optional(decode.int),
  )
  use name <- decode.optional_field(
    "Name",
    option.None,
    decode.optional(decode.string),
  )
  use next_key_marker <- decode.optional_field(
    "NextKeyMarker",
    option.None,
    decode.optional(decode.string),
  )
  use next_version_id_marker <- decode.optional_field(
    "NextVersionIdMarker",
    option.None,
    decode.optional(decode.string),
  )
  use prefix <- decode.optional_field(
    "Prefix",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use version_id_marker <- decode.optional_field(
    "VersionIdMarker",
    option.None,
    decode.optional(decode.string),
  )
  use versions <- decode.optional_field(
    "Versions",
    option.None,
    decode.optional(decode.list(decode_object_version_struct())),
  )
  decode.success(ListObjectVersionsOutput(
    common_prefixes: common_prefixes,
    delete_markers: delete_markers,
    delimiter: delimiter,
    encoding_type: encoding_type,
    is_truncated: is_truncated,
    key_marker: key_marker,
    max_keys: max_keys,
    name: name,
    next_key_marker: next_key_marker,
    next_version_id_marker: next_version_id_marker,
    prefix: prefix,
    request_charged: request_charged,
    version_id_marker: version_id_marker,
    versions: versions,
  ))
}

pub type DeleteMarkerEntry {
  DeleteMarkerEntry(
    is_latest: option.Option(Bool),
    key: option.Option(String),
    last_modified: option.Option(Int),
    owner: option.Option(Owner),
    version_id: option.Option(String),
  )
}

pub fn encode_delete_marker_entry_struct(
  input: DeleteMarkerEntry,
) -> json.Json {
  let pairs = []
  let pairs = case input.is_latest {
    option.Some(v) -> [#("IsLatest", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_delete_marker_entry_struct() -> decode.Decoder(DeleteMarkerEntry) {
  use is_latest <- decode.optional_field(
    "IsLatest",
    option.None,
    decode.optional(decode.bool),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(DeleteMarkerEntry(
    is_latest: is_latest,
    key: key,
    last_modified: last_modified,
    owner: owner,
    version_id: version_id,
  ))
}

pub type ObjectVersion {
  ObjectVersion(
    checksum_algorithm: option.Option(List(ChecksumAlgorithm)),
    checksum_type: option.Option(ChecksumType),
    e_tag: option.Option(String),
    is_latest: option.Option(Bool),
    key: option.Option(String),
    last_modified: option.Option(Int),
    owner: option.Option(Owner),
    restore_status: option.Option(RestoreStatus),
    size: option.Option(Int),
    storage_class: option.Option(ObjectVersionStorageClass),
    version_id: option.Option(String),
  )
}

pub fn encode_object_version_struct(input: ObjectVersion) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_algorithm {
    option.Some(v) -> [
      #(
        "ChecksumAlgorithm",
        fn(xs) { json.array(xs, encode_checksum_algorithm_enum) }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_latest {
    option.Some(v) -> [#("IsLatest", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.restore_status {
    option.Some(v) -> [
      #("RestoreStatus", encode_restore_status_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.size {
    option.Some(v) -> [#("Size", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [
      #("StorageClass", encode_object_version_storage_class_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_object_version_struct() -> decode.Decoder(ObjectVersion) {
  use checksum_algorithm <- decode.optional_field(
    "ChecksumAlgorithm",
    option.None,
    decode.optional(decode.list(decode_checksum_algorithm_enum())),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use is_latest <- decode.optional_field(
    "IsLatest",
    option.None,
    decode.optional(decode.bool),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  use restore_status <- decode.optional_field(
    "RestoreStatus",
    option.None,
    decode.optional(decode_restore_status_struct()),
  )
  use size <- decode.optional_field(
    "Size",
    option.None,
    decode.optional(decode.int),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_object_version_storage_class_enum()),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ObjectVersion(
    checksum_algorithm: checksum_algorithm,
    checksum_type: checksum_type,
    e_tag: e_tag,
    is_latest: is_latest,
    key: key,
    last_modified: last_modified,
    owner: owner,
    restore_status: restore_status,
    size: size,
    storage_class: storage_class,
    version_id: version_id,
  ))
}

pub type ObjectVersionStorageClass {
  ObjectVersionStorageClassStandard
}

pub fn encode_object_version_storage_class_enum(
  v: ObjectVersionStorageClass,
) -> json.Json {
  case v {
    ObjectVersionStorageClassStandard -> json.string("STANDARD")
  }
}

pub fn decode_object_version_storage_class_enum() -> decode.Decoder(
  ObjectVersionStorageClass,
) {
  decode.then(decode.string, fn(s) {
    case s {
      "STANDARD" -> decode.success(ObjectVersionStorageClassStandard)
      _ ->
        decode.failure(ObjectVersionStorageClassStandard, "unknown enum value")
    }
  })
}

pub type ListPartsRequest {
  ListPartsRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    key: option.Option(String),
    max_parts: option.Option(Int),
    part_number_marker: option.Option(String),
    request_payer: option.Option(RequestPayer),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    upload_id: option.Option(String),
  )
}

pub fn encode_list_parts_request_struct(input: ListPartsRequest) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_parts {
    option.Some(v) -> [#("MaxParts", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number_marker {
    option.Some(v) -> [#("PartNumberMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.upload_id {
    option.Some(v) -> [#("UploadId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_parts_request_struct() -> decode.Decoder(ListPartsRequest) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use max_parts <- decode.optional_field(
    "MaxParts",
    option.None,
    decode.optional(decode.int),
  )
  use part_number_marker <- decode.optional_field(
    "PartNumberMarker",
    option.None,
    decode.optional(decode.string),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use upload_id <- decode.optional_field(
    "UploadId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListPartsRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    key: key,
    max_parts: max_parts,
    part_number_marker: part_number_marker,
    request_payer: request_payer,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    upload_id: upload_id,
  ))
}

pub type ListPartsOutput {
  ListPartsOutput(
    abort_date: option.Option(Int),
    abort_rule_id: option.Option(String),
    bucket: option.Option(String),
    checksum_algorithm: option.Option(ChecksumAlgorithm),
    checksum_type: option.Option(ChecksumType),
    initiator: option.Option(Initiator),
    is_truncated: option.Option(Bool),
    key: option.Option(String),
    max_parts: option.Option(Int),
    next_part_number_marker: option.Option(String),
    owner: option.Option(Owner),
    part_number_marker: option.Option(String),
    parts: option.Option(List(Part)),
    request_charged: option.Option(RequestCharged),
    storage_class: option.Option(StorageClass),
    upload_id: option.Option(String),
  )
}

pub fn encode_list_parts_output_struct(input: ListPartsOutput) -> json.Json {
  let pairs = []
  let pairs = case input.abort_date {
    option.Some(v) -> [#("AbortDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.abort_rule_id {
    option.Some(v) -> [#("AbortRuleId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_algorithm {
    option.Some(v) -> [
      #("ChecksumAlgorithm", encode_checksum_algorithm_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.checksum_type {
    option.Some(v) -> [#("ChecksumType", encode_checksum_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.initiator {
    option.Some(v) -> [#("Initiator", encode_initiator_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.is_truncated {
    option.Some(v) -> [#("IsTruncated", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.max_parts {
    option.Some(v) -> [#("MaxParts", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.next_part_number_marker {
    option.Some(v) -> [#("NextPartNumberMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.owner {
    option.Some(v) -> [#("Owner", encode_owner_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number_marker {
    option.Some(v) -> [#("PartNumberMarker", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.parts {
    option.Some(v) -> [
      #("Parts", fn(xs) { json.array(xs, encode_part_struct) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.upload_id {
    option.Some(v) -> [#("UploadId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_list_parts_output_struct() -> decode.Decoder(ListPartsOutput) {
  use abort_date <- decode.optional_field(
    "AbortDate",
    option.None,
    decode.optional(decode.int),
  )
  use abort_rule_id <- decode.optional_field(
    "AbortRuleId",
    option.None,
    decode.optional(decode.string),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_algorithm <- decode.optional_field(
    "ChecksumAlgorithm",
    option.None,
    decode.optional(decode_checksum_algorithm_enum()),
  )
  use checksum_type <- decode.optional_field(
    "ChecksumType",
    option.None,
    decode.optional(decode_checksum_type_enum()),
  )
  use initiator <- decode.optional_field(
    "Initiator",
    option.None,
    decode.optional(decode_initiator_struct()),
  )
  use is_truncated <- decode.optional_field(
    "IsTruncated",
    option.None,
    decode.optional(decode.bool),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use max_parts <- decode.optional_field(
    "MaxParts",
    option.None,
    decode.optional(decode.int),
  )
  use next_part_number_marker <- decode.optional_field(
    "NextPartNumberMarker",
    option.None,
    decode.optional(decode.string),
  )
  use owner <- decode.optional_field(
    "Owner",
    option.None,
    decode.optional(decode_owner_struct()),
  )
  use part_number_marker <- decode.optional_field(
    "PartNumberMarker",
    option.None,
    decode.optional(decode.string),
  )
  use parts <- decode.optional_field(
    "Parts",
    option.None,
    decode.optional(decode.list(decode_part_struct())),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  use upload_id <- decode.optional_field(
    "UploadId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(ListPartsOutput(
    abort_date: abort_date,
    abort_rule_id: abort_rule_id,
    bucket: bucket,
    checksum_algorithm: checksum_algorithm,
    checksum_type: checksum_type,
    initiator: initiator,
    is_truncated: is_truncated,
    key: key,
    max_parts: max_parts,
    next_part_number_marker: next_part_number_marker,
    owner: owner,
    part_number_marker: part_number_marker,
    parts: parts,
    request_charged: request_charged,
    storage_class: storage_class,
    upload_id: upload_id,
  ))
}

pub type Part {
  Part(
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    e_tag: option.Option(String),
    last_modified: option.Option(Int),
    part_number: option.Option(Int),
    size: option.Option(Int),
  )
}

pub fn encode_part_struct(input: Part) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number {
    option.Some(v) -> [#("PartNumber", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.size {
    option.Some(v) -> [#("Size", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_part_struct() -> decode.Decoder(Part) {
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  use part_number <- decode.optional_field(
    "PartNumber",
    option.None,
    decode.optional(decode.int),
  )
  use size <- decode.optional_field(
    "Size",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(Part(
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    e_tag: e_tag,
    last_modified: last_modified,
    part_number: part_number,
    size: size,
  ))
}

pub type PutBucketAnalyticsConfigurationRequest {
  PutBucketAnalyticsConfigurationRequest(
    analytics_configuration: option.Option(AnalyticsConfiguration),
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
  )
}

pub fn encode_put_bucket_analytics_configuration_request_struct(
  input: PutBucketAnalyticsConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.analytics_configuration {
    option.Some(v) -> [
      #("AnalyticsConfiguration", encode_analytics_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_bucket_analytics_configuration_request_struct() -> decode.Decoder(
  PutBucketAnalyticsConfigurationRequest,
) {
  use analytics_configuration <- decode.optional_field(
    "AnalyticsConfiguration",
    option.None,
    decode.optional(decode_analytics_configuration_struct()),
  )
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(PutBucketAnalyticsConfigurationRequest(
    analytics_configuration: analytics_configuration,
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
  ))
}

pub type PutBucketIntelligentTieringConfigurationRequest {
  PutBucketIntelligentTieringConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
    intelligent_tiering_configuration: option.Option(
      IntelligentTieringConfiguration,
    ),
  )
}

pub fn encode_put_bucket_intelligent_tiering_configuration_request_struct(
  input: PutBucketIntelligentTieringConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.intelligent_tiering_configuration {
    option.Some(v) -> [
      #(
        "IntelligentTieringConfiguration",
        encode_intelligent_tiering_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_bucket_intelligent_tiering_configuration_request_struct() -> decode.Decoder(
  PutBucketIntelligentTieringConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use intelligent_tiering_configuration <- decode.optional_field(
    "IntelligentTieringConfiguration",
    option.None,
    decode.optional(decode_intelligent_tiering_configuration_struct()),
  )
  decode.success(PutBucketIntelligentTieringConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
    intelligent_tiering_configuration: intelligent_tiering_configuration,
  ))
}

pub type PutBucketInventoryConfigurationRequest {
  PutBucketInventoryConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
    inventory_configuration: option.Option(InventoryConfiguration),
  )
}

pub fn encode_put_bucket_inventory_configuration_request_struct(
  input: PutBucketInventoryConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.inventory_configuration {
    option.Some(v) -> [
      #("InventoryConfiguration", encode_inventory_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_bucket_inventory_configuration_request_struct() -> decode.Decoder(
  PutBucketInventoryConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use inventory_configuration <- decode.optional_field(
    "InventoryConfiguration",
    option.None,
    decode.optional(decode_inventory_configuration_struct()),
  )
  decode.success(PutBucketInventoryConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
    inventory_configuration: inventory_configuration,
  ))
}

pub type PutBucketMetricsConfigurationRequest {
  PutBucketMetricsConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    id: option.Option(String),
    metrics_configuration: option.Option(MetricsConfiguration),
  )
}

pub fn encode_put_bucket_metrics_configuration_request_struct(
  input: PutBucketMetricsConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.id {
    option.Some(v) -> [#("Id", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.metrics_configuration {
    option.Some(v) -> [
      #("MetricsConfiguration", encode_metrics_configuration_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_bucket_metrics_configuration_request_struct() -> decode.Decoder(
  PutBucketMetricsConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use id <- decode.optional_field(
    "Id",
    option.None,
    decode.optional(decode.string),
  )
  use metrics_configuration <- decode.optional_field(
    "MetricsConfiguration",
    option.None,
    decode.optional(decode_metrics_configuration_struct()),
  )
  decode.success(PutBucketMetricsConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    id: id,
    metrics_configuration: metrics_configuration,
  ))
}

pub type PutBucketNotificationConfigurationRequest {
  PutBucketNotificationConfigurationRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    notification_configuration: option.Option(NotificationConfiguration),
    skip_destination_validation: option.Option(Bool),
  )
}

pub fn encode_put_bucket_notification_configuration_request_struct(
  input: PutBucketNotificationConfigurationRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.notification_configuration {
    option.Some(v) -> [
      #(
        "NotificationConfiguration",
        encode_notification_configuration_struct(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.skip_destination_validation {
    option.Some(v) -> [#("SkipDestinationValidation", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_put_bucket_notification_configuration_request_struct() -> decode.Decoder(
  PutBucketNotificationConfigurationRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use notification_configuration <- decode.optional_field(
    "NotificationConfiguration",
    option.None,
    decode.optional(decode_notification_configuration_struct()),
  )
  use skip_destination_validation <- decode.optional_field(
    "SkipDestinationValidation",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(PutBucketNotificationConfigurationRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    notification_configuration: notification_configuration,
    skip_destination_validation: skip_destination_validation,
  ))
}

pub type RenameObjectRequest {
  RenameObjectRequest(
    bucket: option.Option(String),
    client_token: option.Option(String),
    destination_if_match: option.Option(String),
    destination_if_modified_since: option.Option(Int),
    destination_if_none_match: option.Option(String),
    destination_if_unmodified_since: option.Option(Int),
    key: option.Option(String),
    rename_source: option.Option(String),
    source_if_match: option.Option(String),
    source_if_modified_since: option.Option(Int),
    source_if_none_match: option.Option(String),
    source_if_unmodified_since: option.Option(Int),
  )
}

pub fn encode_rename_object_request_struct(
  input: RenameObjectRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.client_token {
    option.Some(v) -> [#("ClientToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.destination_if_match {
    option.Some(v) -> [#("DestinationIfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.destination_if_modified_since {
    option.Some(v) -> [#("DestinationIfModifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.destination_if_none_match {
    option.Some(v) -> [#("DestinationIfNoneMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.destination_if_unmodified_since {
    option.Some(v) -> [#("DestinationIfUnmodifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.rename_source {
    option.Some(v) -> [#("RenameSource", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_if_match {
    option.Some(v) -> [#("SourceIfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_if_modified_since {
    option.Some(v) -> [#("SourceIfModifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_if_none_match {
    option.Some(v) -> [#("SourceIfNoneMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.source_if_unmodified_since {
    option.Some(v) -> [#("SourceIfUnmodifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_rename_object_request_struct() -> decode.Decoder(
  RenameObjectRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use client_token <- decode.optional_field(
    "ClientToken",
    option.None,
    decode.optional(decode.string),
  )
  use destination_if_match <- decode.optional_field(
    "DestinationIfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use destination_if_modified_since <- decode.optional_field(
    "DestinationIfModifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use destination_if_none_match <- decode.optional_field(
    "DestinationIfNoneMatch",
    option.None,
    decode.optional(decode.string),
  )
  use destination_if_unmodified_since <- decode.optional_field(
    "DestinationIfUnmodifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use rename_source <- decode.optional_field(
    "RenameSource",
    option.None,
    decode.optional(decode.string),
  )
  use source_if_match <- decode.optional_field(
    "SourceIfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use source_if_modified_since <- decode.optional_field(
    "SourceIfModifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use source_if_none_match <- decode.optional_field(
    "SourceIfNoneMatch",
    option.None,
    decode.optional(decode.string),
  )
  use source_if_unmodified_since <- decode.optional_field(
    "SourceIfUnmodifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(RenameObjectRequest(
    bucket: bucket,
    client_token: client_token,
    destination_if_match: destination_if_match,
    destination_if_modified_since: destination_if_modified_since,
    destination_if_none_match: destination_if_none_match,
    destination_if_unmodified_since: destination_if_unmodified_since,
    key: key,
    rename_source: rename_source,
    source_if_match: source_if_match,
    source_if_modified_since: source_if_modified_since,
    source_if_none_match: source_if_none_match,
    source_if_unmodified_since: source_if_unmodified_since,
  ))
}

pub type RenameObjectOutput {
  RenameObjectOutput
}

pub fn encode_rename_object_output_struct(_v: RenameObjectOutput) -> json.Json {
  json.object([])
}

pub fn decode_rename_object_output_struct() -> decode.Decoder(
  RenameObjectOutput,
) {
  decode.success(RenameObjectOutput)
}

pub type SelectObjectContentRequest {
  SelectObjectContentRequest(
    bucket: option.Option(String),
    expected_bucket_owner: option.Option(String),
    expression: option.Option(String),
    expression_type: option.Option(ExpressionType),
    input_serialization: option.Option(InputSerialization),
    key: option.Option(String),
    output_serialization: option.Option(OutputSerialization),
    request_progress: option.Option(RequestProgress),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    scan_range: option.Option(ScanRange),
  )
}

pub fn encode_select_object_content_request_struct(
  input: SelectObjectContentRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression {
    option.Some(v) -> [#("Expression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_type {
    option.Some(v) -> [
      #("ExpressionType", encode_expression_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.input_serialization {
    option.Some(v) -> [
      #("InputSerialization", encode_input_serialization_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.output_serialization {
    option.Some(v) -> [
      #("OutputSerialization", encode_output_serialization_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_progress {
    option.Some(v) -> [
      #("RequestProgress", encode_request_progress_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.scan_range {
    option.Some(v) -> [#("ScanRange", encode_scan_range_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_select_object_content_request_struct() -> decode.Decoder(
  SelectObjectContentRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use expression <- decode.optional_field(
    "Expression",
    option.None,
    decode.optional(decode.string),
  )
  use expression_type <- decode.optional_field(
    "ExpressionType",
    option.None,
    decode.optional(decode_expression_type_enum()),
  )
  use input_serialization <- decode.optional_field(
    "InputSerialization",
    option.None,
    decode.optional(decode_input_serialization_struct()),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use output_serialization <- decode.optional_field(
    "OutputSerialization",
    option.None,
    decode.optional(decode_output_serialization_struct()),
  )
  use request_progress <- decode.optional_field(
    "RequestProgress",
    option.None,
    decode.optional(decode_request_progress_struct()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use scan_range <- decode.optional_field(
    "ScanRange",
    option.None,
    decode.optional(decode_scan_range_struct()),
  )
  decode.success(SelectObjectContentRequest(
    bucket: bucket,
    expected_bucket_owner: expected_bucket_owner,
    expression: expression,
    expression_type: expression_type,
    input_serialization: input_serialization,
    key: key,
    output_serialization: output_serialization,
    request_progress: request_progress,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    scan_range: scan_range,
  ))
}

pub type ExpressionType {
  ExpressionTypeSql
}

pub fn encode_expression_type_enum(v: ExpressionType) -> json.Json {
  case v {
    ExpressionTypeSql -> json.string("SQL")
  }
}

pub fn decode_expression_type_enum() -> decode.Decoder(ExpressionType) {
  decode.then(decode.string, fn(s) {
    case s {
      "SQL" -> decode.success(ExpressionTypeSql)
      _ -> decode.failure(ExpressionTypeSql, "unknown enum value")
    }
  })
}

pub type InputSerialization {
  InputSerialization(
    csv: option.Option(CSVInput),
    compression_type: option.Option(CompressionType),
    json: option.Option(JSONInput),
    parquet: option.Option(ParquetInput),
  )
}

pub fn encode_input_serialization_struct(
  input: InputSerialization,
) -> json.Json {
  let pairs = []
  let pairs = case input.csv {
    option.Some(v) -> [#("CSV", encode_csv_input_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.compression_type {
    option.Some(v) -> [
      #("CompressionType", encode_compression_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.json {
    option.Some(v) -> [#("JSON", encode_json_input_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.parquet {
    option.Some(v) -> [#("Parquet", encode_parquet_input_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_input_serialization_struct() -> decode.Decoder(InputSerialization) {
  use csv <- decode.optional_field(
    "CSV",
    option.None,
    decode.optional(decode_csv_input_struct()),
  )
  use compression_type <- decode.optional_field(
    "CompressionType",
    option.None,
    decode.optional(decode_compression_type_enum()),
  )
  use json <- decode.optional_field(
    "JSON",
    option.None,
    decode.optional(decode_json_input_struct()),
  )
  use parquet <- decode.optional_field(
    "Parquet",
    option.None,
    decode.optional(decode_parquet_input_struct()),
  )
  decode.success(InputSerialization(
    csv: csv,
    compression_type: compression_type,
    json: json,
    parquet: parquet,
  ))
}

pub type CSVInput {
  CSVInput(
    allow_quoted_record_delimiter: option.Option(Bool),
    comments: option.Option(String),
    field_delimiter: option.Option(String),
    file_header_info: option.Option(FileHeaderInfo),
    quote_character: option.Option(String),
    quote_escape_character: option.Option(String),
    record_delimiter: option.Option(String),
  )
}

pub fn encode_csv_input_struct(input: CSVInput) -> json.Json {
  let pairs = []
  let pairs = case input.allow_quoted_record_delimiter {
    option.Some(v) -> [#("AllowQuotedRecordDelimiter", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.comments {
    option.Some(v) -> [#("Comments", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.field_delimiter {
    option.Some(v) -> [#("FieldDelimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.file_header_info {
    option.Some(v) -> [
      #("FileHeaderInfo", encode_file_header_info_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.quote_character {
    option.Some(v) -> [#("QuoteCharacter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.quote_escape_character {
    option.Some(v) -> [#("QuoteEscapeCharacter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.record_delimiter {
    option.Some(v) -> [#("RecordDelimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_csv_input_struct() -> decode.Decoder(CSVInput) {
  use allow_quoted_record_delimiter <- decode.optional_field(
    "AllowQuotedRecordDelimiter",
    option.None,
    decode.optional(decode.bool),
  )
  use comments <- decode.optional_field(
    "Comments",
    option.None,
    decode.optional(decode.string),
  )
  use field_delimiter <- decode.optional_field(
    "FieldDelimiter",
    option.None,
    decode.optional(decode.string),
  )
  use file_header_info <- decode.optional_field(
    "FileHeaderInfo",
    option.None,
    decode.optional(decode_file_header_info_enum()),
  )
  use quote_character <- decode.optional_field(
    "QuoteCharacter",
    option.None,
    decode.optional(decode.string),
  )
  use quote_escape_character <- decode.optional_field(
    "QuoteEscapeCharacter",
    option.None,
    decode.optional(decode.string),
  )
  use record_delimiter <- decode.optional_field(
    "RecordDelimiter",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CSVInput(
    allow_quoted_record_delimiter: allow_quoted_record_delimiter,
    comments: comments,
    field_delimiter: field_delimiter,
    file_header_info: file_header_info,
    quote_character: quote_character,
    quote_escape_character: quote_escape_character,
    record_delimiter: record_delimiter,
  ))
}

pub type FileHeaderInfo {
  FileHeaderInfoIgnore
  FileHeaderInfoNone
  FileHeaderInfoUse
}

pub fn encode_file_header_info_enum(v: FileHeaderInfo) -> json.Json {
  case v {
    FileHeaderInfoIgnore -> json.string("IGNORE")
    FileHeaderInfoNone -> json.string("NONE")
    FileHeaderInfoUse -> json.string("USE")
  }
}

pub fn decode_file_header_info_enum() -> decode.Decoder(FileHeaderInfo) {
  decode.then(decode.string, fn(s) {
    case s {
      "IGNORE" -> decode.success(FileHeaderInfoIgnore)
      "NONE" -> decode.success(FileHeaderInfoNone)
      "USE" -> decode.success(FileHeaderInfoUse)
      _ -> decode.failure(FileHeaderInfoIgnore, "unknown enum value")
    }
  })
}

pub type CompressionType {
  CompressionTypeBzip2
  CompressionTypeGzip
  CompressionTypeNone
}

pub fn encode_compression_type_enum(v: CompressionType) -> json.Json {
  case v {
    CompressionTypeBzip2 -> json.string("BZIP2")
    CompressionTypeGzip -> json.string("GZIP")
    CompressionTypeNone -> json.string("NONE")
  }
}

pub fn decode_compression_type_enum() -> decode.Decoder(CompressionType) {
  decode.then(decode.string, fn(s) {
    case s {
      "BZIP2" -> decode.success(CompressionTypeBzip2)
      "GZIP" -> decode.success(CompressionTypeGzip)
      "NONE" -> decode.success(CompressionTypeNone)
      _ -> decode.failure(CompressionTypeBzip2, "unknown enum value")
    }
  })
}

pub type JSONInput {
  JSONInput(type_: option.Option(JSONType))
}

pub fn encode_json_input_struct(input: JSONInput) -> json.Json {
  let pairs = []
  let pairs = case input.type_ {
    option.Some(v) -> [#("Type", encode_json_type_enum(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_input_struct() -> decode.Decoder(JSONInput) {
  use type_ <- decode.optional_field(
    "Type",
    option.None,
    decode.optional(decode_json_type_enum()),
  )
  decode.success(JSONInput(type_: type_))
}

pub type JSONType {
  JSONTypeDocument
  JSONTypeLines
}

pub fn encode_json_type_enum(v: JSONType) -> json.Json {
  case v {
    JSONTypeDocument -> json.string("DOCUMENT")
    JSONTypeLines -> json.string("LINES")
  }
}

pub fn decode_json_type_enum() -> decode.Decoder(JSONType) {
  decode.then(decode.string, fn(s) {
    case s {
      "DOCUMENT" -> decode.success(JSONTypeDocument)
      "LINES" -> decode.success(JSONTypeLines)
      _ -> decode.failure(JSONTypeDocument, "unknown enum value")
    }
  })
}

pub type ParquetInput {
  ParquetInput
}

pub fn encode_parquet_input_struct(_v: ParquetInput) -> json.Json {
  json.object([])
}

pub fn decode_parquet_input_struct() -> decode.Decoder(ParquetInput) {
  decode.success(ParquetInput)
}

pub type OutputSerialization {
  OutputSerialization(
    csv: option.Option(CSVOutput),
    json: option.Option(JSONOutput),
  )
}

pub fn encode_output_serialization_struct(
  input: OutputSerialization,
) -> json.Json {
  let pairs = []
  let pairs = case input.csv {
    option.Some(v) -> [#("CSV", encode_csv_output_struct(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.json {
    option.Some(v) -> [#("JSON", encode_json_output_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_output_serialization_struct() -> decode.Decoder(
  OutputSerialization,
) {
  use csv <- decode.optional_field(
    "CSV",
    option.None,
    decode.optional(decode_csv_output_struct()),
  )
  use json <- decode.optional_field(
    "JSON",
    option.None,
    decode.optional(decode_json_output_struct()),
  )
  decode.success(OutputSerialization(csv: csv, json: json))
}

pub type CSVOutput {
  CSVOutput(
    field_delimiter: option.Option(String),
    quote_character: option.Option(String),
    quote_escape_character: option.Option(String),
    quote_fields: option.Option(QuoteFields),
    record_delimiter: option.Option(String),
  )
}

pub fn encode_csv_output_struct(input: CSVOutput) -> json.Json {
  let pairs = []
  let pairs = case input.field_delimiter {
    option.Some(v) -> [#("FieldDelimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.quote_character {
    option.Some(v) -> [#("QuoteCharacter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.quote_escape_character {
    option.Some(v) -> [#("QuoteEscapeCharacter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.quote_fields {
    option.Some(v) -> [#("QuoteFields", encode_quote_fields_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.record_delimiter {
    option.Some(v) -> [#("RecordDelimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_csv_output_struct() -> decode.Decoder(CSVOutput) {
  use field_delimiter <- decode.optional_field(
    "FieldDelimiter",
    option.None,
    decode.optional(decode.string),
  )
  use quote_character <- decode.optional_field(
    "QuoteCharacter",
    option.None,
    decode.optional(decode.string),
  )
  use quote_escape_character <- decode.optional_field(
    "QuoteEscapeCharacter",
    option.None,
    decode.optional(decode.string),
  )
  use quote_fields <- decode.optional_field(
    "QuoteFields",
    option.None,
    decode.optional(decode_quote_fields_enum()),
  )
  use record_delimiter <- decode.optional_field(
    "RecordDelimiter",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(CSVOutput(
    field_delimiter: field_delimiter,
    quote_character: quote_character,
    quote_escape_character: quote_escape_character,
    quote_fields: quote_fields,
    record_delimiter: record_delimiter,
  ))
}

pub type QuoteFields {
  QuoteFieldsAlways
  QuoteFieldsAsneeded
}

pub fn encode_quote_fields_enum(v: QuoteFields) -> json.Json {
  case v {
    QuoteFieldsAlways -> json.string("ALWAYS")
    QuoteFieldsAsneeded -> json.string("ASNEEDED")
  }
}

pub fn decode_quote_fields_enum() -> decode.Decoder(QuoteFields) {
  decode.then(decode.string, fn(s) {
    case s {
      "ALWAYS" -> decode.success(QuoteFieldsAlways)
      "ASNEEDED" -> decode.success(QuoteFieldsAsneeded)
      _ -> decode.failure(QuoteFieldsAlways, "unknown enum value")
    }
  })
}

pub type JSONOutput {
  JSONOutput(record_delimiter: option.Option(String))
}

pub fn encode_json_output_struct(input: JSONOutput) -> json.Json {
  let pairs = []
  let pairs = case input.record_delimiter {
    option.Some(v) -> [#("RecordDelimiter", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_json_output_struct() -> decode.Decoder(JSONOutput) {
  use record_delimiter <- decode.optional_field(
    "RecordDelimiter",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(JSONOutput(record_delimiter: record_delimiter))
}

pub type RequestProgress {
  RequestProgress(enabled: option.Option(Bool))
}

pub fn encode_request_progress_struct(input: RequestProgress) -> json.Json {
  let pairs = []
  let pairs = case input.enabled {
    option.Some(v) -> [#("Enabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_request_progress_struct() -> decode.Decoder(RequestProgress) {
  use enabled <- decode.optional_field(
    "Enabled",
    option.None,
    decode.optional(decode.bool),
  )
  decode.success(RequestProgress(enabled: enabled))
}

pub type ScanRange {
  ScanRange(end: option.Option(Int), start: option.Option(Int))
}

pub fn encode_scan_range_struct(input: ScanRange) -> json.Json {
  let pairs = []
  let pairs = case input.end {
    option.Some(v) -> [#("End", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.start {
    option.Some(v) -> [#("Start", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_scan_range_struct() -> decode.Decoder(ScanRange) {
  use end <- decode.optional_field(
    "End",
    option.None,
    decode.optional(decode.int),
  )
  use start <- decode.optional_field(
    "Start",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(ScanRange(end: end, start: start))
}

pub type SelectObjectContentOutput {
  SelectObjectContentOutput(
    payload: option.Option(SelectObjectContentEventStream),
  )
}

pub fn encode_select_object_content_output_struct(
  input: SelectObjectContentOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [
      #("Payload", encode_select_object_content_event_stream_union(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_select_object_content_output_struct() -> decode.Decoder(
  SelectObjectContentOutput,
) {
  use payload <- decode.optional_field(
    "Payload",
    option.None,
    decode.optional(decode_select_object_content_event_stream_union()),
  )
  decode.success(SelectObjectContentOutput(payload: payload))
}

pub type SelectObjectContentEventStream {
  SelectObjectContentEventStreamCont(ContinuationEvent)
  SelectObjectContentEventStreamEnd(EndEvent)
  SelectObjectContentEventStreamProgress(ProgressEvent)
  SelectObjectContentEventStreamRecords(RecordsEvent)
  SelectObjectContentEventStreamStats(StatsEvent)
}

pub fn encode_select_object_content_event_stream_union(
  v: SelectObjectContentEventStream,
) -> json.Json {
  case v {
    SelectObjectContentEventStreamCont(x) ->
      json.object([#("Cont", encode_continuation_event_struct(x))])
    SelectObjectContentEventStreamEnd(x) ->
      json.object([#("End", encode_end_event_struct(x))])
    SelectObjectContentEventStreamProgress(x) ->
      json.object([#("Progress", encode_progress_event_struct(x))])
    SelectObjectContentEventStreamRecords(x) ->
      json.object([#("Records", encode_records_event_struct(x))])
    SelectObjectContentEventStreamStats(x) ->
      json.object([#("Stats", encode_stats_event_struct(x))])
  }
}

pub fn decode_select_object_content_event_stream_union() -> decode.Decoder(
  SelectObjectContentEventStream,
) {
  decode.one_of(
    decode.field("Cont", decode_continuation_event_struct(), fn(x) {
      decode.success(SelectObjectContentEventStreamCont(x))
    }),
    [
      decode.field("End", decode_end_event_struct(), fn(x) {
        decode.success(SelectObjectContentEventStreamEnd(x))
      }),
      decode.field("Progress", decode_progress_event_struct(), fn(x) {
        decode.success(SelectObjectContentEventStreamProgress(x))
      }),
      decode.field("Records", decode_records_event_struct(), fn(x) {
        decode.success(SelectObjectContentEventStreamRecords(x))
      }),
      decode.field("Stats", decode_stats_event_struct(), fn(x) {
        decode.success(SelectObjectContentEventStreamStats(x))
      }),
    ],
  )
}

pub type ContinuationEvent {
  ContinuationEvent
}

pub fn encode_continuation_event_struct(_v: ContinuationEvent) -> json.Json {
  json.object([])
}

pub fn decode_continuation_event_struct() -> decode.Decoder(ContinuationEvent) {
  decode.success(ContinuationEvent)
}

pub type EndEvent {
  EndEvent
}

pub fn encode_end_event_struct(_v: EndEvent) -> json.Json {
  json.object([])
}

pub fn decode_end_event_struct() -> decode.Decoder(EndEvent) {
  decode.success(EndEvent)
}

pub type ProgressEvent {
  ProgressEvent(details: option.Option(Progress))
}

pub fn encode_progress_event_struct(input: ProgressEvent) -> json.Json {
  let pairs = []
  let pairs = case input.details {
    option.Some(v) -> [#("Details", encode_progress_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_progress_event_struct() -> decode.Decoder(ProgressEvent) {
  use details <- decode.optional_field(
    "Details",
    option.None,
    decode.optional(decode_progress_struct()),
  )
  decode.success(ProgressEvent(details: details))
}

pub type Progress {
  Progress(
    bytes_processed: option.Option(Int),
    bytes_returned: option.Option(Int),
    bytes_scanned: option.Option(Int),
  )
}

pub fn encode_progress_struct(input: Progress) -> json.Json {
  let pairs = []
  let pairs = case input.bytes_processed {
    option.Some(v) -> [#("BytesProcessed", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bytes_returned {
    option.Some(v) -> [#("BytesReturned", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bytes_scanned {
    option.Some(v) -> [#("BytesScanned", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_progress_struct() -> decode.Decoder(Progress) {
  use bytes_processed <- decode.optional_field(
    "BytesProcessed",
    option.None,
    decode.optional(decode.int),
  )
  use bytes_returned <- decode.optional_field(
    "BytesReturned",
    option.None,
    decode.optional(decode.int),
  )
  use bytes_scanned <- decode.optional_field(
    "BytesScanned",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(Progress(
    bytes_processed: bytes_processed,
    bytes_returned: bytes_returned,
    bytes_scanned: bytes_scanned,
  ))
}

pub type RecordsEvent {
  RecordsEvent(payload: option.Option(BitArray))
}

pub fn encode_records_event_struct(input: RecordsEvent) -> json.Json {
  let pairs = []
  let pairs = case input.payload {
    option.Some(v) -> [
      #("Payload", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_records_event_struct() -> decode.Decoder(RecordsEvent) {
  use payload <- decode.optional_field(
    "Payload",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  decode.success(RecordsEvent(payload: payload))
}

pub type StatsEvent {
  StatsEvent(details: option.Option(Stats))
}

pub fn encode_stats_event_struct(input: StatsEvent) -> json.Json {
  let pairs = []
  let pairs = case input.details {
    option.Some(v) -> [#("Details", encode_stats_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_stats_event_struct() -> decode.Decoder(StatsEvent) {
  use details <- decode.optional_field(
    "Details",
    option.None,
    decode.optional(decode_stats_struct()),
  )
  decode.success(StatsEvent(details: details))
}

pub type Stats {
  Stats(
    bytes_processed: option.Option(Int),
    bytes_returned: option.Option(Int),
    bytes_scanned: option.Option(Int),
  )
}

pub fn encode_stats_struct(input: Stats) -> json.Json {
  let pairs = []
  let pairs = case input.bytes_processed {
    option.Some(v) -> [#("BytesProcessed", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bytes_returned {
    option.Some(v) -> [#("BytesReturned", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.bytes_scanned {
    option.Some(v) -> [#("BytesScanned", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_stats_struct() -> decode.Decoder(Stats) {
  use bytes_processed <- decode.optional_field(
    "BytesProcessed",
    option.None,
    decode.optional(decode.int),
  )
  use bytes_returned <- decode.optional_field(
    "BytesReturned",
    option.None,
    decode.optional(decode.int),
  )
  use bytes_scanned <- decode.optional_field(
    "BytesScanned",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(Stats(
    bytes_processed: bytes_processed,
    bytes_returned: bytes_returned,
    bytes_scanned: bytes_scanned,
  ))
}

pub type UploadPartCopyRequest {
  UploadPartCopyRequest(
    bucket: option.Option(String),
    copy_source: option.Option(String),
    copy_source_if_match: option.Option(String),
    copy_source_if_modified_since: option.Option(Int),
    copy_source_if_none_match: option.Option(String),
    copy_source_if_unmodified_since: option.Option(Int),
    copy_source_range: option.Option(String),
    copy_source_sse_customer_algorithm: option.Option(String),
    copy_source_sse_customer_key: option.Option(String),
    copy_source_sse_customer_key_md5: option.Option(String),
    expected_bucket_owner: option.Option(String),
    expected_source_bucket_owner: option.Option(String),
    key: option.Option(String),
    part_number: option.Option(Int),
    request_payer: option.Option(RequestPayer),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    upload_id: option.Option(String),
  )
}

pub fn encode_upload_part_copy_request_struct(
  input: UploadPartCopyRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket {
    option.Some(v) -> [#("Bucket", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source {
    option.Some(v) -> [#("CopySource", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_match {
    option.Some(v) -> [#("CopySourceIfMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_modified_since {
    option.Some(v) -> [#("CopySourceIfModifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_none_match {
    option.Some(v) -> [#("CopySourceIfNoneMatch", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_if_unmodified_since {
    option.Some(v) -> [#("CopySourceIfUnmodifiedSince", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_range {
    option.Some(v) -> [#("CopySourceRange", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_sse_customer_algorithm {
    option.Some(v) -> [
      #("CopySourceSSECustomerAlgorithm", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.copy_source_sse_customer_key {
    option.Some(v) -> [#("CopySourceSSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_source_sse_customer_key_md5 {
    option.Some(v) -> [
      #("CopySourceSSECustomerKeyMD5", json.string(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.expected_bucket_owner {
    option.Some(v) -> [#("ExpectedBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expected_source_bucket_owner {
    option.Some(v) -> [#("ExpectedSourceBucketOwner", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.key {
    option.Some(v) -> [#("Key", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.part_number {
    option.Some(v) -> [#("PartNumber", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_payer {
    option.Some(v) -> [#("RequestPayer", encode_request_payer_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key {
    option.Some(v) -> [#("SSECustomerKey", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.upload_id {
    option.Some(v) -> [#("UploadId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_upload_part_copy_request_struct() -> decode.Decoder(
  UploadPartCopyRequest,
) {
  use bucket <- decode.optional_field(
    "Bucket",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source <- decode.optional_field(
    "CopySource",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_if_match <- decode.optional_field(
    "CopySourceIfMatch",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_if_modified_since <- decode.optional_field(
    "CopySourceIfModifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use copy_source_if_none_match <- decode.optional_field(
    "CopySourceIfNoneMatch",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_if_unmodified_since <- decode.optional_field(
    "CopySourceIfUnmodifiedSince",
    option.None,
    decode.optional(decode.int),
  )
  use copy_source_range <- decode.optional_field(
    "CopySourceRange",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_sse_customer_algorithm <- decode.optional_field(
    "CopySourceSSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_sse_customer_key <- decode.optional_field(
    "CopySourceSSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use copy_source_sse_customer_key_md5 <- decode.optional_field(
    "CopySourceSSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use expected_bucket_owner <- decode.optional_field(
    "ExpectedBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use expected_source_bucket_owner <- decode.optional_field(
    "ExpectedSourceBucketOwner",
    option.None,
    decode.optional(decode.string),
  )
  use key <- decode.optional_field(
    "Key",
    option.None,
    decode.optional(decode.string),
  )
  use part_number <- decode.optional_field(
    "PartNumber",
    option.None,
    decode.optional(decode.int),
  )
  use request_payer <- decode.optional_field(
    "RequestPayer",
    option.None,
    decode.optional(decode_request_payer_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key <- decode.optional_field(
    "SSECustomerKey",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use upload_id <- decode.optional_field(
    "UploadId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(UploadPartCopyRequest(
    bucket: bucket,
    copy_source: copy_source,
    copy_source_if_match: copy_source_if_match,
    copy_source_if_modified_since: copy_source_if_modified_since,
    copy_source_if_none_match: copy_source_if_none_match,
    copy_source_if_unmodified_since: copy_source_if_unmodified_since,
    copy_source_range: copy_source_range,
    copy_source_sse_customer_algorithm: copy_source_sse_customer_algorithm,
    copy_source_sse_customer_key: copy_source_sse_customer_key,
    copy_source_sse_customer_key_md5: copy_source_sse_customer_key_md5,
    expected_bucket_owner: expected_bucket_owner,
    expected_source_bucket_owner: expected_source_bucket_owner,
    key: key,
    part_number: part_number,
    request_payer: request_payer,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key: sse_customer_key,
    sse_customer_key_md5: sse_customer_key_md5,
    upload_id: upload_id,
  ))
}

pub type UploadPartCopyOutput {
  UploadPartCopyOutput(
    bucket_key_enabled: option.Option(Bool),
    copy_part_result: option.Option(CopyPartResult),
    copy_source_version_id: option.Option(String),
    request_charged: option.Option(RequestCharged),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
  )
}

pub fn encode_upload_part_copy_output_struct(
  input: UploadPartCopyOutput,
) -> json.Json {
  let pairs = []
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.copy_part_result {
    option.Some(v) -> [
      #("CopyPartResult", encode_copy_part_result_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.copy_source_version_id {
    option.Some(v) -> [#("CopySourceVersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_upload_part_copy_output_struct() -> decode.Decoder(
  UploadPartCopyOutput,
) {
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use copy_part_result <- decode.optional_field(
    "CopyPartResult",
    option.None,
    decode.optional(decode_copy_part_result_struct()),
  )
  use copy_source_version_id <- decode.optional_field(
    "CopySourceVersionId",
    option.None,
    decode.optional(decode.string),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  decode.success(UploadPartCopyOutput(
    bucket_key_enabled: bucket_key_enabled,
    copy_part_result: copy_part_result,
    copy_source_version_id: copy_source_version_id,
    request_charged: request_charged,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key_md5: sse_customer_key_md5,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
  ))
}

pub type CopyPartResult {
  CopyPartResult(
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    e_tag: option.Option(String),
    last_modified: option.Option(Int),
  )
}

pub fn encode_copy_part_result_struct(input: CopyPartResult) -> json.Json {
  let pairs = []
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_copy_part_result_struct() -> decode.Decoder(CopyPartResult) {
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  decode.success(CopyPartResult(
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    e_tag: e_tag,
    last_modified: last_modified,
  ))
}

pub type WriteGetObjectResponseRequest {
  WriteGetObjectResponseRequest(
    accept_ranges: option.Option(String),
    body: option.Option(BitArray),
    bucket_key_enabled: option.Option(Bool),
    cache_control: option.Option(String),
    checksum_crc32: option.Option(String),
    checksum_crc32_c: option.Option(String),
    checksum_crc64_nvme: option.Option(String),
    checksum_md5: option.Option(String),
    checksum_sha1: option.Option(String),
    checksum_sha256: option.Option(String),
    checksum_sha512: option.Option(String),
    checksum_xxhash128: option.Option(String),
    checksum_xxhash3: option.Option(String),
    checksum_xxhash64: option.Option(String),
    content_disposition: option.Option(String),
    content_encoding: option.Option(String),
    content_language: option.Option(String),
    content_length: option.Option(Int),
    content_range: option.Option(String),
    content_type: option.Option(String),
    delete_marker: option.Option(Bool),
    e_tag: option.Option(String),
    error_code: option.Option(String),
    error_message: option.Option(String),
    expiration: option.Option(String),
    expires: option.Option(String),
    last_modified: option.Option(Int),
    metadata: option.Option(dict.Dict(String, String)),
    missing_meta: option.Option(Int),
    object_lock_legal_hold_status: option.Option(ObjectLockLegalHoldStatus),
    object_lock_mode: option.Option(ObjectLockMode),
    object_lock_retain_until_date: option.Option(Int),
    parts_count: option.Option(Int),
    replication_status: option.Option(ReplicationStatus),
    request_charged: option.Option(RequestCharged),
    request_route: option.Option(String),
    request_token: option.Option(String),
    restore: option.Option(String),
    sse_customer_algorithm: option.Option(String),
    sse_customer_key_md5: option.Option(String),
    ssekms_key_id: option.Option(String),
    server_side_encryption: option.Option(ServerSideEncryption),
    status_code: option.Option(Int),
    storage_class: option.Option(StorageClass),
    tag_count: option.Option(Int),
    version_id: option.Option(String),
  )
}

pub fn encode_write_get_object_response_request_struct(
  input: WriteGetObjectResponseRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.accept_ranges {
    option.Some(v) -> [#("AcceptRanges", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.body {
    option.Some(v) -> [
      #("Body", fn(b) { json.string(bit_array.base64_encode(b, True)) }(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.bucket_key_enabled {
    option.Some(v) -> [#("BucketKeyEnabled", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.cache_control {
    option.Some(v) -> [#("CacheControl", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32 {
    option.Some(v) -> [#("ChecksumCRC32", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc32_c {
    option.Some(v) -> [#("ChecksumCRC32C", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_crc64_nvme {
    option.Some(v) -> [#("ChecksumCRC64NVME", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_md5 {
    option.Some(v) -> [#("ChecksumMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha1 {
    option.Some(v) -> [#("ChecksumSHA1", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha256 {
    option.Some(v) -> [#("ChecksumSHA256", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_sha512 {
    option.Some(v) -> [#("ChecksumSHA512", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash128 {
    option.Some(v) -> [#("ChecksumXXHASH128", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash3 {
    option.Some(v) -> [#("ChecksumXXHASH3", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.checksum_xxhash64 {
    option.Some(v) -> [#("ChecksumXXHASH64", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_disposition {
    option.Some(v) -> [#("ContentDisposition", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_encoding {
    option.Some(v) -> [#("ContentEncoding", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_language {
    option.Some(v) -> [#("ContentLanguage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_length {
    option.Some(v) -> [#("ContentLength", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_range {
    option.Some(v) -> [#("ContentRange", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.content_type {
    option.Some(v) -> [#("ContentType", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.delete_marker {
    option.Some(v) -> [#("DeleteMarker", json.bool(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.e_tag {
    option.Some(v) -> [#("ETag", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.error_code {
    option.Some(v) -> [#("ErrorCode", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.error_message {
    option.Some(v) -> [#("ErrorMessage", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expiration {
    option.Some(v) -> [#("Expiration", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expires {
    option.Some(v) -> [#("Expires", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.last_modified {
    option.Some(v) -> [#("LastModified", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.metadata {
    option.Some(v) -> [
      #(
        "Metadata",
        fn(d) {
          json.object(
            dict.to_list(d)
            |> list.map(fn(pair) { #(pair.0, json.string(pair.1)) }),
          )
        }(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.missing_meta {
    option.Some(v) -> [#("MissingMeta", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.object_lock_legal_hold_status {
    option.Some(v) -> [
      #(
        "ObjectLockLegalHoldStatus",
        encode_object_lock_legal_hold_status_enum(v),
      ),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_mode {
    option.Some(v) -> [
      #("ObjectLockMode", encode_object_lock_mode_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.object_lock_retain_until_date {
    option.Some(v) -> [#("ObjectLockRetainUntilDate", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.parts_count {
    option.Some(v) -> [#("PartsCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.replication_status {
    option.Some(v) -> [
      #("ReplicationStatus", encode_replication_status_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_charged {
    option.Some(v) -> [
      #("RequestCharged", encode_request_charged_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_route {
    option.Some(v) -> [#("RequestRoute", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.request_token {
    option.Some(v) -> [#("RequestToken", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.restore {
    option.Some(v) -> [#("Restore", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_algorithm {
    option.Some(v) -> [#("SSECustomerAlgorithm", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.sse_customer_key_md5 {
    option.Some(v) -> [#("SSECustomerKeyMD5", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.ssekms_key_id {
    option.Some(v) -> [#("SSEKMSKeyId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.server_side_encryption {
    option.Some(v) -> [
      #("ServerSideEncryption", encode_server_side_encryption_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.status_code {
    option.Some(v) -> [#("StatusCode", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.storage_class {
    option.Some(v) -> [#("StorageClass", encode_storage_class_enum(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.tag_count {
    option.Some(v) -> [#("TagCount", json.int(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.version_id {
    option.Some(v) -> [#("VersionId", json.string(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn decode_write_get_object_response_request_struct() -> decode.Decoder(
  WriteGetObjectResponseRequest,
) {
  use accept_ranges <- decode.optional_field(
    "AcceptRanges",
    option.None,
    decode.optional(decode.string),
  )
  use body <- decode.optional_field(
    "Body",
    option.None,
    decode.optional(
      decode.then(decode.string, fn(s) {
        decode.success(bit_array.from_string(s))
      }),
    ),
  )
  use bucket_key_enabled <- decode.optional_field(
    "BucketKeyEnabled",
    option.None,
    decode.optional(decode.bool),
  )
  use cache_control <- decode.optional_field(
    "CacheControl",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32 <- decode.optional_field(
    "ChecksumCRC32",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc32_c <- decode.optional_field(
    "ChecksumCRC32C",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_crc64_nvme <- decode.optional_field(
    "ChecksumCRC64NVME",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_md5 <- decode.optional_field(
    "ChecksumMD5",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha1 <- decode.optional_field(
    "ChecksumSHA1",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha256 <- decode.optional_field(
    "ChecksumSHA256",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_sha512 <- decode.optional_field(
    "ChecksumSHA512",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash128 <- decode.optional_field(
    "ChecksumXXHASH128",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash3 <- decode.optional_field(
    "ChecksumXXHASH3",
    option.None,
    decode.optional(decode.string),
  )
  use checksum_xxhash64 <- decode.optional_field(
    "ChecksumXXHASH64",
    option.None,
    decode.optional(decode.string),
  )
  use content_disposition <- decode.optional_field(
    "ContentDisposition",
    option.None,
    decode.optional(decode.string),
  )
  use content_encoding <- decode.optional_field(
    "ContentEncoding",
    option.None,
    decode.optional(decode.string),
  )
  use content_language <- decode.optional_field(
    "ContentLanguage",
    option.None,
    decode.optional(decode.string),
  )
  use content_length <- decode.optional_field(
    "ContentLength",
    option.None,
    decode.optional(decode.int),
  )
  use content_range <- decode.optional_field(
    "ContentRange",
    option.None,
    decode.optional(decode.string),
  )
  use content_type <- decode.optional_field(
    "ContentType",
    option.None,
    decode.optional(decode.string),
  )
  use delete_marker <- decode.optional_field(
    "DeleteMarker",
    option.None,
    decode.optional(decode.bool),
  )
  use e_tag <- decode.optional_field(
    "ETag",
    option.None,
    decode.optional(decode.string),
  )
  use error_code <- decode.optional_field(
    "ErrorCode",
    option.None,
    decode.optional(decode.string),
  )
  use error_message <- decode.optional_field(
    "ErrorMessage",
    option.None,
    decode.optional(decode.string),
  )
  use expiration <- decode.optional_field(
    "Expiration",
    option.None,
    decode.optional(decode.string),
  )
  use expires <- decode.optional_field(
    "Expires",
    option.None,
    decode.optional(decode.string),
  )
  use last_modified <- decode.optional_field(
    "LastModified",
    option.None,
    decode.optional(decode.int),
  )
  use metadata <- decode.optional_field(
    "Metadata",
    option.None,
    decode.optional(decode.dict(decode.string, decode.string)),
  )
  use missing_meta <- decode.optional_field(
    "MissingMeta",
    option.None,
    decode.optional(decode.int),
  )
  use object_lock_legal_hold_status <- decode.optional_field(
    "ObjectLockLegalHoldStatus",
    option.None,
    decode.optional(decode_object_lock_legal_hold_status_enum()),
  )
  use object_lock_mode <- decode.optional_field(
    "ObjectLockMode",
    option.None,
    decode.optional(decode_object_lock_mode_enum()),
  )
  use object_lock_retain_until_date <- decode.optional_field(
    "ObjectLockRetainUntilDate",
    option.None,
    decode.optional(decode.int),
  )
  use parts_count <- decode.optional_field(
    "PartsCount",
    option.None,
    decode.optional(decode.int),
  )
  use replication_status <- decode.optional_field(
    "ReplicationStatus",
    option.None,
    decode.optional(decode_replication_status_enum()),
  )
  use request_charged <- decode.optional_field(
    "RequestCharged",
    option.None,
    decode.optional(decode_request_charged_enum()),
  )
  use request_route <- decode.optional_field(
    "RequestRoute",
    option.None,
    decode.optional(decode.string),
  )
  use request_token <- decode.optional_field(
    "RequestToken",
    option.None,
    decode.optional(decode.string),
  )
  use restore <- decode.optional_field(
    "Restore",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_algorithm <- decode.optional_field(
    "SSECustomerAlgorithm",
    option.None,
    decode.optional(decode.string),
  )
  use sse_customer_key_md5 <- decode.optional_field(
    "SSECustomerKeyMD5",
    option.None,
    decode.optional(decode.string),
  )
  use ssekms_key_id <- decode.optional_field(
    "SSEKMSKeyId",
    option.None,
    decode.optional(decode.string),
  )
  use server_side_encryption <- decode.optional_field(
    "ServerSideEncryption",
    option.None,
    decode.optional(decode_server_side_encryption_enum()),
  )
  use status_code <- decode.optional_field(
    "StatusCode",
    option.None,
    decode.optional(decode.int),
  )
  use storage_class <- decode.optional_field(
    "StorageClass",
    option.None,
    decode.optional(decode_storage_class_enum()),
  )
  use tag_count <- decode.optional_field(
    "TagCount",
    option.None,
    decode.optional(decode.int),
  )
  use version_id <- decode.optional_field(
    "VersionId",
    option.None,
    decode.optional(decode.string),
  )
  decode.success(WriteGetObjectResponseRequest(
    accept_ranges: accept_ranges,
    body: body,
    bucket_key_enabled: bucket_key_enabled,
    cache_control: cache_control,
    checksum_crc32: checksum_crc32,
    checksum_crc32_c: checksum_crc32_c,
    checksum_crc64_nvme: checksum_crc64_nvme,
    checksum_md5: checksum_md5,
    checksum_sha1: checksum_sha1,
    checksum_sha256: checksum_sha256,
    checksum_sha512: checksum_sha512,
    checksum_xxhash128: checksum_xxhash128,
    checksum_xxhash3: checksum_xxhash3,
    checksum_xxhash64: checksum_xxhash64,
    content_disposition: content_disposition,
    content_encoding: content_encoding,
    content_language: content_language,
    content_length: content_length,
    content_range: content_range,
    content_type: content_type,
    delete_marker: delete_marker,
    e_tag: e_tag,
    error_code: error_code,
    error_message: error_message,
    expiration: expiration,
    expires: expires,
    last_modified: last_modified,
    metadata: metadata,
    missing_meta: missing_meta,
    object_lock_legal_hold_status: object_lock_legal_hold_status,
    object_lock_mode: object_lock_mode,
    object_lock_retain_until_date: object_lock_retain_until_date,
    parts_count: parts_count,
    replication_status: replication_status,
    request_charged: request_charged,
    request_route: request_route,
    request_token: request_token,
    restore: restore,
    sse_customer_algorithm: sse_customer_algorithm,
    sse_customer_key_md5: sse_customer_key_md5,
    ssekms_key_id: ssekms_key_id,
    server_side_encryption: server_side_encryption,
    status_code: status_code,
    storage_class: storage_class,
    tag_count: tag_count,
    version_id: version_id,
  ))
}

pub fn encode_abort_multipart_upload_input(
  input: AbortMultipartUploadRequest,
) -> String {
  json.to_string(encode_abort_multipart_upload_request_struct(input))
}

pub fn decode_abort_multipart_upload_input(
  body: String,
) -> Result(AbortMultipartUploadRequest, String) {
  case json.parse(body, decode_abort_multipart_upload_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_abort_multipart_upload_output(
  body: String,
) -> Result(AbortMultipartUploadOutput, String) {
  case json.parse(body, decode_abort_multipart_upload_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_abort_multipart_upload_body(
  _input: AbortMultipartUploadRequest,
) -> json.Json {
  json.object([])
}

pub fn build_abort_multipart_upload_request(
  input: AbortMultipartUploadRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?x-id=AbortMultipartUpload"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.upload_id {
    option.Some(v) -> rest.add_query(query, "uploadId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.if_match_initiated_time {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-if-match-initiated-time",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_abort_multipart_upload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(AbortMultipartUploadOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_abort_multipart_upload_output("{}")
        _ -> decode_abort_multipart_upload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_complete_multipart_upload_input(
  input: CompleteMultipartUploadRequest,
) -> String {
  json.to_string(encode_complete_multipart_upload_request_struct(input))
}

pub fn decode_complete_multipart_upload_input(
  body: String,
) -> Result(CompleteMultipartUploadRequest, String) {
  case json.parse(body, decode_complete_multipart_upload_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_complete_multipart_upload_output(
  body: String,
) -> Result(CompleteMultipartUploadOutput, String) {
  case json.parse(body, decode_complete_multipart_upload_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_complete_multipart_upload_body(
  _input: CompleteMultipartUploadRequest,
) -> json.Json {
  json.object([])
}

pub fn build_complete_multipart_upload_request(
  input: CompleteMultipartUploadRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.upload_id {
    option.Some(v) -> rest.add_query(query, "uploadId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.checksum_crc32 {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-checksum-crc32", v)
    option.None -> headers
  }
  let headers = case input.checksum_crc32_c {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-checksum-crc32c", v)
    option.None -> headers
  }
  let headers = case input.checksum_crc64_nvme {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-checksum-crc64nvme", v)
    option.None -> headers
  }
  let headers = case input.checksum_md5 {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-checksum-md5", v)
    option.None -> headers
  }
  let headers = case input.checksum_sha1 {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-checksum-sha1", v)
    option.None -> headers
  }
  let headers = case input.checksum_sha256 {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-checksum-sha256", v)
    option.None -> headers
  }
  let headers = case input.checksum_sha512 {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-checksum-sha512", v)
    option.None -> headers
  }
  let headers = case input.checksum_type {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-checksum-type",
        rest.enum_wire_value(encode_checksum_type_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.checksum_xxhash128 {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-checksum-xxhash128", v)
    option.None -> headers
  }
  let headers = case input.checksum_xxhash3 {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-checksum-xxhash3", v)
    option.None -> headers
  }
  let headers = case input.checksum_xxhash64 {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-checksum-xxhash64", v)
    option.None -> headers
  }
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.if_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-Match", v)
    option.None -> headers
  }
  let headers = case input.if_none_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-None-Match", v)
    option.None -> headers
  }
  let headers = case input.mpu_object_size {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-mp-object-size",
        rest.int_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let body = case input.multipart_upload {
    option.Some(v) ->
      bit_array.from_string(
        json.to_string(encode_completed_multipart_upload_struct(v)),
      )
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_complete_multipart_upload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CompleteMultipartUploadOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_complete_multipart_upload_output("{}")
        _ -> decode_complete_multipart_upload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_copy_object_input(input: CopyObjectRequest) -> String {
  json.to_string(encode_copy_object_request_struct(input))
}

pub fn decode_copy_object_input(
  body: String,
) -> Result(CopyObjectRequest, String) {
  case json.parse(body, decode_copy_object_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_copy_object_output(
  body: String,
) -> Result(CopyObjectOutput, String) {
  case json.parse(body, decode_copy_object_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_copy_object_body(_input: CopyObjectRequest) -> json.Json {
  json.object([])
}

pub fn build_copy_object_request(
  input: CopyObjectRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?x-id=CopyObject"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.acl {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-acl",
        rest.enum_wire_value(encode_object_canned_acl_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.bucket_key_enabled {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-bucket-key-enabled",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.cache_control {
    option.Some(v) -> rest.maybe_set_header(headers, "Cache-Control", v)
    option.None -> headers
  }
  let headers = case input.checksum_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-checksum-algorithm",
        rest.enum_wire_value(encode_checksum_algorithm_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.content_disposition {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Disposition", v)
    option.None -> headers
  }
  let headers = case input.content_encoding {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Encoding", v)
    option.None -> headers
  }
  let headers = case input.content_language {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Language", v)
    option.None -> headers
  }
  let headers = case input.content_type {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Type", v)
    option.None -> headers
  }
  let headers = case input.copy_source {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-copy-source", v)
    option.None -> headers
  }
  let headers = case input.copy_source_if_match {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-copy-source-if-match", v)
    option.None -> headers
  }
  let headers = case input.copy_source_if_modified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-if-modified-since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.copy_source_if_none_match {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-copy-source-if-none-match", v)
    option.None -> headers
  }
  let headers = case input.copy_source_if_unmodified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-if-unmodified-since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.copy_source_sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.copy_source_sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.copy_source_sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.expected_source_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-source-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.expires {
    option.Some(v) -> rest.maybe_set_header(headers, "Expires", v)
    option.None -> headers
  }
  let headers = case input.grant_full_control {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-grant-full-control", v)
    option.None -> headers
  }
  let headers = case input.grant_read {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-read", v)
    option.None -> headers
  }
  let headers = case input.grant_read_acp {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-read-acp", v)
    option.None -> headers
  }
  let headers = case input.grant_write_acp {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-write-acp", v)
    option.None -> headers
  }
  let headers = case input.if_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-Match", v)
    option.None -> headers
  }
  let headers = case input.if_none_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-None-Match", v)
    option.None -> headers
  }
  let headers = case input.metadata_directive {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-metadata-directive",
        rest.enum_wire_value(encode_metadata_directive_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_legal_hold_status {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-object-lock-legal-hold",
        rest.enum_wire_value(encode_object_lock_legal_hold_status_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_mode {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-object-lock-mode",
        rest.enum_wire_value(encode_object_lock_mode_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_retain_until_date {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-object-lock-retain-until-date",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let headers = case input.ssekms_encryption_context {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-server-side-encryption-context", v)
    option.None -> headers
  }
  let headers = case input.ssekms_key_id {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-aws-kms-key-id",
        v,
      )
    option.None -> headers
  }
  let headers = case input.server_side_encryption {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption",
        rest.enum_wire_value(encode_server_side_encryption_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.storage_class {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-storage-class",
        rest.enum_wire_value(encode_storage_class_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.tagging {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-tagging", v)
    option.None -> headers
  }
  let headers = case input.tagging_directive {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-tagging-directive",
        rest.enum_wire_value(encode_tagging_directive_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.website_redirect_location {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-website-redirect-location", v)
    option.None -> headers
  }
  let headers = case input.metadata {
    option.Some(m) -> rest.add_prefix_headers(headers, "x-amz-meta-", m)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_copy_object_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CopyObjectOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_copy_object_output("{}")
        _ -> decode_copy_object_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_create_bucket_input(input: CreateBucketRequest) -> String {
  json.to_string(encode_create_bucket_request_struct(input))
}

pub fn decode_create_bucket_input(
  body: String,
) -> Result(CreateBucketRequest, String) {
  case json.parse(body, decode_create_bucket_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_create_bucket_output(
  body: String,
) -> Result(CreateBucketOutput, String) {
  case json.parse(body, decode_create_bucket_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_create_bucket_body(_input: CreateBucketRequest) -> json.Json {
  json.object([])
}

pub fn build_create_bucket_request(
  input: CreateBucketRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.acl {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-acl",
        rest.enum_wire_value(encode_bucket_canned_acl_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.bucket_namespace {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-bucket-namespace",
        rest.enum_wire_value(encode_bucket_namespace_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.grant_full_control {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-grant-full-control", v)
    option.None -> headers
  }
  let headers = case input.grant_read {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-read", v)
    option.None -> headers
  }
  let headers = case input.grant_read_acp {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-read-acp", v)
    option.None -> headers
  }
  let headers = case input.grant_write {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-write", v)
    option.None -> headers
  }
  let headers = case input.grant_write_acp {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-write-acp", v)
    option.None -> headers
  }
  let headers = case input.object_lock_enabled_for_bucket {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-bucket-object-lock-enabled",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.object_ownership {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-object-ownership",
        rest.enum_wire_value(encode_object_ownership_enum(v)),
      )
    option.None -> headers
  }
  let body = case input.create_bucket_configuration {
    option.Some(v) ->
      bit_array.from_string(
        json.to_string(encode_create_bucket_configuration_struct(v)),
      )
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_create_bucket_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CreateBucketOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_create_bucket_output("{}")
        _ -> decode_create_bucket_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_create_multipart_upload_input(
  input: CreateMultipartUploadRequest,
) -> String {
  json.to_string(encode_create_multipart_upload_request_struct(input))
}

pub fn decode_create_multipart_upload_input(
  body: String,
) -> Result(CreateMultipartUploadRequest, String) {
  case json.parse(body, decode_create_multipart_upload_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_create_multipart_upload_output(
  body: String,
) -> Result(CreateMultipartUploadOutput, String) {
  case json.parse(body, decode_create_multipart_upload_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_create_multipart_upload_body(
  _input: CreateMultipartUploadRequest,
) -> json.Json {
  json.object([])
}

pub fn build_create_multipart_upload_request(
  input: CreateMultipartUploadRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?uploads"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.acl {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-acl",
        rest.enum_wire_value(encode_object_canned_acl_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.bucket_key_enabled {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-bucket-key-enabled",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.cache_control {
    option.Some(v) -> rest.maybe_set_header(headers, "Cache-Control", v)
    option.None -> headers
  }
  let headers = case input.checksum_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-checksum-algorithm",
        rest.enum_wire_value(encode_checksum_algorithm_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.checksum_type {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-checksum-type",
        rest.enum_wire_value(encode_checksum_type_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.content_disposition {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Disposition", v)
    option.None -> headers
  }
  let headers = case input.content_encoding {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Encoding", v)
    option.None -> headers
  }
  let headers = case input.content_language {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Language", v)
    option.None -> headers
  }
  let headers = case input.content_type {
    option.Some(v) -> rest.maybe_set_header(headers, "Content-Type", v)
    option.None -> headers
  }
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.expires {
    option.Some(v) -> rest.maybe_set_header(headers, "Expires", v)
    option.None -> headers
  }
  let headers = case input.grant_full_control {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-grant-full-control", v)
    option.None -> headers
  }
  let headers = case input.grant_read {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-read", v)
    option.None -> headers
  }
  let headers = case input.grant_read_acp {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-read-acp", v)
    option.None -> headers
  }
  let headers = case input.grant_write_acp {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-grant-write-acp", v)
    option.None -> headers
  }
  let headers = case input.object_lock_legal_hold_status {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-object-lock-legal-hold",
        rest.enum_wire_value(encode_object_lock_legal_hold_status_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_mode {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-object-lock-mode",
        rest.enum_wire_value(encode_object_lock_mode_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_retain_until_date {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-object-lock-retain-until-date",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let headers = case input.ssekms_encryption_context {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-server-side-encryption-context", v)
    option.None -> headers
  }
  let headers = case input.ssekms_key_id {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-aws-kms-key-id",
        v,
      )
    option.None -> headers
  }
  let headers = case input.server_side_encryption {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption",
        rest.enum_wire_value(encode_server_side_encryption_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.storage_class {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-storage-class",
        rest.enum_wire_value(encode_storage_class_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.tagging {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-tagging", v)
    option.None -> headers
  }
  let headers = case input.website_redirect_location {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-website-redirect-location", v)
    option.None -> headers
  }
  let headers = case input.metadata {
    option.Some(m) -> rest.add_prefix_headers(headers, "x-amz-meta-", m)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_create_multipart_upload_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CreateMultipartUploadOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_create_multipart_upload_output("{}")
        _ -> decode_create_multipart_upload_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_create_session_input(input: CreateSessionRequest) -> String {
  json.to_string(encode_create_session_request_struct(input))
}

pub fn decode_create_session_input(
  body: String,
) -> Result(CreateSessionRequest, String) {
  case json.parse(body, decode_create_session_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_create_session_output(
  body: String,
) -> Result(CreateSessionOutput, String) {
  case json.parse(body, decode_create_session_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_create_session_body(_input: CreateSessionRequest) -> json.Json {
  json.object([])
}

pub fn build_create_session_request(
  input: CreateSessionRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?session"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.bucket_key_enabled {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-bucket-key-enabled",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.ssekms_encryption_context {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-server-side-encryption-context", v)
    option.None -> headers
  }
  let headers = case input.ssekms_key_id {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-aws-kms-key-id",
        v,
      )
    option.None -> headers
  }
  let headers = case input.server_side_encryption {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption",
        rest.enum_wire_value(encode_server_side_encryption_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.session_mode {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-create-session-mode",
        rest.enum_wire_value(encode_session_mode_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_create_session_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(CreateSessionOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_create_session_output("{}")
        _ -> decode_create_session_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketOutput {
  DeleteBucketOutput
}

pub fn encode_delete_bucket_output_struct(_v: DeleteBucketOutput) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_output_struct() -> decode.Decoder(
  DeleteBucketOutput,
) {
  decode.success(DeleteBucketOutput)
}

pub fn encode_delete_bucket_input(input: DeleteBucketRequest) -> String {
  json.to_string(encode_delete_bucket_request_struct(input))
}

pub fn decode_delete_bucket_input(
  body: String,
) -> Result(DeleteBucketRequest, String) {
  case json.parse(body, decode_delete_bucket_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_output(
  body: String,
) -> Result(DeleteBucketOutput, String) {
  case json.parse(body, decode_delete_bucket_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_body(_input: DeleteBucketRequest) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_request(
  input: DeleteBucketRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_output("{}")
        _ -> decode_delete_bucket_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketAnalyticsConfigurationOutput {
  DeleteBucketAnalyticsConfigurationOutput
}

pub fn encode_delete_bucket_analytics_configuration_output_struct(
  _v: DeleteBucketAnalyticsConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_analytics_configuration_output_struct() -> decode.Decoder(
  DeleteBucketAnalyticsConfigurationOutput,
) {
  decode.success(DeleteBucketAnalyticsConfigurationOutput)
}

pub fn encode_delete_bucket_analytics_configuration_input(
  input: DeleteBucketAnalyticsConfigurationRequest,
) -> String {
  json.to_string(encode_delete_bucket_analytics_configuration_request_struct(
    input,
  ))
}

pub fn decode_delete_bucket_analytics_configuration_input(
  body: String,
) -> Result(DeleteBucketAnalyticsConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_analytics_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_analytics_configuration_output(
  body: String,
) -> Result(DeleteBucketAnalyticsConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_analytics_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_analytics_configuration_body(
  _input: DeleteBucketAnalyticsConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_analytics_configuration_request(
  input: DeleteBucketAnalyticsConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?analytics"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_analytics_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketAnalyticsConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_analytics_configuration_output("{}")
        _ -> decode_delete_bucket_analytics_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketCorsOutput {
  DeleteBucketCorsOutput
}

pub fn encode_delete_bucket_cors_output_struct(
  _v: DeleteBucketCorsOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_cors_output_struct() -> decode.Decoder(
  DeleteBucketCorsOutput,
) {
  decode.success(DeleteBucketCorsOutput)
}

pub fn encode_delete_bucket_cors_input(
  input: DeleteBucketCorsRequest,
) -> String {
  json.to_string(encode_delete_bucket_cors_request_struct(input))
}

pub fn decode_delete_bucket_cors_input(
  body: String,
) -> Result(DeleteBucketCorsRequest, String) {
  case json.parse(body, decode_delete_bucket_cors_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_cors_output(
  body: String,
) -> Result(DeleteBucketCorsOutput, String) {
  case json.parse(body, decode_delete_bucket_cors_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_cors_body(
  _input: DeleteBucketCorsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_cors_request(
  input: DeleteBucketCorsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?cors"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_cors_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketCorsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_cors_output("{}")
        _ -> decode_delete_bucket_cors_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketEncryptionOutput {
  DeleteBucketEncryptionOutput
}

pub fn encode_delete_bucket_encryption_output_struct(
  _v: DeleteBucketEncryptionOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_encryption_output_struct() -> decode.Decoder(
  DeleteBucketEncryptionOutput,
) {
  decode.success(DeleteBucketEncryptionOutput)
}

pub fn encode_delete_bucket_encryption_input(
  input: DeleteBucketEncryptionRequest,
) -> String {
  json.to_string(encode_delete_bucket_encryption_request_struct(input))
}

pub fn decode_delete_bucket_encryption_input(
  body: String,
) -> Result(DeleteBucketEncryptionRequest, String) {
  case json.parse(body, decode_delete_bucket_encryption_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_encryption_output(
  body: String,
) -> Result(DeleteBucketEncryptionOutput, String) {
  case json.parse(body, decode_delete_bucket_encryption_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_encryption_body(
  _input: DeleteBucketEncryptionRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_encryption_request(
  input: DeleteBucketEncryptionRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?encryption"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_encryption_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketEncryptionOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_encryption_output("{}")
        _ -> decode_delete_bucket_encryption_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketIntelligentTieringConfigurationOutput {
  DeleteBucketIntelligentTieringConfigurationOutput
}

pub fn encode_delete_bucket_intelligent_tiering_configuration_output_struct(
  _v: DeleteBucketIntelligentTieringConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_intelligent_tiering_configuration_output_struct() -> decode.Decoder(
  DeleteBucketIntelligentTieringConfigurationOutput,
) {
  decode.success(DeleteBucketIntelligentTieringConfigurationOutput)
}

pub fn encode_delete_bucket_intelligent_tiering_configuration_input(
  input: DeleteBucketIntelligentTieringConfigurationRequest,
) -> String {
  json.to_string(
    encode_delete_bucket_intelligent_tiering_configuration_request_struct(input),
  )
}

pub fn decode_delete_bucket_intelligent_tiering_configuration_input(
  body: String,
) -> Result(DeleteBucketIntelligentTieringConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_intelligent_tiering_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_intelligent_tiering_configuration_output(
  body: String,
) -> Result(DeleteBucketIntelligentTieringConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_intelligent_tiering_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_intelligent_tiering_configuration_body(
  _input: DeleteBucketIntelligentTieringConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_intelligent_tiering_configuration_request(
  input: DeleteBucketIntelligentTieringConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?intelligent-tiering"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_intelligent_tiering_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketIntelligentTieringConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" ->
          decode_delete_bucket_intelligent_tiering_configuration_output("{}")
        _ -> decode_delete_bucket_intelligent_tiering_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketInventoryConfigurationOutput {
  DeleteBucketInventoryConfigurationOutput
}

pub fn encode_delete_bucket_inventory_configuration_output_struct(
  _v: DeleteBucketInventoryConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_inventory_configuration_output_struct() -> decode.Decoder(
  DeleteBucketInventoryConfigurationOutput,
) {
  decode.success(DeleteBucketInventoryConfigurationOutput)
}

pub fn encode_delete_bucket_inventory_configuration_input(
  input: DeleteBucketInventoryConfigurationRequest,
) -> String {
  json.to_string(encode_delete_bucket_inventory_configuration_request_struct(
    input,
  ))
}

pub fn decode_delete_bucket_inventory_configuration_input(
  body: String,
) -> Result(DeleteBucketInventoryConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_inventory_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_inventory_configuration_output(
  body: String,
) -> Result(DeleteBucketInventoryConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_inventory_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_inventory_configuration_body(
  _input: DeleteBucketInventoryConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_inventory_configuration_request(
  input: DeleteBucketInventoryConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?inventory"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_inventory_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketInventoryConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_inventory_configuration_output("{}")
        _ -> decode_delete_bucket_inventory_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketLifecycleOutput {
  DeleteBucketLifecycleOutput
}

pub fn encode_delete_bucket_lifecycle_output_struct(
  _v: DeleteBucketLifecycleOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_lifecycle_output_struct() -> decode.Decoder(
  DeleteBucketLifecycleOutput,
) {
  decode.success(DeleteBucketLifecycleOutput)
}

pub fn encode_delete_bucket_lifecycle_input(
  input: DeleteBucketLifecycleRequest,
) -> String {
  json.to_string(encode_delete_bucket_lifecycle_request_struct(input))
}

pub fn decode_delete_bucket_lifecycle_input(
  body: String,
) -> Result(DeleteBucketLifecycleRequest, String) {
  case json.parse(body, decode_delete_bucket_lifecycle_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_lifecycle_output(
  body: String,
) -> Result(DeleteBucketLifecycleOutput, String) {
  case json.parse(body, decode_delete_bucket_lifecycle_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_lifecycle_body(
  _input: DeleteBucketLifecycleRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_lifecycle_request(
  input: DeleteBucketLifecycleRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?lifecycle"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_lifecycle_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketLifecycleOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_lifecycle_output("{}")
        _ -> decode_delete_bucket_lifecycle_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketMetadataConfigurationOutput {
  DeleteBucketMetadataConfigurationOutput
}

pub fn encode_delete_bucket_metadata_configuration_output_struct(
  _v: DeleteBucketMetadataConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_metadata_configuration_output_struct() -> decode.Decoder(
  DeleteBucketMetadataConfigurationOutput,
) {
  decode.success(DeleteBucketMetadataConfigurationOutput)
}

pub fn encode_delete_bucket_metadata_configuration_input(
  input: DeleteBucketMetadataConfigurationRequest,
) -> String {
  json.to_string(encode_delete_bucket_metadata_configuration_request_struct(
    input,
  ))
}

pub fn decode_delete_bucket_metadata_configuration_input(
  body: String,
) -> Result(DeleteBucketMetadataConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_metadata_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_metadata_configuration_output(
  body: String,
) -> Result(DeleteBucketMetadataConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_metadata_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_metadata_configuration_body(
  _input: DeleteBucketMetadataConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_metadata_configuration_request(
  input: DeleteBucketMetadataConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metadataConfiguration"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_metadata_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketMetadataConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_metadata_configuration_output("{}")
        _ -> decode_delete_bucket_metadata_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketMetadataTableConfigurationOutput {
  DeleteBucketMetadataTableConfigurationOutput
}

pub fn encode_delete_bucket_metadata_table_configuration_output_struct(
  _v: DeleteBucketMetadataTableConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_metadata_table_configuration_output_struct() -> decode.Decoder(
  DeleteBucketMetadataTableConfigurationOutput,
) {
  decode.success(DeleteBucketMetadataTableConfigurationOutput)
}

pub fn encode_delete_bucket_metadata_table_configuration_input(
  input: DeleteBucketMetadataTableConfigurationRequest,
) -> String {
  json.to_string(
    encode_delete_bucket_metadata_table_configuration_request_struct(input),
  )
}

pub fn decode_delete_bucket_metadata_table_configuration_input(
  body: String,
) -> Result(DeleteBucketMetadataTableConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_metadata_table_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_metadata_table_configuration_output(
  body: String,
) -> Result(DeleteBucketMetadataTableConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_metadata_table_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_metadata_table_configuration_body(
  _input: DeleteBucketMetadataTableConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_metadata_table_configuration_request(
  input: DeleteBucketMetadataTableConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metadataTable"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_metadata_table_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketMetadataTableConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_metadata_table_configuration_output("{}")
        _ -> decode_delete_bucket_metadata_table_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketMetricsConfigurationOutput {
  DeleteBucketMetricsConfigurationOutput
}

pub fn encode_delete_bucket_metrics_configuration_output_struct(
  _v: DeleteBucketMetricsConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_metrics_configuration_output_struct() -> decode.Decoder(
  DeleteBucketMetricsConfigurationOutput,
) {
  decode.success(DeleteBucketMetricsConfigurationOutput)
}

pub fn encode_delete_bucket_metrics_configuration_input(
  input: DeleteBucketMetricsConfigurationRequest,
) -> String {
  json.to_string(encode_delete_bucket_metrics_configuration_request_struct(
    input,
  ))
}

pub fn decode_delete_bucket_metrics_configuration_input(
  body: String,
) -> Result(DeleteBucketMetricsConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_delete_bucket_metrics_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_metrics_configuration_output(
  body: String,
) -> Result(DeleteBucketMetricsConfigurationOutput, String) {
  case
    json.parse(body, decode_delete_bucket_metrics_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_metrics_configuration_body(
  _input: DeleteBucketMetricsConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_metrics_configuration_request(
  input: DeleteBucketMetricsConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metrics"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_metrics_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketMetricsConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_metrics_configuration_output("{}")
        _ -> decode_delete_bucket_metrics_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketOwnershipControlsOutput {
  DeleteBucketOwnershipControlsOutput
}

pub fn encode_delete_bucket_ownership_controls_output_struct(
  _v: DeleteBucketOwnershipControlsOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_ownership_controls_output_struct() -> decode.Decoder(
  DeleteBucketOwnershipControlsOutput,
) {
  decode.success(DeleteBucketOwnershipControlsOutput)
}

pub fn encode_delete_bucket_ownership_controls_input(
  input: DeleteBucketOwnershipControlsRequest,
) -> String {
  json.to_string(encode_delete_bucket_ownership_controls_request_struct(input))
}

pub fn decode_delete_bucket_ownership_controls_input(
  body: String,
) -> Result(DeleteBucketOwnershipControlsRequest, String) {
  case
    json.parse(body, decode_delete_bucket_ownership_controls_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_ownership_controls_output(
  body: String,
) -> Result(DeleteBucketOwnershipControlsOutput, String) {
  case
    json.parse(body, decode_delete_bucket_ownership_controls_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_ownership_controls_body(
  _input: DeleteBucketOwnershipControlsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_ownership_controls_request(
  input: DeleteBucketOwnershipControlsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?ownershipControls"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_ownership_controls_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketOwnershipControlsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_ownership_controls_output("{}")
        _ -> decode_delete_bucket_ownership_controls_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketPolicyOutput {
  DeleteBucketPolicyOutput
}

pub fn encode_delete_bucket_policy_output_struct(
  _v: DeleteBucketPolicyOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_policy_output_struct() -> decode.Decoder(
  DeleteBucketPolicyOutput,
) {
  decode.success(DeleteBucketPolicyOutput)
}

pub fn encode_delete_bucket_policy_input(
  input: DeleteBucketPolicyRequest,
) -> String {
  json.to_string(encode_delete_bucket_policy_request_struct(input))
}

pub fn decode_delete_bucket_policy_input(
  body: String,
) -> Result(DeleteBucketPolicyRequest, String) {
  case json.parse(body, decode_delete_bucket_policy_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_policy_output(
  body: String,
) -> Result(DeleteBucketPolicyOutput, String) {
  case json.parse(body, decode_delete_bucket_policy_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_policy_body(
  _input: DeleteBucketPolicyRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_policy_request(
  input: DeleteBucketPolicyRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?policy"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_policy_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketPolicyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_policy_output("{}")
        _ -> decode_delete_bucket_policy_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketReplicationOutput {
  DeleteBucketReplicationOutput
}

pub fn encode_delete_bucket_replication_output_struct(
  _v: DeleteBucketReplicationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_replication_output_struct() -> decode.Decoder(
  DeleteBucketReplicationOutput,
) {
  decode.success(DeleteBucketReplicationOutput)
}

pub fn encode_delete_bucket_replication_input(
  input: DeleteBucketReplicationRequest,
) -> String {
  json.to_string(encode_delete_bucket_replication_request_struct(input))
}

pub fn decode_delete_bucket_replication_input(
  body: String,
) -> Result(DeleteBucketReplicationRequest, String) {
  case json.parse(body, decode_delete_bucket_replication_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_replication_output(
  body: String,
) -> Result(DeleteBucketReplicationOutput, String) {
  case json.parse(body, decode_delete_bucket_replication_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_replication_body(
  _input: DeleteBucketReplicationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_replication_request(
  input: DeleteBucketReplicationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?replication"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_replication_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketReplicationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_replication_output("{}")
        _ -> decode_delete_bucket_replication_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketTaggingOutput {
  DeleteBucketTaggingOutput
}

pub fn encode_delete_bucket_tagging_output_struct(
  _v: DeleteBucketTaggingOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_tagging_output_struct() -> decode.Decoder(
  DeleteBucketTaggingOutput,
) {
  decode.success(DeleteBucketTaggingOutput)
}

pub fn encode_delete_bucket_tagging_input(
  input: DeleteBucketTaggingRequest,
) -> String {
  json.to_string(encode_delete_bucket_tagging_request_struct(input))
}

pub fn decode_delete_bucket_tagging_input(
  body: String,
) -> Result(DeleteBucketTaggingRequest, String) {
  case json.parse(body, decode_delete_bucket_tagging_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_tagging_output(
  body: String,
) -> Result(DeleteBucketTaggingOutput, String) {
  case json.parse(body, decode_delete_bucket_tagging_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_tagging_body(
  _input: DeleteBucketTaggingRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_tagging_request(
  input: DeleteBucketTaggingRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?tagging"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_tagging_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketTaggingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_tagging_output("{}")
        _ -> decode_delete_bucket_tagging_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeleteBucketWebsiteOutput {
  DeleteBucketWebsiteOutput
}

pub fn encode_delete_bucket_website_output_struct(
  _v: DeleteBucketWebsiteOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_bucket_website_output_struct() -> decode.Decoder(
  DeleteBucketWebsiteOutput,
) {
  decode.success(DeleteBucketWebsiteOutput)
}

pub fn encode_delete_bucket_website_input(
  input: DeleteBucketWebsiteRequest,
) -> String {
  json.to_string(encode_delete_bucket_website_request_struct(input))
}

pub fn decode_delete_bucket_website_input(
  body: String,
) -> Result(DeleteBucketWebsiteRequest, String) {
  case json.parse(body, decode_delete_bucket_website_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_bucket_website_output(
  body: String,
) -> Result(DeleteBucketWebsiteOutput, String) {
  case json.parse(body, decode_delete_bucket_website_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_bucket_website_body(
  _input: DeleteBucketWebsiteRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_bucket_website_request(
  input: DeleteBucketWebsiteRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?website"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_bucket_website_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteBucketWebsiteOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_bucket_website_output("{}")
        _ -> decode_delete_bucket_website_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_delete_object_input(input: DeleteObjectRequest) -> String {
  json.to_string(encode_delete_object_request_struct(input))
}

pub fn decode_delete_object_input(
  body: String,
) -> Result(DeleteObjectRequest, String) {
  case json.parse(body, decode_delete_object_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_object_output(
  body: String,
) -> Result(DeleteObjectOutput, String) {
  case json.parse(body, decode_delete_object_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_object_body(_input: DeleteObjectRequest) -> json.Json {
  json.object([])
}

pub fn build_delete_object_request(
  input: DeleteObjectRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?x-id=DeleteObject"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.bypass_governance_retention {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-bypass-governance-retention",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.if_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-Match", v)
    option.None -> headers
  }
  let headers = case input.if_match_last_modified_time {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-if-match-last-modified-time",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.if_match_size {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-if-match-size",
        rest.int_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.mfa {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-mfa", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_object_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteObjectOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_object_output("{}")
        _ -> decode_delete_object_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_delete_object_tagging_input(
  input: DeleteObjectTaggingRequest,
) -> String {
  json.to_string(encode_delete_object_tagging_request_struct(input))
}

pub fn decode_delete_object_tagging_input(
  body: String,
) -> Result(DeleteObjectTaggingRequest, String) {
  case json.parse(body, decode_delete_object_tagging_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_object_tagging_output(
  body: String,
) -> Result(DeleteObjectTaggingOutput, String) {
  case json.parse(body, decode_delete_object_tagging_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_object_tagging_body(
  _input: DeleteObjectTaggingRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_object_tagging_request(
  input: DeleteObjectTaggingRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?tagging"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_object_tagging_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeleteObjectTaggingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_object_tagging_output("{}")
        _ -> decode_delete_object_tagging_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type DeletePublicAccessBlockOutput {
  DeletePublicAccessBlockOutput
}

pub fn encode_delete_public_access_block_output_struct(
  _v: DeletePublicAccessBlockOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_delete_public_access_block_output_struct() -> decode.Decoder(
  DeletePublicAccessBlockOutput,
) {
  decode.success(DeletePublicAccessBlockOutput)
}

pub fn encode_delete_public_access_block_input(
  input: DeletePublicAccessBlockRequest,
) -> String {
  json.to_string(encode_delete_public_access_block_request_struct(input))
}

pub fn decode_delete_public_access_block_input(
  body: String,
) -> Result(DeletePublicAccessBlockRequest, String) {
  case json.parse(body, decode_delete_public_access_block_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_delete_public_access_block_output(
  body: String,
) -> Result(DeletePublicAccessBlockOutput, String) {
  case json.parse(body, decode_delete_public_access_block_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_delete_public_access_block_body(
  _input: DeletePublicAccessBlockRequest,
) -> json.Json {
  json.object([])
}

pub fn build_delete_public_access_block_request(
  input: DeletePublicAccessBlockRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?publicAccessBlock"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("DELETE", path, headers, body)
}

pub fn parse_delete_public_access_block_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(DeletePublicAccessBlockOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_delete_public_access_block_output("{}")
        _ -> decode_delete_public_access_block_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_abac_input(input: GetBucketAbacRequest) -> String {
  json.to_string(encode_get_bucket_abac_request_struct(input))
}

pub fn decode_get_bucket_abac_input(
  body: String,
) -> Result(GetBucketAbacRequest, String) {
  case json.parse(body, decode_get_bucket_abac_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_abac_output(
  body: String,
) -> Result(GetBucketAbacOutput, String) {
  case json.parse(body, decode_get_bucket_abac_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_abac_body(_input: GetBucketAbacRequest) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_abac_request(
  input: GetBucketAbacRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?abac"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_abac_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketAbacOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_abac_output("{}")
        _ -> decode_get_bucket_abac_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_accelerate_configuration_input(
  input: GetBucketAccelerateConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_accelerate_configuration_request_struct(
    input,
  ))
}

pub fn decode_get_bucket_accelerate_configuration_input(
  body: String,
) -> Result(GetBucketAccelerateConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_get_bucket_accelerate_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_accelerate_configuration_output(
  body: String,
) -> Result(GetBucketAccelerateConfigurationOutput, String) {
  case
    json.parse(body, decode_get_bucket_accelerate_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_accelerate_configuration_body(
  _input: GetBucketAccelerateConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_accelerate_configuration_request(
  input: GetBucketAccelerateConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?accelerate"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_accelerate_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketAccelerateConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_accelerate_configuration_output("{}")
        _ -> decode_get_bucket_accelerate_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_acl_input(input: GetBucketAclRequest) -> String {
  json.to_string(encode_get_bucket_acl_request_struct(input))
}

pub fn decode_get_bucket_acl_input(
  body: String,
) -> Result(GetBucketAclRequest, String) {
  case json.parse(body, decode_get_bucket_acl_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_acl_output(
  body: String,
) -> Result(GetBucketAclOutput, String) {
  case json.parse(body, decode_get_bucket_acl_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_acl_body(_input: GetBucketAclRequest) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_acl_request(
  input: GetBucketAclRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?acl"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_acl_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketAclOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_acl_output("{}")
        _ -> decode_get_bucket_acl_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_analytics_configuration_input(
  input: GetBucketAnalyticsConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_analytics_configuration_request_struct(input))
}

pub fn decode_get_bucket_analytics_configuration_input(
  body: String,
) -> Result(GetBucketAnalyticsConfigurationRequest, String) {
  case
    json.parse(body, decode_get_bucket_analytics_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_analytics_configuration_output(
  body: String,
) -> Result(GetBucketAnalyticsConfigurationOutput, String) {
  case
    json.parse(body, decode_get_bucket_analytics_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_analytics_configuration_body(
  _input: GetBucketAnalyticsConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_analytics_configuration_request(
  input: GetBucketAnalyticsConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?analytics&x-id=GetBucketAnalyticsConfiguration"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_analytics_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketAnalyticsConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_analytics_configuration_output("{}")
        _ -> decode_get_bucket_analytics_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_cors_input(input: GetBucketCorsRequest) -> String {
  json.to_string(encode_get_bucket_cors_request_struct(input))
}

pub fn decode_get_bucket_cors_input(
  body: String,
) -> Result(GetBucketCorsRequest, String) {
  case json.parse(body, decode_get_bucket_cors_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_cors_output(
  body: String,
) -> Result(GetBucketCorsOutput, String) {
  case json.parse(body, decode_get_bucket_cors_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_cors_body(_input: GetBucketCorsRequest) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_cors_request(
  input: GetBucketCorsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?cors"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_cors_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketCorsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_cors_output("{}")
        _ -> decode_get_bucket_cors_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_encryption_input(
  input: GetBucketEncryptionRequest,
) -> String {
  json.to_string(encode_get_bucket_encryption_request_struct(input))
}

pub fn decode_get_bucket_encryption_input(
  body: String,
) -> Result(GetBucketEncryptionRequest, String) {
  case json.parse(body, decode_get_bucket_encryption_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_encryption_output(
  body: String,
) -> Result(GetBucketEncryptionOutput, String) {
  case json.parse(body, decode_get_bucket_encryption_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_encryption_body(
  _input: GetBucketEncryptionRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_encryption_request(
  input: GetBucketEncryptionRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?encryption"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_encryption_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketEncryptionOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_encryption_output("{}")
        _ -> decode_get_bucket_encryption_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_intelligent_tiering_configuration_input(
  input: GetBucketIntelligentTieringConfigurationRequest,
) -> String {
  json.to_string(
    encode_get_bucket_intelligent_tiering_configuration_request_struct(input),
  )
}

pub fn decode_get_bucket_intelligent_tiering_configuration_input(
  body: String,
) -> Result(GetBucketIntelligentTieringConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_get_bucket_intelligent_tiering_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_intelligent_tiering_configuration_output(
  body: String,
) -> Result(GetBucketIntelligentTieringConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_get_bucket_intelligent_tiering_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_intelligent_tiering_configuration_body(
  _input: GetBucketIntelligentTieringConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_intelligent_tiering_configuration_request(
  input: GetBucketIntelligentTieringConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path =
    "/{Bucket}?intelligent-tiering&x-id=GetBucketIntelligentTieringConfiguration"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_intelligent_tiering_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketIntelligentTieringConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_intelligent_tiering_configuration_output("{}")
        _ -> decode_get_bucket_intelligent_tiering_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_inventory_configuration_input(
  input: GetBucketInventoryConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_inventory_configuration_request_struct(input))
}

pub fn decode_get_bucket_inventory_configuration_input(
  body: String,
) -> Result(GetBucketInventoryConfigurationRequest, String) {
  case
    json.parse(body, decode_get_bucket_inventory_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_inventory_configuration_output(
  body: String,
) -> Result(GetBucketInventoryConfigurationOutput, String) {
  case
    json.parse(body, decode_get_bucket_inventory_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_inventory_configuration_body(
  _input: GetBucketInventoryConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_inventory_configuration_request(
  input: GetBucketInventoryConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?inventory&x-id=GetBucketInventoryConfiguration"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_inventory_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketInventoryConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_inventory_configuration_output("{}")
        _ -> decode_get_bucket_inventory_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_lifecycle_configuration_input(
  input: GetBucketLifecycleConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_lifecycle_configuration_request_struct(input))
}

pub fn decode_get_bucket_lifecycle_configuration_input(
  body: String,
) -> Result(GetBucketLifecycleConfigurationRequest, String) {
  case
    json.parse(body, decode_get_bucket_lifecycle_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_lifecycle_configuration_output(
  body: String,
) -> Result(GetBucketLifecycleConfigurationOutput, String) {
  case
    json.parse(body, decode_get_bucket_lifecycle_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_lifecycle_configuration_body(
  _input: GetBucketLifecycleConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_lifecycle_configuration_request(
  input: GetBucketLifecycleConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?lifecycle"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_lifecycle_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketLifecycleConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_lifecycle_configuration_output("{}")
        _ -> decode_get_bucket_lifecycle_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_location_input(
  input: GetBucketLocationRequest,
) -> String {
  json.to_string(encode_get_bucket_location_request_struct(input))
}

pub fn decode_get_bucket_location_input(
  body: String,
) -> Result(GetBucketLocationRequest, String) {
  case json.parse(body, decode_get_bucket_location_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_location_output(
  body: String,
) -> Result(GetBucketLocationOutput, String) {
  case json.parse(body, decode_get_bucket_location_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_location_body(
  _input: GetBucketLocationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_location_request(
  input: GetBucketLocationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?location"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_location_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketLocationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_location_output("{}")
        _ -> decode_get_bucket_location_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_logging_input(
  input: GetBucketLoggingRequest,
) -> String {
  json.to_string(encode_get_bucket_logging_request_struct(input))
}

pub fn decode_get_bucket_logging_input(
  body: String,
) -> Result(GetBucketLoggingRequest, String) {
  case json.parse(body, decode_get_bucket_logging_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_logging_output(
  body: String,
) -> Result(GetBucketLoggingOutput, String) {
  case json.parse(body, decode_get_bucket_logging_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_logging_body(
  _input: GetBucketLoggingRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_logging_request(
  input: GetBucketLoggingRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?logging"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_logging_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketLoggingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_logging_output("{}")
        _ -> decode_get_bucket_logging_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_metadata_configuration_input(
  input: GetBucketMetadataConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_metadata_configuration_request_struct(input))
}

pub fn decode_get_bucket_metadata_configuration_input(
  body: String,
) -> Result(GetBucketMetadataConfigurationRequest, String) {
  case
    json.parse(body, decode_get_bucket_metadata_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_metadata_configuration_output(
  body: String,
) -> Result(GetBucketMetadataConfigurationOutput, String) {
  case
    json.parse(body, decode_get_bucket_metadata_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_metadata_configuration_body(
  _input: GetBucketMetadataConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_metadata_configuration_request(
  input: GetBucketMetadataConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metadataConfiguration"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_metadata_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketMetadataConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_metadata_configuration_output("{}")
        _ -> decode_get_bucket_metadata_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_metadata_table_configuration_input(
  input: GetBucketMetadataTableConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_metadata_table_configuration_request_struct(
    input,
  ))
}

pub fn decode_get_bucket_metadata_table_configuration_input(
  body: String,
) -> Result(GetBucketMetadataTableConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_get_bucket_metadata_table_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_metadata_table_configuration_output(
  body: String,
) -> Result(GetBucketMetadataTableConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_get_bucket_metadata_table_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_metadata_table_configuration_body(
  _input: GetBucketMetadataTableConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_metadata_table_configuration_request(
  input: GetBucketMetadataTableConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metadataTable"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_metadata_table_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketMetadataTableConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_metadata_table_configuration_output("{}")
        _ -> decode_get_bucket_metadata_table_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_metrics_configuration_input(
  input: GetBucketMetricsConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_metrics_configuration_request_struct(input))
}

pub fn decode_get_bucket_metrics_configuration_input(
  body: String,
) -> Result(GetBucketMetricsConfigurationRequest, String) {
  case
    json.parse(body, decode_get_bucket_metrics_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_metrics_configuration_output(
  body: String,
) -> Result(GetBucketMetricsConfigurationOutput, String) {
  case
    json.parse(body, decode_get_bucket_metrics_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_metrics_configuration_body(
  _input: GetBucketMetricsConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_metrics_configuration_request(
  input: GetBucketMetricsConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metrics&x-id=GetBucketMetricsConfiguration"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_metrics_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketMetricsConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_metrics_configuration_output("{}")
        _ -> decode_get_bucket_metrics_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_notification_configuration_input(
  input: GetBucketNotificationConfigurationRequest,
) -> String {
  json.to_string(encode_get_bucket_notification_configuration_request_struct(
    input,
  ))
}

pub fn decode_get_bucket_notification_configuration_input(
  body: String,
) -> Result(GetBucketNotificationConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_get_bucket_notification_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_notification_configuration_output(
  body: String,
) -> Result(NotificationConfiguration, String) {
  case json.parse(body, decode_notification_configuration_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_notification_configuration_body(
  _input: GetBucketNotificationConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_notification_configuration_request(
  input: GetBucketNotificationConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?notification"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_notification_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(NotificationConfiguration, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_notification_configuration_output("{}")
        _ -> decode_get_bucket_notification_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_ownership_controls_input(
  input: GetBucketOwnershipControlsRequest,
) -> String {
  json.to_string(encode_get_bucket_ownership_controls_request_struct(input))
}

pub fn decode_get_bucket_ownership_controls_input(
  body: String,
) -> Result(GetBucketOwnershipControlsRequest, String) {
  case json.parse(body, decode_get_bucket_ownership_controls_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_ownership_controls_output(
  body: String,
) -> Result(GetBucketOwnershipControlsOutput, String) {
  case json.parse(body, decode_get_bucket_ownership_controls_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_ownership_controls_body(
  _input: GetBucketOwnershipControlsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_ownership_controls_request(
  input: GetBucketOwnershipControlsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?ownershipControls"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_ownership_controls_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketOwnershipControlsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_ownership_controls_output("{}")
        _ -> decode_get_bucket_ownership_controls_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_policy_input(input: GetBucketPolicyRequest) -> String {
  json.to_string(encode_get_bucket_policy_request_struct(input))
}

pub fn decode_get_bucket_policy_input(
  body: String,
) -> Result(GetBucketPolicyRequest, String) {
  case json.parse(body, decode_get_bucket_policy_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_policy_output(
  body: String,
) -> Result(GetBucketPolicyOutput, String) {
  case json.parse(body, decode_get_bucket_policy_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_policy_body(
  _input: GetBucketPolicyRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_policy_request(
  input: GetBucketPolicyRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?policy"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_policy_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketPolicyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_policy_output("{}")
        _ -> decode_get_bucket_policy_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_policy_status_input(
  input: GetBucketPolicyStatusRequest,
) -> String {
  json.to_string(encode_get_bucket_policy_status_request_struct(input))
}

pub fn decode_get_bucket_policy_status_input(
  body: String,
) -> Result(GetBucketPolicyStatusRequest, String) {
  case json.parse(body, decode_get_bucket_policy_status_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_policy_status_output(
  body: String,
) -> Result(GetBucketPolicyStatusOutput, String) {
  case json.parse(body, decode_get_bucket_policy_status_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_policy_status_body(
  _input: GetBucketPolicyStatusRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_policy_status_request(
  input: GetBucketPolicyStatusRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?policyStatus"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_policy_status_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketPolicyStatusOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_policy_status_output("{}")
        _ -> decode_get_bucket_policy_status_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_replication_input(
  input: GetBucketReplicationRequest,
) -> String {
  json.to_string(encode_get_bucket_replication_request_struct(input))
}

pub fn decode_get_bucket_replication_input(
  body: String,
) -> Result(GetBucketReplicationRequest, String) {
  case json.parse(body, decode_get_bucket_replication_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_replication_output(
  body: String,
) -> Result(GetBucketReplicationOutput, String) {
  case json.parse(body, decode_get_bucket_replication_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_replication_body(
  _input: GetBucketReplicationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_replication_request(
  input: GetBucketReplicationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?replication"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_replication_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketReplicationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_replication_output("{}")
        _ -> decode_get_bucket_replication_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_request_payment_input(
  input: GetBucketRequestPaymentRequest,
) -> String {
  json.to_string(encode_get_bucket_request_payment_request_struct(input))
}

pub fn decode_get_bucket_request_payment_input(
  body: String,
) -> Result(GetBucketRequestPaymentRequest, String) {
  case json.parse(body, decode_get_bucket_request_payment_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_request_payment_output(
  body: String,
) -> Result(GetBucketRequestPaymentOutput, String) {
  case json.parse(body, decode_get_bucket_request_payment_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_request_payment_body(
  _input: GetBucketRequestPaymentRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_request_payment_request(
  input: GetBucketRequestPaymentRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?requestPayment"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_request_payment_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketRequestPaymentOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_request_payment_output("{}")
        _ -> decode_get_bucket_request_payment_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_tagging_input(
  input: GetBucketTaggingRequest,
) -> String {
  json.to_string(encode_get_bucket_tagging_request_struct(input))
}

pub fn decode_get_bucket_tagging_input(
  body: String,
) -> Result(GetBucketTaggingRequest, String) {
  case json.parse(body, decode_get_bucket_tagging_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_tagging_output(
  body: String,
) -> Result(GetBucketTaggingOutput, String) {
  case json.parse(body, decode_get_bucket_tagging_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_tagging_body(
  _input: GetBucketTaggingRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_tagging_request(
  input: GetBucketTaggingRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?tagging"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_tagging_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketTaggingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_tagging_output("{}")
        _ -> decode_get_bucket_tagging_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_versioning_input(
  input: GetBucketVersioningRequest,
) -> String {
  json.to_string(encode_get_bucket_versioning_request_struct(input))
}

pub fn decode_get_bucket_versioning_input(
  body: String,
) -> Result(GetBucketVersioningRequest, String) {
  case json.parse(body, decode_get_bucket_versioning_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_versioning_output(
  body: String,
) -> Result(GetBucketVersioningOutput, String) {
  case json.parse(body, decode_get_bucket_versioning_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_versioning_body(
  _input: GetBucketVersioningRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_versioning_request(
  input: GetBucketVersioningRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?versioning"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_versioning_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketVersioningOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_versioning_output("{}")
        _ -> decode_get_bucket_versioning_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_bucket_website_input(
  input: GetBucketWebsiteRequest,
) -> String {
  json.to_string(encode_get_bucket_website_request_struct(input))
}

pub fn decode_get_bucket_website_input(
  body: String,
) -> Result(GetBucketWebsiteRequest, String) {
  case json.parse(body, decode_get_bucket_website_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_bucket_website_output(
  body: String,
) -> Result(GetBucketWebsiteOutput, String) {
  case json.parse(body, decode_get_bucket_website_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_bucket_website_body(
  _input: GetBucketWebsiteRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_bucket_website_request(
  input: GetBucketWebsiteRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?website"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_bucket_website_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetBucketWebsiteOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_bucket_website_output("{}")
        _ -> decode_get_bucket_website_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_object_acl_input(input: GetObjectAclRequest) -> String {
  json.to_string(encode_get_object_acl_request_struct(input))
}

pub fn decode_get_object_acl_input(
  body: String,
) -> Result(GetObjectAclRequest, String) {
  case json.parse(body, decode_get_object_acl_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_object_acl_output(
  body: String,
) -> Result(GetObjectAclOutput, String) {
  case json.parse(body, decode_get_object_acl_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_object_acl_body(_input: GetObjectAclRequest) -> json.Json {
  json.object([])
}

pub fn build_get_object_acl_request(
  input: GetObjectAclRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?acl"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_object_acl_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetObjectAclOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_object_acl_output("{}")
        _ -> decode_get_object_acl_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_object_attributes_input(
  input: GetObjectAttributesRequest,
) -> String {
  json.to_string(encode_get_object_attributes_request_struct(input))
}

pub fn decode_get_object_attributes_input(
  body: String,
) -> Result(GetObjectAttributesRequest, String) {
  case json.parse(body, decode_get_object_attributes_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_object_attributes_output(
  body: String,
) -> Result(GetObjectAttributesOutput, String) {
  case json.parse(body, decode_get_object_attributes_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_object_attributes_body(
  _input: GetObjectAttributesRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_object_attributes_request(
  input: GetObjectAttributesRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?attributes"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.max_parts {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-max-parts", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.object_attributes {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-object-attributes", "")
    option.None -> headers
  }
  let headers = case input.part_number_marker {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-part-number-marker", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_object_attributes_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetObjectAttributesOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_object_attributes_output("{}")
        _ -> decode_get_object_attributes_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_object_legal_hold_input(
  input: GetObjectLegalHoldRequest,
) -> String {
  json.to_string(encode_get_object_legal_hold_request_struct(input))
}

pub fn decode_get_object_legal_hold_input(
  body: String,
) -> Result(GetObjectLegalHoldRequest, String) {
  case json.parse(body, decode_get_object_legal_hold_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_object_legal_hold_output(
  body: String,
) -> Result(GetObjectLegalHoldOutput, String) {
  case json.parse(body, decode_get_object_legal_hold_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_object_legal_hold_body(
  _input: GetObjectLegalHoldRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_object_legal_hold_request(
  input: GetObjectLegalHoldRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?legal-hold"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_object_legal_hold_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetObjectLegalHoldOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_object_legal_hold_output("{}")
        _ -> decode_get_object_legal_hold_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_object_lock_configuration_input(
  input: GetObjectLockConfigurationRequest,
) -> String {
  json.to_string(encode_get_object_lock_configuration_request_struct(input))
}

pub fn decode_get_object_lock_configuration_input(
  body: String,
) -> Result(GetObjectLockConfigurationRequest, String) {
  case json.parse(body, decode_get_object_lock_configuration_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_object_lock_configuration_output(
  body: String,
) -> Result(GetObjectLockConfigurationOutput, String) {
  case json.parse(body, decode_get_object_lock_configuration_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_object_lock_configuration_body(
  _input: GetObjectLockConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_object_lock_configuration_request(
  input: GetObjectLockConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?object-lock"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_object_lock_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetObjectLockConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_object_lock_configuration_output("{}")
        _ -> decode_get_object_lock_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_object_retention_input(
  input: GetObjectRetentionRequest,
) -> String {
  json.to_string(encode_get_object_retention_request_struct(input))
}

pub fn decode_get_object_retention_input(
  body: String,
) -> Result(GetObjectRetentionRequest, String) {
  case json.parse(body, decode_get_object_retention_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_object_retention_output(
  body: String,
) -> Result(GetObjectRetentionOutput, String) {
  case json.parse(body, decode_get_object_retention_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_object_retention_body(
  _input: GetObjectRetentionRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_object_retention_request(
  input: GetObjectRetentionRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?retention"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_object_retention_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetObjectRetentionOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_object_retention_output("{}")
        _ -> decode_get_object_retention_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_object_tagging_input(
  input: GetObjectTaggingRequest,
) -> String {
  json.to_string(encode_get_object_tagging_request_struct(input))
}

pub fn decode_get_object_tagging_input(
  body: String,
) -> Result(GetObjectTaggingRequest, String) {
  case json.parse(body, decode_get_object_tagging_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_object_tagging_output(
  body: String,
) -> Result(GetObjectTaggingOutput, String) {
  case json.parse(body, decode_get_object_tagging_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_object_tagging_body(
  _input: GetObjectTaggingRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_object_tagging_request(
  input: GetObjectTaggingRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?tagging"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_object_tagging_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetObjectTaggingOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_object_tagging_output("{}")
        _ -> decode_get_object_tagging_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_object_torrent_input(
  input: GetObjectTorrentRequest,
) -> String {
  json.to_string(encode_get_object_torrent_request_struct(input))
}

pub fn decode_get_object_torrent_input(
  body: String,
) -> Result(GetObjectTorrentRequest, String) {
  case json.parse(body, decode_get_object_torrent_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_object_torrent_output(
  body: String,
) -> Result(GetObjectTorrentOutput, String) {
  case json.parse(body, decode_get_object_torrent_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_object_torrent_body(
  _input: GetObjectTorrentRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_object_torrent_request(
  input: GetObjectTorrentRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?torrent"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_object_torrent_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetObjectTorrentOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_object_torrent_output("{}")
        _ -> decode_get_object_torrent_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_get_public_access_block_input(
  input: GetPublicAccessBlockRequest,
) -> String {
  json.to_string(encode_get_public_access_block_request_struct(input))
}

pub fn decode_get_public_access_block_input(
  body: String,
) -> Result(GetPublicAccessBlockRequest, String) {
  case json.parse(body, decode_get_public_access_block_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_get_public_access_block_output(
  body: String,
) -> Result(GetPublicAccessBlockOutput, String) {
  case json.parse(body, decode_get_public_access_block_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_get_public_access_block_body(
  _input: GetPublicAccessBlockRequest,
) -> json.Json {
  json.object([])
}

pub fn build_get_public_access_block_request(
  input: GetPublicAccessBlockRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?publicAccessBlock"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_get_public_access_block_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(GetPublicAccessBlockOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_get_public_access_block_output("{}")
        _ -> decode_get_public_access_block_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_head_bucket_input(input: HeadBucketRequest) -> String {
  json.to_string(encode_head_bucket_request_struct(input))
}

pub fn decode_head_bucket_input(
  body: String,
) -> Result(HeadBucketRequest, String) {
  case json.parse(body, decode_head_bucket_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_head_bucket_output(
  body: String,
) -> Result(HeadBucketOutput, String) {
  case json.parse(body, decode_head_bucket_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_head_bucket_body(_input: HeadBucketRequest) -> json.Json {
  json.object([])
}

pub fn build_head_bucket_request(
  input: HeadBucketRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("HEAD", path, headers, body)
}

pub fn parse_head_bucket_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HeadBucketOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_head_bucket_output("{}")
        _ -> decode_head_bucket_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_head_object_input(input: HeadObjectRequest) -> String {
  json.to_string(encode_head_object_request_struct(input))
}

pub fn decode_head_object_input(
  body: String,
) -> Result(HeadObjectRequest, String) {
  case json.parse(body, decode_head_object_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_head_object_output(
  body: String,
) -> Result(HeadObjectOutput, String) {
  case json.parse(body, decode_head_object_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_head_object_body(_input: HeadObjectRequest) -> json.Json {
  json.object([])
}

pub fn build_head_object_request(
  input: HeadObjectRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.part_number {
    option.Some(v) -> rest.add_query(query, "partNumber", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.response_cache_control {
    option.Some(v) -> rest.add_query(query, "response-cache-control", v)
    option.None -> query
  }
  let query = case input.response_content_disposition {
    option.Some(v) -> rest.add_query(query, "response-content-disposition", v)
    option.None -> query
  }
  let query = case input.response_content_encoding {
    option.Some(v) -> rest.add_query(query, "response-content-encoding", v)
    option.None -> query
  }
  let query = case input.response_content_language {
    option.Some(v) -> rest.add_query(query, "response-content-language", v)
    option.None -> query
  }
  let query = case input.response_content_type {
    option.Some(v) -> rest.add_query(query, "response-content-type", v)
    option.None -> query
  }
  let query = case input.response_expires {
    option.Some(v) ->
      rest.add_query(query, "response-expires", rest.timestamp_to_header(v))
    option.None -> query
  }
  let query = case input.version_id {
    option.Some(v) -> rest.add_query(query, "versionId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.checksum_mode {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-checksum-mode",
        rest.enum_wire_value(encode_checksum_mode_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.if_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-Match", v)
    option.None -> headers
  }
  let headers = case input.if_modified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "If-Modified-Since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.if_none_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-None-Match", v)
    option.None -> headers
  }
  let headers = case input.if_unmodified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "If-Unmodified-Since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.range {
    option.Some(v) -> rest.maybe_set_header(headers, "Range", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("HEAD", path, headers, body)
}

pub fn parse_head_object_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(HeadObjectOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_head_object_output("{}")
        _ -> decode_head_object_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_bucket_analytics_configurations_input(
  input: ListBucketAnalyticsConfigurationsRequest,
) -> String {
  json.to_string(encode_list_bucket_analytics_configurations_request_struct(
    input,
  ))
}

pub fn decode_list_bucket_analytics_configurations_input(
  body: String,
) -> Result(ListBucketAnalyticsConfigurationsRequest, String) {
  case
    json.parse(
      body,
      decode_list_bucket_analytics_configurations_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_bucket_analytics_configurations_output(
  body: String,
) -> Result(ListBucketAnalyticsConfigurationsOutput, String) {
  case
    json.parse(
      body,
      decode_list_bucket_analytics_configurations_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_bucket_analytics_configurations_body(
  _input: ListBucketAnalyticsConfigurationsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_list_bucket_analytics_configurations_request(
  input: ListBucketAnalyticsConfigurationsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?analytics&x-id=ListBucketAnalyticsConfigurations"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.continuation_token {
    option.Some(v) -> rest.add_query(query, "continuation-token", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_bucket_analytics_configurations_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListBucketAnalyticsConfigurationsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_bucket_analytics_configurations_output("{}")
        _ -> decode_list_bucket_analytics_configurations_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_bucket_intelligent_tiering_configurations_input(
  input: ListBucketIntelligentTieringConfigurationsRequest,
) -> String {
  json.to_string(
    encode_list_bucket_intelligent_tiering_configurations_request_struct(input),
  )
}

pub fn decode_list_bucket_intelligent_tiering_configurations_input(
  body: String,
) -> Result(ListBucketIntelligentTieringConfigurationsRequest, String) {
  case
    json.parse(
      body,
      decode_list_bucket_intelligent_tiering_configurations_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_bucket_intelligent_tiering_configurations_output(
  body: String,
) -> Result(ListBucketIntelligentTieringConfigurationsOutput, String) {
  case
    json.parse(
      body,
      decode_list_bucket_intelligent_tiering_configurations_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_bucket_intelligent_tiering_configurations_body(
  _input: ListBucketIntelligentTieringConfigurationsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_list_bucket_intelligent_tiering_configurations_request(
  input: ListBucketIntelligentTieringConfigurationsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path =
    "/{Bucket}?intelligent-tiering&x-id=ListBucketIntelligentTieringConfigurations"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.continuation_token {
    option.Some(v) -> rest.add_query(query, "continuation-token", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_bucket_intelligent_tiering_configurations_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListBucketIntelligentTieringConfigurationsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_bucket_intelligent_tiering_configurations_output("{}")
        _ -> decode_list_bucket_intelligent_tiering_configurations_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_bucket_inventory_configurations_input(
  input: ListBucketInventoryConfigurationsRequest,
) -> String {
  json.to_string(encode_list_bucket_inventory_configurations_request_struct(
    input,
  ))
}

pub fn decode_list_bucket_inventory_configurations_input(
  body: String,
) -> Result(ListBucketInventoryConfigurationsRequest, String) {
  case
    json.parse(
      body,
      decode_list_bucket_inventory_configurations_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_bucket_inventory_configurations_output(
  body: String,
) -> Result(ListBucketInventoryConfigurationsOutput, String) {
  case
    json.parse(
      body,
      decode_list_bucket_inventory_configurations_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_bucket_inventory_configurations_body(
  _input: ListBucketInventoryConfigurationsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_list_bucket_inventory_configurations_request(
  input: ListBucketInventoryConfigurationsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?inventory&x-id=ListBucketInventoryConfigurations"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.continuation_token {
    option.Some(v) -> rest.add_query(query, "continuation-token", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_bucket_inventory_configurations_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListBucketInventoryConfigurationsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_bucket_inventory_configurations_output("{}")
        _ -> decode_list_bucket_inventory_configurations_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_bucket_metrics_configurations_input(
  input: ListBucketMetricsConfigurationsRequest,
) -> String {
  json.to_string(encode_list_bucket_metrics_configurations_request_struct(input))
}

pub fn decode_list_bucket_metrics_configurations_input(
  body: String,
) -> Result(ListBucketMetricsConfigurationsRequest, String) {
  case
    json.parse(body, decode_list_bucket_metrics_configurations_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_bucket_metrics_configurations_output(
  body: String,
) -> Result(ListBucketMetricsConfigurationsOutput, String) {
  case
    json.parse(body, decode_list_bucket_metrics_configurations_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_bucket_metrics_configurations_body(
  _input: ListBucketMetricsConfigurationsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_list_bucket_metrics_configurations_request(
  input: ListBucketMetricsConfigurationsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metrics&x-id=ListBucketMetricsConfigurations"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.continuation_token {
    option.Some(v) -> rest.add_query(query, "continuation-token", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_bucket_metrics_configurations_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListBucketMetricsConfigurationsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_bucket_metrics_configurations_output("{}")
        _ -> decode_list_bucket_metrics_configurations_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_buckets_input(input: ListBucketsRequest) -> String {
  json.to_string(encode_list_buckets_request_struct(input))
}

pub fn decode_list_buckets_input(
  body: String,
) -> Result(ListBucketsRequest, String) {
  case json.parse(body, decode_list_buckets_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_buckets_output(
  body: String,
) -> Result(ListBucketsOutput, String) {
  case json.parse(body, decode_list_buckets_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_buckets_body(_input: ListBucketsRequest) -> json.Json {
  json.object([])
}

pub fn build_list_buckets_request(
  input: ListBucketsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/?x-id=ListBuckets"
  let query = ""
  let query = case input.bucket_region {
    option.Some(v) -> rest.add_query(query, "bucket-region", v)
    option.None -> query
  }
  let query = case input.continuation_token {
    option.Some(v) -> rest.add_query(query, "continuation-token", v)
    option.None -> query
  }
  let query = case input.max_buckets {
    option.Some(v) -> rest.add_query(query, "max-buckets", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.prefix {
    option.Some(v) -> rest.add_query(query, "prefix", v)
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_buckets_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListBucketsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_buckets_output("{}")
        _ -> decode_list_buckets_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_directory_buckets_input(
  input: ListDirectoryBucketsRequest,
) -> String {
  json.to_string(encode_list_directory_buckets_request_struct(input))
}

pub fn decode_list_directory_buckets_input(
  body: String,
) -> Result(ListDirectoryBucketsRequest, String) {
  case json.parse(body, decode_list_directory_buckets_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_directory_buckets_output(
  body: String,
) -> Result(ListDirectoryBucketsOutput, String) {
  case json.parse(body, decode_list_directory_buckets_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_directory_buckets_body(
  _input: ListDirectoryBucketsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_list_directory_buckets_request(
  input: ListDirectoryBucketsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/?x-id=ListDirectoryBuckets"
  let query = ""
  let query = case input.continuation_token {
    option.Some(v) -> rest.add_query(query, "continuation-token", v)
    option.None -> query
  }
  let query = case input.max_directory_buckets {
    option.Some(v) ->
      rest.add_query(query, "max-directory-buckets", rest.int_to_query(v))
    option.None -> query
  }
  let headers = dict.new()
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_directory_buckets_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListDirectoryBucketsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_directory_buckets_output("{}")
        _ -> decode_list_directory_buckets_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_multipart_uploads_input(
  input: ListMultipartUploadsRequest,
) -> String {
  json.to_string(encode_list_multipart_uploads_request_struct(input))
}

pub fn decode_list_multipart_uploads_input(
  body: String,
) -> Result(ListMultipartUploadsRequest, String) {
  case json.parse(body, decode_list_multipart_uploads_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_multipart_uploads_output(
  body: String,
) -> Result(ListMultipartUploadsOutput, String) {
  case json.parse(body, decode_list_multipart_uploads_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_multipart_uploads_body(
  _input: ListMultipartUploadsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_list_multipart_uploads_request(
  input: ListMultipartUploadsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?uploads"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.delimiter {
    option.Some(v) -> rest.add_query(query, "delimiter", v)
    option.None -> query
  }
  let query = case input.encoding_type {
    option.Some(v) ->
      rest.add_query(
        query,
        "encoding-type",
        rest.enum_wire_value(encode_encoding_type_enum(v)),
      )
    option.None -> query
  }
  let query = case input.key_marker {
    option.Some(v) -> rest.add_query(query, "key-marker", v)
    option.None -> query
  }
  let query = case input.max_uploads {
    option.Some(v) -> rest.add_query(query, "max-uploads", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.prefix {
    option.Some(v) -> rest.add_query(query, "prefix", v)
    option.None -> query
  }
  let query = case input.upload_id_marker {
    option.Some(v) -> rest.add_query(query, "upload-id-marker", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_multipart_uploads_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListMultipartUploadsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_multipart_uploads_output("{}")
        _ -> decode_list_multipart_uploads_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_objects_input(input: ListObjectsRequest) -> String {
  json.to_string(encode_list_objects_request_struct(input))
}

pub fn decode_list_objects_input(
  body: String,
) -> Result(ListObjectsRequest, String) {
  case json.parse(body, decode_list_objects_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_objects_output(
  body: String,
) -> Result(ListObjectsOutput, String) {
  case json.parse(body, decode_list_objects_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_objects_body(_input: ListObjectsRequest) -> json.Json {
  json.object([])
}

pub fn build_list_objects_request(
  input: ListObjectsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.delimiter {
    option.Some(v) -> rest.add_query(query, "delimiter", v)
    option.None -> query
  }
  let query = case input.encoding_type {
    option.Some(v) ->
      rest.add_query(
        query,
        "encoding-type",
        rest.enum_wire_value(encode_encoding_type_enum(v)),
      )
    option.None -> query
  }
  let query = case input.marker {
    option.Some(v) -> rest.add_query(query, "marker", v)
    option.None -> query
  }
  let query = case input.max_keys {
    option.Some(v) -> rest.add_query(query, "max-keys", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.prefix {
    option.Some(v) -> rest.add_query(query, "prefix", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.optional_object_attributes {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-optional-object-attributes", "")
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_objects_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListObjectsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_objects_output("{}")
        _ -> decode_list_objects_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_objects_v2_input(input: ListObjectsV2Request) -> String {
  json.to_string(encode_list_objects_v2_request_struct(input))
}

pub fn decode_list_objects_v2_input(
  body: String,
) -> Result(ListObjectsV2Request, String) {
  case json.parse(body, decode_list_objects_v2_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_objects_v2_output(
  body: String,
) -> Result(ListObjectsV2Output, String) {
  case json.parse(body, decode_list_objects_v2_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_objects_v2_body(_input: ListObjectsV2Request) -> json.Json {
  json.object([])
}

pub fn build_list_objects_v2_request(
  input: ListObjectsV2Request,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?list-type=2"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.continuation_token {
    option.Some(v) -> rest.add_query(query, "continuation-token", v)
    option.None -> query
  }
  let query = case input.delimiter {
    option.Some(v) -> rest.add_query(query, "delimiter", v)
    option.None -> query
  }
  let query = case input.encoding_type {
    option.Some(v) ->
      rest.add_query(
        query,
        "encoding-type",
        rest.enum_wire_value(encode_encoding_type_enum(v)),
      )
    option.None -> query
  }
  let query = case input.fetch_owner {
    option.Some(v) ->
      rest.add_query(query, "fetch-owner", rest.bool_to_query(v))
    option.None -> query
  }
  let query = case input.max_keys {
    option.Some(v) -> rest.add_query(query, "max-keys", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.prefix {
    option.Some(v) -> rest.add_query(query, "prefix", v)
    option.None -> query
  }
  let query = case input.start_after {
    option.Some(v) -> rest.add_query(query, "start-after", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.optional_object_attributes {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-optional-object-attributes", "")
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_objects_v2_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListObjectsV2Output, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_objects_v2_output("{}")
        _ -> decode_list_objects_v2_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_object_versions_input(
  input: ListObjectVersionsRequest,
) -> String {
  json.to_string(encode_list_object_versions_request_struct(input))
}

pub fn decode_list_object_versions_input(
  body: String,
) -> Result(ListObjectVersionsRequest, String) {
  case json.parse(body, decode_list_object_versions_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_object_versions_output(
  body: String,
) -> Result(ListObjectVersionsOutput, String) {
  case json.parse(body, decode_list_object_versions_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_object_versions_body(
  _input: ListObjectVersionsRequest,
) -> json.Json {
  json.object([])
}

pub fn build_list_object_versions_request(
  input: ListObjectVersionsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?versions"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.delimiter {
    option.Some(v) -> rest.add_query(query, "delimiter", v)
    option.None -> query
  }
  let query = case input.encoding_type {
    option.Some(v) ->
      rest.add_query(
        query,
        "encoding-type",
        rest.enum_wire_value(encode_encoding_type_enum(v)),
      )
    option.None -> query
  }
  let query = case input.key_marker {
    option.Some(v) -> rest.add_query(query, "key-marker", v)
    option.None -> query
  }
  let query = case input.max_keys {
    option.Some(v) -> rest.add_query(query, "max-keys", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.prefix {
    option.Some(v) -> rest.add_query(query, "prefix", v)
    option.None -> query
  }
  let query = case input.version_id_marker {
    option.Some(v) -> rest.add_query(query, "version-id-marker", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.optional_object_attributes {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-optional-object-attributes", "")
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_object_versions_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListObjectVersionsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_object_versions_output("{}")
        _ -> decode_list_object_versions_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_list_parts_input(input: ListPartsRequest) -> String {
  json.to_string(encode_list_parts_request_struct(input))
}

pub fn decode_list_parts_input(
  body: String,
) -> Result(ListPartsRequest, String) {
  case json.parse(body, decode_list_parts_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_list_parts_output(
  body: String,
) -> Result(ListPartsOutput, String) {
  case json.parse(body, decode_list_parts_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_list_parts_body(_input: ListPartsRequest) -> json.Json {
  json.object([])
}

pub fn build_list_parts_request(
  input: ListPartsRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?x-id=ListParts"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.max_parts {
    option.Some(v) -> rest.add_query(query, "max-parts", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.part_number_marker {
    option.Some(v) -> rest.add_query(query, "part-number-marker", v)
    option.None -> query
  }
  let query = case input.upload_id {
    option.Some(v) -> rest.add_query(query, "uploadId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("GET", path, headers, body)
}

pub fn parse_list_parts_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(ListPartsOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_list_parts_output("{}")
        _ -> decode_list_parts_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type PutBucketAnalyticsConfigurationOutput {
  PutBucketAnalyticsConfigurationOutput
}

pub fn encode_put_bucket_analytics_configuration_output_struct(
  _v: PutBucketAnalyticsConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_put_bucket_analytics_configuration_output_struct() -> decode.Decoder(
  PutBucketAnalyticsConfigurationOutput,
) {
  decode.success(PutBucketAnalyticsConfigurationOutput)
}

pub fn encode_put_bucket_analytics_configuration_input(
  input: PutBucketAnalyticsConfigurationRequest,
) -> String {
  json.to_string(encode_put_bucket_analytics_configuration_request_struct(input))
}

pub fn decode_put_bucket_analytics_configuration_input(
  body: String,
) -> Result(PutBucketAnalyticsConfigurationRequest, String) {
  case
    json.parse(body, decode_put_bucket_analytics_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_bucket_analytics_configuration_output(
  body: String,
) -> Result(PutBucketAnalyticsConfigurationOutput, String) {
  case
    json.parse(body, decode_put_bucket_analytics_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_put_bucket_analytics_configuration_body(
  _input: PutBucketAnalyticsConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_put_bucket_analytics_configuration_request(
  input: PutBucketAnalyticsConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?analytics"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = case input.analytics_configuration {
    option.Some(v) ->
      bit_array.from_string(
        json.to_string(encode_analytics_configuration_struct(v)),
      )
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_put_bucket_analytics_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutBucketAnalyticsConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_bucket_analytics_configuration_output("{}")
        _ -> decode_put_bucket_analytics_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type PutBucketIntelligentTieringConfigurationOutput {
  PutBucketIntelligentTieringConfigurationOutput
}

pub fn encode_put_bucket_intelligent_tiering_configuration_output_struct(
  _v: PutBucketIntelligentTieringConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_put_bucket_intelligent_tiering_configuration_output_struct() -> decode.Decoder(
  PutBucketIntelligentTieringConfigurationOutput,
) {
  decode.success(PutBucketIntelligentTieringConfigurationOutput)
}

pub fn encode_put_bucket_intelligent_tiering_configuration_input(
  input: PutBucketIntelligentTieringConfigurationRequest,
) -> String {
  json.to_string(
    encode_put_bucket_intelligent_tiering_configuration_request_struct(input),
  )
}

pub fn decode_put_bucket_intelligent_tiering_configuration_input(
  body: String,
) -> Result(PutBucketIntelligentTieringConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_put_bucket_intelligent_tiering_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_bucket_intelligent_tiering_configuration_output(
  body: String,
) -> Result(PutBucketIntelligentTieringConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_put_bucket_intelligent_tiering_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_put_bucket_intelligent_tiering_configuration_body(
  _input: PutBucketIntelligentTieringConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_put_bucket_intelligent_tiering_configuration_request(
  input: PutBucketIntelligentTieringConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?intelligent-tiering"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = case input.intelligent_tiering_configuration {
    option.Some(v) ->
      bit_array.from_string(
        json.to_string(encode_intelligent_tiering_configuration_struct(v)),
      )
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_put_bucket_intelligent_tiering_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutBucketIntelligentTieringConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_bucket_intelligent_tiering_configuration_output("{}")
        _ -> decode_put_bucket_intelligent_tiering_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type PutBucketInventoryConfigurationOutput {
  PutBucketInventoryConfigurationOutput
}

pub fn encode_put_bucket_inventory_configuration_output_struct(
  _v: PutBucketInventoryConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_put_bucket_inventory_configuration_output_struct() -> decode.Decoder(
  PutBucketInventoryConfigurationOutput,
) {
  decode.success(PutBucketInventoryConfigurationOutput)
}

pub fn encode_put_bucket_inventory_configuration_input(
  input: PutBucketInventoryConfigurationRequest,
) -> String {
  json.to_string(encode_put_bucket_inventory_configuration_request_struct(input))
}

pub fn decode_put_bucket_inventory_configuration_input(
  body: String,
) -> Result(PutBucketInventoryConfigurationRequest, String) {
  case
    json.parse(body, decode_put_bucket_inventory_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_bucket_inventory_configuration_output(
  body: String,
) -> Result(PutBucketInventoryConfigurationOutput, String) {
  case
    json.parse(body, decode_put_bucket_inventory_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_put_bucket_inventory_configuration_body(
  _input: PutBucketInventoryConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_put_bucket_inventory_configuration_request(
  input: PutBucketInventoryConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?inventory"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = case input.inventory_configuration {
    option.Some(v) ->
      bit_array.from_string(
        json.to_string(encode_inventory_configuration_struct(v)),
      )
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_put_bucket_inventory_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutBucketInventoryConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_bucket_inventory_configuration_output("{}")
        _ -> decode_put_bucket_inventory_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type PutBucketMetricsConfigurationOutput {
  PutBucketMetricsConfigurationOutput
}

pub fn encode_put_bucket_metrics_configuration_output_struct(
  _v: PutBucketMetricsConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_put_bucket_metrics_configuration_output_struct() -> decode.Decoder(
  PutBucketMetricsConfigurationOutput,
) {
  decode.success(PutBucketMetricsConfigurationOutput)
}

pub fn encode_put_bucket_metrics_configuration_input(
  input: PutBucketMetricsConfigurationRequest,
) -> String {
  json.to_string(encode_put_bucket_metrics_configuration_request_struct(input))
}

pub fn decode_put_bucket_metrics_configuration_input(
  body: String,
) -> Result(PutBucketMetricsConfigurationRequest, String) {
  case
    json.parse(body, decode_put_bucket_metrics_configuration_request_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_bucket_metrics_configuration_output(
  body: String,
) -> Result(PutBucketMetricsConfigurationOutput, String) {
  case
    json.parse(body, decode_put_bucket_metrics_configuration_output_struct())
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_put_bucket_metrics_configuration_body(
  _input: PutBucketMetricsConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_put_bucket_metrics_configuration_request(
  input: PutBucketMetricsConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?metrics"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let query = case input.id {
    option.Some(v) -> rest.add_query(query, "id", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let body = case input.metrics_configuration {
    option.Some(v) ->
      bit_array.from_string(
        json.to_string(encode_metrics_configuration_struct(v)),
      )
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_put_bucket_metrics_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutBucketMetricsConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_bucket_metrics_configuration_output("{}")
        _ -> decode_put_bucket_metrics_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type PutBucketNotificationConfigurationOutput {
  PutBucketNotificationConfigurationOutput
}

pub fn encode_put_bucket_notification_configuration_output_struct(
  _v: PutBucketNotificationConfigurationOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_put_bucket_notification_configuration_output_struct() -> decode.Decoder(
  PutBucketNotificationConfigurationOutput,
) {
  decode.success(PutBucketNotificationConfigurationOutput)
}

pub fn encode_put_bucket_notification_configuration_input(
  input: PutBucketNotificationConfigurationRequest,
) -> String {
  json.to_string(encode_put_bucket_notification_configuration_request_struct(
    input,
  ))
}

pub fn decode_put_bucket_notification_configuration_input(
  body: String,
) -> Result(PutBucketNotificationConfigurationRequest, String) {
  case
    json.parse(
      body,
      decode_put_bucket_notification_configuration_request_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_put_bucket_notification_configuration_output(
  body: String,
) -> Result(PutBucketNotificationConfigurationOutput, String) {
  case
    json.parse(
      body,
      decode_put_bucket_notification_configuration_output_struct(),
    )
  {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_put_bucket_notification_configuration_body(
  _input: PutBucketNotificationConfigurationRequest,
) -> json.Json {
  json.object([])
}

pub fn build_put_bucket_notification_configuration_request(
  input: PutBucketNotificationConfigurationRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}?notification"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.skip_destination_validation {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-skip-destination-validation",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let body = case input.notification_configuration {
    option.Some(v) ->
      bit_array.from_string(
        json.to_string(encode_notification_configuration_struct(v)),
      )
    option.None -> <<>>
  }
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_put_bucket_notification_configuration_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(PutBucketNotificationConfigurationOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_put_bucket_notification_configuration_output("{}")
        _ -> decode_put_bucket_notification_configuration_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_rename_object_input(input: RenameObjectRequest) -> String {
  json.to_string(encode_rename_object_request_struct(input))
}

pub fn decode_rename_object_input(
  body: String,
) -> Result(RenameObjectRequest, String) {
  case json.parse(body, decode_rename_object_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_rename_object_output(
  body: String,
) -> Result(RenameObjectOutput, String) {
  case json.parse(body, decode_rename_object_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_rename_object_body(_input: RenameObjectRequest) -> json.Json {
  json.object([])
}

pub fn build_rename_object_request(
  input: RenameObjectRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?renameObject"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.client_token {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-client-token", v)
    option.None -> headers
  }
  let headers = case input.destination_if_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-Match", v)
    option.None -> headers
  }
  let headers = case input.destination_if_modified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "If-Modified-Since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.destination_if_none_match {
    option.Some(v) -> rest.maybe_set_header(headers, "If-None-Match", v)
    option.None -> headers
  }
  let headers = case input.destination_if_unmodified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "If-Unmodified-Since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.rename_source {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-rename-source", v)
    option.None -> headers
  }
  let headers = case input.source_if_match {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-rename-source-if-match", v)
    option.None -> headers
  }
  let headers = case input.source_if_modified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-rename-source-if-modified-since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.source_if_none_match {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-rename-source-if-none-match", v)
    option.None -> headers
  }
  let headers = case input.source_if_unmodified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-rename-source-if-unmodified-since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_rename_object_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(RenameObjectOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_rename_object_output("{}")
        _ -> decode_rename_object_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_select_object_content_input(
  input: SelectObjectContentRequest,
) -> String {
  json.to_string(encode_select_object_content_request_struct(input))
}

pub fn decode_select_object_content_input(
  body: String,
) -> Result(SelectObjectContentRequest, String) {
  case json.parse(body, decode_select_object_content_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_select_object_content_output(
  body: String,
) -> Result(SelectObjectContentOutput, String) {
  case json.parse(body, decode_select_object_content_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_select_object_content_body(
  input: SelectObjectContentRequest,
) -> json.Json {
  let pairs = []
  let pairs = case input.expression {
    option.Some(v) -> [#("Expression", json.string(v)), ..pairs]
    option.None -> pairs
  }
  let pairs = case input.expression_type {
    option.Some(v) -> [
      #("ExpressionType", encode_expression_type_enum(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.input_serialization {
    option.Some(v) -> [
      #("InputSerialization", encode_input_serialization_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.output_serialization {
    option.Some(v) -> [
      #("OutputSerialization", encode_output_serialization_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.request_progress {
    option.Some(v) -> [
      #("RequestProgress", encode_request_progress_struct(v)),
      ..pairs
    ]
    option.None -> pairs
  }
  let pairs = case input.scan_range {
    option.Some(v) -> [#("ScanRange", encode_scan_range_struct(v)), ..pairs]
    option.None -> pairs
  }
  json.object(pairs)
}

pub fn build_select_object_content_request(
  input: SelectObjectContentRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?select&select-type=2"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let headers = dict.new()
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let body_json = encode_select_object_content_body(input)
  let body = bit_array.from_string(json.to_string(body_json))
  let content_type = "application/xml"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_select_object_content_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(SelectObjectContentOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_select_object_content_output("{}")
        _ -> decode_select_object_content_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn encode_upload_part_copy_input(input: UploadPartCopyRequest) -> String {
  json.to_string(encode_upload_part_copy_request_struct(input))
}

pub fn decode_upload_part_copy_input(
  body: String,
) -> Result(UploadPartCopyRequest, String) {
  case json.parse(body, decode_upload_part_copy_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_upload_part_copy_output(
  body: String,
) -> Result(UploadPartCopyOutput, String) {
  case json.parse(body, decode_upload_part_copy_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_upload_part_copy_body(
  _input: UploadPartCopyRequest,
) -> json.Json {
  json.object([])
}

pub fn build_upload_part_copy_request(
  input: UploadPartCopyRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/{Bucket}/{Key+}?x-id=UploadPartCopy"
  let path = case input.bucket {
    option.Some(v) -> rest.substitute_label(path, "Bucket", v, False)
    option.None -> path
  }
  let path = case input.key {
    option.Some(v) -> rest.substitute_label(path, "Key", v, True)
    option.None -> path
  }
  let query = ""
  let query = case input.part_number {
    option.Some(v) -> rest.add_query(query, "partNumber", rest.int_to_query(v))
    option.None -> query
  }
  let query = case input.upload_id {
    option.Some(v) -> rest.add_query(query, "uploadId", v)
    option.None -> query
  }
  let headers = dict.new()
  let headers = case input.copy_source {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-copy-source", v)
    option.None -> headers
  }
  let headers = case input.copy_source_if_match {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-copy-source-if-match", v)
    option.None -> headers
  }
  let headers = case input.copy_source_if_modified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-if-modified-since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.copy_source_if_none_match {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-copy-source-if-none-match", v)
    option.None -> headers
  }
  let headers = case input.copy_source_if_unmodified_since {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-if-unmodified-since",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.copy_source_range {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-copy-source-range", v)
    option.None -> headers
  }
  let headers = case input.copy_source_sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.copy_source_sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.copy_source_sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-copy-source-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let headers = case input.expected_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.expected_source_bucket_owner {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-source-expected-bucket-owner", v)
    option.None -> headers
  }
  let headers = case input.request_payer {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-request-payer",
        rest.enum_wire_value(encode_request_payer_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let body = <<>>
  let content_type = ""
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("PUT", path, headers, body)
}

pub fn parse_upload_part_copy_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(UploadPartCopyOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_upload_part_copy_output("{}")
        _ -> decode_upload_part_copy_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub type WriteGetObjectResponseOutput {
  WriteGetObjectResponseOutput
}

pub fn encode_write_get_object_response_output_struct(
  _v: WriteGetObjectResponseOutput,
) -> json.Json {
  json.object([])
}

pub fn decode_write_get_object_response_output_struct() -> decode.Decoder(
  WriteGetObjectResponseOutput,
) {
  decode.success(WriteGetObjectResponseOutput)
}

pub fn encode_write_get_object_response_input(
  input: WriteGetObjectResponseRequest,
) -> String {
  json.to_string(encode_write_get_object_response_request_struct(input))
}

pub fn decode_write_get_object_response_input(
  body: String,
) -> Result(WriteGetObjectResponseRequest, String) {
  case json.parse(body, decode_write_get_object_response_request_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn decode_write_get_object_response_output(
  body: String,
) -> Result(WriteGetObjectResponseOutput, String) {
  case json.parse(body, decode_write_get_object_response_output_struct()) {
    Ok(v) -> Ok(v)
    Error(_) -> Error("decode failed")
  }
}

pub fn encode_write_get_object_response_body(
  _input: WriteGetObjectResponseRequest,
) -> json.Json {
  json.object([])
}

pub fn build_write_get_object_response_request(
  input: WriteGetObjectResponseRequest,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let path = "/WriteGetObjectResponse"
  let query = ""
  let headers = dict.new()
  let headers = case input.accept_ranges {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-accept-ranges", v)
    option.None -> headers
  }
  let headers = case input.bucket_key_enabled {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-server-side-encryption-bucket-key-enabled",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.cache_control {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-Cache-Control", v)
    option.None -> headers
  }
  let headers = case input.checksum_crc32 {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-x-amz-checksum-crc32", v)
    option.None -> headers
  }
  let headers = case input.checksum_crc32_c {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-checksum-crc32c",
        v,
      )
    option.None -> headers
  }
  let headers = case input.checksum_crc64_nvme {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-checksum-crc64nvme",
        v,
      )
    option.None -> headers
  }
  let headers = case input.checksum_md5 {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-x-amz-checksum-md5", v)
    option.None -> headers
  }
  let headers = case input.checksum_sha1 {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-x-amz-checksum-sha1", v)
    option.None -> headers
  }
  let headers = case input.checksum_sha256 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-checksum-sha256",
        v,
      )
    option.None -> headers
  }
  let headers = case input.checksum_sha512 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-checksum-sha512",
        v,
      )
    option.None -> headers
  }
  let headers = case input.checksum_xxhash128 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-checksum-xxhash128",
        v,
      )
    option.None -> headers
  }
  let headers = case input.checksum_xxhash3 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-checksum-xxhash3",
        v,
      )
    option.None -> headers
  }
  let headers = case input.checksum_xxhash64 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-checksum-xxhash64",
        v,
      )
    option.None -> headers
  }
  let headers = case input.content_disposition {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-Content-Disposition", v)
    option.None -> headers
  }
  let headers = case input.content_encoding {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-Content-Encoding", v)
    option.None -> headers
  }
  let headers = case input.content_language {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-Content-Language", v)
    option.None -> headers
  }
  let headers = case input.content_length {
    option.Some(v) ->
      rest.maybe_set_header(headers, "Content-Length", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.content_range {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-Content-Range", v)
    option.None -> headers
  }
  let headers = case input.content_type {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-Content-Type", v)
    option.None -> headers
  }
  let headers = case input.delete_marker {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-delete-marker",
        rest.bool_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.e_tag {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-fwd-header-ETag", v)
    option.None -> headers
  }
  let headers = case input.error_code {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-fwd-error-code", v)
    option.None -> headers
  }
  let headers = case input.error_message {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-error-message", v)
    option.None -> headers
  }
  let headers = case input.expiration {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-x-amz-expiration", v)
    option.None -> headers
  }
  let headers = case input.expires {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-Expires", v)
    option.None -> headers
  }
  let headers = case input.last_modified {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-Last-Modified",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.missing_meta {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-missing-meta",
        rest.int_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_legal_hold_status {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-object-lock-legal-hold",
        rest.enum_wire_value(encode_object_lock_legal_hold_status_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_mode {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-object-lock-mode",
        rest.enum_wire_value(encode_object_lock_mode_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.object_lock_retain_until_date {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-object-lock-retain-until-date",
        rest.timestamp_to_header(v),
      )
    option.None -> headers
  }
  let headers = case input.parts_count {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-mp-parts-count",
        rest.int_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.replication_status {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-replication-status",
        rest.enum_wire_value(encode_replication_status_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.request_charged {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-request-charged",
        rest.enum_wire_value(encode_request_charged_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.request_route {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-request-route", v)
    option.None -> headers
  }
  let headers = case input.request_token {
    option.Some(v) -> rest.maybe_set_header(headers, "x-amz-request-token", v)
    option.None -> headers
  }
  let headers = case input.restore {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-x-amz-restore", v)
    option.None -> headers
  }
  let headers = case input.sse_customer_algorithm {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-server-side-encryption-customer-algorithm",
        v,
      )
    option.None -> headers
  }
  let headers = case input.sse_customer_key_md5 {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-server-side-encryption-customer-key-MD5",
        v,
      )
    option.None -> headers
  }
  let headers = case input.ssekms_key_id {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-server-side-encryption-aws-kms-key-id",
        v,
      )
    option.None -> headers
  }
  let headers = case input.server_side_encryption {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-server-side-encryption",
        rest.enum_wire_value(encode_server_side_encryption_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.status_code {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-status", rest.int_to_query(v))
    option.None -> headers
  }
  let headers = case input.storage_class {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-storage-class",
        rest.enum_wire_value(encode_storage_class_enum(v)),
      )
    option.None -> headers
  }
  let headers = case input.tag_count {
    option.Some(v) ->
      rest.maybe_set_header(
        headers,
        "x-amz-fwd-header-x-amz-tagging-count",
        rest.int_to_query(v),
      )
    option.None -> headers
  }
  let headers = case input.version_id {
    option.Some(v) ->
      rest.maybe_set_header(headers, "x-amz-fwd-header-x-amz-version-id", v)
    option.None -> headers
  }
  let headers = case input.metadata {
    option.Some(m) -> rest.add_prefix_headers(headers, "x-amz-meta-", m)
    option.None -> headers
  }
  let body = case input.body {
    option.Some(v) -> v
    option.None -> <<>>
  }
  let content_type = "application/octet-stream"
  let headers = case content_type {
    "" -> headers
    _ -> dict.insert(headers, "Content-Type", content_type)
  }
  let path = rest.build_path(path, query)
  #("POST", path, headers, body)
}

pub fn parse_write_get_object_response_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(WriteGetObjectResponseOutput, String) {
  case bit_array.to_string(body) {
    Ok(text) ->
      case text {
        "" -> decode_write_get_object_response_output("{}")
        _ -> decode_write_get_object_response_output(text)
      }
    Error(_) -> Error("non-utf8 body")
  }
}

pub fn abort_multipart_upload(
  client: Client,
  input: AbortMultipartUploadRequest,
) -> Result(AbortMultipartUploadOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_abort_multipart_upload_request(input),
    parse_abort_multipart_upload_response,
  )
}

pub fn complete_multipart_upload(
  client: Client,
  input: CompleteMultipartUploadRequest,
) -> Result(CompleteMultipartUploadOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_complete_multipart_upload_request(input),
    parse_complete_multipart_upload_response,
  )
}

pub fn copy_object(
  client: Client,
  input: CopyObjectRequest,
) -> Result(CopyObjectOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_copy_object_request(input),
    parse_copy_object_response,
  )
}

pub fn create_bucket(
  client: Client,
  input: CreateBucketRequest,
) -> Result(CreateBucketOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_create_bucket_request(input),
    parse_create_bucket_response,
  )
}

pub fn create_multipart_upload(
  client: Client,
  input: CreateMultipartUploadRequest,
) -> Result(CreateMultipartUploadOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_create_multipart_upload_request(input),
    parse_create_multipart_upload_response,
  )
}

pub fn create_session(
  client: Client,
  input: CreateSessionRequest,
) -> Result(CreateSessionOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_create_session_request(input),
    parse_create_session_response,
  )
}

pub fn delete_bucket(
  client: Client,
  input: DeleteBucketRequest,
) -> Result(DeleteBucketOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_request(input),
    parse_delete_bucket_response,
  )
}

pub fn delete_bucket_analytics_configuration(
  client: Client,
  input: DeleteBucketAnalyticsConfigurationRequest,
) -> Result(
  DeleteBucketAnalyticsConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_analytics_configuration_request(input),
    parse_delete_bucket_analytics_configuration_response,
  )
}

pub fn delete_bucket_cors(
  client: Client,
  input: DeleteBucketCorsRequest,
) -> Result(DeleteBucketCorsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_cors_request(input),
    parse_delete_bucket_cors_response,
  )
}

pub fn delete_bucket_encryption(
  client: Client,
  input: DeleteBucketEncryptionRequest,
) -> Result(DeleteBucketEncryptionOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_encryption_request(input),
    parse_delete_bucket_encryption_response,
  )
}

pub fn delete_bucket_intelligent_tiering_configuration(
  client: Client,
  input: DeleteBucketIntelligentTieringConfigurationRequest,
) -> Result(
  DeleteBucketIntelligentTieringConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_intelligent_tiering_configuration_request(input),
    parse_delete_bucket_intelligent_tiering_configuration_response,
  )
}

pub fn delete_bucket_inventory_configuration(
  client: Client,
  input: DeleteBucketInventoryConfigurationRequest,
) -> Result(
  DeleteBucketInventoryConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_inventory_configuration_request(input),
    parse_delete_bucket_inventory_configuration_response,
  )
}

pub fn delete_bucket_lifecycle(
  client: Client,
  input: DeleteBucketLifecycleRequest,
) -> Result(DeleteBucketLifecycleOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_lifecycle_request(input),
    parse_delete_bucket_lifecycle_response,
  )
}

pub fn delete_bucket_metadata_configuration(
  client: Client,
  input: DeleteBucketMetadataConfigurationRequest,
) -> Result(DeleteBucketMetadataConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_metadata_configuration_request(input),
    parse_delete_bucket_metadata_configuration_response,
  )
}

pub fn delete_bucket_metadata_table_configuration(
  client: Client,
  input: DeleteBucketMetadataTableConfigurationRequest,
) -> Result(
  DeleteBucketMetadataTableConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_metadata_table_configuration_request(input),
    parse_delete_bucket_metadata_table_configuration_response,
  )
}

pub fn delete_bucket_metrics_configuration(
  client: Client,
  input: DeleteBucketMetricsConfigurationRequest,
) -> Result(DeleteBucketMetricsConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_metrics_configuration_request(input),
    parse_delete_bucket_metrics_configuration_response,
  )
}

pub fn delete_bucket_ownership_controls(
  client: Client,
  input: DeleteBucketOwnershipControlsRequest,
) -> Result(DeleteBucketOwnershipControlsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_ownership_controls_request(input),
    parse_delete_bucket_ownership_controls_response,
  )
}

pub fn delete_bucket_policy(
  client: Client,
  input: DeleteBucketPolicyRequest,
) -> Result(DeleteBucketPolicyOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_policy_request(input),
    parse_delete_bucket_policy_response,
  )
}

pub fn delete_bucket_replication(
  client: Client,
  input: DeleteBucketReplicationRequest,
) -> Result(DeleteBucketReplicationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_replication_request(input),
    parse_delete_bucket_replication_response,
  )
}

pub fn delete_bucket_tagging(
  client: Client,
  input: DeleteBucketTaggingRequest,
) -> Result(DeleteBucketTaggingOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_tagging_request(input),
    parse_delete_bucket_tagging_response,
  )
}

pub fn delete_bucket_website(
  client: Client,
  input: DeleteBucketWebsiteRequest,
) -> Result(DeleteBucketWebsiteOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_bucket_website_request(input),
    parse_delete_bucket_website_response,
  )
}

pub fn delete_object(
  client: Client,
  input: DeleteObjectRequest,
) -> Result(DeleteObjectOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_object_request(input),
    parse_delete_object_response,
  )
}

pub fn delete_object_tagging(
  client: Client,
  input: DeleteObjectTaggingRequest,
) -> Result(DeleteObjectTaggingOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_object_tagging_request(input),
    parse_delete_object_tagging_response,
  )
}

pub fn delete_public_access_block(
  client: Client,
  input: DeletePublicAccessBlockRequest,
) -> Result(DeletePublicAccessBlockOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_delete_public_access_block_request(input),
    parse_delete_public_access_block_response,
  )
}

pub fn get_bucket_abac(
  client: Client,
  input: GetBucketAbacRequest,
) -> Result(GetBucketAbacOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_abac_request(input),
    parse_get_bucket_abac_response,
  )
}

pub fn get_bucket_accelerate_configuration(
  client: Client,
  input: GetBucketAccelerateConfigurationRequest,
) -> Result(GetBucketAccelerateConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_accelerate_configuration_request(input),
    parse_get_bucket_accelerate_configuration_response,
  )
}

pub fn get_bucket_acl(
  client: Client,
  input: GetBucketAclRequest,
) -> Result(GetBucketAclOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_acl_request(input),
    parse_get_bucket_acl_response,
  )
}

pub fn get_bucket_analytics_configuration(
  client: Client,
  input: GetBucketAnalyticsConfigurationRequest,
) -> Result(GetBucketAnalyticsConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_analytics_configuration_request(input),
    parse_get_bucket_analytics_configuration_response,
  )
}

pub fn get_bucket_cors(
  client: Client,
  input: GetBucketCorsRequest,
) -> Result(GetBucketCorsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_cors_request(input),
    parse_get_bucket_cors_response,
  )
}

pub fn get_bucket_encryption(
  client: Client,
  input: GetBucketEncryptionRequest,
) -> Result(GetBucketEncryptionOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_encryption_request(input),
    parse_get_bucket_encryption_response,
  )
}

pub fn get_bucket_intelligent_tiering_configuration(
  client: Client,
  input: GetBucketIntelligentTieringConfigurationRequest,
) -> Result(
  GetBucketIntelligentTieringConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_intelligent_tiering_configuration_request(input),
    parse_get_bucket_intelligent_tiering_configuration_response,
  )
}

pub fn get_bucket_inventory_configuration(
  client: Client,
  input: GetBucketInventoryConfigurationRequest,
) -> Result(GetBucketInventoryConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_inventory_configuration_request(input),
    parse_get_bucket_inventory_configuration_response,
  )
}

pub fn get_bucket_lifecycle_configuration(
  client: Client,
  input: GetBucketLifecycleConfigurationRequest,
) -> Result(GetBucketLifecycleConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_lifecycle_configuration_request(input),
    parse_get_bucket_lifecycle_configuration_response,
  )
}

pub fn get_bucket_location(
  client: Client,
  input: GetBucketLocationRequest,
) -> Result(GetBucketLocationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_location_request(input),
    parse_get_bucket_location_response,
  )
}

pub fn get_bucket_logging(
  client: Client,
  input: GetBucketLoggingRequest,
) -> Result(GetBucketLoggingOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_logging_request(input),
    parse_get_bucket_logging_response,
  )
}

pub fn get_bucket_metadata_configuration(
  client: Client,
  input: GetBucketMetadataConfigurationRequest,
) -> Result(GetBucketMetadataConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_metadata_configuration_request(input),
    parse_get_bucket_metadata_configuration_response,
  )
}

pub fn get_bucket_metadata_table_configuration(
  client: Client,
  input: GetBucketMetadataTableConfigurationRequest,
) -> Result(
  GetBucketMetadataTableConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_metadata_table_configuration_request(input),
    parse_get_bucket_metadata_table_configuration_response,
  )
}

pub fn get_bucket_metrics_configuration(
  client: Client,
  input: GetBucketMetricsConfigurationRequest,
) -> Result(GetBucketMetricsConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_metrics_configuration_request(input),
    parse_get_bucket_metrics_configuration_response,
  )
}

pub fn get_bucket_notification_configuration(
  client: Client,
  input: GetBucketNotificationConfigurationRequest,
) -> Result(NotificationConfiguration, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_notification_configuration_request(input),
    parse_get_bucket_notification_configuration_response,
  )
}

pub fn get_bucket_ownership_controls(
  client: Client,
  input: GetBucketOwnershipControlsRequest,
) -> Result(GetBucketOwnershipControlsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_ownership_controls_request(input),
    parse_get_bucket_ownership_controls_response,
  )
}

pub fn get_bucket_policy(
  client: Client,
  input: GetBucketPolicyRequest,
) -> Result(GetBucketPolicyOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_policy_request(input),
    parse_get_bucket_policy_response,
  )
}

pub fn get_bucket_policy_status(
  client: Client,
  input: GetBucketPolicyStatusRequest,
) -> Result(GetBucketPolicyStatusOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_policy_status_request(input),
    parse_get_bucket_policy_status_response,
  )
}

pub fn get_bucket_replication(
  client: Client,
  input: GetBucketReplicationRequest,
) -> Result(GetBucketReplicationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_replication_request(input),
    parse_get_bucket_replication_response,
  )
}

pub fn get_bucket_request_payment(
  client: Client,
  input: GetBucketRequestPaymentRequest,
) -> Result(GetBucketRequestPaymentOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_request_payment_request(input),
    parse_get_bucket_request_payment_response,
  )
}

pub fn get_bucket_tagging(
  client: Client,
  input: GetBucketTaggingRequest,
) -> Result(GetBucketTaggingOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_tagging_request(input),
    parse_get_bucket_tagging_response,
  )
}

pub fn get_bucket_versioning(
  client: Client,
  input: GetBucketVersioningRequest,
) -> Result(GetBucketVersioningOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_versioning_request(input),
    parse_get_bucket_versioning_response,
  )
}

pub fn get_bucket_website(
  client: Client,
  input: GetBucketWebsiteRequest,
) -> Result(GetBucketWebsiteOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_bucket_website_request(input),
    parse_get_bucket_website_response,
  )
}

pub fn get_object_acl(
  client: Client,
  input: GetObjectAclRequest,
) -> Result(GetObjectAclOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_object_acl_request(input),
    parse_get_object_acl_response,
  )
}

pub fn get_object_attributes(
  client: Client,
  input: GetObjectAttributesRequest,
) -> Result(GetObjectAttributesOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_object_attributes_request(input),
    parse_get_object_attributes_response,
  )
}

pub fn get_object_legal_hold(
  client: Client,
  input: GetObjectLegalHoldRequest,
) -> Result(GetObjectLegalHoldOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_object_legal_hold_request(input),
    parse_get_object_legal_hold_response,
  )
}

pub fn get_object_lock_configuration(
  client: Client,
  input: GetObjectLockConfigurationRequest,
) -> Result(GetObjectLockConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_object_lock_configuration_request(input),
    parse_get_object_lock_configuration_response,
  )
}

pub fn get_object_retention(
  client: Client,
  input: GetObjectRetentionRequest,
) -> Result(GetObjectRetentionOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_object_retention_request(input),
    parse_get_object_retention_response,
  )
}

pub fn get_object_tagging(
  client: Client,
  input: GetObjectTaggingRequest,
) -> Result(GetObjectTaggingOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_object_tagging_request(input),
    parse_get_object_tagging_response,
  )
}

pub fn get_object_torrent(
  client: Client,
  input: GetObjectTorrentRequest,
) -> Result(GetObjectTorrentOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_object_torrent_request(input),
    parse_get_object_torrent_response,
  )
}

pub fn get_public_access_block(
  client: Client,
  input: GetPublicAccessBlockRequest,
) -> Result(GetPublicAccessBlockOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_get_public_access_block_request(input),
    parse_get_public_access_block_response,
  )
}

pub fn head_bucket(
  client: Client,
  input: HeadBucketRequest,
) -> Result(HeadBucketOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_head_bucket_request(input),
    parse_head_bucket_response,
  )
}

pub fn head_object(
  client: Client,
  input: HeadObjectRequest,
) -> Result(HeadObjectOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_head_object_request(input),
    parse_head_object_response,
  )
}

pub fn list_bucket_analytics_configurations(
  client: Client,
  input: ListBucketAnalyticsConfigurationsRequest,
) -> Result(ListBucketAnalyticsConfigurationsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_bucket_analytics_configurations_request(input),
    parse_list_bucket_analytics_configurations_response,
  )
}

pub fn list_bucket_intelligent_tiering_configurations(
  client: Client,
  input: ListBucketIntelligentTieringConfigurationsRequest,
) -> Result(
  ListBucketIntelligentTieringConfigurationsOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_list_bucket_intelligent_tiering_configurations_request(input),
    parse_list_bucket_intelligent_tiering_configurations_response,
  )
}

pub fn list_bucket_inventory_configurations(
  client: Client,
  input: ListBucketInventoryConfigurationsRequest,
) -> Result(ListBucketInventoryConfigurationsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_bucket_inventory_configurations_request(input),
    parse_list_bucket_inventory_configurations_response,
  )
}

pub fn list_bucket_metrics_configurations(
  client: Client,
  input: ListBucketMetricsConfigurationsRequest,
) -> Result(ListBucketMetricsConfigurationsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_bucket_metrics_configurations_request(input),
    parse_list_bucket_metrics_configurations_response,
  )
}

pub fn list_buckets(
  client: Client,
  input: ListBucketsRequest,
) -> Result(ListBucketsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_buckets_request(input),
    parse_list_buckets_response,
  )
}

pub fn list_directory_buckets(
  client: Client,
  input: ListDirectoryBucketsRequest,
) -> Result(ListDirectoryBucketsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_directory_buckets_request(input),
    parse_list_directory_buckets_response,
  )
}

pub fn list_multipart_uploads(
  client: Client,
  input: ListMultipartUploadsRequest,
) -> Result(ListMultipartUploadsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_multipart_uploads_request(input),
    parse_list_multipart_uploads_response,
  )
}

pub fn list_objects(
  client: Client,
  input: ListObjectsRequest,
) -> Result(ListObjectsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_objects_request(input),
    parse_list_objects_response,
  )
}

pub fn list_objects_v2(
  client: Client,
  input: ListObjectsV2Request,
) -> Result(ListObjectsV2Output, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_objects_v2_request(input),
    parse_list_objects_v2_response,
  )
}

pub fn list_object_versions(
  client: Client,
  input: ListObjectVersionsRequest,
) -> Result(ListObjectVersionsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_object_versions_request(input),
    parse_list_object_versions_response,
  )
}

pub fn list_parts(
  client: Client,
  input: ListPartsRequest,
) -> Result(ListPartsOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_list_parts_request(input),
    parse_list_parts_response,
  )
}

pub fn put_bucket_analytics_configuration(
  client: Client,
  input: PutBucketAnalyticsConfigurationRequest,
) -> Result(PutBucketAnalyticsConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_put_bucket_analytics_configuration_request(input),
    parse_put_bucket_analytics_configuration_response,
  )
}

pub fn put_bucket_intelligent_tiering_configuration(
  client: Client,
  input: PutBucketIntelligentTieringConfigurationRequest,
) -> Result(
  PutBucketIntelligentTieringConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_put_bucket_intelligent_tiering_configuration_request(input),
    parse_put_bucket_intelligent_tiering_configuration_response,
  )
}

pub fn put_bucket_inventory_configuration(
  client: Client,
  input: PutBucketInventoryConfigurationRequest,
) -> Result(PutBucketInventoryConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_put_bucket_inventory_configuration_request(input),
    parse_put_bucket_inventory_configuration_response,
  )
}

pub fn put_bucket_metrics_configuration(
  client: Client,
  input: PutBucketMetricsConfigurationRequest,
) -> Result(PutBucketMetricsConfigurationOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_put_bucket_metrics_configuration_request(input),
    parse_put_bucket_metrics_configuration_response,
  )
}

pub fn put_bucket_notification_configuration(
  client: Client,
  input: PutBucketNotificationConfigurationRequest,
) -> Result(
  PutBucketNotificationConfigurationOutput,
  awsjson_client.ClientError,
) {
  awsjson_client.invoke(
    client.config,
    build_put_bucket_notification_configuration_request(input),
    parse_put_bucket_notification_configuration_response,
  )
}

pub fn rename_object(
  client: Client,
  input: RenameObjectRequest,
) -> Result(RenameObjectOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_rename_object_request(input),
    parse_rename_object_response,
  )
}

pub fn select_object_content(
  client: Client,
  input: SelectObjectContentRequest,
) -> Result(SelectObjectContentOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_select_object_content_request(input),
    parse_select_object_content_response,
  )
}

pub fn upload_part_copy(
  client: Client,
  input: UploadPartCopyRequest,
) -> Result(UploadPartCopyOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_upload_part_copy_request(input),
    parse_upload_part_copy_response,
  )
}

pub fn write_get_object_response(
  client: Client,
  input: WriteGetObjectResponseRequest,
) -> Result(WriteGetObjectResponseOutput, awsjson_client.ClientError) {
  awsjson_client.invoke(
    client.config,
    build_write_get_object_response_request(input),
    parse_write_get_object_response_response,
  )
}
