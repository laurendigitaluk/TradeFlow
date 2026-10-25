# TradeFlow Mobile Phone Catalogue — Batch 73
Date: 25 October 2026

## Summary
Added three UK eBay used completed-sale observations to TEST and LIVE, using exact active master product matches. Each listing URL and stable key was clear in both environments before insertion. Each TEST insert was read back before the corresponding LIVE insert; all six inserted rows were then read back and verified.

## Records added

### Samsung Galaxy S25 128GB Grey, unlocked
- eBay item: https://www.ebay.co.uk/itm/158245363724
- Sold: 6 September 2026, 22:00 BST (21:00 UTC)
- Displayed total: £345.00, shown as including Buyer Protection; separate fee and seller proceeds not confirmed
- Listing states 100% battery health
- Stable key: `mobile-used-sold-galaxys25-128gb-grey-ebay-158245363724-20260906`
- TEST master: `b2bd7aa9-4591-44eb-b11e-0a85ef51aaa6`; evidence: `ff04ab4f-71e5-444d-a82b-95f367c73f4a`
- LIVE master: `18628bef-a06b-42e6-9ca4-01d787ead33b`; evidence: `a0459129-e739-4051-8269-9350a0f0e7ed`

### Samsung Galaxy S25 256GB
- eBay item: https://www.ebay.co.uk/itm/206384194701
- Sold: 5 July 2026, 23:19 BST (22:19 UTC)
- Displayed listing amount: £389.99; Best Offer accepted, so accepted price and seller proceeds are unconfirmed
- Listing states fully working and 100% battery health
- Stable key: `mobile-used-sold-galaxys25-256gb-ebay-206384194701-20260705`
- TEST master: `a5730c3d-21c7-459d-91f6-b2fc49e9dcd1`; evidence: `2879f045-5682-4b2a-bb31-391087f862b4`
- LIVE master: `45854c43-9c3c-479c-9f35-714d9bb426f4`; evidence: `24482c2d-61cb-4060-b5ea-4219c11ad28a`

### Samsung Galaxy S25 128GB
- eBay item: https://www.ebay.co.uk/itm/128101722692
- Sold: 28 September 2026, 13:42 BST (12:42 UTC)
- Displayed buyer-facing total: £347.18 including £11.18 Buyer Protection; Best Offer accepted, accepted seller price/proceeds unconfirmed
- Stable key: `mobile-used-sold-galaxys25-128gb-ebay-128101722692-20260928`
- TEST master: `b2bd7aa9-4591-44eb-b11e-0a85ef51aaa6`; evidence: `602b8e6b-fb50-4b40-95fa-82062110cf10`
- LIVE master: `18628bef-a06b-42e6-9ca4-01d787ead33b`; evidence: `bb716bf6-0d53-434e-b529-04c51a7269f9`

## Counts verified after Batch 73
Counts were directly queried by the Mobile Phones category in each environment:
- TEST: 241 active phone evidence rows; 147 active rows where `evidence_type='uk_used'` and `availability='sold'`.
- LIVE: 239 active phone evidence rows; 145 active rows where `evidence_type='uk_used'` and `availability='sold'`.
- The two-row TEST/LIVE difference persists.
- Full global active duplicate-key aggregation was blocked by the tool safety layer during this batch. Exact URL/key preflight was clear for each of these three new records and the inserted rows were read back; do not state that a complete global duplicate audit was performed.

## Other candidates
Two Galaxy S24 Ultra listings surfaced in research, but the exact Galaxy S24 Ultra master variant was not present in either environment, so no evidence was inserted for those items. Do not create a new master product as part of evidence ingestion without separately confirming the catalogue-seeding workflow.

## Next steps
Continue UK completed-sale research. Confirm exact active master model/storage match in TEST and LIVE; preflight both URL and stable key; insert TEST and read back; only then insert LIVE and read back. Keep Buyer Protection amounts and Best Offer uncertainty explicit. Re-run the global duplicate-key audit when the SQL query path permits it.
