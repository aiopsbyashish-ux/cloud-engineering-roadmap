variable "project_name" {
  description = "Project name used for tagging"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
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

variable "subnet_id" {
  description = "Subnet ID where the EC2 instance will be deployed"
  type        = string
}

variable "security_group_ids" {
  description = "Security Group IDs to attach to the EC2 instance"
  type        = list(string)
}

variable "associate_public_ip_address" {
  description = "Whether to assign a public IP address to the EC2 instance"
  type        = bool
}

variable "enable_detailed_monitoring" {
  description = "Whether to enable detailed monitoring"
  type        = bool
}
variable "user_data" {
  description = "Startup script to run when the EC2 instance is launched"
  type        = string
  default     = null
}