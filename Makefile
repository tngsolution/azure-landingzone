# ==============================================================================
# Landing Zone — Hub & Spoke Terraform Makefile
# ==============================================================================

SHELL := /bin/bash
TF    := terraform
TFVARS ?= terraform.tfvars
BACKEND_CONFIG ?= backend.hcl

# Colors
RED    := \033[0;31m
GREEN  := \033[0;32m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
RESET  := \033[0m

# Stacks in dependency order
STACKS        ?= global-policies envs/hub-tngs envs/spoke envs/spoke-dev envs/spoke-prd envs/peering/hub-spokes envs/peering/spoke-hub envs/bootstrap
DEFAULT_STACK ?= envs/hub-tngs
STACK         ?= $(DEFAULT_STACK)

# ==============================================================================
# Help
# ==============================================================================
.DEFAULT_GOAL := help

help:
	@printf "\n"
	@printf "$(CYAN)Azure Landing Zone — Hub & Spoke$(RESET)\n"
	@printf "==================================================\n"
	@printf "\n"
	@printf "$(YELLOW)Azure commands:$(RESET)\n"
	@printf "  make az-login           Login to Azure\n"
	@printf "  make az-login-device    Login via device code (MFA)\n"
	@printf "  make az-switch          Switch subscription\n"
	@printf "  make az-switch-tenant   Switch tenant\n"
	@printf "  make az-whoami          Show current Azure context\n"
	@printf "  make az-list            List all subscriptions\n"
	@printf "\n"
	@printf "$(YELLOW)Global commands:$(RESET)\n"
	@printf "  make all-init           Init all stacks\n"
	@printf "  make all-plan           Plan all stacks\n"
	@printf "  make all-apply          Apply all stacks in order\n"
	@printf "  make all-destroy        Destroy all stacks in reverse order\n"
	@printf "  make all-fmt            Format all stacks\n"
	@printf "  make all-validate       Validate all stacks\n"
	@printf "  make all-clean          Remove all tfplan files\n"
	@printf "\n"
	@printf "$(YELLOW)Per stack:$(RESET)\n"
	@printf "  make init     STACK=envs/hub-tngs\n"
	@printf "  make plan     STACK=envs/hub-tngs\n"
	@printf "  make apply    STACK=envs/hub-tngs\n"
	@printf "  make deploy   STACK=envs/hub-tngs\n"
	@printf "  make destroy  STACK=envs/hub-tngs\n"
	@printf "  make fmt      STACK=envs/hub-tngs\n"
	@printf "  make validate STACK=envs/hub-tngs\n"
	@printf "  make clean    STACK=envs/hub-tngs\n"
	@printf "\n"
	@printf "$(YELLOW)Available stacks:$(RESET)\n"
	@for s in $(STACKS); do printf "  - $$s\n"; done
	@printf "\n"

# ==============================================================================
# Azure Authentication
# ==============================================================================
.PHONY: az-login az-login-device az-switch az-switch-tenant az-whoami az-list

az-login:
	@printf "$(CYAN)>>> Login to Azure$(RESET)\n"
	@az login

az-login-device:
	@printf "$(CYAN)>>> Login to Azure (device code)$(RESET)\n"
	@az login --use-device-code

az-switch:
	@printf "$(CYAN)>>> Available subscriptions:$(RESET)\n"
	@az account list --query "[].{Name:name, SubscriptionId:id, TenantId:tenantId, State:state}" --output table
	@printf "\n"
	@read -p "Enter Subscription ID: " sub_id; \
	az account set --subscription $$sub_id && \
	printf "ARM_SUBSCRIPTION_ID=$$sub_id\n" > .env && \
	printf "$(GREEN)>>> Switched to: $$sub_id$(RESET)\n" && \
	printf "$(YELLOW)>>> Run: source .env$(RESET)\n"

az-switch-tenant:
	@printf "$(CYAN)>>> Login to a specific tenant$(RESET)\n"
	@read -p "Enter Tenant ID: " tenant_id; \
	az login --tenant $$tenant_id; \
	sub_id=$$(az account show --query id -o tsv); \
	az account set --subscription $$sub_id && \
	printf "ARM_SUBSCRIPTION_ID=$$sub_id\n" > .env && \
	printf "ARM_TENANT_ID=$$tenant_id\n" >> .env && \
	printf "$(GREEN)>>> Switched to tenant: $$tenant_id$(RESET)\n" && \
	printf "$(YELLOW)>>> Run: source .env$(RESET)\n"

az-whoami:
	@printf "$(CYAN)>>> Current Azure context$(RESET)\n"
	@az account show --query "{Name:name, SubscriptionId:id, TenantId:tenantId, User:user.name}" --output table
	@if [ -f .env ]; then \
		printf "\n$(YELLOW)>>> Active .env:$(RESET)\n"; \
		cat .env; \
	fi

az-list:
	@printf "$(CYAN)>>> All accessible subscriptions$(RESET)\n"
	@az account list --query "[].{Name:name, SubscriptionId:id, TenantId:tenantId, State:state}" --output table

# ==============================================================================
# Per-stack targets
# ==============================================================================
.PHONY: init plan apply deploy destroy fmt validate clean

init:
	@$(call check_stack)
	@printf "$(CYAN)>>> Init: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) init -backend-config=$(BACKEND_CONFIG)

migrate:
	@$(call check_stack)
	@printf "$(CYAN)>>> Migrate state: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) init -migrate-state -backend-config=$(BACKEND_CONFIG)
	
plan:
	@$(call check_stack)
	@printf "$(CYAN)>>> Plan: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) plan -var-file=$(TFVARS)

apply:
	@$(call check_stack)
	@printf "$(GREEN)>>> Apply: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) apply -var-file=$(TFVARS)

deploy:
	@$(call check_stack)
	@printf "$(GREEN)>>> Deploy: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) apply -var-file=$(TFVARS) -auto-approve

destroy:
	@$(call check_stack)
	@printf "$(RED)>>> Destroy: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) destroy -var-file=$(TFVARS)

fmt:
	@$(call check_stack)
	@printf "$(CYAN)>>> Format: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) fmt -recursive

validate:
	@$(call check_stack)
	@printf "$(CYAN)>>> Validate: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) validate

clean:
	@$(call check_stack)
	@printf "$(YELLOW)>>> Clean: $(STACK)$(RESET)\n"
	@rm -f $(STACK)/tfplan

refresh:
	@$(call check_stack)
	@printf "$(CYAN)>>> Refresh: $(STACK)$(RESET)\n"
	@cd $(STACK) && $(TF) apply -refresh-only -var-file=$(TFVARS) -auto-approve

# ==============================================================================
# Global targets
# ==============================================================================
.PHONY: all-init all-plan all-apply all-deploy all-destroy all-fmt all-validate all-clean

all-init:
	@printf "$(CYAN)>>> Init all stacks$(RESET)\n"
	@for s in $(STACKS); do \
		printf "$(CYAN)--- Init: $$s$(RESET)\n"; \
		(cd $$s && $(TF) init -backend-config=backend.hcl); \
	done

all-plan:
	@printf "$(CYAN)>>> Plan all stacks$(RESET)\n"
	@for s in $(STACKS); do \
		printf "$(CYAN)--- Plan: $$s$(RESET)\n"; \
		(cd $$s && $(TF) plan -var-file=terraform.tfvars); \
	done

all-migrate:
	@printf "$(CYAN)>>> Migrate state all stacks$(RESET)\n"
	@for s in $(STACKS); do \
		printf "$(CYAN)--- Migrate: $$s$(RESET)\n"; \
		(cd $$s && $(TF) init -migrate-state -backend-config=backend.hcl); \
	done

all-apply:
	@printf "$(GREEN)>>> Apply all stacks in order$(RESET)\n"
	@for s in $(STACKS); do \
		printf "$(GREEN)--- Apply: $$s$(RESET)\n"; \
		(cd $$s && $(TF) apply -var-file=terraform.tfvars); \
	done

all-deploy:
	@printf "$(GREEN)>>> Deploy all stacks in order$(RESET)\n"
	@for s in $(STACKS); do \
		printf "$(GREEN)--- Deploy: $$s$(RESET)\n"; \
		(cd $$s && $(TF) apply -var-file=terraform.tfvars -auto-approve); \
	done

all-destroy:
	@printf "$(RED)>>> Destroy all stacks in reverse order$(RESET)\n"
	@for s in $(shell printf "$(STACKS)" | tr ' ' '\n' | tac); do \
		printf "$(RED)--- Destroy: $$s$(RESET)\n"; \
		(cd $$s && $(TF) destroy -var-file=terraform.tfvars -auto-approve); \
	done

all-fmt:
	@printf "$(CYAN)>>> Format all stacks$(RESET)\n"
	@for s in $(STACKS); do \
		(cd $$s && $(TF) fmt -recursive); \
	done

all-validate:
	@printf "$(CYAN)>>> Validate all stacks$(RESET)\n"
	@for s in $(STACKS); do \
		(cd $$s && $(TF) validate); \
	done

all-clean:
	@printf "$(YELLOW)>>> Clean all tfplan files$(RESET)\n"
	@find . -name "tfplan" -delete
	@printf "$(GREEN)>>> Done$(RESET)\n"

gen-peering:
	@printf "$(CYAN)>>> Generating envs/peering/hub-spokes/terraform.tfvars$(RESET)\n"
	@./scripts/gen-peering-tfvars.sh
	@printf "$(GREEN)>>> Done$(RESET)\n"

gen-spoke-hub:
	@printf "$(CYAN)>>> Generating envs/peering/spoke-hub files$(RESET)\n"
	@./scripts/gen-spoke-hub.sh
	@printf "$(GREEN)>>> Done$(RESET)\n"

gen-spoke:
	@printf "$(CYAN)>>> Generating envs/spoke files$(RESET)\n"
	@./scripts/gen-spoke.sh
	@printf "$(GREEN)>>> Done$(RESET)\n"

deploy-peering: gen-peering
	@printf "$(GREEN)>>> Deploy peering$(RESET)\n"
	@$(MAKE) deploy STACK=envs/peering/hub-spokes

# ==============================================================================
# Helpers
# ==============================================================================
define check_stack
	@if [ -z "$(STACK)" ]; then \
		printf "$(RED)ERROR: STACK is required. Example: make plan STACK=envs/hub-tngs$(RESET)\n"; \
		exit 1; \
	fi
endef
