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
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string

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
  list.flatten([header, rule_set_constant, new_section, withers])
}

/// Convenience: build + render in one call.
pub fn render(
  endpoint_prefix: String,
  signing_name: String,
  endpoint_rule_set_json: Option(String),
) -> String {
  string.concat([
    code.render(
      Module(items(endpoint_prefix, signing_name, endpoint_rule_set_json)),
    ),
    "\n",
  ])
}

/// Build the AST node for the per-op `pub fn <snake>(client, input)
/// -> Result(<Out>, <Op>Error)` invoker. Identical across the three
/// protocol emitters; lifted here so they share the implementation
/// instead of each carrying a copy.
pub fn invoke_fn(
  snake: String,
  in_type: String,
  out_type: String,
  err_type: String,
) -> Code {
  Fn(
    public: True,
    name: snake,
    params: [
      Param(name: "client", type_: "Client"),
      Param(name: "input", type_: in_type),
    ],
    return: CodeSome(string.concat(["Result(", out_type, ", ", err_type, ")"])),
    body: code.Case(
      scrutinee: Call(Ident("runtime.invoke"), [
        Ident("client.config"),
        Call(Ident(string.concat(["build_", snake, "_request"])), [
          Ident("input"),
        ]),
        Ident(string.concat(["parse_", snake, "_response"])),
      ]),
      branches: [
        code.Branch(pattern: "Ok(out)", body: Call(Ident("Ok"), [Ident("out")])),
        code.Branch(
          pattern: "Error(err)",
          body: Call(Ident("Error"), [
            Call(Ident(string.concat(["translate_", snake, "_error"])), [
              Ident("err"),
            ]),
          ]),
        ),
      ],
    ),
  )
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
  Fn(
    public: True,
    name: string.concat([snake, "_streaming"]),
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
