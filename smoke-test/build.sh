#!/bin/sh
# Build + push the Lambda container image for the smoke test.
#
# The image's Dockerfile does the heavy lifting:
#   1. Installs Gleam on top of erlang:27.
#   2. Copies the repo in.
#   3. Runs ./scripts/regen.sh and `gleam export erlang-shipment` so
#      the BEAM bytecode is compiled with the same OTP version that
#      will run it in the runtime stage.
#   4. Slims the shipment to KEEP_SERVICES (default `s3 sqs`).
#   5. Copies the slimmed shipment onto a fresh erlang:27-slim base.
#
# This script just orchestrates: ECR repo ready → docker buildx
# (linux/amd64) → docker push → tofu apply.
#
# Set `SKIP_INFRA=1` to stop after the push (useful for `docker run`
# locally).
#
# Prereqs: docker (with buildx), tofu (or terraform), AWS CLI v2,
# AWS credentials in env vars (`eval "$(aws configure
# export-credentials --format env)"`).

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"

KEEP_SERVICES="${KEEP_SERVICES:-s3 sqs}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "→ ensuring ECR repo exists"
( cd "$HERE/infra" && tofu init -upgrade=false >/dev/null && \
  tofu apply -auto-approve -target=aws_ecr_repository.smoke >/dev/null )

REPO_URL=$( cd "$HERE/infra" && tofu output -raw ecr_repo_url )
REGION=$( cd "$HERE/infra" && tofu output -raw region 2>/dev/null || echo us-east-1 )

echo "→ building container image for linux/amd64 (this regen+exports the SDK in-image)"
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --load \
  --build-arg KEEP_SERVICES="$KEEP_SERVICES" \
  -t "${REPO_URL}:${IMAGE_TAG}" \
  -f "$HERE/Dockerfile" \
  "$REPO_ROOT"

echo "→ docker login to ECR ($REGION)"
aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$REPO_URL"

echo "→ docker push"
docker push "${REPO_URL}:${IMAGE_TAG}"

if [ "${SKIP_INFRA:-0}" = "1" ]; then
  echo "done → image pushed; skipping tofu apply (SKIP_INFRA=1)"
  exit 0
fi

echo "→ tofu apply (Lambda functions pick up the new image digest)"
( cd "$HERE/infra" && tofu apply -auto-approve )

echo
echo "done. Try:"
WRITER=$( cd "$HERE/infra" && tofu output -raw writer_function_name )
echo "  aws lambda invoke --function-name $WRITER \\"
echo "    --payload '{\"hello\":\"smoke\"}' \\"
echo "    --cli-binary-format raw-in-base64-out /tmp/response.json"
echo "  cat /tmp/response.json"
