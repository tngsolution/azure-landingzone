locals {
  resource_group_suffix                 = "${var.project}-aks-${var.environment}-${var.location_short}-${var.instance}"
  cluster_name_suffix                   = "${var.project}-${var.environment}-${var.location_short}-${var.instance}"
  aks_cluster_name                      = "aks-${local.cluster_name_suffix}-${var.cluster_name}"
  default_source_app_configuration_name = "appcs-spoke-${var.project}-${var.environment}-${var.location_short}-${var.instance}"
  resource_group_name                   = var.resource_group_name != null ? var.resource_group_name : "rg-${local.resource_group_suffix}"
  effective_aks_admin_group_object_ids  = var.read_admin_group_from_app_configuration ? compact([data.azurerm_app_configuration_key.source_admin_group_object_id[0].value]) : var.aks_admin_group_object_ids

  tags = merge(var.tags, {
    environment = var.environment
    team        = var.team
    project     = var.project
    name        = local.cluster_name_suffix
    workload    = var.workload
    location    = var.location
    managed_by  = "terraform"
  })
}
