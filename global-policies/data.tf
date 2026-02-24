#############################
# DATA SOURCES
#############################

data "azurerm_management_group" "landingzones" {
  name = var.management_group_name
}

#############################
# BUILT-IN POLICY DEFINITIONS
#############################

data "azurerm_policy_definition" "append_tag" {
  display_name = "Append a tag and its value to resources"
}

data "azurerm_policy_definition" "deny_public_ip" {
  display_name = "Network interfaces should not have public IPs"
}

data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag on resources"
}

data "azurerm_policy_definition" "allowed_vm_skus" {
  display_name = "Allowed virtual machine size SKUs"
}

data "azurerm_policy_definition" "not_allowed_resource_types" {
  display_name = "Not allowed resource types"
}