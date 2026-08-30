
variable "aws_region" {
  type        = string
  description = "Region for deployed resource"
}
variable "project_name" {
  type        = string
  description = "Terraform lab for for_each Map"
}
variable "environment" {
  type        = string
  description = "Lab for Terraform"
}



variable "environments" {
  type = map(string)
  default = {
    dev  = "development"
    test = "testing"
    prod = "production"
  }
}