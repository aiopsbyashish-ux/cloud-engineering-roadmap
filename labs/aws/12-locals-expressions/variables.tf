variable "aws_region" {
  type        = string
  description = "AWS region where resources will be deployed"
}

variable "project_name" {
  type        = string
  description = "Project name for the Terraform locals lab"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}