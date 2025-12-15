output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.primary.name
}

output "gke_cluster_host" {
  description = "GKE cluster host"
  value       = "https://${google_container_cluster.primary.endpoint}"
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.production.endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.production.db_name
}

output "rds_master_username" {
  description = "RDS master username"
  value       = aws_db_instance.production.username
  sensitive   = true
}

output "azure_kubernetes_cluster_name" {
  description = "Azure AKS cluster name"
  value       = azurerm_kubernetes_cluster.secondary.name
}

output "azure_sql_server_name" {
  description = "Azure SQL server name"
  value       = azurerm_mssql_server.main.name
}

output "azure_storage_account_name" {
  description = "Azure storage account name"
  value       = azurerm_storage_account.main.name
}

output "kubeconfig_command" {
  description = "Command to get kubeconfig"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
}
