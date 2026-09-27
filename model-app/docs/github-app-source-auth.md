# Source read authentication

The app reads the public industry-data-models repo to browse, preview, and
download models, and to check the upstream agent release. Those reads go to
GitHub over HTTP. GitHub rate-limits **unauthenticated** requests to **60 per
hour per IP**. On Databricks Apps the egress IP is shared across the workspace,
so the anonymous budget is exhausted almost immediately and downloads fail.

Authenticating the reads raises the budget to **5,000 requests/hour**. Reading
*public* content only needs *any* authenticated credential to get there, so
there are three modes, configured per installation in **Settings → Sources →
Source read access**:

| Mode | What it uses | When to pick it |
|---|---|---|
| **GitHub App** (recommended) | A GitHub App installation token, minted per request from the App's private key | Production installs — security-aligned, no long-lived user token, immune to the target org's SAML SSO |
| **Personal access token** | A PAT sent as `Authorization: Bearer <token>` | The simplest path to the 5,000/hr budget when a full App is more than you want to set up |
| **Anonymous** | No credential (60/hr) | Only for a quick local trial; downloads behind a shared egress IP will fail |

Secret material — the App private key (PEM) and the PAT — lives in a
**Databricks secret scope**. The app row stores only the scope/key *reference*;
the secret value never lands in Lakebase and is never returned by the API.

When Settings is left unconfigured, the app falls back to the deployment-wide
GitHub App environment credentials if present, then to anonymous.

## GitHub App (recommended)

1. Create (or reuse) a GitHub App. It needs no repo write scope for reads — the
   public-repo contents read is enough. Note its **App ID**, and install it so
   you have an **installation ID**.
2. Put the App's RSA private key (PEM) into a Databricks secret scope:

   ```bash
   databricks secrets create-scope <scope>          # if the scope does not exist
   databricks secrets put-secret <scope> <key> --string-value "$(cat app-private-key.pem)"
   ```

3. Grant the app's service principal **READ** on the secret scope, so the app
   can read the PEM at request time:

   ```bash
   databricks secrets put-acl <scope> <app-service-principal> READ
   ```

4. In **Settings → Sources → Source read access**, choose **GitHub App
   (recommended)** and fill in the App ID, installation ID, and the PEM secret
   scope + key. Save.

The app mints a short-lived installation token per request (cached ~55 min) and
reads through the GitHub Contents API. Nothing user-specific is involved, so the
target org's SAML SSO does not block it.

## Personal access token

1. Create a GitHub PAT. For public-repo reads a fine-grained token with
   **public repositories, read-only** (or a classic token with `public_repo`) is
   enough.
2. Store it in a Databricks secret scope and grant the app SP READ on the scope,
   exactly as in steps 2–3 above.
3. In Settings, choose **Personal access token** and fill in the PAT secret scope
   + key. Save.

The token is sent as `Authorization: Bearer <token>` on each read. It is a
long-lived credential tied to a user, which is why GitHub App is the recommended
production mode.

## Anonymous

No configuration. Reads run unauthenticated and are capped at 60 requests/hour
per egress IP. Behind the shared Databricks Apps egress IP that budget is
effectively shared with everything else on the workspace, so browsing degrades
and downloads fail. Use this only for a brief local trial.

## The required grant

Whichever authenticated mode you pick, the app's service principal must have
**READ on the secret scope** holding the credential:

```bash
databricks secrets put-acl <scope> <app-service-principal> READ
```

Without that grant the read-auth resolver cannot read the secret; it degrades to
anonymous and the Settings page + the source-explorer banner show a generic
"could not read the configured secret" message (the scope and key are never
echoed back).
