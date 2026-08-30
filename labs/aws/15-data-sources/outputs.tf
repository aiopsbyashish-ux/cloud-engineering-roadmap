output "aws_account_id" {
  description = "Current AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}
output "availability_zones" {
  description = "Available AZs in the configured AWS region"
  value       = data.aws_availability_zones.available.names
}