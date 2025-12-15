# GCP DevOps Project

Production-grade DevOps infrastructure on Google Cloud Platform.

## Quick Start

```bash
# 1. Install all dependencies
bash scripts/00-install-all-dependencies.sh

# 2. Setup GCP project
bash scripts/01-setup-gcp-project.sh

# 3. Create Terraform backend
bash scripts/02-create-terraform-backend.sh

# 4. Deploy dev environment
bash scripts/03-deploy-dev-environment.sh

# 5. Deploy Kubernetes
bash kubernetes/apply.sh

# 6. Verify everything
bash scripts/verify-installation.sh
```

## Project Structure

- `scripts/` - Setup and deployment scripts
- `terraform/` - Infrastructure as Code
- `kubernetes/` - Kubernetes manifests
- `monitoring/` - Prometheus & Grafana setup
- `ci-cd/` - Cloud Build pipeline
- `docs/` - Detailed documentation
- `tests/` - Testing scripts

## System Requirements

- Ubuntu 22.04 LTS
- 16+ CPU cores
- 64GB+ RAM
- 200GB+ disk space
- GCP project with billing enabled

## Timeline

- Phases 1-2: 15 minutes
- Phase 3: 10 minutes
- Phase 4: 20 minutes
- Phase 5: 30-45 minutes
- Phase 6-7: 20 minutes
- **Total: 2-3 hours**

## Documentation

See `docs/` folder for detailed guides.

## Support

Check `docs/TROUBLESHOOTING.md` for common issues.
