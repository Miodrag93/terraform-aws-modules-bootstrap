output "s3_bucket_name" {
  description = "Name of the S3 bucket storing Terraform state."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket storing Terraform state."
  value       = aws_s3_bucket.terraform_state.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used to encrypt the Terraform state bucket."
  value       = aws_kms_key.terraform_state.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt the Terraform state bucket."
  value       = aws_kms_key.terraform_state.arn
}

output "kms_key_alias" {
  description = "Alias of the KMS key used to encrypt the Terraform state bucket."
  value       = aws_kms_alias.terraform_state.name
}

output "secrets_manager_secret_arn" {
  description = "ARN of the Secrets Manager secret for infrastructure-level secrets."
  value       = aws_secretsmanager_secret.infrastructure.arn
}
