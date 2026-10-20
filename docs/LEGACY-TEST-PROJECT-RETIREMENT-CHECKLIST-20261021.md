# Legacy TradeFlow TEST Project Retirement Checklist

**Date opened:** 21 October 2026  
**Status:** HOLD — do not delete  
**Legacy project ID:** `twfbmjwwqzxdxvclxbun`  
**Current LIVE project ID:** `gxsrajtqzdjvmceqcpgv`  
**Current TEST project ID:** `nnsshnfkjcflucjrftzi`

## Decision

The old TEST project is reference-only, but that is not enough evidence to permanently delete it. No deletion has been performed. The available current organization listing confirms LIVE and the new TEST project; it did not return the legacy project, so its present ownership/status and remaining dependencies still require verification.

## Required checks before deletion

- [ ] Confirm the old project appears in the correct Supabase organization/account and record its exact project name, owner organization, status, and region.
- [ ] Search all GitHub branches, including `production`, test branches, workflows, scripts, environment examples, deployment manifests, and Cloudflare Worker configuration for the old project ID and URL.
- [ ] Inspect all connected applications and deployed Workers for references to the old project URL, anon/publishable keys, or function endpoints.
- [ ] Inspect old-project Edge Functions, scheduled jobs, Auth redirect URLs, Storage buckets, database triggers, webhooks, and integrations.
- [ ] Confirm Stripe Sandbox and Stripe Live webhook destinations do not target old-project endpoints.
- [ ] Compare old TEST schema/migrations and required catalogue/reference data with new TEST. Confirm that any unique changes are either migrated or intentionally retired.
- [ ] Confirm no required transaction/test evidence, logs, uploaded files, Auth test users, or secrets are needed for audit or recovery.
- [ ] Export/retain a recoverable database backup and required Storage objects; record where the backup is stored and how restoration would work.
- [ ] Update any surviving references and manuals only after dependencies are confirmed absent.
- [ ] Obtain explicit owner approval for permanent deletion after the checklist is complete.

## Safe order of retirement

1. Perform read-only dependency and data inventory.
2. Preserve a verified backup and document its restore procedure.
3. Remove or redirect confirmed stale dependencies in a reviewed branch; do not change LIVE as part of this retirement.
4. If supported and appropriate, pause the old project as a reversible observation period.
5. Monitor the application and integrations for failures and verify the new TEST project remains usable.
6. Permanently delete only after all checks pass and the owner explicitly approves.

## Current blockers

- The old project was not returned by the currently available project listing.
- A complete cross-branch and deployment-reference audit has not been completed.
- Stripe Connect and payment webhooks in the new TEST environment have not yet been proven end-to-end.
- No verified backup/restore evidence for the old TEST project is recorded here.

**Conclusion:** keep the old TEST project undeleted for now. “Legacy/reference only” means do not use it for new work; it does not mean it is safe to destroy.
