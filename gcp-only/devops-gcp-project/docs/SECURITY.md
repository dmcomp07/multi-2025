# Security Best Practices

Comprehensive security guidelines for the DevOps infrastructure.

## Network Security

### VPC Isolation

```hcl
# terraform/gcp-network.tf
resource "google_compute_network" "vpc" {
  # Auto-created subnets disabled - explicit control
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}
```

### Firewall Rules

```hcl
# Internal traffic only
resource "google_compute_firewall" "allow_internal" {
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  source_ranges = ["10.0.0.0/8"]  # Only internal
}

# External traffic restricted
resource "google_compute_firewall" "allow_http" {
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]       # Only HTTP/HTTPS
  }
  source_ranges = ["0.0.0.0/0"]   # Public internet
}
```

### Network Policies

Implement Kubernetes network policies:

```yaml
# kubernetes/network-policies.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-ingress
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress: []  # Deny all ingress by default
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-ingress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: app
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: production
```

## Identity & Access Control

### Service Accounts

```hcl
# terraform/iam.tf
resource "google_service_account" "app_sa" {
  account_id   = "app-sa"
  display_name = "Application Service Account"
}

# Bind minimal required roles
resource "google_project_iam_member" "app_logs" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}

resource "google_project_iam_member" "app_metrics" {
  project = var.gcp_project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.app_sa.email}"
}
```

### Workload Identity

```hcl
# terraform/gke.tf
resource "google_container_cluster" "primary" {
  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }
}

# Bind Kubernetes SA to GCP SA
resource "google_service_account_iam_binding" "workload_identity" {
  service_account_id = google_service_account.app_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.gcp_project_id}.svc.id.goog[production/app-sa]"
  ]
}
```

### RBAC in Kubernetes

```yaml
# kubernetes/01-rbac.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: app-role
  namespace: production
rules:
  # Minimal required permissions
  - apiGroups: [""]
    resources: ["pods", "configmaps"]
    verbs: ["get", "list"]
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get"]
    # Note: No "delete" or "create" - read-only
```

## Data Security

### Cloud SQL Encryption

```hcl
# terraform/cloudsql.tf
resource "google_sql_database_instance" "main" {
  # Encryption at rest (default)
  # Encryption in transit (required SSL)
  
  settings {
    ip_configuration {
      private_network = google_compute_network.vpc.id  # Private IP only
      require_ssl     = true                           # Enforce SSL
    }
  }
}

# Use Cloud KMS for key management
resource "google_kms_crypto_key" "cloudsql" {
  name           = "cloudsql-key"
  key_ring       = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"  # 90 days
}
```

### Application Secrets

```yaml
# kubernetes/02-configmap-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
  namespace: production
type: Opaque
stringData:
  # Secrets stored securely in etcd
  # Never commit to git - use Sealed Secrets or External Secrets Operator
  username: ${POPULATED_BY_SCRIPT}
  password: ${POPULATED_BY_SCRIPT}
```

### Secrets Management

Best practices:

```bash
# 1. Never commit secrets to git
# Use .gitignore for sensitive files

# 2. Use Google Secret Manager
gcloud secrets create db-password --data-file=-

# 3. Use Sealed Secrets
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/sealed-secrets-v0.24.0.yaml

# 4. Implement audit logging
gcloud logging read "resource.type=k8s_cluster AND protoPayload.methodName=~storage.get" --limit=10
```

## Container Security

### Security Contexts

```yaml
# kubernetes/03-deployment.yaml
spec:
  template:
    spec:
      securityContext:
        runAsNonRoot: true          # Don't run as root
        runAsUser: 1000             # Unprivileged user
        fsGroup: 1000               # File system group
        seccompProfile:
          type: RuntimeDefault      # Security policies
      
      containers:
      - name: app
        securityContext:
          allowPrivilegeEscalation: false  # No escalation
          capabilities:
            drop: ["ALL"]           # Drop all capabilities
          readOnlyRootFilesystem: true  # Read-only root
        
        resources:
          limits:
            cpu: 500m
            memory: 512Mi
          requests:
            cpu: 100m
            memory: 128Mi
```

### Pod Security Policies

```yaml
# kubernetes/pod-security-policies.yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - configMap
    - emptyDir
    - projected
    - secret
    - downwardAPI
    - persistentVolumeClaim
  runAsUser:
    rule: MustRunAsNonRoot
  seLinux:
    rule: MustRunAs
    seLinuxOptions:
      level: "s0:c123,c456"
  fsGroup:
    rule: MustRunAs
    ranges:
      - min: 1000
        max: 65535
  readOnlyRootFilesystem: true
```

### Image Security

```dockerfile
# ci-cd/Dockerfile
# Use minimal base image
FROM nginx:alpine

# Don't run as root
RUN addgroup -g 1000 app && adduser -D -u 1000 -G app app

# Copy only necessary files
COPY --chown=app:app . /app/

# Run as non-root
USER app

# Read-only root
RUN chmod -R a-w /etc /app

# Health check
HEALTHCHECK CMD curl -f http://localhost/ || exit 1
```

## Monitoring & Audit

### Audit Logging

```bash
# Enable GCP audit logs
gcloud logging sinks create cloudsql-audit-sink \
  logging.googleapis.com/projects/${PROJECT_ID}/logs/cloudsql-audit \
  --log-filter='resource.type="cloudsql_database"'

# Enable GKE audit logs
gcloud container clusters update dev-cluster \
  --enable-cloud-logging \
  --logging=SYSTEM_COMPONENTS,WORKLOADS
```

### Security Monitoring

```yaml
# monitoring/alert-rules.yaml
groups:
  - name: security
    rules:
      - alert: UnauthorizedAccessAttempt
        expr: rate(apiserver_audit_event_total{verb="get",user_agent="curl"}[5m]) > 0
        for: 1m
        labels:
          severity: warning

      - alert: PrivilegeEscalationAttempt
        expr: kubelet_pod_container_status_privileged > 0
        for: 1m
        labels:
          severity: critical
```

## Compliance

### Standards

- **PCI DSS**: Payment Card Industry Data Security Standard
- **HIPAA**: Health Insurance Portability and Accountability Act
- **GDPR**: General Data Protection Regulation
- **SOC 2**: System and Organization Controls

### Implementation Checklist

- [ ] Encryption at rest and in transit
- [ ] Access controls and RBAC
- [ ] Audit logging enabled
- [ ] Network policies configured
- [ ] Security contexts enforced
- [ ] Vulnerability scanning enabled
- [ ] Backup and recovery tested
- [ ] Incident response plan documented

## Security Scanning

### Container Image Scanning

```bash
# Scan images in Container Registry
gcloud container images scan gcr.io/${PROJECT_ID}/app:latest

# View vulnerabilities
gcloud container images describe gcr.io/${PROJECT_ID}/app:latest \
  --show-package-vulnerability
```

### Vulnerability Assessment

```bash
# Enable Config Connector
gcloud services enable --project=${PROJECT_ID} \
  gkeonprem.googleapis.com

# Run security assessment
gcloud container images scan gcr.io/${PROJECT_ID}/app
```

## Regular Security Tasks

### Weekly
- [ ] Review access logs
- [ ] Check for security updates
- [ ] Review alert rules

### Monthly
- [ ] Penetration testing
- [ ] Security audit
- [ ] Update security policies
- [ ] Review compliance status

### Quarterly
- [ ] Security training
- [ ] Disaster recovery drill
- [ ] Policy review
- [ ] Dependency updates

## Incident Response

### Steps

1. **Detect** → Monitoring systems alert
2. **Respond** → Isolate affected resources
3. **Investigate** → Analyze logs and metrics
4. **Remediate** → Fix vulnerability
5. **Learn** → Update policies

### Resources

- [GCP Security Best Practices](https://cloud.google.com/security)
- [Kubernetes Security](https://kubernetes.io/docs/concepts/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)

## Support

For security concerns:
1. Review GCP Security Center
2. Check Cloud Audit Logs
3. Run vulnerability scans
4. Contact GCP Support for critical issues
