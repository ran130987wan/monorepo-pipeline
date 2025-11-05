#!/bin/bash
set -e

echo "=========================================="
echo "Azure Backend Setup for Terraform State"
echo "=========================================="

# Configuration variables
RESOURCE_GROUP_NAME="terraform-state-rg"
STORAGE_ACCOUNT_NAME="tfstate${RANDOM}${RANDOM}"  # Must be globally unique
CONTAINER_NAME="tfstate"
LOCATION="centralus"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

echo ""
echo "Configuration:"
echo "  Resource Group: ${RESOURCE_GROUP_NAME}"
echo "  Storage Account: ${STORAGE_ACCOUNT_NAME}"
echo "  Container: ${CONTAINER_NAME}"
echo "  Location: ${LOCATION}"
echo "  Subscription: ${SUBSCRIPTION_ID}"
echo ""

# Check if already logged in
if ! az account show &> /dev/null; then
    echo "❌ Not logged in to Azure CLI"
    echo "Please run: az login"
    exit 1
fi

echo "✓ Logged in to Azure"

# Create resource group
echo ""
echo "Creating resource group..."
if az group show --name ${RESOURCE_GROUP_NAME} &> /dev/null; then
    echo "✓ Resource group already exists"
else
    az group create --name ${RESOURCE_GROUP_NAME} --location ${LOCATION}
    echo "✓ Resource group created"
fi

# Create storage account
echo ""
echo "Creating storage account..."
if az storage account show --name ${STORAGE_ACCOUNT_NAME} --resource-group ${RESOURCE_GROUP_NAME} &> /dev/null; then
    echo "✓ Storage account already exists"
else
    az storage account create \
        --resource-group ${RESOURCE_GROUP_NAME} \
        --name ${STORAGE_ACCOUNT_NAME} \
        --sku Standard_LRS \
        --encryption-services blob \
        --min-tls-version TLS1_2 \
        --allow-blob-public-access false
    echo "✓ Storage account created"
fi

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group ${RESOURCE_GROUP_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --query '[0].value' -o tsv)

# Create blob container
echo ""
echo "Creating blob container..."
if az storage container show --name ${CONTAINER_NAME} --account-name ${STORAGE_ACCOUNT_NAME} --account-key ${ACCOUNT_KEY} &> /dev/null; then
    echo "✓ Blob container already exists"
else
    az storage container create \
        --name ${CONTAINER_NAME} \
        --account-name ${STORAGE_ACCOUNT_NAME} \
        --account-key ${ACCOUNT_KEY}
    echo "✓ Blob container created"
fi

# Enable versioning
echo ""
echo "Enabling blob versioning..."
az storage account blob-service-properties update \
    --resource-group ${RESOURCE_GROUP_NAME} \
    --account-name ${STORAGE_ACCOUNT_NAME} \
    --enable-versioning true

echo "✓ Blob versioning enabled"

# Create backend configuration file
echo ""
echo "Creating backend configuration file..."
cat > backend-config.tfbackend <<EOF
resource_group_name  = "${RESOURCE_GROUP_NAME}"
storage_account_name = "${STORAGE_ACCOUNT_NAME}"
container_name       = "${CONTAINER_NAME}"
key                  = "global.tfstate"
EOF

echo "✓ Backend configuration saved to: backend-config.tfbackend"

echo ""
echo "=========================================="
echo "✓ Azure Backend Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Update providers.tf with the backend configuration"
echo "2. Run: terraform init -backend-config=backend-config.tfbackend -migrate-state"
echo ""
echo "Backend Configuration:"
echo "  resource_group_name  = \"${RESOURCE_GROUP_NAME}\""
echo "  storage_account_name = \"${STORAGE_ACCOUNT_NAME}\""
echo "  container_name       = \"${CONTAINER_NAME}\""
echo "  key                  = \"global.tfstate\""
echo ""
