variable "aws_region" {
  description = "Region for AWS resource distribution"
  type        = string
}
variable "project_name" {
  description = "Terraform Lab for count and for_each"
  type        = string
}
variable "environments" {
  description = "Deployment environments"
  type        = list(string)
  default     = ["dev", "prod"]
}
variable "environment" {
  description = "Environment used for common resource tagging"
  type        = string
}