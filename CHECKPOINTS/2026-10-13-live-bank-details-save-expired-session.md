# LIVE customer bank-details save repair — 2026-10-13
Branch: `fix-customer-bank-save-expired-session-20261013`
Environment: LIVE source only; TEST Supabase project `twfbmjwwqzxdxvclxbun` untouched.

## Evidence / root cause
- At 2026-10-13 17:08 UTC, LIVE Supabase logs show repeated POSTs to `/rest/v1/rpc/customer_save_bank_details` from the SceneSource portal returning HTTP 401 with PostgREST `PGRST303`.
- JWT log attributes show the access token expiry was earlier than these save attempts. The customer dashboard was retaining a stale access token in an already-open tab and its generic API helper did not refresh/retry after a 401.
- Read-only SQL confirmed the signed-in customer row exists for the matching auth user and tenant, but no `customer_bank_details` row existed after the failed save attempts.
- The save RPC definition exists and validates authenticated customer membership plus UK sort code (6 digits) and account number (8 digits). No evidence points to a schema/RPC defect in this incident.

## Repair on branch
- Added single-flight refresh of the tenant-scoped customer session via Supabase `/auth/v1/token?grant_type=refresh_token`.
- When an API call receives 401, the dashboard refreshes the session and retries that request once with the renewed access token.
- Bumped `customer-dashboard.js` asset reference from `v151` to `v152`.
- Updated AI operating manual, backend manual, human manual, system handbook, LIVE launch runbook and master roadmap.

## Safety
- No bank data was written through SQL or admin tools. No values copied from the screenshot.
- No customer, Auth, tenant, bank-details, schema, RLS, or RPC records were changed directly.
- LIVE only; TEST untouched.

## Status: CODE PREPARED, NOT YET DEPLOYED/VERIFIED
After merge/deploy, verify a real customer can save their own bank details, see a success message, reload My Details and retrieve the saved values, and see the outstanding bank-details notice clear. The screenshot's sample bank values must not be treated as genuine details. Do not mark resolved until this passes in the live portal.
