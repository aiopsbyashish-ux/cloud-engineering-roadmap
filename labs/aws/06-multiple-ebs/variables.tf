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

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public subnet"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the public subnet"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "root_volume_size" {
  description = "Size of the root EBS volume in GiB"
  type        = number
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public IP address to the EC2 instance"
  type        = bool
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed monitoring for the EC2 instance"
  type        = bool
}

variable "additional_volumes" {
  description = "Map of additional EBS volumes"

  type = map(object({
    size        = number
    type        = string
    device_name = string
  }))

  default = {}
}