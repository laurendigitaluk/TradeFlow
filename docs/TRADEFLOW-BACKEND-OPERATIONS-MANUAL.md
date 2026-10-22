# TradeFlow Backend Operations Manual — LIVE

**Last updated:** 14 October 2026  
**Repository:** `laurendigitaluk/TradeFlow`  
**Production branch:** `production`

## 1. Environment boundary

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv` (`https://gxsrajtqzdjvmceqcpgv.supabase.co`).
- TEST Supabase project: `twfbmjwwqzxdxvclxbun`.
- Current instruction: operate in LIVE only. TEST is a reference environment and must not be modified during this work.
- Keep all code and SQL migrations version-controlled in the repository. Do not apply ad-hoc grants to make a UI error disappear.

## 2. Inventory permissions and Selling workflow

The authenticated browser role does not have broad direct UPDATE permission on `public.inventory_assets`. Preserve that boundary.

The following narrowly scoped RPCs are used by the Selling page:
- `subscriber_update_inventory_asset_sales_fields(p_tenant_id, p_asset_id, p_serial_number, p_location)`: saves serial number and location after checking authentication, `inventory.manage`, `module.inventory`, tenant and asset.
- `subscriber_sync_inventory_asset_status(p_tenant_id, p_asset_id, p_expected_status, p_new_status)`: permits only `ready_for_sale → listed` and `listed → ready_for_sale`, with the same tenant/permission/feature checks.

The migration for the status RPC is `supabase/migrations/20261014190000_subscriber_sync_inventory_asset_status.sql`; it was applied to LIVE on 14 October 2026. The earlier sales-fields RPC migration is `supabase/migrations/20261014180000_subscriber_update_inventory_asset_sales_fields.sql`.

The Selling HTML references `selling-dashboard-fixed.js?v=91` in production after the status-sync fix. If a browser still logs a direct PostgREST UPDATE against `inventory_assets`, check the deployed HTML and browser network request URL before changing permissions. A stale or alternate script was previously confirmed to keep sending direct UPDATE requests.

### Diagnostic sequence

1. Confirm the LIVE domain and tenant before running any query or test.
2. Inspect the deployed HTML script query version and browser Network tab for the actual JS URL.
3. Inspect LIVE Postgres logs for direct `UPDATE public.inventory_assets` statements versus RPC calls.
4. Verify the RPC definitions, EXECUTE grants and tenant permission checks.
5. Make a minimal code/migration correction on a branch, review it, merge to production, and apply any migration to LIVE through the approved process.
6. Retest once and inspect the first failure. Do not repeatedly retry or broaden table grants.

## 3. Website category and channel rules

- Website listings inherit the original inventory asset's `category_id` and `branch_id`; do not create duplicate shop categories.
- Publishing can create/reactivate the tenant's Website sales channel.
- Existing category and branch records should be enabled for selling where appropriate and verified before a listing is created.
- Verify the resulting channel, original category/branch IDs, listing and public shop visibility after deployment.

## 4. Public shop renderer and working template

The production public renderer is `public-site.js`; `public-site.html` loads the renderer. Public pages resolve the subscriber site from the hostname, business slug or tenant ID. Public published retail listings are loaded through `get_published_store_listings`; listing media is requested from the `public-listing-media` Edge Function.

The accepted What We Sell / Retail Shop page behaviour:
- It is a catalogue of published subscriber listings, not six manually edited placeholder tiles.
- Keep the **Find a product** search bar.
- Populate the **Category** dropdown and counts from categories present in the published listings.
- Search and category selection filter cards, update the visible count, and show a no-results message.
- Product cards link to product detail and show available photo, category, title, description and price.
- This behaviour applies to the dedicated shop page only. Do not remove unrelated editable homepage or What We Buy content.
- PR #146 records the implementation; public renderer cache key is `public-site.js?v=29`.

## 5. Shipping boundary

Manual shipping settings use subscriber-selected courier links. Customers pay postage directly to their selected provider. Do not restore the retired Parcel2Go API or legacy TEST provider connection. Settings navigation being visible does not prove retail fulfilment label upload is complete; test manual label upload, tracking and fulfilment independently.

## 6. Next controlled test: DJI Osmo Action 6 purchase

The public Adventure Outpost shop shows **DJI Osmo Action 6 Adventure Combo — £125.00**. Before starting checkout, confirm a safe test-payment mode. Do not initiate a real-money charge unless explicitly authorised.

Verify in order:
1. Product detail matches listing and price.
2. Basket preserves tenant/listing identity, title, £125.00 price and currency.
3. Customer sign-in/registration completes without a loop.
4. Checkout creates one order only.
5. Payment status matches the actual gateway outcome; no order is marked paid prematurely.
6. Customer dashboard, subscriber order/sales view and finance/ledger agree.
7. Inventory/listing transitions match the intended sold/reserved workflow.
8. Public product is no longer purchasable if it has been sold.
9. Shipping choice and tracking remain manual; TradeFlow must not collect postage.

Record actual statuses and references. Stop at the first failure and diagnose before retrying.

## 7. Release references and documentation

- PR #139: Website channel/category inheritance baseline.
- PR #141: category/branch selling flags and Shipping Settings navigation.
- PR #142: permission-scoped inventory sales-field updates.
- PR #143: permission-scoped inventory status synchronisation.
- PR #146: What We Sell live catalogue layout with search and category filter.

Keep `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`, `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`, `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`, and `subscriber-website-manual.html` aligned when this workflow changes.


## Operations update — 22 October 2026

Do not promote the entire TEST branch to production: branch comparison shows significant divergence (114 commits ahead, 38 behind). Review changes individually and preserve environment-specific Stripe configuration. Latest user-observed TEST check: product settings for TradeFlow, StudioFlow and BusinessFlow are present; subscriber password setup and repeat sign-in worked via the subscriber portal. The resend setup-link button remains unverified. No LIVE data/schema/Stripe change was made in this pass. Legacy-code cleanup requires reference/dependency checks before deletion; preserve migrations and checkpoints as audit/rollback history.


## Audit continuation — 22 October 2026 (LIVE source reconciliation and Supabase advisors)

- Latest GitHub comparison for `production` against `test/stripe-connect-test-mode-repair-20261020`: TEST is 114 commits ahead and 42 behind. Earlier 38/33-behind figures in prior notes are stale. Do not bulk-merge.
- LIVE deployed Edge Functions are present: `stripe-connect-onboarding` version 13 (JWT verification enabled; deployed source SHA-256 `f4f4d6054e486901cab6ec488bcd6baa1e9f445485b558102603822771c3c7de`) and `stripe-connect-webhook` version 4 (JWT verification disabled as expected for a webhook; deployed source SHA-256 `ec13b5ff7d6ceda7a42c3bf00d046fd184759c4500687de9208eec4eed7ecdd7`). Both are ACTIVE in LIVE.
- The corresponding source files were absent from `production`. Exact source was retrieved from the deployed LIVE functions and committed to version control without redeploying or changing runtime behavior: onboarding source commit `421c7e66529b20f0542925a0c66a5c7b32238afd`; webhook source commit `6e83cfe28faec14fbfbb8e563c67ee38038f3609`. This repairs source traceability only; it is not a deployment or a functional test.
- LIVE onboarding source uses a LIVE-key guard, validates the Supabase user and active tenant owner/admin membership, and uses a Stripe idempotency key. TEST source is not interchangeable: it includes an explicit environment-mode guard and differs in implementation. Keep each deployed implementation environment-specific.
- Read-only SQL checks in LIVE and TEST each found 99 public tables, zero public tables without RLS, zero SECURITY DEFINER functions missing a configured search_path, and zero direct anon/PUBLIC grants on the inspected sensitive payment, membership, subscription and customer tables. These checks do not prove all RLS expressions, RPC authorization, storage policies, or tenant boundaries are correct.
- Supabase security advisors in both environments report: `pg_net` installed in `public`; 8 SECURITY DEFINER RPCs executable by `anon`; 165 such functions executable by `authenticated` in LIVE and 164 in TEST; and leaked-password protection disabled. Review the eight anon-callable functions individually because some public-site/catalogue RPCs may intentionally serve public pages. Do not blanket-revoke function grants. Enable leaked-password protection through a separately verified Auth settings change.
- Performance advisor snapshot: both environments report 65 unindexed foreign keys, 166 RLS init-plan warnings, and 14 multiple-permissive-policy warnings. LIVE reports 64 unused-index notices and 3 duplicate-index notices; TEST reports 112 unused-index notices. Do not drop indexes based only on a fresh/low-traffic usage snapshot. Review duplicate indexes against constraints and migrations before any change.
- Sensitive-table policy inspection showed tenant-membership/permission checks on customers, payment records, payment-provider connections, payment-provider customers and tenant subscriptions in both environments. This was a targeted inspection, not a complete cross-tenant penetration test.
- Outstanding: inspect all advisor-listed anon-callable SECURITY DEFINER functions and their grants/body authorization; audit full tenant isolation and payment/ledger writes; compare deployed LIVE/TEST checkout and payment-webhook source; verify the complimentary setup resend flow only under a deliberate test plan; run manual browser checks where specified. No SQL permissions, schemas, Stripe settings, data or Edge Function deployments were changed in this audit.

## 2026-10-22 Follow-up — public website access hardening

LIVE migration `public_published_content_active_tenant_guard_20261022` applied (remote version `20261022143445`; source: `supabase/migrations/20261022160000_public_published_content_active_tenant_guard.sql`). It adds active-tenant checks to public site/listing/media SECURITY DEFINER RPCs, changes the public profile and published-site-index RLS policies to the active-tenant predicate, and grants `anon` EXECUTE on `private.is_active_tenant(uuid)` for policy evaluation while leaving schema `private` inaccessible directly. The `public-listing-media` Edge Function was deployed as version 11 with an explicit active-tenant check before signing media URLs.

Post-change verification as role `anon`: `tenant_public_profiles`, `published_site_index`, and `get_published_sites()` remain readable for the active published site (one row each); direct private-schema access is denied. One active tenant and zero inactive-tenant index rows were present at verification. Do not blanket-revoke public published-content functions; review their returned fields and active-tenant guard individually. Full browser/API and tenant-isolation/payment testing remains outstanding.

## LIVE security continuation — 22 October 2026

- Applied LIVE migration version `20261022144655` (`secure_test_registration_and_scope_domain_rpcs_20261022`). Source file is aligned to the remote migration version at `supabase/migrations/20261022144655_secure_test_registration_and_scope_domain_rpcs_20261022.sql`.
- Reconciled the published-content guard source filename to LIVE migration version `20261022143445`; its source now lives at `supabase/migrations/20261022143445_public_published_content_active_tenant_guard_20261022.sql`. Do not reapply either migration.
- Hardened `admin_complete_test_registration` and `staff_complete_test_registration`: both now require the target tenant to be active and `settings.test_lab` to equal true, in addition to their existing authentication, email, and reserved-slug checks.
- Added tenant-explicit RPC signatures `subscriber_get_custom_domain_status(p_tenant_id uuid)` and `subscriber_request_custom_domain(p_tenant_id uuid, p_hostname text)`. Both require an authenticated active membership for that exact active tenant and `website.manage`; their execution is granted to `authenticated` only, not `anon`/PUBLIC.
- Kept legacy no-argument / hostname-only signatures for backwards compatibility, but changed them to fail closed if the user has multiple active tenant memberships rather than selecting an arbitrary tenant.
- Updated production `domain-settings.js` to pass its selected `tenantId` to both explicit RPCs (commit `727508bf1944bf914ee46072e6ae0f4927617746`).
- Verified with LIVE SQL that both new domain RPCs are SECURITY DEFINER with pinned search paths; `has_function_privilege` confirms `anon` cannot execute them and `authenticated` can. LIVE currently has zero active reserved test slugs and zero active `test_lab` tenants.
- Restored the previously missing source for `platform-create-complimentary-subscriber` at `supabase/functions/platform-create-complimentary-subscriber/index.ts` (commit `b9f97dda6584aadef1055a212571400389fff2aa`) and deployed LIVE version 2. Deployed source exactly matches the production-branch file; JWT verification remains enabled. Added explicit `POST, OPTIONS` CORS methods, corrected the stale TEST message to LIVE, stopped returning raw RPC error text or invited user IDs, and made unexpected errors generic while logging safe status-only diagnostics.
- No domain request, invitation, customer, transaction, catalogue, pricing, or valuation record was created by verification. No browser end-to-end domain or complimentary-subscriber flow test was performed; these remain required before calling those workflows fully verified.
- Still open: review remaining authenticated SECURITY DEFINER functions; review leaked-password protection and `pg_net`; complete browser/API tenant-isolation and payment tests; perform a controlled owner-portal test of complimentary subscriber provisioning.
