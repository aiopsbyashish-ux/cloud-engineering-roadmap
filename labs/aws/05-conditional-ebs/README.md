# Lab 05 - Conditional Infrastructure and Optional EBS Volume

## Objective

The objective of this lab is to extend the reusable EC2 Terraform module created in Lab 04 by introducing conditional infrastructure.

The EC2 module can now optionally create and attach an additional EBS application volume depending on the requirements provided by the caller.

This allows the same module to support workloads such as:

- EC2 with only a root volume
- EC2 with a root volume and an additional application volume

without maintaining separate EC2 modules.

---

## Architecture

```text
Application Requirements
        |
        v
terraform.tfvars
        |
        v
Root Module
        |
        v
Reusable EC2 Child Module
        |
        +----------------------+
        |                      |
        v                      v
   EC2 Instance         application_volume_size
        |                      |
        |                +-----+-----+
        |                |           |
        |              null        number
        |                |           |
        |             count=0      count=1
        |                |           |
        |                |           v
        |                |      EBS Volume
        |                |           |
        |                |           v
        +----------------+----> Volume Attachment
```

---

## New Concepts Introduced

### 1. Optional Module Inputs

The application volume is controlled using an optional variable:

```hcl
variable "application_volume_size" {
  description = "Size of the optional application EBS volume in GB"
  type        = number
  default     = null
}
```

`null` represents the absence of the optional requirement.

For example:

```hcl
application_volume_size = null
```

means no application volume is required.

Whereas:

```hcl
application_volume_size = 100
```

requests a 100 GB application volume.

---

## 2. Conditional Expressions

Terraform conditional expressions follow the pattern:

```hcl
condition ? true_value : false_value
```

The module uses:

```hcl
var.application_volume_size != null ? 1 : 0
```

If an application volume is requested, the expression returns `1`.

If no application volume is requested, it returns `0`.

---

## 3. Conditional Resource Creation with count

The EBS volume uses:

```hcl
count = var.application_volume_size != null ? 1 : 0
```

This produces:

```text
application_volume_size = null
        |
        v
count = 0
        |
        v
No EBS volume
```

and:

```text
application_volume_size = 100
        |
        v
count = 1
        |
        v
One 100 GB EBS volume
```

---

## 4. Resource Addressing with count

When `count` is used, Terraform treats the resource as an indexed collection.

Therefore, instead of:

```hcl
aws_ebs_volume.application.id
```

the created resource is referenced using:

```hcl
aws_ebs_volume.application[0].id
```

For example:

```text
module.web_server.aws_ebs_volume.application[0]
```

The `[0]` exists because the first resource created by `count` has index zero.

---

## 5. EBS Availability Zone Requirement

Amazon EBS volumes are Availability Zone scoped.

An EBS volume must be in the same Availability Zone as the EC2 instance to which it will be attached.

Instead of asking the caller to provide the Availability Zone separately, the module derives it from the EC2 instance:

```hcl
availability_zone = aws_instance.this.availability_zone
```

This provides two benefits:

1. The EBS volume automatically uses the same AZ as the EC2 instance.
2. Terraform automatically detects an implicit dependency between the EC2 instance and EBS volume.

---

## 6. Implicit Dependency

The following reference:

```hcl
availability_zone = aws_instance.this.availability_zone
```

allows Terraform Core to determine:

```text
EC2 Instance
     |
     v
EBS Volume
```

Terraform can understand this dependency even when the actual Availability Zone is shown during planning as:

```text
(known after apply)
```

Terraform needs to know the dependency relationship during planning; the actual value can become available during apply.

---

## 7. EBS Volume

The optional application volume is implemented using:

```hcl
resource "aws_ebs_volume" "application" {
  count = var.application_volume_size != null ? 1 : 0

  availability_zone = aws_instance.this.availability_zone
  size              = var.application_volume_size
  type              = "gp3"
  encrypted         = true

  tags = {
    Name = "${var.instance_name}-app-volume"
  }
}
```

The module enforces:

- gp3 volume type
- EBS encryption
- Same Availability Zone as the EC2 instance

while allowing the caller to select the required volume size.

---

## 8. Volume Attachment

Creating an EBS volume does not automatically attach it to an EC2 instance.

The module therefore uses:

```hcl
resource "aws_volume_attachment" "application" {
  count = var.application_volume_size != null ? 1 : 0

  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.application[0].id
  instance_id = aws_instance.this.id
}
```

The attachment uses the same condition as the EBS volume.

This ensures that:

```text
No EBS requested
     |
     +--> EBS count = 0
     |
     +--> Attachment count = 0
```

and:

```text
EBS requested
     |
     +--> EBS count = 1
     |
     +--> Attachment count = 1
```

---

## 9. Dependency Chain

Terraform can infer the required resource ordering through references.

```text
EC2 Instance
     |
     | availability_zone
     v
EBS Volume
     |
     | volume_id
     v
Volume Attachment
```

The attachment also directly references the EC2 instance ID.

Therefore, explicit `depends_on` declarations are not required.

---

## 10. Input Flow

```text
terraform.tfvars
        |
        v
Root Variable
        |
        v
module "web_server"
        |
        v
Child Module Variable
        |
        v
Conditional Expression
        |
        v
count
        |
        v
Optional AWS Resources
```

Example:

```hcl
application_volume_size = 100
```

flows through the root module into the child EC2 module.

---

## 11. Output Flow

The child module exposes the optional EBS volume ID:

```hcl
output "application_volume_id" {
  description = "ID of the optional application EBS volume"
  value       = var.application_volume_size != null ? aws_ebs_volume.application[0].id : null
}
```

The root module then exposes:

```hcl
output "application_volume_id" {
  description = "ID of the optional application EBS volume"
  value       = module.web_server.application_volume_id
}
```

The output safely returns `null` when no application volume exists.

---

## 12. Test Scenario 1 - No Application Volume

No value was provided for:

```hcl
application_volume_size
```

Therefore the root variable used:

```hcl
default = null
```

Terraform evaluated:

```hcl
var.application_volume_size != null ? 1 : 0
```

as:

```text
0
```

The resulting plan contained only the standard infrastructure.

No optional EBS volume or attachment was created.

---

## 13. Test Scenario 2 - 100 GB Application Volume

The following requirement was added:

```hcl
application_volume_size = 100
```

Terraform evaluated the conditional expression as:

```text
1
```

The plan then included:

```text
module.web_server.aws_ebs_volume.application[0]
module.web_server.aws_volume_attachment.application[0]
```

The EBS volume configuration was:

```text
Size       = 100 GB
Type       = gp3
Encrypted  = true
```

The plan changed from:

```text
7 to add
```

to:

```text
9 to add
```

because Terraform added:

1. EBS volume
2. EBS volume attachment

---

## 14. Successful Deployment

Terraform successfully deployed the infrastructure.

Example outputs from the lab:

```text
application_volume_id = vol-09e22ecd7ecda61a9
instance_id           = i-0ad59fd6c7ab209b5
private_ip            = 10.0.1.89
public_ip             = 13.50.226.209
```

Terraform state contained:

```text
module.web_server.aws_ebs_volume.application[0]
module.web_server.aws_instance.this
module.web_server.aws_volume_attachment.application[0]
```

This confirmed that Terraform successfully created and managed both the optional volume and its attachment.

---

## 15. Cloud Attachment vs Operating System Mount

Terraform attaching an EBS volume to an EC2 instance only performs the infrastructure-level attachment.

It does not automatically guarantee:

- Filesystem creation
- Filesystem formatting
- Mount-point creation
- Persistent `/etc/fstab` configuration
- Application usage of the filesystem

These are operating-system or configuration-management responsibilities.

This demonstrates the separation between:

```text
Infrastructure Provisioning
        |
        v
Terraform

versus

Operating System Configuration
        |
        v
cloud-init / Ansible / other configuration tools
```

---

## 16. Enterprise Design Perspective

A reusable infrastructure module should expose application requirements while enforcing organizational standards.

For this module:

Application-controlled input:

```text
application_volume_size
```

Module-enforced standards:

```text
EBS type       = gp3
Encryption     = enabled
EBS AZ         = EC2 AZ
```

This allows different workloads to use the same module:

```text
Application A
EC2 only

Application B
EC2 + 100 GB EBS

Application C
EC2 + 500 GB EBS
```

without creating separate Terraform modules.

---

## 17. Important Learning Points

### null

`null` represents the absence of an optional value.

However, `null` itself does not automatically prevent resource creation.

The module gives `null` this behavior through:

```hcl
count = var.application_volume_size != null ? 1 : 0
```

### count

`count` controls how many instances of a Terraform resource exist.

```text
count = 0 -> resource does not exist
count = 1 -> one resource exists
```

### Indexed Resource Address

Resources using `count` are referenced by index:

```hcl
aws_ebs_volume.application[0]
```

### Dependency Before Value

Terraform can understand:

```text
Resource A depends on Resource B
```

even if the actual value being passed between them is:

```text
(known after apply)
```

---

## 18. Common Mistakes

### Creating the attachment when no volume exists

Incorrect design:

```text
EBS count        = 0
Attachment count = 1
```

The attachment would reference a volume that does not exist.

### Passing the EBS AZ separately

This introduces unnecessary duplicate configuration and the possibility of EC2/EBS AZ mismatch.

### Assuming null automatically disables resources

`null` must be combined with conditional logic such as `count`.

### Forgetting the count index

When `count` is used:

```hcl
aws_ebs_volume.application.id
```

is not the correct reference.

The resource instance must be addressed using:

```hcl
aws_ebs_volume.application[0].id
```

---

## 19. Revision Sheet

Remember:

```text
null
 |
 v
Optional requirement absent
```

Conditional expression:

```hcl
condition ? true_value : false_value
```

Conditional resource:

```hcl
count = var.application_volume_size != null ? 1 : 0
```

Resource addressing:

```text
count used
   |
   v
resource[0]
```

EBS rule:

```text
EC2 AZ = EBS AZ
```

Dependency:

```text
Reference another resource
        |
        v
Implicit dependency
```

Complete Lab 05 flow:

```text
Application Requirement
        |
        v
Root Variable
        |
        v
Child Module Variable
        |
        v
Conditional Expression
        |
        v
count
        |
        +---- 0 ----> No EBS
        |
        `---- 1 ----> EBS
                       |
                       v
                    Attachment
```

---

## 20. Lab Outcome

This lab extended the reusable EC2 module from Lab 04 with conditional infrastructure.

The same module can now deploy EC2 instances with or without additional application storage based entirely on caller requirements.

The lab introduced the foundation required for more advanced Terraform patterns such as:

- Multiple optional resources
- `for_each`
- Maps and objects
- Dynamic infrastructure
- More flexible reusable modules