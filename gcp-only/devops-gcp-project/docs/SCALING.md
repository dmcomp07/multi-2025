# Scaling Guide

How to scale the infrastructure as your needs grow.

## Horizontal Scaling (More Pods)

### Automatic Scaling

The Horizontal Pod Autoscaler (HPA) automatically scales pods based on metrics:

```yaml
# kubernetes/05-hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: app-hpa
  namespace: production
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Manual Scaling

```bash
# Scale deployment manually
kubectl scale deployment app -n production --replicas=5

# Monitor scaling
watch -n 2 'kubectl get pods -n production | grep app'

# Check HPA status
kubectl get hpa app-hpa -n production
kubectl describe hpa app-hpa -n production
```

## Vertical Scaling (Bigger Pods)

### Increase Pod Resources

```bash
# Edit deployment
kubectl edit deployment app -n production

# Update resource limits
resources:
  requests:
    cpu: 200m          # Increase from 100m
    memory: 256Mi      # Increase from 128Mi
  limits:
    cpu: 1000m         # Increase from 500m
    memory: 1Gi        # Increase from 512Mi
```

Or use kubectl set:

```bash
kubectl set resources deployment app -n production \
  --requests=cpu=200m,memory=256Mi \
  --limits=cpu=1000m,memory=1Gi
```

## Node Scaling

### Automatic Node Scaling

The cluster automatically scales nodes based on pod requirements:

```hcl
# terraform/environments/prod/terraform.tfvars
cluster_node_count = 9      # Initial nodes
min_node_count     = 6      # Minimum (for HA)
max_node_count     = 30     # Maximum
```

### Manual Node Scaling

```bash
# Update terraform configuration
cd terraform
vim environments/prod/terraform.tfvars
# Change min_node_count, max_node_count, cluster_node_count

# Apply changes
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

### Monitor Node Usage

```bash
# Check node resources
kubectl top nodes
kubectl describe nodes | grep -A 10 "Allocated resources"

# Watch scaling
watch -n 5 'kubectl get nodes'
```

## Database Scaling

### Cloud SQL Scaling

```bash
# Check current tier
gcloud sql instances describe prod-cloudsql --format='get(settings.tier)'

# Scale up
gcloud sql instances patch prod-cloudsql \
  --tier=db-n1-highmem-4

# Scale storage
gcloud sql instances patch prod-cloudsql \
  --storage-size 200GB

# Monitor
gcloud sql instances describe prod-cloudsql \
  --format='table(settings.tier,settings.storageAutoSize)'
```

### Connection Pooling

```yaml
# kubernetes/03-deployment.yaml
env:
- name: DB_POOL_SIZE
  value: "20"
- name: DB_MAX_IDLE_TIME
  value: "300"
```

## Cluster Scaling Strategies

### Development Environment (1-5 nodes)

```hcl
cluster_node_count = 1
min_node_count     = 1
max_node_count     = 3
machine_type       = "n1-standard-2"
```

**Use when**: Learning, testing, low traffic
**Cost**: ~$50/month

### Staging Environment (2-10 nodes)

```hcl
cluster_node_count = 2
min_node_count     = 2
max_node_count     = 10
machine_type       = "n1-standard-2"
```

**Use when**: Pre-production, performance testing
**Cost**: ~$150/month

### Production Environment (6-30 nodes)

```hcl
cluster_node_count = 6
min_node_count     = 6
max_node_count     = 30
machine_type       = "n1-standard-4"
```

**Use when**: Production traffic, HA required
**Cost**: ~$500/month

## Geographical Scaling

### Multi-Region Setup

```hcl
# terraform/environments/prod/terraform.tfvars
gcp_region = "us-central1"

# Additional regions (future):
# regions = ["us-central1", "us-east1", "europe-west1"]
```

### Future Multi-Region Implementation

```hcl
# Create cluster in additional region
resource "google_container_cluster" "us_east" {
  name     = "prod-us-east"
  location = "us-east1"
  # ... same configuration as primary
}

# Setup Cloud SQL replica
resource "google_sql_database_instance" "us_east" {
  name              = "prod-us-east"
  master_instance_name = google_sql_database_instance.main.name
}

# Setup Cross-region replication
resource "google_compute_network_peering" "us_central_to_us_east" {
  name       = "us-central-to-us-east"
  network    = google_compute_network.us_central.self_link
  peer_network = google_compute_network.us_east.self_link
}
```

## Load Distribution

### Configure Load Balancer

```bash
# GCP automatically creates load balancer for Service type LoadBalancer
# View load balancer
gcloud compute forwarding-rules list

# Get external IP
kubectl get svc app-service -n production -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

### Session Affinity

```yaml
# kubernetes/04-service.yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 10800
```

## Scaling Decision Matrix

| Metric | Action | Threshold |
|--------|--------|-----------|
| CPU | Scale pods → Scale nodes | >70% → >80% |
| Memory | Scale pods → Scale nodes | >80% → >80% |
| Latency | Scale pods → Scale nodes | >1s → >2s |
| Error Rate | Investigate → Scale | >1% → >5% |
| Requests/sec | Add pods | >1000 |

## Testing Scaling

### Load Testing

```bash
# Run load test
bash tests/load-tests.sh

# Monitor scaling in real-time
watch -n 2 'kubectl get hpa,pods -n production'
```

### Stress Testing

```bash
# Use Apache Bench
ab -n 10000 -c 100 http://<EXTERNAL_IP>/

# Use hey
hey -n 10000 -c 100 http://<EXTERNAL_IP>/

# Monitor metrics
kubectl top pods -n production
```

## Scaling Checklist

- [ ] Monitor current resource usage
- [ ] Identify bottleneck (CPU/Memory/Network)
- [ ] Update Terraform configuration
- [ ] Plan scaling changes
- [ ] Apply during low-traffic window
- [ ] Monitor new metrics
- [ ] Verify performance improvement
- [ ] Document scaling event

## Performance Benchmarks

### Development (3 nodes, 2GB pods)
- **Throughput**: 100-500 req/s
- **Latency**: 50-200ms p99
- **Pod startup**: 5-10s

### Staging (6 nodes, 4GB pods)
- **Throughput**: 500-2000 req/s
- **Latency**: 20-100ms p99
- **Pod startup**: 3-8s

### Production (9+ nodes, variable pods)
- **Throughput**: 2000-10000+ req/s
- **Latency**: 10-50ms p99
- **Pod startup**: 2-5s

## Cost Impact of Scaling

| Environment | Nodes | Cost/Month |
|-------------|-------|-----------|
| Dev (current) | 3 | $50 |
| Dev (scaled) | 5 | $85 |
| Staging (current) | 6 | $150 |
| Staging (scaled) | 10 | $250 |
| Prod (current) | 9 | $500 |
| Prod (scaled) | 30 | $1500 |

## Optimization During Growth

1. **Monitor continuously** - Use Prometheus/Grafana
2. **Set appropriate limits** - Prevent runaway costs
3. **Use auto-scaling** - Automatic adjustment
4. **Right-size resources** - Don't over-provision
5. **Review quarterly** - Adjust based on trends

## Advanced Scaling Topics

### Pod Disruption Budgets

```yaml
# kubernetes/06-pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2              # Keep 2 pods during disruptions
  selector:
    matchLabels:
      app: app
```

### Descheduler

Optimize node utilization:

```bash
helm install descheduler descheduler/descheduler \
  --set policy.kind=priority \
  -n kube-system
```

### Cluster Autoscaler Configuration

```bash
# View autoscaler status
kubectl describe configmap cluster-autoscaler-status -n kube-system

# Fine-tune settings
gcloud container clusters update prod-cluster \
  --enable-autoscaling \
  --min-nodes=6 \
  --max-nodes=30
```

## Resources

- [GKE Scaling Documentation](https://cloud.google.com/kubernetes-engine/docs/concepts/horizontalpodautoscaler)
- [Cloud SQL Scaling](https://cloud.google.com/sql/docs/postgres/manage-instances)
- [Kubernetes Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Performance Best Practices](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-metrics-pipeline/)
