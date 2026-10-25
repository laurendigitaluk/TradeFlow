# TradeFlow Mobile Phone Catalogue — Batch 76
Date: 25 October 2026

## Summary
Added two UK eBay completed-sale observations for the active Samsung Galaxy S25 Ultra 256GB master product. Exact URL and stable-key preflight was clear in TEST and LIVE. Both rows were inserted in TEST and read back before LIVE insertion; LIVE rows were then read back and verified. No existing evidence or master rows were changed.

## Records added

### Samsung Galaxy S25 Ultra 256GB Silver (SM-S938U1)
- eBay item: https://www.ebay.co.uk/itm/137804587290
- Sold: 4 October 2026 at 14:25 BST (13:25 UTC)
- Current original listing page displayed £570.15 including £17.90 Buyer Protection. An offer option was present, so accepted sale amount and seller proceeds are unconfirmed.
- Seller located in Glasgow, UK.
- Search-index result showed a different price; current original listing page display was used and discrepancy noted.
- Stable key: `mobile-used-sold-galaxys25ultra-256gb-silverbar-ebay-137804587290-20261004`
- TEST master: `1fe06eb6-7261-405c-9b6c-fb757145df1f`; evidence: `68dfb55c-a351-4227-a8a0-af3128bc8dd9`
- LIVE master: `99aee8d7-17a3-40cd-b556-cc7453c535b5`; evidence: `62b58127-e0e3-4427-a276-a04fc63f6590`

### Samsung Galaxy S25 Ultra 256GB Titanium Blue
- eBay item: https://www.ebay.co.uk/itm/278429059814
- Sold: 3 October 2026 at 13:00 BST (12:00 UTC)
- Current original listing page displayed £594.85 including £18.09 Buyer Protection; seller proceeds not independently confirmed.
- Unlocked, described as excellent condition with free postage; seller located in Leicester, UK.
- Search-index result showed a different price; current original listing page display was used and discrepancy noted.
- Stable key: `mobile-used-sold-galaxys25ultra-256gb-titaniumblue-ebay-278429059814-20261003`
- TEST master: `1fe06eb6-7261-405c-9b6c-fb757145df1f`; evidence: `8a5b3a09-e29a-420c-8c00-5d19120383df`
- LIVE master: `99aee8d7-17a3-40cd-b556-cc7453c535b5`; evidence: `226598aa-9f2d-4db1-9dd9-f2dfba0429de`

## Counts verified after Batch 76
Direct Mobile Phones category counts:
- TEST: 246 active phone evidence rows; 152 active rows where `evidence_type='uk_used'` and `availability='sold'`.
- LIVE: 244 active phone evidence rows; 150 active rows where `evidence_type='uk_used'` and `availability='sold'`.
- The two-row TEST/LIVE difference persists.
- Global active duplicate-key aggregation remains outstanding; do not state that a complete global duplicate audit was performed.

## Candidate handling
- Galaxy S25 Ultra item 800756844624 already existed as active evidence in both environments and was not duplicated.
- Galaxy S25 Ultra item 137433982809 was marked “Opened – never used”, so it was not added as ordinary used evidence.
- Galaxy S25 Ultra item 168204541224 had inconsistent search/index and listing-price context and was excluded.
- Item 227413483025 was not inserted during this batch.

## Next
Continue UK completed-sale research. Exact active master match in both environments, exact URL and stable-key preflight, TEST insertion and read-back, then LIVE insertion and read-back. Record price discrepancies and Buyer Protection/Best Offer caveats. Do not create master products during evidence ingestion.
