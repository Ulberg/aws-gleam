#!/usr/bin/env bash
# Lift the `smithy.rules#endpointRuleSet` and `smithy.rules#endpointTests`
# trait blobs out of each vendored AWS service model and write them as
# the standalone fixtures under `test/fixtures/endpoints/`. Each model
# carries both traits under its service shape; we just unwrap them.
#
# Run after `vendor/aws-sdk-rust` is bumped to a new SHA. Output is
# byte-equivalent to the previously-tracked fixtures (verified by
# diffing before untracking).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MODEL_DIR="$ROOT/vendor/aws-sdk-rust/aws-models"
OUT_DIR="$ROOT/test/fixtures/endpoints"

# Services we ship endpoint fixtures for. Add the model basename here
# when a new service joins the typed SDK surface.
SERVICES=(
  dynamodb
  s3
)

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required (https://stedolan.github.io/jq/)" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

for svc in "${SERVICES[@]}"; do
  model="$MODEL_DIR/$svc.json"
  if [ ! -f "$model" ]; then
    echo "error: model not found: $model" >&2
    exit 1
  fi
  # Find the service shape, then pull each endpoint trait out of its
  # `traits` blob. The service shape is the only shape with type ==
  # "service"; we filter on that rather than hard-coding shape IDs so
  # the script keeps working when AWS renames the service shape.
  jq -j '[ .shapes | to_entries[] | select(.value.type == "service") ][0].value.traits["smithy.rules#endpointRuleSet"]' \
    "$model" > "$OUT_DIR/$svc-rule-set.json"
  jq -j '[ .shapes | to_entries[] | select(.value.type == "service") ][0].value.traits["smithy.rules#endpointTests"]' \
    "$model" > "$OUT_DIR/$svc-tests.json"
  printf "  %s-rule-set.json + %s-tests.json\n" "$svc" "$svc"
done

echo "done. fixtures in $OUT_DIR/"
