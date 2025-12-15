# Architecture Overview

## Multi-Cloud Hybrid Architecture

### Cloud Distribution

```
┌─────────────────────────────────────────────────────────────┐
│                  HYBRID MULTI-CLOUD SETUP                   │
├──────────────────┬──────────────────┬───────────────────────┤
│   AWS Primary    │  Azure Secondary │  GCP (Kubernetes)    │
│                  │                  │                       │
│ - EC2 Instances  │ - VMs (VNets)    │ - GKE Clusters      │
│ - RDS Database   │ - Azure SQL DB   │ - Cloud Storage     │
│ - S3 Buckets     │ - Blob Storage   │                     │
│                  │                  │ (Multi-Zone HA)     │
└──────────────────┴──────────────────┴───────────────────────┘
```

## Multi-Tier Deployment Model

### Development
- Single GKE Node Pool (3 nodes)
- AWS RDS Development DB
- Auto-scale limit: 5 nodes
- Preemptible nodes enabled

### Staging
- Multi-Zone GKE (2 zones, 6 nodes)
- Read Replica Setup
- Full monitoring & logging
- Auto-scale limit: 15 nodes
- Mix of preemptible and reserved

### Production
- Multi-Zone GKE (3 zones, 9+ nodes)
- High-availability RDS (Multi-AZ)
- Global Load Balancing
- Disaster Recovery Setup
- Auto-scale limit: 30 nodes
- Reserved instances

## Data Flow

```
Git Commit
    ↓
Jenkins Pipeline (Build, Test, Push)
    ↓
Terraform (Infrastructure Auto-scale)
    ↓
Ansible (Node Setup & Hardening)
    ↓
Kubernetes (Deployment & Scaling)
    ↓
Prometheus + Grafana (Monitoring)
    ↓
N8N (Automation & Orchestration)
```

## Component Details

### Kubernetes (GKE)

**Node Pools:**
- General Purpose Pool: n1-standard-4 (4 vCPU, 15GB RAM)
- Memory Optimized Pool: n1-highmem-8 (8 vCPU, 52GB RAM)

**Features:**
- Horizontal Pod Autoscaling (HPA)
- Pod Disruption Budgets (PDB)
- Network Policies (deny-all default)
- Pod Security Policies

### Database (AWS RDS)

**Configuration:**
- PostgreSQL 15.4
- Multi-AZ in Production
- Automated backups (30 days retention)
- KMS encryption at rest
- CloudWatch logging

### Monitoring Stack

**Components:**
- Prometheus: Metrics collection & alerting
- Grafana: Visualization & dashboards
- AlertManager: Alert routing & notifications

**Metrics Collected:**
- Kubernetes cluster metrics
- Pod CPU/Memory usage
- Application metrics
- Database performance
- Network I/O

### CI/CD Pipeline

**Jenkins Workflow:**
1. Git push triggers build
2. Docker image build & push
3. Terraform updates infrastructure
4. Ansible configures nodes
5. Kubernetes deployment
6. Smoke tests validation

## Security Architecture

```
┌──────────────────────────────────────┐
│   External Request (HTTPS/TLS)       │
└──────────────────┬───────────────────┘
                   ↓
        ┌──────────────────────┐
        │ Ingress Controller   │
        │ (SSL Termination)    │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Service Mesh (Optional)
        │ (mTLS, Authorization)
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Network Policies     │
        │ (Deny-all default)   │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ Pod Security Policy  │
        │ (Non-root, read-only)
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │ RBAC (Least Privilege)
        │ (Service Accounts)   │
        └──────────────────────┘
```

## High Availability Features

1. **Multi-Zone Deployment**
   - GKE nodes distributed across zones
   - Pod anti-affinity rules

2. **Auto-Scaling**
   - Horizontal Pod Autoscaler (CPU/Memory)
   - Cluster autoscaler (nodes)

3. **Load Balancing**
   - Google Cloud Load Balancer
   - Health checks every 10 seconds

4. **Failover**
   - RDS Multi-AZ failover (< 2 minutes)
   - Pod auto-restart (< 30 seconds)
   - Node drain gracefully (30 second grace period)

## Performance Characteristics

- **Response Time**: < 500ms p95
- **Error Rate**: < 0.1%
- **Uptime SLA**: 99.95%
- **RTO**: < 1 hour
- **RPO**: < 15 minutes

## Disaster Recovery

### Backup Strategy
- Daily automated RDS snapshots
- 30-day retention for production
- Cross-region replication (AWS)

### Recovery Procedures
- Database: Manual restore from snapshot
- Applications: Kubernetes recreation from IaC
- Configuration: GitOps recovery

## Cost Optimization

- Preemptible nodes in non-prod (70% savings)
- Reserved instances in production
- Automatic cluster scaling (prevents over-provisioning)
- Resource quotas per namespace

## Monitoring & Alerting

### Key Dashboards
- Cluster health overview
- Pod resource usage
- Application performance
- Database metrics

### Critical Alerts
- CPU > 80% (Warning), > 95% (Critical)
- Memory > 85% (Warning), > 95% (Critical)
- Pod CrashLoopBackOff
- Node NotReady > 5 minutes
