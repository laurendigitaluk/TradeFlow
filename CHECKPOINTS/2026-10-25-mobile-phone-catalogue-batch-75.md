# TradeFlow Mobile Phone Catalogue — Batch 75
Date: 25 October 2026

## Summary
Added two UK eBay completed-sale observations for the active Samsung Galaxy S25 Ultra 256GB master product. Exact source URL and stable-key preflight was clear in TEST and LIVE. Both rows were inserted in TEST and read back before LIVE insertion; LIVE rows were then read back and verified. No existing evidence or master records were modified.

## Records added

### Samsung Galaxy S25 Ultra 256GB Titanium Black
- eBay item: https://www.ebay.co.uk/itm/137643944477
- Sold: 21 August 2026 at 09:37 BST (08:37 UTC)
- Displayed buyer-facing total: £572.95 including £17.95 Buyer Protection; seller proceeds not confirmed
- Boxed; title describes great condition; UK seller located in Chesterfield
- Stable key: `mobile-used-sold-galaxys25ultra-256gb-titanium-black-ebay-137643944477-20260821`
- TEST master: `1fe06eb6-7261-405c-9b6c-fb757145df1f`; evidence: `974e9083-f2e2-4d91-b8e4-a7d7cc3f21dd`
- LIVE master: `99aee8d7-17a3-40cd-b556-cc7453c535b5`; evidence: `6a720308-c47f-4dcb-8e6d-e7f5a39ce464`

### Samsung Galaxy S25 Ultra 256GB Titanium White
- eBay item: https://www.ebay.co.uk/itm/168615919758
- Sold: 16 August 2026 at 11:23 BST (10:23 UTC)
- Displayed buyer-facing total: £516.84 including £16.84 Buyer Protection; seller proceeds not confirmed
- Factory unlocked, dual SIM; no charger included; UK seller located in Blackpool
- Stable key: `mobile-used-sold-galaxys25ultra-256gb-titanium-white-ebay-168615919758-20260816`
- TEST master: `1fe06eb6-7261-405c-9b6c-fb757145df1f`; evidence: `54b6d3bd-53ff-4263-87b5-9eb4b583d4f0`
- LIVE master: `99aee8d7-17a3-40cd-b556-cc7453c535b5`; evidence: `cca87524-34bf-4355-a4c1-d94f3e3b836a`

## Counts verified after Batch 75
Direct Mobile Phones category counts:
- TEST: 244 active phone evidence rows; 150 active rows where `evidence_type='uk_used'` and `availability='sold'`.
- LIVE: 242 active phone evidence rows; 148 active rows where `evidence_type='uk_used'` and `availability='sold'`.
- The two-row TEST/LIVE difference persists.
- Global active duplicate-key aggregation remains outstanding; do not state that a complete global duplicate audit was performed.

## Research exclusions
- Pixel 10 Pro 256GB eBay item 307091345876 was already present as active evidence in both environments; not duplicated.
- Pixel 10 Pro 128GB Porcelain item 178264125925 is marked “Opened – never used”; the exact active 128GB master was absent, so it was not added.
- Pixel 10 Pro Fold 256GB item 257739236306 had no matching active master in either environment, so it was not added.
- Samsung Galaxy S25 Ultra item 168204541224 was excluded because the sold search result and currently viewable/relisted page showed inconsistent prices; no observation was inserted.

## Next steps
Continue UK completed-sale research. Confirm exact active master match in TEST and LIVE; preflight exact URL and stable key; insert and read back TEST first; then insert and read back LIVE. Preserve Buyer Protection and accepted-offer caveats. Revisit global duplicate-key audit when supported.
