SHELL := /usr/bin/env bash -o pipefail

STACK     ?=
STACKS_DIR := stacks
STACK_DIR  := $(STACKS_DIR)/$(STACK)
ENV_FILE   := $(STACK_DIR)/.env
LOAD_ENV   := if [ -f "$(ENV_FILE)" ]; then set -a; . "$(ENV_FILE)"; set +a; fi

# Template stack for `make new-stack` (Worker + DNS layout).
STACK_TEMPLATE     := $(STACKS_DIR)/profile
STACK_TEMPLATE_NAME := profile

.DEFAULT_GOAL := help

.PHONY: _require_stack
_require_stack:
ifndef STACK
	$(error STACK is required. Usage: make <target> STACK=<stack-name>)
endif
	@test -d "$(STACK_DIR)" || (echo "Stack '$(STACK)' not found in $(STACKS_DIR)/"; exit 1)

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Example: make plan STACK=my-stack"

.PHONY: list
list: ## List all available stacks
	@ls -1 $(STACKS_DIR)/

.PHONY: new-stack
new-stack: ## Create stacks/<name> from stacks/profile (requires STACK=name)
ifndef STACK
	$(error STACK is required. Usage: make new-stack STACK=my-app)
endif
ifeq ($(STACK),$(STACK_TEMPLATE_NAME))
	$(error STACK cannot be "$(STACK_TEMPLATE_NAME)" — pick a new stack name)
endif
	@test -d "$(STACK_TEMPLATE)" || (echo "Template stack not found: $(STACK_TEMPLATE)" >&2; exit 1)
	@test ! -e "$(STACK_DIR)" || (echo "Already exists: $(STACK_DIR)" >&2; exit 1)
	@mkdir -p "$(STACK_DIR)"
	@cp "$(STACK_TEMPLATE)"/*.tf "$(STACK_DIR)/"
	@test -f "$(STACK_TEMPLATE)/.env.example" && cp "$(STACK_TEMPLATE)/.env.example" "$(STACK_DIR)/" || true
	@test -f "$(STACK_TEMPLATE)/.terraform.lock.hcl" && cp "$(STACK_TEMPLATE)/.terraform.lock.hcl" "$(STACK_DIR)/" || true
	@sed -i 's/name = "$(STACK_TEMPLATE_NAME)"/name = "$(STACK)"/' "$(STACK_DIR)/backend.tf"
	@sed -i 's/default[[:space:]]*=[[:space:]]*"$(STACK_TEMPLATE_NAME)"/default     = "$(STACK)"/' "$(STACK_DIR)/variables.tf"
	@terraform fmt "$(STACK_DIR)" >/dev/null
	@echo "Created $(STACK_DIR). Set TFC org/workspace in backend.tf if needed, copy .env.example to .env, then: make init STACK=$(STACK)"

.PHONY: init
init: _require_stack ## terraform init
	@$(LOAD_ENV); terraform -chdir=$(STACK_DIR) init -upgrade

.PHONY: validate
validate: _require_stack ## terraform validate
	terraform -chdir=$(STACK_DIR) validate

.PHONY: fmt
fmt: ## Format all Terraform files
	terraform fmt -recursive .

.PHONY: fmt-check
fmt-check: ## Check formatting (CI-safe)
	terraform fmt -recursive -check .

.PHONY: plan
plan: _require_stack ## terraform plan
	@$(LOAD_ENV); terraform -chdir=$(STACK_DIR) plan

.PHONY: apply
apply: _require_stack ## terraform apply
	@$(LOAD_ENV); terraform -chdir=$(STACK_DIR) apply

.PHONY: apply-auto
apply-auto: _require_stack ## terraform apply -auto-approve (CI only)
	@$(LOAD_ENV); terraform -chdir=$(STACK_DIR) apply -auto-approve

.PHONY: destroy
destroy: _require_stack ## terraform destroy
	terraform -chdir=$(STACK_DIR) destroy

.PHONY: output
output: _require_stack ## Show stack outputs
	terraform -chdir=$(STACK_DIR) output

.PHONY: init-all
init-all: ## Init every stack
	@for stack in $(shell ls $(STACKS_DIR)/); do \
		echo "==> init: $$stack"; \
		terraform -chdir=$(STACKS_DIR)/$$stack init -upgrade || exit 1; \
	done

.PHONY: validate-all
validate-all: ## Validate every stack
	@for stack in $(shell ls $(STACKS_DIR)/); do \
		echo "==> validate: $$stack"; \
		terraform -chdir=$(STACKS_DIR)/$$stack validate || exit 1; \
	done

.PHONY: plan-all
plan-all: ## Plan every stack
	@for stack in $(shell ls $(STACKS_DIR)/); do \
		echo "==> plan: $$stack"; \
		terraform -chdir=$(STACKS_DIR)/$$stack plan || exit 1; \
	done
