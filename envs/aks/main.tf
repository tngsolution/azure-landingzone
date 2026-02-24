resource "azurerm_resource_group" "aks" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  count = var.cluster_enabled ? 1 : 0

  name                              = local.aks_cluster_name
  location                          = var.location
  resource_group_name               = azurerm_resource_group.aks.name
  dns_prefix                        = coalesce(var.dns_prefix, "aks-${var.environment}-${var.location_short}-${var.instance}-${var.cluster_name}")
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  sku_tier                          = var.sku_tier
  node_resource_group               = coalesce(var.node_resource_group_name, "rg-${local.resource_group_suffix}-${var.cluster_name}-vmss")

  default_node_pool {
    name                         = "system"
    node_count                   = var.system_node_count
    vm_size                      = var.system_node_vm_size
    os_disk_size_gb              = var.system_node_os_disk_size_gb
    max_pods                     = var.system_node_max_pods
    zones                        = var.availability_zones
    vnet_subnet_id               = data.terraform_remote_state.spoke.outputs.subnet_ids[var.aks_subnet_name]
    temporary_name_for_rotation  = "systemtmp"
    type                         = "VirtualMachineScaleSets"
    only_critical_addons_enabled = true
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = var.azure_rbac_enabled
    admin_group_object_ids = local.effective_aks_admin_group_object_ids
    tenant_id              = data.azurerm_client_config.current.tenant_id
  }

  dynamic "linux_profile" {
    for_each = var.ssh_public_key == null ? [] : [1]
    content {
      admin_username = var.admin_username
      ssh_key {
        key_data = var.ssh_public_key
      }
    }
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  tags = merge(local.tags, {
    aks_cluster_key = var.cluster_name
  })

  depends_on = [azurerm_resource_group.aks]
}
