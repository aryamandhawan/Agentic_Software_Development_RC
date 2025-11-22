#!/bin/bash

# Initialize local.settings.json for Azure Functions API
# This script creates a local.settings.json if it doesn't exist
# Safe to run multiple times - won't overwrite existing files

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
API_DIR="$SCRIPT_DIR/../api"
LOCAL_SETTINGS_FILE="$API_DIR/local.settings.json"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}=== Initializing local.settings.json ===${NC}"

# Check if local.settings.json already exists
if [ -f "$LOCAL_SETTINGS_FILE" ]; then
    echo -e "${YELLOW}local.settings.json already exists, skipping creation${NC}"
    exit 0
fi

# Create local.settings.json with Azurite connection string
cat > "$LOCAL_SETTINGS_FILE" << 'EOF'
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "UseDevelopmentStorage=true",
    "FUNCTIONS_WORKER_RUNTIME": "dotnet-isolated",
    "StorageConnectionString": "UseDevelopmentStorage=true"
  }
}
EOF

echo -e "${GREEN}✓ Created local.settings.json with Azurite configuration${NC}"
echo -e "  File: $LOCAL_SETTINGS_FILE"
echo -e "\n${YELLOW}Note: This file uses Azurite (local storage emulator)${NC}"
echo -e "To use Azure Storage, update the connection strings in local.settings.json"
