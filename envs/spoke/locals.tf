locals {
  suffix = "${var.workload}-${var.environment}-${var.location_short}-${var.instance}"

  resource_group_name         = var.resource_group_name != null ? var.resource_group_name : "rg-${local.suffix}"
  resource_group_network_name = "${local.resource_group_name}-network"

  vnet_name = "vnet-${local.suffix}"
  nsg_name  = "nsg-${local.suffix}"

  tags = merge(var.tags, {
    environment = var.environment
    team        = var.team
    project     = var.project
    name        = local.suffix
    workload    = var.workload
    location    = var.location
    managed_by  = "terraform"
  })
}
