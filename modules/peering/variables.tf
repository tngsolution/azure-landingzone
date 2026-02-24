variable "src_vnet_name" {
  description = "Name of the source VNet"
  type        = string
}

variable "src_resource_group_name" {
  description = "Resource group of the source VNet"
  type        = string
}

variable "dst_vnet_name" {
  description = "Name of the destination VNet"
  type        = string
}

variable "dst_vnet_id" {
  description = "ID of the destination VNet"
  type        = string
}

variable "peering_name" {
  description = "Optional explicit peering name suffix"
  type        = string
  default     = null
}

variable "allow_gateway_transit" {
  description = "Allow source VNet to offer gateway transit to destination"
  type        = bool
  default     = false
}

variable "allow_forwarded_traffic" {
  description = "Allow forwarded traffic between source and destination"
  type        = bool
  default     = true
}
