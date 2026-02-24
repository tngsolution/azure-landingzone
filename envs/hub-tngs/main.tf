module "hub_vnet" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.network.name
  location            = var.location
  vnet_name           = local.vnet_name
  address_space       = var.address_space

  subnets = {
    # Azure reserved names — cannot follow CAF prefix convention
    "GatewaySubnet" = {
      address_prefixes                = [var.gateway_subnet_prefix]
      default_outbound_access_enabled = true
    }
    "AzureFirewallSubnet" = {
      address_prefixes                = [var.firewall_subnet_prefix]
      default_outbound_access_enabled = true
    }
    "AzureBastionSubnet" = {
      address_prefixes                = [var.bastion_subnet_prefix]
      default_outbound_access_enabled = true
    }
    # CAF compliant subnet name
    "snet-management-${local.suffix}" = {
      address_prefixes                = [var.management_subnet_prefix]
      default_outbound_access_enabled = false
    }
  }

  nsg_rules = var.nsg_rules
  tags      = local.tags
}