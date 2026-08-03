variable "aws_region" {
  description = "AWS Region where resources will be deployed"
  type        = string
}

variable "bucket_name" {
  description = "Unique S3 bucket name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}