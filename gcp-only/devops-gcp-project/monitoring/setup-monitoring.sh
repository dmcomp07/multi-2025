#!/bin/bash
# Setup monitoring stack with Prometheus and Grafana
# Run: bash monitoring/setup-monitoring.sh

set -e

NAMESPACE="monitoring"

echo "=========================================="
echo "Setting up Monitoring Stack"
echo "=========================================="

# Create namespace
kubectl create namespace $NAMESPACE 2>/dev/null || echo "Namespace already exists"

# Add Prometheus Helm repo
echo "Adding Prometheus Helm repository..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Install Prometheus
echo "Installing Prometheus..."
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace $NAMESPACE \
  --values monitoring/prometheus-values.yaml \
  --wait

# Create Grafana admin secret
echo "Creating Grafana credentials..."
kubectl create secret generic grafana-admin-password \
  --from-literal=password=admin \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Install Grafana
echo "Installing Grafana..."
helm install grafana prometheus-community/grafana \
  --namespace $NAMESPACE \
  --values monitoring/grafana-values.yaml \
  --wait

echo ""
echo "=========================================="
echo "✓ Monitoring stack installed!"
echo "=========================================="
echo ""
echo "Access Grafana:"
echo "  kubectl port-forward -n monitoring svc/grafana 3000:80"
echo "  Then visit: http://localhost:3000"
echo ""
echo "Default credentials:"
echo "  Username: admin"
echo "  Password: admin"
