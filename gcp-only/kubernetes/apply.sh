#!/bin/bash
# Deploy Kubernetes resources
# Run: bash kubernetes/apply.sh

set -e

NAMESPACE="${1:-production}"

echo "=========================================="
echo "Deploying Kubernetes Resources"
echo "=========================================="
echo "Namespace: $NAMESPACE"
echo ""

# Create namespace
kubectl apply -f 00-namespace.yaml

# Create RBAC
kubectl apply -f 01-rbac.yaml

# Get Cloud SQL IP from Terraform
CLOUD_SQL_IP=$(cd ../terraform && terraform output -raw cloud_sql_private_ip)
echo "Cloud SQL IP: $CLOUD_SQL_IP"

# Create ConfigMap and Secret
kubectl create configmap app-config \
  --from-literal=db_host=$CLOUD_SQL_IP \
  --from-literal=db_port=5432 \
  --from-literal=db_name=applicationdb \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Get DB password from Terraform
DB_PASSWORD=$(cd ../terraform && terraform output -raw db_password)

kubectl create secret generic db-credentials \
  --from-literal=username=app_user \
  --from-literal=password=$DB_PASSWORD \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Apply manifests
kubectl apply -f 03-deployment.yaml
kubectl apply -f 04-service.yaml
kubectl apply -f 05-hpa.yaml
kubectl apply -f 06-pdb.yaml

# Verify
echo ""
echo "Verifying deployment..."
kubectl rollout status deployment/app -n $NAMESPACE
kubectl get pods -n $NAMESPACE
kubectl get svc -n $NAMESPACE

echo ""
echo "=========================================="
echo "✓ Kubernetes resources deployed!"
echo "=========================================="
