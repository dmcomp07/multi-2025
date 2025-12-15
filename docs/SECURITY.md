# Security Best Practices

## Infrastructure Security

### Kubernetes Security

**Network Policies**
```yaml
# Deny all traffic by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

**Pod Security**
- Run as non-root user
- Read-only root filesystem
- No privilege escalation
- Drop all Linux capabilities
- SELinux labels

**RBAC Configuration**
- Least privilege access
- Role-based access control
- Service account per application
- Regular audit of permissions

### Data Security

**Encryption**
- TLS 1.2+ for all traffic (in-transit)
- KMS encryption for RDS (at-rest)
- Secrets encrypted in etcd
- SSL certificates with valid CN

**Secrets Management**
- Never in Git or Docker images
- Use Kubernetes Secrets
- Rotate regularly (90 days)
- Use secret management tool (Vault, AWS Secrets Manager)

**Database Security**
- Strong passwords (16+ characters)
- Network policies restrict access
- SSL/TLS connections
- Audit logging enabled
- Regular backups encrypted

### Access Control

**SSH Hardening**
- Disable password authentication
- Disable root login
- Use SSH keys only
- Restrict SSH port
- Monitor failed attempts (fail2ban)

**Firewall Rules**
- Allow-list approach
- Restrict inbound to necessary ports
- Deny all by default
- Regular audit of rules

## Container Security

### Image Security

**Scanning**
- Scan all images before deployment
- Use Trivy or Aqua for vulnerability scanning
- Block deployment of high-severity vulnerabilities
- Regular baseline scanning

**Image Best Practices**
- Use specific version tags (no 'latest')
- Minimal base images (Alpine, Distroless)
- Regular updates of base images
- Remove unnecessary packages

### Registry Security
- Authenticate to registry
- Use private registries
- Image signing (Cosign)
- Access logs

## Compliance & Audit

### Logging & Monitoring

**Audit Logging**
- Kubernetes API audit logs
- Application logs
- System logs
- Database query logs

**Log Retention**
- 30 days minimum for prod
- Centralized log aggregation
- Immutable storage

### Compliance Checklist

- [ ] All images scanned for vulnerabilities
- [ ] Network policies enforced
- [ ] RBAC properly configured
- [ ] Secrets encrypted
- [ ] Pod security policies enabled
- [ ] Resource quotas enforced
- [ ] Audit logging enabled
- [ ] SSH keys rotated (90 days)
- [ ] Backups tested (monthly)
- [ ] DR drills (quarterly)
- [ ] Security patches applied (monthly)
- [ ] TLS certificates valid
- [ ] No hardcoded credentials

## Incident Response

### Procedures

1. **Detection**
   - Monitor alerts
   - Review logs
   - Check metrics

2. **Response**
   - Isolate affected components
   - Preserve logs/evidence
   - Notify stakeholders
   - Document actions

3. **Recovery**
   - Restore from clean backup
   - Verify no malware
   - Update configurations
   - Redeploy services

4. **Post-Incident**
   - Root cause analysis
   - Update security procedures
   - Implement preventive measures
   - Document lessons learned

## Vulnerability Management

### Regular Activities

- **Weekly**: Review security alerts
- **Monthly**: Apply patches, update dependencies
- **Quarterly**: Penetration testing, security audit
- **Annually**: Full security review, SOC 2 audit

### Patch Management
- Subscribe to security advisories
- Test patches in staging
- Apply to production within 30 days
- Critical vulnerabilities: 24-48 hours

## Third-Party Risk

- Vet all third-party tools
- Review licenses
- Monitor for vulnerabilities
- Maintain inventory
- Regular assessment

## Documentation

- Security policies
- Incident response plan
- Disaster recovery plan
- Change management procedure
- Access control policy
