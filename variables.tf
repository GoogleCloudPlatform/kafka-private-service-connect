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
  default = false
}

variable "consumer-creation" {
  description = "Configure PSC consumer project"
  type        = bool
  default = false
}

variable "consumer-project" {
  description = "Consumer project name"
  type        = string
  default = ""
}
variable "bootstrap-rule" {
  description = "Bootstrap ILB forwarding rule ID"
  type        = string
  default = "0"
}
variable "broker-rule" {
  description = "Broker ILB forwarding rule ID"
  type        = string
  default = "0"
}
