# Naming & Tagging Conventions

## Naming pattern

```
<resource-type-abbrev>-<project>-<environment>-<region-short>[-<qualifier>]
```

Examples: `rg-opella-dev-eastus`, `vnet-opella-prod-weu`, `st opellaproduseastus001` (storage
accounts strip hyphens — see note below).

| Abbrev | Resource type            |
|--------|---------------------------|
| rg     | Resource Group             |
| vnet   | Virtual Network             |
| snet   | Subnet                      |
| nsg    | Network Security Group      |
| vm     | Virtual Machine              |
| nic    | Network Interface            |
| st     | Storage Account (no hyphens, globally unique, ≤24 chars) |
| pip    | Public IP                    |

All of this is generated from three Terraform locals in each environment
(`project`, `environment`, `location_short`) so a resource's name always
tells you what it is, which environment it belongs to, and which region it's
in, without opening the Azure Portal.

**Storage accounts** are the one exception: they can't contain hyphens and
must be globally unique, so the environment builds their name as
`st${var.project}${var.environment}${local.location_short}${random suffix}`,
lowercased, truncated to 24 characters.

## Tagging

Every resource gets a common tag set, merged from a single `locals.common_tags`
block per environment, plus any resource-specific tags:

| Tag           | Purpose                                              |
|---------------|-------------------------------------------------------|
| `environment` | dev / prod — drives cost reporting and access policies |
| `project`     | Groups resources across environments in Cost Management |
| `managed_by`  | Always `terraform` — flags anything *not* tagged this way as manual drift |
| `owner`       | Team/email responsible, for on-call and cleanup        |
| `cost_center` | Chargeback code                                        |

### How this is enforced, not just documented

- **At the module level**: every resource in `modules/vnet` takes `var.tags`
  and applies it directly — there's no path to creating an untagged VNET or
  NSG through this module.
- **At the environment level**: an [Azure Policy](https://learn.microsoft.com/azure/governance/policy/)
  "Require tag on resources" (or the built-in `Inherit a tag from the
  resource group`) assignment at the resource group scope is the real
  enforcement backstop — Terraform can't stop someone from clicking "Create"
  in the Portal without a tag, but Azure Policy can deny the request outright.
  This repo doesn't provision that policy assignment (it's a subscription-level
  governance concern, usually owned by a platform/landing-zone team rather
  than an individual workload), but it's the recommended pairing with this
  code — see `bootstrap/` for where that would live.
- **In CI**: the `checkov`/`tfsec` step in the pipeline includes rules that
  fail a PR if `tags` is missing on a supported resource type.

## Resource Groups vs. Subscriptions

One Resource Group per environment (`rg-opella-dev-eastus`,
`rg-opella-prod-eastus`) inside a single subscription, rather than a
subscription per environment.

- **Blast radius vs. overhead.** A subscription per environment gives the
  strongest isolation (separate quotas, separate RBAC root, separate cost
  boundary) but is heavier to bootstrap and manage — you need a subscription
  vending process, separate budgets, separate Azure AD app registrations for
  CI, etc. For a project this size, a resource group boundary already gives
  you: independent lifecycle (`terraform destroy` on dev never touches prod),
  independent RBAC (`Contributor` scoped to the RG), and independent cost
  reporting (tags + RG scope in Cost Management).
- **When we'd switch to subscriptions per environment**: if dev and prod
  need genuinely different network topologies peered to different on-prem
  circuits, different compliance boundaries (e.g. prod needs to be in a
  regulated Management Group), or if the org's landing zone (e.g. Azure
  Enterprise-Scale) already mandates subscription-per-environment as policy.
  At that point this module doesn't change — only the `provider` block and
  backend config per environment change, since `resource_group_name` and
  `location` are already inputs, not hardcoded.
- Either way, **state is already isolated per environment** (separate
  `environments/dev` and `environments/prod` directories, each with its own
  backend state file), so switching to separate subscriptions later is a
  provider/backend change, not a module or code-structure change.
