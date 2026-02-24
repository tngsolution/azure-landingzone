# src -> dst: create one-way VNet peering.
resource "azurerm_virtual_network_peering" "src_to_dst" {
  name                         = var.peering_name != null ? "peer-${var.peering_name}" : "peer-${var.src_vnet_name}-to-${var.dst_vnet_name}"
  resource_group_name          = var.src_resource_group_name
  virtual_network_name         = var.src_vnet_name
  remote_virtual_network_id    = var.dst_vnet_id
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  allow_virtual_network_access = true
}
