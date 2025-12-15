#!/bin/bash
# This script installs ALL required tools on Ubuntu 22.04 LTS
# Run: bash scripts/00-install-all-dependencies.sh

set -e

echo "=========================================="
echo "Installing DevOps Dependencies"
echo "=========================================="

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install base tools
sudo apt-get install -y \
  curl \
  wget \
  git \
  unzip \
  jq \
  build-essential \
  openssl \
  dnsutils \
  iputils-ping \
  net-tools \
  htop \
  vim \
  nano

# Install Terraform
echo "Installing Terraform..."
TERRAFORM_VERSION="1.8.0"
cd /tmp
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# Install Helm
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ${USER}
rm get-docker.sh

# Install gcloud (verify it's already installed)
echo "Verifying gcloud CLI..."
gcloud --version || echo "Please install Google Cloud SDK"

# Install additional useful tools
echo "Installing additional tools..."
sudo apt-get install -y \
  google-cloud-cli-gke-gcloud-auth-plugin \
  postgresql-client

# Create necessary directories
mkdir -p ~/.kube
mkdir -p ~/.config/gcloud

# Verify installations
echo ""
echo "=========================================="
echo "Verification"
echo "=========================================="
echo "Terraform:"
terraform -version
echo ""
echo "kubectl:"
kubectl version --client
echo ""
echo "Helm:"
helm version
echo ""
echo "Docker:"
docker --version
echo ""
echo "gcloud:"
gcloud --version
echo ""
echo "=========================================="
echo "✓ All tools installed successfully!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. bash scripts/01-setup-gcp-project.sh"
echo "2. bash scripts/02-create-terraform-backend.sh"
echo "3. bash scripts/03-deploy-dev-environment.sh"
