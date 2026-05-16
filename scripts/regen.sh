#!/usr/bin/env bash
# Regenerate every codegen artefact this repo intentionally keeps
# OUT of git. Run before `gleam test` after a fresh clone or when
# the codegen / fixtures change.
#
# Outputs:
#   src/aws/services/dynamodb.gleam       — real DynamoDB SDK
#   src/aws/services/s3.gleam             — real S3 SDK
#   src/aws/services/protocoltests/*      — generated protocol-test fixtures
#   test/protocol_tests/*_dispatchers.gleam — generated test harness glue
#
# Both kinds of file regenerate deterministically from sources that
# IS in git (`vendor/aws-sdk-rust/aws-models/*.json` and
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

echo "→ regenerating service clients"
$CODEGEN awsJson1_0 ../vendor/aws-sdk-rust/aws-models/dynamodb.json ../src/aws/services/dynamodb.gleam >/dev/null
$CODEGEN restXml ../vendor/aws-sdk-rust/aws-models/s3.json ../src/aws/services/s3.gleam >/dev/null

echo "→ regenerating protocol-test client modules + dispatchers"
$CODEGEN awsJson1_0 ../test/fixtures/protocol-tests/awsJson1_0.json ../src/aws/services/protocoltests/json10.gleam --dispatcher-out ../test/protocol_tests/awsjson10_dispatchers.gleam >/dev/null
$CODEGEN awsJson1_1 ../test/fixtures/protocol-tests/awsJson1_1.json ../src/aws/services/protocoltests/json11.gleam --dispatcher-out ../test/protocol_tests/awsjson11_dispatchers.gleam >/dev/null
$CODEGEN restJson1  ../test/fixtures/protocol-tests/restJson1.json  ../src/aws/services/protocoltests/restjson1.gleam --dispatcher-out ../test/protocol_tests/restjson1_dispatchers.gleam >/dev/null
$CODEGEN restXml    ../test/fixtures/protocol-tests/restXml.json    ../src/aws/services/protocoltests/restxml.gleam   --dispatcher-out ../test/protocol_tests/restxml_dispatchers.gleam >/dev/null
$CODEGEN awsQuery   ../test/fixtures/protocol-tests/awsQuery.json   ../src/aws/services/protocoltests/awsquery.gleam  --dispatcher-out ../test/protocol_tests/awsquery_dispatchers.gleam >/dev/null
$CODEGEN ec2Query   ../test/fixtures/protocol-tests/ec2Query.json   ../src/aws/services/protocoltests/ec2query.gleam  --dispatcher-out ../test/protocol_tests/ec2query_dispatchers.gleam >/dev/null

cd "$REPO"

# `gleam format` to match the project's check-formatting CI step.
# The emitter doesn't try to mimic the formatter's wrapping; we let
# the formatter own that pass.
echo "→ formatting generated modules"
gleam format \
  src/aws/services/dynamodb.gleam \
  src/aws/services/s3.gleam \
  src/aws/services/protocoltests \
  test/protocol_tests >/dev/null

echo "done."
