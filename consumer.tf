module "customer" {
  count = var.consumer-creation ? 1 : 0
  source = "./consumer_module"
  bootstrap-target = google_compute_service_attachment.bootstrap_service_attachment[count.index].name
  broker-target = google_compute_service_attachment.broker_service_attachment[count.index].name
  kafka-project = var.project
  kafka-region = var.region
  project = var.consumer-project
}