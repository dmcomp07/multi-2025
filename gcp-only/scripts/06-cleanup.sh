#!/bin/bash
# Cleanup all resources
# Run: bash scripts/06-cleanup.sh

set -e

PROJECT_ID="${1:-devops-hybrid-cloud}"

echo "=========================================="
echo "WARNING: CLEANUP - This will destroy all resources!"
echo "=========================================="
echo "Project: $PROJECT_ID"
echo ""
echo "Press Ctrl+C to cancel or wait 10 seconds to continue..."
sleep 10

gcloud config set project $PROJECT_ID

# Destroy Terraform resources
cd terraform
echo "Destroying Terraform infrastructure..."
terraform destroy \
  -var-file="environments/dev/terraform.tfvars" \
  -auto-approve

cd ..

# Delete Kubernetes resources
echo "Deleting Kubernetes resources..."
kubectl delete all -A --all 2>/dev/null || echo "No resources to delete"

# Clean up GCS bucket
echo "Cleaning up GCS buckets..."
BUCKET_NAME=$(cat .bucket-name 2>/dev/null || echo "")
if [ ! -z "$BUCKET_NAME" ]; then
  gsutil -m rm -r gs://$BUCKET_NAME 2>/dev/null || echo "Bucket already deleted"
fi

echo ""
echo "=========================================="
echo "✓ Cleanup complete!"
echo "=========================================="
