resource "azurerm_policy_definition" "require_mandatory_tags" {
  name         = "tngs-require-mandatory-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "TNGS - Require mandatory tags"

  management_group_id = data.azurerm_management_group.landingzones.id

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "tags['environment']"
          exists = "false"
        },
        {
          field  = "tags['team']"
          exists = "false"
        },
        {
          field  = "tags['project']"
          exists = "false"
        },
        {
          field  = "tags['name']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "Deny"
    }
  })
}

resource "azurerm_policy_definition" "restrict_rg_location" {
  name         = "tngs-restrict-rg-location"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "TNGS - Restrict Resource Group Locations"

  management_group_id = data.azurerm_management_group.landingzones.id

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Resources/subscriptions/resourceGroups"
        },
        {
          field = "location"
          notIn = "[parameters('allowedLocations')]"
        }
      ]
    }
    then = {
      effect = "Deny"
    }
  })

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed locations"
        description = "The list of allowed locations for Resource Groups"
      }
    }
  })
}
