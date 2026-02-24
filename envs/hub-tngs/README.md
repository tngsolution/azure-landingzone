# Hub Stack

## Purpose
This stack deploys the central hub networking layer.

It provides the shared hub VNet and core subnets used by spokes and connectivity components.

## What This Stack Creates
- Main hub resource group
- Hub network resource group (`-network`)
- Hub VNet
- Hub subnets:
  - `GatewaySubnet`
  - `AzureFirewallSubnet`
  - `AzureBastionSubnet`
  - `snet-management-<suffix>`
- Default NSG and subnet associations (handled by the networking module)

## Inputs and File Layout
- Backend file: `backend.hcl`
- Variables file: `terraform.tfvars`

Key variables:
- `subscription_id`
- `workload`, `environment`, `location`, `location_short`, `instance`
- `address_space`
- subnet prefixes (`gateway`, `firewall`, `bastion`, `management`)
- `nsg_rules`

## Prerequisites
- Azure login in the hub/platform subscription
- Bootstrap stack already applied (tfstate storage exists)

## Deploy
```bash
make az-switch
make az-whoami

make init STACK=envs/hub-tngs
make plan STACK=envs/hub-tngs
make apply STACK=envs/hub-tngs
```

## Outputs
- `resource_group_name`
- `resource_group_network_name`
- `hub_vnet_id`
- `hub_vnet_name`
- `subnet_ids`
- `nsg_id`

These outputs are consumed by peering and downstream stacks.
