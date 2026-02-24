data "terraform_remote_state" "spoke" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.spoke_state_container_name
    use_azuread_auth     = true
    subscription_id      = var.subscription_id
    key                  = var.spoke_state_key
  }
}

data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = var.hub_state_container_name
    use_azuread_auth     = true
    subscription_id      = var.subscription_id
    key                  = var.hub_state_key
  }
}
