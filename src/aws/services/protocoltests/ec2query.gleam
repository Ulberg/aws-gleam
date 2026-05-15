//// Generated from aws.protocoltests.ec2#AwsEc2 (ec2Query).
//// DO NOT EDIT. Re-generate via the codegen subproject.

import gleam/dict

pub type DatetimeOffsetsInput {
  DatetimeOffsetsInput
}

pub type DatetimeOffsetsOutput {
  DatetimeOffsetsOutput
}

pub fn build_datetime_offsets_request(
  _input: DatetimeOffsetsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=DatetimeOffsets&Version=2020-01-08">>)
}

pub fn parse_datetime_offsets_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(DatetimeOffsetsOutput, String) {
  Ok(DatetimeOffsetsOutput)
}

pub type EmptyInputAndEmptyOutputInput {
  EmptyInputAndEmptyOutputInput
}

pub type EmptyInputAndEmptyOutputOutput {
  EmptyInputAndEmptyOutputOutput
}

pub fn build_empty_input_and_empty_output_request(
  _input: EmptyInputAndEmptyOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<
    "Action=EmptyInputAndEmptyOutput&Version=2020-01-08",
  >>)
}

pub fn parse_empty_input_and_empty_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EmptyInputAndEmptyOutputOutput, String) {
  Ok(EmptyInputAndEmptyOutputOutput)
}

pub type EndpointOperationInput {
  EndpointOperationInput
}

pub type EndpointOperationOutput {
  EndpointOperationOutput
}

pub fn build_endpoint_operation_request(
  _input: EndpointOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=EndpointOperation&Version=2020-01-08">>)
}

pub fn parse_endpoint_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(EndpointOperationOutput, String) {
  Ok(EndpointOperationOutput)
}

pub type FractionalSecondsInput {
  FractionalSecondsInput
}

pub type FractionalSecondsOutput {
  FractionalSecondsOutput
}

pub fn build_fractional_seconds_request(
  _input: FractionalSecondsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=FractionalSeconds&Version=2020-01-08">>)
}

pub fn parse_fractional_seconds_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(FractionalSecondsOutput, String) {
  Ok(FractionalSecondsOutput)
}

pub type GreetingWithErrorsInput {
  GreetingWithErrorsInput
}

pub type GreetingWithErrorsOutput {
  GreetingWithErrorsOutput
}

pub fn build_greeting_with_errors_request(
  _input: GreetingWithErrorsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=GreetingWithErrors&Version=2020-01-08">>)
}

pub fn parse_greeting_with_errors_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(GreetingWithErrorsOutput, String) {
  Ok(GreetingWithErrorsOutput)
}

pub type HostWithPathOperationInput {
  HostWithPathOperationInput
}

pub type HostWithPathOperationOutput {
  HostWithPathOperationOutput
}

pub fn build_host_with_path_operation_request(
  _input: HostWithPathOperationInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=HostWithPathOperation&Version=2020-01-08">>)
}

pub fn parse_host_with_path_operation_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(HostWithPathOperationOutput, String) {
  Ok(HostWithPathOperationOutput)
}

pub type IgnoresWrappingXmlNameInput {
  IgnoresWrappingXmlNameInput
}

pub type IgnoresWrappingXmlNameOutput {
  IgnoresWrappingXmlNameOutput
}

pub fn build_ignores_wrapping_xml_name_request(
  _input: IgnoresWrappingXmlNameInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=IgnoresWrappingXmlName&Version=2020-01-08">>)
}

pub fn parse_ignores_wrapping_xml_name_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(IgnoresWrappingXmlNameOutput, String) {
  Ok(IgnoresWrappingXmlNameOutput)
}

pub type NoInputAndOutputInput {
  NoInputAndOutputInput
}

pub type NoInputAndOutputOutput {
  NoInputAndOutputOutput
}

pub fn build_no_input_and_output_request(
  _input: NoInputAndOutputInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=NoInputAndOutput&Version=2020-01-08">>)
}

pub fn parse_no_input_and_output_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(NoInputAndOutputOutput, String) {
  Ok(NoInputAndOutputOutput)
}

pub type RecursiveXmlShapesInput {
  RecursiveXmlShapesInput
}

pub type RecursiveXmlShapesOutput {
  RecursiveXmlShapesOutput
}

pub fn build_recursive_xml_shapes_request(
  _input: RecursiveXmlShapesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=RecursiveXmlShapes&Version=2020-01-08">>)
}

pub fn parse_recursive_xml_shapes_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(RecursiveXmlShapesOutput, String) {
  Ok(RecursiveXmlShapesOutput)
}

pub type SimpleScalarXmlPropertiesInput {
  SimpleScalarXmlPropertiesInput
}

pub type SimpleScalarXmlPropertiesOutput {
  SimpleScalarXmlPropertiesOutput
}

pub fn build_simple_scalar_xml_properties_request(
  _input: SimpleScalarXmlPropertiesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<
    "Action=SimpleScalarXmlProperties&Version=2020-01-08",
  >>)
}

pub fn parse_simple_scalar_xml_properties_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(SimpleScalarXmlPropertiesOutput, String) {
  Ok(SimpleScalarXmlPropertiesOutput)
}

pub type XmlBlobsInput {
  XmlBlobsInput
}

pub type XmlBlobsOutput {
  XmlBlobsOutput
}

pub fn build_xml_blobs_request(
  _input: XmlBlobsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlBlobs&Version=2020-01-08">>)
}

pub fn parse_xml_blobs_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlBlobsOutput, String) {
  Ok(XmlBlobsOutput)
}

pub type XmlEmptyBlobsInput {
  XmlEmptyBlobsInput
}

pub type XmlEmptyBlobsOutput {
  XmlEmptyBlobsOutput
}

pub fn build_xml_empty_blobs_request(
  _input: XmlEmptyBlobsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlEmptyBlobs&Version=2020-01-08">>)
}

pub fn parse_xml_empty_blobs_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlEmptyBlobsOutput, String) {
  Ok(XmlEmptyBlobsOutput)
}

pub type XmlEmptyListsInput {
  XmlEmptyListsInput
}

pub type XmlEmptyListsOutput {
  XmlEmptyListsOutput
}

pub fn build_xml_empty_lists_request(
  _input: XmlEmptyListsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlEmptyLists&Version=2020-01-08">>)
}

pub fn parse_xml_empty_lists_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlEmptyListsOutput, String) {
  Ok(XmlEmptyListsOutput)
}

pub type XmlEnumsInput {
  XmlEnumsInput
}

pub type XmlEnumsOutput {
  XmlEnumsOutput
}

pub fn build_xml_enums_request(
  _input: XmlEnumsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlEnums&Version=2020-01-08">>)
}

pub fn parse_xml_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlEnumsOutput, String) {
  Ok(XmlEnumsOutput)
}

pub type XmlIntEnumsInput {
  XmlIntEnumsInput
}

pub type XmlIntEnumsOutput {
  XmlIntEnumsOutput
}

pub fn build_xml_int_enums_request(
  _input: XmlIntEnumsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlIntEnums&Version=2020-01-08">>)
}

pub fn parse_xml_int_enums_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlIntEnumsOutput, String) {
  Ok(XmlIntEnumsOutput)
}

pub type XmlListsInput {
  XmlListsInput
}

pub type XmlListsOutput {
  XmlListsOutput
}

pub fn build_xml_lists_request(
  _input: XmlListsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlLists&Version=2020-01-08">>)
}

pub fn parse_xml_lists_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlListsOutput, String) {
  Ok(XmlListsOutput)
}

pub type XmlNamespacesInput {
  XmlNamespacesInput
}

pub type XmlNamespacesOutput {
  XmlNamespacesOutput
}

pub fn build_xml_namespaces_request(
  _input: XmlNamespacesInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlNamespaces&Version=2020-01-08">>)
}

pub fn parse_xml_namespaces_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlNamespacesOutput, String) {
  Ok(XmlNamespacesOutput)
}

pub type XmlTimestampsInput {
  XmlTimestampsInput
}

pub type XmlTimestampsOutput {
  XmlTimestampsOutput
}

pub fn build_xml_timestamps_request(
  _input: XmlTimestampsInput,
) -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([#("Content-Type", "application/x-www-form-urlencoded")])
  #("POST", "/", headers, <<"Action=XmlTimestamps&Version=2020-01-08">>)
}

pub fn parse_xml_timestamps_response(
  _code: Int,
  _headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(XmlTimestampsOutput, String) {
  Ok(XmlTimestampsOutput)
}
