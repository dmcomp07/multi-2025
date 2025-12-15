# Kubernetes Manifests

This directory contains all Kubernetes manifests for deploying applications on GKE.

## Files

- `00-namespace.yaml` - Namespace definitions
- `01-rbac.yaml` - Role-based access control and service accounts
- `02-configmap-secrets.yaml` - Configuration and secrets
- `03-deployment.yaml` - Application deployment
- `04-service.yaml` - Service and ingress configuration
- `05-hpa.yaml` - Horizontal Pod Autoscaler
- `06-pdb.yaml` - Pod Disruption Budget
- `apply.sh` - Deployment script

## Deployment

```bash
# Deploy all manifests
bash apply.sh

# Deploy individual manifests
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-rbac.yaml
kubectl apply -f 03-deployment.yaml

# Check deployment status
kubectl rollout status deployment/app -n production
kubectl get pods -n production
```

## Customization

Before deploying, update:
- Namespace names if needed
- Application image references in `03-deployment.yaml`
- Service type and port mappings in `04-service.yaml`
- HPA settings based on your application requirements
