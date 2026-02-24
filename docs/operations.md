# Operations Runbook

## Purpose
Operational guidance for day-to-day Terraform stack execution and incident handling.

## Standard Flow
1. Select the correct subscription (`make az-switch`)
2. Confirm context (`make az-whoami`)
3. Initialize with correct backend
4. Plan with correct tfvars
5. Apply after review

## Backend Changes
Use `-reconfigure` when switching backend target without moving existing state:
```bash
terraform init -reconfigure -backend-config=<backend.hcl>
```

Use `-migrate-state` only when intentionally moving state to a new backend:
```bash
terraform init -migrate-state -backend-config=<backend.hcl>
```

## Unexpected Replace in Plan
If plan shows unexpected destroy/create:
1. Stop and do not apply
2. Verify selected subscription
3. Verify backend file and tfvars file
4. Confirm resource naming inputs (`resource_group_name`, environment, CIDR)
5. Re-run plan

## State Validation
List managed resources:
```bash
terraform state list
```

Compare with expected environment naming.

## Spoke Stack Commands
```bash
make init STACK=envs/spoke BACKEND_CONFIG=backends/stg-backend.hcl
make plan STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
make apply STACK=envs/spoke TFVARS=tfvars/spoke-stg.tfvars
```

## Peering Stack Commands
Hub to spoke(s):
```bash
make init STACK=envs/peering/hub-spokes
make plan STACK=envs/peering/hub-spokes
make apply STACK=envs/peering/hub-spokes
```

Spoke to hub:
```bash
make init STACK=envs/peering/spoke-hub BACKEND_CONFIG=backends/spoke-stg.backend.hcl
make plan STACK=envs/peering/spoke-hub TFVARS=tfvars/spoke-stg.tfvars
make apply STACK=envs/peering/spoke-hub TFVARS=tfvars/spoke-stg.tfvars
```

## Incident Notes
- Never run apply if plan is not understood.
- Preserve state safety first; avoid ad-hoc state surgery unless strictly required.
- Document root cause and fix in PR/issue after resolution.
