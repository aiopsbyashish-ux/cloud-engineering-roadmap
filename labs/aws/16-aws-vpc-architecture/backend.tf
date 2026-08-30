terraform {
  backend "s3" {
    bucket       = "ashish-jain-terraform-lab-2026"
    key          = "16-aws-vpc-architecture/terraform.tfstate"
    region       = "eu-north-1"
    encrypt      = true
    kms_key_id   = "arn:aws:kms:eu-north-1:400131408529:key/db70ccb9-ceb1-43a1-bf0f-429f03c5d9fc"
    use_lockfile = true
  }
}