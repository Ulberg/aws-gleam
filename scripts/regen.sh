#!/usr/bin/env bash
# Regenerate every codegen artefact this repo intentionally keeps
# OUT of git. Run before `gleam test` after a fresh clone or when
# the codegen / fixtures change.
#
# Outputs:
#   src/aws/services/<service>.gleam      — typed Gleam SDK per service
#   src/aws/services/protocoltests/*      — generated protocol-test fixtures
#   test/protocol_tests/*_dispatchers.gleam — generated test harness glue
#
# Auto-discovers every awsJson1_0 / awsJson1_1 / restJson1 / restXml
# service shape in vendor/aws-sdk-rust/aws-models and runs the codegen
# against each. awsQuery / ec2Query / rpcv2Cbor are skipped here:
# their bodies aren't fully supported yet (see docs/audits/m5.md).
#
# All outputs regenerate deterministically from sources that ARE in
# git (`vendor/aws-sdk-rust/aws-models/*.json` and
# `test/fixtures/protocol-tests/*.json`), so we don't ship the
# 100k+ LOC of derived code through the repo.

set -euo pipefail

cd "$(dirname "$0")/.."
REPO=$(pwd)

CODEGEN="gleam run -m aws_codegen --"

echo "→ building protocol-test JSON ASTs"
"$REPO/scripts/build-protocol-test-asts.sh"

echo "→ extracting endpoint fixtures from vendor models"
"$REPO/scripts/extract-endpoints.sh"

cd "$REPO/codegen"

mkdir -p ../src/aws/services/protocoltests ../test/protocol_tests

# Map each model to its protocol. Outputs lines of `<name> <protocol>`.
# Skips models whose service shape has none of the mainline protocols
# we support — awsQuery / ec2Query / rpcv2Cbor are excluded until
# their body codecs land.
echo "→ enumerating service models"
SERVICES_LIST=$(mktemp)
trap 'rm -f $SERVICES_LIST' EXIT

for f in "$REPO"/vendor/aws-sdk-rust/aws-models/*.json; do
  name=$(basename "$f" .json)
  # Skip the generic sdk-* helpers (sdk-endpoints.json, sdk-default-configuration.json).
  case "$name" in
    sdk-*) continue ;;
  esac
  # `|| true` because grep exits 1 when there's no match — that's
  # expected for awsQuery / ec2Query / rpcv2Cbor models we're
  # skipping. Without it, `set -e` would terminate the script.
  proto=$({ grep -m1 -oE '"aws.protocols#(awsJson1_0|awsJson1_1|restJson1|restXml)"' "$f" || true; } | sed -E 's/^"aws.protocols#//;s/".*$//')
  if [ -n "$proto" ]; then
    echo "$name $proto" >> "$SERVICES_LIST"
  fi
done

TOTAL=$(wc -l < "$SERVICES_LIST" | tr -d ' ')
echo "  $TOTAL services to generate"

echo "→ regenerating service clients"
FAILURES=()
while read -r name proto; do
  out="../src/aws/services/${name//-/_}.gleam"
  if ! $CODEGEN "$proto" "../vendor/aws-sdk-rust/aws-models/${name}.json" "$out" >/dev/null 2>&1; then
    FAILURES+=("$name ($proto)")
    rm -f "$out"
  fi
done < "$SERVICES_LIST"

if [ ${#FAILURES[@]} -gt 0 ]; then
  echo "  ${#FAILURES[@]} services failed codegen:"
  printf '    - %s\n' "${FAILURES[@]}"
fi

echo "→ regenerating protocol-test client modules + dispatchers"
$CODEGEN awsJson1_0 ../test/fixtures/protocol-tests/awsJson1_0.json ../src/aws/services/protocoltests/json10.gleam --dispatcher-out ../test/protocol_tests/awsjson10_dispatchers.gleam >/dev/null
$CODEGEN awsJson1_1 ../test/fixtures/protocol-tests/awsJson1_1.json ../src/aws/services/protocoltests/json11.gleam --dispatcher-out ../test/protocol_tests/awsjson11_dispatchers.gleam >/dev/null
$CODEGEN restJson1  ../test/fixtures/protocol-tests/restJson1.json  ../src/aws/services/protocoltests/restjson1.gleam --dispatcher-out ../test/protocol_tests/restjson1_dispatchers.gleam >/dev/null
$CODEGEN restXml    ../test/fixtures/protocol-tests/restXml.json    ../src/aws/services/protocoltests/restxml.gleam   --dispatcher-out ../test/protocol_tests/restxml_dispatchers.gleam >/dev/null
$CODEGEN awsQuery   ../test/fixtures/protocol-tests/awsQuery.json   ../src/aws/services/protocoltests/awsquery.gleam  --dispatcher-out ../test/protocol_tests/awsquery_dispatchers.gleam >/dev/null
$CODEGEN ec2Query   ../test/fixtures/protocol-tests/ec2Query.json   ../src/aws/services/protocoltests/ec2query.gleam  --dispatcher-out ../test/protocol_tests/ec2query_dispatchers.gleam >/dev/null

cd "$REPO"

# `gleam format` to match the project's check-formatting CI step.
# Format every generated service module, not just the previous two.
echo "→ formatting generated modules"
gleam format \
  src/aws/services \
  test/protocol_tests >/dev/null

echo "done."
