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

# VPC
resource "google_compute_network" "vpc" {
  project = var.project
  depends_on = [
    time_sleep.apis_propagation
  ]
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet for gke cluster
resource "google_compute_subnetwork" "gke-subnet" {
  project = var.project
  depends_on = [
    google_compute_network.vpc
  ]
  name          = "${var.region}-gke-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
  secondary_ip_range {
    range_name    = "services-range-0"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges-0"
    ip_cidr_range = "192.168.64.0/22"
  }
}

resource "google_compute_subnetwork" "psc-subnet" {
  project = var.project
  depends_on = [
    google_compute_network.vpc
  ]
  name          = "${var.region}-psc-subnet-bootstrap"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.2.0.0/24"
  purpose       = "PRIVATE_SERVICE_CONNECT"
}
resource "google_compute_subnetwork" "psc-subnet-broker" {
  project = var.project
  depends_on = [
    google_compute_network.vpc
  ]
  name          = "${var.region}-psc-subnet-broker-0"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.4.0.0/24"
  purpose       = "PRIVATE_SERVICE_CONNECT"
}



