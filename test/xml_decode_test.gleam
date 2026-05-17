import aws/internal/codec/xml_decode
import aws/services/s3
import gleam/option
import gleeunit/should

const list_buckets_xml: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListAllMyBucketsResult>
  <Buckets>
    <Bucket>
      <Name>my-test-bucket</Name>
      <CreationDate>1700000000</CreationDate>
    </Bucket>
    <Bucket>
      <Name>second-bucket</Name>
      <CreationDate>1710000000</CreationDate>
    </Bucket>
  </Buckets>
  <Owner>
    <ID>abc123</ID>
    <DisplayName>example-user</DisplayName>
  </Owner>
</ListAllMyBucketsResult>"

pub fn parse_simple_xml_test() {
  let assert Ok(root) = xml_decode.parse("<Hello><World>hi</World></Hello>")
  should.equal(root.name, "Hello")
  let assert option.Some(world) = xml_decode.find_child(root, "World")
  should.equal(xml_decode.text_content(world), "hi")
}

pub fn parse_attrs_test() {
  let assert Ok(root) =
    xml_decode.parse("<Foo attr1=\"a\" attr2=\"b\"><Bar/></Foo>")
  should.equal(xml_decode.attr(root, "attr1"), option.Some("a"))
  should.equal(xml_decode.attr(root, "attr2"), option.Some("b"))
  should.equal(xml_decode.attr(root, "missing"), option.None)
}

pub fn parse_repeated_children_test() {
  let assert Ok(root) =
    xml_decode.parse("<List><Item>1</Item><Item>2</Item><Item>3</Item></List>")
  let items = xml_decode.find_children(root, "Item")
  should.equal(items |> list_length, 3)
}

const list_objects_xml: String = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<ListBucketResult>
  <Name>my-bucket</Name>
  <Prefix>photos/</Prefix>
  <Marker></Marker>
  <MaxKeys>1000</MaxKeys>
  <IsTruncated>false</IsTruncated>
  <Contents>
    <Key>photos/cat.jpg</Key>
    <Size>10240</Size>
  </Contents>
  <Contents>
    <Key>photos/dog.jpg</Key>
    <Size>20480</Size>
  </Contents>
  <CommonPrefixes>
    <Prefix>photos/2024/</Prefix>
  </CommonPrefixes>
  <CommonPrefixes>
    <Prefix>photos/2025/</Prefix>
  </CommonPrefixes>
</ListBucketResult>"

pub fn decode_flattened_list_test() {
  // S3's ListObjects response has `Contents` and `CommonPrefixes` as
  // `@xmlFlattened` lists — repeated siblings of the parent, NOT wrapped
  // in a `<Contents>...<member>...</member>` envelope. The codegen must
  // emit `optional_flat_list` rather than `optional_list` for these,
  // otherwise the Gleam record receives `None` even though the server
  // sent two entries.
  let assert Ok(root) = xml_decode.parse(list_objects_xml)
  let assert Ok(out) = s3.decode_list_objects_output_xml(root)

  let assert option.Some(contents) = out.contents
  list_length(contents) |> should.equal(2)
  let assert [first, ..] = contents
  first.key |> should.equal(option.Some("photos/cat.jpg"))

  let assert option.Some(prefixes) = out.common_prefixes
  list_length(prefixes) |> should.equal(2)
}

pub fn decode_list_buckets_output_test() {
  let assert Ok(root) = xml_decode.parse(list_buckets_xml)
  let assert Ok(out) = s3.decode_list_buckets_output_xml(root)
  let assert option.Some(buckets) = out.buckets
  should.equal(list_length(buckets), 2)
  let assert [first, ..] = buckets
  should.equal(first.name, option.Some("my-test-bucket"))
  should.equal(first.creation_date, option.Some(1_700_000_000))
  let assert option.Some(owner) = out.owner
  should.equal(owner.id, option.Some("abc123"))
  should.equal(owner.display_name, option.Some("example-user"))
}

fn list_length(xs: List(a)) -> Int {
  do_length(xs, 0)
}

fn do_length(xs: List(a), acc: Int) -> Int {
  case xs {
    [] -> acc
    [_, ..rest] -> do_length(rest, acc + 1)
  }
}
