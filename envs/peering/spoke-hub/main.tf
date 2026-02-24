module "spoke_to_hub" {
  source = "../../../modules/peering"

  peering_name = "${var.spoke_name}-to-hub"

  src_vnet_name           = data.terraform_remote_state.spoke.outputs.spoke_vnet_name
  src_resource_group_name = data.terraform_remote_state.spoke.outputs.resource_group_network_name

  dst_vnet_name = data.terraform_remote_state.hub.outputs.hub_vnet_name
  dst_vnet_id   = data.terraform_remote_state.hub.outputs.hub_vnet_id

  allow_gateway_transit   = var.allow_gateway_transit
  allow_forwarded_traffic = var.allow_forwarded_traffic
}
