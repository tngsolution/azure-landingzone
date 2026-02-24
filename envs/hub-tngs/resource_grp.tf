resource "azurerm_resource_group" "hub" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "network" {
  name     = local.resource_group_network_name
  location = var.location
  tags     = local.tags
}
