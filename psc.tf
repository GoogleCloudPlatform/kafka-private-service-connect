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

resource "google_compute_service_attachment" "bootstrap_service_attachment" {
  count       = var.psc-creation ? 1 : 0
  project     = var.project
  provider    = google-beta
  name        = "bootstrap-service"
  region      = var.region
  description = "A service attachment configured with Terraform for Kafka Bootstrap server"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [google_compute_subnetwork.psc-subnet.name]
  target_service        = var.bootstrap-rule
}

resource "google_compute_service_attachment" "broker_service_attachment" {
  count       = var.psc-creation ? 1 : 0
  project     = var.project
  provider    = google-beta
  name        = "broker-service"
  region      = var.region
  description = "A service attachment configured with Terraform for Kafka Broker-0 server"

  enable_proxy_protocol = false
  connection_preference = "ACCEPT_AUTOMATIC"
  nat_subnets           = [google_compute_subnetwork.psc-subnet-broker.name]
  target_service        = var.broker-rule
}