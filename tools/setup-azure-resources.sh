#!/bin/bash

# Setup Azure Resources for Agentic Software Development
# This script creates Azure resources for the project using Azure CLI

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get repository name as default project name
REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || echo "agentic-software-development")

echo -e "${GREEN}=== Azure Resource Setup ===${NC}\n"

# 1. Ask for project name
read -p "Enter project name [${REPO_NAME}]: " PROJECT_NAME
PROJECT_NAME=${PROJECT_NAME:-$REPO_NAME}
# Convert to lowercase and replace spaces/underscores with hyphens
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-' | tr ' ' '-')

echo -e "\n${YELLOW}Project Name: ${PROJECT_NAME}${NC}"

# 2. Ask for resource group name (default based on project name)
DEFAULT_RESOURCE_GROUP="rg-${PROJECT_NAME}"
read -p "Enter resource group name [${DEFAULT_RESOURCE_GROUP}]: " RESOURCE_GROUP
RESOURCE_GROUP=${RESOURCE_GROUP:-$DEFAULT_RESOURCE_GROUP}

# 3. Ask for Static Web App name (default based on project name)
DEFAULT_SWA_NAME="${PROJECT_NAME}-swa"
read -p "Enter Static Web App name [${DEFAULT_SWA_NAME}]: " SWA_NAME
SWA_NAME=${SWA_NAME:-$DEFAULT_SWA_NAME}

# 4. Ask for Storage Account name (default based on project name)
# Storage account names must be 3-24 characters, lowercase letters and numbers only
STORAGE_DEFAULT=$(echo "${PROJECT_NAME}" | tr -d '-' | cut -c1-20)st
read -p "Enter Storage Account name [${STORAGE_DEFAULT}]: " STORAGE_ACCOUNT
STORAGE_ACCOUNT=${STORAGE_ACCOUNT:-$STORAGE_DEFAULT}
# Ensure it meets storage account naming requirements
STORAGE_ACCOUNT=$(echo "$STORAGE_ACCOUNT" | tr '[:upper:]' '[:lower:]' | tr -d '-' | tr -d '_')

# Ask for Azure location
read -p "Enter Azure location [westeurope]: " LOCATION
LOCATION=${LOCATION:-westeurope}

echo -e "\n${GREEN}=== Configuration Summary ===${NC}"
echo -e "Project Name:       ${PROJECT_NAME}"
echo -e "Resource Group:     ${RESOURCE_GROUP}"
echo -e "Static Web App:     ${SWA_NAME}"
echo -e "Storage Account:    ${STORAGE_ACCOUNT}"
echo -e "Location:           ${LOCATION}"
echo ""

read -p "Proceed with resource creation? (y/n): " CONFIRM
if [[ ! $CONFIRM =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Resource creation cancelled${NC}"
    exit 0
fi

echo -e "\n${GREEN}=== Checking Azure CLI Authentication ===${NC}"
if ! az account show &>/dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Please login...${NC}"
    az login
fi

# Get list of subscriptions
echo -e "\n${GREEN}=== Select Azure Subscription ===${NC}"
SUBSCRIPTIONS=$(az account list --query "[].{name:name, id:id, isDefault:isDefault}" -o tsv)

if [ -z "$SUBSCRIPTIONS" ]; then
    echo -e "${RED}No subscriptions found. Please check your Azure account.${NC}"
    exit 1
fi

# Display subscriptions with numbers
echo "Available subscriptions:"
COUNTER=1
declare -a SUB_IDS
declare -a SUB_NAMES
while IFS=$'\t' read -r name id isDefault; do
    if [ "$isDefault" = "True" ]; then
        echo -e "  ${GREEN}${COUNTER}) ${name} (${id}) [DEFAULT]${NC}"
        DEFAULT_SUB_NUM=$COUNTER
    else
        echo "  ${COUNTER}) ${name} (${id})"
    fi
    SUB_IDS[$COUNTER]=$id
    SUB_NAMES[$COUNTER]=$name
    ((COUNTER++))
done <<< "$SUBSCRIPTIONS"

# Ask user to select subscription
if [ -n "$DEFAULT_SUB_NUM" ]; then
    read -p "Select subscription number [${DEFAULT_SUB_NUM}]: " SUB_CHOICE
    SUB_CHOICE=${SUB_CHOICE:-$DEFAULT_SUB_NUM}
else
    read -p "Select subscription number: " SUB_CHOICE
fi

# Validate selection
if [ -z "${SUB_IDS[$SUB_CHOICE]}" ]; then
    echo -e "${RED}Invalid subscription selection${NC}"
    exit 1
fi

# Set the subscription
SELECTED_SUB_ID=${SUB_IDS[$SUB_CHOICE]}
SELECTED_SUB_NAME=${SUB_NAMES[$SUB_CHOICE]}

az account set --subscription "$SELECTED_SUB_ID"
echo -e "${GREEN}Using subscription: ${SELECTED_SUB_NAME}${NC}\n"

echo -e "${GREEN}=== Creating Resource Group ===${NC}"
if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
    echo -e "${YELLOW}Resource group '${RESOURCE_GROUP}' already exists${NC}"
else
    az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
    echo -e "${GREEN}✓ Resource group created${NC}"
fi

echo -e "\n${GREEN}=== Creating Storage Account ===${NC}"
if az storage account show --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo -e "${YELLOW}Storage account '${STORAGE_ACCOUNT}' already exists${NC}"
else
    az storage account create \
        --name "$STORAGE_ACCOUNT" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION" \
        --sku Standard_LRS \
        --kind StorageV2 \
        --allow-blob-public-access false
    echo -e "${GREEN}✓ Storage account created${NC}"
fi

# Get storage account connection string
STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
    --name "$STORAGE_ACCOUNT" \
    --resource-group "$RESOURCE_GROUP" \
    --query connectionString -o tsv)

echo -e "\n${GREEN}=== Creating Static Web App ===${NC}"
if az staticwebapp show --name "$SWA_NAME" --resource-group "$RESOURCE_GROUP" &>/dev/null; then
    echo -e "${YELLOW}Static Web App '${SWA_NAME}' already exists${NC}"
else
    az staticwebapp create \
        --name "$SWA_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --location "$LOCATION"
    echo -e "${GREEN}✓ Static Web App created${NC}"
fi

# Get Static Web App details
SWA_HOSTNAME=$(az staticwebapp show --name "$SWA_NAME" --resource-group "$RESOURCE_GROUP" --query "defaultHostname" -o tsv)
SWA_API_KEY=$(az staticwebapp secrets list --name "$SWA_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.apiKey" -o tsv)

echo -e "\n${GREEN}=== Resource Creation Complete ===${NC}"
echo -e "\n${GREEN}Resource Details:${NC}"
echo -e "  Resource Group:     ${RESOURCE_GROUP}"
echo -e "  Static Web App:     ${SWA_NAME}"
echo -e "  SWA URL:            https://${SWA_HOSTNAME}"
echo -e "  Storage Account:    ${STORAGE_ACCOUNT}"

echo -e "\n${GREEN}=== Next Steps ===${NC}"
echo -e "1. Add the following to your local.settings.json:"
echo -e "   ${YELLOW}\"StorageConnectionString\": \"${STORAGE_CONNECTION_STRING}\"${NC}"
echo -e "\n2. Deploy your application:"
echo -e "   ${YELLOW}swa deploy --deployment-token \"${SWA_API_KEY}\"${NC}"
echo -e "\n3. Or configure GitHub Actions for CI/CD with the deployment token above"

# Save configuration to file
CONFIG_FILE="tools/.azure-config"
cat > "$CONFIG_FILE" << EOF
# Azure Resource Configuration
# Generated: $(date)

PROJECT_NAME=${PROJECT_NAME}
RESOURCE_GROUP=${RESOURCE_GROUP}
SWA_NAME=${SWA_NAME}
STORAGE_ACCOUNT=${STORAGE_ACCOUNT}
LOCATION=${LOCATION}
SWA_HOSTNAME=${SWA_HOSTNAME}
EOF

echo -e "\n${GREEN}Configuration saved to: ${CONFIG_FILE}${NC}"
