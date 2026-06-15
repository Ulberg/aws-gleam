//// Shared `build_<op>_request` scaffolding for restJson1 and restXml.
////
//// Both protocols categorise input members by their `@http*` binding,
//// stitch together path / query / header setup, then build the final
//// `#(method, path, headers, body)` tuple. Everything except the body
//// shape is identical, so the per-protocol emitter passes a
//// `body_setup` closure into `build_request_module` and gets back the
//// fully-rendered `pub fn build_<op>_request(...)` module fragment.

import codegen/code
import codegen/service_customizations.{type ServiceCustomization}
import codegen/trait_helpers
import codegen/types.{
  type BindingCategories, type HttpTrait, type MemberDef, type Resolved, Header,
  PrefixHeaders, Query, RBlob, REnum, RIntEnum, RList, RMap, RPrim,
  RStreamingBlob, RTimestamp,
}
import gleam/dict
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import internal/stringutils

/// Build a Gleam identifier name from a list of parts. Used in place
/// of the `<>` operator throughout codegen so the Gleam source of the
/// emitters doesn't itself use string concat to shape generated names.
fn name_concat(parts: List(String)) -> String {
  string.concat(parts)
}

/// Compose a `pub fn build_<op>_request(input: <Type>) -> #(...)`
/// module fragment. `body_setup` is the protocol-specific list of
/// statements that bind `body` and `content_type` from `input`.
///
/// `requires_md5` reflects the operation's
/// `smithy.api#httpChecksumRequired` trait — when set, the emitter
/// appends a final `let headers = rest.with_content_md5_header(
/// headers, body)` step after the body is fully assembled, so the
/// Content-MD5 header is computed from the exact bytes about to be
/// sent on the wire (not before query / label substitution).
///
/// `http_checksum` reflects `aws.protocols#httpChecksum`. When
/// `request_required` is set the emitter appends a sha256
/// checksum (v1 behaviour — algorithm-member dispatch is a
/// follow-up). Mutually compatible with `requires_md5`: AWS
/// services don't apply both, but the emitter doesn't enforce
/// the constraint.
pub fn build_request_module(
  input_type: String,
  is_unit: Bool,
  snake: String,
  http: HttpTrait,
  members: List(MemberDef),
  requires_md5: Bool,
  http_checksum: option.Option(trait_helpers.HttpChecksumInfo),
  customization: ServiceCustomization,
  body_setup: fn(BindingCategories) -> List(code.Code),
) -> String {
  let cats = types.categorize_bindings(members)
  let touches_input = case
    !is_unit && types.has_any_binding(cats),
    customization.glacier_treehash,
    !list.is_empty(customization.label_defaults |> dict.to_list)
  {
    False, False, False -> False
    _, _, _ -> True
  }
  let header_or_input = case touches_input {
    True -> "input"
    False -> "_input"
  }
  let path_assign =
    code.Let(
      name: "path",
      value: code.Call(head: code.Ident(name: "rest.build_path"), args: [
        code.Ident(name: "path"),
        code.Ident(name: "query"),
      ]),
    )
  let result_tuple =
    code.Tuple(items: [
      code.StrLit(value: http.method),
      code.Ident(name: "path"),
      code.Ident(name: "headers"),
      code.Ident(name: "body"),
    ])
  let md5_step = case requires_md5 {
    True -> [
      code.Let(
        name: "headers",
        value: code.Call(
          head: code.Ident(name: "rest.with_content_md5_header"),
          args: [
            code.Ident(name: "headers"),
            code.Ident(name: "body"),
          ],
        ),
      ),
    ]
    False -> []
  }
  let checksum_step = build_checksum_step(http_checksum, members)
  // Per-service customization steps applied after the base header /
  // body blocks. Service-level default headers go in first so an op's
  // own `@httpHeader`-bound value still wins; Glacier's tree-hash is
  // computed from the assembled body bytes; URI-label defaults
  // substitute the canonical value when the caller leaves the label
  // empty. Order matches the Rust SDK interceptor sequence (see
  // `glacier/src/glacier_interceptors.rs`).
  let customization_default_headers_step =
    emit_default_headers_step(customization.default_headers)
  // Tree-hash only fires on ops that carry an `@httpPayload`-bound
  // **blob** body member. Struct-payload ops (Glacier's InitiateJob,
  // SetVaultAccessPolicy, etc.) serialise JSON and don't need a body-
  // bytes tree-hash. The Rust SDK registers
  // `GlacierTreeHashHeaderInterceptor` on exactly the two blob-payload
  // ops via codegen — see
  // `glacier/src/operation/upload_archive.rs` and
  // `glacier/src/operation/upload_multipart_part.rs`.
  let has_blob_payload = case cats.payload {
    Ok(m) ->
      case m.target {
        RBlob | RStreamingBlob -> True
        _ -> False
      }
    Error(_) -> False
  }
  let customization_tree_hash_step = case
    customization.glacier_treehash,
    has_blob_payload
  {
    True, True -> [
      code.Let(
        name: "headers",
        value: code.Call(
          head: code.Ident(name: "rest.with_glacier_tree_hash_headers"),
          args: [code.Ident(name: "headers"), code.Ident(name: "body")],
        ),
      ),
    ]
    _, _ -> []
  }
  // URI-label substitution: replace `{Bucket}` (and friends) with empty
  // when the customization omits them, OR replace the per-label value
  // with the configured default when the caller passes an empty string.
  let path_template =
    rewrite_uri_template(http.uri, customization.omit_uri_labels)
  let effective_labels =
    list.filter(cats.labels, fn(m) {
      !list.contains(customization.omit_uri_labels, m.member_name)
    })
  let path_steps =
    emit_path_setup_with_defaults(
      path_template,
      effective_labels,
      customization.label_defaults,
    )
  let body_items =
    list.flatten([
      path_steps,
      emit_query_setup(cats.queries, cats.query_maps),
      emit_header_setup(cats.headers, cats.prefix_headers),
      body_setup(cats),
      [content_type_let_block(), content_length_let_block()],
      emit_content_encoding(http.compression),
      customization_default_headers_step,
      md5_step,
      checksum_step,
      customization_tree_hash_step,
      [path_assign, result_tuple],
    ])
  // Re-check whether `input` survives label/binding filtering. The
  // `touches_input` heuristic above is too eager — it returns True
  // whenever ANY binding exists on the input shape, but
  // `omit_uri_labels` can strip every label that remains (S3's
  // `Bucket`-only ops like GetBucketLocation, GetBucketAcl, etc.).
  // Render the body, scan it for an `input.` reference; rename
  // the parameter to `_input` if none survives. Eliminates the
  // "Unused function argument" warning for these ops.
  let body_str = code.render(code.Block(items: body_items))
  let final_param_name = case code.references_identifier(body_str, "input") {
    True -> header_or_input
    False -> "_input"
  }
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: name_concat(["build_", snake, "_request"]),
        params: [code.Param(name: final_param_name, type_: input_type)],
        return: code.CodeSome(
          "#(String, String, dict.Dict(String, String), BitArray)",
        ),
        body: code.Block(items: body_items),
      ),
      code.Blank,
    ]),
  )
}

/// Generate the `aws.protocols#httpChecksum` middleware step
/// that adds the right `x-amz-checksum-<algo>` header before
/// signing. Three cases:
///
/// 1. `request_algorithm_member` is set AND points to a real
///    enum member on the input — emit a `case` that reads the
///    caller's typed enum choice, pulls its wire value via
///    `rest.enum_wire_value`, and calls
///    `rest.with_checksum_header_for_wire`. Falls back to
///    `ChecksumSha256` when the field is `option.None`.
/// 2. `request_required` is set with no algorithm member — emit
///    an unconditional SHA-256 header. This matches the v1
///    behaviour from M10.
/// 3. Otherwise — emit nothing.
fn build_checksum_step(
  http_checksum: option.Option(trait_helpers.HttpChecksumInfo),
  members: List(MemberDef),
) -> List(code.Code) {
  case http_checksum {
    option.None -> []
    option.Some(trait_helpers.HttpChecksumInfo(
      request_required: required,
      request_algorithm_member: alg_member,
    )) ->
      case alg_member {
        option.Some(name) ->
          case find_algorithm_member(members, name) {
            option.Some(m) -> [build_dispatched_checksum_step(m)]
            option.None ->
              case required {
                True -> [default_sha256_checksum_step()]
                False -> []
              }
          }
        option.None ->
          case required {
            True -> [default_sha256_checksum_step()]
            False -> []
          }
      }
  }
}

fn default_sha256_checksum_step() -> code.Code {
  code.Let(
    name: "headers",
    value: code.Call(head: code.Ident(name: "rest.with_checksum_header"), args: [
      code.Ident(name: "headers"),
      code.Ident(name: "rest.ChecksumSha256"),
      code.Ident(name: "body"),
    ]),
  )
}

fn build_dispatched_checksum_step(member: MemberDef) -> code.Code {
  // Read the caller's enum value via the JSON encoder (which
  // returns the wire-form string wrapped in a json.Json) and
  // pass that to the wire-form helper. SHA-256 fallback when
  // the field is None.
  let snake = member.snake_name
  let encoder = types.json_encoder_code(member.target)
  let some_branch =
    code.Call(
      head: code.Ident(name: "rest.with_checksum_header_for_wire"),
      args: [
        code.Ident(name: "headers"),
        code.Call(head: code.Ident(name: "rest.enum_wire_value"), args: [
          code.Call(head: encoder, args: [
            code.Ident(name: "v"),
          ]),
        ]),
        code.Ident(name: "body"),
      ],
    )
  let default_branch =
    code.Call(head: code.Ident(name: "rest.with_checksum_header"), args: [
      code.Ident(name: "headers"),
      code.Ident(name: "rest.ChecksumSha256"),
      code.Ident(name: "body"),
    ])
  let value = case member.required {
    True ->
      code.Block(items: [
        code.Let(
          name: "v",
          value: code.Ident(name: name_concat(["input.", snake])),
        ),
        some_branch,
      ])
    False ->
      code.Case(
        scrutinee: code.Ident(name: name_concat(["input.", snake])),
        branches: [
          code.Branch(pattern: "option.Some(v)", body: some_branch),
          code.Branch(pattern: "option.None", body: default_branch),
        ],
      )
  }
  code.Let(name: "headers", value: value)
}

fn find_algorithm_member(
  members: List(MemberDef),
  member_name: String,
) -> option.Option(MemberDef) {
  case list.find(members, fn(m) { m.member_name == member_name }) {
    Ok(m) -> option.Some(m)
    Error(_) -> option.None
  }
}

/// Insert each service-level default header via `dict.insert`, one
/// `let headers = ...` per pair. Empty list ⇒ no step. Service-level
/// defaults are *insert-when-absent* — so a caller's `@httpHeader`-
/// bound member value wins on name collision. Mirrors the Rust SDK's
/// `set_default_header` (and the `if !contains_key(...)` guard inside
/// `glacier_interceptors::add_checksum_treehash`).
fn emit_default_headers_step(
  headers: List(#(String, String)),
) -> List(code.Code) {
  list.map(headers, fn(h) {
    let #(name, value) = h
    code.Let(
      name: "headers",
      value: code.Call(head: code.Ident(name: "rest.set_default_header"), args: [
        code.Ident(name: "headers"),
        code.StrLit(value: name),
        code.StrLit(value: value),
      ]),
    )
  })
}

/// Drop `{<label>}` (and `{<label>+}`) placeholders from a URI
/// template for each label in `omits`. Used by S3 customization so
/// `{Bucket}` is removed from `/{Bucket}/{Key+}` even though the
/// `Bucket` member still appears in the input record (callers pass
/// it, the runtime would route it through the Host header — out of
/// scope for the protocol-test runner which only inspects the path).
///
/// Replacement order matters: try the `{name}/` form first so we
/// don't leave a double-slash, then the bare `{name}` (handles end-
/// of-URI and `?`-adjacent forms).
fn rewrite_uri_template(uri_template: String, omits: List(String)) -> String {
  list.fold(omits, uri_template, fn(acc, name) {
    let g_with_slash = name_concat(["{", name, "+}/"])
    let plain_with_slash = name_concat(["{", name, "}/"])
    let g_alone = name_concat(["{", name, "+}"])
    let plain_alone = name_concat(["{", name, "}"])
    acc
    |> string.replace(g_with_slash, "")
    |> string.replace(plain_with_slash, "")
    |> string.replace(g_alone, "")
    |> string.replace(plain_alone, "")
  })
}

/// `emit_path_setup` extended with a per-label default-value table.
/// When a label has an entry in `label_defaults`, the substitute step
/// becomes a three-way match:
///   * `option.Some("")` ⇒ substitute the default (Glacier interprets
///     the empty `accountId` as "use my own account", written as the
///     literal `-` on the wire),
///   * `option.Some(v)` ⇒ substitute v as usual,
///   * `option.None` ⇒ substitute the default (same justification).
/// Labels with no default fall back to the existing two-branch shape
/// (`Some` substitutes, `None` leaves the path unchanged).
fn emit_path_setup_with_defaults(
  uri_template: String,
  labels: List(MemberDef),
  label_defaults: dict.Dict(String, String),
) -> List(code.Code) {
  let initial = code.Let(name: "path", value: code.StrLit(value: uri_template))
  let updates =
    list.map(labels, fn(m) {
      let greedy =
        string.contains(uri_template, name_concat(["{", m.json_name, "+}"]))
      let greedy_ident = case greedy {
        True -> code.Ident(name: "True")
        False -> code.Ident(name: "False")
      }
      let value_expr =
        value_to_string_with_format_code(
          m.target,
          m.timestamp_format,
          code.Ident(name: "v"),
        )
      let some_branch =
        code.Call(head: code.Ident(name: "rest.substitute_label"), args: [
          code.Ident(name: "path"),
          code.StrLit(value: m.json_name),
          value_expr,
          greedy_ident,
        ])
      case dict.get(label_defaults, m.member_name) {
        Ok(default_value) -> {
          let default_call =
            code.Call(head: code.Ident(name: "rest.substitute_label"), args: [
              code.Ident(name: "path"),
              code.StrLit(value: m.json_name),
              code.StrLit(value: default_value),
              greedy_ident,
            ])
          let value = case m.required {
            True ->
              code.Block(items: [
                code.Let(
                  name: "v",
                  value: code.Ident(name: name_concat(["input.", m.snake_name])),
                ),
                code.Case(scrutinee: code.Ident(name: "v"), branches: [
                  code.Branch(pattern: "\"\"", body: default_call),
                  code.Branch(pattern: "_", body: some_branch),
                ]),
              ])
            False ->
              code.Case(
                scrutinee: code.Ident(
                  name: name_concat(["input.", m.snake_name]),
                ),
                branches: [
                  code.Branch(pattern: "option.Some(\"\")", body: default_call),
                  code.Branch(pattern: "option.Some(v)", body: some_branch),
                  code.Branch(pattern: "option.None", body: default_call),
                ],
              )
          }
          code.Let(name: "path", value: value)
        }
        Error(_) -> {
          let value = case m.required {
            True ->
              code.Block(items: [
                code.Let(
                  name: "v",
                  value: code.Ident(name: name_concat(["input.", m.snake_name])),
                ),
                some_branch,
              ])
            False ->
              code.Case(
                scrutinee: code.Ident(
                  name: name_concat(["input.", m.snake_name]),
                ),
                branches: [
                  code.Branch(pattern: "option.Some(v)", body: some_branch),
                  code.Branch(
                    pattern: "option.None",
                    body: code.Ident(name: "path"),
                  ),
                ],
              )
          }
          code.Let(name: "path", value: value)
        }
      }
    })
  [initial, ..updates]
}

// ---------- path / query / header setup ----------

pub fn emit_path_setup(
  uri_template: String,
  labels: List(MemberDef),
) -> List(code.Code) {
  let initial = code.Let(name: "path", value: code.StrLit(value: uri_template))
  let updates =
    list.map(labels, fn(m) {
      let greedy =
        string.contains(uri_template, name_concat(["{", m.json_name, "+}"]))
      let greedy_ident = case greedy {
        True -> code.Ident(name: "True")
        False -> code.Ident(name: "False")
      }
      let substitute =
        code.Call(head: code.Ident(name: "rest.substitute_label"), args: [
          code.Ident(name: "path"),
          code.StrLit(value: m.json_name),
          value_to_string_with_format_code(
            m.target,
            m.timestamp_format,
            code.Ident(name: "v"),
          ),
          greedy_ident,
        ])
      let value = case m.required {
        True ->
          code.Block(items: [
            code.Let(
              name: "v",
              value: code.Ident(name: name_concat(["input.", m.snake_name])),
            ),
            substitute,
          ])
        False ->
          code.Case(
            scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
            branches: [
              code.Branch(pattern: "option.Some(v)", body: substitute),
              code.Branch(
                pattern: "option.None",
                body: code.Ident(name: "path"),
              ),
            ],
          )
      }
      code.Let(name: "path", value: value)
    })
  [initial, ..updates]
}

pub fn emit_query_setup(
  queries: List(MemberDef),
  query_maps: List(MemberDef),
) -> List(code.Code) {
  let initial = code.Let(name: "query", value: code.StrLit(value: ""))
  let query_stmts = list.map(queries, query_member_let)
  let map_stmts = list.filter_map(query_maps, query_map_member_let)
  list.flatten([[initial], query_stmts, map_stmts])
}

fn query_member_let(m: MemberDef) -> code.Code {
  let query_name = case m.binding {
    Query(query_name: n) -> n
    _ -> m.json_name
  }
  let scrutinee = code.Ident(name: name_concat(["input.", m.snake_name]))

  let add_query_call = fn(value_arg: code.Code) {
    code.Call(head: code.Ident(name: "rest.add_query"), args: [
      code.Ident(name: "query"),
      code.StrLit(value: query_name),
      value_arg,
    ])
  }

  let #(some_pattern, some_body) = case m.target, m.idempotency_token {
    _, True -> #("option.Some(v)", add_query_call(code.Ident(name: "v")))
    RList(element: e, ..), _ -> #(
      "option.Some(xs)",
      code.Call(head: code.Ident(name: "list.fold"), args: [
        code.Ident(name: "xs"),
        code.Ident(name: "query"),
        code.Lambda(
          params: ["q", "item"],
          body: code.Call(head: code.Ident(name: "rest.add_query"), args: [
            code.Ident(name: "q"),
            code.StrLit(value: query_name),
            value_to_string_with_format_code(
              e,
              m.timestamp_format,
              code.Ident(name: "item"),
            ),
          ]),
        ),
      ]),
    )
    _, _ -> #(
      "option.Some(v)",
      add_query_call(value_to_string_with_format_code(
        m.target,
        m.timestamp_format,
        code.Ident(name: "v"),
      )),
    )
  }

  let none_body = case m.idempotency_token {
    True ->
      add_query_call(
        code.Call(head: code.Ident(name: "rest.idempotency_token"), args: []),
      )
    False -> code.Ident(name: "query")
  }

  let value = case m.required {
    True -> {
      let binding = case some_pattern {
        "option.Some(xs)" -> code.Let(name: "xs", value: scrutinee)
        _ -> code.Let(name: "v", value: scrutinee)
      }
      code.Block(items: [binding, some_body])
    }
    False ->
      code.Case(scrutinee: scrutinee, branches: [
        code.Branch(pattern: some_pattern, body: some_body),
        code.Branch(pattern: "option.None", body: none_body),
      ])
  }
  code.Let(name: "query", value: value)
}

fn query_map_member_let(m: MemberDef) -> Result(code.Code, Nil) {
  let helper = case m.target {
    RMap(key: _, value: RList(element: RPrim(primitive: types.PString), ..), ..) ->
      Ok("rest.add_query_params_list")
    RMap(key: _, value: RPrim(primitive: types.PString), ..) ->
      Ok("rest.add_query_params")
    _ -> Error(Nil)
  }
  case helper {
    Ok(fn_name) -> {
      let call = fn(value: code.Code) {
        code.Call(head: code.Ident(name: fn_name), args: [
          code.Ident(name: "query"),
          value,
        ])
      }
      let scrutinee = code.Ident(name: name_concat(["input.", m.snake_name]))
      let value = case m.required {
        True -> call(scrutinee)
        False ->
          code.Case(scrutinee: scrutinee, branches: [
            code.Branch(
              pattern: "option.Some(m)",
              body: call(code.Ident(name: "m")),
            ),
            code.Branch(pattern: "option.None", body: code.Ident(name: "query")),
          ])
      }
      Ok(code.Let(name: "query", value: value))
    }
    Error(_) -> Error(Nil)
  }
}

pub fn emit_header_setup(
  headers: List(MemberDef),
  prefix_headers: List(MemberDef),
) -> List(code.Code) {
  // Apply prefix-headers FIRST so explicit `@httpHeader` members
  // override on key collision (`HttpEmptyPrefixHeaders` test:
  // `prefixHeaders.hello = "Hello"` then `specificHeader = "There"`
  // bound to `@httpHeader("hello")` → wire `hello: There`).
  let initial =
    code.Let(
      name: "headers",
      value: code.Call(head: code.Ident(name: "dict.new"), args: []),
    )
  let prefix_stmts = list.map(prefix_headers, prefix_header_let)
  let header_stmts = list.map(headers, header_member_let)
  list.flatten([[initial], prefix_stmts, header_stmts])
}

fn prefix_header_let(m: MemberDef) -> code.Code {
  let prefix = case m.binding {
    PrefixHeaders(prefix: p) -> p
    _ -> ""
  }
  let call = fn(value: code.Code) {
    code.Call(head: code.Ident(name: "rest.add_prefix_headers"), args: [
      code.Ident(name: "headers"),
      code.StrLit(value: prefix),
      value,
    ])
  }
  let scrutinee = code.Ident(name: name_concat(["input.", m.snake_name]))
  let value = case m.required {
    True -> call(scrutinee)
    False ->
      code.Case(scrutinee: scrutinee, branches: [
        code.Branch(
          pattern: "option.Some(m)",
          body: call(code.Ident(name: "m")),
        ),
        code.Branch(pattern: "option.None", body: code.Ident(name: "headers")),
      ])
  }
  code.Let(name: "headers", value: value)
}

fn header_member_let(m: MemberDef) -> code.Code {
  let header_name = case m.binding {
    Header(header_name: n) -> n
    _ -> m.json_name
  }
  case m.target {
    RList(element: e, ..) -> {
      // String list-header entries get RFC 7230 list-quoting; other
      // types (numbers, http-date timestamps, enums) use the raw wire
      // form. Smithy's @httpHeader spec only quotes strings.
      let render = case e {
        RPrim(primitive: types.PString) ->
          code.Call(
            head: code.Ident(name: "rest.quote_list_string_entry"),
            args: [
              code.Ident(name: "item"),
            ],
          )
        _ ->
          value_to_string_for_header_code(
            e,
            m.timestamp_format,
            code.Ident(name: "item"),
          )
      }
      let call =
        code.Call(head: code.Ident(name: "rest.maybe_set_list_header"), args: [
          code.Ident(name: "headers"),
          code.StrLit(value: header_name),
          code.Call(head: code.Ident(name: "list.map"), args: [
            code.Ident(name: "xs"),
            code.Lambda(params: ["item"], body: render),
          ]),
        ])
      let scrutinee = code.Ident(name: name_concat(["input.", m.snake_name]))
      let value = case m.required {
        True ->
          code.Block(items: [code.Let(name: "xs", value: scrutinee), call])
        False ->
          code.Case(scrutinee: scrutinee, branches: [
            code.Branch(pattern: "option.Some(xs)", body: call),
            code.Branch(
              pattern: "option.None",
              body: code.Ident(name: "headers"),
            ),
          ])
      }
      code.Let(name: "headers", value: value)
    }
    _ -> {
      // `@mediaType` on a `@httpHeader` string member means the value
      // is opaque to HTTP — base64 the JSON form so commas / quotes /
      // linefeeds in the payload don't break header parsing.
      let render = case m.target, m.media_type {
        RPrim(primitive: types.PString), Some(_) ->
          code.Call(head: code.Ident(name: "bit_array.base64_encode"), args: [
            code.Call(head: code.Ident(name: "bit_array.from_string"), args: [
              code.Ident(name: "v"),
            ]),
            code.Ident(name: "True"),
          ])
        _, _ ->
          value_to_string_for_header_code(
            m.target,
            m.timestamp_format,
            code.Ident(name: "v"),
          )
      }
      let call =
        code.Call(head: code.Ident(name: "rest.maybe_set_header"), args: [
          code.Ident(name: "headers"),
          code.StrLit(value: header_name),
          render,
        ])
      let scrutinee = code.Ident(name: name_concat(["input.", m.snake_name]))
      let value = case m.required {
        True -> code.Block(items: [code.Let(name: "v", value: scrutinee), call])
        False ->
          code.Case(scrutinee: scrutinee, branches: [
            code.Branch(pattern: "option.Some(v)", body: call),
            code.Branch(
              pattern: "option.None",
              body: code.Ident(name: "headers"),
            ),
          ])
      }
      code.Let(name: "headers", value: value)
    }
  }
}

// ---------- standard header gates ----------

/// `Content-Type` header gate. Insert only when a non-empty
/// `content_type` is set AND no upstream code already set the header.
pub fn content_type_let_block() -> code.Code {
  code.Let(
    name: "headers",
    value: code.CaseSubjects(
      scrutinees: [
        code.Ident(name: "content_type"),
        code.Call(head: code.Ident(name: "dict.has_key"), args: [
          code.Ident(name: "headers"),
          code.StrLit(value: "Content-Type"),
        ]),
      ],
      branches: [
        code.Branch(pattern: "\"\", _", body: code.Ident(name: "headers")),
        code.Branch(pattern: "_, True", body: code.Ident(name: "headers")),
        code.Branch(
          pattern: "_, False",
          body: code.Call(head: code.Ident(name: "dict.insert"), args: [
            code.Ident(name: "headers"),
            code.StrLit(value: "Content-Type"),
            code.Ident(name: "content_type"),
          ]),
        ),
      ],
    ),
  )
}

/// `Content-Length` header — only set when a body is present
/// (empty content_type ⇒ no body).
pub fn content_length_let_block() -> code.Code {
  code.Let(
    name: "headers",
    value: code.Case(scrutinee: code.Ident(name: "content_type"), branches: [
      code.Branch(pattern: "\"\"", body: code.Ident(name: "headers")),
      code.Branch(
        pattern: "_",
        body: code.Call(head: code.Ident(name: "dict.insert"), args: [
          code.Ident(name: "headers"),
          code.StrLit(value: "Content-Length"),
          content_length_expr(),
        ]),
      ),
    ]),
  )
}

/// `@smithy.api#requestCompression` body wrap. For each declared
/// encoding the emitter inserts a `compression.maybe_compress` step
/// that gzips the body when its size is at least
/// `default_min_compression_size_bytes` (10 KiB by default,
/// matching the Rust SDK). When the wrap is applied — and ONLY
/// then — the `Content-Encoding` header gets the encoding appended
/// and `Content-Length` is recomputed against the compressed
/// bytes. Sub-threshold bodies pass through untouched, no header,
/// no wrap, so AWS doesn't reject the mismatch.
pub fn emit_content_encoding(encodings: List(String)) -> List(code.Code) {
  list.flat_map(encodings, fn(enc) {
    [
      code.Let(
        name: "#(body, applied)",
        value: code.Call(
          head: code.Ident(name: "compression.maybe_compress"),
          args: [
            code.Ident(name: "body"),
            code.StrLit(value: enc),
            code.Ident(name: "compression.default_min_compression_size_bytes"),
          ],
        ),
      ),
      code.Let(
        name: "headers",
        value: code.Case(scrutinee: code.Ident(name: "applied"), branches: [
          code.Branch(
            pattern: "True",
            body: code.Call(head: code.Ident(name: "dict.insert"), args: [
              code.Call(
                head: code.Ident(name: "rest.append_content_encoding"),
                args: [code.Ident(name: "headers"), code.StrLit(value: enc)],
              ),
              code.StrLit(value: "Content-Length"),
              content_length_expr(),
            ]),
          ),
          code.Branch(pattern: "False", body: code.Ident(name: "headers")),
        ]),
      ),
    ]
  })
}

fn content_length_expr() -> code.Code {
  code.Call(head: code.Ident(name: "int.to_string"), args: [
    code.Call(head: code.Ident(name: "bit_array.byte_size"), args: [
      code.Ident(name: "body"),
    ]),
  ])
}

// ---------- value formatters ----------

/// Stringify `target` as a Gleam expression that consumes `v` and
/// produces a String. Used in label / query position where the
/// protocol default for timestamps is `date-time` (ISO 8601).
pub fn value_to_string_with_format(
  target: Resolved,
  timestamp_format: Option(String),
) -> String {
  code.render_expr(value_to_string_with_format_code(
    target,
    timestamp_format,
    code.Ident(name: "v"),
  ))
}

pub fn value_to_string_with_format_code(
  target: Resolved,
  timestamp_format: Option(String),
  value: code.Code,
) -> code.Code {
  value_to_string(target, timestamp_format, "date-time", value)
}

/// Same as `value_to_string_with_format`, but the protocol default
/// for timestamps is `http-date` — used in header position.
pub fn value_to_string_for_header(
  target: Resolved,
  timestamp_format: Option(String),
) -> String {
  code.render_expr(value_to_string_for_header_code(
    target,
    timestamp_format,
    code.Ident(name: "v"),
  ))
}

pub fn value_to_string_for_header_code(
  target: Resolved,
  timestamp_format: Option(String),
  value: code.Code,
) -> code.Code {
  value_to_string(target, timestamp_format, "http-date", value)
}

fn value_to_string(
  target: Resolved,
  timestamp_format: Option(String),
  default_ts_format: String,
  value: code.Code,
) -> code.Code {
  case target {
    RPrim(primitive: types.PString) -> value
    RPrim(primitive: types.PInt) ->
      code.Call(head: code.Ident(name: "rest.int_to_query"), args: [value])
    RPrim(primitive: types.PFloat) -> smithy_float_to_string(value)
    RPrim(primitive: types.PBool) ->
      code.Call(head: code.Ident(name: "rest.bool_to_query"), args: [value])
    REnum(local_name: _, ..) ->
      code.Call(head: code.Ident(name: "rest.enum_wire_value"), args: [
        code.Call(head: types.json_encoder_code(target), args: [value]),
      ])
    RIntEnum(gleam_name: n, ..) ->
      code.Call(head: code.Ident(name: "rest.int_to_query"), args: [
        code.Call(
          head: code.Ident(
            name: name_concat([stringutils.pascal_to_snake(n), "_int_value"]),
          ),
          args: [value],
        ),
      ])
    RTimestamp -> {
      let chosen = case timestamp_format {
        Some(f) -> f
        None -> default_ts_format
      }
      case chosen {
        "epoch-seconds" ->
          code.Call(
            head: code.Ident(name: "json_timestamp.epoch_seconds_text"),
            args: [value],
          )
        "http-date" ->
          code.Call(
            head: code.Ident(name: "json_timestamp.format_http_date_precise"),
            args: [value],
          )
        _ ->
          code.Call(
            head: code.Ident(name: "json_timestamp.format_iso8601_precise"),
            args: [value],
          )
      }
    }
    _ -> code.StrLit(value: "")
  }
}

fn smithy_float_to_string(value: code.Code) -> code.Code {
  code.Case(scrutinee: value, branches: [
    code.Branch(
      pattern: "json_float.FloatValue(f)",
      body: code.Call(head: code.Ident(name: "rest.float_to_query"), args: [
        code.Ident(name: "f"),
      ]),
    ),
    code.Branch(pattern: "json_float.NaN", body: code.StrLit(value: "NaN")),
    code.Branch(
      pattern: "json_float.PosInfinity",
      body: code.StrLit(value: "Infinity"),
    ),
    code.Branch(
      pattern: "json_float.NegInfinity",
      body: code.StrLit(value: "-Infinity"),
    ),
  ])
}
