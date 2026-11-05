# Mobile Phone Catalogue Reconciliation — Batch 108
Date: 5 November 2026

## Scope
Continue exact-variant UK used-price research and reconcile shared mobile catalogue evidence between TradeFlow LIVE (`gxsrajtqzdjvmceqcpgv`) and TEST (`nnsshnfkjcflucjrftzi`). No code or deployment work.

## Evidence sync completed
Two verified TEST Galaxy S23 128GB observations were copied to the matching LIVE master with the same stable source keys:
- UK-new Idealo UK observation: £274.99, observed 26 October 2026. Source: https://www.idealo.co.uk/compare/202299613/samsung-galaxy-s23-128gb-phantom-black.html. Stable key: `mobile-new-samsung-s23-128gb-idealo-20261026`. LIVE evidence ID `5e5dbb34-7aea-40e7-a6e7-b31dca0e54db`; TEST evidence ID `a528b5a8-e670-48d2-89ab-9f25b8526350`. This is a historical asking-price observation, not a completed sale.
- UK-used completed eBay sale: £160.41 including the £6.90 Buyer Protection fee. Source: https://www.ebay.co.uk/itm/397932077130. Stable key: `mobile-used-ebay-galaxys23-cracked-128gb-397932077130`. LIVE evidence ID `92d69093-ba7b-46df-89b8-505c02a84901`; TEST evidence ID `d3360ca8-50af-4840-8b7a-f46259286283`. Listing is a cracked but fully working Galaxy S23 128GB unlocked, seller located in Cambridge. The TEST price was corrected from £160.35 to £160.41 and condition to `Used - damaged`. Keep as damaged-condition evidence only; do not use as a normal-condition comparable.

## Verified post-write database position
| Metric | LIVE | TEST |
|---|---:|---:|
| Active mobile products | 158 | 159 |
| Customer-visible active products | 156 | 156 |
| Active mobile evidence | 562 | 562 |
| UK-new evidence rows | 266 | 266 |
| UK-used evidence rows | 296 | 296 |
| Products with UK-used evidence | 154 | 154 |
| Active products missing UK-used evidence | 4 | 5 |
| Active products missing all evidence | 0 | 1 |

The product-key difference is one TEST-only `iPhone 18 256 GB` master, currently hidden and unverified with no evidence. Leave it untouched: do not copy it to LIVE, activate/publish it, deactivate it, or delete it without independent product verification and a separate decision. The four common UK-used evidence gaps are:
1. Motorola Edge 70 Plus — 256GB
2. OPPO Find X10 — 256GB
3. OPPO Find X10 Pro Max — 512GB
4. OPPO Reno16 F 5G — 256GB

## Research performed and exclusions
- Motorola Edge 70 Plus 256GB: UK new-price references found; used results were other Edge 70 variants, not the Plus 256GB.
- OPPO Find X10 256GB: surfaced offers were new or opened-never-used; no qualifying UK used listing verified.
- OPPO Find X10 Pro Max 512GB: a pre-owned search lead lacked a verified direct item URL/location; other matching offers were opened-never-used or overseas. Do not insert the unverified lead.
- OPPO Reno16 F 5G 256GB: surfaced UK listings were new/sealed. A £287 buyback quote was for Reno16, not Reno16 F, so it is not evidence for this master.
- Do not count new or opened-never-used as used; do not use overseas offers, adjacent variants, generic category pages as item-level evidence, or trade-in quotes as consumer resale prices.

## Rules preserved
- Exact model and storage/package variant; UK market only; GBP only.
- Preserve listing condition and distinguish asking prices, refurbished retail, completed sales, damaged devices and trade-in/buyback quotes.
- Use direct, verifiable source URLs and observed dates; no inferred prices or model substitutions.
- UK-used evidence is reference-only and does not feed automatic buying valuation.
- Keep TEST and LIVE tenant/customer/ownership/payment data separate. Only the shared catalogue observations above were reconciled.

## Change boundary
No application code, schema, valuation logic, RLS, RPC, Edge Function, Stripe, tenant/customer/order/payment/ownership or Cloudflare Worker changes. No Worker deployment.

## Next action
Continue targeted searches for the four shared used-evidence gaps. Before any further write, rerun both environment gap queries, verify exact product IDs locally, preflight source-key uniqueness, insert separately into each environment, and read back both results.
