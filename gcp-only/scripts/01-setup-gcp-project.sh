#!/bin/bash
# Setup GCP project and enable APIs
# Run: bash scripts/01-setup-gcp-project.sh

set -e

PROJECT_ID="${1:-devops-hybrid-cloud}"
REGION="us-central1"
ZONE="us-central1-a"

echo "=========================================="
echo "Setting up GCP Project"
echo "=========================================="
echo "Project ID: $PROJECT_ID"
echo "Region: $REGION"
echo "Zone: $ZONE"
echo ""

# Create project
echo "Creating GCP project..."
gcloud projects create $PROJECT_ID --name="DevOps Hybrid Cloud" 2>/dev/null || echo "Project already exists"

# Set as default
gcloud config set project $PROJECT_ID
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

# Enable required APIs
echo "Enabling required APIs..."
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  cloudresourcemanager.googleapis.com \
  servicenetworking.googleapis.com \
  sqladmin.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com \
  cloudkms.googleapis.com \
  monitoring.googleapis.com \
  logging.googleapis.com \
  secretmanager.googleapis.com

# Create service account
echo "Creating service account..."
gcloud iam service-accounts create terraform-sa \
  --display-name="Terraform Service Account" 2>/dev/null || echo "Service account already exists"

# Grant permissions
echo "Granting permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member=serviceAccount:terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com \
  --role=roles/editor \
  --quiet 2>/dev/null || echo "Permission already granted"

# Create and download key
echo "Creating service account key..."
mkdir -p ~/.config/gcp
gcloud iam service-accounts keys create ~/.config/gcp/terraform-key.json \
  --iam-account=terraform-sa@${PROJECT_ID}.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcp/terraform-key.json

echo ""
echo "=========================================="
echo "✓ GCP project setup complete!"
echo "=========================================="
echo ""
echo "Next: bash scripts/02-create-terraform-backend.sh"
