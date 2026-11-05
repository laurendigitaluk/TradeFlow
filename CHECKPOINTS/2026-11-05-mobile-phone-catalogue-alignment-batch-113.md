# Mobile Phone Catalogue Alignment and Integrity Reconciliation — Batch 113
Date: 5 November 2026

## Scope
Rechecked the latest batch 112 checkpoint, current LIVE and TEST Supabase catalogue tables, and current mobile evidence. This batch was a data-integrity reconciliation and additional UK used-market research. No new evidence observation was added.

## Preflight finding and correction
- LIVE had 158 active mobile products; TEST had 159. Both had 156 customer-visible active products.
- The active evidence count initially differed by one: LIVE 563, TEST 564. The extra TEST row was active evidence attached to a retired inactive Pixel 11 128GB product variant.
- TEST product e3ed0762-1709-4881-8568-e97272bd79ff was already retired on 23 October 2026 because the 128GB variant is invalid (Google Store UK confirms Pixel 11 starts at 256GB). Its MyMobiles UK new-price row 1a21bf68-2959-4ade-bfbb-7b0fa33218da, source key mobile-new-pixel-11-128gb-mymobiles-20261026, price £594, was deactivated in TEST, retaining the row and audit history. The product master itself was not changed and no row was copied to LIVE.
- Confirmed zero active mobile evidence remains attached to inactive products in either environment.

## Metadata reconciliation
- TEST Galaxy S22 128GB eBay sold row: condition and notes aligned to the more specific LIVE description (Used - good).
- TEST iPhone 15 128GB eBay sold row: condition and notes aligned to LIVE (Used - pristine).
- LIVE Motorola Edge 70 256GB MoneySavingExpert row: source label, sales channel and explanatory notes aligned to fuller TEST wording.
- Galaxy S23 128GB Idealo row: TEST sales channel aligned to Price comparison.
- Galaxy Z Fold7 1TB Samsung UK new-price row: TEST and LIVE condition/channel values normalised to New / null for the matching duplicate observation. The matching LIVE row was also normalised.
- No observed price, source URL, evidence type, active product master, or valuation logic was changed.

## Post-reconciliation verification
| Metric | LIVE | TEST |
|---|---:|---:|
| Active mobile products | 158 | 159 |
| Customer-visible active mobile products | 156 | 156 |
| Active evidence attached to active products | 563 | 563 |
| UK-new evidence | 267 | 267 |
| UK-used evidence | 296 | 296 |
| Active products missing UK-used evidence | 4 | 5 |
| Active products missing all evidence | 0 | 1 |
| Active evidence attached to inactive products | 0 | 0 |

A row-by-row comparison confirmed that all 563 active mobile evidence rows match by model, storage variant, evidence type, source URL, observed price, condition and sales channel. Some explanatory notes and observation timestamps differ slightly between environments and were retained rather than overwritten; those details do not alter the underlying observation. The one-product master count difference is the hidden, unverified TEST-only iPhone 18 256GB; it remains untouched and must not be copied, activated, published, deactivated or deleted without separate verification and approval.

## Remaining common UK-used gaps
1. Motorola Edge 70 Plus — 8GB RAM / 256GB
2. OPPO Find X10 — 12GB RAM / 256GB
3. OPPO Find X10 Pro Max — 12GB RAM / 512GB
4. OPPO Reno16 F 5G — 8GB RAM / 256GB

## Research outcome
No qualifying exact-variant UK used/refurbished item-level listing was verified in this batch:
- Reno16 F: eBay UK £379.99 Certified - Refurbished search result lacks direct item URL, dispatch location and refurbishment grade. Hold.
- Find X10: £821.20 / £876.03 UK-model results are Opened – never used or lack direct item-level verification. Exclude from ordinary used evidence.
- Find X10 Pro Max: pre-owned category result lacks a direct item URL and verified seller/location/condition; direct Gumtree/eBay examples are new/sealed. Hold.
- Motorola Edge 70 Plus: no exact UK used listing found. Other Edge 70 family models/variants are not substitutes.
No prices were estimated and no used evidence was imported. UK-used evidence remains reference-only and excluded from automatic valuation.

## Change boundary
No new evidence rows, product master changes, schema/code/RLS/RPC/Edge Function/Stripe/tenant/customer/order/payment/ownership changes, Worker changes or deployments. No TEST business data was copied to LIVE. See batch 112 for the last shared evidence insertion.
