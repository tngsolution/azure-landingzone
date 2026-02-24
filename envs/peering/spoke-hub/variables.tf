variable "subscription_id" {
  description = "Spoke subscription ID"
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

variable "spoke_name" {
  description = "Spoke name used in peering name (e.g. spoke-dev)"
  type        = string
}

variable "spoke_state_container_name" {
  description = "Container name containing spoke state"
  type        = string
}

variable "spoke_state_key" {
  description = "State key for spoke stack"
  type        = string
  default     = "terraform.tfstate"
}

variable "hub_state_container_name" {
  description = "Container name containing hub state"
  type        = string
  default     = "hub-tngs"
}

variable "hub_state_key" {
  description = "State key for hub stack"
  type        = string
  default     = "terraform.tfstate"
}

variable "allow_gateway_transit" {
  description = "Allow spoke to offer gateway transit to hub"
  type        = bool
  default     = false
}

variable "allow_forwarded_traffic" {
  description = "Allow forwarded traffic between spoke and hub"
  type        = bool
  default     = true
}
