# 3D Printer Catalogue — Batch 6 Checkpoint

**Date:** 5 November 2026  
**Repository:** laurendigitaluk/TradeFlow  
**TEST branch:** main  
**LIVE branch:** production  
**TEST Supabase:** nnsshnfkjcflucjrftzi  
**LIVE Supabase:** gxsrajtqzdjvmceqcpgv  

## Category and branch

No new category or branch was created.

| Record | TEST | LIVE |
|---|---|---|
| 3D Printers & Equipment category | cc35aadb-5c1e-439b-8cf9-70ac07e82044 | ab8b13b0-b070-4534-838b-3ebd4d7261e5 |
| 3D Printers branch | b716ae40-d711-4a0a-a72c-9cf19fee880a | 59873baa-da84-461c-a8c3-4b8fd4359bcb |
| FLSUN manufacturer | 9fa0aba4-a134-4fbe-93a9-48fdab8e7c95 | a89f5624-73f6-411d-bc02-3869792737a0 |

## Added products and evidence

| Product/package | TEST product UUID | LIVE product UUID | TEST evidence UUID | LIVE evidence UUID | GBP | Availability |
|---|---|---|---|---|---:|---|
| FLSUN S1 — Standard Printer | da33941a-a582-4900-b57d-110916e74f1f | 68f91fbb-51e7-413f-8dc3-919a9d38bb13 | bd404e1d-84ec-4634-a7f8-ac06c9a26aee | 3db80ae8-2d92-4d50-89e7-b77691130ef1 | 499 | In stock |
| FLSUN T1 — Standard Printer | 272c87dc-109c-4a20-a05b-2f8818b02a7d | 96905670-8b75-415b-afa1-c1183af01287 | 1793ead3-4685-4d10-860a-5676b30e8c6b | 7cc89553-82f2-4378-b783-0b13e2ebaa0e | 500 | Backordered; available to order |
| FLSUN S1 Pro — Standard Printer | cff0a969-604b-424c-918b-ff845d7c6d2d | 8af5fb40-64d1-4e92-9d94-b70c2b1ee5b2 | 4c4d79a1-a523-40aa-baa1-f399d224bfc4 | 8c797bde-5cfb-4b57-9e2e-5bcf615c1708 | 1,299 | Out of stock |
| FLSUN T1-PRO — Standard Printer | 6f81c5b0-1349-4561-a209-6b51d1b22f8b | f096c6d4-b4f9-444b-a43d-4778e9367667 | d1fbb166-44b0-4c81-99fe-1149d8bfc5aa | e1b3093c-55d2-4e2b-945e-0ca27d0d0097 | 509 | Out of stock |

Evidence sources:

- FLSUN S1, 3D Prima UK: https://www.3dprima.co.uk/flsun-s1-high-speed-3d-printer-12151
- FLSUN T1, 123-3D UK: https://www.123-3d.co.uk/collections/3d-printers-fdm-printers/products/flsun-t1-delta-3d-printer
- FLSUN S1 Pro, FLSUN UK Store: https://uk.store.flsun3d.com/products/flsun-s1-pro
- FLSUN T1-PRO, FLSUN UK Store: https://uk.store.flsun3d.com/products/flsun-t1-pro

All four records are uk_new, condition New, currency GBP. The source status is preserved: the T1 is backordered and S1 Pro/T1-PRO pages show out of stock. Retailer asking prices are not completed sales.

## Final independent verification — TEST and LIVE

| Metric | TEST | LIVE |
|---|---:|---:|
| Active master products | 132 | 132 |
| Active customer-visible products | 132 | 132 |
| Active evidence rows | 145 | 145 |
| Active uk_new evidence | 130 | 130 |
| Active uk_used evidence | 15 | 15 |
| Visible products missing evidence | 0 | 0 |
| Visible products missing branch | 0 | 0 |
| Duplicate active source keys | 0 | 0 |
| Missing evidence URLs | 0 | 0 |
| Missing source keys | 0 | 0 |
| Non-positive prices | 0 | 0 |
| Non-GBP evidence | 0 | 0 |
| uk_new rows with non-New condition | 0 | 0 |

Manufacturer counts are identical in both environments: Anycubic 18, Bambu Lab 26, Creality 13, Elegoo 12, Flashforge 3, FLSUN 4, Formlabs 9, Phrozen 13, Prusa Research 1, QIDI 12, Raise3D 10, Snapmaker 3 and Ultimaker 8.

## Scope and memory note

No application code, schema, valuation logic, RLS, Edge Functions, Stripe, tenant/customer/order/payment data or Cloudflare Worker deployment changed. No Worker deployment required.

The accessible Supabase schemas contain no project-memory or checkpoint table; platform_ai_settings contains provider settings only and was not repurposed. The GitHub project-memory and checkpoint files are updated in both TEST (main) and LIVE (production) branches. Do not invent or write a new database memory structure as part of catalogue work.


### FLSUN evidence freshness correction — 5 November 2026

Final source review found that the official FLSUN UK Store S1 Pro and T1-PRO pages were last crawled about five months before this review. Their £1,299 and £509 observations are retained as historical price references only: observed_at is NULL, availability is “Historical listing; current availability unconfirmed”, and their source keys are marked historical. Do not present either as a current available offer. The S1 Pro direct page could not be fetched during review.

A newer UK T1-PRO retailer observation was added separately: 3DShop UK £365.00, marked in stock and ready for dispatch (page last crawled about four weeks before review), https://3dshop.uk/shop/flsun-t1pro/. TEST evidence UUID b7fb29b9-4d1c-4928-9f10-b9cb90dbf862; LIVE evidence UUID a35fd5f9-72ad-4314-9230-b01a08756517. The older FLSUN UK £509 record remains historical and is not merged with the 3DShop offer.

Latest independent TEST/LIVE snapshot supersedes the earlier Batch 6 total: 132 active customer-visible products; 146 active evidence rows (131 uk_new / 15 uk_used); zero missing evidence or branch; zero duplicate active source keys; zero missing URLs/keys, invalid prices, non-GBP evidence or uk_new condition mismatches.
