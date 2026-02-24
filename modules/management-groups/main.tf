//  Copyright (c) Microsoft Corporation.  All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.

//The ID of the root management group under which the management groups will be created.
resource "azurerm_management_group" "this" {
  for_each = var.management_groups

  name                       = each.key
  display_name               = each.value.display_name
  parent_management_group_id = each.value.parent_id
}
