\# Chapter 09 - Resource Iteration and Collections



\## Learning Objectives



By the end of this chapter, the reader should be able to:



\- Understand why infrastructure collections are useful

\- Understand Terraform maps and objects

\- Design a map of objects for structured infrastructure requirements

\- Understand the difference between `count`, `for\_each`, and `for` expressions

\- Use `for\_each` to create multiple resource instances

\- Understand `each.key` and `each.value`

\- Understand key-based Terraform resource identity

\- Use `for` expressions to transform collections

\- Choose between `count` and `for\_each`

\- Understand the impact of adding, removing, or renaming collection keys



\---



\# 1. Introduction



Infrastructure requirements frequently involve repeated resources.



A server may require multiple disks:



```text

EC2 Instance

&#x20;|

&#x20;+-- Root Disk

&#x20;+-- Application Disk

&#x20;+-- Data Disk

&#x20;+-- Logs Disk

```



A cloud environment may similarly require multiple:



\- Subnets

\- Security groups

\- Virtual machines

\- Storage volumes

\- IAM assignments

\- Route entries



One approach would be to create a separate Terraform resource block for every requirement.



However, this quickly creates repetitive and difficult-to-maintain infrastructure code.



Terraform provides collection types and iteration mechanisms that allow infrastructure to be described as data and processed generically.



Three important concepts are:



```text

count

for\_each

for expressions

```



Although related to iteration, they serve different purposes.



A useful mental model is:



```text

count

&#x20;   -> How many?



for\_each

&#x20;   -> For which items?



for

&#x20;   -> How should this collection be transformed?

```



\---



\# 2. Real World Problem



Consider an application server requiring:



```text

Root Disk = 30 GB

App Disk  = 100 GB

Data Disk = 500 GB

Logs Disk = 200 GB

```



A simple design could introduce separate variables:



```hcl

app\_volume\_size  = 100

data\_volume\_size = 500

logs\_volume\_size = 200

```



and separate resources for each disk.



This works, but the module becomes increasingly rigid.



If another application requires:



```text

Backup Disk

Archive Disk

Cache Disk

```



the module code would need further modification.



A reusable module should instead allow the caller to describe the required disks while keeping the resource creation logic generic.



\---



\# 3. Infrastructure as Structured Data



Instead of creating one variable per disk, the requirements can be represented as a collection:



```hcl

additional\_volumes = {

&#x20; app = {

&#x20;   size        = 100

&#x20;   type        = "gp3"

&#x20;   device\_name = "/dev/sdf"

&#x20; }



&#x20; data = {

&#x20;   size        = 500

&#x20;   type        = "gp3"

&#x20;   device\_name = "/dev/sdg"

&#x20; }



&#x20; logs = {

&#x20;   size        = 200

&#x20;   type        = "gp3"

&#x20;   device\_name = "/dev/sdh"

&#x20; }

}

```



The infrastructure requirement has now become structured data.



Terraform can process this collection without requiring separate resource blocks for `app`, `data`, and `logs`.



\---



\# 4. Understanding Maps



A map associates a key with a value.



Conceptually:



```text

Key       Value

\---       -----

app   ->  ...

data  ->  ...

logs  ->  ...

```



The keys provide meaningful identities.



For example:



```text

app

data

logs

```



are more meaningful than:



```text

0

1

2

```



This becomes particularly important when Terraform tracks resource instances.



\---



\# 5. Understanding Objects



A Terraform object groups multiple related attributes.



For example:



```hcl

{

&#x20; size        = 500

&#x20; type        = "gp3"

&#x20; device\_name = "/dev/sdg"

}

```



This object describes one disk.



Instead of passing only its size, the object can represent multiple properties of the same requirement.



\---



\# 6. Map of Objects



Combining maps and objects gives us:



```hcl

map(object({

&#x20; size        = number

&#x20; type        = string

&#x20; device\_name = string

}))

```



Conceptually:



```text

additional\_volumes

&#x20;|

&#x20;+-- app

&#x20;|    |

&#x20;|    +-- size

&#x20;|    +-- type

&#x20;|    +-- device\_name

&#x20;|

&#x20;+-- data

&#x20;|    |

&#x20;|    +-- size

&#x20;|    +-- type

&#x20;|    +-- device\_name

&#x20;|

&#x20;+-- logs

&#x20;     |

&#x20;     +-- size

&#x20;     +-- type

&#x20;     +-- device\_name

```



This structure scales much better than defining independent variables for every possible disk.



\---



\# 7. Defining the Variable



A reusable module can define:



```hcl

variable "additional\_volumes" {

&#x20; description = "Map of additional EBS volumes to create and attach"



&#x20; type = map(object({

&#x20;   size        = number

&#x20;   type        = string

&#x20;   device\_name = string

&#x20; }))



&#x20; default = {}

}

```



The empty map:



```hcl

{}

```



means that no additional volumes have been requested.



Therefore:



```text

Empty map

&#x20;  |

&#x20;  v

Zero collection members

&#x20;  |

&#x20;  v

Zero additional resources

```



\---



\# 8. count



`count` controls how many instances of a resource or module Terraform should manage.



Example:



```hcl

count = var.application\_volume\_size != null ? 1 : 0

```



This is useful for a simple optional-resource requirement:



```text

Condition false -> count = 0

Condition true  -> count = 1

```



Resources created using `count` have numeric identities:



```text

resource\[0]

resource\[1]

resource\[2]

```



The current index can be accessed using:



```hcl

count.index

```



A useful question for deciding whether `count` is appropriate is:



> How many instances do I need?



\---



\# 9. for\_each



`for\_each` creates resource or module instances based on members of a collection.



Example:



```hcl

resource "aws\_ebs\_volume" "additional" {

&#x20; for\_each = var.additional\_volumes



&#x20; availability\_zone = aws\_instance.this.availability\_zone

&#x20; size              = each.value.size

&#x20; type              = each.value.type

&#x20; encrypted         = true

}

```



If the map contains:



```text

app

data

logs

```



Terraform creates:



```text

aws\_ebs\_volume.additional\["app"]

aws\_ebs\_volume.additional\["data"]

aws\_ebs\_volume.additional\["logs"]

```



The instances are identified by their keys rather than numeric indexes.



A useful question for `for\_each` is:



> For which items should Terraform create resources?



\---



\# 10. each.key



Inside a block using `for\_each`, Terraform exposes:



```hcl

each.key

```



This represents the current collection key.



During processing of:



```text

data

```



the value is:



```text

each.key = "data"

```



It can be used for:



\- Resource naming

\- Tags

\- References

\- Mapping related resources



Example:



```hcl

tags = {

&#x20; Name = "${var.instance\_name}-${each.key}-volume"

}

```



\---



\# 11. each.value



`each.value` represents the value associated with the current key.



For:



```hcl

data = {

&#x20; size        = 500

&#x20; type        = "gp3"

&#x20; device\_name = "/dev/sdg"

}

```



Terraform sees:



```text

each.key               = "data"

each.value.size        = 500

each.value.type        = "gp3"

each.value.device\_name = "/dev/sdg"

```



Because the map value is an object, individual properties are accessed using dot notation.



\---



\# 12. Connecting Related Resources



Collections become particularly useful when multiple resource types must maintain the same identity.



For example:



```hcl

resource "aws\_volume\_attachment" "additional" {

&#x20; for\_each = var.additional\_volumes



&#x20; device\_name = each.value.device\_name

&#x20; volume\_id   = aws\_ebs\_volume.additional\[each.key].id

&#x20; instance\_id = aws\_instance.this.id

}

```



During the `data` iteration:



```text

each.key = "data"

```



therefore:



```hcl

aws\_ebs\_volume.additional\[each.key].id

```



references:



```text

aws\_ebs\_volume.additional\["data"].id

```



This creates a direct relationship between the `data` volume definition and the `data` attachment.



\---



\# 13. Resource Identity with for\_each



The key used by `for\_each` becomes part of the Terraform resource address.



For example:



```text

aws\_ebs\_volume.additional\["data"]

```



This means the key is not merely a display name.



It contributes to Terraform's understanding of resource identity.



If:



```text

"data"

```



is renamed to:



```text

"database"

```



Terraform sees different addresses:



```text

aws\_ebs\_volume.additional\["data"]



aws\_ebs\_volume.additional\["database"]

```



Without explicitly migrating the resource address/state, Terraform may interpret this as:



```text

data removed     -> destroy

database added   -> create

```



Therefore, `for\_each` keys should be meaningful and stable.



\---



\# 14. Changing Values While Keeping the Key



Consider:



```hcl

data = {

&#x20; size = 500

}

```



changing to:



```hcl

data = {

&#x20; size = 700

}

```



The key remains:



```text

"data"

```



Terraform therefore continues to associate the configuration with the same resource instance:



```text

additional\["data"]

```



Terraform then evaluates the changed attribute.



Whether the change occurs in place or requires replacement depends on the resource type, attribute, provider behavior, and underlying cloud API.



For an EBS volume size increase, the volume can normally be modified without replacing the resource.



\---



\# 15. Removing a Collection Member



Suppose the collection contains:



```text

app

data

logs

```



and `logs` is removed.



The desired configuration now contains only:



```text

app

data

```



Terraform recognizes that:



```text

additional\["logs"]

```



is no longer required.



If both an EBS volume and attachment use the same `for\_each` collection, Terraform can propose destruction of:



```text

aws\_ebs\_volume.additional\["logs"]

aws\_volume\_attachment.additional\["logs"]

```



while leaving:



```text

additional\["app"]

additional\["data"]

```



unchanged.



This demonstrates the advantage of meaningful keyed resource identity.



\---



\# 16. Terraform for Expressions



A `for` expression serves a different purpose from `for\_each`.



It does not create multiple AWS resources.



Instead, it transforms one Terraform value into another.



Consider:



```hcl

value = {

&#x20; for key, volume in aws\_ebs\_volume.additional :

&#x20; key => volume.id

}

```



The original resource collection contains complete EBS resource objects.



Conceptually:



```text

app  -> complete EBS object

data -> complete EBS object

logs -> complete EBS object

```



The output only needs:



```text

app  -> volume ID

data -> volume ID

logs -> volume ID

```



The `for` expression performs that transformation.



\---



\# 17. Understanding key and volume



In:



```hcl

for key, volume in aws\_ebs\_volume.additional :

&#x20; key => volume.id

```



`key` and `volume` are temporary iterator variable names.



For the `data` entry:



```text

key    = "data"

volume = complete data EBS resource object

```



Then:



```hcl

key => volume.id

```



produces:



```text

"data" => "vol-..."

```



The variable names are arbitrary.



For example, this is conceptually equivalent:



```hcl

for disk\_name, disk in aws\_ebs\_volume.additional :

&#x20; disk\_name => disk.id

```



Choosing descriptive iterator names can improve readability.



\---



\# 18. count vs for\_each vs for



These three concepts should not be confused.



\## count



Purpose:



```text

Control number of resource/module instances

```



Mental question:



```text

How many?

```



Identity:



```text

resource\[0]

resource\[1]

```



\---



\## for\_each



Purpose:



```text

Create resource/module instances for collection members

```



Mental question:



```text

For which items?

```



Identity:



```text

resource\["app"]

resource\["data"]

```



\---



\## for Expression



Purpose:



```text

Transform collections and values

```



Mental question:



```text

What new collection/value do I want from this data?

```



It does not create infrastructure.



\---



\# 19. Architecture Perspective



The important architectural change is not simply that Terraform can create three disks.



The important change is that the module no longer needs to know in advance which logical disks an application may require.



Application requirements become data:



```text

Application Team

&#x20;     |

&#x20;     v

additional\_volumes

&#x20;     |

&#x20;     +-- app

&#x20;     +-- data

&#x20;     +-- logs

&#x20;     +-- backup

&#x20;     +-- archive

&#x20;     +-- ...

&#x20;     |

&#x20;     v

Reusable Terraform Module

&#x20;     |

&#x20;     v

Standardized Infrastructure

```



The module contains the standard implementation logic.



The caller provides application-specific requirements.



This separation improves:



\- Reusability

\- Standardization

\- Scalability

\- Maintainability

\- Consistency



\---



\# 20. Hands-on Lab



The associated practical implementation is:



```text

labs/aws/06-multiple-ebs

```



The lab extends the reusable EC2 module to create multiple additional EBS volumes using:



```text

map(object(...))

for\_each

each.key

each.value

for expressions

```



The implementation successfully created:



```text

7 base infrastructure resources

3 additional EBS volumes

3 volume attachments

\--------------------------------

13 managed resources

```



The lab also tested removing and restoring a map key to observe Terraform's resource identity behavior.



\---



\# 21. Common Mistakes



\## Mistake 1 - Treating each.key as the resource address



```text

each.key = "data"

```



is a value available during iteration.



The resource address is:



```text

aws\_ebs\_volume.additional\["data"]

```



\---



\## Mistake 2 - Thinking each.value is one property



With a map of objects:



```text

each.value

```



represents the entire object.



Properties are accessed using:



```hcl

each.value.size

each.value.type

each.value.device\_name

```



\---



\## Mistake 3 - Confusing for\_each and for



`for\_each` controls resource/module instances.



A `for` expression transforms data.



\---



\## Mistake 4 - Using unstable keys



Renaming a `for\_each` key changes the resource address and can result in unexpected destroy/create operations.



\---



\## Mistake 5 - Assuming a value change always means in-place update



Keeping the same key preserves Terraform's resource identity, but the provider determines whether a changed attribute can be updated in place or requires replacement.



\---



\# 22. Interview Questions



\### What is the difference between count and for\_each?



`count` creates resource instances using numeric indexes, while `for\_each` creates instances based on collection members and gives them key-based identities.



\### When would you prefer for\_each over count?



When individual resources have meaningful and stable identities or require different configuration values.



\### What is each.key?



The key of the current collection member being processed by `for\_each`.



\### What is each.value?



The value associated with the current key.



\### What happens if a for\_each key is removed?



Terraform recognizes that the corresponding resource instance is no longer part of the desired configuration and may plan to destroy it.



\### What happens if a for\_each key is renamed?



Terraform normally sees the old resource address disappear and a new one appear unless the state/resource address is explicitly migrated.



\### Does a for expression create infrastructure?



No. A `for` expression constructs or transforms Terraform values.



\### Why use a map of objects?



It allows multiple named resources to have structured and potentially different configurations while using common reusable resource logic.



\---



\# 23. Revision Sheet



```text

COUNT

=====

Question:

How many?



Example:

count = condition ? 1 : 0



Identity:

resource\[0]





FOR\_EACH

========

Question:

For which items?



Input:

{

&#x20; app  = {...}

&#x20; data = {...}

&#x20; logs = {...}

}



Identity:

resource\["app"]

resource\["data"]

resource\["logs"]



Inside:

each.key

each.value





FOR EXPRESSION

==============

Question:

How should I transform this data?



Example:



Complete resource objects

&#x20;       |

&#x20;       v

for expression

&#x20;       |

&#x20;       v

{

&#x20; app  = "vol-111"

&#x20; data = "vol-222"

&#x20; logs = "vol-333"

}



Creates AWS resources:

No





MEMORY RULE

===========



count     = How many?

for\_each  = For which items?

for       = Transform what data?

```



\---



\# 24. Summary



Terraform collections allow infrastructure requirements to be represented as structured data instead of repetitive resource definitions.



A map of objects can represent multiple resources with different properties.



`count` is useful when the primary requirement is the number of instances.



`for\_each` is useful when resources have meaningful identities represented by collection keys.



`each.key` identifies the current collection member, while `each.value` contains its associated value.



The `for\_each` key becomes part of Terraform's resource identity and should therefore remain stable.



Terraform `for` expressions do not create infrastructure. They transform collections and are useful for constructing structured outputs and other derived values.



Together, these concepts allow Terraform modules to evolve from simple reusable components into scalable infrastructure abstractions.

