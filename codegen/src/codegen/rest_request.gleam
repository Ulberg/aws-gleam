//// Shared `build_<op>_request` scaffolding for restJson1 and restXml.
////
//// Both protocols categorise input members by their `@http*` binding,
//// stitch together path / query / header setup, then build the final
//// `#(method, path, headers, body)` tuple. Everything except the body
//// shape is identical, so the per-protocol emitter passes a
//// `body_setup` closure into `build_request_module` and gets back the
//// fully-rendered `pub fn build_<op>_request(...)` module fragment.

import codegen/code
import codegen/trait_helpers
import codegen/types.{
  type BindingCategories, type HttpTrait, type MemberDef, type Resolved, Header,
  PrefixHeaders, Query, REnum, RIntEnum, RList, RMap, RPrim, RTimestamp,
}
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
  body_setup: fn(BindingCategories) -> List(code.Code),
) -> String {
  let cats = types.categorize_bindings(members)
  let header_or_input = case !is_unit && types.has_any_binding(cats) {
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
  let body_items =
    list.flatten([
      emit_path_setup(http.uri, cats.labels),
      emit_query_setup(cats.queries, cats.query_maps),
      emit_header_setup(cats.headers, cats.prefix_headers),
      body_setup(cats),
      [content_type_let_block(), content_length_let_block()],
      emit_content_encoding(http.compression),
      md5_step,
      checksum_step,
      [path_assign, result_tuple],
    ])
  code.render(
    code.Module(items: [
      code.Fn(
        public: True,
        name: name_concat(["build_", snake, "_request"]),
        params: [code.Param(name: header_or_input, type_: input_type)],
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
  let encoder = types.json_encoder(member.target)
  let some_branch =
    code.Call(
      head: code.Ident(name: "rest.with_checksum_header_for_wire"),
      args: [
        code.Ident(name: "headers"),
        code.Call(head: code.Ident(name: "rest.enum_wire_value"), args: [
          code.Call(head: code.Ident(name: encoder), args: [
            code.Ident(name: "v"),
          ]),
        ]),
        code.Ident(name: "body"),
      ],
    )
  code.Let(
    name: "headers",
    value: code.Case(
      scrutinee: code.Ident(name: name_concat(["input.", snake])),
      branches: [
        code.Branch(pattern: "option.Some(v)", body: some_branch),
        code.Branch(
          pattern: "option.None",
          body: code.Call(
            head: code.Ident(name: "rest.with_checksum_header"),
            args: [
              code.Ident(name: "headers"),
              code.Ident(name: "rest.ChecksumSha256"),
              code.Ident(name: "body"),
            ],
          ),
        ),
      ],
    ),
  )
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
      code.Let(
        name: "path",
        value: code.Case(
          scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
          branches: [
            code.Branch(
              pattern: "option.Some(v)",
              body: code.Call(
                head: code.Ident(name: "rest.substitute_label"),
                args: [
                  code.Ident(name: "path"),
                  code.StrLit(value: m.json_name),
                  code.Raw(fragment: value_to_string_with_format(
                    m.target,
                    m.timestamp_format,
                  )),
                  greedy_ident,
                ],
              ),
            ),
            code.Branch(pattern: "option.None", body: code.Ident(name: "path")),
          ],
        ),
      )
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
      // `list.fold(xs, query, fn(q, item) { let v = item; rest.add_query(...) })`.
      // The inner `let v = item` lets `value_to_string_with_format`
      // emit its rendering keyed on `v` — that helper assumes a
      // `v`-named binding by convention. Renaming the helper to
      // accept the binding name would invert the dependency; the
      // current shape keeps the rendering atom-sized.
      code.Call(head: code.Ident(name: "list.fold"), args: [
        code.Ident(name: "xs"),
        code.Ident(name: "query"),
        code.Lambda(
          params: ["q", "item"],
          body: code.Block(items: [
            code.Let(name: "v", value: code.Ident(name: "item")),
            code.Call(head: code.Ident(name: "rest.add_query"), args: [
              code.Ident(name: "q"),
              code.StrLit(value: query_name),
              code.Raw(fragment: value_to_string_with_format(
                e,
                m.timestamp_format,
              )),
            ]),
          ]),
        ),
      ]),
    )
    _, _ -> #(
      "option.Some(v)",
      add_query_call(
        code.Raw(fragment: value_to_string_with_format(
          m.target,
          m.timestamp_format,
        )),
      ),
    )
  }

  let none_body = case m.idempotency_token {
    True ->
      add_query_call(
        code.Call(head: code.Ident(name: "rest.idempotency_token"), args: []),
      )
    False -> code.Ident(name: "query")
  }

  code.Let(
    name: "query",
    value: code.Case(scrutinee: scrutinee, branches: [
      code.Branch(pattern: some_pattern, body: some_body),
      code.Branch(pattern: "option.None", body: none_body),
    ]),
  )
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
    Ok(fn_name) ->
      Ok(code.Let(
        name: "query",
        value: code.Case(
          scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
          branches: [
            code.Branch(
              pattern: "option.Some(m)",
              body: code.Call(head: code.Ident(name: fn_name), args: [
                code.Ident(name: "query"),
                code.Ident(name: "m"),
              ]),
            ),
            code.Branch(pattern: "option.None", body: code.Ident(name: "query")),
          ],
        ),
      ))
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
  code.Let(
    name: "headers",
    value: code.Case(
      scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
      branches: [
        code.Branch(
          pattern: "option.Some(m)",
          body: code.Call(
            head: code.Ident(name: "rest.add_prefix_headers"),
            args: [
              code.Ident(name: "headers"),
              code.StrLit(value: prefix),
              code.Ident(name: "m"),
            ],
          ),
        ),
        code.Branch(pattern: "option.None", body: code.Ident(name: "headers")),
      ],
    ),
  )
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
        RPrim(primitive: types.PString) -> "rest.quote_list_string_entry(v)"
        _ -> value_to_string_for_header(e, m.timestamp_format)
      }
      code.Let(
        name: "headers",
        value: code.Case(
          scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
          branches: [
            code.Branch(
              pattern: "option.Some(xs)",
              body: code.Call(
                head: code.Ident(name: "rest.maybe_set_list_header"),
                args: [
                  code.Ident(name: "headers"),
                  code.StrLit(value: header_name),
                  // `list.map(xs, fn(item) { let v = item; <render> })` —
                  // `<render>` is an expression keyed on `v`. The
                  // `let v = item` binding hosts the rename so the
                  // helper-emitted rendering doesn't have to thread
                  // through a parameter name.
                  code.Call(head: code.Ident(name: "list.map"), args: [
                    code.Ident(name: "xs"),
                    code.Lambda(
                      params: ["item"],
                      body: code.Block(items: [
                        code.Let(name: "v", value: code.Ident(name: "item")),
                        code.Raw(fragment: render),
                      ]),
                    ),
                  ]),
                ],
              ),
            ),
            code.Branch(
              pattern: "option.None",
              body: code.Ident(name: "headers"),
            ),
          ],
        ),
      )
    }
    _ -> {
      // `@mediaType` on a `@httpHeader` string member means the value
      // is opaque to HTTP — base64 the JSON form so commas / quotes /
      // linefeeds in the payload don't break header parsing.
      let render = case m.target, m.media_type {
        RPrim(primitive: types.PString), Some(_) ->
          "bit_array.base64_encode(bit_array.from_string(v), True)"
        _, _ -> value_to_string_for_header(m.target, m.timestamp_format)
      }
      code.Let(
        name: "headers",
        value: code.Case(
          scrutinee: code.Ident(name: name_concat(["input.", m.snake_name])),
          branches: [
            code.Branch(
              pattern: "option.Some(v)",
              body: code.Call(
                head: code.Ident(name: "rest.maybe_set_header"),
                args: [
                  code.Ident(name: "headers"),
                  code.StrLit(value: header_name),
                  code.Raw(fragment: render),
                ],
              ),
            ),
            code.Branch(
              pattern: "option.None",
              body: code.Ident(name: "headers"),
            ),
          ],
        ),
      )
    }
  }
}

// ---------- standard header gates ----------

/// `Content-Type` header gate. Insert only when a non-empty
/// `content_type` is set AND no upstream code already set the header.
pub fn content_type_let_block() -> code.Code {
  code.Let(
    name: "headers",
    value: code.Case(
      scrutinee: code.Raw(
        fragment: "content_type, dict.has_key(headers, \"Content-Type\")",
      ),
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
          code.Raw(fragment: "int.to_string(bit_array.byte_size(body))"),
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
        value: code.Raw(
          fragment: "compression.maybe_compress(body, \""
          <> enc
          <> "\", compression.default_min_compression_size_bytes)",
        ),
      ),
      code.Let(
        name: "headers",
        value: code.Raw(
          fragment: "case applied { True -> dict.insert(rest.append_content_encoding(headers, \""
          <> enc
          <> "\"), \"Content-Length\", int.to_string(bit_array.byte_size(body))) False -> headers }",
        ),
      ),
    ]
  })
}

// ---------- value formatters ----------

/// Stringify `target` as a Gleam expression that consumes `v` and
/// produces a String. Used in label / query position where the
/// protocol default for timestamps is `date-time` (ISO 8601).
pub fn value_to_string_with_format(
  target: Resolved,
  timestamp_format: Option(String),
) -> String {
  value_to_string(target, timestamp_format, "date-time")
}

/// Same as `value_to_string_with_format`, but the protocol default
/// for timestamps is `http-date` — used in header position.
pub fn value_to_string_for_header(
  target: Resolved,
  timestamp_format: Option(String),
) -> String {
  value_to_string(target, timestamp_format, "http-date")
}

fn value_to_string(
  target: Resolved,
  timestamp_format: Option(String),
  default_ts_format: String,
) -> String {
  case target {
    RPrim(primitive: types.PString) -> "v"
    RPrim(primitive: types.PInt) -> "rest.int_to_query(v)"
    RPrim(primitive: types.PFloat) ->
      "case v { json_float.FloatValue(f) -> rest.float_to_query(f) json_float.NaN -> \"NaN\" json_float.PosInfinity -> \"Infinity\" json_float.NegInfinity -> \"-Infinity\" }"
    RPrim(primitive: types.PBool) -> "rest.bool_to_query(v)"
    REnum(local_name: _, ..) ->
      name_concat(["rest.enum_wire_value(", types.json_encoder(target), "(v))"])
    RIntEnum(gleam_name: n, ..) ->
      name_concat([
        "rest.int_to_query(",
        stringutils.pascal_to_snake(n),
        "_int_value(v))",
      ])
    RTimestamp -> {
      let chosen = case timestamp_format {
        Some(f) -> f
        None -> default_ts_format
      }
      case chosen {
        "epoch-seconds" -> "json_timestamp.epoch_seconds_text(v)"
        "http-date" -> "json_timestamp.format_http_date_precise(v)"
        _ -> "json_timestamp.format_iso8601_precise(v)"
      }
    }
    _ -> "\"\""
  }
}
