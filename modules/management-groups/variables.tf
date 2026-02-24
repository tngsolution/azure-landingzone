//  Copyright (c) Microsoft Corporation.  All rights reserved.
//  Licensed under the MIT License. See LICENSE in the project root for license information.


// The ID of the root management group under which the management groups will be created.
variable "root_id" {
  type = string
}

// The management groups to create, keyed by the management group ID.
// The management group ID must be unique within the tenant and can only contain lowercase letters,
// numbers, and hyphens. It must start with a letter and end with a letter or number.
// The display name is the friendly name of the management group that will be shown in the Azure portal.
// The parent ID is the ID of the parent management group or subscription under which this management group will be created.
variable "management_groups" {
  type = map(object({
    display_name = string
    parent_id    = string
  }))
}
