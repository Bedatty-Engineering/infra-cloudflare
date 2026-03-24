# infra-cloudflare

Terraform repository for Cloudflare infrastructure. The layout uses **multiple independent stacks** (each with its own state and scope), sharing **modules** where it makes sense.

## How it works

- **`modules/`** — reusable building blocks such as Workers and DNS. They are consumed by stacks and are not applied directly.
- **`stacks/`** — one Terraform root per logical site/environment. Each stack owns its own backend, provider config, variables, and state.
- **`Makefile`** — the standard interface for Terraform operations. Use `make ... STACK=<stack>` instead of calling Terraform manually.
- **CI** — plan runs on pull requests and apply runs on pushes to `main`. Jobs are selected per changed stack and executed in parallel through a matrix.

Typical flow: pick a stack, initialize, plan, and apply. Stacks do not share state with each other, which isolates changes and blast radius.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed
- A Cloudflare account and an API token with suitable access for your stacks
- Access to the Terraform Cloud organization/workspaces used by each stack backend
- If working locally with Terraform Cloud, authenticate with `terraform login`

Each stack configures the Cloudflare provider in `stacks/<stack>/providers.tf`. Sensitive inputs must not be committed.

## CI and Environments

This repository uses GitHub Actions with one GitHub Environment per stack.

Environment naming convention:

- `website-<stack>`

Example:

- stack `profile` uses GitHub Environment `website-profile`

Current workflows expect these values in each stack environment:

- Secret `TF_API_TOKEN`
- Secret `CLOUDFLARE_API_TOKEN`
- Secret `CLOUDFLARE_ACCOUNT_ID`
- Secret `CLOUDFLARE_ZONE_ID`
- Variable `DOMAIN`

How CI selects work:

- changes under `stacks/<stack>/` run only for that stack
- changes under `modules/` run for all stacks
- plan/apply run as a matrix, one job per stack

Terraform Cloud authentication in CI uses:

- `TF_API_TOKEN` from the stack environment, mapped to `TF_TOKEN_app_terraform_io`

If local commands work but CI fails with Terraform Cloud `unauthorized`, check the GitHub Environment secret first. Local success can come from an already-authenticated Terraform CLI on your machine.

## Example commands

List available stacks (directories under `stacks/`):

```bash
make list
```

Show Makefile targets:

```bash
make help
```

Work on one stack (replace `my-stack` with the folder name under `stacks/`):

```bash
make init     STACK=my-stack
make validate STACK=my-stack
make plan     STACK=my-stack
make apply    STACK=my-stack
```

CI-safe apply command used in GitHub Actions:

```bash
make apply-auto STACK=my-stack
```

Format all Terraform in the repository:

```bash
make fmt
```

Check formatting (CI-friendly):

```bash
make fmt-check
```

Run *init* / *validate* / *plan* across every stack (sequential):

```bash
make init-all
make validate-all
make plan-all
```

Show stack outputs:

```bash
make output STACK=my-stack
```

Destroy resources in the stack (use with care):

```bash
make destroy STACK=my-stack
```

If the stack ships `terraform.tfvars.example`, copy it to `terraform.tfvars` (or equivalent) and fill in local values; production secrets usually come from `TF_VAR_*` or the remote backend, not from the repository.

Local note:

- `stacks/<stack>/.env` may exist for local convenience
- CI does not read those files
- CI reads from the GitHub Environment for that stack

## Adding a new stack

1. Create `stacks/<new-stack>/` with `main.tf`, `variables.tf`, `versions.tf`, `providers.tf`, and `backend.tf` following the pattern of existing stacks.
2. Configure the remote backend and matching Terraform Cloud workspace.
3. Create a GitHub Environment named `website-<new-stack>`.
4. Populate that environment with the required secrets and variables.
5. Open a PR so plan runs for the new stack before apply.

---

## Credits

Developed and maintained by [**@bedatty**](https://github.com/bedatty).
