locals {
  # Parse each pipe-delimited rule string into a structured object
  nsg_rules_parsed = {
    for rule in var.nsg_rules :
    split("|", rule)[0] => {
      name                       = split("|", rule)[0]
      priority                   = tonumber(split("|", rule)[1])
      direction                  = split("|", rule)[2]
      access                     = split("|", rule)[3]
      protocol                   = split("|", rule)[4]
      source_port_range          = split("|", rule)[5]
      destination_port_range     = split("|", rule)[6]
      source_address_prefix      = split("|", rule)[7]
      destination_address_prefix = split("|", rule)[8]
    }
  }
}