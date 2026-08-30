variable "aws_region" {
  description = "AWS region where resources will be deployed"
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