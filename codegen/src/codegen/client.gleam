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
  // "generator-time invariant" pattern used elsewhere.
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
  let new_body = case endpoint_rule_set_json {
    None ->
      code.Block(
        items: list.flatten([
          cache_setup,
          [Call(Ident("Client"), [Ident("config")])],
        ]),
      )
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
            Call(Ident("Client"), [
              Call(Ident("runtime.with_endpoint_rule_set"), [
                Ident("config"),
                Ident("rule_set"),
              ]),
            ]),
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
          Call(Ident("new"), [code.Labelled(label: "region", value: Ident("resolved"))]),
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
      "behaviour by overriding the default chain.",
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
        LetAssert(
          pattern: "Ok(cache)",
          value: Call(Ident("credentials_cache.start_default"), [
            Ident("provider"),
          ]),
        ),
        Call(Ident("Client"), [
          Call(Ident("runtime.with_credentials_provider"), [
            Ident("client.config"),
            Call(Ident("credentials_cache.as_provider"), [Ident("cache")]),
          ]),
        ]),
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
      body: Call(Ident("Client"), [
        Call(Ident("runtime.with_endpoint_url"), [
          Ident("client.config"),
          Ident("url"),
        ]),
      ]),
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
      body: Call(Ident("Client"), [
        Call(Ident("runtime.with_http_send"), [
          Ident("client.config"),
          Ident("send"),
        ]),
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
  op_local: String,
  in_type: String,
  out_type: String,
) -> Code {
  let err_type = string.concat([op_local, "Error"])
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
        Call(Ident(string.concat(["build_", snake, "_request"])), [Ident("input")]),
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
