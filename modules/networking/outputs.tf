output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet IDs keyed by subnet name"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "nsg_id" {
  description = "ID of the default NSG"
  value       = azurerm_network_security_group.default.id
}
