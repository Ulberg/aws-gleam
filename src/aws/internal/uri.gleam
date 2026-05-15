//// Percent-encoding helpers shared by SigV4 canonical-URI/query encoding and
//// by HTTP-form encoding in the STS Web Identity provider. Kept in its own
//// module so SigV4 and the STS provider can both depend on it without
//// creating an import cycle through `aws/credentials`.

import gleam/bit_array

/// Percent-encode a single URI path segment. RFC 3986 unreserved characters
/// (`A-Za-z0-9-_.~`) pass through; everything else becomes `%HH`.
pub fn encode_segment(s: String) -> String {
  encode_bytes(bit_array.from_string(s), "")
}

/// Percent-encode a URI component, first decoding any pre-existing
/// percent-escapes so callers can pass values that may or may not already
/// be encoded.
pub fn encode_component(s: String) -> String {
  encode_bytes(percent_decode_bytes(bit_array.from_string(s)), "")
}

fn encode_bytes(bits: BitArray, acc: String) -> String {
  case bits {
    <<>> -> acc
    <<b, rest:bits>> ->
      case is_unreserved(b) {
        True -> encode_bytes(rest, acc <> byte_to_string(b))
        False -> encode_bytes(rest, acc <> "%" <> hex_byte(b))
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
    <<0x25, h, l, rest:bits>> ->
      case hex_value(h), hex_value(l) {
        Ok(hv), Ok(lv) -> {
          let byte = hv * 16 + lv
          do_percent_decode(rest, bit_array.append(acc, <<byte>>))
        }
        _, _ -> do_percent_decode(rest, bit_array.append(acc, <<0x25, h, l>>))
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
