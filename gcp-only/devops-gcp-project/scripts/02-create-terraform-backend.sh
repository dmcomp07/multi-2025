#!/bin/bash
# Create GCS bucket for Terraform state
# Run: bash scripts/02-create-terraform-backend.sh

set -e

PROJECT_ID="${1:-devops-hybrid-cloud}"
REGION="us-central1"
BUCKET_NAME="devops-tf-state-${PROJECT_ID}-${RANDOM}"

echo "=========================================="
echo "Creating Terraform Backend"
echo "=========================================="
echo "Bucket: $BUCKET_NAME"
echo ""

gcloud config set project $PROJECT_ID

# Create GCS bucket
echo "Creating GCS bucket..."
gsutil mb -p $PROJECT_ID -l $REGION gs://$BUCKET_NAME

# Enable versioning
echo "Enabling versioning..."
gsutil versioning set on gs://$BUCKET_NAME

# Create DynamoDB equivalent (GCS bucket lock)
echo "Bucket created successfully"

# Save bucket name to file
echo $BUCKET_NAME > .bucket-name

echo ""
echo "=========================================="
echo "✓ Terraform backend created!"
echo "=========================================="
echo "Bucket name: $BUCKET_NAME"
echo ""
echo "Update terraform/environments/*/backend.tf with:"
echo "bucket = \"$BUCKET_NAME\""
echo ""
echo "Next: bash scripts/03-deploy-dev-environment.sh"
