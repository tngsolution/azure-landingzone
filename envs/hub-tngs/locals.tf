locals {
  suffix = "${var.workload}-${var.environment}-${var.location_short}-${var.instance}"

  resource_group_name         = var.resource_group_name != null ? var.resource_group_name : "rg-${local.suffix}"
  resource_group_network_name = "rg-${local.suffix}-network"
  resource_group_config_name  = "${local.resource_group_name}-config"
  app_configuration_name      = var.app_configuration_name != null ? var.app_configuration_name : "appcs-hub-${var.project}-${var.environment}-${var.location_short}-${var.instance}"

  vnet_name = "vnet-${local.suffix}"

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
