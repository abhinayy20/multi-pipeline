# Jenkins CI/CD Pipeline with Terraform

Automated infrastructure provisioning pipeline demonstrating CI/CD best practices with Jenkins multibranch pipelines and Infrastructure as Code.

## 📋 What This Project Does

This project automates AWS infrastructure deployment using Jenkins and Terraform. It demonstrates:

- **Automated Pipeline Triggering**: Webhook-based automatic builds on code push
- **Environment Management**: Branch-specific infrastructure configurations (dev, staging, prod)
- **Terraform Automation**: Infrastructure initialization, planning, and deployment
- **Approval Gates**: Manual approval step for production deployments
- **Secure Credential Handling**: Proper credential injection in CI/CD workflows

## 🏗️ Infrastructure Components

The Terraform code provisions a complete AWS environment:

- VPC with public subnet
- Internet Gateway and routing
- Security Groups (SSH, HTTP, HTTPS, custom ports)
- EC2 instances with automated configuration
- Elastic IP for persistent addressing
- Pre-configured web server (Nginx)

## 🎯 Pipeline Stages

1. **Checkout**: Retrieves code from GitHub
2. **Terraform Init**: Initializes Terraform backend and providers
3. **Variable Inspection**: Displays environment-specific configuration
4. **Terraform Plan**: Generates infrastructure execution plan
5. **Approval Gate**: Manual validation (conditional based on branch)
6. **Terraform Apply**: Provisions infrastructure (conditional)

## 📁 Project Structure

```
├── Jenkinsfile          # Pipeline definition
├── main.tf             # Infrastructure resources
├── variables.tf        # Input variables
├── outputs.tf          # Output values
├── dev.tfvars          # Development environment config
├── staging.tfvars      # Staging environment config
└── prod.tfvars         # Production environment config
```

## 🔄 Branch Strategy

- **dev**: Full automation with manual approval before apply
- **staging**: Plan-only, no automatic deployment
- **prod**: Plan-only, no automatic deployment

## 🛠️ Technologies Used

- Jenkins (Multibranch Pipeline)
- Terraform
- AWS (VPC, EC2, Security Groups)
- GitHub Webhooks
- Groovy (Pipeline scripting)
