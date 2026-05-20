# Smoke-test deploy — one command

The Lambda zip is already built and ready. Deploying requires a fresh
AWS session (your devtools/SSO session expired 2025-08-05), so first:

```sh
# Refresh AWS session (opens browser, you sign in)
/tmp/awscli-target/aws-cli/aws login
```

Then deploy:

```sh
cd smoke-test/infra
tofu init
tofu apply -auto-approve \
  -var "zip_path=$(realpath ../build/aws-gleam-smoke.zip)" \
  -var "bucket_name=aws-gleam-smoke-$(date +%s)" \
  -var "function_name=aws-gleam-smoke-$(date +%s)" \
  -var "region=eu-central-1"

# Invoke + read result
tofu output -raw function_name | xargs -I {} \
  /tmp/awscli-target/aws-cli/aws lambda invoke --function-name {} /tmp/smoke-output.json
cat /tmp/smoke-output.json
```

## Tooling state

| Tool | Path | Status |
|---|---|---|
| `tofu` | `/opt/homebrew/bin/tofu` | 1.12.0, installed this session |
| `aws` (v2) | `/tmp/awscli-target/aws-cli/aws` | 2.34.50, working — use this |
| `aws` (brew) | `/opt/homebrew/bin/aws` | Broken (python 3.14 / libexpat ABI mismatch — `Symbol not found: _XML_SetAllocTrackerActivationThreshold`). Don't use. |
| Lambda zip | `smoke-test/build/aws-gleam-smoke.zip` | 224 MB, built this session |

## Zip size

`./build.sh` produces a slim Lambda zip (~2 MB) by trimming the
shipment after `gleam export erlang-shipment`:

* Drops `aws/include/` — compile-time-only Erlang record headers
  (~500 MB of .hrl files Lambda never reads).
* Drops every `aws@services@<other>.beam` except the ones in
  `KEEP_SERVICES` (default: `s3`).

Adding scenarios that exercise more services? Build with
`KEEP_SERVICES="s3 dynamodb" ./build.sh`.

The 2 MB zip fits Lambda's 50 MB direct-upload limit — no S3
staging needed in the Tofu config.

## Teardown

```sh
cd smoke-test/infra
tofu destroy -auto-approve \
  -var "zip_path=$(realpath ../build/aws-gleam-smoke.zip)" \
  -var "bucket_name=<same as apply>" \
  -var "function_name=<same as apply>" \
  -var "region=eu-central-1"
```
