# Table of Contents

## Part I - Cloud Engineering Foundations

### Chapter 1 - From Traditional Infrastructure to Cloud Engineering
- Infrastructure Engineering vs Cloud Engineering
- What Changes in the Cloud
- Infrastructure as Code
- Declarative Infrastructure
- Desired State
- Idempotency
- Cloud Engineering Toolchain
- Thinking Like a Cloud Architect

### Chapter 2 - Terraform Fundamentals
- What is Terraform?
- Infrastructure as Code
- Declarative vs Imperative Configuration
- Terraform Configuration Files
- Providers
- Resources
- Variables
- Variable Values
- Outputs
- Terraform Workflow
  - terraform init
  - terraform fmt
  - terraform validate
  - terraform plan
  - terraform apply
  - terraform destroy
- Terraform State
- Configuration Drift
- Terraform Core vs State vs Provider
- Dependency Graph
- Implicit and Explicit Dependencies
- Common Terraform Mistakes
- Terraform Interview Questions
- Revision Sheet

Hands-on Lab:
- Terraform Local File

---

## Part II - AWS Infrastructure with Terraform

### Chapter 3 - AWS Foundations for Infrastructure Engineers
- AWS Regions
- Availability Zones
- AWS Accounts
- IAM Fundamentals
- AWS CLI
- AWS Authentication
- AWS Provider Authentication
- Resource Naming
- Tagging Strategy
- AWS Shared Responsibility Model

### Chapter 4 - AWS Storage with Terraform
- Amazon S3
- Buckets and Objects
- S3 Architecture
- Creating S3 Resources with Terraform
- Variables and Outputs
- Provider Configuration
- Tags
- Terraform State with AWS Resources
- Enterprise Storage Considerations

Hands-on Lab:
- AWS Lab 01 - S3 Bucket

### Chapter 5 - Amazon EC2 with Terraform
- EC2 Architecture
- AMIs
- Instance Types
- EBS Root Volumes
- Security Groups
- Public and Private IP Addresses
- EC2 Data Sources
- Dynamic AMI Discovery
- Risks of most_recent = true
- EC2 User Data
- cloud-init
- Terraform Success vs Application Success
- EC2 Troubleshooting

Hands-on Lab:
- AWS Lab 02 - EC2 Instance

### Chapter 6 - AWS Networking Fundamentals
- VPC
- CIDR and Subnetting
- Public vs Private Subnets
- Internet Gateway
- Route Tables
- Route Table Associations
- Default Routes
- Security Groups
- Routing vs Security
- Public IP Assignment
- Dependency Graph in AWS Networking
- Troubleshooting Network Connectivity

Hands-on Lab:
- AWS Lab 03 - Custom VPC

### Chapter 7 - Reusable Terraform Modules
- Why Modules?
- Root Modules
- Child Modules
- Module Inputs
- Module Outputs
- Variable Flow
- Output Flow
- Reusable EC2 Module
- Application Requirements vs Organizational Standards
- Mandatory vs Optional Configuration
- EBS Encryption Standards
- Optional User Data
- Module Design Principles
- Module Dependency Management
- Troubleshooting Modules

Hands-on Lab:
- AWS Lab 04 - Reusable EC2 Module

---

## Part III - Intermediate Terraform

### Chapter 8 - Conditional Infrastructure
- Conditional Expressions
- null
- count
- Conditional Resource Creation
- Optional Resources
- Optional EBS Volumes
- Resource Attachments
- Availability Zone Dependencies

Hands-on Lab:
- AWS Lab 05 - EC2 with Optional EBS Volume

### Chapter 9 - Terraform Collections and Dynamic Infrastructure
- Lists
- Sets
- Maps
- Objects
- for Expressions
- for_each
- Multiple Resource Creation
- Multiple EBS Volumes
- Designing Flexible Module Inputs

### Chapter 10 - Terraform State for Teams
- Local State Limitations
- Remote State
- State Locking
- S3 Backend
- State Security
- State Recovery
- State Commands
- Importing Existing Infrastructure
- Moving Resources
- Enterprise State Management

### Chapter 11 - Production Terraform Module Design
- Module Interfaces
- Input Validation
- Optional Attributes
- locals
- Naming Standards
- Tagging Standards
- Security Controls
- Versioning Modules
- Module Composition
- Environment Separation
- Development vs Production Design

---

## Part IV - AWS Architecture

### Chapter 12 - Production VPC Design
- Multi-AZ Architecture
- Public and Private Subnets
- NAT Gateway
- Route Design
- Network ACLs
- VPC Endpoints
- DNS
- Highly Available Network Architecture

### Chapter 13 - Compute Architecture
- EC2 Design
- Launch Templates
- Auto Scaling Groups
- Load Balancers
- Health Checks
- Stateless Applications
- Scaling Patterns

### Chapter 14 - AWS Storage Architecture
- S3
- EBS
- EFS
- FSx
- Storage Selection
- Performance
- Availability
- Backup
- Replication
- Cost Optimization

### Chapter 15 - AWS Security and IAM
- Users
- Groups
- Roles
- Policies
- Least Privilege
- Instance Profiles
- Secrets
- KMS
- Security Groups
- Cloud Security Design

---

## Part V - Linux and Automation

### Chapter 16 - Linux for Cloud Engineers
- Linux Fundamentals
- Filesystems
- Processes
- Services
- systemd
- Networking
- Package Management
- Logs
- SSH
- Troubleshooting

### Chapter 17 - Python for Cloud Engineering
- Python Fundamentals
- Files and JSON
- APIs
- AWS Automation
- Infrastructure Automation
- Error Handling

### Chapter 18 - Configuration Management
- Configuration Management Concepts
- Ansible
- Inventories
- Playbooks
- Roles
- Terraform vs Ansible
- Infrastructure Provisioning vs Configuration Management

---

## Part VI - Containers and Kubernetes

### Chapter 19 - Containers and Docker
- Containers vs Virtual Machines
- Images
- Containers
- Dockerfiles
- Networking
- Volumes
- Registries

### Chapter 20 - Kubernetes Fundamentals
- Kubernetes Architecture
- Pods
- Deployments
- Services
- ConfigMaps
- Secrets
- Storage
- Networking

### Chapter 21 - Kubernetes for Infrastructure Engineers
- Persistent Storage
- CSI
- Load Balancing
- Scaling
- Availability
- Backup and Recovery
- Troubleshooting

---

## Part VII - DevOps and CI/CD

### Chapter 22 - Git for Infrastructure Engineers
- Repositories
- Commits
- Branches
- Pull Requests
- .gitignore
- Infrastructure Code Management

### Chapter 23 - CI/CD Fundamentals
- Continuous Integration
- Continuous Delivery
- Pipeline Architecture
- Infrastructure Pipelines
- Testing Terraform

### Chapter 24 - GitHub Actions
- Workflow Files
- Jobs
- Steps
- Secrets
- Terraform Pipelines
- Automated Validation and Deployment

---

## Part VIII - Observability and Operations

### Chapter 25 - Cloud Monitoring
- Metrics
- Logs
- Events
- Alerts
- CloudWatch
- Infrastructure Monitoring
- Application Monitoring

### Chapter 26 - Cloud Troubleshooting
- Layered Troubleshooting
- Terraform Errors
- Provider Errors
- AWS API Errors
- DNS
- IAM
- Capacity
- Networking
- Operating System
- Application

---

## Part IX - AI Engineering and AIOps

### Chapter 27 - AI Fundamentals for Infrastructure Engineers
- AI and Machine Learning
- Generative AI
- Large Language Models
- Agents
- APIs
- Enterprise AI

### Chapter 28 - AIOps
- Infrastructure Telemetry
- Event Correlation
- Anomaly Detection
- Predictive Operations
- Automated Remediation
- Human-in-the-Loop Operations

### Chapter 29 - Building an Infrastructure AI Agent
- Collecting Infrastructure Data
- API Integration
- Normalizing Events
- Failure Analysis
- Capacity Forecasting
- L1/L2 Automation
- Guardrails

---

## Part X - Cloud Architecture

### Chapter 30 - Thinking Like a Cloud Architect
- Requirements
- Constraints
- Availability
- Scalability
- Security
- Performance
- Operations
- Cost

### Chapter 31 - Architecture Patterns
- High Availability
- Disaster Recovery
- Backup
- Multi-AZ
- Multi-Region
- Hybrid Cloud
- Migration Patterns

### Chapter 32 - Enterprise Cloud Architecture Case Study
- Requirements Gathering
- Network Architecture
- Compute
- Storage
- Security
- Backup
- Monitoring
- Automation
- Cost
- Architecture Decisions

---

## Appendices

### Appendix A - Terraform Command Reference
### Appendix B - AWS CLI Command Reference
### Appendix C - Troubleshooting Reference
### Appendix D - Interview Questions
### Appendix E - Architecture Checklists
### Appendix F - Lab Index