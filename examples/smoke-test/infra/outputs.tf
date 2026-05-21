output "region" {
  value       = var.region
  description = "Region everything is deployed in."
}

output "ecr_repo_url" {
  value       = aws_ecr_repository.smoke.repository_url
  description = "ECR repo the build script tags + pushes images to."
}

output "cluster_arn" {
  value       = aws_ecs_cluster.smoke.arn
  description = "ECS cluster ARN — pass to `aws ecs run-task --cluster`."
}

output "writer_task_definition" {
  value       = aws_ecs_task_definition.writer.family
  description = "Task family — pass to `aws ecs run-task --task-definition`."
}

output "reader_service_name" {
  value       = aws_ecs_service.reader.name
  description = "Reader service. `aws ecs describe-services` to inspect."
}

output "bucket_name" {
  value       = aws_s3_bucket.smoke.bucket
  description = "S3 bucket the writer writes + reader reads."
}

output "queue_url" {
  value       = aws_sqs_queue.smoke.url
  description = "SQS queue the writer publishes to and the reader long-polls."
}

output "log_group" {
  value       = aws_cloudwatch_log_group.smoke.name
  description = "Shared log group. `aws logs tail <this> --follow` to watch both writer + reader."
}

output "subnets" {
  value       = data.aws_subnets.default.ids
  description = "Subnets the writer run-task command needs in --network-configuration."
}

output "security_group_id" {
  value       = aws_security_group.tasks.id
  description = "SG the writer run-task command needs in --network-configuration."
}
