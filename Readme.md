# Hybrid Cloud DevOps Infrastructure

A **production-grade, highly available, and highly scalable** DevOps infrastructure spanning **AWS, Azure, and Google Cloud Platform (GCP)**.

![Version](https://img.shields.io/badge/version-1.0-blue)
![Status](https://img.shields.io/badge/status-Production--Ready-brightgreen)
![License](https://img.shields.io/badge/license-MIT-green)
![Last Updated](https://img.shields.io/badge/updated-December%202025-blue)

## 🏗️ Architecture Overview

### Multi-Cloud Distribution
```
┌─────────────────────────────────────────┐
│     AWS (Primary)  │ Azure (Secondary)  │ GCP (K8s)
│   EC2, RDS, S3     │ VMs, SQL, Blob     │ GKE Clusters
└─────────────────────────────────────────┘
         ↓              ↓              ↓
    Multi-Zone Kubernetes Orchestration
         ↓              ↓              ↓
    Prometheus + Grafana Monitoring
         ↓              ↓              ↓
    Jenkins CI/CD Pipeline
```

### Key Features
- ✅ **99.95% uptime** - Multi-AZ deployment with automatic failover
- ✅ **Auto-scaling** - 3 to 30 nodes based on demand
- ✅ **Infrastructure as Code** - 100% reproducible with Terraform
- ✅ **Zero-downtime deployments** - Rolling updates with health checks
- ✅ **Complete monitoring** - Prometheus + Grafana observability stack
- ✅ **CI/CD automation** - Jenkins pipeline integration
- ✅ **Security hardened** - RBAC, network policies, secrets management
- ✅ **Multi-environment** - Development, Staging, Production tiers

## 📋 Prerequisites

### Required Tools
```bash
terraform >= 1.8
ansible >= 2.14
kubectl >= 1.28
docker >= 24.0
jenkins >= 2.426
prometheus >= 2.48
grafana >= 10.0
gcloud CLI (latest)
AWS CLI v2
Azure CLI
```

### Cloud Accounts
- **GCP**: Project with enabled APIs (Kubernetes Engine, Compute, Cloud Resource Manager)
- **AWS**: IAM user with EC2, RDS, S3 permissions
- **Azure**: Subscription with contributor access

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/yourorg/devops-hybrid-cloud.git
cd devops-hybrid-cloud
```

### 2. Setup Credentials
```bash
# GCP
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/terraform-key.json"

# AWS
aws configure --profile devops

# Azure
az login
```

### 3. Initialize Infrastructure
```bash
cd terraform
terraform init
terraform plan -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars"
```

### 4. Configure Kubernetes
```bash
gcloud container clusters get-credentials hybrid-cloud-cluster-prod \
  --region us-central1 --project devops-hybrid-cloud
```

### 5. Deploy Applications
```bash
kubectl apply -f ../kubernetes/base/
```

See [QUICK_START.md](docs/QUICK_START.md) for detailed instructions.

## 📁 Directory Structure

```
.
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # Main configuration
│   ├── gcp.tf             # GCP GKE setup
│   ├── aws.tf             # AWS RDS & EC2
│   ├── azure.tf           # Azure resources
│   ├── variables.tf       # Variable definitions
│   ├── outputs.tf         # Output values
│   ├── environments/      # Environment-specific configs
│   │   ├── dev/
│   │   ├── staging/
│   │   └── prod/
│   ├── modules/           # Reusable Terraform modules
│   │   ├── gke/
│   │   ├── rds/
│   │   └── networking/
│   └── backend/           # Remote state management
│
├── kubernetes/            # Kubernetes manifests
│   ├── base/              # Base configurations
│   │   ├── namespace.yaml
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap-secret.yaml
│   │   └── kustomization.yaml
│   └── overlays/          # Environment-specific overlays
│       ├── dev/
│       ├── staging/
│       └── prod/
│
├── ansible/               # Configuration Management
│   ├── playbooks/         # Ansible playbooks
│   ├── roles/             # Reusable roles
│   │   ├── docker/
│   │   ├── kubernetes/
│   │   ├── prometheus/
│   │   ├── grafana/
│   │   ├── jenkins_agent/
│   │   └── security/
│   ├── inventory/         # Inventory files
│   ├── group_vars/        # Group variables
│   └── ansible.cfg        # Ansible configuration
│
├── docker/                # Docker configurations
│   ├── Dockerfile         # Application image
│   ├── docker-compose.yml # Local development
│   └── .dockerignore
│
├── monitoring/            # Monitoring stack
│   ├── prometheus/        # Prometheus configs
│   └── grafana/           # Grafana dashboards
│
├── jenkins/               # Jenkins configuration
│   ├── Jenkinsfile        # Pipeline definition
│   └── jenkins-values.yaml# Helm values
│
├── tests/                 # Test scripts
│   ├── smoke_tests.sh     # Health checks
│   ├── load_tests.sh      # Performance tests
│   └── failover_tests.sh  # Disaster recovery
│
├── .github/workflows/     # GitHub Actions CI/CD
│   └── ci-cd.yml
│
├── docs/                  # Documentation
│   ├── ARCHITECTURE.md
│   ├── QUICK_START.md
│   ├── TROUBLESHOOTING.md
│   ├── MONITORING.md
│   └── SECURITY.md
│
├── .gitignore             # Git ignore file
├── LICENSE                # MIT License
└── README.md              # This file
```

## 🛠️ Components

### Terraform (IaC)
- **GCP GKE**: Multi-zone Kubernetes clusters with auto-scaling
- **AWS RDS**: Production database with Multi-AZ replication
- **Azure VMs**: Secondary infrastructure and networking
- **Networking**: VPCs, security groups, firewall rules

### Kubernetes
- **Deployments**: Auto-scaled application pods
- **Services**: Load balancing and service discovery
- **ConfigMaps/Secrets**: Secure configuration management
- **Ingress**: Advanced routing and SSL termination
- **HPA**: Horizontal pod autoscaler

### Ansible
- **Docker Installation**: Container runtime setup
- **Kubernetes Setup**: Node provisioning and hardening
- **Monitoring Agents**: Prometheus exporters
- **Security**: Firewall, SSH hardening, audit logs

### Monitoring
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alert routing and notification

## 🔧 Configuration Examples

### Deploy to Production
```bash
# Plan
terraform plan -var-file="environments/prod/terraform.tfvars"

# Apply
terraform apply -var-file="environments/prod/terraform.tfvars"

# Verify
kubectl get nodes -o wide
kubectl get deployment hybrid-app -n production
```

### Scale Cluster
```bash
# Increase pod replicas
kubectl scale deployment hybrid-app --replicas=20 -n production

# Update max nodes in Terraform
# Edit: terraform/environments/prod/terraform.tfvars
# Change: max_nodes = 30
terraform apply -var-file="environments/prod/terraform.tfvars"
```

### Update Application
```bash
# Create new image
docker build -t gcr.io/devops-hybrid-cloud/app:v2 .
docker push gcr.io/devops-hybrid-cloud/app:v2

# Deploy
kubectl set image deployment/hybrid-app \
  hybrid-app=gcr.io/devops-hybrid-cloud/app:v2 \
  -n production --record

# Monitor
kubectl rollout status deployment/hybrid-app -n production
```

## 🧪 Testing

### Run Smoke Tests
```bash
bash tests/smoke_tests.sh
```

### Performance Testing
```bash
bash tests/load_tests.sh
```

### Failover Testing
```bash
bash tests/failover_tests.sh
```

## 📊 Monitoring

### Access Dashboards
```bash
# Prometheus
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
# http://localhost:9090

# Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
# http://localhost:3000
```

### Key Alerts
- CPU usage > 80%
- Memory usage > 85%
- Pod crash loop
- Error rate > 1%
- Database replication lag > 1s

## 🔐 Security

- ✅ Network policies (deny-all default)
- ✅ RBAC with least privilege
- ✅ Pod security policies
- ✅ Secret encryption at rest (KMS)
- ✅ TLS for all traffic
- ✅ Regular security scanning (Trivy)
- ✅ Audit logging enabled
- ✅ Image scanning in CI/CD

See [SECURITY.md](docs/SECURITY.md) for detailed security guidelines.

## 📚 Documentation

- [Architecture Overview](docs/ARCHITECTURE.md)
- [Quick Start Guide](docs/QUICK_START.md)
- [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
- [Monitoring Setup](docs/MONITORING.md)
- [Security Best Practices](docs/SECURITY.md)

## 🚨 Troubleshooting

### Pods Not Starting
```bash
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
```

### Node Issues
```bash
kubectl describe node <node-name>
kubectl top nodes
```

### Database Connectivity
```bash
kubectl exec -it <pod> -n production -- bash
psql -h $DB_HOST -U $DB_USER -d $DB_NAME
```

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for more solutions.

## 📝 Maintenance Schedule

- **Daily**: Monitor dashboards, check alerts
- **Weekly**: Review metrics trends, check costs
- **Monthly**: Update dependencies, security audit
- **Quarterly**: DR drill, compliance review
- **Annually**: Full infrastructure audit, penetration test

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Commit changes (`git commit -am 'Add improvement'`)
4. Push to branch (`git push origin feature/improvement`)
5. Open Pull Request

### Code Quality
- Run `terraform fmt -recursive`
- Validate with `terraform validate`
- Lint Ansible: `ansible-lint`
- Check Docker: `docker scan`

## 📈 Performance Metrics

- **Uptime**: 99.95% SLA
- **RTO**: < 1 hour
- **RPO**: < 15 minutes
- **Response Time**: < 500ms p95
- **Error Rate**: < 0.1%

## 💰 Cost Optimization

- Use preemptible nodes in non-prod (saves 70%)
- Reserved instances in production
- Auto-scaling prevents over-provisioning
- Regular cost analysis and right-sizing

## 📞 Support

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Documentation**: See `/docs` directory
- **Email**: devops-team@example.com

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Kubernetes Community
- Terraform by HashiCorp
- CNCF Projects
- Open Source Contributors

---

**Version**: 1.0 | **Last Updated**: December 2025 | **Status**: Production-Ready

⭐ If you find this helpful, please star the repository!
