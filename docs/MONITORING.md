# Monitoring & Observability Setup

## Prometheus Configuration

### Installation via Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --create-namespace \
  -f monitoring/prometheus/values.yaml
```

### Scrape Configurations

**Kubernetes Components**
```yaml
scrape_configs:
  - job_name: 'kubernetes-apiservers'
    kubernetes_sd_configs:
      - role: endpoints
  
  - job_name: 'kubernetes-nodes'
    kubernetes_sd_configs:
      - role: node
  
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
```

**Application Metrics**
```yaml
  - job_name: 'hybrid-app'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - production
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: hybrid-app
```

## Grafana Dashboards

### Default Dashboards
- Kubernetes Cluster Overview
- Node Exporter Full
- Prometheus Stats
- Pod Resource Requests

### Access Grafana
```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
# http://localhost:3000
# Username: admin
# Password: (from secret)
```

### Import Dashboards
```bash
# Get admin password
kubectl get secret -n monitoring grafana \
  -o jsonpath='{.data.admin-password}' | base64 -d
```

### Key Metrics to Monitor

**Cluster Health**
- Node CPU/Memory usage
- Pod count and distribution
- Network I/O
- Disk usage

**Application Performance**
- Request rate (req/sec)
- Response time (p50, p95, p99)
- Error rate (5xx errors)
- Active connections

**Database Performance**
- Query execution time
- Connection pool usage
- Slow query count
- Replication lag

**Infrastructure**
- Disk I/O operations
- Network latency
- Cost per hour

## Alerting

### Alert Rules

```yaml
groups:
  - name: kubernetes_alerts
    rules:
      - alert: HighCPUUsage
        expr: (100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100) > 80
        for: 5m
        annotations:
          summary: "High CPU usage on {{ $labels.instance }}"

      - alert: HighMemoryUsage
        expr: (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 5m
        annotations:
          summary: "High memory usage on {{ $labels.instance }}"

      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[5m]) > 0.1
        annotations:
          summary: "Pod {{ $labels.pod }} in {{ $labels.namespace }} is crash looping"

      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.01
        for: 5m
        annotations:
          summary: "High error rate ({{ $value | humanizePercentage }})"
```

### Alert Thresholds (Production)

| Metric | Warning | Critical |
|--------|---------|----------|
| CPU Usage | > 80% | > 95% |
| Memory Usage | > 85% | > 95% |
| Disk Usage | > 80% | > 95% |
| Pod CrashLoop | immediate | - |
| Node NotReady | > 5min | - |
| Error Rate | > 1% | > 5% |
| Response Time (p95) | > 1s | > 5s |
| DB Replication Lag | > 1s | > 5s |

### AlertManager Configuration

```yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'default'
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  routes:
    - match:
        severity: critical
      receiver: 'critical'
      continue: true
    - match:
        severity: warning
      receiver: 'default'

receivers:
  - name: 'default'
    slack_configs:
      - api_url: '{{ .SLACK_WEBHOOK_URL }}'
        channel: '#alerts'

  - name: 'critical'
    pagerduty_configs:
      - service_key: '{{ .PAGERDUTY_KEY }}'
    slack_configs:
      - api_url: '{{ .SLACK_WEBHOOK_URL }}'
        channel: '#critical-alerts'
```

## Custom Metrics

### Application Instrumentation

```go
import "github.com/prometheus/client_golang/prometheus"

// Counter
httpRequestsTotal := prometheus.NewCounterVec(
    prometheus.CounterOpts{
        Name: "http_requests_total",
        Help: "Total HTTP requests",
    },
    []string{"method", "endpoint", "status"},
)

// Gauge
activeConnections := prometheus.NewGauge(
    prometheus.GaugeOpts{
        Name: "active_connections",
        Help: "Active database connections",
    },
)

// Histogram
requestDuration := prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name:    "http_request_duration_seconds",
        Help:    "HTTP request duration",
        Buckets: prometheus.DefBuckets,
    },
    []string{"method", "endpoint"},
)
```

## Log Aggregation

### Setup with Loki

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm install loki grafana/loki-stack \
  -n monitoring \
  -f monitoring/loki/values.yaml
```

### Log Queries

```
{namespace="production", app="hybrid-app"} | json | error_level="ERROR"
rate({namespace="production"}[5m])
```

## SLOs & Dashboards

### Service Level Objectives

| Metric | Target | Measurement |
|--------|--------|-------------|
| Availability | 99.95% | Uptime % |
| Error Rate | < 0.1% | 5xx errors |
| Response Time | < 500ms p95 | HTTP latency |
| Deployment Frequency | Daily | Deployments/day |
| Change Failure Rate | < 15% | Failed deployments |

### Custom Dashboards

Create dashboards for:
- Application health
- Business metrics
- Infrastructure costs
- Deployment frequency
- Team metrics
