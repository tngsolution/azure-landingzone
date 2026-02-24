output "hub_to_spokes_peering_ids" {
  description = "Map of peering IDs created from hub to spokes"
  value = {
    for k, v in module.hub_to_spokes : k => v.src_to_dst_id
  }
}
