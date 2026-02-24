# Azure Landing Zone (Hub and Spoke)

## Overview
This repository contains a Terraform-based Azure Landing Zone implementation using a hub-and-spoke network model.

The project is organized into reusable modules and environment stacks, with support for multi-subscription deployments and one-way peering in both directions.

## Architecture
- Hub stack: central networking and shared platform resources
- Spoke stack (generic): reusable spoke deployment for `dev`, `stg`, `prd`
- Peering stacks:
  - `hub -> spokes` (forward peering)
  - `spoke -> hub` (return peering, per spoke)
- Bootstrap stack: remote state storage (RG, Storage Account, blob containers)
- Global policies stack: management group policy assignments

## Repository Structure
- `modules/`: reusable Terraform modules
- `envs/`: deployable stacks
- `global-policies/`: policy assignment stack
- `scripts/`: configuration generation scripts
- `docs/`: operational documentation and runbooks
- `Makefile`: common operational commands

## Stack Documentation

Contribution guidelines: [CONTRIBUTING.md](CONTRIBUTING.md)

### Core Stacks
- [Bootstrap](envs/bootstrap/README.md)
- [Hub](envs/hub-tngs/README.md)
- [Spoke (Generic)](envs/spoke/README.md)
- [Peering Hub to Spokes](envs/peering/hub-spokes/README.md)
- [Peering Spoke to Hub](envs/peering/spoke-hub/README.md)
- [Global Policies](global-policies/README.md)

## Common Workflow
1. Select Azure subscription context
2. Initialize stack with the correct backend config
3. Run plan with the correct tfvars
4. Apply after review

Example:
```bash
make az-switch
make az-whoami

make init STACK=envs/spoke BACKEND_CONFIG=backends/stg-backend.hcl
make plan STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
make apply STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
```

## Configuration Conventions
- Backend files per environment: `backends/<env>-backend.hcl`
- Variable files per spoke/environment: `tfvars/spoke-<env>.tfvars`
- Remote state containers are managed by `envs/bootstrap`
- Spoke network resource group is derived as `<resource_group_name>-network`

## Peering Model
Because subscriptions can differ between hub and spokes, peering is split into two independent stacks:
- `envs/peering/hub-spokes`: creates `hub -> spoke`
- `envs/peering/spoke-hub`: creates `spoke -> hub`

This avoids requiring dual-provider permissions in a single Terraform run.

## Useful Make Targets
- Auth and context: `az-login`, `az-switch`, `az-whoami`, `az-list`
- Per stack: `init`, `plan`, `apply`, `deploy`, `destroy`, `validate`
- Helpers: `gen-spoke`, `gen-spoke-hub`, `gen-peering`

See `make help` for full command list.

## Notes
- Always verify subscription context before any `apply`.
- Review plan output carefully for resource replacement.
- Keep stack-specific docs up to date when changing behavior.

## Governance and Contribution
- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Code ownership rules: [.github/CODEOWNERS](.github/CODEOWNERS)
- PR template: [.github/pull_request_template.md](.github/pull_request_template.md)
- Issue templates: [.github/ISSUE_TEMPLATE](.github/ISSUE_TEMPLATE)
- Operations runbook: [docs/operations.md](docs/operations.md)
