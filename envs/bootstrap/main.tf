resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "tfstate" {
  name                              = local.storage_account_name
  resource_group_name               = azurerm_resource_group.tfstate.name
  location                          = var.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  min_tls_version                   = "TLS1_2"
  https_traffic_only_enabled        = true
  shared_access_key_enabled         = true
  allow_nested_items_to_be_public   = false
  public_network_access_enabled     = false
  infrastructure_encryption_enabled = true

  tags = local.tags

  identity {
    type = "SystemAssigned"
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    ip_rules       = var.allowed_ip_rules
  }

  #   blob_properties {
  #     versioning_enabled = true

  #     delete_retention_policy {
  #       days = 30
  #     }
  #   }
}

# Create a container for each stack
# Note: we could also use a single container with different state file names, but this way we can set different access policies if needed
resource "azurerm_storage_container" "tfstate" {
  for_each = toset(local.containers)

  name                  = each.key
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

# Grant the current user permissions to manage state files
# Note: in a real-world scenario, you would want to grant access to a group or service principal instead of individual users
resource "azurerm_role_assignment" "tfstate_contributor" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Output the backend config block to be copied in each stack
data "azurerm_client_config" "current" {}