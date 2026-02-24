output "src_to_dst_id" {
  description = "ID of the source to destination peering"
  value       = azurerm_virtual_network_peering.src_to_dst.id
}
