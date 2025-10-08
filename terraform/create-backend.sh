#!/bin/bash

set -e

# Default values
RESOURCE_GROUP_NAME=${1:-tfstate}
LOCATION=${2:-westeurope}
STATE_KEY=${3:-terraform.tfstate}
STORAGE_ACCOUNT_NAME=tfstate$(date +%s)
CONTAINER_NAME=tfstate
ENV_FILE=".terraform-backend.env"

echo "Creating Terraform remote state storage..."
echo "Resource Group: $RESOURCE_GROUP_NAME"
echo "Location: $LOCATION"
echo "State Key: $STATE_KEY"
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo ""

# Create resource group
echo "Creating resource group..."
az group create --name $RESOURCE_GROUP_NAME --location $LOCATION --output none

# Create storage account
echo "Creating storage account..."
az storage account create \
    --resource-group $RESOURCE_GROUP_NAME \
    --name $STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS \
    --encryption-services blob \
    --location $LOCATION \
    --output none

echo "Creating blob container..."
az storage container create \
    --name $CONTAINER_NAME \
    --account-name $STORAGE_ACCOUNT_NAME \
    --auth-mode login \
    --output none

SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Write environment variables
cat > $ENV_FILE <<EOF
# Azure Backend Configuration
# These can be set via environment variables:
export ARM_USE_CLI=true
export ARM_USE_AZUREAD=true
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"

# These will be passed via backend config:
export TF_BACKEND_STORAGE_ACCOUNT="$STORAGE_ACCOUNT_NAME"
export TF_BACKEND_CONTAINER="$CONTAINER_NAME"
export TF_BACKEND_KEY="$STATE_KEY"
EOF


echo ""
echo "✅ Backend created successfully!"
echo ""
echo "Storage Account: $STORAGE_ACCOUNT_NAME"
echo "Container: $CONTAINER_NAME"
echo "State Key: $STATE_KEY"
echo ""
echo "Configuration saved to: $ENV_FILE"
echo ""
echo "Next steps:"
echo "  source $ENV_FILE"
echo "  make tf-init"
