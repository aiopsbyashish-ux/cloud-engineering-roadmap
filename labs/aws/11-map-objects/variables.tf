variable "aws_region" {
  type        = string
  description = "eu-north-1"
}
variable "project_name" {
  type        = string
  description = "Terraform lab for map object"
}
variable "environment" {
  type        = string
  description = "Lab for map object"
}
variable "environment_config" {
  type = map(object({
    description = string
    owner       = string
    critical    = bool
    }
    )
  )
}

 