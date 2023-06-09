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

module "customer" {
  count            = var.consumer-creation ? 1 : 0
  source           = "./consumer_module"
  bootstrap-target = google_compute_service_attachment.bootstrap_service_attachment[count.index].name
  broker-target    = google_compute_service_attachment.broker_service_attachment[count.index].name
  kafka-project    = var.project
  kafka-region     = var.region
  project          = var.consumer-project
}