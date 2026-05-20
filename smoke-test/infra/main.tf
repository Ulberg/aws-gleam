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

# ---- S3 bucket the function reads + writes against ----

resource "aws_s3_bucket" "smoke" {
  bucket        = var.bucket_name
  force_destroy = true # ok for a smoke-test bucket; do not copy to prod
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

# ---- IAM role for the Lambda function ----

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

# Basic execution: CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Scoped S3 access — only the smoke-test bucket, all object-level
# operations the scenarios need. Both Lambda roles attach this
# (writer needs Put, reader needs Get) — the list is small enough
# that splitting per-role isn't worth the duplication.
data "aws_iam_policy_document" "bucket_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [aws_s3_bucket.smoke.arn]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = ["${aws_s3_bucket.smoke.arn}/*"]
  }
  # ListBuckets needs account-level — scoped to this caller via the
  # role's principal, so still safe.
  statement {
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "bucket_access" {
  name   = "${var.function_name}-bucket-access"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.bucket_access.json
}

# ---- SQS queue: the writer Lambda sends to, the reader Lambda
# subscribes. `visibility_timeout_seconds` must be ≥ the reader's
# Lambda timeout so a slow GetObject doesn't surface the same
# message to a second consumer.

resource "aws_sqs_queue" "smoke" {
  name                       = "${var.function_name}-queue"
  message_retention_seconds  = 3600
  visibility_timeout_seconds = 60
}

# Writer needs SQS SendMessage on the queue.
data "aws_iam_policy_document" "queue_send" {
  statement {
    actions   = ["sqs:SendMessage", "sqs:GetQueueAttributes"]
    resources = [aws_sqs_queue.smoke.arn]
  }
}

resource "aws_iam_role_policy" "queue_send" {
  name   = "${var.function_name}-queue-send"
  role   = aws_iam_role.lambda.id
  policy = data.aws_iam_policy_document.queue_send.json
}

# ---- Reader-role IAM (separate role so its scoped permissions
# stay minimal). The Lambda event-source mapping needs
# Receive/Delete/GetAttributes on the queue.

resource "aws_iam_role" "reader" {
  name               = "${var.reader_function_name}-exec"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_role_policy_attachment" "reader_basic" {
  role       = aws_iam_role.reader.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "reader_bucket_access" {
  name   = "${var.reader_function_name}-bucket-access"
  role   = aws_iam_role.reader.id
  policy = data.aws_iam_policy_document.bucket_access.json
}

data "aws_iam_policy_document" "queue_consume" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.smoke.arn]
  }
}

resource "aws_iam_role_policy" "queue_consume" {
  name   = "${var.reader_function_name}-queue-consume"
  role   = aws_iam_role.reader.id
  policy = data.aws_iam_policy_document.queue_consume.json
}

# ---- CloudWatch log group (retention) ----

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = 7
}

# ---- Lambda functions ----
#
# Both functions deploy the same zip artifact; the `SMOKE_ROLE` env
# var picks which handler `aws_gleam_smoke:main/0` dispatches to.

resource "aws_cloudwatch_log_group" "reader" {
  name              = "/aws/lambda/${var.reader_function_name}"
  retention_in_days = 7
}

resource "aws_lambda_function" "smoke" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn

  # provided.al2023 is the BEAM-on-AL2023 custom-runtime route: the
  # zip's `bootstrap` script is the entry point.
  runtime  = "provided.al2023"
  handler  = "bootstrap"
  filename = var.zip_path
  # tofu apply re-uploads when the zip changes.
  source_code_hash = filebase64sha256(var.zip_path)

  memory_size = 512
  timeout     = 30

  environment {
    variables = {
      # `SMOKE_ROLE` decides which handler runs: writer / reader /
      # list_buckets (default). The writer role does PutObject +
      # SQS SendMessage on each invocation event.
      SMOKE_ROLE      = var.writer_role
      SMOKE_BUCKET    = aws_s3_bucket.smoke.bucket
      SMOKE_QUEUE_URL = aws_sqs_queue.smoke.url
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy.bucket_access,
    aws_iam_role_policy.queue_send,
    aws_cloudwatch_log_group.lambda,
  ]
}

resource "aws_lambda_function" "reader" {
  function_name = var.reader_function_name
  role          = aws_iam_role.reader.arn

  runtime          = "provided.al2023"
  handler          = "bootstrap"
  filename         = var.zip_path
  source_code_hash = filebase64sha256(var.zip_path)

  memory_size = 512
  timeout     = 30

  environment {
    variables = {
      SMOKE_ROLE   = "reader"
      SMOKE_BUCKET = aws_s3_bucket.smoke.bucket
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.reader_basic,
    aws_iam_role_policy.reader_bucket_access,
    aws_iam_role_policy.queue_consume,
    aws_cloudwatch_log_group.reader,
  ]
}

# Wire SQS → reader Lambda. Each message's body (an S3 key) lands in
# `Records[*].body` of the JSON envelope the runtime delivers.
resource "aws_lambda_event_source_mapping" "reader" {
  event_source_arn = aws_sqs_queue.smoke.arn
  function_name    = aws_lambda_function.reader.arn
  batch_size       = 10
}
