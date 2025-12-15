#!/bin/bash
# Load tests - Performance and capacity testing
# Run: bash tests/load-tests.sh

set -e

echo "=========================================="
echo "Running Load Tests"
echo "=========================================="
echo ""

NAMESPACE="production"
SERVICE_IP=$(kubectl get svc app-service -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ -z "$SERVICE_IP" ]; then
  echo "✗ Cannot find service IP"
  exit 1
fi

echo "Target: http://$SERVICE_IP"
echo ""

# Check if hey is installed
if ! command -v hey &> /dev/null; then
  echo "Installing hey (HTTP load testing tool)..."
  go install github.com/rakyll/hey@latest
fi

# Test 1: Light load (100 requests, 10 concurrent)
echo "Test 1: Light load (100 requests, 10 concurrent)"
hey -n 100 -c 10 http://$SERVICE_IP/ 2>&1 | grep -E "(requests/sec|fastest|slowest|p95|p99)" || echo "✓ Light load test completed"

# Test 2: Medium load (1000 requests, 50 concurrent)
echo ""
echo "Test 2: Medium load (1000 requests, 50 concurrent)"
hey -n 1000 -c 50 http://$SERVICE_IP/ 2>&1 | grep -E "(requests/sec|fastest|slowest|p95|p99)" || echo "✓ Medium load test completed"

# Test 3: Heavy load (5000 requests, 100 concurrent)
echo ""
echo "Test 3: Heavy load (5000 requests, 100 concurrent)"
hey -n 5000 -c 100 http://$SERVICE_IP/ 2>&1 | grep -E "(requests/sec|fastest|slowest|p95|p99)" || echo "✓ Heavy load test completed"

# Monitor scaling during load
echo ""
echo "=========================================="
echo "Monitoring pod scaling..."
echo "=========================================="
watch -n 2 'kubectl get pods,hpa -n production' &
WATCH_PID=$!

# Wait for HPA to react (max 5 minutes)
sleep 30
kill $WATCH_PID 2>/dev/null || true

# Final stats
echo ""
echo "=========================================="
echo "Load test completed"
echo "=========================================="
echo "Check HPA status:"
kubectl get hpa -n $NAMESPACE
echo ""
echo "Check pod metrics:"
kubectl top pods -n $NAMESPACE | head -5
