import aws/internal/crypto
import aws/internal/http_request.{
  type Header, type HttpRequest, Header, HttpRequest,
}
import gleam/bit_array
import gleam/list
import gleam/option.{type Option, Some}
import gleam/order
import gleam/string

pub type Credentials {
  Credentials(
    access_key_id: String,
    secret_access_key: String,
    session_token: Option(String),
  )
}

pub type SigningOptions {
  SigningOptions(
    timestamp: String,
    region: String,
    service: String,
    normalize_path: Bool,
    sign_body: Bool,
    omit_session_token: Bool,
  )
}

pub type CanonicalParts {
  CanonicalParts(
    canonical_request: String,
    signed_headers: String,
    payload_hash: String,
    prepared_headers: List(Header),
  )
}

pub fn canonical_request(
  req: HttpRequest,
  creds: Credentials,
  opts: SigningOptions,
) -> CanonicalParts {
  let payload_hash = case opts.sign_body {
    True -> crypto.hex_encode(crypto.sha256(req.body))
    False -> crypto.hex_encode(crypto.sha256(bit_array.from_string("")))
  }

  let prepared = prepare_headers(req, creds, opts, payload_hash)
  let signing_headers = headers_for_signing(prepared, creds, opts)
  let canonical_headers_block = canonical_headers(signing_headers)
  let signed_headers_list = signed_headers(signing_headers)
  let canonical_uri = case opts.normalize_path {
    True -> encode_path(normalize_path(req.path))
    False -> encode_path(req.path)
  }
  let canonical_query = canonical_query_string(req.query)

  let creq =
    req.method
    <> "\n"
    <> canonical_uri
    <> "\n"
    <> canonical_query
    <> "\n"
    <> canonical_headers_block
    <> "\n"
    <> signed_headers_list
    <> "\n"
    <> payload_hash

  CanonicalParts(
    canonical_request: creq,
    signed_headers: signed_headers_list,
    payload_hash: payload_hash,
    prepared_headers: prepared,
  )
}

pub fn string_to_sign(
  canonical: String,
  timestamp: String,
  region: String,
  service: String,
) -> String {
  let date = string.slice(timestamp, 0, 8)
  let scope = date <> "/" <> region <> "/" <> service <> "/aws4_request"
  let hash = crypto.hex_encode(crypto.sha256(bit_array.from_string(canonical)))
  "AWS4-HMAC-SHA256\n" <> timestamp <> "\n" <> scope <> "\n" <> hash
}

pub fn signing_key(
  secret: String,
  date: String,
  region: String,
  service: String,
) -> BitArray {
  let k_secret = bit_array.from_string("AWS4" <> secret)
  let k_date = crypto.hmac_sha256(k_secret, bit_array.from_string(date))
  let k_region = crypto.hmac_sha256(k_date, bit_array.from_string(region))
  let k_service = crypto.hmac_sha256(k_region, bit_array.from_string(service))
  crypto.hmac_sha256(k_service, bit_array.from_string("aws4_request"))
}

pub fn signature(key: BitArray, sts: String) -> String {
  crypto.hex_encode(crypto.hmac_sha256(key, bit_array.from_string(sts)))
}

pub fn authorization_header(
  creds: Credentials,
  timestamp: String,
  region: String,
  service: String,
  signed_headers: String,
  signature: String,
) -> String {
  let date = string.slice(timestamp, 0, 8)
  "AWS4-HMAC-SHA256 Credential="
  <> creds.access_key_id
  <> "/"
  <> date
  <> "/"
  <> region
  <> "/"
  <> service
  <> "/aws4_request, SignedHeaders="
  <> signed_headers
  <> ", Signature="
  <> signature
}

pub fn sign(
  req: HttpRequest,
  creds: Credentials,
  opts: SigningOptions,
) -> HttpRequest {
  let parts = canonical_request(req, creds, opts)
  let sts =
    string_to_sign(
      parts.canonical_request,
      opts.timestamp,
      opts.region,
      opts.service,
    )
  let date = string.slice(opts.timestamp, 0, 8)
  let key = signing_key(creds.secret_access_key, date, opts.region, opts.service)
  let sig = signature(key, sts)
  let auth =
    authorization_header(
      creds,
      opts.timestamp,
      opts.region,
      opts.service,
      parts.signed_headers,
      sig,
    )
  let with_session = case creds.session_token, opts.omit_session_token {
    Some(token), True ->
      list.append(parts.prepared_headers, [
        Header(name: "X-Amz-Security-Token", value: token),
      ])
    _, _ -> parts.prepared_headers
  }
  let final_headers =
    list.append(with_session, [Header(name: "Authorization", value: auth)])
  HttpRequest(..req, headers: final_headers)
}

fn prepare_headers(
  req: HttpRequest,
  creds: Credentials,
  opts: SigningOptions,
  payload_hash: String,
) -> List(Header) {
  let with_date =
    upsert_header(req.headers, "X-Amz-Date", opts.timestamp, replace: True)
  let with_body = case opts.sign_body {
    True ->
      upsert_header(
        with_date,
        "X-Amz-Content-Sha256",
        payload_hash,
        replace: True,
      )
    False -> with_date
  }
  case creds.session_token, opts.omit_session_token {
    Some(token), False ->
      upsert_header(
        with_body,
        "X-Amz-Security-Token",
        token,
        replace: True,
      )
    _, _ -> with_body
  }
}

fn headers_for_signing(
  prepared: List(Header),
  creds: Credentials,
  opts: SigningOptions,
) -> List(Header) {
  case creds.session_token, opts.omit_session_token {
    Some(_), True ->
      list.filter(prepared, fn(h) {
        string.lowercase(h.name) != "x-amz-security-token"
      })
    _, _ -> prepared
  }
}

fn upsert_header(
  headers: List(Header),
  name: String,
  value: String,
  replace replace: Bool,
) -> List(Header) {
  let lower = string.lowercase(name)
  let already_present =
    list.any(headers, fn(h) { string.lowercase(h.name) == lower })
  case already_present, replace {
    True, True ->
      list.map(headers, fn(h) {
        case string.lowercase(h.name) == lower {
          True -> Header(name: h.name, value: value)
          False -> h
        }
      })
    True, False -> headers
    False, _ -> list.append(headers, [Header(name: name, value: value)])
  }
}

fn canonical_headers(headers: List(Header)) -> String {
  let prepared =
    headers
    |> list.map(fn(h) {
      #(string.lowercase(h.name), collapse_spaces(string.trim(h.value)))
    })
    |> group_by_name
    |> list.sort(by: fn(a, b) { string.compare(a.0, b.0) })

  prepared
  |> list.map(fn(p) { p.0 <> ":" <> string.join(p.1, ",") <> "\n" })
  |> string.concat
}

fn signed_headers(headers: List(Header)) -> String {
  headers
  |> list.map(fn(h) { string.lowercase(h.name) })
  |> list.unique
  |> list.sort(by: string.compare)
  |> string.join(";")
}

fn group_by_name(
  pairs: List(#(String, String)),
) -> List(#(String, List(String))) {
  do_group_by_name(pairs, [])
}

fn do_group_by_name(
  pairs: List(#(String, String)),
  acc: List(#(String, List(String))),
) -> List(#(String, List(String))) {
  case pairs {
    [] -> list.reverse(list.map(acc, fn(p) { #(p.0, list.reverse(p.1)) }))
    [#(name, value), ..rest] -> {
      let updated = case list.key_find(acc, name) {
        Ok(existing) -> {
          let new_values = [value, ..existing]
          list.key_set(acc, name, new_values)
        }
        Error(_) -> [#(name, [value]), ..acc]
      }
      do_group_by_name(rest, updated)
    }
  }
}

fn collapse_spaces(s: String) -> String {
  do_collapse(string.to_graphemes(s), False, "")
}

fn do_collapse(chars: List(String), last_was_space: Bool, acc: String) -> String {
  case chars {
    [] -> acc
    [c, ..rest] ->
      case c == " " || c == "\t" {
        True ->
          case last_was_space {
            True -> do_collapse(rest, True, acc)
            False -> do_collapse(rest, True, acc <> " ")
          }
        False -> do_collapse(rest, False, acc <> c)
      }
  }
}

fn normalize_path(path: String) -> String {
  let trailing_slash = case string.ends_with(path, "/") && path != "/" {
    True -> True
    False -> False
  }
  let segments = case string.starts_with(path, "/") {
    True -> string.split(path, "/") |> drop_first
    False -> string.split(path, "/")
  }
  let processed = process_segments(segments, [])
  case processed, trailing_slash {
    [], _ -> "/"
    parts, True -> "/" <> string.join(parts, "/") <> "/"
    parts, False -> "/" <> string.join(parts, "/")
  }
}

fn drop_first(xs: List(a)) -> List(a) {
  case xs {
    [] -> []
    [_, ..rest] -> rest
  }
}

fn process_segments(segments: List(String), stack: List(String)) -> List(String) {
  case segments {
    [] -> list.reverse(stack)
    ["", ..rest] -> process_segments(rest, stack)
    [".", ..rest] -> process_segments(rest, stack)
    ["..", ..rest] ->
      case stack {
        [_, ..tail] -> process_segments(rest, tail)
        [] -> process_segments(rest, stack)
      }
    [seg, ..rest] -> process_segments(rest, [seg, ..stack])
  }
}

pub fn encode_path(path: String) -> String {
  string.split(path, "/")
  |> list.map(percent_encode_segment)
  |> string.join("/")
}

fn percent_encode_segment(s: String) -> String {
  encode_bytes(bit_array.from_string(s), False, "")
}

pub fn percent_encode_component(s: String) -> String {
  encode_bytes(percent_decode_bytes(bit_array.from_string(s)), False, "")
}

fn encode_bytes(bits: BitArray, _unused: Bool, acc: String) -> String {
  case bits {
    <<>> -> acc
    <<b, rest:bits>> ->
      case is_unreserved(b) {
        True -> encode_bytes(rest, False, acc <> byte_to_string(b))
        False -> encode_bytes(rest, False, acc <> "%" <> hex_byte(b))
      }
    _ -> acc
  }
}

fn is_unreserved(b: Int) -> Bool {
  { b >= 0x41 && b <= 0x5A }
  || { b >= 0x61 && b <= 0x7A }
  || { b >= 0x30 && b <= 0x39 }
  || b == 0x2D
  || b == 0x5F
  || b == 0x2E
  || b == 0x7E
}

fn byte_to_string(b: Int) -> String {
  let bits = <<b>>
  case bit_array.to_string(bits) {
    Ok(s) -> s
    Error(_) -> ""
  }
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

fn percent_decode_bytes(bits: BitArray) -> BitArray {
  do_percent_decode(bits, <<>>)
}

fn do_percent_decode(bits: BitArray, acc: BitArray) -> BitArray {
  case bits {
    <<>> -> acc
    <<0x25, h, l, rest:bits>> -> {
      case hex_value(h), hex_value(l) {
        Ok(hv), Ok(lv) -> {
          let byte = hv * 16 + lv
          do_percent_decode(rest, bit_array.append(acc, <<byte>>))
        }
        _, _ ->
          do_percent_decode(rest, bit_array.append(acc, <<0x25, h, l>>))
      }
    }
    <<b, rest:bits>> -> do_percent_decode(rest, bit_array.append(acc, <<b>>))
    _ -> acc
  }
}

fn hex_value(b: Int) -> Result(Int, Nil) {
  case b {
    _ if b >= 0x30 && b <= 0x39 -> Ok(b - 0x30)
    _ if b >= 0x41 && b <= 0x46 -> Ok(b - 0x41 + 10)
    _ if b >= 0x61 && b <= 0x66 -> Ok(b - 0x61 + 10)
    _ -> Error(Nil)
  }
}

fn canonical_query_string(query: String) -> String {
  case query {
    "" -> ""
    _ -> {
      string.split(query, "&")
      |> list.map(parse_query_pair)
      |> list.sort(by: query_pair_compare)
      |> list.map(fn(p) { p.0 <> "=" <> p.1 })
      |> string.join("&")
    }
  }
}

fn parse_query_pair(pair: String) -> #(String, String) {
  case string.split_once(pair, "=") {
    Ok(#(name, value)) -> #(
      percent_encode_component(name),
      percent_encode_component(value),
    )
    Error(_) -> #(percent_encode_component(pair), "")
  }
}

fn query_pair_compare(
  a: #(String, String),
  b: #(String, String),
) -> order.Order {
  case string.compare(a.0, b.0) {
    order.Eq -> string.compare(a.1, b.1)
    other -> other
  }
}

