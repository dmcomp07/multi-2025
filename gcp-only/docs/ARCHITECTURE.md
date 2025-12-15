# Architecture

## System Overview

This project implements a multi-tier DevOps infrastructure on Google Cloud Platform (GCP) using:

- **GKE** (Google Kubernetes Engine) - Container orchestration
- **Cloud SQL** - Managed PostgreSQL database
- **VPC Networks** - Private networking with security
- **Cloud Build** - CI/CD pipeline
- **Monitoring Stack** - Prometheus + Grafana

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Google Cloud Platform                 │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────────────────────────────────────┐  │
│  │              VPC Network (us-central1)           │  │
│  │                                                   │  │
│  │  ┌──────────────────────────────────────────┐   │  │
│  │  │         GKE Cluster                      │   │  │
│  │  │ ┌─────────────────────────────────────┐ │   │  │
│  │  │ │  Kubernetes Namespace: production  │ │   │  │
│  │  │ ├─────────────────────────────────────┤ │   │  │
│  │  │ │ ┌─────────┐  ┌─────────┐          │ │   │  │
│  │  │ │ │ App Pod │  │ App Pod │  ...     │ │   │  │
│  │  │ │ └────┬────┘  └────┬────┘          │ │   │  │
│  │  │ │      └──────┬─────┘               │ │   │  │
│  │  │ │          [Service]                │ │   │  │
│  │  │ │              │                    │ │   │  │
│  │  │ └──────────────┼────────────────────┘ │   │  │
│  │  │                │                      │   │  │
│  │  └────────────────┼──────────────────────┘   │  │
│  │                   │                          │  │
│  │  ┌────────────────┼──────────────────────┐   │  │
│  │  │  Cloud SQL Instance (PostgreSQL)      │   │  │
│  │  │  - Private IP in VPC                 │   │  │
│  │  │  - Automated backups                 │   │  │
│  │  │  - Multi-AZ for HA                   │   │  │
│  │  └────────────────────────────────────┘   │  │
│  │                                            │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ┌──────────────────────────────────────────┐   │
│  │     Monitoring Stack (Prometheus +       │   │
│  │              Grafana)                    │   │
│  │  - Metrics collection                   │   │
│  │  - Alerting                             │   │
│  │  - Dashboards                           │   │
│  └──────────────────────────────────────────┘   │
│                                                  │
└─────────────────────────────────────────────────┘
```

## Components

### 1. GKE Cluster
- **Location**: us-central1 region
- **Nodes**: Auto-scaling pool (min/max configurable)
- **Features**:
  - Workload Identity for secure authentication
  - Network policies for security
  - Auto-repair and auto-upgrade
  - Preemptible nodes for cost optimization (dev/staging)

### 2. Cloud SQL
- **Database**: PostgreSQL 15
- **Network**: Private IP only (secure)
- **High Availability**: Multi-zone replication
- **Backups**: Automated daily backups
- **Configuration**: Environment-specific tiers

### 3. VPC Network
- **CIDR Ranges**:
  - Dev: 10.1.0.0/24
  - Staging: 10.2.0.0/24
  - Prod: 10.3.0.0/24
- **Security**: Firewall rules for internal and external traffic
- **Private Connectivity**: Service Networking for Cloud SQL

### 4. Kubernetes Namespaces
- `production` - Production workloads
- `staging` - Staging environment
- `development` - Development environment
- `monitoring` - Observability stack

## Data Flow

1. **User Request** → Cloud Load Balancer (external IP)
2. **Load Balancer** → GKE Service (internal IP)
3. **Service** → Application Pods (replicas)
4. **Application** → Cloud SQL Database (private IP)
5. **Metrics** → Prometheus (collection)
6. **Dashboards** → Grafana (visualization)

## Security Layers

1. **Network Security**:
   - VPC isolation
   - Firewall rules
   - Network policies in K8s

2. **Identity & Access**:
   - Service accounts with IAM roles
   - Workload Identity for pod authentication
   - RBAC in Kubernetes

3. **Data Security**:
   - Cloud SQL private IP
   - SSL/TLS for Cloud SQL
   - Encrypted at-rest (GCP default)

4. **Container Security**:
   - Security contexts in pod specs
   - Non-root user execution
   - Resource limits/quotas

## Scaling Strategy

- **Horizontal Pod Autoscaling (HPA)**: Auto-scale pods based on CPU/memory
- **Node Autoscaling**: Auto-scale cluster nodes (1-30 depending on environment)
- **Database**: Cloud SQL auto-storage
- **Load Balancing**: Native GCP load balancing

## Disaster Recovery

- **RTO** (Recovery Time Objective): < 5 minutes
- **RPO** (Recovery Point Objective): < 1 hour
- **Backup Strategy**: Daily automated backups
- **Multi-AZ**: Cloud SQL replication across zones

## Cost Optimization

- **Dev**: Preemptible nodes + minimal resources
- **Staging**: Standard nodes + moderate resources
- **Prod**: Committed resources + HA
- **Storage**: Managed by GCP (pay for what you use)

## Monitoring & Observability

- **Metrics**: Prometheus (15s interval)
- **Logs**: GCP Cloud Logging
- **Dashboards**: Grafana
- **Alerts**: Alert Manager + Custom rules

## References

- [GKE Architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview)
- [Cloud SQL Best Practices](https://cloud.google.com/sql/docs/postgres/best-practices)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
