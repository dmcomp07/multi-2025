# CI/CD Pipeline

This directory contains CI/CD pipeline configuration for Cloud Build.

## Contents

- `cloudbuild.yaml` - Cloud Build pipeline definition
- `Dockerfile` - Sample application container
- `setup-cloud-build.sh` - Setup script

## Setup

```bash
# Configure Cloud Build
bash setup-cloud-build.sh

# Push code to trigger builds
git add .
git commit -m "Update code"
git push origin main
```

## Pipeline Stages

1. **Build** - Build Docker image
2. **Test** - Run tests
3. **Push** - Push to Container Registry
4. **Deploy** - Deploy to GKE

## Customization

Update:
- Image registry paths
- Build steps and commands
- Deployment targets
- Environment variables
