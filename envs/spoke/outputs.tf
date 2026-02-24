output "resource_group_name" {
  value = azurerm_resource_group.spoke.name
}

output "resource_group_network_name" {
  value = azurerm_resource_group.network.name
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