# Bootstrap Stack

## Purpose
This stack bootstraps Terraform state infrastructure in Azure.

It creates the shared storage resources used by other stacks for remote state.

## What This Stack Creates
- Resource group for tfstate
- Storage account for tfstate
- Blob containers for stack states (for example `hub-tngs`, `spoke-dev`, `spoke-stg`, `spoke-prd`, `peering`, `hub-spokes`)
- Role assignment (`Storage Blob Data Contributor`) for the current principal

## Inputs
Main file:
- `terraform.tfvars`

Key variables:
- `subscription_id`
- `location`, `location_short`
- `workload`, `environment`, `instance`
- `sa_suffix`
- `allowed_ip_rules`

## Prerequisites
- Azure login in the platform subscription
- Sufficient rights to create RG, Storage Account, containers, and RBAC assignments

## Deploy
```bash
make az-switch
make az-whoami

make init STACK=envs/bootstrap
make plan STACK=envs/bootstrap
make apply STACK=envs/bootstrap
```

## Outputs
- `resource_group_name`
- `storage_account_name`
- `containers`

Use these outputs to configure backend files in other stacks.
