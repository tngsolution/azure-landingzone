# Global Policies Stack

## Purpose
This stack assigns governance policies at the management group level.

It enforces baseline controls such as allowed regions, mandatory tags, restricted resource types, and VM SKU limits.

## What This Stack Creates
Policy assignments on the target management group, including:
- Restrict resource group locations
- Require mandatory tags
- Deny public IP on NIC
- Restrict allowed regions
- Restrict VM SKUs
- Deny selected expensive or disallowed network resource types
- Append default tags

## Inputs
Main file:
- `terraform.tfvars`

Key variables:
- `management_group_name`
- `allowed_locations`
- `required_tags`
- `allowed_vm_skus`
- `default_tags`

## Prerequisites
- Azure login in a subscription/tenant with access to the target management group
- Permissions to read policy definitions and create policy assignments at management group scope

## Deploy
```bash
make az-switch
make az-whoami

make init STACK=global-policies
make plan STACK=global-policies
make apply STACK=global-policies
```

## Notes
- Policy assignments can have broad impact. Review `plan` carefully before `apply`.
- Changes may affect existing and future resources depending on each policy effect.
