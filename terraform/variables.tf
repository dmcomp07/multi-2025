variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "gcp_region" {
  type        = string
  description = "GCP region for resources"
}

variable "cluster_name" {
  type        = string
  description = "Kubernetes cluster name"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "initial_node_count" {
  type        = number
  description = "Initial number of nodes"
  default     = 3
}

variable "min_nodes" {
  type        = number
  description = "Minimum number of nodes"
}

variable "max_nodes" {
  type        = number
  description = "Maximum number of nodes"
}

variable "machine_type" {
  type        = string
  description = "GKE node machine type"
  default     = "n1-standard-2"
}

variable "memory_machine_type" {
  type        = string
  description = "High-memory node machine type"
  default     = "n1-highmem-4"
}

variable "preemptible_nodes" {
  type        = bool
  description = "Use preemptible nodes to reduce costs"
  default     = false
}

variable "min_cpu" {
  type        = number
  description = "Minimum CPU for cluster autoscaling"
}

variable "max_cpu" {
  type        = number
  description = "Maximum CPU for cluster autoscaling"
}

variable "min_memory" {
  type        = number
  description = "Minimum memory (GB) for cluster autoscaling"
}

variable "max_memory" {
  type        = number
  description = "Maximum memory (GB) for cluster autoscaling"
}

variable "db_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GB"
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "db_name" {
  type        = string
  description = "RDS database name"
  sensitive   = true
}

variable "db_username" {
  type        = string
  description = "RDS master username"
  sensitive   = true
}

variable "azure_region" {
  type        = string
  description = "Azure region"
}

variable "azure_node_count" {
  type        = number
  description = "Number of nodes in Azure cluster"
}

variable "azure_vm_size" {
  type        = string
  description = "Azure VM size"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "10.0.0.0/8"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.28"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default = {
    Project   = "devops-hybrid-cloud"
    ManagedBy = "Terraform"
  }
}
