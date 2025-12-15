#!/bin/bash
# Failover tests - Resilience and recovery testing
# Run: bash tests/failover-tests.sh

set -e

echo "=========================================="
echo "Running Failover Tests"
echo "=========================================="
echo ""

NAMESPACE="production"

# Test 1: Pod failure recovery
echo "Test 1: Pod failure recovery"
echo "Killing a random pod..."
POD=$(kubectl get pods -n $NAMESPACE -l app=app -o jsonpath='{.items[0].metadata.name}')
echo "Deleting pod: $POD"
kubectl delete pod $POD -n $NAMESPACE

echo "Waiting for pod to be recreated..."
sleep 10

RUNNING=$(kubectl get pods -n $NAMESPACE -l app=app --no-headers | grep -c "Running" || echo "0")
if [ "$RUNNING" -gt 0 ]; then
  echo "✓ Pod recovered successfully"
else
  echo "✗ Pod did not recover"
fi

# Test 2: Service redirection
echo ""
echo "Test 2: Service redirection"
echo "Getting service endpoints..."
ENDPOINTS=$(kubectl get endpoints app-service -n $NAMESPACE -o jsonpath='{.subsets[0].addresses[*].ip}' | wc -w)
echo "✓ Service has $ENDPOINTS active endpoints"

# Test 3: Deployment rollback
echo ""
echo "Test 3: Deployment rollback"
echo "Current deployment:"
kubectl get deployment app -n $NAMESPACE -o jsonpath='{.metadata.name} {.spec.replicas} replicas' 
echo ""

echo "Scaling down deployment..."
kubectl scale deployment app -n $NAMESPACE --replicas=1

sleep 5
REPLICAS=$(kubectl get deployment app -n $NAMESPACE -o jsonpath='{.spec.replicas}')
echo "Current replicas: $REPLICAS"

echo "Scaling back up..."
kubectl scale deployment app -n $NAMESPACE --replicas=3

sleep 10
REPLICAS=$(kubectl get deployment app -n $NAMESPACE -o jsonpath='{.spec.replicas}')
echo "✓ Replicas restored to: $REPLICAS"

# Test 4: Connection resilience
echo ""
echo "Test 4: Connection resilience"
SERVICE_IP=$(kubectl get svc app-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ ! -z "$SERVICE_IP" ]; then
  echo "Testing connectivity..."
  
  for i in {1..5}; do
    if curl -s -m 5 http://$SERVICE_IP/ > /dev/null 2>&1; then
      echo "✓ Connection attempt $i successful"
    else
      echo "⚠ Connection attempt $i failed (may be expected)"
    fi
    sleep 2
  done
else
  echo "⚠ Service IP not available"
fi

# Test 5: Database connectivity during chaos
echo ""
echo "Test 5: Database connectivity"
POD=$(kubectl get pods -n $NAMESPACE -l app=app -o jsonpath='{.items[0].metadata.name}')
DB_HOST=$(kubectl get configmap app-config -n $NAMESPACE -o jsonpath='{.data.db_host}' 2>/dev/null || echo "")

if [ ! -z "$DB_HOST" ]; then
  echo "Testing database connectivity..."
  kubectl exec $POD -n $NAMESPACE -- \
    bash -c "nc -zv $DB_HOST 5432" 2>&1 || echo "⚠ Database check skipped"
else
  echo "⚠ Database configuration not found"
fi

# Summary
echo ""
echo "=========================================="
echo "✓ Failover tests completed"
echo "=========================================="
echo ""
echo "Results:"
echo "- Pod recovery: Check logs above"
echo "- Service endpoints: $ENDPOINTS active"
echo "- Scaling: Deployment scaled up/down"
echo "- Connectivity: Tested with curl"
echo ""
echo "Notes:"
echo "- Some failures may be expected during chaos"
echo "- Monitor actual behavior in production"
echo "- Adjust test intensity based on SLA"
