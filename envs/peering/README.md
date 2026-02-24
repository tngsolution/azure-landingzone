# Peering Strategy (Why This Is Split)

## Context
This repository manages peering in a multi-subscription hub-and-spoke setup.

In Azure, each VNet peering object is created **from one VNet to another**. A full bidirectional relationship requires two resources:
- `hub -> spoke`
- `spoke -> hub`

## Chosen Approach
Peering is split into two stacks:
- `envs/peering/hub-spokes`: creates `hub -> spoke-*`
- `envs/peering/spoke-hub`: creates `spoke-* -> hub` (one spoke context at a time)

### Why this approach
- Works cleanly with different subscriptions and RBAC boundaries
- Avoids requiring dual provider aliases and cross-subscription write access in one run
- Easier operational control per subscription/team
- Safer blast radius (changes are isolated by direction/subscription)

## Alternatives and Trade-offs

### 1. Single stack with provider aliases (both directions)
Description:
- One Terraform stack creates both peering directions using multiple aliased Azure providers.

Pros:
- Single plan/apply for complete peering
- Centralized code path

Cons:
- Requires credentials/permissions for all involved subscriptions in one pipeline
- Higher operational risk if permissions or credentials are misconfigured
- Harder to align with strict least-privilege models

### 2. Single-direction peering only
Description:
- Create only `hub -> spoke` or only `spoke -> hub`.

Pros:
- Simpler configuration

Cons:
- Not a full peering relationship for common hub-spoke traffic scenarios
- Often insufficient for expected connectivity behavior

### 3. External orchestration around multiple stacks
Description:
- Keep split stacks, but orchestrate end-to-end flow in CI/CD (hub phase then spoke phase).

Pros:
- Preserves security boundaries
- Better automation and consistency

Cons:
- Slightly more pipeline complexity

## Recommended Operational Pattern
1. Deploy/validate hub and spoke VNets first
2. Apply `hub-spokes` from hub subscription context
3. Apply `spoke-hub` from each spoke subscription context
4. Validate routes/connectivity

This pattern is currently the safest and most maintainable for this repository.

## AKS Considerations
When deploying AKS into a spoke subnet (for example `snet-aks-*`), complete bidirectional peering remains required for common hub-spoke access patterns (management, shared services, private dependencies).

For private AKS clusters, validate DNS and routing from the management network in addition to peering state.
