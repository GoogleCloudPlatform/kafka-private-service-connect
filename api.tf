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

resource "google_project_service" "apis" {
  for_each = toset([
    # Note that appengine is required for both GAE and Cloud Tasks.
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudtrace.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "stackdriver.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "gkehub.googleapis.com",
    "dns.googleapis.com",
    "vpcaccess.googleapis.com",
    "accesscontextmanager.googleapis.com"
  ])
  project = var.project
  service = each.value

}


// Wait a little while for the API's to enable consistently
resource "time_sleep" "apis_propagation" {
  depends_on = [
    google_project_service.apis
  ]
  create_duration = "30s"
}

