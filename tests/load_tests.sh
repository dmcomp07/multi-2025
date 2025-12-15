#!/bin/bash

set -e

echo "=== Load Testing with Apache Bench ==="

SERVICE_IP=$(kubectl get svc hybrid-app -n production -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")

if [ -z "$SERVICE_IP" ]; then
    echo "Service IP not available - using port-forward"
    kubectl port-forward -n production svc/hybrid-app 8080:80 &
    PF_PID=$!
    sleep 2
    SERVICE_URL="http://localhost:8080"
else
    SERVICE_URL="http://$SERVICE_IP"
fi

echo "Testing: $SERVICE_URL"

# Warm-up
echo -e "\n--- Warm-up Phase ---"
ab -n 100 -c 10 -t 30 $SERVICE_URL/ || true

# Light load test
echo -e "\n--- Light Load Test (100 concurrent, 1000 requests) ---"
ab -n 1000 -c 100 -g light_load.tsv $SERVICE_URL/ || true

# Medium load test
echo -e "\n--- Medium Load Test (500 concurrent, 5000 requests) ---"
ab -n 5000 -c 500 -g medium_load.tsv $SERVICE_URL/ || true

echo -e "\n=== Load Test Complete ==="
echo "Results saved to load test TSV files"

# Cleanup port-forward if created
if [ -n "$PF_PID" ]; then
    kill $PF_PID 2>/dev/null || true
fi
