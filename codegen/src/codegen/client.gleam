//// Shared emitter for the per-service `Client` section. Every generated
//// service module ends up with the same shape — an opaque `Client`, a
//// typed `EndpointParams` record (the AWS endpoint-rule-set knobs this
//// service declares), and two constructors: `new()` (full auto — region +
//// credentials resolve themselves) and `new_with(config.Settings,
//// EndpointParams)`. Customer config lives on the shared `config.Settings`;
//// AWS rule-set params live on the per-service `EndpointParams`, so the two
//// never mix. There are no post-construction `with_*` setters.
////
//// Lives in its own module so awsjson / restjson / restxml don't each
//// carry their own copy. The output is identical regardless of protocol —
//// only the endpoint prefix, signing name, and declared endpoint params
//// vary, so we take those as parameters.

import codegen/code.{
  type Code, Blank, Call, CodeSome, Const, DocComment, Fn, Ident, LabelledParam,
  Let, LetAssert, Module, Param, StrLit, TypeDef, Use, Variant,
}
import codegen/trait_helpers.{
  type ContextParamBinding, type EndpointParam, BoolParam, StringParam,
}
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
  endpoint_params: List(EndpointParam),
) -> List(Code) {
  let header = [
    TypeDef(public: True, is_opaque: True, name: "Client", variants: [
      Variant(name: "Client", fields: [
        Param(name: "config", type_: "runtime.ClientConfig"),
        Param(name: "cache", type_: "credentials_cache.Cache"),
      ]),
    ]),
    Blank,
  ]
  let rule_set_constant = case endpoint_rule_set_json {
    None -> []
    Some(json) -> [
      DocComment([
        "Smithy endpoint rule set for this service, lifted verbatim from",
        "the source model. Parsed once in `new_with` and attached to every",
        "Client via `runtime.with_endpoint_rule_set`.",
      ]),
      Const(
        name: "endpoint_rule_set_json",
        type_: "String",
        value: StrLit(json),
      ),
      Blank,
    ]
  }
  list.flatten([
    header,
    rule_set_constant,
    endpoint_params_section(endpoint_params),
    new_section(
      endpoint_prefix,
      signing_name,
      endpoint_rule_set_json,
      endpoint_params,
    ),
    lifecycle_section(),
  ])
}

/// Emit the per-service `EndpointParams` record + `default_endpoint_params`.
/// One typed `Option` field per SDK-config-level rule-set param the service
/// declares (`use_fips`, `use_dual_stack`, S3 `force_path_style`, …), so a
/// param is settable only where the rule set actually supports it. Services
/// that declare none get an empty record — `new_with` still takes it, so the
/// constructor shape stays uniform across every service.
fn endpoint_params_section(endpoint_params: List(EndpointParam)) -> List(Code) {
  let fields =
    list.map(endpoint_params, fn(p) {
      Param(name: stringutils.pascal_to_snake(p.name), type_: param_type(p))
    })
  let default_value = case endpoint_params {
    [] -> Ident("EndpointParams")
    _ ->
      Call(
        Ident("EndpointParams"),
        list.map(endpoint_params, fn(p) {
          code.Labelled(
            label: stringutils.pascal_to_snake(p.name),
            value: Ident("option.None"),
          )
        }),
      )
  }
  [
    DocComment([
      "AWS endpoint-rule-set parameters for this service. Each `Some` value",
      "feeds endpoint resolution; `None` keeps the rule set's own default.",
      "Start from `default_endpoint_params()` and override what you need.",
    ]),
    TypeDef(public: True, is_opaque: False, name: "EndpointParams", variants: [
      Variant(name: "EndpointParams", fields: fields),
    ]),
    Blank,
    DocComment([
      "The all-default `EndpointParams`: every parameter left to the rule",
      "set's default. Spread it and override only the params you need.",
    ]),
    Fn(
      public: True,
      name: "default_endpoint_params",
      params: [],
      return: CodeSome("EndpointParams"),
      body: default_value,
    ),
    Blank,
  ]
}

fn param_type(p: EndpointParam) -> String {
  case p.kind {
    BoolParam -> "option.Option(Bool)"
    StringParam -> "option.Option(String)"
  }
}

fn param_value_ctor(p: EndpointParam) -> String {
  case p.kind {
    BoolParam -> "endpoints.BoolVal"
    StringParam -> "endpoints.StringVal"
  }
}

/// The two construction entry points every service exposes:
///   * `new()` — full auto, region + credentials resolve themselves.
///   * `new_with(settings, endpoint_params)` — customer `config.Settings`
///     plus this service's AWS `EndpointParams`, each spread off its
///     defaults. No post-construction `with_*` setters.
fn new_section(
  endpoint_prefix: String,
  signing_name: String,
  endpoint_rule_set_json: Option(String),
  endpoint_params: List(EndpointParam),
) -> List(Code) {
  // An unused `endpoint_params` arg (services that declare none) would
  // warn; rename it to `_endpoint_params` in that case while keeping the
  // uniform two-arg `new_with` shape.
  let params_param_name = case endpoint_params {
    [] -> "_endpoint_params"
    _ -> "endpoint_params"
  }
  [
    DocComment([
      "Build a Client with everything resolved automatically: the region",
      "from the standard AWS sources (`AWS_REGION`, `AWS_DEFAULT_REGION`,",
      "`~/.aws/config`) and credentials from the default chain. Zero",
      "config — the path you want in Lambda / ECS / EC2, where the",
      "environment always supplies a region. `Error(_)` only when no",
      "source provides one; pass explicit settings via `new_with` then.",
    ]),
    Fn(
      public: True,
      name: "new",
      params: [],
      return: CodeSome("Result(Client, region.ResolveError)"),
      body: Call(Ident("new_with"), [
        Call(Ident("config.default_settings"), []),
        Call(Ident("default_endpoint_params"), []),
      ]),
    ),
    Blank,
    DocComment([
      "Build a Client from explicit customer `config.Settings` and this",
      "service's AWS `EndpointParams`. Start each from its defaults",
      "(`config.default_settings()` / `default_endpoint_params()`) and",
      "override only the fields you need. Region auto-resolves when",
      "`settings.region` is `None` — the only failure path; credentials",
      "resolve lazily on the first request.",
    ]),
    Fn(
      public: True,
      name: "new_with",
      params: [
        Param(name: "settings", type_: "config.Settings"),
        Param(name: params_param_name, type_: "EndpointParams"),
      ],
      return: CodeSome("Result(Client, region.ResolveError)"),
      body: new_with_body(
        endpoint_prefix,
        signing_name,
        endpoint_rule_set_json,
        endpoint_params,
      ),
    ),
    Blank,
  ]
}

/// `new_with`'s body: resolve the settings into a `runtime.ClientConfig`,
/// attach the embedded rule set (when present), then start exactly one
/// per-Client credentials cache around the resolved provider. The
/// `let assert`s are generator-time invariants — the rule-set JSON is a
/// codegen constant and the cache `start` only spawns an actor, so a
/// failure there is an SDK bug, not a runtime condition.
fn new_with_body(
  endpoint_prefix: String,
  signing_name: String,
  endpoint_rule_set_json: Option(String),
  endpoint_params: List(EndpointParam),
) -> Code {
  let resolve_step =
    Use(
      name: "cfg",
      callee: Call(Ident("result.map"), [
        Call(Ident("config.resolve"), [
          Ident("settings"),
          code.Labelled(
            label: "endpoint_prefix",
            value: StrLit(endpoint_prefix),
          ),
          code.Labelled(label: "signing_name", value: StrLit(signing_name)),
        ]),
      ]),
    )
  let rule_set_steps = case endpoint_rule_set_json {
    None -> []
    Some(_) -> [
      LetAssert(
        pattern: "Ok(rule_set)",
        value: Call(Ident("endpoints.parse_rule_set"), [
          Ident("endpoint_rule_set_json"),
        ]),
      ),
      Let(
        name: "cfg",
        value: Call(Ident("runtime.with_endpoint_rule_set"), [
          Ident("cfg"),
          Ident("rule_set"),
        ]),
      ),
    ]
  }
  // One `let cfg = case endpoint_params.<field> { Some(v) -> ... }` per
  // declared param: a `Some` threads the value into the rule-set param
  // dict; `None` leaves the rule set's default in place.
  let endpoint_param_steps =
    list.map(endpoint_params, fn(p) {
      Let(
        name: "cfg",
        value: code.Case(
          scrutinee: Ident(
            "endpoint_params." <> stringutils.pascal_to_snake(p.name),
          ),
          branches: [
            code.Branch(
              pattern: "option.Some(value)",
              body: Call(Ident("runtime.with_endpoint_param"), [
                Ident("cfg"),
                StrLit(p.name),
                Call(Ident(param_value_ctor(p)), [Ident("value")]),
              ]),
            ),
            code.Branch(pattern: "option.None", body: Ident("cfg")),
          ],
        ),
      )
    })
  let cache_steps = [
    LetAssert(
      pattern: "Ok(cache)",
      value: Call(Ident("credentials_cache.start_default"), [
        Ident("cfg.provider"),
      ]),
    ),
    Let(
      name: "cfg",
      value: Call(Ident("runtime.with_credentials_provider"), [
        Ident("cfg"),
        Call(Ident("credentials_cache.as_provider"), [Ident("cache")]),
      ]),
    ),
    Call(Ident("Client"), [
      code.Labelled(label: "config", value: Ident("cfg")),
      code.Labelled(label: "cache", value: Ident("cache")),
    ]),
  ]
  code.Block(
    items: list.flatten([
      [resolve_step],
      rule_set_steps,
      endpoint_param_steps,
      cache_steps,
    ]),
  )
}

/// Accessor + cache lifecycle — independent of how the Client was built.
fn lifecycle_section() -> List(Code) {
  [
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
      name: "client_config",
      params: [Param(name: "client", type_: "Client")],
      return: CodeSome("runtime.ClientConfig"),
      body: Ident("client.config"),
    ),
    Blank,
    DocComment([
      "Release the per-Client credentials cache actor. Call this when a",
      "Client value is no longer needed — long-running processes that",
      "build many Clients (tests, scripts, multi-tenant servers) will",
      "otherwise accumulate one BEAM process per construction. Fire-and-",
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
}

/// Convenience: build + render in one call.
pub fn render(
  endpoint_prefix: String,
  signing_name: String,
  endpoint_rule_set_json: Option(String),
  endpoint_params: List(EndpointParam),
) -> String {
  string.concat([
    code.render(
      Module(items(
        endpoint_prefix,
        signing_name,
        endpoint_rule_set_json,
        endpoint_params,
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
  HostLabelBinding(member_pascal: String, member_snake: String, required: Bool)
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
  context_params: List(ContextParamBinding),
) -> Code {
  let params_expr = case context_params {
    [] -> Call(Ident("dict.new"), [])
    _ -> Ident(string.concat(["build_", snake, "_endpoint_params(input)"]))
  }
  let invoke_call = case host_prefix, context_params {
    None, [] ->
      Call(Ident("runtime.invoke"), [
        Ident("client.config"),
        Call(Ident(string.concat(["build_", snake, "_request"])), [
          Ident("input"),
        ]),
        Ident(string.concat(["parse_", snake, "_response"])),
      ])
    None, _ ->
      Call(Ident("runtime.invoke_with_endpoint_params"), [
        Ident("client.config"),
        params_expr,
        Call(Ident(string.concat(["build_", snake, "_request"])), [
          Ident("input"),
        ]),
        Ident(string.concat(["parse_", snake, "_response"])),
      ])
    Some(_), _ ->
      Call(Ident("runtime.invoke_with_endpoint_params_and_host_prefix"), [
        Ident("client.config"),
        params_expr,
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
  // When the template carries no `@hostLabel` substitutions
  // (e.g. `foo.`) the body never touches `input`. Rename the
  // param to `_input` for these to silence the unused-arg
  // warning on the generated module.
  let param_name = case info.labels {
    [] -> "_input"
    _ -> "input"
  }
  Fn(
    public: False,
    name: string.concat(["build_", snake, "_host_prefix"]),
    params: [Param(name: param_name, type_: in_type)],
    return: CodeSome("Result(String, String)"),
    body: body,
  )
}

fn render_host_prefix_validator_body(info: HostPrefixInfo) -> String {
  let validate_steps =
    list.map(info.labels, fn(lb) {
      let message =
        lb.member_snake
        <> " was unset or empty but must be set as part of the endpoint prefix"
      case lb.required {
        True ->
          string.concat([
            "  use ",
            lb.member_snake,
            " <- result.try(case input.",
            lb.member_snake,
            " {\n",
            "    \"\" -> Error(\"",
            message,
            "\")\n",
            "    v -> Ok(v)\n",
            "  })\n",
          ])
        False ->
          string.concat([
            "  use ",
            lb.member_snake,
            " <- result.try(case input.",
            lb.member_snake,
            " {\n",
            "    option.Some(v) -> case v {\n",
            "      \"\" -> Error(\"",
            message,
            "\")\n",
            "      _ -> Ok(v)\n",
            "    }\n",
            "    option.None -> Error(\"",
            message,
            "\")\n",
            "  })\n",
          ])
      }
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

/// Build the `fn build_<snake>_endpoint_params(input)` helper. For
/// each `smithy.rules#contextParam`-tagged input member, emits a
/// `dict.insert(_, "<param>", v)` step that unwraps the field if
/// optional. Result is the per-call endpoint params dict fed into
/// `runtime.invoke_with_endpoint_params`. Mirrors the Rust SDK's
/// `ContextParam`-driven `endpoint_resolver_params` population in
/// the operation orchestrator.
pub fn endpoint_params_builder_fn(
  snake: String,
  in_type: String,
  bindings: List(ContextParamBinding),
) -> Code {
  let body = code.Raw(fragment: render_endpoint_params_builder_body(bindings))
  Fn(
    public: False,
    name: string.concat(["build_", snake, "_endpoint_params"]),
    params: [Param(name: "input", type_: in_type)],
    return: CodeSome("dict.Dict(String, endpoints.Value)"),
    body: body,
  )
}

fn render_endpoint_params_builder_body(
  bindings: List(ContextParamBinding),
) -> String {
  // Wrap each string value in `endpoints.StringVal(_)` so the
  // resulting dict is compatible with `runtime.invoke_with_endpoint_
  // params`'s `Params = Dict(String, endpoints.Value)` type. Maps to
  // the same shape the rule-set evaluator's other inputs use
  // (Region, UseFips, UseDualStack flow in as `StringVal` / `BoolVal`
  // via `endpoints.params_from`).
  let inserts =
    list.map(bindings, fn(b) {
      case b.required {
        True ->
          string.concat([
            "  let params = dict.insert(params, \"",
            b.param_name,
            "\", endpoints.StringVal(input.",
            b.member_snake,
            "))\n",
          ])
        False ->
          string.concat([
            "  let params = case input.",
            b.member_snake,
            " {\n",
            "    option.Some(v) -> dict.insert(params, \"",
            b.param_name,
            "\", endpoints.StringVal(v))\n",
            "    option.None -> params\n",
            "  }\n",
          ])
      }
    })
    |> string.concat
  string.concat(["  let params = dict.new()\n", inserts, "  params\n"])
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
