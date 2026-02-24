# Contributing Guide

## Scope
This repository manages Azure Landing Zone infrastructure with Terraform.

Contributions should prioritize:
- Safe infrastructure changes
- Clear stack ownership
- Reproducible plans
- Documentation updates

## Prerequisites
- Terraform installed
- Azure CLI installed and authenticated
- Access to the target subscription(s)

Useful commands:
```bash
make az-login
make az-switch
make az-whoami
```

## Tool Installation
Recommended versions:
- Terraform `1.9.x`
- Azure CLI `2.8x+`

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

Verify:
```bash
terraform version
az version
make --version
python3 --version
```

## Branching and Commits
- Create a dedicated branch per change.
- Keep commits focused and atomic.
- Use clear commit messages describing intent and scope.

## Project Conventions
- Reusable logic goes into `modules/`.
- Deployable configurations live in `envs/` and `global-policies/`.
- Spoke and spoke peering configs are generated via scripts.
- Keep backend files in `backends/` and var files in `tfvars/` where supported.

## Safe Change Workflow
1. Switch to the correct Azure subscription.
2. Regenerate config files if needed (`gen-spoke`, `gen-spoke-hub`, `gen-peering`).
3. Initialize the target stack with the correct backend config.
4. Run `plan` with the correct tfvars.
5. Review plan output carefully.
6. Apply only after validation.

Example:
```bash
make init STACK=envs/spoke BACKEND_CONFIG=backends/stg-backend.hcl
make plan STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
make apply STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
```

## Validation Checklist
Before opening a PR:
- `terraform fmt` run on touched Terraform files
- `terraform validate` for impacted stacks
- `terraform plan` reviewed for unintended replacements
- Stack README updated if behavior changed
- Root `README.md` and this guide updated if workflow changed

## Documentation Requirement
Every active stack should include a `README.md` describing:
- Purpose
- Resources created
- Inputs and files (`backends/`, `tfvars/`)
- Prerequisites
- Deploy commands

Do not add documentation under `to-delete` directories.

## Security and Secrets
- Never commit secrets.
- Keep `.tfvars` and backend files out of git as defined in `.gitignore`.
- Do not hardcode credentials in Terraform code or scripts.

## Pull Request Expectations
PR description should include:
- What changed
- Why it changed
- Target stack(s)
- Plan summary (high-level)
- Any migration or rollback considerations

## Related Governance Docs
- Code ownership: `.github/CODEOWNERS`
- PR template: `.github/pull_request_template.md`
- Issue templates: `.github/ISSUE_TEMPLATE/`
- Operations runbook: `docs/operations.md`
