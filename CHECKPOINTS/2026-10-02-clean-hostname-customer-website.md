# Checkpoint — 2026-10-02 — Clean Hostname-Based Customer Website Boundary

## Scope
TEST only. No LIVE code or LIVE Supabase changes were made.

## Verified TEST database state
- TEST Supabase: `twfbmjwwqzxdxvclxbun`
- Camerashack tenant: `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`
- Published site index contains exactly one row for TEST:
  - hostname: `camerashack.co.uk`
  - tenant_id: `21fca2c5-5da2-4ff6-9f8e-318f9b6277f9`
  - revision: 9
- TEST `published_site_index` row count is currently 1.

## Architecture decision
Customer-facing tenant context is now intended to be determined by the hostname, not by a tenant UUID in the URL.

- Public website hostname identifies the subscriber tenant.
- Customer authentication identifies the customer account.
- Subscriber authentication identifies the subscriber account.
- Tenant IDs remain internal database identifiers only.
- Customer-facing navigation should not propagate `tenant_id`.

## TEST fallback
The existing TEST Worker hostname `tradeflow-test.leannelaurenlowe.workers.dev` is treated as a TEST-only single-tenant fallback because TEST currently contains exactly one published site. It resolves that single published site through `get_published_sites`.

This fallback is for TEST only. LIVE must resolve the subscriber from the real custom hostname.

## Code changes
On `cloudflare-test`:
- `public-site.js`: public website navigation no longer adds tenant IDs; hostname resolution is authoritative, with the TEST single-site fallback.
- `customer-auth.js`: resolves tenant from hostname and keeps email-confirmation/password-reset redirects tenantless.
- `customer-dashboard.js`: waits for customer auth tenant resolution before tenant-scoped portal work; public brand link is tenantless.
- `customer-dashboard-nav.js`: no longer propagates tenant IDs.
- `customer-basket.js`: resolves tenant from hostname, supports TEST single-site fallback, corrects the TEST publishable key, and keeps account navigation tenantless.
- `customer-email-confirmed.html`: continuation is tenantless.
- `customer-password-reset.html`: continuation is tenantless and TEST runtime detection/key are corrected.
- `customer-dashboard-auth-fix.js`: remains aligned with the TEST Worker runtime boundary.

## Syntax verification
The following TEST JavaScript files were fetched from `cloudflare-test` and parsed successfully:
- `public-site.js`
- `customer-auth.js`
- `customer-dashboard.js`
- `customer-basket.js`
- `customer-dashboard-nav.js`

## Deployment status
GitHub source changes are committed to `cloudflare-test`. Cloudflare deployment of the latest commit has not been independently verified from this environment. Do not mark browser acceptance as PASS until the latest Worker deployment is confirmed.

## Next acceptance test
After TEST Worker deployment:
1. Open the TEST Worker address in a fresh/incognito browser with no query string.
2. Confirm the Camera Shack public site loads without a tenant UUID.
3. Click Customer Login.
4. Confirm the URL contains no `tenant_id`.
5. Confirm the customer login page identifies Camera Shack.
6. Create/sign in to a customer account.
7. Confirm customer portal works without a tenant UUID.
8. Open the same TEST address in a separate subscriber session and confirm Customer Login still goes to the customer portal, never the subscriber dashboard.
9. Test navigation to shop, basket, and customer account without tenant UUIDs.
10. Once this passes, proceed to the final TradeFlow Assistant/chatbot stage.

## LIVE rule
Do not copy TEST fallback behavior into LIVE. LIVE customer routing must use the subscriber's actual custom hostname, e.g. `camerashack.co.uk`, and resolve the tenant from `published_site_index`.
