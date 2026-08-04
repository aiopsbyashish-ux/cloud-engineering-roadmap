# AWS Lab 02 - EC2 Instance with Terraform

## Overview

This lab demonstrates how to provision an Amazon EC2 instance using Terraform by following Infrastructure as Code (IaC) principles.

The project creates a complete and functional Linux web server by:

- Dynamically selecting the latest Amazon Linux 2023 AMI
- Creating a Security Group
- Launching an EC2 instance
- Configuring an encrypted GP3 root volume
- Executing a bootstrap script (User Data) to install Apache
- Displaying useful outputs such as Instance ID, Public IP, and Public DNS

---

## Architecture

```
                Terraform
                     │
                     ▼
              AWS Provider
                     │
                     ▼
              Data Source (AMI)
                     │
                     ▼
           Security Group
                     │
                     ▼
             EC2 Instance
                     │
                     ▼
              User Data Script
                     │
                     ▼
            Apache Web Server
                     │
                     ▼
               Web Application
```

---

## Project Structure

```
02-ec2-instance/
│
├── versions.tf
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── data.tf
├── main.tf
├── security-group.tf
├── outputs.tf
├── user-data.sh
└── README.md
```

---

## Files Description

| File | Purpose |
|------|---------|
| versions.tf | Terraform and AWS provider version requirements |
| provider.tf | AWS provider configuration and default tags |
| variables.tf | Input variable definitions |
| terraform.tfvars | Variable values for the lab |
| data.tf | Retrieves the latest Amazon Linux 2023 AMI |
| main.tf | Creates the EC2 instance |
| security-group.tf | Creates the Security Group |
| outputs.tf | Displays useful deployment outputs |
| user-data.sh | Bootstraps the EC2 instance |
| README.md | Project documentation |

---

## Resources Created

- EC2 Instance
- Security Group
- Encrypted GP3 Root Volume

---

## Features

- Latest Amazon Linux 2023 AMI using Terraform Data Source
- Dynamic AMI lookup
- Default resource tagging
- Encrypted root EBS volume
- Apache Web Server installation
- Automatic web page deployment
- Public IP assignment
- Infrastructure managed entirely using Terraform

---

## Terraform Commands

### Initialize

```bash
terraform init
```

### Validate

```bash
terraform validate
```

### Preview Changes

```bash
terraform plan
```

### Deploy

```bash
terraform apply
```

### View Outputs

```bash
terraform output
```

### Destroy Infrastructure

```bash
terraform destroy
```

---

## Learning Objectives

This lab covers:

- Terraform Providers
- Variables
- terraform.tfvars
- Outputs
- Data Sources
- Resource References
- Dependency Graph
- User Data
- Security Groups
- EC2
- EBS
- Tags
- Infrastructure as Code

---

## Key Concepts Learned

### Data Source

Retrieve existing AWS resources without creating them.

Example:

```hcl
data "aws_ami" "amazon_linux" {
    ...
}
```

---

### Resource Reference

Terraform automatically resolves dependencies.

Example:

```hcl
vpc_security_group_ids = [
  aws_security_group.web.id
]
```

---

### User Data

A shell script executed automatically during the first boot of the EC2 instance.

Used for:

- Package installation
- Configuration
- Service startup
- Application deployment

---

## Notes

This lab uses:

- Default VPC
- Default Subnet
- Public IP Address

These defaults simplify learning. In production environments, custom networking (VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway, etc.) should be used.

---

## Future Improvements

- Custom VPC
- Public and Private Subnets
- Internet Gateway
- Route Tables
- IAM Role
- Systems Manager Session Manager
- Application Load Balancer
- Auto Scaling Group
- Remote Terraform State (S3 + DynamoDB)

---

## Cleanup

To avoid unnecessary AWS charges, destroy all resources after completing the lab.

```bash
terraform destroy
```

---

## Author

**Ashish Jain**

Cloud Engineering Roadmap Project

Learning Terraform through real-world Infrastructure Engineering concepts.