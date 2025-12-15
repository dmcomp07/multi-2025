# Quick Start Guide

## 5-Minute Setup

### Prerequisites
```bash
terraform >= 1.8
ansible >= 2.14
kubectl >= 1.28
docker >= 24.0
gcloud CLI
aws CLI v2
azure CLI
```

## Step 1: Clone Repository
```bash
git clone https://github.com/yourorg/devops-hybrid-cloud.git
cd devops-hybrid-cloud
```

## Step 2: Setup Cloud Credentials
```bash
# GCP
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/terraform-key.json"

# AWS
aws configure --profile devops

# Azure
az login
```

## Step 3: Deploy Infrastructure
```bash
cd terraform
terraform init
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

## Step 4: Configure Kubernetes
```bash
gcloud container clusters get-credentials hybrid-cloud-cluster-prod \
  --region us-central1 --project devops-hybrid-cloud
```

## Step 5: Deploy Applications
```bash
kubectl apply -f ../kubernetes/base/
```

## Common Commands

### Terraform
```bash
# Plan
terraform plan -var-file="environments/prod/terraform.tfvars"

# Apply
terraform apply -var-file="environments/prod/terraform.tfvars"

# Destroy
terraform destroy -var-file="environments/prod/terraform.tfvars"
```

### Kubernetes
```bash
# View deployments
kubectl get deployments -n production

# Check pods
kubectl get pods -n production

# View logs
kubectl logs deployment/hybrid-app -n production

# Scale
kubectl scale deployment hybrid-app --replicas=20 -n production

# Port forward
kubectl port-forward svc/hybrid-app 8080:80 -n production
```

### Docker
```bash
# Build
docker build -t devops-hybrid-app:v1 docker/

# Run
docker-compose -f docker/docker-compose.yml up -d

# Stop
docker-compose -f docker/docker-compose.yml down
```

### Monitoring
```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
```

## Directory Structure

```
├── terraform/          # Infrastructure as Code
├── kubernetes/         # Container orchestration
├── ansible/           # Configuration management
├── docker/            # Container images
├── monitoring/        # Metrics & observability
├── tests/             # Testing scripts
├── .github/workflows/ # CI/CD pipelines
└── docs/              # Documentation
```

## Environment Variables

```bash
# GCP
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/key.json
export GCP_PROJECT=devops-hybrid-cloud
export GCP_REGION=us-central1

# AWS
export AWS_PROFILE=devops
export AWS_REGION=us-east-1

# Kubernetes
export KUBECONFIG=~/.kube/config
```

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
```

### Image pull errors
```bash
kubectl create secret docker-registry gcr-secret \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat /path/to/key.json)" \
  -n production
```

### Database connectivity
```bash
kubectl exec -it <pod> -n production -- bash
psql -h $DB_HOST -U $DB_USER -d $DB_NAME
```

## Next Steps

1. Read [ARCHITECTURE.md](ARCHITECTURE.md) for architecture details
2. Review [SECURITY.md](SECURITY.md) for security setup
3. Check [MONITORING.md](MONITORING.md) for monitoring setup
4. See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues
