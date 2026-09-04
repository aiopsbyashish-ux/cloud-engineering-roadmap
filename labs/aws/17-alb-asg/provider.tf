provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "Cloud-Engineering-Roadmap"
      Environment = "lab"
      ManagedBy   = "Terraform"
      Lab         = "17-alb-asg"
    }
  }
}