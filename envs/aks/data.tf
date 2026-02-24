data "terraform_remote_state" "spoke" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.tfstate_resource_group_name
    storage_account_name = var.tfstate_storage_account_name
    container_name       = coalesce(var.spoke_state_container_name, "spoke-${var.environment}")
    use_azuread_auth     = true
    subscription_id      = var.subscription_id
    key                  = var.spoke_state_key
  }
}

data "azurerm_client_config" "current" {}

data "azurerm_app_configuration" "source" {
  count = var.read_admin_group_from_app_configuration ? 1 : 0

  name                = coalesce(var.source_app_configuration_name, local.default_source_app_configuration_name)
  resource_group_name = coalesce(var.source_app_configuration_resource_group_name, "${data.terraform_remote_state.spoke.outputs.resource_group_name}-config")
}

data "azurerm_app_configuration_key" "source_admin_group_object_id" {
  count = var.read_admin_group_from_app_configuration ? 1 : 0

  configuration_store_id = data.azurerm_app_configuration.source[0].id
  key                    = "security/admin_group_object_id"
}
