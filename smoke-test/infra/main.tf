terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }
}

provider "aws" {
  region = var.region
}

# Default VPC / subnets — fine for a smoke test. Production would
# pass in dedicated networking via vars; we keep the module
# self-contained so `tofu apply` works against any AWS account
# with a default VPC.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# ---- ECR repo for the container image ----
#
# Created via a -target apply before build.sh pushes; the
# data.aws_ecr_image source below resolves on the second apply
# (after the push) and pins the task definition to the pushed
# digest so re-pushes roll the ECS service forward unambiguously.

resource "aws_ecr_repository" "smoke" {
  name                 = var.service_name
  force_delete         = true
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

data "aws_ecr_image" "smoke" {
  repository_name = aws_ecr_repository.smoke.name
  image_tag       = var.image_tag

  depends_on = [aws_ecr_repository.smoke]
}

locals {
  image_uri = "${aws_ecr_repository.smoke.repository_url}@${data.aws_ecr_image.smoke.image_digest}"
}

# ---- S3 bucket the writer writes + reader reads ----

resource "aws_s3_bucket" "smoke" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "smoke" {
  bucket                  = aws_s3_bucket.smoke.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "smoke" {
  bucket = aws_s3_bucket.smoke.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---- SQS queue: writer publishes, reader long-polls ----

resource "aws_sqs_queue" "smoke" {
  name                       = var.service_name
  message_retention_seconds  = 3600
  visibility_timeout_seconds = 60
  # Reader long-polls with wait_time_seconds=20 on the receive
  # side; the queue's own ReceiveMessageWaitTimeSeconds is for
  # callers that don't override per-call, so we leave it default.
}

# ---- IAM ----
#
# Two roles each, matching ECS task convention:
#   * execution role  — used by the ECS agent to pull the image
#                       from ECR and write logs to CloudWatch.
#   * task role       — used by the container's process for
#                       calls to AWS (S3 / SQS via the SDK).

data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${var.service_name}-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Writer task role — S3 PutObject + SQS SendMessage.

resource "aws_iam_role" "writer" {
  name               = "${var.service_name}-writer"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "writer_perms" {
  statement {
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.smoke.arn}/*"]
  }
  statement {
    actions   = ["sqs:SendMessage", "sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.smoke.arn]
  }
}

resource "aws_iam_role_policy" "writer" {
  name   = "${var.service_name}-writer-policy"
  role   = aws_iam_role.writer.id
  policy = data.aws_iam_policy_document.writer_perms.json
}

# Reader task role — S3 GetObject + SQS Receive/Delete.

resource "aws_iam_role" "reader" {
  name               = "${var.service_name}-reader"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

data "aws_iam_policy_document" "reader_perms" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.smoke.arn}/*"]
  }
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.smoke.arn]
  }
}

resource "aws_iam_role_policy" "reader" {
  name   = "${var.service_name}-reader-policy"
  role   = aws_iam_role.reader.id
  policy = data.aws_iam_policy_document.reader_perms.json
}

# ---- CloudWatch log group, shared by both tasks ----

resource "aws_cloudwatch_log_group" "smoke" {
  name              = "/ecs/${var.service_name}"
  retention_in_days = 7
}

# ---- ECS cluster + writer task def + reader service ----

resource "aws_ecs_cluster" "smoke" {
  name = var.service_name
}

resource "aws_security_group" "tasks" {
  name        = "${var.service_name}-tasks"
  # ASCII-only: EC2 rejects non-ASCII in SG descriptions.
  description = "Egress-only - Fargate tasks call out to S3 / SQS / ECR"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "writer" {
  family                   = "${var.service_name}-writer"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.writer.arn

  # Match the image's `--platform linux/arm64` build (see build.sh).
  # Mixing platforms makes ECS fail with `CannotPullContainerError`.
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "writer"
      image     = local.image_uri
      essential = true
      environment = [
        { name = "SMOKE_ROLE", value = "writer" },
        { name = "SMOKE_BUCKET", value = aws_s3_bucket.smoke.bucket },
        { name = "SMOKE_QUEUE_URL", value = aws_sqs_queue.smoke.url },
        { name = "AWS_REGION", value = var.region },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.smoke.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "writer"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "reader" {
  family                   = "${var.service_name}-reader"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.reader.arn

  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name      = "reader"
      image     = local.image_uri
      essential = true
      environment = [
        { name = "SMOKE_ROLE", value = "reader" },
        { name = "SMOKE_BUCKET", value = aws_s3_bucket.smoke.bucket },
        { name = "SMOKE_QUEUE_URL", value = aws_sqs_queue.smoke.url },
        { name = "AWS_REGION", value = var.region },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.smoke.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "reader"
        }
      }
    }
  ])
}

# Reader as a long-running ECS service. desired_count = 1 keeps
# exactly one task alive; if it crashes ECS restarts it. The
# writer is *not* a service — it's a one-shot, started on demand
# via `aws ecs run-task` (see ../README.md).

resource "aws_ecs_service" "reader" {
  name            = "${var.service_name}-reader"
  cluster         = aws_ecs_cluster.smoke.id
  task_definition = aws_ecs_task_definition.reader.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.tasks.id]
    assign_public_ip = true # Fargate in default-VPC public subnets
                            # needs this to reach ECR + S3 + SQS
  }
}
