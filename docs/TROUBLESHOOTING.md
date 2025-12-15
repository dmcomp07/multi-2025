# Troubleshooting Guide

## Kubernetes Issues

### Pods Not Starting

**Symptoms**: Pods stuck in Pending, CrashLoopBackOff, or ImagePullBackOff

**Diagnosis**:
```bash
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
kubectl get events -n production
```

**Solutions**:

**CrashLoopBackOff**
```bash
# Check logs for errors
kubectl logs <pod-name> -n production
kubectl logs <pod-name> -n production --previous

# Check resource limits
kubectl describe pod <pod-name> -n production | grep -i limits
```

**ImagePullBackOff**
```bash
# Verify image exists
docker pull gcr.io/devops-hybrid-cloud/app:tag

# Check credentials
kubectl get secrets -n production
kubectl describe secret docker-registry-credentials -n production

# Create secret if needed
kubectl create secret docker-registry gcr-secret \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat /path/to/key.json)" \
  -n production
```

**Pending**
```bash
# Check node capacity
kubectl top nodes
kubectl describe nodes

# Check resource quotas
kubectl describe resourcequota -n production

# Check PVC status
kubectl get pvc -n production
kubectl describe pvc <pvc-name> -n production
```

### Node Issues

**Node NotReady**
```bash
kubectl describe node <node-name>
kubectl top node <node-name>

# SSH to node
gcloud compute ssh <instance-name> --zone <zone>

# Check kubelet
journalctl -u kubelet -n 100
systemctl status kubelet
```

**High Resource Usage**
```bash
# Find resource-heavy pods
kubectl top pods -n production --sort-by=memory
kubectl top pods -n production --sort-by=cpu

# Check if node is overprovisioned
kubectl describe node <node-name> | grep -A 5 Allocatable
kubectl describe node <node-name> | grep -A 5 Allocated
```

## Network Issues

**Pod-to-Pod Communication**
```bash
# Test from another pod
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never

# Inside debug pod:
ping <target-pod-ip>
curl http://<service-name>:<port>
nslookup <service-name>

# Check network policies
kubectl get networkpolicies -n production
kubectl describe networkpolicy <policy-name> -n production
```

**Service Not Accessible**
```bash
# Check endpoints
kubectl get endpoints <service-name> -n production
kubectl describe service <service-name> -n production

# Port-forward and test
kubectl port-forward svc/<service-name> 8080:80 -n production
curl http://localhost:8080
```

## Database Issues

### RDS Connectivity

**Cannot Connect**
```bash
# Test from pod
kubectl exec -it <pod> -n production -- bash

# Install psql
apt-get update && apt-get install -y postgresql-client

# Test connection
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT version();"
```

**Security Group Issues**
```bash
# Check security group
aws ec2 describe-security-groups --group-ids sg-xxx

# Add inbound rule
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxx \
  --protocol tcp \
  --port 5432 \
  --cidr 10.0.0.0/8
```

### Slow Queries

**Enable Query Logging**
```bash
aws rds describe-db-instances --db-instance-identifier production-rds

aws rds modify-db-instance \
  --db-instance-identifier production-rds \
  --enable-cloudwatch-logs-exports postgresql \
  --apply-immediately
```

**Check Logs**
```bash
aws logs tail /aws/rds/instance/production-rds/postgresql --follow
```

## Monitoring Issues

### Prometheus Targets Down

**Access Prometheus UI**
```bash
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
# http://localhost:9090/targets
```

**Check Service Discovery**
```bash
kubectl get endpoints -n monitoring
kubectl describe service prometheus-operated -n monitoring

# Verify pod annotations
kubectl get pods -n production -o jsonpath='{range .items[*]}{.metadata.annotations.prometheus\.io/scrape}{"\n"}{end}'
```

### No Metrics Appearing

**Verify Scrape Config**
```bash
kubectl exec prometheus-operated-0 -n monitoring -- \
  cat /etc/prometheus/prometheus.yml

# Check scrape targets
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090
# Visit http://localhost:9090/api/v1/targets
```

## Deployment Issues

### Stuck Rollout

**Check Rollout Status**
```bash
kubectl rollout status deployment/hybrid-app -n production

# View history
kubectl rollout history deployment/hybrid-app -n production

# Undo last deployment
kubectl rollout undo deployment/hybrid-app -n production

# Undo to specific revision
kubectl rollout undo deployment/hybrid-app --to-revision=2 -n production
```

**Manual Recovery**
```bash
# Set replicas to 0
kubectl scale deployment hybrid-app --replicas=0 -n production

# Delete problematic pods
kubectl delete pods -l app=hybrid-app -n production

# Scale back up
kubectl scale deployment hybrid-app --replicas=9 -n production
```

### Failed Health Checks

**Check Probe Configuration**
```bash
kubectl get deployment hybrid-app -n production -o yaml | \
  grep -A 20 "livenessProbe\|readinessProbe"

# Test health endpoint
POD=$(kubectl get pods -n production -l app=hybrid-app -o jsonpath='{.items[0].metadata.name}')
kubectl exec $POD -n production -- curl -v http://localhost:8080/health/live
```

## Storage Issues

### PVC Stuck in Pending

**Check PVC Status**
```bash
kubectl describe pvc <pvc-name> -n production

# Check available storage
kubectl describe storageclass standard

# Check PV status
kubectl get pv
kubectl describe pv <pv-name>
```

## Performance Issues

### High Latency

**Check Pod Performance**
```bash
# Check if pod is CPU-throttled
kubectl top pod <pod-name> -n production

# Check if swapping
kubectl exec <pod-name> -n production -- cat /proc/meminfo

# Check network stats
kubectl exec <pod-name> -n production -- ss -tan
```

### Memory Leaks

**Monitor Memory Usage**
```bash
# Watch memory growth
kubectl top pod <pod-name> -n production --containers

# Inside pod
free -h
ps aux --sort=-%mem
```

## Cost Issues

### Unexpected High Costs

**Find Expensive Resources**
```bash
# GCP
gcloud compute instances list --sort-by=MACHINE_TYPE

# AWS
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]'

# Check running pods
kubectl get pods --all-namespaces -o custom-columns=NAME:.metadata.name,CPU:.spec.containers[0].resources.limits.cpu,MEM:.spec.containers[0].resources.limits.memory
```

**Optimize Costs**
```bash
# Scale down non-prod environments
kubectl scale deployment hybrid-app --replicas=3 -n development

# Check for unused resources
kubectl get pvc --all-namespaces
kubectl get pv
```

## Getting Help

1. Check logs first
2. Review event history: `kubectl get events -n production`
3. Check metrics in Grafana
4. Review documentation
5. Open GitHub issue with error logs
