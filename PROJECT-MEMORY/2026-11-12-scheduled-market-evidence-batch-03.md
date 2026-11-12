# Project Memory — Scheduled Market Evidence Batch 03

**Date:** 12 November 2026  
**Environment:** TradeFlow LIVE only  
**Source checkpoint:** [CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md](../CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md)  
**Status:** Research preserved; not staged to LIVE review queue.

## Scope and preservation
- 20 active LIVE catalogue master products researched.
- Product UUIDs, source links, source observations, original currencies, condition/availability notes and RED VERIFY warnings are preserved in the checkpoint.
- Research checkpoint contains 45 source URL occurrences (before deduplication).
- All uncertain, international, unavailable, comparison-only and no-price findings must be retained as research references; do not discard them.

## Selection / duplicate controls
- Excluded prior scheduled checkpoint product IDs, manual AI prompt product IDs, outstanding queue candidates and the 20 AKASO IDs already reported in the preceding work.
- Immediately before research, all selected products had zero active evidence, zero outstanding queue candidates and zero outstanding prompts.
- Selection was dynamic; no fixed SQL OFFSET.

## Import blocker
- At research time auth.uid() and auth.role() were NULL and platform_cloud_ai_owner_check() returned false.
- No queue candidate or shared_market_evidence row was written from this batch.
- No direct table insert, impersonated JWT, service-role bypass or RLS bypass was attempted.
- Existing manual prompt submission RPC is not suitable: it requires a pre-existing prompt and strict prompt-bound findings.

## Data handling rules
- Preserve source URL, source name, source excerpt, model/package match, observed currency/amount, condition, availability and RED VERIFY notes.
- Do not convert foreign currencies into GBP.
- Do not treat generic search/category pages, sold-out pages, historical listings, or uncertain package matches as verified live offers.
- Only verified UK GBP evidence with a defensible exact model/package match may become valuation-eligible.
- Used-market observations remain reference-only and must not affect automatic valuation.

## Reconciliation
- This batch is one of the 11 scheduled batches (03–13) dated 12 November 2026: 220 researched products total.
- Do not re-research these 20 products unless the source needs re-verification.
- Do not start new scheduled research until the stored backlog has been imported/reconciled.
- Keep TEST, LIVE tenant/customer data, Stripe and valuation logic isolated and unchanged.

## Next action
Implement and use a secure authenticated import path that accepts checkpoint source records, preserves all findings (including RED VERIFY and non-GBP/no-price leads), performs idempotent duplicate detection, and stages candidates for human review. Do not bypass RLS or write as postgres without authenticated owner context.


## 12 November 2026 — Four Batch 03 exact-source imports

LIVE read-back confirmed four new rows: Sony Alpha A7C Body Only £799 new (E-Infinity UK; import tax included); Parrot ANAFI Work £1,040 ex VAT new (Sunbelt Sales exact SKU PF728100AA; complete Work package contents); AKASO Brave 4 With SD Bundle £147.22 new (Desertcart, duties/taxes included, 64GB U3 card plus two batteries/accessory kit); Sony Alpha SLT-A68 Body Only £279 used (MPB SKU 4297151; Good, 5,410 shutter, slight smoke odour and accessory exclusions preserved). Exact source URLs, package notes and evidence IDs are in CHECKPOINTS/2026-11-12-scheduled-market-evidence-batch-03.md.

Batch 03 now four active rows (3 UK New, 1 UK Used). Cumulative Batches 03–13: 246 total, 243 active (133 UK New, 110 UK Used), three inactive. Remaining model/package/currency RED VERIFY leads are retained and not forced into wrong masters. No master/schema/valuation change; TEST and Stripe untouched.


## 12 November 2026 — AKASO V50 X With SD current listing

Imported a current direct eBay UK offer against exact LIVE AKASO V50 X / With SD Bundle master d763014a-70e2-4a0e-a7ce-bf8e0afdb0e1: Clarkson Direct £153.99, new, 2 available / 1 sold, title/item specifics confirm V50 X-U3 and 64GB microSD; seller description confirms V50 X and two 1350mAh batteries. UK business seller, Beverley, 95.5% positive, 11K sold; no returns, eBay Money Back Guarantee. Source https://www.ebay.co.uk/itm/326424455596. LIVE row 8c8b32c5-e38d-4c5c-83f9-a0af9ee3aa3d read back. Batch 03 now 5 active (4 new, 1 used). Batches 01–13: 255 total, 252 active (137 UK New, 115 UK Used), three inactive. YPC £109.99 remains a dated 22 Oct snapshot, not a current offer. No master/schema/valuation change; TEST and Stripe untouched.


## 12 November 2026 — Caddx Walnut UK price references

Added two direct UK specialist-retailer references against existing Caddx Walnut master a628320d-771b-43f9-8503-206e06221d49: FlyingTech £117.90 inc VAT (SKU FPV-WALNUTND816, sold out) and Unmanned Tech £129 incl. taxes (CDX-WLNT-AC, sold out/backorder). Exact package contents, URLs and evidence IDs in Batch 03 checkpoint. Both remain active evidence rows with availability explicitly out_of_stock/backorder; not currently purchasable offers. Batch 03 now 7 active (6 new, 1 used). Batches 01–13: 257 total, 254 active (139 UK New, 115 UK Used), three inactive. No master/schema/valuation changes; TEST and Stripe untouched.


## 12 November 2026 — additional AKASO V50 X With SD row

A parallel research pass added and read back an exact AKASO V50 X-U3 / With 64GB microSDXC UK New offer: eBay UK Clarkson Direct £153.99, new, three available, one sold; seller UK business in Beverley, 95.5% positive, 12K sold. Item specifics confirm MPN/model V50 X-U3 and 64GB microSD card package; seller description confirms two 1350mAh batteries. No returns; eBay Money Back Guarantee. Evidence row 8c8b32c5-e38d-4c5c-83f9-a0af9ee3aa3d; exact master V50 X / With SD Bundle. Source https://www.ebay.co.uk/itm/326424455596. Batch 03 now 5 active (4 UK New, 1 UK Used), superseding prior count of 4.


## 12 November 2026 — Caddx Walnut UK price references

Added two direct UK specialist-retailer references against existing Caddx Walnut master a628320d-771b-43f9-8503-206e06221d49: FlyingTech £117.90 inc VAT (SKU FPV-WALNUTND816, sold out) and Unmanned Tech £129 incl. taxes (CDX-WLNT-AC, sold out/backorder). Exact package contents, URLs and evidence IDs in Batch 03 checkpoint. Both remain active evidence rows with availability explicitly out_of_stock/backorder; not currently purchasable offers. Batch 03 now 7 active (6 new, 1 used). Batches 01–13: 257 total, 254 active (139 UK New, 115 UK Used), three inactive. No master/schema/valuation changes; TEST and Stripe untouched.


## 12 November 2026 — Caddx Peanut UK price reference

Added YourFPV direct UK listing for exact Caddx Peanut / Insta360 Go 2, SKU YFPV - CaddX - PNT, £218.99. Explicitly Out of stock / Join Waitlist, so retain as active price-reference evidence with availability out_of_stock, not a current offer. Full package list and URL in Batch 03 checkpoint. LIVE row 3cf32e49-d7b0-4d30-9851-9da8155e1577 read back against existing master dbf3777c-4f84-4cd1-86db-03d8ed66482f. Batch 03 now 8 active (7 new, 1 used). Batches 01–13: 258 total, 255 active (140 UK New, 115 UK Used), three inactive. No master/schema/valuation changes; TEST and Stripe untouched.
