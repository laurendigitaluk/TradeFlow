# TradeFlow Test checkpoint — multi-item customer valuation — 28 October 2026

## Environment boundaries
- Canonical intended Test branch: `cloudflare-test`.
- Test Worker: `https://tradeflow-test.leannelaurenlowe.workers.dev`.
- Test Supabase project: `nnsshnfkjcflucjrftzi`.
- LIVE Supabase project: `gxsrajtqzdjvmceqcpgv`.
- LIVE Worker: `https://tradeflow.leannelaurenlowe.workers.dev`.
- Do not use LIVE for test submissions or copy Test customers/tenant/domain/ownership data into LIVE. Do not alter LIVE Stripe configuration.

## Current implementation on cloudflare-test
- Multi-item customer valuation flow is committed to this branch; the earlier statement that it was still waiting to be merged is stale.
- Public selling UI and basket styles use `public-site.css?v=68` and `public-site.js?v=87`.
- Customer auth uses the Test runtime config on the current Test hostname; dashboard auth asset is versioned at v21.
- Item-indexed multipart photo fields are supported (`files_0`, `files_1`, etc.), with legacy single-item `files` retained.
- Test Worker config has been aligned with the production asset-routing shape while retaining `name: tradeflow-test`, `TRADEFLOW_ENV: test`, and the current Test Supabase project.
- The Worker must retain its environment-specific URL/key rewrite logic. Do not copy production Worker config or credentials into the Test environment.

## Verification state
- Prior static JavaScript parse checks passed for the multi-item public site and customer auth scripts.
- The Test customers page was observed requesting the LIVE Supabase hostname and failing. The browser loaded `customers.js?v=3` while the corrected asset uses `v=4`; this is evidence the Test Worker was serving stale assets at that time.
- The current branch commits do not prove the Worker has deployed them. Deployment source and deployed commit are not yet verified because no Cloudflare deployment control/status is available in this workflow.
- No browser end-to-end acceptance is complete. Do not describe the feature as accepted or ready for LIVE.

## Acceptance checklist — TEST only
1. Confirm Test Worker serves the expected current assets and all Test customer requests target `nnsshnfkjcflucjrftzi.supabase.co`, never LIVE.
2. Submit one item, two items, three or more items, and mixed categories.
3. Verify each item retains its own model/category/condition, valuation, offer, photos, and `buying_item_id`/product linkage.
4. Exercise add/edit/remove, refresh/reload, customer authentication return, invalid files and upload failures.
5. Confirm one request contains separate item workflows in the customer portal and subscriber Buying dashboard.
6. Confirm acceptance, acquisition, inspection, inventory and sales transitions work without premature movement or cross-item/photo mix-ups.
7. Record results and fix failures on `cloudflare-test` before promotion.

## Promotion rule
Promote only the accepted code to the verified LIVE deployment source after Test deployment and browser/database acceptance pass. Branch names and commits alone do not establish what Cloudflare currently deploys. Keep LIVE untouched until its actual deployment source is confirmed and the Test build is accepted.
