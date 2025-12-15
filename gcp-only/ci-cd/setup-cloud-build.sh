#!/bin/bash
# Setup Cloud Build pipeline
# Run: bash ci-cd/setup-cloud-build.sh

set -e

PROJECT_ID="${1:-devops-hybrid-cloud}"
REPO_NAME="${2:-devops-gcp-project}"
BRANCH="${3:-main}"

echo "=========================================="
echo "Setting up Cloud Build"
echo "=========================================="
echo "Project: $PROJECT_ID"
echo "Repository: $REPO_NAME"
echo "Branch: $BRANCH"
echo ""

gcloud config set project $PROJECT_ID

# Enable Cloud Build API
echo "Enabling Cloud Build API..."
gcloud services enable cloudbuild.googleapis.com

# Connect GitHub repository
echo "Connecting repository..."
gcloud builds connect --repository-name=$REPO_NAME \
  --repository-owner=$(git config user.name) \
  --branch-pattern="^${BRANCH}$" 2>/dev/null || echo "Repository already connected"

# Create build trigger
echo "Creating build trigger..."
gcloud builds triggers create github \
  --repo-name=$REPO_NAME \
  --repo-owner=$(git config user.name) \
  --branch-pattern="^${BRANCH}$" \
  --build-config=ci-cd/cloudbuild.yaml \
  --name="deploy-${BRANCH}" 2>/dev/null || echo "Trigger already exists"

echo ""
echo "=========================================="
echo "✓ Cloud Build setup complete!"
echo "=========================================="
echo ""
echo "Triggers created. Commits to $BRANCH will trigger builds."
