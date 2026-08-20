# Lab 06 - Multiple EBS Volumes with for_each

## Objective

The objective of this lab is to extend the reusable EC2 Terraform module so that it can create and attach multiple additional EBS volumes.

Instead of defining separate variables and resources for application, data, log, or other disks, the module accepts a structured collection of volume requirements.

This lab introduces:

- Maps
- Objects
- Map of objects
- `for_each`
- `each.key`
- `each.value`
- Terraform `for` expressions
- Key-based resource identity
- Collection transformation

---

## Architecture

```text
Application Requirements
        |
        v
additional_volumes
        |
        +-- app
        |    +-- size = 100
        |    +-- type = gp3
        |    +-- device = /dev/sdf
        |
        +-- data
        |    +-- size = 500
        |    +-- type = gp3
        |    +-- device = /dev/sdg
        |
        +-- logs
             +-- size = 200
             +-- type = gp3
             +-- device = /dev/sdh
        |
        v
     for_each
        |
        +--> EBS["app"]  --> Attachment["app"]
        |
        +--> EBS["data"] --> Attachment["data"]
        |
        +--> EBS["logs"] --> Attachment["logs"]
        |
        v
    EC2 Instance
```

---

## Why the Lab 05 Design Needed to Evolve

Lab 05 supported one optional application disk:

```hcl
application_volume_size = 100
```

This worked well for a requirement of:

```text
0 or 1 additional disk
```

However, enterprise workloads may require:

```text
Root Disk
App Disk
Data Disk
Logs Disk
Backup Disk
```

Creating variables such as:

```hcl
app_volume_size  = 100
data_volume_size = 500
logs_volume_size = 200
```

would make the module increasingly repetitive.

The module was therefore redesigned to accept one structured collection.

---

## Map of Objects

The module accepts:

```hcl
variable "additional_volumes" {
  description = "Map of additional EBS volumes to create and attach"

  type = map(object({
    size        = number
    type        = string
    device_name = string
  }))

  default = {}
}
```

Each map key represents the identity of a disk.

Each value is an object containing that disk's configuration.

Example:

```hcl
additional_volumes = {
  app = {
    size        = 100
    type        = "gp3"
    device_name = "/dev/sdf"
  }

  data = {
    size        = 500
    type        = "gp3"
    device_name = "/dev/sdg"
  }

  logs = {
    size        = 200
    type        = "gp3"
    device_name = "/dev/sdh"
  }
}
```

---

## Empty Map as the Default

The variable uses:

```hcl
default = {}
```

An empty map contains zero entries.

Therefore:

```text
additional_volumes = {}
        |
        v
for_each has zero items
        |
        v
No additional EBS volumes
```

A populated map allows Terraform to create one resource instance for every entry.

---

## Creating Multiple Resources with for_each

The EBS resource uses:

```hcl
resource "aws_ebs_volume" "additional" {
  for_each = var.additional_volumes

  availability_zone = aws_instance.this.availability_zone
  size              = each.value.size
  type              = each.value.type
  encrypted         = true

  tags = {
    Name = "${var.instance_name}-${each.key}-volume"
  }
}
```

With the keys:

```text
app
data
logs
```

Terraform creates:

```text
aws_ebs_volume.additional["app"]
aws_ebs_volume.additional["data"]
aws_ebs_volume.additional["logs"]
```

---

## each.key

`each.key` represents the current map key.

For example, while Terraform processes:

```text
data
```

then:

```hcl
each.key
```

is:

```text
"data"
```

This can be used for resource names, tags, references, and other configuration.

---

## each.value

`each.value` represents the complete value associated with the current key.

For:

```hcl
data = {
  size        = 500
  type        = "gp3"
  device_name = "/dev/sdg"
}
```

Terraform sees:

```text
each.key               = "data"
each.value.size        = 500
each.value.type        = "gp3"
each.value.device_name = "/dev/sdg"
```

---

## Multiple Volume Attachments

The attachment resource also uses the same collection:

```hcl
resource "aws_volume_attachment" "additional" {
  for_each = var.additional_volumes

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.additional[each.key].id
  instance_id = aws_instance.this.id
}
```

The important reference is:

```hcl
aws_ebs_volume.additional[each.key].id
```

During the `data` iteration this effectively refers to:

```hcl
aws_ebs_volume.additional["data"].id
```

This ensures that each attachment uses the matching EBS volume.

---

## Resource Mapping

The resulting mapping is:

```text
app
 |
 +--> EBS["app"]
       |
       +--> Attachment["app"]
             |
             +--> /dev/sdf

data
 |
 +--> EBS["data"]
       |
       +--> Attachment["data"]
             |
             +--> /dev/sdg

logs
 |
 +--> EBS["logs"]
       |
       +--> Attachment["logs"]
             |
             +--> /dev/sdh
```

---

## count vs for_each

Lab 05 used `count`.

Lab 06 uses `for_each`.

A useful mental model is:

```text
count
"How many?"
```

Example:

```hcl
count = condition ? 1 : 0
```

Resource identity:

```text
resource[0]
```

Whereas:

```text
for_each
"For which items?"
```

Resource identity:

```text
resource["app"]
resource["data"]
resource["logs"]
```

`count` is useful when numerical instances or simple 0/1 conditional creation are appropriate.

`for_each` is useful when resources have meaningful and stable identities.

---

## Key-Based Resource Identity

With `for_each`, the map key becomes part of the Terraform resource address.

For example:

```text
aws_ebs_volume.additional["data"]
```

The `"data"` key therefore has architectural importance.

Changing:

```text
"data"
```

to:

```text
"database"
```

changes the Terraform resource address.

Terraform can then interpret the configuration as:

```text
"data" removed
"database" added
```

which may result in destruction and creation unless the state/resource address is explicitly migrated.

Keys should therefore be chosen carefully and kept stable.

---

## Changing a Value Without Changing the Key

If:

```text
data.size = 500
```

changes to:

```text
data.size = 700
```

the resource key remains:

```text
additional["data"]
```

Terraform still recognizes the same resource identity.

Whether Terraform performs an in-place update or replacement then depends on whether the changed resource attribute can be modified in place by the provider/API.

For an EBS volume size increase, Terraform can normally perform an in-place modification.

---

## Removing a Key

The lab tested removing:

```text
"logs"
```

from the map.

Terraform detected that these resource instances were no longer part of the desired configuration:

```text
aws_ebs_volume.additional["logs"]
aws_volume_attachment.additional["logs"]
```

The plan therefore proposed:

```text
0 to add
0 to change
2 to destroy
```

The `app` and `data` resources remained unaffected because their keys and configuration were unchanged.

After restoring the `logs` key, `terraform plan` returned:

```text
No changes.
```

This demonstrates the importance of stable resource identity with `for_each`.

---

## Terraform for Expression

The child module needs to return the IDs of all created volumes.

The EBS resource collection contains complete Terraform resource objects.

The output only requires:

```text
disk name -> volume ID
```

A Terraform `for` expression transforms the collection:

```hcl
output "additional_volume_ids" {
  description = "Map of additional EBS volume IDs"

  value = {
    for key, volume in aws_ebs_volume.additional :
    key => volume.id
  }
}
```

Conceptually:

```text
Complete EBS resource collection

app  -> complete EBS object
data -> complete EBS object
logs -> complete EBS object

             |
             | for expression
             v

{
  app  = "vol-..."
  data = "vol-..."
  logs = "vol-..."
}
```

---

## for_each vs for Expression

Although both contain the word `for`, they perform different jobs.

### for_each

Controls resource instances.

```hcl
for_each = var.additional_volumes
```

It creates:

```text
EBS["app"]
EBS["data"]
EBS["logs"]
```

### for Expression

Transforms data.

```hcl
for key, volume in aws_ebs_volume.additional :
key => volume.id
```

It does not create AWS resources.

It produces a new Terraform value.

A useful memory rule is:

```text
count    = How many?
for_each = For which items?
for      = Transform what data?
```

---

## Successful Deployment

The lab successfully created:

```text
7 base infrastructure resources
3 EBS volumes
3 volume attachments
--------------------------------
13 Terraform-managed resources
```

Terraform plan showed:

```text
Plan: 13 to add, 0 to change, 0 to destroy
```

The resulting state included:

```text
module.web_server.aws_ebs_volume.additional["app"]
module.web_server.aws_ebs_volume.additional["data"]
module.web_server.aws_ebs_volume.additional["logs"]

module.web_server.aws_volume_attachment.additional["app"]
module.web_server.aws_volume_attachment.additional["data"]
module.web_server.aws_volume_attachment.additional["logs"]
```

---

## Output

The `for` expression produced a map similar to:

```text
additional_volume_ids = {
  "app"  = "vol-..."
  "data" = "vol-..."
  "logs" = "vol-..."
}
```

This gives consumers of the module a structured output while hiding unnecessary internal resource details.

---

## Enterprise Design Perspective

A reusable module should allow application teams to describe their requirements without requiring module code changes for every new disk.

Instead of:

```text
app_volume
data_volume
logs_volume
backup_volume
```

as separately coded resources, the application provides:

```text
additional_volumes
        |
        +--> app
        +--> data
        +--> logs
        +--> backup
        +--> ...
```

The module then processes the collection generically.

This improves:

- Reusability
- Scalability
- Maintainability
- Consistency
- Standardization

---

## Important Learning Points

### count

Controls the number of resource instances.

```text
How many?
```

### for_each

Creates resource instances from collection members.

```text
For which items?
```

### each.key

Current item's identity/key.

### each.value

Current item's associated value/object.

### for expression

Transforms one collection into another.

It does not create infrastructure.

### Stable Keys

With `for_each`, keys become part of Terraform resource identity and should be treated carefully.

---

## Common Mistakes

### Confusing for_each with for

`for_each` creates multiple resource/module instances.

A `for` expression transforms values.

### Thinking each.key is the resource address

During an iteration:

```text
each.key = "backup"
```

The corresponding resource address is:

```text
aws_ebs_volume.additional["backup"]
```

### Using unstable keys

Changing a `for_each` key changes the Terraform resource address.

### Treating each.value as a single property

With a map of objects, `each.value` represents the complete object.

Individual attributes are accessed using:

```hcl
each.value.size
each.value.type
each.value.device_name
```

---

## Revision Sheet

```text
COUNT
-----
Question: How many?

count = 0
count = 1
count = N

Identity:
resource[0]
resource[1]


FOR_EACH
--------
Question: For which items?

Keys:
app
data
logs

Identity:
resource["app"]
resource["data"]
resource["logs"]

Inside resource:
each.key
each.value


FOR EXPRESSION
--------------
Question: How should I transform this collection?

Input:
Complete resource objects

Output:
{
  app  = "vol-111"
  data = "vol-222"
  logs = "vol-333"
}

Creates infrastructure?
No
```

---

## Lab Outcome

This lab evolved the EC2 module from supporting one optional EBS volume to supporting any number of named additional EBS volumes.

The module now accepts a map of structured volume requirements and uses `for_each` to create and attach the required resources.

The lab also demonstrated how Terraform resource identity works with `for_each` and how `for` expressions can transform complex resource collections into useful module outputs.