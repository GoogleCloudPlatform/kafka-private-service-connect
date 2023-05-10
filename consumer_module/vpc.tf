# VPC
resource "google_compute_network" "vpc" {
  project = var.project
  depends_on = [
    time_sleep.apis_propagation
  ]
  name                    = "${var.project}-vpc"
  auto_create_subnetworks = "false"
}


resource "google_vpc_access_connector" "connector" {
  depends_on = [
    google_compute_subnetwork.psc-subnet-boot
  ]
  project       = var.project
  region        = var.region
  name          = "vpc-serverless-con"
  ip_cidr_range = "10.8.0.0/28"
  network       = "${var.project}-vpc"
}
resource "google_compute_subnetwork" "psc-subnet-boot" {
  project = var.project
  depends_on = [
    google_compute_network.vpc
  ]
  name          = "${var.region}-bootstrap-psc-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.100.0.0/24"

}
resource "google_compute_subnetwork" "psc-subnet-brok" {
  project = var.project
  depends_on = [
    google_compute_network.vpc
  ]
  name          = "${var.region}-broker-psc-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.52.0.0/24"
}

#static ip for broker server
resource "google_compute_address" "broker-ip" {
  project      = var.project
  name         = "broker-ip"
  subnetwork   = google_compute_subnetwork.psc-subnet-brok.id
  address_type = "INTERNAL"
  address      = "10.52.0.2"
  region       = var.region
}

#static ip for bootstrap server
resource "google_compute_address" "bootstrap-ip" {
  project      = var.project
  name         = "bootstrap-ip"
  subnetwork   = google_compute_subnetwork.psc-subnet-boot.id
  address_type = "INTERNAL"
  address      = "10.100.0.2"
  region       = var.region
}


resource "google_compute_forwarding_rule" "bootstrap-psc" {
  project                 = var.project
  provider                = google-beta
  name                    = "bootstrap-psc"
  region                  = var.region
  load_balancing_scheme   = ""
  target                  = "projects/${var.kafka-project}/regions/${var.region}/serviceAttachments/bootstrap-service"
  network                 = google_compute_network.vpc.name
  ip_address              = google_compute_address.bootstrap-ip.self_link
  allow_psc_global_access = true
}


resource "google_compute_forwarding_rule" "broker-psc" {
  project                 = var.project
  provider                = google-beta
  name                    = "broker-psc"
  region                  = var.region
  load_balancing_scheme   = ""
  target                  = "projects/${var.kafka-project}/regions/${var.region}/serviceAttachments/broker-service"
  network                 = google_compute_network.vpc.name
  ip_address              = google_compute_address.broker-ip.self_link
  allow_psc_global_access = true
}

resource "google_dns_record_set" "a-boot" {
  project                 = var.project
  name         = "kafka-boootstrap.${google_dns_managed_zone.kafka.dns_name}"
  managed_zone = google_dns_managed_zone.kafka.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_address.bootstrap-ip.address]
}

resource "google_dns_record_set" "a-brok" {
  project                 = var.project
  name         = "kafka-brok-0.${google_dns_managed_zone.kafka.dns_name}"
  managed_zone = google_dns_managed_zone.kafka.name
  type = "A"
  ttl  = 300

  rrdatas = [google_compute_address.broker-ip.address]
}

resource "google_dns_managed_zone" "kafka" {
  project                 = var.project
  visibility = "private"
  name     = "kafka-zone"
  dns_name = "kafka.demo.io."
  private_visibility_config {
    networks {
      network_url = google_compute_network.vpc.id
    }
  }
}

