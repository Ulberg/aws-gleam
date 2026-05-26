//// LocalStack-backed end-to-end test for the v0.1 S3 path.
////
//// CLAUDE.md names `S3.GetObject` as the gate operation, but
//// `get_object` is checksum-gated at the emitter level —
//// `aws.protocols#httpChecksum` makes the codegen skip it until the
//// checksum middleware lands (v0.2). Until then, `create_bucket` +
//// `list_buckets` + `delete_bucket` exercises the same end-to-end
//// path: typed input → restXml body → SigV4 signing → HTTP send →
//// xmlerl-backed XML decoder → typed output.
////
//// The test is gated on `INCLUDE_LOCALSTACK=1` in the environment.

import aws/config
import aws/services/s3
import gleam/list
import gleam/option.{None, Some}
import gleeunit/should
import support/localstack

const region: String = "us-east-1"

const bucket_name: String = "aws-sdk-gleam-e2e"

fn build_client(endpoint: String) -> s3.Client {
  // `endpoint_url` overrides the rule-set-derived URL — needed for
  // LocalStack since the embedded S3 rule set knows nothing about a
  // `localhost:4566` host.
  let assert Ok(client) =
    s3.new_with(
      config.Settings(
        ..config.default_settings(),
        region: Some(region),
        credentials: Some(localstack.fake_credentials()),
        endpoint_url: Some(endpoint),
      ),
    )
  client
}

fn create_bucket_input() -> s3.CreateBucketRequest {
  s3.CreateBucketRequest(
    acl: None,
    bucket: Some(bucket_name),
    bucket_namespace: None,
    create_bucket_configuration: None,
    grant_full_control: None,
    grant_read: None,
    grant_read_acp: None,
    grant_write: None,
    grant_write_acp: None,
    object_lock_enabled_for_bucket: None,
    object_ownership: None,
  )
}

fn list_buckets_input() -> s3.ListBucketsRequest {
  s3.ListBucketsRequest(
    bucket_region: None,
    continuation_token: None,
    max_buckets: None,
    prefix: None,
  )
}

fn delete_bucket_input() -> s3.DeleteBucketRequest {
  s3.DeleteBucketRequest(bucket: Some(bucket_name), expected_bucket_owner: None)
}

pub fn s3_create_list_delete_bucket_round_trip_test() {
  use container <- localstack.when_enabled
  let client = build_client(container.endpoint)
  let assert Ok(_) = s3.create_bucket(client, create_bucket_input())

  let assert Ok(out) = s3.list_buckets(client, list_buckets_input())
  let assert Some(buckets) = out.buckets
  let names = list.filter_map(buckets, fn(b) { option.to_result(b.name, Nil) })
  list.contains(names, bucket_name) |> should.be_true

  let assert Ok(_) = s3.delete_bucket(client, delete_bucket_input())
  s3.shutdown(client)
}
