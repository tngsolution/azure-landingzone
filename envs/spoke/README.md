# Spoke Stack

Landing zone architecture diagram: [root README](../../README.md#landing-zone-diagram)

## Purpose
This stack deploys one spoke virtual network environment (resource groups, VNet, subnets, NSG, and NSG associations).

Use this stack as the single reusable implementation for `dev`, `stg`, and `prd`.

## What This Stack Creates
- Resource group: `resource_group_name`
- Network resource group: `<resource_group_name>-network`
- Config resource group: `<resource_group_name>-config`
- VNet and subnets
- Default NSG and subnet associations
- App Configuration store (`Free`) for environment metadata

## Inputs and File Layout
- Backend files: `backends/<env>-backend.hcl`
- Variable files: `tfvars/spoke-<env>.tfvars`
- Optional App Configuration inputs:
- `app_configuration_enabled`, `app_configuration_name`
- `admin_group_name`, `admin_group_object_id`
- `app_configuration_values`

`admin_group_object_id` is recommended so Terraform manages key `security/admin_group_object_id` used by AKS.

Examples:
- `backends/dev-backend.hcl` + `tfvars/spoke-dev.tfvars`
- `backends/stg-backend.hcl` + `tfvars/spoke-stg.tfvars`

## Prerequisites
- Azure login in the target spoke subscription (`make az-switch`)
- Terraform initialized with the matching backend file
- State container exists in tfstate storage account (for example `spoke-stg`)

## Deploy
```bash
make az-switch
make az-whoami

make init STACK=envs/spoke BACKEND_CONFIG=backends/stg-backend.hcl
make plan STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
make apply STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
```

Important: always run `make init STACK=envs/spoke BACKEND_CONFIG=backends/<env>-backend.hcl` before `plan/apply` when you switch environment, otherwise Terraform can target the wrong state backend.

## Validate Existing State
```bash
terraform -chdir=envs/spoke state list
terraform -chdir=envs/spoke plan -var-file=tfvars/spoke-dev.tfvars
```

A safe migration from legacy stacks should show `No changes` for the matching environment.
