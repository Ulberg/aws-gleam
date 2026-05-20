//// Shared emitter for the per-service `Client` section. Every
//// generated service module ends up with the same shape — an
//// opaque `Client` type, a `new(region: ...)` constructor that uses
//// the default credentials chain, plus `with_*` knobs to override.
////
//// Lives in its own module so awsjson / restjson / restxml don't
//// each carry their own copy. The output is identical regardless of
//// protocol — only the endpoint prefix + signing name vary, so we
//// take those as parameters.

import codegen/code.{
  type Code, Blank, Call, CodeSome, Const, DocComment, Fn, Ident, LabelledParam,
  Let, LetAssert, Module, Param, StrLit, TypeDef, Use, Variant,
}
import codegen/trait_helpers.{type EndpointParam, BoolParam, StringParam}
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import internal/stringutils

/// Build the AST nodes for the per-service Client section. Pairs with
/// `code.render(code.Module(items))` at the emit site.
///
/// When `endpoint_rule_set_json` is `Some(json)`, the generated `new`
/// constructor parses the embedded JSON once and attaches the
/// resulting `RuleSet` to the client config, so per-request URL
/// resolution runs the official Smithy rule set. When `None` the
/// generated client uses the static `<prefix>.<region>.amazonaws.com`
/// URL the runtime defaults to.
pub fn items(
  endpoint_prefix: String,
  signing_name: String,
  endpoint_rule_set_json: Option(String),
  endpoint_param_setters: List(EndpointParam),
) -> List(Code) {
  // Common preamble for every Client constructor: build the default
  // config and start a per-Client credentials cache so the seven-stage
  // chain runs once at construction rather than per signed request.
  // The cache actor's `start` call cannot realistically fail (it is
  // just spawning an OTP actor) so `let assert` matches the
  // "generator-time invariant" pattern used elsewhere. The cache
  // subject is stashed on the `Client` value so `shutdown` can
  // release the actor cleanly.
  let cache_setup = [
    Let(
      name: "config",
      value: Call(Ident("runtime.default_config"), [
        Ident("region"),
        StrLit(endpoint_prefix),
        StrLit(signing_name),
      ]),
    ),
    LetAssert(
      pattern: "Ok(cache)",
      value: Call(Ident("credentials_cache.start_default"), [
        Ident("config.provider"),
      ]),
    ),
    Let(
      name: "config",
      value: Call(Ident("runtime.with_credentials_provider"), [
        Ident("config"),
        Call(Ident("credentials_cache.as_provider"), [Ident("cache")]),
      ]),
    ),
  ]
  // All `Client` constructions thread the same two labelled fields:
  // `config` and `cache`. Local helpers keep the call shape in one
  // place so adding a third field later is a single-spot edit.
  let client_with = fn(config_expr: Code, cache_expr: Code) -> Code {
    Call(Ident("Client"), [
      code.Labelled(label: "config", value: config_expr),
      code.Labelled(label: "cache", value: cache_expr),
    ])
  }
  let client_call = client_with(Ident("config"), Ident("cache"))
  let new_body = case endpoint_rule_set_json {
    None -> code.Block(items: list.flatten([cache_setup, [client_call]]))
    Some(_) ->
      // Parse the embedded rule set, then chain it onto the default
      // config. The `let assert` is justified because the JSON is a
      // codegen-time constant — if it ever fails to parse, that is a
      // generator bug rather than a runtime concern.
      code.Block(
        items: list.flatten([
          cache_setup,
          [
            LetAssert(
              pattern: "Ok(rule_set)",
              value: Call(Ident("endpoints.parse_rule_set"), [
                Ident("endpoint_rule_set_json"),
              ]),
            ),
            Let(
              name: "config",
              value: Call(Ident("runtime.with_endpoint_rule_set"), [
                Ident("config"),
                Ident("rule_set"),
              ]),
            ),
            client_call,
          ],
        ]),
      )
  }
  let rule_set_constant = case endpoint_rule_set_json {
    None -> []
    Some(json) -> [
      DocComment([
        "Smithy endpoint rule set for this service, lifted verbatim",
        "from the source model. Parsed once in `new` and attached to",
        "every Client via `runtime.with_endpoint_rule_set`.",
      ]),
      Const(
        name: "endpoint_rule_set_json",
        type_: "String",
        value: StrLit(json),
      ),
      Blank,
    ]
  }
  let header = [
    TypeDef(public: True, is_opaque: True, name: "Client", variants: [
      Variant(name: "Client", fields: [
        Param(name: "config", type_: "runtime.ClientConfig"),
        Param(name: "cache", type_: "credentials_cache.Cache"),
      ]),
    ]),
    Blank,
  ]
  let new_section = [
    DocComment([
      "Build a Client for an AWS region. Credentials resolve through",
      "the default chain (env → web-identity → SSO → profile → process",
      "→ ECS → IMDS); use `with_credentials_provider` to override.",
    ]),
    Fn(
      public: True,
      name: "new",
      params: [LabelledParam(label: "region", name: "region", type_: "String")],
      return: CodeSome("Client"),
      body: new_body,
    ),
    Blank,
    DocComment([
      "Build a Client by resolving the region from the standard AWS",
      "sources (`AWS_REGION`, `AWS_DEFAULT_REGION`, `~/.aws/config`).",
      "Returns `Error(_)` when no source supplies a region — typical in",
      "Lambda/ECS/EC2 where exactly one of these is always set.",
    ]),
    Fn(
      public: True,
      name: "new_with_auto_region",
      params: [],
      return: CodeSome("Result(Client, region.ResolveError)"),
      body: code.Block(items: [
        Use(
          name: "resolved",
          callee: Call(Ident("result.try"), [
            Call(Ident("region.resolve"), [
              code.Labelled(label: "profile", value: StrLit("default")),
            ]),
          ]),
        ),
        Call(Ident("Ok"), [
          Call(Ident("new"), [
            code.Labelled(label: "region", value: Ident("resolved")),
          ]),
        ]),
      ]),
    ),
    Blank,
  ]
  let withers = [
    DocComment([
      "Override the credentials provider — use for non-default",
      "profiles, in-process static credentials, or a custom chain.",
      "The supplied provider is wrapped in a fresh per-Client",
      "credentials cache so callers don't lose refresh/coalesce",
      "behaviour by overriding the default chain. The previously",
      "running cache actor is stopped — call this on a Client value",
      "you intend to keep, not on one that's about to be discarded.",
    ]),
    Fn(
      public: True,
      name: "with_credentials_provider",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "provider", type_: "credentials.Provider"),
      ],
      return: CodeSome("Client"),
      body: code.Block(items: [
        Let(
          name: "_",
          value: Call(Ident("credentials_cache.shutdown"), [
            Ident("client.cache"),
          ]),
        ),
        LetAssert(
          pattern: "Ok(cache)",
          value: Call(Ident("credentials_cache.start_default"), [
            Ident("provider"),
          ]),
        ),
        client_with(
          Call(Ident("runtime.with_credentials_provider"), [
            Ident("client.config"),
            Call(Ident("credentials_cache.as_provider"), [Ident("cache")]),
          ]),
          Ident("cache"),
        ),
      ]),
    ),
    Blank,
    DocComment([
      "Override the endpoint URL (LocalStack, FIPS endpoints, custom DNS).",
    ]),
    Fn(
      public: True,
      name: "with_endpoint_url",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "url", type_: "String"),
      ],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_endpoint_url"), [
          Ident("client.config"),
          Ident("url"),
        ]),
        Ident("client.cache"),
      ),
    ),
    Blank,
    DocComment([
      "Swap the HTTP transport — useful for canned-response test doubles.",
    ]),
    Fn(
      public: True,
      name: "with_http_send",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "send", type_: "http_send.Send"),
      ],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_http_send"), [
          Ident("client.config"),
          Ident("send"),
        ]),
        Ident("client.cache"),
      ),
    ),
    Blank,
    DocComment([
      "Swap the streaming HTTP transport. Same role as `with_http_send`",
      "but targets the `@streaming` output path (`runtime.invoke_streaming`).",
      "Use for canned-response test doubles on streaming ops, or to plug",
      "in a custom chunked transport (proxy, gRPC tunnel, instrumented",
      "sender) without disturbing the buffered path.",
    ]),
    Fn(
      public: True,
      name: "with_streaming_http_send",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "send", type_: "http_send.StreamingSend"),
      ],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_streaming_http_send"), [
          Ident("client.config"),
          Ident("send"),
        ]),
        Ident("client.cache"),
      ),
    ),
    Blank,
    DocComment([
      "Switch the streaming sender to the HTTP/2 variant. httpc adds",
      "`{http_version, \"HTTP/2\"}` to its option list; servers that",
      "don't speak HTTP/2 negotiate down to HTTP/1.1 via ALPN, so",
      "calls keep working even when the peer doesn't support it.",
      "Buffered requests (`with_http_send`) are unaffected — HTTP/2",
      "is for high-throughput streaming endpoints (S3 multipart,",
      "Bedrock streaming, Transcribe).",
    ]),
    Fn(
      public: True,
      name: "with_http2",
      params: [Param(name: "client", type_: "Client")],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_http2"), [Ident("client.config")]),
        Ident("client.cache"),
      ),
    ),
    Blank,
    DocComment([
      "Opt the Client into SigV4a (asymmetric ECDSA P-256) signing",
      "for every request. `region_set` becomes the `X-Amz-Region-Set`",
      "header — single-region callers pass `[\"us-east-1\"]`,",
      "multi-region callers pass the full list. Required for S3",
      "Multi-Region Access Points and any other endpoint that demands",
      "AWS4-ECDSA-P256-SHA256 signatures.",
    ]),
    Fn(
      public: True,
      name: "with_sigv4a_region_set",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "region_set", type_: "List(String)"),
      ],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_sigv4a_region_set"), [
          Ident("client.config"),
          Ident("region_set"),
        ]),
        Ident("client.cache"),
      ),
    ),
    Blank,
    DocComment([
      "Override SigV4a's `normalize_path` (RFC 3986 dot-segment removal).",
      "No-op when `with_sigv4a_region_set` has not been called yet — the",
      "knob lives on the per-Client SigV4a state, not on the underlying",
      "transport. S3 callers need `False` so object keys with `.` / `..`",
      "survive the canonical-request step.",
    ]),
    Fn(
      public: True,
      name: "with_sigv4a_path_normalization",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "normalize", type_: "Bool"),
      ],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_sigv4a_path_normalization"), [
          Ident("client.config"),
          Ident("normalize"),
        ]),
        Ident("client.cache"),
      ),
    ),
    Blank,
    DocComment([
      "Override the retry attempt budget on the underlying ClientConfig.",
      "The common case for retry tuning — pass `1` to disable retries",
      "entirely (single attempt per request), `5` for long-running batch",
      "workloads. Preserves the other retry knobs (delays, sleep, rng,",
      "rate-limiter); use `runtime.with_retry_strategy` for full control.",
    ]),
    Fn(
      public: True,
      name: "with_max_attempts",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "n", type_: "Int"),
      ],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_max_attempts"), [
          Ident("client.config"),
          Ident("n"),
        ]),
        Ident("client.cache"),
      ),
    ),
    Blank,
  ]
  let endpoint_setters =
    list.flat_map(endpoint_param_setters, fn(p) {
      emit_endpoint_param_setter(p, client_with)
    })
  let tail = [
    DocComment([
      "Read the underlying `runtime.ClientConfig` out of an existing",
      "`Client`. Use this when you want to dispatch a request through",
      "`runtime.invoke` / `runtime.invoke_streaming` directly — e.g. to",
      "build a service-specific streaming wrapper around a `@streaming`",
      "output operation that the per-op codegen hasn't surfaced yet.",
      "The returned config is a value (Gleam records are immutable);",
      "callers cannot mutate the Client through it.",
    ]),
    Fn(
      public: True,
      name: "config",
      params: [Param(name: "client", type_: "Client")],
      return: CodeSome("runtime.ClientConfig"),
      body: Ident("client.config"),
    ),
    Blank,
    DocComment([
      "Release the per-Client credentials cache actor. Call this when a",
      "Client value is no longer needed — long-running processes that",
      "build many Clients (tests, scripts, multi-tenant servers) will",
      "otherwise accumulate one BEAM process per `new` call. Fire-and-",
      "forget; safe to call multiple times. For tests or graceful",
      "shutdown that must observe the actor's exit, use `shutdown_sync`.",
    ]),
    Fn(
      public: True,
      name: "shutdown",
      params: [Param(name: "client", type_: "Client")],
      return: CodeSome("Nil"),
      body: Call(Ident("credentials_cache.shutdown"), [Ident("client.cache")]),
    ),
    Blank,
    DocComment([
      "Like `shutdown` but blocks until the credentials cache actor has",
      "actually exited (or `timeout_ms` elapses). `Ok(Nil)` indicates a",
      "clean exit; `Error(Nil)` indicates the timeout fired and the",
      "actor was still alive when the caller gave up.",
    ]),
    Fn(
      public: True,
      name: "shutdown_sync",
      params: [
        Param(name: "client", type_: "Client"),
        LabelledParam(label: "timeout_ms", name: "timeout_ms", type_: "Int"),
      ],
      return: CodeSome("Result(Nil, Nil)"),
      body: Call(Ident("credentials_cache.shutdown_sync"), [
        Ident("client.cache"),
        Ident("timeout_ms"),
      ]),
    ),
    Blank,
  ]
  list.flatten([
    header,
    rule_set_constant,
    new_section,
    withers,
    endpoint_setters,
    tail,
  ])
}

/// Emit the doc comment + setter `Fn` for a single endpoint-rule-set
/// param. Booleans and strings each follow the same pattern: pass
/// the supplied value through `runtime.with_endpoint_param` using the
/// `endpoints.BoolVal` / `endpoints.StringVal` constructor for the
/// `Value` wrapper, keep the credentials cache intact.
fn emit_endpoint_param_setter(
  param: EndpointParam,
  client_with: fn(Code, Code) -> Code,
) -> List(Code) {
  let snake = stringutils.pascal_to_snake(param.name)
  let #(type_, ctor) = case param.kind {
    BoolParam -> #("Bool", "endpoints.BoolVal")
    StringParam -> #("String", "endpoints.StringVal")
  }
  // Doc-comment: lift the trait's `documentation` field verbatim when
  // present; fall back to a generic one-liner. Either way pin the
  // wire-form name so callers can correlate with the Smithy rule
  // set if needed.
  let header_doc = case param.documentation {
    "" -> "Set the `" <> param.name <> "` endpoint-rule-set parameter."
    other -> other
  }
  let trailer_doc =
    "Wire form: `runtime.with_endpoint_param(config, \""
    <> param.name
    <> "\", ...)`."
  [
    DocComment([header_doc, trailer_doc]),
    Fn(
      public: True,
      name: "with_" <> snake,
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "value", type_: type_),
      ],
      return: CodeSome("Client"),
      body: client_with(
        Call(Ident("runtime.with_endpoint_param"), [
          Ident("client.config"),
          StrLit(param.name),
          Call(Ident(ctor), [Ident("value")]),
        ]),
        Ident("client.cache"),
      ),
    ),
    Blank,
  ]
}

/// Convenience: build + render in one call.
pub fn render(
  endpoint_prefix: String,
  signing_name: String,
  endpoint_rule_set_json: Option(String),
  endpoint_param_setters: List(EndpointParam),
) -> String {
  string.concat([
    code.render(
      Module(items(
        endpoint_prefix,
        signing_name,
        endpoint_rule_set_json,
        endpoint_param_setters,
      )),
    ),
    "\n",
  ])
}

/// `@smithy.api#endpoint.hostPrefix` plumbing the op wrapper needs to
/// expand the template against the input's `@hostLabel` members at
/// call time. `template` is the trait value verbatim (e.g.
/// `"{RequestRoute}."`); `labels` lists every `@hostLabel`-tagged
/// input member's snake_case name (the placeholder text inside `{...}`
/// is the original PascalCase member name).
pub type HostPrefixInfo {
  HostPrefixInfo(template: String, labels: List(HostLabelBinding))
}

pub type HostLabelBinding {
  HostLabelBinding(member_pascal: String, member_snake: String)
}

/// Build the AST node for the per-op `pub fn <snake>(client, input)
/// -> Result(<Out>, <Op>Error)` invoker. Identical across the three
/// protocol emitters; lifted here so they share the implementation
/// instead of each carrying a copy.
///
/// When `host_prefix` is `Some(_)`, the emitted body first validates
/// the `@hostLabel` input members (must be `Some(non-empty)`),
/// substitutes them into the prefix template, and routes through
/// `runtime.invoke_with_endpoint_params_and_host_prefix` so the
/// resolved Host header carries the substituted prefix. Mirrors the
/// Rust SDK's `read_before_execution` interceptor pattern.
pub fn invoke_fn(
  snake: String,
  in_type: String,
  out_type: String,
  err_type: String,
  host_prefix: Option(HostPrefixInfo),
) -> Code {
  let invoke_call = case host_prefix {
    None ->
      Call(Ident("runtime.invoke"), [
        Ident("client.config"),
        Call(Ident(string.concat(["build_", snake, "_request"])), [
          Ident("input"),
        ]),
        Ident(string.concat(["parse_", snake, "_response"])),
      ])
    Some(_) ->
      Call(Ident("runtime.invoke_with_endpoint_params_and_host_prefix"), [
        Ident("client.config"),
        Call(Ident("dict.new"), []),
        Ident("option.Some(host_prefix)"),
        Call(Ident(string.concat(["build_", snake, "_request"])), [
          Ident("input"),
        ]),
        Ident(string.concat(["parse_", snake, "_response"])),
      ])
  }
  let body = case host_prefix {
    None ->
      code.Case(scrutinee: invoke_call, branches: [
        code.Branch(pattern: "Ok(out)", body: Call(Ident("Ok"), [Ident("out")])),
        code.Branch(
          pattern: "Error(err)",
          body: Call(Ident("Error"), [
            Call(Ident(string.concat(["translate_", snake, "_error"])), [
              Ident("err"),
            ]),
          ]),
        ),
      ])
    Some(info) ->
      code.Block(items: [
        // `case build_<snake>_host_prefix(input) { ... }` —
        // validation surfaces as `Error(reason)` and gets wrapped
        // in a `runtime.DecodeError` so the typed-error translator
        // sees it as a normal client-side failure.
        code.Raw(fragment: build_host_prefix_case(
          snake,
          info,
          err_type,
          invoke_call,
        )),
      ])
  }
  Fn(
    public: True,
    name: snake,
    params: [
      Param(name: "client", type_: "Client"),
      Param(name: "input", type_: in_type),
    ],
    return: CodeSome(string.concat(["Result(", out_type, ", ", err_type, ")"])),
    body: body,
  )
}

/// Emit the inline `case build_<snake>_host_prefix(input) { ... }`
/// wrapper that validates the `@hostLabel` members and, on success,
/// passes the substituted prefix to the host-prefix-aware invoker.
fn build_host_prefix_case(
  snake: String,
  _info: HostPrefixInfo,
  err_type: String,
  invoke_call: Code,
) -> String {
  let prefix_fn = string.concat(["build_", snake, "_host_prefix"])
  let invoke_src = code.render(invoke_call)
  let translator = string.concat(["translate_", snake, "_error"])
  string.concat([
    "case ",
    prefix_fn,
    "(input) {\n",
    "    Error(reason) ->\n",
    "      Error(",
    translator,
    "(runtime.DecodeError(reason: reason)))\n",
    "    Ok(host_prefix) ->\n",
    "      case ",
    invoke_src,
    " {\n",
    "        Ok(out) -> Ok(out)\n",
    "        Error(err) -> Error(",
    translator,
    "(err))\n",
    "      }\n",
    "  }",
    // Silence the unused-binding warning if `host_prefix` slips
    // out of scope (it doesn't — invoke_src consumes it — but
    // explicit binding is clearer).
    case err_type {
      _ -> ""
    },
  ])
}

/// Build the `fn build_<snake>_host_prefix(input)` validator that
/// the codegen emits alongside each `@endpoint.hostPrefix` op. Each
/// `@hostLabel` member must be `Some(non-empty)`; otherwise return
/// `Error(reason)` matching the Rust SDK's message format. On
/// success returns `Ok(<substituted prefix>)`.
pub fn host_prefix_validator_fn(
  snake: String,
  in_type: String,
  info: HostPrefixInfo,
) -> Code {
  let body = code.Raw(fragment: render_host_prefix_validator_body(info))
  Fn(
    public: False,
    name: string.concat(["build_", snake, "_host_prefix"]),
    params: [Param(name: "input", type_: in_type)],
    return: CodeSome("Result(String, String)"),
    body: body,
  )
}

fn render_host_prefix_validator_body(info: HostPrefixInfo) -> String {
  let validate_steps =
    list.map(info.labels, fn(lb) {
      string.concat([
        "  use ",
        lb.member_snake,
        " <- result.try(case input.",
        lb.member_snake,
        " {\n",
        "    option.Some(v) -> case v {\n",
        "      \"\" -> Error(\"",
        lb.member_snake,
        " was unset or empty but must be set as part of the endpoint prefix\")\n",
        "      _ -> Ok(v)\n",
        "    }\n",
        "    option.None -> Error(\"",
        lb.member_snake,
        " was unset or empty but must be set as part of the endpoint prefix\")\n",
        "  })\n",
      ])
    })
    |> string.concat
  let substitutions =
    list.fold(info.labels, "\"" <> info.template <> "\"", fn(acc, lb) {
      string.concat([
        "string.replace(",
        acc,
        ", \"{",
        lb.member_pascal,
        "}\", ",
        lb.member_snake,
        ")",
      ])
    })
  string.concat([validate_steps, "  Ok(", substitutions, ")\n"])
}

/// Streaming-side counterpart: emits `pub fn <snake>_streaming(client,
/// input) -> Result(streaming.Response, runtime.ClientError)` for
/// operations whose output struct carries a `@streaming` blob member.
/// Routes through `runtime.invoke_streaming` so the response body
/// arrives as a chunked `StreamingBody` instead of the buffered
/// `BitArray` the regular invoker materialises.
///
/// Errors surface as untyped `runtime.ClientError` rather than the
/// per-op `<Op>Error` enum — the typed-error translator is private
/// to the generated module and the streaming variant is read-only
/// (response body just passes through, no response decode needed).
/// Callers that want typed errors fall back to the buffered op.
pub fn invoke_streaming_fn(snake: String, in_type: String) -> Code {
  invoke_streaming_with_suffix(snake, in_type, "_streaming")
}

/// Same shape as `invoke_streaming_fn`, named `<snake>_event_stream`
/// instead, for operations whose output struct carries a
/// `@streaming` union (Smithy's event-stream representation —
/// Transcribe.StartStreamTranscription, Kinesis.SubscribeToShard,
/// S3.SelectObjectContent, Bedrock InvokeModelWithResponseStream).
///
/// The wire body comes back as `application/vnd.amazon.eventstream`
/// frames; callers decode it with
/// `aws/internal/codec/event_stream.fold_events(resp.body, …)` and
/// then dispatch each frame through the codegen-emitted
/// `parse_<snake>_event(event)` (see `event_parser_fn`).
pub fn invoke_event_stream_fn(snake: String, in_type: String) -> Code {
  invoke_streaming_with_suffix(snake, in_type, "_event_stream")
}

/// One variant of an event-stream union — the codegen builds these
/// from the union shape's members and threads them into
/// `event_parser_fn` so the emitter has everything it needs to
/// dispatch on `:event-type`.
pub type EventParserVariant {
  EventParserVariant(
    /// Wire-form name as it appears in the `:event-type` header
    /// (the Smithy member name, e.g. `"TranscriptEvent"`).
    wire_name: String,
    /// Variant constructor on the Gleam union type (e.g.
    /// `TranscriptResultStreamTranscriptEvent`).
    variant_ctor: String,
    /// JSON struct decoder fn for the variant's payload, called as
    /// `<decoder_fn>()` to get the `decode.Decoder(T)`.
    decoder_fn: String,
  )
}

/// Emit `pub fn parse_<snake>_event(event: event_stream.Event) ->
/// Result(<UnionLocal>, String)` for an op whose output carries a
/// `@streaming` union. Dispatches on the `:event-type` header,
/// decodes each variant's payload as JSON via the variant's
/// existing struct decoder, and wraps in the matching union
/// constructor. Mirrors the Rust SDK's `UnmarshallMessage`
/// implementation (vendor/aws-sdk-rust/sdk/transcribestreaming/
/// src/event_stream_serde.rs).
///
/// JSON-only today — services on awsjson + restjson1 are covered.
/// restxml's event-stream variant decoding (S3 SelectObjectContent)
/// would need an XML payload path here; deferred until a user
/// surfaces it.
pub fn event_parser_fn(
  snake: String,
  union_local: String,
  variants: List(EventParserVariant),
) -> Code {
  let arms =
    list.map(variants, fn(v) {
      string.concat([
        "    Ok(\"",
        v.wire_name,
        "\") ->\n",
        "      json.parse_bits(event.payload, ",
        v.decoder_fn,
        "())\n",
        "      |> result.map(",
        v.variant_ctor,
        ")\n",
        "      |> result.map_error(fn(_) { \"decode ",
        v.wire_name,
        " payload failed\" })\n",
      ])
    })
    |> string.concat
  let body =
    string.concat([
      "case event_stream.string_header(event, \":event-type\") {\n",
      arms,
      "    Ok(other) -> Error(\"unknown :event-type: \" <> other)\n",
      "    Error(_) -> Error(\"missing :event-type header\")\n",
      "  }",
    ])
  Fn(
    public: True,
    name: string.concat(["parse_", snake, "_event"]),
    params: [Param(name: "event", type_: "event_stream.Event")],
    return: CodeSome(string.concat(["Result(", union_local, ", String)"])),
    body: code.Raw(fragment: body),
  )
}

fn invoke_streaming_with_suffix(
  snake: String,
  in_type: String,
  suffix: String,
) -> Code {
  Fn(
    public: True,
    name: string.concat([snake, suffix]),
    params: [
      Param(name: "client", type_: "Client"),
      Param(name: "input", type_: in_type),
    ],
    return: CodeSome("Result(streaming.Response, runtime.ClientError)"),
    body: Call(Ident("runtime.invoke_streaming"), [
      Ident("client.config"),
      Call(Ident(string.concat(["build_", snake, "_request"])), [
        Ident("input"),
      ]),
    ]),
  )
}
