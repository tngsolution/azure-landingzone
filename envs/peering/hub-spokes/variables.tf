variable "subscription_id" {
  description = "Hub subscription ID"
  type        = string
}

variable "tfstate_resource_group_name" {
  description = "Resource group of the tfstate storage account"
  type        = string
}

variable "tfstate_storage_account_name" {
  description = "Name of the tfstate storage account"
  type        = string
}

variable "spokes" {
  description = "Map of spokes to peer from hub (one-way: hub -> spoke)"
  type = map(object({
    container_name          = string
    allow_gateway_transit   = optional(bool, false)
    allow_forwarded_traffic = optional(bool, true)
  }))
  default = {}
}
