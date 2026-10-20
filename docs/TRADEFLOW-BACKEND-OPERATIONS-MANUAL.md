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


---

# Environment Status Addendum — 21 October 2026

This addendum supersedes any earlier environment references in this document where they conflict. It records the currently verified environment split and the remaining Stripe TEST verification work. It does not claim end-to-end payment success.

## Authoritative Supabase environments

| Purpose | Project | Project ID | URL | Current state |
|---|---|---|---|---|
| LIVE / production | TradeFlow Live | `gxsrajtqzdjvmceqcpgv` | `https://gxsrajtqzdjvmceqcpgv.supabase.co` | Active; production must be protected |
| Current TEST / staging | TradeFlow TEST | `nnsshnfkjcflucjrftzi` | `https://nnsshnfkjcflucjrftzi.supabase.co` | Active; intended for isolated validation |
| Legacy TEST | Previous TradeFlow TEST | `twfbmjwwqzxdxvclxbun` | `https://twfbmjwwqzxdxvclxbun.supabase.co` | Legacy/reference only; not approved for deletion yet |

LIVE and current TEST are in the TradeFlow Pro organization. The current TEST project was created on 20 October 2026. The old TEST project must not be confused with the new TEST project.

## Mandatory safety boundary

- Make development, deployment, Stripe test-key changes, webhook testing, and purchase-flow tests against current TEST only unless a separately approved LIVE change is explicitly required.
- Do not change LIVE secrets, production functions, production configuration, or production data as part of this TEST repair.
- Never paste Stripe secret keys or webhook signing secrets into chat, issues, manuals, commits, or logs. Enter them only in the intended Supabase project's Edge Function Secrets interface.
- Treat Stripe test mode and Stripe live mode as separate systems. A TEST connected account must never be reused as a LIVE connected account, or vice versa.
- The repository's production branch and `wrangler.jsonc` are not to be repointed as part of TEST work. The isolated TEST configuration is `wrangler.test.jsonc`.

## Stripe Connect TEST repair — status

The following functions are deployed and reported ACTIVE in the new TEST project:

- `stripe-connect-onboarding` — JWT verification enabled.
- `create-stripe-checkout-session` — JWT verification enabled.
- `stripe-payment-webhook` — JWT verification disabled; requests must be verified with the Stripe webhook signature.
- `stripe-connect-webhook` — JWT verification disabled; requests must be verified with the Stripe webhook signature.

The code branch for the repair is `test/stripe-connect-test-mode-repair-20261020`. Source-level mode guards were added to reject test/live key, account, and event mismatches. Static source assertions passed, but these checks are not a substitute for runtime tests.

Stripe Sandbox has two active TEST event destinations configured to the new TEST project's function endpoints:

- Platform payments → `/functions/v1/stripe-payment-webhook`
- Connected accounts → `/functions/v1/stripe-connect-webhook`

The platform destination is configured for checkout-session and payment-intent success/failure events. The Connect destination is configured for `account.updated`, `account.application.authorized`, and `account.application.deauthorized`. No successful delivery has yet been demonstrated in the recorded evidence.

## Secrets and verification

The operator reported entering the three Stripe secrets in the new TEST project's Edge Function Secrets. Their values cannot be read back through the available inspection, so their correctness is not independently verified. Confirm that the project has:

- `TRADEFLOW_STRIPE_MODE=test`
- `STRIPE_SECRET_KEY` using a Stripe TEST secret key
- `STRIPE_WEBHOOK_SECRET` copied from the TEST **TradeFlow TEST - Platform Payments** destination
- `STRIPE_CONNECT_WEBHOOK_SECRET` copied from the TEST **TradeFlow TEST - Connect Events** destination

Never copy a signing secret from one destination into the other. If a secret was entered before its corresponding endpoint was created or rotated, re-copy the current secret into TEST Supabase only.

## Known open verification items

1. Send a Stripe Sandbox test event to the platform webhook and inspect the delivery status, HTTP response, and new TEST Edge Function logs.
2. Repeat separately for the Connect webhook.
3. Investigate the platform webhook source's reported `admin` client reference before declaring payment/domain-order handling healthy; verify that the client is declared and initialized on every relevant path.
4. Run Connect onboarding in TEST and verify account mode, onboarding completion, webhook processing, and persisted account status.
5. Run a complete TEST checkout and confirm Stripe event delivery, database state transitions, and dashboard outcomes.
6. Only after those pass, update the test-purchase runbook and resume the planned DJI Osmo Action 6 purchase-flow test.

Until these are complete, do not describe Stripe Connect, checkout, or webhook handling as end-to-end verified.

## Legacy TEST project retirement decision

**Do not delete `twfbmjwwqzxdxvclxbun` yet.** It remains a legacy/reference environment until a read-only retirement audit confirms that no current Worker, application environment variable, CI/CD workflow, Supabase function, webhook, manual, or recovery procedure still depends on it, and that required schema/catalogue/reference data and any useful logs or backups have been preserved. The old project should be paused only after dependency checks and a restore/retention decision; permanent deletion requires a separate explicit owner approval after that checklist passes.

## Update policy

This addendum records verified configuration and outstanding checks as of 21 October 2026. Update the status after runtime evidence is collected. Do not rewrite an unverified state as complete.
