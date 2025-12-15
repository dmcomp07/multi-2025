# DEVOPS PROJECT - QUICK START & REFERENCE GUIDE

## QUICK START (5 MINUTES)

### Prerequisites Checklist
```bash
# Verify all tools installed
terraform -version          # >= 1.8
ansible --version          # >= 2.14
kubectl version --client    # >= 1.28
docker --version           # >= 24.0
gcloud --version           # Latest
aws --version              # v2
az --version               # Latest
```

### Initial Setup (30 minutes)
```bash
# 1. Clone repository
git clone https://github.com/yourorg/devops-hybrid-cloud.git
cd devops-hybrid-cloud

# 2. Set credentials
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/terraform-key.json"
aws configure --profile devops
az login

# 3. Initialize Terraform
cd terraform
terraform init
terraform plan -var-file="environments/prod/terraform.tfvars"

# 4. Deploy infrastructure
terraform apply -var-file="environments/prod/terraform.tfvars"

# 5. Get kubeconfig
gcloud container clusters get-credentials hybrid-cloud-cluster-prod \
  --region us-central1 --project devops-hybrid-cloud

# 6. Deploy applications
kubectl apply -f ../k8s/
```

---

## COMMAND REFERENCE

### Terraform Commands
```bash
# Initialize
terraform init -upgrade

# Plan with specific environment
terraform plan -var-file="environments/prod/terraform.tfvars" -out=tfplan

# Apply with specific plan
terraform apply tfplan

# Validate configuration
terraform validate
terraform fmt -recursive

# View current state
terraform show
terraform state list
terraform state show google_container_cluster.primary

# Remote state operations
terraform state pull > backup.tfstate
terraform state push backup.tfstate

# Destroy resources (with safety)
terraform plan -destroy -var-file="environments/prod/terraform.tfvars"
terraform apply -var-file="environments/prod/terraform.tfvars" -auto-approve

# Detect drift
terraform plan -var-file="environments/prod/terraform.tfvars" | grep -i "will be" 

# Module debugging
terraform get -update
terraform validate -var-file="environments/prod/terraform.tfvars"
```

### GCP / GKE Commands
```bash
# Project setup
gcloud projects list
gcloud config set project devops-hybrid-cloud
gcloud config get-value project

# GKE clusters
gcloud container clusters list
gcloud container clusters describe hybrid-cloud-cluster-prod --region us-central1

# Get cluster credentials
gcloud container clusters get-credentials hybrid-cloud-cluster-prod \
  --region us-central1 --project devops-hybrid-cloud

# GKE node pools
gcloud container node-pools list --cluster hybrid-cloud-cluster-prod --region us-central1
gcloud container node-pools create new-pool --cluster hybrid-cloud-cluster-prod \
  --region us-central1 --num-nodes 3

# GKE updates
gcloud container clusters upgrade hybrid-cloud-cluster-prod \
  --master --cluster-version 1.28 --region us-central1
gcloud container clusters upgrade hybrid-cloud-cluster-prod \
  --node-pool general --region us-central1

# GKE monitoring
gcloud monitoring metrics-descriptors list --filter="resource.type=k8s_cluster"
gcloud logging read "resource.type=k8s_cluster" --limit 10 --format json
```

### Kubernetes Commands
```bash
# Cluster info
kubectl cluster-info
kubectl get nodes
kubectl describe nodes

# Namespaces
kubectl get namespaces
kubectl create namespace production
kubectl delete namespace development

# Deployments
kubectl get deployments -n production
kubectl describe deployment hybrid-app -n production
kubectl logs deployment/hybrid-app -n production
kubectl scale deployment hybrid-app --replicas=15 -n production
kubectl rollout status deployment/hybrid-app -n production
kubectl rollout history deployment/hybrid-app -n production
kubectl rollout undo deployment/hybrid-app -n production

# Pods
kubectl get pods -n production
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
kubectl exec -it <pod-name> -n production -- /bin/bash
kubectl delete pod <pod-name> -n production

# Services
kubectl get svc -n production
kubectl describe svc hybrid-app -n production
kubectl port-forward svc/hybrid-app 8080:80 -n production

# ConfigMaps & Secrets
kubectl get configmaps -n production
kubectl get secrets -n production
kubectl create secret generic db-creds --from-literal=password=secret -n production
kubectl edit configmap app-config -n production

# Horizontal Pod Autoscaler
kubectl get hpa -n production
kubectl autoscale deployment hybrid-app --min=5 --max=20 -n production

# Resource quotas
kubectl get resourcequotas -n production
kubectl describe resourcequota pods-quota -n production

# Events
kubectl get events -n production
kubectl get events -n production --sort-by='.lastTimestamp'

# Debugging
kubectl top nodes
kubectl top pods -n production
kubectl describe pvc <pvc-name> -n production
kubectl get pv
```

### Docker Commands
```bash
# Image management
docker images
docker search ubuntu
docker pull gcr.io/devops-hybrid-cloud/devops-hybrid-app:latest
docker build -t devops-hybrid-app:v1 .
docker tag devops-hybrid-app:v1 gcr.io/devops-hybrid-cloud/devops-hybrid-app:v1
docker push gcr.io/devops-hybrid-cloud/devops-hybrid-app:v1

# Container operations
docker run -d --name hybrid-app -p 8080:8080 devops-hybrid-app:v1
docker ps
docker logs hybrid-app
docker exec -it hybrid-app /bin/bash
docker stop hybrid-app
docker rm hybrid-app

# Image scanning
docker scan devops-hybrid-app:v1
trivy image devops-hybrid-app:v1

# Cleanup
docker system prune -a
docker image prune -a
docker container prune
```

### Ansible Commands
```bash
# Playbook execution
ansible-playbook playbooks/site.yml
ansible-playbook playbooks/site.yml -i inventory/production.ini
ansible-playbook playbooks/site.yml --tags security
ansible-playbook playbooks/site.yml --skip-tags docker

# Inventory management
ansible-inventory -i inventory/production.ini --list
ansible-inventory -i inventory/dynamic_gke.py --list

# Ad-hoc commands
ansible all -i inventory/production.ini -m ping
ansible all -i inventory/production.ini -m setup
ansible all -i inventory/production.ini -m command -a "df -h"

# Playbook validation
ansible-playbook playbooks/site.yml --syntax-check
ansible-playbook playbooks/site.yml --check (dry-run)

# Debugging
ansible-playbook playbooks/site.yml -vv
ansible-playbook playbooks/site.yml -e "ansible_python_interpreter=/usr/bin/python3"
```

### Jenkins Commands
```bash
# Get admin password
kubectl exec -it svc/jenkins -n jenkins -- cat /run/secrets/additional/chart-admin-secret/jenkins-admin-password

# Jenkins CLI (after installing jenkins-cli.jar)
java -jar jenkins-cli.jar -s http://localhost:8080/ list-jobs
java -jar jenkins-cli.jar -s http://localhost:8080/ get-job "job-name" > job.xml
java -jar jenkins-cli.jar -s http://localhost:8080/ build "job-name"

# Port forward
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

### Prometheus & Grafana Commands
```bash
# Port forward to Prometheus
kubectl port-forward -n monitoring svc/prometheus-operated 9090:9090

# Port forward to Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Query Prometheus API
curl 'http://localhost:9090/api/v1/query?query=up'
curl 'http://localhost:9090/api/v1/query_range?query=up&start=1640995200&end=1640998800&step=60'

# Check alert rules
curl 'http://localhost:9090/api/v1/rules'

# Health check
curl http://localhost:9090/-/healthy
```

---

## TROUBLESHOOTING GUIDE

### Cluster Issues

**Pods not starting**
```bash
kubectl describe pod <pod-name> -n production
kubectl logs <pod-name> -n production
kubectl get events -n production
```

**Node not ready**
```bash
kubectl describe node <node-name>
gcloud compute ssh <instance-name> --zone us-central1-a
journalctl -u kubelet -n 100
```

**Network connectivity issues**
```bash
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never
# Inside pod:
curl http://service-name:port
nslookup service-name
ping pod-ip
```

**Resource exhaustion**
```bash
kubectl top nodes
kubectl top pods -n production --sort-by=memory
kubectl describe resourcequota -n production
```

### Database Issues

**RDS connectivity**
```bash
# Test from pod
kubectl exec -it <pod-name> -n production -- bash
psql -h rds-endpoint -U admin -d applicationdb -c "\dt"

# Check security groups
aws ec2 describe-security-groups --group-ids sg-xxx
aws ec2 authorize-security-group-ingress --group-id sg-xxx \
  --protocol tcp --port 5432 --cidr 10.0.0.0/8
```

**Slow queries**
```bash
# Enable query logging
aws rds describe-db-instances --db-instance-identifier production-rds
aws rds modify-db-instance --db-instance-identifier production-rds \
  --enable-cloudwatch-logs-exports postgresql

# Check logs
aws logs tail /aws/rds/instance/production-rds/postgresql --follow
```

### Monitoring Issues

**Prometheus targets down**
```bash
# Visit Prometheus UI
http://localhost:9090/targets

# Check service discovery
kubectl get endpoints -n monitoring
kubectl describe service prometheus-operated -n monitoring
```

**No metrics appearing**
```bash
# Verify scrape configs
kubectl exec prometheus-operated-0 -n monitoring -- cat /etc/prometheus/prometheus.yml

# Check pod annotations
kubectl get pods -n production -o jsonpath='{range .items[*]}{.metadata.annotations.prometheus\.io/scrape}{"\n"}{end}'
```

### Deployment Issues

**Stuck rollout**
```bash
kubectl rollout history deployment/hybrid-app -n production
kubectl rollout undo deployment/hybrid-app -n production
kubectl set image deployment/hybrid-app hybrid-app=<image> --record -n production
kubectl patch deployment hybrid-app -p "{\"spec\":{\"progressDeadlineSeconds\":600}}" -n production
```

**ImagePullBackOff**
```bash
# Check image availability
docker pull gcr.io/devops-hybrid-cloud/devops-hybrid-app:tag

# Verify credentials
kubectl get secrets -n production
kubectl describe secret docker-registry-credentials -n production

# Fix credentials if needed
kubectl create secret docker-registry gcr-secret \
  --docker-server=gcr.io \
  --docker-username=_json_key \
  --docker-password="$(cat terraform-key.json)" \
  -n production
```

### Cost Optimization

**Find expensive resources**
```bash
# GCP
gcloud compute instances list --sort-by=MACHINE_TYPE
gcloud container node-pools list --cluster hybrid-cloud-cluster-prod

# AWS
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]'
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceClass,MultiAZ]'

# Azure
az vm list --query "[].{Name:name, Size:hardwareProfile.vmSize}"
az container list --query "[].{Name:name, Cpu:containers[0].resources.requests.cpu}"
```

**Reduce costs**
```bash
# Scale down non-prod environments
kubectl scale deployment hybrid-app --replicas=3 -n development

# Use preemptible nodes (GCP)
gcloud container node-pools create preemptible-pool \
  --cluster hybrid-cloud-cluster-staging \
  --preemptible --num-nodes 3

# Use spot instances (AWS)
# Terraform configuration already includes this option
```

---

## MONITORING DASHBOARDS

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
- Replication lag (if applicable)

**Cost Metrics**
- Compute hours
- Storage usage
- Data transfer
- API calls

### Alert Thresholds (Production)

```
CPU Usage > 80%              → WARNING
CPU Usage > 95%              → CRITICAL

Memory Usage > 85%           → WARNING
Memory Usage > 95%           → CRITICAL

Pod Crash Loop               → CRITICAL
Node Not Ready > 5min        → CRITICAL

Error Rate > 1%              → WARNING
Error Rate > 5%              → CRITICAL

Response Time p95 > 1s       → WARNING
Response Time p95 > 5s       → CRITICAL

Database Replication Lag > 1s → WARNING
Database Replication Lag > 5s → CRITICAL
```

---

## SECURITY CHECKLIST

- [ ] All images scanned for vulnerabilities (Trivy)
- [ ] Network policies enforced (deny all, allow specific)
- [ ] RBAC properly configured (least privilege)
- [ ] Secrets encrypted at rest (KMS)
- [ ] Pod security policies enabled
- [ ] Resource quotas enforced per namespace
- [ ] Audit logging enabled
- [ ] SSH key rotation schedule
- [ ] Regular backup testing
- [ ] Disaster recovery drills (quarterly)
- [ ] Security patches applied (monthly)
- [ ] Compliance audits passed
- [ ] Data encryption in transit (TLS)
- [ ] Secrets never in logs or images

---

## MAINTENANCE SCHEDULE

### Daily
- [ ] Monitor Prometheus/Grafana dashboards
- [ ] Check alert notifications
- [ ] Verify application health endpoints

### Weekly
- [ ] Review cluster metrics trends
- [ ] Check cost reports
- [ ] Review security logs

### Monthly
- [ ] Test disaster recovery procedures
- [ ] Update dependencies
- [ ] Review and update documentation
- [ ] Capacity planning review

### Quarterly
- [ ] Security audit
- [ ] Compliance review
- [ ] Performance optimization review
- [ ] Cost optimization analysis

### Annually
- [ ] Full infrastructure audit
- [ ] Disaster recovery drill
- [ ] Security penetration test
- [ ] Strategic architecture review

---

## USEFUL LINKS & RESOURCES

**Official Documentation**
- https://www.terraform.io/docs
- https://kubernetes.io/docs
- https://prometheus.io/docs
- https://grafana.com/docs
- https://cloud.google.com/kubernetes-engine/docs
- https://docs.ansible.com

**Community & Support**
- Kubernetes Slack: https://slack.k8s.io
- CNCF Community: https://www.cncf.io
- Stack Overflow: Tag kubernetes, terraform, devops
- GitHub Issues: For tool-specific issues

**Learning Resources**
- Linux Academy
- A Cloud Guru
- Pluralsight
- YouTube Channels: Kube Academy, TechWorld with Nana

---

## PROJECT COMPLETION CHECKLIST

- [ ] All infrastructure provisioned
- [ ] Applications deployed successfully
- [ ] Monitoring stack operational
- [ ] CI/CD pipelines configured
- [ ] Load testing completed
- [ ] Failover testing completed
- [ ] Database backups verified
- [ ] Security scans passed
- [ ] Documentation complete
- [ ] Team trained
- [ ] Runbooks created
- [ ] Disaster recovery plan documented
- [ ] Cost baseline established
- [ ] Performance baselines recorded

---

**Last Updated:** December 2025 | **Version:** 1.0
**For support:** devops-team@example.com