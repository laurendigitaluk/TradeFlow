# Checkpoint — LIVE Gemma batch controls and How It Works editor correction
Date: 7 November 2026

## Operating boundary
- All catalogue coverage reads and research task submissions are against TradeFlow LIVE.
- TEST remains for software development and regression only. No TEST catalogue, evidence, tenant, customer, order or Stripe data was changed.
- Research candidates remain subject to owner/ChatGPT verification. No automatic approval or evidence insertion was added.

## Implemented in production branch
- Replaced the one-product Gemma task form with category, branch, product coverage, research operation, specialist agent and batch-size controls.
- Product coverage filters: all, missing UK new, missing UK used, missing both, missing either, has UK new, has UK used.
- Research operations: UK new, UK used, both.
- Batch sizes: 10, 20, 50, 100 or all selected; products are selectable individually and by selecting all currently displayed products (up to 500).
- When a smaller batch is submitted, only submitted product IDs are removed from selection; the remaining selected products are retained for subsequent batches.
- Pokémon Trading Cards remains in the master catalogue but is excluded from Gemma batch selection until the owner explicitly links sources/agent.
- Added LIVE owner-only RPCs:
  - platform_owner_list_gemma_research_categories()
  - platform_owner_list_gemma_research_products(text,text,text,integer)
- Removed Platform AI provider settings panel and nav link from owner dashboard. Subscriber-supplied AI remains disabled.
- How It Works remains a text-only accordion page. Its owner editor hides legacy screenshots/visual_layout image-box fields. Examples visual editor no longer overwrites the How It Works editor loader.

## LIVE database verification
- RPCs exist in LIVE and were checked in pg_proc.
- anon execute=false; authenticated execute=true. Both functions perform active platform_memberships checks internally.
- The product query was tested using an authenticated platform-member claim and returned product records.
- LIVE 3D Printers & Equipment point-in-time coverage: 201 active products; 1 missing new evidence; 190 missing used evidence; 0 missing both; 191 missing either.

## Files updated directly on production
- platform-owner-dashboard.html
- platform-owner-dashboard.js
- platform-owner-dashboard.css
- platform-public-pages-editor.js
- platform-public-pages-visual-editor.js
- supabase/migrations/20261107170000_gemma_live_batch_research_selection.sql
- docs/TRADEFLOW-SYSTEM-HANDBOOK.md
- docs/TRADEFLOW-AI-OPERATING-MANUAL.md
- docs/DIAGNOSTIC-ROADMAPS/TRADEFLOW-GEMMA-RESEARCH-PIPELINE.md

## Verification still required
- Refresh authenticated LIVE owner dashboard and verify category/branch lists, evidence filters, selection, batching and task enqueue in browser.
- Confirm Cloudflare production deployment has served the new static assets; GitHub commit presence alone is not deployment verification.
- Update/restart Research PC only after browser queue submission and LIVE queue/worker processing are verified.
- Verify How It Works editor opens as text-only accordions and the published public page remains unchanged.
