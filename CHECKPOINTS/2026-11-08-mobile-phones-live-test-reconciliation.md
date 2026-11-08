# Mobile Phones — LIVE/TEST reconciliation checkpoint

Date: 8 November 2026.
Projects: LIVE gxsrajtqzdjvmceqcpgv; TEST nnsshnfkjcflucjrftzi.
Category: mobile-phones.

## Canonical product catalogue
- LIVE: 158 products; TEST: 160 total.
- 158 shared product identities and all compared product metadata now match exactly.
- TEST has two extra audit/verification placeholders, both inactive and hidden:
  - Apple iPhone 18 standard 256 GB, unconfirmed model, now inactive pending official confirmation.
  - Google Pixel 11 128 GB, previously retired as invalid variant, remains inactive.
- TEST product_type normalized to Smartphone to match LIVE.
- No product records deleted or copied into LIVE.

## Evidence
- LIVE and TEST each have 567 active evidence rows: 271 UK new, 296 UK used.
- All 158 active catalogue products have active evidence.
- No active evidence is attached to inactive products.
- Evidence records were not bulk-copied or overwritten; independent capture provenance retained.

## Official source check
Apple's 9 September 2026 official UK announcement confirms iPhone 18 Pro and iPhone 18 Pro Max, not a standard iPhone 18 model:
https://www.apple.com/uk/newsroom/2026/09/apple-debuts-iphone-18-pro-and-iphone-18-pro-max/

## Remaining category-level drift
- 3D Printers & Equipment: 208 LIVE vs 209 TEST products; 260 vs 232 active evidence rows.
- Laptops: 8 products and zero active evidence in TEST; category absent from LIVE.
- Continue category-by-category reconciliation. Do not start the full Gemma worker/agent sweep until the intended catalogues and source-selection configuration are ready.
