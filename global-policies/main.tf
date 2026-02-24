// This file defines policy assignments at the management group level for the landing zones. 
//It includes policies to restrict resource group locations, require mandatory tags, deny public IPs, restrict regions, and more.

// The policies are assigned to the management group specified in the variables, 
// and parameters are passed to customize the behavior of each policy assignment.
resource "azurerm_management_group_policy_assignment" "restrict_rg_location" {
  name                 = "restrict-rg-location"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = azurerm_policy_definition.restrict_rg_location.id

  display_name = "Restrict Resource Group Locations"

  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
  })
}

// Custom policy to require multiple mandatory tags on resources
resource "azurerm_management_group_policy_assignment" "require_mandatory_tags_assign" {
  name                 = "require-mandatory-tags"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = azurerm_policy_definition.require_mandatory_tags.id
}

#############################
# POLICY ASSIGNMENTS
#############################

# 1️⃣ Deny Public IP

resource "azurerm_management_group_policy_assignment" "deny_public_ip" {
  name                 = "deny-public-ip"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = data.azurerm_policy_definition.deny_public_ip.id

  display_name = "Deny Public IP on NIC"
  description  = "Prevents creation of public IPs on network interfaces"
}

# 2️⃣ Restrict Regions

resource "azurerm_management_group_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id

  display_name = "Restrict Regions"

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

# 3️⃣ Require Tag

#############################
# POLICY ASSIGNMENTS (LOOP)
#############################

resource "azurerm_management_group_policy_assignment" "require_tags" {
  for_each = toset(var.required_tags)

  name                 = "require-tag-${each.value}"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = data.azurerm_policy_definition.require_tag.id

  display_name = "Require tag ${each.value}"

  parameters = jsonencode({
    tagName = {
      value = each.value
    }
  })
}

// 4️⃣ Restrict VM SKUs
resource "azurerm_management_group_policy_assignment" "allowed_vm_skus" {
  name                 = "allowed-vm-skus"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = data.azurerm_policy_definition.allowed_vm_skus.id

  display_name = "Restrict allowed VM SKUs"

  parameters = jsonencode({
    listOfAllowedSKUs = {
      value = var.allowed_vm_skus
    }
  })
}

// 5️⃣ Not allowed resource types
resource "azurerm_management_group_policy_assignment" "deny_firewall" {
  name                 = "deny-azure-firewall"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = data.azurerm_policy_definition.not_allowed_resource_types.id

  display_name = "Deny Azure Firewall creation"

  parameters = jsonencode({
    listOfResourceTypesNotAllowed = {
      value = [
        "Microsoft.Network/azureFirewalls"
      ]
    }
  })
}

#############################
# POLICY ASSIGNMENT 
#############################
resource "azurerm_management_group_policy_assignment" "deny_expensive_network" {
  name                 = "deny-expensive-network"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = data.azurerm_policy_definition.not_allowed_resource_types.id

  parameters = jsonencode({
    listOfResourceTypesNotAllowed = {
      value = [
        "Microsoft.Network/applicationGateways",
        "Microsoft.Network/expressRouteCircuits",
        "Microsoft.Network/azureFirewalls"
      ]
    }
  })
}

resource "azurerm_management_group_policy_assignment" "append_tags" {
  for_each = var.default_tags

  name                 = "append-tag-${each.key}"
  management_group_id  = data.azurerm_management_group.landingzones.id
  policy_definition_id = data.azurerm_policy_definition.append_tag.id

  display_name = "Append tag ${each.key}"

  parameters = jsonencode({
    tagName = {
      value = each.key
    }
    tagValue = {
      value = each.value
    }
  })
}