#!/bin/sh
# Build the Lambda deployment zip:
#   1. Resolve + download deps (including the path-dep SDK).
#   2. Run the SDK's codegen so all 409 services compile.
#   3. `gleam export erlang-shipment` builds a self-contained OTP
#      release under build/erlang-shipment/.
#   4. Slim the shipment: drop compile-time-only `.hrl` includes
#      and any `aws@services@*.beam` we don't actually use. The
#      `KEEP_SERVICES` env var (space-separated, defaults to `s3`)
#      controls which service modules survive — set to `s3 dynamodb`
#      (etc.) when adding scenarios that exercise more services.
#   5. Drop `bootstrap` at the release root and zip the lot.
#
# Output: build/aws-gleam-smoke.zip — under 50 MB so it fits Lambda's
# direct-upload limit. Pre-slim, the shipment is ~800 MB; the trim
# step brings it to ~2 MB (the BEAM bytecode for one S3 client +
# SDK runtime + stdlib is genuinely that small).

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

# Writer needs S3 (PutObject) + SQS (SendMessage); reader needs S3
# (GetObject). Both ship in the same zip, the slim step keeps both
# service beams.
KEEP_SERVICES="${KEEP_SERVICES:-s3 sqs}"

echo "→ resolving Gleam deps"
gleam deps download >/dev/null

echo "→ generating SDK services (one-shot via the path dep)"
( cd ../ && ./scripts/regen.sh )

echo "→ building OTP release"
rm -rf build/erlang-shipment
# Lift Erlang's default 1 MiB atom table — the codegen-emitted
# 409-service SDK allocates several million atoms during type-
# checking, the same as the SDK's own scripts/test.sh.
ERL_FLAGS="${ERL_FLAGS:-+t 4194304}" gleam export erlang-shipment >/dev/null

SHIPMENT="build/erlang-shipment"
cp bootstrap "$SHIPMENT/bootstrap"
chmod +x "$SHIPMENT/bootstrap"

echo "→ slimming shipment (keep services: $KEEP_SERVICES)"
# Compile-time-only Erlang record headers — ~500 MB of `.hrl`
# files Lambda never reads at runtime.
rm -rf "$SHIPMENT/aws/include"
# Build a `\|`-separated alternation of service BEAMs to keep
# (e.g. 's3\|dynamodb' → keep aws@services@s3.beam +
# aws@services@dynamodb.beam, delete the rest).
KEEP_ALT=$(echo "$KEEP_SERVICES" | tr ' ' '|')
find "$SHIPMENT/aws/ebin" -name 'aws@services@*.beam' \
  -not -regex ".*aws@services@\\($KEEP_ALT\\)\\.beam" \
  -delete

echo "→ zipping Lambda artifact"
ZIP="$HERE/build/aws-gleam-smoke.zip"
rm -f "$ZIP"
( cd "$SHIPMENT" && zip -qr "$ZIP" . )

echo "done → $ZIP"
ls -lh "$ZIP"
