# Copilot Instructions

## ⚠️ CRITICAL: Dev Container Environment

**This project runs inside a VS Code Dev Container.** This has important implications:

### NEVER Use Aggressive Process Killing
Commands like these **WILL CRASH THE ENTIRE DEV CONTAINER SESSION**:
```bash
# ❌ DANGEROUS - DO NOT USE
pkill -9 -f "func" || true
pkill -9 -f "swa" || true
pkill -f "node" || true
kill -9 $(lsof -t -i:PORT)
```

These commands are dangerous because:
- The VS Code Server runs inside the container as a Node.js process
- `pkill -f "func"` can match unintended processes
- `pkill -f "swa"` or killing node processes will kill the VS Code Server
- This disconnects the entire dev container session

### Safe Alternatives
Instead of aggressive pkill commands:
1. **Use VS Code Tasks** - Run "swa stop" task which uses controlled process termination
2. **Use specific PIDs** - If you must kill a process, identify its exact PID first with `ps aux | grep <process>`
3. **Use graceful shutdown** - Send SIGTERM (not SIGKILL) and only to specific PIDs
4. **Ctrl+C in terminal** - For foreground processes, use Ctrl+C in their terminal

### If the Container Crashes
If you accidentally crash the container:
1. VS Code will show "Reconnecting..." or disconnect
2. Simply reconnect to the dev container
3. You may need to restart SWA and other services

---

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

## ⚠️ Security and Authentication

**CAUTION: Do NOT implement custom security or authentication mechanisms.**

Azure Static Web Apps provides built-in authentication via `/.auth/` endpoints. Always use this instead of rolling your own:
- Login: `/.auth/login/aad` (Azure AD)
- User info: `/.auth/me`
- Logout: `/.auth/logout`

The `staticwebapp.config.json` file controls route-level authentication requirements.

**If you absolutely must implement custom authentication logic:**
- **DO NOT use the `Authorization` header** - Azure Static Web Apps does not support custom Authorization headers on API requests. The platform strips or ignores them.
- Use cookies or custom headers with different names (e.g., `X-Custom-Token`)
- Store tokens in `localStorage` or `sessionStorage` and pass via request body or query parameters
- Consider if you really need this - the built-in auth is secure and well-tested

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

**See the "Dev Container Environment" section at the top of this file for critical warnings about process killing.**

**To avoid this:**
1. Always use the VS Code tasks (not manual terminal commands)
2. If SWA is behaving unexpectedly, use "swa stop" first, wait a moment, then use "swa start"
3. **NEVER use `pkill -9 -f "func"` or `pkill -9 -f "swa"`** - these will crash the container
4. If the container disconnects, simply reconnect - but be aware this was likely caused by aggressive port cleanup
 