output "ecr_repo_url" {
  value       = aws_ecr_repository.smoke.repository_url
  description = "ECR repo the build script tags + pushes images to."
}

output "region" {
  value       = var.region
  description = "Region everything is deployed in. Re-exported so the build script can `aws ecr get-login-password --region ...`."
}

output "writer_function_name" {
  value       = aws_lambda_function.smoke.function_name
  description = "Pass to `aws lambda invoke --function-name`."
}

output "writer_function_arn" {
  value       = aws_lambda_function.smoke.arn
  description = "Full ARN, useful for X-Ray / cross-account references."
}

output "reader_function_name" {
  value       = aws_lambda_function.reader.function_name
  description = "SQS-triggered reader; observe via CloudWatch logs."
}

output "reader_function_arn" {
  value = aws_lambda_function.reader.arn
}

output "bucket_name" {
  value       = aws_s3_bucket.smoke.bucket
  description = "S3 bucket both Lambdas read + write."
}

output "queue_url" {
  value       = aws_sqs_queue.smoke.url
  description = "SQS queue the writer publishes to and the reader subscribes to."
}

output "log_group_writer" {
  value       = aws_cloudwatch_log_group.lambda.name
  description = "Writer logs. Tail with `aws logs tail <this> --follow`."
}

output "log_group_reader" {
  value       = aws_cloudwatch_log_group.reader.name
  description = "Reader logs. Look here after invoking the writer."
}

output "invoke_command" {
  value       = "aws lambda invoke --function-name ${aws_lambda_function.smoke.function_name} --payload '{\"hello\":\"smoke\"}' --cli-binary-format raw-in-base64-out /tmp/aws-gleam-smoke-response.json && cat /tmp/aws-gleam-smoke-response.json"
  description = "Copy-paste invoke command for the writer Lambda."
}
