resource "google_artifact_registry_repository" "my-repo" {
  depends_on = [
    time_sleep.apis_propagation
  ]
  project = var.project
  location      = var.region
  repository_id = "docker-repo"
  description   = "Docker hub remote repo"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"
  remote_repository_config {
    description = "docker hub"
    docker_repository {
      public_repository = "DOCKER_HUB"
    }
  }
}



resource "google_cloud_run_service" "kafka-ui" {
  depends_on = [
    time_sleep.apis_propagation, google_vpc_access_connector.connector, google_compute_network.vpc
  ]
  project = var.project
  name     = "kafka-ui-cr"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project}/docker-repo/provectuslabs/kafka-ui"
        env {
          name = "DYNAMIC_CONFIG_ENABLED"
          value = "true"
        }
      }
    }
    metadata {
      annotations = {
        # Limit scale up to prevent any cost blow outs!
        # Use the VPC Connector
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.connector.name
        # all egress from the service should go through the VPC Connector
        "run.googleapis.com/vpc-access-egress" = "all-traffic"
      }
    }
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.kafka-ui.location
  project     = google_cloud_run_service.kafka-ui.project
  service     = google_cloud_run_service.kafka-ui.name

  policy_data = data.google_iam_policy.noauth.policy_data
}