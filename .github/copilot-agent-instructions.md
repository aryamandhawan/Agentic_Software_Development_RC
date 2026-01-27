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
