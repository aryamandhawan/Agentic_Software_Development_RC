# Agentic Software Development Template

This repository has been designed to enable the Rapid Circle team to get up and running with a new Agentic Software solution as fast as possible.

## Overview

This template provides a starting point for building AI-powered agentic applications, streamlining the setup process and incorporating best practices for agent development.

## Getting Started

1. Clone this repository
2. Customize the configuration for your specific use case
3. Begin building your agentic solution

## Features

- Pre-configured project structure
- Best practices for AI agent development
- Ready-to-use templates and scaffolding

## Tools

### Azure Resource Setup

The `tools/setup-azure-resources.sh` script automates the creation of Azure resources needed for your agentic application.

**What it creates:**
- Azure Resource Group
- Azure Storage Account (for Table Storage and Blob Storage)
- Azure Static Web App (for hosting)

**Usage:**
```bash
./tools/setup-azure-resources.sh
```

The script will interactively prompt you for:
- Project name (defaults to repository name)
- Resource group name
- Static Web App name
- Storage Account name
- Azure location

After completion, you'll receive connection strings, deployment tokens, and next steps for deploying your application.

For more details, see [tools/README.md](tools/README.md).

## Support

For questions or support, please reach out to the Rapid Circle team.
