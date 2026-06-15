#!/usr/bin/env bash
# Run `gleam test` with the BEAM atom-table bumped. Generating all
# ~409 AWS services creates several million atoms across the
# generated source (type names, function names, record field labels,
# etc.) which blows past Erlang's default 1M-atom ceiling. Without
# `+t <large>` the BEAM crashes mid-compile with
# `no more index entries in atom_tab` (macOS prints the line; the
# Linux CI BEAM segfaults silently with the same root cause).
#
# 16M (16777216) is comfortable headroom — a recent local run uses
# ~2.4M atoms. ERL_AFLAGS is also exported so escripts spawned by
# `gleam` (Rust binary) inherit the bump even if they construct
# their `erl` argv from scratch — ERL_AFLAGS is *appended* by the
# emulator init and survives an explicit `-args_file`.
#
# CI may layer additional ERL_FLAGS (`+S N:N` to cap parallelism on
# lower-headroom runners, etc.) via the workflow's step `env:` block
# without editing this script — keep the local default fast.
#
# The generated service source and Smithy fixtures are intentionally
# gitignored. On a fresh clone this script bootstraps them before
# running the suite; on an already-generated workspace it stays fast.
#
# Pass any additional flags through to `gleam test` — e.g.
# `scripts/test.sh --include live` to opt into the live AWS suite.

set -euo pipefail

cd "$(dirname "$0")/.."

missing_artifacts() {
  required=(
    "services/api_gateway/src/aws/services/api_gateway.gleam"
    "services/cloudwatch_logs/src/aws/services/cloudwatch_logs.gleam"
    "services/dynamodb/src/aws/services/dynamodb.gleam"
    "services/eks/src/aws/services/eks.gleam"
    "services/s3/src/aws/services/s3.gleam"
    "services/sqs/src/aws/services/sqs.gleam"
    "services/transcribe_streaming/src/aws/services/transcribe_streaming.gleam"
    "src/aws/services/protocoltests/json10.gleam"
    "src/aws/services/protocoltests/json11.gleam"
    "src/aws/services/protocoltests/restjson1.gleam"
    "src/aws/services/protocoltests/restxml.gleam"
    "test/fixtures/endpoints/dynamodb-rule-set.json"
    "test/fixtures/endpoints/s3-rule-set.json"
    "test/fixtures/protocol-tests/awsJson1_0.json"
    "test/fixtures/protocol-tests/awsJson1_1.json"
    "test/fixtures/protocol-tests/restJson1.json"
    "test/fixtures/protocol-tests/restXml.json"
  )

  for path in "${required[@]}"; do
    if [ ! -s "$path" ]; then
      echo "test.sh: missing generated artifact: $path"
      return 0
    fi
  done

  return 1
}

ensure_codegen_inputs() {
  if [ ! -s vendor/aws-sdk-rust/aws-models/s3.json ] ||
     [ ! -s vendor/smithy/smithy-aws-protocol-tests/model/shared-types.smithy ]; then
    echo "test.sh: initializing sparse vendor submodules"
    ./scripts/init-submodules.sh
  fi
}

case "${AWS_GLEAM_TEST_REGEN:-auto}" in
  always)
    ensure_codegen_inputs
    ./scripts/regen.sh
    ;;
  auto)
    if missing_artifacts; then
      ensure_codegen_inputs
      ./scripts/regen.sh
    fi
    ;;
  never)
    ;;
  *)
    echo "error: AWS_GLEAM_TEST_REGEN must be auto, always, or never" >&2
    exit 1
    ;;
esac

# Always overwrite — CI's previous bump-attempts left a too-small
# value in the env and the `:-` default never fired. Idempotent
# locally either way.
export ERL_FLAGS="+t 16777216"
export ERL_AFLAGS="+t 16777216"

echo "test.sh: ERL_FLAGS=$ERL_FLAGS ERL_AFLAGS=$ERL_AFLAGS"

exec gleam test "$@"
