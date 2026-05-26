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
# their bodies aren't fully supported yet.
#
# All outputs regenerate deterministically from sources that ARE in
# git (`vendor/aws-sdk-rust/aws-models/*.json` and
# `test/fixtures/protocol-tests/*.json`), so we don't ship the
# 100k+ LOC of derived code through the repo.
#
# Usage:
#   ./scripts/regen.sh                  # regen everything (full run, ~minute+)
#   ./scripts/regen.sh s3 polly         # regen ONLY listed services
#   ./scripts/regen.sh transcribe-streaming
#
# Service names are the model basename (e.g. `s3`, `polly`,
# `transcribe-streaming`) — anything matching
# `vendor/aws-sdk-rust/aws-models/<name>.json`. Use dashes, NOT
# underscores (`transcribe-streaming`, not `transcribe_streaming`)
# — the model filename has dashes and the script maps them to
# underscores in the output path.
#
# Focused mode (positional args supplied) skips the protocol-test
# fixture regen + the global service-count guard; both presume a
# full run. Use the no-args form before commits + after fixture
# changes; use the focused form during iteration on a specific
# service's codegen.

set -euo pipefail

cd "$(dirname "$0")/.."
REPO=$(pwd)

CODEGEN="gleam run -m aws_codegen --"

# Positional args become the focused service filter. Empty = full run.
FOCUS=("$@")

if [ ${#FOCUS[@]} -eq 0 ]; then
  echo "→ building protocol-test JSON ASTs"
  "$REPO/scripts/build-protocol-test-asts.sh"

  echo "→ extracting endpoint fixtures from vendor models"
  "$REPO/scripts/extract-endpoints.sh"
else
  echo "→ focused mode: regenerating only ${FOCUS[*]}"
fi

cd "$REPO/codegen"

mkdir -p ../src/aws/services/protocoltests ../test/protocol_tests ../services

# Create a per-service hex package skeleton at services/<svc>/ on
# first regen. Idempotent: re-running doesn't clobber the gleam.toml
# (so manually edited metadata like extra deps survives).
#
# Used by the per-service codegen loop below so each emitted
# .gleam file lands inside a buildable, publish-ready package
# alongside its sibling services.
ensure_service_package() {
  svc="$1"
  pkg_dir="../services/$svc"
  toml="$pkg_dir/gleam.toml"
  readme="$pkg_dir/README.md"
  licence="$pkg_dir/LICENSE"
  # Always (re)create the src tree — the codegen write below will
  # fail with ENOENT if `src/aws/services/` is missing, which it is
  # for a service whose `gleam.toml` was committed by hand but
  # whose generated file is gitignored.
  mkdir -p "$pkg_dir/src/aws/services"
  # README is only required by `gleam publish` ("Cannot publish with
  # no README"). Only emit it for services we actually publish — see
  # the same list in scripts/publish.sh. Override via env var when
  # adding a new service to the publish set.
  PUBLISHED_SERVICES="${PUBLISHED_SERVICES:-s3 sqs dynamodb rds sesv2}"
  case " $PUBLISHED_SERVICES " in
    *" $svc "*)
      if [ ! -f "$readme" ]; then
        cat > "$readme" <<EOF
# aws_gleam_$svc

Typed Gleam client for AWS ${svc//_/ }. Auto-generated from the
upstream Smithy model in [aws-gleam](https://github.com/Ulberg/aws-gleam).

\`\`\`gleam
import aws/services/$svc

pub fn main() {
  let assert Ok(client) = $svc.new()
  // ... typed ops, e.g. $svc.<op>(client, input)
}
\`\`\`

Depends on
[\`aws_gleam_runtime\`](https://hex.pm/packages/aws_gleam_runtime)
for SigV4 signing, credentials, endpoint resolution, retry, and
the protocol codecs. Each AWS service ships as a separate hex
package so consumers only compile the services they import; the
SDK's full set of ~409 generated services lives at
<https://github.com/Ulberg/aws-gleam/tree/main/services>.

## Documentation

Full docs at <https://hexdocs.pm/aws_gleam_$svc>.

## License

Apache 2.0. See LICENSE.
EOF
      fi
      ;;
  esac
  # Share the top-level LICENSE across every published package.
  if [ ! -f "$licence" ] && [ -f "../LICENSE" ]; then
    cp ../LICENSE "$licence"
  fi
  if [ ! -f "$toml" ]; then
    cat > "$toml" <<EOF
name = "aws_gleam_$svc"
version = "0.1.0"
target = "erlang"

description = "Typed Gleam client for AWS ${svc//_/ } service. Auto-generated from the upstream Smithy model. Depends on aws_gleam_runtime for SigV4 signing, the credentials chain, endpoint resolution, retry, and the protocol codecs."

licences = ["Apache-2.0"]
repository = { type = "github", user = "Ulberg", repo = "aws-gleam" }
links = [
  { title = "Source", href = "https://github.com/Ulberg/aws-gleam/tree/main/services/$svc" },
]

[dependencies]
aws_gleam_runtime = { path = "../../runtime" }
gleam_stdlib = ">= 0.40.0 and < 2.0.0"
gleam_otp = ">= 1.0.0 and < 2.0.0"
gleam_erlang = ">= 1.0.0 and < 2.0.0"
gleam_http = ">= 4.0.0 and < 5.0.0"
gleam_httpc = ">= 5.0.0 and < 6.0.0"
gleam_json = ">= 2.0.0 and < 4.0.0"

[dev-dependencies]
gleeunit = ">= 1.0.0 and < 2.0.0"
EOF
  fi
}

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
  # Focused mode: skip names not in the FOCUS list.
  if [ ${#FOCUS[@]} -gt 0 ]; then
    in_focus=0
    for want in "${FOCUS[@]}"; do
      if [ "$name" = "$want" ]; then
        in_focus=1
        break
      fi
    done
    if [ "$in_focus" -eq 0 ]; then
      continue
    fi
  fi
  # `|| true` because grep exits 1 when there's no match — that's
  # expected for awsQuery / ec2Query / rpcv2Cbor models we're
  # skipping. Without it, `set -e` would terminate the script.
  proto=$({ grep -m1 -oE '"aws.protocols#(awsJson1_0|awsJson1_1|restJson1|restXml|awsQuery)"' "$f" || true; } | sed -E 's/^"aws.protocols#//;s/".*$//')
  if [ -n "$proto" ]; then
    echo "$name $proto" >> "$SERVICES_LIST"
  fi
done

TOTAL=$(wc -l < "$SERVICES_LIST" | tr -d ' ')
echo "  $TOTAL services to generate"

# Focused mode: any names that didn't survive the filter (typo, or
# the service uses a protocol we don't generate yet) surface here
# so a silent miss doesn't masquerade as "done".
if [ ${#FOCUS[@]} -gt 0 ]; then
  missing=()
  for want in "${FOCUS[@]}"; do
    if ! grep -q "^${want} " "$SERVICES_LIST"; then
      missing+=("$want")
    fi
  done
  if [ ${#missing[@]} -gt 0 ]; then
    echo "  warning: requested services not found in supported-protocol set:"
    printf '    - %s\n' "${missing[@]}"
  fi
fi

echo "→ regenerating service clients"
FAILURES=()
ERRLOG=$(mktemp)
trap 'rm -f $SERVICES_LIST $ERRLOG' EXIT

# Track touched files so focused-mode formatting only re-runs `gleam
# format` on what changed.
TOUCHED=()

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
  # Per-service hex package directory: services/<svc>/src/aws/services/<svc>.gleam.
  # Service name on disk uses underscores; the hex package name follows the
  # same convention ("aws_<svc>"). Auto-create the package skeleton on first
  # regen via ensure_service_package; the .gleam file lands inside.
  svc="${name//-/_}"
  ensure_service_package "$svc"
  out="../services/${svc}/src/aws/services/${svc}.gleam"
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
  else
    TOUCHED+=("$out")
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
#
# Skipped in focused mode: the full-run count check expects ~409
# files on disk; a focused run leaves the rest of the services
# from the previous full run alongside the freshly-regenerated
# subset, so the count usually still passes — but if a focused
# run is the first one ever on a clean repo, the directory is
# nearly empty and the guard would spuriously fire.
if [ ${#FOCUS[@]} -eq 0 ]; then
  WRITTEN=$(find ../services -maxdepth 5 -path '*/src/aws/services/*.gleam' | wc -l | tr -d ' ')
  if [ "$WRITTEN" -lt "$TOTAL" ]; then
    echo
    echo "  service-count check: expected $TOTAL .gleam files, found $WRITTEN."
    echo "  the per-service loop reported 0 failures but the directory is short."
    echo "  one or more codegen calls exited 0 without writing — investigate"
    echo "  by running ./scripts/regen.sh interactively without stderr suppression."
    exit 1
  fi
fi

# Protocol-test fixtures regenerate from the smithy-rs corpus and
# are independent of any single service. Skip in focused mode —
# they're presumably fresh from a recent full run, and re-running
# them on every focused iteration defeats the focus.
if [ ${#FOCUS[@]} -eq 0 ]; then
  echo "→ regenerating protocol-test client modules + dispatchers"
  $CODEGEN awsJson1_0 ../test/fixtures/protocol-tests/awsJson1_0.json ../src/aws/services/protocoltests/json10.gleam --dispatcher-out ../test/protocol_tests/awsjson10_dispatchers.gleam >/dev/null
  $CODEGEN awsJson1_1 ../test/fixtures/protocol-tests/awsJson1_1.json ../src/aws/services/protocoltests/json11.gleam --dispatcher-out ../test/protocol_tests/awsjson11_dispatchers.gleam >/dev/null
  $CODEGEN restJson1  ../test/fixtures/protocol-tests/restJson1.json  ../src/aws/services/protocoltests/restjson1.gleam --dispatcher-out ../test/protocol_tests/restjson1_dispatchers.gleam >/dev/null
  $CODEGEN restXml    ../test/fixtures/protocol-tests/restXml.json    ../src/aws/services/protocoltests/restxml.gleam   --dispatcher-out ../test/protocol_tests/restxml_dispatchers.gleam >/dev/null
  $CODEGEN restXml    ../test/fixtures/protocol-tests/restXmlWithNamespace.json ../src/aws/services/protocoltests/restxml_with_namespace.gleam --dispatcher-out ../test/protocol_tests/restxml_with_namespace_dispatchers.gleam >/dev/null
  $CODEGEN awsQuery   ../test/fixtures/protocol-tests/awsQuery.json   ../src/aws/services/protocoltests/awsquery.gleam  --dispatcher-out ../test/protocol_tests/awsquery_dispatchers.gleam >/dev/null
  $CODEGEN ec2Query   ../test/fixtures/protocol-tests/ec2Query.json   ../src/aws/services/protocoltests/ec2query.gleam  --dispatcher-out ../test/protocol_tests/ec2query_dispatchers.gleam >/dev/null
  $CODEGEN rpcv2Cbor  ../test/fixtures/protocol-tests/rpcv2Cbor.json  ../src/aws/services/protocoltests/rpcv2cbor.gleam --dispatcher-out ../test/protocol_tests/rpcv2cbor_dispatchers.gleam >/dev/null
fi

cd "$REPO"

# `gleam format` to match the project's check-formatting CI step.
# Format every generated service module on full runs; in focused
# mode, format only the freshly-regenerated files so the format
# step doesn't walk ~410 files for one service.
echo "→ formatting generated modules"
if [ ${#FOCUS[@]} -eq 0 ]; then
  gleam format \
    services \
    src/aws/services/protocoltests \
    test/protocol_tests >/dev/null
else
  # `${TOUCHED[@]}` paths are codegen-relative (../src/...); strip
  # the leading `../` so `gleam format` sees them from the repo
  # root. Guarded against the empty case (`set -u` would otherwise
  # treat `"${TOUCHED[@]}"` as an unbound-variable expansion when
  # the focused run produced zero matches).
  if [ ${#TOUCHED[@]} -gt 0 ]; then
    REPO_RELATIVE=()
    for t in "${TOUCHED[@]}"; do
      REPO_RELATIVE+=("${t#../}")
    done
    gleam format "${REPO_RELATIVE[@]}" >/dev/null
  fi
fi

echo "done."
