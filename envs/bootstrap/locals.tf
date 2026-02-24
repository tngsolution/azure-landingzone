locals {
  suffix = "${var.workload}-${var.environment}-${var.location_short}-${var.instance}"

  resource_group_name = "rg-${local.suffix}-tfstate"
  # Pas de tirets, max 24 caractères
  storage_account_name = var.sa_suffix #"sttfstate${var.workload}${var.environment}${var.location_short}"

  containers = [
    "hub-tngs",
    "spoke-dev",
    "spoke-stg",
    "spoke-prd",
    "peering",
    "hub-spokes",
  ]

  tags = merge(var.tags, {
    environment = var.environment
    team        = var.team
    project     = var.project
    name        = "tfstate-${local.suffix}"
    workload    = var.workload
    location    = var.location
    managed_by  = "terraform"
  })
}
