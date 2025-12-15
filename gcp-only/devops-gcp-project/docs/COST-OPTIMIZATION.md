# Cost Optimization Guide

Strategies to reduce costs while maintaining reliability.

## Cost Breakdown

### Development Environment
- **GKE Cluster**: $30-50/month (preemptible nodes, auto-scaling)
- **Cloud SQL**: $5-10/month (db-f1-micro)
- **Storage**: $0-5/month
- **Total**: ~$50-70/month

### Staging Environment
- **GKE Cluster**: $100-150/month
- **Cloud SQL**: $20-30/month (db-n1-standard-1)
- **Storage**: $5-10/month
- **Total**: ~$150-200/month

### Production Environment
- **GKE Cluster**: $300-500/month (HA nodes, reserved)
- **Cloud SQL**: $100-150/month (db-n1-highmem-2 with HA)
- **Storage**: $20-50/month
- **Total**: ~$500-700/month

## Cost Reduction Strategies

### 1. Use Preemptible VMs (Dev/Staging)

Reduce compute costs by 70-80%:

```hcl
# terraform/gke.tf
preemptible = var.environment != "prod"  # Already enabled

# Preemptible node pricing:
# n1-standard-2: $0.30/hour → $0.10/hour (3x cheaper)
```

**Savings**: ~$100-200/month per environment

### 2. Right-Size Instances

Use appropriate machine types:

```hcl
# Development
machine_type = "n1-standard-2"      # Sufficient for dev

# Staging
machine_type = "n1-standard-2"      # Start here, scale if needed

# Production
machine_type = "n1-standard-4"      # Standard tier
# or
machine_type = "e2-standard-4"      # More cost-effective
```

**Savings**: ~$50-100/month by choosing right size

### 3. Optimize Node Count

Auto-scaling reduces idle nodes:

```hcl
# terraform/environments/dev/terraform.tfvars
cluster_node_count = 1              # Minimum for dev
min_node_count     = 1
max_node_count     = 3              # Limit max

# terraform/environments/staging/terraform.tfvars
cluster_node_count = 2
min_node_count     = 1
max_node_count     = 5

# terraform/environments/prod/terraform.tfvars
cluster_node_count = 3
min_node_count     = 3
max_node_count     = 10
```

**Savings**: ~$50-200/month by preventing over-provisioning

### 4. Use Committed Use Discounts (CUD)

For production workloads:

```bash
# 1-year CUD: ~25% discount
# 3-year CUD: ~52% discount

# Apply via GCP Console:
# Billing > Commitments > Purchase commitment
```

**Savings**: ~$150-250/month for 1-year CUD

### 5. Cloud SQL Optimization

```hcl
# Use shared-core for dev (db-f1-micro is free tier)
cloudsql_tier = "db-f1-micro"  # $0 (but limited)

# Scale for staging
cloudsql_tier = "db-n1-standard-1"  # $10-15/month

# Production with HA
cloudsql_tier = "db-n1-standard-2"  # With automatic failover
```

**Savings**: ~$50-100/month by right-sizing database

### 6. Storage Cost Optimization

```bash
# Enable storage optimization
gcloud sql instances patch dev-cloudsql \
  --database-flags=log_checkpoints=off

# Archive old backups
# Via GCP Console: Cloud SQL > Backups > Automatic backups
```

**Savings**: ~$10-20/month on storage

### 7. Network Optimization

```bash
# Minimize egress charges
# Keep services in same region (us-central1)

# Use Cloud CDN for static content
# Use Cloud NAT for egress optimization

# Estimated savings: ~$5-20/month
```

### 8. Monitoring Cost

```bash
# Reduce metric retention
# Adjust Prometheus scrape interval (currently 15s)

prometheus_scrape_interval = "30s"  # Double to save costs

# Estimated savings: ~$5-10/month
```

## Cost Monitoring

### Set Budget Alerts

```bash
# GCP Console > Billing > Budgets & alerts
# Create budget:
# - Amount: $500/month
# - Alerts at: 50%, 75%, 100%, 125%
```

### Monitor Costs

```bash
# View costs by resource
gcloud billing accounts list
gcloud compute instances list --format='table(name,machineType,zone)'

# Cost estimation
# GCP Console > Pricing calculator
# Estimate new configurations before deploying
```

### Cost Analysis Query

```bash
# SQL query for detailed breakdown
gcloud billing export create-table-export \
  --dataset=billing \
  --table-name=gcp_billing
```

## Comparison: Cost vs. Reliability

| Strategy | Dev Cost | Staging Cost | Prod Cost | Reliability |
|----------|----------|--------------|-----------|-------------|
| Current | $50 | $150 | $500 | ✓✓✓ |
| + Preemptible | $20 | $100 | $400 | ✓✓ |
| + CUD (prod) | $20 | $100 | $250 | ✓✓✓ |
| All optimizations | $20 | $80 | $200 | ✓✓✓ |

## Implementation Checklist

- [ ] Use preemptible nodes for dev/staging
- [ ] Right-size machine types
- [ ] Implement auto-scaling
- [ ] Purchase CUD for production
- [ ] Optimize Cloud SQL tier
- [ ] Implement storage lifecycle policies
- [ ] Enable Compute Engine commitments
- [ ] Monitor costs regularly
- [ ] Review and optimize quarterly

## Estimated Annual Savings

| Optimization | Savings |
|--------------|---------|
| Preemptible nodes | $1,200 |
| Right-sizing | $600 |
| CUD (3-year) | $2,400 |
| Storage optimization | $200 |
| Total | ~$4,400 |

## Advanced Cost Optimization

### Spot VMs (Beta)

For non-critical workloads:
```bash
# Enable Spot VMs (up to 90% cheaper)
gcloud container node-pools create spot-pool \
  --cluster=dev-cluster \
  --spot
```

### Workload Consolidation

Combine dev/staging clusters:
```bash
# Use namespaces instead of separate clusters
# Reduces cluster overhead by 50%
```

### Auto-scaling Policies

Fine-tune scaling behavior:
```yaml
# kubernetes/05-hpa.yaml
behavior:
  scaleUp:
    stabilizationWindowSeconds: 300
    policies:
    - type: Percent
      value: 50
      periodSeconds: 60
  scaleDown:
    stabilizationWindowSeconds: 300
    policies:
    - type: Percent
      value: 100
      periodSeconds: 120
```

## Resources

- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [Cost Management Best Practices](https://cloud.google.com/architecture/best-practices-for-managing-costs)
- [Committed Use Discounts](https://cloud.google.com/docs/cuds)
- [Preemptible VMs](https://cloud.google.com/compute/docs/instances/preemptible)

## Monthly Review

Perform monthly cost analysis:

```bash
# 1. Check current spend
gcloud billing accounts list

# 2. Review recommendations
# Via GCP Console > Billing > Recommendations

# 3. Adjust quotas/limits
# Via GCP Console > Quotas

# 4. Forecast next month
# Use Pricing Calculator with current usage
```
