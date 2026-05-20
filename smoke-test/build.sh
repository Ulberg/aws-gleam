#!/bin/sh
# Build + push the Lambda container image for the smoke test.
#
#   1. Resolve + download deps (incl. the path-dep SDK).
#   2. Run the SDK's codegen so all ~409 services compile.
#   3. `gleam export erlang-shipment` builds a self-contained OTP
#      release under build/erlang-shipment/. The shipment doesn't
#      include the Erlang runtime itself — the Dockerfile pulls
#      that from `erlang:27-slim`.
#   4. Slim the shipment: drop compile-time-only `.hrl` includes
#      and any `aws@services@*.beam` we don't actually use. The
#      `KEEP_SERVICES` env var (space-separated, defaults to
#      `s3 sqs`) controls which service modules survive.
#   5. `docker buildx build` the image for `linux/amd64` (Lambda's
#      x86_64 architecture — change to arm64 if you change the
#      Lambda function's `architectures` in main.tf).
#   6. Ensure the ECR repo exists (`tofu apply -target=...`),
#      docker-login, push.
#   7. Final `tofu apply` so the Lambda picks up the new image
#      digest. The function depends on the data.aws_ecr_image
#      data source so a fresh push forces a Lambda update.
#
# Set `SKIP_REGEN=1` to skip step 2 once the SDK is generated.
# Set `SKIP_INFRA=1` to stop after the push (useful for `docker run`
# locally).
#
# Prereqs: gleam, docker, tofu (or terraform), AWS CLI v2,
# AWS credentials in env vars (`aws configure export-credentials
# --format env | eval`).

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"

KEEP_SERVICES="${KEEP_SERVICES:-s3 sqs}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "→ resolving Gleam deps"
gleam deps download >/dev/null

if [ "${SKIP_REGEN:-0}" != "1" ]; then
  echo "→ generating SDK services (one-shot via the path dep)"
  ( cd ../ && ./scripts/regen.sh )
fi

echo "→ building OTP release (no ERTS — the container provides Erlang)"
rm -rf build/erlang-shipment
ERL_FLAGS="${ERL_FLAGS:-+t 4194304}" gleam export erlang-shipment >/dev/null

SHIPMENT="build/erlang-shipment"

echo "→ slimming shipment (keep services: $KEEP_SERVICES)"
rm -rf "$SHIPMENT/aws/include"
KEEP_ALT=$(echo "$KEEP_SERVICES" | tr ' ' '|')
find "$SHIPMENT/aws/ebin" -name 'aws@services@*.beam' \
  -not -regex ".*aws@services@\\($KEEP_ALT\\)\\.beam" \
  -delete

echo "→ ensuring ECR repo exists"
( cd infra && tofu init -upgrade=false >/dev/null && \
  tofu apply -auto-approve -target=aws_ecr_repository.smoke >/dev/null )

REPO_URL=$( cd infra && tofu output -raw ecr_repo_url )
REGION=$( cd infra && tofu output -raw region 2>/dev/null || echo us-east-1 )

echo "→ building container image for linux/amd64"
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --load \
  -t "${REPO_URL}:${IMAGE_TAG}" \
  .

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
( cd infra && tofu apply -auto-approve )

echo
echo "done. Try:"
WRITER=$( cd infra && tofu output -raw writer_function_name )
echo "  aws lambda invoke --function-name $WRITER \\"
echo "    --payload '{\"hello\":\"smoke\"}' \\"
echo "    --cli-binary-format raw-in-base64-out /tmp/response.json"
echo "  cat /tmp/response.json"
