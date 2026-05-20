#!/bin/sh
# Build + push the Fargate container image for the smoke test.
#
# The Dockerfile does the heavy lifting (gleam + erlang from
# `ghcr.io/gleam-lang/gleam:VERSION-erlang-alpine`, runs
# `scripts/regen.sh`, `gleam export erlang-shipment`). This script
# orchestrates: ensure ECR repo → docker buildx → docker push →
# tofu apply.
#
# Set `SKIP_INFRA=1` to stop after the push (e.g. for `docker run`
# locally to debug the image).
#
# Prereqs: docker (with buildx), tofu (or terraform), AWS CLI v2,
# AWS credentials in env vars (`eval "$(aws configure
# export-credentials --format env)"`).

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"

IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "→ ensuring ECR repo exists"
( cd "$HERE/infra" && tofu init -upgrade=false >/dev/null && \
  tofu apply -auto-approve -target=aws_ecr_repository.smoke >/dev/null )

REPO_URL=$( cd "$HERE/infra" && tofu output -raw ecr_repo_url )
REGION=$( cd "$HERE/infra" && tofu output -raw region 2>/dev/null || echo us-east-1 )

# `linux/arm64` on purpose:
#   * matches Fargate's arm64 platform (cheaper vCPU, no emulation
#     overhead vs x86_64),
#   * matches an Apple-silicon dev host so no Rosetta layer,
#   * avoids https://github.com/erlang/otp/issues/10355 (escript
#     crashes with `failed_to_start_child,user,nouser` when running
#     an x86 OTP under QEMU/Rosetta on an arm64 host).
# infra/main.tf must keep `runtime_platform.cpu_architecture = "ARM64"`
# in lockstep with this.
echo "→ building container image for linux/arm64"
docker buildx build \
  --platform linux/arm64 \
  --provenance=false \
  --load \
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

echo "→ tofu apply (reader service rolls forward to the new image digest)"
( cd "$HERE/infra" && tofu apply -auto-approve )

echo
echo "done. Try:"
echo "  ./run-smoke.sh \"hello from fargate\""
