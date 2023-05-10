resource "google_project_service" "apis-producer" {
  for_each = toset([
    # Note that appengine is required for both GAE and Cloud Tasks.
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "stackdriver.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "vpcaccess.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "run.googleapis.com"
  ])
  project = var.project
  service = each.value
}

// Wait a little while for the API's to enable consistently
resource "time_sleep" "apis_propagation" {
  depends_on = [
    google_project_service.apis-producer
  ]
  create_duration = "30s"
}
