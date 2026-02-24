# Hub state
data "terraform_remote_state" "hub" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = "hub-tngs"
    use_azuread_auth     = true
    subscription_id      = var.subscription_id
    key                  = "terraform.tfstate"
  }
}

# Spokes states - dynamic
data "terraform_remote_state" "spokes" {
  for_each = var.spokes

  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = each.value.container_name
    use_azuread_auth     = true
    subscription_id      = var.subscription_id
    key                  = "terraform.tfstate"
  }
}
