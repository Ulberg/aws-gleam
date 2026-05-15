//// End-to-end smoke test of the M1 + M2 stack against real S3.
////
//// Builds an unsigned GET request to
//// `https://<bucket>.s3.<region>.amazonaws.com/<key>`, signs it with SigV4
//// using credentials resolved through the default chain, sends it through
//// `gleam_httpc`, and prints the response.
////
//// ## How to run
////
////   1. Edit the three `const` lines below — bucket, key, region.
////   2. Make sure credentials are reachable by the default chain. For most
////      local setups that means:
////         - You have `aws_access_key_id` / `aws_secret_access_key` in
////           `~/.aws/credentials`, OR
////         - You've run `aws sso login` and the `~/.aws/sso/cache/*.json`
////           token is still valid for the configured profile, OR
////         - You have `AWS_ACCESS_KEY_ID` and friends in your shell.
////   3. From the repo root:
////         gleam run -m aws/examples/s3_get
////
//// ## What this proves
////
//// If you see a "HTTP 200" and a body preview, the credential chain →
//// SigV4 signer → HTTP transport pipeline works end-to-end against real
//// AWS. A 403 with a `<Code>...</Code>` body means credentials reached S3
//// and S3 rejected them (clock skew, missing permission, wrong region…) —
//// also a useful signal: the auth path is correct, the rest is policy.
////
//// ## What this does NOT prove
////
//// Anything that lives in M3+ — region resolution from `~/.aws/config`,
//// endpoint construction from Smithy rules, typed responses, retries,
//// the typed `s3.get_object(...)` API. Those are coming.

import aws/credentials
import aws/internal/http_request as our_http
import aws/internal/http_send
import aws/internal/sigv4
import gleam/bit_array
import gleam/http
import gleam/http/request
import gleam/int
import gleam/io
import gleam/list
import gleam/string

// === EDIT THESE THREE LINES ===
const bucket: String = "demo-bucket-388180356984-eu-north-1-an"

// Empty key requests `/` — i.e. a bucket listing (ListObjectsV2 returns XML).
// Set this to a specific object name like "hello.txt" to fetch one object.
const object_key: String = ""

const region: String = "eu-north-1"
// ===============================

const profile: String = "default"

pub fn main() {
  // 1. Resolve credentials through the chain. Two deliberate departures
  //    from `credentials.default_chain` here:
  //
  //      - IMDS is omitted. Its connect to 169.254.169.254 hangs for the
  //        full TCP retransmit window on a non-EC2 host. The SDK proper
  //        will set per-provider HTTP timeouts (M3 work); for now we just
  //        leave IMDS off the local smoke test.
  //      - The cache actor (`credentials_cache.start_default`) is skipped.
  //        For a one-shot a direct `fetch` is simpler and avoids the
  //        actor.call timeout that surfaced the IMDS hang previously.
  let send = http_send.default_send
  let provider =
    credentials.chain([
      credentials.from_environment(),
      credentials.from_web_identity(send: send),
      credentials.from_sso(send: send, profile: profile),
      credentials.from_profile(name: profile),
      credentials.from_process(profile: profile),
      credentials.from_ecs(send: send),
    ])

  case credentials.fetch(provider) {
    Error(err) -> {
      io.println("Could not resolve credentials.")
      io.println(describe_error(err))
    }
    Ok(creds) -> {
      io.println("Resolved credentials from: " <> creds.source)
      do_get_object(creds)
    }
  }
}

fn do_get_object(creds: credentials.Credentials) -> Nil {
  let host = bucket <> ".s3." <> region <> ".amazonaws.com"
  let path = "/" <> object_key
  let encoded_path = sigv4.encode_path(path)
  let url = "https://" <> host <> encoded_path

  // 2. Build a SigV4-ready request: our internal HttpRequest is what the
  //    signer eats. The host header is mandatory in the canonical request.
  let unsigned =
    our_http.HttpRequest(
      method: "GET",
      path: path,
      query: "",
      headers: [our_http.Header(name: "host", value: host)],
      body: bit_array.from_string(""),
    )
  let opts =
    sigv4.SigningOptions(
      timestamp: aws_timestamp(),
      region: region,
      service: "s3",
      // S3 keys can contain literal `.` and `..` — don't collapse them.
      normalize_path: False,
      // S3 requires X-Amz-Content-Sha256; sign_body: True adds it.
      sign_body: True,
      omit_session_token: False,
    )
  let signed = sigv4.sign(unsigned, creds, opts)

  // 3. Bridge our HttpRequest (sigv4 shape) to gleam_http's Request
  //    (gleam_httpc shape) by copying every header the signer produced.
  let assert Ok(base) = request.to(url)
  let http_req =
    base
    |> request.set_method(http.Get)
    |> request.set_body(bit_array.from_string(""))
  let http_req =
    list.fold(signed.headers, http_req, fn(r, h) {
      request.set_header(r, h.name, h.value)
    })

  // 4. Send and report.
  case http_send.default_send(http_req) {
    Error(e) -> {
      io.println("Transport error: " <> describe_http_error(e))
    }
    Ok(resp) -> {
      io.println("HTTP " <> int.to_string(resp.status))
      print_body_preview(resp.body)
    }
  }
}

fn print_body_preview(body: BitArray) -> Nil {
  case bit_array.to_string(body) {
    Ok(text) -> {
      let len = string.length(text)
      let preview = case len > 400 {
        True -> string.slice(text, 0, 400) <> "..."
        False -> text
      }
      io.println("Body (" <> int.to_string(len) <> " chars):")
      io.println(preview)
    }
    Error(_) -> {
      let bytes = bit_array.byte_size(body)
      io.println("Body: " <> int.to_string(bytes) <> " binary bytes")
    }
  }
}

fn describe_error(err: credentials.ProviderError) -> String {
  case err {
    credentials.NotConfigured(reason: r) -> "NotConfigured: " <> r
    credentials.FetchFailed(reason: r) -> "FetchFailed: " <> r
    credentials.ChainExhausted(attempts: attempts) -> {
      let lines =
        list.map(attempts, fn(pair) {
          "  - " <> pair.0 <> ": " <> describe_error(pair.1)
        })
      "ChainExhausted:\n" <> string.join(lines, "\n")
    }
  }
}

fn describe_http_error(err: http_send.HttpError) -> String {
  case err {
    http_send.ConnectFailed(reason: r) -> "connect failed: " <> r
    http_send.Timeout -> "timeout"
    http_send.InvalidBody(reason: r) -> "invalid body: " <> r
    http_send.Other(reason: r) -> r
  }
}

@external(erlang, "aws_ffi", "aws_timestamp")
fn aws_timestamp() -> String
