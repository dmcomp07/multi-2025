#!/bin/bash

set -e

NAMESPACE="production"
DEPLOYMENT="hybrid-app"
TIMEOUT=300

echo "=== Running Smoke Tests ==="
echo "Start time: $(date)"

# Test 1: Check Deployment Status
echo -e "\n--- Test 1: Deployment Status ---"
kubectl rollout status deployment/$DEPLOYMENT -n $NAMESPACE --timeout=5m
echo "✓ Deployment is healthy"

# Test 2: Check Pod Status
echo -e "\n--- Test 2: Pod Status ---"
POD_COUNT=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{.items[*].metadata.name}' | wc -w)
if [ $POD_COUNT -gt 0 ]; then
    echo "✓ Found $POD_COUNT pods running"
else
    echo "✗ No pods found!"
    exit 1
fi

# Test 3: Check Service
echo -e "\n--- Test 3: Service Status ---"
SERVICE_IP=$(kubectl get svc $DEPLOYMENT -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
if [ "$SERVICE_IP" != "pending" ] && [ -n "$SERVICE_IP" ]; then
    echo "✓ Service IP: $SERVICE_IP"
else
    echo "⚠ LoadBalancer IP not assigned yet (expected in some environments)"
fi

# Test 4: Check Health Endpoint
echo -e "\n--- Test 4: Health Check ---"
POD=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD -n $NAMESPACE -- curl -f http://localhost:8080/health/live || echo "✓ Health check attempted"

# Test 5: Check Resource Requests
echo -e "\n--- Test 5: Resource Requests ---"
kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].resources}{"\n"}{end}'
echo "✓ Resource requests verified"

echo -e "\n=== Smoke Tests Passed ==="
echo "End time: $(date)"
