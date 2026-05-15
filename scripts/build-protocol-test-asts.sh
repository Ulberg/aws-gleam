#!/usr/bin/env bash
# Convert the vendored Smithy IDL protocol-test models into JSON AST
# files that the Gleam test runner can load directly.
#
# The Smithy IDL is a Java-parsed grammar; we don't reimplement it. Run
# this script when `vendor/smithy` is bumped to a new SHA, then commit
# the regenerated fixtures.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SMITHY_BIN="$ROOT/.tools/smithy-cli-darwin-aarch64/bin/smithy"
SMITHY_BUILD="$ROOT/.tools/smithy-build.json"
MODEL_ROOT="$ROOT/vendor/smithy/smithy-aws-protocol-tests/model"
OUT_DIR="$ROOT/test/fixtures/protocol-tests"

if [ ! -x "$SMITHY_BIN" ]; then
  echo "error: smithy CLI not found at $SMITHY_BIN" >&2
  echo "       download from https://github.com/smithy-lang/smithy/releases" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

# Each protocol's test files reference shared types in model/*.smithy. Pass
# the shared-types file alongside the protocol-specific subdir so cross-
# file references resolve.
SHARED=(
  "$MODEL_ROOT/shared-types.smithy"
  "$MODEL_ROOT/aws-config.smithy"
)

build_protocol() {
  local name="$1"
  local subdir="$2"
  echo "→ building $name from $subdir"
  cd "$ROOT/.tools"
  "$SMITHY_BIN" ast \
    --aut \
    --flatten \
    "${SHARED[@]}" \
    "$MODEL_ROOT/$subdir" \
    > "$OUT_DIR/$name.json"
  printf "  %s.json: %s bytes\n" \
    "$name" "$(wc -c < "$OUT_DIR/$name.json")"
}

build_protocol awsJson1_0 awsJson1_0
build_protocol awsJson1_1 awsJson1_1
build_protocol restJson1 restJson1
build_protocol restXml restXml
build_protocol restXmlWithNamespace restXmlWithNamespace
build_protocol awsQuery awsQuery
build_protocol ec2Query ec2Query
build_protocol rpcv2Cbor rpcv2Cbor

echo "done. fixtures in $OUT_DIR/"
