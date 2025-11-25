Rotation & remediation guide — what to do now
==========================================

This guide lists explicit steps you should perform immediately to rotate/revoke any secrets that were exposed in the original repo and how to update your GitHub repository and CI/CD so your project keeps running securely.

High-level sequence (do these now, in order)
------------------------------------------------
1. Revoke the leaked keys in each provider (SendGrid, Cloudinary, VNPay, etc.)
2. Create new keys/secrets in the provider dashboard
3. Store new secrets in GitHub repo settings (Settings → Secrets → Actions, or via gh CLI)
4. Update deployments/containers to use the new secrets (Docker Compose, environment, or cloud provider)
5. Confirm everything works and monitor provider logs for suspicious usage

Secrets we found (examples — these are the repository environment variable names you should rotate/update):
- SENDGRID_API_KEY
- JWT_SECRET
- DB_PASSWORD, MYSQL_ROOT_PASSWORD
- CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET
- VNPAY_TMN_CODE, VNPAY_HASH_SECRET
- GHCR_TOKEN or DockerHub credentials (if using CD)

Provider-specific step-by-step
-----------------------------

1) SendGrid (email)
   - Go to the SendGrid dashboard -> Settings -> API Keys
   - Revoke/delete the exposed API key
   - Create a new API key with lowest required scope
   - Update the repo secret in GitHub called: SENDGRID_API_KEY
   - Update any running server environment (.env, container secrets) with new key
   - Check SendGrid logs for unusual activity and disable inbound/outbound templates tied to the old key if necessary

2) Cloudinary (image service)
   - Sign-in to Cloudinary -> Settings -> Security
   - Rotate the API secret and key pair (remove the leaked secret)
   - Update `CLOUDINARY_API_KEY` and `CLOUDINARY_API_SECRET` in GitHub secrets and application environments
   - If you used any CLI or CI secrets for Cloudinary, update them there too

3) VNPay (payment integration)
   - In your VNPay (merchant or sandbox) portal: rotate the hash-secret and (optionally) change the terminal code / merchant id
   - If VNPay doesn't allow rotating the same key, create a new merchant/test account and update `VNPAY_TMN_CODE` and `VNPAY_HASH_SECRET`
   - Update repository secrets and deployments
   - Monitor all payment activity for suspicious transactions

4) MySQL / DB credentials
   - Update root and application-dedicated DB user passwords
   - Replace `MYSQL_ROOT_PASSWORD`, `DB_PASSWORD` in Docker Compose, container environments and GitHub secrets
   - If your DB dump or credentials were public, treat data as compromised and rotate any external credentials, consider forcing password resets for affected accounts

5) JWT signing secret
   - Generate a **strong** new secret (e.g. 32+ random characters)
   - Replace `JWT_SECRET` / `JWT_SIGNING_SECRET` in GitHub secrets and all environments
   - Decide whether to invalidate existing JWT tokens (force logout flow) — if tokens are long lived, consider revoking all sessions

6) CI/CD & repository secrets (GitHub)
   - Add the new secrets to the repository (GitHub UI or gh CLI)
   - Suggested secret names used by workflows and apps:
     - SENDGRID_API_KEY
     - CLOUDINARY_API_KEY
     - CLOUDINARY_API_SECRET
     - VNPAY_TMN_CODE
     - VNPAY_HASH_SECRET
     - DB_PASSWORD
     - MYSQL_ROOT_PASSWORD
     - JWT_SECRET
     - GHCR_TOKEN (for pushing Docker images to GHCR)
     - DOCKERHUB_USERNAME & DOCKERHUB_PASSWORD (if you use DockerHub)

How to add/update repo secrets using GitHub CLI (recommended)
---------------------------------------------------------
Install GitHub CLI (https://cli.github.com/) and authenticate (gh auth login), then run from a safe machine:

PowerShell examples:

```powershell
# set a single secret (interactive) for the current repo
gh secret set SENDGRID_API_KEY --body "NEW_SENDGRID_KEY"

# set secrets for a remote repository (owner/repo)
gh secret set GHCR_TOKEN --body "<your-token>" --repo quangminh18112003/TestingCICD

# set with value from a file
gh secret set DB_PASSWORD --body "$(Get-Content -Raw secrets/db_password.txt)"

# list existing secrets in repo
gh secret list
```

If you prefer the web UI: go to your repository Settings → Secrets and variables → Actions → New repository secret. Add each secret name and value.

Tips for safely updating runtime environments (Docker / servers)
---------------------------------------------------------
- Update secret values in your deployment orchestration (example: Docker Compose environment files or CI/CD secret store) and restart services.
- In Docker Compose files, prefer referencing external secret managers or use env_file that is not committed to the repo.
- After updating secrets, perform smoke tests (login, email send) in staging to verify everything.

Check for remaining exposures
-----------------------------
- Run the included `scripts/scan_for_secrets.ps1` locally to list suspicious patterns.
- Confirm gitleaks workflow runs on PRs and fail if new secrets are introduced.

If you want me to automate this
------------------------------
- I can craft GitHub CLI commands with placeholders you can run locally (I'll not run them here). 
- If you'd like me to rewrite your repository history to remove secrets completely, I can prepare an action plan and commands using git-filter-repo or BFG — we must coordinate because rewriting history requires force-push and impacts collaborators.
