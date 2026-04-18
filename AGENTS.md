<table><tr>
<td><img src="https://github.com/Bedatty-Engineering.png" alt="Bedatty Engineering" width="80" /></td>
<td><h1>AGENTS.md</h1></td>
</tr></table>

This file is only for AI coding agents working in this repository.

## Mission

Work safely and efficiently in this Terraform monorepo for Cloudflare infrastructure.

Primary goals:

- keep changes scoped
- do not leak secrets in logs or code
- preserve CI behavior
- use the existing stack/module model correctly

## Repository Model

- `stacks/<stack>/` are independent Terraform root modules
- `modules/` contains shared Terraform modules
- each stack has its own backend and state
- use the `Makefile` as the default interface for Terraform commands

Do not treat this repo as a single Terraform root.

## Default Working Method

Before changing code:

1. Identify whether the change is stack-local or module-wide.
2. If editing a module, inspect all affected stacks.
3. Prefer the smallest change that solves the problem.

Preferred commands:

```bash
make init STACK=<stack>
make validate STACK=<stack>
make plan STACK=<stack>
make apply STACK=<stack>
```

Avoid raw `terraform` commands unless needed for debugging.

## CI Behavior

GitHub Actions runs per changed stack.

- PR workflow: `.github/workflows/terraform-plan.yml` → `Bedatty-Engineering/modules-hub/.github/workflows/terraform/plan.yml`
- Push workflow: `.github/workflows/terraform-apply.yml` → `Bedatty-Engineering/modules-hub/.github/workflows/terraform/apply.yml`
- changes under `stacks/<stack>/` select that stack
- changes under `modules/` expand to all stacks
- jobs run as a matrix, one job per stack

Do not break the matrix model unless explicitly asked.

## GitHub Environment Convention

Each stack uses a GitHub Environment named:

- `website-<stack>`

Example:

- `profile` -> `website-profile`

Current workflow inputs expected from that environment:

- secret `TF_API_TOKEN`
- secret `CLOUDFLARE_API_TOKEN`
- secret `CLOUDFLARE_ACCOUNT_ID`
- secret `CLOUDFLARE_ZONE_ID`
- variable `DOMAIN`

`TF_API_TOKEN` is used as `TF_TOKEN_app_terraform_io` for Terraform Cloud authentication.

## Terraform Cloud Guidance

Local success does not prove CI correctness.

Reason:

- local Terraform may already be authenticated to Terraform Cloud
- CI depends on the GitHub Environment secret `TF_API_TOKEN`

If CI fails with:

- `organization settings: unauthorized`

check this first:

- the correct `website-<stack>` environment exists
- `TF_API_TOKEN` exists there as a secret
- that token can access the Terraform Cloud organization/workspace

Do not assume `.env` parity fixes Terraform Cloud auth.

## Secret Handling Rules

Primary rule: do not expose sensitive values in workflow logs.

Never:

- print `TF_TOKEN_app_terraform_io`
- print `TF_VAR_*`
- add `env`, `printenv`, `set`, or similar dump steps
- echo provider tokens or secret maps

Allowed:

- presence checks that do not print values
- using GitHub `secrets.*` in workflow `env`
- marking Terraform inputs as `sensitive = true`

## Sensitive Terraform Collections

Terraform cannot use sensitive maps directly in `for_each`.

Correct pattern:

```hcl
dynamic "secret_text_binding" {
  for_each = nonsensitive(toset(keys(var.secrets)))
  content {
    name = secret_text_binding.value
    text = var.secrets[secret_text_binding.value]
  }
}
```

Why:

- only keys become non-sensitive for iteration
- values remain sensitive

Do not replace this with:

```hcl
for_each = nonsensitive(var.secrets)
```

unless the user explicitly accepts removing sensitivity from the whole map.

## Workflow Safety Rules

When editing workflows:

- keep secrets in GitHub Environment secrets, not repository vars
- keep non-sensitive values in vars when appropriate
- prefer job-scoped secrets when they depend on `matrix.stack`
- comment/reporting steps must not be able to leak secrets
- non-critical PR comment steps should not break the whole plan job

## Output Safety

Before adding or editing Terraform outputs:

- do not expose tokens, secrets, or secret-containing maps
- if an output is sensitive, mark it explicitly with `sensitive = true`
- avoid adding debug outputs for CI troubleshooting

## Debugging Priorities

If CI fails but local passes, debug in this order:

1. GitHub Environment naming and scoping
2. missing or wrong secrets/vars
3. Terraform Cloud auth
4. provider version/resource compatibility
5. Terraform code logic

If `validate` fails only in CI, consider whether CI injects non-empty sensitive inputs that local runs did not provide.

## Efficiency Guidance for AI Models

To work efficiently in this repo:

- inspect `Makefile` before inventing command patterns
- inspect the target stack first, then the shared module it calls
- avoid large refactors when a stack-specific fix is enough
- when changing modules, reason about all stacks, not just the current one
- keep explanations short and operational
- prefer concrete fixes over speculative redesign

## Completion Checklist

Before finishing:

- no secrets are printed in workflows
- matrix stack handling still works
- `website-<stack>` environment mapping still works
- Terraform changes respect sensitive-value handling
- changes are scoped to the intended stack/module boundary
