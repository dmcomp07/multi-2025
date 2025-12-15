# Troubleshooting Guide

Common issues and their solutions.

## Installation Issues

### "Command not found" (terraform, kubectl, helm, etc.)

**Problem**: Tools are not installed or not in PATH.

**Solution**:
```bash
# Run installation script
bash scripts/00-install-all-dependencies.sh

# Verify installation
bash scripts/verify-installation.sh

# Check PATH
echo $PATH
```

### GCP Authentication Failed

**Problem**: `Error: Application default credentials not found`

**Solution**:
```bash
# Authenticate with gcloud
gcloud auth login

# Set project
gcloud config set project devops-hybrid-cloud

# Create service account credentials
gcloud iam service-accounts create terraform-sa
gcloud iam service-accounts keys create ~/.config/gcp/terraform-key.json \
  --iam-account=terraform-sa@<PROJECT_ID>.iam.gserviceaccount.com

# Set credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcp/terraform-key.json
```

### Permission Denied

**Problem**: Service account lacks required permissions.

**Solution**:
```bash
# Grant Editor role (recommended for initial setup)
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member=serviceAccount:terraform-sa@<PROJECT_ID>.iam.gserviceaccount.com \
  --role=roles/editor
```

## GCP Issues

### API Not Enabled

**Problem**: `Error: The ... API is not enabled`

**Solution**:
```bash
# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### Quota Exceeded

**Problem**: Quota limit for resource exceeded.

**Solution**:
```bash
# Check quotas
gcloud compute project-info describe --project <PROJECT_ID> \
  --format='table(quotas[].display_name,quotas[].metric,quotas[].limit)'

# Request quota increase
# Via GCP Console: IAM & Admin > Quotas
```

### Bucket Already Exists

**Problem**: GCS bucket name conflict (globally unique).

**Solution**: Use a different bucket name with random suffix:
```bash
BUCKET_NAME="devops-tf-state-${PROJECT_ID}-$RANDOM"
gsutil mb gs://$BUCKET_NAME
```

## Terraform Issues

### Terraform State Lock

**Problem**: Another operation is in progress.

**Solution**:
```bash
# List locks
terraform state list

# Force unlock (use carefully!)
terraform force-unlock <LOCK_ID>

# Or wait 10 minutes for lock to expire
```

### "No matching versions"

**Problem**: Provider version mismatch.

**Solution**:
```bash
# Upgrade providers
terraform init -upgrade

# Or specify version
terraform init -var="google_version=~> 5.0"
```

### "Conflicting configuration"

**Problem**: Variable conflicts in backend configuration.

**Solution**:
```bash
# Clear local state
rm -rf .terraform

# Reinitialize
terraform init
```

## Kubernetes Issues

### Cluster Not Ready

**Problem**: Nodes showing "NotReady" status.

**Solution**:
```bash
# Check node status
kubectl get nodes -o wide

# Describe node for issues
kubectl describe node <NODE_NAME>

# Check node logs
gcloud compute instances get-serial-port-output <INSTANCE_NAME>

# Wait 10-15 minutes for cluster initialization
watch -n 5 kubectl get nodes
```

### Pods Not Starting

**Problem**: Pods stuck in Pending, CrashLoopBackOff, etc.

**Solution**:
```bash
# Check pod status
kubectl get pods -n production

# Describe pod for error details
kubectl describe pod <POD_NAME> -n production

# View logs
kubectl logs <POD_NAME> -n production

# Check resource availability
kubectl describe nodes | grep -A 5 "Allocated resources"
```

### Service has No Endpoints

**Problem**: Service shows `<none>` for endpoints.

**Solution**:
```bash
# Check selector matching
kubectl get pods -n production --show-labels

# Verify service selector matches labels
kubectl describe svc app-service -n production

# Fix labels if needed
kubectl label pods <POD_NAME> -n production app=app --overwrite
```

### Network Connectivity Issues

**Problem**: Pods can't reach Cloud SQL or external services.

**Solution**:
```bash
# Check network policies
kubectl get networkpolicies -n production

# Test connectivity from pod
kubectl exec -it <POD_NAME> -n production -- bash
curl http://external-service.com

# Check firewall rules
gcloud compute firewall-rules list --filter="network:dev-vpc"

# Verify Cloud SQL private IP
gcloud sql instances describe dev-cloudsql --format='get(privateIpAddress)'
```

## Database Issues

### Can't Connect to Cloud SQL

**Problem**: Connection refused or timeout.

**Solution**:
```bash
# Get database IP
CLOUD_SQL_IP=$(gcloud sql instances describe dev-cloudsql \
  --format='get(privateIpAddress)')

# Test from pod
kubectl exec -it <POD_NAME> -n production -- \
  psql -h $CLOUD_SQL_IP -U app_user -d applicationdb

# Check Cloud SQL proxy
kubectl get pods -n production -l app=cloudsql-proxy
```

### Database Password Not Working

**Problem**: Authentication failed.

**Solution**:
```bash
# Get password from Terraform
cd terraform
terraform output -raw db_password

# Update Kubernetes secret
kubectl create secret generic db-credentials \
  --from-literal=username=app_user \
  --from-literal=password=<PASSWORD> \
  -n production \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart deployments
kubectl rollout restart deployment/app -n production
```

### Disk Space Full

**Problem**: Cloud SQL out of disk space.

**Solution**:
```bash
# Check disk usage
gcloud sql operations list --instance=dev-cloudsql

# Increase disk size
gcloud sql instances patch dev-cloudsql \
  --storage-size 100GB

# Monitor growth
gcloud monitoring time-series list \
  --filter='metric.type="cloudsql.googleapis.com/database/disk/bytes_used"'
```

## Monitoring Issues

### Prometheus Not Scraping Metrics

**Problem**: No data in Prometheus.

**Solution**:
```bash
# Check Prometheus targets
kubectl port-forward -n monitoring svc/prometheus 9090:90
# Visit http://localhost:9090/targets

# Check logs
kubectl logs -n monitoring -l app.kubernetes.io/name=prometheus

# Verify scrape configs
kubectl get configmap -n monitoring prometheus-server -o yaml
```

### Grafana Dashboards Not Loading

**Problem**: No data in Grafana dashboards.

**Solution**:
```bash
# Check data source
kubectl port-forward -n monitoring svc/grafana 3000:80
# Admin > Data Sources > Test Prometheus

# Verify Prometheus connectivity
kubectl exec -it -n monitoring <GRAFANA_POD> -- \
  curl http://prometheus:9090

# Check logs
kubectl logs -n monitoring -l app.kubernetes.io/name=grafana
```

## CI/CD Issues

### Cloud Build Failing

**Problem**: Build pipeline fails.

**Solution**:
```bash
# Check build logs
gcloud builds log <BUILD_ID> --limit=100

# Verify service account permissions
gcloud projects get-iam-policy <PROJECT_ID> \
  --flatten="bindings[].members" \
  --filter="bindings.members:cloud-builds@<PROJECT_ID>.iam.gserviceaccount.com"

# Grant required permissions
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member=serviceAccount:cloud-builds@<PROJECT_ID>.iam.gserviceaccount.com \
  --role=roles/container.developer
```

### Image Push Failing

**Problem**: Docker push to Container Registry fails.

**Solution**:
```bash
# Authenticate with Container Registry
gcloud auth configure-docker gcr.io

# Grant permissions
gcloud projects add-iam-policy-binding <PROJECT_ID> \
  --member=serviceAccount:cloud-builds@<PROJECT_ID>.iam.gserviceaccount.com \
  --role=roles/storage.admin
```

## Performance Issues

### High CPU/Memory Usage

**Problem**: Pods consuming excessive resources.

**Solution**:
```bash
# Check resource usage
kubectl top pods -n production

# Check limits
kubectl describe deployment app -n production | grep -A 5 "Limits"

# Adjust limits
kubectl set resources deployment app -n production \
  --limits=cpu=1000m,memory=1Gi \
  --requests=cpu=500m,memory=512Mi

# Check HPA status
kubectl get hpa -n production
kubectl describe hpa app-hpa -n production
```

### Slow Database Queries

**Problem**: Database performance degradation.

**Solution**:
```bash
# Enable slow query log
gcloud sql instances patch dev-cloudsql \
  --database-flags=slow_query_log=on,long_query_time=2

# Check logs
gcloud sql operations list --instance=dev-cloudsql

# Analyze query performance
# Via Cloud SQL console: Logs > Query Insights
```

## General Debugging

### Collect Diagnostics

```bash
# Cluster info
kubectl cluster-info dump --output-directory=./cluster-dump

# Describe all resources
kubectl describe all -A

# Get events
kubectl get events -A --sort-by='.lastTimestamp'

# Check resource limits
kubectl describe node

# Save for support
gcloud compute instances get-serial-port-output <INSTANCE> > instance-logs.txt
```

### Enable Debug Logging

```bash
# Terraform debug
export TF_LOG=DEBUG
terraform apply

# kubectl debug
kubectl -v=8 get pods

# gcloud debug
gcloud --verbose compute instances list
```

## Getting Help

1. Check this troubleshooting guide
2. Review logs: `kubectl logs`, `gcloud logging read`
3. Check GCP console for service status
4. Review Terraform state: `terraform show`
5. Ask on Stack Overflow (tag: gcp, kubernetes, terraform)
6. File GitHub issue with diagnostics

## Common Error Messages

| Error | Cause | Solution |
|-------|-------|----------|
| "Permission denied" | Insufficient IAM role | Grant Editor role |
| "Timeout" | Network/API issue | Wait and retry |
| "AlreadyExists" | Resource exists | Use different name |
| "NotFound" | Resource not found | Verify resource exists |
| "Conflict" | State conflict | Run `terraform refresh` |
| "Failed" | Generic error | Check logs with `-v` flag |
