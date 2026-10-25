# TradeFlow Mobile Phone Catalogue — Batch 88 Checkpoint
Date: 25 October 2026

## Lifecycle review and second-hand evidence
Reviewed active phone variants that had no active UK new-price evidence. Current manufacturer UK line-ups were checked:
- Apple UK buy page: https://www.apple.com/uk/shop/buy-iphone — iPhone 13/14/15 families are absent from the current new-device line-up.
- Google Store UK phone line-up: https://store.google.com/gb/category/phones?hl=en-GB — Pixel 8/9 families are absent from the current line-up.
- Samsung UK S-series guide: https://www.samsung.com/uk/mobile-phone-buying-guide/best-samsung-s-series-phone/ — S22/S23/S24 are prior-generation ranges; Samsung notes older models may no longer be available to buy from Samsung as new models.

For active variants among these families that lacked active `uk_new` evidence, appended lifecycle-review notes with source URL and date in both TEST and LIVE. Wording explicitly says cessation of manufacturing is not independently confirmed; status is discontinued from the current manufacturer UK retail line-up for new-price research. Masters remain active for valuation. This was a notes-only update; no schema change and no master deactivation.

## Observation added — Apple iPhone 15 128GB Pink
- Original listing: https://www.ebay.co.uk/itm/307244687330
- Sold: 23 October 2026 at 11:07 BST / 10:07 UTC.
- Used condition; Pink; 128GB; model A3090/MTP13ZD/A; private seller in Ipswich, UK.
- Displayed £292.00 including £12.00 Buyer Protection. Buyer-facing total, not seller proceeds.
- Best Offer option shown, but no explicit acceptance notice appeared in captured page; accepted-price uncertainty retained.
- Stable key: `mobile-used-sold-iphone15-128gb-pink-ebay-307244687330-20261023`
- TEST master: `5ec2f627-4880-4ff1-bd03-559dde3db510`; evidence: `49c7213e-c63b-43a8-99d7-aa14d371983e`.
- LIVE master: `c9d0c053-8a12-4809-b2c8-69cef071f63b`; evidence: `ed16e210-e9fb-416b-b7c0-b450d4c36c1a`.

## Verified coverage after Batch 88
- LIVE: 130 active phone products; 72 with active new evidence; 66 with active used evidence; 0 missing both; 259 active evidence rows; 158 active used/sold rows; 18 active products have lifecycle-review notes.
- TEST: 133 active phone products; 72 with active new evidence; 68 with active used evidence; 1 missing both; 261 active evidence rows; 160 active used/sold rows; 19 active products have lifecycle-review notes.
- TEST/LIVE product-master discrepancy, global active duplicate-key aggregation and historical source-price audits remain open. Counts are fresh snapshots and may change if other agents update the catalogue.

## Next
Continue new-price research for variants that remain in current manufacturer UK line-ups. Where no new evidence is found, verify lifecycle status before marking the variant discontinued for new-price research, then prioritise UK second-hand completed-sale evidence. Preserve exact storage, condition, Buyer Protection and Best Offer caveats. TEST-first, then LIVE; never create masters during evidence ingestion.
