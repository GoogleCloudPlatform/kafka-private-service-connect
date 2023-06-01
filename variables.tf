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
variable "region" {
  description = "Region where a GKE cluster has to be created"
  type        = string
  default     = "europe-west2"
}

variable "project" {
  description = "Project kafka name"
  type        = string
}
variable "psc-creation" {
  description = "Create PSC endpoint. "
  type        = bool
  default     = false
}

variable "consumer-creation" {
  description = "Configure PSC consumer project"
  type        = bool
  default     = false
}

variable "consumer-project" {
  description = "Consumer project name"
  type        = string
  default     = ""
}
variable "bootstrap-rule" {
  description = "Bootstrap ILB forwarding rule ID"
  type        = string
  default     = "0"
}
variable "broker-rule" {
  description = "Broker ILB forwarding rule ID"
  type        = string
  default     = "0"
}
