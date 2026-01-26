# Copilot Coding Agent Environment Instructions

These instructions are specific to the GitHub Copilot coding agent running in the ephemeral GitHub Actions environment.

---

## 🔐 Authentication in Sandboxed Environment

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

---

## 🚀 Starting Services

To start the full development environment:

```bash
# Start Azurite in background
azurite --silent --location .azurite --debug .azurite/debug.log &

# Start SWA CLI (this also starts Azure Functions)
swa start
```

The SWA emulator will be available at `http://localhost:4280`.

---

## 🧪 Testing Approach

1. **API-only testing**: Call `http://localhost:7071/api/...` directly (no auth required)
2. **Full app testing**: Use programmatic auth (above), then navigate to `http://localhost:4280/app/`
3. **Always verify**: After backend changes, restart SWA to pick up the new code
