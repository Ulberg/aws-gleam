variable "region" {
  description = "AWS region for the ECS cluster + bucket + queue."
  type        = string
  default     = "us-east-1"
}

variable "service_name" {
  description = "Logical name used for the ECS cluster, ECR repo, IAM roles, and log group."
  type        = string
  default     = "aws-gleam-smoke"
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
    ECR image tag the task definitions point at. The build script
    pushes `latest` by default; the task defs pin to the digest
    behind whichever tag is set here, so a new push automatically
    rolls the running reader service + the next writer run-task.
  EOT
  type    = string
  default = "latest"
}
