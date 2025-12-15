terraform {
  required_version = ">= 1.8"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

provider "google-beta" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

locals {
  environment = var.environment
  common_labels = {
    Environment = local.environment
    Project     = "devops-gcp"
    ManagedBy   = "Terraform"
  }
}
