output "resource_group_name" {
  description = "Name of the main resource group"
  value       = azurerm_resource_group.hub.name
}

output "resource_group_network_name" {
  description = "Name of the network resource group"
  value       = azurerm_resource_group.network.name
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