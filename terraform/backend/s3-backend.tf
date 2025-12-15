# Terraform backend configuration for remote state management
terraform {
  backend "s3" {
    bucket         = "devops-hybrid-cloud-tfstate"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}

# Note: Backend configuration can also be set via backend config file:
# terraform init -backend-config="bucket=YOUR_BUCKET" -backend-config="key=YOUR_KEY"
