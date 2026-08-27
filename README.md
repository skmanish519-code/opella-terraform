# Opella — Azure Infrastructure (Terraform)

Terraform setup for provisioning Azure infra: a reusable VNET module, two
environments built from it (`dev`, `prod`), a VM + storage account in each,
and a GitHub Actions pipeline for plan/apply.

```
.
├── modules/vnet/            # Reusable VNET module
│   ├── main.tf / variables.tf / outputs.tf / versions.tf
│   ├── vnet.tftest.hcl      # terraform test suite (plan-only, mocked provider)
│   └── README.md
├── environments/
│   ├── dev/
│   └── prod/
├── .github/workflows/terraform.yml
└── CONVENTIONS.md           # Naming/tagging rules, RG vs subscription decision
```

## Running it

```bash
az login
cd environments/dev
terraform init
terraform plan -var="allowed_ssh_cidr=YOUR_IP/32"
```

Replace `YOUR_IP` with your public IP (search "what's my ip"). That's the
only variable without a default — everything else in `variables.tf` has one.

State is local for now (see `versions.tf`) — fine for a solo run. For a real
team setup, swap in a remote `backend "azurerm"` block pointing at a shared
storage account.

Same pattern for `environments/prod`, except it also requires
`ssh_public_key` (no auto-generated fallback for a prod box):

```bash
cd environments/prod
terraform init
terraform plan -var="allowed_ssh_cidr=YOUR_IP/32" -var="ssh_public_key=ssh-rsa AAAA..."
```

## Module design

`modules/vnet` takes a list of subnets, and each subnet can optionally carry
its own NSG + rule set. A "data" subnet and an "app" subnet almost never
want the same rules, and this way one module call handles both instead of
needing a second module or `count` workarounds at the caller level. NSGs
default to on (`create_nsg = true`); turning one off is an explicit choice.

Nothing is hardcoded — names, address space, subnets, region all come in as
variables — so the same module is used for both dev and prod with different
inputs. Outputs are maps keyed by subnet name (`subnet_ids`, `nsg_ids`) so
callers do `module.vnet.subnet_ids["snet-app-dev"]` instead of relying on
list order.

## Environments

Each environment has its own resource group, calls the shared module, and
adds:
- a Linux VM (private IP only — SSH restricted to `allowed_ssh_cidr` at the
  NSG, no public IP on the NIC)
- a storage account + blob container, network-locked to the data subnet via
  service endpoint

Prod differs from dev: larger VM size, Premium disk instead of Standard,
GRS storage instead of LRS, and requires your own SSH key instead of
generating one.

One resource group per environment in a single subscription, not a
subscription per environment — reasoning in `CONVENTIONS.md`.

## Pipeline / release flow

`.github/workflows/terraform.yml`:

1. PR opened → fmt, validate, and the module's `terraform test` suite run.
2. `plan` runs for both `dev` and `prod`, posted as a PR comment.
3. Merge to `main` → auto-apply to dev.
4. Apply to prod waits for manual approval (GitHub Environment protection
   rule) before running.
5. Auth is OIDC, not a stored client secret.

## Tooling

`terraform fmt -check` and `terraform validate` run in CI on every PR, plus
the module's own `terraform test` suite (see `modules/vnet/tests`).

For a longer-lived version of this repo I'd add: TFLint (catches unused
variables, naming issues, deprecated syntax), Checkov or tfsec (flags
security misconfigurations — public storage access, missing encryption,
open NSG rules), and terraform-docs (auto-generates the variable/output
tables in each module's README so docs can't drift from the code). All
three plug into the same CI job as an extra step, and into a local
pre-commit hook so issues get caught before a PR is even opened.

## Naming & tagging

Covered in `CONVENTIONS.md`: `<type>-<project>-<env>-<region>` naming, and
a `common_tags` map merged into every resource.
