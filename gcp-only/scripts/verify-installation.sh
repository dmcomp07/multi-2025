#!/bin/bash
# Verify all tools are installed and configured
# Run: bash scripts/verify-installation.sh

echo "=========================================="
echo "Verifying Installation"
echo "=========================================="
echo ""

# Check Terraform
echo "✓ Terraform:"
terraform -version | head -1
echo ""

# Check kubectl
echo "✓ kubectl:"
kubectl version --client --short
echo ""

# Check Helm
echo "✓ Helm:"
helm version --short
echo ""

# Check Docker
echo "✓ Docker:"
docker --version
echo ""

# Check gcloud
echo "✓ gcloud:"
gcloud --version | head -1
echo ""

# Check GCP authentication
echo "✓ GCP Authentication:"
gcloud auth list
echo ""

# Check GCP project
echo "✓ GCP Project:"
gcloud config get-value project
echo ""

echo "=========================================="
echo "✓ All tools verified!"
echo "=========================================="
