resource "azurerm_resource_group" "spoke" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "network" {
  name     = local.resource_group_network_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "config" {
  name     = local.resource_group_config_name
  location = var.location
  tags     = local.tags
}
