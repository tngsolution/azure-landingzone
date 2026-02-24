data "azurerm_client_config" "current" {}

resource "azurerm_app_configuration" "spoke" {
  count = var.app_configuration_enabled ? 1 : 0

  name                = local.app_configuration_name
  resource_group_name = azurerm_resource_group.config.name
  location            = var.location
  sku                 = "free"
  tags                = local.tags
}

resource "azurerm_role_assignment" "spoke_app_config_data_owner" {
  count = var.app_configuration_enabled ? 1 : 0

  scope                = azurerm_app_configuration.spoke[0].id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_app_configuration_key" "spoke" {
  for_each = var.app_configuration_enabled ? local.app_configuration_entries : {}

  configuration_store_id = azurerm_app_configuration.spoke[0].id
  key                    = each.key
  value                  = each.value

  depends_on = [azurerm_role_assignment.spoke_app_config_data_owner]
}
