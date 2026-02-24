resource "azurerm_app_configuration" "hub" {
  count = var.app_configuration_enabled ? 1 : 0

  name                = local.app_configuration_name
  resource_group_name = azurerm_resource_group.config.name
  location            = var.location
  sku                 = "free"
  tags                = local.tags
}
