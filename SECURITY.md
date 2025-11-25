# Security & Secret rotation checklist

## What I found

In the original repository several files contained sensitive defaults or real credentials which caused push protection to block earlier pushes. Examples included SendGrid keys, Cloudinary credentials, VNPay merchant values, DB passwords and the JWT secret. The sanitized repository uses placeholders for these values.

## Priority actions (do these now)

1. Revoke and rotate exposed provider credentials immediately (SendGrid, Cloudinary, VNPay, any cloud DB or hosting panels).
   - Revoke the leaked key(s) and create new keys with minimal required permissions.
   - Update production/staging systems to use the new secrets.
2. Rotate database credentials.
   - Change MySQL root and application user passwords.
   - Update container/orchestration secrets and CI configuration.
3. Rotate JWT signing secret.
   - Replace the JWT secret in all environments and consider invalidating existing tokens where applicable.

## Per-service steps (short guidance)

- **SendGrid**:
  1. Log in to SendGrid dashboard > Settings > API Keys → revoke the exposed key.
  2. Create a new key with only the permissions you need and update `SENDGRID_API_KEY` in your environment and CI secrets.
  3. Check SendGrid logs for suspicious activity.
  Docs: https://docs.sendgrid.com/for-developers/sending-email/api-getting-started

- **Cloudinary**:
  1. Log in to Cloudinary console → Settings → Security -> rotate/remove API credentials.
  2. Update service environment variables.
  Docs: https://cloudinary.com/documentation/security_and_protection

- **VNPay**:
  1. Rotate the VNPay merchant secret or create a new sandbox/merchant account in VNPay dashboard.
  2. Update `VNPAY_TMN_CODE` and `VNPAY_HASH_SECRET` in deployment/CI.
  If you’re unsure how to rotate, contact VNPay support.

- **MySQL (database)**:
  1. Change root and DB user passwords immediately.
  2. If a DB dump was exposed, treat it as compromised and rotate all credentials.

- **JWT secret**:
  1. Generate a strong random secret (e.g. 32+ random characters) and replace JWT secret in all environments.
  2. Force session invalidation if tokens are long-lived.

## Repository hygiene & follow-up

- Do not re-push history containing secrets. If you require secrets removed from all commits, I can help rewrite history using `git-filter-repo` or BFG (destructive — requires force-push and coordination).
- Enable GitHub push protection / secret scanning, and add environment secrets in GitHub Settings.

## Quick local scan example (PowerShell)

```powershell
Get-ChildItem -Recurse -File | Select-String -Pattern 'SG\.|SENDGRID|CLOUDINARY|VNPAY|DB_PASSWORD|JWT_SECRET|CLOUDINARY_API_SECRET' -List | Format-Table Path,LineNumber -AutoSize
```

## If you'd like me to proceed

- I can produce a checklist with provider-specific docs and exact next steps for each (I recommend doing revocation first, then update CI secrets, then rotate application configuration).
- I can also implement a GitHub Action to scan for secrets on PRs and add extra repository protection settings.
