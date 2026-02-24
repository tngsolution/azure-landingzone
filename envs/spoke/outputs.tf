output "resource_group_name" {
  value = azurerm_resource_group.spoke.name
}

output "resource_group_network_name" {
  value = azurerm_resource_group.network.name
}

output "resource_group_config_name" {
  value = azurerm_resource_group.config.name
}

output "spoke_vnet_id" {
  value = module.spoke_vnet.vnet_id
}

output "spoke_vnet_name" {
  value = module.spoke_vnet.vnet_name
}

output "subnet_ids" {
  value = module.spoke_vnet.subnet_ids
}

output "nsg_id" {
  value = module.spoke_vnet.nsg_id
}

output "app_configuration_id" {
  value = try(azurerm_app_configuration.spoke[0].id, null)
}

output "app_configuration_name" {
  value = try(azurerm_app_configuration.spoke[0].name, null)
}

output "app_configuration_endpoint" {
  value = try(azurerm_app_configuration.spoke[0].endpoint, null)
}
