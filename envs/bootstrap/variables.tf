variable "subscription_id" {
  type    = string
  default = null
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "location_short" {
  type    = string
  default = "frc"
}

variable "workload" {
  type    = string
  default = "tngs"
}

variable "environment" {
  type    = string
  default = "prd"
}

variable "instance" {
  type    = string
  default = "001"
}

variable "team" {
  type    = string
  default = "platform"
}

variable "project" {
  type    = string
  default = "tngs"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "sa_suffix" {
  type    = string
  default = "tftgnshubprdfrc001"
}

variable "allowed_ip_rules" {
  description = "List of allowed IP addresses for the storage account"
  type        = list(string)
  default     = []
}

variable "enable_nsp" {
  description = "Enable Network Security Perimeter (preview feature)"
  type        = bool
  default     = false
}
