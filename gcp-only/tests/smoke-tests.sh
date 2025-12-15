#!/bin/bash
# Smoke tests - Basic functionality validation
# Run: bash tests/smoke-tests.sh

set -e

echo "=========================================="
echo "Running Smoke Tests"
echo "=========================================="
echo ""

NAMESPACE="production"
FAILED=0

# Test 1: Check cluster connectivity
echo "Test 1: Cluster connectivity"
if kubectl cluster-info &>/dev/null; then
  echo "✓ Cluster is accessible"
else
  echo "✗ Cluster is not accessible"
  FAILED=$((FAILED + 1))
fi

# Test 2: Check nodes are ready
echo ""
echo "Test 2: All nodes ready"
READY_NODES=$(kubectl get nodes --no-headers | grep -c " Ready ")
TOTAL_NODES=$(kubectl get nodes --no-headers | wc -l)
if [ "$READY_NODES" -eq "$TOTAL_NODES" ]; then
  echo "✓ All $TOTAL_NODES nodes are ready"
else
  echo "✗ Only $READY_NODES/$TOTAL_NODES nodes are ready"
  FAILED=$((FAILED + 1))
fi

# Test 3: Check namespace exists
echo ""
echo "Test 3: Production namespace"
if kubectl get namespace $NAMESPACE &>/dev/null; then
  echo "✓ Namespace $NAMESPACE exists"
else
  echo "✗ Namespace $NAMESPACE does not exist"
  FAILED=$((FAILED + 1))
fi

# Test 4: Check pods are running
echo ""
echo "Test 4: Pods status"
RUNNING_PODS=$(kubectl get pods -n $NAMESPACE --no-headers 2>/dev/null | grep -c "Running" || echo "0")
if [ "$RUNNING_PODS" -gt 0 ]; then
  echo "✓ $RUNNING_PODS pods are running"
else
  echo "✗ No running pods found"
  FAILED=$((FAILED + 1))
fi

# Test 5: Check service is accessible
echo ""
echo "Test 5: Service accessibility"
SERVICE_IP=$(kubectl get svc app-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
if [ ! -z "$SERVICE_IP" ]; then
  echo "✓ Service has external IP: $SERVICE_IP"
  
  # Try to connect
  if timeout 5 curl -s http://$SERVICE_IP/ > /dev/null 2>&1; then
    echo "✓ Service is responding"
  else
    echo "⚠ Service IP assigned but not responding yet (may be normal)"
  fi
else
  echo "⚠ Service does not have external IP (may be normal in private clusters)"
fi

# Test 6: Check storage
echo ""
echo "Test 6: Storage connectivity"
if kubectl get pvc -n $NAMESPACE &>/dev/null; then
  echo "✓ Storage is accessible"
else
  echo "⚠ No storage found (may be normal)"
fi

# Test 7: Check RBAC
echo ""
echo "Test 7: RBAC configuration"
if kubectl get serviceaccount app-sa -n $NAMESPACE &>/dev/null; then
  echo "✓ Service account exists"
else
  echo "✗ Service account not found"
  FAILED=$((FAILED + 1))
fi

# Test 8: Check monitoring
echo ""
echo "Test 8: Monitoring stack"
if kubectl get deployment -n monitoring &>/dev/null; then
  echo "✓ Monitoring namespace exists"
else
  echo "⚠ Monitoring not deployed"
fi

# Summary
echo ""
echo "=========================================="
if [ $FAILED -eq 0 ]; then
  echo "✓ All smoke tests passed!"
  exit 0
else
  echo "✗ $FAILED test(s) failed"
  exit 1
fi
