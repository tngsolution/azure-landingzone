# Peering Hub to Spokes Stack

## Purpose
This stack creates one-way VNet peering from the hub to all configured spokes.

Direction managed by this stack:
- `hub -> spoke-*`

## What This Stack Creates
For each entry in `spokes`:
- `azurerm_virtual_network_peering` named `peer-hub-to-<spoke>`

It reads:
- Hub remote state (`hub-tngs`)
- Spoke remote states (`spoke-dev`, `spoke-stg`, `spoke-prd`, ...)

## Inputs
Main file:
- `terraform.tfvars` with:
  - `subscription_id`
  - `tfstate_resource_group_name`
  - `tfstate_storage_account_name`
  - `spokes` map

## Prerequisites
- Azure login in the hub subscription
- Hub and spoke VNets already deployed
- Remote state containers available and readable

## Deploy
```bash
make az-switch
make az-whoami

make init STACK=envs/peering/hub-spokes
make plan STACK=envs/peering/hub-spokes
make apply STACK=envs/peering/hub-spokes
```

## Notes
This stack only creates the forward direction. Return peering (`spoke -> hub`) is handled by `envs/peering/spoke-hub`.
