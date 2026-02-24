output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "containers" {
  value = { for k, v in azurerm_storage_container.tfstate : k => v.name }
}
