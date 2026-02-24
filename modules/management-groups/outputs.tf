//  Copyright (c) Microsoft Corporation.  All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.

// Output the IDs of the created management groups, keyed by the management group ID.
output "management_group_ids" {
  value = {
    for k, v in azurerm_management_group.this :
    k => v.id
  }
}
