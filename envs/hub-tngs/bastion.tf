# Public IP for Azure Bastion
# resource "azurerm_public_ip" "bastion" {
#   name                = "pip-bastion-${local.suffix}"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.compute.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
#   sku_tier            = "Regional"
#   tags                = local.tags
# }

# Azure Bastion Host
resource "azurerm_bastion_host" "this" {
  name                = "bas-${local.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.compute.name
  sku                 = try(var.bastion_sku, "Developer")
  virtual_network_id  = module.hub_vnet.vnet_id

#   ip_configuration {
#     name                 = "configuration"
#     subnet_id            = module.hub_vnet.subnet_ids["AzureBastionSubnet"]
#     public_ip_address_id = azurerm_public_ip.bastion.id
#   }

  tags = local.tags
}
