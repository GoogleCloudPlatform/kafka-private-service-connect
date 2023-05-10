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