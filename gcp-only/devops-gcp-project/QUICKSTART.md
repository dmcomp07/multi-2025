# Quick Start Guide

## Step 1: Install Dependencies (2 minutes)

```bash
bash scripts/00-install-all-dependencies.sh
```

Verify installation:
```bash
bash scripts/verify-installation.sh
```

## Step 2: Setup GCP (5 minutes)

```bash
bash scripts/01-setup-gcp-project.sh
```

## Step 3: Create Terraform Backend (2 minutes)

```bash
bash scripts/02-create-terraform-backend.sh
```

Note the bucket name, update it in:
- `terraform/environments/dev/backend.tf`
- `terraform/environments/staging/backend.tf`
- `terraform/environments/prod/backend.tf`

## Step 4: Deploy Infrastructure (45 minutes)

```bash
bash scripts/03-deploy-dev-environment.sh
```

This will:
- Create VPC and subnets
- Create GKE cluster
- Create Cloud SQL database
- Configure networking

## Step 5: Deploy Kubernetes (10 minutes)

```bash
bash kubernetes/apply.sh
```

## Step 6: Verify

```bash
kubectl get pods -n production
kubectl get svc -n production
```

## Next Steps

- See `docs/` for detailed documentation
- Check `tests/` for testing scripts
- Review `monitoring/` for observability setup

## Troubleshooting

Common issues? See `docs/TROUBLESHOOTING.md`
