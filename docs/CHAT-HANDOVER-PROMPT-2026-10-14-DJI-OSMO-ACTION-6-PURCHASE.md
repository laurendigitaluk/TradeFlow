# New Chat Handover — TradeFlow LIVE: Test DJI Osmo Action 6 Purchase

We are continuing the TradeFlow SaaS project in repository `laurendigitaluk/TradeFlow`, production branch `production`.

## Hard rules
- Work in LIVE only. LIVE Supabase project is `gxsrajtqzdjvmceqcpgv` (`https://gxsrajtqzdjvmceqcpgv.supabase.co`). TEST project `twfbmjwwqzxdxvclxbun` is reference-only and must not be modified.
- Do not grant broad UPDATE permission to `public.inventory_assets`. Keep inventory writes behind tenant-scoped, permission-checked RPCs.
- Do not restore the retired Parcel2Go API or legacy TEST shipping connection.
- Do not run a real-money payment. First establish a safe payment test mode or another confirmed no-charge test route.
- Be methodical: inspect current production code, LIVE state and logs; identify the first failing step; make minimal version-controlled changes; merge/deploy; verify; update all manuals. Do not repeatedly ask the user to retry the same failing step.

## Current state
- The public Adventure Outpost shop route `https://scenesource.co.uk/shop` now visibly shows the **DJI Osmo Action 6 Adventure Combo** for **£125.00**.
- The current What We Sell page is the working template: no six empty editable tiles; keep the **Find a product** search, automatic **Category** dropdown with category counts, dynamically populated published product cards, filtering, result count and no-results message. This behaviour is for the dedicated shop page only; other pages retain their own editable content.
- PR #146 documents the What We Sell implementation. Public renderer cache key is `public-site.js?v=29`.
- Website category/channel work: PR #139 baseline and PR #141 follow-up.
- LIVE Selling permission work: PR #142 added the sales-field RPC; PR #143 added status synchronisation RPC and removed the remaining direct inventory status PATCH calls. Migration `subscriber_sync_inventory_asset_status_20261014` was applied to LIVE on 14 October 2026. Selling script source uses `selling-dashboard-fixed.js?v=91`.
- Do not assume the whole purchase workflow is verified. Product visibility is confirmed from the screenshot, but the purchase/checkout journey is the next test.

## First task: test purchasing the DJI Osmo Action 6
1. Inspect current LIVE checkout/payment configuration and determine whether it is safe to test without a real charge. If payment mode cannot be established safely, stop and report what is missing.
2. Open the public product card and inspect product detail. Confirm title, tenant, listing ID, price £125.00 and currency.
3. Follow basket/checkout without making a real charge. Verify customer sign-in/registration, tenant persistence, and no sign-in loop.
4. Verify order creation is idempotent (one click must not create duplicate orders).
5. Check payment status against actual gateway result; do not mark paid before verified payment.
6. Verify customer dashboard, subscriber orders/sales view, and finance/ledger agree on the same order and payment state.
7. Verify inventory and listing status transition according to the existing intended workflow, and the item cannot be bought again once sold.
8. Check any shipping step without making TradeFlow collect postage. Shipping remains manual; customer pays their shipping provider directly.
9. Inspect database records and LIVE logs for each step. Stop at the first failure and fix only that cause.
10. Report exact outcomes, references/statuses, anything not tested, and update all relevant documentation.

## Required documentation
Keep these files aligned after changes:
- `docs/TRADEFLOW-SYSTEM-HANDBOOK.md`
- `docs/TRADEFLOW-AI-OPERATING-MANUAL.md`
- `docs/TRADEFLOW-HUMAN-USER-MANUAL.md`
- `subscriber-website-manual.html`
- `docs/TRADEFLOW-BACKEND-OPERATIONS-MANUAL.md`

Do not claim a real transaction occurred unless a real, verified transaction was explicitly authorised. Do not treat an earlier simulated purchase as proof of a completed live purchase.
