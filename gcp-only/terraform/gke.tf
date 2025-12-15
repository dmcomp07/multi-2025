resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.cluster_subnet.name

  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  depends_on = [google_service_networking_connection.private_vpc]
}

resource "google_container_node_pool" "general" {
  name       = "${var.cluster_name}-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = var.cluster_node_count

  node_config {
    preemptible  = var.environment != "prod"
    machine_type = var.machine_type
    disk_size_gb = 100

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      environment = var.environment
    }
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
