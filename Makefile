.PHONY: help tf-init tf-plan tf-apply tf-destroy deploy deploy-all save-outputs clean backend-create

# Default target
help:
	@echo "Available targets:"
	@echo "  backend-create - Initialize remote backend for Terraform"
	@echo "  tf-init        - Initialize Terraform"
	@echo "  tf-plan        - Run Terraform plan"
	@echo "  tf-apply       - Apply Terraform changes and save outputs"
	@echo "  tf-destroy     - Destroy Terraform resources"
	@echo "  save-outputs   - Save Terraform outputs to .tfoutputs file"
	@echo "  deploy ENV=env - Deploy function app to specific environment"
	@echo "  deploy-all     - Deploy function app to all environments"
	@echo "  clean          - Remove generated files"

# Terraform directory
TF_DIR := terraform
ENV_FILE := .terraform-backend.env
OUTPUTS_FILE := .tfoutputs
RESOURCE_GROUP ?= tfstate
LOCATION ?= westeurope
STATE_KEY ?= terraform.tfstate

# Create terraform backend
backend-create: 
	@$(TF_DIR)/create-backend.sh $(RESOURCE_GROUP) $(LOCATION) $(STATE_KEY)

# Initialize terraform
tf-init:
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "❌ Backend not configured. Run: make create-backend"; \
		exit 1; \
	fi
	@echo "Initializing Terraform..."
	@cd $(TF_DIR) && . ../.terraform-backend.env && \
		terraform init \
			-backend-config="storage_account_name=$$TF_BACKEND_STORAGE_ACCOUNT" \
			-backend-config="container_name=$$TF_BACKEND_CONTAINER" \
			-backend-config="key=$$TF_BACKEND_KEY"

tf-plan: tf-init
	@cd $(TF_DIR) && . ./.terraform-backend.env && terraform plan

tf-apply: tf-init
	@cd $(TF_DIR) && . ./.terraform-backend.env && terraform apply
	@$(MAKE) save-outputs

tf-destroy: tf-init
	@cd $(TF_DIR) && . ./.terraform-backend.env && terraform destroy

# Save Terraform outputs to file
save-outputs:
	@echo "Saving Terraform outputs..."
	@cd $(TF_DIR) && terraform output -json > ../$(OUTPUTS_FILE)
	@echo "Outputs saved to $(OUTPUTS_FILE)"

# Deploy to specific environment
deploy:
	@if [ -z "$(ENV)" ]; then \
		echo "Error: ENV variable is required. Usage: make deploy ENV=dev"; \
		exit 1; \
	fi
	@if [ ! -f $(OUTPUTS_FILE) ]; then \
		echo "Error: $(OUTPUTS_FILE) not found. Run 'make tf-apply' first."; \
		exit 1; \
	fi
	@FUNCTION_APP=$$(cat $(OUTPUTS_FILE) | jq -r '.function_app_names.value["$(ENV)"]'); \
	if [ "$$FUNCTION_APP" = "null" ] || [ -z "$$FUNCTION_APP" ]; then \
		echo "Error: Function app not found for environment: $(ENV)"; \
		echo "Available environments:"; \
		cat $(OUTPUTS_FILE) | jq -r '.function_app_names.value | keys[]'; \
		exit 1; \
	fi; \
	echo "Deploying to $$FUNCTION_APP..."; \
	cd function-app && func azure functionapp publish $$FUNCTION_APP

# Deploy to all environments
deploy-all:
	@if [ ! -f $(OUTPUTS_FILE) ]; then \
		echo "Error: $(OUTPUTS_FILE) not found. Run 'make tf-apply' first."; \
		exit 1; \
	fi
	@echo "Deploying to all environments..."
	@cat $(OUTPUTS_FILE) | jq -r '.function_app_names.value | to_entries[] | "\(.key):\(.value)"' | \
	while IFS=: read -r env app; do \
		echo ""; \
		echo "========================================"; \
		echo "Deploying to environment: $$env"; \
		echo "Function App: $$app"; \
		echo "========================================"; \
		cd function-app && func azure functionapp publish $$app || echo "Failed to deploy to $$env"; \
	done
	@echo ""
	@echo "Deployment complete!"

# Clean generated files
clean:
	@rm -f $(OUTPUTS_FILE)
	@rm -f $(ENV_FILE)
	@echo "✅ Cleaned up generated files"

.DEFAULT_GOAL := help
