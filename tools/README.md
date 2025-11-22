# Azure Resource Setup Tools

This folder contains scripts for setting up and managing Azure resources for the Agentic Software Development project.

## Scripts

### init-local-settings.sh

Creates a default `api/local.settings.json` file with Azurite configuration for local development.

**What it does:**
- Checks if `local.settings.json` already exists
- If not, creates it with Azurite (local storage emulator) connection strings
- Safe to run multiple times - won't overwrite existing files

**Usage:**
```bash
./tools/init-local-settings.sh
```

**Note:** This script runs automatically during dev container creation via `postCreateCommand`.

**Configuration created:**
- `AzureWebJobsStorage`: Uses Azurite local emulator
- `StorageConnectionString`: Uses Azurite local emulator
- `FUNCTIONS_WORKER_RUNTIME`: Set to `dotnet-isolated`

### setup-azure-resources.sh

Interactive script that creates Azure resources using Azure CLI.

**What it does:**
1. Prompts for project name (defaults to repository name)
2. Prompts for resource group name (required)
3. Prompts for Static Web App name (defaults to `{project-name}-swa`)
4. Prompts for Storage Account name (defaults to sanitized project name + "st")
5. Creates the following Azure resources:
   - Resource Group
   - Azure Storage Account (Standard_LRS)
   - Azure Static Web App

**Usage:**
```bash
./tools/setup-azure-resources.sh
```

**Requirements:**
- Azure CLI (`az`) installed and available
- Authenticated to Azure (script will prompt login if needed)
- Appropriate permissions to create resources in your Azure subscription

**Output:**
- Creates Azure resources
- Displays resource URLs and connection strings
- Saves configuration to `tools/.azure-config`
- Provides next steps for deployment

## Configuration

After running the setup script, a `.azure-config` file will be created with your resource details. This file is gitignored by default.

## Example

```bash
cd /workspaces/Agentic-Software-Development
./tools/setup-azure-resources.sh
```

The script will interactively prompt for:
- Project name [Agentic-Software-Development]
- Resource group name: rg-agentic-dev
- Static Web App name [agentic-software-development-swa]
- Storage Account name [agenticsoftwaredevelopmentst]
- Azure location [eastus]
