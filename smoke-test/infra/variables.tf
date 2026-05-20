variable "region" {
  description = "AWS region for the Lambda + S3 bucket."
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Writer Lambda function name. Shows up in CloudWatch / X-Ray."
  type        = string
  default     = "aws-gleam-smoke"
}

variable "reader_function_name" {
  description = "Reader Lambda function name (SQS-triggered)."
  type        = string
  default     = "aws-gleam-smoke-reader"
}

variable "writer_role" {
  description = <<-EOT
    `SMOKE_ROLE` env var the writer Lambda runs under. Default
    `writer` exercises the two-lambda S3+SQS hop; set to
    `list_buckets` to keep the original proof-of-life behaviour
    (no SQS message sent).
  EOT
  type        = string
  default     = "writer"
  validation {
    condition     = contains(["writer", "list_buckets"], var.writer_role)
    error_message = "writer_role must be `writer` or `list_buckets`."
  }
}

variable "bucket_name" {
  description = <<-EOT
    S3 bucket name. Must be globally unique — pin to your AWS
    account by including the account id or a personal prefix.
  EOT
  type        = string
}

variable "image_tag" {
  description = <<-EOT
    ECR image tag the Lambda functions point at. The build script
    pushes `latest` by default and the function pins to the digest
    behind whichever tag is set here, so a new push automatically
    rolls the Lambda forward.
  EOT
  type    = string
  default = "latest"
}
