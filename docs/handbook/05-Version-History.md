\# Version History



This file tracks major updates to the Cloud Engineering handbook and its associated learning journey.



\---



\## 2026-08-19 - Terraform Foundations and AWS Labs 01-04



\### Handbook



\- Established the initial handbook structure and Table of Contents.

\- Added Chapter 2 - Terraform Fundamentals.

\- Documented Infrastructure as Code and declarative infrastructure.

\- Documented the relationship between Terraform Configuration, Core, State and Providers.

\- Added resources and data sources.

\- Added variables, tfvars and outputs.

\- Added Terraform dependency graph concepts.

\- Added implicit and explicit dependencies.

\- Added Terraform State and configuration drift.

\- Added the Terraform workflow:

&#x20; - init

&#x20; - fmt

&#x20; - validate

&#x20; - plan

&#x20; - apply

&#x20; - destroy

\- Added Terraform plan interpretation and resource replacement concepts.

\- Added layered Terraform and AWS troubleshooting methodology.

\- Added enterprise considerations, common mistakes, interview questions and revision notes.



\### Hands-on Progress



Completed:



\- Terraform Lab 01 - Local File

\- AWS Lab 01 - S3 Bucket

\- AWS Lab 02 - EC2 Instance

\- AWS Lab 03 - Custom VPC

\- AWS Lab 04 - Reusable EC2 Module



\### Key Learning Milestones



\- Built AWS infrastructure using Terraform.

\- Used Terraform variables and tfvars to separate configuration from values.

\- Used data sources for dynamic AWS information such as AMIs.

\- Built VPC, subnet, Internet Gateway, route table and security group resources.

\- Deployed EC2 instances with user data.

\- Understood the difference between successful infrastructure provisioning and successful application configuration.

\- Built a reusable EC2 child module.

\- Understood root-to-child input flow and child-to-root output flow.

\- Practiced Terraform state inspection and drift concepts.

\- Troubleshot AWS API, networking, instance type and Free Tier eligibility issues.

\- Implemented Git hygiene for Terraform state, `.terraform` directories and tfvars.



\### Current Learning Position



The foundation phase is complete.



Next focus:



\*\*AWS Lab 05 - Conditional Infrastructure and Optional EBS Volumes\*\*



This lab will introduce:



\- Conditional expressions

\- `null`

\- `count`

\- Conditional resource creation

\- EBS volumes

\- Volume attachments

\- Availability Zone dependencies

