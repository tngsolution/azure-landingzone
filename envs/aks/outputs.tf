output "resource_group_name" {
  description = "AKS resource group name"
  value       = azurerm_resource_group.aks.name
}

output "aks_cluster_name" {
  description = "AKS cluster name"
  value       = try(azurerm_kubernetes_cluster.this[0].name, null)
}

output "aks_cluster_id" {
  description = "AKS cluster resource ID"
  value       = try(azurerm_kubernetes_cluster.this[0].id, null)
}

output "aks_private_fqdn" {
  description = "AKS private FQDN"
  value       = try(azurerm_kubernetes_cluster.this[0].private_fqdn, null)
}

output "aks_fqdn" {
  description = "AKS public FQDN (if public cluster)"
  value       = try(azurerm_kubernetes_cluster.this[0].fqdn, null)
}

output "aks_identity_principal_id" {
  description = "AKS managed identity principal ID"
  value       = try(azurerm_kubernetes_cluster.this[0].identity[0].principal_id, null)
}

output "kubelet_identity_object_id" {
  description = "Kubelet managed identity object ID"
  value       = try(azurerm_kubernetes_cluster.this[0].kubelet_identity[0].object_id, null)
}

output "aks_subnet_id" {
  description = "AKS subnet ID"
  value       = data.terraform_remote_state.spoke.outputs.subnet_ids[var.aks_subnet_name]
}
