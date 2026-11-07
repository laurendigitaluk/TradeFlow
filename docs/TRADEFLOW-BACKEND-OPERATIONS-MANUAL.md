# CURRENT OPERATIONS UPDATE — 7 NOVEMBER 2026

- Approved TEST Supabase: nnsshnfkjcflucjrftzi.
- Approved LIVE Supabase: gxsrajtqzdjvmceqcpgv.
- Retired project twfbmjwwqzxdxvclxbun is forbidden; older references below are historical only.
- The LIVE Common Room migration and four additive routing/security migrations are installed. Owner RPCs are authenticated with active-membership checks; agent RPCs are service_role-only; all four use an empty search_path. Dashboard and Gemma worker changes remain in PR #267; no Cloudflare deployment or Research PC restart has been verified.
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
