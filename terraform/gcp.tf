# GCP GKE Configuration
resource "google_container_cluster" "primary" {
  name     = "${var.cluster_name}-${var.environment}"
  location = var.gcp_region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = "default"
  subnetwork = "default"

  addons_config {
    http_load_balancing {
      disabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    network_policy_config {
      disabled = false
    }
  }

  enable_network_policy = true

  cluster_autoscaling {
    enabled = true
    resource_limits {
      resource_type = "cpu"
      min_limit     = var.min_cpu
      max_limit     = var.max_cpu
    }
    resource_limits {
      resource_type = "memory"
      min_limit     = var.min_memory
      max_limit     = var.max_memory
    }
  }

  labels = var.common_tags
}

# General purpose node pool
resource "google_container_node_pool" "general" {
  name       = "${var.cluster_name}-general-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = var.initial_node_count

  autoscaling {
    min_node_count = var.min_nodes
    max_node_count = var.max_nodes
  }

  node_config {
    preemptible  = var.preemptible_nodes
    machine_type = var.machine_type
    disk_size_gb = 100

    labels = merge(
      var.common_tags,
      {
        pool_type = "general"
      }
    )

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append"
    ]

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}

# Memory-optimized node pool for data processing
resource "google_container_node_pool" "memory_optimized" {
  count      = var.memory_pool_node_count > 0 ? 1 : 0
  name       = "${var.cluster_name}-memory-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = var.memory_pool_node_count

  autoscaling {
    min_node_count = 0
    max_node_count = var.max_nodes
  }

  node_config {
    preemptible  = var.preemptible_nodes
    machine_type = var.memory_machine_type
    disk_size_gb = 100

    labels = merge(
      var.common_tags,
      {
        pool_type = "memory_optimized"
      }
    )

    taint {
      key    = "memory-optimized"
      value  = "true"
      effect = "NO_SCHEDULE"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }
}

# Configure kubectl access
resource "null_resource" "kubectl_config" {
  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials ${google_container_cluster.primary.name} --region ${var.gcp_region} --project ${var.gcp_project_id}"
  }

  depends_on = [google_container_node_pool.general]
}
