# TradeFlow LIVE project memory — 10 November 2026

## Scope
Repair the TradeFlow LIVE Cloud AI Research Manager catalogue picker and correct Groq model availability diagnostics. LIVE project: `gxsrajtqzdjvmceqcpgv`. TEST project `nnsshnfkjcflucjrftzi` was not touched.

## Confirmed root causes and fixes
1. Dashboard multiline parsing was double-escaped in three places. Newline-delimited catalogue search and queue submission were treated as a single item, and selected products were joined with a literal backslash-n. Fixed in `platform-owner-dashboard.js`; cache version advanced to v41.
2. Owner RPC `platform_owner_search_cloud_ai_catalogue` matched manufacturer, model and package separately, not the concatenated manufacturer/model phrase. Added combined-field matching while preserving owner membership check, active-product filter, optional category filter, result limit, SECURITY DEFINER and authenticated-only EXECUTE. Applied directly to LIVE and recorded in migration `20261111000100_fix_cloud_ai_catalogue_combined_product_search.sql`.
3. Groq's configured `llama-3.3-70b-versatile` is decommissioned for Free/Developer tier from 2026-08-16 per official Groq docs. LIVE row retained but marked `error` to exclude it from the research runner until an account-verified no-paid-billing replacement is selected. No key changes and no inference.
4. `tradeflow-cloud-ai-manager` deployed ACTIVE version 3; missing model-list entry now sets provider status `error` instead of incorrectly `ready`. Dashboard wording differentiates reachable API from unavailable configured model.

## Verification
- LIVE search RPC test with category `3d-printers-equipment`: Bambu Lab P1S = 3 packages; Creality K1 Max = 1; Anycubic Kobra 3 = 2.
- LIVE master catalogue: 47,410 total / 28,394 active. 3D Printers & Equipment: 201 active, including Bambu Lab 27, Creality 35, Anycubic 24.
- Groq record: enabled true, status error, daily cap 5, requests used 0, Vault secret present. Key never read.
- Cloud AI jobs empty at last inspection. No catalogue/evidence/tenant/Stripe/TEST data changes.

## Remaining acceptance gates
- Confirm latest GitHub Actions Cloudflare Worker deployment from dashboard HTML cache v41 succeeds.
- Gary should refresh the signed-in owner dashboard and test multi-line catalogue search; then select multiple returned products and verify they populate the product batch textarea as separate lines.
- Do not queue research or enable Groq until an approved active model is confirmed free/no-paid-billing on the account. No paid fallback.
