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
import gleam/string

fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

/// Build the AST nodes for the per-service Client section. Pairs with
/// `code.render(code.Module(items))` at the emit site.
pub fn items(endpoint_prefix: String, signing_name: String) -> List(Code) {
  [
    TypeDef(public: True, is_opaque: True, name: "Client", variants: [
      Variant(name: "Client", fields: [
        Param(name: "config", type_: "runtime.ClientConfig"),
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
        Call(Ident("runtime.default_config"), [
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
        Call(Ident("runtime.with_credentials_provider"), [
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
}

/// Convenience: build + render in one call.
pub fn render(endpoint_prefix: String, signing_name: String) -> String {
  string.concat([
    code.render(Module(items(endpoint_prefix, signing_name))),
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
  let err_type = name_concat([op_local, "Error"])
  Fn(
    public: True,
    name: snake,
    params: [
      Param(name: "client", type_: "Client"),
      Param(name: "input", type_: in_type),
    ],
    return: CodeSome(name_concat(["Result(", out_type, ", ", err_type, ")"])),
    body: code.Case(
      scrutinee: Call(Ident("runtime.invoke"), [
        Ident("client.config"),
        Call(Ident(name_concat(["build_", snake, "_request"])), [Ident("input")]),
        Ident(name_concat(["parse_", snake, "_response"])),
      ]),
      branches: [
        code.Branch(pattern: "Ok(out)", body: Call(Ident("Ok"), [Ident("out")])),
        code.Branch(
          pattern: "Error(err)",
          body: Call(Ident("Error"), [
            Call(Ident(name_concat(["translate_", snake, "_error"])), [
              Ident("err"),
            ]),
          ]),
        ),
      ],
    ),
  )
}
