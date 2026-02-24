# Security Policy

## Supported Scope
This repository manages infrastructure-as-code for Azure Landing Zone components (Terraform stacks, modules, and automation scripts).

Security reports are in scope for:
- Terraform code and configuration logic
- CI/CD workflow security in this repository
- Credential and secret handling in repo scripts/docs
- Misconfigurations that can create security exposure

## Reporting a Vulnerability
Please do **not** open a public issue for security vulnerabilities.

Report privately to:
- Security team email: `security@tngsolution.com`
- Include subject: `[SECURITY][azure-landingzone] <short-title>`

Please provide:
- Affected file(s)/stack(s)
- Impact and attack scenario
- Reproduction steps or proof of concept
- Suggested mitigation (if available)

## Response Process
- Initial acknowledgment target: within 2 business days
- Triage and severity classification
- Mitigation plan and fix timeline
- Coordinated disclosure after remediation

## Secret Handling Rules
- Never commit secrets, credentials, tokens, or private keys
- Keep `.tfvars`, backend files, and local state files out of version control
- Use Azure identity-based auth where possible
- Rotate credentials immediately if accidental exposure occurs

## Infrastructure Security Baselines
- Review `terraform plan` before every `apply`
- Avoid unintended destroy/replace operations
- Enforce policy assignments through `global-policies`
- Keep provider/tool versions updated and pinned as needed

## Dependency and Tooling Hygiene
- Use maintained Terraform and Azure CLI versions
- Validate code in CI (`fmt`, `init -backend=false`, `validate`, `tflint`)
- Prefer least-privilege access in Azure RBAC assignments
