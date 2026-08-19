# Lab 04 - Reusable EC2 Terraform Module

## Objective

The objective of this lab is to build a reusable Terraform module for deploying AWS EC2 instances.

The module separates application-specific requirements from standardized EC2 deployment logic so that different application teams can use the same module with different configurations.

Examples of configurable requirements include:

- AMI / Operating System
- Instance type
- Root volume size
- Subnet
- Security Groups
- Public IP assignment
- Detailed monitoring
- Startup / user-data script

Common organizational or security standards, such as EBS encryption, can be enforced within the module.

---

## Architecture

```text
Internet
   |
   v
Internet Gateway
   |
   v
Route Table
0.0.0.0/0 -> IGW
   |
   v
Public Subnet
   |
   v
Security Group
TCP/80 allowed
   |
   v
EC2 Instance
   |
   v
Apache Web Server
```

The lab creates:

- VPC
- Public subnet
- Internet Gateway
- Public route table
- Route table association
- Security Group
- EC2 instance using a reusable child module
- Apache web server using EC2 user data

---

## Terraform Structure

```text
04-ec2-module/
|-- data.tf
|-- internet-gateway.tf
|-- main.tf
|-- outputs.tf
|-- provider.tf
|-- route-table.tf
|-- security-group.tf
|-- subnet.tf
|-- terraform.tfvars
|-- user-data.sh
|-- variables.tf
|-- versions.tf
|-- vpc.tf
`-- modules/
    `-- ec2/
        |-- main.tf
        |-- outputs.tf
        `-- variables.tf
```

---

# Root Module vs Child Module

The root module represents the requirements of the deployment and passes the required inputs to the reusable EC2 child module.

The child EC2 module contains the standardized logic for creating an EC2 instance.

This allows the same EC2 module to be reused by multiple applications while allowing application-specific configuration to be supplied by the caller.

## Input Flow

```text
terraform.tfvars
      |
      v
Root variables
      |
      v
module "web_server"
      |
      v
Child module variables
      |
      v
aws_instance.this
      |
      v
AWS EC2
```

## Output Flow

```text
AWS EC2
      |
      v
aws_instance.this
      |
      v
Child module outputs
      |
      v
module.web_server
      |
      v
Root outputs
      |
      v
terraform output
```

A simple way to remember this:

```text
Variables -> Information INTO a module
Outputs   -> Information OUT OF a module
```

---

# Key Terraform Concepts

## Variables and tfvars

`variables.tf` defines the inputs accepted by the Terraform configuration.

It can define:

- Variable name
- Description
- Data type
- Default value
- Validation rules

Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
```

`terraform.tfvars` provides the actual values for a particular deployment.

Example:

```hcl
instance_type = "t3.micro"
```

The basic flow is:

```text
variables.tf
Defines WHAT input is expected

terraform.tfvars
Defines WHAT VALUE is supplied
```

This separation allows the same Terraform configuration to be reused for different environments and application requirements.

---

# Terraform Configuration, Core, State and Provider

A useful mental model:

```text
Configuration = Desire
Core          = Brain
State         = Memory
Provider      = AWS Interface
```

## Terraform Configuration

Terraform configuration describes the desired infrastructure.

Example:

```hcl
instance_type = "t3.micro"
```

This tells Terraform what we want the infrastructure to look like.

## Terraform Core

Terraform Core processes the configuration.

It is responsible for activities such as:

- Reading the Terraform configuration
- Evaluating expressions
- Building the dependency graph
- Comparing desired and known infrastructure
- Determining the required actions
- Creating the execution plan

## Terraform State

Terraform state maintains information about infrastructure managed by Terraform.

For example:

```text
module.web_server.aws_instance.this
                 |
                 v
           i-xxxxxxxx
```

The state allows Terraform to know that a particular Terraform resource address corresponds to a particular real AWS resource.

State is therefore Terraform's memory of the infrastructure it manages.

## AWS Provider

The AWS provider allows Terraform to communicate with AWS APIs.

Conceptually:

```text
Terraform
    |
    v
AWS Provider
    |
    v
AWS APIs
    |
    v
VPC / EC2 / EBS / Security Groups / etc.
```

The provider performs AWS-specific operations such as reading, creating, updating and deleting AWS resources.

---

# Provider Configuration

The AWS provider is configured with the required AWS region.

Example:

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      Owner       = "Ashish Jain"
      ManagedBy   = "Terraform"
    }
  }
}
```

Common tags are configured using `default_tags` so they do not need to be manually repeated across every supported AWS resource.

Typical common tags include:

```text
Project
Environment
Owner
ManagedBy
```

Resource-specific tags, such as an EC2 instance name, can still be defined directly on the resource.

---

# Resources vs Data Sources

## Resource

A Terraform `resource` creates or manages infrastructure.

Example:

```hcl
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}
```

This instructs Terraform to manage a VPC in AWS.

## Data Source

A Terraform `data` source queries information rather than creating the queried resource.

Example:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
}
```

The returned information can then be used elsewhere:

```hcl
ami_id = data.aws_ami.amazon_linux.id
```

Simple mental model:

```text
resource = Create / Manage
data     = Read / Query
```

---

# Terraform Dependency Graph

Terraform automatically determines resource dependencies by analyzing references between resources.

Example:

```hcl
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
}
```

The subnet references:

```hcl
aws_vpc.main.id
```

Terraform therefore understands that the VPC must exist before the subnet can be created.

This is called an **implicit dependency**.

```text
aws_vpc.main
      |
      v
aws_subnet.public
```

Another example:

```hcl
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
```

Terraform automatically determines:

```text
aws_subnet.public -----------\
                              \
                               -> route_table_association
                              /
aws_route_table.public ------/
```

Explicit `depends_on` is generally unnecessary when Terraform can already determine the dependency from resource references.

---

# AWS Networking Concepts

## VPC

A VPC provides an isolated virtual network within AWS.

Example:

```text
VPC CIDR
10.0.0.0/16
```

Multiple subnets can exist inside the VPC.

---

## Subnet

A subnet represents a smaller network range within the VPC.

Example:

```text
VPC
10.0.0.0/16

Public Subnet
10.0.1.0/24
```

A `/24` subnet leaves 8 bits for addresses within that subnet.

---

## Internet Gateway

An Internet Gateway provides a path between the VPC and the Internet.

Creating an Internet Gateway alone does not automatically make a subnet public.

The route table must also contain an appropriate route.

---

## Route Table

The route table determines where network traffic should be sent.

For Internet connectivity, the public route table contains:

```text
Destination: 0.0.0.0/0
Target:      Internet Gateway
```

The public subnet must also be associated with this route table.

A useful mental model:

```text
Route Table = Where should the packet go?
```

---

## Security Group

A Security Group controls whether traffic is permitted to reach or leave an AWS resource.

For the Apache web server, inbound TCP port 80 must be allowed.

A useful mental model:

```text
Route Table    = Where should traffic go?
Security Group = Is the traffic permitted?
```

Both routing and security must be correct for network communication to succeed.

---

# Reusable EC2 Module

The EC2 child module accepts application-specific inputs.

Examples include:

```text
AMI
Instance type
Root volume size
Subnet ID
Security Group IDs
Public IP requirement
Detailed monitoring
Instance name
User data
```

The module contains the standardized EC2 implementation.

Example:

```hcl
resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.enable_detailed_monitoring
  user_data                   = var.user_data

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name    = var.instance_name
    Project = var.project_name
  }
}
```

This separates:

```text
Application Requirement
        |
        v
Configurable Inputs
```

from:

```text
Organizational Standard
        |
        v
Module Implementation
```

For example, EBS encryption can remain enforced:

```hcl
encrypted = true
```

rather than allowing every application team to decide whether encryption should be enabled.

---

# Optional User Data

Not every EC2 instance is a web server.

Therefore, Apache installation should not be hard-coded into a generic EC2 module.

The module accepts optional user data:

```hcl
variable "user_data" {
  description = "Startup script to run when the EC2 instance is launched"
  type        = string
  default     = null
}
```

The root module can provide:

```hcl
user_data = file("${path.module}/user-data.sh")
```

If no startup configuration is required, the caller does not need to provide user data.

---

# Apache User Data

The lab uses the following startup script:

```bash
#!/bin/bash

dnf install -y httpd

systemctl enable httpd
systemctl start httpd

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<body>
<h1>Hello from the EC2 Module!</h1>
<p>This web server was configured automatically using Terraform user data.</p>
</body>
</html>
EOF
```

This script:

1. Installs Apache.
2. Enables Apache at startup.
3. Starts the Apache service.
4. Creates a basic web page.

---

# Terraform Outputs

The child module exposes useful information about the EC2 instance.

Examples:

```hcl
output "instance_id" {
  value = aws_instance.this.id
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_ip" {
  value = aws_instance.this.public_ip
}
```

The root module can then expose those values:

```hcl
output "instance_id" {
  value = module.web_server.instance_id
}

output "private_ip" {
  value = module.web_server.private_ip
}

output "public_ip" {
  value = module.web_server.public_ip
}
```

The values can be displayed using:

```powershell
terraform output
```

Example:

```text
instance_id = "i-xxxxxxxx"
private_ip  = "10.0.1.x"
public_ip   = "x.x.x.x"
```

---

# Terraform Workflow

The standard workflow used in this lab was:

```text
terraform init
      |
      v
terraform fmt
      |
      v
terraform validate
      |
      v
terraform plan
      |
      v
terraform apply
```

## terraform init

Initializes:

- Backend
- Provider plugins
- Modules

Run it when starting a new Terraform working directory or after relevant module/backend configuration changes.

## terraform fmt

Formats Terraform code into the standard Terraform style.

For modules and subdirectories:

```powershell
terraform fmt -recursive
```

## terraform validate

Checks whether the Terraform configuration is structurally valid.

```powershell
terraform validate
```

## terraform plan

Shows the actions Terraform intends to perform.

Examples:

```text
+   Create
~   Update
-   Destroy
-/+ Replace
```

The plan must always be reviewed carefully before applying changes, especially in production.

## terraform apply

Applies the planned changes to the infrastructure.

## terraform destroy

Removes infrastructure managed by the Terraform configuration/state.

---

# Terraform State Commands

List resources currently tracked by Terraform:

```powershell
terraform state list
```

Example:

```text
data.aws_ami.amazon_linux
aws_internet_gateway.igw
aws_route_table.public
aws_route_table_association.public
aws_security_group.public
aws_subnet.public
aws_vpc.main
module.web_server.aws_instance.this
```

Inspect a particular resource:

```powershell
terraform state show module.web_server.aws_instance.this
```

This displays attributes such as:

```text
Instance ID
AMI
Instance type
Availability Zone
Private IP
Public IP
Subnet ID
Security Groups
Root volume
Tags
```

---

# Configuration Drift

Configuration drift occurs when the actual infrastructure differs from the desired Terraform configuration.

For example:

```text
Terraform configuration:
instance_type = "t3.micro"

Engineer manually changes AWS:
t3.micro -> t3.small
```

When Terraform refreshes the managed resource during planning, the AWS provider can discover the actual value.

Terraform may then propose reconciling the resource back to the desired configuration.

Conceptually:

```text
Desired Configuration
       |
       v
Terraform Core
       |
       +---- Terraform State
       |
       v
AWS Provider
       |
       v
Actual AWS Infrastructure
```

Manual changes to Terraform-managed infrastructure should therefore be avoided unless the Terraform configuration/state is handled appropriately.

---

# Important Lesson: Dynamic AMI Selection

The AMI data source used:

```hcl
most_recent = true
```

This dynamically selects the latest AMI matching the configured filters.

During the lab, the AMI returned by AWS changed between deployments.

The existing EC2 used one AMI while the data source later returned a newer AMI.

Terraform therefore detected:

```text
Existing EC2
AMI-A

Desired Configuration
AMI-B
```

Because an EC2 instance's AMI cannot simply be changed in place, Terraform proposed replacing the EC2 instance.

## Production Consideration

Using:

```hcl
most_recent = true
```

can cause unexpected replacement plans when AWS publishes a newer matching AMI.

For production environments, AMI versioning should be controlled carefully rather than blindly accepting a new image.

---

# Troubleshooting Lessons

Several real-world issues were encountered during this lab.

## 1. Insufficient Instance Capacity

Example error:

```text
InsufficientInstanceCapacity:
We currently do not have sufficient t3.micro capacity
in the Availability Zone requested.
```

This is not a Terraform syntax problem.

It indicates that AWS does not currently have sufficient capacity for that instance type in the selected Availability Zone.

Important distinction:

```text
Instance type offered in AZ
            +
Free Tier eligible
            +
Current AWS capacity
            |
            v
Successful launch
```

An instance type being offered in an AZ does not guarantee that capacity is currently available.

---

## 2. Free Tier Instance Type Restriction

Example:

```text
InvalidParameterCombination:
The specified instance type is not eligible for Free Tier.
```

The list of Free Tier eligible instance types can be queried using the AWS CLI.

Example:

```powershell
aws ec2 describe-instance-types `
  --filters "Name=free-tier-eligible,Values=true" `
  --query "InstanceTypes[].InstanceType" `
  --output table
```

Free Tier eligibility and Availability Zone support are separate considerations.

---

## 3. Availability Zone Instance Offerings

Instance types offered in a particular Availability Zone can be queried.

Example:

```powershell
aws ec2 describe-instance-type-offerings `
  --location-type availability-zone `
  --filters "Name=location,Values=eu-north-1c" `
  --query "InstanceTypeOfferings[].InstanceType" `
  --output table
```

However:

```text
Offered in AZ != Guaranteed current capacity
```

---

## 4. DNS / Connectivity Failure

The following error was encountered:

```text
dial tcp:
lookup ec2.eu-north-1.amazonaws.com:
no such host
```

This indicated a DNS/network connectivity problem between the local machine and the AWS API endpoint rather than a Terraform configuration problem.

DNS resolution was tested using:

```powershell
nslookup ec2.eu-north-1.amazonaws.com
```

AWS connectivity and authentication were tested using:

```powershell
aws sts get-caller-identity
```

This reinforced an important troubleshooting principle:

```text
Read the actual error first
        |
        v
Identify the failing layer
        |
        v
Troubleshoot that layer
```

Do not modify Terraform code automatically when the actual problem is DNS, AWS capacity, authentication or another external dependency.

---

# User Data vs Runtime Configuration

An important lesson from the lab is that:

```text
Terraform configuration contains user_data
```

does NOT automatically prove:

```text
user_data executed successfully
Apache installed successfully
Apache started successfully
Port 80 is listening
Web page was created successfully
```

Terraform can successfully create an EC2 instance and supply the user-data script while the script itself fails inside the operating system.

Therefore:

```text
Terraform success
       !=
Application success
```

---

# Web Server Troubleshooting Approach

If the EC2 instance is successfully created but the web page is inaccessible, troubleshoot layer by layer.

## Layer 1 - AWS Resource

Verify:

```text
EC2 instance is running
Public IP exists
Expected subnet is attached
```

## Layer 2 - Networking

Verify:

```text
Internet Gateway attached to VPC
        |
        v
Route table has 0.0.0.0/0 -> IGW
        |
        v
Public subnet associated with route table
```

## Layer 3 - Security

Verify that the Security Group allows:

```text
TCP
Port 80
Expected source
```

## Layer 4 - Operating System

Verify that the instance booted successfully and user data executed.

## Layer 5 - Apache

Check:

```bash
sudo systemctl status httpd
```

Verify port 80:

```bash
sudo ss -lntp | grep :80
```

Test Apache locally:

```bash
curl localhost
```

Check user-data/cloud-init execution:

```bash
sudo cat /var/log/cloud-init-output.log
```

This helps separate AWS networking problems from operating-system/application problems.

---

# Troubleshooting Mental Model

When something fails, identify the layer first.

```text
Terraform syntax/configuration
          |
          v
Terraform Core / State
          |
          v
AWS Provider
          |
          v
AWS API / IAM / Capacity
          |
          v
VPC / Subnet / Routing
          |
          v
Security Group
          |
          v
EC2 Operating System
          |
          v
User Data / cloud-init
          |
          v
Application / Apache
```

Avoid changing unrelated layers before identifying where the failure actually exists.

---

# Module Design Principles Learned

## 1. Separate requirements from implementation

Application teams should provide their requirements through module inputs.

The module should contain reusable implementation logic.

## 2. Standardize mandatory controls

Security and organizational requirements can be enforced inside the module.

Example:

```hcl
encrypted = true
```

## 3. Keep application-specific configuration flexible

Examples:

```text
Instance type
AMI
Disk size
Monitoring
Subnet
Security Groups
User data
```

## 4. Make optional features optional

Not every EC2 requires user data.

Therefore:

```hcl
default = null
```

allows the module to support servers that do not require a startup script.

## 5. Expose only useful outputs

The child module does not need to expose every EC2 attribute.

Useful outputs include:

```text
Instance ID
Private IP
Public IP
```

---

# Future Enhancement - Additional EBS Volumes

The current module supports configuration of the EC2 root volume.

A future enhancement will allow application teams to optionally request additional EBS application volumes.

Example requirements:

```text
App A -> No additional disk

App B -> 100 GB application disk

App C -> Multiple application disks
         with different sizes
```

This enhancement can introduce additional Terraform concepts such as:

```text
Optional resources
Conditional creation
count
for_each
Objects
Maps
Dynamic application disk configuration
```

The objective will be to maintain one reusable EC2 module while supporting different application storage requirements.

---

# Key Commands Used

```powershell
terraform init

terraform fmt -recursive

terraform validate

terraform plan

terraform apply

terraform output

terraform state list

terraform state show module.web_server.aws_instance.this

terraform destroy
```

AWS validation commands used during troubleshooting:

```powershell
aws sts get-caller-identity
```

```powershell
nslookup ec2.eu-north-1.amazonaws.com
```

```powershell
aws ec2 describe-instance-types `
  --filters "Name=free-tier-eligible,Values=true" `
  --query "InstanceTypes[].InstanceType" `
  --output table
```

---

# Key Takeaways

1. Terraform modules allow infrastructure code to be reused across different application requirements.

2. Root modules provide requirements while child modules implement reusable infrastructure logic.

3. Variables carry information into modules and outputs expose information from modules.

4. Terraform Core builds the dependency graph.

5. Terraform State maintains the mapping between Terraform resources and real infrastructure.

6. The AWS Provider communicates with AWS APIs.

7. Resource references create implicit dependencies.

8. Data sources query information while resources create or manage infrastructure.

9. `terraform plan` must be reviewed carefully before applying changes.

10. Dynamic values such as `most_recent = true` can unexpectedly change the desired infrastructure.

11. An instance type being offered in an Availability Zone does not guarantee current AWS capacity.

12. Terraform successfully creating an EC2 instance does not guarantee that user data or applications inside the instance configured successfully.

13. Infrastructure troubleshooting should be performed layer by layer rather than immediately modifying Terraform code.

14. Reusable modules should balance application flexibility with organizational standardization.

15. Terraform-managed infrastructure should normally be changed through Terraform to avoid configuration drift.