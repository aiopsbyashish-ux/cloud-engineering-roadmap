output "state_bucket_name" {
  description = "Name of the S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_arn" {
  description = "ARN of the S3 bucket used for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "kms_key_arn" {
  description = "ARN of the KMS key used to encrypt Terraform state"
  value       = aws_kms_key.terraform_state.arn
}