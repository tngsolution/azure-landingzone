variable "management_group_name" {
  type        = string
  description = "Name of the Management Group"
}

variable "allowed_locations" {
  type        = list(string)
  description = "Allowed Azure regions"
}

variable "required_tags" {
  type        = list(string)
  description = "List of mandatory tags"
}

variable "allowed_vm_skus" {
  type        = list(string)
  description = "List of allowed VM SKUs"
}

variable "default_tags" {
  type = map(string)
}