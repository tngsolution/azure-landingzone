variable "workload" {
  type    = string
  default = "tngs"
}

variable "environment" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["prd", "dev", "stg", "tst"], var.environment)
    error_message = "Environment must be one of: prd, dev, stg, tst."
  }
}

variable "location" {
  type    = string
  default = "francecentral"
}

variable "location_short" {
  type    = string
  default = "frc"
}

variable "instance" {
  type    = string
  default = "001"
}

variable "subscription_id" {
  type    = string
  default = null
}

variable "resource_group_name" {
  type    = string
  default = null
}

variable "team" {
  description = "Team owning the resource (required by TNGS policy)"
  type        = string
  default     = "platform"
}

variable "project" {
  description = "Project name (required by TNGS policy)"
  type        = string
  default     = "tngs"
}

variable "address_space" {
  type    = list(string)
  default = ["10.1.0.0/16"]
}

variable "subnets" {
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
  }))
  default = {}
}

variable "nsg_rules" {
  description = <<EOT
NSG rules in pipe-delimited format:
"name|priority|direction|access|protocol|source_port|dest_port|source_prefix|dest_prefix"
EOT
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "app_configuration_enabled" {
  description = "Deploy Azure App Configuration store"
  type        = bool
  default     = true
}

variable "app_configuration_name" {
  description = "Custom App Configuration name. If null, a default naming convention is used"
  type        = string
  default     = null
}

variable "admin_group_name" {
  description = "Admin Entra group display name to store in App Configuration"
  type        = string
  default     = null
}

variable "admin_group_object_id" {
  description = "Admin Entra group object ID to store in App Configuration"
  type        = string
  default     = null
}

variable "app_configuration_values" {
  description = "Additional key-values to store in App Configuration"
  type        = map(string)
  default     = {}
}
