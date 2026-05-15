//// Smithy endpoint rule set evaluator.
////
//// Implements the runtime side of the Smithy rules engine: parses a
//// `endpoint-rule-set.json` document, then walks it against a set of
//// parameter values and produces a concrete endpoint URL.
////
//// Supported features:
////
////   - Rule types: `endpoint`, `error`, `tree`
////   - Parameters: `String`, `Boolean`, with `default` and `required`
////   - Templates: `{Name}` and `{Var#field}` (and nested `{Var#a#b}`)
////   - Built-in functions: `isSet`, `not`, `booleanEquals`, `stringEquals`,
////     `getAttr`, `substring`, `uriEncode`, `parseURL`, `isValidHostLabel`,
////     `aws.partition`, `aws.parseArn`, `aws.isVirtualHostableS3Bucket`
////   - Common partition data hardcoded (`aws`, `aws-cn`, `aws-us-gov`).
////     For a richer table, vendor `partitions.json` and replace
////     `partition_for/1`.
////
//// Not implemented (rare; flagged at evaluation time as `Unsupported`):
////
////   - `StringArray` parameter type (used by a few new services)
////
//// Codegen at milestone 7 will use this evaluator at compile time to emit
//// per-service endpoint resolvers; the runtime fallback path here keeps
//// hand-written services working before any code is generated.

import gleam/bit_array
import gleam/dict.{type Dict}
import gleam/dynamic/decode
import gleam/int
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string

// ---------- public API ----------

pub type Endpoint {
  Endpoint(url: String, headers: Dict(String, List(String)))
}

pub type ResolveError {
  /// A rule's `error` branch fired with this message.
  RuleError(message: String)
  /// No rule matched (the rule set is supposed to always end in either an
  /// endpoint or an error rule, so this normally indicates a bad rule set).
  NoMatch
  /// JSON could not be parsed into a `RuleSet`.
  InvalidRuleSet(reason: String)
  /// Evaluation tripped over an unimplemented function or a parameter type
  /// the evaluator doesn't support yet.
  Unsupported(reason: String)
  /// A parameter referenced by a rule wasn't supplied and has no default.
  MissingParameter(name: String)
  /// A required parameter is unset.
  RequiredParameterMissing(name: String)
}

/// Parameter values supplied to evaluation. Keys are parameter names.
pub type Params =
  Dict(String, Value)

/// Runtime values that flow through evaluation: literals plus the record
/// shape that `aws.partition` returns.
pub type Value {
  StringVal(String)
  BoolVal(Bool)
  RecordVal(Dict(String, Value))
  EmptyVal
}

/// Convenience constructor: build a `Params` map from string and boolean
/// pairs. The most common shape (Region + UseFips + UseDualStack).
pub fn params_from(
  strings strings: List(#(String, String)),
  bools bools: List(#(String, Bool)),
) -> Params {
  let s_dict =
    list.fold(strings, dict.new(), fn(acc, pair) {
      dict.insert(acc, pair.0, StringVal(pair.1))
    })
  list.fold(bools, s_dict, fn(acc, pair) {
    dict.insert(acc, pair.0, BoolVal(pair.1))
  })
}

/// Parse a rule set JSON document (as a Gleam string) into the internal AST.
/// The result is reusable across many `resolve` calls with different params.
pub fn parse_rule_set(json_text: String) -> Result(RuleSet, ResolveError) {
  json.parse(json_text, rule_set_decoder())
  |> result.map_error(fn(err) {
    InvalidRuleSet(reason: describe_decode_error(err))
  })
}

/// Walk the rule set with the given parameters. Returns the first matching
/// endpoint, the first matching error rule (surfaced as `RuleError`), or
/// `NoMatch` if every rule's conditions failed.
pub fn resolve(
  rule_set: RuleSet,
  params: Params,
) -> Result(Endpoint, ResolveError) {
  use prepared <- result.try(apply_defaults_and_check_required(rule_set, params))
  evaluate_rules(rule_set.rules, prepared)
}

// ---------- AST ----------

pub type RuleSet {
  RuleSet(parameters: Dict(String, Parameter), rules: List(Rule))
}

pub type Parameter {
  Parameter(
    type_: ParamType,
    required: Bool,
    default: Option(Value),
    builtin: Option(String),
  )
}

pub type ParamType {
  StringType
  BooleanType
}

pub type Rule {
  EndpointRule(conditions: List(Condition), endpoint: EndpointSpec)
  ErrorRule(conditions: List(Condition), message: Expr)
  TreeRule(conditions: List(Condition), rules: List(Rule))
}

pub type EndpointSpec {
  EndpointSpec(url: Expr, headers: Dict(String, List(Expr)))
}

pub type Condition {
  Condition(expr: Expr, assign: Option(String))
}

pub type Expr {
  /// Reference to a parameter or assigned variable.
  Ref(name: String)
  /// String literal that may contain `{Name}` and `{Var#field}` interpolations.
  TemplateExpr(parts: List(TemplatePart))
  BoolLit(value: Bool)
  /// Integer literal — `substring(input, 0, 3, false)` and similar.
  IntLit(value: Int)
  /// Builtin function call. The function name is the raw "fn" value
  /// (e.g. `"isSet"`, `"aws.partition"`).
  FnCall(name: String, args: List(Expr))
}

pub type TemplatePart {
  Static(text: String)
  Interp(path: List(String))
}

// ---------- decoder ----------

fn rule_set_decoder() -> decode.Decoder(RuleSet) {
  use parameters <- decode.field("parameters", parameters_decoder())
  use rules <- decode.field("rules", decode.list(rule_decoder()))
  decode.success(RuleSet(parameters: parameters, rules: rules))
}

fn parameters_decoder() -> decode.Decoder(Dict(String, Parameter)) {
  decode.dict(decode.string, parameter_decoder())
}

fn parameter_decoder() -> decode.Decoder(Parameter) {
  use type_str <- decode.field("type", decode.string)
  use required <- decode.optional_field("required", False, decode.bool)
  use default <- decode.then(decode.optionally_at(
    ["default"],
    None,
    decode.map(value_decoder(), Some),
  ))
  use builtin <- decode.then(decode.optionally_at(
    ["builtIn"],
    None,
    decode.map(decode.string, Some),
  ))
  let type_ = case string.lowercase(type_str) {
    "string" -> StringType
    _ -> BooleanType
  }
  decode.success(Parameter(
    type_: type_,
    required: required,
    default: default,
    builtin: builtin,
  ))
}

fn value_decoder() -> decode.Decoder(Value) {
  decode.one_of(decode.map(decode.string, StringVal), [
    decode.map(decode.bool, BoolVal),
  ])
}

fn rule_decoder() -> decode.Decoder(Rule) {
  use type_str <- decode.field("type", decode.string)
  case type_str {
    "endpoint" -> endpoint_rule_decoder()
    "error" -> error_rule_decoder()
    "tree" -> tree_rule_decoder()
    _ -> decode.failure(error_rule_failsafe(), "unknown rule type")
  }
}

fn error_rule_failsafe() -> Rule {
  ErrorRule(
    conditions: [],
    message: TemplateExpr(parts: [Static("unknown rule")]),
  )
}

fn conditions_decoder() -> decode.Decoder(List(Condition)) {
  decode.list(condition_decoder())
}

fn condition_decoder() -> decode.Decoder(Condition) {
  use fn_name <- decode.field("fn", decode.string)
  use argv <- decode.field("argv", decode.list(expr_decoder()))
  use assign <- decode.then(decode.optionally_at(
    ["assign"],
    None,
    decode.map(decode.string, Some),
  ))
  decode.success(Condition(
    expr: FnCall(name: fn_name, args: argv),
    assign: assign,
  ))
}

/// Decoder for an `Expr` — i.e. anything that can appear in an `argv` slot
/// of a function call or as the value of an endpoint property. Smithy rules
/// allow several shapes here, so we use `one_of` to try each in turn.
fn expr_decoder() -> decode.Decoder(Expr) {
  decode.one_of(ref_decoder(), [
    bool_decoder(),
    int_decoder(),
    fn_call_decoder(),
    string_expr_decoder(),
  ])
}

fn int_decoder() -> decode.Decoder(Expr) {
  decode.map(decode.int, IntLit)
}

fn ref_decoder() -> decode.Decoder(Expr) {
  use name <- decode.field("ref", decode.string)
  decode.success(Ref(name: name))
}

fn bool_decoder() -> decode.Decoder(Expr) {
  decode.map(decode.bool, BoolLit)
}

fn fn_call_decoder() -> decode.Decoder(Expr) {
  use fn_name <- decode.field("fn", decode.string)
  use argv <- decode.field("argv", decode.list(expr_decoder()))
  decode.success(FnCall(name: fn_name, args: argv))
}

fn string_expr_decoder() -> decode.Decoder(Expr) {
  decode.map(decode.string, fn(s) { TemplateExpr(parts: parse_template(s)) })
}

/// Endpoint rule fields: `endpoint = { url, properties, headers }`.
fn endpoint_rule_decoder() -> decode.Decoder(Rule) {
  use conditions <- decode.field("conditions", conditions_decoder())
  use url <- decode.subfield(["endpoint", "url"], expr_decoder())
  use headers <- decode.then(decode.optionally_at(
    ["endpoint", "headers"],
    dict.new(),
    decode.dict(decode.string, decode.list(expr_decoder())),
  ))
  decode.success(EndpointRule(
    conditions: conditions,
    endpoint: EndpointSpec(url: url, headers: headers),
  ))
}

fn error_rule_decoder() -> decode.Decoder(Rule) {
  use conditions <- decode.field("conditions", conditions_decoder())
  use message <- decode.field("error", expr_decoder())
  decode.success(ErrorRule(conditions: conditions, message: message))
}

fn tree_rule_decoder() -> decode.Decoder(Rule) {
  use conditions <- decode.field("conditions", conditions_decoder())
  use rules <- decode.field("rules", decode.list(rule_decoder()))
  decode.success(TreeRule(conditions: conditions, rules: rules))
}

fn describe_decode_error(err: json.DecodeError) -> String {
  case err {
    json.UnexpectedByte(b) -> "unexpected byte: " <> b
    json.UnexpectedEndOfInput -> "unexpected end of input"
    json.UnexpectedSequence(_) -> "unexpected sequence in JSON"
    json.UnableToDecode(_) -> "JSON did not match rule set schema"
  }
}

// ---------- template parsing ----------

/// Split a raw template string into static + interpolation segments.
/// `{Region}` becomes `Interp(["Region"])`. `{var#field#sub}` becomes
/// `Interp(["var", "field", "sub"])`. Literal `{{` and `}}` are NOT supported
/// — none of the AWS rule sets in scope use escaped braces.
fn parse_template(text: String) -> List(TemplatePart) {
  do_parse_template(text, "", [])
}

fn do_parse_template(
  remaining: String,
  static_buf: String,
  acc: List(TemplatePart),
) -> List(TemplatePart) {
  case string.split_once(remaining, "{") {
    Error(_) -> list.reverse([Static(static_buf <> remaining), ..acc])
    Ok(#(before_brace, rest_with_brace)) ->
      case string.split_once(rest_with_brace, "}") {
        Error(_) ->
          // Unbalanced brace — just take the rest as literal.
          list.reverse([Static(static_buf <> remaining), ..acc])
        Ok(#(interp_body, after_close)) -> {
          let new_static = static_buf <> before_brace
          let acc = case new_static {
            "" -> acc
            _ -> [Static(new_static), ..acc]
          }
          let path = string.split(interp_body, "#")
          let acc = [Interp(path: path), ..acc]
          do_parse_template(after_close, "", acc)
        }
      }
  }
}

// ---------- evaluation ----------

fn apply_defaults_and_check_required(
  rule_set: RuleSet,
  params: Params,
) -> Result(Params, ResolveError) {
  dict.fold(rule_set.parameters, Ok(params), fn(acc, name, parameter) {
    use current <- result.try(acc)
    case dict.get(current, name) {
      Ok(_) -> Ok(current)
      Error(_) ->
        case parameter.default {
          Some(value) -> Ok(dict.insert(current, name, value))
          None ->
            case parameter.required {
              True -> Error(RequiredParameterMissing(name: name))
              False -> Ok(current)
            }
        }
    }
  })
}

fn evaluate_rules(
  rules: List(Rule),
  scope: Params,
) -> Result(Endpoint, ResolveError) {
  case rules {
    [] -> Error(NoMatch)
    [rule, ..rest] ->
      case try_rule(rule, scope) {
        Ok(Some(endpoint)) -> Ok(endpoint)
        Ok(None) -> evaluate_rules(rest, scope)
        Error(reason) -> Error(reason)
      }
  }
}

/// `Ok(Some(_))`  — matched + produced an endpoint
/// `Ok(None)`     — conditions didn't match; try the next rule
/// `Error(_)`     — an error rule fired, or evaluation hit an error
fn try_rule(
  rule: Rule,
  scope: Params,
) -> Result(Option(Endpoint), ResolveError) {
  case rule {
    EndpointRule(conditions: conditions, endpoint: endpoint) -> {
      case check_conditions(conditions, scope) {
        Ok(None) -> Ok(None)
        Ok(Some(new_scope)) -> {
          use url <- result.try(eval_to_string(endpoint.url, new_scope))
          use headers <- result.try(eval_headers(endpoint.headers, new_scope))
          Ok(Some(Endpoint(url: url, headers: headers)))
        }
        Error(reason) -> Error(reason)
      }
    }
    ErrorRule(conditions: conditions, message: message) -> {
      case check_conditions(conditions, scope) {
        Ok(None) -> Ok(None)
        Ok(Some(new_scope)) -> {
          use text <- result.try(eval_to_string(message, new_scope))
          Error(RuleError(message: text))
        }
        Error(reason) -> Error(reason)
      }
    }
    TreeRule(conditions: conditions, rules: nested) ->
      case check_conditions(conditions, scope) {
        Ok(None) -> Ok(None)
        Ok(Some(new_scope)) ->
          case evaluate_rules(nested, new_scope) {
            Ok(endpoint) -> Ok(Some(endpoint))
            Error(NoMatch) -> Ok(None)
            Error(reason) -> Error(reason)
          }
        Error(reason) -> Error(reason)
      }
  }
}

fn check_conditions(
  conditions: List(Condition),
  scope: Params,
) -> Result(Option(Params), ResolveError) {
  do_check(conditions, scope)
}

fn do_check(
  conditions: List(Condition),
  scope: Params,
) -> Result(Option(Params), ResolveError) {
  case conditions {
    [] -> Ok(Some(scope))
    [Condition(expr: expr, assign: assign), ..rest] -> {
      use value <- result.try(eval(expr, scope))
      // A condition is true when the value is truthy (non-empty / non-false).
      case is_truthy(value) {
        False -> Ok(None)
        True -> {
          let scope = case assign {
            Some(name) -> dict.insert(scope, name, value)
            None -> scope
          }
          do_check(rest, scope)
        }
      }
    }
  }
}

fn is_truthy(value: Value) -> Bool {
  case value {
    EmptyVal -> False
    BoolVal(b) -> b
    _ -> True
  }
}

fn eval_headers(
  headers: Dict(String, List(Expr)),
  scope: Params,
) -> Result(Dict(String, List(String)), ResolveError) {
  dict.fold(headers, Ok(dict.new()), fn(acc, key, exprs) {
    use current <- result.try(acc)
    use values <- result.try(eval_string_list(exprs, scope))
    Ok(dict.insert(current, key, values))
  })
}

fn eval_string_list(
  exprs: List(Expr),
  scope: Params,
) -> Result(List(String), ResolveError) {
  case exprs {
    [] -> Ok([])
    [head, ..tail] -> {
      use h <- result.try(eval_to_string(head, scope))
      use t <- result.try(eval_string_list(tail, scope))
      Ok([h, ..t])
    }
  }
}

fn eval(expr: Expr, scope: Params) -> Result(Value, ResolveError) {
  case expr {
    Ref(name: name) ->
      case dict.get(scope, name) {
        Ok(value) -> Ok(value)
        Error(_) -> Ok(EmptyVal)
      }
    BoolLit(value: value) -> Ok(BoolVal(value))
    IntLit(value: n) -> Ok(StringVal(int.to_string(n)))
    TemplateExpr(parts: parts) ->
      eval_template(parts, scope)
      |> result.map(StringVal)
    FnCall(name: name, args: args) -> eval_builtin(name, args, scope)
  }
}

fn eval_to_string(expr: Expr, scope: Params) -> Result(String, ResolveError) {
  use value <- result.try(eval(expr, scope))
  case value {
    StringVal(s) -> Ok(s)
    BoolVal(True) -> Ok("true")
    BoolVal(False) -> Ok("false")
    EmptyVal -> Ok("")
    RecordVal(_) -> Error(Unsupported(reason: "cannot stringify record value"))
  }
}

fn eval_template(
  parts: List(TemplatePart),
  scope: Params,
) -> Result(String, ResolveError) {
  do_eval_template(parts, scope, "")
}

fn do_eval_template(
  parts: List(TemplatePart),
  scope: Params,
  acc: String,
) -> Result(String, ResolveError) {
  case parts {
    [] -> Ok(acc)
    [Static(text), ..rest] -> do_eval_template(rest, scope, acc <> text)
    [Interp(path: path), ..rest] -> {
      use value <- result.try(lookup_path(path, scope))
      use text <- result.try(value_to_string(value))
      do_eval_template(rest, scope, acc <> text)
    }
  }
}

fn lookup_path(
  path: List(String),
  scope: Params,
) -> Result(Value, ResolveError) {
  case path {
    [] -> Ok(EmptyVal)
    [first, ..rest] ->
      case dict.get(scope, first) {
        Error(_) -> Ok(EmptyVal)
        Ok(value) -> traverse_record(value, rest)
      }
  }
}

fn traverse_record(
  value: Value,
  path: List(String),
) -> Result(Value, ResolveError) {
  case path {
    [] -> Ok(value)
    [field, ..rest] ->
      case value {
        RecordVal(fields) ->
          case dict.get(fields, field) {
            Ok(inner) -> traverse_record(inner, rest)
            Error(_) -> Ok(EmptyVal)
          }
        _ -> Ok(EmptyVal)
      }
  }
}

fn value_to_string(value: Value) -> Result(String, ResolveError) {
  case value {
    StringVal(s) -> Ok(s)
    BoolVal(True) -> Ok("true")
    BoolVal(False) -> Ok("false")
    EmptyVal -> Ok("")
    RecordVal(_) -> Error(Unsupported(reason: "cannot stringify record"))
  }
}

fn eval_builtin(
  name: String,
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case name {
    "isSet" -> bi_is_set(args, scope)
    "not" -> bi_not(args, scope)
    "booleanEquals" -> bi_boolean_equals(args, scope)
    "stringEquals" -> bi_string_equals(args, scope)
    "getAttr" -> bi_get_attr(args, scope)
    "substring" -> bi_substring(args, scope)
    "uriEncode" -> bi_uri_encode(args, scope)
    "parseURL" -> bi_parse_url(args, scope)
    "isValidHostLabel" -> bi_is_valid_host_label(args, scope)
    "aws.partition" -> bi_aws_partition(args, scope)
    "aws.parseArn" -> bi_aws_parse_arn(args, scope)
    "aws.isVirtualHostableS3Bucket" ->
      bi_is_virtual_hostable_s3_bucket(args, scope)
    _ ->
      Error(Unsupported(
        reason: "endpoint rule builtin '" <> name <> "' not implemented",
      ))
  }
}

fn bi_is_set(args: List(Expr), scope: Params) -> Result(Value, ResolveError) {
  case args {
    [arg] -> {
      use value <- result.try(eval(arg, scope))
      Ok(
        BoolVal(case value {
          EmptyVal -> False
          _ -> True
        }),
      )
    }
    _ -> Error(Unsupported(reason: "isSet expects 1 argument"))
  }
}

fn bi_not(args: List(Expr), scope: Params) -> Result(Value, ResolveError) {
  case args {
    [arg] -> {
      use value <- result.try(eval(arg, scope))
      Ok(BoolVal(!is_truthy(value)))
    }
    _ -> Error(Unsupported(reason: "not expects 1 argument"))
  }
}

fn bi_boolean_equals(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [a, b] -> {
      use va <- result.try(eval(a, scope))
      use vb <- result.try(eval(b, scope))
      Ok(
        BoolVal(case va, vb {
          BoolVal(x), BoolVal(y) -> x == y
          _, _ -> False
        }),
      )
    }
    _ -> Error(Unsupported(reason: "booleanEquals expects 2 arguments"))
  }
}

fn bi_string_equals(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [a, b] -> {
      use sa <- result.try(eval_to_string(a, scope))
      use sb <- result.try(eval_to_string(b, scope))
      Ok(BoolVal(sa == sb))
    }
    _ -> Error(Unsupported(reason: "stringEquals expects 2 arguments"))
  }
}

fn bi_get_attr(args: List(Expr), scope: Params) -> Result(Value, ResolveError) {
  case args {
    [obj, key] -> {
      use record <- result.try(eval(obj, scope))
      use key_str <- result.try(eval_to_string(key, scope))
      // The path may include array indexing like "resourceId[0]". Parse into
      // a sequence of segments and walk.
      let path = parse_attr_path(key_str)
      Ok(traverse_value(record, path))
    }
    _ -> Error(Unsupported(reason: "getAttr expects 2 arguments"))
  }
}

/// Parse a getAttr path into a list of segments. `"service"` → `["service"]`,
/// `"resourceId[0]"` → `["resourceId", "0"]`, `"a[1][2]"` → `["a","1","2"]`.
fn parse_attr_path(path: String) -> List(String) {
  path
  |> string.split("[")
  |> list.map(fn(segment) { string.replace(segment, "]", "") })
  |> list.filter(fn(s) { s != "" })
}

fn traverse_value(value: Value, path: List(String)) -> Value {
  case path {
    [] -> value
    [first, ..rest] ->
      case value {
        RecordVal(fields) ->
          case dict.get(fields, first) {
            Ok(inner) -> traverse_value(inner, rest)
            Error(_) -> EmptyVal
          }
        _ -> EmptyVal
      }
  }
}

fn bi_aws_partition(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [region_expr] -> {
      use region <- result.try(eval_to_string(region_expr, scope))
      Ok(RecordVal(partition_for(region)))
    }
    _ -> Error(Unsupported(reason: "aws.partition expects 1 argument"))
  }
}

/// `substring(input, start, stop, reverse)` — Smithy spec says the result is
/// empty (returns `EmptyVal`) if any character is non-ASCII, or if the range
/// is invalid. With `reverse=true` the indexes count from the end of the
/// string.
fn bi_substring(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [input_expr, start_expr, stop_expr, reverse_expr] -> {
      use input <- result.try(eval_to_string(input_expr, scope))
      use start <- result.try(eval_to_int(start_expr, scope))
      use stop <- result.try(eval_to_int(stop_expr, scope))
      use reverse <- result.try(eval_to_bool(reverse_expr, scope))
      Ok(do_substring(input, start, stop, reverse))
    }
    _ -> Error(Unsupported(reason: "substring expects 4 arguments"))
  }
}

fn do_substring(input: String, start: Int, stop: Int, reverse: Bool) -> Value {
  let length = string.length(input)
  // Spec: empty if any byte is > 127 (non-ASCII). We're stricter than
  // necessary: use byte length so multi-byte chars don't sneak in.
  let bytes = bit_array.byte_size(bit_array.from_string(input))
  case bytes != length {
    True -> EmptyVal
    False ->
      case start < 0 || stop > length || start >= stop {
        True -> EmptyVal
        False -> {
          let #(real_start, real_stop) = case reverse {
            False -> #(start, stop)
            True -> #(length - stop, length - start)
          }
          StringVal(string.slice(input, real_start, real_stop - real_start))
        }
      }
  }
}

/// Percent-encode a URI component.
fn bi_uri_encode(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [arg] -> {
      use input <- result.try(eval_to_string(arg, scope))
      Ok(StringVal(percent_encode_uri(input)))
    }
    _ -> Error(Unsupported(reason: "uriEncode expects 1 argument"))
  }
}

fn percent_encode_uri(input: String) -> String {
  // Re-use the same encoder we use for SigV4 component encoding.
  case input {
    "" -> ""
    _ -> aws_uri_encode(input)
  }
}

/// Parse a URL into `{ scheme, authority, path, normalizedPath, isIp }`.
/// Returns `EmptyVal` if the URL doesn't look well-formed. We support the
/// shapes AWS rule sets actually pass us; this is not a full RFC 3986
/// parser.
fn bi_parse_url(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [arg] -> {
      use url <- result.try(eval_to_string(arg, scope))
      Ok(parse_url(url))
    }
    _ -> Error(Unsupported(reason: "parseURL expects 1 argument"))
  }
}

fn parse_url(url: String) -> Value {
  // Smithy parseURL: scheme must be http or https, no userinfo, no fragment.
  case string.split_once(url, "://") {
    Error(_) -> EmptyVal
    Ok(#(scheme, rest)) ->
      case scheme {
        "http" | "https" -> do_parse_url_parts(scheme, rest)
        _ -> EmptyVal
      }
  }
}

fn do_parse_url_parts(scheme: String, after_scheme: String) -> Value {
  // No userinfo (`@`) and no fragment (`#`) allowed.
  case
    string.contains(after_scheme, "@") || string.contains(after_scheme, "#")
  {
    True -> EmptyVal
    False -> {
      let #(authority, path_and_query) = case
        string.split_once(after_scheme, "/")
      {
        Ok(#(a, rest)) -> #(a, "/" <> rest)
        Error(_) -> #(after_scheme, "")
      }
      let path = case string.split_once(path_and_query, "?") {
        Ok(#(p, _)) -> p
        Error(_) -> path_and_query
      }
      // `path` is the literal value (may be "" for hostnames with no path);
      // `normalizedPath` always starts AND ends with "/" so callers can
      // concatenate suffixes without worrying about doubled slashes.
      let normalized = case path {
        "" -> "/"
        _ ->
          case string.ends_with(path, "/") {
            True -> path
            False -> path <> "/"
          }
      }
      let is_ip = looks_like_ip(authority)
      RecordVal(
        dict.from_list([
          #("scheme", StringVal(scheme)),
          #("authority", StringVal(authority)),
          #("path", StringVal(path)),
          #("normalizedPath", StringVal(normalized)),
          #("isIp", BoolVal(is_ip)),
        ]),
      )
    }
  }
}

fn looks_like_ip(authority: String) -> Bool {
  // Strip port if any.
  let host = case string.split_once(authority, ":") {
    Ok(#(h, _)) -> h
    Error(_) -> authority
  }
  // Pure dotted-decimal IPv4 or bracket-wrapped IPv6.
  case string.starts_with(host, "[") && string.ends_with(host, "]") {
    True -> True
    False -> all_ip4_segments(string.split(host, "."))
  }
}

fn all_ip4_segments(parts: List(String)) -> Bool {
  case list.length(parts) {
    4 -> list.all(parts, fn(p) { is_int_string(p) })
    _ -> False
  }
}

fn is_int_string(s: String) -> Bool {
  case int.parse(s) {
    Ok(_) -> True
    Error(_) -> False
  }
}

/// Parse an AWS ARN: `arn:partition:service:region:accountId:resource`. The
/// resource is whatever comes after the fifth colon. Returns `EmptyVal` if
/// the input doesn't have at least 6 colon-separated parts.
fn bi_aws_parse_arn(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [arg] -> {
      use arn <- result.try(eval_to_string(arg, scope))
      Ok(parse_arn(arn))
    }
    _ -> Error(Unsupported(reason: "aws.parseArn expects 1 argument"))
  }
}

/// Port of the Go SDK's `awsrulesfn.ParseARN`
/// (aws-sdk-go-v2/internal/endpoints/awsrulesfn/arn.go). Requires the
/// literal `arn:` prefix, splits into exactly six sections (so colons in
/// the resource section stay intact), requires non-empty partition /
/// service / resource, and splits the resource on either `:` or `/`.
fn parse_arn(arn: String) -> Value {
  case string.starts_with(arn, "arn:") {
    False -> EmptyVal
    True ->
      case split_n(arn, ":", 6) {
        [_, partition, service, region, account_id, resource]
          if partition != "" && service != "" && resource != ""
        ->
          RecordVal(
            dict.from_list([
              #("partition", StringVal(partition)),
              #("service", StringVal(service)),
              #("region", StringVal(region)),
              #("accountId", StringVal(account_id)),
              #("resourceId", split_resource_to_value(resource)),
            ]),
          )
        _ -> EmptyVal
      }
  }
}

/// `strings.SplitN(input, sep, n)` — split into at most `n` parts; the last
/// part keeps any remaining separators as literal characters.
fn split_n(input: String, sep: String, n: Int) -> List(String) {
  do_split_n(input, sep, n, [])
}

fn do_split_n(
  input: String,
  sep: String,
  n: Int,
  acc: List(String),
) -> List(String) {
  case n <= 1 {
    True -> list.reverse([input, ..acc])
    False ->
      case string.split_once(input, sep) {
        Ok(#(head, rest)) -> do_split_n(rest, sep, n - 1, [head, ..acc])
        Error(_) -> list.reverse([input, ..acc])
      }
  }
}

/// Resource-section splitter: break on either `/` or `:`, like the Go SDK's
/// `splitResource`.
fn split_resource_to_value(resource: String) -> Value {
  resource
  |> split_resource_chars
  |> list.index_map(fn(part, idx) { #(int.to_string(idx), StringVal(part)) })
  |> dict.from_list
  |> RecordVal
}

fn split_resource_chars(input: String) -> List(String) {
  do_split_resource(input, "", [])
}

fn do_split_resource(
  input: String,
  buf: String,
  acc: List(String),
) -> List(String) {
  case string.pop_grapheme(input) {
    Error(_) -> list.reverse([buf, ..acc])
    Ok(#(c, rest)) ->
      case c {
        "/" | ":" -> do_split_resource(rest, "", [buf, ..acc])
        _ -> do_split_resource(rest, buf <> c, acc)
      }
  }
}

/// RFC 1123 host label validation. Accepts ASCII letters/digits/hyphens, no
/// leading/trailing hyphen, length 1..63. With `allowSubdomains=true` the
/// label may be `.`-separated and each piece is validated independently.
fn bi_is_valid_host_label(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [name_expr, allow_subdomains_expr] -> {
      use name <- result.try(eval_to_string(name_expr, scope))
      use allow_subdomains <- result.try(eval_to_bool(
        allow_subdomains_expr,
        scope,
      ))
      Ok(BoolVal(is_valid_host_label(name, allow_subdomains)))
    }
    _ -> Error(Unsupported(reason: "isValidHostLabel expects 2 arguments"))
  }
}

fn is_valid_host_label(name: String, allow_subdomains: Bool) -> Bool {
  case allow_subdomains {
    False -> is_one_host_label(name)
    True ->
      name
      |> string.split(".")
      |> list.all(is_one_host_label)
  }
}

fn is_one_host_label(label: String) -> Bool {
  let length = string.length(label)
  let bytes = bit_array.byte_size(bit_array.from_string(label))
  case length == bytes && length >= 1 && length <= 63 {
    False -> False
    True ->
      !string.starts_with(label, "-")
      && !string.ends_with(label, "-")
      && all_host_label_chars(string.to_graphemes(label))
  }
}

fn all_host_label_chars(chars: List(String)) -> Bool {
  list.all(chars, fn(c) {
    case c {
      "-" -> True
      _ -> is_lower_alnum(c) || is_upper_alpha(c) || is_digit(c)
    }
  })
}

fn is_upper_alpha(c: String) -> Bool {
  case string.to_utf_codepoints(c) {
    [cp] -> {
      let n = string.utf_codepoint_to_int(cp)
      n >= 65 && n <= 90
    }
    _ -> False
  }
}

fn is_digit(c: String) -> Bool {
  case c {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ -> False
  }
}

/// DNS-3-to-63-char rules + S3 bucket constraints: lowercase letters, digits,
/// hyphens; not IP-shaped; doesn't begin or end with a hyphen.
fn bi_is_virtual_hostable_s3_bucket(
  args: List(Expr),
  scope: Params,
) -> Result(Value, ResolveError) {
  case args {
    [name_expr, allow_subdomains_expr] -> {
      use name <- result.try(eval_to_string(name_expr, scope))
      use allow_subdomains <- result.try(eval_to_bool(
        allow_subdomains_expr,
        scope,
      ))
      Ok(BoolVal(is_virtual_hostable(name, allow_subdomains)))
    }
    _ ->
      Error(Unsupported(reason: "aws.isVirtualHostableS3Bucket expects 2 args"))
  }
}

fn is_virtual_hostable(name: String, allow_subdomains: Bool) -> Bool {
  case allow_subdomains {
    False -> is_valid_bucket_label(name)
    True ->
      name
      |> string.split(".")
      |> list.all(is_valid_bucket_label)
  }
}

fn is_valid_bucket_label(label: String) -> Bool {
  let length = string.length(label)
  let bytes = bit_array.byte_size(bit_array.from_string(label))
  case length == bytes && length >= 3 && length <= 63 {
    False -> False
    True ->
      case label {
        "" -> False
        _ ->
          !string.starts_with(label, "-")
          && !string.ends_with(label, "-")
          && all_bucket_chars(string.to_graphemes(label))
          && !looks_like_ip(label)
      }
  }
}

fn all_bucket_chars(chars: List(String)) -> Bool {
  list.all(chars, fn(c) {
    case c {
      "-" -> True
      _ -> is_lower_alnum(c)
    }
  })
}

fn is_lower_alnum(c: String) -> Bool {
  case c {
    "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9" -> True
    _ ->
      case string.to_utf_codepoints(c) {
        [cp] -> {
          let n = string.utf_codepoint_to_int(cp)
          n >= 97 && n <= 122
        }
        _ -> False
      }
  }
}

// ---------- evaluation helpers ----------

fn eval_to_int(expr: Expr, scope: Params) -> Result(Int, ResolveError) {
  case expr {
    IntLit(value: n) -> Ok(n)
    _ -> {
      use value <- result.try(eval(expr, scope))
      case value {
        StringVal(s) ->
          case int.parse(s) {
            Ok(n) -> Ok(n)
            Error(_) -> Error(Unsupported(reason: "non-integer string: " <> s))
          }
        _ -> Error(Unsupported(reason: "expected an integer"))
      }
    }
  }
}

fn eval_to_bool(expr: Expr, scope: Params) -> Result(Bool, ResolveError) {
  use value <- result.try(eval(expr, scope))
  case value {
    BoolVal(b) -> Ok(b)
    _ -> Error(Unsupported(reason: "expected a boolean"))
  }
}

/// Single-component percent-encoding matching `aws/internal/uri.encode_component`.
/// Inlined to avoid a cross-module dependency.
fn aws_uri_encode(input: String) -> String {
  do_uri_encode(bit_array.from_string(input), "")
}

fn do_uri_encode(bits: BitArray, acc: String) -> String {
  case bits {
    <<>> -> acc
    <<b, rest:bits>> ->
      case is_unreserved_byte(b) {
        True ->
          case bit_array.to_string(<<b>>) {
            Ok(s) -> do_uri_encode(rest, acc <> s)
            Error(_) -> do_uri_encode(rest, acc <> "%" <> hex_byte(b))
          }
        False -> do_uri_encode(rest, acc <> "%" <> hex_byte(b))
      }
    _ -> acc
  }
}

fn is_unreserved_byte(b: Int) -> Bool {
  { b >= 0x41 && b <= 0x5A }
  || { b >= 0x61 && b <= 0x7A }
  || { b >= 0x30 && b <= 0x39 }
  || b == 0x2D
  || b == 0x5F
  || b == 0x2E
  || b == 0x7E
}

fn hex_byte(b: Int) -> String {
  let high = b / 16
  let low = b % 16
  hex_digit(high) <> hex_digit(low)
}

fn hex_digit(n: Int) -> String {
  case n {
    0 -> "0"
    1 -> "1"
    2 -> "2"
    3 -> "3"
    4 -> "4"
    5 -> "5"
    6 -> "6"
    7 -> "7"
    8 -> "8"
    9 -> "9"
    10 -> "A"
    11 -> "B"
    12 -> "C"
    13 -> "D"
    14 -> "E"
    _ -> "F"
  }
}

/// Hardcoded partition data sourced from smithy-rs's `partitions.json`.
/// Refresh when AWS announces a new partition or DNS suffix.
fn partition_for(region: String) -> Dict(String, Value) {
  let trimmed = string.trim(region)
  case classify_partition(trimmed) {
    AwsCommercial ->
      dict.from_list([
        #("name", StringVal("aws")),
        #("dnsSuffix", StringVal("amazonaws.com")),
        #("dualStackDnsSuffix", StringVal("api.aws")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("us-east-1")),
      ])
    AwsCn ->
      dict.from_list([
        #("name", StringVal("aws-cn")),
        #("dnsSuffix", StringVal("amazonaws.com.cn")),
        #("dualStackDnsSuffix", StringVal("api.amazonwebservices.com.cn")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("cn-northwest-1")),
      ])
    AwsUsGov ->
      dict.from_list([
        #("name", StringVal("aws-us-gov")),
        #("dnsSuffix", StringVal("amazonaws.com")),
        #("dualStackDnsSuffix", StringVal("api.aws")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("us-gov-west-1")),
      ])
    AwsEusc ->
      dict.from_list([
        #("name", StringVal("aws-eusc")),
        #("dnsSuffix", StringVal("amazonaws.eu")),
        #("dualStackDnsSuffix", StringVal("api.amazonwebservices.eu")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("eusc-de-east-1")),
      ])
    AwsIso ->
      dict.from_list([
        #("name", StringVal("aws-iso")),
        #("dnsSuffix", StringVal("c2s.ic.gov")),
        #("dualStackDnsSuffix", StringVal("api.aws.ic.gov")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("us-iso-east-1")),
      ])
    AwsIsoB ->
      dict.from_list([
        #("name", StringVal("aws-iso-b")),
        #("dnsSuffix", StringVal("sc2s.sgov.gov")),
        #("dualStackDnsSuffix", StringVal("api.aws.scloud")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("us-isob-east-1")),
      ])
    AwsIsoE ->
      dict.from_list([
        #("name", StringVal("aws-iso-e")),
        #("dnsSuffix", StringVal("cloud.adc-e.uk")),
        #("dualStackDnsSuffix", StringVal("api.cloud-aws.adc-e.uk")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("eu-isoe-west-1")),
      ])
    AwsIsoF ->
      dict.from_list([
        #("name", StringVal("aws-iso-f")),
        #("dnsSuffix", StringVal("csp.hci.ic.gov")),
        #("dualStackDnsSuffix", StringVal("api.aws.hci.ic.gov")),
        #("supportsFIPS", BoolVal(True)),
        #("supportsDualStack", BoolVal(True)),
        #("implicitGlobalRegion", StringVal("us-isof-south-1")),
      ])
  }
}

type Partition {
  AwsCommercial
  AwsCn
  AwsUsGov
  AwsEusc
  AwsIso
  AwsIsoB
  AwsIsoE
  AwsIsoF
}

/// Classify a region into one of the AWS partitions. Mirrors the
/// `regionRegex` patterns from upstream `partitions.json`. Order matters:
/// the longest-prefix matchers (us-isob-, us-isof-) come first, then the
/// generic `us-iso-`.
fn classify_partition(region: String) -> Partition {
  case region {
    "aws-cn-global" -> AwsCn
    "aws-us-gov-global" -> AwsUsGov
    "aws-iso-global" -> AwsIso
    "aws-iso-b-global" -> AwsIsoB
    "aws-iso-e-global" -> AwsIsoE
    "aws-iso-f-global" -> AwsIsoF
    _ ->
      case
        string.starts_with(region, "cn-")
        || string.starts_with(region, "aws-cn-")
      {
        True -> AwsCn
        False ->
          case string.starts_with(region, "us-gov-") {
            True -> AwsUsGov
            False ->
              case string.starts_with(region, "eusc-") {
                True -> AwsEusc
                False ->
                  case string.starts_with(region, "us-isob-") {
                    True -> AwsIsoB
                    False ->
                      case string.starts_with(region, "us-isof-") {
                        True -> AwsIsoF
                        False ->
                          case string.starts_with(region, "us-iso-") {
                            True -> AwsIso
                            False ->
                              case string.starts_with(region, "eu-isoe-") {
                                True -> AwsIsoE
                                False -> AwsCommercial
                              }
                          }
                      }
                  }
              }
          }
      }
  }
}
