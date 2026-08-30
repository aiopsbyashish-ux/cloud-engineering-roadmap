variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "project_name" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Deployment environment"

  validation {
    condition     = contains(["dev", "test", "uat", "prod"], var.environment)
    error_message = "Environment must be dev, test, uat, or prod."
  }
}