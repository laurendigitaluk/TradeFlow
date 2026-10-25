# TradeFlow Mobile Phone Catalogue — Batch 89 Checkpoint
Date: 25 October 2026

## Scope
Added two distinct UK eBay new-condition completed-sale observations for the existing active Apple iPhone 16 Pro Max 256GB master. Both URL and stable-key preflights were clear in TEST and LIVE. TEST was inserted and read back before LIVE. No master products were created or modified.

## Observation 1 — Black Titanium
- Original listing: https://www.ebay.co.uk/itm/176644847651
- Sold: 24 July 2026 at 14:17 BST / 13:17 UTC.
- Apple iPhone 16 Pro Max 256GB Black Titanium, new and unopened.
- Displayed price: £999.00. eBay search result indicated Buyer Protection included; separate fee amount not shown on original listing. Treat as buyer-facing price, not seller proceeds.
- UK business seller in Newcastle upon Tyne, Tyne and Wear; listing stated out of stock / 24 sold.
- Stable key: `mobile-new-sold-iphone16promax-256gb-black-ebay-176644847651-20260724`
- TEST master: `284a24c2-9ae0-468c-b6ac-80e2044f4516`; evidence: `946c5046-d88a-43fa-a347-a3ac0112ceca`.
- LIVE master: `b9d4b016-a231-4dcf-bd31-3f3777a8ba19`; evidence: `30a3ea72-3b36-4f2f-a6c9-10e5b3a65404`.

## Observation 2 — Natural Titanium
- Original listing: https://www.ebay.co.uk/itm/256779530734
- Sold: 10 July 2026 at 07:27 BST / 06:27 UTC.
- Apple iPhone 16 Pro Max 256GB Natural Titanium, factory unlocked, new/sealed, one-year Apple warranty, no charger included.
- Displayed price: £1,149.00; separate fee breakdown not shown on original listing. Treat as buyer-facing price, not seller proceeds.
- UK business seller in Warminster, Wiltshire; listing stated out of stock / 18 sold.
- Stable key: `mobile-new-sold-iphone16promax-256gb-natural-titanium-ebay-256779530734-20260710`
- TEST master: `284a24c2-9ae0-468c-b6ac-80e2044f4516`; evidence: `e11f823f-7b8a-4f0b-a5c4-f56255e0b91d`.
- LIVE master: `b9d4b016-a231-4dcf-bd31-3f3777a8ba19`; evidence: `08b4be71-0a8c-410a-b7d7-125acea2ee31`.

## Verified coverage after Batch 89
- LIVE: 130 active phone products; 73 with active new evidence; 66 with active used evidence; none missing both; 261 active evidence rows; 9 active new/sold rows; 158 active used/sold rows.
- TEST: 133 active phone products; 73 with active new evidence; 68 with active used evidence; one missing both; 263 active evidence rows; 9 active new/sold rows; 160 active used/sold rows.
- TEST/LIVE master-product discrepancy remains unresolved. Global active duplicate-key aggregation and historic source-price discrepancy audits remain open.
- Counts are snapshots; other catalogue agents may add or change evidence.

## Next
Continue researching current new-price evidence for active models/variants without it. Verify exact model and storage, preflight source URL and stable key in both environments, insert/read back TEST before LIVE, and do not create masters during evidence ingestion. For variants absent from current manufacturer UK new line-ups, continue second-hand completed-sale research with condition and Buyer Protection/Best Offer caveats.


## Additional audit flag discovered during continued research
A fresh eBay capture for prior Batch 88 item 307244687330 (iPhone 15 128GB Pink) now displays £289.92 including £9.92 Buyer Protection, whereas the Batch 88 evidence row records £292.00 including £12.00. Do not overwrite the historic row in this batch. Add this item to the open historical source-price discrepancy audit and determine which original page capture/price was valid at sale time before using it for valuation. The current eBay page is https://www.ebay.co.uk/itm/307244687330. Another candidate, iPhone 16e item 178318053825, was excluded from ingestion because the seller feedback is poor and the page/search capture showed a price discrepancy (£258.92 vs £260.61).