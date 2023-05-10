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
  purpose = "PRIVATE_SERVICE_CONNECT"
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
  purpose = "PRIVATE_SERVICE_CONNECT"
}



