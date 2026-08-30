variable "aws_region" {
  description = "AWS region for the Terraform backend resources"
  type        = string
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name for Terraform remote state"
  type        = string
}