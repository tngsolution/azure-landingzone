# AKS Stack

## Purpose
This stack deploys an AKS cluster into an existing spoke subnet.

It is designed to plug into this landing zone after the spoke network is already created.

## What This Stack Creates
- AKS resource group
- One AKS cluster per state (`azurerm_kubernetes_cluster`)
- One system node pool attached to an existing spoke subnet
- One dedicated node resource group for VMSS per cluster

## Inputs and File Layout
- Backend files: `backends/<env>-<cluster>.backend.hcl`
- Generated variable files:
- `tfvars/aks-<env>.auto.tfvars.json` (base env)
- `tfvars/aks-<env>-<cluster>.auto.tfvars.json` (cluster)
- Templates: `templates/backend.hcl.j2`, `templates/terraform.tfvars.json.j2`, `templates/cluster.auto.tfvars.json.j2`

Key variables:
- `subscription_id`
- `tfstate_resource_group_name`
- `tfstate_storage_account_name`
- `spoke_state_container_name`
- `spoke_state_key`
- `cluster_name`
- `aks_subnet_name`
- `aks_admin_group_object_ids` (Entra ID admin groups)
- `read_admin_group_from_app_configuration`
- `source_app_configuration_name`, `source_app_configuration_resource_group_name`

## Naming Convention
- AKS resource group (default): `rg-<project>-aks-<env>-<loc>-<instance>`
- AKS cluster (default): `aks-<project>-<env>-<loc>-<instance>-<cluster>`
- VMSS node resource group per cluster (default): `rg-<project>-aks-<env>-<loc>-<instance>-<cluster>-vmss`

## Prerequisites
- Spoke stack deployed for the target environment (`envs/spoke`)
- AKS subnet exists in spoke state outputs (`subnet_ids`, for example `snet-aks-tngs-dev-frc-001`)
- Azure login in the target subscription (`make az-switch`)

## Deploy
```bash
make az-switch
make az-whoami

AKS_ADMIN_GROUP_OBJECT_ID="<entra-group-object-id>" make gen-aks ENVIRONMENT=dev CLUSTER_KEY=cluster-v134 KUBERNETES_VERSION=1.34

make init STACK=envs/aks BACKEND_CONFIG=backends/dev-cluster-v134.backend.hcl
make plan STACK=envs/aks TFVARS='tfvars/aks-dev.auto.tfvars.json -var-file=tfvars/aks-dev-cluster-v134.auto.tfvars.json'
make apply STACK=envs/aks TFVARS='tfvars/aks-dev.auto.tfvars.json -var-file=tfvars/aks-dev-cluster-v134.auto.tfvars.json'
```

The `gen-aks` script checks Terraform state for `azurerm_kubernetes_cluster.this[0]` and reports whether the cluster already exists.
By default, AKS reads Entra admin group object ID from App Configuration key `security/admin_group_object_id` in the spoke config store.
You can override source with `source_app_configuration_name` and `source_app_configuration_resource_group_name`.
If you disable App Configuration read (`read_admin_group_from_app_configuration = false`), use `aks_admin_group_object_ids`.

## Outputs
- `resource_group_name`
- `aks_cluster_name`
- `aks_cluster_id`
- `aks_private_fqdn`
- `aks_fqdn`
- `aks_identity_principal_id`
- `kubelet_identity_object_id`
- `aks_subnet_id`

## Multi-Cluster Upgrade Pattern
To run multiple Kubernetes versions in parallel (example `1.34` and `1.35`), create one state per cluster:
1. Create `cluster-v134`:
2. `make gen-aks ENVIRONMENT=dev CLUSTER_KEY=cluster-v134 KUBERNETES_VERSION=1.34`
3. `make init STACK=envs/aks BACKEND_CONFIG=backends/dev-cluster-v134.backend.hcl`
4. `make apply STACK=envs/aks TFVARS='tfvars/aks-dev.auto.tfvars.json -var-file=tfvars/aks-dev-cluster-v134.auto.tfvars.json'`
5. Create `cluster-v135`:
6. `make gen-aks ENVIRONMENT=dev CLUSTER_KEY=cluster-v135 KUBERNETES_VERSION=1.35`
7. `make init STACK=envs/aks BACKEND_CONFIG=backends/dev-cluster-v135.backend.hcl`
8. `make apply STACK=envs/aks TFVARS='tfvars/aks-dev.auto.tfvars.json -var-file=tfvars/aks-dev-cluster-v135.auto.tfvars.json'`
9. Migrate applications to the target cluster.
10. Destroy the old cluster:
11. `ACTION=remove make gen-aks ENVIRONMENT=dev CLUSTER_KEY=cluster-v134`
12. `make init STACK=envs/aks BACKEND_CONFIG=backends/dev-cluster-v134.backend.hcl`
13. `make apply STACK=envs/aks TFVARS='tfvars/aks-dev.auto.tfvars.json -var-file=tfvars/aks-dev-cluster-v134.auto.tfvars.json'`

## Example Cluster tfvars
```json
{
  "cluster_name": "cluster-v134",
  "cluster_enabled": true,
  "aks_subnet_name": "snet-aks-tngs-dev-frc-001",
  "kubernetes_version": "1.34",
  "private_cluster_enabled": true,
  "azure_rbac_enabled": true,
  "aks_admin_group_object_ids": [],
  "read_admin_group_from_app_configuration": true,
  "source_app_configuration_name": null,
  "source_app_configuration_resource_group_name": null,
  "system_node_count": 2,
  "system_node_vm_size": "Standard_D4s_v5",
  "node_resource_group_name": "rg-tngs-aks-dev-frc-001-cluster-v134-vmss"
}
```
