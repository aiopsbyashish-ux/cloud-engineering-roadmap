\# Chapter 8 - Conditional Infrastructure



\## 1. Learning Objectives



By the end of this chapter, you should be able to:



\- Explain optional infrastructure requirements.

\- Use `null` to represent an absent optional value.

\- Use Terraform conditional expressions.

\- Use `count` for conditional resource creation.

\- Understand indexed resource addressing.

\- Understand dependency relationships between EC2 and EBS.

\- Explain why EBS volumes must be created in the same Availability Zone as the EC2 instance.

\- Design optional infrastructure inside reusable Terraform modules.



\---



\# 2. The Real-World Problem



Different applications may require different infrastructure.



For example:



```text

Application A

\- EC2 instance

\- Root disk only



Application B

\- EC2 instance

\- Root disk

\- 100 GB application disk



Application C

\- EC2 instance

\- Root disk

\- 500 GB application disk

```



Creating separate Terraform modules for every combination would create unnecessary duplication.



A better design is to allow one reusable module to create optional resources depending on caller requirements.



\---



\# 3. Optional Inputs with null



An optional application disk can be represented using:



```hcl

variable "application\_volume\_size" {

&#x20; description = "Size of the optional application EBS volume in GB"

&#x20; type        = number

&#x20; default     = null

}

```



The meaning is:



```text

null -> no application disk requested

100  -> create a 100 GB application disk

500  -> create a 500 GB application disk

```



`null` represents the absence of a value.



However, `null` alone does not prevent Terraform from creating a resource.



Conditional logic is required.



\---



\# 4. Terraform Conditional Expressions



Terraform conditional expressions use:



```hcl

condition ? true\_value : false\_value

```



Example:



```hcl

var.application\_volume\_size != null ? 1 : 0

```



If a volume size is supplied:



```text

100 != null

&#x20;    |

&#x20;    v

true

&#x20;    |

&#x20;    v

1

```



If no size is supplied:



```text

null != null

&#x20;    |

&#x20;    v

false

&#x20;    |

&#x20;    v

0

```



\---



\# 5. Conditional Resource Creation with count



Terraform's `count` meta-argument controls how many instances of a resource should exist.



Example:



```hcl

resource "aws\_ebs\_volume" "application" {

&#x20; count = var.application\_volume\_size != null ? 1 : 0

}

```



Behavior:



```text

application\_volume\_size = null

&#x20;       |

&#x20;       v

count = 0

&#x20;       |

&#x20;       v

No EBS volume

```



and:



```text

application\_volume\_size = 100

&#x20;       |

&#x20;       v

count = 1

&#x20;       |

&#x20;       v

One EBS volume

```



\---



\# 6. Indexed Resource Addressing



Once `count` is used, Terraform treats the resource as an indexed collection.



Instead of:



```hcl

aws\_ebs\_volume.application.id

```



the first resource is addressed as:



```hcl

aws\_ebs\_volume.application\[0].id

```



For example:



```text

module.web\_server.aws\_ebs\_volume.application\[0]

```



If `count` were three:



```text

resource\[0]

resource\[1]

resource\[2]

```



\---



\# 7. EBS Availability Zone Requirement



Amazon EBS volumes are scoped to an Availability Zone.



An EBS volume must be in the same Availability Zone as the EC2 instance to which it is attached.



Therefore:



```text

EC2 in eu-north-1c

&#x20;       |

&#x20;       +--> EBS in eu-north-1c  OK



EC2 in eu-north-1c

&#x20;       |

&#x20;       +--> EBS in eu-north-1a  Invalid attachment

```



Instead of asking the caller to provide the AZ again, the module can derive it directly:



```hcl

availability\_zone = aws\_instance.this.availability\_zone

```



This reduces duplicate inputs and prevents EC2/EBS AZ mismatch.



\---



\# 8. Dependency Before Value



During `terraform plan`, the EC2 Availability Zone may appear as:



```text

(known after apply)

```



Terraform can still understand the dependency because the configuration contains:



```hcl

availability\_zone = aws\_instance.this.availability\_zone

```



Terraform knows:



```text

EC2

&#x20;|

&#x20;v

EBS

```



even before the final AZ value is known.



The actual value can become available during apply.



This demonstrates an important Terraform principle:



> Terraform can know a dependency before it knows the final value.



\---



\# 9. EBS Volume Attachment



Creating an EBS volume does not automatically attach it to an EC2 instance.



The attachment is a separate Terraform resource:



```hcl

resource "aws\_volume\_attachment" "application" {

&#x20; count = var.application\_volume\_size != null ? 1 : 0



&#x20; device\_name = "/dev/sdf"

&#x20; volume\_id   = aws\_ebs\_volume.application\[0].id

&#x20; instance\_id = aws\_instance.this.id

}

```



The attachment references both:



```text

EC2 instance

EBS volume

```



Terraform therefore knows both must exist before the attachment can be created.



\---



\# 10. Matching Conditional Logic



The EBS volume and attachment use the same condition:



```hcl

count = var.application\_volume\_size != null ? 1 : 0

```



This keeps their lifecycle aligned.



Correct:



```text

No disk requested



EBS count        = 0

Attachment count = 0

```



Correct:



```text

Disk requested



EBS count        = 1

Attachment count = 1

```



Incorrect:



```text

EBS count        = 0

Attachment count = 1

```



because the attachment would reference a volume that does not exist.



\---



\# 11. Module Input Flow



```text

terraform.tfvars

&#x20;       |

&#x20;       v

Root variable

&#x20;       |

&#x20;       v

module call

&#x20;       |

&#x20;       v

Child module variable

&#x20;       |

&#x20;       v

Conditional expression

&#x20;       |

&#x20;       v

count

&#x20;       |

&#x20;       v

Optional resource

```



This allows application teams to control optional requirements without modifying the module implementation.



\---



\# 12. Module Output Flow



The optional EBS volume ID can be exposed using:



```hcl

output "application\_volume\_id" {

&#x20; value = var.application\_volume\_size != null ? aws\_ebs\_volume.application\[0].id : null

}

```



If no volume exists, the output safely returns:



```text

null

```



If a volume exists, Terraform returns its AWS volume ID.



\---



\# 13. Infrastructure Attachment vs OS Configuration



Terraform attaching an EBS volume only provides the block device to the EC2 instance.



It does not automatically perform:



\- Filesystem creation

\- Formatting

\- Mount-point creation

\- Persistent mounting

\- Application configuration



These belong to the operating-system/configuration layer.



```text

Terraform

&#x20;  |

&#x20;  v

Create and attach EBS

&#x20;  |

&#x20;  v

Operating System

&#x20;  |

&#x20;  +--> Format

&#x20;  +--> Mount

&#x20;  +--> Configure filesystem

```



\---



\# 14. Enterprise Module Design



Reusable modules should separate:



```text

Application choice

```



from:



```text

Organizational standard

```



For example:



Application-controlled:



```text

application\_volume\_size

```



Module-controlled:



```text

Volume type = gp3

Encryption  = enabled

AZ          = EC2 AZ

```



This creates reusable but governed infrastructure.



\---



\# 15. Common Mistakes



\## Mistake 1 - Assuming null prevents resource creation automatically



It does not.



Conditional logic such as `count` must use the null value.



\## Mistake 2 - Forgetting the count index



Incorrect:



```hcl

aws\_ebs\_volume.application.id

```



Correct:



```hcl

aws\_ebs\_volume.application\[0].id

```



\## Mistake 3 - Creating EBS in another AZ



The EBS volume must be in the same AZ as the EC2 instance.



\## Mistake 4 - Duplicating the AZ input



Deriving the AZ from the EC2 is cleaner and less error-prone.



\## Mistake 5 - Creating an attachment when no volume exists



The conditional logic for dependent optional resources should remain aligned.



\---



\# 16. Revision Sheet



Remember:



```text

null = optional requirement not supplied

```



Conditional expression:



```hcl

condition ? true\_value : false\_value

```



Conditional creation:



```hcl

count = condition ? 1 : 0

```



Count addressing:



```text

resource\[0]

```



EBS requirement:



```text

EC2 AZ = EBS AZ

```



Dependency:



```text

Reference

&#x20;  |

&#x20;  v

Implicit dependency

```



Complete flow:



```text

Application Requirement

&#x20;       |

&#x20;       v

Optional Variable

&#x20;       |

&#x20;       v

Conditional Expression

&#x20;       |

&#x20;       v

count

&#x20;  /          \\

&#x20; 0            1

&#x20; |            |

No resource   Create resource

```



\---



\# 17. Hands-on Lab



The concepts in this chapter are implemented in:



```text

labs/aws/05-conditional-ebs

```



The lab demonstrates both conditions:



```text

No application disk

```



and:



```text

100 GB application disk

```



using the same reusable EC2 module.



\---



\# 18. Chapter Summary



Conditional infrastructure allows one Terraform module to support multiple workload requirements without duplicating code.



`null` can represent the absence of an optional requirement, while conditional expressions and `count` control whether the associated infrastructure should exist.



Using resource references allows Terraform to automatically build dependencies such as EC2 -> EBS -> volume attachment.



These concepts form the foundation for more advanced Terraform patterns such as `for\_each`, collections, objects and multiple dynamic resources.

