resource "google_compute_service_attachment" "bootstrap_service_attachment" {
  count = var.psc-creation ? 1 : 0
  project = var.project
  provider    = google-beta
  name        = "bootstrap-service"
  region      =  var.region
  description = "A service attachment configured with Terraform for Kafka Bootstrap server"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [google_compute_subnetwork.psc-subnet.name]
  target_service        = var.bootstrap-rule
}

resource "google_compute_service_attachment" "broker_service_attachment" {
  count = var.psc-creation ? 1 : 0
  project = var.project
  provider    = google-beta
  name        = "broker-service"
  region      =  var.region
  description = "A service attachment configured with Terraform for Kafka Broker-0 server"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [google_compute_subnetwork.psc-subnet-broker.name]
  target_service        = var.broker-rule
}