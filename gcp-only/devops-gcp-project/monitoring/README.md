# Monitoring Setup

This directory contains monitoring configuration for Prometheus and Grafana.

## Contents

- `prometheus-config.yaml` - Prometheus configuration
- `alert-rules.yaml` - Alert rule definitions
- `grafana-values.yaml` - Grafana Helm chart values
- `setup-monitoring.sh` - Installation script

## Installation

```bash
# Install monitoring stack
bash setup-monitoring.sh

# Check deployment
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# Access Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80
# Open http://localhost:3000
```

## Customization

Update the following as needed:
- Prometheus scrape configs for additional targets
- Alert thresholds and conditions
- Grafana dashboard definitions
- Retention policies
