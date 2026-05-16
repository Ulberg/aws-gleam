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
  type Code, Blank, Call, CodeSome, DocComment, Fn, Ident, LabelledParam, Module,
  Param, StrLit, TypeDef, Variant,
}

/// Build the AST nodes for the per-service Client section. Pairs with
/// `code.render(code.Module(items))` at the emit site.
pub fn items(endpoint_prefix: String, signing_name: String) -> List(Code) {
  [
    TypeDef(public: True, is_opaque: True, name: "Client", variants: [
      Variant(name: "Client", fields: [
        Param(name: "config", type_: "awsjson_client.ClientConfig"),
      ]),
    ]),
    Blank,
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
      body: Call(Ident("Client"), [
        Call(Ident("awsjson_client.default_config"), [
          Ident("region"),
          StrLit(endpoint_prefix),
          StrLit(signing_name),
        ]),
      ]),
    ),
    Blank,
    DocComment([
      "Override the credentials provider — use for non-default",
      "profiles, in-process static credentials, or a custom chain.",
    ]),
    Fn(
      public: True,
      name: "with_credentials_provider",
      params: [
        Param(name: "client", type_: "Client"),
        Param(name: "provider", type_: "credentials.Provider"),
      ],
      return: CodeSome("Client"),
      body: Call(Ident("Client"), [
        Call(Ident("awsjson_client.with_credentials_provider"), [
          Ident("client.config"),
          Ident("provider"),
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
        Call(Ident("awsjson_client.with_endpoint_url"), [
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
        Call(Ident("awsjson_client.with_http_send"), [
          Ident("client.config"),
          Ident("send"),
        ]),
      ]),
    ),
    Blank,
  ]
}

/// Convenience: build + render in one call.
pub fn render(endpoint_prefix: String, signing_name: String) -> String {
  code.render(Module(items(endpoint_prefix, signing_name))) <> "\n"
}
