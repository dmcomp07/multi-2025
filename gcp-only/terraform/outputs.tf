output "cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE cluster name"
}

output "cluster_endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "GKE cluster endpoint"
  sensitive   = true
}

output "cloud_sql_private_ip" {
  value       = google_sql_database_instance.main.private_ip_address
  description = "Cloud SQL private IP"
}

output "cloud_sql_connection_name" {
  value       = google_sql_database_instance.main.connection_name
  description = "Cloud SQL connection name"
}

output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "VPC network name"
}
