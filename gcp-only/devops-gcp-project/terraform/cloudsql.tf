resource "google_sql_database_instance" "main" {
  name                = var.cloudsql_instance_name
  database_version    = "POSTGRES_15"
  region              = var.gcp_region
  deletion_protection = var.environment == "prod" ? true : false

  settings {
    tier      = var.cloudsql_tier
    disk_size = 50
    disk_type = "PD_SSD"

    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }

    ip_configuration {
      private_network = google_compute_network.vpc.id
      require_ssl     = true
    }
  }

  depends_on = [google_service_networking_connection.private_vpc]
}

resource "google_sql_database" "database" {
  name     = "applicationdb"
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "app_user" {
  name     = "app_user"
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 32
  special = true
}
