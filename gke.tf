# GKE cluster
resource "google_container_cluster" "primary" {
  provider = google-beta
  project  = var.project
  depends_on = [
    google_compute_subnetwork.gke-subnet
  ]

  name                      = "kafka-cluster"
  location                  = var.region
  remove_default_node_pool  = false
  initial_node_count        = 2
  network                   = google_compute_network.vpc.name
  subnetwork                = google_compute_subnetwork.gke-subnet.name
  default_max_pods_per_node = 32
  dns_config {
    cluster_dns = "CLOUD_DNS"
    cluster_dns_scope = "VPC_SCOPE"
    cluster_dns_domain = "kafkademo.io"
  }

  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }
  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "CONTROLLER_MANAGER", "SCHEDULER"]

    managed_prometheus {
      enabled = true
    }
  }
  release_channel {
    channel = "REGULAR"
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/logging.admin",
      "https://www.googleapis.com/auth/logging.write"
    ]
    machine_type = "e2-standard-4"
    tags = [
      var.region
    ]

  }
  networking_mode = "VPC_NATIVE"
  addons_config {
    config_connector_config {
      enabled = true
    }
  }
  ip_allocation_policy {
    cluster_secondary_range_name  = "pod-ranges-0"
    services_secondary_range_name = "services-range-0"
  }
  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

}






