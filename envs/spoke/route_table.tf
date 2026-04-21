resource "azurerm_route_table" "spoke_to_hub" {
  name                          = "rt-${local.suffix}-to-hub"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.network.name
  tags                          = local.tags
}

# Route to hub network via peering
resource "azurerm_route" "to_hub" {
  name                = "route-${local.suffix}-hub"
  resource_group_name = azurerm_resource_group.network.name
  route_table_name    = azurerm_route_table.spoke_to_hub.name
  address_prefix      = var.hub_address_space[0]
  next_hop_type       = "VnetLocal"
}

# Associate route table with all subnets
resource "azurerm_subnet_route_table_association" "spoke_to_hub" {
  for_each = {
    for k, v in var.subnets : k => v
    if !contains(["GatewaySubnet", "AzureFirewallSubnet", "AzureBastionSubnet"], k)
  }

  subnet_id      = module.spoke_vnet.subnet_ids[each.key]
  route_table_id = azurerm_route_table.spoke_to_hub.id
}
