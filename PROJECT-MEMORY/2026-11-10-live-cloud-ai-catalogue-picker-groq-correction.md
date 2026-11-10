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


## LIVE research picker rebuilt around the master catalogue hierarchy — 11 November 2026
- Supersedes the earlier free-text/multi-term search picker. The required interaction is now category dropdown → branch dropdown → individual product/model dropdown, with explicit **Add selected product** and **Add entire branch** actions. Product names are never typed by the user.
- LIVE schema source is `catalogue_master_categories` → `catalogue_master_branches` → `catalogue_master_products`, joined by category_id and branch_id. The 3D Printers & Equipment category has the branches 3D Printers (183 active products) and 3D Printer Equipment & Accessories (18 active products).
- Added owner-protected RPC `platform_owner_get_cloud_ai_catalogue_tree(p_category_id,p_branch_id)`, returning active categories, branches and products in the selected branch. Verified the LIVE RPC returns 38 categories and 183 products for the 3D Printers branch.
- Added owner-protected bulk RPC `platform_owner_enqueue_cloud_ai_catalogue_selection(p_product_ids,p_branch_id,p_task_type)`. It creates research jobs directly from selected master product UUIDs, supports branch-wide selection, and stores master_product_id and branch_slug on each job. It does not alter catalogue products or market evidence. A no-op validation with an unknown UUID returned selected=0 / queued_or_existing=0; no research jobs were created during validation.
- Added nullable `master_product_id` FK and `branch_slug` to `platform_cloud_ai_research_jobs`. Source migration: `supabase/migrations/20261111000200_cloud_ai_catalogue_hierarchical_dropdown_picker.sql`. Also applied a follow-up correction qualifying pgcrypto as `extensions.digest`; this is required in this LIVE database because pgcrypto is installed in the extensions schema.
- Replaced the text-search textarea and manually typed queue textarea in the owner dashboard with three cascading dropdowns, a selected-product staging list, add-single and add-entire-branch actions, and one bulk queue submission. Dashboard JS cache is v42. Production Cloudflare workflow run 42910837625 for HTML commit cf3bea245eb317447dab42c8a8b83dea733621f2 completed successfully.
- Remaining acceptance: sign in to the LIVE owner dashboard, refresh with Ctrl+F5, choose 3D Printers & Equipment → 3D Printers, confirm model dropdown loads 183 active catalogue products, test adding one model, test adding the entire branch (183 products), and verify the queue count. Do not click Queue selected products until the user chooses the intended items. TEST was not touched.
