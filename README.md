# infra-cloudflare

Terraform repository for Cloudflare infrastructure. The layout uses **multiple independent stacks** (each with its own state and scope), sharing **modules** where it makes sense.

## How it works

- **`modules/`** — reusable building blocks (for example: static sites, DNS, Workers). They are not applied on their own; stacks reference them.
- **`stacks/`** — one directory per logical environment or per application/site. Each stack is a Terraform root module with its own backend (for example Terraform Cloud or another remote backend configured in `backend.tf`) and its own `versions.tf` (Terraform and provider version constraints).
- **`Makefile`** — shortcuts that run `terraform` with `-chdir` for the selected stack. Sensitive values can be loaded from `stacks/<stack>/.env` when present (sourced before `plan` / `apply`).
- **CI** — typically: *plan* on pull requests and *apply* after merge to the default branch, with secrets injected as `TF_VAR_*` or provider environment variables.

Typical flow: pick a stack, initialize, plan, and apply. Stacks do not share state with each other, which isolates changes and blast radius.

## Prerequisites

- [Terraform](https://www.terraform.io/) installed
- A Cloudflare account and an API token with suitable access for your stacks.
- Each stack configures `provider "cloudflare"` in `stacks/<stack>/providers.tf` (for example `api_token = var.cloudflare_api_token`). Inject the token with `TF_VAR_cloudflare_api_token` or your backend—never commit it.
- If using Terraform Cloud: `terraform login` and a workspace aligned with each stack’s `backend`

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

## Adding a new stack

1. Create `stacks/<new-stack>/` with `main.tf`, `variables.tf`, `versions.tf`, `providers.tf`, and `backend.tf` following the pattern of existing stacks.
2. Configure the remote backend and matching workspace.
3. Define variables and secrets in CI or your environment (for example `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`, zone, domain—whatever the modules require).
4. Open a PR so *plan* runs before *apply*.

---

## Credits

Developed and maintained by [**@bedatty**](https://github.com/bedatty).
