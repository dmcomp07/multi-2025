# Ansible Configuration

This directory contains Ansible playbooks and roles for infrastructure configuration management.

## Directory Structure

```
ansible/
├── ansible.cfg           # Ansible configuration
├── inventory/            # Inventory files
│   ├── production.ini
│   ├── staging.ini
│   ├── development.ini
│   └── dynamic_gke.py   # Dynamic inventory for GKE
├── playbooks/           # Playbooks
│   ├── site.yml
│   ├── provision.yml
│   ├── deploy.yml
│   ├── monitoring.yml
│   └── security.yml
├── roles/               # Reusable roles
│   ├── docker/
│   ├── kubernetes/
│   ├── prometheus/
│   ├── grafana/
│   ├── jenkins_agent/
│   ├── security/
│   ├── networking/
│   └── logging/
├── group_vars/          # Group variables
│   ├── all.yml
│   ├── gke.yml
│   ├── aws.yml
│   └── azure.yml
└── templates/           # Jinja2 templates
```

## Running Playbooks

### All Hosts
```bash
ansible-playbook playbooks/site.yml
```

### Specific Environment
```bash
ansible-playbook playbooks/site.yml -i inventory/production.ini
```

### Specific Tags
```bash
ansible-playbook playbooks/site.yml --tags security
```

### Dry Run (Check Mode)
```bash
ansible-playbook playbooks/site.yml --check
```

## Inventory Management

### Static Inventory
Edit `inventory/production.ini` and add hosts:
```ini
[production]
app1.example.com
app2.example.com

[monitoring]
monitor1.example.com
```

### Dynamic Inventory (GKE)
```bash
python inventory/dynamic_gke.py
```

## Creating Roles

### Role Structure
```
roles/my_role/
├── tasks/
│   └── main.yml         # Main tasks
├── handlers/
│   └── main.yml         # Event handlers
├── templates/
│   └── config.j2        # Jinja2 templates
├── files/
│   └── app.conf         # Static files
├── vars/
│   └── main.yml         # Role variables
├── defaults/
│   └── main.yml         # Default variables
└── README.md            # Role documentation
```

## Variables

### Group Variables
In `group_vars/production.yml`:
```yaml
# Variables for all production servers
docker_users:
  - ubuntu
  - root

docker_daemon_config:
  storage-driver: overlay2
```

### Host Variables
In `host_vars/app1.example.com.yml`:
```yaml
# Host-specific variables
docker_version: 20.10.21
```

## Best Practices

1. Use descriptive task names
2. Add comments for complex logic
3. Use handlers for service restarts
4. Validate syntax: `ansible-playbook --syntax-check`
5. Use tags for flexibility
6. Keep roles focused and reusable
7. Use variables instead of hardcoding values
8. Test in non-production first

## Debugging

```bash
# Verbose output
ansible-playbook playbooks/site.yml -v

# Very verbose
ansible-playbook playbooks/site.yml -vv

# Extra verbose
ansible-playbook playbooks/site.yml -vvv

# Debug specific host
ansible-playbook playbooks/site.yml -l hostname

# List hosts
ansible-inventory -i inventory/production.ini --list
```
