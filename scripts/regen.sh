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

cd "$REPO/codegen"

mkdir -p ../src/aws/services/protocoltests

echo "→ regenerating service clients"
$CODEGEN awsJson1_0 ../vendor/aws-sdk-rust/aws-models/dynamodb.json ../src/aws/services/dynamodb.gleam >/dev/null
$CODEGEN restXml ../vendor/aws-sdk-rust/aws-models/s3.json ../src/aws/services/s3.gleam >/dev/null

echo "→ regenerating protocol-test client modules"
$CODEGEN awsJson1_0 ../test/fixtures/protocol-tests/awsJson1_0.json ../src/aws/services/protocoltests/json10.gleam >/dev/null
$CODEGEN awsJson1_1 ../test/fixtures/protocol-tests/awsJson1_1.json ../src/aws/services/protocoltests/json11.gleam >/dev/null
$CODEGEN restJson1  ../test/fixtures/protocol-tests/restJson1.json  ../src/aws/services/protocoltests/restjson1.gleam >/dev/null
$CODEGEN restXml    ../test/fixtures/protocol-tests/restXml.json    ../src/aws/services/protocoltests/restxml.gleam >/dev/null
$CODEGEN awsQuery   ../test/fixtures/protocol-tests/awsQuery.json   ../src/aws/services/protocoltests/awsquery.gleam >/dev/null
$CODEGEN ec2Query   ../test/fixtures/protocol-tests/ec2Query.json   ../src/aws/services/protocoltests/ec2query.gleam >/dev/null

cd "$REPO"

echo "→ regenerating dispatcher glue"
python3 scripts/emit-dispatchers.py --protocol awsjson10  --service-module aws/services/protocoltests/json10     --namespace 'aws.protocoltests.json10'  >/dev/null
python3 scripts/emit-dispatchers.py --protocol awsjson11  --service-module aws/services/protocoltests/json11     --namespace 'aws.protocoltests.json'    >/dev/null
python3 scripts/emit-dispatchers.py --protocol restjson1  --service-module aws/services/protocoltests/restjson1  --namespace 'aws.protocoltests.restjson' >/dev/null
python3 scripts/emit-dispatchers.py --protocol restxml    --service-module aws/services/protocoltests/restxml    --namespace 'aws.protocoltests.restxml' >/dev/null
python3 scripts/emit-dispatchers.py --protocol awsquery   --service-module aws/services/protocoltests/awsquery   --namespace 'aws.protocoltests.query'   >/dev/null
python3 scripts/emit-dispatchers.py --protocol ec2query   --service-module aws/services/protocoltests/ec2query   --namespace 'aws.protocoltests.ec2'     >/dev/null

echo "done."
