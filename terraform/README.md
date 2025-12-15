# Terraform Module Documentation

This directory contains reusable Terraform modules for infrastructure components.

## Available Modules

### GKE Module
- **Location**: `modules/gke/`
- **Purpose**: Deploy and manage Google Kubernetes Engine clusters
- **Features**:
  - Multi-zone node pools
  - Auto-scaling configuration
  - Security hardening
  - Network policies
  - Monitoring integration

### RDS Module
- **Location**: `modules/rds/`
- **Purpose**: Deploy and manage AWS RDS databases
- **Features**:
  - Multi-AZ support
  - Automated backups
  - Performance insights
  - Parameter group management
  - Encryption at rest

### Networking Module
- **Location**: `modules/networking/`
- **Purpose**: Setup VPCs, subnets, and security groups
- **Features**:
  - VPC creation
  - Subnet management
  - Security group rules
  - NAT gateway setup
  - Route table configuration

## Using Modules

### Example: Use GKE Module
```hcl
module "gke_cluster" {
  source = "./modules/gke"
  
  cluster_name     = "my-cluster"
  gcp_project_id   = var.gcp_project_id
  gcp_region       = var.gcp_region
  initial_node_count = 3
  min_nodes        = 3
  max_nodes        = 10
}
```

### Example: Use RDS Module
```hcl
module "rds_database" {
  source = "./modules/rds"
  
  allocated_storage = 100
  engine           = "postgres"
  instance_class   = "db.t3.micro"
  db_name          = "mydb"
  username         = "admin"
}
```

## Module Development

When creating new modules:
1. Create a directory under `modules/`
2. Create `main.tf`, `variables.tf`, `outputs.tf`
3. Add comprehensive documentation
4. Test with `terraform validate`
5. Use consistent naming conventions

## Best Practices

- Keep modules focused and reusable
- Use descriptive variable names
- Provide default values where appropriate
- Document all variables and outputs
- Use consistent formatting (`terraform fmt`)
- Test before publishing
