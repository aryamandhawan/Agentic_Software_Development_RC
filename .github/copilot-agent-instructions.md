# Copilot Coding Agent Environment Instructions

These instructions are specific to the GitHub Copilot coding agent running in the ephemeral GitHub Actions environment.

---

## � Template Repository - Sample Files

This repository is a **template/starter project**. The existing files are **sample files** meant to demonstrate the project structure and patterns. When implementing a feature or building the application:

- **Delete or replace sample files** that don't apply to the specification
- **Modify existing files** to match the project requirements
- Files like `SampleBackendFunction.cs`, sample HTML pages, and placeholder content are meant to be replaced with actual implementation
- Keep infrastructure and configuration files (e.g., `staticwebapp.config.json`, `host.json`, `Program.cs`) but modify them as needed

**Do not preserve sample code just because it exists** — build what the specification requires.

---

## �🔐 Authentication in Sandboxed Environment

The SWA CLI's mock login UI (`/.auth/login/aad`) depends on jQuery from `ajax.aspnetcdn.com`, which is blocked by the agent's firewall. Use programmatic authentication instead:

### Set Auth Cookie via JavaScript (Recommended)

When using browser automation, evaluate this JavaScript to authenticate:

```javascript
const clientPrincipal = {
  identityProvider: "aad",
  userId: "test-user-id-12345",
  userDetails: "test@example.com",
  userRoles: ["anonymous", "authenticated"],
  claims: []
};
document.cookie = `StaticWebAppsAuthCookie=${btoa(JSON.stringify(clientPrincipal))}; path=/`;
```

Then navigate to `/app/` — the SWA CLI will recognize the session as authenticated.

### Set Auth Cookie via curl

```bash
AUTH_COOKIE=$(echo -n '{"identityProvider":"aad","userId":"test-user-id","userDetails":"test@example.com","userRoles":["anonymous","authenticated"],"claims":[]}' | base64 -w0)
curl -b "StaticWebAppsAuthCookie=$AUTH_COOKIE" http://localhost:4280/app/
```
