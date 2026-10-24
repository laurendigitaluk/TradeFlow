# Mobile phone catalogue — Batch 61
Date: 24 October 2026

## Added evidence
- Product: Apple iPhone 15 Pro 128GB Black Titanium
- Source: https://www.ebay.co.uk/itm/900018786339
- Sale date: 19 October 2026
- Displayed buyer-facing total: £404.50, including £14.50 Buyer Protection
- Listing title describes mint condition and 100% battery health; no charger included. Seller proceeds are not independently confirmed.
- Stable key: `mobile-used-sold-iphone15pro-128gb-black-100bh-ebay-900018786339-20261019`
- TEST master: `0ba2c8a6-b0b5-45d3-93f1-362597c1cdfe`; evidence ID: `30580208-5cdb-4c82-8337-e2cc13d7d063`
- LIVE master: `8c3787c6-fd0e-4f3b-af7a-a628f3ae4d16`; evidence ID: `d853dc91-35e1-42aa-9fdc-bb9552f1117e`
- Global source URL and stable-key preflights were empty in both environments. TEST-first then LIVE insert responses succeeded; separate read-back verified one active row in each environment.

## Candidate screened but not duplicated
- Google Pixel 9 128GB Obsidian, eBay item 820179580133, £279.58 displayed including £9.58 Buyer Protection, sold 29 September 2026. This URL already exists in both TEST and LIVE under two keys, including the sold-record key `mobile-used-sold-pixel9-128gb-ebay-820179580133-20260929`. No insert was attempted.

## Counts
- TEST active phone evidence: 225
- LIVE active phone evidence: 223
- Two-row environment difference persists.
- Last refreshed active `uk_used` + `sold` counts before this batch: TEST 130, LIVE 128. Not refreshed in Batch 61.
- Last stable-key audit found zero duplicate active non-null source keys in both environments. Re-run after more batches if useful; URL repeats alone may be valid for generic category pages.

## Process
Continue global URL/key preflight, exact model/storage master matching, TEST-first, LIVE second, and read-after-write verification. Record Buyer Protection as part of buyer-facing totals, not seller net proceeds.
