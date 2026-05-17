#!/usr/bin/env bash
# Initialise the codegen-side submodules with sparse-checkout.
#
# A plain `git submodule update --init` would pull the full 2.7 GB
# aws-sdk-rust tree. We only need ~185 MB across two subtrees:
#
#   vendor/aws-sdk-rust  — sparse to `aws-models/` (Smithy JSON models +
#                          sdk-partitions.json + sdk-endpoints.json)
#   vendor/smithy        — sparse to `smithy-aws-protocol-tests/`
#                          (per-protocol httpRequestTests fixtures)
#
# Safe to re-run: idempotent. Run after `git submodule update --remote`
# to re-apply the sparse config after a remote bump.
set -euo pipefail

if [ ! -f .gitmodules ]; then
  echo "error: run from the repo root (.gitmodules not found here)" >&2
  exit 1
fi

# Initialise without checking out anything yet.
git submodule init
git -c submodule.recurse=false submodule update --init --no-fetch >/dev/null 2>&1 || true

# vendor/aws-sdk-rust → aws-models/ only.
if [ -d vendor/aws-sdk-rust/.git ] || [ -f vendor/aws-sdk-rust/.git ]; then
  (
    cd vendor/aws-sdk-rust
    git sparse-checkout init --cone
    git sparse-checkout set aws-models
    # Re-checkout pinned SHA so the sparse filter materialises.
    pinned_sha="$(git -C .. rev-parse :vendor/aws-sdk-rust)"
    if [ -n "$pinned_sha" ]; then
      git checkout --quiet "$pinned_sha"
    fi
  )
fi

# vendor/smithy → smithy-aws-protocol-tests/ only.
if [ -d vendor/smithy/.git ] || [ -f vendor/smithy/.git ]; then
  (
    cd vendor/smithy
    git sparse-checkout init --cone
    git sparse-checkout set smithy-aws-protocol-tests
    pinned_sha="$(git -C .. rev-parse :vendor/smithy)"
    if [ -n "$pinned_sha" ]; then
      git checkout --quiet "$pinned_sha"
    fi
  )
fi

echo "submodules initialised:"
git submodule status
