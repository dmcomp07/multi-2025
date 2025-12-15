# Installation Guide

Complete step-by-step guide to set up the DevOps infrastructure.

## Prerequisites

### Local Machine
- Git installed
- Terraform >= 1.8
- gcloud CLI installed and authenticated
- kubectl installed
- Helm 3.x installed

### GCP Project
- Active GCP project
- Billing enabled
- Appropriate permissions (Editor role minimum)

### Cloud Instance (Ubuntu 22.04)
- 16+ CPU cores
- 64GB+ RAM
- 200GB+ disk space
- Internet access

## Installation Steps

### Step 1: Clone Repository

```bash
git clone https://github.com/dmcomp07/multi-2025/gcp-only.git
cd gcp-only
```

### Step 2: Install Dependencies (On Ubuntu Instance)

```bash
bash scripts/00-install-all-dependencies.sh
```

Verify installation:
```bash
bash scripts/verify-installation.sh
```

### Step 3: Setup GCP Project

```bash
bash scripts/01-setup-gcp-project.sh devops-hybrid-cloud
```

This script:
- Creates the GCP project
- Enables required APIs
- Creates service account
- Generates credentials

### Step 4: Create Terraform Backend

```bash
bash scripts/02-create-terraform-backend.sh devops-hybrid-cloud
```

Update backend configuration:
```bash
BUCKET_NAME=$(cat .bucket-name)
sed -i "s/REPLACE_WITH_BUCKET_NAME/$BUCKET_NAME/" terraform/environments/*/backend.tf
```

### Step 5: Customize Terraform Variables

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
gcp_project_id         = "your-project-id"
gcp_region             = "us-central1"
environment            = "dev"
cluster_name           = "dev-cluster"
cluster_node_count     = 3
min_node_count         = 1
max_node_count         = 5
machine_type           = "n1-standard-2"
cloudsql_instance_name = "dev-cloudsql"
cloudsql_tier          = "db-f1-micro"
```

### Step 6: Deploy Infrastructure

```bash
bash scripts/03-deploy-dev-environment.sh devops-hybrid-cloud
```

This takes approximately 45 minutes. Monitor the Terraform output.

### Step 7: Deploy Kubernetes Resources

```bash
bash kubernetes/apply.sh production
```

### Step 8: Verify Deployment

```bash
# Check cluster status
kubectl cluster-info
kubectl get nodes

# Check pods
kubectl get pods -n production
kubectl get svc -n production

# Check database
kubectl exec -it deployment/app -n production -- psql -h $DB_HOST -U app_user -d applicationdb
```

## Configuration

### Updating Cluster Size

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
cluster_node_count = 3      # Initial nodes
min_node_count     = 1      # Min for autoscaling
max_node_count     = 5      # Max for autoscaling
```

Then:
```bash
cd terraform
terraform plan -var-file="environments/dev/terraform.tfvars"
terraform apply -var-file="environments/dev/terraform.tfvars"
```

### Changing Machine Type

Edit machine type in `terraform/environments/dev/terraform.tfvars`:

```hcl
machine_type = "n1-standard-4"  # Change as needed
```

Available types:
- `n1-standard-1` through `n1-standard-4` (balanced)
- `n1-highmem-2` through `n1-highmem-8` (memory-optimized)
- `n1-highcpu-2` through `n1-highcpu-16` (compute-optimized)

### Database Configuration

Edit in `terraform/environments/dev/terraform.tfvars`:

```hcl
cloudsql_tier = "db-f1-micro"  # Free tier
# or
cloudsql_tier = "db-n1-standard-1"  # Standard tier
```

## Deployment Timeline

| Step | Duration |
|------|----------|
| Install dependencies | 15 min |
| Setup GCP project | 5 min |
| Create Terraform backend | 2 min |
| Deploy infrastructure | 45 min |
| Deploy Kubernetes | 10 min |
| Verify setup | 5 min |
| **Total** | **~80 minutes** |

## Accessing Resources

### Kubernetes Dashboard

```bash
kubectl proxy --port=8001
# Visit http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
```

### Grafana

```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
# Visit http://localhost:3000
# Default: admin / admin
```

### Prometheus

```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Visit http://localhost:9090
```

### Application

```bash
# Get external IP
kubectl get svc -n production

# Visit http://<EXTERNAL-IP>
```

## Troubleshooting

### GCP API Not Enabled

```bash
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable sqladmin.googleapis.com
```

### Terraform State Lock

If Terraform is locked:
```bash
terraform force-unlock <lock_id>
```

### Cluster not ready

Wait 10-15 minutes. Monitor:
```bash
watch -n 5 kubectl get nodes
watch -n 5 kubectl get pods -n production
```

### Cloud SQL Connection Issues

```bash
# Get Cloud SQL IP
gcloud sql instances describe dev-cloudsql --format='get(privateIpAddress)'

# Test connection
psql -h <IP> -U app_user -d applicationdb
```

## Security Hardening

### Enable Network Policies

```bash
kubectl apply -f kubernetes/network-policies.yaml
```

### Enable Pod Security Policies

```bash
kubectl apply -f kubernetes/pod-security-policies.yaml
```

### Audit Logging

```bash
gcloud logging sinks create k8s-audit-log \
  logging.googleapis.com/projects/<PROJECT>/logs/k8s-audit \
  --log-filter='resource.type="k8s_cluster"'
```

## Next Steps

1. Configure monitoring alerts
2. Setup CI/CD pipeline with Cloud Build
3. Configure backup policies
4. Implement cost monitoring
5. Setup disaster recovery procedures

## Support

For issues, check:
- `docs/TROUBLESHOOTING.md`
- `docs/SECURITY.md`
- GCP documentation
- Kubernetes documentation
