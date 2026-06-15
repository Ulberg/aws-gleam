#!/usr/bin/env bash
# Convert the vendored Smithy IDL protocol-test models into JSON AST
# files that the Gleam test runner can load directly.
#
# The Smithy IDL is a Java-parsed grammar; we don't reimplement it. Run
# this script when `vendor/smithy` is bumped to a new SHA, then commit
# the regenerated fixtures.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

SMITHY_VERSION="1.70.0"

# Pick the platform-specific Smithy CLI build.
case "$(uname -s)-$(uname -m)" in
  Darwin-arm64)  SMITHY_DIST="smithy-cli-darwin-aarch64" ;;
  Darwin-x86_64) SMITHY_DIST="smithy-cli-darwin-x86_64" ;;
  Linux-x86_64)  SMITHY_DIST="smithy-cli-linux-x86_64" ;;
  Linux-aarch64) SMITHY_DIST="smithy-cli-linux-aarch64" ;;
  *)
    echo "error: unsupported platform $(uname -s)-$(uname -m)" >&2
    echo "       extend the case in $0 with the matching Smithy CLI build." >&2
    exit 1
    ;;
esac

SMITHY_BIN="$ROOT/.tools/$SMITHY_DIST/bin/smithy"
SMITHY_BUILD="$ROOT/.tools/smithy-build.json"
MODEL_ROOT="$ROOT/vendor/smithy/smithy-aws-protocol-tests/model"
OUT_DIR="$ROOT/test/fixtures/protocol-tests"

if [ ! -x "$SMITHY_BIN" ]; then
  echo "→ downloading Smithy CLI $SMITHY_VERSION ($SMITHY_DIST)"
  mkdir -p "$ROOT/.tools"
  zip="$ROOT/.tools/$SMITHY_DIST.zip"
  curl -sSL -o "$zip" \
    "https://github.com/smithy-lang/smithy/releases/download/$SMITHY_VERSION/$SMITHY_DIST.zip"
  unzip -q "$zip" -d "$ROOT/.tools/"
  rm "$zip"
  test -x "$SMITHY_BIN"
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
