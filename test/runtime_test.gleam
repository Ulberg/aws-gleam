//// Runtime middleware tests: assert that `runtime.invoke` wires the
//// retry strategy around the HTTP send, that the parse callback only
//// runs once on the final successful response, and that the
//// per-operation pipeline keeps working when the strategy is disabled.

import aws/credentials
import aws/endpoints
import aws/internal/client/runtime
import aws/internal/http_send
import aws/retry
import gleam/bit_array
import gleam/dict
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/list
import gleam/option.{None}
import gleeunit/should

// ---------- helpers ----------

fn static_credentials() -> credentials.Provider {
  credentials.static_provider(credentials.Credentials(
    access_key_id: "AKIDEXAMPLE",
    secret_access_key: "wJalrXUtnFEMI/K7MDENG+bPxRfiCYEXAMPLEKEY",
    session_token: None,
    expires_at: None,
    source: "Static",
  ))
}

fn fixed_timestamp() -> String {
  "20150830T123600Z"
}

/// Zero-delay, zero-jitter test strategy so retry loops finish instantly.
fn no_wait_strategy(max_attempts: Int) -> retry.Strategy {
  retry.standard_with(
    max_attempts: max_attempts,
    base_delay_ms: 0,
    max_delay_ms: 0,
    sleep: fn(_ms) { Nil },
    rng: fn() { 0.0 },
  )
}

fn one_attempt_strategy() -> retry.Strategy {
  no_wait_strategy(1)
}

fn ok_response(status: Int, body: BitArray) -> response.Response(BitArray) {
  response.Response(status: status, headers: [], body: body)
}

/// Build a `Send` that returns a scripted sequence of results, recording each
/// invocation into the supplied subject for assertion.
fn scripted_send(
  script: List(Result(response.Response(BitArray), http_send.HttpError)),
  counter: process.Subject(Int),
) -> http_send.Send {
  let script_subject = process.new_subject()
  list.each(script, fn(item) { process.send(script_subject, item) })
  fn(_req: Request(BitArray)) {
    process.send(counter, 1)
    case process.receive(script_subject, 0) {
      Ok(item) -> item
      Error(_) ->
        Error(http_send.ConnectFailed(reason: "scripted send exhausted"))
    }
  }
}

fn count_messages(subject: process.Subject(Int), acc: Int) -> Int {
  case process.receive(subject, 0) {
    Ok(_) -> count_messages(subject, acc + 1)
    Error(_) -> acc
  }
}

fn test_config(
  send: http_send.Send,
  strategy: retry.Strategy,
) -> runtime.ClientConfig {
  runtime.ClientConfig(
    provider: static_credentials(),
    region: "us-east-1",
    endpoint_prefix: "service",
    signing_name: "service",
    endpoint_url: "https://service.us-east-1.amazonaws.com",
    http_send: send,
    streaming_http_send: http_send.default_streaming_send,
    timestamp: fixed_timestamp,
    retry_strategy: strategy,
    endpoint_rule_set: None,
    endpoint_params: dict.new(),
  )
}

fn echo_parse(
  _status: Int,
  _headers: dict.Dict(String, String),
  body: BitArray,
) -> Result(String, String) {
  case bit_array.to_string(body) {
    Ok(s) -> Ok(s)
    Error(_) -> Error("non-utf8 body")
  }
}

fn ddb_request() -> #(String, String, dict.Dict(String, String), BitArray) {
  let headers =
    dict.from_list([
      #("content-type", "application/x-amz-json-1.0"),
      #("x-amz-target", "DynamoDB_20120810.GetItem"),
    ])
  #("POST", "/", headers, <<"{}":utf8>>)
}

// ---------- tests ----------

pub fn invoke_succeeds_on_first_call_with_one_attempt_test() {
  let counter = process.new_subject()
  let send = scripted_send([Ok(ok_response(200, <<"hello":utf8>>))], counter)
  let config = test_config(send, one_attempt_strategy())

  runtime.invoke(config, ddb_request(), echo_parse)
  |> should.equal(Ok("hello"))

  count_messages(counter, 0) |> should.equal(1)
}

pub fn invoke_retries_through_500_then_succeeds_test() {
  // Standard retry mode (max_attempts: 3) should swallow one 500 before
  // surfacing the successful 200 to the parser.
  let counter = process.new_subject()
  let send =
    scripted_send(
      [
        Ok(ok_response(500, <<"":utf8>>)),
        Ok(ok_response(200, <<"after-retry":utf8>>)),
      ],
      counter,
    )
  let config = test_config(send, no_wait_strategy(3))

  runtime.invoke(config, ddb_request(), echo_parse)
  |> should.equal(Ok("after-retry"))

  count_messages(counter, 0) |> should.equal(2)
}

pub fn invoke_retries_transport_error_then_succeeds_test() {
  // Transport-class errors (e.g. ConnectFailed) are TransientError; they
  // should also be retried.
  let counter = process.new_subject()
  let send =
    scripted_send(
      [
        Error(http_send.ConnectFailed(reason: "boom")),
        Ok(ok_response(200, <<"recovered":utf8>>)),
      ],
      counter,
    )
  let config = test_config(send, no_wait_strategy(3))

  runtime.invoke(config, ddb_request(), echo_parse)
  |> should.equal(Ok("recovered"))

  count_messages(counter, 0) |> should.equal(2)
}

pub fn invoke_does_not_retry_non_retryable_status_test() {
  // 400-class responses (non-throttle) should pass straight through as a
  // ServiceError — exactly one HTTP attempt, no backoff loop.
  let counter = process.new_subject()
  let send = scripted_send([Ok(ok_response(400, <<"":utf8>>))], counter)
  let config = test_config(send, no_wait_strategy(3))

  let result = runtime.invoke(config, ddb_request(), echo_parse)
  case result {
    Error(runtime.ServiceError(status: 400, ..)) -> Nil
    other -> panic as { "expected ServiceError(400), got: " <> describe(other) }
  }

  count_messages(counter, 0) |> should.equal(1)
}

pub fn invoke_stops_at_max_attempts_test() {
  // Three 503s with max_attempts=3 should produce exactly three HTTP
  // attempts and surface the last response as ServiceError.
  let counter = process.new_subject()
  let send =
    scripted_send(
      [
        Ok(ok_response(503, <<"":utf8>>)),
        Ok(ok_response(503, <<"":utf8>>)),
        Ok(ok_response(503, <<"":utf8>>)),
      ],
      counter,
    )
  let config = test_config(send, no_wait_strategy(3))

  let result = runtime.invoke(config, ddb_request(), echo_parse)
  case result {
    Error(runtime.ServiceError(status: 503, ..)) -> Nil
    other -> panic as { "expected ServiceError(503), got: " <> describe(other) }
  }

  count_messages(counter, 0) |> should.equal(3)
}

pub fn with_retry_strategy_overrides_default_test() {
  // Custom strategy with max_attempts=1 disables retry entirely. Even on
  // 503 the runtime should give up after the first attempt.
  let counter = process.new_subject()
  let send =
    scripted_send(
      [
        Ok(ok_response(503, <<"":utf8>>)),
        Ok(ok_response(200, <<"unreached":utf8>>)),
      ],
      counter,
    )
  let config =
    test_config(send, no_wait_strategy(3))
    |> runtime.with_retry_strategy(one_attempt_strategy())

  let result = runtime.invoke(config, ddb_request(), echo_parse)
  case result {
    Error(runtime.ServiceError(status: 503, ..)) -> Nil
    other -> panic as { "expected ServiceError(503), got: " <> describe(other) }
  }

  count_messages(counter, 0) |> should.equal(1)
}

// ---------- endpoint-resolver tests ----------

/// Minimal valid Smithy endpoint-rule-set JSON. Always returns the same
/// URL regardless of params — enough to prove the runtime invokes the
/// resolver and uses its output for the host header and final request URL.
const constant_rule_set_json: String = "
{
  \"version\": \"1.0\",
  \"parameters\": {
    \"Region\": {\"type\": \"String\", \"required\": true, \"builtIn\": \"AWS::Region\"}
  },
  \"rules\": [
    {
      \"type\": \"endpoint\",
      \"conditions\": [],
      \"endpoint\": {\"url\": \"https://override.example.com\"}
    }
  ]
}
"

/// Rule set that picks one of two URLs based on a `Bucket` parameter. Used
/// to verify per-op params actually drive the resolver.
const branching_rule_set_json: String = "
{
  \"version\": \"1.0\",
  \"parameters\": {
    \"Region\": {\"type\": \"String\", \"required\": true, \"builtIn\": \"AWS::Region\"},
    \"Bucket\": {\"type\": \"String\", \"required\": false}
  },
  \"rules\": [
    {
      \"type\": \"endpoint\",
      \"conditions\": [
        {\"fn\": \"isSet\", \"argv\": [{\"ref\": \"Bucket\"}]}
      ],
      \"endpoint\": {\"url\": \"https://{Bucket}.s3.example.com\"}
    },
    {
      \"type\": \"endpoint\",
      \"conditions\": [],
      \"endpoint\": {\"url\": \"https://s3.example.com\"}
    }
  ]
}
"

fn echo_host_parse(
  _status: Int,
  headers: dict.Dict(String, String),
  _body: BitArray,
) -> Result(String, String) {
  case dict.get(headers, "host") {
    Ok(h) -> Ok(h)
    Error(_) -> Error("no host in response")
  }
}

/// `Send` that echoes the request's `host` header back as a 200 response —
/// lets the test assert what URL the runtime actually constructed.
fn host_echo_send() -> http_send.Send {
  fn(req: Request(BitArray)) {
    // Surface the host header as a response header for the parse callback
    // to read; if it's missing we emit a 200 with empty body so the test
    // can assert on the failure path explicitly.
    let host = case list.find(req.headers, fn(h) { h.0 == "host" }) {
      Ok(#(_, v)) -> v
      Error(_) -> ""
    }
    Ok(response.Response(status: 200, headers: [#("host", host)], body: <<>>))
  }
}

pub fn invoke_uses_endpoint_url_when_no_rule_set_test() {
  let counter = process.new_subject()
  let _ = counter
  let config = test_config(host_echo_send(), one_attempt_strategy())

  runtime.invoke(config, ddb_request(), echo_host_parse)
  |> should.equal(Ok("service.us-east-1.amazonaws.com"))
}

pub fn invoke_uses_rule_set_when_attached_test() {
  // With a rule set attached, the runtime should ignore endpoint_url and
  // use the rule set's resolved URL instead.
  let assert Ok(rs) = endpoints.parse_rule_set(constant_rule_set_json)
  let config =
    test_config(host_echo_send(), one_attempt_strategy())
    |> runtime.with_endpoint_rule_set(rs)

  runtime.invoke(config, ddb_request(), echo_host_parse)
  |> should.equal(Ok("override.example.com"))
}

pub fn invoke_with_endpoint_params_threads_op_params_test() {
  // Per-op params (`Bucket`) only available at the operation layer must
  // flow through to the resolver — the runtime should produce a virtual-
  // hosted-style URL from the `Bucket` param.
  let assert Ok(rs) = endpoints.parse_rule_set(branching_rule_set_json)
  let config =
    test_config(host_echo_send(), one_attempt_strategy())
    |> runtime.with_endpoint_rule_set(rs)

  let op_params =
    dict.from_list([#("Bucket", endpoints.StringVal("acme-photos"))])

  runtime.invoke_with_endpoint_params(
    config,
    op_params,
    ddb_request(),
    echo_host_parse,
  )
  |> should.equal(Ok("acme-photos.s3.example.com"))
}

pub fn invoke_falls_through_to_default_when_op_params_missing_test() {
  // Without the `Bucket` param the rule set chooses the path-style branch.
  let assert Ok(rs) = endpoints.parse_rule_set(branching_rule_set_json)
  let config =
    test_config(host_echo_send(), one_attempt_strategy())
    |> runtime.with_endpoint_rule_set(rs)

  runtime.invoke(config, ddb_request(), echo_host_parse)
  |> should.equal(Ok("s3.example.com"))
}

pub fn with_endpoint_param_overrides_default_test() {
  // Client-level params merge with op params. Setting `Bucket` at the
  // client level should still resolve to the virtual-hosted URL.
  let assert Ok(rs) = endpoints.parse_rule_set(branching_rule_set_json)
  let config =
    test_config(host_echo_send(), one_attempt_strategy())
    |> runtime.with_endpoint_rule_set(rs)
    |> runtime.with_endpoint_param(
      "Bucket",
      endpoints.StringVal("default-bucket"),
    )

  runtime.invoke(config, ddb_request(), echo_host_parse)
  |> should.equal(Ok("default-bucket.s3.example.com"))
}

pub fn with_endpoint_url_threads_endpoint_param_into_rule_set_test() {
  // When a rule set is attached, calling `with_endpoint_url` must
  // surface the override through the rule set's standard `Endpoint`
  // parameter — otherwise the rule set ignores `endpoint_url` and
  // routes to its computed AWS host (the LocalStack / FIPS / custom-
  // DNS use case breaks if this contract slips).
  //
  // Rule set: branches on `Endpoint` being set; uses `{Endpoint}`
  // verbatim when present, falls back to a fixed AWS URL otherwise.
  let rs_json =
    "
  {
    \"version\": \"1.0\",
    \"parameters\": {
      \"Region\": {\"type\": \"String\", \"required\": true, \"builtIn\": \"AWS::Region\"},
      \"Endpoint\": {\"type\": \"String\", \"required\": false, \"builtIn\": \"SDK::Endpoint\"}
    },
    \"rules\": [
      {
        \"type\": \"endpoint\",
        \"conditions\": [{\"fn\": \"isSet\", \"argv\": [{\"ref\": \"Endpoint\"}]}],
        \"endpoint\": {\"url\": \"{Endpoint}\"}
      },
      {
        \"type\": \"endpoint\",
        \"conditions\": [],
        \"endpoint\": {\"url\": \"https://ignored.example.com\"}
      }
    ]
  }
  "
  let assert Ok(rs) = endpoints.parse_rule_set(rs_json)
  let config =
    test_config(host_echo_send(), one_attempt_strategy())
    |> runtime.with_endpoint_rule_set(rs)
    |> runtime.with_endpoint_url("https://override.example.com")

  runtime.invoke(config, ddb_request(), echo_host_parse)
  |> should.equal(Ok("override.example.com"))
}

pub fn op_params_override_client_level_params_test() {
  // Operation-specific params win over client-level params when both
  // supply the same key.
  let assert Ok(rs) = endpoints.parse_rule_set(branching_rule_set_json)
  let config =
    test_config(host_echo_send(), one_attempt_strategy())
    |> runtime.with_endpoint_rule_set(rs)
    |> runtime.with_endpoint_param(
      "Bucket",
      endpoints.StringVal("default-bucket"),
    )

  let op_params = dict.from_list([#("Bucket", endpoints.StringVal("override"))])
  runtime.invoke_with_endpoint_params(
    config,
    op_params,
    ddb_request(),
    echo_host_parse,
  )
  |> should.equal(Ok("override.s3.example.com"))
}

// ---------- error-extraction tests (restXml) ----------

pub fn restxml_error_body_surfaces_typed_error_code_test() {
  // S3-style `<Error><Code>NoSuchBucket</Code>...</Error>` body without
  // an `x-amzn-errortype` header. The runtime should pick `NoSuchBucket`
  // up via the XML path so the codegen's typed-error dispatcher can
  // resolve it.
  let counter = process.new_subject()
  let body = <<
    "<Error><Code>NoSuchBucket</Code><Message>...</Message></Error>":utf8,
  >>
  let send =
    scripted_send(
      [Ok(response.Response(status: 404, headers: [], body: body))],
      counter,
    )
  let config = test_config(send, one_attempt_strategy())

  case runtime.invoke(config, ddb_request(), echo_parse) {
    Error(runtime.ServiceError(status: 404, error_type: et, ..)) ->
      et |> should.equal("NoSuchBucket")
    other ->
      panic as { "expected ServiceError NoSuchBucket, got " <> describe(other) }
  }
}

pub fn restxml_error_response_wrapper_is_unwrapped_test() {
  // SQS/SNS-style `<ErrorResponse><Error><Code>X</Code>...</Error>...</ErrorResponse>`.
  // The first `<Code>` element still wins, regardless of wrapper.
  let counter = process.new_subject()
  let body = <<
    "<ErrorResponse><Error><Type>Sender</Type><Code>InvalidParameterValue</Code><Message>Bad</Message></Error></ErrorResponse>":utf8,
  >>
  let send =
    scripted_send(
      [Ok(response.Response(status: 400, headers: [], body: body))],
      counter,
    )
  let config = test_config(send, one_attempt_strategy())

  case runtime.invoke(config, ddb_request(), echo_parse) {
    Error(runtime.ServiceError(error_type: et, ..)) ->
      et |> should.equal("InvalidParameterValue")
    other ->
      panic as {
        "expected ServiceError InvalidParameterValue, got " <> describe(other)
      }
  }
}

pub fn header_error_type_still_wins_over_xml_test() {
  // When the response carries both an `x-amzn-errortype` header AND an
  // XML body, the header path wins — it is the canonical signal.
  let counter = process.new_subject()
  let body = <<"<Error><Code>FromXml</Code></Error>":utf8>>
  let send =
    scripted_send(
      [
        Ok(response.Response(
          status: 400,
          headers: [#("x-amzn-errortype", "FromHeader:https://...")],
          body: body,
        )),
      ],
      counter,
    )
  let config = test_config(send, one_attempt_strategy())

  case runtime.invoke(config, ddb_request(), echo_parse) {
    Error(runtime.ServiceError(error_type: et, ..)) ->
      et |> should.equal("FromHeader")
    other ->
      panic as { "expected ServiceError FromHeader, got " <> describe(other) }
  }
}

fn describe(r: Result(String, runtime.ClientError)) -> String {
  case r {
    Ok(s) -> "Ok(" <> s <> ")"
    Error(runtime.ServiceError(status: s, ..)) ->
      "ServiceError(" <> int_to_string(s) <> ")"
    Error(runtime.TransportError(_)) -> "TransportError(_)"
    Error(runtime.CredentialsError(_)) -> "CredentialsError(_)"
    Error(runtime.DecodeError(reason: r)) -> "DecodeError(" <> r <> ")"
  }
}

@external(erlang, "erlang", "integer_to_binary")
fn int_to_string(n: Int) -> String
