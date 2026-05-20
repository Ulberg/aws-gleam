# Deploying Gleam to AWS Lambda

Reference for callers who want to run Gleam code on AWS Lambda
specifically (as opposed to Fargate, which is what
[`smoke-test/`](../smoke-test/) uses for the SDK's end-to-end test —
see the [Why not Lambda for this SDK](#why-not-lambda-for-this-sdk)
note below).

Three working approaches exist; pick the one that matches your
Gleam project's target.

## Approach 1 — JavaScript target via glambda *(simplest, no FFI)*

If your Gleam project targets JavaScript (`target = "javascript"`
in `gleam.toml`) and **doesn't** import any Erlang-only modules,
the cleanest path is [`ryanmiville/glambda`][glambda]. It compiles
to JS, runs on the official Node.js Lambda runtime, and avoids
every "how do I get Erlang into Lambda" problem entirely.

```gleam
import glambda

pub fn handler(event, ctx) {
  glambda.http_handler(handle_request)(event, ctx)
}

fn handle_request(req) {
  // ... plain Gleam code, returns a typed response ...
}
```

Deploy with whatever JS-friendly tooling you already use — SST,
SAM with a Node.js runtime, Serverless Framework, plain Terraform
with `runtime = "nodejs20.x"`. Cold-start is fast (~100-300 ms),
the deploy is a `.zip` of compiled JS, no Docker or layers needed.

**Constraint:** **does not work for the aws-gleam SDK in this
repo.** Our SDK is Erlang-target (`target = "erlang"`) and depends
on Erlang FFI for `crypto`, `httpc`, `aws_ffi`, `aws_streaming_ffi`,
the credentials-cache OTP actor, etc. Porting it to JS would mean
replacing every FFI with a JS equivalent — different SDK, not a
deploy choice.

## Approach 2 — Container image with Erlang bundled

Lambda's `provided.al2023` runtime ships **no** language runtime
— just AL2023 + the runtime interface. So `gleam export
erlang-shipment` + zip-upload fails at cold start with
`exec: erl: not found` (we hit this exact error during the
smoke-test work — see git history).

The fix is a container image that bundles Erlang/OTP. Lambda
accepts any container image whose entrypoint polls the Runtime
API; you build the image, push it to ECR, point a `package_type =
"Image"` Lambda at it.

The key gotcha — compile and run on the **same** OTP version, or
the BEAM rejects modules with `undef`. The easiest way is to use
the official Gleam image, which ships Gleam + a matching
Erlang/OTP:

```dockerfile
FROM ghcr.io/gleam-lang/gleam:v1.16.0-erlang-alpine

COPY . /build/
WORKDIR /build
RUN gleam deps download \
    && gleam export erlang-shipment \
    && mv build/erlang-shipment /app

WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
```

Plus a tiny Gleam module that polls the Lambda Runtime API:

```gleam
//// src/lambda_runtime.gleam — simplified
import gleam/http.{Get, Post}
import gleam/http/request
import gleam/http/response
import gleam/httpc

pub fn run_loop(handle: fn(BitArray) -> Result(BitArray, String)) -> Nil {
  let endpoint = case os_getenv("AWS_LAMBDA_RUNTIME_API") {
    Ok(v) -> v
    Error(_) -> panic
  }
  loop(endpoint, handle)
}

fn loop(endpoint, handle) {
  let assert Ok(req) = request.to(
    "http://" <> endpoint <> "/2018-06-01/runtime/invocation/next",
  )
  let assert Ok(resp) = httpc.send_bits(request.set_method(req, Get))
  let request_id = header(resp, "lambda-runtime-aws-request-id")
  case handle(resp.body) {
    Ok(out) -> post(endpoint, request_id, "/response", out)
    Error(msg) -> post(endpoint, request_id, "/error", error_json(msg))
  }
  loop(endpoint, handle)
}

@external(erlang, "os", "getenv")
fn os_getenv(name: String) -> Result(String, Nil)
```

(Full implementation: see this repo's
[`smoke-test/src/runtime_api.gleam`](../smoke-test/src/runtime_api.gleam)
on the `feat/smoke-test` branch — it's the working version from
when we still targeted Lambda.)

Terraform deploy shape:

```hcl
resource "aws_ecr_repository" "fn" { name = "my-gleam-fn" }
data "aws_ecr_image" "fn" {
  repository_name = aws_ecr_repository.fn.name
  image_tag       = "latest"
}

resource "aws_lambda_function" "fn" {
  function_name = "my-gleam-fn"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.fn.repository_url}@${data.aws_ecr_image.fn.image_digest}"
  role          = aws_iam_role.fn.arn
  memory_size   = 512
  timeout       = 30
}
```

Two-phase apply: `tofu apply -target=aws_ecr_repository.fn` first,
then `docker buildx + push`, then full `tofu apply`. Pinning to
the image digest (not the tag) means each push triggers a Lambda
update unambiguously.

**Cost:** image build is ~5-10 min (BEAM compile + 409-service
codegen if you use this SDK), cold start is ~1-2 s (BEAM startup
+ atom-table loading).

## Approach 3 — Erlang/OTP as a Lambda Layer

[`fogfish/serverless`][fogfish] publishes Erlang/OTP as a Lambda
Layer, attaches the layer to a function whose `runtime =
"provided.al2023"`, and uses an `escript`-based handler. Smaller
deploy zip (no Erlang in your code package — the layer carries
it), but the layer is OTP-version-pinned and you don't control
upgrades.

For a Gleam project this means:
1. `gleam export erlang-shipment` locally (against the OTP version
   the layer ships).
2. Repackage the shipment into an escript or zip that the layer's
   bootstrap can execute.
3. `make layer` (per the project README) to publish the runtime
   layer to your AWS account.
4. Deploy your function pointing at the layer ARN + your code zip.

This works if you want the smallest possible deploy artefact and
are happy pinning to whatever OTP version the layer's maintainer
ships. The container-image approach (Approach 2) trades artefact
size for full version control.

## Why not Lambda for this SDK

The smoke-test in this repo started on Lambda and we migrated it
to Fargate after hitting these issues in sequence:

1. **No Erlang in `provided.al2023`.** Zip deploy fails with
   `exec: erl: not found`. Forced container image.
2. **OTP version mismatch host-vs-image.** BEAM bytecode rejects
   modules with `undef`. Forced same-image compile.
3. **Cold-start tax.** BEAM startup + the SDK's 409-service
   atom-table loading takes ~1-2 s. Amortized across one request
   on Lambda; meaningless on Fargate.
4. **State-amortization loss.** The SDK's `credentials_cache`
   actor + retry `rate_limiter` + per-Client endpoint rule-set
   evaluator are designed to live across many requests in one
   process. Lambda discards them on every cold start.
5. **Runtime API ceremony.** `runtime_api.gleam` (~200 LOC) only
   exists to satisfy Lambda's invoke contract. Fargate runs the
   BEAM directly; you delete the whole file.

Lambda still makes sense for **very short-lived, very high-RPS,
event-driven** workloads — and for those, Approach 1 (JS target +
glambda) is the right call because JS startup is ~10× faster than
BEAM. For BEAM-target Gleam in particular, Fargate is the more
natural fit: see [`smoke-test/`](../smoke-test/) for the working
reference.

[glambda]: https://github.com/ryanmiville/glambda
[fogfish]: https://github.com/fogfish/serverless
