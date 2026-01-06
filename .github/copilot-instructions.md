# Copilot Instructions

## Project Overview
- **Frontend**: Vanilla JavaScript, HTML, CSS
- **Backend**: .NET C# API
- **Database**: Azure Table Storage and Blob Storage (no SQL)
- **Caching**: Managed Redis on Azure (with core classes for implementation)
- **Hosting**: Azure Static Web Apps
- **Architecture**: No view framework (React, Vue, etc.)

## Code Style Preferences

### General Philosophy
- **Fail fast**: Prefer things to fail when they don't work as intended
- **Simple fallbacks only**: Avoid long chains of fallbacks
- **Modern JavaScript**: Use modern ES6+ features (const/let, arrow functions, async/await)
- **Minimal comments**: Only comment complex logic

### Frontend (JavaScript)
- Use vanilla JavaScript only - no frameworks
- Fetch API for HTTP requests
- Always use relative URLs for API calls (e.g., `/api/users` not `https://domain.com/api/users`)
- Implement both client-side and server-side validation

### Backend (C#)
- Use async/await patterns
- Implement validation on all API endpoints
- Standard .NET C# API patterns
- Utilize Redis caching where appropriate
- Use Azure Table Storage for structured data
- Use Azure Blob Storage for files/documents
- **IMPORTANT**: Always use the `STORAGE` environment variable for Azure Storage connection strings (Table Storage and Blob Storage)
  - Local development: Uses Azurite (configured in `local.settings.json`)
  - Production: Uses Azure Storage Account (configured as Static Web App environment variable)
- **IMPORTANT**: Always configure JSON serialization to use camelCase for property names (JavaScript expects camelCase, not PascalCase)

### Error Handling
- Follow standard best practices
- Let errors fail fast rather than creating complex fallback chains
- Simple, straightforward error messages

## Documentation Requirements
- **JSDoc for JavaScript**: Document all functions with JSDoc comments
- **XML Documentation for C#**: Use XML documentation comments for all public methods
- **README files**: Include when needed for complex features or modules
- Focus on documenting the "why" not the "what" (code should be self-explanatory)

## Azure Static Web Apps Specifics
- API calls are proxied - always use relative URLs
- Backend API is automatically deployed and linked

## File Organization
- No specific naming conventions required
- Keep structure simple and logical

## Performance Considerations
- Utilize Redis caching through existing core classes
- Be mindful of bundle sizes in vanilla JS
- Follow Azure Static Web Apps best practices
- Consider Table Storage query patterns for performance

## Key Reminders
1. This is vanilla JavaScript - no React, Vue, or other frameworks
2. Always use relative URLs for API calls in JavaScript code (e.g., `/api/users` not `https://domain.com/api/users`) - SWA proxies these to Functions
3. Fail fast - don't over-engineer error handling
4. Both frontend and backend validation is required
5. Keep comments minimal (but use proper JSDoc/XML documentation)
6. Use Table Storage and Blob Storage - no SQL databases
7. Implementing NEW backend APIs in C# is a big deal, please confirm you should do it, and clearly describe why it's needed
8. Always use the `STORAGE` environment variable for all Azure Storage operations (Table Storage and Blob Storage). Do NOT use `AzureWebJobsStorage` as this is reserved by Static Web Apps
9. Never commit secrets, connection strings, or the `tools/.azure-config` file to git
10. All API endpoints should be authenticated by default unless explicitly made public
11. Use camelCase for JSON properties sent to the frontend (JavaScript convention)
12. **Testing APIs locally**: Call the Azure Functions URL directly (`http://localhost:7071/api/...`), NOT through the SWA server (`http://localhost:4280/api/...`) which requires authentication. Use terminal tools like `curl`, or if Chrome MCP is available, test through the browser

---

## ⚠️ CRITICAL: Local Development with SWA CLI and Azurite

### ALWAYS Use VS Code Tasks for SWA
**NEVER run `swa start`, `swa stop`, or Azurite commands directly in the terminal.**

Instead, use the VS Code tasks:
- **"swa start"** - Starts SWA CLI and Azurite together
- **"swa stop"** - Stops SWA CLI gracefully
- **"swa restart"** - Stops then starts SWA

These tasks are configured to properly manage Azurite alongside SWA.

### Azurite Configuration
Azurite is configured in `swa-cli.config.json` to run automatically when SWA starts:
```
"run": "azurite --silent --location .azurite --debug .azurite/debug.log"
```

**Local Azurite Endpoints:**
- Blob Storage: `http://127.0.0.1:10000/devstoreaccount1`
- Queue Storage: `http://127.0.0.1:10001/devstoreaccount1`
- Table Storage: `http://127.0.0.1:10002/devstoreaccount1`

**Connection String (in `local.settings.json`):**
```
STORAGE=DefaultEndpointsProtocol=http;AccountName=devstoreaccount1;AccountKey=Eby8vdM02xNOcqFlqUwJPLlmEtlCDXJ1OUzFT50uSRZ6IFsuFq2UVErCz4I6tq/K1SZFPTOtr/KBHBeksoGMGw==;BlobEndpoint=http://127.0.0.1:10000/devstoreaccount1;QueueEndpoint=http://127.0.0.1:10001/devstoreaccount1;TableEndpoint=http://127.0.0.1:10002/devstoreaccount1;
```

### ⚠️ Known Issue: Port Killing Can Crash Dev Container
When Azurite is not running and SWA CLI attempts to recover, it may try to kill processes on various ports. **This can inadvertently kill the VS Code Server running inside the dev container**, causing the entire container session to disconnect.

**To avoid this:**
1. Always use the VS Code tasks (not manual terminal commands)
2. If SWA is behaving unexpectedly, use "swa stop" first, wait a moment, then use "swa start"
3. If the container disconnects, simply reconnect - but be aware this was likely caused by aggressive port cleanup
 