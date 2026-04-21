output "resource_group_name" {
  value = azurerm_resource_group.spoke.name
}

output "resource_group_network_name" {
  value = azurerm_resource_group.network.name
}

output "resource_group_config_name" {
  value = azurerm_resource_group.config.name
}

output "resource_group_compute_name" {
  value = azurerm_resource_group.compute.name
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

output "route_table_id" {
  description = "ID of the spoke-to-hub route table"
  value       = azurerm_route_table.spoke_to_hub.id
}

output "route_table_name" {
  description = "Name of the spoke-to-hub route table"
  value       = azurerm_route_table.spoke_to_hub.name
}
