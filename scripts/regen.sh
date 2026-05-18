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

# Force a fresh codegen build before the per-service loop runs
# 409 sequential `gleam run -m aws_codegen` calls. CI restores a
# previously-cached `codegen/build` whose BEAM modules were
# compiled against an OLDER version of the codegen source —
# `gleam build` alone wasn't enough to bust through (the CI run
# at 5c34822 still showed the per-service loop completing in <2s
# with 408 silent no-ops), so we delete the build dir outright
# before recompiling. The 1.6s recompile is a small price for
# guaranteed-fresh BEAMs on every regen run.
echo "→ rebuilding codegen"
rm -rf build
gleam build >/dev/null

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
ERRLOG=$(mktemp)
trap 'rm -f $SERVICES_LIST $ERRLOG' EXIT

ITER=0
# `$CODEGEN` (gleam run -m aws_codegen) reads stdin during BEAM
# startup on some platforms (Ubuntu CI reproduces it; macOS local
# does not). When the loop body inherits stdin from `done < FILE`
# the command consumes the rest of the file, the loop exits after
# one iteration, and 408 service codegens never happen — yet the
# count guard reports "found 1" with no failures recorded. Fix:
# feed SERVICES_LIST via a dedicated file descriptor (FD 3) and
# explicitly redirect the loop body's stdin to `/dev/null` so the
# command can't reach the loop driver's input.
while read -r -u 3 name proto; do
  ITER=$((ITER + 1))
  out="../src/aws/services/${name//-/_}.gleam"
  PER_SERVICE_LOG=$(mktemp)
  $CODEGEN "$proto" "../vendor/aws-sdk-rust/aws-models/${name}.json" "$out" \
    </dev/null >"$PER_SERVICE_LOG" 2>&1
  rc=$?
  if [ "$rc" -ne 0 ] || [ ! -s "$out" ]; then
    FAILURES+=("$name ($proto)")
    {
      printf '%s (%s) rc=%s out=%s exists=%s size=%s\n' \
        "$name" "$proto" "$rc" "$out" \
        "$( [ -e "$out" ] && echo yes || echo no )" \
        "$( [ -e "$out" ] && wc -c <"$out" | tr -d ' ' || echo - )"
      cat "$PER_SERVICE_LOG"
      printf '\n'
    } >> "$ERRLOG"
    rm -f "$out"
  fi
  rm -f "$PER_SERVICE_LOG"
done 3< "$SERVICES_LIST"
echo "  loop iterated $ITER times"

if [ ${#FAILURES[@]} -gt 0 ]; then
  echo "  ${#FAILURES[@]} services failed codegen:"
  printf '    - %s\n' "${FAILURES[@]}"
  echo
  echo "  first 20 lines of the captured error log:"
  head -20 "$ERRLOG" | sed 's/^/    /'
  echo
  echo "  full log: $ERRLOG"
  exit 1
fi

# Belt-and-braces: count what landed on disk. The per-service
# `gleam run` calls historically exited 0 even when they did
# nothing useful (codegen errors printed to stdout, returned
# `Nil`, BEAM exited 0). The `aws_codegen.main` halt(1) fix and
# the `if !` guard above should catch every failure path now —
# but if some new path slips through, a sample count mismatch
# surfaces it here instead of as a downstream "Unknown module"
# at `gleam test` time minutes later.
WRITTEN=$(find ../src/aws/services -maxdepth 1 -name '*.gleam' | wc -l | tr -d ' ')
if [ "$WRITTEN" -lt "$TOTAL" ]; then
  echo
  echo "  service-count check: expected $TOTAL .gleam files, found $WRITTEN."
  echo "  the per-service loop reported 0 failures but the directory is short."
  echo "  one or more codegen calls exited 0 without writing — investigate"
  echo "  by running ./scripts/regen.sh interactively without stderr suppression."
  exit 1
fi

echo "→ regenerating protocol-test client modules + dispatchers"
$CODEGEN awsJson1_0 ../test/fixtures/protocol-tests/awsJson1_0.json ../src/aws/services/protocoltests/json10.gleam --dispatcher-out ../test/protocol_tests/awsjson10_dispatchers.gleam >/dev/null
$CODEGEN awsJson1_1 ../test/fixtures/protocol-tests/awsJson1_1.json ../src/aws/services/protocoltests/json11.gleam --dispatcher-out ../test/protocol_tests/awsjson11_dispatchers.gleam >/dev/null
$CODEGEN restJson1  ../test/fixtures/protocol-tests/restJson1.json  ../src/aws/services/protocoltests/restjson1.gleam --dispatcher-out ../test/protocol_tests/restjson1_dispatchers.gleam >/dev/null
$CODEGEN restXml    ../test/fixtures/protocol-tests/restXml.json    ../src/aws/services/protocoltests/restxml.gleam   --dispatcher-out ../test/protocol_tests/restxml_dispatchers.gleam >/dev/null
$CODEGEN awsQuery   ../test/fixtures/protocol-tests/awsQuery.json   ../src/aws/services/protocoltests/awsquery.gleam  --dispatcher-out ../test/protocol_tests/awsquery_dispatchers.gleam >/dev/null
$CODEGEN ec2Query   ../test/fixtures/protocol-tests/ec2Query.json   ../src/aws/services/protocoltests/ec2query.gleam  --dispatcher-out ../test/protocol_tests/ec2query_dispatchers.gleam >/dev/null
$CODEGEN rpcv2Cbor  ../test/fixtures/protocol-tests/rpcv2Cbor.json  ../src/aws/services/protocoltests/rpcv2cbor.gleam --dispatcher-out ../test/protocol_tests/rpcv2cbor_dispatchers.gleam >/dev/null

cd "$REPO"

# `gleam format` to match the project's check-formatting CI step.
# Format every generated service module, not just the previous two.
echo "→ formatting generated modules"
gleam format \
  src/aws/services \
  test/protocol_tests >/dev/null

echo "done."
