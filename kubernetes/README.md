# Kubernetes Overlays for Different Environments

This file explains how to use Kustomize overlays for environment-specific configurations.

## Directory Structure

```
kubernetes/
├── base/                      # Base configurations
│   ├── namespace.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── configmap-secret.yaml
│   └── kustomization.yaml
│
└── overlays/
    ├── dev/                   # Development environment
    │   ├── kustomization.yaml
    │   ├── replica_override.yaml
    │   └── resource_override.yaml
    ├── staging/              # Staging environment
    │   ├── kustomization.yaml
    │   └── resource_override.yaml
    └── prod/                 # Production environment
        ├── kustomization.yaml
        ├── replica_override.yaml
        └── resource_override.yaml
```

## Usage

### Deploy to Development
```bash
kubectl apply -k kubernetes/overlays/dev
```

### Deploy to Staging
```bash
kubectl apply -k kubernetes/overlays/staging
```

### Deploy to Production
```bash
kubectl apply -k kubernetes/overlays/prod
```

## Creating Environment-Specific Overlays

Create the following files in each overlay directory:

### kustomization.yaml
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: development

bases:
  - ../../base

patchesStrategicMerge:
  - replica_override.yaml
  - resource_override.yaml

namePrefix: dev-
commonSuffix: -dev
```

### Example Patch: replica_override.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hybrid-app
spec:
  replicas: 2
```

### Example Patch: resource_override.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hybrid-app
spec:
  template:
    spec:
      containers:
      - name: hybrid-app
        resources:
          requests:
            cpu: "100m"
            memory: "256Mi"
          limits:
            cpu: "200m"
            memory: "512Mi"
```

## Environment Differences

| Aspect | Dev | Staging | Prod |
|--------|-----|---------|------|
| Replicas | 2 | 6 | 9 |
| CPU Request | 100m | 200m | 250m |
| Memory Request | 256Mi | 512Mi | 512Mi |
| CPU Limit | 200m | 400m | 500m |
| Memory Limit | 512Mi | 1Gi | 1Gi |
| HPA Min | 2 | 6 | 9 |
| HPA Max | 5 | 15 | 30 |
| Storage | 10Gi | 50Gi | 100Gi |
