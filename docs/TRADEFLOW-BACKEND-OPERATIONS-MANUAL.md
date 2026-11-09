# CURRENT OPERATIONS UPDATE — 7 NOVEMBER 2026

- Approved TEST Supabase: nnsshnfkjcflucjrftzi.
- Approved LIVE Supabase: gxsrajtqzdjvmceqcpgv.
- Retired project twfbmjwwqzxdxvclxbun is forbidden; older references below are historical only.
- The LIVE Common Room migration and four additive routing/security migrations are installed. Owner RPCs are authenticated with active-membership checks; agent RPCs are service_role-only; all four use an empty search_path. PR #267 is merged to production; the Research PC worker has completed a controlled LIVE research task and posted an owner-visible handover. Cloudflare dashboard deployment and the separate owner-instruction delivery test remain unverified.
- A LIVE dashboard defect was confirmed: Research Again previously changed a candidate to `needs_research` without enqueuing a new task. The fix from PR #268 is merged to `production` as `a76cf1e3d0ea5e9c068f05a9242cab98d5839f3e`; it uses the existing owner enqueue RPC before the existing review RPC. PR #269 merged the dashboard JS cache-bust to `?v=27` (`fa14ebaad62039b413962a09a466bc7d36b92912`). Cloudflare deployment/browser acceptance remain pending. Do not re-click repeatedly or manually insert rows into `platform_ai_agent_tasks`.
- The Research PC updater must preserve the separate local environment file selected by TRADEFLOW_GEMMA_ENV_FILE. Update code without overwriting the existing .env, tokens, API keys or local Ollama configuration. Never copy these secrets into GitHub, the dashboard or Common Room messages.
- Gemma receives bounded Common Room guidance in the extraction prompt; exact task identity, approved category sources, evidence validation and human review rules remain authoritative.
- How It Works is source-managed in how-it-works.html / how-it-works.css; the legacy JSON draft is not its published source. Examples remains owner-CMS editable.
- The Owner Dashboard now has nine consistent collapsible management sections; its overview statistics remain visible.
- Shipping is manual: the subscriber selects supported services and manages the handoff, while the customer pays the selected carrier directly. TradeFlow does not collect shipping charges or book courier services.

---

# TradeFlow Backend Operations Manual — LIVE

**Last updated:** 7 November 2026  
**Repository:** `laurendigitaluk/TradeFlow`  
**Production branch:** `production`

## 1. Environment boundary

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv` (`https://gxsrajtqzdjvmceqcpgv.supabase.co`).
- TEST Supabase project: `nnsshnfkjcflucjrftzi`. The retired `twfbmjwwqzxdxvclxbun` project must never be used.
- LIVE is authoritative for product research and research candidates. TEST is reserved for code development, migrations and regression; it is not a live agent research queue.
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
- Still open: review remaining authenticated SECURITY DEFINER functions; enable leaked-password protection through supported Auth configuration; assess the `pg_net` advisor warning carefully. LIVE has an active `tradeflow-notification-queue` cron job running every minute via `net.http_post`, using Vault secrets named `tradeflow_project_url` and `tradeflow_notification_processor_secret` and the `x-tradeflow-cron-secret` header. The `process-notification-queue` function is version 10 with JWT verification disabled but checks that secret; do not move the extension or alter the cron job until the queue path is regression-tested. Complete browser/API tenant-isolation and payment tests, and run a controlled owner-portal test of complimentary subscriber provisioning.


### Post-change Supabase advisor snapshot — 22 October 2026, 14:50 UTC

- Security: 8 anonymous-executable SECURITY DEFINER RPCs (reviewed as intended public catalogue/published-content/plan endpoints); 167 authenticated-executable SECURITY DEFINER functions requiring continued individual review; `pg_net` extension reported in `public`; leaked-password protection disabled.
- Performance: 65 unindexed foreign keys, 166 RLS init-plan warnings, 64 unused-index notices, 14 multiple-permissive-policy warnings, 3 duplicate-index notices, and an informational Auth connection-allocation warning.
- These advisor findings are not proof of exploitable vulnerabilities on their own. Do not blanket-revoke RPCs or drop indexes. Prioritize authorization review of privileged functions and verify each index/policy against actual query plans and workload before changing it.


## Cross-agent coordination and follow-up — 22 October 2026

- Read `COORDINATION-QUESTION-2026-10-22.md` and replied with this agent's scope, database/deployment status, and boundaries (coordination branch commit `c5b28d9b6d5fca44778490d9a736c7c06c2328a3`). Shared memory was updated at commit `af8111e43213ebcb4bdc08669b0c81e33d706ecd`.
- Scope remains LIVE security review/hardening. No pricing formulas, pricing UI, evidence tables/policies, catalogue ingestion, or evidence research code was edited. The other agent's exact branch/files/database scope is still awaiting confirmation.
- To avoid conflict, no further schema/migration writes should be made on shared pricing/evidence surfaces until coordination confirms scope. Continue read-only review meanwhile.
- Read-only review of the four test-registration RPCs confirms admin/staff/customer registration and customer status all require an active tenant with `settings.test_lab=true`; all are non-executable by `anon`, executable by `authenticated`. LIVE has no active reserved test tenants or active test-lab tenants at this snapshot.
- Read-only review of platform-owner helpers confirms `private.is_platform_owner` is defined by active membership in `platform_memberships`, and all current active memberships pass that guard (1 active, 1 passes, 0 mismatches). Four platform settings/product-page RPCs use the equivalent active-membership check directly; no present-state privilege mismatch was found.
- Public `SECURITY DEFINER` endpoints reviewed at a high level return active published site revisions, published store listings/media, published catalogue entries, or website-visible active plan rows. The catalogue and plan endpoints are intentionally left out of deeper review to avoid overlap with the separate pricing/evidence agent.


## LIVE security audit continuation — 22 October 2026 (second pass)

### Read-only checks
- Refreshed LIVE Supabase security/performance advisor snapshot (observed 2026-10-22 15:00 UTC). Existing advisor totals remain: 8 anonymous-executable SECURITY DEFINER endpoints, 167 authenticated-executable SECURITY DEFINER functions, 65 unindexed foreign keys, 166 RLS init-plan notices, 64 unused-index notices, 14 multiple-permissive-policy notices, 3 duplicate-index notices, pg_net in public, leaked-password protection disabled, and informational Auth connection allocation notice. These are audit leads, not proof that every flagged item is exploitable.
- Reviewed RLS flags on high-value tenant and transaction tables: `tenants`, `tenant_memberships`, `tenant_subscriptions`, `customers`, `customer_bank_details`, `buying_requests`, `buying_items`, `offers`, `acquisitions`, `payment_records`, `retail_orders`, `customer_credit_accounts`, `customer_credit_holds`, `tenant_domains`, `platform_owner_domain_actions`, `media_assets`, `listings`, and `inventory_assets` all have RLS enabled.
- `customer_bank_details`, `customer_credit_accounts`, `customer_credit_holds`, and `platform_owner_domain_actions` each have explicit deny-all direct client policies for `anon` and `authenticated`. Payment-record policies are permission-gated by tenant finance permissions.
- Reviewed platform-admin private helper definitions. The create-tenant helper calls `private.has_platform_owner_access()`; user lookup, tenant listing, subscriber listing and subscription management helpers call `private.require_platform_owner()`. Private schema helpers were not executable by anon; service-role-only helpers remained service-role-only.
- Reviewed notification processor DB RPC privileges: `notification_processor_auth_secret`, `claim_notification_queue_batch`, `mark_notification_sent`, and `mark_notification_failed` are SECURITY DEFINER with pinned empty search path, not executable by anon/authenticated, and executable by service_role only. The secret-returning RPC explicitly checks `current_user = 'service_role'`. The deployed processor compares the request's `x-tradeflow-cron-secret` header with that secret before claiming work. No queue data or secret values were read.
- Public published-site/store RPCs reviewed at high level are scoped to active tenants and published revisions/listings. No confirmed new tenant-isolation vulnerability was established by this pass.

### No changes made
- This pass was read-only: no SQL writes, migrations, Edge Function deployments, customer-data changes, or payment/invitation tests.
- Pricing/evidence/catalogue surfaces remain excluded pending the other agent's scope confirmation.

### Outstanding
- Leaked-password protection remains disabled; no supported Auth configuration control was available through the connected Supabase actions in this pass, so it was not changed.
- Browser-level smoke tests for tenant-scoped custom domains and complimentary subscriber creation remain outstanding.
- Review the 65 unindexed foreign keys and duplicate-index notices individually before changing indexes. Do not blindly drop unused indexes, merge branches, or move pg_net while the live cron path lacks regression coverage.

- Follow-up validation of the advisor's multiple-permissive-policy notices confirmed that the relevant buying/inventory/acquisition policies pair broad membership policies with RESTRICTIVE subscription/permission policies. PostgreSQL applies restrictive policies as additional AND conditions, so the membership policies do not by themselves bypass the relevant permission/feature checks. This pass did not establish an exploitable RLS bypass from those policy pairs.


## Notification queue service-role guard correction — 22 October 2026

The LIVE notification worker was returning HTTP 500 responses at its scheduled minute interval. Logs showed the database exception Not authorised from notification_processor_auth_secret(). The function was SECURITY DEFINER, owned by postgres, and incorrectly compared current_user to service_role; inside SECURITY DEFINER, current_user is the function owner. The same defect existed in shipping_provider_credentials_for_service(uuid).

LIVE migration 20261022151000_fix_service_role_jwt_guards_20261022 replaces these checks with auth.role(), while keeping EXECUTE restricted to service_role. LIVE privilege checks after the migration confirm anon=false, authenticated=false, service_role=true for both functions. Migration source: supabase/migrations/20261022151000_fix_service_role_jwt_guards_20261022.sql, production commit b87b8257be16edcfade2f059b3b157cf55c9096a.

Do not retrieve the secret directly or invoke the secret-returning RPC manually. Check the next scheduled worker request for HTTP success and absence of Not authorised before declaring queue recovery. As of this note, post-migration successful processing has not yet been confirmed. No TEST changes or Edge Function redeployment was made.


## Multi-item valuation update — 28 October 2026

TradeFlow supports multiple products under one buying request while preserving a separate item record and lifecycle for each product. The customer portal groups published initial/revised offers for a request into one quote, shows item-level cash/trade-in values and combined totals, and supports item-by-item accept/refuse decisions plus whole-quote actions. Final offers after inspection remain item-specific.

The subscriber Buying workspace groups items from the same request, stacks the item valuation panels before evidence/photos, and provides one “Submit total valuations” action. Each item's values remain separate. **Current limitation:** the submit action calls the manual valuation RPC sequentially per item; it is not an atomic batch. If a later item fails, earlier offers may already have been created.

UI was reviewed in screenshots and JavaScript syntax checks passed. Mixed accept/refuse and the full shipping-to-inventory lifecycle have not yet passed end-to-end verification. See `CHECKPOINTS/2026-10-28-multi-item-valuation.md` for the full test checklist and safeguards. Do not mark this workflow fully verified until those tests pass.


## LIVE subscriber checkout security — deployed 1 November 2026

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv` (EU West 2).
- `subscriber-create-checkout-session` is deployed and verified at Edge Function version **13** with JWT verification enabled.
- Migration `guard_subscriber_signup_subscription_collisions` is applied to LIVE and recorded as `20261101130118`.
- The database finalisation RPC now serialises signup finalisation per Auth user, accepts a retry only for the same existing Stripe subscription ID, and rejects a different subscription ID rather than replacing an existing subscription.
- LIVE checkout validates the exact platform HTTPS origin, uses origin-bound CORS, no longer trusts Referer, checks for an existing active business before creating checkout, and sends a stable per-user Stripe idempotency key.
- TEST Stripe is not required for this LIVE deployment and was not changed.
- No Stripe products, prices, API secrets, dashboard settings, customer records, payment records or existing subscription rows were changed.
- Deployment and database state are confirmed. Full real-browser checkout and webhook E2E verification have not yet been performed; do not mark the entire signup journey fully tested until that is complete.


## LIVE subscriber checkout — billing interval and verification status (1 November 2026)

The LIVE subscriber signup functions now store the correct monthly or annual interval from the exact configured Stripe Price ID. The finalisation RPC rejects an unrecognised Price ID before creating a tenant; the subscription-sync RPC updates the interval only for a recognised configured monthly/annual Price ID and otherwise preserves the stored value. The migration is `20261101131036_preserve_subscriber_billing_interval.sql`, applied to LIVE as registry version `20261101131036`.

The configured LIVE plan remains £59.99 monthly or £499.99 annually, GBP, with a 30-day trial. Existing subscription rows, Stripe products/prices, Stripe secrets, customer/payment records and Stripe dashboard settings were not changed. TEST Stripe is not required for this LIVE work.

Important verification boundary: checkout function version 13 and webhook version 16 are deployed, but a real browser signup through Stripe Checkout and webhook provisioning has not yet been completed. Do not describe signup as end-to-end verified. No live payment should be initiated without a controlled test plan.

The deployed LIVE webhook source has connected-account handling that is absent from both the production and hardening-branch GitHub copies. Do not redeploy either repository copy over LIVE. Reconcile the deployed source into version control and review its connected-account payment/refund paths before any webhook edit or redeployment.


## Email-confirmation checkout resume correction — 1 November 2026

- Production `subscriber-signup.js` now includes the selected `billing_interval` in Supabase Auth user metadata as well as the existing pending-signup browser record (commit `cc6b9e898a8f35f7ae5e6c24b2e9b2e5825136ce`).
- Production `subscriber-login.html` now resumes checkout with the saved monthly/annual choice when the pending signup email matches the authenticated account; it falls back to the Auth metadata interval and then monthly only when no saved selection exists (commit `92068c1ed9c9477141d6d1857273b7bdd9c74d63`).
- The pending signup record is cleared when the account already has an active membership and the user is sent to the subscriber dashboard.
- Static source inspection confirms the selected interval is passed into `subscriber-create-checkout-session`. Browser verification remains outstanding; do not claim the email-confirmation route has passed end-to-end testing.


## Deployed LIVE webhook v16 source-drift finding — 1 November 2026

- Preserved the exact deployed LIVE `stripe-payment-webhook` version 16 entrypoint in `PROJECT-MEMORY/SNAPSHOTS/2026-11-01-live-stripe-payment-webhook-v16.ts` (commit `e40442c84d682f60ef0c80e98e87226a58c1ad0d`). This is an evidence snapshot only; it is not a deployable replacement.
- The deployed v16 source contains `account.updated` handling and connected-account validation/refund logic. The GitHub `production` and `security/prelaunch-hardening-20261101` function files are the same older blob and omit those deployed branches. Do not redeploy either older copy over LIVE.
- The deployed source references `admin.from(...)` in the legacy domain-order payment path but has no `admin` declaration/import in the entrypoint. This is a likely runtime ReferenceError if that retired domain-order branch is invoked. Do not invoke the retired flow; investigate and repair it separately after the deployed source is reconciled. The subscriber signup branch does not use this identifier.
- Production frontend commits for billing interval persistence are in GitHub, but no GitHub CI/check runs are attached to the commit and the deployed Cloudflare Worker/static response could not be independently verified in this session. Treat the frontend change as committed, not yet deployment-verified.

## Subscriber TEST routing repair — 1 November 2026

Updated subscriber login/signup references from retired TEST Supabase project `twfbmjwwqzxdxvclxbun` to current TEST project `nnsshnfkjcflucjrftzi`, including the current publishable key. Added explicit TEST Worker hostname detection to signup. Changes are committed to production GitHub source but have not been verified on the deployed Cloudflare Worker.

## 2 November 2026 — Selling listing editor repair

The Selling editor now saves title, description, asking price, currency and listing metadata through `public.subscriber_update_listing_details`, a tenant-scoped SECURITY DEFINER RPC. It requires authentication, `selling.manage`, and `module.selling`; it refuses sold/delisted records and never changes workflow status or ownership. Public/anon execution is revoked; authenticated execution is granted. Direct authenticated UPDATE on `public.listings` remains denied.

The editor normalises Manufacturer/Model/Package so identical Model and Package values are not repeated in the listing title. New public listing descriptions start blank instead of copying internal structured customer-submission fields. Script cache version: `selling-dashboard-fixed.js?v=92`.

The migration was applied independently to TEST (`nnsshnfkjcflucjrftzi`) and LIVE (`gxsrajtqzdjvmceqcpgv`). Function existence and execute privileges were verified in both. No business data was copied between environments; existing LIVE GoPro listing data was not changed. Browser save/reload and Cloudflare deployment verification remain outstanding.

## 7 November 2026 — Current environment and AI operations correction

This section supersedes older environment references above where they conflict.

- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- TEST Supabase project: `nnsshnfkjcflucjrftzi`.
- Retired TEST project `twfbmjwwqzxdxvclxbun` is forbidden for current operations; any earlier mention is historical only.
- LIVE Gemma control plane is versioned: `platform_ai_agent_tasks`, `platform_catalogue_research_queue`, owner task enqueue/list/review RPCs, and service-role-only worker claim/heartbeat/complete/fail RPCs. LIVE is the authoritative research queue; TEST is software development/regression only.
- Research PC worker is `tools/tradeflow-gemma-agent/src/task-worker.mjs`; it expects `TRADEFLOW_LIVE_URL` and `TRADEFLOW_LIVE_SERVICE_ROLE_KEY`, and checks the TEST URL/key as explicit environment-boundary inputs. Keep the protected `.env` separate and preserve it when updating code.
- Approved websites are stored in LIVE `platform_research_sources` with category scoping. Amazon UK and eBay UK are universal only where explicitly marked; no category mapping means fail closed.
- Candidate results are staged in LIVE `platform_catalogue_research_queue`. Owner/ChatGPT verification remains mandatory before catalogue/evidence import.
- AI Agent Common Room has a versioned migration in branch `feature/ai-agent-common-room-20261107`; it is not yet applied or deployed. It will use `platform_ai_agent_messages`, owner-authenticated RPCs and service-role-only agent RPCs.
- Public How It Works is source-managed in `how-it-works.html` and `how-it-works.css`; do not edit legacy `platform_public_pages` JSON and assume it updates the public page.

### Research PC deployment/acceptance
1. Confirm the PC's current worker process and original `TRADEFLOW_GEMMA_ENV_FILE` path.
2. Preserve the dedicated `.env`, TEST/LIVE URLs and service-role credentials. Do not copy them into GitHub or browser HTML.
3. Update only worker source/code from the accepted production release, preserving local configuration.
4. Restart the worker and confirm a current LIVE heartbeat.
5. Once the Common Room migration is applied, check worker startup, owner instruction read, research handover post and owner dashboard visibility.
6. Run one deliberately limited research task and inspect the first failing hop before any larger batch.

## Current LIVE AI operations — 7 November 2026

- LIVE Gemma task queue and candidate-review queue are installed; worker queue RPCs are service-role-only, owner task/review RPCs require active platform membership.
- Approved research sources are category-scoped in LIVE `platform_research_sources`. No category match must fail closed.
- Candidate market evidence is staged to LIVE and still requires owner/ChatGPT validation. Used-market observations are reference only.
- AI Agent Common Room migration is applied to LIVE; table is RLS-protected with no direct anon/authenticated access. Owner RPC is authenticated with active owner check; agent RPCs are service-role-only.
- Dashboard and worker Common Room code are in feature branch `feature/ai-agent-common-room-20261107`; not yet released. Research PC update/restart and owner-instruction → worker-read → handover → owner-view round-trip remain outstanding.
- Preserve the PC's existing .env file and `TRADEFLOW_GEMMA_ENV_FILE` setting. Do not copy service-role keys into code/browser.

 
## Gemma Research PC update — 7 November 2026
The production worker source is under tools/tradeflow-gemma-agent/src. Use tools/tradeflow-gemma-agent/Update-TradeFlow-Gemma.ps1 to update/install the local worker. Supply the existing private environment file path explicitly; the updater validates approved TEST/LIVE URLs, tests Node source, backs up source files and changes only the dedicated src directory. It must not replace, print, copy or move the private .env, Ollama configuration or other local secrets. For a new install, use a dedicated TradeFlow folder, not the retired GearCashOut source directory. Set TRADEFLOW_GEMMA_ENV_FILE to the exact existing private .env path before starting src/task-worker.mjs.

 
## Queue task validation refinement — 7 November 2026
The task normaliser now rejects incomplete payload rows before calling runTask. It requires category_slug, manufacturer, model, package_key, package_name, search_query and a research_type of uk_new, uk_used or uk_both. The Owner Dashboard's production task builder supplies these fields. Tests cover incomplete payload rejection as well as valid rows, malformed rows, duplicate removal and preservation of distinct task definitions. Four tests pass.

 
### Existing Research PC installation paths
The current TradeFlow Gemma installation folder is `C:\CTFGemma2\TradeFlow-feature-tradeflow-gemma-agent-foundation-20261105\tools\tradeflow-gemma-agent`. Its existing private TradeFlow environment file is `.env` inside that folder. The updater should be run in-place against that folder and exact .env path. The separate `C:\GearCashOut-Config\.env` and GearCashOut source folders are unrelated and must remain untouched. The existing local launcher/supervisor setup must be preserved; the new updater only replaces reviewed files under `src` and creates a source backup.


## Gemma Research Again repair — 7 November 2026
The defect is in `platform-owner-dashboard.js` → `reviewGemmaCandidate()`, not in the Research PC polling loop. The prior handler only called `platform_owner_review_catalogue_research_item()`. The corrected handler obtains the selected candidate from the loaded LIVE queue, builds a single exact-product task (`uk_both`), calls `platform_owner_enqueue_ai_agent_task()`, and only after successful enqueue records `needs_research`. It refreshes the task and candidate lists. The worker's existing 15-second polling/claim flow is unchanged. Merged PR #268 to production (`a76cf1e3d0ea5e9c068f05a9242cab98d5839f3e`); Cloudflare deployment and browser acceptance pending.


## First-agent rollout: 3D Printers & Equipment website playbooks and Common Room inbox — 7 November 2026
- A first category-specific website playbook has been added at `tools/tradeflow-gemma-agent/src/source-playbooks.mjs`, exclusively for `3d-printers-equipment`. It defines manufacturer, new-retailer, used/refurbished dealer and marketplace routes/navigation for Creality, Bambu Lab, Anycubic, Uni3Dverse, 3DGBIRE, 3D Prima, 123-3D, iDig3DPrinting, 3DFLO, 3DJake, Gumtree, SecondHand.org.uk, eBay UK and Amazon UK.
- Rule: search/category/collection pages are discovery only. Gemma must extract exact-model links, open individual product/listing pages, and validate model/package, UK GBP price, condition and availability before returning evidence. Accessories, consumables, upgrades, mismatched variants, sold/completed listings and unverified social snippets are not evidence.
- `probeApprovedResearchSources()` now uses website-specific routes, ignores a stale configured direct `/products/...` URL as a search route, and no longer caps the balanced category source sweep at 12. The 3D-printer source count can exceed 12; all category-approved sources are now included in the balanced new/used/official rotation. Up to five site-specific routes are attempted per source. Source attempts and route failures are reported through progress telemetry.
- The first Common Room inbox/reply behaviour is scoped only to `3d-printers-equipment`. The Research PC worker checks the LIVE Common Room at startup, before this agent's tasks, and while idle between queue polls. It replies to the owner's first-visit welcome message, acknowledges unanswered owner instructions, and drafts concise answers to unanswered questions with local Ollama. Replies are linked by `parent_message_id`, and existing replies are checked to avoid duplication. The existing worker still passes relevant owner/agent instructions into the extraction context; hard-coded evidence rules and owner approval gates remain authoritative.
- This does not yet enable automatic Common Room replies for other categories. Roll out one agent at a time after acceptance testing the 3D-printer agent.
- Updater now downloads/tests `source-playbooks.mjs` and `source-playbooks.test.mjs` alongside the existing worker files. No private `.env`, legacy GearCashOut config, Supabase schema, TEST tenant data, LIVE catalogue/evidence approval, Stripe or Cloudflare configuration was changed by this code branch.
- Deployment remains pending: merge the reviewed branch, run the updater on the Research PC using the existing TradeFlow install and exact existing TradeFlow `.env` path, stop the old worker cleanly, restart, then verify the 3D Printer Gemma greeting is posted as a threaded reply to the owner's Welcome message. Do not claim the behaviour is live until that round-trip is visible in AI Common Room.
- Known follow-up after acceptance: verify each website route against live pages, record per-site success/failure, improve pagination/load-more handling where needed, then enable the next category agent. Social-platform discovery remains a separate capability and must not be represented as implemented by this first rollout.


## 3D printer playbook route verification correction — 7 November 2026
- Live web inspection confirmed Gumtree UK uses the `gumtree.com/uk/srpsearch%2B...` route and its individual advert pages use `/p/...`; its `.com` host therefore needs an explicit UK-source allowlist entry, while evidence still must show GBP and a direct active UK advert.
- Confirmed the official Anycubic UK store has moved to `uk.anycubic3d.com`; the old `uk.anycubic.com` site stated its transition ended 15 October 2026. LIVE `platform_research_sources` now points to the current domain and product-search route, and the worker allowlist/playbook/tests match it.
- Confirmed Bambu Lab UK uses `bambu-lab-uk.myshopify.com`, 3DFLO is a UK retailer, Uni3Dverse has a dedicated used/refurbished catalogue, SecondHand has a dedicated second-hand 3D-printer category, and 3DGBIRE has an active reconditioned-printer collection. These routes are encoded in the first category playbook. Their actual Research PC extraction success remains pending acceptance testing.
- LIVE Creality `search_url_template` was corrected from the fixed K1 detail page to the UK search route `https://store.creality.com/uk/search?q={query}`. This prevents repeatedly treating the same K1 page as the category's search route.


## Gemma research failure analysis and navigation correction — 7 November 2026

### Observed LIVE run
- Investigated LIVE `platform_ai_agent_activity` for task `owner-research-again-b94e2225-c07b-4001-8dfa-cd045bf962fd-1794075404013` (queue task UUID `9f6f79db-4085-4638-8415-e2b654c03893`). It completed in about 84 seconds with 15 search candidates (10 DuckDuckGo, 5 approved-source), 4 initially eligible URLs, 1 price-bearing page fetched, 1 Gemma extraction call, 0 accepted evidence and 0 queue writes. No worker/task exception occurred.
- Source-level activity showed: 123-3D direct refurbished K1 result returned HTTP 404; eBay item fetch returned HTTP 403; iDig3DPrinting and 3DFLO search routes returned HTTP 404/empty results; Gumtree returned no exact-model links; Uni3Dverse collection fallback returned HTTP 500; Creality collection pages had no server-rendered matching links and the generic Shopify `products.json` fallback returned HTTP 404; 3DGBIRE and 123-3D Shopify collection JSON returned zero matching K1 products.
- Amazon's result was an AAX tracking URL leading to a Creality extruder/filament accessory. The search query text `keywords=Creality+K1` was included in `matchesTaskModel()` identity, allowing the unrelated accessory through the prefilter. The final evidence validator correctly rejected it because the page did not identify the K1 printer or provide qualifying visible GBP price/direct listing evidence.
- The single fetched price-bearing page therefore did not contain acceptable K1 evidence. The earlier known official Creality K1 product URL was not being passed back into Research Again as a seed URL, so the worker could miss a known exact-model product page while relying on current search indexing.

### Minimal code corrections on branch `fix/gemma-research-page-navigation-20261107`
- `matchesTaskModel()` now checks result title plus canonical hostname/path only; it ignores query strings so search terms and tracking parameters cannot turn accessories into exact-model matches.
- Amazon AAX sponsored/tracking links are unwrapped to the canonical `www.amazon.co.uk/.../dp/<ASIN>` page before eligibility/model checks.
- Collection expansion now uses Shopify's `/products.json` endpoint only when that website's playbook explicitly declares `collectionApi: 'shopify'`. Creality and Uni3Dverse are no longer sent to an incompatible Shopify endpoint; 123-3D and 3DGBIRE retain the declared Shopify fallback.
- Owner Dashboard Research Again now passes the existing candidate's `source_url` in `seed_urls`. The worker rechecks this URL only if it still belongs to a category-approved UK source and passes direct-product and exact-model checks; it is not trusted evidence and must be fetched and validated again.
- Owner Dashboard cache reference bumped from `platform-owner-dashboard.js?v=27` to `?v=28` so the seed-URL change is loaded.
- Added tests for query-string false positives, Amazon AAX canonicalisation, and per-site Shopify collection capability. The Research PC updater already runs both task-group and website-playbook test suites before install. These new tests have not yet run on the Research PC; deployment and a fresh product test remain pending.

### Safety and next verification
- No catalogue candidate was approved/imported, no LIVE/TEST catalogue data was changed, no Supabase schema or RLS was changed, and no `.env`, legacy GearCashOut configuration, Stripe or Cloudflare setting was touched.
- Next step: run the reviewed Research PC updater against the existing TradeFlow install and `.env`; require syntax checks and all tests to pass. Then confirm Owner Dashboard serves `v=28`, rerun the same Creality candidate once, and inspect activity for a `seed_url_added` event, canonical Amazon product links, no accessory false-positive, no Shopify API request to Creality/Uni3Dverse, and any qualifying new/used evidence returned to owner review.
- Do not treat registered source count or general search-result count as source coverage. Track each approved source's route attempts, HTTP outcome, links discovered, direct pages fetched, price-bearing pages and accepted candidates separately. Add further website-specific navigation only from observed failures and verified routes.


## Deep category and website research — 7 November 2026 (PR #273; awaiting validation/merge)

- Scope is the first 3D Printers & Equipment agent only. Do not roll these rules to other category agents until the first agent has passed Research PC acceptance.
- The Owner Dashboard batch builder already resolves a selected master category/branch into individual master-catalogue product/package tasks. Each queued task is one exact product leaf, retaining its branch_slug; the worker must not treat a branch or category page as finished research. LIVE category structure was checked: 201 active products total, comprising 183 in branch 3d-printers and 18 in branch 3d-printer-equipment-accessories. The playbook now has separate machine-versus-accessory instructions so printer-only exclusions cannot incorrectly reject the accessories branch.
- probeApprovedResearchSources() now checks every configured website route in parallel per source and accumulates unique matches instead of returning after the first route succeeds. Search result pages can follow bounded same-host pagination (up to two further pages); collection discovery can inspect up to 12 hubs and follow up to three same-host pagination pages per hub. Individual direct product pages are inspected up to 30 per product task, with an explicit telemetry event when the bound is reached.
- Each page must still be an individual exact-model/product listing. Category/branch/collection/search pages remain discovery only. Manufacturer/category source allow-lists, UK/GBP checks, model/package matching and the ChatGPT/owner approval boundary remain authoritative. Do not bypass logins, robots, access controls or invent site endpoints.
- Exact-model direct pages without visible GBP price are no longer silently discarded before Gemma. They are passed to Gemma for a separate borderline assessment. Validation failures on an otherwise eligible exact-model product page are also retained as borderline. These are inserted into LIVE platform_catalogue_research_queue as record_type='evidence_candidate', status='needs_research', with null evidence type/price/currency/condition/availability, captured excerpt, original URL and explicit reason in research_notes/raw_payload.review_classification='borderline'. They are for ChatGPT inspection only, not verified evidence.
- Verified candidates remain pending_review. The Owner Dashboard displays borderline notes and hides the approval action for raw_payload.review_classification='borderline'; only Research Again or Reject is available. No automatic catalogue/evidence approval or import is introduced.
- Telemetry/metrics distinguish search results, eligible URLs, discovered product pages, inspected product pages, price-bearing pages, verified candidates and borderline candidates. Website route errors and pagination failures remain visible.
- Owner Dashboard cache reference bumped from platform-owner-dashboard.js?v=28 to ?v=29.
- Tests added for same-host search/collection pagination, category-to-product traversal, borderline instructions and separate printer/accessory branch rules. Existing Research PC updater already downloads the updated agent.mjs, playbook and playbook tests and runs syntax checks plus both test suites before installation.
- PR #273 is open against production. GitHub Actions workflow-run lookup returned no run at checkpoint time; do not claim tests have passed until a green run or equivalent Research PC updater output is observed.
- No Supabase schema/migration or LIVE/TEST catalogue data changed. The existing 201-product catalogue and all evidence approvals remain untouched. No Research PC .env, Ollama settings, legacy GearCashOut configuration, Stripe or Cloudflare setting was changed.
- After merge, update the existing Research PC using the reviewed updater, preserving the exact private .env path. Then verify Owner Dashboard v29, run one controlled Creality K1 task, and inspect activity for all-route completion, pagination, individual-page counts, verified candidates and borderline candidates. Do not start the wider branch/category batch until this acceptance is complete.


## Merge and CI verification — 7 November 2026

PR #273, “Deepen Gemma category research and capture borderline findings”, was merged into production as commit 7e8e2d4ba6e634fa788ec78b345ac6047e54aee7. GitHub Actions Gemma Research Tests run 42403829606 completed successfully: all Gemma source syntax checks passed, the task-group and website-playbook test suites passed (19 tests, 0 failures), and Owner Dashboard JavaScript syntax passed. The first test run exposed a collection-pagination fixture that dropped the Creality UK locale path; the fixture was corrected to retain /uk/, and the subsequent complete CI run passed.

Production now contains all-route probing, bounded search/collection pagination, branch-specific printer/accessory rules, direct-page borderline assessment, validation-failure borderline handoff, approval suppression for borderline queue rows, expanded research coverage metrics, and Owner Dashboard cache reference v29. This confirms GitHub source and CI only; it does not yet confirm Cloudflare's production deployment or Research PC installation. The Research PC must be updated with the production updater, then the owner dashboard must be checked for v29, and exactly one controlled Creality K1 task run before any wider batch is dispatched.


## Gemma desktop supervisor and Control Centre diagnostics

Diagnostic path: desktop shortcut Gemma - specialist.lnk → wscript.exe → Launch-TradeFlow-Control-Centre.vbs → hidden PowerShell WinForms script TradeFlow-Research-Control-Centre.ps1 → local agents.json, config.json, and status.json → scheduled task TradeFlow Gemma Research Supervisor → Run-TradeFlow-Gemma-Supervisor.ps1 → existing Gemma Node queue worker → LIVE service-role scoped claim RPC platform_ai_agent_claim_task_for_agents(text,text[],integer) → LIVE platform_ai_agent_tasks and status/activity records.

Desktop UI defects must be isolated from worker defects. First inspect the seven canonical local agent definitions, enabled keys, local activeAgentKeys, shortcut targets/arguments and scheduled-task action. Do not change LIVE queue/source/evidence tables to repair the UI. LIVE platform_ai_agent_status may contain historic alias rows such as 3d-printers and gaming-consoles; use the canonical desktop keys for the seven UI switches and do not display aliases as additional agents. One worker is intentional; enabled specialists are eligible to claim their matching tasks but are not separate concurrent workers.

The seven-agent UI uses a vertical scrollable list with specialist name, state and individual checkbox, plus enabled/active counts. If only a subset appears, inspect the installed local UI script version and layout before changing configuration. A UI-only update should replace only %LOCALAPPDATA%\TradeFlow\ResearchControlCentre\TradeFlow-Research-Control-Centre.ps1; do not rerun the full installer for a display-only change because it also invokes the Gemma worker updater. Closing the visible Control Centre does not stop the scheduled background supervisor. Preserve the existing private .env and service.json paths.

Windows Terminal can capture a hidden PowerShell session on some Windows 11 configurations even when the VBS launcher uses WScript.Run window style 0. On the affected Research PC, selecting System > Advanced > Terminal > Windows Console Host stopped the extra console. This is a local OS preference and should not be treated as a backend or worker change.


### Specialist card clipping / no vertical scroll — 9 November 2026

First failure point is the WinForms card container in TradeFlow-Research-Control-Centre.ps1, not Supabase, the queue worker or the agent definitions. The initial FlowLayoutPanel TopDown/WrapContents=false layout clipped the first two cards in the owner's narrow side-by-side window. Production commit 55bba312db21fe1e0a667a4c38cd82d63cad2add replaces it with a standard Panel using AutoScroll, explicit Y positions, AutoScrollMinSize and responsive card widths. For deployment replace only the local UI script; do not rerun the installer or touch the worker. Verify the list from first to seventh card by vertical scrolling.


### Dedicated scrollbar fallback

The owner reported that the standard Panel AutoScroll correction did not change the display. Production UI moved to an explicit VScrollBar control and manually positioned card canvas. This is the deterministic fallback for WinForms scroll issues. Ensure LargeChange is set before Maximum, calculate Maximum as content overflow plus LargeChange minus one, clamp Value to Maximum - LargeChange + 1, and guard ValueChanged during programmatic updates. Confirm all seven keys remain rendered; no backend changes are required.
