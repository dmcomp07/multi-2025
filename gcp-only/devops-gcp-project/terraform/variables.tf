variable "gcp_project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "gcp_region" {
  type        = string
  default     = "us-central1"
  description = "GCP region"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "cluster_name" {
  type        = string
  description = "GKE cluster name"
}

variable "cluster_node_count" {
  type        = number
  description = "Initial node count"
}

variable "min_node_count" {
  type        = number
  description = "Minimum nodes for autoscaling"
}

variable "max_node_count" {
  type        = number
  description = "Maximum nodes for autoscaling"
}

variable "machine_type" {
  type        = string
  default     = "n1-standard-4"
  description = "Node machine type"
}

variable "cloudsql_instance_name" {
  type        = string
  description = "Cloud SQL instance name"
}

variable "cloudsql_tier" {
  type        = string
  description = "Cloud SQL tier"
}
