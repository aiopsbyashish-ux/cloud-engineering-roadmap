# Lab 03 - AWS Custom VPC

## Objective

Deploy a complete AWS network from scratch using Terraform and host a web server inside a custom VPC.

---

## Architecture

Internet
↓
Internet Gateway
↓
Route Table
↓
Public Subnet
↓
Security Group
↓
EC2 Instance
↓
Apache Web Server

---

## Resources Created

- VPC
- Public Subnet
- Internet Gateway
- Route Table
- Route Table Association
- Security Group
- EC2 Instance
- Amazon Linux 2023 AMI (Data Source)

---

## Variables Used

- aws_region
- project_name
- environment
- vpc_cidr
- public_subnet_cidr
- availability_zone

---

## Validation

### Terraform

terraform validate

terraform plan

terraform apply

---

### AWS Console

Verified

- VPC
- Subnet
- Internet Gateway
- Route Table
- Route Table Association
- Security Group
- EC2 Instance

---

### Connectivity Test

```
curl http://<Public IP>
```

Expected Output

```
Hello from the Custom VPC Lab!
```

---

## Learning Outcomes

- Created a custom VPC
- Created a public subnet
- Understood Internet Gateway
- Understood Route Tables
- Understood Route Table Association
- Created Security Groups
- Deployed EC2 inside custom VPC
- Used User Data for automated provisioning
- Validated infrastructure using Terraform and AWS Console

---

## Cleanup

```
terraform destroy
```