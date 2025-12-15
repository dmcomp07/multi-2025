#!/bin/bash
# Deploy staging environment
# Run: bash scripts/04-deploy-staging-environment.sh

set -e

PROJECT_ID="${1:-devops-hybrid-cloud}"
ENVIRONMENT="staging"

echo "=========================================="
echo "Deploying $ENVIRONMENT Environment"
echo "=========================================="

gcloud config set project $PROJECT_ID

# Initialize Terraform
cd terraform
echo "Initializing Terraform..."
terraform init

# Validate
echo "Validating Terraform..."
terraform validate

# Plan
echo "Planning infrastructure..."
terraform plan \
  -var-file="environments/${ENVIRONMENT}/terraform.tfvars" \
  -out=${ENVIRONMENT}.tfplan

# Apply
echo ""
echo "Ready to apply. Press Enter to continue or Ctrl+C to cancel..."
read

echo "Applying infrastructure..."
terraform apply ${ENVIRONMENT}.tfplan

# Get cluster credentials
echo ""
echo "Getting cluster credentials..."
gcloud container clusters get-credentials ${ENVIRONMENT}-cluster --region us-central1

# Verify
echo ""
echo "Verifying cluster..."
kubectl cluster-info
kubectl get nodes

cd ..

echo ""
echo "=========================================="
echo "✓ Staging environment deployed!"
echo "=========================================="
