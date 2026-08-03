# Project 01 - AWS S3 Bucket Using Terraform

## Objective

Deploy and manage an Amazon S3 bucket using Terraform.

## Concepts Covered

- AWS provider configuration
- AWS CLI authentication
- Terraform variables
- Terraform outputs
- Provider version constraints
- Terraform state
- Resource verification using AWS CLI
- Git and GitHub workflow

## Project Structure

```text
01-s3-bucket/
├── .gitignore
├── README.md
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── variables.tf
└── versions.tf
```

## Resource Created

- Amazon S3 bucket
- Region: `eu-north-1`
- Encryption: Amazon S3 managed keys (`AES256`)
- Managed by Terraform

## Commands Used

```powershell
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform show
```

AWS verification:

```powershell
aws s3api head-bucket --bucket ashish-terraform-lab-400131408529
aws s3api get-bucket-location --bucket ashish-terraform-lab-400131408529
```

## Outputs

- Bucket name
- Bucket ARN

## Important Learning

Terraform compares the desired configuration, its state, and the actual AWS resource to determine what must be created, changed, or destroyed.

The AWS provider used credentials from the AWS credential chain. No credentials were stored in the Terraform files.

## Status

- [x] Configuration created
- [x] Terraform initialized
- [x] Configuration validated
- [x] Plan reviewed
- [x] S3 bucket deployed
- [x] AWS verification completed
- [x] Terraform state inspected
- [ ] S3 bucket destroyed
- [ ] Project pushed to GitHub

## Author

Ashish Jain# Project 01 - AWS S3 Bucket Using Terraform

## Objective

Deploy and manage an Amazon S3 bucket using Terraform.

## Concepts Covered

- AWS provider configuration
- AWS CLI authentication
- Terraform variables
- Terraform outputs
- Provider version constraints
- Terraform state
- Resource verification using AWS CLI
- Git and GitHub workflow

## Project Structure

```text
01-s3-bucket/
├── .gitignore
├── README.md
├── main.tf
├── outputs.tf
├── provider.tf
├── terraform.tfvars
├── variables.tf
└── versions.tf
```

## Resource Created

- Amazon S3 bucket
- Region: `eu-north-1`
- Encryption: Amazon S3 managed keys (`AES256`)
- Managed by Terraform

## Commands Used

```powershell
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
terraform output
terraform state list
terraform show
```

AWS verification:

```powershell
aws s3api head-bucket --bucket ashish-terraform-lab-400131408529
aws s3api get-bucket-location --bucket ashish-terraform-lab-400131408529
```

## Outputs

- Bucket name
- Bucket ARN

## Important Learning

Terraform compares the desired configuration, its state, and the actual AWS resource to determine what must be created, changed, or destroyed.

The AWS provider used credentials from the AWS credential chain. No credentials were stored in the Terraform files.

## Status

- [x] Configuration created
- [x] Terraform initialized
- [x] Configuration validated
- [x] Plan reviewed
- [x] S3 bucket deployed
- [x] AWS verification completed
- [x] Terraform state inspected
- [ ] S3 bucket destroyed
- [ ] Project pushed to GitHub

## Author

Ashish Jain