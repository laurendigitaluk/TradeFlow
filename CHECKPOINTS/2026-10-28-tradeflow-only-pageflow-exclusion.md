# TradeFlow-only scope and PageFlow exclusion — 28 October 2026

## Binding product boundary
TradeFlow is the only product in this repository's website and customer-facing runtime. PageFlow (previously BusinessFlow) has been removed completely from the TradeFlow site. Do not restore it, re-integrate it, or route its data into TradeFlow.

The user confirmed on 27 October 2026:
- Remove PageFlow/BusinessFlow entirely from this system and restore the last working TradeFlow-only state.
- Keep TradeFlow LIVE and TEST closely aligned while pre-release, with environment-specific data isolated.
- PageFlow/BusinessFlow may remain in its own GitHub/Supabase history/resources, but it must not appear in the TradeFlow UI, navigation, public website, subscriber dashboard, customer portal, deployment bundle, runtime configuration, or TradeFlow database flows.
- Any future separate product must use its own repository, Worker/deployment and database, linked from TradeFlow only by a plain hyperlink if explicitly requested. Do not share tenants, customer records, domains, ownership, Stripe configuration, or product-specific tables.

## Required checks before accepting any branch or deployment
1. Scan all deployed TradeFlow HTML, JS, CSS, Worker code, configuration, navigation and public-page links for PageFlow/BusinessFlow routes, imports, script references, API endpoints, branding, tenant identifiers and cross-product data reads/writes.
2. Confirm Test and Live Worker deployments serve TradeFlow-only assets. Never infer deployment from a Git commit alone.
3. Inspect TEST and LIVE Supabase schemas, Edge Functions, triggers, views, RPCs, grants and environment variables for cross-product coupling. Report legacy PageFlow/BusinessFlow objects, but do not drop tables, delete records, or remove project resources without a separately scoped migration and backup plan.
4. Keep legacy PageFlow/BusinessFlow code/data that is still present in GitHub/Supabase inert and disconnected from the TradeFlow runtime. Do not copy it into the TradeFlow release branch or deployment package.
5. Confirm the Test Worker uses only TEST Supabase for all customer/subscriber operations; LIVE Worker uses LIVE Supabase. Never test with LIVE customer data or write test records to LIVE.
6. Continue the one-branch workflow: `cloudflare-test` is the intended Test branch. Verify Cloudflare's actual Git integration/deployed commit before assuming it is current. Promote only accepted TradeFlow-only changes to the confirmed LIVE deployment source.

## Current known environment identifiers
- Test Worker: `tradeflow-test.leannelaurenlowe.workers.dev`.
- Live Worker: `tradeflow.leannelaurenlowe.workers.dev`.
- Current Test Supabase project: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- Legacy Test project references may still exist in historical/local code: `twfbmjwwqzxdxvclxbun`. Do not let these fallbacks route current Test or LIVE traffic to the wrong project.

## Deployment status at checkpoint
- Recent commits to `cloudflare-test` align Worker asset-routing configuration and harden the Test customers page's fallback Supabase URL.
- Cloudflare deployment source and deployed commit are not yet verified in this workflow.
- Multi-item customer valuation still requires real-browser end-to-end acceptance in TEST.
- No PageFlow/BusinessFlow data should be migrated into TradeFlow. Legacy product data may remain in its separate resources, but must be disconnected from TradeFlow.


## Database changes completed — 28 October 2026
A versioned migration was committed at `supabase/migrations/20261028170000_tradeflow_only_product_pages.sql` (commit `a78e116a1c20ffacd9a5d9014f062a9f5b0a9b05`) and applied successfully to both current TradeFlow Supabase projects:
- TEST: `nnsshnfkjcflucjrftzi`
- LIVE: `gxsrajtqzdjvmceqcpgv`

The existing `platform_product_pages` rows for `businessflow` and `studioflow` are retained for historical traceability but now have status `hidden` in both environments. The TradeFlow row remains `published`. The platform-owner read RPC now returns only the TradeFlow product page, and the platform-owner update RPC rejects any slug except `tradeflow`. No PageFlow/BusinessFlow records were copied into TradeFlow and no tables or historical rows were deleted.

Post-migration read-only checks confirmed the same three statuses in TEST and LIVE. The RPC source was verified to filter to `slug = 'tradeflow'`.

## Still outstanding
- Full scan of all deployed site assets/routes for stale PageFlow/BusinessFlow links and code references.
- Confirm Cloudflare's Test and LIVE Git integration/deployed commits.
- Verify the public TradeFlow homepage and platform-owner product-page UI in a browser after deployment.
- Continue multi-item valuation acceptance tests in TEST only.


## Static site scan — 28 October 2026
Reviewed the current `cloudflare-test` versions of:
- `index.html`: TradeFlow marketing homepage, TradeFlow-only title/copy/navigation, no PageFlow or BusinessFlow link in the inspected content.
- `public-site.html`: subscriber public-site shell loads `public-site.css?v=68` and `public-site.js?v=87`; no cross-product links in the shell.
- `public-site.js`: subscriber website rendering and customer selling/valuation flow. Its explicit runtime Supabase defaults include LIVE and a legacy Test project; the Worker is expected to rewrite these in served JavaScript according to `TRADEFLOW_ENV`. This is a dependency that must be confirmed in the deployed Test Worker. The file inspection did not show a PageFlow/BusinessFlow integration in the reviewed excerpts.
- `worker/index.js`: environment-specific Supabase URL/key replacement is performed on JavaScript assets, while HTML route aliases are returned directly with no-store headers.

This is a targeted static review, not a complete repository-wide or deployed-asset scan. The GitHub search connector did not return source matches for PageFlow/BusinessFlow terms, so absence from all files is not established.

## Risk to resolve before acceptance
The Worker must be verified serving the current `cloudflare-test` commit, and the browser Network panel must show all Test API calls going to `nnsshnfkjcflucjrftzi.supabase.co`, never `gxsrajtqzdjvmceqcpgv.supabase.co`. Verify the LIVE Worker uses LIVE Supabase. The production site remains unmodified by branch promotion.


## Prior-day removal decision recovered from conversation context
The 27 October decision is explicit: remove PageFlow/BusinessFlow from the TradeFlow site and restore the last working TradeFlow-only state; TradeFlow must be the only product option. Future PageFlow, if revived, must have a separate GitHub repository/account/environment and may be linked only by a plain hyperlink if requested. Keep the BusinessFlow repository/history rather than deleting it. Cloudflare should retain only the `tradeflow` and `tradeflow-test` Workers for this application; do not reintroduce a BusinessFlow Worker or product runtime here. The intended public parent address is `LaurenDigital.co.uk`, while the TradeFlow product remains on its own site; TEST and LIVE should stay near-identical except for environment-specific settings and data.
