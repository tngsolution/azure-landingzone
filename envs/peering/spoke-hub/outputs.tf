output "spoke_to_hub_peering_id" {
  description = "Peering ID for spoke -> hub"
  value       = module.spoke_to_hub.src_to_dst_id
}
