terraform {
  required_version = ">= 1.13.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "ashish-jain-terraform-lab-2026"
    key          = "17-alb-asg/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:eu-north-1:400131408529:key/db70ccb9-ceb1-43a1-bf0f-429f03c5d9fc"
    use_lockfile = true
  }
}