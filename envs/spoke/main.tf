module "spoke_vnet" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  vnet_name           = local.vnet_name
  address_space       = var.address_space
  subnets             = var.subnets
  nsg_rules           = var.nsg_rules
  tags                = local.tags

  depends_on = [azurerm_resource_group.network]
}
