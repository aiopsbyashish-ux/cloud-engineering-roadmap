# Chapter 2 - Terraform Fundamentals

## 1. Learning Objectives

By the end of this chapter, you should be able to:

- Explain Infrastructure as Code.
- Explain what Terraform does.
- Understand declarative infrastructure.
- Understand Terraform configuration files.
- Differentiate Terraform Configuration, Core, State and Provider.
- Understand resources and data sources.
- Use variables, tfvars and outputs.
- Understand Terraform's dependency graph.
- Explain implicit dependencies.
- Understand the Terraform state file.
- Explain configuration drift.
- Understand the Terraform workflow.
- Read a Terraform execution plan.
- Understand when Terraform updates versus replaces a resource.
- Troubleshoot basic Terraform problems systematically.

---

# 2. Why Infrastructure as Code?

Traditional infrastructure provisioning often involves:

1. Logging into a management console.
2. Creating infrastructure manually.
3. Selecting configuration options.
4. Documenting what was created.
5. Repeating the same process for another environment.

This creates several challenges:

- Manual errors
- Configuration inconsistency
- Poor repeatability
- Difficult auditing
- Configuration drift
- Dependency on individual knowledge

Infrastructure as Code changes this model.

Instead of infrastructure existing only as manually configured resources, the required infrastructure is described in code.

For example:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

The code represents the desired infrastructure.

---

# 3. What is Terraform?

Terraform is an Infrastructure as Code tool that allows infrastructure to be defined using configuration files.

Terraform can work with many platforms through providers, including:

- AWS
- Azure
- Google Cloud
- VMware
- Kubernetes
- GitHub

Terraform uses a declarative approach.

Instead of telling Terraform every individual step required to create infrastructure, we describe the final state that we want.

Example:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

We are saying:

> A VPC with this configuration should exist.

Terraform determines how to achieve that desired state.

---

# 4. Declarative vs Imperative Infrastructure

## Imperative approach

An imperative process describes the individual actions that must be performed.

Conceptually:

```text
Create VPC
Create subnet
Attach subnet to VPC
Create Internet Gateway
Attach Internet Gateway
Create route table
Create route
Associate route table
Create EC2
```

The engineer defines the sequence of operations.

## Declarative approach

Terraform primarily uses a declarative model.

We define resources and relationships:

```hcl
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

Terraform determines the required order from the relationships between resources.

This becomes especially important as infrastructure grows.

---

# 5. Terraform Configuration Files

Terraform configuration is normally divided across multiple `.tf` files.

Example:

```text
main.tf
variables.tf
outputs.tf
provider.tf
versions.tf
data.tf
vpc.tf
subnet.tf
security-group.tf
```

Terraform does not execute these files sequentially based on their filenames.

Terraform reads the `.tf` configuration files in the working directory together as one configuration.

Therefore:

```text
vpc.tf
subnet.tf
main.tf
```

are primarily used to organize code for humans.

The dependency graph determines the actual resource creation order.

---

# 6. Terraform Configuration, Core, State and Provider

This distinction is fundamental.

A useful mental model is:

```text
Configuration = Desire
Core          = Brain
State         = Memory
Provider      = Interface
```

## 6.1 Terraform Configuration

Configuration describes what infrastructure we want.

Example:

```hcl
instance_type = "t3.micro"
```

The configuration represents the desired state.

---

## 6.2 Terraform Core

Terraform Core is the central engine.

It performs tasks such as:

- Reading configuration
- Evaluating expressions
- Resolving references
- Building the dependency graph
- Comparing desired and actual infrastructure
- Determining required actions
- Creating the execution plan

Think of Terraform Core as the brain or orchestrator.

---

## 6.3 Terraform State

Terraform State records information about infrastructure managed by Terraform.

For example:

```text
Terraform address:

module.web_server.aws_instance.this

             maps to

AWS resource:

i-123456789
```

State allows Terraform to remember which real infrastructure resource corresponds to which Terraform resource.

Think of state as Terraform's memory.

---

## 6.4 AWS Provider

Terraform Core does not directly implement every AWS API operation.

The AWS provider understands AWS resources and communicates with AWS APIs.

Conceptually:

```text
Terraform Configuration
        |
        v
Terraform Core
        |
        +------ Terraform State
        |
        v
AWS Provider
        |
        v
AWS APIs
        |
        v
Actual AWS Infrastructure
```

A useful distinction:

```text
Terraform Core     -> decides what needs to happen
Terraform State    -> remembers what Terraform manages
AWS Provider       -> communicates with AWS
Configuration      -> describes what we want
```

---

# 7. Terraform Providers

Providers allow Terraform to interact with external platforms.

Example:

```hcl
provider "aws" {
  region = var.aws_region
}
```

The AWS provider can manage resources such as:

- VPC
- Subnet
- EC2
- EBS
- S3
- Security Groups
- Internet Gateways
- Route Tables

The provider should not be confused with Terraform Core.

For example, Terraform Core determines that:

```text
VPC must be created before subnet
```

when the configuration contains a reference such as:

```hcl
vpc_id = aws_vpc.main.id
```

The AWS provider is then used to perform the required AWS API operations.

---

# 8. Resources

A Terraform resource represents infrastructure that Terraform creates or manages.

Example:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
```

The syntax follows:

```text
resource "<RESOURCE_TYPE>" "<LOCAL_NAME>"
```

For example:

```text
aws_vpc = AWS resource type

main = Terraform local resource name
```

The Terraform address becomes:

```text
aws_vpc.main
```

Another example:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

Address:

```text
aws_instance.web
```

---

# 9. Data Sources

A data source reads information rather than creating the queried resource.

Example:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
}
```

The result can then be referenced:

```hcl
data.aws_ami.amazon_linux.id
```

Simple mental model:

```text
resource = Create / Manage
data     = Read / Query
```

This distinction becomes important when reading Terraform plans.

---

# 10. Dynamic Data Sources and AMI Selection

A useful feature of data sources is dynamic discovery.

For example:

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
}
```

Terraform can query AWS and obtain the newest matching AMI.

However, this introduces an important architectural consideration.

Suppose:

```text
Monday:
Latest AMI = ami-111

EC2 created using ami-111
```

Later:

```text
Friday:
AWS publishes ami-222
```

The Terraform code itself has not changed.

But the data source now returns:

```text
ami-222
```

The desired EC2 configuration therefore changes.

Terraform may produce:

```text
Existing EC2 = ami-111
Desired EC2  = ami-222

Result:
EC2 replacement required
```

This demonstrates that dynamic external data can change the effective desired infrastructure even when the Terraform source code itself has not changed.

Production environments therefore require controlled AMI management.

---

# 11. Terraform Variables

Variables make Terraform configuration reusable.

Instead of:

```hcl
instance_type = "t3.micro"
```

we can use:

```hcl
instance_type = var.instance_type
```

and define:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}
```

The variable definition explains what Terraform expects.

---

# 12. terraform.tfvars

`terraform.tfvars` provides values for variables.

Example:

```hcl
instance_type    = "t3.micro"
root_volume_size = 20
```

The distinction is:

```text
variables.tf
"What inputs does this configuration accept?"

terraform.tfvars
"What values should this deployment use?"
```

This makes the same Terraform configuration reusable.

For example:

```text
Development:
instance_type = t3.micro

Production:
instance_type = m7i.large
```

The implementation can remain the same while requirements differ.

---

# 13. Outputs

Outputs expose information produced by Terraform resources or modules.

Example:

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

After deployment:

```powershell
terraform output
```

might display:

```text
instance_id = "i-123456789"
public_ip   = "13.x.x.x"
```

Outputs are particularly important with modules.

A useful mental model:

```text
Variables -> information INTO a module

Outputs   -> information OUT OF a module
```

---

# 14. Terraform Dependency Graph

Terraform determines relationships between resources.

Consider:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}
```

The subnet contains:

```hcl
vpc_id = aws_vpc.main.id
```

Terraform Core sees this reference and determines:

```text
VPC
 |
 v
Subnet
```

The VPC must therefore exist before Terraform can create the subnet.

This is called an implicit dependency.

---

# 15. Implicit vs Explicit Dependencies

## Implicit Dependency

Created automatically through references.

Example:

```hcl
subnet_id = aws_subnet.public.id
```

Terraform understands that the referenced subnet must exist first.

Implicit dependencies are preferred when the relationship can naturally be expressed through resource references.

## Explicit Dependency

Terraform also supports:

```hcl
depends_on = [
  aws_example.resource
]
```

This explicitly tells Terraform that one object depends on another.

It should generally be used when the dependency exists but cannot be inferred from normal references.

---

# 16. Terraform State

Terraform normally maintains state in:

```text
terraform.tfstate
```

State is not simply a copy of the Terraform code.

It contains Terraform's information about managed infrastructure.

Useful command:

```powershell
terraform state list
```

Example:

```text
aws_internet_gateway.igw
aws_route_table.public
aws_security_group.public
aws_subnet.public
aws_vpc.main
module.web_server.aws_instance.this
```

To inspect one resource:

```powershell
terraform state show module.web_server.aws_instance.this
```

This can display information such as:

```text
AMI
Instance ID
Instance type
Availability Zone
Private IP
Public IP
Subnet
Security Groups
EBS volume
Tags
```

---

# 17. Desired State, State and Actual Infrastructure

These three concepts should not be confused.

```text
Terraform Configuration
"What should exist?"

Terraform State
"What infrastructure does Terraform know/manage?"

Actual Infrastructure
"What currently exists in AWS?"
```

The AWS provider allows Terraform to read the actual infrastructure.

Terraform Core then determines whether changes are required.

---

# 18. Configuration Drift

Configuration drift occurs when actual infrastructure differs from the Terraform-managed desired configuration.

Example:

Terraform configuration:

```hcl
instance_type = "t3.micro"
```

An engineer manually changes the AWS instance to:

```text
t3.small
```

Terraform still expects:

```text
t3.micro
```

During planning, Terraform can refresh/read the AWS resource through the provider and detect the difference.

It may then propose:

```text
t3.small -> t3.micro
```

to restore the configured desired state.

This is one reason Terraform-managed infrastructure should generally be modified through Terraform rather than manually through the cloud console.

---

# 19. What if Someone Deletes a Resource Manually?

Suppose Terraform State contains:

```text
module.web_server.aws_instance.this
             |
             v
          i-123456
```

Someone manually deletes:

```text
i-123456
```

from AWS.

Terraform configuration still says the EC2 should exist.

When Terraform checks AWS:

```text
Configuration:
EC2 should exist

State:
Terraform knows i-123456

Actual AWS:
i-123456 does not exist
```

Terraform can then propose creating the missing EC2 instance.

This demonstrates the different responsibilities of Configuration, State, Core and Provider.

---

# 20. Terraform Initialization

Before using a Terraform configuration, initialize the working directory:

```powershell
terraform init
```

Initialization prepares components such as:

- Providers
- Modules
- Backend configuration

A common misconception is that the provider itself performs Terraform initialization.

It does not.

`terraform init` is a Terraform CLI/Core workflow operation that prepares the required components.

---

# 21. terraform fmt

Command:

```powershell
terraform fmt
```

It reformats Terraform configuration according to Terraform's standard formatting conventions.

For subdirectories:

```powershell
terraform fmt -recursive
```

Formatting improves consistency and readability.

---

# 22. terraform validate

Command:

```powershell
terraform validate
```

It checks whether the Terraform configuration is structurally valid.

Validation does not mean that AWS will necessarily be able to create the requested infrastructure.

For example, configuration can be valid while AWS later rejects the request because of:

```text
IAM permissions
Capacity
Unsupported instance type
Quota
Invalid AWS-side combination
```

---

# 23. terraform plan

Command:

```powershell
terraform plan
```

Terraform calculates the changes required to move toward the desired configuration.

Common plan symbols include:

```text
+    Create
~    Update
-    Destroy
-/+  Destroy and recreate
```

Example:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Before applying infrastructure changes, the execution plan should always be reviewed.

Pay particular attention to:

```text
destroy
replacement
security changes
network changes
storage changes
```

---

# 24. Update vs Replacement

Not every Terraform change can be performed in place.

Some AWS attributes can be modified on an existing resource.

Others require resource replacement.

For example, changing an EC2 AMI requires creating an instance from the new image rather than changing the AMI of the existing instance.

Terraform may therefore display:

```text
-/+ destroy and then create replacement
```

The important lesson is:

> A small configuration change can sometimes cause a large infrastructure action.

Always read the plan.

---

# 25. terraform apply

Command:

```powershell
terraform apply
```

Terraform:

1. Reads the configuration.
2. Evaluates current infrastructure.
3. Determines required changes.
4. Requests confirmation when applicable.
5. Uses providers to perform the operations.
6. Updates state after successful operations.

Possible actions include:

```text
Create
Update
Replace
Destroy
```

---

# 26. terraform destroy

Command:

```powershell
terraform destroy
```

Terraform plans removal of the infrastructure managed by the current configuration/state and, after approval, performs the required delete operations.

This is particularly useful for temporary labs to avoid leaving unnecessary cloud resources running.

Always review the destroy plan before confirming it.

---

# 27. Terraform Workflow

A typical workflow is:

```text
Write / Modify Configuration
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
Review Plan
          |
          v
terraform apply
          |
          v
Validate Infrastructure
```

For a new working directory, first run:

```text
terraform init
```

---

# 28. Terraform Success Does Not Mean Application Success

This is an important operational lesson.

Suppose Terraform contains:

```hcl
user_data = file("${path.module}/user-data.sh")
```

and Terraform reports:

```text
Apply complete!
```

This proves that Terraform successfully supplied the configured user data as part of the EC2 provisioning request.

It does not prove that:

```text
user_data executed successfully
package installation succeeded
Apache started
port 80 is listening
application is healthy
```

The infrastructure layer and operating-system/application layer are different.

Conceptually:

```text
Terraform
   |
   v
EC2 Created
   |
   v
Operating System Boots
   |
   v
cloud-init
   |
   v
user_data
   |
   v
Package Installation
   |
   v
Application Service
```

Failure can occur at any layer.

---

# 29. Troubleshooting by Layer

When Terraform operations fail, do not immediately modify the Terraform code.

Identify the failing layer.

A useful troubleshooting model is:

```text
Terraform Configuration
        |
        v
Terraform Core / State
        |
        v
Provider
        |
        v
AWS API / IAM
        |
        v
AWS Capacity / Quotas
        |
        v
Networking
        |
        v
Security
        |
        v
Operating System
        |
        v
Application
```

Examples:

## DNS failure

An error such as:

```text
lookup ec2.<region>.amazonaws.com: no such host
```

points toward local DNS/network connectivity rather than necessarily incorrect Terraform resource code.

## AWS capacity failure

An AWS capacity error means Terraform successfully reached AWS, but AWS could not currently satisfy the requested infrastructure.

## Security Group issue

If the EC2 is running but TCP/80 is blocked, the infrastructure may exist while the application remains unreachable.

## User-data failure

Terraform can successfully provision the EC2 while the startup script fails inside the instance.

The error message should guide the troubleshooting layer.

---

# 30. Common Mistakes

## Mistake 1 - Assuming file order controls creation order

Terraform does not create resources based on filenames such as:

```text
01-vpc.tf
02-subnet.tf
03-ec2.tf
```

Dependencies are determined from the configuration graph.

## Mistake 2 - Confusing State with Terraform Core

State remembers managed infrastructure.

Core performs reasoning and builds the dependency graph.

## Mistake 3 - Assuming the Provider builds the dependency graph

The provider communicates with the external platform.

Terraform Core determines dependencies from the configuration.

## Mistake 4 - Blindly running terraform apply

Always review:

```text
Add
Change
Destroy
Replace
```

before applying.

## Mistake 5 - Treating Terraform success as application validation

Provisioning success does not guarantee application health.

## Mistake 6 - Committing state files to Git

Files such as:

```text
terraform.tfstate
terraform.tfstate.backup
.terraform/
```

should not normally be committed to the source repository.

## Mistake 7 - Storing sensitive values in Git

Environment-specific or sensitive tfvars should be handled carefully.

A repository can provide:

```text
terraform.tfvars.example
```

while keeping the real:

```text
terraform.tfvars
```

outside version control.

---

# 31. Enterprise Perspective

Terraform becomes significantly more valuable when infrastructure is managed by multiple teams.

Instead of every engineer manually creating infrastructure, organizations can define standardized modules.

For example:

```text
Application Team
      |
      | Requirements
      v
Terraform Module
      |
      | Organization Standards
      v
Cloud Infrastructure
```

Application teams may control:

```text
Instance size
Disk size
Application configuration
Environment
```

while the platform team can enforce:

```text
Encryption
Tagging
Security standards
Naming standards
Monitoring requirements
Approved architectures
```

This creates a balance between flexibility and governance.

---

# 32. Interview Questions

### Q1. What is Terraform?

Terraform is an Infrastructure as Code tool that allows infrastructure to be defined declaratively and managed through providers.

### Q2. What is Terraform State?

Terraform State maintains information and mappings between Terraform resource addresses and managed infrastructure.

### Q3. What is a Terraform Provider?

A provider is the integration used by Terraform to communicate with an external platform such as AWS.

### Q4. What is the difference between a resource and a data source?

A resource creates or manages infrastructure, while a data source reads information.

### Q5. What is configuration drift?

Configuration drift is a difference between the intended Terraform-managed configuration and the actual infrastructure.

### Q6. What is an implicit dependency?

A dependency Terraform determines automatically from references between resources.

### Q7. What does terraform init do?

It initializes the working directory, including required providers, modules and backend configuration.

### Q8. Why should terraform plan be reviewed?

Because configuration changes can result in updates, destruction or complete resource replacement.

### Q9. Does a successful terraform apply guarantee an application is healthy?

No. Terraform may successfully provision infrastructure while operating-system initialization or application configuration fails.

### Q10. What is the difference between Terraform Core and a Provider?

Terraform Core evaluates configuration and determines the actions required. The provider communicates with the target platform APIs to perform or read platform-specific operations.

---

# 33. Revision Sheet

Remember these four:

```text
Configuration = Desire
Core          = Brain
State         = Memory
Provider      = Interface
```

Remember:

```text
resource = Create / Manage
data     = Read / Query
```

Remember:

```text
variables = Inputs
outputs   = Outputs
```

Remember:

```text
Resource reference
       |
       v
Implicit dependency
       |
       v
Dependency graph
       |
       v
Creation order
```

Remember the workflow:

```text
init
 |
 v
fmt
 |
 v
validate
 |
 v
plan
 |
 v
review
 |
 v
apply
```

And the most important operational principle:

```text
Terraform Apply Successful
           !=
Application Healthy
```

Always validate the infrastructure and application after deployment.

---

# 34. Hands-on Lab

The concepts in this chapter are reinforced through:

```text
labs/terraform/01-local-file
```

and subsequently applied throughout:

```text
labs/aws/
```

The AWS labs progressively introduce real provider operations, state management, dependencies, variables, outputs, networking and reusable modules.

---

# 35. Chapter Summary

Terraform allows infrastructure to be managed as declarative code.

The configuration describes what should exist. Terraform Core evaluates that configuration and builds the dependency graph. Terraform State remembers the infrastructure Terraform manages. Providers communicate with platforms such as AWS.

Terraform then compares the desired infrastructure with the real environment and determines whether resources need to be created, updated, replaced or destroyed.

Understanding these internal responsibilities is more important than memorizing Terraform commands.

Once these fundamentals are clear, more advanced concepts such as modules, conditional resources, `for_each`, remote state and production infrastructure design become much easier to understand.