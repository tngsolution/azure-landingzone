variable "subscription_id" {
  description = "Azure subscription ID where AKS is deployed"
  type        = string
  default     = null
}

variable "workload" {
  description = "Workload name used in resource naming"
  type        = string
  default     = "tngs-aks"
}

variable "environment" {
  description = "Environment (prd, dev, stg, tst)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["prd", "dev", "stg", "tst"], var.environment)
    error_message = "Environment must be one of: prd, dev, stg, tst."
  }
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "francecentral"
}

variable "location_short" {
  description = "Short code for Azure region used in naming"
  type        = string
  default     = "frc"
}

variable "instance" {
  description = "Instance number for resource naming"
  type        = string
  default     = "001"
}

variable "resource_group_name" {
  description = "AKS resource group name. If null, default is rg-<project>-aks-<env>-<loc>-<instance>"
  type        = string
  default     = null
}

variable "tfstate_resource_group_name" {
  description = "Resource group of the tfstate storage account"
  type        = string
  default     = "rg-tngs-hub-prd-frc-001-tfstate"
}

variable "tfstate_storage_account_name" {
  description = "Name of the tfstate storage account"
  type        = string
  default     = "tfsttgnsprdfrc1"
}

variable "spoke_state_container_name" {
  description = "Container name containing spoke state"
  type        = string
  default     = null
}

variable "spoke_state_key" {
  description = "State key for spoke stack"
  type        = string
  default     = "terraform.tfstate"
}

variable "cluster_name" {
  description = "AKS cluster suffix name (for example cluster-v134)"
  type        = string
}

variable "cluster_enabled" {
  description = "Whether the AKS cluster should exist in this state"
  type        = bool
  default     = true
}

variable "aks_subnet_name" {
  description = "AKS subnet name looked up from spoke state outputs.subnet_ids"
  type        = string
}

variable "kubernetes_version" {
  description = "AKS Kubernetes version"
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "Enable private AKS API endpoint"
  type        = bool
  default     = true
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = true
}

variable "aks_admin_group_object_ids" {
  description = "Entra ID group object IDs granted AKS admin access"
  type        = list(string)
  default     = []
}

variable "read_admin_group_from_app_configuration" {
  description = "Read AKS admin group object ID from Azure App Configuration"
  type        = bool
  default     = true
}

variable "source_app_configuration_name" {
  description = "Source App Configuration name for reading AKS admin group. If null, spoke naming convention is used"
  type        = string
  default     = null
}

variable "source_app_configuration_resource_group_name" {
  description = "Source App Configuration resource group name. If null, '<spoke_resource_group_name>-config' is used"
  type        = string
  default     = null
}

variable "sku_tier" {
  description = "AKS SKU tier"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be one of: Free, Standard, Premium."
  }
}

variable "dns_prefix" {
  description = "Custom DNS prefix for AKS. If null, one is generated"
  type        = string
  default     = null
}

variable "node_resource_group_name" {
  description = "Dedicated node resource group for VMSS. If null, a default name is generated"
  type        = string
  default     = null
}

variable "system_node_count" {
  description = "System node pool node count"
  type        = number
  default     = 2
}

variable "system_node_vm_size" {
  description = "System node pool VM size"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "system_node_os_disk_size_gb" {
  description = "System node pool OS disk size in GB"
  type        = number
  default     = 128
}

variable "system_node_max_pods" {
  description = "Maximum pods per system node"
  type        = number
  default     = 50
}

variable "availability_zones" {
  description = "Availability zones for system node pool"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "admin_username" {
  description = "Linux admin username for AKS node profile"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for AKS nodes. If null, linux_profile is omitted"
  type        = string
  default     = null
}

variable "team" {
  description = "Team owning the resource (required by TNGS policy)"
  type        = string
  default     = "platform"
}

variable "project" {
  description = "Project name (required by TNGS policy)"
  type        = string
  default     = "tngs"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
