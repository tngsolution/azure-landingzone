output "resource_group_name" {
  description = "Name of the main resource group"
  value       = azurerm_resource_group.hub.name
}

output "resource_group_network_name" {
  description = "Name of the network resource group"
  value       = azurerm_resource_group.network.name
}

output "resource_group_config_name" {
  description = "Name of the config resource group"
  value       = azurerm_resource_group.config.name
}

output "hub_vnet_id" {
  description = "ID of the Hub VNet"
  value       = module.hub_vnet.vnet_id
}

output "hub_vnet_name" {
  description = "Name of the Hub VNet"
  value       = module.hub_vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of all hub subnet IDs"
  value       = module.hub_vnet.subnet_ids
}

output "nsg_id" {
  description = "ID of the default NSG"
  value       = module.hub_vnet.nsg_id
}

output "app_configuration_id" {
  description = "Hub App Configuration resource ID"
  value       = try(azurerm_app_configuration.hub[0].id, null)
}

output "app_configuration_name" {
  description = "Hub App Configuration name"
  value       = try(azurerm_app_configuration.hub[0].name, null)
}

output "app_configuration_endpoint" {
  description = "Hub App Configuration endpoint"
  value       = try(azurerm_app_configuration.hub[0].endpoint, null)
}
