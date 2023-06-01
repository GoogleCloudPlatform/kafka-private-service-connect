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
  description = "Region where your consumer will be deployed"
  type        = string
  default     = "europe-west2"
}

variable "project" {
  description = "Project consumer name"
  type        = string
}

variable "kafka-project" {
  description = "Project name where Kafka is deployed"
  type        = string
}
variable "kafka-region" {
  description = "Project name where Kafka is deployed"
  type        = string
}

variable "bootstrap-target" {
  description = "Bootstrap target name"
  type        = string
}

variable "broker-target" {
  description = "broker target name"
  type        = string
}