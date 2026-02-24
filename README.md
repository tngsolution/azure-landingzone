# Azure Landing Zone (Hub and Spoke)

## Overview
This repository contains a Terraform-based Azure Landing Zone implementation using a hub-and-spoke network model.

The project is organized into reusable modules and environment stacks, with support for multi-subscription deployments and one-way peering in both directions.

## Architecture
- Hub stack: central networking and shared platform resources
- Spoke stack (generic): reusable spoke deployment for `dev`, `stg`, `prd`
- AKS stack: Kubernetes cluster deployed into an existing spoke subnet
- Peering stacks:
  - `hub -> spokes` (forward peering)
  - `spoke -> hub` (return peering, per spoke)
- Bootstrap stack: remote state storage (RG, Storage Account, blob containers)
- Global policies stack: management group policy assignments

### Landing Zone Diagram
```mermaid
flowchart LR
    BOOT[Bootstrap\nRG + Storage Account + tfstate containers]
    POL[Global Policies\nManagement Group assignments]

    HUBRG[Hub RG]
    HUBNET[Hub VNet]
    HUBCFG[Hub App Configuration\n*-config RG]

    DEV[Spoke DEV VNet]
    STG[Spoke STG VNet]
    PRD[Spoke PRD VNet]

    AKSDEV[AKS DEV cluster(s)]
    AKSSTG[AKS STG cluster(s)]
    AKSPRD[AKS PRD cluster(s)]

    BOOT --> HUBRG
    BOOT --> DEV
    BOOT --> STG
    BOOT --> PRD
    POL -. applies .-> HUBRG
    POL -. applies .-> DEV
    POL -. applies .-> STG
    POL -. applies .-> PRD

    HUBRG --> HUBNET
    HUBRG --> HUBCFG

    DEV <-->|Peering bi-directional| HUBNET
    STG <-->|Peering bi-directional| HUBNET
    PRD <-->|Peering bi-directional| HUBNET

    DEV --> AKSDEV
    STG --> AKSSTG
    PRD --> AKSPRD
```

```text
                    +---------------------------------------------+
                    | Bootstrap (tfstate)                         |
                    | RG + Storage Account + containers           |
                    +-------------------+-------------------------+
                                        |
                                        v
                    +---------------------------------------------+
                    | Hub Subscription                            |
                    | rg-...                                      |
                    |  - Hub VNet                                |
                    |  - App Configuration (rg-...-config)       |
                    +-------------------+-------------------------+
                                        ^
                peering bi-directional  |  peering bi-directional
                                        |
      +---------------------------------+----------------------------------+
      |                                 |                                  |
      v                                 v                                  v
+-------------+                 +-------------+                    +-------------+
| Spoke DEV   |                 | Spoke STG   |                    | Spoke PRD   |
| VNet/Subnets|                 | VNet/Subnets|                    | VNet/Subnets|
| App Config  |                 | App Config  |                    | App Config  |
+------+------+                 +------+------+                    +------+------+
       |                               |                                   |
       v                               v                                   v
 +------------+                    +------------+                     +------------+
 | AKS DEV    |                    | AKS STG    |                     | AKS PRD    |
 | 1..n states|                    | 1..n states|                     | 1..n states|
 +------------+                    +------------+                     +------------+

Global Policies (Management Group) apply across hub/spoke environments.
```

## Repository Structure
- `modules/`: reusable Terraform modules
- `envs/`: deployable stacks
- `global-policies/`: policy assignment stack
- `scripts/`: configuration generation scripts
- `docs/`: operational documentation and runbooks
- `Makefile`: common operational commands

## Tooling Setup
Required tools:
- Terraform (recommended: `1.9.x`)
- Azure CLI (recommended: `2.8x+`)
- GNU Make
- Python 3 (used by generation scripts)

macOS (Homebrew):
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform azure-cli make python
```

Ubuntu/Debian:
```bash
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common curl make python3
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install -y terraform
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Version check:
```bash
terraform version
az version
make --version
python3 --version
```

## Stack Documentation

Contribution guidelines: [CONTRIBUTING.md](CONTRIBUTING.md)

### Core Stacks
- [Bootstrap](envs/bootstrap/README.md)
- [Hub](envs/hub-tngs/README.md)
- [Spoke (Generic)](envs/spoke/README.md)
- [AKS](envs/aks/README.md)
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

Important: when switching environment, re-run `make init` with the matching backend file before any `plan/apply` to avoid applying on the wrong state.

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
- AKS generator: `gen-aks ENVIRONMENT=<dev|stg|prd> CLUSTER_KEY=<cluster-name> KUBERNETES_VERSION=<x.y>`

See `make help` for full command list.

## Notes
- Always verify subscription context before any `apply`.
- Review plan output carefully for resource replacement.
- Keep stack-specific docs up to date when changing behavior.

## Governance and Contribution
- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Security policy: [SECURITY.md](SECURITY.md)
- Code ownership rules: [.github/CODEOWNERS](.github/CODEOWNERS)
- PR template: [.github/pull_request_template.md](.github/pull_request_template.md)
- Issue templates: [.github/ISSUE_TEMPLATE](.github/ISSUE_TEMPLATE)
- Operations runbook: [docs/operations.md](docs/operations.md)
