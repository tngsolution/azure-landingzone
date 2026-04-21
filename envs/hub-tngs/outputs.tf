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

output "resource_group_compute_name" {
  description = "Name of the compute resource group"
  value       = azurerm_resource_group.compute.name
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

output "hub_address_space" {
  description = "Address space of the Hub VNet"
  value       = var.address_space
}

output "bastion_host_id" {
  description = "ID of the Azure Bastion Host"
  value       = azurerm_bastion_host.this.id
}

output "bastion_host_name" {
  description = "Name of the Azure Bastion Host"
  value       = azurerm_bastion_host.this.name
}

# output "bastion_public_ip_id" {
#   description = "ID of the Bastion public IP"
#   value       = azurerm_public_ip.bastion.id
# }
