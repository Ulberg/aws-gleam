#!/bin/sh
# Trigger one writer-task run and tail the reader's logs so you can
# eyeball the round-trip. Assumes:
#   * `./build.sh` ran (image pushed, infra applied)
#   * AWS creds are in the current shell
#
# Usage:
#   ./run-smoke.sh               # default payload
#   ./run-smoke.sh "my payload"  # custom payload

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
PAYLOAD="${1:-hello from aws-gleam fargate smoke test}"

cd "$HERE/infra"
CLUSTER=$(tofu output -raw cluster_arn)
TASK_DEF=$(tofu output -raw writer_task_definition)
SUBNETS=$(tofu output -json subnets | python3 -c 'import json,sys;print(",".join(json.load(sys.stdin)))')
SG=$(tofu output -raw security_group_id)
LOG_GROUP=$(tofu output -raw log_group)

# Override SMOKE_PAYLOAD in the container's env for this run only.
# AWS expects a JSON blob via --overrides.
OVERRIDES=$(cat <<EOF
{
  "containerOverrides": [
    {
      "name": "writer",
      "environment": [
        { "name": "SMOKE_PAYLOAD", "value": "$PAYLOAD" }
      ]
    }
  ]
}
EOF
)

echo "→ starting writer task with payload: $PAYLOAD"
TASK_ARN=$(aws ecs run-task \
  --cluster "$CLUSTER" \
  --task-definition "$TASK_DEF" \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],securityGroups=[$SG],assignPublicIp=ENABLED}" \
  --overrides "$OVERRIDES" \
  --query 'tasks[0].taskArn' --output text)

echo "→ task: $TASK_ARN"
echo "→ tailing $LOG_GROUP (Ctrl-C to stop)"
exec aws logs tail "$LOG_GROUP" --follow --since 1m
