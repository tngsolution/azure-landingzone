# Peering Spoke to Hub Stack

## Purpose
This stack creates one-way VNet peering from one spoke to the hub.

Direction managed by this stack:
- `spoke-* -> hub`

Use it per spoke environment with dedicated backend and tfvars files.

## What This Stack Creates
- One `azurerm_virtual_network_peering` named `peer-<spoke>-to-hub`

It reads:
- Spoke remote state (selected spoke)
- Hub remote state (`hub-tngs`)

## Inputs and File Layout
- Backend files: `backends/spoke-<env>.backend.hcl`
- Variable files: `tfvars/spoke-<env>.tfvars`

Examples:
- `backends/spoke-stg.backend.hcl`
- `tfvars/spoke-stg.tfvars`

## Prerequisites
- Azure login in the target spoke subscription
- Spoke and hub VNets already deployed
- Remote state containers available and readable

## Deploy
```bash
make az-switch
make az-whoami

make init STACK=envs/peering/spoke-hub BACKEND_CONFIG=backends/spoke-stg.backend.hcl
make plan STACK=envs/peering/spoke-hub TFVARS=tfvars/spoke-stg.tfvars
make apply STACK=envs/peering/spoke-hub TFVARS=tfvars/spoke-stg.tfvars
```

## Backend Reconfiguration
If Terraform reports `Backend configuration changed`:
```bash
terraform -chdir=envs/peering/spoke-hub init -reconfigure -backend-config=backends/spoke-stg.backend.hcl
```
