module "hub_to_spokes" {
  for_each = var.spokes

  source = "../../../modules/peering"

  peering_name = "hub-to-${each.key}"

  src_vnet_name           = data.terraform_remote_state.hub.outputs.hub_vnet_name
  src_resource_group_name = data.terraform_remote_state.hub.outputs.resource_group_network_name

  dst_vnet_name = data.terraform_remote_state.spokes[each.key].outputs.spoke_vnet_name
  dst_vnet_id   = data.terraform_remote_state.spokes[each.key].outputs.spoke_vnet_id

  allow_gateway_transit   = each.value.allow_gateway_transit
  allow_forwarded_traffic = each.value.allow_forwarded_traffic
}
