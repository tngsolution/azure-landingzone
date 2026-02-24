variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# variable "subnets" {
#   description = "Map of subnets to create"
#   type = map(object({
#     address_prefixes  = list(string)
#     service_endpoints = optional(list(string), [])
#   }))
#   default = {}
# }

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Disabled")
    private_link_service_network_policies_enabled = optional(bool, false)
    default_outbound_access_enabled               = optional(bool, false)
  }))
  default = {}
}

variable "nsg_rules" {
  description = <<EOT
List of NSG rules in compact pipe-delimited format:
"name|priority|direction|access|protocol|source_port|dest_port|source_prefix|dest_prefix"

Example:
  "AllowHTTPS|100|Inbound|Allow|Tcp|*|443|*|*"
  "AllowSSH|110|Inbound|Allow|Tcp|*|22|10.0.0.0/8|*"
  "DenyAll|4000|Inbound|Deny|*|*|*|Internet|*"
EOT
  type        = list(string)
  default = [
    "DenyInternetInbound|4000|Inbound|Deny|*|*|*|Internet|*"
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}