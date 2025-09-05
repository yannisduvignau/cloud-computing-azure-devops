## ########################################################################## ##
# Makefile for managing Terraform and Azure resources
#
# Usage:
#   make <target> [SCRIPTS_PATH=<path>] [PUBLIC_IP_ADDRESS=<ip_address>] [AZ_USER=<user>] [REGION_KEY=<region>]
#
# Default scripts path: ./helpers (Override with SCRIPTS_PATH variable if needed.)
# Default public IP address: 127.0.0.1 (Override with PUBLIC_IP_ADDRESS variable if needed.)
# Default target user: azureuser (Override with AZ_USER variable if needed.)
# Default region key: uksouth (Override with REGION_KEY variable if needed.)
#
# IMPORTANT:
# - Makefiles require TAB characters (not spaces) for command indentation.
# - Do not modify this file directly unless necessary.
#
# HOW TO DOCUMENT TARGETS FOR `make help`
#
# - Write a single-line comment (starting with #) directly above each target.
# - This comment will be shown as the help description for that target.
# - Example:
#       # Run Terraform plan and apply
#       terraform-plan:
#       	$(TERRAFORM_SCRIPT) tp1
#
# - To see all documented targets, run: make (or make help)
## ########################################################################## ##








## ########################################################################## ##
## Parameters (can be overridden when calling make)
## ########################################################################## ##
SCRIPTS_PATH ?= ./helpers
PUBLIC_IP_ADDRESS ?= 127.0.0.1
AZ_USER ?= azureuser
REGION_KEY ?= uksouth

## ########################################################################## ##
## Varibles and scripts permissions
## ########################################################################## ##
SSH_ED25519_SCRIPT = $(SCRIPTS_PATH)/setup_ssh_ed25519.sh
ALLOW_SSH_ED25519_RIGHTS = chmod +x $(SSH_ED25519_SCRIPT)

SSH_KEY_PATH = $(HOME)/.ssh
SSH_KEY_NAME = id_rsa_terraform
SSH_KEY_COMMENT = terraform_vm
SSH_RSA_SCRIPT = ssh-keygen -t rsa -b 4096 -f $(SSH_KEY_PATH)/$(SSH_KEY_NAME) -C "$(SSH_KEY_COMMENT)"

SSH_AGENT_SCRIPT = $(SCRIPTS_PATH)/start_ssh_agent.sh
ALLOW_AGENT_RIGHTS = chmod +x $(SSH_AGENT_SCRIPT)

CLEAR_AZURE_SCRIPT = $(SCRIPTS_PATH)/delete_all_resource_groups.sh
ALLOW_CLEAR_RIGHTS = chmod +x $(CLEAR_AZURE_SCRIPT)

AZ_CLI_SCRIPT = $(SCRIPTS_PATH)/create_azure_vm.sh
ALLOW_AZ_CLI_RIGHTS = chmod +x $(AZ_CLI_SCRIPT)

TERRAFORM_SCRIPT = $(SCRIPTS_PATH)/terraform.sh
ALLOW_TERRAFORM_RIGHTS = chmod +x $(TERRAFORM_SCRIPT)

## ########################################################################## ##
## Default goal: show help
## ########################################################################## ##
.DEFAULT_GOAL := help

# Show all available targets with their descriptions
help:
	@awk '/^#/{c=substr($$0,3);next}c&&/^[[:alpha:]][[:alnum:]_-]+:/{print substr($$1,1,index($$1,":")),c}1{c=0}' $(MAKEFILE_LIST) | column -s: -t

# Show all available targets with descriptions by category
help-with-categories:
	@echo "Available targets grouped by category:"
	@echo
	@awk ' \
		/^###/{ \
			category=substr($$0,5,length($$0)-7); \
			printf "\n%s\n", category; \
			next; \
		} \
		/^#/{desc=substr($$0,3); next} \
		desc && /^[[:alnum:]_-]+:/{ \
			target=substr($$1, 1, index($$1, ":")-1); \
			printf "  %-30s %s\n", target, desc; \
			desc=""; \
		}' $(MAKEFILE_LIST)

## ########################################################################## ##
##                                  TOOLS                                     ##
## ########################################################################## ##

### TOOLS ###
# Delete all Azure resource groups in the current subscription
delete-resources-azure:
	@echo "🗑️ Deleting all Azure resource groups..."
	$(ALLOW_CLEAR_RIGHTS) && $(CLEAR_AZURE_SCRIPT)

# Generate RSA SSH keys for Terraform
generate-ssh-keys-rsa:
	@echo "🔑 Generating RSA SSH keys for Terraform..."
	$(SSH_RSA_SCRIPT)

# Generate ED25519 SSH keys
generate-ssh-keys-ed25519:
	@echo "🔑 Generating ED25519 SSH keys..."
	$(ALLOW_SSH_ED25519_RIGHTS) && $(SSH_ED25519_SCRIPT)

# Start SSH agent and add keys
start-ssh-agent:
	@echo "🚀 Starting SSH agent..."
	$(ALLOW_AGENT_RIGHTS) && $(SSH_AGENT_SCRIPT)

# Connect to the VM via SSH (use ssh-agent or explicit RSA key if provided)
exec-ssh:
	@echo "🔌 Connecting to VM at $(PUBLIC_IP_ADDRESS) as $(AZ_USER)..."
	@if [ "$(KEY)" = "rsa" ]; then \
		ssh -i $(SSH_KEY_PATH)/$(SSH_KEY_NAME) $(AZ_USER)@$(PUBLIC_IP_ADDRESS); \
	else \
		ssh $(AZ_USER)@$(PUBLIC_IP_ADDRESS); \
	fi

## ########################################################################## ##
##                                 AZURE CLI                                  ##
## ########################################################################## ##

### AZURE CLI ###
# Run Terraform plan and apply in the tp1/terraform directory
create-vm-cli:
	@echo "📝 Running Terraform plan and apply..."
	$(ALLOW_AZ_CLI_RIGHTS) && $(AZ_CLI_SCRIPT)

## ########################################################################## ##
##                                 TERRAFORM                                  ##
## ########################################################################## ##

### TERRAFORM ###
# Run Terraform plan and apply in the tp1/terraform directory
terraform-plan:
	@echo "📝 Running Terraform plan and apply..."
	$(ALLOW_TERRAFORM_RIGHTS) && $(TERRAFORM_SCRIPT) tp1/terraform

# Destroy all Terraform-managed resources in the tp1/terraform directory
terraform-destroy:
	@echo "💣 Destroying all Terraform-managed resources..."
	cd tp1/terraform && terraform destroy -auto-approve

# List all available Azure regions
get-available-region:
	@echo "🌍 Fetching available Azure regions..."
	az account list-locations --output table

# List all available VM sizes in a given region (requires REGION_KEY variable)
get-available-sizes:
	@echo "📏 Fetching available VM sizes in region $(REGION_KEY)..."
	az vm list-sizes --location $(REGION_KEY) -o table

# Start Azure CLI in interactive mode
make-interactive-create-vm-cli:
	@echo "💻 Starting Azure CLI in interactive mode..."
	az interactive

# Show information about the current Azure subscription
get-subscription-info:
	@echo "🔑 Fetching subscription information..."
	az account show


## ########################################################################## ##
## PHONY targets grouped by category
## ########################################################################## ##
.PHONY: \
	delete-resources-azure \
	generate-ssh-keys-rsa \
	generate-ssh-keys-ed25519 \
	start-ssh-agent \
	exec-ssh \

	create-vm-cli \
	make-interactive-create-vm-cli \
	get-available-region \
	get-available-sizes \
	get-subscription-info \

	terraform-plan \
	terraform-destroy \

	help \
	help-with-categories