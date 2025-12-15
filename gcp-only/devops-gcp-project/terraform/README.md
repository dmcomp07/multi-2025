# GCP Terraform Configuration

This directory contains all Terraform configurations for the GCP DevOps infrastructure.

## Structure

- `main.tf` - Provider and backend configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `gcp-network.tf` - VPC and networking resources
- `gke.tf` - GKE cluster configuration
- `cloudsql.tf` - Cloud SQL database configuration
- `iam.tf` - IAM roles and service accounts

## Environments

Each environment (dev, staging, prod) has:
- `terraform.tfvars` - Environment-specific variables
- `backend.tf` - Backend configuration for state storage

## Usage

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan changes
terraform plan -var-file="environments/dev/terraform.tfvars"

# Apply changes
terraform apply -var-file="environments/dev/terraform.tfvars"

# Destroy resources
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

## Required Variables

Update `terraform/environments/ENV/terraform.tfvars` with your values:
- `gcp_project_id` - Your GCP project ID
- `gcp_region` - GCP region (default: us-central1)
- `cluster_name` - Name for the GKE cluster
- `machine_type` - Node machine type
- Node count settings (min, max, initial)

## State Management

Terraform state is stored in Google Cloud Storage (GCS):
- Backend bucket is created by `scripts/02-create-terraform-backend.sh`
- State files are versioned and locked
- Each environment has its own state prefix
