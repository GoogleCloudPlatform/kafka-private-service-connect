# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Copyright 2023 Google. This software is provided as-is, without warranty or representation for any use or purpose. Your use of it is subject to your agreement with Google.

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
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_scope  = "VPC_SCOPE"
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






