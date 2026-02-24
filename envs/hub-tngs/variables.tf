variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = null
}

variable "workload" {
  description = "Workload or project name used in resource naming"
  type        = string
  default     = "hub"
}

variable "environment" {
  description = "Environment (prd, dev, stg, tst)"
  type        = string
  default     = "prd"

  validation {
    condition     = contains(["prd", "dev", "stg", "tst"], var.environment)
    error_message = "Environment must be one of: prd, dev, stg, tst."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "francecentral"
}

variable "location_short" {
  description = "Short code for the Azure region used in naming (e.g. frc, weu, eus)"
  type        = string
  default     = "frc"
}

variable "instance" {
  description = "Instance number for the resource (e.g. 001)"
  type        = string
  default     = "001"
}

variable "resource_group_name" {
  description = "Name of the resource group (overrides auto-generated name if set)"
  type        = string
  default     = null
}

variable "address_space" {
  description = "Address space for the Hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "gateway_subnet_prefix" {
  description = "Address prefix for GatewaySubnet"
  type        = string
  default     = "10.0.0.0/27"
}

variable "firewall_subnet_prefix" {
  description = "Address prefix for AzureFirewallSubnet"
  type        = string
  default     = "10.0.1.0/26"
}

variable "bastion_subnet_prefix" {
  description = "Address prefix for AzureBastionSubnet"
  type        = string
  default     = "10.0.2.0/26"
}

variable "management_subnet_prefix" {
  description = "Address prefix for the management subnet"
  type        = string
  default     = "10.0.3.0/24"
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
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
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

variable "app_configuration_rbac_propagation_wait" {
  description = "Delay to wait after RBAC assignment before creating App Configuration keys"
  type        = string
  default     = "180s"
}
